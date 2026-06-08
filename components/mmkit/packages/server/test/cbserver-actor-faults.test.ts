import { expect } from "chai";
import { waitForHsmState } from "./helpers/hsm";
import { pollUntil } from "./helpers/async";
import { allocatePort, cleanupActors, createInitializedActor, testConfig } from "./helpers/actor";
import { createSimCBServerPort, type SimCBServerPort } from "./ports/SimCBServerPort";

function simPort(overrides: Parameters<typeof createSimCBServerPort>[0] = {}): SimCBServerPort {
  return createSimCBServerPort(overrides).port;
}

describe("CBServerActor faults (sim port)", function () {
  this.timeout(15_000);

  afterEach(async () => {
    await cleanupActors();
  });

  describe("port probe failures", () => {
    it("fails start when the port never becomes reachable", async () => {
      const port = allocatePort();
      const { actor } = await createInitializedActor(() => simPort({ reachable: false }), testConfig({ port, portProbeAttempts: 4, portProbeIntervalMs: 40 }));

      actor.post("start");
      await waitForHsmState(actor, "Stopped", { timeoutMs: 5_000 });

      expect(actor.ctx.lastProcessError).to.match(/not reachable/);
      expect(actor.ctx.processSubscription).to.equal(undefined);
      expect(actor.ctx.pid).to.equal(undefined);
    });

    it("reaches Running after a delayed port-ready signal", async () => {
      const { actor } = await createInitializedActor(() => simPort({ reachable: true, startupDelayMs: 120 }));

      actor.post("start");
      await waitForHsmState(actor, "WatchingProcess", { timeoutMs: 5_000 });
    });

    it("reaches Running when the port opens mid-probe", async () => {
      const port = allocatePort();
      const { actor, port: sim } = await createInitializedActor(() => simPort({ reachable: false }), testConfig({ port, portProbeAttempts: 20, portProbeIntervalMs: 80 }));

      actor.post("start");
      await waitForHsmState(actor, "ProbingPort");

      const pid = actor.ctx.pid!;
      (sim as SimCBServerPort).scriptPortReady(pid);
      await waitForHsmState(actor, "WatchingProcess");
    });
  });

  describe("spawn and early process death", () => {
    it("fails start when spawn throws", async () => {
      const { actor } = await createInitializedActor(() =>
        simPort({ spawnThrows: "EACCES: permission denied" }));

      actor.post("start");
      await waitForHsmState(actor, "Stopped", { timeoutMs: 3_000 });

      expect(actor.ctx.lastProcessError).to.match(/cbserver start failed/);
      expect(actor.ctx.lastProcessError).to.match(/EACCES/);
    });

    it("fails start when the process exits with a non-zero code during probe", async () => {
      const port = allocatePort();
      const { actor, port: sim } = await createInitializedActor(() => simPort({ reachable: false }), testConfig({ port, portProbeAttempts: 30, portProbeIntervalMs: 100 }));

      actor.post("start");
      await waitForHsmState(actor, "ProbingPort");

      (sim as SimCBServerPort).scriptExit(actor.ctx.pid!, 127);
      await waitForHsmState(actor, "Stopped", { timeoutMs: 3_000 });

      expect(actor.ctx.lastExitCode).to.equal(127);
      expect(actor.ctx.lastProcessError).to.match(/exited during start/);
    });

    it("fails start when the process is signaled during probe", async () => {
      const port = allocatePort();
      const { actor, port: sim } = await createInitializedActor(() => simPort({ reachable: false }), testConfig({ port, portProbeAttempts: 30, portProbeIntervalMs: 100 }));

      actor.post("start");
      await waitForHsmState(actor, "ProbingPort");

      (sim as SimCBServerPort).scriptExit(actor.ctx.pid!, null, "SIGABRT");
      await waitForHsmState(actor, "Stopped", { timeoutMs: 3_000 });

      expect(actor.ctx.lastExitSignal).to.equal("SIGABRT");
      expect(actor.ctx.lastProcessError).to.match(/exited during start/);
    });
  });

  describe("stop and restart paths", () => {
    it("stops while still probing an unreachable port", async () => {
      const port = allocatePort();
      const { actor, port: sim } = await createInitializedActor(() => simPort({ reachable: false }), testConfig({ port, portProbeAttempts: 50, portProbeIntervalMs: 200 }));

      actor.post("start");
      await waitForHsmState(actor, "ProbingPort");

      actor.post("stop");
      await waitForHsmState(actor, "Stopped");

      expect((sim as SimCBServerPort).sim.killCount).to.be.greaterThan(0);
    });

    it("ignores stop when already Stopped", async () => {
      const { actor, port: sim } = await createInitializedActor(() => simPort());

      actor.post("stop");
      await actor.sync();

      expect(actor.currentStateName).to.equal("Stopped");
      expect((sim as SimCBServerPort).sim.killCount).to.equal(0);
    });

    it("ignores duplicate stop from WatchingProcess", async () => {
      const { actor, port: sim } = await createInitializedActor(() => simPort());

      actor.post("start");
      await waitForHsmState(actor, "WatchingProcess");

      actor.post("stop");
      await waitForHsmState(actor, "Stopped");

      const killsAfterFirstStop = (sim as SimCBServerPort).sim.killCount;
      actor.post("stop");
      await actor.sync();

      expect((sim as SimCBServerPort).sim.killCount).to.equal(killsAfterFirstStop);
    });

    it("recovers from a failed start and reaches Running on a later start", async () => {
      const port = allocatePort();
      const { actor, port: sim } = await createInitializedActor(() => simPort({ reachable: false }), testConfig({ port, portProbeAttempts: 3, portProbeIntervalMs: 40 }));

      actor.post("start");
      await waitForHsmState(actor, "Stopped", { timeoutMs: 5_000 });

      (sim as SimCBServerPort).sim.reachable = true;
      actor.post("start");
      await waitForHsmState(actor, "WatchingProcess");
    });

    it("supports start → stop → start cycles", async () => {
      const { actor } = await createInitializedActor(() => simPort());

      for (let cycle = 0; cycle < 2; cycle += 1) {
        actor.post("start");
        await waitForHsmState(actor, "WatchingProcess");
        actor.post("stop");
        await waitForHsmState(actor, "Stopped");
      }
    });
  });

  describe("stdio and subprocess errors while running", () => {
    it("records stdio stream errors in context", async () => {
      const { actor, port: sim } = await createInitializedActor(() => simPort());

      actor.post("start");
      await waitForHsmState(actor, "WatchingProcess");

      const pid = actor.ctx.pid!;
      (sim as SimCBServerPort).scriptStdioError(pid, "stdout", "broken pipe");
      (sim as SimCBServerPort).scriptStdioError(pid, "stderr", "epipe");
      await actor.sync();

      expect(actor.ctx.lastProcessError).to.equal("stderr: epipe");
    });

    it("records stream end without exiting", async () => {
      const { actor, port: sim } = await createInitializedActor(() => simPort());

      actor.post("start");
      await waitForHsmState(actor, "WatchingProcess");

      const pid = actor.ctx.pid!;
      (sim as SimCBServerPort).scriptEnd(pid, "stdout");
      (sim as SimCBServerPort).scriptEnd(pid, "stderr");
      await actor.sync();

      expect(actor.ctx.stdoutEnded).to.equal(true);
      expect(actor.ctx.stderrEnded).to.equal(true);
      expect(actor.currentStateName).to.equal("WatchingProcess");
    });

    it("truncates accumulated IO at 64 KiB", async () => {
      const { actor, port: sim } = await createInitializedActor(() => simPort());

      actor.post("start");
      await waitForHsmState(actor, "WatchingProcess");

      const pid = actor.ctx.pid!;
      const chunk = "x".repeat(1024);
      for (let i = 0; i < 70; i += 1) {
        (sim as SimCBServerPort).scriptIo(pid, "stdout", chunk);
      }
      await actor.sync();

      expect(actor.ctx.processStdout.length).to.equal(64 * 1024);
      expect(actor.ctx.processStdout.endsWith(chunk)).to.equal(true);
    });

    it("returns to Stopped on process error while running", async () => {
      const { actor, port: sim } = await createInitializedActor(() => simPort());

      actor.post("start");
      await waitForHsmState(actor, "WatchingProcess");

      (sim as SimCBServerPort).scriptError(actor.ctx.pid!, "write EPIPE");
      await waitForHsmState(actor, "Stopped");

      expect(actor.ctx.lastProcessError).to.equal("write EPIPE");
    });

    it("returns to Stopped on a clean exit code while running", async () => {
      const { actor, port: sim } = await createInitializedActor(() => simPort());

      actor.post("start");
      await waitForHsmState(actor, "WatchingProcess");

      (sim as SimCBServerPort).scriptExit(actor.ctx.pid!, 0);
      await waitForHsmState(actor, "Stopped");

      expect(actor.ctx.lastExitCode).to.equal(0);
      expect(actor.ctx.lastExitSignal).to.equal(null);
    });
  });

  describe("stop and shutdown while exiting", () => {
    it("sends SIGKILL after kill grace when SIGTERM is ignored", async () => {
      const { actor, port: sim } = await createInitializedActor(() => simPort({ ignoreSigterm: true }), testConfig({ killGraceMs: 200 }));

      actor.post("start");
      await waitForHsmState(actor, "WatchingProcess");

      actor.post("stop");
      await waitForHsmState(actor, "AwaitingExit");

      await pollUntil(async () => {
          await actor.sync();
          return (sim as SimCBServerPort).sim.killCount >= 2;
        }, { timeoutMs: 5_000, label: "SIGKILL after grace" });

      expect((sim as SimCBServerPort).sim.lastKillSignal).to.equal("SIGKILL");
      (sim as SimCBServerPort).scriptExit(actor.ctx.pid!, null, "SIGKILL");
      await waitForHsmState(actor, "Stopped");
    });

    it("returns to Stopped on process error during AwaitingExit", async () => {
      const { actor, port: sim } = await createInitializedActor(() => simPort({ ignoreSigterm: true }));

      actor.post("start");
      await waitForHsmState(actor, "WatchingProcess");

      actor.post("stop");
      await waitForHsmState(actor, "AwaitingExit");

      (sim as SimCBServerPort).scriptError(actor.ctx.pid!, "kill failed");
      await waitForHsmState(actor, "Stopped");

      expect(actor.ctx.lastProcessError).to.equal("kill failed");
    });

    it("returns to Stopped on disconnect during AwaitingExit", async () => {
      const { actor, port: sim } = await createInitializedActor(() => simPort());

      actor.post("start");
      await waitForHsmState(actor, "WatchingProcess");

      actor.post("stop");
      await waitForHsmState(actor, "AwaitingExit");

      (sim as SimCBServerPort).scriptDisconnect(actor.ctx.pid!);
      await waitForHsmState(actor, "Stopped");
    });

    it("enters ShuttingDown when shutdown was requested before stop completes", async () => {
      const { actor, port: sim } = await createInitializedActor(() => simPort());

      actor.post("start");
      await waitForHsmState(actor, "WatchingProcess");

      actor.ctx.shutdownRequested = true;
      actor.post("stop");
      await waitForHsmState(actor, "AwaitingExit");

      const pid = actor.ctx.pid!;
      (sim as SimCBServerPort).scriptExit(pid, 0);
      await waitForHsmState(actor, "ShuttingDown");

      expect(actor.ctx.processSubscription).to.equal(undefined);
    });

    it("enters ShuttingDown on process error during stop when shutdown requested", async () => {
      const { actor, port: sim } = await createInitializedActor(() => simPort());

      actor.post("start");
      await waitForHsmState(actor, "WatchingProcess");

      actor.ctx.shutdownRequested = true;
      actor.post("stop");
      await waitForHsmState(actor, "AwaitingExit");

      (sim as SimCBServerPort).scriptError(actor.ctx.pid!, "teardown fault");
      await waitForHsmState(actor, "ShuttingDown");
    });

    it("survives orphaned onKillGraceElapsed after stop completes", async () => {
      const { actor } = await createInitializedActor(() => simPort(), testConfig({ killGraceMs: 400 }));

      actor.post("start");
      await waitForHsmState(actor, "WatchingProcess");
      actor.post("stop");
      await waitForHsmState(actor, "Stopped");

      await pollUntil(async () => {
          await actor.sync();
          return actor.currentStateName === "Stopped";
        }, { timeoutMs: 2_000, intervalMs: 100, label: "still Stopped after grace timer" });

      expect(actor.currentStateName).to.equal("Stopped");
      expect(actor.currentStateName).to.not.equal("FatalErrorState");
    });
  });

  describe("configuration and queries", () => {
    it("passes extraArgs to spawn", async () => {
      const { actor, port: sim } = await createInitializedActor(() => simPort(), testConfig({ extraArgs: ["--trace", "on"] }));

      actor.post("start");
      await waitForHsmState(actor, "WatchingProcess");

      expect((sim as SimCBServerPort).sim.lastSpawnSpec?.args).to.deep.equal([
        "-p",
        String(actor.ctx.config.port),
        "--trace",
        "on",
      ]);
    });

    it("reports current state via getCurrentStateName", async () => {
      const { actor } = await createInitializedActor(() => simPort());

      const stopped = await actor.call("getCurrentStateName");
      expect(stopped).to.equal("Stopped");

      actor.post("start");
      await waitForHsmState(actor, "WatchingProcess");

      const running = await actor.call("getCurrentStateName");
      expect(running).to.equal("WatchingProcess");
    });
  });
});
