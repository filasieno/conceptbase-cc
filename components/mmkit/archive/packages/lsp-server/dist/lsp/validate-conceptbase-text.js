"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.validateConceptBaseText = validateConceptBaseText;
const vscode_languageserver_textdocument_1 = require("vscode-languageserver-textdocument");
const diagnostics_1 = require("./tree-sitter/diagnostics");
const runtime_1 = require("./tree-sitter/runtime");
const MAX_FRAME_BYTES = 512_000;
async function validateConceptBaseText(text) {
    if (text.length === 0) {
        return { ok: false, issues: [{ message: "empty input" }], parser: "empty" };
    }
    if (Buffer.byteLength(text, "utf8") > MAX_FRAME_BYTES) {
        return {
            ok: false,
            issues: [{ message: `input exceeds ${MAX_FRAME_BYTES} bytes` }],
            parser: "empty",
        };
    }
    const ready = await (0, runtime_1.isTreeSitterAvailable)();
    if (ready) {
        const tree = (0, runtime_1.parseConceptBase)(text);
        if (!tree) {
            return {
                ok: false,
                issues: [{ message: "tree-sitter parse failed" }],
                parser: "tree-sitter",
            };
        }
        const errorCount = (0, runtime_1.countSyntaxErrors)(tree.rootNode);
        if (errorCount > 0) {
            return {
                ok: false,
                issues: [{ message: `syntax errors in ConceptBase source (${errorCount} ERROR node(s))` }],
                parser: "tree-sitter",
            };
        }
        return { ok: true, issues: [], parser: "tree-sitter" };
    }
    const doc = vscode_languageserver_textdocument_1.TextDocument.create("mcp://inline", "conceptbase", 1, text);
    const diags = (0, diagnostics_1.bracketDiagnostics)(text, doc);
    if (diags.length > 0) {
        return {
            ok: false,
            issues: diags.map((d) => ({
                message: d.message,
                line: d.range.start.line,
                character: d.range.start.character,
            })),
            parser: "bracket-fallback",
        };
    }
    return { ok: true, issues: [], parser: "bracket-fallback" };
}
//# sourceMappingURL=validate-conceptbase-text.js.map