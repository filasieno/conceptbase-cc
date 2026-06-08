#!/usr/bin/env bash
# Sync static documentation from the frozen archive snapshot in git history.
# Archive tree was removed in d54a9ac; sources live at d54a9ac^:archive/2026-06-06-wip/ProductPOOL/doc/
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ARCH_REF="${ARCH_REF:-d54a9ac^}"
ARCH_BASE="$ARCH_REF:archive/2026-06-06-wip/ProductPOOL/doc"

extract_file() {
  local rel="$1"
  local dest="$2"
  mkdir -p "$(dirname "$dest")"
  git show "$ARCH_BASE/$rel" >"$dest"
}

tech_info_files=(
  TechInfo/InstallationGuide.txt
  TechInfo/ReleaseNotes.txt
  TechInfo/Nissues.txt
)

developer_files=(
  Developper/JavaGraphicalTypes.txt
  Developper/cb_server_objects.doc
  Developper/cb_ptelos_objects.doc
  Developper/ErrorNotes.doc
  Developper/README.windows
)

license_files=(
  ExternalLicenses/README.txt
  ExternalLicenses/Swi-Prolog-License-14Jan2008.txt
  ExternalLicenses/Grappa-License-14Jan2008.txt
  ExternalLicenses/CBLogo-CC-BY-ND-40.txt
  ExternalLicenses/FlatLaf-LICENSE-9Mar2024.txt
  ExternalLicenses/Batik-License-2025.txt
  ExternalLicenses/Stl-Port-License-14Jan2008.txt
)

logo_files=(
  Logos/CB.gif
  Logos/CB-trans.gif
  Logos/CB-Linux.gif
  Logos/CB-Linux-trans.gif
  Logos/conceptbase-cc-logo.png
  Logos/ConceptBase.sxi
  Logos/CB_Linux.sxi
  Logos/conceptbase-cc-logo.sxd
)

for f in "${tech_info_files[@]}"; do
  extract_file "$f" "$ROOT/components/doc/tech-info/$(basename "$f")"
done

for f in "${developer_files[@]}"; do
  extract_file "$f" "$ROOT/components/doc/developer/$(basename "$f")"
done

for f in "${license_files[@]}"; do
  extract_file "$f" "$ROOT/components/doc/external-licenses/$(basename "$f")"
done

for f in "${logo_files[@]}"; do
  extract_file "$f" "$ROOT/components/doc/logos/$(basename "$f")"
done

cat >"$ROOT/components/doc/tech-info/README.md" <<'EOF'
# Technical reference (static)

Legacy plain-text technical notes from the ConceptBase.cc archive. For day-to-day
usage see the Typst **user manual**; for API and kernel details see the **programmer manual**.

| File | Contents |
|------|----------|
| `InstallationGuide.txt` | System requirements and install layout (updated for greenfield: use `nix run .#cbserver`) |
| `ReleaseNotes.txt` | Product release history |
| `Nissues.txt` | Known issues and release notes supplement |

Greenfield install replaces archive Make/`CB_Make` with Nix — see [CONTRIBUTING.md](../../../CONTRIBUTING.md).
EOF

cat >"$ROOT/components/doc/developer/README.md" <<'EOF'
# Developer notes (static)

Internal developer reference retained from the archive `doc/Developper/` tree.
Binary `.doc` files are legacy Word exports; prefer Typst manuals and `components/server-engine/`
for current behaviour.

| File | Contents |
|------|----------|
| `JavaGraphicalTypes.txt` | Graphical type implementation notes |
| `cb_server_objects.doc` | Server object model reference |
| `cb_ptelos_objects.doc` | P-Telos object model reference |
| `ErrorNotes.doc` | Error catalogue |
| `README.windows` | Windows build notes (historical; Linux x86_64 only in greenfield) |
EOF

cat >"$ROOT/components/doc/logos/README.md" <<'EOF'
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
EOF

echo "Synced static docs under components/doc/{tech-info,developer,external-licenses,logos}."
