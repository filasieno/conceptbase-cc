# cbserver — ConceptBase server process (query, tell, untell, notifications).
{
  lib,
  stdenv,
  swi-prolog,
  llvmPackages,
  coreutils,
  findutils,
  makeWrapper,
  componentSrc,
  server-repl,
  server-engine,
  system-data,
  libcbgeneral,
  libcbipc,
  libcbtelos,
  libcbtelosserver,
  libcbcos,
  man-pages,
}:

let
  linkArchives = lib.concatStringsSep " " [
    "${libcbipc}/lib/libcbipc.a"
    "${libcbgeneral}/lib/libcbgeneral.a"
    "${libcbcos}/lib/libcbcos.a"
    "${libcbtelos}/lib/libcbtelos.a"
    "${libcbtelosserver}/lib/libcbtelosserver.a"
  ];
in
stdenv.mkDerivation {
  pname = "cbserver";
  version = "0.1.1";
  src = componentSrc;

  nativeBuildInputs = [ swi-prolog llvmPackages.clang makeWrapper ];
  buildInputs = [
    swi-prolog
    server-repl
    server-engine
    system-data
    libcbipc
    libcbgeneral
    libcbcos
    libcbtelos
    libcbtelosserver
  ];

  dontConfigure = true;
  doCheck = false;
  doInstallCheck = true;

  buildPhase = ''
    runHook preBuild
    export CC=clang
    export CXX=clang++
    export PKG_CONFIG_PATH="${swi-prolog}/lib/pkgconfig''${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"
    export CB_POOL="${server-engine}/share"
    export CB_VARIANT=""
    export CBS_DIR="${server-engine}/share/serverSources/Prolog_Files"
    export CBL_DIR="${system-data}/share/system-data"

    swipl-ld -v -cc "$CC" \
      -o CBserver \
      -pl ${server-repl}/bin/server-repl \
      src/swiMain.c \
      -lstdc++ -lm \
      ${linkArchives}

    # Precompile the Prolog kernel into a saved state so the server does not
    # recompile ~115 .swi.pl sources on every boot. CB_SAVE_STATE makes
    # swiMain.c load + loadCBkernel, qsave_program, then exit (no server start).
    echo "cbserver: precompiling kernel saved state"
    CB_SAVE_STATE="$PWD/cbserver.prc" ./CBserver
    test -s "$PWD/cbserver.prc"

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin" "$out/lib" \
      "$out/share/serverSources/Prolog_Files" \
      "$out/share/system-data"
    install -m755 CBserver "$out/lib/CBserver"
    install -m644 cbserver.prc "$out/lib/cbserver.prc"
    install -m755 ${componentSrc}/cbserver-launcher.sh "$out/bin/cbserver"
    cp -r ${server-engine}/share/serverSources/Prolog_Files/* \
      "$out/share/serverSources/Prolog_Files/"
    cp -r ${system-data}/share/system-data/* "$out/share/system-data/"
    mkdir -p "$out/share/man/man1"
    ln -s ${man-pages}/share/man/man1/cbserver.1.gz "$out/share/man/man1/cbserver.1.gz"

    runHook postInstall
  '';

  installCheckPhase = ''
    runHook preInstallCheck
    test -x "$out/bin/cbserver"
    test -x "$out/lib/CBserver"
    test -s "$out/lib/cbserver.prc"
    test -s "$out/share/serverSources/Prolog_Files/startCBserver.swi.pl"
    runHook postInstallCheck
  '';

  meta = with lib; {
    description = "ConceptBase.cc cbserver — knowledge base server";
    homepage = "https://gitlab.com/mjeu/conceptbasecc";
    platforms = [ "x86_64-linux" ];
    license = licenses.free;
    mainProgram = "cbserver";
  };
}
