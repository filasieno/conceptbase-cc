/** Shown only when mmkit server is not reachable within this window after start. */
export declare const FAST_START_THRESHOLD_MS = 2000;
export declare const INSTALL_MARKER_FILE = ".mmkit-installed";
/** Relative path under dataDir where materialize copies the cbserver binary. */
export declare const CBSERVER_INSTALL_REL_PATH = "bin/cbserver";
export declare const INSTALL_STEPS: readonly ["prepare", "materialize", "dockerImage", "launch", "awaitPort"];
export type InstallStep = (typeof INSTALL_STEPS)[number];
