#!/usr/bin/env bash
# Build tree-sitter-conceptbase:
#   - generate parser.c (single grammar; UTF-8/UTF-16 selected at parse time)
#   - link shared (.so) and static (.a) libraries
#   - optional WebAssembly module (.wasm)
#   - install public C/C++ headers
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE="${ROOT}/source"
TARGET="${ROOT}/target"
GENERATED="${TARGET}/generated"
LIBDIR="${TARGET}/lib"
INCLUDEDIR="${TARGET}/include"
PKGCONFIGDIR="${TARGET}/lib/pkgconfig"

VERSION="${VERSION:-0.1.0}"
SONAME="${SONAME:-libtree-sitter-conceptbase.so.${VERSION}}"
SHARED_NAME="${SHARED_NAME:-libtree-sitter-conceptbase.so}"
STATIC_NAME="${STATIC_NAME:-libtree-sitter-conceptbase.a}"
WASM_NAME="${WASM_NAME:-tree-sitter-conceptbase.wasm}"

: "${CC:=cc}"
: "${AR:=ar}"
: "${TREE_SITTER_INCLUDE:=}"
: "${BUILD_WASM:=1}"

if [[ -z "${TREE_SITTER_INCLUDE}" ]]; then
  if command -v pkg-config >/dev/null 2>&1 && pkg-config --exists tree-sitter; then
    TREE_SITTER_INCLUDE="$(pkg-config --cflags-only-I tree-sitter)"
  elif command -v tree-sitter >/dev/null 2>&1; then
    ts_root="$(dirname "$(dirname "$(command -v tree-sitter)")")"
    TREE_SITTER_INCLUDE="-I${ts_root}/include"
  else
    echo "error: set TREE_SITTER_INCLUDE or install tree-sitter" >&2
    exit 1
  fi
fi

CFLAGS=(
  -O2 -fPIC -std=c11 -Wall -Wextra -Wno-unused-parameter
  ${TREE_SITTER_INCLUDE}
  -I"${GENERATED}"
  -I"${SOURCE}"
)

echo "==> source:   ${SOURCE}"
echo "==> target:   ${TARGET}"

rm -rf "${GENERATED}"
mkdir -p "${GENERATED}" "${LIBDIR}" "${INCLUDEDIR}" "${PKGCONFIGDIR}"

echo "==> tree-sitter generate"
(
  cd "${SOURCE}"
  tree-sitter generate
)

echo "==> stage generated artifacts"
cp -f "${SOURCE}/src/parser.c" "${GENERATED}/parser.c"
cp -r "${SOURCE}/src/tree_sitter" "${GENERATED}/"
[[ -f "${SOURCE}/src/grammar.json" ]] && cp -f "${SOURCE}/src/grammar.json" "${GENERATED}/"
[[ -f "${SOURCE}/src/node-types.json" ]] && cp -f "${SOURCE}/src/node-types.json" "${GENERATED}/"

OBJECTS=(
  "${GENERATED}/parser.o"
  "${GENERATED}/conceptbase_parser.o"
)

echo "==> compile objects"
# shellcheck disable=SC2086
"${CC}" -c "${CFLAGS[@]}" -o "${GENERATED}/parser.o" "${GENERATED}/parser.c"
# shellcheck disable=SC2086
"${CC}" -c "${CFLAGS[@]}" -o "${GENERATED}/conceptbase_parser.o" "${SOURCE}/conceptbase_parser.c"

echo "==> link ${SHARED_NAME}"
# shellcheck disable=SC2086
"${CC}" -shared -o "${LIBDIR}/${SHARED_NAME}" "${OBJECTS[@]}" -Wl,-soname,"${SONAME}"

echo "==> archive ${STATIC_NAME}"
"${AR}" rcs "${LIBDIR}/${STATIC_NAME}" "${OBJECTS[@]}"

if [[ "${BUILD_WASM}" == "1" ]] && command -v tree-sitter >/dev/null 2>&1; then
  echo "==> build ${WASM_NAME} (tree-sitter wasm backend)"
  if (
    cd "${SOURCE}"
    tree-sitter build --wasm -o "${LIBDIR}/${WASM_NAME}" .
  ); then
    :
  else
    echo "warning: wasm build skipped (toolchain unavailable)" >&2
  fi
fi

rm -f "${GENERATED}"/*.o

echo "==> install headers"
cp -f "${SOURCE}/tree-sitter-conceptbase.h" "${INCLUDEDIR}/"
cp -f "${SOURCE}/conceptbase_parser.h" "${INCLUDEDIR}/"
cp -f "${SOURCE}/conceptbase_parser.hpp" "${INCLUDEDIR}/"

cat > "${PKGCONFIGDIR}/tree-sitter-conceptbase.pc" <<EOF
prefix=${TARGET}
exec_prefix=\${prefix}
libdir=\${prefix}/lib
includedir=\${prefix}/include

Name: tree-sitter-conceptbase
Description: Tree-sitter grammar for ConceptBase (UTF-8 / UTF-16LE / UTF-16BE)
Version: ${VERSION}
Libs: -L\${libdir} -ltree-sitter-conceptbase -ltree-sitter
Libs.private:
Cflags: -I\${includedir}
EOF

echo "==> done"
echo "    ${LIBDIR}/${SHARED_NAME}"
echo "    ${LIBDIR}/${STATIC_NAME}"
[[ -f "${LIBDIR}/${WASM_NAME}" ]] && echo "    ${LIBDIR}/${WASM_NAME}"
echo "    ${INCLUDEDIR}/tree-sitter-conceptbase.h"
echo "    ${INCLUDEDIR}/conceptbase_parser.h"
echo "    ${INCLUDEDIR}/conceptbase_parser.hpp"
echo "    ${PKGCONFIGDIR}/tree-sitter-conceptbase.pc"
