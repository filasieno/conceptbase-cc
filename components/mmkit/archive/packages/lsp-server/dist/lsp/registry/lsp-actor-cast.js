"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.castLspActor = castLspActor;
exports.castLspActorHsm = castLspActorHsm;
/** Typed registry extraction — the only supported way to narrow a stored actor. */
function castLspActor(registry, actorId, typeId) {
    return registry.cast(actorId, typeId);
}
function castLspActorHsm(registry, actorId, typeId) {
    return registry.cast(actorId, typeId)?.hsm;
}
//# sourceMappingURL=lsp-actor-cast.js.map