# Java client JARs and launcher scripts (no native server).
{ lib, runCommand, java-distribution, jdk11 }:

let
  version = java-distribution.version;
in
runCommand "conceptbase-clients-${version}" {
  inherit version;
  meta = with lib; {
    description = "ConceptBase.cc Java clients (cb.jar, launchers)";
    homepage = "https://gitlab.com/mjeu/conceptbasecc";
    license = licenses.bsd2;
  };
} ''
  mkdir -p "$out/lib/classes" "$out/bin"

  cp ${java-distribution}/lib/cb.jar "$out/lib/classes/cb.jar"
  cp ${java-distribution}/lib/CBinstaller.jar "$out/lib/classes/CBinstaller.jar"

  cat > "$out/bin/cbiva" <<EOF
#!/bin/sh
export CB_HOME="$out"
exec ${jdk11}/bin/java -Djava.awt.headless=false -DCB_HOME="\$CB_HOME" \
  -classpath "\$CB_HOME/lib/classes/*" i5.cb.workbench.CBIva "\$@"
EOF
  chmod +x "$out/bin/cbiva"
  ln -sf "$out/bin/cbiva" "$out/bin/cbgraph"

  cat > "$out/bin/cbshell" <<EOF
#!/bin/sh
export CB_HOME="$out"
export CB_PORTNR="\''${CB_PORTNR:=4001}"
exec ${jdk11}/bin/java -DCB_HOME="\$CB_HOME" -DCB_PORTNR="\$CB_PORTNR" \
  -classpath "\$CB_HOME/lib/classes/cb.jar" i5.cb.CBShell "\$@"
EOF
  chmod +x "$out/bin/cbshell" "$out/cbshell"
''
