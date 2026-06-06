# java — single Maven multi-module reactor (cbcommon … cbdistribution), JDK 25.
{
  lib,
  stdenv,
  maven,
  jdk,
  java-maven-lock,
  java-reactor-src,
}:

let
  version = "8.5";
in
stdenv.mkDerivation {
  pname = "java";
  inherit version;

  src = java-reactor-src;

  nativeBuildInputs = [ maven jdk ];
  doCheck = true;
  dontConfigure = true;

  buildPhase = ''
    runHook preBuild

    repo="$NIX_BUILD_TOP/maven-repository"
    mkdir -p "$repo"
    cp -r ${java-maven-lock}/. "$repo"/
    chmod -R u+w "$repo"

    cd java
    mvn -f pom.xml install \
      -Dmaven.repo.local="$repo" \
      -DskipTests \
      --batch-mode \
      --offline

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    cd "$NIX_BUILD_TOP/$sourceRoot/java"
    mkdir -p "$out/lib"
    install -m644 cbcommon/target/cbcommon-${version}.jar "$out/lib/cbcommon.jar"
    install -m644 cbapi/target/cbapi-${version}.jar "$out/lib/cbapi.jar"
    install -m644 cbtelos/target/cbtelos-${version}.jar "$out/lib/cbtelos.jar"
    install -m644 cbgraph/target/cbgraph-${version}.jar "$out/lib/cbgraph.jar"
    install -m644 cbgraph/target/cbgraph-${version}.jar "$out/lib/cbworkbench.jar"
    install -m644 cbdistribution/target/cbdistribution-${version}-cb.jar "$out/lib/cb.jar"
    install -m644 cbdistribution/target/cbdistribution-${version}-installer.jar \
      "$out/lib/cbinstaller.jar"
    runHook postInstall
  '';

  checkPhase = ''
    runHook preCheck
    cd "$NIX_BUILD_TOP/$sourceRoot/java"
    cbcommon_jar="cbcommon/target/cbcommon-${version}.jar"
    cbapi_jar="cbapi/target/cbapi-${version}.jar"
    cbgraph_jar="cbgraph/target/cbgraph-${version}.jar"
    cb_jar="cbdistribution/target/cbdistribution-${version}-cb.jar"

    for j in "$cbcommon_jar" "$cbapi_jar" "$cbgraph_jar" "$cb_jar"; do
      test -s "$j"
    done
    jar tf "$cbcommon_jar" | grep -q 'i5/cb/PrologPreProcessor.class'
    jar tf "$cbapi_jar" | grep -q 'i5/cb/CBShell.class'
    jar tf "$cbgraph_jar" | grep -q 'i5/cb/GUIHandler.class'

    cat > ppp_test.pro <<'EOF'
#MODULE(PppTest)
#EXPORT(foo/0)
foo :- true.
EOF
    java -cp "$cbcommon_jar" i5.cb.PrologPreProcessor SWI ppp_test.pro
    test -s ppp_test.swi.pl
    grep -q ":- module('PppTest'" ppp_test.swi.pl
    runHook postCheck
  '';

  meta = with lib; {
    description = "ConceptBase.cc Java clients — Maven multi-module reactor (JDK 25)";
    homepage = "https://gitlab.com/mjeu/conceptbasecc";
    platforms = [ "x86_64-linux" ];
    license = licenses.free;
  };
}
