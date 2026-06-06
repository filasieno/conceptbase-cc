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

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin" "$out/lib" \
      "$out/share/serverSources/Prolog_Files" \
      "$out/share/system-data"
    install -m755 CBserver "$out/lib/CBserver"
    cp -r ${server-engine}/share/serverSources/Prolog_Files/* \
      "$out/share/serverSources/Prolog_Files/"
    cp -r ${system-data}/share/system-data/* "$out/share/system-data/"

    makeWrapper "$out/lib/CBserver" "$out/bin/cbserver" \
      --set CB_HOME "$out" \
      --set CB_POOL "$out/share" \
      --set CB_VARIANT "" \
      --set CBS_DIR "$out/share/serverSources/Prolog_Files" \
      --set CBL_DIR "$out/share/system-data" \
      --set CB_PORTNR "4001" \
      --add-flags "--" \
      --add-flags "-u" \
      --add-flags "nonpersistent" \
      --prefix PATH : "${coreutils}/bin:${findutils}/bin"

    runHook postInstall
  '';

  installCheckPhase = ''
    runHook preInstallCheck
    test -x "$out/bin/cbserver"
    test -x "$out/lib/CBserver"
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
