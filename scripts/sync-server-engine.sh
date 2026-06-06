#!/usr/bin/env bash
# Sync SWI server kernel modules from archive into components/server-engine.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ARCH="$ROOT/archive/2026-06-06-wip/ProductPOOL/linux/serverSources/Prolog_Files"
DEST="$ROOT/components/server-engine/src"

mkdir -p "$DEST"
find "$DEST" -mindepth 1 -delete

shopt -s nullglob
for f in "$ARCH"/*.swi.pl; do
  cp "$f" "$DEST/"
done

echo "Synced $(find "$DEST" -name '*.swi.pl' | wc -l) server-engine modules from archive."
