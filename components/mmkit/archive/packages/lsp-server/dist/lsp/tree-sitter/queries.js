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
exports.SEMANTIC_CAPTURE_NAMES = void 0;
exports.resolveHighlightsQueryPath = resolveHighlightsQueryPath;
exports.loadHighlightsQuery = loadHighlightsQuery;
exports.getHighlightsQuerySource = getHighlightsQuerySource;
exports.capturesByName = capturesByName;
exports.keywordTokens = keywordTokens;
exports.allHighlightTokens = allHighlightTokens;
exports._resetQueriesForTests = _resetQueriesForTests;
const fs = __importStar(require("node:fs"));
const path = __importStar(require("node:path"));
const range_bridge_1 = require("../text/range-bridge");
let highlightsQuery;
let highlightsSource;
function highlightsCandidates() {
    const here = path.dirname(__filename);
    const rel = "tree-sitter-conceptbase/source/queries/highlights.scm";
    return [
        path.resolve(here, "../../../../../../", rel),
        path.resolve(here, "../../../../../../../", rel),
        path.resolve(here, "../../../../../", rel),
    ];
}
function resolveHighlightsQueryPath() {
    for (const candidate of highlightsCandidates()) {
        if (fs.existsSync(candidate))
            return candidate;
    }
    return undefined;
}
async function loadHighlightsQuery(language) {
    if (highlightsQuery)
        return highlightsQuery;
    const queryPath = resolveHighlightsQueryPath();
    if (!queryPath)
        return undefined;
    highlightsSource = fs.readFileSync(queryPath, "utf8");
    const { Query } = (await Promise.resolve().then(() => __importStar(require("web-tree-sitter"))));
    highlightsQuery = new Query(language, highlightsSource);
    return highlightsQuery;
}
function getHighlightsQuerySource() {
    return highlightsSource;
}
/**
 * Run highlights.scm captures filtered by name (e.g. `keyword`, `keyword.control`).
 * Prepares semantic token wiring: capture name → token type legend.
 */
function capturesByName(doc, tree, query, captureNames) {
    const tokens = [];
    for (const match of query.matches(tree.rootNode)) {
        for (const cap of match.captures) {
            if (!captureNames.has(cap.name))
                continue;
            tokens.push({
                captureName: cap.name,
                text: doc.getText().slice(cap.node.startIndex, cap.node.endIndex),
                range: (0, range_bridge_1.nodeToLspRange)(doc, cap.node),
                nodeType: cap.node.type,
            });
        }
    }
    return tokens;
}
/** Keyword captures from highlights.scm `@keyword` / `@keyword.control`. */
function keywordTokens(doc, tree, query) {
    return capturesByName(doc, tree, query, new Set(["keyword", "keyword.control"]));
}
/** All highlights.scm capture names used for semantic tokens. */
exports.SEMANTIC_CAPTURE_NAMES = new Set([
    "comment",
    "keyword",
    "keyword.control",
    "function",
    "function.builtin",
    "punctuation.special",
    "string",
    "embedded",
    "variable",
    "number",
    "constant.builtin",
]);
/** Every semantic-token capture from highlights.scm. */
function allHighlightTokens(doc, tree, query) {
    return capturesByName(doc, tree, query, exports.SEMANTIC_CAPTURE_NAMES);
}
/** @internal tests */
function _resetQueriesForTests() {
    highlightsQuery = undefined;
    highlightsSource = undefined;
}
//# sourceMappingURL=queries.js.map