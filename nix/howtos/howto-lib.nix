# Shared shell helpers for HOW-TO Nix checks (not a generator).
{ lib }:

let
  cbPort = "4001";

  startCbserver = ''
    start_cbserver() {
      if [ -z "''${HOWTO_PORT_SEQ:-}" ]; then HOWTO_PORT_SEQ=0; fi
      export CB_PORTNR=$((4001 + HOWTO_PORT_SEQ))
      HOWTO_PORT_SEQ=$((HOWTO_PORT_SEQ + 1))
      server_log="$(mktemp)"
      cbserver -u nonpersistent -p "$CB_PORTNR" >"$server_log" 2>&1 &
      server_pid=$!
      ready=0
      for _ in $(seq 1 120); do
        if grep -q "CBserver ready on host" "$server_log" 2>/dev/null; then
          ready=1
          break
        fi
        sleep 1
      done
      if [ "$ready" -ne 1 ]; then
        echo "cbserver did not become ready" >&2
        tail -40 "$server_log" >&2 || true
        return 1
      fi
    }

    stop_cbserver() {
      if [ -n "''${server_pid:-}" ]; then
        kill "$server_pid" 2>/dev/null || true
        wait "$server_pid" 2>/dev/null || true
        server_pid=
      fi
      rm -f "''${server_log:-}"
      sleep 2
    }
  '';

  assertLastResponse = ''
    assert_last_response() {
      local expected="$1"
      local got
      got="$(grep -E '^\[localhost:[0-9]+\]>(yes|no)$' "$TMPDIR/run.log" | tail -1 | sed 's/.*>//')"
      if [ "$got" != "$expected" ]; then
        echo "Expected last CBShell response '$expected', got '$got'" >&2
        return 1
      fi
    }
  '';

  runCbsFile = ''
    run_cbs_file() {
      local script="$1"
      local work
      work="$(mktemp)"
      sed -e 's/^cbserver .*/connect localhost '"$CB_PORTNR"'/I' \
          -e 's/^startServer.*/connect localhost '"$CB_PORTNR"'/I' \
          -e 's/^#startServer.*/connect localhost '"$CB_PORTNR"'/I' \
          -e 's/^stopServer.*/exit/I' \
          "$script" >"$work"
      echo "exit" >>"$work"
      echo ">>> Running $script"
      timeout 600 cbshell <"$work" 2>&1 | tee -a "$TMPDIR/run.log" || {
        echo "cbshell timed out or failed on $script" >&2
        return 1
      }
      rm -f "$work"
      echo >>"$TMPDIR/run.log"
    }
  '';

  tellModel = ''
    tell_model() {
      local sml="$1"
      echo ">>> Telling $sml" >>"$TMPDIR/run.log"
      timeout 600 cbshell 2>&1 <<EOF >>"$TMPDIR/run.log" || return 1
connect localhost $CB_PORTNR
tellModel "$sml"
exit
EOF
      echo >>"$TMPDIR/run.log"
    }
  '';

  tellExpr = ''
    tell_expr() {
      local expr="$1"
      echo ">>> Telling $expr" >>"$TMPDIR/run.log"
      timeout 600 cbshell 2>&1 <<EOF >>"$TMPDIR/run.log" || return 1
connect localhost $CB_PORTNR
tell "
$expr
"
exit
EOF
      echo >>"$TMPDIR/run.log"
    }
  '';

  failOnErrors = ''
    if grep -Eiq 'Unable to (tell|ask|untell|connect)|failed to compile|Known client hanging|cbserver did not become ready|Errors found in query definition' "$TMPDIR/run.log"; then
      echo "HOW-TO run reported failures (see log above)" >&2
      exit 1
    fi
  '';

  initEnv = port: ''
    export HOME="$TMPDIR"
    export CB_SHELL_ENABLE_LPI=1
    export CB_PORTNR=${port}
    : >"$TMPDIR/run.log"
    trap 'stop_cbserver' EXIT
  '';

in
{
  inherit cbPort startCbserver assertLastResponse runCbsFile tellModel tellExpr failOnErrors initEnv;

  shellHelpers = ''
    ${startCbserver}
    ${assertLastResponse}
    ${runCbsFile}
    ${tellModel}
    ${tellExpr}
  '';
}
