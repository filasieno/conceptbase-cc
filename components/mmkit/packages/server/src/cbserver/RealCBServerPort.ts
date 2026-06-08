import { spawn, type ChildProcess, type StdioOptions } from "node:child_process";

function waitForChildPid(child: ChildProcess): Promise<number | undefined> {
  if (child.pid !== undefined) {
    return Promise.resolve(child.pid);
  }
  return new Promise((resolve) => {
    child.once("spawn", () => resolve(child.pid));
    child.once("error", () => resolve(undefined));
  });
}
import type { CBServerPort, SpawnOptions, SpawnSpec } from "./CBServerPort";
import type { ProcessMailbox } from "./processMailbox";
import { attachProcessSubscription } from "./processSubscription";

interface TrackedProcess {
  child: ChildProcess;
  stdout: string;
  stderr: string;
}

function stdioOption(mode: SpawnSpec["stdio"]): StdioOptions {
  if (mode === "ignore" || mode === "inherit") {
    return mode;
  }
  return "pipe";
}

export class RealCBServerPort implements CBServerPort {
  private readonly tracked = new Map<number, TrackedProcess>();

  async spawn(spec: SpawnSpec, mailbox: ProcessMailbox, options?: SpawnOptions) {
    const stdio = stdioOption(spec.stdio ?? "pipe");
    const child = spawn(spec.command, spec.args, {
      cwd: spec.cwd,
      env: spec.env ?? process.env,
      stdio,
      detached: false,
      windowsHide: true,
    });
    const entry: TrackedProcess = { child, stdout: "", stderr: "" };
    const subscription = attachProcessSubscription(child, mailbox, entry, options?.listen);

    const pid = await waitForChildPid(child);
    if (pid === undefined) {
      subscription.dispose();
      throw new Error(`failed to spawn ${spec.command}`);
    }
    this.tracked.set(pid, entry);

    child.once("exit", () => {
      this.tracked.delete(pid);
    });

    return { pid, subscription };
  }

  async kill(pid: number, signal: NodeJS.Signals = "SIGTERM") {
    const entry = this.tracked.get(pid);
    if (!entry) {
      return;
    }
    entry.child.kill(signal);
  }
}

export function createRealCBServerPort(): RealCBServerPort {
  return new RealCBServerPort();
}
