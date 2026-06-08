"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createRealSupervisorPort = createRealSupervisorPort;
const shared_1 = require("@mmkit/shared");
const MMKIT_PROGRESS_TOKEN = "mmkit-server-install";
function createRealSupervisorPort(options) {
    let progressVisible = false;
    return {
        getServerPorts: () => options.ports,
        getHandlerRegistry: () => options.registry,
        getConnection: () => options.getConnection(),
        getActuators: () => options.getActuators(),
        isProgressVisible: () => progressVisible,
        registerLspHandlers(sink) {
            const { registry } = options;
            registry.register(shared_1.MMKIT_LSP_METHODS.serverStart, (p) => sink.onServerStart(p));
            registry.register(shared_1.MMKIT_LSP_METHODS.serverStop, () => sink.onServerStop());
            registry.register(shared_1.MMKIT_LSP_METHODS.serverRestart, (p) => sink.onServerRestart(p));
            registry.register(shared_1.MMKIT_LSP_METHODS.serverStatus, () => sink.onServerStatus());
            registry.register(shared_1.MMKIT_LSP_METHODS.configUpdate, (p) => sink.onConfigUpdate(p));
            registry.register(shared_1.MMKIT_LSP_METHODS.otelTest, (p) => sink.onOtelTest(p));
        },
        sendStateNotification(notification) {
            const conn = options.getConnection();
            if (conn) {
                void conn.sendNotification(shared_1.MMKIT_LSP_METHODS.serverStateNotification, notification);
            }
            if (notification.message) {
                this.logServerMessage(notification.phase, notification.message);
            }
        },
        logServerMessage(phase, message) {
            const actuators = options.getActuators();
            if (actuators) {
                actuators.consoleInfo(`[mmkit-server] ${phase}: ${message}`);
            }
        },
        beginInstallProgress(title) {
            const actuators = options.getActuators();
            if (!actuators || progressVisible)
                return;
            actuators.beginWorkDone(MMKIT_PROGRESS_TOKEN, title, false);
            progressVisible = true;
        },
        reportInstallProgress(message, percent) {
            const actuators = options.getActuators();
            if (!actuators)
                return;
            if (!progressVisible) {
                this.beginInstallProgress("Starting mmkit server");
            }
            actuators.reportWorkDone(MMKIT_PROGRESS_TOKEN, message, percent);
        },
        endInstallProgress() {
            const actuators = options.getActuators();
            if (!actuators || !progressVisible)
                return;
            actuators.endWorkDone(MMKIT_PROGRESS_TOKEN);
            progressVisible = false;
        },
        async probeOtelEndpoint(config) {
            const started = Date.now();
            try {
                const url = `${config.protocol === "grpc" ? "http" : config.protocol}://${config.host}:${config.port}`;
                const res = await fetch(url, { method: "HEAD", signal: AbortSignal.timeout(3000) });
                return {
                    ok: res.ok || res.status < 500,
                    message: res.ok ? "collector reachable" : `HTTP ${res.status}`,
                    latencyMs: Date.now() - started,
                };
            }
            catch (err) {
                return {
                    ok: false,
                    message: err instanceof Error ? err.message : String(err),
                    latencyMs: Date.now() - started,
                };
            }
        },
        setProgressVisible(visible) {
            progressVisible = visible;
        },
    };
}
//# sourceMappingURL=real-supervisor-port.js.map