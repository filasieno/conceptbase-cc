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
exports.InitializedCompleted = exports.InitializedRunning = exports.InitializedReceived = exports.InitializedTop = void 0;
exports.spawnInitializedNotification = spawnInitializedNotification;
const ihsm = __importStar(require("ihsm"));
const otel_1 = require("../../../shared/telemetry/otel");
const lsp_actor_type_ids_1 = require("../../registry/lsp-actor-type-ids");
const notification_lifecycle_helpers_1 = require("../_shared/notification-lifecycle.helpers");
const METHOD = "initialized";
class InitializedTop extends ihsm.TopState {
}
exports.InitializedTop = InitializedTop;
class InitializedReceived extends InitializedTop {
    onEntry() {
        this.postNow("start");
    }
    start() {
        this.transition(InitializedRunning);
    }
}
exports.InitializedReceived = InitializedReceived;
class InitializedRunning extends InitializedTop {
    onEntry() {
        this.postNow("run");
    }
    async run() {
        await (0, notification_lifecycle_helpers_1.runNotificationBody)(this.ctx.server, this.ctx.actorId, async () => {
            this.ctx.server.readiness.lspInitialized = true;
            (0, otel_1.otelLogger)("mmkit-lsp").emit({ severityText: "INFO", body: "LSP initialized" });
        }, (s) => this.transition(s), InitializedCompleted);
    }
}
exports.InitializedRunning = InitializedRunning;
class InitializedCompleted extends InitializedTop {
    onEntry() {
        this.ctx.server.registry.remove(this.ctx.actorId);
    }
}
exports.InitializedCompleted = InitializedCompleted;
ihsm.InitialState(InitializedReceived);
ihsm.registerStateNames({
    InitializedReceived,
    InitializedRunning,
    InitializedCompleted,
});
function spawnInitializedNotification(server) {
    const notificationId = server.registry.allocateId(METHOD);
    (0, notification_lifecycle_helpers_1.spawnNotificationHsm)(server, lsp_actor_type_ids_1.LSP_ACTOR_TYPE_IDS.initialized, METHOD, notificationId, InitializedTop, {});
}
//# sourceMappingURL=initialized-notification.hsm.js.map