import type { Writable } from "node:stream";
import type * as ihsm from "ihsm";
import type { ICBServerContext } from "./CBServerContext";
import type { CBServerConfig } from "./CBServerSettings";
import type {
  CBAnswer,
  ICBConnection,
  ICBConnectionOptions,
  ProcessIoListener,
  ProcessSignal,
  ProcessStream,
  StatusListener,
} from "./CBServerDefs";

export {
  buildLaunchRequest,
  CBServerConfig,
  CB_SERVER_OPTIMIZER_MODES,
  CB_SERVER_SECURITY_LEVELS,
  CB_SERVER_TRACE_MODES,
  CB_SERVER_UPDATE_MODES,
  DEFAULT_CB_SERVER_LAUNCH,
  DEFAULT_CB_SERVER_MMKIT,
  DEFAULT_CB_SERVER_NETWORK,
  DEFAULT_CB_SERVER_PATHS,
  DEFAULT_CB_SERVER_RUNTIME,
} from "./CBServerSettings";
export type {
  CBServerCacheMode,
  CBServerCcMode,
  CBServerConfigInit,
  CBServerDevCommand,
  CBServerEcaMode,
  CBServerEcaOptimizer,
  CBServerModuleGeneration,
  CBServerModuleSeparator,
  CBServerMultiUserMode,
  CBServerOptimizerMode,
  CBServerRuleLabels,
  CBServerSecurityLevel,
  CBServerServerMode,
  CBServerStratificationMode,
  CBServerTraceMode,
  CBServerUntellMode,
  CBServerUpdateMode,
  CBServerViewsMaintenance,
} from "./CBServerSettings";
export {
  CB_SERVER_SETTING_META,
  CB_SERVER_SETTINGS_META_DOC,
} from "./CBServerSettingMeta";
export type {
  CBServerSettingChangeClass,
  CBServerSettingGroup,
  CBServerSettingKind,
} from "./CBServerSettingMeta";

/** ihsm Config bag for the CBServer supervisor actor. */
export interface CBServerMachineConfig {
  context: ICBServerContext;
  notifications: {
    start(): void;
    stop(): void;
    requestShutdown(): void;
  };
  services: {
    initialize(): Promise<void>;
    createConnection(options?: ICBConnectionOptions): Promise<ICBConnection>;
    executeCommand(message: string): Promise<CBAnswer>;
    subscribeStatus(listener: StatusListener): Promise<ihsm.Disposable>;
    subscribeProcessIo(listener: ProcessIoListener): Promise<ihsm.Disposable>;
    getCurrentStateName(): Promise<string>;
  };
  internalNotifications: {
    onSpawn(): void;
    onData(stream: ProcessStream, chunk: string): void;
    onEnd(stream: ProcessStream): void;
    onStdioError(stream: ProcessStream, errorMessage: string): void;
    onProcessExit(code: number | null, signal: NodeJS.Signals | null): void;
    onProcessClose(code: number | null, signal: NodeJS.Signals | null): void;
    onProcessError(errorMessage: string): void;
    onDisconnect(): void;
    onWriterReady(): void;
    onReaderAnswer(answer: CBAnswer): void;
    onReaderFailed(message: string): void;
    onReaderInterrupted(): void;
    onWriterInterrupted(): void;
    onKillGraceElapsed(): void;
    onFailToStart(errorMessage: string): void;
    doStart(): void;
    doPromoteRunning(): void;
    doAbortStart(errorMessage: string): void;
    doArmChildren(): void;
    doProcessNext(): void;
    doWriteActive(): void;
    doWriteComplete(): void;
    doReadActive(): void;
    doReadComplete(answer: CBAnswer): void;
    doFailActive(message: string): void;
    doStop(): void;
    doSendSigterm(): void;
    doArmKillGrace(): void;
    doBeginDetach(target: "stopped" | "shuttingDown"): void;
    doDispatchInterrupt(): void;
    doFinalizeDetach(): void;
    doCompleteStop(code: number | null, signal: NodeJS.Signals | null, errorMessage?: string): void;
  };
  port: {
    spawn(config: CBServerConfig): Promise<ihsm.ResultWithSubscription<number>>;
    stdinFor(pid: number): Writable | undefined;
    kill(pid: number, signal?: ProcessSignal): Promise<void>;
  };
}

export type CBServerPort = ihsm.DomainPortOf<CBServerMachineConfig>;

/** Inbound mailbox for CBServer internal events (reader/writer subactors). */
export type CBServerActorRef = ihsm.InboundActor<CBServerMachineConfig>;
