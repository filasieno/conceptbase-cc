# jgl — ObjectSpace Java Generic Library 3.1.0 (legacy dependency).
{
  lib,
  stdenv,
  maven,
  jdk,
  java-legacy-maven-lock,
  legacy-maven-src,
}:

let
  version = "3.1.0";
in
stdenv.mkDerivation {
  pname = "jgl";
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

    cd jgl
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
    install -m644 "$NIX_BUILD_TOP/$sourceRoot/jgl/target/jgl-${version}.jar" "$out/lib/jgl.jar"
    install -m644 "$NIX_BUILD_TOP/$sourceRoot/jgl/pom.xml" "$out/lib/jgl.pom"
    runHook postInstall
  '';

  checkPhase = ''
    runHook preCheck
    jar="$NIX_BUILD_TOP/$sourceRoot/jgl/target/jgl-${version}.jar"
    test -s "$jar"
    ${jdk}/bin/jar tf "$jar" | grep -q 'com/objectspace/jgl/SList.class'
    ${jdk}/bin/jar tf "$jar" | grep -q 'com/objectspace/jgl/HashSet.class'
    runHook postCheck
  '';

  meta = with lib; {
    description = "ObjectSpace JGL 3.1.0 — recovered sources for ConceptBase.cc";
    homepage = "https://gitlab.com/mjeu/conceptbasecc";
    platforms = [ "x86_64-linux" ];
    license = licenses.free;
  };
}
