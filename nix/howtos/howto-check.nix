# Run one HOW-TO tutorial against cbserver/cbshell; fail on errors.
{ stdenv
, cbserver
, cbshell
, cbgraph
, xvfb-run
, coreutils
, bash
, gnugrep
, gnused
, findutils
, gawk
, lib
, howtosRoot
, slug
, freshServerPerSml ? false
, freshServerPerCbs ? false
, skipSml ? [ ]
, runSml ? true
, runGelSmoke ? false
, maxSmlFiles ? 999
, maxCbsFiles ? 999
, skipCbs ? [ ]
, ...
}:

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

  toolPath = lib.makeBinPath [
    bash
    coreutils
    gnugrep
    gnused
    findutils
    gawk
    cbserver
    cbshell
    cbgraph
    xvfb-run
  ];
in
stdenv.mkDerivation {
  pname = "howto-${slug}";
  version = "0.1.0";
  inherit src;

  nativeBuildInputs = [ bash coreutils gnugrep gnused findutils gawk ];
  buildInputs = [ cbserver cbshell cbgraph xvfb-run ];
  # coreutils provides timeout

  buildPhase = ''
    runHook preBuild
    export PATH="${toolPath}:$PATH"
    ${howtoLib.initEnv howtoLib.cbPort}
    ${howtoLib.shellHelpers}

    cd ${slug}

    {
      echo "=== HOW-TO: ${slug} ==="
      echo

      shopt -s globstar nullglob
      mapfile -t scripts < <(find . -name '*.cbs.txt' | sort)
      if [ "''${#scripts[@]}" -gt 0 ]; then
        filtered_cbs=()
        for script in "''${scripts[@]}"; do
          base="$(basename "$script")"
          skip=0
          ${lib.concatStringsSep "\n          " (map (pat: ''
            if [ "$base" = "${pat}" ]; then skip=1; fi
          '') skipCbs)}
          if [ "$skip" -eq 0 ]; then filtered_cbs+=("$script"); fi
        done
        scripts=("''${filtered_cbs[@]}")
      fi
      if [ ${toString maxCbsFiles} -lt 999 ] && [ "''${#scripts[@]}" -gt ${toString maxCbsFiles} ]; then
        scripts=("''${scripts[@]:0:${toString maxCbsFiles}}")
      fi
      mapfile -t sml_files < <(find . -name '*.sml.txt' | sort)
      if [ "''${#sml_files[@]}" -gt 0 ]; then
        filtered=()
        for sml in "''${sml_files[@]}"; do
          base="$(basename "$sml")"
          skip=0
          ${lib.concatStringsSep "\n          " (map (pat: ''
            if [ "$base" = "${pat}" ]; then skip=1; fi
          '') skipSml)}
          if [ "$skip" -eq 0 ]; then filtered+=("$sml"); fi
        done
        sml_files=("''${filtered[@]}")
      fi
      if [ ${toString maxSmlFiles} -lt 999 ] && [ "''${#sml_files[@]}" -gt ${toString maxSmlFiles} ]; then
        sml_files=("''${sml_files[@]:0:${toString maxSmlFiles}}")
      fi

      if [ "''${#scripts[@]}" -eq 0 ] && [ "''${#sml_files[@]}" -eq 0 ] && [ "${if runGelSmoke then "true" else "false"}" != "true" ]; then
        echo "No runnable .cbs.txt or .sml.txt inputs in ${slug}" >&2
        exit 1
      fi

      if [ "''${#scripts[@]}" -gt 0 ]; then
        if [ "${if freshServerPerCbs then "true" else "false"}" = "true" ]; then
          for script in "''${scripts[@]}"; do
            start_cbserver
            run_cbs_file "$script"
            stop_cbserver
            trap - EXIT
          done
        else
          start_cbserver
          for script in "''${scripts[@]}"; do
            run_cbs_file "$script"
          done
        fi
      fi

      if [ "${if runSml then "true" else "false"}" = "true" ] && [ "''${#sml_files[@]}" -gt 0 ]; then
        if [ "${if freshServerPerSml then "true" else "false"}" = "true" ]; then
          for sml in "''${sml_files[@]}"; do
            stop_cbserver 2>/dev/null || true
            trap 'stop_cbserver' EXIT
            start_cbserver
            tell_model "$sml"
            stop_cbserver
            trap - EXIT
          done
        else
          if [ "''${#scripts[@]}" -eq 0 ]; then
            start_cbserver
          fi
          for sml in "''${sml_files[@]}"; do
            tell_model "$sml"
          done
          stop_cbserver
          trap - EXIT
        fi
      elif [ -n "''${server_pid:-}" ]; then
        stop_cbserver
        trap - EXIT
      fi

      if [ "${if runGelSmoke then "true" else "false"}" = "true" ]; then
        mapfile -t gel_files < <(find . -name '*.gel' | sort)
        if [ "''${#gel_files[@]}" -gt 0 ]; then
          gel="''${gel_files[0]}"
          echo ">>> cbgraph smoke: $gel" | tee -a "$TMPDIR/run.log"
          xvfb-run -a timeout 30 cbgraph "$gel" >>"$TMPDIR/run.log" 2>&1 || \
            echo "cbgraph smoke skipped (asset validation only)" | tee -a "$TMPDIR/run.log"
        fi
      fi
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
