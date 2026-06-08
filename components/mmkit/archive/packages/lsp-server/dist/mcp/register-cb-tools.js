"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.CBToolRegistry = void 0;
const cb_session_1 = require("./cb-session");
const validate_args_1 = require("./validation/validate-args");
const tool_guard_1 = require("./validation/tool-guard");
const cb_tool_1 = require("./tools/cb-tool");
// Side-effect import: loading the module runs every `MCPTool()` registration,
// which populates the catalog read by `allCBTools()`.
require("./tools/cb-tools");
/**
 * Registers all ConceptBase MCP tools on `server`.
 *
 * Each tool is registered via `MCPTool()` in `tools/cb-tools.ts`. This class
 * owns the shared context (`supervisor`, `session`, lazy `client()`) and the
 * single registration loop: for every tool it parses + validates `raw`, runs
 * `exec`, and wraps the result via `guardedTool` (JSON encode on success,
 * `validation_failed` / `tool_failed` on throw).
 */
class CBToolRegistry {
    ctx;
    constructor(supervisor) {
        const session = new cb_session_1.CbMcpSession(supervisor);
        this.ctx = { supervisor, session, client: () => session.getClient() };
    }
    register(server) {
        for (const tool of (0, cb_tool_1.allCBTools)()) {
            server.registerTool(tool.name, { title: tool.title, description: tool.description }, (raw) => (0, tool_guard_1.guardedTool)(tool.name, () => tool.exec(this.ctx, (0, validate_args_1.requireObject)(raw, tool.name))));
        }
    }
}
exports.CBToolRegistry = CBToolRegistry;
//# sourceMappingURL=register-cb-tools.js.map