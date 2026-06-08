# HOW-TO: define-formulas-at-the-meta-class-level
args:

{
  "define-formulas-at-the-meta-class-level" = import ./howto-check.nix (args // {
    slug = "define-formulas-at-the-meta-class-level";
    freshServerPerSml = true;
    maxSmlFiles = 3;
    runGelSmoke = true;
  });
}
