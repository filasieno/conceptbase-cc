/** Mirrors the VS Code `Disposable` pattern for port subscription cleanup. */
export interface Disposable {
  dispose(): void;
}

export class DisposableStore implements Disposable {
  private readonly items = new Set<Disposable>();

  add(disposable: Disposable): Disposable {
    this.items.add(disposable);
    return {
      dispose: () => {
        disposable.dispose();
        this.items.delete(disposable);
      },
    };
  }

  dispose(): void {
    for (const disposable of this.items) {
      disposable.dispose();
    }
    this.items.clear();
  }
}
