import { expect } from "chai";
import { createCBServerActor } from "../src/cbserver/CBServerActor";
import { CBServerConfig } from "../src/cbserver/CBServerConfig";
import { waitForHsmState } from "./helpers/hsm";
import { createSimCBServerPort, type SimCBServerPort } from "./ports/SimCBServerPort";

function testConfig(overrides: Partial<CBServerConfig> = {}): CBServerConfig {
  return new CBServerConfig({ port: 4001, executablePath: "cbserver", ...overrides });
}

const activeActors: ReturnType<typeof createCBServerActor>[] = [];

async function createInitializedActor(portFactory: () => SimCBServerPort,
  config = testConfig()) {
  const actor = createCBServerActor(config);
  activeActors.push(actor);
  await actor.sync();
  expect(actor.currentStateName).to.equal("Uninitialized");
  const port = portFactory();
  await actor.call("initialize", port);
  await actor.sync();
  expect(actor.currentStateName).to.equal("Stopped");
  return { actor, port };
}

describe("CBServerActor", function () {
  this.timeout(10_000);

  afterEach(async () => {
    for (const actor of activeActors) {
      await actor.sync();
      if (
        actor.currentStateName !== "Uninitialized" &&
        actor.currentStateName !== "Stopped" &&
        actor.currentStateName !== "ShuttingDown" &&
        actor.currentStateName !== "FatalErrorState"
      ) {
        actor.post("stop");
        await waitForHsmState(actor, "Stopped").catch(() => undefined);
        await actor.sync();
      }
    }
    activeActors.length = 0;
  });

  it("starts in Uninitialized until initialize", async () => {
    const actor = createCBServerActor();
    activeActors.push(actor);
    await actor.sync();
    expect(actor.currentStateName).to.equal("Uninitialized");
  });

  it("reaches WatchingProcess after initialize and start", async () => {
    const { actor } = await createInitializedActor(() => createSimCBServerPort().port);
    actor.post("start");
    await waitForHsmState(actor, "WatchingProcess");
  });

  it("does not start without initialize", async () => {
    const actor = createCBServerActor();
    activeActors.push(actor);
    await actor.sync();
    actor.post("start");
    await actor.sync();
    expect(actor.currentStateName).to.equal("Uninitialized");
  });

  it("returns to Stopped on stop from WatchingProcess", async () => {
    const { actor, port } = await createInitializedActor(() => createSimCBServerPort().port);

    actor.post("start");
    await waitForHsmState(actor, "WatchingProcess");

    actor.post("stop");
    await waitForHsmState(actor, "Stopped");

    expect(port.sim.killCount).to.equal(1);
    expect(actor.ctx.processSubscription).to.equal(undefined);
  });

  it("spawns the configured executable path", async () => {
    const { actor, port } = await createInitializedActor(() => createSimCBServerPort().port, testConfig({ executablePath: "/opt/cbserver/bin/cbserver" }));

    actor.post("start");
    await waitForHsmState(actor, "WatchingProcess");

    expect(port.sim.lastSpawnSpec?.command).to.equal("/opt/cbserver/bin/cbserver");
    expect(port.sim.lastSpawnSpec?.args).to.deep.equal(["-p", "4001"]);
  });

  it("subscribeStatus delivers state names via call", async () => {
    const { actor } = await createInitializedActor(() => createSimCBServerPort().port);
    const states: string[] = [];
    const listener = (state: string) => states.push(state);

    await actor.call("subscribeStatus", listener);

    actor.post("start");
    await waitForHsmState(actor, "WatchingProcess");

    expect(states[0]).to.equal("Stopped");
    expect(states).to.include("Starting");
  });

  it("unsubscribeStatus stops notifications via call", async () => {
    const { actor } = await createInitializedActor(() => createSimCBServerPort().port);
    const states: string[] = [];
    const listener = (state: string) => states.push(state);

    await actor.call("subscribeStatus", listener);
    await actor.call("unsubscribeStatus", listener);

    states.length = 0;
    actor.post("start");
    await waitForHsmState(actor, "WatchingProcess");

    expect(states).to.deep.equal([]);
  });

  it("ignores start while already starting", async () => {
    const { actor, port } = await createInitializedActor(() => createSimCBServerPort({ reachable: false }).port, testConfig({ portProbeAttempts: 5, portProbeIntervalMs: 2000 }));

    actor.post("start");
    await waitForHsmState(actor, "ProbingPort");
    const spawnCountAfterFirstStart = port.sim.spawnCount;

    actor.post("start");
    await actor.sync();

    expect(port.sim.spawnCount).to.equal(spawnCountAfterFirstStart);
  });

  it("accumulates subprocess IO in context from mailbox events", async () => {
    const { actor, port } = await createInitializedActor(() => createSimCBServerPort().port);

    actor.post("start");
    await waitForHsmState(actor, "WatchingProcess");

    const pid = actor.ctx.pid!;
    port.scriptIo(pid, "stdout", "ready\n");
    port.scriptIo(pid, "stderr", "warn\n");
    await actor.sync();

    expect(actor.ctx.processStdout).to.equal("ready\n");
    expect(actor.ctx.processStderr).to.equal("warn\n");
    expect(actor.ctx.processSpawned).to.equal(true);
  });

  it("records exit signal from subprocess sink", async () => {
    const { actor, port } = await createInitializedActor(() => createSimCBServerPort().port);

    actor.post("start");
    await waitForHsmState(actor, "WatchingProcess");

    const pid = actor.ctx.pid!;
    port.scriptExit(pid, null, "SIGSEGV");
    await waitForHsmState(actor, "Stopped");

    expect(actor.ctx.lastExitSignal).to.equal("SIGSEGV");
    expect(actor.ctx.stdoutEnded).to.equal(true);
    expect(actor.ctx.stderrEnded).to.equal(true);
    expect(actor.ctx.processSubscription).to.equal(undefined);
  });

  it("ignores IO after subscription disposed", async () => {
    const { actor, port } = await createInitializedActor(() => createSimCBServerPort().port);

    actor.post("start");
    await waitForHsmState(actor, "WatchingProcess");

    const pid = actor.ctx.pid!;
    actor.post("stop");
    await waitForHsmState(actor, "Stopped");

    port.scriptIo(pid, "stdout", "late\n");
    await actor.sync();

    expect(actor.ctx.processStdout).to.equal("");
  });

  it("fails start on subprocess error during Starting", async () => {
    const { actor, port } = await createInitializedActor(() => createSimCBServerPort({ reachable: false }).port, testConfig({ portProbeAttempts: 10, portProbeIntervalMs: 200 }));

    actor.post("start");
    await waitForHsmState(actor, "ProbingPort");

    port.scriptError(actor.ctx.pid!, "spawn EACCES");
    await waitForHsmState(actor, "Stopped", { timeoutMs: 3000 });

    expect(actor.ctx.lastProcessError).to.equal("spawn EACCES");
    expect(actor.ctx.processSubscription).to.equal(undefined);
  });

  it("stops on IPC disconnect while running", async () => {
    const { actor, port } = await createInitializedActor(() => createSimCBServerPort().port);

    actor.post("start");
    await waitForHsmState(actor, "WatchingProcess");

    port.scriptDisconnect(actor.ctx.pid!);
    await waitForHsmState(actor, "Stopped");
  });
});
