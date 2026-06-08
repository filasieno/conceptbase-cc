"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.mapActorStateToPhase = mapActorStateToPhase;
function mapActorStateToPhase(stateName) {
    if (stateName === "Running")
        return "running";
    if (stateName === "Idle")
        return "idle";
    if (stateName === "Stopping" || stateName === "ShuttingDown")
        return "stopping";
    if (stateName === "Starting")
        return "starting";
    if (stateName.startsWith("Installing"))
        return "installing";
    return "fault";
}
//# sourceMappingURL=server-supervisor-state.js.map