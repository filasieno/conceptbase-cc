"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.CustomHandlerRegistry = void 0;
class CustomHandlerRegistry {
    handlers = new Map();
    register(method, handler) {
        this.handlers.set(method, handler);
    }
    has(method) {
        return this.handlers.has(method);
    }
    async dispatch(method, params) {
        const handler = this.handlers.get(method);
        if (!handler) {
            throw new Error(`no handler for ${method}`);
        }
        return handler(params);
    }
}
exports.CustomHandlerRegistry = CustomHandlerRegistry;
//# sourceMappingURL=custom-handler-registry.js.map