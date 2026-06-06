# Fixed-output Maven plugin cache for offline jgl/grappa builds.
{
  lib,
  stdenv,
  maven,
  jdk,
  legacy-maven-src,
}:

stdenv.mkDerivation {
  pname = "java-legacy-maven-lock";
  version = "1";

  src = legacy-maven-src;

  nativeBuildInputs = [ maven jdk ];

  outputHashMode = "recursive";
  outputHashAlgo = "sha256";
  outputHash = "sha256-3xY3RtmgGbsdwIRrszVzV+zP0dzxz2LsPxPw5Sws4Nw=";

  dontConfigure = true;

  buildPhase = ''
    runHook preBuild

    repo="$TMPDIR/maven-repository"
    mkdir -p "$repo"

    cd jgl
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
    description = "Pinned Maven plugins for ConceptBase.cc legacy Java libraries (jgl, grappa)";
    homepage = "https://gitlab.com/mjeu/conceptbasecc";
    platforms = [ "x86_64-linux" ];
    license = licenses.free;
  };
}
