"use strict";
/**
 * Line model backed solely by {@link TextDocument} (LSP buffer).
 *
 * `vscode-languageserver-textdocument` maintains incremental `_lineOffsets` on each
 * `TextDocument.update()` — line count and `offsetAt`/`positionAt` never require a
 * tree-sitter re-parse or a full `split('\n')` rescan of the buffer.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.getLineCount = getLineCount;
exports.getLineLength = getLineLength;
exports.validateLinePosition = validateLinePosition;
const encoding_1 = require("./encoding");
/** O(1) line count from the open buffer — no CST parse. */
function getLineCount(doc) {
    return doc.lineCount;
}
/** UTF-16 length of line `line` (content only, no trailing newline). */
function getLineLength(doc, line) {
    return (0, encoding_1.utf16Length)((0, encoding_1.getLineText)(doc, line));
}
/**
 * Validate an LSP position against buffer line bounds.
 * `character` may equal line length (insert-after-last-char / exclusive range end).
 */
function validateLinePosition(doc, position) {
    const { line, character } = position;
    if (line < 0 || line >= doc.lineCount) {
        return `line ${line} out of range (lineCount=${doc.lineCount})`;
    }
    if (character < 0) {
        return `character ${character} must be non-negative`;
    }
    const lineLen = getLineLength(doc, line);
    if (character > lineLen) {
        return `character ${character} past end of line ${line} (length=${lineLen})`;
    }
    return undefined;
}
//# sourceMappingURL=lines.js.map