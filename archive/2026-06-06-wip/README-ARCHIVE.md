# Archived snapshot — 2026-06-06

This directory is a frozen copy of the repository as it existed before the greenfield redesign.

## Contents

| Path | Description |
|------|-------------|
| `AdminPOOL/` | Legacy admin tools, `CB_Make`, `compileCB`, developer scripts |
| `ProductPOOL/` | Upstream ConceptBase sources (C server, Prolog, Java clients) |
| `nix/` | Nix flake packages (`swi-prolog`, `cb-make`, server, Java modules, docker) |
| `flake.nix`, `flake.lock` | Flake entry point (monolith → fine-grained derivations, in progress) |
| `ProductPOOL/java/pom.xml` | Maven multi-module experiment (common, api, telos, graph, workbench, distribution) |
| `Dockerfile`, `docker/` | Container build sketch (Nix builder → Debian runtime) |

## Work completed in this snapshot

- Cloned from `gitlab.com/mjeu/conceptbasecc`
- Removed tracked binaries (GNU make blobs, `CBserver`, JARs, `.o` files) from git index
- Removed 212 `CVS/` metadata directories
- Removed Java Makefiles; started Maven migration
- SWI-Prolog 6.6.6 builds as separate Nix derivation
- Server native build partially working (C/Prolog); Java build via Maven not finished (offline sandbox / plugin deps)

## Do not build from here directly

Treat this tree as read-only reference. The active project lives at the repository root.

## Pruned migrated content

Files already copied into `components/` are removed from this archive snapshot so git
records a **rename/move** into the greenfield tree (not a duplicate copy). Run
`scripts/fix-migration-git.sh` after syncing from archive to refresh pruning and index
renames. Remaining paths are intentionally archive-only (Makefiles, platform variants,
unmigrated docs, `.pro` sources, EXPORT trees, etc.).
