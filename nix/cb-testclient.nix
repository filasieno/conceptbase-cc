# cb-testclient — AdminPOOL utils regression harness (CBS corpus + analyzer tools).
{
  lib,
  runCommandLocal,
  coreutils,
  bash,
  gnused,
  findutils,
  perl,
  makeWrapper,
  cbserver,
  cb-shell,
  examples-corpus,
  componentSrc,
}:

runCommandLocal "cb-testclient"
  {
    nativeBuildInputs = [ makeWrapper coreutils bash gnused findutils perl ];
    buildInputs = [ cbserver cb-shell examples-corpus ];
  }
  ''
    mkdir -p "$out/share/cb-testclient/tools" "$out/bin"
    cp -r ${componentSrc}/src/* "$out/share/cb-testclient/"
    cp ${componentSrc}/tools/CB_OutputAnalyzer ${componentSrc}/tools/CB_AnalyzerDiff \
      "$out/share/cb-testclient/tools/"
    install -m755 ${componentSrc}/cb-autotest.sh "$out/bin/cb-autotest.raw"
    install -m755 ${componentSrc}/run-regression.sh "$out/bin/run-regression.raw"
    makeWrapper ${bash}/bin/bash "$out/bin/cb-autotest" \
      --add-flags "$out/bin/cb-autotest.raw"
    makeWrapper ${bash}/bin/bash "$out/bin/run-regression" \
      --add-flags "$out/bin/run-regression.raw"

    for tool in CB_OutputAnalyzer CB_AnalyzerDiff; do
      makeWrapper ${perl}/bin/perl "$out/bin/$tool" \
        --add-flags "$out/share/cb-testclient/tools/$tool"
    done
    ${perl}/bin/perl -c "$out/share/cb-testclient/tools/CB_OutputAnalyzer"
    ${perl}/bin/perl -c "$out/share/cb-testclient/tools/CB_AnalyzerDiff"

    test -f "$out/share/cb-testclient/scripts/BuiltinQueries.cbs"
    test -f "$out/share/cb-testclient/scripts/Modules.cbs"
    test -x "$out/bin/cb-autotest"

    export PATH="${coreutils}/bin:${findutils}/bin:$PATH"
    export CB_PORTNR=4001

    server_log=$(mktemp)
    ${cbserver}/bin/cbserver >"$server_log" 2>&1 &
    server_pid=$!
    cleanup() {
      kill "$server_pid" 2>/dev/null || true
      wait "$server_pid" 2>/dev/null || true
      rm -f "$server_log"
    }
    trap cleanup EXIT

    ready=0
    for _ in $(seq 1 60); do
      if grep -q "CBserver ready on host" "$server_log" 2>/dev/null; then
        ready=1
        break
      fi
      if ! kill -0 "$server_pid" 2>/dev/null; then
        echo "cb-testclient: cbserver exited early"
        tail -30 "$server_log" || true
        exit 1
      fi
      sleep 1
    done
    if [ "$ready" -ne 1 ]; then
      echo "cb-testclient: cbserver did not become ready"
      tail -30 "$server_log" || true
      exit 1
    fi
    sleep 5

    smoke=$(mktemp)
    cat >"$smoke" <<'EOF'
connect 127.0.0.1 4001
tell "Class B end Class A end b in B end"
ask get_object[A/objname]
exit
EOF

    ${cb-shell}/bin/cbshell -v -f "$smoke" | tee /tmp/cb-testclient-smoke.log
    if ! grep -qE 'yes|B|connected' /tmp/cb-testclient-smoke.log; then
      echo "cb-testclient: smoke script failed"
      tail -30 "$server_log" || true
      exit 1
    fi
    rm -f "$smoke"
  ''
