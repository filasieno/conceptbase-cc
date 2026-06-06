# module-preprocessor — #MODULE dialect sources → SWI loadable modules.
{
  lib,
  stdenv,
  jdk,
  java-reactor,
  componentSrc,
}:

stdenv.mkDerivation {
  pname = "module-preprocessor";
  version = "0.1.1";
  src = componentSrc;

  nativeBuildInputs = [ jdk ];
  doCheck = true;
  dontConfigure = true;

  buildPhase = ''
    runHook preBuild
    mkdir -p out
    cbcommon="${java-reactor}/lib/cbcommon.jar"
    for pro in src/*.pro; do
      base="$(basename "$pro" .pro)"
      java -cp "$cbcommon" i5.cb.PrologPreProcessor SWI "$pro"
      mv "''${base}.swi.pl" "out/"
    done
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/share/module-preprocessor"
    cp out/*.swi.pl "$out/share/module-preprocessor/"
    runHook postInstall
  '';

  checkPhase = ''
    runHook preCheck
    test "$(find out -name '*.swi.pl' | wc -l)" -ge 1
    grep -rq ":- module(" out/
    runHook postCheck
  '';

  meta = with lib; {
    description = "ConceptBase.cc module-preprocessor — #MODULE source translation";
    homepage = "https://gitlab.com/mjeu/conceptbasecc";
    platforms = [ "x86_64-linux" ];
    license = licenses.free;
  };
}
