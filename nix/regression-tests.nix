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
    export CB_PORTNR=4001
    export CB_AUTOTEST_TIMEOUT=3600
    export REGRESSION_TICKET_TIMEOUT=900

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
    bash ${cb-testclient}/bin/run-regression.raw 2>&1 | tee "$CB_TESTCLIENT_LOGDIR/regression.log"

    mkdir -p "$out/share/regression-tests"
    cp -r "$CB_TESTCLIENT_LOGDIR"/* "$out/share/regression-tests/"
    touch "$out/share/regression-tests/success"
  ''
