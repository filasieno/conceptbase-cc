# Assemble the HOW-TO manual from hand-written page.typ files under components/howtos/.
{ stdenv, typst, manualSrc }:

{
  howto-manual = stdenv.mkDerivation {
    pname = "howto-manual";
    version = "0.1.0";
    src = manualSrc;

    nativeBuildInputs = [ typst ];

    buildPhase = ''
      runHook preBuild
      mkdir -p "$out"
      typst compile --root "$src" "$src/doc/howto-manual.typ" "$out/howto-manual.pdf"
      runHook postBuild
    '';

    dontInstall = true;
  };
}
