# HOW-TO: design-service-networks
args:

{
  "design-service-networks" = import ./howto-check.nix (args // {
    slug = "design-service-networks";
    freshServerPerCbs = true;
    maxCbsFiles = 1;
    skipCbs = [ "create-DB-SERVICE.cbs.txt" ];
    runSml = false;
    runGelSmoke = true;
  });
}
