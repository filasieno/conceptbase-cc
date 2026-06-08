/** Stdio stream — mirrors piped `ChildProcess` stdout/stderr. */
export type ProcessStream = "stdout" | "stderr";

/**
 * Minimal forward target for subprocess push events.
 * Implemented by the actor mailbox (`ctx.mailbox`); ports must not touch context.
 */
export interface ProcessMailbox {
  post(event: "onSpawn"): void;
  post(event: "onData", stream: ProcessStream, chunk: string): void;
  post(event: "onEnd", stream: ProcessStream): void;
  post(event: "onStdioError", stream: ProcessStream, errorMessage: string): void;
  post(event: "onProcessExit", code: number | null, signal: NodeJS.Signals | null): void;
  post(event: "onProcessClose", code: number | null, signal: NodeJS.Signals | null): void;
  post(event: "onProcessError", errorMessage: string): void;
  post(event: "onDisconnect"): void;
  post(event: "onPortReady"): void;
  post(event: "onFailToStart", errorMessage: string): void;
}
