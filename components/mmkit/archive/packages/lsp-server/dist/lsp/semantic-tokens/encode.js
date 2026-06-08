"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.prepareSemanticTokens = prepareSemanticTokens;
exports.encodeSemanticTokens = encodeSemanticTokens;
exports.filterTokensInRange = filterTokensInRange;
const node_1 = require("vscode-languageserver/node");
const range_bridge_1 = require("../text/range-bridge");
const legend_1 = require("./legend");
/** Sort by position and drop overlaps, keeping higher-priority captures. */
function prepareSemanticTokens(tokens) {
    const encoded = [];
    for (const token of tokens) {
        const typeIndex = (0, legend_1.captureToTypeIndex)(token.captureName);
        if (typeIndex === undefined)
            continue;
        const startIndex = (0, range_bridge_1.lspPositionToIndex)(token.document, token.range.start);
        const endIndex = (0, range_bridge_1.lspPositionToIndex)(token.document, token.range.end);
        if (endIndex <= startIndex)
            continue;
        encoded.push({
            startIndex,
            endIndex,
            tokenType: typeIndex,
            tokenModifiers: (0, legend_1.captureToModifiers)(token.captureName),
            priority: legend_1.CAPTURE_PRIORITY[token.captureName] ?? 0,
        });
    }
    encoded.sort((a, b) => a.startIndex - b.startIndex ||
        b.priority - a.priority ||
        a.endIndex - b.endIndex);
    const out = [];
    let lastEnd = -1;
    for (const token of encoded) {
        if (token.startIndex < lastEnd)
            continue;
        out.push(token);
        lastEnd = token.endIndex;
    }
    return out.map(({ priority: _priority, ...rest }) => rest);
}
/** Build LSP `SemanticTokens` data array from prepared tokens. */
function encodeSemanticTokens(doc, tokens) {
    const builder = new node_1.SemanticTokensBuilder();
    for (const token of tokens) {
        const start = doc.positionAt(token.startIndex);
        const length = token.endIndex - token.startIndex;
        builder.push(start.line, start.character, length, token.tokenType, token.tokenModifiers);
    }
    return builder.build();
}
/** Keep tokens intersecting `range` (LSP range, UTF-16). */
function filterTokensInRange(doc, tokens, range) {
    const rangeStart = (0, range_bridge_1.lspPositionToIndex)(doc, range.start);
    const rangeEnd = (0, range_bridge_1.lspPositionToIndex)(doc, range.end);
    return tokens.filter((t) => t.startIndex < rangeEnd && t.endIndex > rangeStart);
}
//# sourceMappingURL=encode.js.map