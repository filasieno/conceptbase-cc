#!/usr/bin/env bash
# Maximally complete ConceptBase regression: CB_TestClient .cbs corpus + ticket .cbs.txt scripts.
set -euo pipefail

: "${CB_EXAMPLES:?}"
: "${CB_HOME:?}"
: "${CB_TESTCLIENT:?}"
: "${CB_TESTCLIENT_LOGDIR:?}"
: "${JAVA:?}"
: "${CB_JAR:?}"
: "${CBSERVER:?}"
export SYSTEM_SML1="${SYSTEM_SML1:-}"

CB_PORTNR="${CB_PORTNR:-4001}"
TICKET_TIMEOUT="${REGRESSION_TICKET_TIMEOUT:-600}"
AUTOTEST_TIMEOUT="${CB_AUTOTEST_TIMEOUT:-600}"
KILL_GRACE="${REGRESSION_KILL_GRACE:-30}"
# Hard ceiling for the entire regression run (both phases). 0 disables.
GLOBAL_TIMEOUT="${REGRESSION_GLOBAL_TIMEOUT:-3600}"
SUITE_START="$(date +%s)"
TICKET_DIR="${REGRESSION_TICKET_DIR:-}"

# Job control so each backgrounded cbserver is its own process-group leader,
# enabling reliable group-scoped teardown (see stop_cbserver).
set -m 2>/dev/null || true

export CB_PORTNR CB_EXAMPLES CB_HOME CB_TESTCLIENT CB_TESTCLIENT_LOGDIR
export CB_SHELL_ENABLE_LPI=1
export JAVA CB_JAR
export CB_AUTOTEST_TIMEOUT="$AUTOTEST_TIMEOUT"
export CB_AUTOTEST_KILL_GRACE="$KILL_GRACE"
# Propagate the remaining global budget to the Phase-1 autotest sub-run.
export CB_AUTOTEST_GLOBAL_TIMEOUT="$GLOBAL_TIMEOUT"
export CB_AUTOTEST_FULL=1

check_global_deadline() {
  [[ "$GLOBAL_TIMEOUT" -gt 0 ]] || return 0
  local now elapsed
  now="$(date +%s)"
  elapsed=$((now - SUITE_START))
  if [[ "$elapsed" -ge "$GLOBAL_TIMEOUT" ]]; then
    echo "regression: global timeout (${GLOBAL_TIMEOUT}s) exceeded after ${elapsed}s — aborting" >&2
    stop_cbserver 2>/dev/null || true
    exit 1
  fi
}

REGRESSION_WORK="${REGRESSION_WORK:-$CB_TESTCLIENT_LOGDIR/work}"
mkdir -p "$REGRESSION_WORK" "$CB_TESTCLIENT_LOGDIR/tickets"
cd "$REGRESSION_WORK"

run_cbshell() {
  "$JAVA" \
    -DCB_HOME="$CB_HOME" \
    -DCB_PORTNR="$CB_PORTNR" \
    -cp "$CB_JAR" \
    i5.cb.CBShell "$@"
}

run_cbshell_timed() {
  timeout -k "$KILL_GRACE" "$TICKET_TIMEOUT" "$JAVA" \
    -DCB_HOME="$CB_HOME" \
    -DCB_PORTNR="$CB_PORTNR" \
    -cp "$CB_JAR" \
    i5.cb.CBShell "$@"
}

# Extract the server flags a ticket script intended (e.g. "-st off", "-c transient")
# from its leading startServer/cbserver line, stripping any port option (the
# harness supplies its own -p). Some scripts (e.g. BigFlights) define
# intentionally unstratified queries and require "-st off"; ignoring their flags
# makes the server start with default "-st on" and the query reports a
# stratification violation instead of the documented answer.
extract_start_server_args() {
  local script="$1" line
  # Ticket .cbs.txt files from the BIM archive often use CRLF; a trailing \r on
  # e.g. "-t high" becomes "-t high\r" and cbserver rejects the tracemode.
  line=$(tr -d '\r' <"$script" | grep -E '^[[:space:]]*startServer|^[[:space:]]*cbserver' | head -1 || true)
  if [[ -z "$line" ]]; then
    echo "-u nonpersistent"
    return
  fi
  echo "$line" | tr -d '\r' | sed -E 's/^[[:space:]]*(startServer|cbserver)[[:space:]]+//;s/[[:space:]]+-port[[:space:]]+[0-9]+//;s/[[:space:]]+-p[[:space:]]+[0-9]+//'
}

start_cbserver() {
  local args_line="${1:--u nonpersistent}"
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
    if grep -qiE "Unable to bind socket|Address already in use" "$server_log" 2>/dev/null; then
      echo "regression: cbserver could not bind port $CB_PORTNR (already in use?)" >&2
      tail -40 "$server_log" >&2 || true
      return 1
    fi
    if ! kill -0 "$server_pid" 2>/dev/null; then
      echo "regression: cbserver exited early" >&2
      tail -40 "$server_log" >&2 || true
      return 1
    fi
    sleep 1
  done
  if [[ "$ready" -ne 1 ]]; then
    echo "regression: cbserver did not become ready on port $CB_PORTNR" >&2
    tail -40 "$server_log" >&2 || true
    return 1
  fi
}

stop_cbserver() {
  if [[ -n "${server_pid:-}" ]]; then
    # Kill the launcher and its CBserver child as a process group.
    kill -TERM -- "-$server_pid" 2>/dev/null || kill -TERM "$server_pid" 2>/dev/null || true
    pkill -P "$server_pid" 2>/dev/null || true
    for _ in $(seq 1 "$KILL_GRACE"); do
      kill -0 "$server_pid" 2>/dev/null || break
      sleep 1
    done
    kill -KILL -- "-$server_pid" 2>/dev/null || kill -KILL "$server_pid" 2>/dev/null || true
    wait "$server_pid" 2>/dev/null || true
    server_pid=
  fi
  rm -f "${server_log:-}"
  # Scoped to our port only — never a host-wide pkill.
  pkill -f "CBserver .*-p ${CB_PORTNR}( |\$)" 2>/dev/null || true
  sleep 1
}

trap 'stop_cbserver 2>/dev/null || true' EXIT
trap 'echo "regression: interrupted" >&2; stop_cbserver 2>/dev/null || true; exit 130' INT TERM

rewrite_ticket_script() {
  local src="$1" dest="$2"
  local sysdir="${CB_SYSTEM_DIR:-}"
  if [[ -z "$sysdir" && -n "${SYSTEM_SML1:-}" ]]; then
    sysdir="$(dirname "$SYSTEM_SML1")"
  fi
  : "${sysdir:=$CB_EXAMPLES/lib}"
  sed \
    -e 's/^cbserver .*/connect 127.0.0.1 '"$CB_PORTNR"'/I' \
    -e 's/^startServer.*/connect 127.0.0.1 '"$CB_PORTNR"'/I' \
    -e 's/^#startServer.*/connect 127.0.0.1 '"$CB_PORTNR"'/I' \
    -e 's/^connect$/connect 127.0.0.1 '"$CB_PORTNR"'/I' \
    -e 's/^stopServer.*/exit/I' \
    -e "s|\$CB_WORK/lib|$sysdir|g" \
    -e "s|\$CB_WORK/examples|$CB_EXAMPLES|g" \
    -e "s|\$CB_HOME/examples|$CB_EXAMPLES|g" \
    -e "s|\$CB_WORK|$CB_EXAMPLES|g" \
    -e "s|/home/jeusfeld/CBMODELS/BigFlights|$CB_EXAMPLES/FLIGHT/BigFlights|g" \
    -e "s|/home/jeusfeld/CBMODELS/USU|$CB_EXAMPLES/USU|g" \
    "$src" | tr -d '\r' >"$dest"
}

ticket_is_shell_hybrid() {
  grep -qE '^(mkdir|cd) ' "$1"
}

ticket_has_result_ok() {
  grep -qE '^result OK' "$1"
}

check_ticket_log() {
  local log="$1"
  if grep -Eiq 'Unable to (tell|ask|untell|connect)|failed to compile|Known client hanging|Errors found in query definition|Exception:' "$log"; then
    return 1
  fi
  return 0
}

run_ticket_script() {
  local script="$1"
  local name work log server_args
  name="$(basename "$script")"
  log="$CB_TESTCLIENT_LOGDIR/tickets/$name.log"

  work="$(mktemp)"
  rewrite_ticket_script "$script" "$work"
  if ! ticket_has_result_ok "$script"; then
    echo "exit" >>"$work"
  fi
  echo "regression: ticket $name"

  rm -f error.log stat.log ok.log
  server_args="$(extract_start_server_args "$script")"
  start_cbserver "$server_args"

  if ticket_has_result_ok "$script"; then
    if ! run_cbshell_timed -l -f "$work" >"$log" 2>&1; then
      stop_cbserver
      rm -f "$work"
      echo "regression: ticket $name failed (cbshell exit / timeout)" >&2
      tail -40 "$log" >&2 || true
      return 1
    fi
    if [[ -s error.log ]]; then
      cp error.log "$CB_TESTCLIENT_LOGDIR/tickets/error.$name"
      stop_cbserver
      rm -f "$work"
      echo "regression: ticket $name reported answer deviations:" >&2
      cat error.log >&2
      return 1
    fi
  else
    if ! run_cbshell_timed <"$work" >"$log" 2>&1; then
      stop_cbserver
      rm -f "$work"
      echo "regression: ticket $name failed (cbshell exit / timeout)" >&2
      tail -40 "$log" >&2 || true
      return 1
    fi
    if ! check_ticket_log "$log"; then
      stop_cbserver
      rm -f "$work"
      echo "regression: ticket $name log contains failures:" >&2
      tail -40 "$log" >&2 || true
      return 1
    fi
  fi

  stop_cbserver
  rm -f "$work" error.log stat.log ok.log
  return 0
}

echo "=== Phase 1: CB_TestClient .cbs corpus ==="
export CB_AUTOTEST_WORKDIR="$REGRESSION_WORK/autotest"
mkdir -p "$CB_AUTOTEST_WORKDIR"
bash "$(dirname "$0")/cb-autotest.raw"

if [[ -n "$TICKET_DIR" && -d "$TICKET_DIR" ]]; then
  echo "=== Phase 2: ticket .cbs.txt scripts ==="
  : >"$CB_TESTCLIENT_LOGDIR/tickets/skipped-shell-hybrid.txt"
  ticket_failures=0
  ticket_total=0
  ticket_ran=0
  shopt -s nullglob
  for script in "$TICKET_DIR"/*.cbs.txt; do
    check_global_deadline
    ticket_total=$((ticket_total + 1))
    name="$(basename "$script")"
    if ticket_is_shell_hybrid "$script"; then
      echo "regression: skip $name (shell commands mkdir/cd — not runnable via cbshell)"
      echo "$name" >>"$CB_TESTCLIENT_LOGDIR/tickets/skipped-shell-hybrid.txt"
      continue
    fi
    ticket_ran=$((ticket_ran + 1))
    if ! run_ticket_script "$script"; then
      ticket_failures=$((ticket_failures + 1))
    fi
  done
  skipped="$(wc -l <"$CB_TESTCLIENT_LOGDIR/tickets/skipped-shell-hybrid.txt" | tr -d ' ')"
  echo "regression: tickets $((ticket_ran - ticket_failures))/$ticket_ran runnable passed ($skipped shell-hybrid skipped of $ticket_total total)"
  if [[ "$ticket_failures" -gt 0 ]]; then
    echo "regression: $ticket_failures ticket script(s) failed" >&2
    exit 1
  fi
else
  echo "=== Phase 2: skipped (no ticket directory) ==="
fi

echo "regression: complete"
