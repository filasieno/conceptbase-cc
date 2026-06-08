"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.TextEditingFramework = void 0;
exports.validateUtf16Range = validateUtf16Range;
exports.applyEditsToDocument = applyEditsToDocument;
const vscode_languageserver_textdocument_1 = require("vscode-languageserver-textdocument");
const encoding_1 = require("./encoding");
const lines_1 = require("./lines");
/**
 * UTF-16–aware incremental editing on top of {@link DocumentRegistry}.
 *
 * All ranges use LSP semantics (UTF-16 code units). Tree-sitter re-parse uses the
 * updated `document.getText()`; CST indices remain aligned when parsing the same string.
 */
class TextEditingFramework {
    registry;
    constructor(registry) {
        this.registry = registry;
    }
    open(document) {
        return this.registry.trackOpen(document);
    }
    close(uri) {
        this.registry.trackClose(uri);
    }
    /**
     * Apply one LSP `contentChanges` batch. Validates UTF-16 range bounds before update.
     */
    applyEdits(uri, edits, nextVersion) {
        const current = this.registry.getBuffer(uri);
        if (!current)
            return { ok: false, reason: "unknown-uri" };
        const changes = [];
        for (const edit of edits) {
            const err = validateUtf16Range(current, edit.range);
            if (err)
                throw new Error(`Invalid UTF-16 edit range: ${err}`);
            changes.push({ range: edit.range, text: edit.text });
        }
        return this.registry.trackChange(uri, changes, nextVersion);
    }
    /** Insert at UTF-16 (line, character). */
    insertAt(uri, line, character, text, nextVersion) {
        const current = this.registry.getBuffer(uri);
        if (!current)
            return { ok: false, reason: "unknown-uri" };
        const version = nextVersion ?? current.version + 1;
        return this.applyEdits(uri, [{ range: { start: { line, character }, end: { line, character } }, text }], version);
    }
    /** Delete UTF-16 range [start, end). */
    deleteRange(uri, start, end, nextVersion) {
        const current = this.registry.getBuffer(uri);
        if (!current)
            return { ok: false, reason: "unknown-uri" };
        const version = nextVersion ?? current.version + 1;
        return this.applyEdits(uri, [{ range: { start, end }, text: "" }], version);
    }
    getDocument(uri) {
        return this.registry.getBuffer(uri);
    }
    /** Line text from the LSP buffer — never triggers tree-sitter parse. */
    getLine(uri, line) {
        const doc = this.registry.getBuffer(uri);
        if (!doc || line < 0 || line >= (0, lines_1.getLineCount)(doc))
            return undefined;
        return (0, encoding_1.getLineText)(doc, line);
    }
    /** O(1) line count from buffer cache — never triggers tree-sitter parse. */
    getLineCount(uri) {
        const doc = this.registry.getBuffer(uri);
        return doc ? (0, lines_1.getLineCount)(doc) : undefined;
    }
    getRegistry() {
        return this.registry;
    }
}
exports.TextEditingFramework = TextEditingFramework;
/** Ensure range endpoints are valid UTF-16 offsets within the document (buffer-only). */
function validateUtf16Range(doc, range) {
    const startErr = (0, lines_1.validateLinePosition)(doc, range.start);
    if (startErr)
        return startErr;
    const endErr = (0, lines_1.validateLinePosition)(doc, range.end);
    if (endErr)
        return endErr;
    const text = doc.getText();
    const len = (0, encoding_1.utf16Length)(text);
    const start = doc.offsetAt(range.start);
    const end = doc.offsetAt(range.end);
    if (start < 0 || end < 0 || start > len || end > len || start > end) {
        return `out of bounds start=${start} end=${end} len=${len}`;
    }
    return undefined;
}
/** Build a new in-memory document after edits (test helper sharing framework rules). */
function applyEditsToDocument(doc, edits, nextVersion) {
    for (const edit of edits) {
        const err = validateUtf16Range(doc, edit.range);
        if (err)
            throw new Error(err);
    }
    return vscode_languageserver_textdocument_1.TextDocument.update(doc, edits.map((e) => ({ range: e.range, text: e.text })), nextVersion ?? doc.version + 1);
}
//# sourceMappingURL=editing.js.map