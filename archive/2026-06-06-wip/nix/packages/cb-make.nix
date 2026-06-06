# ConceptBase historically required GNU make 3.80 (3.81+ loops on some Prolog rules).
# make 3.80 no longer links on current glibc; this wrapper uses make 4.x with -j1.
{ lib, gnumake, writeShellScriptBin }:

writeShellScriptBin "make" ''
  exec ${gnumake}/bin/make -j1 "$@"
''
