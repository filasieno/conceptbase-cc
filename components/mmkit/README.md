# mmkit — Metamodelling Kit

VS Code extension for **ConceptBase** metamodelling. This workspace was reset to a minimal
bootstrap; the previous implementation lives under `archive/packages/`.

## Workspace layout

```
components/mmkit/
  archive/packages/       previous extension, lsp-server, shared
  package.json              npm workspaces root
  packages/
    shared/                 @mmkit/shared — command ids and shared constants
    server/                 @mmkit/server — MCP, HTTP, LSP, cbserver (ihsm actor), system entry
      src/cbserver/         CBServerActor, CBServerPort, CBServerContext
      src/http/             Express health + MCP mount
      src/lsp/              TCP language server
      src/mcp/              MCP tools
      src/system/           process entrypoint (main)
    extension/              mmkit — VS Code extension
```

## Build

```bash
cd components/mmkit
npm install
npm run build
```

F5 from `packages/extension/` (Run Extension).

## Test

```bash
npm test
npm run test:integration
```

## Package (Nix)

```bash
nix build .#mmkit -L
```
