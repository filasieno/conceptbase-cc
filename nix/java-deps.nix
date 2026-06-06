# Third-party Java libraries — fetched at build time, not vendored in git.
{ lib, fetchurl }:

let
  maven = base: artifact: version: file: sha256:
    fetchurl {
      url = "${base}/${artifact}/${version}/${file}";
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
  };
in
lib.genAttrs (lib.attrNames jars) (name: jars.${name})
