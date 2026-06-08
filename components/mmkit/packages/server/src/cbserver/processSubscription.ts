import type { ChildProcess } from "node:child_process";
import * as net from "node:net";
import type { Disposable } from "./Disposable";
import type { ProcessMailbox, ProcessStream } from "./processMailbox";

const MAX_IO_BYTES = 64 * 1024;

export interface PortListenOptions {
  host: string;
  port: number;
  maxAttempts: number;
  intervalMs: number;
}

export interface SubprocessIoBuffers {
  stdout: string;
  stderr: string;
}

function appendChunk(buffer: string, chunk: Buffer): string {
  const next = buffer + chunk.toString("utf8");
  if (next.length <= MAX_IO_BYTES) {
    return next;
  }
  return next.slice(-MAX_IO_BYTES);
}

function attachChild(child: ChildProcess, mailbox: ProcessMailbox, buffers?: SubprocessIoBuffers): Disposable {
  let active = true;

  const detach = () => {
    if (!active) {
      return;
    }
    active = false;
    child.stdout?.removeAllListeners();
    child.stderr?.removeAllListeners();
    child.removeAllListeners("exit");
    child.removeAllListeners("close");
    child.removeAllListeners("error");
    child.removeAllListeners("disconnect");
  };

  const postSpawn = () => {
    if (active) {
      mailbox.post("onSpawn");
    }
  };
  if (child.pid !== undefined) {
    postSpawn();
  } else {
    child.once("spawn", postSpawn);
  }

  const onData = (stream: ProcessStream, chunk: Buffer) => {
    if (!active) {
      return;
    }
    if (buffers !== undefined) {
      buffers[stream] = appendChunk(buffers[stream], chunk);
    }
    mailbox.post("onData", stream, chunk.toString("utf8"));
  };

  if (child.stdout) {
    child.stdout.on("data", (chunk: Buffer) => onData("stdout", chunk));
    child.stdout.once("end", () => active && mailbox.post("onEnd", "stdout"));
    child.stdout.once("error", (err) => active && mailbox.post("onStdioError", "stdout", String(err)));
  }

  if (child.stderr) {
    child.stderr.on("data", (chunk: Buffer) => onData("stderr", chunk));
    child.stderr.once("end", () => active && mailbox.post("onEnd", "stderr"));
    child.stderr.once("error", (err) => active && mailbox.post("onStdioError", "stderr", String(err)));
  }

  child.once("exit", (code, signal) => {
    if (!active) {
      return;
    }
    mailbox.post("onProcessExit", code, signal);
    detach();
  });

  child.once("close", (code, signal) => {
    if (!active) {
      return;
    }
    mailbox.post("onProcessClose", code, signal);
    detach();
  });

  child.once("error", (err) => {
    if (!active) {
      return;
    }
    mailbox.post("onProcessError", String(err));
    detach();
  });

  child.once("disconnect", () => {
    if (!active) {
      return;
    }
    mailbox.post("onDisconnect");
    detach();
  });

  return { dispose: detach };
}

/** Event-driven TCP listen — posts `onPortReady` or `onFailToStart`; self-disposes on either. */
export function attachPortListen(mailbox: ProcessMailbox, options: PortListenOptions): Disposable {
  let active = true;
  let attempt = 0;
  let timer: NodeJS.Timeout | undefined;

  const dispose = () => {
    active = false;
    if (timer !== undefined) {
      clearTimeout(timer);
      timer = undefined;
    }
  };

  const scheduleRetry = () => {
    if (!active) {
      return;
    }
    attempt += 1;
    if (attempt >= options.maxAttempts) {
      mailbox.post("onFailToStart", `cbserver port ${options.port} not reachable`);
      dispose();
      return;
    }
    timer = setTimeout(tryConnect, options.intervalMs);
  };

  const tryConnect = () => {
    if (!active) {
      return;
    }
    const socket = net.connect({ host: options.host, port: options.port });
    let settled = false;
    const settle = (fn: () => void) => {
      if (settled || !active) {
        return;
      }
      settled = true;
      socket.destroy();
      fn();
    };
    const connectTimer = setTimeout(() => {
      settle(scheduleRetry);
    }, 500);
    socket.once("connect", () => {
      clearTimeout(connectTimer);
      settle(() => {
        mailbox.post("onPortReady");
        dispose();
      });
    });
    socket.once("error", () => {
      clearTimeout(connectTimer);
      settle(scheduleRetry);
    });
  };

  tryConnect();
  return { dispose };
}

/** Child push forwarder + optional port-listen watcher; returns one composite disposable. */
export function attachProcessSubscription(child: ChildProcess, mailbox: ProcessMailbox, buffers?: SubprocessIoBuffers, listen?: PortListenOptions): Disposable {
  const parts: Disposable[] = [attachChild(child, mailbox, buffers)];
  if (listen !== undefined) {
    parts.push(attachPortListen(mailbox, listen));
  }
  let disposed = false;
  return {
    dispose: () => {
      if (disposed) {
        return;
      }
      disposed = true;
      for (const part of parts) {
        part.dispose();
      }
    },
  };
}
