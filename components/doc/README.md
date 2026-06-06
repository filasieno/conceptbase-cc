# ConceptBase.cc documentation (Typst)

Canonical source for product manuals. **Edit `.typ` files here** — LaTeX was migrated once
from the archive and removed; do not reintroduce `.tex` under `components/`.

## Layout

| Path | Manual |
|------|--------|
| `lib/cb.typ` | Shared template (title page, TOC, styling) |
| `user-manual/` | End-user manual (`main.typ` + `chapters/*.typ` + `assets/`) |
| `prog-manual/` | Programmer manual |
| `tutorial/` | Tutorial |
| `references.yml` | Bibliography (Hayagriva YAML) for the user manual |

Each manual has a `main.typ` that `#include`s `title.typ` and chapter files. Chapter figures
live in that manual's `assets/` directory (paths from chapters use `../assets/...`).

## Build

```bash
nix build .#doc-user-manual .#doc-prog-manual .#doc-tutorial
```

Outputs: `$out/share/doc/<name>.pdf` and `$out/share/doc/<name>.html`.

Local iteration (from this directory):

```bash
nix shell nixpkgs#typst -c typst compile --root . user-manual/main.typ /tmp/user-manual.pdf
nix shell nixpkgs#typst -c typst compile --root . --features html --format html \
  user-manual/main.typ /tmp/user-manual.html
```

## Authoring

- Add or edit chapter `.typ` files under the manual's `chapters/` directory.
- Register new chapters in that manual's `main.typ` with `#include "chapters/<name>.typ"`.
- Use `#import "../lib/cb.typ": *` only in `title.typ` / `main.typ`; chapters are included
  into the document started by `main.typ`.
- Citations in the user manual: add entries to `references.yml`, cite with `@key`, and keep
  the `#bibliography(...)` block in `user-manual/main.typ`.
- HTML export uses Typst's experimental HTML backend (`--features html`); expect warnings.

## Nix

Derivations: `nix/doc-user-manual.nix`, `nix/doc-prog-manual.nix`, `nix/doc-tutorial.nix`
(shared logic in `nix/doc-common.nix`). Flake package `docSrc` points at this tree via
`builtins.path` so dirty-tree edits are visible before `git add`.

## History

One-time LaTeX → Typst migration script (no longer used):  
`archive/2026-06-06-wip/tools/migrate-tex-to-typst.py`

Re-convert a single chapter from git TeX (section-by-section, same path as
`Examples.typ`):  
`archive/2026-06-06-wip/tools/reconvert-tex-sections.py`

```bash
nix shell nixpkgs#pandoc nixpkgs#python3 -c python3 \
  archive/2026-06-06-wip/tools/reconvert-tex-sections.py \
  /path/to/chapter.tex components/doc/tutorial/chapters/chapter.typ \
  --assets components/doc/tutorial/assets
```
