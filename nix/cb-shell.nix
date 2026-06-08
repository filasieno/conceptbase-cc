# cb-shell — terminal client (CBShell).
{ callPackage, java-reactor, jdk, man-pages }:

callPackage ./java-app.nix {
  inherit java-reactor jdk man-pages;
  pname = "cb-shell";
  program = "cbshell";
  mainClass = "i5.cb.CBShell";
  manPage = "cbshell";
  javaFlags = [ ];
  env = {
    CB_PORTNR = "4001";
  };
}
