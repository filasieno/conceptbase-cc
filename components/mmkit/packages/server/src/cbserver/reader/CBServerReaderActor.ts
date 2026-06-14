import * as ihsm from "ihsm";
import { IpcAnswer, tryParseTextFramedMessage } from "../CBServerDefs";
import type { CBServerActorRef, CBServerConfig } from "../CBServerConfig";
import type { ICBServerReaderSettings, ReaderMachineConfig } from "./CBServerReaderConfig";
import { ReaderContext } from "./CBServerReaderContext";
import type { IReaderContext } from "./CBServerReaderContext";
import * as self from "./CBServerReaderActor";

/**
 * CBServer reader subactor — state hierarchy (* = {@link ihsm.InitialState})
 *
 * ```text
 * ReaderTop
 * * Uninitialized
 * - Initialized
 *   * Idle
 *   - Stopped
 *   - Subscribing
 *   - StreamObserving
 *     - Subscribed
 *       * Ready
 *       - Awaiting
 * ```
 */

/** Root — public queries only. */
export class ReaderTop extends ihsm.TopState<ReaderMachineConfig> {
  protected _checkInvariant(): void {}
}

/** Post-{@link initialize} lifecycle. */
export class Initialized extends ReaderTop {
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
 * Actor created but not yet initialized.
 *
 * Invariants: {@link ReaderContext.assertDisarmed}.
 */
@ihsm.InitialState
export class Uninitialized extends ReaderTop {
  protected override _checkInvariant(): void {
    super._checkInvariant();
    this.ctx.assertDisarmed();
    this.ctx.assertNoBufferedData();
  }

  async initialize(): Promise<void> {
    this._checkInvariant();
    this.hsm.transition(Initialized);
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
 * Terminal — subscription disarmed, buffer empty, reads rejected.
 *
 * Invariants: {@link ReaderContext.assertDisarmed}, {@link ReaderContext.assertNoBufferedData}.
 */
export class Stopped extends Initialized {
  protected override _checkInvariant(): void {
    super._checkInvariant();
    this.ctx.assertDisarmed();
    this.ctx.assertNoBufferedData();
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

  async readAnswer(): Promise<IpcAnswer> {
    this._checkInvariant();
    throw new Error("reader stopped");
  }

  onData(_chunk: string): void {
    this._checkInvariant();
  }

  onEnd(): void {
    this._checkInvariant();
  }

  onStreamError(_message: string): void {
    this._checkInvariant();
  }
}

/**
 * No port subscription; no pending read.
 *
 * Invariants: {@link ReaderContext.assertDisarmed}.
 */
@ihsm.InitialState
export class Idle extends Initialized {
  protected override _checkInvariant(): void {
    super._checkInvariant();
    this.ctx.assertDisarmed();
  }

  onEntry(): void {
    this.ctx.clearBuffer();
    this._checkInvariant();
  }

  async readAnswer(): Promise<IpcAnswer> {
    this._checkInvariant();
    return new Promise<IpcAnswer>((resolve, reject) => {
      try {
        this.ctx.pendingRead = { resolve, reject };
        this.hsm.transition(Subscribing);
        this.notify.doSubscribe();
      } catch (err) {
        this.ctx.pendingRead = undefined;
        reject(err instanceof Error ? err : new Error(String(err)));
      }
    });
  }

  onData(chunk: string): void {
    this._checkInvariant();
    this.ctx.appendBuffer(chunk);
    if (this.ctx.buffer.length > this.ctx.config.maxBufferBytes) {
      this.ctx.clearBuffer();
    }
  }

  onEnd(): void {
    this._checkInvariant();
  }

  onStreamError(_message: string): void {
    this._checkInvariant();
  }
}

/**
 * Stdout may fail or end while a read is armed or pending.
 */
export class StreamObserving extends Initialized {
  onStreamError(message: string): void {
    this._checkInvariant();
    this.notify.doFailPending(message);
  }

  doFailPending(message: string): void {
    this._checkInvariant();
    const pending = this.ctx.pendingRead;
    this.ctx.resetIdle();
    this.hsm.transition(Idle);
    pending?.reject(new Error(message));
    this.ctx.postReaderFailed(message);
  }
}

/**
 * {@link readAnswer} posted {@link doSubscribe}; subscription not yet armed.
 *
 * Invariants: pending read set; subscription disarmed; buffer may hold partial frames.
 */
export class Subscribing extends StreamObserving {
  protected override _checkInvariant(): void {
    super._checkInvariant();
    if (this.ctx.pendingRead === undefined) {
      throw new Error("invariant violation [Subscribing]: readAnswer must be pending");
    }
    if (this.ctx.subscription !== undefined) {
      throw new Error("invariant violation [Subscribing]: subscription must not be armed yet");
    }
  }

  doSubscribe(): void {
    this._checkInvariant();
    try {
      const result = this.hsm.port.subscribe();
      this.ctx.subscription = result.subscription;
      this.hsm.transition(Awaiting);
    } catch (err) {
      const pending = this.ctx.pendingRead;
      this.ctx.resetIdle();
      this.hsm.transition(Idle);
      pending?.reject(err instanceof Error ? err : new Error(String(err)));
    }
  }

  onData(chunk: string): void {
    this._checkInvariant();
    this.ctx.appendBuffer(chunk);
    if (this.ctx.buffer.length > this.ctx.config.maxBufferBytes) {
      this.notify.doFailPending(`ipcanswer exceeded reader buffer limit (${this.ctx.config.maxBufferBytes} bytes)`);
    }
  }

  onEnd(): void {
    this._checkInvariant();
    this.notify.doFailPending("stdout ended before ipcanswer");
  }
}

/** Subscription armed — {@link Ready} or {@link Awaiting}. */
export class Subscribed extends StreamObserving {
  protected override _checkInvariant(): void {
    super._checkInvariant();
    this.ctx.assertSubscribed();
  }

  onExit(): void {
    this.ctx.disposeSubscription();
  }

  onEnd(): void {
    this._checkInvariant();
    this.notify.doFailPending("stdout ended");
  }
}

/**
 * Subscription armed; no pending {@link readAnswer}.
 *
 * Invariants: {@link ReaderContext.assertReady}.
 */
@ihsm.InitialState
export class Ready extends Subscribed {
  protected override _checkInvariant(): void {
    super._checkInvariant();
    this.ctx.assertReady();
  }

  async readAnswer(): Promise<IpcAnswer> {
    this._checkInvariant();
    const parsed = tryParseTextFramedMessage(this.ctx.buffer);
    if (parsed !== undefined) {
      this.ctx.consumeBuffer(parsed.consumed);
      const answer = IpcAnswer.fromTerm(parsed.body);
      this.ctx.postReaderAnswer(answer);
      return answer;
    }
    return new Promise<IpcAnswer>((resolve, reject) => {
      try {
        this.ctx.pendingRead = { resolve, reject };
        this.hsm.transition(Awaiting);
      } catch (err) {
        reject(err instanceof Error ? err : new Error(String(err)));
      }
    });
  }

  onData(chunk: string): void {
    this._checkInvariant();
    this.ctx.appendBuffer(chunk);
    if (this.ctx.buffer.length > this.ctx.config.maxBufferBytes) {
      this.notify.doFailPending(`ipcanswer exceeded reader buffer limit (${this.ctx.config.maxBufferBytes} bytes)`);
    }
  }
}

/**
 * Subscription armed; waiting for the next complete text-framed ipcanswer.
 *
 * Invariants: {@link ReaderContext.assertAwaitingRead}.
 */
export class Awaiting extends Subscribed {
  protected override _checkInvariant(): void {
    super._checkInvariant();
    this.ctx.assertAwaitingRead();
  }

  onEntry(): void {
    this.notify.doDeliverPending();
    this._checkInvariant();
  }

  onData(chunk: string): void {
    this._checkInvariant();
    this.ctx.appendBuffer(chunk);
    if (this.ctx.buffer.length > this.ctx.config.maxBufferBytes) {
      this.notify.doFailPending(`ipcanswer exceeded reader buffer limit (${this.ctx.config.maxBufferBytes} bytes)`);
      return;
    }
    this.notify.doDeliverPending();
  }

  doDeliverPending(): void {
    this._checkInvariant();
    const parsed = tryParseTextFramedMessage(this.ctx.buffer);
    if (parsed === undefined || this.ctx.pendingRead === undefined) {
      return;
    }
    this.ctx.consumeBuffer(parsed.consumed);
    const answer = IpcAnswer.fromTerm(parsed.body);
    const pending = this.ctx.pendingRead;
    this.ctx.pendingRead = undefined;
    this.hsm.transition(Ready);
    pending.resolve(answer);
    this.ctx.postReaderAnswer(answer);
  }
}

export function createReaderSettings(_parent: CBServerConfig): ICBServerReaderSettings {
  return {
    maxBufferBytes: 64 * 1024 * 1024,
  };
}

export function createReaderContext(settings?: ICBServerReaderSettings,
  server?: CBServerActorRef,): ReaderContext {
  return new ReaderContext(settings ?? {
      maxBufferBytes: 64 * 1024 * 1024,
    }, server,);
}

export function createReaderActor(port: ihsm.Port<typeof ReaderTop>,
  settings?: ICBServerReaderSettings,
  server?: CBServerActorRef,
  options?: ihsm.ActorOptions<ReaderMachineConfig>,): ihsm.ExternalActor<ReaderMachineConfig> {
  return ihsm.makeActor(ReaderTop, createReaderContext(settings, server), port, options);
}

ihsm.registerStateNames(self);
