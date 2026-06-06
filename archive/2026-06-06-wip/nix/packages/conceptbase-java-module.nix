# Build one Maven reactor module; chain repos for fine-grained caching.
{ lib
, stdenv
, src
, maven
, jdk11
, module
, artifactId
, mavenRepos ? [ ]
}:

stdenv.mkDerivation rec {
  pname = artifactId;
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
      -pl modules/${module} -am \
      install \
      -Dmaven.repo.local="$repo" \
      -DskipTests \
      --batch-mode \
      --offline

    mkdir -p "$out/repository" "$out/lib"
    cp -a "$repo"/. "$out/repository"/

    jar=$(find "$repo/com/conceptbase/${artifactId}/${version}" -name '*.jar' ! -name '*-sources.jar' ! -name '*-javadoc.jar' | head -1)
    if [ -n "$jar" ]; then
      cp "$jar" "$out/lib/${artifactId}.jar"
    fi

    runHook postBuild
  '';

  meta = with lib; {
    description = "ConceptBase.cc Java module ${artifactId}";
    homepage = "https://gitlab.com/mjeu/conceptbasecc";
    license = licenses.bsd2;
  };
}
