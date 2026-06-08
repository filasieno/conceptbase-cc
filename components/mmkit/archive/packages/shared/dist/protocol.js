"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.MMKIT_LSP_METHODS = void 0;
/** LSP custom request method names (IDE control only — not MCP). */
exports.MMKIT_LSP_METHODS = {
    serverStart: "mmkit/server/start",
    serverStop: "mmkit/server/stop",
    serverRestart: "mmkit/server/restart",
    serverStatus: "mmkit/server/status",
    configUpdate: "mmkit/config/update",
    otelTest: "mmkit/otel/test",
    serverStateNotification: "mmkit/server/state",
};
//# sourceMappingURL=protocol.js.map