/** Builtin query — `Class` exists in every fresh cbserver database. */
export declare const CONNECTION_TEST_ASK_QUERY = "exists[Class/objname]";
export type AskFormat = "OBJNAMES" | "FRAMES";
/** ASK ipc payload: Format, Query, AnswerRep, RollbackTime (Format is unencoded). */
export declare function buildAskPayload(query: string, askFormat?: AskFormat, answerRep?: string, rollbackTime?: string): string;
/** True when a LABEL answer to `exists[Class/objname]` indicates success. */
export declare function isExistsClassYes(reply: string | undefined): boolean;
