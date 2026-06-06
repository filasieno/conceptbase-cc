# Contributing to ConceptBase.cc

## Packaging strategy (Nix)

One flake (`flake.nix`) for all Linux builds. Component directory names describe **what the
artifact does** (e.g. `server-engine`, `grammar-compiler`), not the implementation language.

### Three layers

| Layer | What | Where |
|-------|------|-------|
| **Flake package** | Install / run / open | `packages.x86_64-linux.<name>` |
| **Derivation** | Build recipe | `let` in `flake.nix` + `nix/*.nix` |
| **Component** | Versioned sources | `components/<name>/` |

**Rule:** only **user-facing** outputs appear under `packages`. Libraries, grammar builds,
kernel modules, and Maven reactors stay internal.

### User-facing flake packages

| Package | Delivers | Program |
|---------|----------|---------|
| `conceptbase` | Full product bundle (default) | `cbserver`, `cbiva` |
| `cbserver` | Knowledge-base server | `cbserver` |
| `cb-workbench` | Desktop Workbench | `cbiva` |
| `cb-shell` | Terminal client | `cbshell` |
| `cb-graph` | Graph editor | `cbgraph` |

`nix flake show .#packages` must list **only** these five (plus `default`).

Documentation (`doc-*`) is built separately while Typst migration is in progress — not exposed
as flake packages yet.

### Internal derivations (representative)

| Derivation | Component | Role |
|------------|-----------|------|
| `grammar-compiler` | `grammar-compiler/` | DCG → grammar modules |
| `module-preprocessor` | `module-preprocessor/` | `#MODULE` translation |
| `server-engine` | `server-engine/` | Kernel module tree (115 modules) |
| `system-data` | `system-data/` | SYSTEM ontology bootstrap |
| `server-repl` | `server-repl/` | Developer interactive embed |
| `java-reactor` | `java/` | Maven reactor → `cb.jar` (no Ant) |
| `jgl` / `grappa` | `jgl/`, `grappa/` | Legacy Maven modules (`legacy-parent`) |
| `no-ant` | — | Policy check: no `build.xml` / `*.ant.xml` in greenfield tree |
| `examples-corpus` | `examples/` | Demo corpora (bundled in `conceptbase`) |
| `libcb*` | `libcb*/` | Native static libraries |

### Archive sync scripts

| Script | Target component |
|--------|------------------|
| `./scripts/sync-java-sources.sh` | `components/java/` |
| `./scripts/sync-server-engine.sh` | `components/server-engine/` |
| `./scripts/sync-system-data.sh` | `components/system-data/` |
| `./scripts/sync-examples.sh` | `components/examples/` |

Re-run after archive reference updates; then `git add` new files before `nix build`.

### Adding a flake package

1. Node in **[deliverable-nodes.md](deliverable-nodes.md)**.
2. `components/<functional-name>/`.
3. `nix/<functional-name>.nix`.
4. User-facing → `packages.${system}`; otherwise `let` only.
5. `checks.${system}` when `doCheck` exists.

### Derivation dependency graph

Build-time edges between flake `let` bindings are documented in
**[docs/derivation-deps.puml](docs/derivation-deps.puml)** (PlantUML).

```plantuml
@startuml
' Abbreviated — see docs/derivation-deps.puml for the full graph.

package "Server libs" {
  [libcbgeneral] --> [libcbipc]
  [libcbgeneral] --> [libcbtelos] --> [libcbtelosserver]
}
[grammar-compiler] --> [server-engine]
[server-repl] --> [cbserver]
[server-engine] --> [cbserver]
[java-reactor] --> [cb-workbench]
[cbserver] --> [conceptbase]
@enduml
```

Render locally (PlantUML is in `nix develop`):

```bash
nix develop
plantuml -tsvg docs/derivation-deps.puml    # writes docs/derivation-deps.svg
plantuml -tpng docs/derivation-deps.puml    # writes docs/derivation-deps.png
```

Update the `.puml` file whenever you add or rewire a derivation in `flake.nix`.

---

## Quick use

### Build and run

```bash
nix build                    # conceptbase (default)
nix run .#cbserver
nix run .#cb-workbench
nix run .#cb-shell
nix run .#cb-graph
```

Start the server before clients. Example:

```bash
nix run .#cbserver &
nix run .#cb-workbench
```

### Verify

```bash
nix flake check
nix flake show .#packages    # must show only user-facing packages
```

### Java (Maven only)

All Java code builds with **Maven** — never Apache Ant. Legacy libraries live in
`components/jgl/` and `components/grappa/` (parent `components/legacy/pom.xml`) and are
listed as reactor modules in `components/java/pom.xml`.

```bash
cd components/java && mvn install    # full reactor (JDK 25)
cd components/legacy && mvn install  # legacy libs only
```

`checks.no-ant` fails if `build.xml`, `*.ant.xml`, or `maven-antrun-plugin` appear under
`components/`, `nix/`, or `scripts/`.

### Development shell

```bash
nix develop
./scripts/sync-server-engine.sh   # after archive changes
plantuml -tsvg docs/derivation-deps.puml
```

Includes `plantuml` and `graphviz` for the derivation dependency diagram.

### Inspect internal derivations

```bash
nix build .#checks.x86_64-linux.server-engine
nix build .#checks.x86_64-linux.grammar-compiler
ls "$(nix build --no-link --print-out-paths .#checks.x86_64-linux.server-engine)/share/server-engine" | head
```

### Environment (server + clients)

| Variable | Set by | Meaning |
|----------|--------|---------|
| `CB_HOME` | wrappers | Install prefix |
| `CB_POOL` | `cbserver` | Kernel module search root |
| `CBS_DIR` | `cbserver` | Server module directory |
| `CBL_DIR` | `cbserver` | SYSTEM ontology directory |
| `CB_PORTNR` | `cb-shell` | Server port (default 4001) |
