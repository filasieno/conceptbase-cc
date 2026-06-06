#!/usr/bin/env bash
# Build all Linux libcb* static libraries (local CMake + Ninja).
# Requires bison and flex in PATH (provided by `nix develop`).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LIBS=(
  libcbgeneral
  libcbipc
  libcbtelos
  libcbtelosserver
  libcbcos
  libcbc
  libcbtelosclient
  libcbcview
)

BUILD_TYPE="${BUILD_TYPE:-RelWithDebInfo}"

for lib in "${LIBS[@]}"; do
  dir="$ROOT/components/$lib"
  if [[ ! -f "$dir/CMakeLists.txt" ]]; then
    echo "SKIP $lib (no CMakeLists.txt)" >&2
    continue
  fi
  echo "=== $lib ==="
  cmake -G Ninja -B "$dir/build" -S "$dir" -DCMAKE_BUILD_TYPE="$BUILD_TYPE"
  cmake --build "$dir/build"
  ls -la "$dir/build/"*.a
done

echo "All libcb* archives built."
