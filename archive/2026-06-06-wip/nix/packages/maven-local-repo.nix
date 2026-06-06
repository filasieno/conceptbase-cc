# Offline Maven repository: legacy JARs + pinned Central dependencies.
{ lib, runCommand, java-deps, fetchurl }:

let
  version = "8.5";

  maven = base: artifact: ver: file: sha256:
    fetchurl {
      url = "${base}/${artifact}/${ver}/${file}";
      inherit sha256;
    };

  central = maven "https://repo1.maven.org/maven2";

  flatlaf = central "com/formdev/flatlaf" "3.4" "flatlaf-3.4.jar"
    "095fs5vwfkzailwl2srbv5v51vv04wpwkkq4wp54bjjcgpnzgskx";
  batik = central "org/apache/xmlgraphics/batik-all" "1.19" "batik-all-1.19.jar"
    "09gmvja2wfq71drp7a10v0n3qpkyagmq6nsl99n2pcc6smrjvhsx";
  xmlApis = central "xml-apis/xml-apis-ext" "1.3.04" "xml-apis-ext-1.3.04.jar"
    "0ihn37mabwlf9w1si8gzpb81781rskxayn2a0x4xwmsdqdyqid6h";

  installJar = repo: group: artifact: ver: jar:
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
runCommand "conceptbase-maven-local-repo" { } ''
  repo=$out/repository

  ${installJar "$repo" "com.conceptbase.legacy" "jgl" "3.1.0" "${java-deps}/jgl3.1.0.jar"}
  ${installJar "$repo" "com.conceptbase.legacy" "grappa" "1.2" "${java-deps}/grappa1_2.jar"}
  ${installJar "$repo" "com.formdev" "flatlaf" "3.4" flatlaf}
  ${installJar "$repo" "org.apache.xmlgraphics" "batik-all" "1.19" batik}
  ${installJar "$repo" "xml-apis" "xml-apis-ext" "1.3.04" xmlApis}
''
