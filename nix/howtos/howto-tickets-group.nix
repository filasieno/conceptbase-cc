# Run a subset of ticket .cbs.txt scripts for scripts-to-tests-solutions-to-tickets.
{ stdenv, cbserver, cbshell, coreutils, bash, gnugrep, gnused, findutils, lib, howtosRoot, groupName, filePatterns, maxCbsFiles ? 999, ... }:

let
  howtoLib = import ./howto-lib.nix { inherit lib; };
  slug = "scripts-to-tests-solutions-to-tickets";

  src = builtins.path {
    path = howtosRoot;
    name = "howto-tickets-${groupName}-src";
    filter = path: type:
      let
        root = toString howtosRoot;
        rel = lib.removePrefix (root + "/") (toString path);
      in
        rel == slug || lib.hasPrefix (slug + "/") rel;
  };

  toolPath = lib.makeBinPath [ bash coreutils gnugrep gnused findutils cbserver cbshell ];

  patternTest = pattern: ''
    case "$(basename "$f")" in
      ${pattern}) return 0 ;;
    esac
  '';

  patternCases = lib.concatStringsSep "\n      " (map patternTest filePatterns);
in
stdenv.mkDerivation {
  pname = "howto-tickets-${groupName}";
  version = "0.1.0";
  inherit src;

  nativeBuildInputs = [ bash coreutils gnugrep gnused findutils ];
  buildInputs = [ cbserver cbshell ];

  buildPhase = ''
    runHook preBuild
    export PATH="${toolPath}:$PATH"
    ${howtoLib.initEnv howtoLib.cbPort}
    ${howtoLib.shellHelpers}

    cd ${slug}

    {
      echo "=== HOW-TO tickets group: ${groupName} ==="
      echo
      shopt -s nullglob
      ran=0
      for f in ./*.cbs.txt; do
        matches_group() {
          ${patternCases}
          return 1
        }
        if matches_group; then
          if [ ${toString maxCbsFiles} -lt 999 ] && [ "$ran" -ge ${toString maxCbsFiles} ]; then
            echo ">>> Skipping $f (max ${toString maxCbsFiles} per group in Nix check)"
            continue
          fi
          start_cbserver
          run_cbs_file "$f"
          stop_cbserver
          trap - EXIT
          ran=$((ran + 1))
        fi
      done

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
}
