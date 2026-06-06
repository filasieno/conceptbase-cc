# doc-developer — internal developer reference (archive exports).
{ lib, stdenv, componentSrc }:

import ./doc-static.nix {
  inherit lib stdenv componentSrc;
  pname = "doc-developer";
  subdir = "developer";
  requiredFiles = [
    "README.md"
    "JavaGraphicalTypes.txt"
  ];
}
