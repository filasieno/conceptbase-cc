import type * as ihsm from "ihsm";
import type { CBServerActorRef } from "../CBServerConfig";
import type { IpcAnswer } from "../CBServerDefs";
import type { IReaderContext } from "./CBServerReaderContext";

/** Tunable parameters for the CBServer reader subactor. */
export interface ICBServerReaderSettings {
  /**
   * Upper bound on stdout bytes buffered while assembling a single text-framed
   * ipcanswer. If exceeded before a complete frame arrives, the pending read is
   * failed instead of growing the buffer without bound. Default 64 MiB.
   */
  maxBufferBytes: number;
}

/** ihsm Config bag for the CBServer reader subactor. */
export interface ReaderMachineConfig {
  context: IReaderContext;
  notifications: {
    stop(): void;
    interrupt(): void;
  };
  services: {
    initialize(): Promise<void>;
    readAnswer(): Promise<IpcAnswer>;
    getCurrentStateName(): Promise<string>;
  };
  internalNotifications: {
    onData(chunk: string): void;
    onEnd(): void;
    onStreamError(message: string): void;
    doSubscribe(): void;
    doDeliverPending(): void;
    doFailPending(message: string): void;
  };
  port: {
    subscribe(): ihsm.ResultWithSubscription<void>;
  };
}

export type ReaderPort = ihsm.DomainPortOf<ReaderMachineConfig>;

export type { CBServerActorRef };
