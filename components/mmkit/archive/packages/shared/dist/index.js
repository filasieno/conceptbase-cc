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
var __exportStar = (this && this.__exportStar) || function(m, exports) {
    for (var p in m) if (p !== "default" && !Object.prototype.hasOwnProperty.call(exports, p)) __createBinding(exports, m, p);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.NODE_EDITOR_COMMAND = exports.NODE_EDITOR_EXTENSION = exports.NODE_EDITOR_VIEW_TYPE = exports.NODE_EDITOR_SCHEME = exports.MMNB_VERSION = exports.TEXT_DOCUMENT_SYNC_INCREMENTAL = exports.LANGUAGE_SCOPE = exports.CBS_EXTENSION = exports.NOTEBOOK_EXTENSION = exports.NOTEBOOK_TYPE = exports.LANGUAGE_ID = void 0;
__exportStar(require("./constants"), exports);
__exportStar(require("./config"), exports);
__exportStar(require("./protocol"), exports);
__exportStar(require("./cb-tcp"), exports);
__exportStar(require("./cb-ask"), exports);
__exportStar(require("./executable-path"), exports);
/** ConceptBase language id registered with VS Code and the LSP server. */
exports.LANGUAGE_ID = "conceptbase";
/** MM notebook type for ConceptBase-only code cells. */
exports.NOTEBOOK_TYPE = "mmkit.conceptbase-notebook";
/** On-disk notebook extension. */
exports.NOTEBOOK_EXTENSION = ".mmnb";
/** ConceptBase source file extension. */
exports.CBS_EXTENSION = ".cbs";
/** TextMate / tree-sitter scope for ConceptBase sources. */
exports.LANGUAGE_SCOPE = "source.conceptbase";
/** LSP text sync: incremental only (TextDocumentSyncKind.Incremental === 2). */
exports.TEXT_DOCUMENT_SYNC_INCREMENTAL = 2;
/** Current on-disk MM notebook JSON schema version. */
exports.MMNB_VERSION = 1;
/** Virtual URI scheme for in-memory ConceptBase browser documents. */
exports.NODE_EDITOR_SCHEME = "mmkit-node";
/** Custom editor view type for the ConceptBase browser (WebGL2 + Slug text). */
exports.NODE_EDITOR_VIEW_TYPE = "mmkit.nodeEditor";
/** Virtual document extension shown in editor tabs. */
exports.NODE_EDITOR_EXTENSION = ".cbn";
/** Command palette id — opens the default ConceptBase browser virtual document. */
exports.NODE_EDITOR_COMMAND = "mmkit.openNodeEditor";
//# sourceMappingURL=index.js.map