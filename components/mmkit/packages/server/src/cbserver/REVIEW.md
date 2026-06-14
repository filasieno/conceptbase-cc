# CBServer implementation review

Review of the `cbserver` subsystem (supervisor `CBServerActor`, reader/writer subactors,
ports, IPC framing). Overall the implementation is strong: a well-documented hierarchical
state machine with rigorous per-state invariants, clean IO isolation behind ports, and
mirrored mock + real test suites. This document records the substantive issues found and
the proposed solutions.

**Overall rating: 8.5 / 10** — production-grade structure; the items below are what stand
between it and a 9.5+.

---

## Summary

| # | Issue | Severity | Files |
|---|-------|----------|-------|
| 1 | Unescaped command-string assembly | High (correctness) | `CBServerConfig.ts` (`CBServerTop`, ~241–333) |
| 2 | Dual command surface + boilerplate | Medium (maintainability) | `CBServerConfig.ts` |
| 3 | Type smells (`as unknown` cast, `typeof … post`) | Low | `CBServerActor.ts:173`, `CBServerContext.ts:160` |
| 4 | O(n²) framing parse on partial reads | Medium (performance) | `ipc/textFraming.ts`, reader states |
| 5 | Silent buffer drop in reader `Idle` | Medium (correctness) | `reader/CBServerReaderActor.ts:151-158` |

Suggested order of work: **#1 + #2** together (shared command table), then **#5** and
**#4** (both centred on a new frame assembler), then **#3** (mechanical cleanup).

---

## 1. Unescaped command-string assembly — High

### Issue

Commands are built by raw string interpolation in `CBServerTop` and joined on spaces,
e.g. `` `tell ${frames}` `` and `["ask", query, queryFormat, answerRep, rollbackTime].join(" ")``.
There is no quoting or injection guard.

Two distinct sub-problems are conflated:

- **Trailing-rest commands** (`tell`, `untell`, `prolog`, `lpicall`, `show`, `mkdir`, `cd`):
  everything after the verb is a single argument. Because the whole line is length-prefixed
  by the writer, embedded spaces/newlines are already safe — these only need verb validation.
- **Multi-positional commands** (`ask`, `hypoAsk`, `retell`, `tellModel`): arguments are
  space-joined and positional, so any space/newline in `query`, `untellFrames`, a filename,
  etc. silently corrupts argument boundaries downstream. Length-prefixing does **not** fix
  this; it is a genuine ambiguity / injection risk.

The legacy TCP path already solved escaping and is the reference convention to reuse:

```ts
// archive/packages/shared/src/cb-tcp.ts
export function encodeCbString(value: string): string {
  const escaped = value.replace(/\\/g, "\\\\").replace(/"/g, '\\"');
  return `"${escaped}"`;
}
```

### Solution

Introduce a single command-encoder module with per-command descriptors declaring arity and
which arguments are trailing-rest vs delimited tokens. Apply `encodeCbString`-style quoting
to delimited tokens; leave trailing-rest args verbatim (length-prefixing keeps them safe).

```ts
// ipc/cbCommand.ts
type ArgKind = "rest" | "token";

interface CommandSpec {
  verb: string;
  args: ArgKind[];
  trailingRest?: boolean; // last arg consumes the remainder of the line
  variadic?: boolean;     // last token kind repeats (tellModel)
}

const COMMAND_SPECS = {
  tell:      { verb: "tell",      args: ["rest"],  trailingRest: true },
  untell:    { verb: "untell",    args: ["rest"],  trailingRest: true },
  retell:    { verb: "retell",    args: ["token", "token"] },
  ask:       { verb: "ask",       args: ["token", "token", "token", "token"] },
  hypoAsk:   { verb: "hypoAsk",   args: ["token", "token", "token", "token", "token"] },
  tellModel: { verb: "tellModel", args: ["token"], variadic: true },
  // ... remaining commands ...
} as const;

function encodeArg(value: string): string {
  if (value.includes("\0")) throw new Error("NUL not permitted in cbserver argument");
  return encodeCbString(value);
}

export function buildCommand(kind: keyof typeof COMMAND_SPECS, parts: string[]): string {
  const spec = COMMAND_SPECS[kind];
  const encoded = spec.trailingRest
    ? parts
    : parts.filter((p) => p !== "").map(encodeArg);
  return [spec.verb, ...encoded].join(" ");
}
```

### Decision point (blocker)

This requires that the cbserver stdin tokenizer **unquotes** `"…\""` the same way the TCP
`ipcmessage` parser does. The cbserver command parser is not in-tree (the real tests run
against a fixture binary), so confirm the downstream contract before implementing:

- cbserver **supports quoting** → the table above is the fix.
- cbserver **does not** → switch multi-positional commands to the structured
  `ipcmessage(client,server,method,[arg,arg,…]).` form already used over TCP (each arg
  `encodeCbString`-quoted). This is a wire-format change but is the only injection-safe option.

---

## 2. Dual command surface + boilerplate — Medium

### Issue

`CBServerCommandProtocol` declares async `resolve/reject/Promise` signatures, but the
`CBServerTop` implementations are synchronous `void` funnels into `executeCommand`. Both
`executeCommand` and the typed `tell/ask/...` methods are public, giving a redundant and
inconsistent API surface plus ~90 lines of near-identical hand-written funnels.

### Solution

- **Pick one public surface.** Keep the typed `tell/ask/...` methods (type-checked arity,
  better DX) and remove `executeCommand` from `ICBServerPublic`. It remains the
  internal dispatch seam that states override to accept/reject, but is no longer client API.
- **Generate the funnels from the same table as #1**, removing the duplication:

```ts
// CBServerTop — single funnel, table-driven encoding
private dispatch(
  kind: CommandKind,
  parts: string[],
  resolve: ihsm.ResolveCallback<IpcAnswer>,
  reject: ihsm.RejectCallback,
): void {
  this.executeCommand(resolve, reject, buildCommand(kind, parts));
}

tell(resolve, reject, frames: string) {
  this.dispatch("tell", [frames], resolve, reject);
}
ask(resolve, reject, q, fmt?, rep?, rb?) {
  this.dispatch("ask", [q, fmt, rep, rb].filter((x) => x !== undefined) as string[], resolve, reject);
}
```

- **Reconcile signatures.** Align `CBServerCommandProtocol` to the actual dispatch shape
  (synchronous `void` with resolve/reject callbacks, matching how ihsm invokes handlers) so
  the type reflects reality.

---

## 3. Type smells — Low

### Issue

- `this.hsm as unknown as CBServerActorRef` (`CBServerActor.ts:173`) — double cast bypasses
  the type system.
- `typeof children.reader.post === "function"` (`CBServerContext.ts:160`) — runtime feature
  detection because `Actor.post` is optional in the type.

### Solution

Typed self-reference accessor instead of a double cast (single documented seam):

```ts
// CBServerTop
protected selfRef(): CBServerActorRef {
  return this.hsm as CBServerActorRef;
}
```

If `ihsm.TopState` can expose `this.self` typed as `InboundPoster<Ctx, InternalProtocol>`,
prefer that and drop the cast entirely (worth a small ihsm-side addition — every server
actor hits this).

For the children probe, define a narrow child contract so `post` is guaranteed and the
runtime check disappears:

```ts
interface InterruptibleChild { post(ev: "interrupt"): void; }

type CBServerStdioChildren = {
  reader: ihsm.Actor<ReaderContext, IReaderPublic> & InterruptibleChild;
  writer: ihsm.Actor<WriterContext, IWriterPublic> & InterruptibleChild;
  readerPort: ForwardingReaderPort;
  writerPort: IWriterPort;
};
```

`beginDetachChildren` / `dispatchInterruptToChildren` then call `children.reader.post("interrupt")`
directly, and `awaitReaderInterrupted` becomes an unconditional `true`.

---

## 4. O(n²) framing parse on partial reads — Medium

### Issue

`tryParseTextFramedMessage` re-walks the body from offset 0 on every `onData` chunk while a
frame is still incomplete (to map a UTF-8 byte length to a char boundary). For a large
answer arriving in many small chunks this is quadratic.

### Solution

Make the assembler stateful and incremental: maintain a running byte count and cache the
parsed header, so each chunk is an O(chunk) gate; do a single code-point walk only once the
full frame has arrived.

```ts
// ipc/frameAssembler.ts
class FrameAssembler {
  private buffer = "";
  private bufferBytes = 0;
  private header?: { bodyBytes: number; bodyStartChar: number };

  push(chunk: string): void {
    this.buffer += chunk;
    this.bufferBytes += Buffer.byteLength(chunk, "utf8");
  }

  tryTake(): { body: string } | undefined {
    if (this.header === undefined) {
      const nl = this.buffer.indexOf("\n");
      if (nl < 0) return undefined;
      const len = Number.parseInt(this.buffer.slice(0, nl), 10);
      if (!Number.isFinite(len) || len < 0) return undefined;
      this.header = { bodyBytes: len, bodyStartChar: nl + 1 };
    }
    const headerBytes = Buffer.byteLength(this.buffer.slice(0, this.header.bodyStartChar), "utf8");
    if (this.bufferBytes - headerBytes < this.header.bodyBytes) return undefined; // cheap gate
    // single final walk over the body to map bodyBytes -> char count, slice once,
    // then reset header and recompute bufferBytes for the remainder.
    // ...
  }
}
```

Reader states call `assembler.push()` in `onData` and `assembler.tryTake()` where they
currently call `tryParseTextFramedMessage`. Keep the pure `tryParseTextFramedMessage` for
tests, implemented in terms of the assembler. This turns N partial chunks for one frame
from O(N²) into O(total length).

---

## 5. Silent buffer drop in reader `Idle` — Medium

### Issue

In `Idle`, over-limit unsolicited stdout is cleared wholesale, which can chop a frame
mid-body and desync all subsequent framing:

```ts
// reader/CBServerReaderActor.ts:151-158
onData(chunk: string): void {
  this._checkInvariant();
  this.ctx.appendBuffer(chunk);
  if (this.ctx.buffer.length > this.ctx.config.maxBufferBytes) {
    // No read is pending in Idle; drop unsolicited stdout to stay bounded.
    this.ctx.clearBuffer();
  }
}
```

### Solution

Drain whole frames instead of truncating, and treat true overflow as fatal rather than
silent:

1. **Drain complete frames while idle** using the assembler from #4 — repeatedly `tryTake()`
   and either discard each parsed frame or route it as a notification (the answer parser
   already distinguishes a `notification` completion). The buffer then only ever retains a
   *partial trailing* frame, so framing never desyncs.
2. **Only a single oversized in-progress frame is an error**, and it must be loud: escalate
   via `postReaderFailed` and force the supervisor to recycle the subprocess, because at that
   point stream sync is unrecoverable.

```ts
// Idle.onData (sketch)
onData(chunk: string): void {
  this._checkInvariant();
  this.ctx.appendBuffer(chunk);
  let frame;
  while ((frame = this.ctx.assembler.tryTake()) !== undefined) {
    this.ctx.routeNotification(frame); // emit or discard a fully-formed unsolicited frame
  }
  if (this.ctx.bufferBytes > this.ctx.config.maxBufferBytes) {
    this.ctx.postReaderFailed(`unsolicited stdout exceeded ${this.ctx.config.maxBufferBytes} bytes`);
  }
}
```

If notifications are explicitly out of scope, replace `routeNotification` with a discard —
but the discard must happen at **frame granularity**, which is the part that preserves sync.
