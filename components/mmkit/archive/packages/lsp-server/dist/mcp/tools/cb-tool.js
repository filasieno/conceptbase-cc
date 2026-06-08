"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.MCPTool = MCPTool;
exports.allCBTools = allCBTools;
const REGISTERED_TOOLS = [];
/**
 * Registers one ConceptBase MCP tool into the global catalog — no manual
 * `ALL_CB_TOOLS` array to keep in sync. The metadata lives alongside the
 * routine, so the routine is just a plain function:
 *
 * ```ts
 * MCPTool(
 *   { name: "cb_tell", title: "Tell frames", description: "…" },
 *   async (ctx, raw) => (await ctx.client()).tell(await requireValidFrames(raw, "frames")),
 * );
 * ```
 *
 * Registration order follows call order within the module. The module must be
 * imported (even for side effects) for the tools to appear; see
 * `register-cb-tools.ts`.
 */
function MCPTool(meta, exec) {
    REGISTERED_TOOLS.push({ ...meta, exec });
}
/** Every registered tool, in call order. */
function allCBTools() {
    return REGISTERED_TOOLS;
}
//# sourceMappingURL=cb-tool.js.map