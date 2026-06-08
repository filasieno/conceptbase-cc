"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.toConceptBaseDocument = toConceptBaseDocument;
function toConceptBaseDocument(document, tree) {
    return {
        uri: document.uri,
        document,
        version: document.version,
        tree,
    };
}
//# sourceMappingURL=conceptbase-document.js.map