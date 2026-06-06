# libcbgeneral — C / Prolog bridge and OS utilities.
{
  lib,
  stdenv,
  cmake,
  ninja,
  pkg-config,
  bison,
  flex,
  swi-prolog,
  componentSrc,
}:

stdenv.mkDerivation {
  pname = "libcbgeneral";
  version = "0.1.1";
  src = componentSrc;

  nativeBuildInputs = [ cmake ninja pkg-config bison flex ];
  buildInputs = [ swi-prolog ];

  cmakeFlags = [
    "-GNinja"
    "-DCMAKE_BUILD_TYPE=RelWithDebInfo"
    "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON"
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DCMAKE_INSTALL_INCLUDEDIR=include"
  ];

  meta = with lib; {
    description = "ConceptBase.cc libcbgeneral — C / Prolog bridge and OS utilities";
    homepage = "https://gitlab.com/mjeu/conceptbasecc";
    platforms = [ "x86_64-linux" ];
    license = licenses.free;
  };
}
