# ConceptBase.cc — rebuild task execution graph

Topological plan for greenfield reconstruction. Each node is one deliverable; edges are hard
prerequisites. Execute **layer by layer** (topological sort). Within a layer, tasks may run in
parallel unless a sub-edge says otherwise.

Archive reference: `archive/2026-06-06-wip/`

---

## Legend

| Prefix | Domain |
|--------|--------|
| `DOC` | Documentation & specifications |
| `INFRA` | Repo scaffold, Nix, CI, tooling |
| `TOOL` | Pinned third-party toolchains |
| `SRV-C` | Server C foreign-function layer (`libcb<name>` → `libcb<name>.a`) |
| `SRV-P` | Server Prolog kernel |
| `SRV` | Server binary, install layout, scripts |
| `DATA` | Ontology bootstrap & example corpora |
| `PROTO` | Wire protocol & API contracts |
| `JAVA` | Java client modules |
| `NATIVE` | C/C++ client libraries (`libcbc`, `libcbtelosclient`, `libcbcview`, …) |
| `CLI` | Launcher scripts & desktop entrypoints |
| `PKG` | Packaging (Nix outputs, Docker, release) |
| `TEST` | Verification & integration gates |

**Edge notation:** `A → B` means *A must complete before B starts*.

---

## Master DAG (all parts)

```mermaid
flowchart TD
  subgraph L0["Layer 0 — charter"]
    DOC-001[DOC-001 Vision & scope]
    DOC-002[DOC-002 Archive inventory]
    INFRA-001[INFRA-001 Repo scaffold]
  end

  subgraph L1["Layer 1 — architecture docs"]
    DOC-010[DOC-010 Target architecture]
    DOC-011[DOC-011 Directory layout spec]
    DOC-012[DOC-012 Toolchain policy]
    DOC-013[DOC-013 License & third-party audit]
    INFRA-002[INFRA-002 Nix flake skeleton]
    INFRA-003[INFRA-003 Git ignore & hygiene]
  end

  subgraph L2["Layer 2 — pinned toolchains"]
    TOOL-001[TOOL-001 SWI-Prolog 6.6.6 derivation]
    TOOL-002[TOOL-002 cb-make wrapper]
    TOOL-003[TOOL-003 Java 11 + Maven policy]
    TOOL-004[TOOL-004 Legacy JAR fetch]
    DOC-020[DOC-020 Build system guide]
  end

  subgraph L3["Layer 3 — server contracts"]
    DOC-030[DOC-030 Telos data model primer]
    DOC-031[DOC-031 CBserver process model]
    PROTO-001[PROTO-001 IPC/socket term encoding]
    DATA-001[DATA-001 SYSTEM ontology extract]
    SRV-C-001[SRV-C-001 libcbgeneral]
  end

  subgraph L4["Layer 4 — C bridge complete"]
    SRV-C-002[SRV-C-002 libcbipc]
    SRV-C-003[SRV-C-003 libcbtelos FFI]
    SRV-C-004[SRV-C-004 libcbtelosserver]
    SRV-C-005[SRV-C-005 libcbcos family]
    DOC-032[DOC-032 C↔Prolog FFI map]
  end

  subgraph L5["Layer 5 — Prolog DCG & core"]
    SRV-P-001[SRV-P-001 Prolog build harness]
    SRV-P-002[SRV-P-002 Module graph & #IMPORT map]
    SRV-P-003[SRV-P-003 DCG / assertion compiler]
    SRV-P-004[SRV-P-004 BDM storage layer]
    DOC-040[DOC-040 Prolog module catalog]
  end

  subgraph L6["Layer 6 — Prolog services"]
    SRV-P-010[SRV-P-010 Query & rule engine]
    SRV-P-011[SRV-P-011 Server interface]
    SRV-P-012[SRV-P-012 Notifications]
    SRV-P-013[SRV-P-013 LPI plugin interface]
    DOC-041[DOC-041 Server command reference]
  end

  subgraph L7["Layer 7 — CBserver binary"]
    SRV-001[SRV-001 link CBserver]
    SRV-002[SRV-002 linux64 install tree]
    SRV-003[SRV-003 cbserver wrapper script]
    DATA-002[DATA-002 Empty DB bootstrap]
    TEST-001[TEST-001 Server smoke test]
  end

  subgraph L8["Layer 8 — protocol & API spec"]
    PROTO-002[PROTO-002 Java CBterm grammar]
    PROTO-003[PROTO-003 Client session lifecycle]
    DOC-050[DOC-050 Client API specification]
    DOC-051[DOC-051 Port 4001 deployment guide]
  end

  subgraph L9["Layer 9 — Java foundation"]
    INFRA-010[INFRA-010 Maven parent POM]
    JAVA-001[JAVA-001 conceptbase-java-common]
    JAVA-002[JAVA-002 conceptbase-java-api]
    TEST-010[TEST-010 API connect integration test]
  end

  subgraph L10["Layer 10 — Java UI stack"]
    JAVA-010[JAVA-010 conceptbase-java-telos]
    JAVA-011[JAVA-011 conceptbase-java-graph]
    JAVA-012[JAVA-012 conceptbase-java-workbench]
    JAVA-020[JAVA-020 distribution JARs]
    DOC-060[DOC-060 Workbench user guide stub]
  end

  subgraph L11["Layer 11 — clients & native"]
    CLI-001[CLI-001 cbiva / cbgraph / cbshell]
    NATIVE-001[NATIVE-001 libcbc headers]
    NATIVE-002[NATIVE-002 libcbc term codec]
    NATIVE-003[NATIVE-003 libcbtelosclient]
    DATA-010[DATA-010 Ported examples corpus]
    DOC-070[DOC-070 Example walkthroughs]
  end

  subgraph L12["Layer 12 — packaging"]
    PKG-001[PKG-001 Fine-grained Nix outputs]
    PKG-002[PKG-002 conceptbase aggregate]
    PKG-003[PKG-003 Docker image]
    INFRA-020[INFRA-020 CI pipeline]
    DOC-080[DOC-080 Operator runbook]
    TEST-020[TEST-020 End-to-end trial]
  end

  %% L0
  DOC-001 --> DOC-010
  DOC-002 --> DOC-010
  INFRA-001 --> INFRA-002
  INFRA-001 --> INFRA-003

  %% L1
  DOC-010 --> DOC-011
  DOC-010 --> DOC-012
  DOC-002 --> DOC-013
  DOC-011 --> INFRA-002
  DOC-012 --> INFRA-002
  INFRA-002 --> TOOL-001

  %% L2
  DOC-012 --> TOOL-002
  DOC-012 --> TOOL-003
  DOC-013 --> TOOL-004
  INFRA-002 --> TOOL-001
  INFRA-002 --> TOOL-002
  INFRA-002 --> TOOL-003
  TOOL-003 --> TOOL-004
  TOOL-001 --> DOC-020
  TOOL-002 --> DOC-020

  %% L3
  DOC-010 --> DOC-030
  DOC-030 --> DATA-001
  DOC-031 --> PROTO-001
  TOOL-001 --> SRV-C-001
  TOOL-002 --> SRV-C-001
  DOC-012 --> SRV-C-001

  %% L4
  SRV-C-001 --> SRV-C-002
  SRV-C-001 --> SRV-C-003
  SRV-C-003 --> SRV-C-004
  SRV-C-002 --> SRV-C-005
  SRV-C-001 --> DOC-032
  SRV-C-004 --> DOC-032

  %% L5
  TOOL-001 --> SRV-P-001
  SRV-C-004 --> SRV-P-001
  SRV-P-001 --> SRV-P-002
  SRV-P-002 --> SRV-P-003
  SRV-P-003 --> SRV-P-004
  SRV-P-002 --> DOC-040

  %% L6
  SRV-P-004 --> SRV-P-010
  SRV-P-010 --> SRV-P-011
  SRV-P-011 --> SRV-P-012
  SRV-P-011 --> SRV-P-013
  SRV-P-011 --> DOC-041
  PROTO-001 --> SRV-P-011

  %% L7
  SRV-P-011 --> SRV-001
  SRV-C-005 --> SRV-001
  SRV-001 --> SRV-002
  SRV-002 --> SRV-003
  DATA-001 --> DATA-002
  SRV-002 --> DATA-002
  SRV-003 --> TEST-001
  DATA-002 --> TEST-001

  %% L8
  TEST-001 --> PROTO-002
  PROTO-001 --> PROTO-002
  PROTO-002 --> PROTO-003
  PROTO-003 --> DOC-050
  SRV-003 --> DOC-051

  %% L9
  DOC-050 --> INFRA-010
  TOOL-003 --> INFRA-010
  TOOL-004 --> INFRA-010
  INFRA-010 --> JAVA-001
  JAVA-001 --> JAVA-002
  TEST-001 --> TEST-010
  JAVA-002 --> TEST-010
  SRV-003 --> TEST-010

  %% L10
  JAVA-002 --> JAVA-010
  JAVA-010 --> JAVA-011
  JAVA-011 --> JAVA-012
  JAVA-012 --> JAVA-020
  JAVA-020 --> DOC-060

  %% L11
  JAVA-020 --> CLI-001
  SRV-002 --> CLI-001
  PROTO-001 --> NATIVE-001
  NATIVE-001 --> NATIVE-002
  NATIVE-002 --> NATIVE-003
  TEST-001 --> DATA-010
  DATA-010 --> DOC-070

  %% L12
  SRV-002 --> PKG-001
  JAVA-020 --> PKG-001
  TOOL-001 --> PKG-001
  PKG-001 --> PKG-002
  PKG-002 --> PKG-003
  PKG-002 --> INFRA-020
  PKG-003 --> DOC-080
  CLI-001 --> TEST-020
  PKG-002 --> TEST-020
  TEST-010 --> TEST-020
```

---

## Topological sort — execution layers

Tasks grouped by **minimum prerequisite depth**. Complete each layer before the next.
Within-layer order is a suggestion, not a hard constraint.

### Layer 0 — charter (start here)

| ID | Task | Archive pointers |
|----|------|------------------|
| DOC-001 | Vision & scope: what to keep, drop, modernize | `README.md`, analysis notes |
| DOC-002 | Archive inventory: file counts, hot spots, debt | whole `archive/2026-06-06-wip/` |
| INFRA-001 | Repo scaffold: `README`, `LICENSE`, `docs/` | — |

### Layer 1 — architecture & skeleton

| ID | Task | Depends on |
|----|------|------------|
| DOC-010 | Target architecture (server / clients / data / pkg) | DOC-001, DOC-002 |
| DOC-011 | Directory layout spec (`server/`, `clients/java/`, …) | DOC-010 |
| DOC-012 | Toolchain policy (SWI 6.6.6 pin, JDK 11, clang) | DOC-010 |
| DOC-013 | License & third-party audit (FlatLaf, Batik, jgl, grappa) | DOC-002 |
| INFRA-002 | Nix flake skeleton (empty outputs, `src` filter) | DOC-011, DOC-012, INFRA-001 |
| INFRA-003 | Git hygiene (ignore rules, no binaries policy) | INFRA-001 |

### Layer 2 — pinned toolchains

| ID | Task | Depends on |
|----|------|------------|
| TOOL-001 | `swi-prolog` Nix derivation (6.6.6 patches) | INFRA-002, DOC-012 |
| TOOL-002 | `cb-make` wrapper (make 4.x, `-j1`) | INFRA-002, DOC-012 |
| TOOL-003 | Java 11 + Maven reactor policy | INFRA-002, DOC-012 |
| TOOL-004 | Legacy JAR fetch (`jgl`, `grappa`) + Maven Central pins | TOOL-003, DOC-013 |
| DOC-020 | Build system guide (`nix build .#…`) | TOOL-001, TOOL-002 |

### Layer 3 — server contracts & first C lib

| ID | Task | Depends on |
|----|------|------------|
| DOC-030 | Telos data model primer | DOC-010 |
| DOC-031 | CBserver process model (ports, DB dirs, lock files) | DOC-010 |
| PROTO-001 | IPC/socket term encoding (from `BimIpc`, `CBterm`) | DOC-031 |
| DATA-001 | SYSTEM ontology extract → `ontology/system/` | DOC-030 |
| SRV-C-001 | `libcbgeneral` (C↔Prolog bridge, `unixToProlog.c`, …) → `libcbgeneral.a` | TOOL-001, TOOL-002, DOC-012 |

### Layer 4 — C bridge complete

| ID | Task | Depends on |
|----|------|------------|
| SRV-C-002 | `libcbipc` (client connection handling) → `libcbipc.a` | SRV-C-001 |
| SRV-C-003 | `libcbtelos` FFI → `libcbtelos.a` | SRV-C-001 |
| SRV-C-004 | `libcbtelosserver` → `libcbtelosserver.a` | SRV-C-003 |
| SRV-C-005 | `libcbcos` (archive `libCos` / `libCos2` / `libCos3`) → `libcbcos.a` | SRV-C-002 |
| DOC-032 | C↔Prolog FFI map (exported predicates ↔ `.c`) | SRV-C-001, SRV-C-004 |

### Layer 5 — Prolog build harness & storage core

| ID | Task | Depends on |
|----|------|------------|
| SRV-P-001 | Prolog build harness (`dcg`, `plcb`, object dirs) | TOOL-001, SRV-C-004 |
| SRV-P-002 | Module graph & `#IMPORT` / `#EXPORT` map | SRV-P-001 |
| SRV-P-003 | DCG / assertion compiler chain | SRV-P-002 |
| SRV-P-004 | BDM storage layer | SRV-P-003 |
| DOC-040 | Prolog module catalog (group by subsystem) | SRV-P-002 |

### Layer 6 — Prolog services

| ID | Task | Depends on |
|----|------|------------|
| SRV-P-010 | Query & rule engine | SRV-P-004 |
| SRV-P-011 | `CBserverInterface` / session commands | SRV-P-010, PROTO-001 |
| SRV-P-012 | Client notifications | SRV-P-011 |
| SRV-P-013 | LPI plugin interface (`cbserver.pro`) | SRV-P-011 |
| DOC-041 | Server command reference | SRV-P-011 |

### Layer 7 — CBserver runnable

| ID | Task | Depends on |
|----|------|------------|
| SRV-001 | Link `CBserver` binary | SRV-P-011, SRV-C-005 |
| SRV-002 | `linux64` install tree (`CB_Install` equivalent) | SRV-001 |
| SRV-003 | `cbserver` wrapper script | SRV-002 |
| DATA-002 | Empty DB bootstrap (`OB.telos` from SYSTEM) | DATA-001, SRV-002 |
| TEST-001 | Server smoke: `cbserver -port 4001 -d /tmp/db` | SRV-003, DATA-002 |

### Layer 8 — client protocol specification

| ID | Task | Depends on |
|----|------|------------|
| PROTO-002 | Java `CBterm` grammar & codec | PROTO-001, TEST-001 |
| PROTO-003 | Client session lifecycle (connect, ask, notify) | PROTO-002 |
| DOC-050 | Client API specification | PROTO-003 |
| DOC-051 | Port 4001 deployment guide | SRV-003 |

### Layer 9 — Java API foundation

| ID | Task | Depends on |
|----|------|------------|
| INFRA-010 | Maven parent POM + offline repo wiring | DOC-050, TOOL-003, TOOL-004 |
| JAVA-001 | `conceptbase-java-common` | INFRA-010 |
| JAVA-002 | `conceptbase-java-api` (`CBclient`, `CBterm`) | JAVA-001 |
| TEST-010 | API integration: Java client ↔ live server | JAVA-002, TEST-001, SRV-003 |

### Layer 10 — Java UI stack

| ID | Task | Depends on |
|----|------|------------|
| JAVA-010 | `conceptbase-java-telos` | JAVA-002 |
| JAVA-011 | `conceptbase-java-graph` | JAVA-010 |
| JAVA-012 | `conceptbase-java-workbench` (`CBIva`) | JAVA-011 |
| JAVA-020 | Distribution JARs (`cb.jar`, `CBinstaller.jar`) | JAVA-012 |
| DOC-060 | Workbench user guide stub | JAVA-020 |

### Layer 11 — launchers, native clients, examples

| ID | Task | Depends on |
|----|------|------------|
| CLI-001 | `cbiva`, `cbgraph`, `cbshell` launchers | JAVA-020, SRV-002 |
| NATIVE-001 | `libcbc` public headers → `libcbc.a` | PROTO-001 |
| NATIVE-002 | `libcbc` term codec | NATIVE-001 |
| NATIVE-003 | `libcbtelosclient` → `libcbtelosclient.a` | NATIVE-002 |
| DATA-010 | Ported examples (`FLIGHT`, `QUERIES`, …) | TEST-001 |
| DOC-070 | Example walkthroughs | DATA-010 |

### Layer 12 — packaging & release gate

| ID | Task | Depends on |
|----|------|------------|
| PKG-001 | Fine-grained Nix outputs (per derivation) | SRV-002, JAVA-020, TOOL-001 |
| PKG-002 | `conceptbase` aggregate install | PKG-001 |
| PKG-003 | Docker image (server trial) | PKG-002 |
| INFRA-020 | CI pipeline (build + smoke tests) | PKG-002 |
| DOC-080 | Operator runbook | PKG-003 |
| TEST-020 | End-to-end trial (server + workbench + example) | CLI-001, PKG-002, TEST-010 |

---

## Subsystem graphs

### Documentation-only spine

```mermaid
flowchart LR
  DOC-001 --> DOC-010 --> DOC-011
  DOC-010 --> DOC-012 --> DOC-020
  DOC-010 --> DOC-030 --> DATA-001
  DOC-031 --> DOC-041
  PROTO-003 --> DOC-050 --> DOC-060
  DATA-010 --> DOC-070
  PKG-003 --> DOC-080
```

Write docs **just-in-time**: each doc node depends on the code it describes, except charter
docs (layers 0–1) which precede implementation.

### Server spine (critical path)

```mermaid
flowchart LR
  TOOL-001 --> SRV-C-001 --> SRV-C-003 --> SRV-C-004
  SRV-C-004 --> SRV-P-001 --> SRV-P-004 --> SRV-P-011
  SRV-P-011 --> SRV-001 --> SRV-003 --> TEST-001
```

Longest path: **~11 hops** from toolchain to smoke test.

### Java client spine

```mermaid
flowchart LR
  TEST-001 --> PROTO-002 --> JAVA-002
  JAVA-002 --> JAVA-010 --> JAVA-011 --> JAVA-012 --> JAVA-020
  JAVA-020 --> CLI-001
```

Java UI cannot start until **TEST-001** proves the server speaks the protocol.

### Packaging spine

```mermaid
flowchart LR
  TOOL-001 --> PKG-001
  SRV-002 --> PKG-001
  JAVA-020 --> PKG-001
  PKG-001 --> PKG-002 --> PKG-003 --> TEST-020
```

---

## Prolog internal module order (SRV-P sub-graph)

When executing SRV-P-002…013, migrate Prolog modules in this **internal topological order**
(derived from `#IMPORT` chains in `serverSources/Prolog_Files/`):

| Phase | Modules (representative) | Notes |
|-------|--------------------------|-------|
| P0 | `ConfigurationUtilities`, `ErrorMessages` | utilities, no business logic |
| P1 | `BDMCompile`, `BDMLiteralDeps`, `AssertionCompiler` | storage compiler |
| P2 | `BDMEvaluation`, `BDMForget`, `BDMKBMS` | DB manager core |
| P3 | `CodeCompiler`, `CodeStorage`, `AssertionTransformer` | code & assertions |
| P4 | `AnswerTransform`, `AnswerTransformator` | query answers |
| P5 | `CBserverInterface`, `ClientNotification` | wire protocol |
| P6 | `cbserver`, `CBprofiler` | top-level API & tools |

Re-validate this list against `#IMPORT` in the archive before each phase.

---

## Milestone gates

| Gate | Required tasks | Exit criterion |
|------|----------------|----------------|
| **M0 — chartered** | DOC-001…002, INFRA-001 | Written scope + clean repo |
| **M1 — builds nothing yet** | Layer 1 complete | Flake evaluates, layout agreed |
| **M2 — toolchains** | Layer 2 complete | `nix build .#swi-prolog` succeeds |
| **M3 — server alpha** | TEST-001 | CBserver accepts TCP on 4001 |
| **M4 — API proven** | TEST-010 | Java `CBclient.connect()` works |
| **M5 — GUI alpha** | JAVA-020, CLI-001 | `cbiva` opens against live server |
| **M6 — shippable** | TEST-020, PKG-003 | Docker trial runs end-to-end |

---

## Parallelism hints

| Can run in parallel (same layer) | Must stay sequential |
|----------------------------------|----------------------|
| DOC-011 + DOC-012 + DOC-013 | SRV-P phases P0→P6 |
| TOOL-001 + TOOL-002 + TOOL-003 | JAVA-010 → JAVA-011 → JAVA-012 |
| SRV-C-002 + SRV-C-003 (after SRV-C-001) | TEST-001 before any Java work |
| NATIVE-* branch alongside JAVA-* after Layer 8 | PKG-002 after both server + java |

---

## Next action

**Start Layer 0:** create `DOC-001` (vision/scope) and `INFRA-001` (directory scaffold per
`DOC-011` draft). Do not port code until **M1** is signed off.
