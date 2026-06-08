"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createRealPorts = createRealPorts;
const asset_port_1 = require("./real/asset-port");
const docker_port_1 = require("./real/docker-port");
const fs_port_1 = require("./real/fs-port");
const network_port_1 = require("./real/network-port");
const process_port_1 = require("./real/process-port");
function createRealPorts(assetRoot) {
    return {
        fs: new fs_port_1.RealFsPort(),
        assets: new asset_port_1.RealAssetPort(assetRoot ?? (0, asset_port_1.resolveAssetRoot)()),
        process: new process_port_1.RealProcessPort(),
        docker: new docker_port_1.RealDockerPort(),
        network: new network_port_1.RealNetworkPort(),
    };
}
//# sourceMappingURL=index.js.map