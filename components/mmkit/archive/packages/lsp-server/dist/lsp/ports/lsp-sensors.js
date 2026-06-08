"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createLspSensors = createLspSensors;
function createLspSensors() {
    const listeners = new Set();
    return {
        onCancel(listener) {
            listeners.add(listener);
            return () => listeners.delete(listener);
        },
        emitCancel(requestId) {
            for (const listener of listeners)
                listener(requestId);
        },
    };
}
//# sourceMappingURL=lsp-sensors.js.map