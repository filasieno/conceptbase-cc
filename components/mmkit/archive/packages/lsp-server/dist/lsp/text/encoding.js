"use strict";
/**
 * Position encoding contract for ConceptBase LSP.
 *
 * - **LSP / {@link TextDocument}**: line + `character` are **UTF-16 code unit** offsets
 *   (JavaScript string indices). Surrogate pairs (e.g. emoji) count as two units.
 * - **web-tree-sitter** (JS string input): `startIndex` / `endIndex` on nodes match the
 *   same UTF-16 code unit indices when parsing `document.getText()` as a JS string.
 *   For **lines**, always derive positions via `document.positionAt(index)` — never
 *   tree-sitter `startPosition`/`endPosition` (EOF / trailing-newline rows can differ).
 *
 * Tree-sitter's C API uses UTF-8 byte offsets; the WASM binding over JS strings aligns
 * indices with LSP for BMP + supplementary text in practice — validate via
 * {@link assertIndexEncodingContract} (indices only).
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.utf16Length = utf16Length;
exports.utf8ByteLength = utf8ByteLength;
exports.assertIndexEncodingContract = assertIndexEncodingContract;
exports.lineSlice = lineSlice;
exports.getLineText = getLineText;
exports.positionEquals = positionEquals;
/** UTF-16 code unit length (same as `string.length` and LSP offsets). */
function utf16Length(text) {
    return text.length;
}
/** Byte length when the buffer is UTF-8-encoded (tree-sitter C API view). */
function utf8ByteLength(text) {
    return Buffer.byteLength(text, "utf8");
}
/**
 * Verify tree-sitter UTF-16 indices map to consistent LSP line/character positions.
 * Does not compare tree-sitter row/column — line counting uses the buffer only.
 */
function assertIndexEncodingContract(doc, node, context) {
    const text = doc.getText();
    const prefix = context ? `${context}: ` : "";
    const len = utf16Length(text);
    if (node.startIndex < 0 || node.endIndex < 0 || node.startIndex > node.endIndex || node.endIndex > len) {
        throw new Error(`${prefix}index out of bounds [${node.startIndex},${node.endIndex}) len=${len}`);
    }
    const start = doc.positionAt(node.startIndex);
    const end = doc.positionAt(node.endIndex);
    const slice = text.slice(node.startIndex, node.endIndex);
    const viaLine = lineSlice(doc, start.line, start.character, end.line, end.character);
    if (slice !== viaLine) {
        throw new Error(`${prefix}slice mismatch at [${node.startIndex},${node.endIndex})`);
    }
    if (doc.offsetAt(start) !== node.startIndex || doc.offsetAt(end) !== node.endIndex) {
        throw new Error(`${prefix}position round-trip failed for [${node.startIndex},${node.endIndex})`);
    }
}
/** Extract text for an LSP range using UTF-16 line/character positions. */
function lineSlice(doc, startLine, startCharacter, endLine, endCharacter) {
    const startOffset = doc.offsetAt({ line: startLine, character: startCharacter });
    const endOffset = doc.offsetAt({ line: endLine, character: endCharacter });
    return doc.getText().slice(startOffset, endOffset);
}
/** Line text without trailing `\\n`/`\\r\\n` line break. */
function getLineText(doc, line) {
    const start = doc.offsetAt({ line, character: 0 });
    const end = line + 1 < doc.lineCount
        ? doc.offsetAt({ line: line + 1, character: 0 })
        : doc.getText().length;
    let slice = doc.getText().slice(start, end);
    if (slice.endsWith("\r\n"))
        slice = slice.slice(0, -2);
    else if (slice.endsWith("\n"))
        slice = slice.slice(0, -1);
    return slice;
}
function positionEquals(a, b) {
    return a.line === b.line && a.character === b.character;
}
//# sourceMappingURL=encoding.js.map