# cb-web — AdminPOOL web portal (static CBdoc + PHP download site).
{
  lib,
  stdenv,
  php,
  componentSrc,
}:

stdenv.mkDerivation {
  pname = "cb-web";
  version = "0.1.0";
  src = componentSrc;

  nativeBuildInputs = [ php ];
  dontConfigure = true;
  doInstallCheck = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/share/web/CBdoc" "$out/share/web/php"
    cp -r CBdoc/* "$out/share/web/CBdoc/"
    cp -r php/* "$out/share/web/php/"
    runHook postInstall
  '';

  installCheckPhase = ''
    runHook preInstallCheck
    test -s "$out/share/web/CBdoc/InstallationGuide.txt"
    test -s "$out/share/web/CBdoc/cb.css"
    for f in "$out"/share/web/php/*.php; do
      ${php}/bin/php -l "$f"
    done
    runHook postInstallCheck
  '';

  meta = with lib; {
    description = "ConceptBase.cc web portal — static CBdoc and PHP download scripts (requires PHP at deploy time)";
    homepage = "https://gitlab.com/mjeu/conceptbasecc";
    platforms = [ "x86_64-linux" ];
    license = licenses.free;
  };
}
