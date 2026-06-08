import * as ihsm from "ihsm";
import { homedir } from "node:os";
import path from "node:path";
import { appendProcessIo, CBServerContext } from "./CBServerContext";
import { CBServerConfig } from "./CBServerConfig";
import type { CBServerPort } from "./CBServerPort";
import type { ProcessStream } from "./processMailbox";

export type StatusListener = (state: string) => void;

/**
 * User-facing mailbox vocabulary for {@link CBServerActor}.
 *
 * - **Commands** (`post`) — `start`, `stop`.
 * - **Notifications** (`post`) — `onXxx` from subprocess / port observations.
 * - **Queries** (`call`) — `initialize`, `subscribeStatus`, `unsubscribeStatus`, `getCurrentStateName`.
 */
export interface CBServerActorProtocol {
  start(): void;
  stop(): void;
  initialize(resolve: ihsm.ResolveCallback<void>, reject: ihsm.RejectCallback, port: CBServerPort): Promise<void>;
  subscribeStatus(resolve: ihsm.ResolveCallback<void>, reject: ihsm.RejectCallback, listener: StatusListener): Promise<void>;
  unsubscribeStatus(resolve: ihsm.ResolveCallback<void>, reject: ihsm.RejectCallback, listener: StatusListener): Promise<void>;
  getCurrentStateName(resolve: ihsm.ResolveCallback<string>, reject: ihsm.RejectCallback): Promise<void>;

  onSpawn(): void;
  onData(stream: ProcessStream, chunk: string): void;
  onEnd(stream: ProcessStream): void;
  onStdioError(stream: ProcessStream, errorMessage: string): void;
  onProcessExit(code: number | null, signal: NodeJS.Signals | null): void;
  onProcessClose(code: number | null, signal: NodeJS.Signals | null): void;
  onProcessError(errorMessage: string): void;
  onDisconnect(): void;
  onPortReady(): void;
  onKillGraceElapsed(): void;
  onFailToStart(errorMessage: string): void;
}

function disposeProcess(ctx: CBServerContext): void {
  ctx.pid = undefined;
  ctx.processSubscription?.dispose();
  ctx.processSubscription = undefined;
}

/** Queries valid in every state; no environment events. */
export class CBServerTop extends ihsm.TopState<CBServerContext, CBServerActorProtocol> {
  async subscribeStatus(resolve: ihsm.ResolveCallback<void>, reject: ihsm.RejectCallback, listener: StatusListener): Promise<void> {
    try {
      this.ctx.statusEvents.on("status", listener);
      listener(this.currentStateName);
      resolve();
    } catch (err) {
      reject(err instanceof Error ? err : new Error(String(err)));
    }
  }

  async unsubscribeStatus(resolve: ihsm.ResolveCallback<void>, reject: ihsm.RejectCallback, listener: StatusListener): Promise<void> {
    try {
      this.ctx.statusEvents.off("status", listener);
      resolve();
    } catch (err) {
      reject(err instanceof Error ? err : new Error(String(err)));
    }
  }

  async getCurrentStateName(resolve: ihsm.ResolveCallback<string>, reject: ihsm.RejectCallback): Promise<void> {
    try {
      resolve(this.currentStateName);
    } catch (err) {
      reject(err instanceof Error ? err : new Error(String(err)));
    }
  }
}

/** Subprocess stdio while a spawn subscription is armed (Starting, Running, Stopping). */
class ProcessObserving extends CBServerTop {
  onSpawn(): void {
    this.ctx.processSpawned = true;
  }

  onData(stream: ProcessStream, chunk: string): void {
    appendProcessIo(this.ctx, stream, chunk);
  }

  onEnd(stream: ProcessStream): void {
    if (stream === "stdout") {
      this.ctx.stdoutEnded = true;
    } else {
      this.ctx.stderrEnded = true;
    }
  }

  onStdioError(stream: ProcessStream, errorMessage: string): void {
    this.ctx.lastProcessError = `${stream}: ${errorMessage}`;
  }

  onProcessClose(code: number | null, signal: NodeJS.Signals | null): void {
    this.ctx.lastExitCode = code;
    this.ctx.lastExitSignal = signal;
    this.ctx.stdoutEnded = true;
    this.ctx.stderrEnded = true;
  }
}

@ihsm.InitialState
export class Uninitialized extends CBServerTop {
  start(): void {}

  async initialize(resolve: ihsm.ResolveCallback<void>, reject: ihsm.RejectCallback, port: CBServerPort): Promise<void> {
    try {
      this.ctx.port = port;
      resolve();
      this.transition(Stopped);
    } catch (err) {
      reject(err instanceof Error ? err : new Error(String(err)));
    }
  }
}

export class Stopped extends CBServerTop {
  onEntry(): void {
    disposeProcess(this.ctx);
    this.ctx.killSignaled = false;
    this.ctx.processSpawned = false;
    this.ctx.processStdout = "";
    this.ctx.processStderr = "";
    this.ctx.statusEvents.emit("status", this.currentStateName);
  }

  start(): void {
    this.transition(Starting);
  }

  stop(): void {}

  /** Orphaned grace timer after a completed stop. */
  onKillGraceElapsed(): void {}
}

/** Composite: spawn + event-driven port listen until ready or failure. */
export class Starting extends ProcessObserving {
  onEntry(): void {
    this.ctx.processSpawned = false;
    this.ctx.processStdout = "";
    this.ctx.processStderr = "";
    this.ctx.stdoutEnded = false;
    this.ctx.stderrEnded = false;
    this.ctx.lastExitCode = null;
    this.ctx.lastExitSignal = null;
    this.ctx.lastProcessError = undefined;
    this.ctx.statusEvents.emit("status", "Starting");
  }

  onPortReady(): void {
    this.transition(Running);
  }

  onProcessExit(code: number | null, signal: NodeJS.Signals | null): void {
    this.ctx.lastExitCode = code;
    this.ctx.lastExitSignal = signal;
    disposeProcess(this.ctx);
    this.postNow("onFailToStart", `cbserver exited during start (code=${code}, signal=${signal})`);
  }

  onProcessError(errorMessage: string): void {
    this.ctx.lastProcessError = errorMessage;
    this.postNow("onFailToStart", errorMessage);
  }

  onFailToStart(errorMessage: string): void {
    this.ctx.lastProcessError = errorMessage;
    const pid = this.ctx.pid;
    const port = this.ctx.port;
    disposeProcess(this.ctx);
    if (pid !== undefined && port !== undefined) {
      void port.kill(pid, "SIGTERM").catch(() => undefined);
    }
    this.transition(Stopped);
  }

  start(): void {}

  stop(): void {
    this.transition(Stopping);
  }
}

@ihsm.InitialState
export class ProbingPort extends Starting {
  async onEntry(): Promise<void> {
    super.onEntry();
    if (this.ctx.pid !== undefined) {
      return;
    }
    const port = this.ctx.port!;
    const { config } = this.ctx;
    const mailbox = this.ctx.mailbox!;
    const dataDir = config.dataDir;
    const spawnCwd =
      !dataDir ? undefined
      : dataDir === "~" || dataDir === "~/" ? homedir()
      : dataDir.startsWith("~/") ? path.join(homedir(), dataDir.slice(2))
      : dataDir;
    try {
      const spawnSpec = {
        command: config.executablePath,
        args: ["-p", String(config.port), ...config.extraArgs],
        cwd: spawnCwd,
        env: process.env,
        stdio: "pipe" as const,
      };
      const listenOptions = {
        listen: {
          host: "127.0.0.1",
          port: config.port,
          maxAttempts: config.portProbeAttempts,
          intervalMs: config.portProbeIntervalMs,
        },
      };
      const { pid, subscription } = await port.spawn(spawnSpec, mailbox, listenOptions);
      this.ctx.pid = pid;
      this.ctx.processSubscription = subscription;
    } catch (err) {
      this.postNow("onFailToStart", `cbserver start failed: ${String(err)}`);
    }
  }
}

export class Running extends ProcessObserving {
  onEntry(): void {
    this.ctx.statusEvents.emit("status", "Running");
  }

  onProcessExit(code: number | null, signal: NodeJS.Signals | null): void {
    this.ctx.lastExitCode = code;
    this.ctx.lastExitSignal = signal;
    this.ctx.stdoutEnded = true;
    this.ctx.stderrEnded = true;
    disposeProcess(this.ctx);
    this.transition(Stopped);
  }

  start(): void {}

  onProcessError(errorMessage: string): void {
    this.ctx.lastProcessError = errorMessage;
    disposeProcess(this.ctx);
    this.transition(Stopped);
  }

  onDisconnect(): void {
    disposeProcess(this.ctx);
    this.transition(Stopped);
  }

  stop(): void {
    this.transition(Stopping);
  }
}

@ihsm.InitialState
export class WatchingProcess extends Running {}

export class Stopping extends ProcessObserving {
  onEntry(): void {
    this.ctx.statusEvents.emit("status", "Stopping");
  }
}

@ihsm.InitialState
export class AwaitingExit extends Stopping {
  onEntry(): void {
    const pid = this.ctx.pid;
    const port = this.ctx.port;
    if (pid === undefined) {
      this.postNow("onProcessExit", null, null);
      return;
    }
    if (!this.ctx.killSignaled && port !== undefined) {
      this.ctx.killSignaled = true;
      void port.kill(pid, "SIGTERM").catch(() => undefined);
      this.deferredPost(this.ctx.config.killGraceMs, "onKillGraceElapsed");
    }
  }

  onKillGraceElapsed(): void {
    const pid = this.ctx.pid;
    const port = this.ctx.port;
    if (pid === undefined || port === undefined) {
      return;
    }
    void port.kill(pid, "SIGKILL").catch(() => undefined);
  }

  onProcessExit(code: number | null, signal: NodeJS.Signals | null): void {
    this.ctx.lastExitCode = code;
    this.ctx.lastExitSignal = signal;
    this.ctx.stdoutEnded = true;
    this.ctx.stderrEnded = true;
    disposeProcess(this.ctx);
    if (this.ctx.shutdownRequested) {
      this.transition(ShuttingDown);
    } else {
      this.transition(Stopped);
    }
  }

  onProcessError(errorMessage: string): void {
    this.ctx.lastProcessError = errorMessage;
    disposeProcess(this.ctx);
    if (this.ctx.shutdownRequested) {
      this.transition(ShuttingDown);
    } else {
      this.transition(Stopped);
    }
  }

  onDisconnect(): void {
    disposeProcess(this.ctx);
    if (this.ctx.shutdownRequested) {
      this.transition(ShuttingDown);
    } else {
      this.transition(Stopped);
    }
  }
}

export class ShuttingDown extends CBServerTop {
  onEntry(): void {
    disposeProcess(this.ctx);
    this.ctx.statusEvents.emit("status", this.currentStateName);
  }

  onKillGraceElapsed(): void {}
}

export function createCBServerActor(config?: CBServerConfig): ihsm.Hsm<CBServerContext, CBServerActorProtocol> {
  const ctx = new CBServerContext(config);
  const hsm = ihsm.makeHsm(CBServerTop, ctx, true);
  ctx.mailbox = hsm;
  return hsm;
}
