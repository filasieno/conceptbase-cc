"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.requireObject = requireObject;
exports.requireString = requireString;
exports.optionalString = optionalString;
exports.requireStringArray = requireStringArray;
exports.optionalPort = optionalPort;
exports.requirePort = requirePort;
exports.requireAskFormat = requireAskFormat;
exports.requireIdentifier = requireIdentifier;
const errors_1 = require("./errors");
const MAX_STRING = 64_000;
const MAX_ARRAY = 256;
const MAX_PORT = 65_535;
const CONTROL_CHARS = /[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F]/;
function requireObject(args, toolName) {
    if (args === null || args === undefined) {
        return {};
    }
    if (typeof args !== "object" || Array.isArray(args)) {
        throw new errors_1.McpValidationError(`${toolName}: arguments must be a JSON object`);
    }
    return args;
}
function requireString(args, field, opts = {}) {
    const raw = args[field];
    if (typeof raw !== "string") {
        throw new errors_1.McpValidationError(`missing or invalid string field: ${field}`, field);
    }
    if (CONTROL_CHARS.test(raw)) {
        throw new errors_1.McpValidationError(`field ${field} contains control characters`, field);
    }
    const max = opts.maxLength ?? MAX_STRING;
    if (raw.length > max) {
        throw new errors_1.McpValidationError(`field ${field} exceeds ${max} characters`, field);
    }
    if (!opts.allowEmpty && raw.trim().length === 0) {
        throw new errors_1.McpValidationError(`field ${field} must not be empty`, field);
    }
    if (opts.minLength !== undefined && raw.length < opts.minLength) {
        throw new errors_1.McpValidationError(`field ${field} shorter than ${opts.minLength}`, field);
    }
    return raw;
}
function optionalString(args, field, maxLength = MAX_STRING) {
    const raw = args[field];
    if (raw === undefined || raw === null)
        return undefined;
    return requireString(args, field, { maxLength, allowEmpty: false });
}
function requireStringArray(args, field) {
    const raw = args[field];
    if (!Array.isArray(raw)) {
        throw new errors_1.McpValidationError(`field ${field} must be a string array`, field);
    }
    if (raw.length > MAX_ARRAY) {
        throw new errors_1.McpValidationError(`field ${field} exceeds ${MAX_ARRAY} items`, field);
    }
    return raw.map((item, i) => {
        if (typeof item !== "string") {
            throw new errors_1.McpValidationError(`field ${field}[${i}] must be a string`, field);
        }
        if (CONTROL_CHARS.test(item)) {
            throw new errors_1.McpValidationError(`field ${field}[${i}] contains control characters`, field);
        }
        if (item.length > MAX_STRING) {
            throw new errors_1.McpValidationError(`field ${field}[${i}] too long`, field);
        }
        return item;
    });
}
function optionalPort(args, field) {
    const raw = args[field];
    if (raw === undefined || raw === null)
        return undefined;
    return requirePort(args, field);
}
function requirePort(args, field) {
    const raw = args[field];
    if (typeof raw !== "number" || !Number.isInteger(raw) || raw < 1 || raw > MAX_PORT) {
        throw new errors_1.McpValidationError(`field ${field} must be an integer port 1–${MAX_PORT}`, field);
    }
    return raw;
}
function requireAskFormat(value, field) {
    if (value !== "OBJNAMES" && value !== "FRAMES") {
        throw new errors_1.McpValidationError(`field ${field} must be OBJNAMES or FRAMES`, field);
    }
    return value;
}
function requireIdentifier(value, field) {
    if (!/^[A-Za-z][A-Za-z0-9_./-]*$/.test(value)) {
        throw new errors_1.McpValidationError(`field ${field} has invalid identifier characters`, field);
    }
    return value;
}
//# sourceMappingURL=validate-args.js.map