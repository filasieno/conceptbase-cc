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
exports.CbTcpClient = void 0;
const net = __importStar(require("node:net"));
const os = __importStar(require("node:os"));
const shared_1 = require("@mmkit/shared");
class CbTcpClient {
    options;
    socket;
    buffer = "";
    clientId = '""';
    serverId = '"cbserver"';
    connected = false;
    toolName;
    userName;
    connectTimeoutMs;
    socketTimeoutMs;
    constructor(options) {
        this.options = options;
        this.toolName = options.toolName ?? "mmkit-mcp";
        this.userName = options.userName ?? "mmkit";
        this.connectTimeoutMs = options.connectTimeoutMs ?? 10_000;
        this.socketTimeoutMs = options.socketTimeoutMs ?? 120_000;
    }
    get isConnected() {
        return this.connected;
    }
    get host() {
        return this.options.host;
    }
    get port() {
        return this.options.port;
    }
    get clientName() {
        return this.clientId;
    }
    get serverName() {
        return this.serverId;
    }
    async connect() {
        if (this.connected) {
            return { completion: "ok", ok: true, result: this.clientId };
        }
        await this.openSocket();
        const userSuffix = `${this.userName}@${os.hostname()}_${os.arch()}_${os.platform().replace(/\s/g, "")}`;
        const payload = (0, shared_1.buildEnrollPayload)(this.toolName, userSuffix);
        const answer = await this.sendMessage("ENROLL_ME", payload, '""', '""');
        if (answer.ok) {
            this.connected = true;
            if (answer.respondingTool) {
                this.serverId = answer.respondingTool;
            }
            if (answer.result) {
                this.clientId = (0, shared_1.encodeCbString)(answer.result);
            }
        }
        return answer;
    }
    async disconnect() {
        if (!this.connected || !this.socket) {
            return { completion: "ok", ok: true };
        }
        const answer = await this.sendMessage("CANCEL_ME", "", this.clientId, this.serverId);
        this.connected = false;
        this.socket.destroy();
        this.socket = undefined;
        return answer;
    }
    async tell(frames) {
        return this.sendMessage("TELL", (0, shared_1.encodeCbString)(frames));
    }
    async tellTransactions(transactions) {
        const parts = transactions.split(/\{---\}/);
        let merged;
        for (const part of parts) {
            const ans = await this.tell(part);
            merged = ans;
            if (!ans.ok)
                return ans;
        }
        return merged ?? { completion: "ok", ok: true };
    }
    async untell(frames) {
        return this.sendMessage("UNTELL", (0, shared_1.encodeCbString)(frames));
    }
    async tellModel(files) {
        const encoded = `[${files.map((f) => (0, shared_1.encodeCbString)(f)).join(",")}]`;
        return this.sendMessage("TELL_MODEL", encoded);
    }
    async retell(untellFrames, tellFrames) {
        const payload = `[${(0, shared_1.encodeCbString)(untellFrames)},${(0, shared_1.encodeCbString)(tellFrames)}]`;
        return this.sendMessage("RETELL", payload);
    }
    async ask(query, queryFormat = "OBJNAMES", answerRep = "LABEL", rollbackTime = "Now") {
        const payload = `${queryFormat},${(0, shared_1.encodeCbString)(query)},${(0, shared_1.encodeCbString)(answerRep)},${(0, shared_1.encodeCbString)(rollbackTime)}`;
        return this.sendMessage("ASK", payload);
    }
    async askFrames(query, answerRep = "LABEL", rollbackTime = "Now") {
        return this.ask(query, "FRAMES", answerRep, rollbackTime);
    }
    async askObjNames(query, answerRep = "LABEL", rollbackTime = "Now") {
        return this.ask(query, "OBJNAMES", answerRep, rollbackTime);
    }
    async hypoAsk(frames, query, queryFormat, answerRep, rollbackTime) {
        const payload = `${(0, shared_1.encodeCbString)(frames)},${queryFormat},${(0, shared_1.encodeCbString)(query)},${(0, shared_1.encodeCbString)(answerRep)},${(0, shared_1.encodeCbString)(rollbackTime)}`;
        return this.sendMessage("HYPO_ASK", payload);
    }
    async getObject(objname) {
        const ans = await this.ask(`get_object[${objname}/objname]`, "OBJNAMES", "FRAME", "Now");
        return ans.ok ? (ans.result ?? "error") : "error";
    }
    async findInstances(objname) {
        const ans = await this.ask(`find_instances[${objname}/class]`, "OBJNAMES", "LABEL", "Now");
        return ans.ok ? (ans.result ?? "error") : "error";
    }
    async stopServer() {
        const ans = await this.sendMessage("STOP_SERVER", "");
        if (ans.ok) {
            this.connected = false;
            this.socket?.destroy();
            this.socket = undefined;
        }
        return ans;
    }
    async lpiCall(lpicall) {
        return this.sendMessage("LPI_CALL", (0, shared_1.encodeCbString)(lpicall));
    }
    async nextMessage(messageType) {
        return this.sendMessage("NEXT_MESSAGE", messageType);
    }
    async setModule(modulePath) {
        return this.sendMessage("SET_MODULE_CONTEXT", (0, shared_1.encodeCbString)(quoteModuleNames(modulePath)));
    }
    async getModule() {
        const ans = await this.sendMessage("GET_MODULE_CONTEXT", "");
        return ans.result;
    }
    async getModulePath() {
        return this.sendMessage("GET_MODULE_PATH", "");
    }
    async listModule(module) {
        const ans = await this.ask(`listModule[${module}/module]`, "OBJNAMES", "FRAME", "Now");
        return ans.ok ? ans.result : undefined;
    }
    async notificationRequest(about, tool) {
        const target = tool ?? this.clientId;
        return this.sendMessage("NOTIFICATION_REQUEST", `${(0, shared_1.encodeCbString)(about)},${target}`);
    }
    async disconnectSimple() {
        const ans = await this.disconnect();
        return ans.ok ? "yes" : "no";
    }
    async tells(frames) {
        const ans = await this.tell(frames);
        return ans.ok ? "yes" : (ans.result ?? "no");
    }
    async untells(frames) {
        const ans = await this.untell(frames);
        return ans.ok ? "yes" : (ans.result ?? "no");
    }
    async asks(query, format) {
        const ans = format
            ? await this.ask(query, "OBJNAMES", format, "Now")
            : await this.ask(query, "OBJNAMES", "LABEL", "Now");
        return ans.ok ? (ans.result ?? "no") : "no";
    }
    async pwd() {
        const ans = await this.getModulePath();
        return ans.ok ? (ans.result ?? "no") : "no";
    }
    async cd(newModule) {
        const ans = await this.setModule(newModule);
        return ans.ok ? "yes" : "no";
    }
    async mkdir(newModule) {
        const ans = await this.tell(`:MOD-CB-NAME ${newModule}\n:MOD-CB-TYPE SubModule.`);
        return ans.ok ? "yes" : "no";
    }
    async openSocket() {
        if (this.socket)
            return;
        const { host, port } = this.options;
        this.socket = await new Promise((resolve, reject) => {
            const socket = new net.Socket();
            socket.setTimeout(this.socketTimeoutMs);
            socket.once("timeout", () => {
                socket.destroy();
                reject(new Error("connect timeout"));
            });
            socket.once("error", reject);
            socket.connect(port, host, () => {
                socket.setTimeout(this.socketTimeoutMs);
                resolve(socket);
            });
        });
    }
    async sendMessage(method, data, client = this.clientId, server = this.serverId) {
        if (!this.socket) {
            return { completion: "broken", ok: false, result: "not connected" };
        }
        const message = (0, shared_1.buildIpcMessage)(client, server, method, data);
        const frame = (0, shared_1.lengthPrefix)(message);
        return new Promise((resolve) => {
            this.socket.write(frame, async (err) => {
                if (err) {
                    resolve({ completion: "broken", ok: false, result: String(err) });
                    return;
                }
                try {
                    const parsed = await this.readAnswer();
                    resolve((0, shared_1.toCbAnswer)(parsed));
                }
                catch (e) {
                    resolve({ completion: "broken", ok: false, result: String(e) });
                }
            });
        });
    }
    readAnswer() {
        return new Promise((resolve, reject) => {
            const socket = this.socket;
            if (!socket) {
                reject(new Error("no socket"));
                return;
            }
            const onData = (chunk) => {
                this.buffer += chunk.toString("utf8");
                const newline = this.buffer.indexOf("\n");
                if (newline < 0)
                    return;
                const len = Number.parseInt(this.buffer.slice(0, newline), 10);
                const bodyStart = newline + 1;
                if (this.buffer.length < bodyStart + len)
                    return;
                const body = this.buffer.slice(bodyStart, bodyStart + len);
                this.buffer = this.buffer.slice(bodyStart + len);
                socket.off("data", onData);
                resolve((0, shared_1.parseAnswerTerm)(body));
            };
            socket.on("data", onData);
            socket.once("error", reject);
            socket.once("timeout", () => reject(new Error("read timeout")));
        });
    }
}
exports.CbTcpClient = CbTcpClient;
function quoteModuleNames(modulePath) {
    if (/(.*)-[0-9](.*)/.test(modulePath)) {
        return `'${modulePath.replaceAll("-", "'-'")}'`;
    }
    if (/(.*)\/[0-9](.*)/.test(modulePath)) {
        return `'${modulePath.replaceAll("/", "'/'")}'`;
    }
    return modulePath;
}
//# sourceMappingURL=cb-tcp-client.js.map