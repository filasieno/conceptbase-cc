"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.bracketDiagnostics = bracketDiagnostics;
exports.diagnosticsFromTree = diagnosticsFromTree;
const node_1 = require("vscode-languageserver/node");
const range_bridge_1 = require("../text/range-bridge");
function walkErrors(node, doc, out) {
    if (node.hasError || node.type === "ERROR") {
        const range = (0, range_bridge_1.nodeToLspRange)(doc, node);
        out.push({
            severity: node_1.DiagnosticSeverity.Error,
            range,
            message: node.isMissing ? `Missing ${node.type}` : "Syntax error",
            source: "conceptbase",
        });
    }
    for (let i = 0; i < node.childCount; i++) {
        const child = node.child(i);
        if (child)
            walkErrors(child, doc, out);
    }
}
/** Bracket/string-aware fallback when tree-sitter is unavailable. Uses UTF-16 indices. */
function bracketDiagnostics(text, doc) {
    const stack = [];
    const pairs = { "(": ")", "[": "]" };
    const closers = new Set(Object.values(pairs));
    const diagnostics = [];
    for (let i = 0; i < text.length; i++) {
        const ch = text[i];
        if (ch === '"' || ch === "'") {
            const quote = ch;
            i++;
            while (i < text.length && text[i] !== quote) {
                if (text[i] === "\\")
                    i++;
                i++;
            }
            continue;
        }
        if (pairs[ch]) {
            stack.push({ ch, index: i });
            continue;
        }
        if (closers.has(ch)) {
            const open = stack.pop();
            if (!open || pairs[open.ch] !== ch) {
                const start = (0, range_bridge_1.indexToLspPosition)(doc, i);
                diagnostics.push({
                    severity: node_1.DiagnosticSeverity.Error,
                    range: { start, end: { line: start.line, character: start.character + 1 } },
                    message: `Unexpected '${ch}'`,
                    source: "conceptbase",
                });
            }
        }
    }
    for (const open of stack) {
        const start = (0, range_bridge_1.indexToLspPosition)(doc, open.index);
        diagnostics.push({
            severity: node_1.DiagnosticSeverity.Error,
            range: { start, end: { line: start.line, character: start.character + 1 } },
            message: `Unclosed '${open.ch}'`,
            source: "conceptbase",
        });
    }
    return diagnostics;
}
function diagnosticsFromTree(root, doc) {
    const diagnostics = [];
    walkErrors(root, doc, diagnostics);
    return diagnostics;
}
//# sourceMappingURL=diagnostics.js.map