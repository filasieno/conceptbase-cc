# mmkit — Metamodelling Kit

A VS Code extension for **ConceptBase** metamodelling.

This is the initial scaffold. It currently ships a single **Hello World** command.
The O-Telos language server (LSP) and the ConceptBase MCP integration will be
added on top of this.

## Features

- Command Palette → **Metamodelling Kit: Hello World**
  (`mmkit.helloWorld`) — shows a notification.

## Build / package

This extension is plain JavaScript and has **no `node_modules`** — `vscode` is
provided by the host. Package it into a `.vsix` with the Nix derivation:

```bash
nix build .#mmkit -L
ls result/        # mmkit-0.1.0.vsix
```

Install the result with:

```bash
code --install-extension result/mmkit-0.1.0.vsix
```

Or, during development, open `components/mmkit/` in VS Code and press **F5**,
then run **Hello World** from the Command Palette.

## Layout

```
package.json        extension manifest
src/extension.js    activate() + the helloWorld command
```
