"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ServerSupervisor = void 0;
const real_supervisor_port_1 = require("./ports/real-supervisor-port");
const server_supervisor_actor_hsm_1 = require("./server-supervisor-actor.hsm");
/** Thin façade over the supervisor ihsm actor for LSP/MCP wiring. */
class ServerSupervisor {
    hsm;
    constructor(options) {
        const port = (0, real_supervisor_port_1.createRealSupervisorPort)(options);
        const ctx = {
            port,
            generation: 0,
            shutdownRequested: false,
        };
        this.hsm = (0, server_supervisor_actor_hsm_1.createServerSupervisorActor)(ctx);
    }
    start() {
        this.hsm.post("hostStart");
    }
    getState() {
        return (0, server_supervisor_actor_hsm_1.buildSupervisorState)(this.hsm);
    }
    async shutdown() {
        this.hsm.post("hostShutdown");
        await this.hsm.sync();
    }
}
exports.ServerSupervisor = ServerSupervisor;
//# sourceMappingURL=server-supervisor.js.map