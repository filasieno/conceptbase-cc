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
exports.NotificationCompleted = exports.NotificationRunning = exports.NotificationReceived = exports.NotificationExecutorTop = void 0;
exports.registerNotificationExecutor = registerNotificationExecutor;
const ihsm = __importStar(require("ihsm"));
const lsp_hsm_factory_1 = require("../../../lsp/lsp-hsm-factory");
const lsp_actor_ids_1 = require("../../registry/lsp-actor-ids");
const lsp_actor_type_ids_1 = require("../../registry/lsp-actor-type-ids");
class NotificationExecutorTop extends ihsm.TopState {
}
exports.NotificationExecutorTop = NotificationExecutorTop;
class NotificationReceived extends NotificationExecutorTop {
    onEntry() {
        this.postNow("start");
    }
    start() {
        this.transition(NotificationRunning);
    }
}
exports.NotificationReceived = NotificationReceived;
class NotificationRunning extends NotificationExecutorTop {
    onEntry() {
        this.postNow("run");
    }
    async run() {
        try {
            await this.ctx.work(this.ctx.server, this.ctx.params);
            this.transition(NotificationCompleted);
        }
        catch (err) {
            this.ctx.server.actuators.consoleError(String(err));
            this.transition(NotificationCompleted);
        }
    }
}
exports.NotificationRunning = NotificationRunning;
class NotificationCompleted extends NotificationExecutorTop {
    onEntry() {
        this.ctx.server.registry.remove(this.ctx.actorId);
    }
}
exports.NotificationCompleted = NotificationCompleted;
ihsm.InitialState(NotificationReceived);
ihsm.registerStateNames({
    NotificationReceived,
    NotificationRunning,
    NotificationCompleted,
});
function registerNotificationExecutor(server, spec) {
    const actorId = (0, lsp_actor_ids_1.lspActorId)(spec.method, spec.notificationId);
    const ctx = {
        typeId: lsp_actor_type_ids_1.LSP_ACTOR_TYPE_IDS.notificationExecutor,
        server,
        actorId,
        requestId: spec.notificationId,
        progressToken: spec.notificationId,
        method: spec.method,
        params: spec.params,
        work: spec.work,
    };
    const hsm = (0, lsp_hsm_factory_1.createLspHsm)(NotificationExecutorTop, ctx);
    server.registry.register(actorId, lsp_actor_type_ids_1.LSP_ACTOR_TYPE_IDS.notificationExecutor, hsm, spec.notificationId);
    return hsm;
}
//# sourceMappingURL=notification-executor.hsm.js.map