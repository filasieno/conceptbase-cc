#!/usr/bin/env python3
"""Re-convert a LaTeX chapter from git sources section-by-section into Typst.

Uses the same pandoc + cleanup path as Examples.typ (section split fallback).
"""

from __future__ import annotations

import argparse
import importlib.util
import re
import subprocess
import sys
from pathlib import Path

TOOLS = Path(__file__).resolve().parent
REPO = TOOLS.parents[1]


def load_module(name: str, path: Path):
    spec = importlib.util.spec_from_file_location(name, path)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def strip_footnotes(text: str) -> str:
    out: list[str] = []
    i = 0
    tag = r"\footnote{"
    while i < len(text):
        start = text.find(tag, i)
        if start < 0:
            out.append(text[i:])
            break
        out.append(text[i:start])
        j = start + len(tag)
        depth = 1
        while j < len(text) and depth:
            if text[j] == "{":
                depth += 1
            elif text[j] == "}":
                depth -= 1
            j += 1
        note = text[start + len(tag) : j - 1].strip()
        out.append(f" ({note}) ")
        i = j
    return "".join(out)


def fix_extra(text: str) -> str:
    text = re.sub(r"\\begin\{center\}", "", text)
    text = re.sub(r"\\end\{center\}", "", text)
    text = re.sub(r"\\hline\b", "", text)
    text = re.sub(r"\\end\{description\}\}", r"\\end{description}", text)
    text = re.sub(r"\\end\{itemize\}\}+", r"\\end{itemize}", text)
    text = re.sub(r"\\end\{enumerate\}\}", r"\\end{enumerate}", text)
    text = re.sub(r"\\end\{tabular\}\}", r"\\end{tabular}", text)
    text = re.sub(r"^\s*\}\s*\\\\\s*$", "", text, flags=re.M)
    text = re.sub(
        r"(\\end\{tabular\})\s*(?=\\subsubsection|\\paragraph|\\subsection|\\section)",
        r"\1\n}",
        text,
    )
    if r"\begin{itemize}" not in text:
        text = re.sub(r"\\end\{itemize\}\s*", "", text)
    if r"\begin{enumerate}" not in text:
        text = re.sub(r"\\end\{enumerate\}\s*", "", text)
    text = re.sub(r"(\\end\{itemize\})\s*\n\s*\}\s*", r"\1\n", text)
    text = re.sub(r"(\\end\{enumerate\})\s*\n\s*\}\s*", r"\1\n", text)
    text = re.sub(r"^\s*\}\s*$", "", text, flags=re.M)
    text = re.sub(r"\\url\{([^}]+)\}\.\}", r"\\url{\1}.", text)
    return text


def brace_padding(text: str) -> str:
    """Closing braces for pandoc wrapper — ignore { } inside verbatim blocks."""

    parts = re.split(r"(\\begin\{verbatim\}.*?\\end\{verbatim\})", text, flags=re.S)
    nonverb = "".join(p for p in parts if not p.startswith(r"\begin{verbatim}"))
    diff = nonverb.count("{") - nonverb.count("}")
    return "}" * diff if diff > 0 else ""


def extract_body(tex: str) -> str:
    body = re.search(r"\\begin\{document\}(.*)\\end\{document\}", tex, re.S)
    if body:
        text = body.group(1)
    else:
        text = tex
    text = re.sub(r"\\input\{[^}]+\}", "", text)
    text = re.sub(r"\\maketitle\b", "", text)
    return text.strip()


def fix_code_fences(text: str) -> str:
    lines = text.splitlines()
    out: list[str] = []
    in_code = False
    code_buf: list[str] = []
    telos_start = re.compile(
        r'^(Class |Individual |Attribute |\{\[\*|"\(|Integer in |String in |Real in |QueryClass )'
    )
    for line in lines:
        s = line.strip()
        if s == "```":
            if in_code:
                code_buf.append(line)
                out.extend(code_buf)
                out.append("```")
                in_code = False
                code_buf = []
            else:
                in_code = True
                code_buf = ["```"]
            continue
        if in_code:
            code_buf.append(line)
            continue
        if telos_start.match(s):
            in_code = True
            code_buf = ["```", line]
            continue
        out.append(line)
    if in_code and code_buf:
        out.extend(code_buf)
        out.append("```")
    text = "\n".join(out)
    # Drop orphan closing fences (no matching opener in file order).
    lines = text.splitlines()
    depth = 0
    fixed: list[str] = []
    for line in lines:
        if line.strip() == "```":
            if depth == 0:
                fixed.append(line)
                depth = 1
            else:
                depth = 0
                fixed.append(line)
        else:
            fixed.append(line)
    if depth == 1:
        fixed = [ln for ln in fixed if ln.strip() != "```"] if fixed and fixed[-1].strip() == "```" else fixed
        if fixed and fixed[-1].strip() == "```":
            fixed.pop()
    text = "\n".join(fixed)
    text = re.sub(r"_([^_]+)_;", r"_\1_", text)
    return text


def convert_chunk(chunk: str, m, cleanup, assets: Path) -> str:
    pre = strip_footnotes(fix_extra(m.preprocess_tex(chunk, "assets", asset_root=assets)))
    pre = m.aggressive_preprocess(pre)
    pre = fix_extra(pre)
    wrapper = (
        "\\documentclass{report}\n"
        "\\usepackage{graphicx}\n"
        "\\usepackage{longtable}\n"
        "\\usepackage{hyperref}\n"
        "\\usepackage{url}\n"
        "\\usepackage{description}\n"
        "\\begin{document}\n"
        f"{pre}\n"
        "\\end{document}\n"
    )
    proc = subprocess.run(
        ["pandoc", "-flatex", "-ttypst", "-"],
        input=wrapper,
        capture_output=True,
        text=True,
    )
    if proc.returncode != 0:
        pad = brace_padding(pre)
        if pad:
            wrapper = wrapper.replace(
                f"{pre}\n\\end{{document}}",
                f"{pre}\n{pad}\n\\end{{document}}",
            )
            proc = subprocess.run(
                ["pandoc", "-flatex", "-ttypst", "-"],
                input=wrapper,
                capture_output=True,
                text=True,
            )
    if proc.returncode != 0:
        raise RuntimeError(proc.stderr[:600])
    return cleanup.convert_latex_to_typst(m.postprocess_typst(proc.stdout))


def convert_solutions_section(chunk: str, m, cleanup, assets: Path) -> str:
    """Solutions chapter is one big itemize list — convert per \\item."""

    if r"\begin{itemize}" not in chunk:
        return convert_chunk(chunk, m, cleanup, assets)

    header, rest = chunk.split(r"\begin{itemize}", 1)
    rest = rest.rsplit(r"\end{itemize}", 1)[0]
    parts = [convert_chunk(header.strip(), m, cleanup, assets)]
    items = [item.strip() for item in re.split(r"(?=\\item\s)", rest) if item.strip()]
    for item in items:
        try:
            parts.append(
                convert_chunk(
                    r"\begin{itemize}" + "\n" + item + "\n" + r"\end{itemize}",
                    m,
                    cleanup,
                    assets,
                )
            )
        except RuntimeError as e:
            print(f"    item FAIL: {item[:40]}: {e}")
    return "\n\n".join(parts)


def convert_section_chunk(chunk: str, m, cleanup, assets: Path) -> str:
    """Convert one \\section{...} block, splitting by \\subsection when needed."""

    title_m = re.search(r"\\section\{([^}]*)\}", chunk)
    if title_m and title_m.group(1).strip() == "Solutions to the Exercises":
        return convert_solutions_section(chunk, m, cleanup, assets)

    subs = re.split(r"(?=\\subsection\{)", chunk)
    if len(subs) <= 1:
        return convert_chunk(chunk, m, cleanup, assets)

    subparts: list[str] = []
    header = subs[0].strip()
    if header and not header.startswith(r"\subsection{"):
        try:
            subparts.append(convert_chunk(header, m, cleanup, assets))
        except RuntimeError as e:
            print(f"    header fail: {e}")

    for sub in subs[1:]:
        sub = sub.strip()
        if not sub:
            continue
        title_m = re.search(r"\\subsection\{([^}]*)\}", sub)
        title = title_m.group(1).strip() if title_m else sub[:40]
        try:
            subparts.append(convert_chunk(sub, m, cleanup, assets))
            print(f"    sub OK: {title}")
        except RuntimeError as e:
            # split large subsections at \\subsubsection
            subsubs = re.split(r"(?=\\subsubsection\{)", sub)
            if len(subsubs) <= 1:
                print(f"    sub FAIL: {title}: {e}")
                continue
            subsubparts: list[str] = []
            for ss in subsubs:
                ss = ss.strip()
                if not ss:
                    continue
                try:
                    subsubparts.append(convert_chunk(ss, m, cleanup, assets))
                    t2 = re.search(r"\\subsubsection\{([^}]*)\}", ss)
                    print(f"      subsub OK: {t2.group(1).strip() if t2 else ss[:35]}")
                except RuntimeError as e2:
                    print(f"      subsub FAIL: {e2}")
            if subsubparts:
                subparts.append("\n\n".join(subsubparts))

    if not subparts:
        raise RuntimeError(f"no content converted for section: {chunk[:80]}")
    return "\n\n".join(subparts)


def convert_sections(body: str, m, cleanup, assets: Path) -> str:
    parts: list[str] = []
    chunks = re.split(r"(?=\\section\{)", body)
    for chunk in chunks:
        chunk = chunk.strip()
        if not chunk:
            continue
        title_m = re.search(r"\\section\{([^}]*)\}", chunk)
        title = title_m.group(1).strip() if title_m else chunk[:40]
        try:
            parts.append(convert_section_chunk(chunk, m, cleanup, assets))
            print(f"  OK section: {title}")
        except RuntimeError as err:
            print(f"  FAIL section {title}: {err}")

    if not parts:
        raise RuntimeError("no sections converted")
    return fix_code_fences("\n\n".join(parts))


def reconvert(tex_path: Path, out_path: Path, assets: Path) -> None:
    m = load_module("migrate", TOOLS / "migrate-tex-to-typst.py")
    cleanup = load_module("cleanup", TOOLS / "cleanup-typst-latex.py")

    tex = m.read_tex(tex_path)
    body = extract_body(tex)
    body = fix_extra(m.preprocess_tex(body, "assets", asset_root=assets))

    print(f"converting {tex_path.name} -> {out_path.name}")
    typ = convert_sections(body, m, cleanup, assets)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(typ + "\n", encoding="utf-8")
    print(f"  wrote {out_path} ({typ.count(chr(10))} lines)")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("tex", type=Path, help="Source .tex file")
    parser.add_argument("out", type=Path, help="Destination .typ file")
    parser.add_argument(
        "--assets",
        type=Path,
        default=REPO / "components/doc/tutorial/assets",
        help="Asset directory for image resolution",
    )
    args = parser.parse_args()

    if not shutil_which("pandoc"):
        print("pandoc not found in PATH", file=sys.stderr)
        return 1

    reconvert(args.tex.resolve(), args.out.resolve(), args.assets.resolve())
    return 0


def shutil_which(cmd: str) -> str | None:
    from shutil import which

    return which(cmd)


if __name__ == "__main__":
    raise SystemExit(main())
