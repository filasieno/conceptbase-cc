# HOW-TO: avoid traps with aggregation functions in constraints (multi-step)
args@{
  stdenv,
  cbserver,
  cbshell,
  coreutils,
  bash,
  gnugrep,
  findutils,
  lib,
  howtosRoot,
  ...
}:

let
  slug = "avoid-traps-with-aggregation-functions-in-constraints";
  howtoLib = import ./howto-lib.nix { inherit lib; };

  src = builtins.path {
    path = howtosRoot;
    name = "howto-${slug}-src";
    filter = path: type:
      let
        root = toString howtosRoot;
        rel = lib.removePrefix (root + "/") (toString path);
      in
        rel == slug || lib.hasPrefix (slug + "/") rel;
  };

  toolPath = lib.makeBinPath [ bash coreutils gnugrep findutils cbserver cbshell ];
in
{
  "${slug}" = stdenv.mkDerivation {
    pname = "howto-${slug}";
    version = "0.1.0";
    inherit src;

    nativeBuildInputs = [ bash coreutils gnugrep findutils ];
    buildInputs = [ cbserver cbshell ];

    buildPhase = ''
      runHook preBuild
      export PATH="${toolPath}:$PATH"
      ${howtoLib.initEnv howtoLib.cbPort}
      ${howtoLib.shellHelpers}

      cd ${slug}

      {
        echo "=== HOW-TO: ${slug} ==="
        echo

        echo "=== Scenario 1: incorrect COUNT constraint (trap) ==="
        start_cbserver
        tell_model "./ClassLimit1.sml.txt"
        assert_last_response yes
        tell_expr "x3 in MyContainer end"
        assert_last_response yes
        stop_cbserver
        trap - EXIT
        echo

        echo "=== Scenario 2: correct COUNT constraint ==="
        trap 'stop_cbserver' EXIT
        start_cbserver
        tell_model "./ClassLimit2.sml.txt"
        assert_last_response yes
        tell_expr "x3 in MyContainer end"
        assert_last_response no
        stop_cbserver
        trap - EXIT
        echo

        echo "=== Scenario 3: meta-level cardinality formulas ==="
        trap 'stop_cbserver' EXIT
        start_cbserver
        tell_model "./ClassLimitMeta.sml.txt"
        assert_last_response yes
        stop_cbserver
      } 2>&1 | tee -a "$TMPDIR/run.log"

      ${howtoLib.failOnErrors}

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p "$out"
      cp "$TMPDIR/run.log" "$out/run.log"
      touch "$out/success"
      runHook postInstall
    '';
  };
}
