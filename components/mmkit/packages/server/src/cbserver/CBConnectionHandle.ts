import type * as ihsm from "ihsm";
import type { CBAnswer, ICBConnection } from "./CBServerDefs";
import type { CBConnectionMachineConfig } from "./CBServerConnection";

export class CBConnectionHandle implements ICBConnection {
  private readonly actor: ihsm.ExternalActor<CBConnectionMachineConfig>;

  constructor(actor: ihsm.ExternalActor<CBConnectionMachineConfig>) {
    this.actor = actor;
  }

  async getConnectionId(): Promise<string> {
    return this.actor.call.getConnectionId();
  }

  async close(): Promise<void> {
    await this.actor.call.close();
  }

  async tell(frames: string): Promise<CBAnswer> {
    return this.actor.call.tell(frames);
  }

  async untell(frames: string): Promise<CBAnswer> {
    return this.actor.call.untell(frames);
  }

  async retell(untellFrames: string, tellFrames: string): Promise<CBAnswer> {
    return this.actor.call.retell(untellFrames, tellFrames);
  }

  async tellModel(...files: string[]): Promise<CBAnswer> {
    return this.actor.call.tellModel(...files);
  }

  async ask(query: string, queryFormat?: string, answerRep?: string, rollbackTime?: string): Promise<CBAnswer> {
    return this.actor.call.ask(query, queryFormat, answerRep, rollbackTime);
  }

  async hypoAsk(frames: string, query: string, queryFormat?: string, answerRep?: string, rollbackTime?: string): Promise<CBAnswer> {
    return this.actor.call.hypoAsk(frames, query, queryFormat, answerRep, rollbackTime);
  }

  async lpicall(lpiCall: string): Promise<CBAnswer> {
    return this.actor.call.lpicall(lpiCall);
  }

  async prolog(statement: string): Promise<CBAnswer> {
    return this.actor.call.prolog(statement);
  }

  async why(): Promise<CBAnswer> {
    return this.actor.call.why();
  }

  async cd(modulePath?: string): Promise<CBAnswer> {
    return this.actor.call.cd(modulePath);
  }

  async pwd(): Promise<CBAnswer> {
    return this.actor.call.pwd();
  }

  async lm(modulePath?: string): Promise<CBAnswer> {
    return this.actor.call.lm(modulePath);
  }

  async ls(className?: string): Promise<CBAnswer> {
    return this.actor.call.ls(className);
  }

  async mkdir(moduleName: string): Promise<CBAnswer> {
    return this.actor.call.mkdir(moduleName);
  }

  async who(): Promise<CBAnswer> {
    return this.actor.call.who();
  }

  async sub(): Promise<CBAnswer> {
    return this.actor.call.sub();
  }

  async show(objectName: string): Promise<CBAnswer> {
    return this.actor.call.show(objectName);
  }
}
