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
exports.WillSaveCompleted = exports.WillSaveRunning = exports.WillSaveReceived = exports.WillSaveTop = void 0;
exports.spawnWillSaveNotification = spawnWillSaveNotification;
const ihsm = __importStar(require("ihsm"));
const node_1 = require("vscode-languageserver/node");
const lsp_actor_type_ids_1 = require("../../registry/lsp-actor-type-ids");
const notification_lifecycle_helpers_1 = require("../_shared/notification-lifecycle.helpers");
const METHOD = "textDocument/willSave";
class WillSaveTop extends ihsm.TopState {
}
exports.WillSaveTop = WillSaveTop;
class WillSaveReceived extends WillSaveTop {
    onEntry() {
        this.postNow("start");
    }
    start() {
        this.transition(WillSaveRunning);
    }
}
exports.WillSaveReceived = WillSaveReceived;
class WillSaveRunning extends WillSaveTop {
    onEntry() {
        this.postNow("run");
    }
    async run() {
        await (0, notification_lifecycle_helpers_1.runNotificationBody)(this.ctx.server, this.ctx.actorId, async () => {
            const { document, reason } = this.ctx.event;
            this.ctx.server.actuators.logMessage(node_1.MessageType.Log, `will save ${document.uri} (reason=${String(reason)})`);
        }, (s) => this.transition(s), WillSaveCompleted);
    }
}
exports.WillSaveRunning = WillSaveRunning;
class WillSaveCompleted extends WillSaveTop {
    onEntry() {
        this.ctx.server.registry.remove(this.ctx.actorId);
    }
}
exports.WillSaveCompleted = WillSaveCompleted;
ihsm.InitialState(WillSaveReceived);
ihsm.registerStateNames({
    WillSaveReceived,
    WillSaveRunning,
    WillSaveCompleted,
});
function spawnWillSaveNotification(server, event) {
    const notificationId = server.registry.allocateId(METHOD);
    (0, notification_lifecycle_helpers_1.spawnNotificationHsm)(server, lsp_actor_type_ids_1.LSP_ACTOR_TYPE_IDS.textDocumentWillSave, METHOD, notificationId, WillSaveTop, { event });
}
//# sourceMappingURL=will-save-notification.hsm.js.map