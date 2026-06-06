# conceptbase — server + workbench + examples (end-user product bundle).
{
  lib,
  runCommand,
  cbserver,
  cb-workbench,
  examples-corpus,
  makeWrapper,
}:

runCommand "conceptbase"
  {
    nativeBuildInputs = [ makeWrapper ];
  }
  ''
    mkdir -p $out/bin
    ln -s ${cbserver}/bin/cbserver $out/bin/cbserver
    ln -s ${cb-workbench}/bin/cbiva $out/bin/cbiva
    mkdir -p $out/share
    ln -s ${examples-corpus}/share/examples $out/share/examples
    ln -s ${cbserver}/share/serverSources $out/share/serverSources
    ln -s ${cbserver}/share/system-data $out/share/system-data
  ''
