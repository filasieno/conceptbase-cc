# Native server: Prolog + C (CBserver) — no Java makefile build.
{ lib
, stdenv
, src
, swi-prolog
, cb-make
, openjdk11
, serverPatches
, flex
, bison
, clang
, gmp
, readline
, ncurses
, zlib
, which
, bash
}:

stdenv.mkDerivation rec {
  pname = "conceptbase-server";
  version = "8.5";

  inherit src;

  nativeBuildInputs = [
    flex bison clang cb-make which openjdk11 bash
  ];

  buildInputs = [
    swi-prolog gmp readline ncurses zlib
  ];

  patchPhase = ''
    runHook prePatch
    ${serverPatches}
    runHook postPatch
  '';

  buildPhase = ''
    runHook preBuild

    export CB_LOCATION=NixBuild
    export CB_WORK="$PWD/ProductPOOL"
    export CB_HOME="$out"
    export CB_VARIANT=linux64
    export CB_CC=${clang}/bin/clang
    export CB_CXX=${clang}/bin/clang++
    export SWI_HOME=${swi-prolog}
    export SWI_INCLUDE=${swi-prolog}/lib/swipl-${swi-prolog.version}/include
    export TEX_CAPABLE=/none/
    export JAVA_CAPABLE=/none/
    export PATH="$PWD/AdminPOOL/bin:$out:$PATH"

    mkdir -p "$out" AdminPOOL/utils
    ln -sf ${cb-make}/bin/make "AdminPOOL/utils/make.linux64"

    echo "Building ConceptBase.cc server (native)..."
    (cd "$CB_WORK" && CB_Make touch_src)
    (cd "$CB_WORK/serverSources/Prolog_Files" && CB_Make dcg)
    (cd "$CB_WORK/serverSources" && CB_Make all)
    (cd "$CB_WORK" && CB_Make export)
    CB_HOME="$out" CB_WORK="$CB_WORK" ${bash} -c 'cd "$CB_WORK" && CB_Install "$out"'

    runHook postBuild
  '';

  postInstall = ''
    if [ -f "$out/cbserver" ]; then
      substituteInPlace "$out/cbserver" \
        --replace-fail 'CB_HOME:=`dirname $0`' "CB_HOME:=$out"
    fi
    if [ -f "$out/cbshell" ]; then
      substituteInPlace "$out/cbshell" \
        --replace-fail 'CB_HOME:=`dirname $0`' "CB_HOME:=$out"
    fi

    mkdir -p "$out/bin"
    if [ -f "$out/linux64/bin/CBserver" ]; then
      install -m755 "$out/linux64/bin/CBserver" "$out/bin/CBserver"
    fi
    install -m755 AdminPOOL/bin/CBvariant "$out/bin/CBvariant"
  '';

  meta = with lib; {
    description = "ConceptBase.cc server (linux64, SWI-Prolog + CBserver)";
    homepage = "https://gitlab.com/mjeu/conceptbasecc";
    license = licenses.bsd2;
    platforms = platforms.x86_64;
    mainProgram = "cbserver";
  };
}
