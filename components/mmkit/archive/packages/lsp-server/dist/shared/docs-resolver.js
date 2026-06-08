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
exports.resolveConceptBaseDocsDir = resolveConceptBaseDocsDir;
const fs = __importStar(require("node:fs"));
const path = __importStar(require("node:path"));
const node_child_process_1 = require("node:child_process");
const otel_1 = require("./telemetry/otel");
const log = (0, otel_1.otelLogger)("mmkit-docs");
/**
 * Locate the ConceptBase HTML docs root (`…/share/doc/`).
 *
 * Resolution order:
 *   1. `MMKIT_CONCEPTBASE_DOCS_DIR`  — explicit override
 *   2. `MMKIT_CONCEPTBASE_FLAKE`#docs — nix build (instant when already cached)
 *   3. Auto-detect flake path by walking up from __dirname
 */
function resolveConceptBaseDocsDir() {
    const explicit = process.env.MMKIT_CONCEPTBASE_DOCS_DIR;
    if (explicit) {
        if (fs.existsSync(explicit))
            return path.resolve(explicit);
        log.emit({ severityText: "WARN", body: "MMKIT_CONCEPTBASE_DOCS_DIR not found", attributes: { path: explicit } });
        return undefined;
    }
    const flake = process.env.MMKIT_CONCEPTBASE_FLAKE ?? detectFlakePath();
    if (!flake) {
        log.emit({ severityText: "INFO", body: "docs not found — set MMKIT_CONCEPTBASE_DOCS_DIR or MMKIT_CONCEPTBASE_FLAKE" });
        return undefined;
    }
    try {
        const result = (0, node_child_process_1.spawnSync)("nix", ["build", `${flake}#docs`, "--print-out-paths", "--no-link", "--quiet"], {
            encoding: "utf8",
            timeout: 30_000,
        });
        const nixOut = result.stdout?.trim().split("\n")[0] ?? "";
        if (nixOut && fs.existsSync(nixOut)) {
            const docsDir = path.join(nixOut, "share", "doc");
            if (fs.existsSync(docsDir)) {
                log.emit({ severityText: "INFO", body: "docs resolved via nix build", attributes: { flake, path: docsDir } });
                return docsDir;
            }
        }
    }
    catch {
        log.emit({ severityText: "WARN", body: "nix build for docs failed — docs will not be served" });
    }
    return undefined;
}
/** Walk up from the running binary's dir looking for flake.nix. */
function detectFlakePath() {
    // __dirname in dist/ — walk up to find the monorepo root
    let dir = path.resolve(__dirname);
    for (let i = 0; i < 10; i++) {
        if (fs.existsSync(path.join(dir, "flake.nix")))
            return `path:${dir}`;
        const parent = path.dirname(dir);
        if (parent === dir)
            break;
        dir = parent;
    }
    return undefined;
}
//# sourceMappingURL=docs-resolver.js.map