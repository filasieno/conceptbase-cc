/// <reference types="node" />
import { EventEmitter } from "node:events";
import type { CBServerPort, ProcessSignal, SpawnOptions, SpawnSpec } from "../../src/cbserver/CBServerPort";
import type { Disposable } from "../../src/cbserver/Disposable";
import type { ProcessMailbox, ProcessStream } from "../../src/cbserver/processMailbox";
import { attachPortListen } from "../../src/cbserver/processSubscription";

export interface SimProcessRecord {
  exitCode: number | null;
  signal: ProcessSignal | null;
  killed: boolean;
  stdout: string;
  stderr: string;
  stdoutEnded: boolean;
  stderrEnded: boolean;
  emitter: EventEmitter;
  mailbox?: ProcessMailbox;
  detached: boolean;
  portListen?: Disposable;
}

export interface SimCBServerPortState {
  spawnCount: number;
  killCount: number;
  lastKillSignal?: ProcessSignal;
  reachable: boolean;
  startupDelayMs: number;
  /** When set, `spawn` rejects before creating a process record. */
  spawnThrows?: string;
  /** When true, `kill(SIGTERM)` does not finish the process (exercises kill grace). */
  ignoreSigterm?: boolean;
  nextPid: number;
  lastSpawnSpec?: SpawnSpec;
  processes: Map<number, SimProcessRecord>;
}

export class SimCBServerPort implements CBServerPort {
  readonly sim: SimCBServerPortState;

  constructor(overrides: Partial<SimCBServerPortState> = {}) {
    this.sim = {
      spawnCount: 0,
      killCount: 0,
      reachable: true,
      startupDelayMs: 0,
      nextPid: 10_000,
      processes: new Map(),
      ...overrides,
    };
  }

  async spawn(spec: SpawnSpec, mailbox: ProcessMailbox, options?: SpawnOptions) {
    if (this.sim.spawnThrows !== undefined) {
      throw new Error(this.sim.spawnThrows);
    }
    this.sim.spawnCount += 1;
    this.sim.lastSpawnSpec = spec;
    const pid = this.sim.nextPid++;
    const emitter = new EventEmitter();
    const record: SimProcessRecord = {
      exitCode: null,
      signal: null,
      killed: false,
      stdout: "",
      stderr: "",
      stdoutEnded: false,
      stderrEnded: false,
      emitter,
      mailbox,
      detached: false,
    };
    this.sim.processes.set(pid, record);
    mailbox.post("onSpawn");

    let portListen: Disposable | undefined;
    if (options?.listen !== undefined) {
      if (this.sim.reachable) {
        const delay = this.sim.startupDelayMs;
        const timer = setTimeout(() => {
          if (!record.detached) {
            mailbox.post("onPortReady");
          }
        }, delay);
        portListen = { dispose: () => clearTimeout(timer) };
      } else {
        portListen = attachPortListen(mailbox, options.listen);
      }
    }
    record.portListen = portListen;

    const subscription: Disposable = {
      dispose: () => {
        record.detached = true;
        record.mailbox = undefined;
        record.portListen?.dispose();
        record.portListen = undefined;
      },
    };

    return { pid, subscription };
  }

  async kill(pid: number, signal: ProcessSignal = "SIGTERM") {
    this.sim.killCount += 1;
    this.sim.lastKillSignal = signal;
    const record = this.sim.processes.get(pid);
    if (!record) {
      return;
    }
    record.killed = true;
    if (signal === "SIGTERM" && this.sim.ignoreSigterm) {
      return;
    }
    if (signal === "SIGKILL" || signal === "SIGTERM") {
      record.exitCode = signal === "SIGKILL" ? null : 0;
      record.signal = signal === "SIGKILL" ? "SIGKILL" : null;
      this.finishProcess(pid, record);
    }
  }

  private finishProcess(pid: number, record: SimProcessRecord): void {
    const mailbox = record.detached ? undefined : record.mailbox;
    if (mailbox !== undefined) {
      if (!record.stdoutEnded) {
        record.stdoutEnded = true;
        mailbox.post("onEnd", "stdout");
      }
      if (!record.stderrEnded) {
        record.stderrEnded = true;
        mailbox.post("onEnd", "stderr");
      }
      record.emitter.emit("exit", record.exitCode, record.signal);
      mailbox.post("onProcessExit", record.exitCode, record.signal);
    }
    record.detached = true;
    record.mailbox = undefined;
    record.portListen?.dispose();
    record.portListen = undefined;
    this.sim.processes.delete(pid);
  }

  /** Test hook: push stdout/stderr through the active mailbox. */
  scriptIo(pid: number, stream: ProcessStream, chunk: string): void {
    const record = this.sim.processes.get(pid);
    if (!record || record.detached || record.mailbox === undefined) {
      return;
    }
    if (stream === "stdout") {
      record.stdout += chunk;
    } else {
      record.stderr += chunk;
    }
    record.mailbox.post("onData", stream, chunk);
  }

  /** Test hook: simulate spawn/handle error. */
  scriptError(pid: number, errorMessage: string): void {
    const record = this.sim.processes.get(pid);
    if (!record || record.detached || record.mailbox === undefined) {
      return;
    }
    record.mailbox.post("onProcessError", errorMessage);
  }

  /** Test hook: simulate unexpected process exit. */
  scriptExit(pid: number, code: number | null, signal: ProcessSignal | null = null): void {
    const record = this.sim.processes.get(pid);
    if (!record) {
      return;
    }
    record.exitCode = code;
    record.signal = signal;
    this.finishProcess(pid, record);
  }

  /** Test hook: simulate a stdio stream error. */
  scriptStdioError(pid: number, stream: ProcessStream, errorMessage: string): void {
    const record = this.sim.processes.get(pid);
    if (!record || record.detached || record.mailbox === undefined) {
      return;
    }
    record.mailbox.post("onStdioError", stream, errorMessage);
  }

  /** Test hook: simulate stdout/stderr end without process exit. */
  scriptEnd(pid: number, stream: ProcessStream): void {
    const record = this.sim.processes.get(pid);
    if (!record || record.detached || record.mailbox === undefined) {
      return;
    }
    if (stream === "stdout") {
      record.stdoutEnded = true;
    } else {
      record.stderrEnded = true;
    }
    record.mailbox.post("onEnd", stream);
  }

  /** Test hook: simulate IPC disconnect. */
  scriptDisconnect(pid: number): void {
    const record = this.sim.processes.get(pid);
    if (!record || record.detached || record.mailbox === undefined) {
      return;
    }
    record.mailbox.post("onDisconnect");
  }

  /** Test hook: port becomes reachable during start. */
  scriptPortReady(pid: number): void {
    const record = this.sim.processes.get(pid);
    if (!record || record.detached || record.mailbox === undefined) {
      return;
    }
    record.portListen?.dispose();
    record.portListen = undefined;
    record.mailbox.post("onPortReady");
  }
}

export function createSimCBServerPort(overrides: Partial<SimCBServerPortState> = {}): { port: SimCBServerPort; sim: SimCBServerPortState } {
  const port = new SimCBServerPort(overrides);
  return { port, sim: port.sim };
}
