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
exports.DidChangeCompleted = exports.DidChangeRunning = exports.DidChangeReceived = exports.DidChangeTop = void 0;
exports.spawnDidChangeNotification = spawnDidChangeNotification;
const ihsm = __importStar(require("ihsm"));
const diagnostics_service_1 = require("../../services/diagnostics-service");
const lsp_actor_type_ids_1 = require("../../registry/lsp-actor-type-ids");
const notification_lifecycle_helpers_1 = require("../_shared/notification-lifecycle.helpers");
const METHOD = "textDocument/didChange";
class DidChangeTop extends ihsm.TopState {
}
exports.DidChangeTop = DidChangeTop;
class DidChangeReceived extends DidChangeTop {
    onEntry() {
        this.postNow("start");
    }
    start() {
        this.transition(DidChangeRunning);
    }
}
exports.DidChangeReceived = DidChangeReceived;
class DidChangeRunning extends DidChangeTop {
    onEntry() {
        this.postNow("run");
    }
    async run() {
        await (0, notification_lifecycle_helpers_1.runNotificationBody)(this.ctx.server, this.ctx.actorId, async () => {
            const doc = this.ctx.document;
            const sync = this.ctx.server.documentRegistry.trackSyncedDocument(doc);
            if (!sync.ok) {
                this.ctx.server.actuators.consoleError(`conceptbase-lsp: ignored stale document sync for ${doc.uri}`);
                return;
            }
            await (0, diagnostics_service_1.publishDiagnosticsForUri)(this.ctx.server, doc.uri);
        }, (s) => this.transition(s), DidChangeCompleted);
    }
}
exports.DidChangeRunning = DidChangeRunning;
class DidChangeCompleted extends DidChangeTop {
    onEntry() {
        this.ctx.server.registry.remove(this.ctx.actorId);
    }
}
exports.DidChangeCompleted = DidChangeCompleted;
ihsm.InitialState(DidChangeReceived);
ihsm.registerStateNames({
    DidChangeReceived,
    DidChangeRunning,
    DidChangeCompleted,
});
function spawnDidChangeNotification(server, document) {
    const notificationId = server.registry.allocateId(METHOD);
    (0, notification_lifecycle_helpers_1.spawnNotificationHsm)(server, lsp_actor_type_ids_1.LSP_ACTOR_TYPE_IDS.textDocumentDidChange, METHOD, notificationId, DidChangeTop, { document });
}
//# sourceMappingURL=did-change-notification.hsm.js.map