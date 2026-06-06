#!/usr/bin/env bash
# Run corpus tests, encoding smoke tests, frame smoke tests, and C encoding tests.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE="${ROOT}/source"

if [[ ! -f "${ROOT}/target/lib/libtree-sitter-conceptbase.a" ]]; then
  echo "==> build (static lib required for encoding tests)"
  bash "${ROOT}/scripts/build.sh"
fi

if [[ "${REGENERATE_DOC_CORPUS:-0}" == "1" ]]; then
  echo "==> regenerate documentation corpus"
  python3 "${ROOT}/scripts/generate-doc-corpus.py"
fi

echo "==> tree-sitter corpus"
(
  cd "${SOURCE}"
  tree-sitter generate
  tree-sitter test
)

echo "==> C encoding unit test"
bash "${ROOT}/scripts/run-c-test.sh"

echo "==> encoding smoke (CLI utf8/utf16-le + C API utf16-be)"
bash "${ROOT}/scripts/test-encoding.sh"

echo "==> documented frames smoke (utf8)"
bash "${ROOT}/scripts/test-frames.sh"
