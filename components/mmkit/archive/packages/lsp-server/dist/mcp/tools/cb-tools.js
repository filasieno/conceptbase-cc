"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const validate_args_1 = require("../validation/validate-args");
const validate_frames_1 = require("../validation/validate-frames");
const cb_tool_1 = require("./cb-tool");
const label = (a) => (0, validate_args_1.optionalString)(a, "answerRep", 32) ?? "LABEL";
const now = (a) => (0, validate_args_1.optionalString)(a, "rollbackTime", 64) ?? "Now";
// Each tool = MCP metadata + a plain `exec(ctx, raw)` routine, registered via
// `MCPTool(meta, exec)`. Registration order = call order in this file. No list
// or class to maintain — add another `MCPTool(...)` below.
// ── lifecycle / status ─────────────────────────────────────────────────────────
(0, cb_tool_1.MCPTool)({
    name: "mmkit_server_status",
    title: "mmkit server status",
    description: "Returns mmkit server lifecycle phase (idle|starting|running|…) and TCP port. Call before cb_connect when using internal server.",
}, async (ctx) => ctx.supervisor.getState());
(0, cb_tool_1.MCPTool)({
    name: "cb_connect",
    title: "Connect to ConceptBase server",
    description: "Enrolls an MCP session over TCP (ICBclient.enrollMe). Optional host/port override; default uses running mmkit server on 127.0.0.1.",
}, async (ctx, raw) => {
    const params = {
        host: (0, validate_args_1.optionalString)(raw, "host", 253),
        port: (0, validate_args_1.optionalPort)(raw, "port"),
        toolName: (0, validate_args_1.optionalString)(raw, "toolName", 128),
        userName: (0, validate_args_1.optionalString)(raw, "userName", 128),
    };
    const client = await ctx.session.getClient(params);
    return { ok: true, host: client.host, port: client.port, clientId: client.clientName, serverId: client.serverName };
});
(0, cb_tool_1.MCPTool)({ name: "cb_disconnect", title: "Disconnect from ConceptBase server", description: "CANCEL_ME / disconnect current MCP session." }, async (ctx) => {
    await ctx.session.disconnect();
    return { ok: true };
});
// ── tell / untell ────────────────────────────────────────────────────────────
(0, cb_tool_1.MCPTool)({ name: "cb_tell", title: "Tell frames", description: "TELL frames — tree-sitter validated ConceptBase source." }, async (ctx, raw) => (await ctx.client()).tell(await (0, validate_frames_1.requireValidFrames)(raw, "frames")));
(0, cb_tool_1.MCPTool)({ name: "cb_untell", title: "Untell frames", description: "UNTELL frames — tree-sitter validated." }, async (ctx, raw) => (await ctx.client()).untell(await (0, validate_frames_1.requireValidFrames)(raw, "frames")));
(0, cb_tool_1.MCPTool)({ name: "cb_tell_transactions", title: "Tell transactions", description: "Tell {---} transaction blocks." }, async (ctx, raw) => (await ctx.client()).tellTransactions((0, validate_args_1.requireString)(raw, "transactions")));
(0, cb_tool_1.MCPTool)({ name: "cb_tell_model", title: "Tell model", description: "Tell remote model file paths on server." }, async (ctx, raw) => (await ctx.client()).tellModel((0, validate_args_1.requireStringArray)(raw, "files")));
(0, cb_tool_1.MCPTool)({ name: "cb_retell", title: "Retell frames", description: "RETELL in one transaction." }, async (ctx, raw) => {
    const { untellFrames, tellFrames } = await (0, validate_frames_1.requireValidFramePair)(raw, "untellFrames", "tellFrames");
    return (await ctx.client()).retell(untellFrames, tellFrames);
});
// ── ask variants ───────────────────────────────────────────────────────────────
(0, cb_tool_1.MCPTool)({ name: "cb_ask", title: "Ask query", description: "ASK query (ICBclient.ask)." }, async (ctx, raw) => {
    const queryFormat = (0, validate_args_1.requireAskFormat)((0, validate_args_1.optionalString)(raw, "queryFormat", 32) ?? "OBJNAMES", "queryFormat");
    return (await ctx.client()).ask((0, validate_args_1.requireString)(raw, "query"), queryFormat, label(raw), now(raw));
});
(0, cb_tool_1.MCPTool)({ name: "cb_ask_frames", title: "Ask frames", description: "ASK with FRAMES query format." }, async (ctx, raw) => (await ctx.client()).askFrames((0, validate_args_1.requireString)(raw, "query"), label(raw), now(raw)));
(0, cb_tool_1.MCPTool)({ name: "cb_ask_objnames", title: "Ask object names", description: "ASK with OBJNAMES query format." }, async (ctx, raw) => (await ctx.client()).askObjNames((0, validate_args_1.requireString)(raw, "query"), label(raw), now(raw)));
(0, cb_tool_1.MCPTool)({ name: "cb_hypo_ask", title: "Hypothetical ask", description: "Hypothetical ASK with temporary frames." }, async (ctx, raw) => {
    const frames = await (0, validate_frames_1.requireValidFrames)(raw, "frames");
    const queryFormat = (0, validate_args_1.requireAskFormat)((0, validate_args_1.requireString)(raw, "queryFormat", { maxLength: 32 }), "queryFormat");
    return (await ctx.client()).hypoAsk(frames, (0, validate_args_1.requireString)(raw, "query"), queryFormat, label(raw), now(raw));
});
// ── object builtins ──────────────────────────────────────────────────────────
(0, cb_tool_1.MCPTool)({ name: "cb_get_object", title: "Get object", description: "Builtin get_object[objname]." }, async (ctx, raw) => {
    const objname = (0, validate_args_1.requireIdentifier)((0, validate_args_1.requireString)(raw, "objname", { maxLength: 512 }), "objname");
    return { completion: "ok", ok: true, result: await (await ctx.client()).getObject(objname) };
});
(0, cb_tool_1.MCPTool)({ name: "cb_find_instances", title: "Find instances", description: "Builtin find_instances[class]." }, async (ctx, raw) => {
    const objname = (0, validate_args_1.requireIdentifier)((0, validate_args_1.requireString)(raw, "objname", { maxLength: 512 }), "objname");
    return { completion: "ok", ok: true, result: await (await ctx.client()).findInstances(objname) };
});
// ── LPI / messaging ────────────────────────────────────────────────────────────
(0, cb_tool_1.MCPTool)({ name: "cb_lpi_call", title: "LPI call", description: "LPI Prolog call." }, async (ctx, raw) => (await ctx.client()).lpiCall((0, validate_args_1.requireString)(raw, "lpicall")));
(0, cb_tool_1.MCPTool)({ name: "cb_next_message", title: "Next message", description: "Poll server message queue." }, async (ctx, raw) => (await ctx.client()).nextMessage((0, validate_args_1.requireString)(raw, "messageType", { maxLength: 128 })));
// ── module navigation ──────────────────────────────────────────────────────────
(0, cb_tool_1.MCPTool)({ name: "cb_set_module", title: "Set module", description: "SET_MODULE_CONTEXT." }, async (ctx, raw) => (await ctx.client()).setModule((0, validate_args_1.requireString)(raw, "module", { maxLength: 1024 })));
(0, cb_tool_1.MCPTool)({ name: "cb_get_module", title: "Get module", description: "GET_MODULE_CONTEXT." }, async (ctx) => ({ completion: "ok", ok: true, result: await (await ctx.client()).getModule() }));
(0, cb_tool_1.MCPTool)({ name: "cb_get_module_path", title: "Get module path", description: "GET_MODULE_PATH." }, async (ctx) => (await ctx.client()).getModulePath());
(0, cb_tool_1.MCPTool)({ name: "cb_list_module", title: "List module", description: "listModule[module/module] ASK." }, async (ctx, raw) => {
    const module = (0, validate_args_1.requireString)(raw, "module", { maxLength: 512 });
    return { completion: "ok", ok: true, result: await (await ctx.client()).listModule(module) };
});
// ── server control ─────────────────────────────────────────────────────────────
(0, cb_tool_1.MCPTool)({ name: "cb_notification_request", title: "Notification request", description: "NOTIFICATION_REQUEST." }, async (ctx, raw) => (await ctx.client()).notificationRequest((0, validate_args_1.requireString)(raw, "about"), (0, validate_args_1.optionalString)(raw, "tool", 128)));
(0, cb_tool_1.MCPTool)({ name: "cb_stop_server", title: "Stop server", description: "STOP_SERVER on connected cbserver." }, async (ctx) => (await ctx.client()).stopServer());
// ── simplified helpers ──────────────────────────────────────────────────────────
(0, cb_tool_1.MCPTool)({ name: "cb_tells", title: "Tells (simplified)", description: "Simplified tell → yes/no." }, async (ctx, raw) => ({ result: await (await ctx.client()).tells(await (0, validate_frames_1.requireValidFrames)(raw, "frames")) }));
(0, cb_tool_1.MCPTool)({ name: "cb_untells", title: "Untells (simplified)", description: "Simplified untell → yes/no." }, async (ctx, raw) => ({ result: await (await ctx.client()).untells(await (0, validate_frames_1.requireValidFrames)(raw, "frames")) }));
(0, cb_tool_1.MCPTool)({ name: "cb_asks", title: "Asks (simplified)", description: "Simplified ask → string answer." }, async (ctx, raw) => ({ result: await (await ctx.client()).asks((0, validate_args_1.requireString)(raw, "query"), (0, validate_args_1.optionalString)(raw, "format", 32)) }));
(0, cb_tool_1.MCPTool)({ name: "cb_pwd", title: "Print working module", description: "Module path string." }, async (ctx) => ({ result: await (await ctx.client()).pwd() }));
(0, cb_tool_1.MCPTool)({ name: "cb_cd", title: "Change module", description: "Change module context." }, async (ctx, raw) => ({ result: await (await ctx.client()).cd((0, validate_args_1.requireString)(raw, "module", { maxLength: 1024 })) }));
(0, cb_tool_1.MCPTool)({ name: "cb_mkdir", title: "Make submodule", description: "Create submodule in current module." }, async (ctx, raw) => ({ result: await (await ctx.client()).mkdir((0, validate_args_1.requireString)(raw, "module", { maxLength: 512 })) }));
//# sourceMappingURL=cb-tools.js.map