"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.DiagnosticsPublisher = void 0;
const parse_1 = require("../parse");
/**
 * Wires parse diagnostics to the LSP client (VS Code Problems panel).
 *
 * The extension host receives `textDocument/publishDiagnostics` and renders squiggles
 * in editors and the Diagnostics panel.
 */
class DiagnosticsPublisher {
    send;
    constructor(send) {
        this.send = send;
    }
    static fromConnection(connection) {
        return new DiagnosticsPublisher((params) => connection.sendDiagnostics(params));
    }
    /** Parse + publish diagnostics for `uri`; returns the published set. */
    async publish(registry, uri) {
        const diagnostics = await (0, parse_1.validateDocument)(registry, uri);
        this.send({ uri, diagnostics });
        return diagnostics;
    }
    /** Clear diagnostics when a document closes. */
    clear(uri) {
        this.send({ uri, diagnostics: [] });
    }
}
exports.DiagnosticsPublisher = DiagnosticsPublisher;
//# sourceMappingURL=publisher.js.map