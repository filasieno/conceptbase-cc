# regression-container — run the full regression suite inside an isolated
# container network namespace so the fixed CB_PORTNR (4001) can never collide
# with stray servers on the host. Built with dockerTools (no Dockerfile / no
# nix-in-docker rebuild); `docker run --rm` gives each run its own netns.
{
  lib,
  dockerTools,
  writeShellScriptBin,
  bash,
  coreutils,
  gnused,
  findutils,
  gnugrep,
  procps,
  hostname,
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

  # Entrypoint mirrors nix/regression-tests.nix env setup, but runs at container
  # runtime against a writable /work. The container netns isolates port 4001.
  runner = writeShellScriptBin "run-regression-container" ''
    set -euo pipefail
    export PATH="${lib.makeBinPath [ bash coreutils gnused findutils gnugrep procps hostname jdk ]}"

    : "''${WORK:=/work}"
    mkdir -p "$WORK"
    export HOME="$WORK"
    export TMPDIR="$WORK/tmp"
    mkdir -p "$TMPDIR"

    # Stable hostname so BuiltinQueries' De* palette answers are reproducible
    # (the host login name must not leak into results).
    hostname cbregression 2>/dev/null || true
    echo "127.0.0.1 cbregression" >> /etc/hosts 2>/dev/null || true

    export JAVA=${jdk}/bin/java
    export CB_JAR=${java-reactor}/lib/cb.jar
    export CBSERVER=${cbserver}/bin/cbserver
    export CB_EXAMPLES=${examples-corpus}/share/examples
    export SYSTEM_SML1=${system-data}/share/system-data/SML1.sml
    export CB_TESTCLIENT=${cb-testclient}/share/cb-testclient
    export CB_TESTCLIENT_LOGDIR="$WORK/regression-log"
    export REGRESSION_TICKET_DIR=${ticketSrc}/scripts-to-tests-solutions-to-tickets
    export REGRESSION_WORK="$WORK/work"

    # Container netns is private: a fixed port is safe and collision-free.
    export CB_PORTNR="''${CB_PORTNR:-4001}"
    # Finite budgets + global ceiling (matches the hardened scripts).
    export CB_AUTOTEST_TIMEOUT="''${CB_AUTOTEST_TIMEOUT:-600}"
    export REGRESSION_TICKET_TIMEOUT="''${REGRESSION_TICKET_TIMEOUT:-600}"
    export REGRESSION_GLOBAL_TIMEOUT="''${REGRESSION_GLOBAL_TIMEOUT:-3000}"

    export CB_HOME="$WORK/cb-home"
    mkdir -p "$CB_HOME/lib" "$CB_HOME/share"
    ln -sf ${cbserver}/bin/cbserver "$CB_HOME/cbserver"
    ln -sf ${cbserver}/lib/CBserver "$CB_HOME/lib/CBserver"
    cp -a ${cbserver}/share/. "$CB_HOME/share/"
    chmod -R u+w "$CB_HOME/share"
    export CB_POOL="$CB_HOME/share"
    export CBS_DIR="$CB_HOME/share/serverSources/Prolog_Files"
    export CBL_DIR="$CB_HOME/share/system-data"

    mkdir -p "$CB_TESTCLIENT_LOGDIR"
    set -o pipefail
    # Outer hard backstop above the script-level global deadline.
    timeout -k 60 3300 bash ${cb-testclient}/bin/run-regression.raw 2>&1 \
      | tee "$CB_TESTCLIENT_LOGDIR/regression.log"
    echo "regression-container: PASSED"
  '';
in
dockerTools.streamLayeredImage {
  name = "conceptbase-regression-tests";
  tag = "latest";
  contents = [ bash coreutils gnugrep gnused findutils procps hostname ];
  config = {
    Entrypoint = [ "${runner}/bin/run-regression-container" ];
    WorkingDir = "/work";
    Env = [
      "PATH=/bin:/usr/bin"
      "WORK=/work"
    ];
  };
}
