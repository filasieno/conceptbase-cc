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
TICKET_TIMEOUT="${REGRESSION_TICKET_TIMEOUT:-900}"
AUTOTEST_TIMEOUT="${CB_AUTOTEST_TIMEOUT:-3600}"
TICKET_DIR="${REGRESSION_TICKET_DIR:-}"

export CB_PORTNR CB_EXAMPLES CB_HOME CB_TESTCLIENT CB_TESTCLIENT_LOGDIR
export CB_SHELL_ENABLE_LPI=1
export JAVA CB_JAR
export CB_AUTOTEST_TIMEOUT="$AUTOTEST_TIMEOUT"
export CB_AUTOTEST_FULL=1

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
  timeout "$TICKET_TIMEOUT" "$JAVA" \
    -DCB_HOME="$CB_HOME" \
    -DCB_PORTNR="$CB_PORTNR" \
    -cp "$CB_JAR" \
    i5.cb.CBShell "$@"
}

start_cbserver() {
  server_log="$(mktemp)"
  "$CBSERVER" -u nonpersistent -p "$CB_PORTNR" >"$server_log" 2>&1 &
  server_pid=$!
  ready=0
  for _ in $(seq 1 180); do
    if grep -q "CBserver ready on host" "$server_log" 2>/dev/null; then
      ready=1
      break
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
    kill "$server_pid" 2>/dev/null || true
    wait "$server_pid" 2>/dev/null || true
    server_pid=
  fi
  rm -f "${server_log:-}"
  pkill -f '[/]cbserver' 2>/dev/null || true
  sleep 2
}

rewrite_ticket_script() {
  local src="$1" dest="$2"
  sed \
    -e 's/^cbserver .*/connect 127.0.0.1 '"$CB_PORTNR"'/I' \
    -e 's/^startServer.*/connect 127.0.0.1 '"$CB_PORTNR"'/I' \
    -e 's/^#startServer.*/connect 127.0.0.1 '"$CB_PORTNR"'/I' \
    -e 's/^connect$/connect 127.0.0.1 '"$CB_PORTNR"'/I' \
    -e 's/^stopServer.*/exit/I' \
    -e "s|\$CB_WORK|$CB_EXAMPLES|g" \
    -e "s|\$CB_HOME/examples|$CB_EXAMPLES|g" \
    "$src" >"$dest"
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
  local name work log
  name="$(basename "$script")"
  log="$CB_TESTCLIENT_LOGDIR/tickets/$name.log"

  work="$(mktemp)"
  rewrite_ticket_script "$script" "$work"
  if ! ticket_has_result_ok "$script"; then
    echo "exit" >>"$work"
  fi
  echo "regression: ticket $name"

  rm -f error.log stat.log ok.log
  start_cbserver

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
