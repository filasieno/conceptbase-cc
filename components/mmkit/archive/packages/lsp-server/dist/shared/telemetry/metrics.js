"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createLspMetrics = createLspMetrics;
const prom_client_1 = require("prom-client");
function createLspMetrics() {
    const registry = new prom_client_1.Registry();
    (0, prom_client_1.collectDefaultMetrics)({ register: registry, prefix: "mmkit_lsp_" });
    const documentsOpen = new prom_client_1.Gauge({
        name: "mmkit_lsp_documents_open",
        help: "Number of open ConceptBase documents tracked by the language server",
        registers: [registry],
    });
    const diagnosticsPublished = new prom_client_1.Counter({
        name: "mmkit_lsp_diagnostics_published_total",
        help: "Total diagnostic publish operations",
        registers: [registry],
    });
    const lspInitialized = new prom_client_1.Counter({
        name: "mmkit_lsp_initialize_total",
        help: "LSP initialize handshakes completed",
        registers: [registry],
    });
    return { documentsOpen, diagnosticsPublished, lspInitialized, registry };
}
//# sourceMappingURL=metrics.js.map