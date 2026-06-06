# doc-prog-manual — ConceptBase.cc Programmer Manual (Typst → PDF + HTML).
{ lib, stdenv, typst, componentSrc }:

import ./doc-common.nix {
  inherit lib stdenv typst;
  pname = "doc-prog-manual";
  version = "6.1";
  src = componentSrc;
  mainFile = "prog-manual/main.typ";
}
