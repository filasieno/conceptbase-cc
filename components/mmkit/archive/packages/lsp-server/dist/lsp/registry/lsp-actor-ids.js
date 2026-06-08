"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.LSP_ACTOR_PREFIX = void 0;
exports.lspActorId = lspActorId;
/** Prefix for in-flight LSP request / notification actor ids. */
exports.LSP_ACTOR_PREFIX = "lsp";
function lspActorId(method, requestId) {
    const safeMethod = method.replace(/\//g, ".");
    return `${exports.LSP_ACTOR_PREFIX}.${safeMethod}.${String(requestId)}`;
}
//# sourceMappingURL=lsp-actor-ids.js.map