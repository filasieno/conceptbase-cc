#!/usr/bin/env bash
# Nix-adapted CB_AutoTest: run the .cbs regression corpus via cbshell against ConceptBase.
set -euo pipefail

: "${CB_PORTNR:=4001}"
: "${CB_EXAMPLES:?CB_EXAMPLES must point at examples-corpus share}"
: "${CBSERVER:?CBSERVER must point at cbserver launcher}"

SCRIPTDIR="${CB_TESTCLIENT:-/share/cb-testclient}/scripts"
LOGDIR="${CB_TESTCLIENT_LOGDIR:-/tmp/cb-testclient-log}"
WORKDIR="${CB_AUTOTEST_WORKDIR:-$PWD}"
# Per-script wall-clock budget (the cbshell run). Kept generous but finite so a
# single hung script can never wedge the whole suite. Override via env.
SCRIPT_TIMEOUT="${CB_AUTOTEST_TIMEOUT:-600}"
# Grace period after SIGTERM before timeout escalates to SIGKILL.
SCRIPT_KILL_GRACE="${CB_AUTOTEST_KILL_GRACE:-30}"
# Hard ceiling for the entire suite. 0 disables. Enforced between scripts.
GLOBAL_TIMEOUT="${CB_AUTOTEST_GLOBAL_TIMEOUT:-1800}"
SUITE_START="$(date +%s)"

mkdir -p "$LOGDIR"
cd "$WORKDIR"

# Job control so every backgrounded cbserver becomes its own process-group
# leader; this lets stop_cbserver kill the launcher *and* its CBserver child as
# a group, instead of relying on a host-wide pkill that would also take down
# unrelated servers.
set -m 2>/dev/null || true

export CB_PORTNR
export CB_WORK="$CB_EXAMPLES"
export CB_SHELL_ENABLE_LPI="${CB_SHELL_ENABLE_LPI:-1}"

server_pid=""
server_log=""

# Always reclaim the server on any exit path (normal, error, or signal) so we
# never leak orphaned cbserver processes holding the port.
trap 'stop_cbserver 2>/dev/null || true' EXIT
trap 'echo "cb-autotest: interrupted" >&2; stop_cbserver 2>/dev/null || true; exit 130' INT TERM

check_global_deadline() {
  [[ "$GLOBAL_TIMEOUT" -gt 0 ]] || return 0
  local now elapsed
  now="$(date +%s)"
  elapsed=$((now - SUITE_START))
  if [[ "$elapsed" -ge "$GLOBAL_TIMEOUT" ]]; then
    echo "cb-autotest: global timeout (${GLOBAL_TIMEOUT}s) exceeded after ${elapsed}s — aborting" >&2
    stop_cbserver 2>/dev/null || true
    exit 1
  fi
}

run_cbshell() {
  if [[ -n "${JAVA:-}" && -n "${CB_JAR:-}" ]]; then
    "$JAVA" \
      -DCB_HOME="${CB_HOME:-}" \
      -DCB_PORTNR="$CB_PORTNR" \
      -cp "$CB_JAR" \
      i5.cb.CBShell "$@"
  elif [[ -n "${CBSHELL:-}" ]]; then
    CB_HOME="${CB_HOME:-}" CB_PORTNR="$CB_PORTNR" "$CBSHELL" "$@"
  else
    echo "cb-autotest: set JAVA+CB_JAR or CBSHELL" >&2
    return 1
  fi
}

run_cbshell_timed() {
  if [[ -n "${JAVA:-}" && -n "${CB_JAR:-}" ]]; then
    timeout -k "$SCRIPT_KILL_GRACE" "$SCRIPT_TIMEOUT" "$JAVA" \
      -DCB_HOME="${CB_HOME:-}" \
      -DCB_PORTNR="$CB_PORTNR" \
      -cp "$CB_JAR" \
      i5.cb.CBShell "$@"
  else
    timeout -k "$SCRIPT_KILL_GRACE" "$SCRIPT_TIMEOUT" run_cbshell "$@"
  fi
}

extract_start_server_args() {
  local script="$1"
  local line
  line=$(tr -d '\r' <"$script" | grep -E '^[[:space:]]*startServer|^[[:space:]]*cbserver' | head -1 || true)
  if [[ -z "$line" ]]; then
    echo "-u nonpersistent"
    return
  fi
  echo "$line" | tr -d '\r' | sed -E 's/^[[:space:]]*(startServer|cbserver)[[:space:]]+//;s/[[:space:]]+-port[[:space:]]+[0-9]+//;s/[[:space:]]+-p[[:space:]]+[0-9]+//'
}

rewrite_cbs() {
  local src="$1"
  # Legacy scripts reference two install roots via $CB_WORK / $CB_HOME:
  #   $CB_WORK/examples/<X>  → example models   → $CB_EXAMPLES (already .../examples)
  #   $CB_WORK/lib/<X>       → system models    → system-data dir (sibling of SML1)
  # $CB_EXAMPLES already ends in /examples, so a bare "$CB_WORK" + "/examples"
  # would double the segment; map the specific prefixes BEFORE the bare fallback.
  local sysdir="${CB_SYSTEM_DIR:-}"
  if [[ -z "$sysdir" && -n "${SYSTEM_SML1:-}" ]]; then
    sysdir="$(dirname "$SYSTEM_SML1")"
  fi
  : "${sysdir:=$CB_EXAMPLES/lib}"
  sed \
    -e "s|\$CB_WORK/lib|$sysdir|g" \
    -e "s|\$CB_WORK/examples|$CB_EXAMPLES|g" \
    -e "s|\$CB_HOME/examples|$CB_EXAMPLES|g" \
    -e "s|\$CB_WORK|$CB_EXAMPLES|g" \
    -e 's|RULES+CONSTRAINTS|RULES-AND-CONSTRAINTS|g' \
    -e 's/^startServer.*/connect 127.0.0.1 '"$CB_PORTNR"'/I' \
    -e 's/^cbserver.*/connect 127.0.0.1 '"$CB_PORTNR"'/I' \
    -e "s|localhost 6387|127.0.0.1 $CB_PORTNR|g" \
    -e "s|localhost $CB_PORTNR|127.0.0.1 $CB_PORTNR|g" \
    "$src"
}

prepare_script_workspace() {
  local cur="$1"
  case "$cur" in
    ECArules)
      rm -rf ECArules
      mkdir -p ECArules
      cp -a "$CB_EXAMPLES/ECArules/"*.lpi ECArules/ 2>/dev/null || true
      ;;
    AnswerFormat)
      rm -rf AnswerFormat
      mkdir -p AnswerFormat
      cp -a "$CB_EXAMPLES/AnswerFormat/"*.lpi AnswerFormat/ 2>/dev/null || true
      ;;
    BuiltinQueries)
      rm -rf BuiltinQueries
      mkdir -p BuiltinQueries
      cp -a "$CB_EXAMPLES/BuiltinQueries/"*.lpi BuiltinQueries/ 2>/dev/null || true
      ;;
  esac
}

cleanup_script_workspace() {
  local cur="$1"
  rm -rf "$cur" ECArules AnswerFormat BuiltinQueries
  rm -f error.log stat.log ok.log
}

check_error_log() {
  local cur="$1"
  if [[ -s error.log ]]; then
    echo "cb-autotest: $cur reported answer deviations (error.log):" >&2
    cat error.log >&2
    return 1
  fi
  return 0
}

start_cbserver_for_script() {
  local args_line="$1"
  stop_cbserver
  server_log="$(mktemp)"
  # shellcheck disable=SC2086
  "$CBSERVER" $args_line -p "$CB_PORTNR" >"$server_log" 2>&1 &
  server_pid=$!
  ready=0
  for _ in $(seq 1 180); do
    if grep -q "CBserver ready on host" "$server_log" 2>/dev/null; then
      ready=1
      break
    fi
    # Fail fast on a port-bind conflict instead of waiting out the full loop.
    if grep -qiE "Unable to bind socket|Address already in use" "$server_log" 2>/dev/null; then
      echo "cb-autotest: cbserver could not bind port $CB_PORTNR (already in use?)" >&2
      tail -40 "$server_log" >&2 || true
      return 1
    fi
    if ! kill -0 "$server_pid" 2>/dev/null; then
      echo "cb-autotest: cbserver exited early" >&2
      tail -40 "$server_log" >&2 || true
      return 1
    fi
    sleep 1
  done
  if [[ "$ready" -ne 1 ]]; then
    echo "cb-autotest: cbserver did not become ready" >&2
    tail -40 "$server_log" >&2 || true
    return 1
  fi
}

stop_cbserver() {
  if [[ -n "${server_pid:-}" ]]; then
    # Kill the whole process group (launcher + its CBserver child). With job
    # control (set -m) server_pid is the group leader, so -PID targets both.
    kill -TERM -- "-$server_pid" 2>/dev/null || kill -TERM "$server_pid" 2>/dev/null || true
    # Also reap any direct children in case job control was unavailable.
    pkill -P "$server_pid" 2>/dev/null || true
    for _ in $(seq 1 "${SCRIPT_KILL_GRACE:-30}"); do
      kill -0 "$server_pid" 2>/dev/null || break
      sleep 1
    done
    kill -KILL -- "-$server_pid" 2>/dev/null || kill -KILL "$server_pid" 2>/dev/null || true
    wait "$server_pid" 2>/dev/null || true
    server_pid=""
  fi
  rm -f "${server_log:-}"
  # Scoped safety net: only reap servers bound to *our* port, never host-wide.
  pkill -f "CBserver .*-p ${CB_PORTNR}( |\$)" 2>/dev/null || true
  sleep 1
}

run_cbs() {
  local script="$1"
  local cur="$2"
  local tmp args_line
  args_line=$(extract_start_server_args "$script")
  tmp="$(mktemp)"
  rewrite_cbs "$script" >"$tmp"
  rm -f error.log stat.log ok.log
  if ! start_cbserver_for_script "$args_line"; then
    rm -f "$tmp"
    return 1
  fi
  if ! run_cbshell_timed -l -f "$tmp"; then
    stop_cbserver
    rm -f "$tmp"
    echo "cb-autotest: cbshell failed on $cur" >&2
    return 1
  fi
  stop_cbserver
  rm -f "$tmp"
  check_error_log "$cur"
}

SMOKE_SCRIPTS=(
  BuiltinQueries.cbs
  Modules.cbs
  FLIGHT_100.cbs
)

if [[ "${CB_AUTOTEST_FULL:-0}" == "1" ]]; then
  mapfile -t SCRIPTS < <(find "$SCRIPTDIR" -maxdepth 1 -name '*.cbs' | LC_ALL=C sort)
else
  SCRIPTS=()
  for name in "${SMOKE_SCRIPTS[@]}"; do
    SCRIPTS+=("$SCRIPTDIR/$name")
  done
fi

stop_cbserver

failures=0
for f in "${SCRIPTS[@]}"; do
  [[ -f "$f" ]] || continue
  check_global_deadline
  cur="$(basename "$f" .cbs)"
  echo "cb-autotest: running $cur"
  prepare_script_workspace "$cur"
  if run_cbs "$f" "$cur"; then
    [[ -f error.log ]] && mv error.log "$LOGDIR/error.$cur"
    [[ -f stat.log ]] && mv stat.log "$LOGDIR/stat.$cur"
    cleanup_script_workspace "$cur"
  else
    [[ -f error.log ]] && cp error.log "$LOGDIR/error.$cur" || true
    [[ -f stat.log ]] && cp stat.log "$LOGDIR/stat.$cur" || true
    cleanup_script_workspace "$cur"
    failures=$((failures + 1))
  fi
done

stop_cbserver

if [[ "$failures" -gt 0 ]]; then
  echo "cb-autotest: $failures script(s) failed" >&2
  exit 1
fi

echo "cb-autotest: all scripts passed"
