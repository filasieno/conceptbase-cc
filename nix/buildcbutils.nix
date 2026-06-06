# Shared CMake modules for libcb* (Flex/Bison, find_package helpers, CTest).
{
  lib,
  stdenv,
  cmakeModulesSrc,
}:

stdenv.mkDerivation {
  pname = "buildcbutils";
  version = "0.1.1";
  src = cmakeModulesSrc;

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/share/cmake/buildcbutils"
    cp "$src"/*.cmake "$out/share/cmake/buildcbutils/"
    runHook postInstall
  '';

  meta = with lib; {
    description = "ConceptBase.cc buildcbutils — shared CMake modules for libcb* components";
    homepage = "https://gitlab.com/mjeu/conceptbasecc";
    platforms = [ "x86_64-linux" ];
    license = licenses.free;
  };
}
