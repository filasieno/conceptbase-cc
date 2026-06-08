import type { ProcessMailbox } from "./processMailbox";
import type { PortListenOptions } from "./processSubscription";
import type { Disposable } from "./Disposable";

/** POSIX signal name accepted by `ChildProcess.kill`. */
export type ProcessSignal = NodeJS.Signals;

/** Mirrors `child_process.spawn` options used by {@link CBServerPort}. */
export interface SpawnSpec {
  command: string;
  args: string[];
  cwd?: string;
  env?: NodeJS.ProcessEnv;
  /** Default `pipe` — the port drains streams so cbserver cannot block on full pipes. */
  stdio?: "ignore" | "pipe" | "inherit";
}

export interface SpawnResult {
  pid: number;
  /** Detach push listeners; idempotent. Auto-run when the child exits. */
  subscription: Disposable;
}

export interface SpawnOptions {
  listen?: PortListenOptions;
}

/**
 * Command surface for {@link CBServerActor}.
 * Push observations are forwarded into a {@link ProcessMailbox} per `spawn`.
 */
export interface CBServerPort {
  spawn(spec: SpawnSpec, mailbox: ProcessMailbox, options?: SpawnOptions): Promise<SpawnResult>;
  kill(pid: number, signal?: ProcessSignal): Promise<void>;
}
