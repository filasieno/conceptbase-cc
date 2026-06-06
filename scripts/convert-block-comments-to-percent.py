#!/usr/bin/env python3
"""Convert C-style /* */ block comments to Prolog % line comments."""

from __future__ import annotations

import re
import sys
from pathlib import Path

_PREDICATE_HEAD = re.compile(
    r"^('(?:[^'\\]|\\.|'')*'|[A-Za-z_][A-Za-z0-9_]*)\s*(?:\(|\.|:-)"
)

ROOT = Path(__file__).resolve().parents[1]


def is_prolog_file(path: Path) -> bool:
    if path.name.endswith(".swi.pl"):
        return True
    return path.suffix in {".pl", ".dcg", ".builtin", ".pro"}


def format_comment_body(comment: str, indent: str) -> str:
    lines: list[str] = []
    for raw in comment.split("\n"):
        stripped = raw.rstrip()
        if not stripped:
            lines.append(indent + "%")
            continue
        content = stripped
        if content.startswith("*"):
            content = content[1:]
            if content.startswith(" "):
                content = content[1:]
            elif content == "/":
                continue
        if not content:
            lines.append(indent + "%")
        else:
            lines.append(indent + "% " + content)
    return "\n".join(lines)


def is_comment_line(line: str) -> bool:
    return line.lstrip().startswith("%")


def is_top_level_line(line: str) -> bool:
    return bool(line.strip()) and line == line.lstrip()


def predicate_head(line: str) -> str | None:
    """Top-level clause head name, or None if not a predicate line."""
    if not is_top_level_line(line) or is_comment_line(line):
        return None
    match = _PREDICATE_HEAD.match(line.lstrip())
    return match.group(1) if match else None


def clause_predicate_head(lines: list[str], index: int) -> str | None:
    """Predicate name for the clause containing lines[index]."""
    head = predicate_head(lines[index])
    if head:
        return head
    for j in range(index - 1, -1, -1):
        head = predicate_head(lines[j])
        if head:
            return head
    return None


def add_spacing_after_comments_and_dots(text: str) -> str:
    """Insert a blank line after comment blocks and after '.' before a new predicate."""
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


def collapse_blank_lines_after_comments(text: str) -> str:
    """Remove blank lines between consecutive % comment lines."""
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

        # Existing Prolog % comment — copy through end of line
        if ch == "%":
            flush_line()
            nl = text.find("\n", i)
            if nl == -1:
                out.append(text[i:])
                break
            out.append(text[i : nl + 1])
            i = nl + 1
            continue

        # Single-quoted atom
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

        # Double-quoted string
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

        # Block comment
        if ch == "/" and i + 1 < n and text[i + 1] == "*":
            j = i + 2
            while j < n - 1:
                if text[j] == "*" and text[j + 1] == "/":
                    break
                j += 1
            else:
                line_buf.append(text[i:])
                break

            comment = text[i + 2 : j]
            buf = "".join(line_buf)
            has_code = bool(buf.strip())
            indent = line_indent(buf) if not has_code else ""

            pct = format_comment_body(comment, indent)
            single_line_comment = "\n" not in comment

            if has_code:
                if single_line_comment:
                    body = comment.strip()
                    if body.startswith("*"):
                        body = body[1:].lstrip()
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
            if (not has_code or not single_line_comment) and i < n and text[i] == "\n":
                i += 1
            continue

        line_buf.append(ch)
        if ch == "\n":
            flush_line()
        i += 1

    if line_buf:
        out.append("".join(line_buf))
    text = collapse_blank_lines_after_comments("".join(out))
    return add_spacing_after_comments_and_dots(text)


def process_file(
    path: Path,
    fix_blanks_only: bool = False,
    fix_spacing_only: bool = False,
) -> bool:
    original = path.read_text(encoding="utf-8", errors="surrogateescape")
    if fix_spacing_only:
        converted = add_spacing_after_comments_and_dots(
            collapse_blank_lines_after_comments(original)
        )
    elif fix_blanks_only:
        converted = collapse_blank_lines_after_comments(original)
    else:
        if "/*" not in original:
            return False
        converted = convert_content(original)
    if converted != original:
        path.write_text(converted, encoding="utf-8")
        return True
    return False


def main() -> int:
    fix_blanks_only = "--fix-blanks" in sys.argv
    fix_spacing_only = "--fix-spacing" in sys.argv or "--fix-newlines" in sys.argv
    components = ROOT / "components"
    changed = 0
    scanned = 0
    for path in sorted(components.rglob("*")):
        if not path.is_file() or not is_prolog_file(path):
            continue
        scanned += 1
        if process_file(
            path,
            fix_blanks_only=fix_blanks_only,
            fix_spacing_only=fix_spacing_only,
        ):
            changed += 1
            print(path.relative_to(ROOT))
    if fix_spacing_only:
        action = "added spacing in"
    elif fix_blanks_only:
        action = "fixed blank lines in"
    else:
        action = "converted"
    print(f"Scanned {scanned} Prolog files, {action} {changed}", file=sys.stderr)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
