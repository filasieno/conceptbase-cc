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
exports.installMarkerPath = installMarkerPath;
exports.readManifest = readManifest;
exports.isInstallationComplete = isInstallationComplete;
exports.materializeInstallAssets = materializeInstallAssets;
const fs = __importStar(require("node:fs/promises"));
const path = __importStar(require("node:path"));
const promises_1 = require("node:fs/promises");
const shared_1 = require("@mmkit/shared");
function resolveExecutableSource(assetRoot, bundleName) {
    if (process.env.MMKIT_CBSERVER_BIN) {
        return path.resolve(process.env.MMKIT_CBSERVER_BIN);
    }
    return path.join(assetRoot, bundleName);
}
function installMarkerPath(paths) {
    return path.join(paths.dataDir, shared_1.INSTALL_MARKER_FILE);
}
async function readManifest(assetRoot) {
    const raw = await fs.readFile(path.join(assetRoot, "manifest.json"), "utf8");
    return JSON.parse(raw);
}
async function isInstallationComplete(paths) {
    try {
        await fs.access(installMarkerPath(paths));
        return true;
    }
    catch {
        return false;
    }
}
async function materializeInstallAssets(assetRoot, paths, onProgress) {
    const report = (message, fraction) => {
        onProgress?.(message, fraction);
    };
    report("Reading installation manifest…", 0);
    const manifest = await readManifest(assetRoot);
    let loadFileCount = 0;
    try {
        const loadEntries = await fs.readdir(path.join(assetRoot, "load"), { withFileTypes: true });
        loadFileCount = loadEntries.filter((e) => e.isFile()).length;
    }
    catch {
        loadFileCount = 0;
    }
    const executableUnits = manifest.executable ? 1 : 0;
    const workUnits = 1 + manifest.directories.length + (manifest.workspaceFiles?.length ?? 0) + loadFileCount + executableUnits + 1;
    let done = 1;
    const tick = (message) => {
        report(message, done / workUnits);
        done += 1;
    };
    for (const dir of manifest.directories) {
        const target = dir === "workspace"
            ? paths.databaseAllPath
            : dir === "tmp"
                ? paths.tmpDir
                : path.join(paths.dataDir, dir);
        tick(`Creating ${dir} directory…`);
        await fs.mkdir(target, { recursive: true });
    }
    const workspaceSrc = path.join(assetRoot, "workspace");
    for (const file of manifest.workspaceFiles ?? []) {
        const src = path.join(workspaceSrc, file);
        const dest = path.join(paths.databaseAllPath, file);
        try {
            await fs.access(dest);
            tick(`Workspace file ${file} already present`);
        }
        catch {
            tick(`Copying workspace file ${file}…`);
            await fs.copyFile(src, dest);
        }
    }
    const loadSrc = path.join(assetRoot, "load");
    const loadDest = path.join(paths.dataDir, "load");
    await fs.mkdir(loadDest, { recursive: true });
    try {
        const entries = await fs.readdir(loadSrc, { withFileTypes: true });
        for (const entry of entries) {
            if (!entry.isFile())
                continue;
            const dest = path.join(loadDest, entry.name);
            try {
                await fs.access(dest);
                tick(`Load file ${entry.name} already present`);
            }
            catch {
                tick(`Copying load file ${entry.name}…`);
                await fs.copyFile(path.join(loadSrc, entry.name), dest);
            }
        }
    }
    catch {
        // optional load/ seed
    }
    if (manifest.executable) {
        if (process.env.MMKIT_CBSERVER_BIN) {
            tick(`Using MMKIT_CBSERVER_BIN for ${manifest.executable.bundleName} (not copied into dataDir)`);
        }
        else {
            const dest = path.join(paths.dataDir, manifest.executable.installRelPath);
            await fs.mkdir(path.dirname(dest), { recursive: true });
            const source = resolveExecutableSource(assetRoot, manifest.executable.bundleName);
            try {
                await fs.access(dest);
                tick(`Executable ${manifest.executable.bundleName} already present`);
            }
            catch {
                tick(`Copying ${manifest.executable.bundleName} executable…`);
                await fs.copyFile(source, dest);
                try {
                    await (0, promises_1.chmod)(dest, 0o755);
                }
                catch {
                    // best effort on platforms without chmod semantics
                }
            }
        }
    }
    tick("Writing installation marker…");
    const marker = path.join(paths.dataDir, manifest.markerFile || shared_1.INSTALL_MARKER_FILE);
    await fs.writeFile(marker, JSON.stringify({ version: manifest.version, installedAt: new Date().toISOString() }, null, 2), "utf8");
    report("Workspace assets installed", 1);
}
//# sourceMappingURL=materialize.js.map