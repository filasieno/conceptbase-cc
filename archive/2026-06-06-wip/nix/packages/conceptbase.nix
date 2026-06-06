# Full ConceptBase.cc install: native server + Maven-built Java clients.
{ lib, runCommand, conceptbase-server, java-distribution, jdk11, src }:

let
  version = conceptbase-server.version;
in
runCommand "conceptbase-cc-${version}" {
  inherit version;
  meta = with lib; {
    description = "ConceptBase.cc full install (server + Java clients)";
    homepage = "https://gitlab.com/mjeu/conceptbasecc";
    license = licenses.bsd2;
    platforms = platforms.x86_64;
    mainProgram = "cbserver";
  };
} ''
  mkdir -p "$out"
  cp -a ${conceptbase-server}/. "$out"/

  mkdir -p "$out/lib/classes"
  cp ${java-distribution}/lib/cb.jar "$out/lib/classes/cb.jar"
  cp ${java-distribution}/lib/CBinstaller.jar "$out/lib/classes/CBinstaller.jar"

  cat > "$out/bin/cbiva" <<EOF
#!/bin/sh
export CB_HOME="$out"
exec ${jdk11}/bin/java -Djava.awt.headless=false -DCB_HOME="\$CB_HOME" \
  -classpath "\$CB_HOME/lib/classes/*" i5.cb.workbench.CBIva "\$@"
EOF
  chmod +x "$out/bin/cbiva"

  cat > "$out/bin/cbshell" <<EOF
#!/bin/sh
export CB_HOME="$out"
export CB_PORTNR="\''${CB_PORTNR:=4001}"
exec ${jdk11}/bin/java -DCB_HOME="\$CB_HOME" -DCB_PORTNR="\$CB_PORTNR" \
  -classpath "\$CB_HOME/lib/classes/cb.jar" i5.cb.CBShell "\$@"
EOF
  chmod +x "$out/bin/cbshell"

  install -m755 ${src}/docker/entrypoint.sh "$out/docker-entrypoint.sh"
''
