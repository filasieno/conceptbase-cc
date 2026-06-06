# Third-party Java libraries — fetched at build time, not vendored in git.
{ lib, fetchurl, runCommand }:

let
  maven = base: artifact: version: file: sha256:
    fetchurl {
      url = "${base}/${artifact}/${version}/${file}";
      inherit sha256;
    };

  upstreamRev = "797579e330db8b473d26693f060b7e3a24ddfbb3";
  legacy = file: sha256:
    fetchurl {
      url = "https://gitlab.com/mjeu/conceptbasecc/-/raw/${upstreamRev}/ProductPOOL/java/lib/${file}";
      inherit sha256;
    };

  jars = {
    "batik-all-1.19.jar" = maven
      "https://repo1.maven.org/maven2/org/apache/xmlgraphics/batik-all"
      "batik-all" "1.19" "batik-all-1.19.jar"
      "09gmvja2wfq71drp7a10v0n3qpkyagmq6nsl99n2pcc6smrjvhsx";
    "flatlaf-3.4.jar" = maven
      "https://repo1.maven.org/maven2/com/formdev/flatlaf"
      "flatlaf" "3.4" "flatlaf-3.4.jar"
      "095fs5vwfkzailwl2srbv5v51vv04wpwkkq4wp54bjjcgpnzgskx";
    "xml-apis-ext-1.3.04.jar" = maven
      "https://repo1.maven.org/maven2/xml-apis/xml-apis-ext"
      "xml-apis-ext" "1.3.04" "xml-apis-ext-1.3.04.jar"
      "0ihn37mabwlf9w1si8gzpb81781rskxayn2a0x4xwmsdqdyqid6h";
    "jgl3.1.0.jar" = legacy "jgl3.1.0.jar"
      "d82aeaab073bd38d683ee55876f34e29651996469e10e546deaeaad631b627b1";
    "grappa1_2.jar" = legacy "grappa1_2.jar"
      "335b1afcdfa06d5b15459bc24b6c3f88763136262e559b8fb8afc0965c0df2f7";
  };
in
runCommand "conceptbase-java-lib" { } ''
  mkdir -p $out
  ${lib.concatStringsSep "\n" (
    lib.map (name: ''
      ln -s ${jars.${name}} $out/${name}
    '') (lib.attrNames jars)
  )}
''
