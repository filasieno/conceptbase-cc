# Static documentation bundle (plain text / legacy formats from archive).
{
  lib,
  stdenv,
  pname,
  version ? "0.1.0",
  componentSrc,
  subdir,
  requiredFiles,
}:

stdenv.mkDerivation {
  inherit pname version;
  src = componentSrc;

  dontConfigure = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/share/doc/${subdir}"
    cp -r ${subdir}/* "$out/share/doc/${subdir}/"
    ${lib.concatStringsSep "\n" (
      map (f: "test -s \"$out/share/doc/${subdir}/${f}\"") requiredFiles
    )}
    runHook postInstall
  '';

  meta = with lib; {
    description = "ConceptBase.cc ${pname} (static export)";
    homepage = "https://gitlab.com/mjeu/conceptbasecc";
    platforms = [ "x86_64-linux" ];
    license = licenses.free;
  };
}
