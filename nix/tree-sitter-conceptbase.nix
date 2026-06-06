# tree-sitter-conceptbase — Telos / CBL / ECArule grammar → shared + static libs, WASM, headers.
{
  lib,
  stdenv,
  tree-sitter,
  nodejs,
  pkg-config,
  iconv,
  python3,
  componentSrc,
}:

stdenv.mkDerivation {
  pname = "tree-sitter-conceptbase";
  version = "0.1.0";
  src = componentSrc;

  nativeBuildInputs = [ tree-sitter nodejs pkg-config ];
  buildInputs = [ tree-sitter iconv python3 ];
  doCheck = true;
  dontConfigure = true;

  buildPhase = ''
    runHook preBuild
    export HOME="$TMPDIR"
    export XDG_CACHE_HOME="$TMPDIR/.cache"
    export CC="${stdenv.cc.targetPrefix}cc"
    export AR="${stdenv.cc.targetPrefix}ar"
    export TREE_SITTER_INCLUDE="-I${tree-sitter}/include"
    export TREE_SITTER_LIB="-L${tree-sitter}/lib -ltree-sitter -Wl,-rpath,${tree-sitter}/lib"
    # WASM needs wasi-sdk download; enable outside sandbox or when network is allowed.
    export BUILD_WASM=''${BUILD_WASM:-0}
    bash scripts/build.sh
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/lib/pkgconfig" "$out/include" "$out/share/tree-sitter-conceptbase"
    cp -f target/lib/libtree-sitter-conceptbase.so "$out/lib/"
    cp -f target/lib/libtree-sitter-conceptbase.a "$out/lib/"
    ln -sfn libtree-sitter-conceptbase.so "$out/lib/libtree-sitter-conceptbase.so.0.1"
    if [[ -f target/lib/tree-sitter-conceptbase.wasm ]]; then
      cp -f target/lib/tree-sitter-conceptbase.wasm "$out/lib/"
    fi
    cp -f target/include/tree-sitter-conceptbase.h "$out/include/"
    cp -f target/include/conceptbase_parser.h "$out/include/"
    cp -f target/include/conceptbase_parser.hpp "$out/include/"
    cp -f target/lib/pkgconfig/tree-sitter-conceptbase.pc "$out/lib/pkgconfig/"
    cp -r source/grammar.js source/tree-sitter.json source/queries docs \
      "$out/share/tree-sitter-conceptbase/"
    cp -r target/generated "$out/share/tree-sitter-conceptbase/"
    runHook postInstall
  '';

  checkPhase = ''
    runHook preCheck
    export HOME="$TMPDIR"
    export XDG_CACHE_HOME="$TMPDIR/.cache"

    # Artifacts
    test -f target/lib/libtree-sitter-conceptbase.so
    test -f target/lib/libtree-sitter-conceptbase.a
    test -f target/include/conceptbase_parser.h
    test -f target/include/conceptbase_parser.hpp
    test -f target/generated/parser.c
    file target/lib/libtree-sitter-conceptbase.so | grep -q 'ELF .*shared object'
    file target/lib/libtree-sitter-conceptbase.a | grep -q 'current ar archive'

    # Generated grammar symbols
    grep -q 'tree_sitter_conceptbase' target/generated/parser.c
    grep -q 'assertion_embedding' target/generated/parser.c
    grep -q 'telos_object' target/generated/parser.c
    grep -q 'ecarule' target/generated/parser.c
    test "$(wc -l < target/generated/parser.c)" -ge 1000

    # Corpus tests (UTF-8)
    (
      cd source
      tree-sitter test
    )

    # Encoding smoke (UTF-8 + UTF-16LE via CLI; UTF-16BE via C API)
    export TREE_SITTER_INCLUDE="-I${tree-sitter}/include"
    export TREE_SITTER_LIB="-L${tree-sitter}/lib -ltree-sitter -Wl,-rpath,${tree-sitter}/lib"
    bash scripts/run-c-test.sh
    bash scripts/test-encoding.sh

    # Documented frame smoke (UTF-8 files)
    if [[ -f /tmp/frames.txt ]]; then
      bash scripts/test-frames.sh
    fi

    runHook postCheck
  '';

  meta = with lib; {
    description = "Tree-sitter grammar for ConceptBase — shared/static libs, WASM, UTF-8/UTF-16 API";
    homepage = "https://gitlab.com/mjeu/conceptbasecc";
    platforms = platforms.linux;
    license = licenses.bsd2;
  };
}
