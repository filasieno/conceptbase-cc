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
exports.NotebookDidCloseCompleted = exports.NotebookDidCloseRunning = exports.NotebookDidCloseReceived = exports.NotebookDidCloseTop = void 0;
exports.spawnNotebookDidClose = spawnNotebookDidClose;
const ihsm = __importStar(require("ihsm"));
const lsp_actor_type_ids_1 = require("../../registry/lsp-actor-type-ids");
const notification_lifecycle_helpers_1 = require("../_shared/notification-lifecycle.helpers");
const METHOD = "notebookDocument/didClose";
class NotebookDidCloseTop extends ihsm.TopState {
}
exports.NotebookDidCloseTop = NotebookDidCloseTop;
class NotebookDidCloseReceived extends NotebookDidCloseTop {
    onEntry() {
        this.postNow("start");
    }
    start() {
        this.transition(NotebookDidCloseRunning);
    }
}
exports.NotebookDidCloseReceived = NotebookDidCloseReceived;
class NotebookDidCloseRunning extends NotebookDidCloseTop {
    onEntry() {
        this.postNow("run");
    }
    async run() {
        await (0, notification_lifecycle_helpers_1.runNotificationBody)(this.ctx.server, this.ctx.actorId, async () => {
            this.ctx.server.notebookRegistry.trackClose(this.ctx.params.notebookDocument.uri);
        }, (s) => this.transition(s), NotebookDidCloseCompleted);
    }
}
exports.NotebookDidCloseRunning = NotebookDidCloseRunning;
class NotebookDidCloseCompleted extends NotebookDidCloseTop {
    onEntry() {
        this.ctx.server.registry.remove(this.ctx.actorId);
    }
}
exports.NotebookDidCloseCompleted = NotebookDidCloseCompleted;
ihsm.InitialState(NotebookDidCloseReceived);
ihsm.registerStateNames({
    NotebookDidCloseReceived,
    NotebookDidCloseRunning,
    NotebookDidCloseCompleted,
});
function spawnNotebookDidClose(server, params) {
    const notificationId = server.registry.allocateId(METHOD);
    (0, notification_lifecycle_helpers_1.spawnNotificationHsm)(server, lsp_actor_type_ids_1.LSP_ACTOR_TYPE_IDS.notebookDidClose, METHOD, notificationId, NotebookDidCloseTop, { params });
}
//# sourceMappingURL=did-close-notification.hsm.js.map