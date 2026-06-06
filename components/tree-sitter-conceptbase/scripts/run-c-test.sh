#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="${ROOT}/target"

: "${CC:=cc}"
: "${TREE_SITTER_INCLUDE:=}"
: "${TREE_SITTER_LIB:=}"

if [[ -z "${TREE_SITTER_INCLUDE}" || -z "${TREE_SITTER_LIB}" ]]; then
  if command -v pkg-config >/dev/null 2>&1 && pkg-config --exists tree-sitter; then
    TREE_SITTER_INCLUDE="$(pkg-config --cflags-only-I tree-sitter)"
    TREE_SITTER_LIB="$(pkg-config --libs tree-sitter)"
  elif command -v tree-sitter >/dev/null 2>&1; then
    ts_root="$(dirname "$(dirname "$(command -v tree-sitter)")")"
    TREE_SITTER_INCLUDE="-I${ts_root}/include"
    TREE_SITTER_LIB="-L${ts_root}/lib -ltree-sitter -Wl,-rpath,${ts_root}/lib"
  else
    echo "error: set TREE_SITTER_INCLUDE/TREE_SITTER_LIB or install tree-sitter" >&2
    exit 1
  fi
fi

TEST_BIN="${TARGET}/test_parse"
# shellcheck disable=SC2086
"${CC}" -std=c11 -O2 ${TREE_SITTER_INCLUDE} \
  -I"${TARGET}/include" \
  -o "${TEST_BIN}" \
  "${ROOT}/tests/test_parse.c" \
  "${TARGET}/lib/libtree-sitter-conceptbase.a" \
  ${TREE_SITTER_LIB}

"${TEST_BIN}"
