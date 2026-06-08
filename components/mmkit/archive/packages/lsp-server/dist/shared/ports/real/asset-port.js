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
exports.RealAssetPort = void 0;
exports.resolveAssetRoot = resolveAssetRoot;
const path = __importStar(require("node:path"));
const materialize_1 = require("../../../cbserver/mmkit-server/install/materialize");
class RealAssetPort {
    assetRoot;
    constructor(assetRoot) {
        this.assetRoot = assetRoot;
    }
    getAssetRoot() {
        return this.assetRoot;
    }
    isInstallationComplete(paths) {
        return (0, materialize_1.isInstallationComplete)(paths);
    }
    materialize(paths, onProgress) {
        return (0, materialize_1.materializeInstallAssets)(this.assetRoot, paths, onProgress);
    }
}
exports.RealAssetPort = RealAssetPort;
function resolveAssetRoot() {
    if (process.env.MMKIT_ASSET_ROOT) {
        return path.resolve(process.env.MMKIT_ASSET_ROOT);
    }
    return path.resolve(__dirname, "..", "..", "..", "..", "extension", "assets", "cbserver");
}
//# sourceMappingURL=asset-port.js.map