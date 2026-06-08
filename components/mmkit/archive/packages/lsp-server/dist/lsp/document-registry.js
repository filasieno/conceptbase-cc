"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.DocumentRegistry = void 0;
const vscode_languageserver_textdocument_1 = require("vscode-languageserver-textdocument");
const conceptbase_document_1 = require("./conceptbase-document");
class DocumentRegistry {
    /** URI → LSP text buffer. */
    buffers = new Map();
    /** URI → last accepted LSP document version. */
    versions = new Map();
    /** URI → incremental tree-sitter CST (optional sidecar). */
    trees = new Map();
    /** Document opened (full text). */
    trackOpen(document) {
        const prev = this.versions.get(document.uri);
        if (prev !== undefined && document.version <= prev) {
            return { ok: false, reason: "stale-version" };
        }
        this.buffers.set(document.uri, document);
        this.versions.set(document.uri, document.version);
        return { ok: true, document };
    }
    /**
     * Apply incremental LSP edits. `nextVersion` must be strictly greater than the
     * stored version unless this is the first change after open with matching version.
     */
    trackChange(uri, contentChanges, nextVersion) {
        const current = this.buffers.get(uri);
        if (!current)
            return { ok: false, reason: "unknown-uri" };
        const prevVersion = this.versions.get(uri);
        if (prevVersion === undefined)
            return { ok: false, reason: "unknown-uri" };
        if (nextVersion <= prevVersion)
            return { ok: false, reason: "stale-version" };
        if (nextVersion > prevVersion + 1) {
            return { ok: false, reason: "version-gap" };
        }
        const updated = vscode_languageserver_textdocument_1.TextDocument.update(current, contentChanges, nextVersion);
        this.buffers.set(uri, updated);
        this.versions.set(uri, nextVersion);
        return { ok: true, document: updated };
    }
    /** Sync from an already-updated document (e.g. `TextDocuments` manager event). */
    trackSyncedDocument(document) {
        const prev = this.versions.get(document.uri);
        if (prev === undefined) {
            return this.trackOpen(document);
        }
        if (document.version <= prev) {
            return { ok: false, reason: "stale-version" };
        }
        if (document.version > prev + 1) {
            return { ok: false, reason: "version-gap" };
        }
        this.buffers.set(document.uri, document);
        this.versions.set(document.uri, document.version);
        return { ok: true, document };
    }
    trackClose(uri) {
        this.buffers.delete(uri);
        this.versions.delete(uri);
        this.trees.delete(uri);
    }
    getBuffer(uri) {
        return this.buffers.get(uri);
    }
    getAcceptedVersion(uri) {
        return this.versions.get(uri);
    }
    getTree(uri) {
        return this.trees.get(uri);
    }
    setTree(uri, tree) {
        if (tree === undefined) {
            this.trees.delete(uri);
        }
        else {
            this.trees.set(uri, tree);
        }
    }
    getConceptBaseDocument(uri) {
        const document = this.buffers.get(uri);
        if (!document)
            return undefined;
        return (0, conceptbase_document_1.toConceptBaseDocument)(document, this.trees.get(uri));
    }
    openCount() {
        return this.buffers.size;
    }
    /** All open ConceptBase buffers (for tests / diagnostics sweep). */
    entries() {
        return [...this.buffers.entries()].map(([uri, document]) => (0, conceptbase_document_1.toConceptBaseDocument)(document, this.trees.get(uri)));
    }
}
exports.DocumentRegistry = DocumentRegistry;
//# sourceMappingURL=document-registry.js.map