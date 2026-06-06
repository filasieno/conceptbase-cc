# grammar-compiler — assertion and SML DCG grammars → loadable modules.
{
  lib,
  stdenv,
  swi-prolog,
  componentSrc,
}:

let
  dcgGrammars = [
    "tokens"
    "parseAss"
  ];
in
stdenv.mkDerivation {
  pname = "grammar-compiler";
  version = "0.1.1";
  src = componentSrc;

  nativeBuildInputs = [ swi-prolog ];
  doCheck = true;
  dontConfigure = true;

  buildPhase = ''
    runHook preBuild
    mkdir -p out
    cd src

    generate_dcg() {
      local stem="$1"
      printf 'dcg.\n%s.dcg\nhalt.\n' "$stem" | swipl -q -f dcg.pl
      test -s "''${stem}_dcg.pro"
      mv "''${stem}_dcg.pro" "../out/"
    }

    ${lib.concatStringsSep "\n    " (map (g: ''
      generate_dcg "${g}"
    '') dcgGrammars)}

    cp sml_gramm_dcg.pro.stub ../out/sml_gramm_dcg.pro
    cd ..
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/share/grammar-compiler"
    for f in tokens_dcg.pro parseAss_dcg.pro sml_gramm_dcg.pro; do
      install -m644 "out/$f" "$out/share/grammar-compiler/"
    done
    for f in tokens.dcg parseAss.dcg sml_gramm.dcg; do
      install -m644 "src/$f" "$out/share/grammar-compiler/"
    done
    install -m644 src/dcg.pl "$out/share/grammar-compiler/"
    runHook postInstall
  '';

  checkPhase = ''
    runHook preCheck
    for f in tokens_dcg.pro parseAss_dcg.pro sml_gramm_dcg.pro; do
      test -s "out/$f"
      grep -q '#MODULE' "out/$f"
    done
    test "$(wc -l < out/tokens_dcg.pro)" -ge 40
    test "$(wc -l < out/parseAss_dcg.pro)" -ge 500
    runHook postCheck
  '';

  meta = with lib; {
    description = "ConceptBase.cc grammar-compiler — assertion and SML grammar modules";
    homepage = "https://gitlab.com/mjeu/conceptbasecc";
    platforms = [ "x86_64-linux" ];
    license = licenses.free;
  };
}
