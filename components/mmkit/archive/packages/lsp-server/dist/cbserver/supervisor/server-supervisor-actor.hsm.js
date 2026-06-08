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
var __esDecorate = (this && this.__esDecorate) || function (ctor, descriptorIn, decorators, contextIn, initializers, extraInitializers) {
    function accept(f) { if (f !== void 0 && typeof f !== "function") throw new TypeError("Function expected"); return f; }
    var kind = contextIn.kind, key = kind === "getter" ? "get" : kind === "setter" ? "set" : "value";
    var target = !descriptorIn && ctor ? contextIn["static"] ? ctor : ctor.prototype : null;
    var descriptor = descriptorIn || (target ? Object.getOwnPropertyDescriptor(target, contextIn.name) : {});
    var _, done = false;
    for (var i = decorators.length - 1; i >= 0; i--) {
        var context = {};
        for (var p in contextIn) context[p] = p === "access" ? {} : contextIn[p];
        for (var p in contextIn.access) context.access[p] = contextIn.access[p];
        context.addInitializer = function (f) { if (done) throw new TypeError("Cannot add initializers after decoration has completed"); extraInitializers.push(accept(f || null)); };
        var result = (0, decorators[i])(kind === "accessor" ? { get: descriptor.get, set: descriptor.set } : descriptor[key], context);
        if (kind === "accessor") {
            if (result === void 0) continue;
            if (result === null || typeof result !== "object") throw new TypeError("Object expected");
            if (_ = accept(result.get)) descriptor.get = _;
            if (_ = accept(result.set)) descriptor.set = _;
            if (_ = accept(result.init)) initializers.unshift(_);
        }
        else if (_ = accept(result)) {
            if (kind === "field") initializers.unshift(_);
            else descriptor[key] = _;
        }
    }
    if (target) Object.defineProperty(target, contextIn.name, descriptor);
    done = true;
};
var __runInitializers = (this && this.__runInitializers) || function (thisArg, initializers, value) {
    var useValue = arguments.length > 2;
    for (var i = 0; i < initializers.length; i++) {
        value = useValue ? initializers[i].call(thisArg, value) : initializers[i].call(thisArg);
    }
    return useValue ? value : void 0;
};
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
exports.ShuttingDown = exports.Active = exports.Bootstrapping = exports.Inactive = exports.SupervisorTop = void 0;
exports.createServerSupervisorActor = createServerSupervisorActor;
exports.buildSupervisorState = buildSupervisorState;
const ihsm = __importStar(require("ihsm"));
const lsp_hsm_factory_1 = require("../../lsp/lsp-hsm-factory");
const mmkit_server_actor_hsm_1 = require("../mmkit-server/mmkit-server-actor.hsm");
const server_supervisor_state_1 = require("./server-supervisor-state");
class SupervisorTop extends ihsm.TopState {
    get mmkitServer() {
        return this.ctx.mmkitServer;
    }
    buildState() {
        const childName = this.mmkitServer?.currentStateName ?? "Idle";
        return {
            phase: (0, server_supervisor_state_1.mapActorStateToPhase)(childName),
            port: this.ctx.snapshot?.server.port,
            generation: this.ctx.generation,
        };
    }
    createMmkitNotifier() {
        return {
            emitState: (n) => this.post("mmkitServerState", n),
            reportInstallProgress: (message, percent) => this.post("mmkitServerInstallProgress", message, percent),
            showInstallProgress: (title) => this.post("mmkitServerShowProgress", title),
            hideInstallProgress: () => this.post("mmkitServerHideProgress"),
        };
    }
    createHandlerSink() {
        const supervisor = this.hsm;
        return {
            onServerStart: async (params) => {
                supervisor.post("lspServerStart", params);
                await supervisor.sync();
                return supervisor.ctx.lastStartResult ?? { ok: false, state: this.buildState() };
            },
            onServerStop: async () => {
                supervisor.post("lspServerStop");
                await supervisor.sync();
                return supervisor.ctx.lastStopResult ?? { ok: true };
            },
            onServerRestart: async (params) => {
                supervisor.post("lspServerRestart", params);
                await supervisor.sync();
                return supervisor.ctx.lastStartResult ?? { ok: false, state: this.buildState() };
            },
            onServerStatus: async () => this.buildState(),
            onConfigUpdate: async (params) => {
                supervisor.post("lspConfigUpdate", params);
                await supervisor.sync();
                return supervisor.ctx.lastConfigUpdateResult ?? { generation: supervisor.ctx.generation };
            },
            onOtelTest: async (config) => {
                supervisor.post("lspOtelTest", config);
                await supervisor.sync();
                return supervisor.ctx.lastOtelResult ?? { ok: false, message: "no result", latencyMs: 0 };
            },
        };
    }
    hostStart() {
        this.transition(Bootstrapping);
    }
    async hostShutdown() {
        this.ctx.shutdownRequested = true;
        if (this.mmkitServer) {
            this.mmkitServer.post("shutdownRequested");
            await this.mmkitServer.sync();
        }
        this.transition(ShuttingDown);
    }
    mmkitServerState(notification) {
        this.ctx.port.sendStateNotification(notification);
    }
    mmkitServerInstallProgress(message, percent) {
        this.ctx.port.reportInstallProgress(message, percent);
    }
    mmkitServerShowProgress(title) {
        this.ctx.port.beginInstallProgress(title);
        this.ctx.port.setProgressVisible(true);
    }
    mmkitServerHideProgress() {
        this.ctx.port.endInstallProgress();
        this.ctx.port.setProgressVisible(false);
    }
}
exports.SupervisorTop = SupervisorTop;
let Inactive = (() => {
    var _a;
    let _classDecorators = [(_a = ihsm).InitialState.bind(_a)];
    let _classDescriptor;
    let _classExtraInitializers = [];
    let _classThis;
    let _classSuper = SupervisorTop;
    var Inactive = class extends _classSuper {
        static { _classThis = this; }
        static {
            const _metadata = typeof Symbol === "function" && Symbol.metadata ? Object.create(_classSuper[Symbol.metadata] ?? null) : void 0;
            __esDecorate(null, _classDescriptor = { value: _classThis }, _classDecorators, { kind: "class", name: _classThis.name, metadata: _metadata }, null, _classExtraInitializers);
            Inactive = _classThis = _classDescriptor.value;
            if (_metadata) Object.defineProperty(_classThis, Symbol.metadata, { enumerable: true, configurable: true, writable: true, value: _metadata });
            __runInitializers(_classThis, _classExtraInitializers);
        }
    };
    return Inactive = _classThis;
})();
exports.Inactive = Inactive;
class Bootstrapping extends SupervisorTop {
    onEntry() {
        this.postNow("bootstrapRegisterHandlers");
    }
    bootstrapRegisterHandlers() {
        this.ctx.port.registerLspHandlers(this.createHandlerSink());
        this.postNow("bootstrapSpawnMmkitServer");
    }
    bootstrapSpawnMmkitServer() {
        this.ctx.mmkitServer = (0, mmkit_server_actor_hsm_1.createMmkitServerActor)({
            ports: this.ctx.port.getServerPorts(),
            notifier: this.createMmkitNotifier(),
            shutdownRequested: false,
            progressVisible: this.ctx.port.isProgressVisible(),
        });
        this.transition(Active);
    }
}
exports.Bootstrapping = Bootstrapping;
class Active extends SupervisorTop {
    async lspServerStart(params) {
        if (!params.snapshot.valid) {
            this.ctx.lastStartResult = {
                ok: false,
                state: this.buildState(),
                errors: params.snapshot.errors,
            };
            return;
        }
        this.ctx.snapshot = params.snapshot;
        this.ctx.generation = params.generation;
        this.mmkitServer?.post("userStart", params.snapshot, params.generation);
        await this.mmkitServer?.sync();
        this.ctx.lastStartResult = { ok: true, state: this.buildState() };
    }
    async lspServerStop() {
        this.mmkitServer?.post("userStop");
        await this.mmkitServer?.sync();
        this.ctx.lastStopResult = { ok: true };
    }
    async lspServerRestart(params) {
        this.mmkitServer?.post("userStop");
        await this.mmkitServer?.sync();
        if (!params.snapshot.valid) {
            this.ctx.lastStartResult = {
                ok: false,
                state: this.buildState(),
                errors: params.snapshot.errors,
            };
            return;
        }
        this.ctx.snapshot = params.snapshot;
        this.ctx.generation = params.generation;
        this.mmkitServer?.post("userStart", params.snapshot, params.generation);
        await this.mmkitServer?.sync();
        this.ctx.lastStartResult = { ok: true, state: this.buildState() };
    }
    async lspConfigUpdate(params) {
        this.ctx.snapshot = params.snapshot;
        this.ctx.generation = params.snapshot.generation;
        this.mmkitServer?.post("snapshotUpdated", params.snapshot);
        await this.mmkitServer?.sync();
        this.ctx.lastConfigUpdateResult = { generation: this.ctx.generation };
    }
    async lspOtelTest(config) {
        this.ctx.lastOtelResult = await this.ctx.port.probeOtelEndpoint(config);
    }
}
exports.Active = Active;
class ShuttingDown extends SupervisorTop {
}
exports.ShuttingDown = ShuttingDown;
ihsm.registerStateNames({
    Inactive,
    Bootstrapping,
    Active,
    ShuttingDown,
});
function createServerSupervisorActor(ctx) {
    return (0, lsp_hsm_factory_1.createLspHsm)(SupervisorTop, ctx);
}
function buildSupervisorState(hsm) {
    const childName = hsm.ctx.mmkitServer?.currentStateName ?? "Idle";
    return {
        phase: (0, server_supervisor_state_1.mapActorStateToPhase)(childName),
        port: hsm.ctx.snapshot?.server.port,
        generation: hsm.ctx.generation,
    };
}
//# sourceMappingURL=server-supervisor-actor.hsm.js.map