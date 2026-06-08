"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.validateDocument = validateDocument;
exports.validateConceptBaseDocument = validateConceptBaseDocument;
exports.clearDocumentTree = clearDocumentTree;
const diagnostics_1 = require("./tree-sitter/diagnostics");
const runtime_1 = require("./tree-sitter/runtime");
async function validateDocument(registry, uri) {
    const entry = registry.getConceptBaseDocument(uri);
    if (!entry)
        return [];
    return validateConceptBaseDocument(registry, entry.document);
}
async function validateConceptBaseDocument(registry, doc) {
    const text = doc.getText();
    if (text.trim().length === 0)
        return [];
    const ready = await (0, runtime_1.isTreeSitterAvailable)();
    if (!ready) {
        return (0, diagnostics_1.bracketDiagnostics)(text, doc);
    }
    const previous = registry.getTree(doc.uri);
    const tree = (0, runtime_1.parseConceptBase)(text, previous);
    if (!tree) {
        registry.setTree(doc.uri, undefined);
        return (0, diagnostics_1.bracketDiagnostics)(text, doc);
    }
    registry.setTree(doc.uri, tree);
    const diagnostics = (0, diagnostics_1.diagnosticsFromTree)(tree.rootNode, doc);
    if (diagnostics.length === 0) {
        diagnostics.push(...(0, diagnostics_1.bracketDiagnostics)(text, doc));
    }
    return diagnostics;
}
/** @deprecated Use DocumentRegistry.trackClose */
function clearDocumentTree(registry, uri) {
    registry.setTree(uri, undefined);
}
//# sourceMappingURL=parse.js.map