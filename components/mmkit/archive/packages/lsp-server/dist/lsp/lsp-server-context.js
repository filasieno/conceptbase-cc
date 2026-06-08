"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createLspServerContext = createLspServerContext;
const node_1 = require("vscode-languageserver/node");
const vscode_languageserver_textdocument_1 = require("vscode-languageserver-textdocument");
const document_registry_1 = require("./document-registry");
const publisher_1 = require("./diagnostics/publisher");
const notebook_registry_1 = require("./notebook-registry");
const connection_actuators_1 = require("./ports/real/connection-actuators");
const lsp_sensors_1 = require("./ports/lsp-sensors");
const lsp_actor_registry_1 = require("./registry/lsp-actor-registry");
function createLspServerContext(connection, readiness, metrics, supervisor, actuators, sensors) {
    const registry = new lsp_actor_registry_1.LspActorRegistry();
    const documentRegistry = new document_registry_1.DocumentRegistry();
    const notebookRegistry = new notebook_registry_1.NotebookRegistry();
    const documents = new node_1.TextDocuments(vscode_languageserver_textdocument_1.TextDocument);
    const realActuators = actuators ?? (0, connection_actuators_1.createConnectionActuators)(connection);
    const realSensors = sensors ?? (0, lsp_sensors_1.createLspSensors)();
    const diagnosticsPublisher = new publisher_1.DiagnosticsPublisher((params) => realActuators.publishDiagnostics(params.uri, params.diagnostics));
    return {
        connection,
        actuators: realActuators,
        sensors: realSensors,
        registry,
        readiness,
        metrics,
        supervisor,
        documents,
        documentRegistry,
        notebookRegistry,
        diagnosticsPublisher,
    };
}
//# sourceMappingURL=lsp-server-context.js.map