#!/usr/bin/env node
import { createCBServerActor } from "../cbserver/CBServerActor";
import { CBServerConfig } from "../cbserver/CBServerConfig";
import { createRealCBServerPort } from "../cbserver/RealCBServerPort";
import { startHttpApp } from "../http/http-app";
import { startLspTcp } from "../lsp/lsp-server";
import { createMcpServer } from "../mcp/mcp-server";

async function main(): Promise<void> {
  const httpPort = Number(process.env.MMKIT_HTTP_PORT ?? "28080");
  const lspPort = Number(process.env.MMKIT_LSP_PORT ?? "16011");
  const config = CBServerConfig.fromEnv();

  const readiness = { started: false };
  const cbserverActor = createCBServerActor(config);
  await cbserverActor.sync();
  const port = createRealCBServerPort();
  await cbserverActor.call("initialize", port);
  await cbserverActor.sync();

  if (config.autoStartup) {
    cbserverActor.post("start");
  }

  const mcpServer = createMcpServer(() => cbserverActor.call("getCurrentStateName"));
  const httpServer = startHttpApp(httpPort, { readiness, mcpServer });
  const lspServer = startLspTcp(lspPort);

  const shutdown = async (signal: string) => {
    console.log(`mmkit-server shutting down (${signal})`);
    cbserverActor.ctx.shutdownRequested = true;
    cbserverActor.post("stop");
    await cbserverActor.sync();
    httpServer.close();
    lspServer.close();
    process.exit(0);
  };

  process.on("SIGINT", () => void shutdown("SIGINT"));
  process.on("SIGTERM", () => void shutdown("SIGTERM"));

  console.log(`mmkit-server listening http=${httpPort} lsp=${lspPort} cbserver=${config.port} (${config.executablePath})`);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
