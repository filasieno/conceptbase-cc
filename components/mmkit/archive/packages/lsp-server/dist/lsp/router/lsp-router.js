"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.LspRouter = void 0;
exports.bindLspServer = bindLspServer;
exports.startLspStdio = startLspStdio;
exports.startLspTcp = startLspTcp;
const node_1 = require("vscode-languageserver/node");
const node_net_1 = require("node:net");
const lsp_server_context_1 = require("../lsp-server-context");
const initialize_request_hsm_1 = require("../requests/initialization/initialize-request.hsm");
const initialized_notification_hsm_1 = require("../requests/initialization/initialized-notification.hsm");
const did_change_notification_hsm_1 = require("../requests/notebook/did-change-notification.hsm");
const did_close_notification_hsm_1 = require("../requests/notebook/did-close-notification.hsm");
const did_open_notification_hsm_1 = require("../requests/notebook/did-open-notification.hsm");
const did_save_notification_hsm_1 = require("../requests/notebook/did-save-notification.hsm");
const full_request_hsm_1 = require("../requests/semantic-tokens/full-request.hsm");
const range_request_hsm_1 = require("../requests/semantic-tokens/range-request.hsm");
const did_change_notification_hsm_2 = require("../requests/text-document/did-change-notification.hsm");
const did_close_notification_hsm_2 = require("../requests/text-document/did-close-notification.hsm");
const did_open_notification_hsm_2 = require("../requests/text-document/did-open-notification.hsm");
const did_save_notification_hsm_2 = require("../requests/text-document/did-save-notification.hsm");
const will_save_notification_hsm_1 = require("../requests/text-document/will-save-notification.hsm");
const will_save_wait_until_request_hsm_1 = require("../requests/text-document/will-save-wait-until-request.hsm");
const shared_1 = require("@mmkit/shared");
const otel_1 = require("../../shared/telemetry/otel");
class LspRouter {
    server;
    bindOptions;
    constructor(server, bindOptions) {
        this.server = server;
        this.bindOptions = bindOptions;
    }
    bind(connection) {
        this.server.sensors.onCancel((requestId) => {
            this.server.registry.cancel(requestId);
        });
        connection.onNotification("$/cancelRequest", (params) => {
            this.server.sensors.emitCancel(params.id);
        });
        connection.onInitialize((params) => {
            return (0, initialize_request_hsm_1.runInitializeRequest)(this.server, params, this.bindOptions);
        });
        this.bindCustomHandlers(connection);
        connection.onInitialized(() => {
            (0, initialized_notification_hsm_1.spawnInitializedNotification)(this.server);
            this.bindNotebookHandlers();
        });
        connection.languages.semanticTokens.on((params, token) => (0, full_request_hsm_1.runSemanticTokensFullRequest)(this.server, params, token));
        connection.languages.semanticTokens.onRange((params, token) => (0, range_request_hsm_1.runSemanticTokensRangeRequest)(this.server, params, token));
        this.server.documents.onDidOpen((event) => {
            (0, did_open_notification_hsm_2.spawnDidOpenNotification)(this.server, event.document);
        });
        this.server.documents.onDidChangeContent((change) => {
            (0, did_change_notification_hsm_2.spawnDidChangeNotification)(this.server, change.document);
        });
        this.server.documents.onWillSave((event) => {
            (0, will_save_notification_hsm_1.spawnWillSaveNotification)(this.server, event);
        });
        this.server.documents.onWillSaveWaitUntil((event) => (0, will_save_wait_until_request_hsm_1.runWillSaveWaitUntilRequest)(this.server, event));
        this.server.documents.onDidSave((event) => {
            (0, did_save_notification_hsm_2.spawnDidSaveNotification)(this.server, event);
        });
        this.server.documents.onDidClose((event) => {
            (0, did_close_notification_hsm_2.spawnDidCloseNotification)(this.server, event.document);
        });
        this.server.documents.listen(connection);
        connection.listen();
    }
    bindCustomHandlers(connection) {
        const { customHandlers } = this.bindOptions;
        const methods = [
            shared_1.MMKIT_LSP_METHODS.serverStart,
            shared_1.MMKIT_LSP_METHODS.serverStop,
            shared_1.MMKIT_LSP_METHODS.serverRestart,
            shared_1.MMKIT_LSP_METHODS.serverStatus,
            shared_1.MMKIT_LSP_METHODS.configUpdate,
            shared_1.MMKIT_LSP_METHODS.otelTest,
        ];
        for (const method of methods) {
            if (!customHandlers.has(method))
                continue;
            connection.onRequest(method, async (params) => {
                return customHandlers.dispatch(method, params ?? {});
            });
        }
    }
    bindNotebookHandlers() {
        const sync = this.server.connection.notebooks?.synchronization;
        if (!sync)
            return;
        sync.onDidOpenNotebookDocument((event) => (0, did_open_notification_hsm_1.spawnNotebookDidOpen)(this.server, event));
        sync.onDidChangeNotebookDocument((event) => (0, did_change_notification_hsm_1.spawnNotebookDidChange)(this.server, event));
        sync.onDidCloseNotebookDocument((event) => (0, did_close_notification_hsm_1.spawnNotebookDidClose)(this.server, event));
        sync.onDidSaveNotebookDocument((event) => (0, did_save_notification_hsm_1.spawnNotebookDidSave)(this.server, event));
    }
}
exports.LspRouter = LspRouter;
function bindLspServer(connection, options, onWire) {
    const server = (0, lsp_server_context_1.createLspServerContext)(connection, options.readiness, options.metrics, options.supervisor);
    options.readiness.started = true;
    onWire?.(connection, server.actuators);
    const router = new LspRouter(server, options);
    router.bind(connection);
    return server;
}
function startLspStdio(options, onWire) {
    const connection = (0, node_1.createConnection)(node_1.ProposedFeatures.all);
    return bindLspServer(connection, options, onWire);
}
function startLspTcp(port, options, onWire) {
    const log = (0, otel_1.otelLogger)("mmkit-lsp");
    let clientConnection;
    const netServer = (0, node_net_1.createServer)((socket) => {
        if (clientConnection) {
            log.emit({
                severityText: "WARN",
                body: "rejecting additional LSP TCP client — only one client supported",
            });
            socket.destroy();
            return;
        }
        const connection = (0, node_1.createConnection)(node_1.ProposedFeatures.all, new node_1.StreamMessageReader(socket), new node_1.StreamMessageWriter(socket));
        clientConnection = connection;
        socket.on("close", () => {
            clientConnection = undefined;
        });
        bindLspServer(connection, options, onWire);
        log.emit({
            severityText: "INFO",
            body: "LSP TCP client connected",
            attributes: { port },
        });
    });
    netServer.listen(port, "0.0.0.0", () => {
        options.readiness.started = true;
        log.emit({
            severityText: "INFO",
            body: "LSP TCP server listening",
            attributes: { port },
        });
    });
    return netServer;
}
//# sourceMappingURL=lsp-router.js.map