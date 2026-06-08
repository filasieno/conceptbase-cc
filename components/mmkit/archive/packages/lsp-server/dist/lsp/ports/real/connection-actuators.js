"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createConnectionActuators = createConnectionActuators;
const vscode_languageserver_protocol_1 = require("vscode-languageserver-protocol");
function createConnectionActuators(connection) {
    return {
        publishDiagnostics(uri, diagnostics) {
            void connection.sendDiagnostics({ uri, diagnostics });
        },
        sendProgress(token, value) {
            void connection.sendProgress(vscode_languageserver_protocol_1.WorkDoneProgress.type, token, value);
        },
        beginWorkDone(token, title, cancellable = false) {
            void connection.sendProgress(vscode_languageserver_protocol_1.WorkDoneProgress.type, token, {
                kind: "begin",
                title,
                cancellable,
            });
        },
        reportWorkDone(token, message, percentage) {
            void connection.sendProgress(vscode_languageserver_protocol_1.WorkDoneProgress.type, token, {
                kind: "report",
                message,
                percentage,
            });
        },
        endWorkDone(token) {
            void connection.sendProgress(vscode_languageserver_protocol_1.WorkDoneProgress.type, token, { kind: "end" });
        },
        logMessage(type, message) {
            void connection.sendNotification("window/logMessage", { type, message });
        },
        showErrorMessage(message, ...actions) {
            if (actions.length === 0) {
                void connection.window.showErrorMessage(message);
                return Promise.resolve(undefined);
            }
            return connection.window.showErrorMessage(message, ...actions);
        },
        showWarningMessage(message, ...actions) {
            if (actions.length === 0) {
                void connection.window.showWarningMessage(message);
                return Promise.resolve(undefined);
            }
            return connection.window.showWarningMessage(message, ...actions);
        },
        showInformationMessage(message, ...actions) {
            if (actions.length === 0) {
                void connection.window.showInformationMessage(message);
                return Promise.resolve(undefined);
            }
            return connection.window.showInformationMessage(message, ...actions);
        },
        showDocument(params) {
            return connection.window.showDocument(params);
        },
        consoleLog(message) {
            connection.console.log(message);
        },
        consoleInfo(message) {
            connection.console.info(message);
        },
        consoleWarn(message) {
            connection.console.warn(message);
        },
        consoleError(message) {
            connection.console.error(message);
        },
        consoleDebug(message) {
            connection.console.debug(message);
        },
        applyWorkspaceEdit(edit) {
            return connection.workspace.applyEdit(edit);
        },
        getConfiguration(items) {
            return connection.workspace.getConfiguration(items);
        },
        getWorkspaceFolders() {
            return connection.workspace.getWorkspaceFolders();
        },
        registerCapabilities(registrations) {
            return connection.sendRequest(vscode_languageserver_protocol_1.RegistrationRequest.type, { registrations });
        },
        unregisterCapabilities(unregisterations) {
            return connection.sendRequest(vscode_languageserver_protocol_1.UnregistrationRequest.type, { unregisterations });
        },
        refreshSemanticTokens() {
            connection.languages.semanticTokens.refresh();
        },
        logTelemetryEvent(data) {
            connection.telemetry.logEvent(data);
        },
        logTrace(message, verbose) {
            connection.tracer.log(message, verbose);
        },
    };
}
//# sourceMappingURL=connection-actuators.js.map