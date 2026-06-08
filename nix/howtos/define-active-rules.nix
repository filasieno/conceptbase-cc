# HOW-TO: define-active-rules (many scripts; asset validation + smoke)
args:

{
  "define-active-rules" = import ./howto-assets-check.nix (args // {
    slug = "define-active-rules";
  });
}
