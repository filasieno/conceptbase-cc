#!/usr/bin/env bash
# Sync AdminPOOL/web from git archive into components/web.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ARCH_COMMIT="${ARCH_COMMIT:-b281721}"
ARCH_PREFIX="archive/2026-06-06-wip/AdminPOOL/web"
DEST="$ROOT/components/web"

rm -rf "$DEST"
mkdir -p "$DEST"

while IFS= read -r path; do
  [[ -z "$path" ]] && continue
  rel="${path#"$ARCH_PREFIX"/}"
  [[ "$rel" == *.md ]] && continue
  dest_file="$DEST/$rel"
  mkdir -p "$(dirname "$dest_file")"
  git -C "$ROOT" show "$ARCH_COMMIT:$path" >"$dest_file"
done < <(git -C "$ROOT" ls-tree -r --name-only "$ARCH_COMMIT" -- "$ARCH_PREFIX/")

echo "Synced $(find "$DEST" -type f | wc -l) web files from $ARCH_COMMIT."
