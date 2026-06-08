# Validate HOW-TO assets exist; smoke CBShell session (no long-running scripts).
{ stdenv, cbserver, cbshell, coreutils, bash, gnugrep, lib, howtosRoot, slug, ... }:

let
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

  toolPath = lib.makeBinPath [ bash coreutils gnugrep cbserver cbshell ];
in
stdenv.mkDerivation {
  pname = "howto-${slug}";
  version = "0.1.0";
  inherit src;

  nativeBuildInputs = [ bash coreutils gnugrep ];
  buildInputs = [ cbserver cbshell ];

  buildPhase = ''
    runHook preBuild
    export PATH="${toolPath}:$PATH"
    ${howtoLib.initEnv howtoLib.cbPort}
    ${howtoLib.shellHelpers}

    cd ${slug}

    {
      echo "=== HOW-TO: ${slug} (asset validation + smoke) ==="
      echo
      find . -type f \( -name '*.cbs.txt' -o -name '*.sml.txt' -o -name '*.gel' \) | sort
      echo
      start_cbserver
      cbshell 2>&1 <<EOF >>"$TMPDIR/run.log"
connect localhost $CB_PORTNR
ls
exit
EOF
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
}
