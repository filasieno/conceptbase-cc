# Run one HOW-TO tutorial against cbserver/cbshell; fail on errors.
{ stdenv
, cbserver
, cbshell
, coreutils
, bash
, gnugrep
, gnused
, findutils
, gawk
, lib
, howtosRoot
, slug
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

  toolPath = lib.makeBinPath [
    bash
    coreutils
    gnugrep
    gnused
    findutils
    gawk
    cbserver
    cbshell
  ];
in
stdenv.mkDerivation {
  pname = "howto-${slug}";
  version = "0.1.0";
  inherit src;

  nativeBuildInputs = [ bash coreutils gnugrep gnused findutils gawk ];
  buildInputs = [ cbserver cbshell ];

  buildPhase = ''
    runHook preBuild
    export PATH="${toolPath}:$PATH"
    export HOME="$TMPDIR"
    export CB_SHELL_ENABLE_LPI=1
    export CB_PORTNR=4001

    cd ${slug}

    server_log="$(mktemp)"
    cbserver -u nonpersistent -p "$CB_PORTNR" >"$server_log" 2>&1 &
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
      sleep 1
    done
    if [ "$ready" -ne 1 ]; then
      echo "cbserver did not become ready" >&2
      tail -40 "$server_log" >&2 || true
      exit 1
    fi

    set -o pipefail
    {
      echo "=== HOW-TO: ${slug} ==="
      echo

      shopt -s globstar nullglob
      mapfile -t scripts < <(find . -name '*.cbs.txt' | sort)
      if [ "''${#scripts[@]}" -gt 0 ]; then
        for script in "''${scripts[@]}"; do
          work="$(mktemp)"
          sed -e 's/^cbserver .*/connect localhost '"$CB_PORTNR"'/I' \
              -e 's/^startServer.*/connect localhost '"$CB_PORTNR"'/I' \
              -e 's/^#startServer.*/connect localhost '"$CB_PORTNR"'/I' \
              -e 's/^stopServer.*/exit/I' \
              "$script" >"$work"
          echo "exit" >>"$work"
          echo ">>> Running $script"
          cbshell <"$work"
          rm -f "$work"
          echo
        done
      fi

      mapfile -t sml_files < <(find . -name '*.sml.txt' | sort)
      if [ "''${#scripts[@]}" -eq 0 ] && [ "''${#sml_files[@]}" -gt 0 ]; then
        for sml in "''${sml_files[@]}"; do
          echo ">>> Telling $sml"
          cbshell <<EOF
connect localhost $CB_PORTNR
tellModel "$sml"
exit
EOF
          echo
        done
      fi

      if [ "''${#scripts[@]}" -eq 0 ] && [ "''${#sml_files[@]}" -eq 0 ]; then
        echo "No runnable .cbs.txt or .sml.txt inputs in ${slug}" >&2
        exit 1
      fi
    } 2>&1 | tee "$TMPDIR/run.log"

    if grep -Eiq 'Unable to (tell|ask|untell|connect)|failed to compile|Known client hanging|cbserver did not become ready|Errors found in query definition' "$TMPDIR/run.log"; then
      echo "HOW-TO run reported failures (see log above)" >&2
      exit 1
    fi

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
