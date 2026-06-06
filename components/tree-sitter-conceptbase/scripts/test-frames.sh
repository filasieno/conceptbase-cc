#!/usr/bin/env bash
# Smoke-parse Telos frame examples (no expected CST — checks for ERROR/MISSING only).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE="${ROOT}/source"
FRAMES="${FRAMES:-/tmp/frames.txt}"
SPLIT="${SPLIT:-/tmp/frames_split}"

if [[ ! -f "${FRAMES}" ]]; then
  echo "skip: ${FRAMES} not found (extract from docs first)" >&2
  exit 0
fi

mkdir -p "${SPLIT}"
awk -v D="${SPLIT}" '
/^===== /{ n++; fn=sprintf("%s/f%03d.cb", D, n); next }
{ if(n>0) print > fn }
' "${FRAMES}"

cd "${SOURCE}"
tree-sitter generate >/dev/null 2>&1

ok=0
bad=0
skip=0
for f in "${SPLIT}"/f*.cb; do
  [[ -f "$f" ]] || continue
  if grep -qE '\.\.\.|\[\.\.\.\]|\[offline\]|^[[:space:]]*cd |tell "|asks\(|\{\\tt|\\ref|\\section|\\begin' "$f"; then
    skip=$((skip + 1))
    continue
  fi
  frame_ok=1
  # Frame files on disk are UTF-8; UTF-16 encoding flags require UTF-16 byte streams.
  out=$(tree-sitter parse --encoding utf8 --quiet "$f" 2>&1) || true
  if echo "${out}" | grep -qE 'ERROR|MISSING'; then
    bad=$((bad + 1))
    frame_ok=0
    echo "FAIL  $(basename "$f")"
    echo "${out}" | grep -nE 'ERROR|MISSING' | head -2 | sed 's/^/        /'
  fi
  if [[ "${frame_ok}" -eq 1 ]]; then
    ok=$((ok + 1))
  fi
done

echo "-----"
echo "OK=${ok} FAIL=${bad} SKIP=${skip}"
[[ "${bad}" -eq 0 ]]
