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
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.startHttpApp = startHttpApp;
const fs = __importStar(require("node:fs"));
const path = __importStar(require("node:path"));
const express_1 = __importDefault(require("express"));
const express_2 = require("@modelcontextprotocol/express");
const node_1 = require("@modelcontextprotocol/node");
const otel_1 = require("./telemetry/otel");
const KNOWN_DOCS = [
    {
        slug: "user-manual",
        title: "ConceptBase User Manual",
        description: "End-user reference: modules, frames, queries, client interfaces.",
        html: "doc-user-manual.html",
        pdf: "doc-user-manual.pdf",
    },
    {
        slug: "prog-manual",
        title: "ConceptBase Programmer Manual",
        description: "API, IPC protocol, extending the server.",
        html: "doc-prog-manual.html",
        pdf: "doc-prog-manual.pdf",
    },
    {
        slug: "tutorial",
        title: "ConceptBase Tutorial",
        description: "Step-by-step introduction to modelling with ConceptBase.",
        html: "doc-tutorial.html",
        pdf: "doc-tutorial.pdf",
    },
    {
        slug: "howto-manual",
        title: "ConceptBase HOW-TO Manual",
        description: "Task-oriented how-to guides.",
        pdf: "howto-manual.pdf",
    },
];
// ── index page ─────────────────────────────────────────────────────────────────
function buildDocsIndexHtml(baseUrl, docsDir) {
    const rows = KNOWN_DOCS.map((doc) => {
        const htmlExists = doc.html && fs.existsSync(path.join(docsDir, doc.html));
        const pdfExists = doc.pdf && fs.existsSync(path.join(docsDir, doc.pdf));
        const htmlLink = htmlExists ? `<a href="${baseUrl}/${doc.html}">HTML</a>` : "";
        const pdfLink = pdfExists ? `<a href="${baseUrl}/${doc.pdf}">PDF</a>` : "";
        const links = [htmlLink, pdfLink].filter(Boolean).join(" &nbsp;·&nbsp; ");
        return `
      <tr>
        <td><strong>${doc.title}</strong><br><small>${doc.description}</small></td>
        <td>${links || "—"}</td>
      </tr>`;
    }).join("\n");
    return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>ConceptBase Documentation</title>
  <style>
    body { font-family: system-ui, sans-serif; max-width: 860px; margin: 2rem auto; padding: 0 1rem; color: #222; }
    h1 { margin-bottom: .25rem; }
    p.sub { color: #555; margin-top: 0; }
    table { border-collapse: collapse; width: 100%; margin-top: 1.5rem; }
    th { text-align: left; border-bottom: 2px solid #ccc; padding: .5rem 0; color: #444; }
    td { padding: .6rem .4rem; border-bottom: 1px solid #eee; vertical-align: top; }
    a { color: #0060c0; }
    code { background: #f4f4f4; padding: .1rem .3rem; border-radius: 3px; font-size: .9em; }
  </style>
</head>
<body>
  <h1>ConceptBase Documentation</h1>
  <p class="sub">Served by mmkit at <code>${baseUrl}</code></p>

  <table>
    <thead><tr><th>Manual</th><th>Formats</th></tr></thead>
    <tbody>${rows}</tbody>
  </table>

  <h2>API endpoints</h2>
  <p>
    MCP tools: <code>POST /mcp</code><br>
    Health: <code>GET /healthz</code> &nbsp;·&nbsp; <code>GET /readyz</code><br>
    Metrics: <code>GET /metrics</code>
  </p>
</body>
</html>`;
}
// ── http app ───────────────────────────────────────────────────────────────────
function startHttpApp(port, options) {
    if (process.env.MMKIT_HTTP_DISABLED === "1") {
        return undefined;
    }
    const log = (0, otel_1.otelLogger)("mmkit-http");
    const app = (0, express_2.createMcpExpressApp)({ host: "0.0.0.0" });
    app.use(express_1.default.json({ limit: "4mb" }));
    app.get(["/healthz", "/health"], (_req, res) => {
        res.type("text/plain").send("ok");
    });
    app.get(["/readyz", "/ready"], (_req, res) => {
        if (options.readiness.started) {
            res.type("text/plain").send("ready");
            return;
        }
        res.status(503).type("text/plain").send("not ready");
    });
    app.get("/metrics", async (_req, res) => {
        try {
            const body = await options.metricsRegistry.metrics();
            res.type(options.metricsRegistry.contentType).send(body);
        }
        catch (err) {
            log.emit({ severityText: "ERROR", body: "failed to render Prometheus metrics", attributes: { error: String(err) } });
            res.status(500).type("text/plain").send("metrics error");
        }
    });
    app.post("/mcp", async (req, res) => {
        const transport = new node_1.NodeStreamableHTTPServerTransport({ sessionIdGenerator: undefined });
        await options.mcpServer.connect(transport);
        await transport.handleRequest(req, res, req.body);
    });
    // ── docs ────────────────────────────────────────────────────────────────────
    const { docsDir } = options;
    if (docsDir && fs.existsSync(docsDir)) {
        const baseUrl = `http://localhost:${port}/docs`;
        app.get("/docs", (_req, res) => {
            res.type("text/html").send(buildDocsIndexHtml(baseUrl, docsDir));
        });
        // Serve all files (HTML, PDF, images, text) from the docs dir
        app.use("/docs", express_1.default.static(docsDir, { index: false, dotfiles: "ignore" }));
        log.emit({ severityText: "INFO", body: "ConceptBase docs served", attributes: { url: `${baseUrl}`, docsDir } });
    }
    const endpoints = ["/healthz", "/readyz", "/metrics", "/mcp", ...(docsDir ? ["/docs"] : [])];
    const server = app.listen(port, "0.0.0.0", () => {
        log.emit({ severityText: "INFO", body: "mmkit HTTP server listening", attributes: { port, endpoints } });
    });
    server.on("error", (err) => {
        log.emit({ severityText: "WARN", body: "HTTP server unavailable", attributes: { port, error: err.message } });
    });
    return server;
}
//# sourceMappingURL=http-app.js.map