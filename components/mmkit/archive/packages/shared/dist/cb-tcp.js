"use strict";
/** ConceptBase TCP framing — mirrors libcbc send_message / connect_CB_server. */
Object.defineProperty(exports, "__esModule", { value: true });
exports.encodeCbString = encodeCbString;
exports.buildIpcMessage = buildIpcMessage;
exports.lengthPrefix = lengthPrefix;
exports.parseAnswerTerm = parseAnswerTerm;
exports.decodeCbString = decodeCbString;
exports.buildEnrollPayload = buildEnrollPayload;
exports.toCbAnswer = toCbAnswer;
function encodeCbString(value) {
    const escaped = value.replace(/\\/g, "\\\\").replace(/"/g, '\\"');
    return `"${escaped}"`;
}
function buildIpcMessage(client, serverName, method, data) {
    return `ipcmessage(${client},${serverName},${method},[${data}]).\n`;
}
function lengthPrefix(message) {
    const body = typeof message === "string" ? Buffer.from(message, "utf8") : message;
    const header = Buffer.alloc(5);
    const len = body.length;
    header[0] = "X".charCodeAt(0);
    header[1] = (len >>> 24) & 0xff;
    header[2] = (len >>> 16) & 0xff;
    header[3] = (len >>> 8) & 0xff;
    header[4] = len & 0xff;
    return Buffer.concat([header, body]);
}
/** Parse answer line format: length newline body (Prolog term). */
function parseAnswerTerm(term) {
    const match = term.match(/^\s*(\w+)\s*\(\s*([^,]+)\s*,\s*(\w+)\s*,\s*(.+)\s*\)\s*\.?\s*$/);
    if (!match) {
        return { completion: "broken" };
    }
    const status = match[3];
    let completion = "broken";
    if (status === "ok")
        completion = "ok";
    else if (status === "error")
        completion = "error";
    else if (status === "not_handled")
        completion = "not_handled";
    else if (status === "notification")
        completion = "notification";
    const sender = match[2].trim();
    const dataRaw = match[4].trim();
    const returnData = decodeCbString(dataRaw);
    return { completion, sender, returnData };
}
function decodeCbString(token) {
    if (!token.startsWith('"') || !token.endsWith('"')) {
        return token;
    }
    return token
        .slice(1, -1)
        .replace(/\\"/g, '"')
        .replace(/\\\\/g, "\\");
}
function buildEnrollPayload(toolName, userName) {
    return `${encodeCbString(toolName)},${encodeCbString(userName)}`;
}
function toCbAnswer(parsed) {
    return {
        completion: parsed.completion,
        result: parsed.returnData,
        respondingTool: parsed.sender,
        ok: parsed.completion === "ok",
    };
}
//# sourceMappingURL=cb-tcp.js.map