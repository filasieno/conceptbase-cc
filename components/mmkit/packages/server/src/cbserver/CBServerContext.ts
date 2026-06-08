import type * as ihsm from "ihsm";
import { EventEmitter } from "node:events";
import type { CBServerActorProtocol } from "./CBServerActor";
import { CBServerConfig } from "./CBServerConfig";
import type { CBServerPort } from "./CBServerPort";
import type { Disposable } from "./Disposable";

const MAX_IO_BYTES = 64 * 1024;

/** ihsm context for {@link CBServerActor} — data only; mutated from state handlers. */
export class CBServerContext {
  mailbox?: ihsm.Hsm<CBServerContext, CBServerActorProtocol>;
  port?: CBServerPort;
  processSubscription?: Disposable;
  readonly config: CBServerConfig;
  readonly statusEvents = new EventEmitter();
  pid?: number;
  shutdownRequested = false;
  killSignaled = false;

  processSpawned = false;
  processStdout = "";
  processStderr = "";
  stdoutEnded = false;
  stderrEnded = false;
  lastExitCode: number | null = null;
  lastExitSignal: NodeJS.Signals | null = null;
  lastProcessError?: string;

  constructor(config?: CBServerConfig) {
    this.config = config ?? new CBServerConfig();
  }
}

export function appendProcessIo(ctx: CBServerContext, stream: "stdout" | "stderr", chunk: string): void {
  const key = stream === "stdout" ? "processStdout" : "processStderr";
  const next = ctx[key] + chunk;
  ctx[key] = next.length <= MAX_IO_BYTES ? next : next.slice(-MAX_IO_BYTES);
}
