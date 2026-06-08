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
exports.ShuttingDown = exports.Stopping = exports.Running = exports.InstallingAwaitPort = exports.InstallingLaunchContainer = exports.InstallingEnsureDockerImage = exports.InstallingMaterializeAssets = exports.InstallingPrepare = exports.Installing = exports.Starting = exports.Idle = exports.ServerTop = void 0;
exports.createMmkitServerActor = createMmkitServerActor;
const ihsm = __importStar(require("ihsm"));
const shared_1 = require("@mmkit/shared");
const lsp_hsm_factory_1 = require("../../lsp/lsp-hsm-factory");
const launch_spec_1 = require("./launch-spec");
const progress_1 = require("./install/progress");
const server_notifier_1 = require("./server-notifier");
class ServerTop extends ihsm.TopState {
    traceLevelChanged(_level) { }
    emitState(message, fault) {
        const phase = (0, server_notifier_1.phaseFromStateName)(this.hsm.currentStateName);
        this.ctx.notifier.emitState({
            phase,
            port: this.ctx.snapshot?.server.port,
            message,
            fault,
            generation: this.ctx.generation,
        });
    }
    reportInstallProgress(message, percent) {
        this.ctx.notifier.reportInstallProgress(message, percent);
    }
    reportInstallStep(step, fraction, message) {
        const percent = (0, progress_1.percentWithinStep)(step, fraction);
        this.reportProgress(message, percent);
    }
    reportProgress(message, percent) {
        this.maybeShowSlowStartProgress();
        this.reportInstallProgress(message, percent);
    }
    hideProgressIfVisible() {
        if (this.ctx.progressVisible) {
            this.ctx.notifier.hideInstallProgress();
            this.ctx.progressVisible = false;
        }
    }
    isInstallInFlight() {
        const state = this.hsm.currentStateName;
        return state === "Starting" || state.startsWith("Installing");
    }
    maybeShowSlowStartProgress() {
        if (this.ctx.progressVisible || !this.isInstallInFlight())
            return;
        const startedAt = this.ctx.startRequestedAt;
        if (startedAt === undefined || Date.now() - startedAt < shared_1.FAST_START_THRESHOLD_MS)
            return;
        this.ctx.notifier.showInstallProgress("Starting mmkit server");
        this.ctx.progressVisible = true;
        this.ctx.notifier.reportInstallProgress("Preparing mmkit server…", 0);
    }
    armFastStartWatchdog() {
        this.clearFastStartWatchdog();
        this.ctx.startRequestedAt = Date.now();
        this.ctx.fastStartTimer = setTimeout(() => {
            this.ctx.fastStartTimer = undefined;
            this.post("fastStartThresholdElapsed");
        }, shared_1.FAST_START_THRESHOLD_MS);
    }
    clearFastStartWatchdog() {
        if (this.ctx.fastStartTimer === undefined)
            return;
        clearTimeout(this.ctx.fastStartTimer);
        this.ctx.fastStartTimer = undefined;
    }
    async tearDownServer() {
        this.hideProgressIfVisible();
        this.ctx.exitUnsubscribe?.();
        this.ctx.exitUnsubscribe = undefined;
        if (this.ctx.containerName) {
            try {
                await this.ctx.ports.docker.stop(this.ctx.containerName);
            }
            catch {
                // best effort
            }
            this.ctx.containerName = undefined;
        }
        if (this.ctx.pid !== undefined) {
            try {
                await this.ctx.ports.process.kill(this.ctx.pid);
            }
            catch {
                // best effort
            }
            this.ctx.pid = undefined;
        }
        if (this.ctx.shutdownRequested) {
            if (this.hsm.currentStateName !== "ShuttingDown") {
                this.transition(ShuttingDown);
            }
            return;
        }
        this.transition(Idle);
    }
    snapshotUpdated(snapshot) {
        this.ctx.snapshot = snapshot;
    }
    fastStartThresholdElapsed() {
        this.clearFastStartWatchdog();
        this.maybeShowSlowStartProgress();
    }
    userStart(snapshot, generation) {
        this.ctx.snapshot = snapshot;
        this.ctx.generation = generation;
        if (!snapshot.valid) {
            this.emitState(undefined, "Cannot start server: invalid configuration");
            return;
        }
        this.transition(Starting);
    }
    userStop() {
        this.transition(Stopping);
    }
    shutdownRequested() {
        this.ctx.shutdownRequested = true;
        this.transition(Stopping);
    }
    delay(ms) {
        return new Promise((resolve) => setTimeout(resolve, ms));
    }
}
exports.ServerTop = ServerTop;
let Idle = (() => {
    var _a;
    let _classDecorators = [(_a = ihsm).InitialState.bind(_a)];
    let _classDescriptor;
    let _classExtraInitializers = [];
    let _classThis;
    let _classSuper = ServerTop;
    var Idle = class extends _classSuper {
        static { _classThis = this; }
        static {
            const _metadata = typeof Symbol === "function" && Symbol.metadata ? Object.create(_classSuper[Symbol.metadata] ?? null) : void 0;
            __esDecorate(null, _classDescriptor = { value: _classThis }, _classDecorators, { kind: "class", name: _classThis.name, metadata: _metadata }, null, _classExtraInitializers);
            Idle = _classThis = _classDescriptor.value;
            if (_metadata) Object.defineProperty(_classThis, Symbol.metadata, { enumerable: true, configurable: true, writable: true, value: _metadata });
            __runInitializers(_classThis, _classExtraInitializers);
        }
        onEntry() {
            this.clearFastStartWatchdog();
            this.hideProgressIfVisible();
            this.emitState("mmkit server idle");
        }
        userStart(snapshot, generation) {
            this.ctx.snapshot = snapshot;
            this.ctx.generation = generation;
            if (!snapshot.valid) {
                this.emitState(undefined, "Cannot start server: invalid configuration");
                return;
            }
            this.transition(Starting);
        }
        userStop() { }
    };
    return Idle = _classThis;
})();
exports.Idle = Idle;
class Starting extends ServerTop {
    onEntry() {
        this.emitState("Starting mmkit server");
        this.armFastStartWatchdog();
        this.postNow("beginInstallPipeline");
    }
    beginInstallPipeline() {
        this.reportInstallStep("prepare", 0, "Starting mmkit server installation…");
        this.transition(InstallingPrepare);
    }
}
exports.Starting = Starting;
class Installing extends ServerTop {
    requireSnapshot() {
        const snapshot = this.ctx.snapshot;
        if (!snapshot) {
            this.postNow("installFailed", "missing configuration snapshot");
            return undefined;
        }
        return snapshot;
    }
    installFailed(error) {
        this.emitState(undefined, error);
        this.postNow("installFailureTeardown");
    }
    async installFailureTeardown() {
        await this.tearDownServer();
    }
    portReady() {
        this.transition(Running);
    }
    processExited(code) {
        this.emitState(undefined, `mmkit server exited with code ${code} during install`);
        this.transition(Idle);
    }
}
exports.Installing = Installing;
class InstallingPrepare extends Installing {
    onEntry() {
        this.postNow("installPrepare");
    }
    async installPrepare() {
        const snapshot = this.requireSnapshot();
        if (!snapshot)
            return;
        try {
            const dirs = [
                { label: "data", path: snapshot.paths.dataDir },
                { label: "temporary", path: snapshot.paths.tmpDir },
                { label: "load", path: snapshot.paths.loadDir },
                { label: "workspace", path: snapshot.paths.databaseAllPath },
            ];
            for (let i = 0; i < dirs.length; i += 1) {
                const { label, path: dirPath } = dirs[i];
                this.reportInstallStep("prepare", i / dirs.length, `Creating ${label} directory…`);
                await this.ctx.ports.fs.ensureDir(dirPath);
            }
            this.reportInstallStep("prepare", 1, "Data directories ready");
            this.transition(InstallingMaterializeAssets);
        }
        catch (err) {
            this.postNow("installFailed", `prepare failed: ${String(err)}`);
        }
    }
}
exports.InstallingPrepare = InstallingPrepare;
class InstallingMaterializeAssets extends Installing {
    onEntry() {
        this.postNow("installMaterializeAssets");
    }
    async installMaterializeAssets() {
        const snapshot = this.requireSnapshot();
        if (!snapshot)
            return;
        try {
            const complete = await this.ctx.ports.assets.isInstallationComplete(snapshot.paths);
            if (!complete) {
                await this.ctx.ports.assets.materialize(snapshot.paths, (message, fraction) => {
                    this.reportInstallStep("materialize", fraction, message);
                });
            }
            else {
                this.reportInstallStep("materialize", 1, "Workspace already installed");
            }
            this.transition(InstallingEnsureDockerImage);
        }
        catch (err) {
            this.postNow("installFailed", `materialize failed: ${String(err)}`);
        }
    }
}
exports.InstallingMaterializeAssets = InstallingMaterializeAssets;
class InstallingEnsureDockerImage extends Installing {
    onEntry() {
        this.postNow("installEnsureDockerImage");
    }
    async installEnsureDockerImage() {
        const snapshot = this.requireSnapshot();
        if (!snapshot)
            return;
        try {
            if (snapshot.server.launchKind !== "docker") {
                this.reportInstallStep("dockerImage", 1, "Using local mmkit server executable");
                this.transition(InstallingLaunchContainer);
                return;
            }
            const image = snapshot.server.dockerImage;
            this.reportInstallStep("dockerImage", 0, `Checking Docker image ${image}…`);
            const exists = await this.ctx.ports.docker.imageExists(image);
            if (!exists) {
                await this.ctx.ports.docker.pullImage(image, (message, fraction) => {
                    this.reportInstallStep("dockerImage", fraction, message);
                });
            }
            else {
                this.reportInstallStep("dockerImage", 1, `Docker image ${image} already present`);
            }
            this.transition(InstallingLaunchContainer);
        }
        catch (err) {
            this.postNow("installFailed", `docker image failed: ${String(err)}`);
        }
    }
}
exports.InstallingEnsureDockerImage = InstallingEnsureDockerImage;
class InstallingLaunchContainer extends Installing {
    onEntry() {
        this.postNow("installLaunchContainer");
    }
    async installLaunchContainer() {
        const snapshot = this.requireSnapshot();
        if (!snapshot)
            return;
        const spec = (0, launch_spec_1.buildLaunchSpec)(snapshot);
        const launchLabel = spec.kind === "docker" ? "container" : "process";
        this.reportInstallStep("launch", 0, `Starting mmkit server ${launchLabel}…`);
        try {
            if (spec.kind === "docker") {
                const info = await this.ctx.ports.docker.run(spec);
                this.ctx.containerName = snapshot.server.dockerContainerName;
                this.ctx.pid = info.pid;
                this.reportInstallStep("launch", 0.7, `Container ${snapshot.server.dockerContainerName} started`);
            }
            else {
                const info = await this.ctx.ports.process.spawn(spec);
                this.ctx.pid = info.pid;
                this.ctx.exitUnsubscribe = this.ctx.ports.process.onExit(info.pid, (code) => {
                    this.postNow("processExited", code);
                });
                this.reportInstallStep("launch", 0.7, `mmkit server process started (pid ${info.pid})`);
            }
            this.reportInstallStep("launch", 1, "mmkit server launched");
            this.transition(InstallingAwaitPort);
        }
        catch (err) {
            this.postNow("installFailed", `Launch failed: ${String(err)}`);
        }
    }
}
exports.InstallingLaunchContainer = InstallingLaunchContainer;
class InstallingAwaitPort extends Installing {
    onEntry() {
        this.postNow("installAwaitPort");
    }
    async installAwaitPort() {
        const snapshot = this.requireSnapshot();
        if (!snapshot)
            return;
        try {
            const maxAttempts = Number(process.env.MMKIT_PORT_PROBE_ATTEMPTS ?? "120");
            const probeIntervalMs = Number(process.env.MMKIT_PORT_PROBE_INTERVAL_MS ?? "500");
            for (let attempt = 0; attempt < maxAttempts; attempt += 1) {
                this.maybeShowSlowStartProgress();
                const fraction = attempt / maxAttempts;
                this.reportInstallStep("awaitPort", fraction, `Waiting for mmkit server on port ${snapshot.server.port}… (attempt ${attempt + 1}/${maxAttempts})`);
                const probe = await this.ctx.ports.network.probe("127.0.0.1", snapshot.server.port, 1000);
                if (probe.reachable) {
                    this.reportInstallStep("awaitPort", 1, "mmkit server is accepting connections");
                    this.postNow("portReady");
                    return;
                }
                await this.delay(probeIntervalMs);
            }
            this.postNow("installFailed", "port not reachable");
        }
        catch (err) {
            this.postNow("installFailed", `port probe failed: ${String(err)}`);
        }
    }
}
exports.InstallingAwaitPort = InstallingAwaitPort;
class Running extends ServerTop {
    onEntry() {
        this.clearFastStartWatchdog();
        this.hideProgressIfVisible();
        this.reportInstallProgress("mmkit server is running", 100);
        this.emitState("mmkit server running");
    }
    userStart(_snapshot, _generation) { }
    processExited(code) {
        this.emitState(undefined, `mmkit server exited with code ${code}`);
        this.transition(Idle);
    }
}
exports.Running = Running;
class Stopping extends ServerTop {
    onEntry() {
        this.emitState("Stopping mmkit server");
        this.clearFastStartWatchdog();
        this.postNow("beginStop");
    }
    async beginStop() {
        await this.tearDownServer();
    }
}
exports.Stopping = Stopping;
class ShuttingDown extends ServerTop {
    onEntry() {
        this.hideProgressIfVisible();
        this.emitState("mmkit server shut down");
    }
}
exports.ShuttingDown = ShuttingDown;
ihsm.registerStateNames({
    Idle,
    Starting,
    Installing,
    InstallingPrepare,
    InstallingMaterializeAssets,
    InstallingEnsureDockerImage,
    InstallingLaunchContainer,
    InstallingAwaitPort,
    Running,
    Stopping,
    ShuttingDown,
});
function createMmkitServerActor(ctx) {
    return (0, lsp_hsm_factory_1.createLspHsm)(ServerTop, ctx);
}
//# sourceMappingURL=mmkit-server-actor.hsm.js.map