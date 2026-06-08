"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.RealProcessPort = void 0;
const node_child_process_1 = require("node:child_process");
const node_events_1 = require("node:events");
class RealProcessPort {
    tracked = new Map();
    async spawn(spec) {
        const child = (0, node_child_process_1.spawn)(spec.command, spec.args, {
            env: { ...process.env, ...spec.env },
            cwd: spec.cwd,
            // cbserver is verbose on stdout/stderr; unread pipes stall startup before the port opens.
            stdio: "ignore",
        });
        const emitter = new node_events_1.EventEmitter();
        const pid = child.pid ?? -1;
        this.tracked.set(pid, { child, emitter });
        child.on("exit", (code, signal) => {
            emitter.emit("exit", code, signal);
            this.tracked.delete(pid);
        });
        return { pid, command: spec.command };
    }
    async kill(pid, signal = "SIGTERM") {
        this.tracked.get(pid)?.child.kill(signal);
    }
    async isRunning(pid) {
        const entry = this.tracked.get(pid);
        if (!entry)
            return false;
        return entry.child.exitCode === null && !entry.child.killed;
    }
    onExit(pid, cb) {
        const entry = this.tracked.get(pid);
        if (!entry)
            return () => undefined;
        entry.emitter.on("exit", cb);
        return () => entry.emitter.off("exit", cb);
    }
}
exports.RealProcessPort = RealProcessPort;
//# sourceMappingURL=process-port.js.map