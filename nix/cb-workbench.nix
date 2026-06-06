# cb-workbench — desktop Workbench (CBIva).
{ callPackage, java-reactor, jdk }:

callPackage ./java-app.nix {
  inherit java-reactor jdk;
  pname = "cb-workbench";
  program = "cbiva";
  mainClass = "i5.cb.workbench.CBIva";
}
