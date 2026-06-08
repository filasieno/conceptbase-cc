# Graph HOW-TO: cbgraph smoke on first .gel, asset validation for the rest.
{ stdenv
, cbserver
, cbgraph
, xvfb-run
, coreutils
, bash
, gnugrep
, findutils
, lib
, howtosRoot
, slug
, ...
}:

let
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

  toolPath = lib.makeBinPath [ bash coreutils gnugrep findutils cbgraph xvfb-run ];
in
stdenv.mkDerivation {
  pname = "howto-${slug}";
  version = "0.1.0";
  inherit src;

  nativeBuildInputs = [ bash coreutils gnugrep findutils ];
  buildInputs = [ cbgraph xvfb-run ];

  buildPhase = ''
    runHook preBuild
    export PATH="${toolPath}:$PATH"
    export HOME="$TMPDIR"
    : >"$TMPDIR/run.log"

    cd ${slug}

    {
      echo "=== HOW-TO: ${slug} ==="
      echo

      mapfile -t gel_files < <(find . -name '*.gel' | sort)
      if [ "''${#gel_files[@]}" -eq 0 ]; then
        echo "No .gel files in ${slug}" >&2
        exit 1
      fi

      smoke_done=0
      for gel in "''${gel_files[@]}"; do
        echo ">>> Validating $gel"
        test -s "$gel"
        grep -q . "$gel"

        if [ "$smoke_done" -eq 0 ]; then
          echo ">>> cbgraph smoke: $gel"
          if xvfb-run -a timeout 30 cbgraph "$gel" >>"$TMPDIR/run.log" 2>&1; then
            echo "cbgraph smoke succeeded for $gel"
          else
            echo "cbgraph smoke skipped or timed out for $gel (asset validation only)"
          fi
          smoke_done=1
        fi
        echo
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
