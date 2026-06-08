# HOW-TO: use-graphical-types — CBShell scripts and graph smoke
args:

{
  "use-graphical-types" = import ./howto-check.nix (args // {
    slug = "use-graphical-types";
    runSml = false;
    runGelSmoke = true;
  });
}
