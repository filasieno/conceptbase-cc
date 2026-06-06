#!/usr/bin/env python3
"""Reduce step: apply translated comment lines to components/ source files."""

from __future__ import annotations

import json
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[3]
OUT = Path(__file__).resolve().parent


def main() -> int:
    replacements: dict[str, dict[int, tuple[str, str]]] = {}
    applied = 0
    skipped = 0

    for result_file in sorted(OUT.glob("batch-*-result.json")):
        data = json.loads(result_file.read_text(encoding="utf-8"))
        for section in data:
            path = section["file"]
            if path not in replacements:
                replacements[path] = {}
            for ln in section["lines"]:
                line_no = ln["line"]
                original = ln["original"]
                translated = ln.get("translated", original)
                replacements[path][line_no] = (original, translated)

    for rel_path, line_map in sorted(replacements.items()):
        src = REPO / rel_path
        if not src.exists():
            print(f"MISSING {rel_path}", file=sys.stderr)
            continue
        lines = src.read_text(encoding="latin-1", errors="replace").splitlines()
        changed = False
        for line_no, (original, translated) in line_map.items():
            idx = line_no - 1
            if idx < 0 or idx >= len(lines):
                print(f"SKIP out of range {rel_path}:{line_no}", file=sys.stderr)
                skipped += 1
                continue
            if lines[idx] == original:
                lines[idx] = translated
                applied += 1
                changed = True
            elif lines[idx] == translated:
                skipped += 1
            else:
                print(
                    f"MISMATCH {rel_path}:{line_no}\n"
                    f"  expected: {original!r}\n"
                    f"  actual:   {lines[idx]!r}",
                    file=sys.stderr,
                )
                skipped += 1
        if changed:
            src.write_text("\n".join(lines) + "\n", encoding="latin-1")

    print(f"applied {applied} line replacements across {len(replacements)} files")
    print(f"skipped {skipped} lines")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
