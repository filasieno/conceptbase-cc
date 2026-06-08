"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.RealDockerPort = void 0;
const node_child_process_1 = require("node:child_process");
class RealDockerPort {
    async run(spec) {
        return new Promise((resolve, reject) => {
            const child = (0, node_child_process_1.spawn)(spec.command, spec.args, { stdio: "ignore", detached: true });
            child.unref();
            child.once("error", reject);
            child.once("spawn", () => resolve({ pid: child.pid ?? 0, command: spec.command }));
        });
    }
    async stop(containerName) {
        await new Promise((resolve, reject) => {
            const child = (0, node_child_process_1.spawn)("docker", ["rm", "-f", containerName], { stdio: "ignore" });
            child.once("error", reject);
            child.once("exit", () => resolve());
        });
    }
    async isRunning(containerName) {
        return new Promise((resolve) => {
            const child = (0, node_child_process_1.spawn)("docker", ["inspect", "-f", "{{.State.Running}}", containerName], {
                stdio: ["ignore", "pipe", "ignore"],
            });
            let out = "";
            child.stdout.on("data", (d) => (out += d.toString()));
            child.once("exit", (code) => resolve(code === 0 && out.trim() === "true"));
            child.once("error", () => resolve(false));
        });
    }
    imageExists(image) {
        return new Promise((resolve) => {
            const child = (0, node_child_process_1.spawn)("docker", ["image", "inspect", image], { stdio: "ignore" });
            child.once("exit", (code) => resolve(code === 0));
            child.once("error", () => resolve(false));
        });
    }
    pullImage(image, onProgress) {
        return new Promise((resolve, reject) => {
            onProgress?.(`Pulling Docker image ${image}…`, 0);
            const child = (0, node_child_process_1.spawn)("docker", ["pull", image], { stdio: ["ignore", "pipe", "pipe"] });
            child.stdout.on("data", (chunk) => {
                for (const line of chunk.toString().split(/\r?\n/)) {
                    if (line.trim())
                        onProgress?.(line.trim(), 0.5);
                }
            });
            child.stderr.on("data", (chunk) => {
                const line = chunk.toString().trim();
                if (line)
                    onProgress?.(line, 0.5);
            });
            child.once("error", reject);
            child.once("exit", (code) => {
                if (code === 0) {
                    onProgress?.(`Image ${image} ready`, 1);
                    resolve();
                    return;
                }
                reject(new Error(`docker pull failed (${code})`));
            });
        });
    }
}
exports.RealDockerPort = RealDockerPort;
//# sourceMappingURL=docker-port.js.map