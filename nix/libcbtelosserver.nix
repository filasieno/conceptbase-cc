# libcbtelosserver — Telos / Prolog FFI (server).
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
  libcbtelos,
  buildcbutils,
  componentSrc,
}:

stdenv.mkDerivation {
  pname = "libcbtelosserver";
  version = "0.1.1";
  src = componentSrc;

  nativeBuildInputs = [ cmake ninja pkg-config bison flex buildcbutils ];
  buildInputs = [ swi-prolog libcbgeneral libcbtelos ];

  cmakeFlags = [
    "-GNinja"
    "-DCMAKE_BUILD_TYPE=RelWithDebInfo"
    "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON"
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DCMAKE_INSTALL_INCLUDEDIR=include"
    "-DCMAKE_MODULE_PATH=${buildcbutils}/share/cmake/buildcbutils"
    "-DCMAKE_PREFIX_PATH=${lib.concatStringsSep ";" (map (d: "${d}") [ libcbgeneral libcbtelos swi-prolog ])}"
  ];

  meta = with lib; {
    description = "ConceptBase.cc libcbtelosserver — Telos / Prolog FFI (server)";
    homepage = "https://gitlab.com/mjeu/conceptbasecc";
    platforms = [ "x86_64-linux" ];
    license = licenses.free;
  };
}
