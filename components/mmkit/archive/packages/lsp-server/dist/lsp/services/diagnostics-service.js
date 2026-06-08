"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.publishDiagnosticsForUri = publishDiagnosticsForUri;
const api_1 = require("@opentelemetry/api");
const tracer = api_1.trace.getTracer("mmkit-lsp");
async function publishDiagnosticsForUri(ctx, uri) {
    await tracer.startActiveSpan("lsp.publishDiagnostics", async (span) => {
        span.setAttribute("document.uri", uri);
        await ctx.diagnosticsPublisher.publish(ctx.documentRegistry, uri);
        ctx.metrics.diagnosticsPublished.inc();
        span.end();
    });
}
//# sourceMappingURL=diagnostics-service.js.map