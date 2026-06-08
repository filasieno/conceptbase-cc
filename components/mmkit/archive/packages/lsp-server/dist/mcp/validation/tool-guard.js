"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.jsonText = jsonText;
exports.validationResponse = validationResponse;
exports.guardedTool = guardedTool;
const errors_1 = require("./errors");
function jsonText(value) {
    return { content: [{ type: "text", text: JSON.stringify(value, null, 2) }] };
}
function validationResponse(err) {
    return {
        content: [
            {
                type: "text",
                text: JSON.stringify({ ok: false, error: "validation_failed", message: err.message, field: err.field, issues: err.issues }, null, 2),
            },
        ],
        isError: true,
    };
}
function wrapError(toolName, err) {
    if (err instanceof errors_1.McpValidationError)
        return validationResponse(err);
    const message = err instanceof Error ? err.message : String(err);
    return {
        content: [{ type: "text", text: JSON.stringify({ ok: false, error: "tool_failed", tool: toolName, message }, null, 2) }],
        isError: true,
    };
}
/**
 * Wraps a tool's `run` callback: JSON-encodes the result on success, and on any
 * throw converts `McpValidationError` → `validation_failed` and everything else
 * → `tool_failed`. Used by the declarative registration loop in
 * `register-cb-tools.ts`, so individual tool entries stay pure logic.
 */
async function guardedTool(toolName, run) {
    try {
        return jsonText(await run());
    }
    catch (err) {
        return wrapError(toolName, err);
    }
}
//# sourceMappingURL=tool-guard.js.map