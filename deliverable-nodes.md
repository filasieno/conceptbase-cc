# ConceptBase.cc — deliverable nodes

Archive reference: `archive/2026-06-06-wip/` (frozen snapshot; read-only).  
Active tree: `components/`, `nix/`, `flake.nix`. Linux x86_64 / SWI-Prolog only.

**Node** = one library, executable, documentation build, or example bundle.  
Component names describe **what they do**, not implementation technology.

| Column | Meaning |
|--------|---------|
| **type** | Kind + language: `lib c`, `lib c++`, `lib java`, `exe embed`, `exe server`, `src grammar`, `doc typst`, `example telos`, … |
| **status** | Migration + Nix: `done`, `wip`, `deferred`, `—` (not started) |
| **dependencies** | Build — cannot compile, link, or package without these nodes |
| **runtime** | Run — cannot execute or use without these nodes |

---

## Current state (2026-06-06)

### Summary

| Metric | Value |
|--------|------:|
| Deliverable nodes (inventory) | 43 |
| Nodes with sources in `components/` | 26 |
| `server-engine` kernel modules | 115 `.swi.pl` |
| Java sources | 264 `.java` |
| Example files (`examples-corpus`) | 188 |
| Flake **packages** (user-facing) | 5 + `default` |
| Flake **checks** (`nix flake check`) | 16 — **all passing** |

The greenfield repo has replaced the archive build system (Make / `CB_Make` → Nix + CMake + Maven).
**Phases A–E are complete:** Prolog kernel, `cbserver`, SYSTEM bootstrap, Java client stack, examples
corpus, and C/C++ integration tests against a live server.

### Verification

```bash
nix flake check -L
nix build .#checks.x86_64-linux.integration-tests -L
nix run .#cbserver &    # then cb-workbench / cb-shell
```

`integration-tests` (internal check, not a user package) runs `testlib.c` and `testlib.cc`: connect,
tell, query, disconnect against `cbserver` on `127.0.0.1:4001`.

### In progress (parallel work)

| Area | Status |
|------|--------|
| **German → English** (`server-engine` comments / log strings) | ~115 files synced; translation ongoing; review for hybrid/broken comments before commit |
| **tree-sitter-conceptbase** | Builds; grammar conflict warnings in `gen.err` — polish remaining |
| **Git landing** | Full migration staged locally (~4k paths); not yet committed on `main` |

### Documentation (Phase F — complete)

| Item | Notes |
|------|-------|
| `doc-user-manual`, `doc-prog-manual`, `doc-tutorial` | Typst → PDF+HTML; flake **checks** + bundled in `.#docs` |
| `doc-howto-manual` | Assembled from `components/howtos/*/page.typ` |
| `doc-tech-info`, `doc-developer`, `doc-external-licenses` | Synced from git archive via `sync-static-docs.sh` |
| Server C libs (`libcbgeneral` … `libcbcos`) | Built as `cbserver` dependencies; no standalone `checks` entry |
| `buildcbutils` | Internal CMake helper only |

---

## Objectives

Ordered by priority. See also **[docs/archive-migration.md](docs/archive-migration.md)** (continuation
plan; executive summary there is stale — this file is authoritative for build status).

### Phase F — Documentation ✓

| # | Objective | Status |
|---|-----------|--------|
| F1 | Typst manuals + flake `docs` package | **done** — `nix build .#docs` |
| F2 | Static docs (`doc-tech-info`, `doc-developer`, `doc-external-licenses`) | **done** — `components/doc/{tech-info,developer,external-licenses}/` |
| F3 | Refresh `docs/archive-migration.md` | **done** |

### Phase G — Packaging and operations

| # | Objective | Acceptance |
|---|-----------|------------|
| G1 | GitLab CI: `nix flake check` on push | Pipeline green on `x86_64-linux` |
| G2 | Docker image (server + JRE 25 + optional workbench) | Documented run path |
| G3 | Operator runbook in `docs/` (essentials from archive `AdminPOOL`) | Port 4001, `CB_POOL`, `CBS_DIR`, `CBL_DIR` |

### Phase H — Quality and developer experience ✓

| # | Objective | Status |
|---|-----------|--------|
| H1 | `server-engine` English pass | **done** — umlaut guard in `server-engine` check |
| H2 | Tree-sitter grammar generate gate | **done** — `tree-sitter generate` in library `checkPhase` |
| H3 | Java client smoke in `integration-tests` | **done** — `cbshell` tell/ask against live `cbserver` |
| H4 | Commit greenfield tree in reviewable chunks | see git history on this branch |

### Out of scope (intentional)

- Platform variants (`windows/`, `sun4/`, …) — Linux x86_64 only
- Archive `AdminPOOL` / CVS / committed binaries
- Per-project container registries or non-Nix build paths

---

## Naming conventions

### Linux native library naming

| Scope | Convention | Example |
|-------|------------|---------|
| **Node id** | `libcb` + short name | `libcbgeneral` |
| **Component directory** | `components/<name>/` | `components/libcbgeneral/` |
| **Nix file** | `nix/<name>.nix` (internal) | `nix/libcbgeneral.nix` |
| **Static archive** | `libcb<name>.a` | `libcbgeneral.a` |

### Java module naming

| Scope | Convention | Example |
|-------|------------|---------|
| **Node id** | `cb` + short name | `cbcommon` |
| **Maven module** | `components/java/cb<name>/` | `cbcommon` |
| **User apps** | flake package | `.#cb-workbench`, `.#cb-shell`, `.#cb-graph` |

### Server kernel naming (no technology in component ids)

| Node id | Component | Role |
|---------|-----------|------|
| `grammar-compiler` | `components/grammar-compiler/` | Assertion/SML DCG → loadable grammar modules |
| `module-preprocessor` | `components/module-preprocessor/` | `#MODULE` sources → SWI dialect |
| `server-engine` | `components/server-engine/` | Query/rule kernel module tree |
| `system-data` | `components/system-data/` | Empty-database SYSTEM ontology bootstrap |
| `server-repl` | `components/server-repl/` | Interactive kernel developer embed (internal) |
| `cbserver` | `components/cbserver/` | Runnable knowledge-base server |

### Flake packages (user-facing only)

| Package | Delivers |
|---------|----------|
| `conceptbase` | **default** — server + workbench + examples bundle |
| `cbserver` | Knowledge-base server (`cbserver`) |
| `cb-workbench` | Desktop Workbench (`cbiva`) |
| `cb-shell` | Terminal client (`cbshell`) |
| `cb-graph` | Graph editor (`cbgraph`) |

All libraries, `java-reactor`, `grammar-compiler`, `server-engine`, `examples-corpus`,
`integration-tests`, etc. are **internal derivations / checks**. See **[CONTRIBUTING.md](CONTRIBUTING.md)**.

---

## Nodes

| id | type | status | delivers | artifact | dependencies | runtime |
|----|------|--------|----------|----------|--------------|---------|
| `libcbgeneral` | lib c | done | C↔engine bridge, OS utilities | `libcbgeneral.a` | — | — |
| `libcbipc` | lib c | done | TCP/socket IPC and message framing | `libcbipc.a` | — | — |
| `libcbtelos` | lib c | done | Telos parser (server-side) | `libcbtelos.a` | — | — |
| `libcbtelosserver` | lib c | done | Telos↔engine FFI | `libcbtelosserver.a` | — | — |
| `libcbcos` | lib c++ | done | Object store (P-tuples, revisions) | `libcbcos.a` | — | — |
| `server-repl` | exe embed | done | Interactive kernel developer embed | `server-repl` | server `libcb*` | — |
| `cbserver` | exe server | done | ConceptBase server process | `CBserver` | `server-repl`, server `libcb*`, `grammar-compiler`, `server-engine`, `system-data` ‡ | — |
| `libcbc` | lib c | done | C client API | `libcbc.a` | — | `cbserver` |
| `libcbtelosclient` | lib c | done | Telos parser (native clients) | `libcbtelosclient.a` | — | `cbserver` |
| `libcbcview` | lib c++ | done | C++ graph/view helpers | `libcbcview.a` | `libcbc` | `cbserver` |
| `grammar-compiler` | src grammar | done | DCG grammars for assertion and SML parsing | `*_dcg.pro` (×3) | — | — |
| `tree-sitter-conceptbase` | src grammar | done | Tree-sitter grammar for Telos / CBL / ECArule | `libtree-sitter-conceptbase.so` | — | — |
| `module-preprocessor` | src translate | done | Dialect-specific sources from `#MODULE` | `.swi.pl` | `cbcommon` † | — |
| `server-engine` | src kernel | done | Server query/rule module tree | `.swi.pl` (×115) | `grammar-compiler` | — |
| `system-data` | data | done | SYSTEM ontology bootstrap | `SYSTEM.*` | — | — |
| `cbcommon` | lib java | done | Shared utilities, `PrologPreProcessor` | `cbcommon.jar` | — | — |
| `cbapi` | lib java | done | Java client API | `cbapi.jar` | `cbcommon` | `cbserver` |
| `cbtelos` | lib java | done | Telos frame parser (Java) | `cbtelos.jar` | `cbapi` | `cbserver` |
| `cbgraph` | lib java | done | Graph editor (Swing) | `cbgraph.jar` | `cbtelos` | `cbserver` |
| `cbworkbench` | lib java | done | Workbench UI (`CBIva`) | (in `cbgraph.jar`) | `cbgraph` | `cbserver` |
| `cbdistribution` | lib java | done | Fat client JAR | `cb.jar` | `cbworkbench` | `cbserver` |
| `examples-corpus` | data | done | Sample ontologies and client demos | `share/examples/` (188 files) | — | `cbserver` |
| `integration-tests` | test | done | C/C++ client smoke against live server | check only | `cbserver`, `libcbc`, `libcbcview`, `examples-corpus` | `cbserver` |
| `doc-user-manual` | doc typst | done | End-user manual | PDF + HTML | — | — |
| `doc-prog-manual` | doc typst | done | Programmer manual | PDF + HTML | — | — |
| `doc-tutorial` | doc typst | done | Tutorial | PDF + HTML | — | — |
| `doc-howto-manual` | doc typst | done | HOW-TO book | PDF | — | — |
| `doc-tech-info` | doc static | done | Technical reference | static export | — | — |
| `doc-developer` | doc static | done | Developer notes | static export | — | — |
| `doc-external-licenses` | doc static | done | Third-party licenses | static export | — | — |
| `ex-*` (17) | example | done | Telos/Java/C demo corpora | under `examples-corpus` | — | `cbserver` |

† `module-preprocessor` optional when committed `.swi.pl` fast path is used (**current build**).  
‡ `module-preprocessor` not required on SWI fast path.

**Status legend:** `done` = sources migrated + Nix build/check green · `wip` = builds but active
follow-up (i18n, grammar) · `deferred` = sources exist, not flake packages · `—` = not started

---

## Topological order (build)

```
libcbgeneral, libcbipc, libcbtelos, libcbtelosserver, libcbcos,
cbcommon, grammar-compiler, system-data
  → module-preprocessor (optional), server-engine
    → server-repl, cbapi
      → cbserver, cbtelos
        → cbgraph → cbdistribution / cb-workbench
          → conceptbase, integration-tests
```

Client libs (`libcbc`, `libcbtelosclient`, `libcbcview`) build in parallel with server libs.

**Runtime:** `nix run .#cbserver`, then `.#cb-workbench` or `.#cb-shell`.
