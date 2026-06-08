"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createSimSupervisorPort = createSimSupervisorPort;
const shared_1 = require("@mmkit/shared");
const custom_handler_registry_1 = require("../custom-handler-registry");
function createSimSupervisorPort(options) {
    const calls = [];
    const registry = options.registry ?? new custom_handler_registry_1.CustomHandlerRegistry();
    let progressVisible = false;
    let sink;
    const record = (method, ...args) => {
        calls.push({ method, args });
    };
    const port = {
        calls,
        registry,
        get sink() {
            return sink;
        },
        set sink(value) {
            sink = value;
        },
        getServerPorts: () => options.serverPorts,
        getHandlerRegistry: () => registry,
        getConnection: () => undefined,
        getActuators: () => undefined,
        isProgressVisible: () => progressVisible,
        registerLspHandlers(handlerSink) {
            record("registerLspHandlers");
            sink = handlerSink;
            registry.register(shared_1.MMKIT_LSP_METHODS.serverStart, (p) => handlerSink.onServerStart(p));
            registry.register(shared_1.MMKIT_LSP_METHODS.serverStop, () => handlerSink.onServerStop());
            registry.register(shared_1.MMKIT_LSP_METHODS.serverRestart, (p) => handlerSink.onServerRestart(p));
            registry.register(shared_1.MMKIT_LSP_METHODS.serverStatus, () => handlerSink.onServerStatus());
            registry.register(shared_1.MMKIT_LSP_METHODS.configUpdate, (p) => handlerSink.onConfigUpdate(p));
            registry.register(shared_1.MMKIT_LSP_METHODS.otelTest, (p) => handlerSink.onOtelTest(p));
        },
        sendStateNotification(notification) {
            record("sendStateNotification", notification);
        },
        logServerMessage(phase, message) {
            record("logServerMessage", phase, message);
        },
        beginInstallProgress(title) {
            record("beginInstallProgress", title);
            progressVisible = true;
        },
        reportInstallProgress(message, percent) {
            record("reportInstallProgress", message, percent);
        },
        endInstallProgress() {
            record("endInstallProgress");
            progressVisible = false;
        },
        async probeOtelEndpoint(config) {
            record("probeOtelEndpoint", config);
            return (options.otelResult ?? {
                ok: true,
                message: "simulated collector",
                latencyMs: 1,
            });
        },
        setProgressVisible(visible) {
            record("setProgressVisible", visible);
            progressVisible = visible;
        },
    };
    return port;
}
//# sourceMappingURL=sim-supervisor-port.js.map