"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.CbMcpSession = void 0;
const cb_tcp_client_1 = require("./cb-tcp-client");
class CbMcpSession {
    supervisor;
    client;
    constructor(supervisor) {
        this.supervisor = supervisor;
    }
    async getClient(params = {}) {
        const state = this.supervisor.getState();
        const host = params.host ?? "127.0.0.1";
        const port = params.port ?? state.port;
        if (!port) {
            throw new Error("mmkit server is not running (no port)");
        }
        if (!this.client || this.client.host !== host || this.client.port !== port) {
            this.client = new cb_tcp_client_1.CbTcpClient({
                host,
                port,
                toolName: params.toolName,
                userName: params.userName,
            });
        }
        if (!this.client.isConnected) {
            const answer = await this.client.connect();
            if (!answer.ok) {
                throw new Error(answer.result ?? "ENROLL_ME failed");
            }
        }
        return this.client;
    }
    async disconnect() {
        if (this.client?.isConnected) {
            await this.client.disconnect();
        }
        this.client = undefined;
    }
}
exports.CbMcpSession = CbMcpSession;
//# sourceMappingURL=cb-session.js.map