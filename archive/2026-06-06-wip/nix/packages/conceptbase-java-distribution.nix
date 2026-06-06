# Assembles cb.jar and CBinstaller.jar from reactor modules.
{ lib
, stdenv
, src
, maven
, jdk11
, mavenRepos ? [ ]
}:

stdenv.mkDerivation rec {
  pname = "conceptbase-java-distribution";
  version = "8.5";

  inherit src;

  nativeBuildInputs = [ maven jdk11 ];

  buildPhase = ''
    runHook preBuild

    repo=$(mktemp -d)
    for dep in ${lib.concatStringsSep " " (map (r: "\"${r}/repository\"") mavenRepos)}; do
      if [ -d "$dep" ]; then
        cp -rs "$dep"/* "$repo"/ 2>/dev/null || true
      fi
    done

    mvn -f ProductPOOL/java/pom.xml \
      -pl modules/distribution -am \
      package \
      -Dmaven.repo.local="$repo" \
      -DskipTests \
      --batch-mode \
      --offline

    dist="$PWD/ProductPOOL/java/modules/distribution/target"
    mkdir -p "$out/lib"
    cp "$dist/${pname}-${version}-cb.jar" "$out/lib/cb.jar"
    cp "$dist/${pname}-${version}-installer.jar" "$out/lib/CBinstaller.jar"

    runHook postBuild
  '';

  meta = with lib; {
    description = "ConceptBase.cc Java client JARs (cb.jar, CBinstaller.jar)";
    homepage = "https://gitlab.com/mjeu/conceptbasecc";
    license = licenses.bsd2;
  };
}
