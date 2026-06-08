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
exports.InitializeCompleted = exports.InitializeRunning = exports.InitializeReceived = exports.InitializeTop = void 0;
exports.runInitializeRequest = runInitializeRequest;
const ihsm = __importStar(require("ihsm"));
const api_1 = require("@opentelemetry/api");
const node_1 = require("vscode-languageserver/node");
const capabilities_1 = require("../../capabilities");
const lsp_hsm_factory_1 = require("../../../lsp/lsp-hsm-factory");
const otel_1 = require("../../../shared/telemetry/otel");
const lsp_actor_ids_1 = require("../../registry/lsp-actor-ids");
const lsp_actor_type_ids_1 = require("../../registry/lsp-actor-type-ids");
const tracer = api_1.trace.getTracer("mmkit-lsp");
class InitializeTop extends ihsm.TopState {
}
exports.InitializeTop = InitializeTop;
class InitializeReceived extends InitializeTop {
    onEntry() {
        this.postNow("start");
    }
    start() {
        this.transition(InitializeRunning);
    }
}
exports.InitializeReceived = InitializeReceived;
class InitializeRunning extends InitializeTop {
    onEntry() {
        this.postNow("validateClient");
    }
    validateClient() {
        const log = (0, otel_1.otelLogger)("mmkit-lsp");
        tracer.startActiveSpan("lsp.initialize", (span) => {
            const textDocumentCaps = this.ctx.params.capabilities.textDocument;
            const clientSync = textDocumentCaps?.sync;
            const changeKind = typeof clientSync === "object" && clientSync !== null ? clientSync.change : clientSync;
            if (changeKind !== undefined && changeKind !== node_1.TextDocumentSyncKind.Incremental) {
                const msg = `conceptbase-lsp: client must use incremental sync (got ${String(changeKind)})`;
                this.ctx.server.actuators.consoleError(msg);
                log.emit({ severityText: "ERROR", body: msg });
            }
            span.setAttribute("client.incremental_sync", changeKind === node_1.TextDocumentSyncKind.Incremental);
            span.end();
        });
        this.postNow("buildResult");
    }
    buildResult() {
        this.ctx.server.metrics.lspInitialized.inc();
        this.ctx.bindOptions.readiness.lspInitialized = true;
        this.ctx.result = {
            capabilities: (0, capabilities_1.buildServerCapabilities)({
                serverControl: true,
                otel: true,
                mcpHttpPort: Number(process.env.MMKIT_HTTP_PORT ?? "28080"),
            }),
        };
        this.transition(InitializeCompleted);
    }
}
exports.InitializeRunning = InitializeRunning;
class InitializeCompleted extends InitializeTop {
    onEntry() {
        this.ctx.server.registry.remove(this.ctx.actorId);
    }
}
exports.InitializeCompleted = InitializeCompleted;
ihsm.InitialState(InitializeReceived);
ihsm.registerStateNames({
    InitializeReceived,
    InitializeRunning,
    InitializeCompleted,
});
async function runInitializeRequest(server, params, bindOptions) {
    const requestId = server.registry.allocateId("initialize");
    const actorId = (0, lsp_actor_ids_1.lspActorId)("initialize", requestId);
    const ctx = {
        typeId: lsp_actor_type_ids_1.LSP_ACTOR_TYPE_IDS.initialize,
        server,
        bindOptions,
        actorId,
        requestId,
        params,
    };
    const hsm = (0, lsp_hsm_factory_1.createLspHsm)(InitializeTop, ctx);
    server.registry.register(actorId, lsp_actor_type_ids_1.LSP_ACTOR_TYPE_IDS.initialize, hsm, requestId);
    await hsm.sync();
    if (!ctx.result) {
        throw new Error("initialize HSM did not produce a result");
    }
    return ctx.result;
}
//# sourceMappingURL=initialize-request.hsm.js.map