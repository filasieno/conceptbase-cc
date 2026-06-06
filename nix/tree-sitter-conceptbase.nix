# tree-sitter-conceptbase — Telos / CBL / ECArule grammar.
#
# Returns an attrset:
#   library   — shared grammar build (libs, headers, test_parse; no corpus CTest)
#   languages — per-surface-language CMake derivations (filtered corpus + optional test_parse)
#   aggregate — meta derivation depending on library + all language checks
{
  lib,
  stdenv,
  cmake,
  ninja,
  pkg-config,
  tree-sitter,
  nodejs,
  componentSrc,
  runCommandLocal,
}:

let
  version = "0.1.0";

  cmakeCommon = [
    "-GNinja"
    "-DCMAKE_BUILD_TYPE=RelWithDebInfo"
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DCMAKE_INSTALL_INCLUDEDIR=include"
    "-DBUILD_WASM=OFF"
  ];

  checkPhase = ''
    runHook preCheck
    export HOME="$TMPDIR/ts-home"
    export XDG_CACHE_HOME="$HOME/.cache"
    mkdir -p "$HOME/.cache"
    export CTEST_PARALLEL_LEVEL=1
    cmake --build . --target test
    runHook postCheck
  '';

  # Shared library build (install tree used for documentation; corpus tests are per-language).
  library = stdenv.mkDerivation {
    pname = "tree-sitter-conceptbase";
    inherit version;
    src = componentSrc;

    nativeBuildInputs = [ cmake ninja pkg-config tree-sitter nodejs ];
    buildInputs = [ tree-sitter ];
    doCheck = true;

    cmakeFlags = cmakeCommon ++ [
      "-DBUILD_TESTING=ON"
      "-DTS_CORPORA=skip"
      "-DTS_RUN_PARSE_TEST=ON"
    ];

    checkPhase = ''
      runHook preCheck
      log=$(mktemp)
      if ! (cd source && tree-sitter generate >"$log" 2>&1); then
        echo "tree-sitter generate failed:"
        cat "$log"
        exit 1
      fi
      if grep -E 'Error|Unresolved rule' "$log"; then
        echo "tree-sitter generate reported errors:"
        cat "$log"
        exit 1
      fi
      test -s source/src/parser.c
      runHook postCheck
    '';
  };

  languageDefs = {
    telos = {
      description = "Telos frames";
      corpora = [
        "telos"
        "documentation-frames"
      ];
    };
    assertions = {
      description = "CBL assertions, rules, and snippets";
      corpora = [
        "assertions"
        "documentation-assertions"
        "documentation-snippets"
      ];
    };
    ecarules = {
      description = "ECArule active rules";
      corpora = [ "ecarules" ];
    };
    examples = {
      description = "Examples corpus (.sml)";
      corpora = [ "examples-corpus" ];
    };
    encoding = {
      description = "UTF-8 / UTF-16 encoding (corpus + C API)";
      corpora = [ "encoding" ];
      runParseTest = true;
    };
  };

  mkLanguageDerivation =
    name: cfg:
    stdenv.mkDerivation {
      pname = "tree-sitter-conceptbase-${name}";
      inherit version;
      src = componentSrc;

      nativeBuildInputs = [ cmake ninja pkg-config tree-sitter nodejs ];
      buildInputs = [ tree-sitter ];
      doCheck = true;
      inherit checkPhase;

      cmakeFlags = cmakeCommon ++ [
        "-DBUILD_TESTING=ON"
        "-DTS_CORPORA=${lib.concatStringsSep ";" cfg.corpora}"
      ] ++ lib.optionals (!(cfg.runParseTest or false)) [
        "-DTS_RUN_PARSE_TEST=OFF"
      ];
    };

  languages = lib.mapAttrs mkLanguageDerivation languageDefs;

  aggregate = runCommandLocal "tree-sitter-conceptbase"
    {
      nativeBuildInputs = lib.attrValues languages;
      buildInputs = [ library ];
    }
    ''
      mkdir -p "$out"
      cat > "$out/manifest" <<EOF
library=${library}
${lib.concatStringsSep "\n" (
        lib.mapAttrsToList (n: d: "${n}=${d}") languages
      )}
EOF
    '';

in
{
  inherit version library languages aggregate;

  meta = {
    description = "Tree-sitter grammar for ConceptBase Telos, CBL, and ECArules";
    homepage = "https://gitlab.com/mjeu/conceptbasecc";
    platforms = lib.platforms.linux;
    license = lib.licenses.bsd2;
  };
}
