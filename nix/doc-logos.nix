# doc-logos — ConceptBase logo assets (GIF, PNG, OpenOffice/LibreOffice sources).
{ lib, stdenv, componentSrc }:

import ./doc-static.nix {
  inherit lib stdenv componentSrc;
  pname = "doc-logos";
  subdir = "logos";
  requiredFiles = [
    "README.md"
    "CB.gif"
    "CB-Linux.gif"
    "CB-trans.gif"
    "CB-Linux-trans.gif"
    "conceptbase-cc-logo.png"
  ];
}
