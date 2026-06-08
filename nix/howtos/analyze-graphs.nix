# HOW-TO: analyze-graphs — Organigraph model + graph smoke
args:

{
  "analyze-graphs" = import ./howto-check.nix (args // {
    slug = "analyze-graphs";
    skipSml = [
      "bigcity-queries.sml.txt"
      "Clique.sml.txt"
      "ConnectedComponents.sml.txt"
    ];
    runGelSmoke = true;
  });
}
