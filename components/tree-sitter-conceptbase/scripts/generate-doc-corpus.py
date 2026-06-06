#!/usr/bin/env python3
"""
Extract ConceptBase / Telos sources from documentation and example trees,
then write tree-sitter corpus files under source/test/corpus/.

Usage:
  python3 scripts/generate-doc-corpus.py
  cd source && tree-sitter generate && tree-sitter test -u
"""
from __future__ import annotations

import hashlib
import re
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DOC = ROOT.parents[1] / "components" / "doc"
EXAMPLES = ROOT.parents[1] / "components" / "examples" / "src"
CORPUS = ROOT / "source" / "test" / "corpus"

SKIP_RE = re.compile(
    r"(-->"
    r"|<[A-Za-z][A-Za-z0-9_]*>"
    r"|\\ref\b"
    r"|\\section\b"
    r"|\\begin\{"
    r"|\[\.\.\.\]"
    r"|^\s*cd\s"
    r"|tell\s+\""
    r"|P\(#"
    r"|\[offline\]"
    r"|asks\("
    r"|\\\\tt\b"
    r"|#set\s+text"
    r"|#include\b"
    r"|#import\b"
    r"|#raw\("
    r"|#link\("
    r"|#figure\("
    r"|#table\("
    r"|printf\s*\("
    r"|strcmp\s*\("
    r"|#!/bin"
    r"|typedef\s+"
    r"|struct\s+\w"
    r'|int\s+main\s*\('
    r"|public\s+class\b"
    r"|import\s+java\.)",
    re.M,
)

END_LINE = re.compile(r"^\s*(end|END|endmit|ENDMIT)\s*$", re.I | re.M)
FRAME_KEY = re.compile(r"\b(in|with|isA|isa|IN|WITH|ISA)\b", re.I)
# Object names may include selectors (! ^ @ . |) and parentheses.
FRAME_HEAD = r"(?:QueryClass|Class|Function|GenericQueryClass|Individual\s+AnswerFormat|[A-Za-z][\w!^@.|/-]*)"
FRAME_START = re.compile(
    rf"^(?:{FRAME_HEAD})\s+(?:in|isA|isa|IN|ISA)\b",
    re.I | re.M,
)
INLINE_FRAME = re.compile(
    rf"(?ms)^({FRAME_HEAD}\s+(?:in|isA|isa|IN|ISA)\b.*?^\s*end\s*$)",
    re.I,
)

CB_EMBED_BODY = re.compile(
    r"\b(forall|exists|not\b|==>|<==>|~\w|In\(|Tell|Untell|From\(|To\(|and|or)\b",
    re.I,
)


def unescape_cb(text: str) -> str:
    return (
        text.replace("\\$", "$")
        .replace("\\_", "_")
        .replace("\\{", "{")
        .replace("\\}", "}")
    )


def norm_hash(text: str) -> str:
    return hashlib.sha256(text.strip().encode("utf-8")).hexdigest()[:16]


def should_skip(text: str) -> bool:
    if not text.strip():
        return True
    if SKIP_RE.search(text):
        return True
    lines = [ln.strip() for ln in text.splitlines() if ln.strip()]
    if lines and all(re.match(r"^P\(", ln) for ln in lines):
        return True
    # Prose paragraphs (tutorial narrative).
    if len(text) > 400 and not FRAME_START.match(text.strip()):
        wordish = sum(1 for w in text.split() if len(w) > 2)
        if wordish > 60 and "$" not in text:
            return True
    return False


def cb_embeddings(text: str) -> list[str]:
    """ConceptBase $...$ regions, ignoring shell ${var} expansions."""
    scrubbed = re.sub(r"\$\{[^}]*\}", "", text)
    return re.findall(r"\$[^$]+\$", scrubbed)


def looks_like_frame(text: str) -> bool:
    text = unescape_cb(text)
    if should_skip(text):
        return False
    if not END_LINE.search(text):
        return False
    if not FRAME_KEY.search(text):
        return False
    if not FRAME_START.match(text.strip()):
        return False
    return True


def looks_like_assertion_codeblock(text: str) -> bool:
    text = unescape_cb(text)
    if should_skip(text):
        return False
    if looks_like_frame(text):
        return False
    embeds = cb_embeddings(text)
    if embeds and any(CB_EMBED_BODY.search(e) for e in embeds):
        return True
    if re.search(r"\bON\s+(Tell|Untell|tell|untell)\b", text):
        return True
    if re.search(r"^\s*(forall|exists)\b", text, re.I | re.M):
        return True
    return False


def looks_like_assertion_inline(text: str) -> bool:
    text = unescape_cb(text.strip())
    if not text.startswith("$") or not text.endswith("$"):
        return False
    if "arrow" in text:  # Typst math, e.g. $L arrow.r R$
        return False
    return bool(CB_EMBED_BODY.search(text))


def looks_like_directive(text: str) -> bool:
    s = unescape_cb(text).strip()
    return s.startswith("{$set") and s.endswith("}")


def looks_like_cb_content(text: str) -> bool:
    """Heuristic: documentation block is ConceptBase/Telos, not C/Java/shell."""
    s = unescape_cb(text).strip()
    if should_skip(s):
        return False
    if looks_like_frame(s) or looks_like_directive(s) or looks_like_assertion_codeblock(s):
        return True
    embeds = cb_embeddings(s)
    if embeds and any(CB_EMBED_BODY.search(e) for e in embeds):
        return True
    if re.search(r"^\s*(tell|forall|exists|Rule\b|ON\s+Tell)\b", s, re.I | re.M):
        return True
    if re.search(r"\b(QueryClass|GenericQueryClass|Function|Class)\b", s):
        return True
    if re.search(r"[!^@]", s) and re.search(r"\b(in|end|with)\b", s, re.I):
        return True
    return False


def split_frames(text: str) -> list[str]:
    text = unescape_cb(text)
    chunks: list[str] = []
    current: list[str] = []
    for line in text.splitlines():
        current.append(line)
        if END_LINE.match(line):
            block = "\n".join(current).strip()
            if looks_like_frame(block):
                chunks.append(block)
            current = []
    if current:
        block = "\n".join(current).strip()
        if looks_like_frame(block):
            chunks.append(block)
    if chunks:
        return chunks
    return [text] if looks_like_frame(text) else []


def add_entry(
    out: list[tuple[str, str, str]],
    seen: set[str],
    kind: str,
    name: str,
    body: str,
) -> None:
    body = unescape_cb(body).strip()
    if not body:
        return
    h = norm_hash(body)
    if h in seen:
        return
    seen.add(h)
    out.append((kind, name, body))


def extract_from_text(
    text: str,
    rel: Path,
    seen: set[str],
    out: list[tuple[str, str, str]],
    source_label: str,
) -> None:
    for idx, m in enumerate(re.finditer(r"```[^\n]*\n(.*?)```", text, re.S)):
        body = m.group(1).strip("\n")
        frames = split_frames(body)
        if frames:
            for j, fr in enumerate(frames):
                suffix = f"{source_label}:{idx + 1}.{j + 1}" if len(frames) > 1 else f"{source_label}:{idx + 1}"
                add_entry(out, seen, "frame", f"doc-frame: {rel}:{suffix}", fr)
            continue
        if looks_like_directive(body):
            add_entry(out, seen, "snippet", f"doc-directive: {rel}:{source_label}:{idx + 1}", body)
            continue
        if looks_like_assertion_codeblock(body):
            add_entry(out, seen, "assertion", f"doc-assertion: {rel}:{source_label}:{idx + 1}", body)
            continue
        if looks_like_cb_content(body):
            add_entry(out, seen, "snippet", f"doc-cb: {rel}:{source_label}:{idx + 1}", body)
            continue

    # #quote(block: true)[ ... ] and similar bracket blocks from Typst conversion.
    for idx, m in enumerate(re.finditer(r"#quote\([^)]*\)\[(.*?)\]", text, re.S)):
        body = m.group(1).strip()
        for j, fr in enumerate(split_frames(body) or ([] if not looks_like_frame(body) else [body])):
            suffix = f"quote:{idx + 1}.{j + 1}" if len(split_frames(body) or [body]) > 1 else f"quote:{idx + 1}"
            add_entry(out, seen, "frame", f"doc-frame: {rel}:{suffix}", fr)

    # Inline Telos frames in Typst body (LaTeX conversion often omits fences).
    scrubbed = re.sub(r"```.*?```", "", text, flags=re.S)
    scrubbed = re.sub(r"#quote\([^)]*\)\[.*?\]", "", scrubbed, flags=re.S)
    for idx, m in enumerate(INLINE_FRAME.finditer(scrubbed)):
        body = m.group(1).strip()
        if looks_like_frame(body):
            add_entry(out, seen, "frame", f"doc-frame: {rel}:inline:{idx + 1}", body)

    for idx, m in enumerate(re.finditer(r"\$[^$\n]+\$", scrubbed)):
        body = m.group(0).strip()
        if looks_like_assertion_inline(body):
            add_entry(out, seen, "assertion", f"doc-assertion-inline: {rel}:{idx + 1}", body)

    for idx, m in enumerate(re.finditer(r"\\\$([^$]+?)\\\$", scrubbed)):
        body = unescape_cb("$" + m.group(1).strip() + "$")
        if looks_like_assertion_inline(body):
            add_entry(
                out,
                seen,
                "assertion",
                f"doc-assertion-escaped: {rel}:{idx + 1}",
                body,
            )


def extract_all_doc_blocks() -> list[tuple[str, str, str]]:
    out: list[tuple[str, str, str]] = []
    seen: set[str] = set()
    for typ in sorted(DOC.rglob("*.typ")):
        rel = typ.relative_to(DOC)
        text = typ.read_text(encoding="utf-8", errors="replace")
        extract_from_text(text, rel, seen, out, "block")
    return out


_CORPUS_TEST = re.compile(
    r"^==================\n(.+?)\n==================\n\n(.*?)\n\n---\n\n(.*?)(?=\n\n==================\n|\Z)",
    re.S | re.M,
)


def read_corpus_trees(path: Path) -> dict[str, tuple[str, str]]:
    """Map test name -> (body_hash, expected_tree)."""
    if not path.exists():
        return {}
    content = path.read_text(encoding="utf-8")
    trees: dict[str, tuple[str, str]] = {}
    for m in _CORPUS_TEST.finditer(content):
        name, body, tree = m.group(1).strip(), m.group(2), m.group(3).strip()
        trees[name] = (norm_hash(body), tree)
    return trees


def write_corpus(path: Path, entries: list[tuple[str, str]]) -> int:
    path.parent.mkdir(parents=True, exist_ok=True)
    preserved = read_corpus_trees(path)
    parts: list[str] = []
    for name, body in entries:
        body = body.rstrip()
        h = norm_hash(body)
        tree = preserved.get(name, ("", ""))[1]
        if not tree or preserved.get(name, ("", ""))[0] != h:
            tree = "(source_file)"
        parts.extend(
            [
                "==================",
                name,
                "==================",
                "",
                body,
                "",
                "---",
                "",
                tree,
                "",
            ]
        )
    path.write_text("\n".join(parts), encoding="utf-8")
    return len(entries)


def collect_examples() -> list[tuple[str, str]]:
    entries: list[tuple[str, str]] = []
    if not EXAMPLES.is_dir():
        return entries
    for sml in sorted(EXAMPLES.rglob("*.sml")):
        rel = sml.relative_to(EXAMPLES)
        body = sml.read_text(encoding="utf-8", errors="replace")
        entries.append((f"example: {rel.as_posix()}", body))
    return entries


def parse_ok(body: str, source_dir: Path) -> bool:
    try:
        with tempfile.NamedTemporaryFile(
            mode="w",
            suffix=".cb",
            encoding="utf-8",
            delete=False,
        ) as tmp:
            tmp.write(body)
            tmp_path = tmp.name
        proc = subprocess.run(
            ["tree-sitter", "parse", "--quiet", tmp_path],
            cwd=source_dir,
            capture_output=True,
            text=True,
            timeout=60,
        )
        Path(tmp_path).unlink(missing_ok=True)
    except (subprocess.TimeoutExpired, FileNotFoundError, OSError):
        return False
    out = proc.stdout + proc.stderr
    return (
        proc.returncode == 0
        and "ERROR" not in out
        and "MISSING" not in out
    )


def main() -> int:
    source_dir = ROOT / "source"
    if shutil_which("tree-sitter"):
        subprocess.run(["tree-sitter", "generate"], cwd=source_dir, check=False)

    blocks = extract_all_doc_blocks()

    frames = [(n, b) for k, n, b in blocks if k == "frame"]
    assertions = [(n, b) for k, n, b in blocks if k == "assertion"]
    snippets = [(n, b) for k, n, b in blocks if k == "snippet"]
    examples = collect_examples()

    bad: list[str] = []
    if shutil_which("tree-sitter"):
        for group in (frames, assertions, snippets, examples):
            for name, body in group:
                if not parse_ok(body, source_dir):
                    bad.append(name)

    n_frames = write_corpus(CORPUS / "documentation-frames.txt", frames)
    n_assert = write_corpus(CORPUS / "documentation-assertions.txt", assertions)
    n_snip = write_corpus(CORPUS / "documentation-snippets.txt", snippets)
    n_ex = write_corpus(CORPUS / "examples-corpus.txt", examples)

    manifest = CORPUS / "documentation-parse-failures.txt"
    manifest.write_text("\n".join(bad) + "\n" if bad else "", encoding="utf-8")

    print(f"Wrote {n_frames} frame tests -> documentation-frames.txt")
    print(f"Wrote {n_assert} assertion tests -> documentation-assertions.txt")
    print(f"Wrote {n_snip} snippet tests -> documentation-snippets.txt")
    print(f"Wrote {n_ex} example tests -> examples-corpus.txt")
    print(f"Total doc+example entries: {n_frames + n_assert + n_snip + n_ex}")
    if bad:
        print(f"Parse smoke failures: {len(bad)} (listed in {manifest.name})")
    print("Next: cd source && tree-sitter test -u")
    return 0


def shutil_which(cmd: str) -> str | None:
    from shutil import which

    return which(cmd)


if __name__ == "__main__":
    sys.exit(main())
