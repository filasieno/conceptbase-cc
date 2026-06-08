"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.phaseFromStateName = phaseFromStateName;
function phaseFromStateName(stateName) {
    if (stateName === "Running")
        return "running";
    if (stateName === "Idle" || stateName === "Disabled")
        return "idle";
    if (stateName === "Stopping" || stateName === "ShuttingDown")
        return "stopping";
    if (stateName === "Starting")
        return "starting";
    if (stateName.startsWith("Installing"))
        return "installing";
    return "fault";
}
//# sourceMappingURL=server-notifier.js.map