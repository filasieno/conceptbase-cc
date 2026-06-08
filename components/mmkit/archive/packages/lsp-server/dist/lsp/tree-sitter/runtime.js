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
exports.getLoadedLanguage = getLoadedLanguage;
exports.resolveWasmPath = resolveWasmPath;
exports.isTreeSitterAvailable = isTreeSitterAvailable;
exports.parseConceptBase = parseConceptBase;
exports.collectNodeTypes = collectNodeTypes;
exports.countSyntaxErrors = countSyntaxErrors;
exports._resetTreeSitterRuntimeForTests = _resetTreeSitterRuntimeForTests;
const fs = __importStar(require("node:fs"));
const path = __importStar(require("node:path"));
let parserReady;
let parserUnavailable = false;
let ParserCtor;
let LanguageLoader;
let language;
let parser;
function getLoadedLanguage() {
    return language;
}
function wasmCandidates() {
    const here = path.dirname(__filename);
    const grammarWasm = "tree-sitter-conceptbase/target/lib/tree-sitter-conceptbase.wasm";
    return [
        path.join(here, "tree-sitter-conceptbase.wasm"),
        path.join(here, "..", "tree-sitter-conceptbase.wasm"),
        path.resolve(here, "../../../../../", grammarWasm),
        path.resolve(here, "../../../../../../", grammarWasm),
        path.resolve(here, "../../../../../../../", grammarWasm),
    ];
}
function resolveWasmPath() {
    for (const candidate of wasmCandidates()) {
        if (fs.existsSync(candidate))
            return candidate;
    }
    return undefined;
}
/** Returns true when the ConceptBase WASM grammar loaded successfully. */
async function isTreeSitterAvailable() {
    if (parserUnavailable)
        return false;
    if (parser && language)
        return true;
    if (!parserReady) {
        parserReady = (async () => {
            try {
                const wasmPath = resolveWasmPath();
                if (!wasmPath)
                    return false;
                const imported = (await Promise.resolve().then(() => __importStar(require("web-tree-sitter"))));
                const mod = imported.default ?? imported;
                ParserCtor = mod.Parser;
                LanguageLoader = mod.Language;
                await ParserCtor.init();
                language = await LanguageLoader.load(wasmPath);
                parser = new ParserCtor();
                parser.setLanguage(language);
                return true;
            }
            catch {
                parserUnavailable = true;
                parser = undefined;
                language = undefined;
                return false;
            }
        })();
    }
    return parserReady;
}
/** Incrementally parse `text`, reusing `previousTree` when provided. */
function parseConceptBase(text, previousTree) {
    if (!parser || parserUnavailable)
        return undefined;
    try {
        return parser.parse(text, previousTree);
    }
    catch {
        parserUnavailable = true;
        return undefined;
    }
}
/** Walk the tree and collect node type names (for tests). */
function collectNodeTypes(root, out = new Set()) {
    out.add(root.type);
    for (let i = 0; i < root.childCount; i++) {
        const child = root.child(i);
        if (child)
            collectNodeTypes(child, out);
    }
    return out;
}
/** Count ERROR / missing nodes in the CST. */
function countSyntaxErrors(root) {
    let n = 0;
    if (root.hasError || root.type === "ERROR" || root.isMissing)
        n += 1;
    for (let i = 0; i < root.childCount; i++) {
        const child = root.child(i);
        if (child)
            n += countSyntaxErrors(child);
    }
    return n;
}
/** Reset runtime state (tests only). */
function _resetTreeSitterRuntimeForTests() {
    parserReady = undefined;
    parserUnavailable = false;
    ParserCtor = undefined;
    LanguageLoader = undefined;
    language = undefined;
    parser = undefined;
}
//# sourceMappingURL=runtime.js.map