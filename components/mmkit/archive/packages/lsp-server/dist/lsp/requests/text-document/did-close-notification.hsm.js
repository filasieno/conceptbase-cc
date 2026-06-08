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
exports.DidCloseCompleted = exports.DidCloseRunning = exports.DidCloseReceived = exports.DidCloseTop = void 0;
exports.spawnDidCloseNotification = spawnDidCloseNotification;
const ihsm = __importStar(require("ihsm"));
const lsp_actor_type_ids_1 = require("../../registry/lsp-actor-type-ids");
const notification_lifecycle_helpers_1 = require("../_shared/notification-lifecycle.helpers");
const METHOD = "textDocument/didClose";
class DidCloseTop extends ihsm.TopState {
}
exports.DidCloseTop = DidCloseTop;
class DidCloseReceived extends DidCloseTop {
    onEntry() {
        this.postNow("start");
    }
    start() {
        this.transition(DidCloseRunning);
    }
}
exports.DidCloseReceived = DidCloseReceived;
class DidCloseRunning extends DidCloseTop {
    onEntry() {
        this.postNow("run");
    }
    async run() {
        await (0, notification_lifecycle_helpers_1.runNotificationBody)(this.ctx.server, this.ctx.actorId, async () => {
            const doc = this.ctx.document;
            this.ctx.server.documentRegistry.trackClose(doc.uri);
            this.ctx.server.metrics.documentsOpen.set(this.ctx.server.documentRegistry.openCount());
            this.ctx.server.diagnosticsPublisher.clear(doc.uri);
        }, (s) => this.transition(s), DidCloseCompleted);
    }
}
exports.DidCloseRunning = DidCloseRunning;
class DidCloseCompleted extends DidCloseTop {
    onEntry() {
        this.ctx.server.registry.remove(this.ctx.actorId);
    }
}
exports.DidCloseCompleted = DidCloseCompleted;
ihsm.InitialState(DidCloseReceived);
ihsm.registerStateNames({
    DidCloseReceived,
    DidCloseRunning,
    DidCloseCompleted,
});
function spawnDidCloseNotification(server, document) {
    const notificationId = server.registry.allocateId(METHOD);
    (0, notification_lifecycle_helpers_1.spawnNotificationHsm)(server, lsp_actor_type_ids_1.LSP_ACTOR_TYPE_IDS.textDocumentDidClose, METHOD, notificationId, DidCloseTop, { document });
}
//# sourceMappingURL=did-close-notification.hsm.js.map