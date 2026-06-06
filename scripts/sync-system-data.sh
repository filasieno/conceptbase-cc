#!/usr/bin/env bash
# Sync SYSTEM ontology bootstrap files from archive into components/system-data.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ARCH="$ROOT/archive/2026-06-06-wip/ProductPOOL/lib"
DEST="$ROOT/components/system-data/src"

mkdir -p "$DEST"
find "$DEST" -mindepth 1 -delete

for f in SYSTEM.builtin SYSTEM.rule SYSTEM.telos SYSTEM.symbol \
         SYSTEM.SWI.builtin SYSTEM.SWI.rule SYSTEM.SWI.telos SYSTEM.SWI.symbol \
         SYSTEM.SWI.ecarule SYSTEM.SWI.ruleinfo SYSTEM.cbs SYSTEM.ecarule SYSTEM.prop SYSTEM.ruleinfo; do
  if [[ -f "$ARCH/$f" ]]; then
    cp "$ARCH/$f" "$DEST/"
  fi
done

# Common SML bootstrap snippets used with the server.
for f in "$ARCH"/*.sml; do
  [[ -f "$f" ]] && cp "$f" "$DEST/" || true
done

echo "Synced $(find "$DEST" -type f | wc -l) system-data files from archive."
