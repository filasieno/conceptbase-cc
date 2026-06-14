import * as ihsm from "ihsm";
import type { CBServerActorRef } from "../CBServerConfig";
import type { IpcAnswer } from "../CBServerDefs";
import type { ICBServerReaderSettings } from "./CBServerReaderConfig";

export type PendingRead = {
  resolve(answer: IpcAnswer): void;
  reject(error: Error): void;
};

export interface IReaderContext {
  readonly config: ICBServerReaderSettings;
  readonly server: CBServerActorRef | undefined;
  interrupted: boolean;
  interruptedPosted: boolean;
  subscription?: ihsm.Disposable;
  buffer: string;
  pendingRead?: PendingRead;
  assertDisarmed(): void;
  assertNoBufferedData(): void;
  assertSubscribed(): void;
  assertAwaitingRead(): void;
  assertReady(): void;
  disposeSubscription(): void;
  appendBuffer(chunk: string): void;
  consumeBuffer(consumed: number): void;
  clearBuffer(): void;
  shutdown(): void;
  resetIdle(): void;
  interrupt(): void;
  postInterrupted(): void;
  postReaderAnswer(answer: IpcAnswer): void;
  postReaderFailed(message: string): void;
}

/** Domain data for the CBServer reader subactor. */
export class ReaderContext implements IReaderContext {
  readonly config: ICBServerReaderSettings;
  readonly server: CBServerActorRef | undefined;
  interrupted = false;
  interruptedPosted = false;
  subscription?: ihsm.Disposable;
  buffer = "";
  pendingRead?: PendingRead;

  constructor(config: ICBServerReaderSettings, server?: CBServerActorRef) {
    this.config = config;
    this.server = server;
  }

  assertDisarmed(): void {
    if (this.subscription !== undefined) {
      throw new Error("invariant violation: reader subscription must be disarmed");
    }
    if (this.pendingRead !== undefined) {
      throw new Error("invariant violation: no readAnswer call may be pending when disarmed");
    }
  }

  assertNoBufferedData(): void {
    if (this.buffer.length > 0) {
      throw new Error("invariant violation: parse buffer must be empty");
    }
  }

  assertSubscribed(): void {
    if (this.subscription === undefined) {
      throw new Error("invariant violation: reader subscription must be armed");
    }
  }

  assertAwaitingRead(): void {
    this.assertSubscribed();
    if (this.pendingRead === undefined) {
      throw new Error("invariant violation: readAnswer must be pending");
    }
  }

  assertReady(): void {
    this.assertSubscribed();
    if (this.pendingRead !== undefined) {
      throw new Error("invariant violation: no readAnswer call may be pending in Ready");
    }
  }

  disposeSubscription(): void {
    this.subscription?.dispose();
    this.subscription = undefined;
  }

  /** Append stdout bytes; buffer grows without bound until a frame is consumed. */
  appendBuffer(chunk: string): void {
    if (chunk.length === 0) {
      return;
    }
    this.buffer += chunk;
  }

  /** Drop a fully parsed text-framed prefix (header + body) from the parse buffer. */
  consumeBuffer(consumed: number): void {
    if (consumed <= 0) {
      return;
    }
    if (consumed > this.buffer.length) {
      throw new Error("invariant violation: cannot consume more bytes than buffered");
    }
    this.buffer = this.buffer.slice(consumed);
  }

  clearBuffer(): void {
    this.buffer = "";
  }

  /** {@link Stopped.onEntry} — reject pending read and release subscription. */
  shutdown(): void {
    const pending = this.pendingRead;
    this.disposeSubscription();
    this.clearBuffer();
    this.pendingRead = undefined;
    pending?.reject(new Error("reader stopped"));
  }

  resetIdle(): void {
    this.disposeSubscription();
    this.clearBuffer();
    this.pendingRead = undefined;
  }

  interrupt(): void {
    this.interrupted = true;
  }

  postInterrupted(): void {
    if (this.interruptedPosted) {
      return;
    }
    this.interruptedPosted = true;
    this.server?.notify.onReaderInterrupted();
  }

  postReaderAnswer(answer: IpcAnswer): void {
    if (this.interrupted) {
      throw new Error("invariant violation: reader posted onReaderAnswer after interrupt");
    }
    this.server?.notify.onReaderAnswer(answer);
  }

  postReaderFailed(message: string): void {
    if (this.interrupted) {
      throw new Error("invariant violation: reader posted onReaderFailed after interrupt");
    }
    this.server?.notify.onReaderFailed(message);
  }
}
