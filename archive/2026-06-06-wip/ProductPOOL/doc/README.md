# Archive doc corpus (post-migration)

**Product manuals (UserManual, ProgManual, Tutorial)** were migrated to Typst under
`components/doc/` and the LaTeX sources were removed from this archive.

What remains here:

| Directory | Node | Notes |
|-----------|------|-------|
| `TechInfo/` | `doc-tech-info` | Release notes, install guides (static text) |
| `Developper/` | `doc-developer` | Internal developer notes (`.doc`, `.txt`, …) |
| `ExternalLicenses/` | `doc-external-licenses` | Third-party license texts |
| `Logos/` | — | Legacy logo assets (copies also under `components/doc/*/assets/`) |

Do not add new `.tex` manual sources here. Future documentation work is Typst-only in
`components/doc/`.

One-time migration tool (historical): `archive/2026-06-06-wip/tools/migrate-tex-to-typst.py`
