import { parseAnswerTerm, toCbAnswer } from "@mmkit/shared/dist/cb-tcp";

/** Parsed ipcanswer term from a text-framed stdout message. */
export class IpcAnswer {
  readonly ok: boolean;
  readonly completion: string;
  readonly result?: string;
  readonly term: string;

  constructor(term: string, ok: boolean, completion: string, result?: string) {
    this.term = term;
    this.ok = ok;
    this.completion = completion;
    this.result = result;
  }

  static fromTerm(term: string): IpcAnswer {
    const parsed = toCbAnswer(parseAnswerTerm(term));
    return new IpcAnswer(term, parsed.ok, parsed.completion, parsed.result);
  }
}

/** Text-framed ipcanswer: `<byteLength>\n<body>` (ConceptBase stdout convention). */
export function tryParseTextFramedMessage(buffer: string): { consumed: number; body: string } | undefined {
  const headerEnd = buffer.indexOf("\n");
  if (headerEnd < 0) {
    return undefined;
  }
  const len = Number.parseInt(buffer.slice(0, headerEnd), 10);
  if (!Number.isFinite(len) || len < 0) {
    return undefined;
  }
  const bodyStart = headerEnd + 1;
  const body = buffer.slice(bodyStart);
  let consumedChars = 0;
  let consumedBytes = 0;

  while (consumedChars < body.length && consumedBytes < len) {
    const cp = body.codePointAt(consumedChars);
    if (cp === undefined) {
      return undefined;
    }
    const charLen = cp > 0xffff ? 2 : 1;
    const byteLen = cp <= 0x7f ? 1 : cp <= 0x7ff ? 2 : cp <= 0xffff ? 3 : 4;
    consumedChars += charLen;
    consumedBytes += byteLen;
  }

  if (consumedBytes !== len) {
    return undefined;
  }

  return {
    consumed: bodyStart + consumedChars,
    body: body.slice(0, consumedChars),
  };
}

export function formatTextFramedMessage(body: string): string {
  return `${Buffer.byteLength(body, "utf8")}\n${body}`;
}

export type CBAnswer = IpcAnswer;

export type StatusListener = (state: string) => void;

/** Stdio stream observed from the cbserver subprocess. */
export type ProcessStream = "stdout" | "stderr";

export type ProcessIoListener = (stream: ProcessStream, line: string) => void;

/** POSIX signal name accepted by `ChildProcess.kill`. */
export type ProcessSignal = NodeJS.Signals;

export interface ICBConnection {
  getConnectionId(): Promise<string>;
  close(): Promise<void>;
  tell(frames: string): Promise<CBAnswer>;
  untell(frames: string): Promise<CBAnswer>;
  retell(untellFrames: string, tellFrames: string): Promise<CBAnswer>;
  tellModel(...files: string[]): Promise<CBAnswer>;
  ask(query: string, queryFormat?: string, answerRep?: string, rollbackTime?: string): Promise<CBAnswer>;
  hypoAsk(frames: string, query: string, queryFormat?: string, answerRep?: string, rollbackTime?: string): Promise<CBAnswer>;
  lpicall(lpiCall: string): Promise<CBAnswer>;
  prolog(statement: string): Promise<CBAnswer>;
  why(): Promise<CBAnswer>;
  cd(modulePath?: string): Promise<CBAnswer>;
  pwd(): Promise<CBAnswer>;
  lm(modulePath?: string): Promise<CBAnswer>;
  ls(className?: string): Promise<CBAnswer>;
  mkdir(moduleName: string): Promise<CBAnswer>;
  who(): Promise<CBAnswer>;
  sub(): Promise<CBAnswer>;
  show(objectName: string): Promise<CBAnswer>;
}

export interface ICBConnectionOptions {
  label?: string;
  timeoutMs?: number;
  autoConnect?: boolean;
  startupProbeCommand?: "pwd" | "who";
}
