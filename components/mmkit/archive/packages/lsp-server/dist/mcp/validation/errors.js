"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.McpValidationError = void 0;
exports.validationError = validationError;
class McpValidationError extends Error {
    field;
    issues;
    constructor(message, field, issues) {
        super(message);
        this.field = field;
        this.issues = issues;
        this.name = "McpValidationError";
    }
}
exports.McpValidationError = McpValidationError;
function validationError(message, field) {
    throw new McpValidationError(message, field);
}
//# sourceMappingURL=errors.js.map