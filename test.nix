with import <nixpkgs> {};
stdenv.mkDerivation {
  name = "test-howto";
  src = ./components/examples/HOW-TO/Batch\ load\ multiple\ files\ in\ ConceptBase;
  buildInputs = [
    (import ./flake.nix).packages.x86_64-linux.cbserver
    (import ./flake.nix).packages.x86_64-linux.cbshell
  ];
  buildPhase = ''
    cbshell < demoloader.cbs.txt
  '';
  installPhase = "mkdir \$out";
}
