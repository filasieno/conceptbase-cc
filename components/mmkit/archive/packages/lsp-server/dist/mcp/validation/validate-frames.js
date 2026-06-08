"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.requireValidFrames = requireValidFrames;
exports.requireValidFramePair = requireValidFramePair;
const validate_conceptbase_text_1 = require("../../lsp/validate-conceptbase-text");
const errors_1 = require("./errors");
const validate_args_1 = require("./validate-args");
/** Validate frame-bearing MCP arguments with tree-sitter when available. */
async function requireValidFrames(args, field) {
    const text = (0, validate_args_1.requireString)(args, field, { allowEmpty: false });
    const result = await (0, validate_conceptbase_text_1.validateConceptBaseText)(text);
    if (!result.ok) {
        const detail = result.issues.map((i) => i.message).join("; ");
        throw new errors_1.McpValidationError(`invalid ConceptBase ${field}: ${detail}`, field, result.issues.map((i) => i.message));
    }
    return text;
}
async function requireValidFramePair(args, untellField, tellField) {
    return {
        untellFrames: await requireValidFrames(args, untellField),
        tellFrames: await requireValidFrames(args, tellField),
    };
}
//# sourceMappingURL=validate-frames.js.map