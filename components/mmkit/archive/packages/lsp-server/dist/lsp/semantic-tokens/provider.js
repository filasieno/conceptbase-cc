"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.provideSemanticTokensFull = provideSemanticTokensFull;
exports.provideSemanticTokensRange = provideSemanticTokensRange;
const parse_1 = require("../parse");
const queries_1 = require("../tree-sitter/queries");
const runtime_1 = require("../tree-sitter/runtime");
const encode_1 = require("./encode");
async function provideSemanticTokensFull(registry, uri) {
    const prepared = await collectEncodedTokens(registry, uri);
    if (!prepared)
        return { data: [] };
    return (0, encode_1.encodeSemanticTokens)(prepared.doc, prepared.tokens);
}
async function provideSemanticTokensRange(registry, uri, range) {
    const prepared = await collectEncodedTokens(registry, uri);
    if (!prepared)
        return { data: [] };
    const filtered = (0, encode_1.filterTokensInRange)(prepared.doc, prepared.tokens, range);
    return (0, encode_1.encodeSemanticTokens)(prepared.doc, filtered);
}
async function collectEncodedTokens(registry, uri) {
    const doc = registry.getBuffer(uri);
    if (!doc || doc.getText().trim().length === 0)
        return undefined;
    if (!(await (0, runtime_1.isTreeSitterAvailable)()))
        return undefined;
    await (0, parse_1.validateConceptBaseDocument)(registry, doc);
    const tree = registry.getTree(uri);
    if (!tree)
        return undefined;
    const query = await (0, queries_1.loadHighlightsQuery)((0, runtime_1.getLoadedLanguage)());
    if (!query)
        return undefined;
    const raw = (0, queries_1.allHighlightTokens)(doc, tree, query).map((t) => ({ ...t, document: doc }));
    const tokens = (0, encode_1.prepareSemanticTokens)(raw);
    return { doc, tokens };
}
//# sourceMappingURL=provider.js.map