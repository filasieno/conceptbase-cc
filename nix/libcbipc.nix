# libcbipc — IPC message parser and SWI foreign glue.
{
  lib,
  stdenv,
  cmake,
  ninja,
  pkg-config,
  bison,
  flex,
  swi-prolog,
  libcbgeneral,
  buildcbutils,
  componentSrc,
}:

stdenv.mkDerivation {
  pname = "libcbipc";
  version = "0.1.1";
  src = componentSrc;

  nativeBuildInputs = [ cmake ninja pkg-config bison flex buildcbutils ];
  buildInputs = [ swi-prolog libcbgeneral ];

  cmakeFlags = [
    "-GNinja"
    "-DCMAKE_BUILD_TYPE=RelWithDebInfo"
    "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON"
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DCMAKE_INSTALL_INCLUDEDIR=include"
    "-DCMAKE_MODULE_PATH=${buildcbutils}/share/cmake/buildcbutils"
    "-DCMAKE_PREFIX_PATH=${lib.concatStringsSep ";" (map (d: "${d}") [ libcbgeneral swi-prolog ])}"
  ];

  meta = with lib; {
    description = "ConceptBase.cc libcbipc — IPC message parser and SWI foreign glue";
    homepage = "https://gitlab.com/mjeu/conceptbasecc";
    platforms = [ "x86_64-linux" ];
    license = licenses.free;
  };
}
