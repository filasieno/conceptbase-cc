# man-pages — groff manual pages for ConceptBase.cc launchers.
{
  lib,
  stdenv,
  componentSrc,
}:

stdenv.mkDerivation {
  pname = "man-pages";
  version = "0.1.0";
  src = componentSrc;
  dontConfigure = true;
  doInstallCheck = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/share/man/man1"
    for page in man1/*.1; do
      install -m644 "$page" "$out/share/man/man1/"
      gzip -n "$out/share/man/man1/$(basename "$page")"
    done
    runHook postInstall
  '';

  installCheckPhase = ''
    runHook preInstallCheck
    for cmd in cbserver cbshell cbgraph cbiva; do
      test -s "$out/share/man/man1/$cmd.1.gz"
    done
    runHook postInstallCheck
  '';

  meta = with lib; {
    description = "ConceptBase.cc manual pages";
    homepage = "https://gitlab.com/mjeu/conceptbasecc";
    platforms = [ "x86_64-linux" ];
    license = licenses.free;
  };
}
