"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.bindRequestCompleter = bindRequestCompleter;
exports.beginRequestProgress = beginRequestProgress;
exports.createRequestDeferred = createRequestDeferred;
exports.finishCancelled = finishCancelled;
exports.completeRequestSuccess = completeRequestSuccess;
exports.failRequestError = failRequestError;
exports.cancelInFlight = cancelInFlight;
const cancellable_request_deferred_1 = require("../../cancellation/cancellable-request-deferred");
const work_done_tracker_1 = require("../../progress/work-done-tracker");
function bindRequestCompleter(registry, requestId, cancelToken) {
    return new Promise((resolve, reject) => {
        registry.registerCompleter(requestId, { resolve, reject });
        if (cancelToken) {
            cancelToken.onCancellationRequested(() => registry.cancel(requestId));
        }
    });
}
function beginRequestProgress(actuators, requestId, title) {
    const tracker = new work_done_tracker_1.WorkDoneTracker(actuators, requestId);
    tracker.begin(title, true);
    return tracker;
}
function createRequestDeferred(owner, requestId, registry) {
    return new cancellable_request_deferred_1.CancellableRequestDeferred(owner, requestId, registry);
}
function finishCancelled(registry, requestId, tracker, transition, completedState) {
    tracker?.end();
    registry.failRequest(requestId, new cancellable_request_deferred_1.CancelledLspRequestError(requestId));
    transition(completedState);
}
function completeRequestSuccess(registry, requestId, tracker, result, transition, completedState) {
    if (registry.isCancelled(requestId)) {
        finishCancelled(registry, requestId, tracker, transition, completedState);
        return;
    }
    tracker?.report("Finishing", 95);
    registry.completeRequest(requestId, result);
    tracker?.end();
    transition(completedState);
}
function failRequestError(registry, requestId, tracker, actuators, err, transition, completedState) {
    actuators.consoleError(String(err));
    tracker?.end();
    registry.failRequest(requestId, err);
    transition(completedState);
}
function cancelInFlight(deferred, registry, requestId, tracker, transition, completedState) {
    if (deferred) {
        deferred.cancel();
        return;
    }
    finishCancelled(registry, requestId, tracker, transition, completedState);
}
//# sourceMappingURL=request-lifecycle.helpers.js.map