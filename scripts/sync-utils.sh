#!/usr/bin/env bash
# Sync AdminPOOL/utils from git archive into components/cb-testclient.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ARCH_COMMIT="${ARCH_COMMIT:-b281721}"
ARCH_PREFIX="archive/2026-06-06-wip/AdminPOOL/utils"
DEST="$ROOT/components/cb-testclient"

list_archive_files() {
  git -C "$ROOT" ls-tree -r --name-only "$ARCH_COMMIT" -- "$ARCH_PREFIX/"
}

should_skip() {
  local rel="$1"
  case "$rel" in
    */.#* | */*.orig | */*.1 | */scripts/.#* ) return 0 ;;
    CB_ExportAdmin | CB_ExportProduct | CB_Makedepend | CB_CopyOldFiles | sccs2cvs | Makefile ) return 0 ;;
    CB_TestClient/Makefile | CB_TestClient/README ) return 0 ;;
  esac
  return 1
}

dest_for() {
  local rel="$1"
  case "$rel" in
    CB_AnalyzerDiff | CB_OutputAnalyzer ) echo "$DEST/tools/$rel" ;;
    CB_TestClient/* ) echo "$DEST/src/${rel#CB_TestClient/}" ;;
    * ) echo "$DEST/src/$rel" ;;
  esac
}

rm -rf "$DEST"
mkdir -p "$DEST/src" "$DEST/tools"

while IFS= read -r path; do
  [[ -z "$path" ]] && continue
  rel="${path#"$ARCH_PREFIX"/}"
  should_skip "$rel" && continue
  dest_file="$(dest_for "$rel")"
  mkdir -p "$(dirname "$dest_file")"
  git -C "$ROOT" show "$ARCH_COMMIT:$path" >"$dest_file"
done < <(list_archive_files)

chmod +x "$DEST/tools/CB_OutputAnalyzer" "$DEST/tools/CB_AnalyzerDiff" 2>/dev/null || true
chmod +x "$DEST/src/CB_AutoTest" "$DEST/src/CB_Create_SYSTEM" "$DEST/src/CB_TestClient" 2>/dev/null || true

echo "Synced $(find "$DEST" -type f | wc -l) cb-testclient files from $ARCH_COMMIT."
