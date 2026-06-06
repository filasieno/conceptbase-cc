# Composite source tree for standalone legacy Maven builds (parent + modules).
{ runCommand, componentSrc }:

runCommand "legacy-maven-src" { } ''
  mkdir -p "$out"
  cp -r ${componentSrc "legacy"} "$out/legacy"
  cp -r ${componentSrc "jgl"} "$out/jgl"
  cp -r ${componentSrc "grappa"} "$out/grappa"
''
