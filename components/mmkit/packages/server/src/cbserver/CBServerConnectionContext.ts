export interface ICBConnectionContext {
  readonly connectionId: string;
  readonly onClose: () => void;
  closed: boolean;
}

/** Domain data for the CBServer connection actor. */
export class CBConnectionContext implements ICBConnectionContext {
  readonly connectionId: string;
  readonly onClose: () => void;
  closed = false;

  constructor(connectionId: string, onClose: () => void) {
    this.connectionId = connectionId;
    this.onClose = onClose;
  }
}
