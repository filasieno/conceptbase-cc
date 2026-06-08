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
exports.WillSaveWaitUntilCompleted = exports.WillSaveWaitUntilRunning = exports.WillSaveWaitUntilReceived = exports.WillSaveWaitUntilTop = void 0;
exports.runWillSaveWaitUntilRequest = runWillSaveWaitUntilRequest;
const ihsm = __importStar(require("ihsm"));
const lsp_hsm_factory_1 = require("../../../lsp/lsp-hsm-factory");
const lsp_actor_ids_1 = require("../../registry/lsp-actor-ids");
const lsp_actor_type_ids_1 = require("../../registry/lsp-actor-type-ids");
const METHOD = "textDocument/willSaveWaitUntil";
class WillSaveWaitUntilTop extends ihsm.TopState {
}
exports.WillSaveWaitUntilTop = WillSaveWaitUntilTop;
class WillSaveWaitUntilReceived extends WillSaveWaitUntilTop {
    onEntry() {
        this.postNow("start");
    }
    start() {
        this.transition(WillSaveWaitUntilRunning);
    }
}
exports.WillSaveWaitUntilReceived = WillSaveWaitUntilReceived;
class WillSaveWaitUntilRunning extends WillSaveWaitUntilTop {
    onEntry() {
        this.postNow("resolveEdits");
    }
    resolveEdits() {
        // No pre-save formatting yet; empty edits keeps the buffer as-is.
        this.ctx.result = [];
        this.transition(WillSaveWaitUntilCompleted);
    }
}
exports.WillSaveWaitUntilRunning = WillSaveWaitUntilRunning;
class WillSaveWaitUntilCompleted extends WillSaveWaitUntilTop {
    onEntry() {
        this.ctx.server.registry.remove(this.ctx.actorId);
    }
}
exports.WillSaveWaitUntilCompleted = WillSaveWaitUntilCompleted;
ihsm.InitialState(WillSaveWaitUntilReceived);
ihsm.registerStateNames({
    WillSaveWaitUntilReceived,
    WillSaveWaitUntilRunning,
    WillSaveWaitUntilCompleted,
});
async function runWillSaveWaitUntilRequest(server, event) {
    const requestId = server.registry.allocateId(METHOD);
    const actorId = (0, lsp_actor_ids_1.lspActorId)(METHOD, requestId);
    const ctx = {
        typeId: lsp_actor_type_ids_1.LSP_ACTOR_TYPE_IDS.textDocumentWillSaveWaitUntil,
        server,
        actorId,
        requestId,
        event,
    };
    const hsm = (0, lsp_hsm_factory_1.createLspHsm)(WillSaveWaitUntilTop, ctx);
    server.registry.register(actorId, lsp_actor_type_ids_1.LSP_ACTOR_TYPE_IDS.textDocumentWillSaveWaitUntil, hsm, requestId);
    await hsm.sync();
    return ctx.result ?? [];
}
//# sourceMappingURL=will-save-wait-until-request.hsm.js.map