"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.INSTALL_PROGRESS_RANGES = void 0;
exports.percentWithinStep = percentWithinStep;
exports.INSTALL_PROGRESS_RANGES = {
    prepare: { start: 0, end: 15 },
    materialize: { start: 15, end: 40 },
    dockerImage: { start: 40, end: 65 },
    launch: { start: 65, end: 80 },
    awaitPort: { start: 80, end: 99 },
};
function percentWithinStep(step, fraction) {
    const { start, end } = exports.INSTALL_PROGRESS_RANGES[step];
    const clamped = Math.min(1, Math.max(0, fraction));
    return Math.round(start + (end - start) * clamped);
}
//# sourceMappingURL=progress.js.map