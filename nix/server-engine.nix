# server-engine — versioned server kernel modules (SWI dialect).
{
  lib,
  stdenv,
  grammar-compiler,
  componentSrc,
}:

stdenv.mkDerivation {
  pname = "server-engine";
  version = "0.1.1";
  src = componentSrc;

  dontConfigure = true;
  doCheck = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/share/serverSources/Prolog_Files"
    cp -r src/*.swi.pl "$out/share/serverSources/Prolog_Files/"
    mkdir -p "$out/share/serverSources/Prolog_Files/grammar"
    cp ${grammar-compiler}/share/grammar-compiler/*_dcg.pro \
      "$out/share/serverSources/Prolog_Files/grammar/"
    runHook postInstall
  '';

  checkPhase = ''
    runHook preCheck
    test -s src/startCBserver.swi.pl
    test "$(find src -name '*.swi.pl' | wc -l)" -ge 100
    grep -q ":- module(" src/startCBserver.swi.pl
    if grep -rP '[äöüßÄÖÜ]' src --include='*.swi.pl' >/dev/null 2>&1; then
      echo "server-engine: German umlauts found in kernel sources"
      grep -rP '[äöüßÄÖÜ]' src --include='*.swi.pl' | head -20
      exit 1
    fi
    runHook postCheck
  '';

  meta = with lib; {
    description = "ConceptBase.cc server-engine — query and rule kernel modules";
    homepage = "https://gitlab.com/mjeu/conceptbasecc";
    platforms = [ "x86_64-linux" ];
    license = licenses.free;
  };
}
