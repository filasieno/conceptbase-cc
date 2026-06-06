# Offline Maven repository: pinned Central dependencies (legacy libs built in reactor).
{ lib, runCommand, java-deps }:

let
  installFetchedJar = repo: group: artifact: ver: jar:
    let
      path = lib.replaceStrings [ "." ] [ "/" ] group;
      dir = "${repo}/${path}/${artifact}/${ver}";
    in ''
      mkdir -p "${dir}"
      cp ${jar} "${dir}/${artifact}-${ver}.jar"
      cat > "${dir}/${artifact}-${ver}.pom" <<POM
      <?xml version="1.0" encoding="UTF-8"?>
      <project xmlns="http://maven.apache.org/POM/4.0.0">
        <modelVersion>4.0.0</modelVersion>
        <groupId>${group}</groupId>
        <artifactId>${artifact}</artifactId>
        <version>${ver}</version>
      </project>
      POM
    '';
in
runCommand "java-maven-local-repo" { } ''
  repo=$out/repository

  ${installFetchedJar "$repo" "com.formdev" "flatlaf" "3.4" "${java-deps."flatlaf-3.4.jar"}"}
  ${installFetchedJar "$repo" "org.apache.xmlgraphics" "batik-all" "1.19" "${java-deps."batik-all-1.19.jar"}"}
  ${installFetchedJar "$repo" "xml-apis" "xml-apis-ext" "1.3.04" "${java-deps."xml-apis-ext-1.3.04.jar"}"}
''
