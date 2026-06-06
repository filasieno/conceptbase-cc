# libcbcview — C++ client view helpers.
{
  lib,
  stdenv,
  cmake,
  ninja,
  pkg-config,
  bison,
  flex,
  libcbc,
  buildcbutils,
  componentSrc,
}:

stdenv.mkDerivation {
  pname = "libcbcview";
  version = "0.1.1";
  src = componentSrc;

  nativeBuildInputs = [ cmake ninja pkg-config bison flex buildcbutils ];
  buildInputs = [ libcbc ];

  cmakeFlags = [
    "-GNinja"
    "-DCMAKE_BUILD_TYPE=RelWithDebInfo"
    "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON"
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DCMAKE_INSTALL_INCLUDEDIR=include"
    "-DCMAKE_MODULE_PATH=${buildcbutils}/share/cmake/buildcbutils"
    "-DCMAKE_PREFIX_PATH=${libcbc}"
  ];

  meta = with lib; {
    description = "ConceptBase.cc libcbcview — C++ client view helpers";
    homepage = "https://gitlab.com/mjeu/conceptbasecc";
    platforms = [ "x86_64-linux" ];
    license = licenses.free;
  };
}
