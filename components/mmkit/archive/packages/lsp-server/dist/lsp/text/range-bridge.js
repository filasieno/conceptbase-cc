"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.nodeToLspRange = nodeToLspRange;
exports.indexToLspPosition = indexToLspPosition;
exports.lspPositionToIndex = lspPositionToIndex;
const encoding_1 = require("./encoding");
/**
 * Map a tree-sitter node to an LSP {@link Range} via UTF-16 indices only.
 * Line/character come from {@link TextDocument.positionAt} — no tree-sitter row lookup.
 */
function nodeToLspRange(doc, node) {
    (0, encoding_1.assertIndexEncodingContract)(doc, node);
    return {
        start: doc.positionAt(node.startIndex),
        end: doc.positionAt(node.endIndex),
    };
}
/** Map tree-sitter byte/code-unit index to LSP position (UTF-16). */
function indexToLspPosition(doc, index) {
    return doc.positionAt(index);
}
/** Map LSP position to index for tree-sitter edit alignment. */
function lspPositionToIndex(doc, position) {
    return doc.offsetAt(position);
}
//# sourceMappingURL=range-bridge.js.map