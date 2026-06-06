# mmkit — Metamodelling Kit VS Code extension (packaged as a .vsix via vsce).
{
  lib,
  stdenvNoCC,
  vsce,
  nodejs,
  componentSrc,
}:

stdenvNoCC.mkDerivation rec {
  pname = "mmkit";
  version = "0.1.0";
  src = componentSrc;

  nativeBuildInputs = [ vsce nodejs ];

  dontConfigure = true;
  doCheck = true;

  buildPhase = ''
    runHook preBuild
    export HOME="$TMPDIR"
    cp -r --no-preserve=mode,ownership "$src" build
    cd build
    vsce package --no-dependencies --out "mmkit-${version}.vsix"
    cd ..
    runHook postBuild
  '';

  checkPhase = ''
    runHook preCheck
    export HOME="$TMPDIR"
    node -e "JSON.parse(require('fs').readFileSync('$src/package.json','utf8'))"
    node --check "$src/src/extension.js"
    test -s build/mmkit-${version}.vsix
    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    cp "build/mmkit-${version}.vsix" "$out/"
    runHook postInstall
  '';

  meta = with lib; {
    description = "ConceptBase Metamodelling Kit — VS Code extension for O-Telos / CBL / ECArule";
    homepage = "https://gitlab.com/mjeu/conceptbasecc";
    platforms = [ "x86_64-linux" ];
    license = licenses.bsd2;
  };
}
