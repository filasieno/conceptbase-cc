"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.NotebookRegistry = void 0;
class NotebookRegistry {
    notebooks = new Map();
    cellToNotebook = new Map();
    trackOpen(uri, version, notebookType, cellUris) {
        const prev = this.notebooks.get(uri);
        if (prev && version <= prev.version) {
            return { ok: false, reason: "stale-version" };
        }
        if (prev) {
            for (const cell of prev.cellUris) {
                this.cellToNotebook.delete(cell);
            }
        }
        const record = { uri, version, notebookType, cellUris: [...cellUris] };
        this.notebooks.set(uri, record);
        for (const cell of cellUris) {
            this.cellToNotebook.set(cell, uri);
        }
        return { ok: true, record };
    }
    trackChange(uri, nextVersion, cellUris) {
        const record = this.notebooks.get(uri);
        if (!record)
            return { ok: false, reason: "unknown-uri" };
        if (nextVersion <= record.version)
            return { ok: false, reason: "stale-version" };
        if (nextVersion > record.version + 1)
            return { ok: false, reason: "version-gap" };
        for (const cell of record.cellUris) {
            this.cellToNotebook.delete(cell);
        }
        record.version = nextVersion;
        if (cellUris) {
            record.cellUris = [...cellUris];
        }
        for (const cell of record.cellUris) {
            this.cellToNotebook.set(cell, uri);
        }
        return { ok: true, record };
    }
    trackClose(uri) {
        const record = this.notebooks.get(uri);
        if (record) {
            for (const cell of record.cellUris) {
                this.cellToNotebook.delete(cell);
            }
        }
        this.notebooks.delete(uri);
    }
    get(uri) {
        return this.notebooks.get(uri);
    }
    findNotebookForCell(cellUri) {
        const nbUri = this.cellToNotebook.get(cellUri);
        if (!nbUri)
            return undefined;
        return this.notebooks.get(nbUri);
    }
    entries() {
        return [...this.notebooks.values()];
    }
}
exports.NotebookRegistry = NotebookRegistry;
//# sourceMappingURL=notebook-registry.js.map