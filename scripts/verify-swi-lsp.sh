#!/usr/bin/env bash
set -euo pipefail

export PATH="$HOME/.nix-profile/bin:$HOME/.local/bin:$PATH"

echo -n "swipl: "; command -v swipl
swipl --version

echo "lsp_server pack:"
swipl -g "pack_list(lsp_server), halt." 2>/dev/null | sed -n '1p'

echo -n "library(json): "
swipl -g "use_module(library(json)), writeln(ok), halt."

echo -n "lsp_server module: "
swipl -g "use_module(library(lsp_server)), writeln(ok), halt."

BODY='{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"capabilities":{},"rootUri":"file:///tmp"}}'
printf "Content-Length: %d\r\n\r\n%s" "${#BODY}" "$BODY" \
  | timeout 5 swipl -g "use_module(library(lsp_server))." -g "lsp_server:main" -t halt -- stdio 2>/dev/null \
  | head -1

if command -v cursor >/dev/null; then
  echo -n "cursor extension: "
  cursor --list-extensions 2>/dev/null | grep -i prolog || echo "(not installed)"
fi

echo "OK"
