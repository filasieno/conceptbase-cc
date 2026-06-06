{ stdenv, cbserver, cbshell, howtosRoot, lib, ... }@args:

let
  call = file: import file args;
in
  call ./avoid-traps-with-aggregation-functions-in-constraints.nix
  # More HOW-TO checks are added here one by one.
