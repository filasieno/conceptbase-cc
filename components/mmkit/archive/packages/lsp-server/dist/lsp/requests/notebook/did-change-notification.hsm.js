"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.NotebookDidChangeCompleted = exports.NotebookDidChangeRunning = exports.NotebookDidChangeReceived = exports.NotebookDidChangeTop = void 0;
exports.spawnNotebookDidChange = spawnNotebookDidChange;
const ihsm = __importStar(require("ihsm"));
const diagnostics_service_1 = require("../../services/diagnostics-service");
const lsp_actor_type_ids_1 = require("../../registry/lsp-actor-type-ids");
const notification_lifecycle_helpers_1 = require("../_shared/notification-lifecycle.helpers");
const notebook_helpers_1 = require("./notebook.helpers");
const METHOD = "notebookDocument/didChange";
class NotebookDidChangeTop extends ihsm.TopState {
}
exports.NotebookDidChangeTop = NotebookDidChangeTop;
class NotebookDidChangeReceived extends NotebookDidChangeTop {
    onEntry() {
        this.postNow("start");
    }
    start() {
        this.transition(NotebookDidChangeRunning);
    }
}
exports.NotebookDidChangeReceived = NotebookDidChangeReceived;
class NotebookDidChangeRunning extends NotebookDidChangeTop {
    onEntry() {
        this.postNow("run");
    }
    async run() {
        await (0, notification_lifecycle_helpers_1.runNotificationBody)(this.ctx.server, this.ctx.actorId, async () => {
            const event = this.ctx.params;
            const structure = event.change.cells?.structure;
            const cellUris = structure?.array?.cells?.map((c) => (0, notebook_helpers_1.cellDocumentUri)(c.document));
            this.ctx.server.notebookRegistry.trackChange(event.notebookDocument.uri, event.notebookDocument.version, cellUris);
            const textChanges = event.change.cells?.textContent ?? [];
            for (const cellChange of textChanges) {
                const uri = (0, notebook_helpers_1.cellDocumentUri)(cellChange.document);
                const doc = this.ctx.server.documents.get(uri);
                if (doc) {
                    this.ctx.server.documentRegistry.trackSyncedDocument(doc);
                    await (0, diagnostics_service_1.publishDiagnosticsForUri)(this.ctx.server, uri);
                }
            }
        }, (s) => this.transition(s), NotebookDidChangeCompleted);
    }
}
exports.NotebookDidChangeRunning = NotebookDidChangeRunning;
class NotebookDidChangeCompleted extends NotebookDidChangeTop {
    onEntry() {
        this.ctx.server.registry.remove(this.ctx.actorId);
    }
}
exports.NotebookDidChangeCompleted = NotebookDidChangeCompleted;
ihsm.InitialState(NotebookDidChangeReceived);
ihsm.registerStateNames({
    NotebookDidChangeReceived,
    NotebookDidChangeRunning,
    NotebookDidChangeCompleted,
});
function spawnNotebookDidChange(server, params) {
    const notificationId = server.registry.allocateId(METHOD);
    (0, notification_lifecycle_helpers_1.spawnNotificationHsm)(server, lsp_actor_type_ids_1.LSP_ACTOR_TYPE_IDS.notebookDidChange, METHOD, notificationId, NotebookDidChangeTop, { params });
}
//# sourceMappingURL=did-change-notification.hsm.js.map