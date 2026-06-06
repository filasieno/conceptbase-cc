// Metamodelling Kit — ConceptBase toolkit for VS Code.
// Minimal scaffold: a single "Hello World" command. The O-Telos LSP and the
// ConceptBase MCP integration will be added on top of this later.
//
// Plain CommonJS so the extension needs no build step and no node_modules:
// the only runtime dependency, `vscode`, is provided by the host.

const vscode = require("vscode");

function activate(context) {
  const disposable = vscode.commands.registerCommand("mmkit.helloWorld", () => {
    vscode.window.showInformationMessage("Hello World from Metamodelling Kit!");
  });
  context.subscriptions.push(disposable);
}

function deactivate() {}

module.exports = { activate, deactivate };
