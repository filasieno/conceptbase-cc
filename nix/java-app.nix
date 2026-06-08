# Wrap the fat cb.jar reactor output as a runnable desktop/CLI application.
{
  lib,
  stdenv,
  makeWrapper,
  jdk,
  java-reactor,
  pname,
  version ? "8.5",
  program,
  mainClass,
  javaFlags ? [ "-Djava.awt.headless=false" ],
  env ? { },
  man-pages ? null,
  manPage ? null,
}:

let
  envFlags = lib.concatMap (name: [
    "--set"
    name
    (env.${name} or "")
  ]) (lib.attrNames env);
in
stdenv.mkDerivation {
  inherit pname version;
  nativeBuildInputs = [ makeWrapper jdk ];
  dontUnpack = true;
  dontBuild = true;
  doCheck = false;
  doInstallCheck = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin" "$out/lib"
    cp ${java-reactor}/lib/cb.jar "$out/lib/cb.jar"

    makeWrapper ${jdk}/bin/java "$out/bin/${program}" \
      --set CB_HOME "$out" \
      ${lib.concatStringsSep " " (
        lib.map (flag: "--add-flags ${lib.escapeShellArg flag}") javaFlags
      )} \
      --add-flags "-DCB_HOME=$out" \
      ${lib.concatStringsSep " " envFlags} \
      --add-flags "-cp" \
      --add-flags "$out/lib/cb.jar" \
      --add-flags ${lib.escapeShellArg mainClass}

    ${lib.optionalString (man-pages != null && manPage != null) ''
      mkdir -p "$out/share/man/man1"
      ln -s ${man-pages}/share/man/man1/${manPage}.1.gz "$out/share/man/man1/${manPage}.1.gz"
    ''}

    runHook postInstall
  '';

  installCheckPhase = ''
    runHook preInstallCheck
    test -x "$out/bin/${program}"
    test -s "$out/lib/cb.jar"
    jar tf "$out/lib/cb.jar" | grep -q '${lib.replaceStrings [ "." ] [ "/" ] mainClass}.class'
    runHook postInstallCheck
  '';

  meta = with lib; {
    description = "ConceptBase.cc ${pname} — ${program}";
    homepage = "https://gitlab.com/mjeu/conceptbasecc";
    platforms = [ "x86_64-linux" ];
    license = licenses.free;
    mainProgram = program;
  };
}
