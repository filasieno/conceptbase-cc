import type * as ihsm from "ihsm";
import type { CBAnswer, IpcAnswer } from "./CBServerDefs";
import type { ICBConnectionContext } from "./CBServerConnectionContext";

type ResolveCallback<T> = (value: T) => void;
type RejectCallback = (error: Error) => void;

/**
 * Canonical cbserver command surface (manual-aligned shell commands).
 *
 * Every command is dispatched as an actor `call`, therefore command requests are
 * serialized by the state machine queue while a previous command is running.
 */
export interface ICBConnectionDriver {
  tell(resolve: ResolveCallback<IpcAnswer>, reject: RejectCallback, frames: string): Promise<void>;
  untell(resolve: ResolveCallback<IpcAnswer>, reject: RejectCallback, frames: string): Promise<void>;
  retell(resolve: ResolveCallback<IpcAnswer>, reject: RejectCallback, untellFrames: string, tellFrames: string): Promise<void>;
  tellModel(resolve: ResolveCallback<IpcAnswer>, reject: RejectCallback, ...files: string[]): Promise<void>;
  ask(resolve: ResolveCallback<IpcAnswer>, reject: RejectCallback, query: string, queryFormat?: string, answerRep?: string, rollbackTime?: string): Promise<void>;
  hypoAsk(resolve: ResolveCallback<IpcAnswer>, reject: RejectCallback, frames: string, query: string, queryFormat?: string, answerRep?: string, rollbackTime?: string): Promise<void>;
  lpicall(resolve: ResolveCallback<IpcAnswer>, reject: RejectCallback, lpiCall: string): Promise<void>;
  prolog(resolve: ResolveCallback<IpcAnswer>, reject: RejectCallback, statement: string): Promise<void>;
  why(resolve: ResolveCallback<IpcAnswer>, reject: RejectCallback): Promise<void>;
  cd(resolve: ResolveCallback<IpcAnswer>, reject: RejectCallback, modulePath?: string): Promise<void>;
  pwd(resolve: ResolveCallback<IpcAnswer>, reject: RejectCallback): Promise<void>;
  lm(resolve: ResolveCallback<IpcAnswer>, reject: RejectCallback, modulePath?: string): Promise<void>;
  ls(resolve: ResolveCallback<IpcAnswer>, reject: RejectCallback, className?: string): Promise<void>;
  mkdir(resolve: ResolveCallback<IpcAnswer>, reject: RejectCallback, moduleName: string): Promise<void>;
  who(resolve: ResolveCallback<IpcAnswer>, reject: RejectCallback): Promise<void>;
  sub(resolve: ResolveCallback<IpcAnswer>, reject: RejectCallback): Promise<void>;
  show(resolve: ResolveCallback<IpcAnswer>, reject: RejectCallback, objectName: string): Promise<void>;
  getConnectionId(resolve: ResolveCallback<string>, reject: RejectCallback): Promise<void>;
  close(resolve: ResolveCallback<void>, reject: RejectCallback): Promise<void>;
}

/** ihsm Config bag for the CBServer connection actor. */
export interface CBConnectionMachineConfig {
  context: ICBConnectionContext;
  services: {
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
  };
  port: {
    execute(message: string): Promise<CBAnswer>;
  };
}

export type CBConnectionPort = ihsm.DomainPortOf<CBConnectionMachineConfig>;

export type CBConnectionActorHandle = ihsm.ExternalActor<CBConnectionMachineConfig>;

export interface CBServerConnectionConfig {
  connectionId: string;
  executeCommand(message: string): Promise<IpcAnswer>;
  onClose(): void;
}

export type { ICBConnectionContext } from "./CBServerConnectionContext";
