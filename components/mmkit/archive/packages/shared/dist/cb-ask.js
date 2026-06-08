"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.CONNECTION_TEST_ASK_QUERY = void 0;
exports.buildAskPayload = buildAskPayload;
exports.isExistsClassYes = isExistsClassYes;
const cb_tcp_1 = require("./cb-tcp");
/** Builtin query — `Class` exists in every fresh cbserver database. */
exports.CONNECTION_TEST_ASK_QUERY = "exists[Class/objname]";
/** ASK ipc payload: Format, Query, AnswerRep, RollbackTime (Format is unencoded). */
function buildAskPayload(query, askFormat = "OBJNAMES", answerRep = "LABEL", rollbackTime = "Now") {
    return `${askFormat},${(0, cb_tcp_1.encodeCbString)(query)},${(0, cb_tcp_1.encodeCbString)(answerRep)},${(0, cb_tcp_1.encodeCbString)(rollbackTime)}`;
}
/** True when a LABEL answer to `exists[Class/objname]` indicates success. */
function isExistsClassYes(reply) {
    if (!reply)
        return false;
    const normalized = reply.trim().toLowerCase();
    return normalized === "yes" || normalized.includes('"yes"');
}
//# sourceMappingURL=cb-ask.js.map