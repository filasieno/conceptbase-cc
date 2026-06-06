#!/usr/bin/env bash
# Sync archive Java sources into components/java Maven modules (src/main/java layout).
# Copies *.java and JavaCC *.jj grammars — never Ant build files (build.xml, *.ant.xml).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ARCH="$ROOT/archive/2026-06-06-wip/ProductPOOL/java"
JAVA="$ROOT/components/java"

copy_tree() {
  local src="$1" dest="$2"
  mkdir -p "$dest"
  find "$src" -type f -name '*.java' \
    ! -path '*/tests/*' \
    ! -name '*.java.*' \
    ! -name '.#*' \
    -print0 | while IFS= read -r -d '' f; do
      rel="${f#"$src"/}"
      mkdir -p "$dest/$(dirname "$rel")"
      cp "$f" "$dest/$rel"
    done
}

rm -rf \
  "$JAVA/cbcommon/src" \
  "$JAVA/cbframe/src" \
  "$JAVA/cbapi/src" \
  "$JAVA/cbtelos/src" \
  "$JAVA/cbgraph/src" \
  "$JAVA/cbworkbench/src" \
  "$JAVA/cbdistribution/src"

COMMON="$JAVA/cbcommon/src/main/java"
mkdir -p "$COMMON/i5/cb"
cp "$ARCH/i5/ShallowCloneable.java" "$COMMON/i5/"
for f in CBConfiguration CBException CBinstaller Contract PrologPreProcessor; do
  cp "$ARCH/i5/cb/${f}.java" "$COMMON/i5/cb/"
done

API="$JAVA/cbapi/src/main/java"
copy_tree "$ARCH/i5/cb/api" "$API/i5/cb/api"
cp "$ARCH/i5/cb/CBShell.java" "$API/i5/cb/"

copy_tree "$ARCH/i5/cb/telos/frame" "$JAVA/cbframe/src/main/java/i5/cb/telos/frame"
mkdir -p "$JAVA/cbframe/src/main/javacc"
cp "$ARCH/i5/cb/telos/frame/Telos.jj" "$JAVA/cbframe/src/main/javacc/"
mkdir -p "$JAVA/cbapi/src/main/javacc"
cp "$ARCH/i5/cb/api/notification/Notification.jj" "$JAVA/cbapi/src/main/javacc/"
copy_tree "$ARCH/i5/cb/telos" "$JAVA/cbtelos/src/main/java/i5/cb/telos"
rm -rf "$JAVA/cbtelos/src/main/java/i5/cb/telos/frame"

GRAPH="$JAVA/cbgraph/src/main/java"
copy_tree "$ARCH/i5/cb/graph" "$GRAPH/i5/cb/graph"
cp "$ARCH/i5/cb/GUIHandler.java" "$GRAPH/i5/cb/"
mkdir -p "$JAVA/cbgraph/src/main/resources/i5/cb/graph"
find "$ARCH/i5/cb/graph" -type f \( -name '*.gif' -o -name '*.png' \) -print0 \
  | while IFS= read -r -d '' f; do
      rel="${f#"$ARCH/i5/cb/graph"/}"
      mkdir -p "$JAVA/cbgraph/src/main/resources/i5/cb/graph/$(dirname "$rel")"
      cp "$f" "$JAVA/cbgraph/src/main/resources/i5/cb/graph/$rel"
    done

copy_tree "$ARCH/i5/cb/workbench" "$JAVA/cbworkbench/src/main/java/i5/cb/workbench"
mkdir -p "$JAVA/cbworkbench/src/main/resources/i5/cb/workbench/gif"
cp -r "$ARCH/i5/cb/workbench/gif/." "$JAVA/cbworkbench/src/main/resources/i5/cb/workbench/gif/" 2>/dev/null || true

mkdir -p "$JAVA/cbdistribution/src/main/resources"
cp "$ARCH/manifest.txt" "$ARCH/CBinstaller-manifest.txt" "$JAVA/cbdistribution/"
cp -r "$ARCH/resources/." "$JAVA/cbdistribution/src/main/resources/" 2>/dev/null || true

echo "Java sources synced into components/java/cb*/src/main/java"
