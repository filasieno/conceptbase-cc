#!/usr/bin/env python3
"""Convert ConceptBase {* *}, { }, and /* */ comments to Prolog % line comments."""

from __future__ import annotations

import re
import sys
from pathlib import Path

_PREDICATE_HEAD = re.compile(
    r"^('(?:[^'\\]|\\.|'')*'|[A-Za-z_][A-Za-z0-9_]*)\s*(?:\(|\.|:-)"
)


def format_body(body: str, indent: str) -> str:
    lines: list[str] = []
    for raw in body.split("\n"):
        stripped = raw.rstrip()
        if not stripped:
            lines.append(indent + "%")
            continue
        content = stripped
        if content.startswith("*"):
            content = content[1:]
            if content.startswith(" "):
                content = content[1:]
        if not content:
            lines.append(indent + "%")
        else:
            lines.append(indent + "% " + content)
    return "\n".join(lines)


def is_comment_line(line: str) -> bool:
    return line.lstrip().startswith("%")


def predicate_head(line: str) -> str | None:
    if line != line.lstrip() or not line.strip() or is_comment_line(line):
        return None
    match = _PREDICATE_HEAD.match(line.lstrip())
    return match.group(1) if match else None


def clause_predicate_head(lines: list[str], index: int) -> str | None:
    head = predicate_head(lines[index])
    if head:
        return head
    for j in range(index - 1, -1, -1):
        head = predicate_head(lines[j])
        if head:
            return head
    return None


def add_spacing(text: str) -> str:
    lines = text.splitlines()
    out: list[str] = []
    for line in lines:
        if not line.strip():
            continue
        if out:
            prev = out[-1]
            need_blank = False
            curr_head = predicate_head(line)
            if is_comment_line(prev) and not is_comment_line(line):
                need_blank = True
            elif (
                curr_head
                and prev.rstrip().endswith(".")
                and not is_comment_line(prev)
            ):
                prev_head = clause_predicate_head(out, len(out) - 1)
                if prev_head and prev_head != curr_head:
                    need_blank = True
            if need_blank:
                out.append("")
        out.append(line)
    result = "\n".join(out)
    if text.endswith("\n"):
        result += "\n"
    return result


def collapse_comment_blanks(text: str) -> str:
    lines = text.splitlines(keepends=True)
    if not lines:
        return text
    out: list[str] = []
    i = 0
    while i < len(lines):
        out.append(lines[i])
        if (
            i + 2 < len(lines)
            and is_comment_line(lines[i])
            and lines[i + 1].strip() == ""
            and is_comment_line(lines[i + 2])
        ):
            i += 2
            continue
        i += 1
    return "".join(out)


def find_closer_star(text: str, pos: int) -> int:
    """Return index after *} or botched *) closing a {* comment."""
    j = pos
    n = len(text)
    while j < n:
        if text[j] == "*" and j + 1 < n:
            nxt = text[j + 1]
            if nxt == "}":
                return j + 2
            if nxt == ")" and j + 2 < n and text[j + 2] in "\n\r":
                return j + 2
        j += 1
    return n


def find_closer_brace(text: str, pos: int) -> int:
    j = pos
    n = len(text)
    depth = 1
    while j < n and depth:
        ch = text[j]
        if ch == "'":
            j += 1
            while j < n:
                if text[j] == "\\" and j + 1 < n:
                    j += 2
                    continue
                if text[j] == "'":
                    if j + 1 < n and text[j + 1] == "'":
                        j += 2
                        continue
                    j += 1
                    break
                j += 1
            continue
        if ch == '"':
            j += 1
            while j < n and text[j] != '"':
                if text[j] == "\\" and j + 1 < n:
                    j += 2
                else:
                    j += 1
            j += 1
            continue
        if ch == "{":
            depth += 1
        elif ch == "}":
            depth -= 1
            if depth == 0:
                return j + 1
        j += 1
    return n


def convert_content(text: str) -> str:
    out: list[str] = []
    line_buf: list[str] = []
    i = 0
    n = len(text)

    def flush_line() -> None:
        out.append("".join(line_buf))
        line_buf.clear()

    def line_indent(buf: str) -> str:
        return buf[: len(buf) - len(buf.lstrip("\t "))]

    while i < n:
        ch = text[i]

        if ch == "%":
            flush_line()
            nl = text.find("\n", i)
            if nl == -1:
                out.append(text[i:])
                break
            out.append(text[i : nl + 1])
            i = nl + 1
            continue

        if ch == "'":
            j = i + 1
            while j < n:
                if text[j] == "\\" and j + 1 < n:
                    j += 2
                    continue
                if text[j] == "'":
                    if j + 1 < n and text[j + 1] == "'":
                        j += 2
                        continue
                    j += 1
                    break
                j += 1
            line_buf.append(text[i:j])
            i = j
            continue

        if ch == '"':
            j = i + 1
            while j < n:
                if text[j] == "\\" and j + 1 < n:
                    j += 2
                    continue
                if text[j] == '"':
                    j += 1
                    break
                j += 1
            line_buf.append(text[i:j])
            i = j
            continue

        if ch == "/" and i + 1 < n and text[i + 1] == "*":
            j = i + 2
            while j < n - 1:
                if text[j] == "*" and text[j + 1] == "/":
                    break
                j += 1
            comment = text[i + 2 : j]
            buf = "".join(line_buf)
            has_code = bool(buf.strip())
            indent = line_indent(buf) if not has_code else ""
            pct = format_body(comment, indent)
            single = "\n" not in comment
            if has_code:
                body = comment.strip()
                if body.startswith("*"):
                    body = body[1:].lstrip()
                if single:
                    line_buf = [buf.rstrip(), "  % ", body]
                else:
                    out.append(buf.rstrip())
                    out.append("\n")
                    out.append(pct)
                    out.append("\n")
                    line_buf.clear()
            else:
                line_buf.clear()
                out.append(pct)
                out.append("\n")
            i = j + 2
            if (not has_code or not single) and i < n and text[i] == "\n":
                i += 1
            continue

        if ch == "{" and i + 1 < n and text[i + 1] == "*":
            close = find_closer_star(text, i + 2)
            comment = text[i + 2 : close - 2] if close <= n else text[i + 2 :]
            if close > i + 2 and text[close - 2 : close] == "*)":
                comment = text[i + 2 : close - 2]
            elif close > i + 2:
                comment = text[i + 2 : close - 2]

            buf = "".join(line_buf)
            has_code = bool(buf.strip())
            indent = line_indent(buf) if not has_code else ""
            pct = format_body(comment, indent)
            single = "\n" not in comment
            if has_code:
                body = comment.strip()
                if body.startswith("*"):
                    body = body[1:].lstrip()
                if single:
                    line_buf = [buf.rstrip(), "  % ", body]
                else:
                    out.append(buf.rstrip())
                    out.append("\n")
                    out.append(pct)
                    out.append("\n")
                    line_buf.clear()
            else:
                line_buf.clear()
                out.append(pct)
                out.append("\n")
            i = close
            if (not has_code or not single) and i < n and text[i] == "\n":
                i += 1
            continue

        if ch == "{":
            buf_so_far = "".join(line_buf)
            # Brace comment: own line, after comma, or after opening paren context.
            rest = text[i:]
            stripped_before = buf_so_far.rstrip()
            is_inline = bool(stripped_before) and not stripped_before.endswith(
                ("\n", "(", "[")
            )
            close = find_closer_brace(text, i + 1)
            comment = text[i + 1 : close - 1] if close <= n else text[i + 1 :]
            buf = "".join(line_buf)
            has_code = bool(buf.strip()) and is_inline
            indent = line_indent(buf) if not has_code else line_indent(buf)
            pct = format_body(comment, indent if not has_code else indent + "  ")
            single = "\n" not in comment
            if has_code:
                if single:
                    out.append(buf.rstrip())
                    out.append("\n")
                    out.append(indent + "  % " + comment.strip())
                    out.append("\n")
                    line_buf.clear()
                else:
                    out.append(buf.rstrip())
                    out.append("\n")
                    out.append(pct)
                    out.append("\n")
                    line_buf.clear()
            else:
                line_buf.clear()
                out.append(pct)
                out.append("\n")
            i = close
            if i < n and text[i] == "\n":
                i += 1
            continue

        line_buf.append(ch)
        if ch == "\n":
            flush_line()
        i += 1

    if line_buf:
        out.append("".join(line_buf))

    text = collapse_comment_blanks("".join(out))
    return add_spacing(text)


def main() -> int:
    if len(sys.argv) != 2:
        print(f"usage: {sys.argv[0]} <file>", file=sys.stderr)
        return 1
    path = Path(sys.argv[1])
    original = path.read_text(encoding="utf-8", errors="surrogateescape")
    converted = convert_content(original)
    path.write_text(converted, encoding="utf-8")
    print(f"converted {path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
