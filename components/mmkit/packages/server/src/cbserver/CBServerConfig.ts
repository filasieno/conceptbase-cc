/** Persistent cbserver launch and runtime configuration (executable mode only). */
export class CBServerConfig {
  autoStartup = true;
  executablePath = "cbserver";
  dataDir = "~/.mmkit";
  port = 4001;
  updateMode = "persistent";
  databasePath = "";
  databaseAllPath = "";
  newDatabasePath = "";
  resetOnStart = false;
  tmpDir = "";
  loadDir = "";
  saveDir = "";
  viewsDir = "";
  traceMode = "";
  untellMode = "";
  cacheMode = "";
  cacheSize = "";
  optimizerMode = "";
  viewsMaintenance = "";
  restartDelaySeconds = "";
  securityLevel = "";
  maxErrors = "";
  adminUser = "";
  multiUser = false;
  moduleSeparator = "";
  moduleGeneration = "";
  ccMode = "";
  maxCost = "";
  pathLength = "";
  iterMax = "";
  ecaMode = "";
  ecaOptimizer = "";
  ruleLabels = "";
  inactivityHours = "";
  serverMode = "";
  stratificationMode = "";
  devCommand = "";
  extraArgs: string[] = [];
  portProbeAttempts = 40;
  portProbeIntervalMs = 100;
  killGraceMs = 5_000;

  constructor(init?: Partial<CBServerConfig>) {
    if (init) {
      Object.assign(this, init);
    }
  }

  static fromEnv(): CBServerConfig {
    return new CBServerConfig({
      port: Number(process.env.MMKIT_CBSERVER_PORT ?? "4001"),
      executablePath: process.env.MMKIT_CBSERVER_BIN ?? "cbserver",
      portProbeAttempts: Number(process.env.MMKIT_PORT_PROBE_ATTEMPTS ?? "40"),
      portProbeIntervalMs: Number(process.env.MMKIT_PORT_PROBE_INTERVAL_MS ?? "100"),
      killGraceMs: Number(process.env.MMKIT_KILL_GRACE_MS ?? "5000"),
    });
  }
}
