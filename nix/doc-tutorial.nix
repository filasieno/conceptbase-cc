# doc-tutorial — ConceptBase.cc Tutorial (Typst → PDF + HTML).
{ lib, stdenv, typst, componentSrc }:

import ./doc-common.nix {
  inherit lib stdenv typst;
  pname = "doc-tutorial";
  version = "0.1.0";
  src = componentSrc;
  mainFile = "tutorial/main.typ";
}
