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
exports.NotebookDidOpenCompleted = exports.NotebookDidOpenRunning = exports.NotebookDidOpenReceived = exports.NotebookDidOpenTop = void 0;
exports.spawnNotebookDidOpen = spawnNotebookDidOpen;
const ihsm = __importStar(require("ihsm"));
const shared_1 = require("@mmkit/shared");
const lsp_actor_type_ids_1 = require("../../registry/lsp-actor-type-ids");
const notification_lifecycle_helpers_1 = require("../_shared/notification-lifecycle.helpers");
const notebook_helpers_1 = require("./notebook.helpers");
const METHOD = "notebookDocument/didOpen";
class NotebookDidOpenTop extends ihsm.TopState {
}
exports.NotebookDidOpenTop = NotebookDidOpenTop;
class NotebookDidOpenReceived extends NotebookDidOpenTop {
    onEntry() {
        this.postNow("start");
    }
    start() {
        this.transition(NotebookDidOpenRunning);
    }
}
exports.NotebookDidOpenReceived = NotebookDidOpenReceived;
class NotebookDidOpenRunning extends NotebookDidOpenTop {
    onEntry() {
        this.postNow("run");
    }
    async run() {
        await (0, notification_lifecycle_helpers_1.runNotificationBody)(this.ctx.server, this.ctx.actorId, async () => {
            const event = this.ctx.params;
            const cellUris = event.notebookDocument.cells.map((c) => (0, notebook_helpers_1.cellDocumentUri)(c.document));
            this.ctx.server.notebookRegistry.trackOpen(event.notebookDocument.uri, event.notebookDocument.version, shared_1.NOTEBOOK_TYPE, cellUris);
            for (const uri of cellUris) {
                this.ctx.server.actuators.consoleLog(`notebook open: ${shared_1.LANGUAGE_ID} cell ${uri}`);
            }
        }, (s) => this.transition(s), NotebookDidOpenCompleted);
    }
}
exports.NotebookDidOpenRunning = NotebookDidOpenRunning;
class NotebookDidOpenCompleted extends NotebookDidOpenTop {
    onEntry() {
        this.ctx.server.registry.remove(this.ctx.actorId);
    }
}
exports.NotebookDidOpenCompleted = NotebookDidOpenCompleted;
ihsm.InitialState(NotebookDidOpenReceived);
ihsm.registerStateNames({
    NotebookDidOpenReceived,
    NotebookDidOpenRunning,
    NotebookDidOpenCompleted,
});
function spawnNotebookDidOpen(server, params) {
    const notificationId = server.registry.allocateId(METHOD);
    (0, notification_lifecycle_helpers_1.spawnNotificationHsm)(server, lsp_actor_type_ids_1.LSP_ACTOR_TYPE_IDS.notebookDidOpen, METHOD, notificationId, NotebookDidOpenTop, { params });
}
//# sourceMappingURL=did-open-notification.hsm.js.map