#!/usr/bin/env bash
# Install / repair SWI-Prolog LSP tooling (Nix swipl + lsp_server pack + Cursor extension).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CACHE="$ROOT/.cache"
VSIX_URL="https://github.com/jamesnvc/lsp_server/releases/download/v2.2.7/prolog-lsp-2.2.7.vsix"
NIX_SWI="$(command -v nix >/dev/null && nix build --no-link --print-out-paths 'nixpkgs#swi-prolog' 2>/dev/null || true)"

echo "==> SWI-Prolog via Nix profile"
if ! command -v swipl >/dev/null || ! swipl --version 2>&1 | grep -q 'SWI-Prolog'; then
  nix profile add nixpkgs#swi-prolog
fi
export PATH="$HOME/.nix-profile/bin:$PATH"
swipl --version

echo "==> library(json) shim for Nix swipl"
mkdir -p "$HOME/.config/swi-prolog/lib" "$HOME/.local/bin"
if [[ -z "$NIX_SWI" ]]; then
  NIX_SWI="$(dirname "$(dirname "$(command -v swipl)")")"
fi
JSON_PL="$NIX_SWI/lib/swipl/library/ext/http/http/json.pl"
if [[ ! -f "$JSON_PL" ]]; then
  echo "error: cannot find json.pl under $NIX_SWI" >&2
  exit 1
fi
ln -sf "$JSON_PL" "$HOME/.config/swi-prolog/lib/json.pl"
cat > "$HOME/.config/swi-prolog/init.pl" <<'EOF'
%% User init — LSP json shim (Nix swi-prolog)
:- multifile user:file_search_path/2.
user:file_search_path(library, Dir) :-
    absolute_file_name(app_config(lib), Dir, [file_type(directory), access(read)]).
EOF

echo "==> lsp_server pack"
swipl -g "pack_install(lsp_server, [interactive(false)])" -t halt

echo "==> swipl on PATH for GUI/LSP hosts"
ln -sf "$HOME/.nix-profile/bin/swipl" "$HOME/.local/bin/swipl"

echo "==> Cursor extension (jamesnvc.prolog-lsp)"
mkdir -p "$CACHE"
curl -fsSL -o "$CACHE/prolog-lsp.vsix" "$VSIX_URL"
if command -v cursor >/dev/null; then
  cursor --install-extension "$CACHE/prolog-lsp.vsix" || true
else
  echo "cursor CLI not found — install $CACHE/prolog-lsp.vsix manually"
fi

echo "==> Done. Run: $ROOT/scripts/verify-swi-lsp.sh"
