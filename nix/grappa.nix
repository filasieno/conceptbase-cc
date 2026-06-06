# grappa — AT&T Graphviz Grappa 1.2 (legacy dependency).
{
  lib,
  stdenv,
  maven,
  jdk,
  java-legacy-maven-lock,
  legacy-maven-src,
}:

let
  version = "1.2";
in
stdenv.mkDerivation {
  pname = "grappa";
  inherit version;

  src = legacy-maven-src;

  nativeBuildInputs = [ maven jdk ];
  doCheck = true;
  dontConfigure = true;

  buildPhase = ''
    runHook preBuild

    repo="$NIX_BUILD_TOP/maven-repository"
    mkdir -p "$repo"
    cp -r ${java-legacy-maven-lock}/. "$repo"/
    chmod -R u+w "$repo"

    cd grappa
    mvn -f pom.xml install \
      -Dmaven.repo.local="$repo" \
      -DskipTests \
      --batch-mode \
      --offline

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/lib"
    install -m644 "$NIX_BUILD_TOP/$sourceRoot/grappa/target/grappa-${version}.jar" "$out/lib/grappa.jar"
    install -m644 "$NIX_BUILD_TOP/$sourceRoot/grappa/pom.xml" "$out/lib/grappa.pom"
    runHook postInstall
  '';

  checkPhase = ''
    runHook preCheck
    jar="$NIX_BUILD_TOP/$sourceRoot/grappa/target/grappa-${version}.jar"
    test -s "$jar"
    ${jdk}/bin/jar tf "$jar" | grep -q 'att/grappa/GrappaConstants.class'
    runHook postCheck
  '';

  meta = with lib; {
    description = "AT&T Grappa 1.2 — recovered sources for ConceptBase.cc graph tooling";
    homepage = "https://gitlab.com/mjeu/conceptbasecc";
    platforms = [ "x86_64-linux" ];
    license = licenses.free;
  };
}
