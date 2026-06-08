"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.startTelemetryHttpServer = startTelemetryHttpServer;
const http = __importStar(require("node:http"));
const otel_1 = require("./otel");
function startTelemetryHttpServer(port, readiness, metricsRegistry) {
    if (process.env.MMKIT_HTTP_DISABLED === "1") {
        return undefined;
    }
    const log = (0, otel_1.otelLogger)("mmkit-lsp-http");
    const server = http.createServer(async (req, res) => {
        const path = req.url?.split("?")[0] ?? "/";
        if (path === "/healthz" || path === "/health") {
            res.writeHead(200, { "Content-Type": "text/plain" });
            res.end("ok");
            return;
        }
        if (path === "/readyz" || path === "/ready") {
            // Ready when the LSP transport is accepting connections (stdio bound or TCP
            // listening). Do not require lspInitialized — compose/VS Code probes before
            // the LanguageClient connects.
            if (readiness.started) {
                res.writeHead(200, { "Content-Type": "text/plain" });
                res.end("ready");
                return;
            }
            res.writeHead(503, { "Content-Type": "text/plain" });
            res.end("not ready");
            return;
        }
        if (path === "/metrics") {
            try {
                const body = await metricsRegistry.metrics();
                res.writeHead(200, { "Content-Type": metricsRegistry.contentType });
                res.end(body);
            }
            catch (err) {
                log.emit({
                    severityText: "ERROR",
                    body: "failed to render Prometheus metrics",
                    attributes: { error: String(err) },
                });
                res.writeHead(500, { "Content-Type": "text/plain" });
                res.end("metrics error");
            }
            return;
        }
        res.writeHead(404, { "Content-Type": "text/plain" });
        res.end("not found");
    });
    server.on("error", (err) => {
        log.emit({
            severityText: "WARN",
            body: "telemetry HTTP server unavailable — LSP continues without scrape endpoints",
            attributes: { port, error: err.message },
        });
    });
    server.listen(port, "0.0.0.0", () => {
        log.emit({
            severityText: "INFO",
            body: "telemetry HTTP server listening",
            attributes: { port, endpoints: ["/healthz", "/readyz", "/metrics"] },
        });
    });
    return server;
}
//# sourceMappingURL=http.js.map