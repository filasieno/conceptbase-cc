"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.startLspTcp = exports.startLspStdio = exports.bindLspServer = void 0;
/* Transport entrypoints — logic lives in router/ + requests/ */
var lsp_router_1 = require("./router/lsp-router");
Object.defineProperty(exports, "bindLspServer", { enumerable: true, get: function () { return lsp_router_1.bindLspServer; } });
Object.defineProperty(exports, "startLspStdio", { enumerable: true, get: function () { return lsp_router_1.startLspStdio; } });
Object.defineProperty(exports, "startLspTcp", { enumerable: true, get: function () { return lsp_router_1.startLspTcp; } });
//# sourceMappingURL=lsp-app.js.map