"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const http_app_1 = require("./shared/http-app");
const lsp_app_1 = require("./lsp/lsp-app");
const mcp_server_1 = require("./mcp/mcp-server");
const ports_1 = require("./shared/ports");
const custom_handler_registry_1 = require("./cbserver/supervisor/custom-handler-registry");
const server_supervisor_1 = require("./cbserver/supervisor/server-supervisor");
const metrics_1 = require("./shared/telemetry/metrics");
const otel_1 = require("./shared/telemetry/otel");
async function main() {
    const transport = (process.env.MMKIT_LSP_TRANSPORT ?? "tcp").toLowerCase();
    const httpPort = Number(process.env.MMKIT_HTTP_PORT ?? "28080");
    const lspPort = Number(process.env.MMKIT_LSP_PORT ?? "16011");
    const log = (0, otel_1.otelLogger)("mmkit-lsp");
    (0, otel_1.initOpenTelemetry)();
    const readiness = { started: false, lspInitialized: false };
    const metrics = (0, metrics_1.createLspMetrics)();
    const customHandlers = new custom_handler_registry_1.CustomHandlerRegistry();
    const ports = (0, ports_1.createRealPorts)();
    let activeConnection;
    let activeActuators;
    const supervisor = new server_supervisor_1.ServerSupervisor({
        ports,
        registry: customHandlers,
        getConnection: () => activeConnection,
        getActuators: () => activeActuators,
    });
    supervisor.start();
    const mcpServer = (0, mcp_server_1.createMmkitMcpServer)(supervisor);
    const httpServer = (0, http_app_1.startHttpApp)(httpPort, {
        readiness,
        metricsRegistry: metrics.registry,
        mcpServer,
    });
    const bindOptions = {
        readiness,
        metrics,
        supervisor,
        customHandlers,
    };
    const wireConnection = (connection, actuators) => {
        activeConnection = connection;
        activeActuators = actuators;
    };
    if (transport === "tcp") {
        (0, lsp_app_1.startLspTcp)(lspPort, bindOptions, wireConnection);
        log.emit({
            severityText: "INFO",
            body: "mmkit LSP started in TCP mode",
            attributes: { lspPort, httpPort },
        });
    }
    else {
        const server = (0, lsp_app_1.startLspStdio)(bindOptions);
        wireConnection(server.connection, server.actuators);
        log.emit({
            severityText: "INFO",
            body: "mmkit LSP started in stdio mode",
            attributes: { httpPort },
        });
    }
    const shutdown = async (signal) => {
        log.emit({ severityText: "INFO", body: "shutting down", attributes: { signal } });
        await supervisor.shutdown();
        httpServer?.close();
        await (0, otel_1.shutdownOpenTelemetry)();
        process.exit(0);
    };
    process.on("SIGTERM", () => void shutdown("SIGTERM"));
    process.on("SIGINT", () => void shutdown("SIGINT"));
}
main().catch((err) => {
    console.error("mmkit-lsp fatal:", err);
    process.exit(1);
});
//# sourceMappingURL=main.js.map