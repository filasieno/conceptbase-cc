import type { ConfigSnapshotPayload } from "./config";
export type MmkitServerPhase = "idle" | "starting" | "installing" | "running" | "stopping" | "fault";
export interface MmkitTraceContext {
    traceparent?: string;
    baggage?: string;
}
export interface MmkitServerStateNotification {
    phase: MmkitServerPhase;
    port?: number;
    message?: string;
    fault?: string;
    generation?: number;
    traceContext?: MmkitTraceContext;
}
export interface MmkitServerState {
    phase: MmkitServerPhase;
    port?: number;
    message?: string;
    fault?: string;
    generation?: number;
}
export interface MmkitServerStartParams {
    generation: number;
    snapshot: ConfigSnapshotPayload;
    traceContext?: MmkitTraceContext;
}
export interface MmkitServerStartResult {
    ok: boolean;
    state: MmkitServerState;
    errors?: {
        field: string;
        message: string;
    }[];
}
export interface MmkitConfigUpdateParams {
    snapshot: ConfigSnapshotPayload;
    traceContext?: MmkitTraceContext;
}
export interface MmkitConfigUpdateResult {
    generation: number;
}
export interface OtelEndpointConfig {
    protocol: "grpc" | "http";
    host: string;
    port: number;
}
export interface OtelTestResult {
    ok: boolean;
    message: string;
    latencyMs?: number;
}
export interface MmkitInitializeExtension {
    serverControl: boolean;
    otel: boolean;
    mcpHttpPort: number;
}
/** LSP custom request method names (IDE control only — not MCP). */
export declare const MMKIT_LSP_METHODS: {
    readonly serverStart: "mmkit/server/start";
    readonly serverStop: "mmkit/server/stop";
    readonly serverRestart: "mmkit/server/restart";
    readonly serverStatus: "mmkit/server/status";
    readonly configUpdate: "mmkit/config/update";
    readonly otelTest: "mmkit/otel/test";
    readonly serverStateNotification: "mmkit/server/state";
};
