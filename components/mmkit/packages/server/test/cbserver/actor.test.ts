/**
 * CBServerActor — stdio mock-port spec (ihsm 0.1.1).
 */
/// <reference types="mocha" />
import { Writable } from "node:stream";
import { expect } from "chai";
import * as ihsm from "ihsm/testing";
import { CBServerConfig } from "../../src/cbserver/CBServerConfig";
import {
  CBServerTop,
  Starting,
  Uninitialized,
} from "../../src/cbserver/CBServerActor";
import { CBServerContext } from "../../src/cbserver/CBServerContext";

@ihsm.mock("spawn", "stdinFor", "kill")
abstract class MockCBServerPort extends ihsm.TestPort<typeof CBServerTop> {
  abstract spawn(config: CBServerConfig): Promise<ihsm.ResultWithSubscription<number>>;
  abstract stdinFor(pid: number): Writable | undefined;
  abstract kill(pid: number, signal?: NodeJS.Signals): Promise<void>;
}

function makeServer(ctx: CBServerContext) {
  const port = ihsm.makeTestPort(MockCBServerPort);
  const actor = ihsm.makeTestActor(CBServerTop, ctx, port, { initialize: false });
  return { port, actor, ctx };
}

describe("CBServerActor [stdio mock port]", function () {
  this.timeout(5_000);

  it("initialize → Stopped", async () => {
    const ctx = new CBServerContext(new CBServerConfig({ paths: { dataDir: "" } }));
    const { actor } = makeServer(ctx);
    actor.hsm.restore(Uninitialized, ctx);

    await actor.call.initialize();
    await actor.hsm.sync();

    expect(actor.hsm.currentStateName).to.equal("Stopped");
  });

  it("Starting: spawn failure → Stopped", async () => {
    const ctx = new CBServerContext(new CBServerConfig({ paths: { dataDir: "" } }));
    const { port, actor } = makeServer(ctx);
    port.spawn.default(async () => {
      throw new Error("EACCES: permission denied");
    });
    actor.hsm.restore(Uninitialized, ctx);
    await actor.call.initialize();
    await actor.hsm.sync();

    actor.notify.start();
    await actor.hsm.sync();
    await actor.hsm.sync();
    await actor.hsm.sync();

    expect(actor.hsm.currentStateName).to.equal("Stopped");
    expect(ctx.lastProcessError).to.match(/start failed|EACCES/i);
  });

  it("start → RequestIdle", async () => {
    const pid = 10_002;
    const ctx = new CBServerContext(new CBServerConfig({ paths: { dataDir: "" } }));
    const { port, actor } = makeServer(ctx);
    port.spawn.default(async () => ({
      value: pid,
      subscription: { dispose: () => port.record("dispose-subscription", pid) },
    }));
    port.stdinFor.default(() =>
        new Writable({
          write(_chunk, _encoding, callback) {
            callback();
          },
        }),);
    port.kill.default(async (targetPid, signal) => {
      port.record("kill", targetPid, signal);
    });
    actor.hsm.restore(Uninitialized, ctx);
    await actor.call.initialize();
    await actor.hsm.sync();

    actor.notify.start();
    await actor.hsm.sync();

    expect(actor.hsm.currentStateName).to.equal("RequestIdle");
    expect(ctx.children).to.not.equal(undefined);
  });

  it("RequestIdle: stop → ProcessDetaching (awaiting child interrupts)", async () => {
    const pid = 10_003;
    const ctx = new CBServerContext(new CBServerConfig({
        paths: { dataDir: "" },
        mmkit: { killGraceMs: 50 },
      }),);
    const { port, actor } = makeServer(ctx);
    port.spawn.default(async () => ({
      value: pid,
      subscription: { dispose: () => port.record("dispose-subscription", pid) },
    }));
    port.stdinFor.default(() =>
        new Writable({
          write(_chunk, _encoding, callback) {
            callback();
          },
        }),);
    port.kill.default(async (targetPid, signal) => {
      port.record("kill", targetPid, signal);
      port.send("onProcessExit", 0, null);
    });
    actor.hsm.restore(Uninitialized, ctx);
    await actor.call.initialize();
    await actor.hsm.sync();

    actor.notify.start();
    await actor.hsm.sync();
    expect(actor.hsm.currentStateName).to.equal("RequestIdle");

    actor.notify.stop();
    await actor.hsm.sync();
    port.advance(50);
    await actor.hsm.sync();

    expect(actor.hsm.currentStateName).to.equal("ProcessDetaching");
    expect(port.kill.calls.length).to.be.greaterThan(0);
  });

  it("Stopping: executeCommand is rejected", async () => {
    const pid = 10_031;
    const ctx = new CBServerContext(new CBServerConfig({ paths: { dataDir: "" } }));
    const { port, actor } = makeServer(ctx);
    port.spawn.default(async () => ({
      value: pid,
      subscription: { dispose: () => port.record("dispose-subscription", pid) },
    }));
    port.stdinFor.default(() => new Writable({ write(_c, _e, cb) { cb(); } }));
    port.kill.default(async (targetPid, signal) => {
      port.record("kill", targetPid, signal);
    });
    actor.hsm.restore(Uninitialized, ctx);
    await actor.call.initialize();
    await actor.hsm.sync();

    actor.notify.start();
    await actor.hsm.sync();
    expect(actor.hsm.currentStateName).to.equal("RequestIdle");

    actor.notify.stop();
    await actor.hsm.sync();
    expect(actor.hsm.currentStateName).to.equal("Stopping");

    let rejected: Error | undefined;
    try {
      await actor.call.executeCommand("tell after-stop.");
    } catch (err) {
      rejected = err instanceof Error ? err : new Error(String(err));
    }
    await actor.hsm.sync();

    expect(actor.hsm.currentStateName).to.equal("Stopping");
    expect(rejected?.message).to.match(/stopping/i);
  });

  it("Stopped: executeCommand is rejected", async () => {
    const ctx = new CBServerContext(new CBServerConfig({ paths: { dataDir: "" } }));
    const { actor } = makeServer(ctx);
    actor.hsm.restore(Uninitialized, ctx);
    await actor.call.initialize();
    await actor.hsm.sync();

    let tellRejected: Error | undefined;
    try {
      await actor.call.executeCommand("tell \"Employee in Class end\".");
    } catch (err) {
      tellRejected = err instanceof Error ? err : new Error(String(err));
    }
    await actor.hsm.sync();

    expect(actor.hsm.currentStateName).to.equal("Stopped");
    expect(tellRejected?.message).to.match(/not running/i);
  });

  it("Starting: onProcessExit → Stopped", async () => {
    const pid = 10_001;
    const ctx = new CBServerContext(new CBServerConfig({ paths: { dataDir: "" } }));
    const { port, actor } = makeServer(ctx);
    port.kill.default(async (targetPid, signal) => {
      port.record("kill", targetPid, signal);
    });
    actor.hsm.restore(Uninitialized, ctx);
    await actor.call.initialize();
    await actor.hsm.sync();

    actor.hsm.restore(Starting, ctx);
    ctx.pid = pid;
    ctx.processSubscription = { dispose: () => port.record("dispose-subscription", pid) };

    port.send("onProcessExit", 127, null);
    await actor.hsm.sync();
    await actor.hsm.sync();

    expect(actor.hsm.currentStateName).to.equal("Stopped");
    expect(ctx.lastExitCode).to.equal(127);
  });
});
