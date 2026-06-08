/// <reference types="node" />
import { expect } from "chai";
import { execFileSync } from "node:child_process";
import path from "node:path";
import { createRealCBServerPort } from "../src/cbserver/RealCBServerPort";
import { waitForHsmState } from "./helpers/hsm";
import { allocatePort, cleanupActors, createInitializedActor, testConfig } from "./helpers/actor";

const MOCK_CBSERVER = path.resolve(__dirname, "../../test/fixtures/mock-cbserver.js");

function cbserverOnPath(): string | undefined {
  try {
    return execFileSync("which", ["cbserver"], { encoding: "utf8" }).trim() || undefined;
  } catch {
    return undefined;
  }
}

function mockCbserverConfig(port: number, overrides: Parameters<typeof testConfig>[0] = {}) {
  return testConfig({
    port,
    executablePath: MOCK_CBSERVER,
    extraArgs: [],
    portProbeAttempts: 40,
    portProbeIntervalMs: 100,
    ...overrides,
  });
}

describe("CBServerActor real port", function () {
  this.timeout(20_000);

  afterEach(async () => {
    await cleanupActors();
  });

  describe("RealCBServerPort + mock cbserver subprocess", () => {
    it("starts a real subprocess and reaches WatchingProcess", async () => {
      const port = allocatePort();
      const { actor } = await createInitializedActor(() => createRealCBServerPort(), mockCbserverConfig(port));

      actor.post("start");
      await waitForHsmState(actor, "WatchingProcess", { timeoutMs: 10_000 });

      expect(actor.ctx.pid).to.be.greaterThan(0);
      expect(actor.ctx.processSpawned).to.equal(true);
      expect(actor.ctx.processStdout).to.match(/mock-cbserver listening/);
    });

    it("stops a real subprocess cleanly", async () => {
      const port = allocatePort();
      const { actor } = await createInitializedActor(() => createRealCBServerPort(), mockCbserverConfig(port, { killGraceMs: 500 }));

      actor.post("start");
      await waitForHsmState(actor, "WatchingProcess", { timeoutMs: 10_000 });

      actor.post("stop");
      await waitForHsmState(actor, "Stopped", { timeoutMs: 10_000 });

      expect(actor.ctx.pid).to.equal(undefined);
      expect(actor.ctx.processSubscription).to.equal(undefined);
      expect(actor.ctx.lastExitCode).to.equal(0);
    });

    it("fails start when the executable does not exist", async () => {
      const port = allocatePort();
      const { actor } = await createInitializedActor(() => createRealCBServerPort(), testConfig({
          port,
          executablePath: "/nonexistent/cbserver-missing",
          portProbeAttempts: 3,
          portProbeIntervalMs: 50,
        }));

      actor.post("start");
      await waitForHsmState(actor, "Stopped", { timeoutMs: 8_000 });

      expect(actor.ctx.lastProcessError).to.match(/cbserver start failed|ENOENT|not reachable/);
    });
  });

  const systemCbserver = cbserverOnPath();
  if (systemCbserver !== undefined) {
    describe("RealCBServerPort + system cbserver binary", () => {
      it("starts and stops the real cbserver on PATH", async function () {
        this.timeout(30_000);
        const port = allocatePort();
        const { actor } = await createInitializedActor(() => createRealCBServerPort(), testConfig({
            port,
            executablePath: systemCbserver,
            killGraceMs: 2_000,
            portProbeAttempts: 60,
            portProbeIntervalMs: 250,
          }));

        actor.post("start");
        await waitForHsmState(actor, "WatchingProcess", { timeoutMs: 25_000 });

        actor.post("stop");
        await waitForHsmState(actor, "Stopped", { timeoutMs: 15_000 });
      });
    });
  } else {
    describe("RealCBServerPort + system cbserver binary", () => {
      it("skips when cbserver is not on PATH");
    });
  }
});
