# cb-graph — standalone graph editor (CBEditor).
{ callPackage, java-reactor, jdk }:

callPackage ./java-app.nix {
  inherit java-reactor jdk;
  pname = "cb-graph";
  program = "cbgraph";
  mainClass = "i5.cb.graph.cbeditor.CBEditor";
}
