# libcbtelosclient — Telos parser (client).
{
  lib,
  stdenv,
  cmake,
  ninja,
  pkg-config,
  bison,
  flex,
  buildcbutils,
  componentSrc,
}:

stdenv.mkDerivation {
  pname = "libcbtelosclient";
  version = "0.1.1";
  src = componentSrc;

  nativeBuildInputs = [ cmake ninja pkg-config bison flex buildcbutils ];
  doCheck = true;

  cmakeFlags = [
    "-GNinja"
    "-DCMAKE_BUILD_TYPE=RelWithDebInfo"
    "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON"
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DCMAKE_INSTALL_INCLUDEDIR=include"
    "-DCMAKE_MODULE_PATH=${buildcbutils}/share/cmake/buildcbutils"
  ];

  meta = with lib; {
    description = "ConceptBase.cc libcbtelosclient — Telos parser (client)";
    homepage = "https://gitlab.com/mjeu/conceptbasecc";
    platforms = [ "x86_64-linux" ];
    license = licenses.free;
  };
}
