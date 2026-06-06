# Fixed-output Maven repository for offline reactor builds (plugins + deps).
{
  lib,
  stdenv,
  maven,
  jdk,
  java-maven-local-repo,
  java-reactor-src,
}:

stdenv.mkDerivation {
  pname = "java-maven-lock";
  version = "8.5";

  src = java-reactor-src;

  nativeBuildInputs = [ maven jdk ];

  outputHashMode = "recursive";
  outputHashAlgo = "sha256";
  # Update after first FOD build reports the correct hash.
  outputHash = "sha256-ENC2NHKL5MZhB5nuxmYjK+CoSv+S1IQFBasGtGJgkwA=";

  dontConfigure = true;

  buildPhase = ''
    runHook preBuild

    repo="$TMPDIR/maven-repository"
    mkdir -p "$repo"
    cp -r ${java-maven-local-repo}/repository/. "$repo"/
    chmod -R u+w "$repo"

    cd java
    mvn -f pom.xml install \
      -Dmaven.repo.local="$repo" \
      -DskipTests \
      --batch-mode

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    cp -r "$TMPDIR/maven-repository"/. "$out"/
    runHook postInstall
  '';

  meta = with lib; {
    description = "Pinned Maven repository for ConceptBase.cc java reactor";
    homepage = "https://gitlab.com/mjeu/conceptbasecc";
    platforms = [ "x86_64-linux" ];
    license = licenses.free;
  };
}
