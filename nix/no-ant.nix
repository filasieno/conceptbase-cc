# Policy check — Apache Ant must not appear in the greenfield build tree.
{
  lib,
  runCommand,
  componentsSrc,
  nixSrc,
  scriptsSrc,
  flakeSrc,
}:

runCommand "no-ant"
  {
    inherit componentsSrc nixSrc scriptsSrc flakeSrc;
  }
  ''
    set -euo pipefail
    fail=

    check_tree() {
      local label="$1" root="$2"
      local hits
      hits=$(find "$root" \( -name '*.ant.xml' -o -name 'build.xml' \) -print 2>/dev/null || true)
      if [ -n "$hits" ]; then
        echo "ERROR: Ant build files under $label (use Maven instead):"
        echo "$hits"
        fail=1
      fi
      if grep -rE 'maven-antrun-plugin|org\.apache\.tools\.ant' "$root" \
          --include='pom.xml' --include='*.sh' --include='Makefile*' -n 2>/dev/null; then
        echo "ERROR: Ant tooling references under $label"
        fail=1
      fi
    }

    check_tree components "$componentsSrc"
    check_tree scripts "$scriptsSrc"

    if grep -rE 'pkgs\.ant\b|apacheAnt|apache-ant' "$nixSrc" \
        --include='*.nix' --exclude='no-ant.nix' -n 2>/dev/null; then
      echo "ERROR: Ant package referenced in nix/"
      fail=1
    fi

    if grep -E 'pkgs\.ant\b|apacheAnt|apache-ant' "$flakeSrc" -n 2>/dev/null; then
      echo "ERROR: Ant package referenced in flake.nix"
      fail=1
    fi

    if [ -n "$fail" ]; then
      exit 1
    fi

    mkdir -p "$out"
    echo "no Ant build files or tooling in greenfield tree" > "$out/verified"
  ''
