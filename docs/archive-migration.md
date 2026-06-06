# Archive migration — status report

Reference corpus: `archive/2026-06-06-wip/` (removed from the working tree in `d54a9ac`; recoverable via `git show d54a9ac^:archive/...`).  
Active tree: repository root (`components/`, `nix/`, `flake.nix`).  
Node inventory: **[deliverable-nodes.md](../deliverable-nodes.md)**.

---

## Executive summary (2026-06-06)

| Metric | Value |
|--------|------:|
| Deliverable nodes (inventory) | 43 + HOW-TO corpus |
| Nodes with sources in `components/` | 26+ |
| `server-engine` kernel modules | 115 `.swi.pl` |
| Example files (`examples-corpus`) | 188 |
| HOW-TO tutorials (`components/howtos/`) | 52 |
| Flake **packages** (user-facing) | 6 + `default` (`conceptbase`, apps, `mmkit`, `docs`) |
| Flake **checks** | core + 52 howtos + `howto-manual` + 7 doc nodes |

The greenfield repo has replaced the archive **build system** (Make/`CB_Make` → Nix + CMake + Maven) and migrated the **full product spine**: native libraries, Prolog kernel, `cbserver`, Java clients, examples, HOW-TO corpus, Typst manuals, and static documentation exports.

---

## Migrated and building

| Archive area | Greenfield path | Nix |
|--------------|-----------------|-----|
| Server C libs (`libGeneral` … `libCos3`) | `components/libcb*` | internal → `cbserver` |
| Server Prolog kernel | `components/server-engine/` | `server-engine` check |
| SYSTEM bootstrap | `components/system-data/` | `system-data` check |
| `CBserver` binary | `components/cbserver/` | `.#cbserver` |
| Java client stack | `components/java/` | `java-reactor` → apps |
| Client C libs | `components/libcbc*` | checks |
| DCG grammars | `components/grammar-compiler/` | check |
| Examples | `components/examples/` | `examples-corpus` |
| HOW-TO tutorials | `components/howtos/` | 52 checks + `howto-manual` |
| User / prog / tutorial manuals | `components/doc/{user,prog,tutorial}-manual/` | `doc-*` checks |
| TechInfo / Developper / licenses | `components/doc/{tech-info,developer,external-licenses}/` | `doc-*` checks |
| Tree-sitter grammar | `components/tree-sitter-conceptbase/` | checks (generate + corpus) |

Sync scripts (archive snapshot in git history):

| Script | Target |
|--------|--------|
| `./scripts/sync-java-sources.sh` | `components/java/` |
| `./scripts/sync-server-engine.sh` | `components/server-engine/` |
| `./scripts/sync-system-data.sh` | `components/system-data/` |
| `./scripts/sync-examples.sh` | `components/examples/` |
| `./scripts/sync-static-docs.sh` | `components/doc/{tech-info,developer,external-licenses}/` |

---

## Verification

```bash
nix flake check -L
nix build .#docs -L
nix build .#checks.x86_64-linux.integration-tests -L
nix run .#cbserver &
nix run .#cb-workbench
```

---

## Intentionally not migrated

- Platform variants (`windows/`, `sun4/`, `mac/`, …) — Linux x86_64 only
- `AdminPOOL` / `CB_Make` / CVS metadata — replaced by `nix flake check`
- `libCos` / `libCos2` — superseded by `libcbcos`
- LaTeX sources — converted to Typst; originals in git history only
- Man pages, `.desktop`, mime XML — not part of the Nix product bundle

---

## Remaining work (post Phase F / H)

| Phase | Item | Status |
|-------|------|--------|
| G | GitLab CI (`nix flake check`) | not started |
| G | Docker image (server + JRE + workbench) | not started |
| G | Operator runbook in `docs/` | not started |

See **[deliverable-nodes.md](../deliverable-nodes.md)** for objectives and acceptance criteria.
