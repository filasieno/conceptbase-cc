# integration-tests — C/C++, Java shell client smoke tests against a live cbserver.
{
  lib,
  runCommandLocal,
  llvmPackages,
  coreutils,
  findutils,
  cbserver,
  cb-shell,
  libcbc,
  libcbcview,
  examples-corpus,
}:

let
  cTestSrc = "${examples-corpus}/share/examples/Clients/C_Client/testlib.c";
  cxxTestSrc = "${examples-corpus}/share/examples/Clients/Cpp-Client/testlib.cc";
in
runCommandLocal "integration-tests"
  {
    nativeBuildInputs = [ llvmPackages.clang ];
    buildInputs = [ libcbc libcbcview cbserver cb-shell coreutils findutils ];
  }
  ''
    mkdir -p build out/bin
    export PATH="${coreutils}/bin:${findutils}/bin:$PATH"
    export CB_HOME=${cbserver}
    export CB_POOL=${cbserver}/share
    export CBS_DIR=${cbserver}/share/serverSources/Prolog_Files
    export CBL_DIR=${cbserver}/share/system-data
    export CB_VARIANT=""
    export CB_PORTNR=4001

    sed 's/"localhost"/"127.0.0.1"/g' ${cTestSrc} > build/testlib.c
    sed 's/"localhost"/"127.0.0.1"/g' ${cxxTestSrc} > build/testlib.cc

    clang -DLINUX -o build/testlib-c \
      -I${libcbc}/include/libcbc \
      build/testlib.c \
      -L${libcbc}/lib -lcbc -lm

    clang++ -DLINUX -std=c++17 -o build/testlib-cpp \
      -I${libcbcview}/include/libcbcview \
      -I${libcbc}/include/libcbc \
      build/testlib.cc \
      -L${libcbcview}/lib -L${libcbc}/lib -lcbcview -lcbc -lm -lstdc++

    cp build/testlib-c build/testlib-cpp out/bin/

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
        echo "integration-tests: cbserver exited early:"
        tail -30 "$server_log" || true
        exit 1
      fi
      sleep 1
    done

    if [ "$ready" -ne 1 ]; then
      echo "integration-tests: cbserver did not become ready within 60s"
      tail -30 "$server_log" || true
      exit 1
    fi

    sleep 2

    out/bin/testlib-c | tee /tmp/testlib-c.log
    if ! grep -q "connected, client name:" /tmp/testlib-c.log; then
      echo "integration-tests: testlib-c failed; server log:"
      tail -30 "$server_log" || true
      exit 1
    fi
    grep -q "disconnected!" /tmp/testlib-c.log

    out/bin/testlib-cpp | tee /tmp/testlib-cpp.log
    if ! grep -q "connected, client name:" /tmp/testlib-cpp.log; then
      echo "integration-tests: testlib-cpp failed; server log:"
      tail -30 "$server_log" || true
      exit 1
    fi

    ${cb-shell}/bin/cbshell <<'EOF' | tee /tmp/testlib-java.log
connect 127.0.0.1 4001
tell "Class B end Class A end b in B end"
ask get_object[A/objname]
exit
EOF
    if ! grep -qE 'connected|yes|objname|B' /tmp/testlib-java.log; then
      echo "integration-tests: cbshell tell/ask failed; server log:"
      tail -30 "$server_log" || true
      exit 1
    fi

    mkdir -p $out/bin
    cp out/bin/* $out/bin/
  ''
