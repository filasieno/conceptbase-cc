# doc-tech-info — installation guide, release notes, known issues.
{ lib, stdenv, componentSrc }:

import ./doc-static.nix {
  inherit lib stdenv componentSrc;
  pname = "doc-tech-info";
  subdir = "tech-info";
  requiredFiles = [
    "README.md"
    "InstallationGuide.txt"
    "ReleaseNotes.txt"
    "Nissues.txt"
  ];
}
