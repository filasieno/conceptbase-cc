# Composite source tree: java reactor + legacy Maven modules (jgl, grappa, legacy-parent).
{ runCommand, componentSrc }:

runCommand "java-reactor-src" { } ''
  mkdir -p "$out"
  cp -r ${componentSrc "java"} "$out/java"
  cp -r ${componentSrc "jgl"} "$out/jgl"
  cp -r ${componentSrc "grappa"} "$out/grappa"
  cp -r ${componentSrc "legacy"} "$out/legacy"
''
