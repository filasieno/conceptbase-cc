"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.LspActorRegistry = void 0;
class LspActorRegistry {
    actors = new Map();
    byRequestId = new Map();
    completers = new Map();
    cancelled = new Set();
    seq = 0;
    allocateId(method) {
        this.seq += 1;
        return `${method}#${this.seq}`;
    }
    register(actorId, typeId, hsm, requestId) {
        this.actors.set(actorId, { typeId, hsm });
        if (requestId !== undefined) {
            this.byRequestId.set(requestId, actorId);
        }
    }
    /** Untyped peek — prefer {@link cast} for typed extraction. */
    get(actorId) {
        return this.actors.get(actorId);
    }
    /** Typed extraction — returns undefined when actorId is missing or typeId mismatches. */
    cast(actorId, typeId) {
        const entry = this.actors.get(actorId);
        if (!entry || entry.typeId !== typeId) {
            return undefined;
        }
        return entry;
    }
    post(actorId, event, ...payload) {
        const entry = this.actors.get(actorId);
        if (!entry)
            return;
        entry.hsm.post(event, ...payload);
    }
    registerCompleter(requestId, completer) {
        this.completers.set(requestId, completer);
    }
    completeRequest(requestId, result) {
        const completer = this.completers.get(requestId);
        this.completers.delete(requestId);
        completer?.resolve(result);
    }
    failRequest(requestId, error) {
        const completer = this.completers.get(requestId);
        this.completers.delete(requestId);
        completer?.reject(error);
    }
    cancel(requestId) {
        if (this.cancelled.has(requestId))
            return;
        this.cancelled.add(requestId);
        const actorId = this.byRequestId.get(requestId);
        if (actorId) {
            this.post(actorId, "cancel");
        }
    }
    isCancelled(requestId) {
        return this.cancelled.has(requestId);
    }
    clearCancellation(requestId) {
        this.cancelled.delete(requestId);
    }
    remove(actorId) {
        this.actors.delete(actorId);
        for (const [requestId, id] of this.byRequestId) {
            if (id === actorId) {
                this.byRequestId.delete(requestId);
                this.cancelled.delete(requestId);
                this.completers.delete(requestId);
                break;
            }
        }
    }
    async sync(actorId) {
        await this.actors.get(actorId)?.hsm.sync();
    }
    size() {
        return this.actors.size;
    }
    ids() {
        return [...this.actors.keys()];
    }
}
exports.LspActorRegistry = LspActorRegistry;
//# sourceMappingURL=lsp-actor-registry.js.map