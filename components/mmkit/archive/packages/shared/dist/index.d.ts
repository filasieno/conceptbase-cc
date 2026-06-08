export * from "./constants";
export * from "./config";
export * from "./protocol";
export * from "./cb-tcp";
export * from "./cb-ask";
export * from "./executable-path";
/** ConceptBase language id registered with VS Code and the LSP server. */
export declare const LANGUAGE_ID = "conceptbase";
/** MM notebook type for ConceptBase-only code cells. */
export declare const NOTEBOOK_TYPE = "mmkit.conceptbase-notebook";
/** On-disk notebook extension. */
export declare const NOTEBOOK_EXTENSION = ".mmnb";
/** ConceptBase source file extension. */
export declare const CBS_EXTENSION = ".cbs";
/** TextMate / tree-sitter scope for ConceptBase sources. */
export declare const LANGUAGE_SCOPE = "source.conceptbase";
/** LSP text sync: incremental only (TextDocumentSyncKind.Incremental === 2). */
export declare const TEXT_DOCUMENT_SYNC_INCREMENTAL: 2;
/** Current on-disk MM notebook JSON schema version. */
export declare const MMNB_VERSION = 1;
/** Virtual URI scheme for in-memory ConceptBase browser documents. */
export declare const NODE_EDITOR_SCHEME = "mmkit-node";
/** Custom editor view type for the ConceptBase browser (WebGL2 + Slug text). */
export declare const NODE_EDITOR_VIEW_TYPE = "mmkit.nodeEditor";
/** Virtual document extension shown in editor tabs. */
export declare const NODE_EDITOR_EXTENSION = ".cbn";
/** Command palette id — opens the default ConceptBase browser virtual document. */
export declare const NODE_EDITOR_COMMAND = "mmkit.openNodeEditor";
