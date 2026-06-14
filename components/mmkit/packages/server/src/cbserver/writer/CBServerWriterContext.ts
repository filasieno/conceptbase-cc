import type { CBServerActorRef } from "../CBServerConfig";
import type { ICBServerWriterSettings } from "./CBServerWriterConfig";

export type PendingWrite = {
  message: string;
  resolve(): void;
  reject(error: Error): void;
};

export interface IWriterContext {
  readonly config: ICBServerWriterSettings;
  readonly server: CBServerActorRef | undefined;
  interrupted: boolean;
  interruptedPosted: boolean;
  outBuffer: string;
  pendingWrite?: PendingWrite;
  assertDisarmed(): void;
  assertWriting(): void;
  assertOutboundPending(): void;
  clearOutBuffer(): void;
  consumeOutBuffer(written: number): void;
  shutdown(): void;
  resetIdle(): void;
  interrupt(): void;
  postInterrupted(): void;
  postWriterReady(): void;
}

/** Domain data for the CBServer writer subactor. */
export class WriterContext implements IWriterContext {
  readonly config: ICBServerWriterSettings;
  readonly server: CBServerActorRef | undefined;
  interrupted = false;
  interruptedPosted = false;
  /** Length-prefixed stdin payload not yet accepted by the port (split writes / backpressure). */
  outBuffer = "";
  pendingWrite?: PendingWrite;

  constructor(config: ICBServerWriterSettings, server?: CBServerActorRef) {
    this.config = config;
    this.server = server;
  }

  assertDisarmed(): void {
    if (this.pendingWrite !== undefined) {
      throw new Error("invariant violation: pendingWrite must be unset when disarmed");
    }
    if (this.outBuffer.length > 0) {
      throw new Error("invariant violation: outBuffer must be empty when disarmed");
    }
  }

  assertWriting(): void {
    if (this.pendingWrite === undefined) {
      throw new Error("invariant violation: pendingWrite must be set while writing");
    }
  }

  assertOutboundPending(): void {
    if (this.outBuffer.length === 0) {
      throw new Error("invariant violation: outBuffer must hold unsent framed bytes");
    }
  }

  clearOutBuffer(): void {
    this.outBuffer = "";
  }

  /** Drop bytes the port has flushed to stdin. */
  consumeOutBuffer(written: number): void {
    if (written <= 0) {
      return;
    }
    if (written > this.outBuffer.length) {
      throw new Error("invariant violation: cannot consume more outbound bytes than buffered");
    }
    this.outBuffer = this.outBuffer.slice(written);
  }

  /** {@link Stopped.onEntry} — reject in-flight write. */
  shutdown(): void {
    const pending = this.pendingWrite;
    this.clearOutBuffer();
    this.pendingWrite = undefined;
    pending?.reject(new Error("writer stopped"));
  }

  resetIdle(): void {
    this.clearOutBuffer();
    this.pendingWrite = undefined;
  }

  interrupt(): void {
    this.interrupted = true;
  }

  postInterrupted(): void {
    if (this.interruptedPosted) {
      return;
    }
    this.interruptedPosted = true;
    this.server?.notify.onWriterInterrupted();
  }

  postWriterReady(): void {
    if (this.interrupted) {
      throw new Error("invariant violation: writer posted onWriterReady after interrupt");
    }
    this.server?.notify.onWriterReady();
  }
}
