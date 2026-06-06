# ConceptBase.cc

Greenfield redesign of [ConceptBase.cc](https://gitlab.com/mjeu/conceptbasecc).

## Quick start

```bash
nix build                  # full product (server + workbench + examples)
nix run .#cbserver &       # start server
nix run .#cb-workbench     # desktop UI
nix flake check
```

Packaging rules and commands: **[CONTRIBUTING.md](CONTRIBUTING.md)**

## Archive

Prior work lives under `archive/2026-06-06-wip/` (read-only reference).  
Migration status: **[docs/archive-migration.md](docs/archive-migration.md)**

## Build graph

**[deliverable-nodes.md](deliverable-nodes.md)** — 43 nodes, topological dependencies.

Flake exposes **five user-facing packages** only: `conceptbase`, `cbserver`, `cb-workbench`,
`cb-shell`, `cb-graph`.

## Prolog editing (LSP)

See **[docs/dev-swi-lsp.md](docs/dev-swi-lsp.md)**.

```bash
./scripts/verify-swi-lsp.sh
```

## Documentation (in progress)

Typst sources under `components/doc/`. Not exposed as flake packages until migration completes.
See `components/doc/README.md`.
