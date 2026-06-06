# examples-corpus — sample ontologies, queries, and client demos.
{
  lib,
  stdenv,
  componentSrc,
}:

stdenv.mkDerivation {
  pname = "examples-corpus";
  version = "0.1.1";
  src = componentSrc;

  dontConfigure = true;
  doCheck = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/share/examples"
    cp -r src/* "$out/share/examples/"
    runHook postInstall
  '';

  checkPhase = ''
    runHook preCheck
    test -d src/FLIGHT
    test -d src/Clients
    test "$(find src -type f | wc -l)" -ge 100
    runHook postCheck
  '';

  meta = with lib; {
    description = "ConceptBase.cc examples-corpus — demonstration knowledge bases";
    homepage = "https://gitlab.com/mjeu/conceptbasecc";
    platforms = [ "x86_64-linux" ];
    license = licenses.free;
  };
}
