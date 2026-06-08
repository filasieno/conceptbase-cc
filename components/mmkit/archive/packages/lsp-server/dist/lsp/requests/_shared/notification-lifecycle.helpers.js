"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.spawnNotificationHsm = spawnNotificationHsm;
exports.completeNotification = completeNotification;
exports.runNotificationBody = runNotificationBody;
const lsp_hsm_factory_1 = require("../../../lsp/lsp-hsm-factory");
const lsp_actor_ids_1 = require("../../registry/lsp-actor-ids");
function spawnNotificationHsm(server, typeId, method, notificationId, topState, ctx) {
    const actorId = (0, lsp_actor_ids_1.lspActorId)(method, notificationId);
    const fullCtx = {
        typeId,
        ...ctx,
        server,
        actorId,
        requestId: notificationId,
    };
    const hsm = (0, lsp_hsm_factory_1.createLspHsm)(topState, fullCtx);
    server.registry.register(actorId, typeId, hsm, notificationId);
    return hsm;
}
function completeNotification(server, actorId, transition, completedState) {
    transition(completedState);
}
async function runNotificationBody(server, actorId, body, transition, completedState) {
    try {
        await body();
        completeNotification(server, actorId, transition, completedState);
    }
    catch (err) {
        server.actuators.consoleError(String(err));
        completeNotification(server, actorId, transition, completedState);
    }
}
//# sourceMappingURL=notification-lifecycle.helpers.js.map