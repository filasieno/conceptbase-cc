# docs — all documentation outputs (Typst manuals + static exports + HOW-TO book).
{
  lib,
  runCommand,
  doc-user-manual,
  doc-prog-manual,
  doc-tutorial,
  howto-manual,
  doc-tech-info,
  doc-developer,
  doc-external-licenses,
  doc-logos,
}:

runCommand "docs"
  {
    passthru = {
      inherit
        doc-user-manual
        doc-prog-manual
        doc-tutorial
        howto-manual
        doc-tech-info
        doc-developer
        doc-external-licenses
        doc-logos
        ;
    };
  }
  ''
    mkdir -p $out/share/doc
    cp -r ${doc-user-manual}/share/doc/* $out/share/doc/
    cp -r ${doc-prog-manual}/share/doc/* $out/share/doc/
    cp -r ${doc-tutorial}/share/doc/* $out/share/doc/
    install -D ${howto-manual}/howto-manual.pdf $out/share/doc/howto-manual.pdf
    cp -r ${doc-tech-info}/share/doc/* $out/share/doc/
    cp -r ${doc-developer}/share/doc/* $out/share/doc/
    cp -r ${doc-external-licenses}/share/doc/* $out/share/doc/
    cp -r ${doc-logos}/share/doc/* $out/share/doc/
  ''
