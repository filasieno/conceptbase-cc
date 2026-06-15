# regression-tests — maximally complete CB_TestClient + ticket script regression.
{
  lib,
  runCommandLocal,
  coreutils,
  bash,
  gnused,
  findutils,
  jdk,
  java-reactor,
  cbserver,
  cb-shell,
  cb-testclient,
  examples-corpus,
  system-data,
  howtosRoot,
}:

let
  ticketSrc = builtins.path {
    path = howtosRoot;
    name = "regression-tickets-src";
    filter = path: type:
      let
        root = toString howtosRoot;
        rel = lib.removePrefix (root + "/") (toString path);
        slug = "scripts-to-tests-solutions-to-tickets";
      in
        rel == slug || lib.hasPrefix (slug + "/") rel;
  };
in
runCommandLocal "regression-tests"
  {
    nativeBuildInputs = [ bash coreutils gnused findutils ];
    buildInputs = [
      jdk
      java-reactor
      cbserver
      cb-shell
      cb-testclient
      examples-corpus
    ];
  }
  ''
    export PATH="${coreutils}/bin:${findutils}/bin:$PATH"
    export HOME="$TMPDIR"
    # Avoid hostname-dependent BuiltinQueries palette answers (e.g. "Debian" matching De*).
    echo "127.0.0.1 cbregression" >> /etc/hosts 2>/dev/null || true
    hostname cbregression 2>/dev/null || true
    export JAVA=${jdk}/bin/java
    export CB_JAR=${java-reactor}/lib/cb.jar
    export CBSERVER=${cbserver}/bin/cbserver
    export CB_EXAMPLES=${examples-corpus}/share/examples
    export SYSTEM_SML1=${system-data}/share/system-data/SML1.sml
    export CB_TESTCLIENT=${cb-testclient}/share/cb-testclient
    export CB_TESTCLIENT_LOGDIR="$TMPDIR/regression-log"
    export REGRESSION_TICKET_DIR=${ticketSrc}/scripts-to-tests-solutions-to-tickets
    export REGRESSION_WORK="$TMPDIR/work"
    # Random high port per build to avoid colliding with stray :4001 servers
    # left over from earlier (possibly hung) runs sharing the host network.
    export CB_PORTNR=$(( 20000 + RANDOM % 20000 ))
    # Finite per-script / per-ticket budgets and a global ceiling so a hang can
    # never wedge the build; the scripts also trap EXIT to reap their servers.
    export CB_AUTOTEST_TIMEOUT=900
    export REGRESSION_TICKET_TIMEOUT=900
    # The BigFlights model defines deliberately expensive recursive queries
    # (ReachableFrom/UnReachableFrom ~400-800s each) that run in BOTH the Phase-1
    # .cbs corpus and the Phase-2 ticket corpus. The earlier 3000s ceiling was
    # exhausted mid-suite once BigFlights started actually computing (rather than
    # erroring out fast under -st on), so give the full corpus real headroom.
    export REGRESSION_GLOBAL_TIMEOUT=5400

    export CB_HOME="$TMPDIR/cb-home"
    mkdir -p "$CB_HOME/lib" "$CB_HOME/share"
    ln -sf ${cbserver}/bin/cbserver "$CB_HOME/cbserver"
    ln -sf ${cbserver}/lib/CBserver "$CB_HOME/lib/CBserver"
    cp -a ${cbserver}/share/. "$CB_HOME/share/"
    export CB_POOL="$CB_HOME/share"
    export CBS_DIR="$CB_HOME/share/serverSources/Prolog_Files"
    export CBL_DIR="$CB_HOME/share/system-data"

    mkdir -p "$CB_TESTCLIENT_LOGDIR"
    set -o pipefail
    # Outer hard backstop (> REGRESSION_GLOBAL_TIMEOUT) so the build self-aborts
    # even if the script-level deadline ever fails to trigger. SIGTERM first,
    # SIGKILL after a 60s grace.
    timeout -k 60 5700 bash ${cb-testclient}/bin/run-regression.raw 2>&1 \
      | tee "$CB_TESTCLIENT_LOGDIR/regression.log"

    mkdir -p "$out/share/regression-tests"
    cp -r "$CB_TESTCLIENT_LOGDIR"/* "$out/share/regression-tests/"
    touch "$out/share/regression-tests/success"
  ''
