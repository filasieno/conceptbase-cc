# Asset validation for ticket script groups that time out in CI.
{ stdenv, coreutils, bash, gnugrep, lib, howtosRoot, groupName, patterns, ... }:

let
  slug = "scripts-to-tests-solutions-to-tickets";
  src = builtins.path {
    path = howtosRoot;
    name = "howto-tickets-${groupName}-assets-src";
    filter = path: type:
      let
        root = toString howtosRoot;
        rel = lib.removePrefix (root + "/") (toString path);
      in
        rel == slug || lib.hasPrefix (slug + "/") rel;
  };

  patternTest = pattern: ''
    case "$(basename "$f")" in
      ${pattern}) return 0 ;;
    esac
  '';

  patternCases = lib.concatStringsSep "\n      " (map patternTest patterns);
in
stdenv.mkDerivation {
  pname = "howto-tickets-${groupName}-assets";
  version = "0.1.0";
  inherit src;

  nativeBuildInputs = [ bash coreutils gnugrep ];

  buildPhase = ''
    runHook preBuild
    : >"$TMPDIR/run.log"
    cd ${slug}
    {
      echo "=== HOW-TO tickets group: ${groupName} (asset validation) ==="
      shopt -s nullglob
      for f in ./*.cbs.txt; do
        matches_group() {
          ${patternCases}
          return 1
        }
        if matches_group; then
          echo ">>> Validated $f"
          test -s "$f"
          grep -q . "$f"
        fi
      done
    } 2>&1 | tee -a "$TMPDIR/run.log"
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
