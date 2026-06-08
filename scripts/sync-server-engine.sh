#!/usr/bin/env bash
# Sync SWI server kernel modules into components/server-engine.
#
# The archive ProductPOOL/serverSources/Prolog_Files/*.pro files are legacy
# BIM-Prolog sources. Greenfield uses SWI modules (*.swi.pl) already under
# components/server-engine/src/.
#
# Intentionally not ported from archive .pro (functionality merged or disabled):
#   Rep_fast, Rep_h, Rep_temp, PropositionBase  -> PropositionProcessor.swi.pl
#   ViewCodeGenerator                           -> commented out in startCBserver
#   QO_CostBase_old                             -> superseded by QO_costBase
#   CostModel, DatalogOptimizer, ECA_SML2Events, FragmentToHtml, sml_gramm_dcg
#     -> not loaded by startCBserver.swi.pl (no runtime references)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ARCH_COMMIT="${ARCH_COMMIT:-b281721}"
ARCH_PREFIX="archive/2026-06-06-wip/ProductPOOL"
DEST="$ROOT/components/server-engine/src"

# Prefer pre-built SWI modules from linux64 if present in archive snapshot.
ARCH_SWI="$ARCH_PREFIX/linux64/serverSources/Prolog_Files"
ARCH_PRO="$ARCH_PREFIX/serverSources/Prolog_Files"

mkdir -p "$DEST"

synced=0
if git -C "$ROOT" ls-tree -r --name-only "$ARCH_COMMIT" -- "$ARCH_SWI/" 2>/dev/null \
  | grep -q '\.swi\.pl$'; then
  find "$DEST" -mindepth 1 -maxdepth 1 -name '*.swi.pl' -delete 2>/dev/null || true
  while IFS= read -r path; do
    [[ "$path" == *.swi.pl ]] || continue
    base="$(basename "$path")"
    git -C "$ROOT" show "$ARCH_COMMIT:$path" >"$DEST/$base"
    synced=$((synced + 1))
  done < <(git -C "$ROOT" ls-tree -r --name-only "$ARCH_COMMIT" -- "$ARCH_SWI/")
else
  echo "sync-server-engine: no *.swi.pl in archive at $ARCH_SWI; keeping existing $DEST modules." >&2
  synced="$(find "$DEST" -name '*.swi.pl' 2>/dev/null | wc -l)"
fi

archive_pro="$(git -C "$ROOT" ls-tree -r --name-only "$ARCH_COMMIT" -- "$ARCH_PRO/" \
  | grep -c '\.pro$' || true)"
component_swi="$(find "$DEST" -name '*.swi.pl' | wc -l)"
echo "Synced $synced server-engine modules ($component_swi .swi.pl on disk; archive has $archive_pro legacy .pro files)."
