# server-repl — interactive embed for developing the server kernel.
{
  lib,
  stdenv,
  swi-prolog,
  llvmPackages,
  componentSrc,
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
  pname = "server-repl";
  version = "0.1.1";
  src = componentSrc;

  dontConfigure = true;
  doCheck = true;

  nativeBuildInputs = [ swi-prolog llvmPackages.clang ];
  buildInputs = [
    swi-prolog
    libcbipc
    libcbgeneral
    libcbcos
    libcbtelos
    libcbtelosserver
  ];

  buildPhase = ''
    runHook preBuild
    export CC=clang
    export CXX=clang++
    export PKG_CONFIG_PATH="${swi-prolog}/lib/pkgconfig''${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"
    swipl-ld -v -cc "$CC" -o server-repl -nostate src/swiInteractive.c \
      -lstdc++ -lm \
      ${linkArchives}
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin"
    install -m755 server-repl "$out/bin/server-repl"
    runHook postInstall
  '';

  checkPhase = ''
    runHook preCheck
    ./server-repl -g 'halt(0).' -q
    runHook postCheck
  '';

  meta = with lib; {
    description = "ConceptBase.cc server-repl — interactive server kernel developer embed";
    homepage = "https://gitlab.com/mjeu/conceptbasecc";
    platforms = [ "x86_64-linux" ];
    license = licenses.free;
    mainProgram = "server-repl";
  };
}
