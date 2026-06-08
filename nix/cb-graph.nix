# cb-graph — standalone graph editor (CBEditor).
{ callPackage, java-reactor, jdk, man-pages }:

callPackage ./java-app.nix {
  inherit java-reactor jdk man-pages;
  pname = "cb-graph";
  program = "cbgraph";
  mainClass = "i5.cb.graph.cbeditor.CBEditor";
  manPage = "cbgraph";
}
