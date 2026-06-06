# doc-external-licenses — third-party license texts shipped with the product.
{ lib, stdenv, componentSrc }:

import ./doc-static.nix {
  inherit lib stdenv componentSrc;
  pname = "doc-external-licenses";
  subdir = "external-licenses";
  requiredFiles = [
    "README.txt"
    "Swi-Prolog-License-14Jan2008.txt"
    "Grappa-License-14Jan2008.txt"
    "FlatLaf-LICENSE-9Mar2024.txt"
    "Batik-License-2025.txt"
  ];
}
