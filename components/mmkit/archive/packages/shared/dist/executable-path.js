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
exports.installedCbserverPath = installedCbserverPath;
exports.resolveExecutableCommand = resolveExecutableCommand;
const fs = __importStar(require("node:fs"));
const path = __importStar(require("node:path"));
const constants_1 = require("./constants");
function installedCbserverPath(paths) {
    return path.join(paths.dataDir, constants_1.CBSERVER_INSTALL_REL_PATH);
}
function envCbserverBin() {
    const bin = process.env.MMKIT_CBSERVER_BIN;
    if (!bin)
        return undefined;
    const resolved = path.resolve(bin);
    try {
        fs.accessSync(resolved, fs.constants.X_OK);
        return resolved;
    }
    catch {
        try {
            fs.accessSync(resolved);
            return resolved;
        }
        catch {
            return undefined;
        }
    }
}
function resolveExecutableCommand(paths, executablePath, devCommand) {
    if (devCommand) {
        return devCommand;
    }
    const fromEnv = envCbserverBin();
    if (fromEnv) {
        return fromEnv;
    }
    const installed = installedCbserverPath(paths);
    try {
        fs.accessSync(installed, fs.constants.X_OK);
        return installed;
    }
    catch {
        // fall through
    }
    try {
        fs.accessSync(installed);
        return installed;
    }
    catch {
        // fall through
    }
    if (executablePath) {
        return executablePath;
    }
    return installed;
}
//# sourceMappingURL=executable-path.js.map