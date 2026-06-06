# cb-shell — terminal client (CBShell).
{ callPackage, java-reactor, jdk }:

callPackage ./java-app.nix {
  inherit java-reactor jdk;
  pname = "cb-shell";
  program = "cbshell";
  mainClass = "i5.cb.CBShell";
  javaFlags = [ ];
  env = {
    CB_PORTNR = "4001";
  };
}
