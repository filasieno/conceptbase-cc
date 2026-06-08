"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.INSTALL_STEPS = exports.CBSERVER_INSTALL_REL_PATH = exports.INSTALL_MARKER_FILE = exports.FAST_START_THRESHOLD_MS = void 0;
/** Shown only when mmkit server is not reachable within this window after start. */
exports.FAST_START_THRESHOLD_MS = 2000;
exports.INSTALL_MARKER_FILE = ".mmkit-installed";
/** Relative path under dataDir where materialize copies the cbserver binary. */
exports.CBSERVER_INSTALL_REL_PATH = "bin/cbserver";
exports.INSTALL_STEPS = [
    "prepare",
    "materialize",
    "dockerImage",
    "launch",
    "awaitPort",
];
//# sourceMappingURL=constants.js.map