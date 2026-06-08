"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.WorkDoneTracker = void 0;
/** Tracks a single work-done progress token lifecycle on actuators. */
class WorkDoneTracker {
    actuators;
    token;
    open = false;
    constructor(actuators, token) {
        this.actuators = actuators;
        this.token = token;
    }
    begin(title, cancellable = false) {
        if (this.open)
            return;
        this.open = true;
        this.actuators.beginWorkDone(this.token, title, cancellable);
    }
    report(message, percentage) {
        if (!this.open)
            return;
        this.actuators.reportWorkDone(this.token, message, percentage);
    }
    end() {
        if (!this.open)
            return;
        this.actuators.endWorkDone(this.token);
        this.open = false;
    }
}
exports.WorkDoneTracker = WorkDoneTracker;
//# sourceMappingURL=work-done-tracker.js.map