import { expect } from "chai";
import { createCBServerActor } from "../../src/cbserver/CBServerActor";
import { CBServerConfig } from "../../src/cbserver/CBServerConfig";
import type { CBServerPort } from "../../src/cbserver/CBServerPort";
import { waitForHsmState } from "./hsm";

let nextTestPort = 14_100;

/** Allocate a unique TCP port for probe / real-process tests. */
export function allocatePort(): number {
  nextTestPort += 1;
  return nextTestPort;
}

export function testConfig(overrides: Partial<CBServerConfig> = {}): CBServerConfig {
  const port = overrides.port ?? allocatePort();
  return new CBServerConfig({
    executablePath: "cbserver",
    dataDir: "",
    killGraceMs: 300,
    portProbeAttempts: 8,
    portProbeIntervalMs: 50,
    ...overrides,
    port,
  });
}

export const activeActors: ReturnType<typeof createCBServerActor>[] = [];

export async function createInitializedActor(portFactory: () => CBServerPort,
  config = testConfig()) {
  const actor = createCBServerActor(config);
  activeActors.push(actor);
  await actor.sync();
  expect(actor.currentStateName).to.equal("Uninitialized");
  const port = portFactory();
  await actor.call("initialize", port);
  await actor.sync();
  expect(actor.currentStateName).to.equal("Stopped");
  return { actor, port, config };
}

export async function cleanupActors(): Promise<void> {
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
}
