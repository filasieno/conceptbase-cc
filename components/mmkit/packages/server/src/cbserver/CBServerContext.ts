import { EventEmitter } from "node:events";
import * as ihsm from "ihsm";
import type { CBServerConfig } from "./CBServerConfig";
import type { IpcAnswer, ProcessStream } from "./CBServerDefs";
import type { ICBConnectionDriver } from "./CBServerConnection";
import type { ForwardingReaderPort } from "./stdioPorts";
import type { ReaderMachineConfig } from "./reader/CBServerReaderConfig";
import type { WriterMachineConfig, WriterPort } from "./writer/CBServerWriterConfig";

const MAX_IO_BYTES = 64 * 1024;

export type PendingCommand = {
  message: string;
  resolve(answer: IpcAnswer): void;
  reject(error: Error): void;
};

/** Armed reader/writer subactors — lifecycle tied to {@link ProcessActive}. */
export type CBServerStdioChildren = {
  reader: ihsm.ChildActor<ReaderMachineConfig>;
  writer: ihsm.ChildActor<WriterMachineConfig>;
  readerPort: ForwardingReaderPort;
  writerPort: WriterPort;
};

export interface ICBServerContext {
  processSubscription?: ihsm.Disposable;
  killGraceTimer?: number;
  detachTarget: "stopped" | "shuttingDown";
  awaitReaderInterrupted: boolean;
  awaitWriterInterrupted: boolean;
  readonly config: CBServerConfig;
  readonly statusEvents: EventEmitter;
  readonly processIoEvents: EventEmitter;
  readonly requestQueue: PendingCommand[];
  readonly connections: Map<string, ICBConnectionDriver>;
  pid?: number;
  shutdownRequested: boolean;
  killSignaled: boolean;
  children?: CBServerStdioChildren;
  activeRequest?: PendingCommand;
  writerReady: boolean;
  processSpawned: boolean;
  processStderr: string;
  processStdout: string;
  stderrEnded: boolean;
  lastExitCode: number | null;
  lastExitSignal: NodeJS.Signals | null;
  lastProcessError?: string;
  serverMailbox?: import("./CBServerConfig").CBServerActorRef;
  assertSpawnArmed(): void;
  assertProcessArmed(): void;
  assertProcessDisarmed(): void;
  assertNoActiveRequest(): void;
  assertIdle(): void;
  resetForStart(): void;
  appendStderr(chunk: string): void;
  appendProcessStreamChunk(stream: ProcessStream, chunk: string): void;
  flushProcessStream(stream: ProcessStream): void;
  disposeProcess(): void;
  resetIdle(): void;
  resetShutdown(): void;
  allocConnectionId(): string;
  beginDetachChildren(target: "stopped" | "shuttingDown"): void;
  dispatchInterruptToChildren(): void;
  noteReaderInterrupted(): void;
  noteWriterInterrupted(): void;
  allInterrupted(): boolean;
  rejectAllPending(message: string): void;
}

/** Domain data for the CBServer actor — mutated from state handlers only. */
export class CBServerContext implements ICBServerContext {
  processSubscription?: ihsm.Disposable;
  killGraceTimer?: number;
  detachTarget: "stopped" | "shuttingDown" = "stopped";
  awaitReaderInterrupted = false;
  awaitWriterInterrupted = false;
  readonly config: CBServerConfig;
  readonly statusEvents = new EventEmitter();
  readonly processIoEvents = new EventEmitter();
  readonly requestQueue: PendingCommand[] = [];
  readonly connections = new Map<string, ICBConnectionDriver>();
  pid?: number;
  shutdownRequested = false;
  killSignaled = false;
  children?: CBServerStdioChildren;
  activeRequest?: PendingCommand;
  writerReady = false;

  processSpawned = false;
  processStderr = "";
  processStdout = "";
  stderrEnded = false;
  lastExitCode: number | null = null;
  lastExitSignal: NodeJS.Signals | null = null;
  lastProcessError?: string;

  serverMailbox?: import("./CBServerConfig").CBServerActorRef;
  private connectionSeq = 0;

  constructor(config: CBServerConfig) {
    this.config = config;
  }

  assertSpawnArmed(): void {
    if (this.processSubscription === undefined || this.pid === undefined) {
      throw new Error("invariant violation: process subscription must be armed");
    }
  }

  assertProcessArmed(): void {
    this.assertSpawnArmed();
    if (this.children === undefined) {
      throw new Error("invariant violation: stdio children must be armed while process is active");
    }
    if (this.children.reader === undefined || this.children.writer === undefined) {
      throw new Error("invariant violation: stdio actors must be armed while process is active");
    }
    if (this.children.readerPort === undefined || this.children.writerPort === undefined) {
      throw new Error("invariant violation: stdio ports must be armed while process is active");
    }
  }

  assertProcessDisarmed(): void {
    if (this.processSubscription !== undefined || this.pid !== undefined) {
      throw new Error("invariant violation: process subscription must be disarmed");
    }
    if (this.children !== undefined) {
      throw new Error("invariant violation: stdio children must be disarmed");
    }
  }

  assertNoActiveRequest(): void {
    if (this.activeRequest !== undefined) {
      throw new Error("invariant violation: no command may be active");
    }
  }

  assertIdle(): void {
    this.assertProcessDisarmed();
    if (this.killSignaled) {
      throw new Error("invariant violation: killSignaled must be false when idle");
    }
    if (this.requestQueue.length > 0) {
      throw new Error("invariant violation: request queue must be empty when stopped");
    }
    this.assertNoActiveRequest();
  }

  /** {@link Starting.onEntry} — fresh subprocess attempt. */
  resetForStart(): void {
    this.processSpawned = false;
    this.processStderr = "";
    this.processStdout = "";
    this.stderrEnded = false;
    this.lastExitCode = null;
    this.lastExitSignal = null;
    this.lastProcessError = undefined;
    this.killSignaled = false;
    this.writerReady = false;
    this.activeRequest = undefined;
    this.requestQueue.length = 0;
    this.awaitReaderInterrupted = false;
    this.awaitWriterInterrupted = false;
    this.detachTarget = "stopped";
  }

  appendStderr(chunk: string): void {
    const next = this.processStderr + chunk;
    this.processStderr = next.length <= MAX_IO_BYTES ? next : next.slice(-MAX_IO_BYTES);
  }

  appendProcessStreamChunk(stream: ProcessStream, chunk: string): void {
    const next = (stream === "stdout" ? this.processStdout : this.processStderr) + chunk;
    const bounded = next.length <= MAX_IO_BYTES ? next : next.slice(-MAX_IO_BYTES);
    const lines = bounded.split("\n");
    const tail = lines.pop() ?? "";
    for (const line of lines) {
      this.processIoEvents.emit("line", stream, line);
    }
    if (stream === "stdout") {
      this.processStdout = tail;
    } else {
      this.processStderr = tail;
    }
  }

  flushProcessStream(stream: ProcessStream): void {
    const pending = stream === "stdout" ? this.processStdout : this.processStderr;
    if (pending.length > 0) {
      this.processIoEvents.emit("line", stream, pending);
    }
    if (stream === "stdout") {
      this.processStdout = "";
      return;
    }
    this.processStderr = "";
  }

  disposeProcess(): void {
    this.processSubscription?.dispose();
    this.processSubscription = undefined;
    this.pid = undefined;
    this.processSpawned = false;
  }

  /** {@link Stopped.onEntry} — idle; tear down all subscriptions and IO buffers. */
  resetIdle(): void {
    this.disposeProcess();
    this.killSignaled = false;
    this.processStderr = "";
    this.processStdout = "";
    this.stderrEnded = false;
    this.writerReady = false;
    this.activeRequest = undefined;
    this.requestQueue.length = 0;
    this.awaitReaderInterrupted = false;
    this.awaitWriterInterrupted = false;
    this.detachTarget = "stopped";
  }

  /** {@link ShuttingDown.onEntry} — final shutdown; no restart. */
  resetShutdown(): void {
    this.disposeProcess();
    this.processStdout = "";
    this.processStderr = "";
    this.awaitReaderInterrupted = false;
    this.awaitWriterInterrupted = false;
    this.detachTarget = "shuttingDown";
  }

  allocConnectionId(): string {
    this.connectionSeq += 1;
    return `conn-${this.connectionSeq}`;
  }

  beginDetachChildren(target: "stopped" | "shuttingDown"): void {
    this.detachTarget = target;
    const children = this.children;
    if (children === undefined) {
      this.awaitReaderInterrupted = false;
      this.awaitWriterInterrupted = false;
      return;
    }
    this.awaitReaderInterrupted = children.reader !== undefined;
    this.awaitWriterInterrupted = children.writer !== undefined;
  }

  dispatchInterruptToChildren(): void {
    const children = this.children;
    if (children === undefined) {
      return;
    }
    if (this.awaitReaderInterrupted) {
      children.reader.notify.interrupt();
    }
    if (this.awaitWriterInterrupted) {
      children.writer.notify.interrupt();
    }
    this.children = undefined;
    this.writerReady = false;
  }

  noteReaderInterrupted(): void {
    this.awaitReaderInterrupted = false;
  }

  noteWriterInterrupted(): void {
    this.awaitWriterInterrupted = false;
  }

  allInterrupted(): boolean {
    return !this.awaitReaderInterrupted && !this.awaitWriterInterrupted;
  }

  rejectAllPending(message: string): void {
    const queued = [...this.requestQueue];
    const active = this.activeRequest;
    this.activeRequest = undefined;
    this.requestQueue.length = 0;
    const error = new Error(message);
    for (const pending of queued) {
      if (pending === active) {
        continue;
      }
      pending.reject(error);
    }
    if (active !== undefined) {
      active.reject(error);
    }
  }
}
