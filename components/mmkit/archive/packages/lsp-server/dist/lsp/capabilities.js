"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.buildServerCapabilities = buildServerCapabilities;
const node_1 = require("vscode-languageserver/node");
const shared_1 = require("@mmkit/shared");
const legend_1 = require("./semantic-tokens/legend");
/** Server initialize capabilities (exported for contract tests). */
function buildServerCapabilities(mmkitExtension) {
    if (node_1.TextDocumentSyncKind.Incremental !== shared_1.TEXT_DOCUMENT_SYNC_INCREMENTAL) {
        throw new Error("TextDocumentSyncKind.Incremental must equal 2");
    }
    return {
        textDocumentSync: {
            openClose: true,
            change: node_1.TextDocumentSyncKind.Incremental,
            willSave: true,
            willSaveWaitUntil: true,
            save: { includeText: true },
        },
        notebookDocumentSync: {
            notebookSelector: [{ notebook: shared_1.NOTEBOOK_TYPE, cells: [{ language: shared_1.LANGUAGE_ID }] }],
            save: true,
        },
        semanticTokensProvider: {
            legend: {
                tokenTypes: [...legend_1.SEMANTIC_TOKEN_TYPES],
                tokenModifiers: [...legend_1.SEMANTIC_TOKEN_MODIFIERS],
            },
            full: true,
            range: true,
            workDoneProgress: true,
        },
        mmkit: mmkitExtension ?? {
            serverControl: true,
            otel: true,
            mcpHttpPort: Number(process.env.MMKIT_HTTP_PORT ?? "28080"),
        },
    };
}
//# sourceMappingURL=capabilities.js.map