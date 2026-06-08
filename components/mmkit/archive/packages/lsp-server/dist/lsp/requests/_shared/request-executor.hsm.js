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
exports.RequestCompleted = exports.RequestAwaitingAsync = exports.RequestRunning = exports.RequestReceived = exports.RequestExecutorTop = void 0;
exports.registerRequestExecutor = registerRequestExecutor;
const ihsm = __importStar(require("ihsm"));
const cancellable_request_deferred_1 = require("../../cancellation/cancellable-request-deferred");
const lsp_hsm_factory_1 = require("../../../lsp/lsp-hsm-factory");
const work_done_tracker_1 = require("../../progress/work-done-tracker");
const lsp_actor_ids_1 = require("../../registry/lsp-actor-ids");
const lsp_actor_type_ids_1 = require("../../registry/lsp-actor-type-ids");
class RequestExecutorTop extends ihsm.TopState {
    finishCancelled() {
        this.ctx.progressTracker?.end();
        this.ctx.server.registry.failRequest(this.ctx.requestId, new cancellable_request_deferred_1.CancelledLspRequestError(this.ctx.requestId));
        this.transition(RequestCompleted);
    }
    cancel() {
        if (this.ctx.deferred) {
            this.ctx.deferred.cancel();
            return;
        }
        this.finishCancelled();
    }
}
exports.RequestExecutorTop = RequestExecutorTop;
class RequestReceived extends RequestExecutorTop {
    onEntry() {
        this.postNow("start");
    }
    start() {
        this.transition(RequestRunning);
    }
}
exports.RequestReceived = RequestReceived;
class RequestRunning extends RequestExecutorTop {
    onEntry() {
        const tracker = new work_done_tracker_1.WorkDoneTracker(this.ctx.server.actuators, this.ctx.progressToken ?? this.ctx.requestId);
        this.ctx.progressTracker = tracker;
        tracker.begin(this.ctx.progressTitle, true);
        this.ctx.deferred = new cancellable_request_deferred_1.CancellableRequestDeferred(this.hsm, this.ctx.requestId, this.ctx.server.registry);
        void this.ctx.deferred.run((signal) => this.ctx.work(signal, this.ctx.server, this.ctx.params));
    }
    asyncStarted() {
        this.transition(RequestAwaitingAsync);
    }
}
exports.RequestRunning = RequestRunning;
class RequestAwaitingAsync extends RequestExecutorTop {
    resolved(result) {
        this.ctx.result = result;
        this.ctx.progressTracker?.report("Finishing", 95);
        if (this.ctx.server.registry.isCancelled(this.ctx.requestId)) {
            this.finishCancelled();
            return;
        }
        this.ctx.server.registry.completeRequest(this.ctx.requestId, result);
        this.ctx.progressTracker?.end();
        this.transition(RequestCompleted);
    }
    rejected(err) {
        this.ctx.server.actuators.consoleError(String(err));
        this.ctx.progressTracker?.end();
        this.ctx.server.registry.failRequest(this.ctx.requestId, err);
        this.transition(RequestCompleted);
    }
    cancelled() {
        this.finishCancelled();
    }
}
exports.RequestAwaitingAsync = RequestAwaitingAsync;
class RequestCompleted extends RequestExecutorTop {
    onEntry() {
        this.ctx.server.registry.remove(this.ctx.actorId);
    }
}
exports.RequestCompleted = RequestCompleted;
ihsm.InitialState(RequestReceived);
ihsm.registerStateNames({
    RequestReceived,
    RequestRunning,
    RequestAwaitingAsync,
    RequestCompleted,
});
function registerRequestExecutor(server, spec) {
    const actorId = (0, lsp_actor_ids_1.lspActorId)(spec.method, spec.requestId);
    const progressToken = spec.progressToken ?? spec.requestId;
    const ctx = {
        typeId: lsp_actor_type_ids_1.LSP_ACTOR_TYPE_IDS.requestExecutor,
        server,
        actorId,
        requestId: spec.requestId,
        progressToken,
        method: spec.method,
        params: spec.params,
        progressTitle: spec.progressTitle,
        work: spec.work,
    };
    const hsm = (0, lsp_hsm_factory_1.createLspHsm)(RequestExecutorTop, ctx);
    server.registry.register(actorId, lsp_actor_type_ids_1.LSP_ACTOR_TYPE_IDS.requestExecutor, hsm, spec.requestId);
    return hsm;
}
//# sourceMappingURL=request-executor.hsm.js.map