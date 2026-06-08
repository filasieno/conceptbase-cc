# Logo assets (static)

Brand artwork from the archive `ProductPOOL/doc/Logos/` tree. Use these for
documentation, packaging, and desktop integration.

| File | Contents |
|------|----------|
| `CB.gif` | Classic ConceptBase logo |
| `CB-trans.gif` | Transparent background variant |
| `CB-Linux.gif` | Linux branding variant |
| `CB-Linux-trans.gif` | Linux variant, transparent |
| `conceptbase-cc-logo.png` | ConceptBase.cc logo (PNG) |
| `ConceptBase.sxi` | OpenOffice/LibreOffice Draw source |
| `CB_Linux.sxi` | Linux logo Draw source |
| `conceptbase-cc-logo.sxd` | Legacy StarOffice Draw source |

License terms for the CB logo are in `../external-licenses/CBLogo-CC-BY-ND-40.txt`.

Sync from git archive:

```bash
./scripts/sync-static-docs.sh
```

Build:

```bash
nix build .#checks.x86_64-linux.doc-logos -L
```

Bundled in `.#docs` under `share/doc/logos/`.
