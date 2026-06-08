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
exports.SemanticTokensFullCompleted = exports.SemanticTokensFullAwaitingAsync = exports.SemanticTokensFullRunning = exports.SemanticTokensFullReceived = exports.SemanticTokensFullTop = void 0;
exports.runSemanticTokensFullRequest = runSemanticTokensFullRequest;
const ihsm = __importStar(require("ihsm"));
const lsp_hsm_factory_1 = require("../../../lsp/lsp-hsm-factory");
const lsp_actor_ids_1 = require("../../registry/lsp-actor-ids");
const lsp_actor_type_ids_1 = require("../../registry/lsp-actor-type-ids");
const provider_1 = require("../../semantic-tokens/provider");
const request_lifecycle_helpers_1 = require("../_shared/request-lifecycle.helpers");
const METHOD = "textDocument/semanticTokens/full";
const PROGRESS_TITLE = "Semantic tokens (full)";
class SemanticTokensFullTop extends ihsm.TopState {
    finishCancelled() {
        (0, request_lifecycle_helpers_1.finishCancelled)(this.ctx.server.registry, this.ctx.requestId, this.ctx.progressTracker, (s) => this.transition(s), SemanticTokensFullCompleted);
    }
    cancel() {
        (0, request_lifecycle_helpers_1.cancelInFlight)(this.ctx.deferred, this.ctx.server.registry, this.ctx.requestId, this.ctx.progressTracker, (s) => this.transition(s), SemanticTokensFullCompleted);
    }
}
exports.SemanticTokensFullTop = SemanticTokensFullTop;
class SemanticTokensFullReceived extends SemanticTokensFullTop {
    onEntry() {
        this.postNow("start");
    }
    start() {
        this.transition(SemanticTokensFullRunning);
    }
}
exports.SemanticTokensFullReceived = SemanticTokensFullReceived;
class SemanticTokensFullRunning extends SemanticTokensFullTop {
    onEntry() {
        this.ctx.progressTracker = (0, request_lifecycle_helpers_1.beginRequestProgress)(this.ctx.server.actuators, this.ctx.requestId, PROGRESS_TITLE);
        this.ctx.deferred = (0, request_lifecycle_helpers_1.createRequestDeferred)(this.hsm, this.ctx.requestId, this.ctx.server.registry);
        this.postNow("collect");
    }
    collect() {
        this.ctx.progressTracker?.report("Collecting tokens", 40);
        void this.ctx.deferred.run(async (signal) => {
            if (signal.aborted)
                throw new Error("cancelled");
            const tokens = await (0, provider_1.provideSemanticTokensFull)(this.ctx.server.documentRegistry, this.ctx.params.textDocument.uri);
            if (signal.aborted)
                throw new Error("cancelled");
            this.ctx.progressTracker?.report("Encoding", 85);
            return tokens;
        });
    }
    asyncStarted() {
        this.transition(SemanticTokensFullAwaitingAsync);
    }
}
exports.SemanticTokensFullRunning = SemanticTokensFullRunning;
class SemanticTokensFullAwaitingAsync extends SemanticTokensFullTop {
    resolved(result) {
        (0, request_lifecycle_helpers_1.completeRequestSuccess)(this.ctx.server.registry, this.ctx.requestId, this.ctx.progressTracker, result, (s) => this.transition(s), SemanticTokensFullCompleted);
    }
    rejected(err) {
        (0, request_lifecycle_helpers_1.failRequestError)(this.ctx.server.registry, this.ctx.requestId, this.ctx.progressTracker, this.ctx.server.actuators, err, (s) => this.transition(s), SemanticTokensFullCompleted);
    }
    cancelled() {
        this.finishCancelled();
    }
}
exports.SemanticTokensFullAwaitingAsync = SemanticTokensFullAwaitingAsync;
class SemanticTokensFullCompleted extends SemanticTokensFullTop {
    onEntry() {
        this.ctx.server.registry.remove(this.ctx.actorId);
    }
}
exports.SemanticTokensFullCompleted = SemanticTokensFullCompleted;
ihsm.InitialState(SemanticTokensFullReceived);
ihsm.registerStateNames({
    SemanticTokensFullReceived,
    SemanticTokensFullRunning,
    SemanticTokensFullAwaitingAsync,
    SemanticTokensFullCompleted,
});
function runSemanticTokensFullRequest(server, params, cancelToken) {
    const requestId = server.registry.allocateId(METHOD);
    const actorId = (0, lsp_actor_ids_1.lspActorId)(METHOD, requestId);
    const resultPromise = (0, request_lifecycle_helpers_1.bindRequestCompleter)(server.registry, requestId, cancelToken);
    const ctx = {
        typeId: lsp_actor_type_ids_1.LSP_ACTOR_TYPE_IDS.semanticTokensFull,
        server,
        actorId,
        requestId,
        params,
    };
    const hsm = (0, lsp_hsm_factory_1.createLspHsm)(SemanticTokensFullTop, ctx);
    server.registry.register(actorId, lsp_actor_type_ids_1.LSP_ACTOR_TYPE_IDS.semanticTokensFull, hsm, requestId);
    return resultPromise;
}
//# sourceMappingURL=full-request.hsm.js.map