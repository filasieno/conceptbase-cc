import * as ihsm from "ihsm";
import { formatTextFramedMessage } from "../CBServerDefs";
import type { CBServerActorRef, CBServerConfig } from "../CBServerConfig";
import type { ICBServerWriterSettings, WriterMachineConfig } from "./CBServerWriterConfig";
import { WriterContext } from "./CBServerWriterContext";
import type { IWriterContext } from "./CBServerWriterContext";
import * as self from "./CBServerWriterActor";

/**
 * Stdio length-prefixed writer — state hierarchy (* = {@link ihsm.InitialState})
 *
 * ```text
 * WriterTop
 * * Uninitialized
 * - Initialized
 *   * Idle
 *   - Stopped
 *   - WriteObserving
 *     - Writing
 * ```
 */

/** Root — public queries only. */
export class WriterTop extends ihsm.TopState<WriterMachineConfig> {
  protected _checkInvariant(): void {}
}

/** Post-{@link initialize} lifecycle. */
export class Initialized extends WriterTop {
  async getCurrentStateName(): Promise<string> {
    this._checkInvariant();
    return this.hsm.currentStateName;
  }

  interrupt(): void {
    this._checkInvariant();
    this.ctx.interrupt();
    this.hsm.transition(Stopped);
  }

  stop(): void {
    this._checkInvariant();
    this.hsm.transition(Stopped);
  }
}

/**
 * Terminal — no in-flight write; further writes rejected.
 *
 * Invariants: {@link WriterContext.assertDisarmed}.
 */
export class Stopped extends Initialized {
  protected override _checkInvariant(): void {
    super._checkInvariant();
    this.ctx.assertDisarmed();
  }

  onEntry(): void {
    this.ctx.shutdown();
    this.ctx.postInterrupted();
    this._checkInvariant();
  }

  stop(): void {
    this._checkInvariant();
  }

  interrupt(): void {
    this._checkInvariant();
    this.ctx.interrupt();
  }

  async write(_message: string): Promise<void> {
    this._checkInvariant();
    throw new Error("writer stopped");
  }

  onWriteProgress(_written: number): void {
    this._checkInvariant();
  }

  onWriteSucceeded(): void {
    this._checkInvariant();
  }

  onWriteFailed(_message: string): void {
    this._checkInvariant();
  }
}

/**
 * Port write may fail while a message is in flight.
 */
export class WriteObserving extends Initialized {
  onWriteFailed(message: string): void {
    this._checkInvariant();
    this.notify.doFailPending(message);
  }

  doFailPending(message: string): void {
    this._checkInvariant();
    const pending = this.ctx.pendingWrite;
    this.ctx.resetIdle();
    this.hsm.transition(Idle);
    pending?.reject(new Error(message));
  }

  doComplete(): void {
    this._checkInvariant();
    const pending = this.ctx.pendingWrite!;
    this.ctx.resetIdle();
    pending.resolve();
    this.hsm.transition(Idle);
  }
}

/**
 * Actor created but not yet initialized.
 *
 * Invariants: {@link WriterContext.assertDisarmed}.
 */
@ihsm.InitialState
export class Uninitialized extends WriterTop {
  protected override _checkInvariant(): void {
    super._checkInvariant();
    this.ctx.assertDisarmed();
  }

  async initialize(): Promise<void> {
    this._checkInvariant();
    this.hsm.transition(Idle);
  }

  stop(): void {
    this._checkInvariant();
  }

  interrupt(): void {
    this._checkInvariant();
    this.ctx.interrupt();
    this.ctx.postInterrupted();
  }
}

/**
 * Ready to accept one {@link write}; no port write in flight.
 *
 * Invariants: {@link WriterContext.assertDisarmed}.
 */
@ihsm.InitialState
export class Idle extends WriteObserving {
  protected override _checkInvariant(): void {
    super._checkInvariant();
    this.ctx.assertDisarmed();
  }

  onEntry(): void {
    this.ctx.resetIdle();
    this.ctx.postWriterReady();
    this._checkInvariant();
  }

  async write(message: string): Promise<void> {
    this._checkInvariant();
    return new Promise<void>((resolve, reject) => {
      try {
        this.ctx.pendingWrite = { message, resolve, reject };
        this.hsm.transition(Writing);
      } catch (err) {
        this.ctx.pendingWrite = undefined;
        reject(err instanceof Error ? err : new Error(String(err)));
      }
    });
  }

  onWriteProgress(_written: number): void {
    this._checkInvariant();
  }

  onWriteSucceeded(): void {
    this._checkInvariant();
  }
}

/**
 * Port write in flight for the sole pending message.
 *
 * Invariants: {@link WriterContext.assertWriting}.
 */
export class Writing extends WriteObserving {
  protected override _checkInvariant(): void {
    super._checkInvariant();
    this.ctx.assertWriting();
  }

  onEntry(): void {
    if (this.ctx.outBuffer.length === 0) {
      this.ctx.outBuffer = formatTextFramedMessage(this.ctx.pendingWrite!.message);
    }
    this.ctx.assertOutboundPending();
    this._checkInvariant();
    this.notify.doWrite();
  }

  async write(_message: string): Promise<void> {
    this._checkInvariant();
    throw new Error("writer busy: a message is already in flight");
  }

  doWrite(): void {
    this._checkInvariant();
    this.ctx.assertOutboundPending();
    this.hsm.port.write(this.ctx.outBuffer);
  }

  onWriteProgress(written: number): void {
    this._checkInvariant();
    this.ctx.consumeOutBuffer(written);
  }

  onWriteSucceeded(): void {
    this._checkInvariant();
    if (this.ctx.outBuffer.length > 0) {
      this.ctx.consumeOutBuffer(this.ctx.outBuffer.length);
    }
    this.notify.doComplete();
  }
}

export function createWriterSettings(parent: CBServerConfig): ICBServerWriterSettings {
  return {
    clientToolName: parent.mmkit.clientToolName,
    clientUserName: parent.mmkit.clientUserName,
    askFormat: "ASK",
    answerRep: "",
    rollbackTime: "",
  };
}

export function createWriterContext(settings?: ICBServerWriterSettings,
  server?: CBServerActorRef,): WriterContext {
  return new WriterContext(settings ?? {
      clientToolName: "mmkit-server",
      clientUserName: "mmkit",
      askFormat: "ASK",
      answerRep: "",
      rollbackTime: "",
    }, server,);
}

export function createWriterActor(port: ihsm.Port<typeof WriterTop>,
  settings?: ICBServerWriterSettings,
  server?: CBServerActorRef,
  options?: ihsm.ActorOptions<WriterMachineConfig>,): ihsm.ExternalActor<WriterMachineConfig> {
  return ihsm.makeActor(WriterTop, createWriterContext(settings, server), port, options);
}

ihsm.registerStateNames(self);
