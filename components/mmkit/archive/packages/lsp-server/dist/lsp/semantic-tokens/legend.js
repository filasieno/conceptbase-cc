"use strict";
/** LSP semantic token legend — indices must match {@link captureToTokenIndex}. */
Object.defineProperty(exports, "__esModule", { value: true });
exports.CAPTURE_PRIORITY = exports.DEFAULT_LIBRARY_CAPTURES = exports.CAPTURE_TO_TYPE_INDEX = exports.SEMANTIC_TOKEN_MODIFIERS = exports.SEMANTIC_TOKEN_TYPES = void 0;
exports.captureToTypeIndex = captureToTypeIndex;
exports.captureToModifiers = captureToModifiers;
exports.SEMANTIC_TOKEN_TYPES = [
    "keyword",
    "function",
    "variable",
    "string",
    "number",
    "comment",
    "macro",
    "operator",
];
exports.SEMANTIC_TOKEN_MODIFIERS = ["defaultLibrary"];
/** tree-sitter highlights.scm capture name → LSP token type index. */
exports.CAPTURE_TO_TYPE_INDEX = {
    keyword: 0,
    "keyword.control": 0,
    function: 1,
    "function.builtin": 1,
    variable: 2,
    string: 3,
    number: 4,
    comment: 5,
    embedded: 6,
    "constant.builtin": 4,
    "punctuation.special": 7,
};
/** Capture names that set the `defaultLibrary` modifier bit. */
exports.DEFAULT_LIBRARY_CAPTURES = new Set(["function.builtin", "constant.builtin"]);
/** Higher priority wins when captures overlap at the same offset. */
exports.CAPTURE_PRIORITY = {
    keyword: 100,
    "keyword.control": 100,
    "punctuation.special": 90,
    function: 85,
    "function.builtin": 84,
    string: 80,
    embedded: 75,
    number: 70,
    "constant.builtin": 70,
    variable: 60,
    comment: 50,
};
function captureToTypeIndex(captureName) {
    return exports.CAPTURE_TO_TYPE_INDEX[captureName];
}
function captureToModifiers(captureName) {
    return exports.DEFAULT_LIBRARY_CAPTURES.has(captureName) ? 1 << 0 : 0;
}
//# sourceMappingURL=legend.js.map