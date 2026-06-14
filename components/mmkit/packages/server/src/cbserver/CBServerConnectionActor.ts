import * as ihsm from "ihsm";
import type { CBAnswer, IpcAnswer } from "./CBServerDefs";
import { CBConnectionContext } from "./CBServerConnectionContext";
import type {
  CBConnectionActorHandle,
  CBConnectionMachineConfig,
  CBServerConnectionConfig,
  ICBConnectionDriver,
} from "./CBServerConnection";
import * as self from "./CBServerConnectionActor";

type ResolveCallback<T> = (value: T) => void;
type RejectCallback = (error: Error) => void;

class DelegateConnectionPort extends ihsm.Port<typeof CBConnectionTop> {
  private readonly executor: (message: string) => Promise<IpcAnswer>;

  constructor(executor: (message: string) => Promise<IpcAnswer>) {
    super();
    this.executor = executor;
  }

  async execute(message: string): Promise<IpcAnswer> {
    return this.executor(message);
  }
}

class CBConnectionTop extends ihsm.TopState<CBConnectionMachineConfig> {
  protected _checkInvariant(): void {}
}

@ihsm.InitialState
class Uninitialized extends CBConnectionTop {
  onEntry(): void {
    this.hsm.transition(Initialized);
  }
}

class Initialized extends CBConnectionTop {
  async getConnectionId(): Promise<string> {
    return this.ctx.connectionId;
  }

  async close(): Promise<void> {
    if (!this.ctx.closed) {
      this.ctx.closed = true;
      this.ctx.onClose();
      this.hsm.transition(Closed as never);
    }
  }

  async tell(frames: string): Promise<CBAnswer> {
    return this.execute(`tell ${frames}`);
  }

  async untell(frames: string): Promise<CBAnswer> {
    return this.execute(`untell ${frames}`);
  }

  async retell(untellFrames: string, tellFrames: string): Promise<CBAnswer> {
    return this.execute(`retell ${untellFrames} ${tellFrames}`);
  }

  async tellModel(...files: string[]): Promise<CBAnswer> {
    return this.execute(`tellModel ${files.join(" ")}`.trim());
  }

  async ask(query: string, queryFormat?: string, answerRep?: string, rollbackTime?: string): Promise<CBAnswer> {
    const command = ["ask", query, queryFormat, answerRep, rollbackTime]
      .filter((part) => part !== undefined && part !== "")
      .join(" ");
    return this.execute(command);
  }

  async hypoAsk(frames: string, query: string, queryFormat?: string, answerRep?: string, rollbackTime?: string): Promise<CBAnswer> {
    const command = ["hypoAsk", frames, query, queryFormat, answerRep, rollbackTime]
      .filter((part) => part !== undefined && part !== "")
      .join(" ");
    return this.execute(command);
  }

  async lpicall(lpiCall: string): Promise<CBAnswer> {
    return this.execute(`lpicall ${lpiCall}`);
  }

  async prolog(statement: string): Promise<CBAnswer> {
    return this.execute(`prolog ${statement}`);
  }

  async why(): Promise<CBAnswer> {
    return this.execute("why");
  }

  async cd(modulePath?: string): Promise<CBAnswer> {
    return this.execute(modulePath === undefined || modulePath === "" ? "cd" : `cd ${modulePath}`);
  }

  async pwd(): Promise<CBAnswer> {
    return this.execute("pwd");
  }

  async lm(modulePath?: string): Promise<CBAnswer> {
    return this.execute(modulePath === undefined || modulePath === "" ? "lm" : `lm ${modulePath}`);
  }

  async ls(className?: string): Promise<CBAnswer> {
    return this.execute(className === undefined || className === "" ? "ls" : `ls ${className}`);
  }

  async mkdir(moduleName: string): Promise<CBAnswer> {
    return this.execute(`mkdir ${moduleName}`);
  }

  async who(): Promise<CBAnswer> {
    return this.execute("who");
  }

  async sub(): Promise<CBAnswer> {
    return this.execute("sub");
  }

  async show(objectName: string): Promise<CBAnswer> {
    return this.execute(`show ${objectName}`);
  }

  private async execute(message: string): Promise<CBAnswer> {
    return this.hsm.port.execute(message);
  }
}

class Closed extends CBConnectionTop {
  async getConnectionId(): Promise<string> {
    return this.ctx.connectionId;
  }

  async close(): Promise<void> {
    this.ctx.closed = true;
  }

  async tell(_frames: string): Promise<CBAnswer> {
    throw new Error("connection is closed");
  }

  async untell(_frames: string): Promise<CBAnswer> {
    throw new Error("connection is closed");
  }

  async retell(_untellFrames: string, _tellFrames: string): Promise<CBAnswer> {
    throw new Error("connection is closed");
  }

  async tellModel(..._files: string[]): Promise<CBAnswer> {
    throw new Error("connection is closed");
  }

  async ask(): Promise<CBAnswer> {
    throw new Error("connection is closed");
  }

  async hypoAsk(): Promise<CBAnswer> {
    throw new Error("connection is closed");
  }

  async lpicall(): Promise<CBAnswer> {
    throw new Error("connection is closed");
  }

  async prolog(): Promise<CBAnswer> {
    throw new Error("connection is closed");
  }

  async why(): Promise<CBAnswer> {
    throw new Error("connection is closed");
  }

  async cd(): Promise<CBAnswer> {
    throw new Error("connection is closed");
  }

  async pwd(): Promise<CBAnswer> {
    throw new Error("connection is closed");
  }

  async lm(): Promise<CBAnswer> {
    throw new Error("connection is closed");
  }

  async ls(): Promise<CBAnswer> {
    throw new Error("connection is closed");
  }

  async mkdir(): Promise<CBAnswer> {
    throw new Error("connection is closed");
  }

  async who(): Promise<CBAnswer> {
    throw new Error("connection is closed");
  }

  async sub(): Promise<CBAnswer> {
    throw new Error("connection is closed");
  }

  async show(): Promise<CBAnswer> {
    throw new Error("connection is closed");
  }
}

export class CBServerConnection implements ICBConnectionDriver {
  private readonly actor: CBConnectionActorHandle;

  constructor(config: CBServerConnectionConfig) {
    const port = new DelegateConnectionPort(config.executeCommand);
    const context = new CBConnectionContext(config.connectionId, config.onClose);
    this.actor = ihsm.makeActor(CBConnectionTop, context, port);
  }

  async close(resolve: ResolveCallback<void>, reject: RejectCallback): Promise<void> {
    this.delegate(resolve, reject, () => this.actor.call.close());
  }

  getActorHandle(): CBConnectionActorHandle {
    return this.actor;
  }

  async getConnectionId(resolve: ResolveCallback<string>, reject: RejectCallback): Promise<void> {
    this.delegate(resolve, reject, () => this.actor.call.getConnectionId());
  }

  async tell(resolve: ResolveCallback<IpcAnswer>, reject: RejectCallback, frames: string): Promise<void> {
    this.delegate(resolve, reject, () => this.actor.call.tell(frames));
  }

  async untell(resolve: ResolveCallback<IpcAnswer>, reject: RejectCallback, frames: string): Promise<void> {
    this.delegate(resolve, reject, () => this.actor.call.untell(frames));
  }

  async retell(resolve: ResolveCallback<IpcAnswer>, reject: RejectCallback, untellFrames: string, tellFrames: string): Promise<void> {
    this.delegate(resolve, reject, () => this.actor.call.retell(untellFrames, tellFrames));
  }

  async tellModel(resolve: ResolveCallback<IpcAnswer>, reject: RejectCallback, ...files: string[]): Promise<void> {
    this.delegate(resolve, reject, () => this.actor.call.tellModel(...files));
  }

  async ask(resolve: ResolveCallback<IpcAnswer>, reject: RejectCallback, query: string, queryFormat?: string, answerRep?: string, rollbackTime?: string): Promise<void> {
    this.delegate(resolve, reject, () => this.actor.call.ask(query, queryFormat, answerRep, rollbackTime));
  }

  async hypoAsk(resolve: ResolveCallback<IpcAnswer>, reject: RejectCallback, frames: string, query: string, queryFormat?: string, answerRep?: string, rollbackTime?: string): Promise<void> {
    this.delegate(resolve, reject, () => this.actor.call.hypoAsk(frames, query, queryFormat, answerRep, rollbackTime));
  }

  async lpicall(resolve: ResolveCallback<IpcAnswer>, reject: RejectCallback, lpiCall: string): Promise<void> {
    this.delegate(resolve, reject, () => this.actor.call.lpicall(lpiCall));
  }

  async prolog(resolve: ResolveCallback<IpcAnswer>, reject: RejectCallback, statement: string): Promise<void> {
    this.delegate(resolve, reject, () => this.actor.call.prolog(statement));
  }

  async why(resolve: ResolveCallback<IpcAnswer>, reject: RejectCallback): Promise<void> {
    this.delegate(resolve, reject, () => this.actor.call.why());
  }

  async cd(resolve: ResolveCallback<IpcAnswer>, reject: RejectCallback, modulePath?: string): Promise<void> {
    this.delegate(resolve, reject, () => this.actor.call.cd(modulePath));
  }

  async pwd(resolve: ResolveCallback<IpcAnswer>, reject: RejectCallback): Promise<void> {
    this.delegate(resolve, reject, () => this.actor.call.pwd());
  }

  async lm(resolve: ResolveCallback<IpcAnswer>, reject: RejectCallback, modulePath?: string): Promise<void> {
    this.delegate(resolve, reject, () => this.actor.call.lm(modulePath));
  }

  async ls(resolve: ResolveCallback<IpcAnswer>, reject: RejectCallback, className?: string): Promise<void> {
    this.delegate(resolve, reject, () => this.actor.call.ls(className));
  }

  async mkdir(resolve: ResolveCallback<IpcAnswer>, reject: RejectCallback, moduleName: string): Promise<void> {
    this.delegate(resolve, reject, () => this.actor.call.mkdir(moduleName));
  }

  async who(resolve: ResolveCallback<IpcAnswer>, reject: RejectCallback): Promise<void> {
    this.delegate(resolve, reject, () => this.actor.call.who());
  }

  async sub(resolve: ResolveCallback<IpcAnswer>, reject: RejectCallback): Promise<void> {
    this.delegate(resolve, reject, () => this.actor.call.sub());
  }

  async show(resolve: ResolveCallback<IpcAnswer>, reject: RejectCallback, objectName: string): Promise<void> {
    this.delegate(resolve, reject, () => this.actor.call.show(objectName));
  }

  private delegate<T>(resolve: ResolveCallback<T>,
    reject: RejectCallback,
    run: () => Promise<T>,): void {
    void run().then(resolve).catch((err) => {
      reject(err instanceof Error ? err : new Error(String(err)));
    });
  }
}

ihsm.registerStateNames(self);
