import type { Writable } from "node:stream";
import * as ihsm from "ihsm";
import type { ReaderMachineConfig } from "./reader/CBServerReaderConfig";
import type { WriterMachineConfig } from "./writer/CBServerWriterConfig";
import type { CBServerTop } from "./CBServerActor";
import type { ReaderTop } from "./reader/CBServerReaderActor";
import type { WriterTop } from "./writer/CBServerWriterActor";

/** Max bytes per stdin.write while draining an outbound frame (split / backpressure). */
const STDIN_WRITE_CHUNK_BYTES = 16 * 1024;

/**
 * Bridges piped stdout into the reader subactor internal protocol.
 * Subscription armed/disarmed is owned by the reader state machine.
 */
export class ForwardingReaderPort extends ihsm.Port<typeof ReaderTop> {
  subscribe(): ihsm.ResultWithSubscription<void> {
    return {
      value: undefined,
      subscription: {
        dispose: () => undefined,
      },
    };
  }
}

/**
 * Stdin byte sink — reports {@link onWriteProgress} per flushed chunk, then
 * {@link onWriteSucceeded} when the supplied payload is fully drained.
 */
export class StdinWriterPort extends ihsm.Port<typeof WriterTop> {
  private readonly stdin: Writable | undefined;

  constructor(stdin: Writable | undefined) {
    super();
    this.stdin = stdin;
  }

  write(payload: string): void {
    if (this.stdin === undefined) {
      this.actor.notify.onWriteFailed("stdin not available");
      return;
    }
    if (payload.length === 0) {
      this.actor.notify.onWriteSucceeded();
      return;
    }
    this.writeChunk(payload, 0);
  }

  private writeChunk(payload: string, offset: number): void {
    const stdin = this.stdin;
    if (stdin === undefined) {
      return;
    }
    const slice = payload.slice(offset, offset + STDIN_WRITE_CHUNK_BYTES);
    stdin.write(slice, "utf8", (err) => {
      if (err !== undefined && err !== null) {
        this.actor.notify.onWriteFailed(String(err));
        return;
      }
      this.actor.notify.onWriteProgress(slice.length);
      const next = offset + slice.length;
      if (next < payload.length) {
        this.writeChunk(payload, next);
        return;
      }
      this.actor.notify.onWriteSucceeded();
    });
  }
}

export type { CBServerTop };
