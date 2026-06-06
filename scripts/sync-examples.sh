#!/usr/bin/env bash
# Sync example corpora from archive into components/examples.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ARCH="$ROOT/archive/2026-06-06-wip/ProductPOOL/examples"
DEST="$ROOT/components/examples/src"

mkdir -p "$DEST"
find "$DEST" -mindepth 1 -delete

copy_tree() {
  local src="$1" dest="$2"
  mkdir -p "$dest"
  find "$src" -type f \
    ! -path '*/EXPORT/*' \
    ! -name 'Makefile' \
    ! -name 'COPYRIGHT.txt' \
    -print0 | while IFS= read -r -d '' f; do
      rel="${f#"$src"/}"
      mkdir -p "$dest/$(dirname "$rel")"
      cp "$f" "$dest/$rel"
    done
}

copy_tree "$ARCH" "$DEST"
echo "Synced examples tree ($(find "$DEST" -type f | wc -l) files)."
