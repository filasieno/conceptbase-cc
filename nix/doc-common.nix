# Shared Typst document build (PDF + HTML) for ConceptBase.cc manuals.
{
  lib,
  stdenv,
  typst,
  pname,
  version ? "0.1.0",
  src,
  mainFile ? "main.typ",
}:

stdenv.mkDerivation {
  inherit pname version src;
  nativeBuildInputs = [ typst ];
  doCheck = true;
  dontConfigure = true;

  buildPhase = ''
    runHook preBuild
    mkdir -p "$out/share/doc"
    typst compile --root "$src" "$src/${mainFile}" "$out/share/doc/${pname}.pdf"
    typst compile --root "$src" --features html --format html "$src/${mainFile}" "$out/share/doc/${pname}.html"
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    runHook postInstall
  '';

  checkPhase = ''
    runHook preCheck
    test -s "$out/share/doc/${pname}.pdf"
    test -s "$out/share/doc/${pname}.html"
    runHook postCheck
  '';

  meta = with lib; {
    description = "ConceptBase.cc ${pname} (Typst PDF and HTML)";
    homepage = "https://gitlab.com/mjeu/conceptbasecc";
    platforms = [ "x86_64-linux" ];
    license = licenses.free;
  };
}
