import * as ihsm from "ihsm";
import { CBServerContext } from "./CBServerContext";
import type { CBServerActorRef, CBServerMachineConfig } from "./CBServerConfig";
import type { CBAnswer, ICBConnection, ICBConnectionOptions, ProcessStream } from "./CBServerDefs";
import { CBConnectionHandle } from "./CBConnectionHandle";
import { CBServerConnection } from "./CBServerConnectionActor";
import { createReaderContext, createReaderSettings, ReaderTop } from "./reader/CBServerReaderActor";
import { createWriterContext, createWriterSettings, WriterTop } from "./writer/CBServerWriterActor";
import { ForwardingReaderPort, StdinWriterPort } from "./stdioPorts";
import * as self from "./CBServerActor";

/**
 * CBServer supervisor — state hierarchy (* = {@link ihsm.InitialState}, - = other states)
 *
 * ```text
 * CBServerTop
 * * Uninitialized
 * - Initialized
 *   * ProcessDetached
 *     * Stopped
 *     - ShuttingDown
 *     - ProcessDetaching
 *   - ProcessObserving
 *     * Starting
 *     - ProcessActive
 *       - Running
 *         * RequestIdle
 *         - RequestProcessing
 *           - WritingCommand
 *           - ReadingAnswer
 *       - Stopping
 * ```
 */

/**
 * Root — public queries only.
 *
 * Invariants: none on context (valid under any descendant state).
 */
export class CBServerTop extends ihsm.TopState<CBServerMachineConfig> {
  protected _checkInvariant(): void {}
}

export class Initialized extends CBServerTop {
  async subscribeStatus(listener: (state: string) => void): Promise<ihsm.Disposable> {
    this._checkInvariant();
    this.ctx.statusEvents.on("status", listener);
    listener(this.hsm.currentStateName);
    return {
      dispose: () => {
        this.ctx.statusEvents.off("status", listener);
      },
    };
  }

  async subscribeProcessIo(listener: (stream: ProcessStream, line: string) => void): Promise<ihsm.Disposable> {
    this._checkInvariant();
    this.ctx.processIoEvents.on("line", listener);
    return {
      dispose: () => {
        this.ctx.processIoEvents.off("line", listener);
      },
    };
  }

  async getCurrentStateName(): Promise<string> {
    this._checkInvariant();
    return this.hsm.currentStateName;
  }

  async createConnection(_options?: ICBConnectionOptions): Promise<ICBConnection> {
    this._checkInvariant();
    throw new Error(`illegal state: createConnection is not allowed in ${this.hsm.currentStateName}`);
  }

  async executeCommand(_message: string): Promise<CBAnswer> {
    this._checkInvariant();
    throw new Error("cbserver is not running");
  }

  requestShutdown(): void {
    this._checkInvariant();
    this.ctx.shutdownRequested = true;
  }

  start(): void {
    this._checkInvariant();
  }

  stop(): void {
    this._checkInvariant();
  }
}

/**
 * Detached lifecycle branch (no active subprocess subscription).
 *
 * External process/stdio events can race in after teardown; they are ignored here.
 */
@ihsm.InitialState
export class ProcessDetached extends Initialized {
  onSpawn(): void {
    this._checkInvariant();
  }

  onProcessExit(_code: number | null, _signal: NodeJS.Signals | null): void {
    this._checkInvariant();
  }

  onProcessClose(_code: number | null, _signal: NodeJS.Signals | null): void {
    this._checkInvariant();
  }

  onProcessError(_errorMessage: string): void {
    this._checkInvariant();
  }

  onDisconnect(): void {
    this._checkInvariant();
  }

  onFailToStart(_errorMessage: string): void {
    this._checkInvariant();
  }

  onKillGraceElapsed(): void {
    this._checkInvariant();
  }
}

export class ProcessDetaching extends ProcessDetached {
  protected override _checkInvariant(): void {
    super._checkInvariant();
    if (this.ctx.processSubscription !== undefined || this.ctx.pid !== undefined) {
      throw new Error("invariant violation [ProcessDetaching]: process must be disarmed");
    }
  }

  onEntry(): void {
    // Instance prototype is still the source leaf until the transition routine finishes.
    if (this.ctx.processSubscription !== undefined || this.ctx.pid !== undefined) {
      throw new Error("invariant violation [ProcessDetaching]: process must be disarmed");
    }
    this.notify.doDispatchInterrupt();
  }

  doDispatchInterrupt(): void {
    this._checkInvariant();
    this.ctx.dispatchInterruptToChildren();
    this.notifyNow.doFinalizeDetach();
  }

  onData(_stream: ProcessStream, _chunk: string): void {
    this._checkInvariant();
  }

  onEnd(_stream: ProcessStream): void {
    this._checkInvariant();
  }

  onStdioError(_stream: ProcessStream, _errorMessage: string): void {
    this._checkInvariant();
  }

  onWriterReady(): void {
    this._checkInvariant();
  }

  onReaderAnswer(_answer: CBAnswer): void {
    this._checkInvariant();
  }

  onReaderFailed(_message: string): void {
    this._checkInvariant();
  }

  onReaderInterrupted(): void {
    this._checkInvariant();
    this.ctx.noteReaderInterrupted();
    this.notifyNow.doFinalizeDetach();
  }

  onWriterInterrupted(): void {
    this._checkInvariant();
    this.ctx.noteWriterInterrupted();
    this.notifyNow.doFinalizeDetach();
  }

  doFinalizeDetach(): void {
    this._checkInvariant();
    if (this.ctx.allInterrupted()) {
      this.hsm.transition(this.ctx.detachTarget === "shuttingDown" ? ShuttingDown : Stopped);
    }
  }
}

@ihsm.InitialState
export class Uninitialized extends CBServerTop {
  protected override _checkInvariant(): void {
    super._checkInvariant();
    this.ctx.assertProcessDisarmed();
    if (this.ctx.killSignaled) {
      throw new Error("invariant violation [Uninitialized]: killSignaled must be false");
    }
  }

  async initialize(): Promise<void> {
    this._checkInvariant();
    if (this.ctx.config.network.port !== undefined && this.ctx.config.network.port > 0) {
      throw new Error("network mode is not supported; only stdio is allowed");
    }
    this.ctx.serverMailbox = (this.hsm.port as unknown as ihsm.IPort<CBServerMachineConfig>).actor;
    this.hsm.transition(Initialized);
  }
}

@ihsm.InitialState
export class Stopped extends ProcessDetached {
  protected override _checkInvariant(): void {
    super._checkInvariant();
    this.ctx.assertIdle();
  }

  onEntry(): void {
    this.ctx.resetIdle();
    this.ctx.statusEvents.emit("status", this.hsm.currentStateName);
    this._checkInvariant();
  }

  start(): void {
    this._checkInvariant();
    this.hsm.transition(Starting);
  }
}

export class ShuttingDown extends ProcessDetached {
  protected override _checkInvariant(): void {
    super._checkInvariant();
    this.ctx.assertProcessDisarmed();
  }

  onEntry(): void {
    this.ctx.resetShutdown();
    this.ctx.statusEvents.emit("status", this.hsm.currentStateName);
    this._checkInvariant();
  }

  async executeCommand(_message: string): Promise<CBAnswer> {
    this._checkInvariant();
    throw new Error("cbserver is shutting down");
  }
}

export class ProcessObserving extends Initialized {
  stop(): void {
    this._checkInvariant();
    this.hsm.transition(Stopping);
  }

  onSpawn(): void {
    this._checkInvariant();
    this.ctx.processSpawned = true;
  }

  onData(stream: ProcessStream, chunk: string): void {
    this._checkInvariant();
    this.ctx.appendProcessStreamChunk(stream, chunk);
    if (stream === "stdout") {
      this.ctx.children?.reader.notify.onData(chunk);
    }
  }

  onEnd(stream: ProcessStream): void {
    this._checkInvariant();
    this.ctx.flushProcessStream(stream);
    if (stream === "stderr") {
      this.ctx.stderrEnded = true;
      return;
    }
    this.ctx.children?.reader.notify.onEnd();
  }

  onStdioError(stream: ProcessStream, errorMessage: string): void {
    this._checkInvariant();
    if (stream === "stderr") {
      this.ctx.lastProcessError = `${stream}: ${errorMessage}`;
      return;
    }
    this.ctx.children?.reader.notify.onStreamError(errorMessage);
  }

  onProcessClose(code: number | null, signal: NodeJS.Signals | null): void {
    this._checkInvariant();
    this.ctx.lastExitCode = code;
    this.ctx.lastExitSignal = signal;
    this.ctx.stderrEnded = true;
  }

  onFailToStart(_errorMessage: string): void {
    this._checkInvariant();
  }

  onKillGraceElapsed(): void {
    this._checkInvariant();
  }

  async executeCommand(_message: string): Promise<CBAnswer> {
    this._checkInvariant();
    throw new Error("cbserver is not ready for commands");
  }

  doBeginDetach(target: "stopped" | "shuttingDown"): void {
    this.ctx.beginDetachChildren(target);
    this.hsm.transition(ProcessDetaching);
  }

  doCompleteStop(code: number | null, signal: NodeJS.Signals | null, errorMessage?: string): void {
    if (this.ctx.killGraceTimer !== undefined) {
      this.hsm.port.clearTimeout(this.ctx.killGraceTimer);
      this.ctx.killGraceTimer = undefined;
    }
    if (errorMessage !== undefined) {
      this.ctx.lastProcessError = errorMessage;
    }
    this.ctx.lastExitCode = code;
    this.ctx.lastExitSignal = signal;
    if (errorMessage === undefined) {
      this.ctx.stderrEnded = true;
      if (code !== null && code !== 0 && this.ctx.lastProcessError === undefined) {
        this.ctx.lastProcessError = `cbserver exited (code=${code}, signal=${signal})`;
      }
    }
    this.ctx.rejectAllPending(errorMessage ?? "cbserver stopped");
    this.ctx.disposeProcess();
    this.doBeginDetach(this.ctx.shutdownRequested ? "shuttingDown" : "stopped");
  }
}

@ihsm.InitialState
export class Starting extends ProcessObserving {
  protected override _checkInvariant(): void {
    super._checkInvariant();
    if (this.ctx.killSignaled) {
      throw new Error("invariant violation [Starting]: killSignaled must be false");
    }
    const hasPid = this.ctx.pid !== undefined;
    const hasSub = this.ctx.processSubscription !== undefined;
    if (hasPid !== hasSub) {
      throw new Error("invariant violation [Starting]: pid and processSubscription must both be set or both unset");
    }
    if (this.ctx.children !== undefined) {
      throw new Error("invariant violation [Starting]: stdio children must be disarmed");
    }
  }

  onEntry(): void {
    this.ctx.resetForStart();
    this.ctx.statusEvents.emit("status", this.hsm.currentStateName);
    this.notifyNow.doStart();
    this._checkInvariant();
  }

  async doStart(): Promise<void> {
    this._checkInvariant();
    if (this.ctx.pid !== undefined) {
      return;
    }
    try {
      const { value, subscription } = await this.hsm.port.spawn(this.ctx.config);
      this.ctx.pid = value;
      this.ctx.processSubscription = subscription;
      if (this.hsm.currentState !== Starting) {
        subscription.dispose();
        this.ctx.disposeProcess();
        void this.hsm.port.kill(value, "SIGTERM").catch(() => undefined);
        return;
      }
      this.notifyNow.doPromoteRunning();
    } catch (err) {
      this.notifyNow.onFailToStart(`cbserver start failed: ${String(err)}`);
    }
  }

  doPromoteRunning(): void {
    this._checkInvariant();
    this.hsm.transition(Running);
  }

  onProcessExit(code: number | null, signal: NodeJS.Signals | null): void {
    this._checkInvariant();
    this.ctx.lastExitCode = code;
    this.ctx.lastExitSignal = signal;
    this.notifyNow.doAbortStart(`cbserver exited during start (code=${code}, signal=${signal})`);
  }

  onProcessError(errorMessage: string): void {
    this._checkInvariant();
    this.doAbortStart(errorMessage);
  }

  onFailToStart(errorMessage: string): void {
    this._checkInvariant();
    this.doAbortStart(errorMessage);
  }

  onDisconnect(): void {
    this._checkInvariant();
    this.doAbortStart("cbserver disconnected during start");
  }

  doAbortStart(errorMessage: string): void {
    this._checkInvariant();
    this.ctx.lastProcessError = errorMessage;
    const pid = this.ctx.pid;
    this.ctx.disposeProcess();
    this.doBeginDetach("stopped");
    if (pid !== undefined) {
      void this.hsm.port.kill(pid, "SIGTERM").catch(() => undefined);
    }
  }
}

export class ProcessActive extends ProcessObserving {
  protected override _checkInvariant(): void {
    super._checkInvariant();
    this.ctx.assertSpawnArmed();
  }

  onProcessExit(code: number | null, signal: NodeJS.Signals | null): void {
    this._checkInvariant();
    this.ctx.lastExitCode = code;
    this.ctx.lastExitSignal = signal;
    this.notifyNow.doCompleteStop(code, signal);
  }

  onProcessError(errorMessage: string): void {
    this._checkInvariant();
    this.notifyNow.doCompleteStop(null, null, errorMessage);
  }

  onDisconnect(): void {
    this._checkInvariant();
    this.notifyNow.doCompleteStop(null, null);
  }
}

export class Running extends ProcessActive {
  protected override _checkInvariant(): void {
    super._checkInvariant();
    if (this.ctx.killSignaled) {
      throw new Error("invariant violation [Running]: killSignaled must be false");
    }
    if (this.ctx.serverMailbox === undefined) {
      throw new Error("invariant violation [Running]: server mailbox must be set");
    }
  }

  onEntry(): void {
    this.ctx.statusEvents.emit("status", this.hsm.currentStateName);
    this._checkInvariant();
  }

  async doArmChildren(): Promise<void> {
    this._checkInvariant();
    if (this.ctx.children !== undefined || this.ctx.pid === undefined) {
      return;
    }
    const server = this.ctx.serverMailbox!;
    const parent = ihsm.asParentActor(this);
    const readerPort = new ForwardingReaderPort();
    const writerPort = new StdinWriterPort(this.hsm.port.stdinFor(this.ctx.pid));
    const readerSettings = createReaderSettings(this.ctx.config);
    const writerSettings = createWriterSettings(this.ctx.config);
    const reader = ihsm.makeChildActor(parent, ReaderTop, createReaderContext(readerSettings, server), readerPort);
    const writer = ihsm.makeChildActor(parent, WriterTop, createWriterContext(writerSettings, server), writerPort);
    await reader.call.initialize();
    await writer.call.initialize();
    this.ctx.children = { reader, writer, readerPort, writerPort };
  }

  onWriterReady(): void {
    this._checkInvariant();
    this.ctx.writerReady = true;
  }

  async createConnection(_options?: ICBConnectionOptions): Promise<ICBConnection> {
    this._checkInvariant();
    const connectionId = this.ctx.allocConnectionId();
    const serverRef = this.ctx.serverMailbox!;
    const connection = new CBServerConnection({
      connectionId,
      executeCommand: (message: string) => serverRef.call.executeCommand(message),
      onClose: () => {
        this.ctx.connections.delete(connectionId);
      },
    });
    this.ctx.connections.set(connectionId, connection);
    return new CBConnectionHandle(connection.getActorHandle());
  }
}

@ihsm.InitialState
export class RequestIdle extends Running {
  protected override _checkInvariant(): void {
    super._checkInvariant();
    if (this.ctx.children !== undefined) {
      this.ctx.assertProcessArmed();
      this.ctx.assertNoActiveRequest();
      if (this.ctx.requestQueue.length > 0) {
        throw new Error("invariant violation [RequestIdle]: request queue must be empty");
      }
    }
  }

  onEntry(): void {
    if (this.ctx.children === undefined) {
      this.notifyNow.doArmChildren();
    }
    this._checkInvariant();
  }

  onExit(): void {
    if (this.ctx.activeRequest !== undefined) {
      throw new Error("invariant violation [RequestIdle.onExit]: no command may be active");
    }
  }

  async executeCommand(message: string): Promise<CBAnswer> {
    this._checkInvariant();
    if (this.ctx.children === undefined || !this.ctx.writerReady) {
      throw new Error("cbserver is not ready for commands");
    }
    return new Promise<CBAnswer>((resolve, reject) => {
      try {
        this.ctx.requestQueue.push({ message, resolve, reject });
        this.hsm.transition(RequestProcessing);
        this.notify.doProcessNext();
      } catch (err) {
        reject(err instanceof Error ? err : new Error(String(err)));
      }
    });
  }
}

export class RequestProcessing extends Running {
  protected override _checkInvariant(): void {
    super._checkInvariant();
    this.ctx.assertProcessArmed();
    if (this.ctx.requestQueue.length === 0) {
      throw new Error("invariant violation [RequestProcessing]: request queue must be non-empty");
    }
  }

  onEntry(): void {
    this._checkInvariant();
  }

  async executeCommand(message: string): Promise<CBAnswer> {
    this._checkInvariant();
    return new Promise<CBAnswer>((resolve, reject) => {
      try {
        this.ctx.requestQueue.push({ message, resolve, reject });
      } catch (err) {
        reject(err instanceof Error ? err : new Error(String(err)));
      }
    });
  }

  doProcessNext(): void {
    this._checkInvariant();
    if (this.ctx.requestQueue.length === 0) {
      this.hsm.transition(RequestIdle);
      return;
    }
    if (this.ctx.activeRequest !== undefined) {
      return;
    }
    if (!this.ctx.writerReady) {
      return;
    }
    this.ctx.activeRequest = this.ctx.requestQueue[0];
    this.hsm.transition(WritingCommand);
    this.notify.doWriteActive();
  }

  onWriterReady(): void {
    this._checkInvariant();
    this.ctx.writerReady = true;
    this.notify.doProcessNext();
  }

  doFailActive(message: string): void {
    this._checkInvariant();
    const hadActive = this.ctx.activeRequest !== undefined;
    const active = this.ctx.activeRequest ?? this.ctx.requestQueue.shift();
    if (hadActive) {
      this.ctx.requestQueue.shift();
    }
    this.ctx.activeRequest = undefined;
    active?.reject(new Error(message));
    if (this.ctx.requestQueue.length === 0) {
      this.hsm.transition(RequestIdle);
      return;
    }
    this.hsm.transition(RequestProcessing);
    this.notify.doProcessNext();
  }
}

export class WritingCommand extends RequestProcessing {
  protected override _checkInvariant(): void {
    super._checkInvariant();
    if (this.ctx.activeRequest === undefined) {
      throw new Error("invariant violation [WritingCommand]: active request must be set");
    }
  }

  async doWriteActive(): Promise<void> {
    this._checkInvariant();
    try {
      await this.ctx.children!.writer.call.write(this.ctx.activeRequest!.message);
      this.notify.doWriteComplete();
    } catch (err) {
      this.notify.doFailActive(err instanceof Error ? err.message : String(err));
    }
  }

  doWriteComplete(): void {
    this._checkInvariant();
    this.hsm.transition(ReadingAnswer);
  }
}

export class ReadingAnswer extends RequestProcessing {
  protected override _checkInvariant(): void {
    super._checkInvariant();
    if (this.ctx.activeRequest === undefined) {
      throw new Error("invariant violation [ReadingAnswer]: active request must be set");
    }
  }

  onEntry(): void {
    this.notify.doReadActive();
    this._checkInvariant();
  }

  doReadActive(): void {
    this._checkInvariant();
    void this.ctx.children!.reader.call.readAnswer().catch((err: unknown) => {
      this.notify.doFailActive(err instanceof Error ? err.message : String(err));
    });
  }

  onReaderAnswer(answer: CBAnswer): void {
    this._checkInvariant();
    this.notify.doReadComplete(answer);
  }

  onReaderFailed(message: string): void {
    this._checkInvariant();
    this.notify.doFailActive(message);
  }

  doReadComplete(answer: CBAnswer): void {
    this._checkInvariant();
    const active = this.ctx.activeRequest!;
    this.ctx.requestQueue.shift();
    this.ctx.activeRequest = undefined;
    active.resolve(answer);
    if (this.ctx.requestQueue.length === 0) {
      this.hsm.transition(RequestIdle);
      return;
    }
    this.hsm.transition(RequestProcessing);
    this.notify.doProcessNext();
  }
}

export class Stopping extends ProcessActive {
  onEntry(): void {
    this.ctx.statusEvents.emit("status", this.hsm.currentStateName);
    this.notifyNow.doStop();
    this._checkInvariant();
  }

  /** Child interrupt ack may arrive before ProcessDetaching is entered. */
  onReaderInterrupted(): void {
    this.ctx.noteReaderInterrupted();
  }

  /** Child interrupt ack may arrive before ProcessDetaching is entered. */
  onWriterInterrupted(): void {
    this.ctx.noteWriterInterrupted();
  }

  async executeCommand(_message: string): Promise<CBAnswer> {
    this._checkInvariant();
    throw new Error("cbserver is stopping");
  }

  onExit(): void {
    if (this.ctx.killGraceTimer !== undefined) {
      this.hsm.port.clearTimeout(this.ctx.killGraceTimer);
      this.ctx.killGraceTimer = undefined;
    }
  }

  doStop(): void {
    this._checkInvariant();
    if (this.ctx.pid === undefined) {
      this.notifyNow.doCompleteStop(null, null);
      return;
    }
    if (!this.ctx.killSignaled) {
      this.notifyNow.doSendSigterm();
    }
  }

  doSendSigterm(): void {
    this._checkInvariant();
    const pid = this.ctx.pid;
    if (pid === undefined) {
      this.notifyNow.doCompleteStop(null, null);
      return;
    }
    this.ctx.killSignaled = true;
    void this.hsm.port.kill(pid, "SIGTERM").catch(() => undefined);
    this.notifyNow.doArmKillGrace();
  }

  doArmKillGrace(): void {
    this._checkInvariant();
    if (this.ctx.killGraceTimer !== undefined) {
      this.hsm.port.clearTimeout(this.ctx.killGraceTimer);
    }
    this.ctx.killGraceTimer = this.hsm.port.setTimeout(() => {
      this.notify.onKillGraceElapsed();
    }, this.ctx.config.mmkit.killGraceMs);
  }

  onKillGraceElapsed(): void {
    this._checkInvariant();
    const pid = this.ctx.pid;
    if (pid === undefined) {
      return;
    }
    void this.hsm.port.kill(pid, "SIGKILL").catch(() => undefined);
  }
}

export function createCBServerActor(ctx: CBServerContext,
  port: ihsm.MachinePortInput<CBServerMachineConfig>,
  options?: ihsm.ActorOptions<CBServerMachineConfig>,): ihsm.ExternalActor<CBServerMachineConfig> {
  return ihsm.makeActor(CBServerTop, ctx, port, options);
}

ihsm.registerStateNames(self);
