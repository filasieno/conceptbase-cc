# cb-workbench — desktop Workbench (CBIva).
{ callPackage, java-reactor, jdk, man-pages }:

callPackage ./java-app.nix {
  inherit java-reactor jdk man-pages;
  pname = "cb-workbench";
  program = "cbiva";
  mainClass = "i5.cb.workbench.CBIva";
  manPage = "cbiva";
}
