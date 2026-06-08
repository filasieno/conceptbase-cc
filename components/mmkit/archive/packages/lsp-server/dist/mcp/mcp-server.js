"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.MCP_CB_TOOL_NAMES = void 0;
exports.createMmkitMcpServer = createMmkitMcpServer;
const server_1 = require("@modelcontextprotocol/server");
const register_cb_tools_1 = require("./register-cb-tools");
var mcp_tool_names_1 = require("./mcp-tool-names");
Object.defineProperty(exports, "MCP_CB_TOOL_NAMES", { enumerable: true, get: function () { return mcp_tool_names_1.MCP_CB_TOOL_NAMES; } });
function createMmkitMcpServer(supervisor) {
    const server = new server_1.McpServer({
        name: "mmkit",
        version: "0.2.0",
    });
    new register_cb_tools_1.CBToolRegistry(supervisor).register(server);
    return server;
}
//# sourceMappingURL=mcp-server.js.map