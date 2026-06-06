# system-data — SYSTEM ontology bootstrap and kernel library files.
{
  lib,
  stdenv,
  componentSrc,
}:

stdenv.mkDerivation {
  pname = "system-data";
  version = "0.1.1";
  src = componentSrc;

  dontConfigure = true;
  doCheck = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/share/system-data"
    cp -r src/* "$out/share/system-data/"
    runHook postInstall
  '';

  checkPhase = ''
    runHook preCheck
    for f in SYSTEM.SWI.builtin SYSTEM.SWI.rule SYSTEM.SWI.telos SYSTEM.SWI.symbol; do
      test -s "src/$f"
    done
    runHook postCheck
  '';

  meta = with lib; {
    description = "ConceptBase.cc system-data — empty database bootstrap ontology";
    homepage = "https://gitlab.com/mjeu/conceptbasecc";
    platforms = [ "x86_64-linux" ];
    license = licenses.free;
  };
}
