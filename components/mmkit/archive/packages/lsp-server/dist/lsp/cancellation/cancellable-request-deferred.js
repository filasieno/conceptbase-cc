"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.CancellableRequestDeferred = exports.CancelledLspRequestError = void 0;
class CancelledLspRequestError extends Error {
    constructor(requestId) {
        super(`LSP request ${String(requestId)} cancelled`);
        this.name = "CancelledLspRequestError";
    }
}
exports.CancelledLspRequestError = CancelledLspRequestError;
/**
 * Promise-like async bridge for cancellable LSP request replies.
 * Posts `asyncStarted` when constructed so the owning HSM enters `AwaitingAsync`.
 */
class CancellableRequestDeferred {
    owner;
    requestId;
    registry;
    abortController = new AbortController();
    constructor(owner, requestId, registry) {
        this.owner = owner;
        this.requestId = requestId;
        this.registry = registry;
        owner.post("asyncStarted");
    }
    get signal() {
        return this.abortController.signal;
    }
    cancel() {
        this.abortController.abort();
    }
    async run(factory) {
        try {
            const value = await factory(this.abortController.signal);
            if (this.registry.isCancelled(this.requestId) || this.abortController.signal.aborted) {
                this.owner.post("cancelled");
                return;
            }
            this.owner.post("resolved", value);
        }
        catch (err) {
            if (this.registry.isCancelled(this.requestId) || this.abortController.signal.aborted) {
                this.owner.post("cancelled");
                return;
            }
            this.owner.post("rejected", err);
        }
    }
}
exports.CancellableRequestDeferred = CancellableRequestDeferred;
//# sourceMappingURL=cancellable-request-deferred.js.map