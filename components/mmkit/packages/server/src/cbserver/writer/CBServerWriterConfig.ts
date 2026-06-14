import type * as ihsm from "ihsm";
import type { CBServerActorRef } from "../CBServerConfig";
import type { IWriterContext } from "./CBServerWriterContext";

/** Tunable parameters for the CBServer writer subactor. */
export interface ICBServerWriterSettings {
  clientToolName: string;
  clientUserName: string;
  askFormat: string;
  answerRep: string;
  rollbackTime: string;
}

/** ihsm Config bag for the CBServer writer subactor. */
export interface WriterMachineConfig {
  context: IWriterContext;
  notifications: {
    stop(): void;
    interrupt(): void;
  };
  services: {
    initialize(): Promise<void>;
    write(message: string): Promise<void>;
    getCurrentStateName(): Promise<string>;
  };
  internalNotifications: {
    doWrite(): void;
    doComplete(): void;
    doFailPending(message: string): void;
    onWriteProgress(written: number): void;
    onWriteSucceeded(): void;
    onWriteFailed(message: string): void;
  };
  port: {
    write(payload: string): void;
  };
}

export type WriterPort = ihsm.DomainPortOf<WriterMachineConfig>;

export type { CBServerActorRef };
