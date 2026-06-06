# doc-user-manual — ConceptBase.cc User Manual (Typst → PDF + HTML).
{ lib, stdenv, typst, componentSrc }:

import ./doc-common.nix {
  inherit lib stdenv typst;
  pname = "doc-user-manual";
  version = "8.5";
  src = componentSrc;
  mainFile = "user-manual/main.typ";
}
