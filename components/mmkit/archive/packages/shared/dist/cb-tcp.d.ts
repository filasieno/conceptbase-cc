/** ConceptBase TCP framing — mirrors libcbc send_message / connect_CB_server. */
export declare function encodeCbString(value: string): string;
export declare function buildIpcMessage(client: string, serverName: string, method: string, data: string): string;
export declare function lengthPrefix(message: string | Buffer): Buffer;
export interface ParsedAnswer {
    completion: "ok" | "error" | "not_handled" | "notification" | "timeout" | "broken";
    sender?: string;
    returnData?: string;
}
/** Parse answer line format: length newline body (Prolog term). */
export declare function parseAnswerTerm(term: string): ParsedAnswer;
export declare function decodeCbString(token: string): string | undefined;
export declare function buildEnrollPayload(toolName: string, userName: string): string;
export interface CbAnswer {
    completion: ParsedAnswer["completion"];
    result?: string;
    respondingTool?: string;
    ok: boolean;
}
export declare function toCbAnswer(parsed: ParsedAnswer): CbAnswer;
