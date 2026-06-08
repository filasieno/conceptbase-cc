# HOW-TO: define-and-use-functions
args:

{
  "define-and-use-functions" = import ./howto-check.nix (args // {
    slug = "define-and-use-functions";
    freshServerPerCbs = true;
    runSml = false;
    runGelSmoke = true;
  });
}
