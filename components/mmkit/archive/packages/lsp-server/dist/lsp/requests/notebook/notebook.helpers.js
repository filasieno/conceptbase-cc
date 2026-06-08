"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.cellDocumentUri = cellDocumentUri;
function cellDocumentUri(document) {
    return typeof document === "string" ? document : document.uri;
}
//# sourceMappingURL=notebook.helpers.js.map