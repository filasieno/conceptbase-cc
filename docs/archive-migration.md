# Archive migration — status report and continuation plan

Reference corpus: `archive/2026-06-06-wip/` (frozen snapshot; read-only).  
Active tree: repository root (`components/`, `nix/`, `flake.nix`).  
Node inventory: **[deliverable-nodes.md](../deliverable-nodes.md)** (43 nodes).

---

## Part 1 — Migration report (what moved, what remains)

### Executive summary (updated 2026-06-06)

| Metric | Count |
|--------|------:|
| Deliverable nodes (total) | 43 |
| Nodes with sources in `components/` | ~22 |
| Internal derivations with passing Nix check | 15 |
| User-facing flake packages | 5 |
| Example files synced | 188 |
| Server (`cbserver`) | **built** |
| Docs (Typst flake packages) | deferred (in progress) |

The greenfield repo has replaced the archive **build system** (Make/`CB_Make` → Nix + CMake + Maven) and
migrated the **native library layer**, **Java client stack**, **DCG toolchain**, **three Typst manuals**,
and **developer `plcb`**. The **ConceptBase server** (Prolog kernel + `CBserver` binary), **ontology
bootstrap** (`lib/SYSTEM`), **examples**, and **runtime launchers** for the server are still entirely in
the archive.

---

### Migrated and building

#### Build infrastructure

| Archive | Greenfield | Nix | Notes |
|---------|------------|-----|-------|
| `ProductPOOL/config.mk`, `rules.mk`, per-dir Makefiles | — | — | Replaced by Nix/CMake/Maven |
| `buildcbutils` (implicit in CMake paths) | `components/buildcbutils/` | internal `buildcbutils` | Flex/Bison in `build/generated/` |
| — | `flake.nix`, `nix/*.nix` | 7 packages + internal derivations | See [CONTRIBUTING.md](../CONTRIBUTING.md) |

#### Server C/C++ libraries (5 nodes)

Archive: `ProductPOOL/serverSources/C_Files/{libGeneral,libIpc,libtelos,libtelosServer,libCos3}`.

| Node | Component | Archive lib | Build |
|------|-----------|-------------|-------|
| `libcbgeneral` | `components/libcbgeneral/` | `libGeneral` | ✓ `nix flake check` |
| `libcbipc` | `components/libcbipc/` | `libIpc` | ✓ |
| `libcbtelos` | `components/libcbtelos/` | `libtelos` | ✓ |
| `libcbtelosserver` | `components/libcbtelosserver/` | `libtelosServer` | ✓ |
| `libcbcos` | `components/libcbcos/` | `libCos3` | ✓ |

Legacy `libCos` / `libCos2` in the archive were **not** migrated (superseded by `libCos3`).

#### Client C/C++ libraries (3 nodes)

Archive: `ProductPOOL/clientSources/{libCB,libtelos,libCBview}`.

| Node | Component | Archive lib | Build |
|------|-----------|-------------|-------|
| `libcbc` | `components/libcbc/` | `libCB` | ✓ (+ `tests/testterm.c`) |
| `libcbtelosclient` | `components/libcbtelosclient/` | `libtelos` | ✓ (+ `tests/te_test_access.c`) |
| `libcbcview` | `components/libcbcview/` | `libCBview` | ✓ |

Integration tests `testlib.c` / `testlib.cc` remain in the archive (need `exe-cbserver`).

#### Prolog tooling

| Node | Archive | Greenfield | Build |
|------|---------|------------|-------|
| `prolog-dcg` | `serverSources/Prolog_Files/{dcg.pl,*.dcg}` | `components/prolog-dcg/src/` | ✓ |
| `plcb` | `linux64/.../swiInteractive.c` (variant path) | `components/plcb/src/swiInteractive.c` | ✓ `.#plcb` |

#### Java client stack (7 Maven modules → 3 user apps)

Archive: `ProductPOOL/java/i5/` (266 `.java` files).  
Greenfield: `components/java/` (264 `.java` via `scripts/sync-java-sources.sh`).

| Node | Maven module | User-facing package | Build |
|------|--------------|---------------------|-------|
| `cbcommon` … `cbdistribution` | `cbcommon`, `cbframe`, `cbapi`, `cbtelos`, `cbgraph`, `cbworkbench`, `cbdistribution` | — (internal `java-reactor`) | ✓ |
| `cbworkbench` / `cbdistribution` | fat `cb.jar` | `.#cb-workbench` (`cbiva`) | ✓ |
| — | `CBShell` in `cbapi` | `.#cb-shell` | ✓ |
| — | `CBEditor` in `cbgraph` | `.#cb-graph` | ✓ |

Not synced from archive (low priority): two graph editor test classes under `cbeditor/tests/`.

Third-party JARs (`jgl`, `grappa`, `flatlaf`, `batik`) are **not** copied into `components/`; they are
fetched by `nix/java-deps.nix` and the Maven local repo overlay.

#### Documentation (3 of 6 doc nodes)

| Node | Archive | Greenfield | Build |
|------|---------|------------|-------|
| `doc-user-manual` | `doc/UserManual/` (LaTeX → converted) | `components/doc/user-manual/*.typ` | ✓ `.#doc-user-manual` |
| `doc-prog-manual` | `doc/ProgManual/` | `components/doc/prog-manual/*.typ` | ✓ |
| `doc-tutorial` | `doc/Tutorial/` | `components/doc/tutorial/*.typ` | ✓ |

Conversion tooling: `archive/2026-06-06-wip/tools/migrate-tex-to-typst.py` (one-time).

---

### Partially migrated or restructured

| Area | Status |
|------|--------|
| **Java layout** | Flat `i5/` tree → Maven `src/main/java`; `cbframe` added; workbench sources compile inside `cbgraph` (cycle break). |
| **Java launchers** | Archive shell scripts (`cbiva`, `cbshell`, `cbgraph`) → Nix `makeWrapper` in `nix/java-app.nix`. |
| **Server Prolog** | 126 `#MODULE` `.pro` in variant-independent tree; **115** preprocessed `.swi.pl` under `linux/serverSources/Prolog_Files/` — **none** in `components/` yet. |
| **Unit tests** | 2 client tests migrated; server/client integration tests still in archive. |
| **Task graph docs** | `docs/rebuild-task-graph.md` describes target layers; many tasks not started. |

---

### Not migrated (still only in archive)

#### Critical path — server

| Node / area | Archive location | Blocker |
|-------------|------------------|---------|
| **`exe-cbserver`** | `linux64/serverSources/` link rules, `cbserver.pro`, `CBserver` binary | No `components/cbserver/`, no `nix/cbserver.nix` |
| **`prolog-ppp`** | PPP via `cbcommon.jar` / `PrologPreProcessor` | No `components/prolog-ppp/`, no batch `.pro` → `.swi.pl` in Nix |
| **Server Prolog kernel** | `serverSources/Prolog_Files/*.pro` + `linux/serverSources/Prolog_Files/*.swi.pl` (~126 modules) | No `components/prolog-server/` harness |
| **SYSTEM ontology** | `lib/SYSTEM.*`, `lib/*.sml` bootstrap | No `components/data-system/` |
| **Server launchers** | `cbserver`, `startCBserver.sh`, `ProductPOOL/bin/CBserver*` | Waiting on `exe-cbserver` package |

#### Examples (17 nodes, 0 migrated)

Archive: `ProductPOOL/examples/` — FLIGHT, QUERIES, Clients, Servlets, etc. (~315 files).  
No `components/examples/` yet.

#### Documentation (3 static nodes)

| Node | Archive |
|------|---------|
| `doc-tech-info` | `doc/TechInfo/` |
| `doc-developer` | `doc/Developper/` |
| `doc-external-licenses` | `doc/ExternalLicenses/` |

#### Admin, packaging, platform

| Area | Archive | Decision |
|------|---------|----------|
| **AdminPOOL** | `AdminPOOL/` (`CB_Make`, `compileCB`, CBS test scripts) | Replace with Nix/`flake check`; port scripts as needed |
| **Platform variants** | `linux64/`, `windows/`, `sun4/`, `mac/`, … | **Dropped** — Linux x86_64 only |
| **Docker** | `archive/.../Dockerfile`, `docker/` | Revisit after `cbserver` + apps |
| **Old flake experiment** | `archive/.../flake.nix` | Superseded by root `flake.nix` |
| **Man pages** | `ProductPOOL/man/` | Not ported |
| **Desktop/mime assets** | `lib/cbiva.desktop`, logos, mime XML | Not ported |

---

### Intentionally left behind

- **CVS metadata**, committed **binaries** (`.o`, old `CBserver`, JARs in tree)
- **Java Makefiles** and `javac` → `java/classes/` workflow
- **LaTeX** sources (dropped after Typst migration)
- **Per-platform** build trees and `config.mk` machine paths
- **libCos / libCos2** object-store predecessors

---

### Nix / flake coverage vs nodes

| Category | Nodes | Migrated source | Nix build | Flake package |
|----------|------:|:---------------:|:---------:|:-------------:|
| Server C libs | 5 | ✓ | ✓ | — (internal) |
| Client C libs | 3 | ✓ | ✓ | — |
| Server exe | 1 | — | — | — |
| Prolog | 2 | 1 (dcg) | 2 (dcg, plcb) | `plcb` only |
| Java libs + apps | 7 | ✓ | ✓ | 3 apps |
| Docs | 6 | 3 | 3 | 3 |
| Examples | 17 | — | — | — |
| **Total** | **43** | **~18** | **16** | **7** |

---

## Part 2 — Continuation plan

Follow **topological order** from `deliverable-nodes.md`. One node (or tight group) at a time:
migrate sources → add `components/` + `nix/*.nix` → `nix flake check` green → expose flake package if
user-facing.

### Phase A — Prolog preprocessing (`prolog-ppp`)

**Goal:** Nix derivation that runs `PrologPreProcessor` on server `.pro` sources.

| Step | Action |
|------|--------|
| A1 | Create `components/prolog-ppp/` with manifest of `.pro` inputs (from `serverSources/Prolog_Files/`) |
| A2 | Add `nix/prolog-ppp.nix`: `java -cp cbcommon.jar i5.cb.PrologPreProcessor SWI …` |
| A3 | `checkPhase`: spot-check known module output (e.g. fragment of `cbserver.swi.pl`) |
| A4 | Decide SWI fast path: use committed `linux/serverSources/Prolog_Files/*.swi.pl` where PPP is skipped |

**Archive refs:** `serverSources/Prolog_Files/*.pro`, `rules.mk` `makePrologVariantSource`, `cbcommon.jar`.

**Acceptance:** `nix build .#checks.x86_64-linux.prolog-ppp` succeeds.

---

### Phase B — Server Prolog tree (`components/prolog-server`)

**Goal:** Versioned server Prolog under `components/`, compilable to `.swo` / loadable by SWI.

| Step | Action |
|------|--------|
| B1 | Copy or sync `linux/serverSources/Prolog_Files/*.swi.pl` (+ shared `serverSources/Prolog_Files` DCG outputs) into `components/prolog-server/src/` |
| B2 | Document `#IMPORT` / module graph (from archive + `BDMCompile.pro` entry) |
| B3 | Add `nix/prolog-server.nix`: compile or validate modules with `swipl --goal=…` (incremental: start with `dcg.pro`, `cbserver.pro`) |
| B4 | Wire dependency: `prolog-server` → `prolog-dcg`, optional `prolog-ppp` |

**Archive refs:** 115 `.swi.pl` files under `linux/serverSources/Prolog_Files/`.

**Acceptance:** `swipl -l startCBserver.swi.pl -g halt` (or equivalent) in `checkPhase`.

---

### Phase C — `exe-cbserver` (critical)

**Goal:** Flake package `.#cbserver` — the runnable ConceptBase server.

| Step | Action |
|------|--------|
| C1 | Create `components/cbserver/` (minimal: link script, `swiInteractive` glue if needed, wrapper) |
| C2 | Port `linux64/serverSources` link order from archive Makefile → `nix/cbserver.nix` (`swipl-ld` like `plcb`, plus Prolog entry) |
| C3 | `buildInputs`: five server `libcb*`, `prolog-server`, `plcb` (if required for link) |
| C4 | Install `bin/cbserver` wrapper (from archive `cbserver` / `startCBserver.sh` behaviour) |
| C5 | Add `components/data-system/` from `lib/SYSTEM.*` + minimal bootstrap SML |
| C6 | Expose `packages.cbserver`; add smoke `checkPhase` (start, port, `halt`) |

**Archive refs:** `linux64/serverSources/Makefile`, `cbserver.pro`, `ProductPOOL/cbserver`, `lib/SYSTEM.*`.

**Acceptance:** `nix run .#cbserver` listens on 4001; `nix run .#cb-workbench` connects locally.

---

### Phase D — Runtime integration and tests

| Step | Action |
|------|--------|
| D1 | Port `testlib.c` / `testlib.cc` into `components/*/tests/` with `checkPhase` gated on `cbserver` |
| D2 | Add `checks` integration job: build `cbserver` + `cb-workbench`, run minimal tell/query |
| D3 | Meta flake package `.#conceptbase` (`symlinkJoin` server + workbench + SYSTEM data) |

---

### Phase E — Examples corpus

**Goal:** 17 `ex-*` nodes as `components/examples/<name>/` with export or run scripts.

| Priority | Examples | Rationale |
|----------|----------|-----------|
| E1 | `ex-client-java`, `ex-client-swi`, `ex-client-c` | Client smoke paths |
| E2 | `ex-flight`, `ex-queries`, `ex-builtin-queries` | Manual/tutorial alignment |
| E3 | Remaining telos corpora | Batch `components/examples/` + optional `.#ex-<name>` data packages |

**Archive ref:** `ProductPOOL/examples/`.

---

### Phase F — Remaining documentation

| Step | Action |
|------|--------|
| F1 | Port or rewrite `doc-tech-info`, `doc-developer`, `doc-external-licenses` (Typst or static markdown) |
| F2 | Align `components/doc/` with workbench/server behaviour after Phase C |

---

### Phase G — Packaging and CI

| Step | Action |
|------|--------|
| G1 | Refresh Docker image (server + JRE 25 + workbench) |
| G2 | CI: `nix flake check` on GitLab |
| G3 | Operator runbook in `docs/` (port from `AdminPOOL/CB-developer-guide.txt` essentials) |

---

### Suggested timeline (ordered milestones)

```
Now     ✓ libcb*  ✓ plcb  ✓ prolog-dcg  ✓ java apps  ✓ doc (typst ×3)
  │
  ├─► A  prolog-ppp
  ├─► B  prolog-server (module tree)
  ├─► C  cbserver + SYSTEM data          ← unlocks end-to-end product
  ├─► D  integration tests + .#conceptbase
  ├─► E  examples (tiered)
  ├─► F  static docs
  └─► G  Docker / CI / runbook
```

### Working agreements (carry forward)

1. **Archive stays read-only** — sync via scripts (`sync-java-sources.sh`, future `sync-prolog-server.sh`).
2. **One flake** — user-facing outputs only in `packages`; libs stay internal ([CONTRIBUTING.md](../CONTRIBUTING.md)).
3. **Git-track** new `components/` and `nix/` paths before relying on `nix build` on dirty trees.
4. **Topological discipline** — do not start Phase C until A/B are green or explicitly bypassed via SWI fast path.
5. **Linux x86_64 only** — do not port variant Makefiles.

---

### Quick reference — archive → greenfield path map

| Archive path | Greenfield path |
|--------------|-----------------|
| `ProductPOOL/serverSources/C_Files/libGeneral` | `components/libcbgeneral` |
| `ProductPOOL/serverSources/C_Files/libIpc` | `components/libcbipc` |
| `ProductPOOL/serverSources/C_Files/libtelos` | `components/libcbtelos` |
| `ProductPOOL/serverSources/C_Files/libtelosServer` | `components/libcbtelosserver` |
| `ProductPOOL/serverSources/C_Files/libCos3` | `components/libcbcos` |
| `ProductPOOL/clientSources/libCB` | `components/libcbc` |
| `ProductPOOL/clientSources/libtelos` | `components/libcbtelosclient` |
| `ProductPOOL/clientSources/libCBview` | `components/libcbcview` |
| `ProductPOOL/serverSources/Prolog_Files/dcg.*` | `components/prolog-dcg` |
| `ProductPOOL/java/i5` | `components/java` (via sync script) |
| `ProductPOOL/doc/{UserManual,ProgManual,Tutorial}` | `components/doc/{user-manual,prog-manual,tutorial}` |
| `ProductPOOL/linux/serverSources/Prolog_Files` | *(planned)* `components/prolog-server` |
| `ProductPOOL/lib/SYSTEM.*` | *(planned)* `components/data-system` |
| `ProductPOOL/examples` | *(planned)* `components/examples` |
