import { spawn, type ChildProcess } from "node:child_process";
import type { Writable } from "node:stream";
import * as ihsm from "ihsm";
import { buildLaunchRequest } from "./CBServerSettings";
import type { CBServerConfig, CBServerMachineConfig } from "./CBServerConfig";
import type { CBServerTop } from "./CBServerActor";
import type { ProcessStream } from "./CBServerDefs";

/** Subprocess port — Node `child_process` events become CBServer internal notifications. */
export class CBServerPort extends ihsm.Port<typeof CBServerTop> {
  private readonly tracked = new Map<number, ChildProcess>();

  async spawn(config: CBServerConfig): Promise<ihsm.ResultWithSubscription<number>> {
    const inbound = this.actor;
    const launch = buildLaunchRequest(config);
    const child = spawn(launch.executablePath, [...launch.args], {
      cwd: launch.cwd,
      env: launch.env,
      stdio: ["pipe", "pipe", "pipe"],
      detached: false,
      windowsHide: true,
    });
    const subscription = this.bindChildProcess(child, inbound);
    const pid =
      child.pid ??
      (await new Promise<number | undefined>((resolve) => {
        child.once("spawn", () => resolve(child.pid));
        child.once("error", () => resolve(undefined));
      }));
    if (pid === undefined) {
      subscription.dispose();
      throw new Error(`failed to spawn ${launch.executablePath}`);
    }
    this.tracked.set(pid, child);
    child.once("exit", () => {
      this.tracked.delete(pid);
    });
    return { value: pid, subscription };
  }

  stdinFor(pid: number): Writable | undefined {
    const stdin = this.tracked.get(pid)?.stdin;
    if (stdin === null || stdin === undefined) {
      return undefined;
    }
    return stdin;
  }

  async kill(pid: number, signal: NodeJS.Signals = "SIGTERM"): Promise<void> {
    this.tracked.get(pid)?.kill(signal);
  }

  private bindChildProcess(child: ChildProcess,
    inbound: ihsm.InboundActor<CBServerMachineConfig>,): ihsm.Disposable {
    let active = true;

    const detach = (): void => {
      if (!active) {
        return;
      }
      active = false;
      child.stdout?.removeAllListeners();
      child.stderr?.removeAllListeners();
      child.stdin?.removeAllListeners();
      child.removeAllListeners("exit");
      child.removeAllListeners("close");
      child.removeAllListeners("error");
      child.removeAllListeners("disconnect");
    };

    const postSpawn = (): void => {
      if (active) {
        inbound.notify.onSpawn();
      }
    };
    if (child.pid !== undefined) {
      postSpawn();
    } else {
      child.once("spawn", postSpawn);
    }

    const onData = (stream: ProcessStream, chunk: Buffer): void => {
      if (!active) {
        return;
      }
      inbound.notify.onData(stream, chunk.toString("utf8"));
    };

    child.stdout?.on("data", (chunk: Buffer) => onData("stdout", chunk));
    child.stdout?.once("end", () => active && inbound.notify.onEnd("stdout"));
    child.stdout?.once("error", (err) => active && inbound.notify.onStdioError("stdout", String(err)));

    child.stderr?.on("data", (chunk: Buffer) => onData("stderr", chunk));
    child.stderr?.once("end", () => active && inbound.notify.onEnd("stderr"));
    child.stderr?.once("error", (err) => active && inbound.notify.onStdioError("stderr", String(err)));

    child.once("exit", (code, signal) => {
      if (!active) {
        return;
      }
      inbound.notify.onProcessExit(code, signal);
      detach();
    });

    child.once("close", (code, signal) => {
      if (!active) {
        return;
      }
      inbound.notify.onProcessClose(code, signal);
      detach();
    });

    child.once("error", (err) => {
      if (!active) {
        return;
      }
      inbound.notify.onProcessError(String(err));
      detach();
    });

    child.once("disconnect", () => {
      if (!active) {
        return;
      }
      inbound.notify.onDisconnect();
      detach();
    });

    return { dispose: detach };
  }
}
