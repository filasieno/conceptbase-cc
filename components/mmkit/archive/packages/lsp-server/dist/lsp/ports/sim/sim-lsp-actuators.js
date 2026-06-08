"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.SimLspActuators = void 0;
class SimLspActuators {
    diagnostics = new Map();
    progress = [];
    logMessages = [];
    showMessages = [];
    showDocuments = [];
    consoleLogLines = [];
    consoleInfoLines = [];
    consoleWarnLines = [];
    consoleErrorLines = [];
    consoleDebugLines = [];
    workspaceEdits = [];
    configurationRequests = [];
    workspaceFolderRequestCount = 0;
    capabilityRegistrations = [];
    capabilityUnregistrations = [];
    semanticTokenRefreshCount = 0;
    telemetryEvents = [];
    traceLogs = [];
    throwOn = {};
    /** Simulated responses for client-request actuators. */
    configurationResponse = [];
    workspaceFoldersResponse = null;
    applyEditResponse = { applied: true };
    showDocumentResponse = { success: true };
    showMessageResponse = undefined;
    guard(method) {
        const err = this.throwOn[method];
        if (err)
            throw err;
    }
    publishDiagnostics(uri, diagnostics) {
        this.guard("publishDiagnostics");
        this.diagnostics.set(uri, diagnostics);
    }
    sendProgress(token, value) {
        this.guard("sendProgress");
        this.progress.push({ token, value });
    }
    beginWorkDone(token, title, cancellable) {
        this.guard("beginWorkDone");
        this.sendProgress(token, { kind: "begin", title, cancellable });
    }
    reportWorkDone(token, message, percentage) {
        this.guard("reportWorkDone");
        this.sendProgress(token, { kind: "report", message, percentage });
    }
    endWorkDone(token) {
        this.guard("endWorkDone");
        this.sendProgress(token, { kind: "end" });
    }
    logMessage(type, message) {
        this.guard("logMessage");
        this.logMessages.push({ type, message });
    }
    showErrorMessage(message, ...actions) {
        this.guard("showErrorMessage");
        this.showMessages.push({ level: "error", message, actions });
        return Promise.resolve(this.showMessageResponse);
    }
    showWarningMessage(message, ...actions) {
        this.guard("showWarningMessage");
        this.showMessages.push({ level: "warning", message, actions });
        return Promise.resolve(this.showMessageResponse);
    }
    showInformationMessage(message, ...actions) {
        this.guard("showInformationMessage");
        this.showMessages.push({ level: "information", message, actions });
        return Promise.resolve(this.showMessageResponse);
    }
    showDocument(params) {
        this.guard("showDocument");
        this.showDocuments.push(params);
        return Promise.resolve(this.showDocumentResponse);
    }
    consoleLog(message) {
        this.guard("consoleLog");
        this.consoleLogLines.push(message);
    }
    consoleInfo(message) {
        this.guard("consoleInfo");
        this.consoleInfoLines.push(message);
    }
    consoleWarn(message) {
        this.guard("consoleWarn");
        this.consoleWarnLines.push(message);
    }
    consoleError(message) {
        this.guard("consoleError");
        this.consoleErrorLines.push(message);
    }
    consoleDebug(message) {
        this.guard("consoleDebug");
        this.consoleDebugLines.push(message);
    }
    applyWorkspaceEdit(edit) {
        this.guard("applyWorkspaceEdit");
        this.workspaceEdits.push(edit);
        return Promise.resolve(this.applyEditResponse);
    }
    getConfiguration(items) {
        this.guard("getConfiguration");
        this.configurationRequests.push(items);
        return Promise.resolve(this.configurationResponse);
    }
    getWorkspaceFolders() {
        this.guard("getWorkspaceFolders");
        this.workspaceFolderRequestCount += 1;
        return Promise.resolve(this.workspaceFoldersResponse);
    }
    registerCapabilities(registrations) {
        this.guard("registerCapabilities");
        this.capabilityRegistrations.push(registrations);
        return Promise.resolve();
    }
    unregisterCapabilities(unregisterations) {
        this.guard("unregisterCapabilities");
        this.capabilityUnregistrations.push(unregisterations);
        return Promise.resolve();
    }
    refreshSemanticTokens() {
        this.guard("refreshSemanticTokens");
        this.semanticTokenRefreshCount += 1;
    }
    logTelemetryEvent(data) {
        this.guard("logTelemetryEvent");
        this.telemetryEvents.push(data);
    }
    logTrace(message, verbose) {
        this.guard("logTrace");
        this.traceLogs.push({ message, verbose });
    }
    workDoneSequence(token) {
        return this.progress.filter((p) => p.token === token).map((p) => p.value);
    }
}
exports.SimLspActuators = SimLspActuators;
//# sourceMappingURL=sim-lsp-actuators.js.map