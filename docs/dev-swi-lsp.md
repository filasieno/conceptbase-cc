# SWI-Prolog LSP — dev setup

Configured for editing ConceptBase `.pro` sources in Cursor/VS Code (WSL).

## Installed components

| Component | Version | Location |
|-----------|---------|----------|
| SWI-Prolog | 9.2.9 | `~/.nix-profile/bin/swipl` (`nix profile add nixpkgs#swi-prolog`) |
| `lsp_server` pack | 3.16.3 | `~/.local/share/swi-prolog/pack/lsp_server` |
| Cursor extension (LSP) | `jamesnvc.prolog-lsp` 2.2.7 | VSIX from [lsp_server releases](https://github.com/jamesnvc/lsp_server/releases) |
| Syntax highlighting | `conceptbase.conceptbase-prolog-highlight` | `editor/prolog-highlight/` (sublimeprolog grammar from [vsc-prolog](https://github.com/arthwang/vsc-prolog)) |

## Nix `library(json)` shim

The Nix `swi-prolog` package exposes JSON as `library(http/json)` only. The LSP pack expects `library(json)`.

Shim: `~/.config/swi-prolog/lib/json.pl` → Nix store `http/json.pl`  
Init: `~/.config/swi-prolog/init.pl` adds `app_config(lib)` to the library search path.

## Verify

```bash
./scripts/verify-swi-lsp.sh
```

Or open any `.pro` file under `archive/2026-06-06-wip/` and check:

- Outline view lists predicates
- Hover shows predicate docs (where xref finds them)
- Diagnostics for singleton variables / syntax errors

Reload the window if the language server does not attach (`Ctrl+Shift+P` → **Developer: Reload Window**).

## Troubleshooting

**`swipl: command not found` in LSP**

Ensure `~/.local/bin/swipl` exists (symlink to nix profile) and Cursor was restarted after install.

**No syntax colors (plain text look)**

`jamesnvc.prolog-lsp` provides **LSP only** — no TextMate grammar. Install the local grammar extension:

```bash
cp -a editor/prolog-highlight ~/.cursor-server/extensions/conceptbase.conceptbase-prolog-highlight-0.1.0
```

Then reload the window. Colors come from `editor/prolog-highlight` (SWI sublimeprolog grammar).

**Wrong language mode on `.swi.pl`**

Workspace settings map `*.pro`, `*.pl`, `*.swi.pl`, `*.gel`, `*.lpi` → `prolog`. Check the status bar shows **Prolog**, not Plain Text.

**Server crashes on start**

```bash
swipl -g "use_module(library(lsp_server)), writeln(ok), halt."
```

If `library(json)` fails, re-run the shim steps in `scripts/setup-swi-lsp.sh`.

## Note on ConceptBase server Prolog

The **archive server** targets SWI **6.6.6** with a custom `#MODULE` dialect. This LSP stack uses **SWI 9.2.9** for editing only; expect false positives on legacy syntax until modules are ported.
