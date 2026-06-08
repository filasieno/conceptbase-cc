"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.isOpenTelemetryEnabled = isOpenTelemetryEnabled;
exports.initOpenTelemetry = initOpenTelemetry;
exports.shutdownOpenTelemetry = shutdownOpenTelemetry;
exports.otelLogger = otelLogger;
const api_1 = require("@opentelemetry/api");
const api_logs_1 = require("@opentelemetry/api-logs");
const exporter_logs_otlp_http_1 = require("@opentelemetry/exporter-logs-otlp-http");
const exporter_metrics_otlp_http_1 = require("@opentelemetry/exporter-metrics-otlp-http");
const exporter_trace_otlp_http_1 = require("@opentelemetry/exporter-trace-otlp-http");
const resources_1 = require("@opentelemetry/resources");
const sdk_logs_1 = require("@opentelemetry/sdk-logs");
const sdk_metrics_1 = require("@opentelemetry/sdk-metrics");
const sdk_node_1 = require("@opentelemetry/sdk-node");
const semantic_conventions_1 = require("@opentelemetry/semantic-conventions");
let sdk;
let loggerProvider;
/** OpenTelemetry is opt-in: set `MMKIT_OTEL_ENABLED=1` and `OTEL_EXPORTER_OTLP_ENDPOINT`. */
function isOpenTelemetryEnabled() {
    return process.env.MMKIT_OTEL_ENABLED === "1" && process.env.MMKIT_OTEL_DISABLED !== "1";
}
function otlpBaseUrl() {
    const endpoint = process.env.OTEL_EXPORTER_OTLP_ENDPOINT?.replace(/\/$/, "");
    if (endpoint)
        return endpoint;
    return "http://127.0.0.1:4318";
}
function initOpenTelemetry() {
    if (!isOpenTelemetryEnabled())
        return;
    if (!process.env.OTEL_EXPORTER_OTLP_ENDPOINT) {
        console.warn("mmkit-lsp: MMKIT_OTEL_ENABLED=1 but OTEL_EXPORTER_OTLP_ENDPOINT is unset — skipping OpenTelemetry");
        return;
    }
    const serviceName = process.env.OTEL_SERVICE_NAME ?? "mmkit-lsp";
    const resource = new resources_1.Resource({
        [semantic_conventions_1.ATTR_SERVICE_NAME]: serviceName,
        "service.namespace": "mmkit",
    });
    if (process.env.OTEL_LOG_LEVEL === "debug") {
        api_1.diag.setLogger(new api_1.DiagConsoleLogger(), api_1.DiagLogLevel.DEBUG);
    }
    const base = otlpBaseUrl();
    const traceExporter = new exporter_trace_otlp_http_1.OTLPTraceExporter({ url: `${base}/v1/traces` });
    const metricExporter = new exporter_metrics_otlp_http_1.OTLPMetricExporter({ url: `${base}/v1/metrics` });
    const logExporter = new exporter_logs_otlp_http_1.OTLPLogExporter({ url: `${base}/v1/logs` });
    loggerProvider = new sdk_logs_1.LoggerProvider({ resource });
    loggerProvider.addLogRecordProcessor(new sdk_logs_1.BatchLogRecordProcessor(logExporter));
    api_logs_1.logs.setGlobalLoggerProvider(loggerProvider);
    sdk = new sdk_node_1.NodeSDK({
        resource,
        traceExporter,
        metricReader: new sdk_metrics_1.PeriodicExportingMetricReader({
            exporter: metricExporter,
            exportIntervalMillis: 15_000,
        }),
    });
    sdk.start();
}
async function shutdownOpenTelemetry() {
    await loggerProvider?.shutdown();
    await sdk?.shutdown();
    sdk = undefined;
    loggerProvider = undefined;
}
function otelLogger(name = "mmkit-lsp") {
    return api_logs_1.logs.getLogger(name);
}
//# sourceMappingURL=otel.js.map