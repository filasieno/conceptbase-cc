#!/usr/bin/env python3
"""Migrate ConceptBase.cc LaTeX manuals from archive to Typst under components/doc/."""

from __future__ import annotations

import argparse
import re
import shutil
import subprocess
import sys
from pathlib import Path

ARCHIVE_DOC = Path(__file__).resolve().parents[1] / "archive/2026-06-06-wip/ProductPOOL/doc"
OUT_ROOT = Path(__file__).resolve().parents[1] / "components/doc"

MANUALS = {
    "user-manual": {
        "archive_dir": "UserManual",
        "main_tex": "CB-Manual.tex",
        "title_typ": "title.typ",
        "document_title": "ConceptBase.cc User Manual",
        "version": "8.5",
        "date": "2026-04-26",
    },
    "prog-manual": {
        "archive_dir": "ProgManual",
        "main_tex": "ProgManual.tex",
        "title_typ": "title.typ",
        "document_title": "ConceptBase.cc Programmer Manual",
        "version": "6.1",
        "date": "17-Jan-2003",
    },
    "tutorial": {
        "archive_dir": "Tutorial",
        "main_tex": "cbTutorial.tex",
        "title_typ": "title.typ",
        "document_title": "ConceptBase Tutorial",
        "version": "",
        "date": "2017-08-25",
        "extra_chapters": ["cbTutorial2.tex", "cbTutorial3.tex"],
        "monolithic_main": True,
    },
}


def read_tex(path: Path) -> str:
    return path.read_text(encoding="latin-1", errors="replace")


def parse_inputs(main_tex: Path) -> list[str]:
    text = read_tex(main_tex)
    body = re.search(r"\\begin\{document\}(.*)\\end\{document\}", text, re.S)
    if not body:
        return []
    content = body.group(1)
    chapters: list[str] = []
    for m in re.finditer(r"\\input\{([^}]+)\}", content):
        name = m.group(1).strip()
        if not name.endswith(".tex"):
            name += ".tex"
        if name not in chapters:
            chapters.append(name)
    extra = MANUALS.get("", {}).get("extra_chapters", [])
    for ch in MANUALS.get(main_tex.parent.name.lower(), {}).get("extra_chapters", []):
        if ch not in chapters:
            chapters.append(ch)
    return chapters


def parse_inputs_for_manual(archive_dir: Path, main_tex_name: str, manual_key: str) -> list[str]:
    main_tex = archive_dir / main_tex_name
    text = strip_latex_comments(read_tex(main_tex))
    body = re.search(r"\\begin\{document\}(.*)\\end\{document\}", text, re.S)
    if not body:
        return []
    content = body.group(1)
    chapters: list[str] = []
    for m in re.finditer(r"\\input\{([^}]+)\}", content):
        name = m.group(1).strip()
        if not name.endswith(".tex"):
            name += ".tex"
        if name not in chapters:
            chapters.append(name)
    for ch in MANUALS[manual_key].get("extra_chapters", []):
        if ch not in chapters:
            chapters.append(ch)
    return chapters


def replace_centerline(text: str) -> str:
    tag = r"\centerline{"
    out: list[str] = []
    i = 0
    while True:
        start = text.find(tag, i)
        if start < 0:
            out.append(text[i:])
            break
        out.append(text[i:start])
        j = start + len(tag)
        depth = 1
        while j < len(text) and depth:
            ch = text[j]
            if ch == "{":
                depth += 1
            elif ch == "}":
                depth -= 1
            j += 1
        inner = text[start + len(tag) : j - 1]
        out.append(f"\\begin{{center}}{inner}\\end{{center}}")
        i = j
    return "".join(out)


def unwrap_braced_macro(text: str, macro: str, label: str) -> str:
    """Expand \\macro{...} with nested braces into a quote block."""

    tag = f"\\{macro}{{"
    out: list[str] = []
    i = 0
    while True:
        start = text.find(tag, i)
        if start < 0:
            out.append(text[i:])
            break
        out.append(text[i:start])
        j = start + len(tag)
        depth = 1
        while j < len(text) and depth:
            ch = text[j]
            if ch == "{":
                depth += 1
            elif ch == "}":
                depth -= 1
            j += 1
        inner = text[start + len(tag) : j - 1]
        inner = re.sub(r"\\end\{description\}\}", r"\\end{description}", inner)
        out.append(f"\\textbf{{{label}:}}\\begin{{quote}}{inner}\\end{{quote}}")
        i = j
    return "".join(out)


def simplify_tabular_begin(text: str) -> str:
    """Replace \\begin{tabular}…{…} with a pandoc-friendly {ll} spec (nested braces)."""

    needle = r"\begin{tabular}"
    out: list[str] = []
    i = 0
    while True:
        start = text.find(needle, i)
        if start < 0:
            out.append(text[i:])
            break
        out.append(text[i:start])
        j = start + len(needle)
        # \begin{tabular}[t]{lp{0.5\textwidth}} — optional [..] then column {..}
        if j < len(text) and text[j] == "[":
            close = text.find("]", j)
            if close >= 0:
                j = close + 1
        if j < len(text) and text[j] == "{":
            depth = 0
            while j < len(text):
                ch = text[j]
                if ch == "{":
                    depth += 1
                elif ch == "}":
                    depth -= 1
                    if depth == 0:
                        j += 1
                        break
                j += 1
        out.append(r"\begin{tabular}{ll}")
        i = j
    return "".join(out)


def strip_latex_comments(text: str) -> str:
    lines = []
    for line in text.splitlines():
        out = []
        i = 0
        while i < len(line):
            if line[i] == "%" and (i == 0 or line[i - 1] != "\\"):
                break
            out.append(line[i])
            i += 1
        lines.append("".join(out))
    return "\n".join(lines)


def preprocess_tex(
    text: str,
    asset_subdir: str,
    relnr: str = "8.5",
    reldate: str = "2026-04-26",
    asset_root: Path | None = None,
) -> str:
    text = strip_latex_comments(text)

    assets_path = asset_root or Path(asset_subdir)
    text = cbfigure_repl(text, asset_subdir, assets_path)

    # Unwrap macros before stripping the extra `}` in `\end{description}}`.
    text = unwrap_braced_macro(text, "inputpar", "Input parameters")
    text = unwrap_braced_macro(text, "result", "Result")
    text = unwrap_braced_macro(text, "desc", "Description")

    # DOC++ / legacy markup leaves extra closing braces on common environments.
    text = re.sub(r"\\end\{description\}\}", r"\\end{description}", text)
    text = re.sub(r"\\end\{tabular\}\}", r"\\end{tabular}", text)
    text = re.sub(r"\\end\{itemize\}\}", r"\\end{itemize}", text)
    text = re.sub(r"\\end\{enumerate\}\}", r"\\end{enumerate}", text)

    replacements = [
        (r"\\relnr\b", relnr),
        (r"\\reldate\b", reldate),
        (r"\\Isa\b", r"\\textit{Isa}"),
        (r"\\In\b", r"\\textit{In}"),
        (r"\\ID\b", r"\\textrm{ID}"),
        (r"\\IN\b", r"\\textit{IN}"),
        (r"\\AL\b", r"\\textrm{AL}"),
        (r"\\OB\b", r"\\textrm{OB}"),
        (r"\\LABEL\b", r"\\textrm{LABEL}"),
        (r"\\cxxtilde", "~"),
        (r"\\longcom\{[^}]*\}", ""),
        (r"\\setcounter\{[^}]*\}\{[^}]*\}", ""),
        (r"\\tableofcontents\b", ""),
        (r"\\addcontentsline\{[^}]*\}\{[^}]*\}\{[^}]*\}", ""),
        (r"\\renewcommand\{\\bibname\}\{[^}]*\}", ""),
        (r"\\begin\{thebibliography\}\{[^}]*\}", ""),
        (r"\\end\{thebibliography\}", ""),
        (r"\\begin\{appendix\}", ""),
        (r"\\end\{appendix\}", ""),
        (r"\\vfill\b", ""),
        (r"\\vspace\{[^}]*\}", ""),
    ]
    text = replace_centerline(text)
    for pat, rep in replacements:
        text = re.sub(pat, rep, text)

    for env in [
        "cxxclass",
        "cxxfunction",
        "cxxunion",
        "cxxentry",
        "cxxnames",
        "cxxvariable",
        "method",
    ]:
        text = re.sub(rf"\\begin\{{{env}\}}(\[[^\]]*\])?(\[[^\]]*\])?(\[[^\]]*\])?(\[[^\]]*\])?(\[[^\]]*\])?", "", text)
        text = re.sub(rf"\\end\{{{env}\}}", "", text)

    text = re.sub(r"\\begin\{cxxdoc\}", r"\\begin{quote}\\textbf{Description:} ", text)
    text = re.sub(r"\\end\{cxxdoc\}", r"\\end{quote}", text)
    text = re.sub(r"\\begin\{example\}", r"\\begin{quote}\\itshape ", text)
    text = re.sub(r"\\end\{example\}", r"\\end{quote}", text)

    def axiom_repl(m: re.Match[str]) -> str:
        title = m.group(1)
        return rf"\paragraph{{{title}}}\begin{{quote}}"

    text = re.sub(r"\\begin\{axiom\}\{((?:[^{}]|\{[^{}]*\})*)\}", axiom_repl, text)
    text = re.sub(r"\\end\{axiom\}", r"\\end{quote}", text)

    text = re.sub(
        r"\\exobox\{([^}]*)\}\{((?:[^{}]|\{[^{}]*\})*)\}",
        r"\\begin{quote}\\textbf{\1:} \2\\end{quote}",
        text,
        flags=re.S,
    )

    text = re.sub(r"\\cxxParameter\{\s*", r"\\textbf{Parameters:}\n", text)
    text = re.sub(r"\\cxxReturn\{\s*", r"\\textbf{Returns:}\n", text)

    # { \it \begin{quote} ... \end{quote}} / {\scriptsize \begin{verbatim}...} wrappers
    text = re.sub(
        r"\{\\(?:it|em|bf|sl|sc|small|scriptsize|footnotesize)\s*\n?\\begin\{quote\}",
        r"\\begin{quote}",
        text,
    )
    text = re.sub(r"\\end\{quote\}\s*\n?\}", r"\\end{quote}", text)
    text = re.sub(r"\{\\it\s*\n", "", text)
    text = re.sub(r"\\end\{itemize\}\s*\n\}", r"\\end{itemize}", text)
    text = re.sub(r"\\end\{enumerate\}\s*\n\}", r"\\end{enumerate}", text)
    text = re.sub(
        r"\\end\{itemize\}\s*\n\s*\n\}",
        r"\\end{itemize}",
        text,
    )
    text = re.sub(r"\\\\\s*\n\}", r"\\\\", text)
    text = re.sub(r"\{\\bf Exercise[^}]*\}", lambda m: m.group(0).replace("{", "").replace("}", ""), text)
    text = re.sub(r"^\s*\}\s*$", "", text, flags=re.M)
    text = re.sub(
        r"\{\\(?:small|scriptsize|footnotesize)\s*\n?\\begin\{verbatim\}",
        r"\\begin{verbatim}",
        text,
    )
    text = re.sub(r"\\end\{verbatim\}\s*\n?\}", r"\\end{verbatim}", text)

    text = re.sub(r"^\s*\{[^}]*\}\s*$", "", text, flags=re.M)

    text = re.sub(r"\\begin\{latexonly\}", "", text)
    text = re.sub(r"\\end\{latexonly\}", "", text)
    text = re.sub(r"\\begin\{html\}", "", text)
    text = re.sub(r"\\end\{html\}", "", text)
    text = re.sub(r"\\strut\b", "", text)
    text = re.sub(r"\\end\{(\w+)\}\}", r"\\end{\1}", text)
    text = simplify_tabular_begin(text)
    text = re.sub(r"\\htmladdnormallink\{([^}]*)\}\{([^}]*)\}", r"\\url{\2}", text)

    # Prefer PNG assets; Typst does not read EPS.
    def img_repl(m: re.Match[str]) -> str:
        opts = (m.group(1) or "").strip("[]")
        name = m.group(2)
        stem = Path(name).stem
        ext = pick_asset_ext(assets_path, stem)
        if opts:
            return rf"\includegraphics[{opts}]{{{asset_subdir}/{stem}{ext}}}"
        return rf"\includegraphics{{{asset_subdir}/{stem}{ext}}}"

    text = re.sub(r"\\includegraphics(\[[^\]]*\])?\{([^}]+)\}", img_repl, text)

    return text


def cbfigure_repl(text: str, asset_subdir: str, assets_path: Path) -> str:
    tag = r"\cbfigure"
    out: list[str] = []
    i = 0
    while True:
        start = text.find(tag, i)
        if start < 0:
            out.append(text[i:])
            break
        out.append(text[i:start])
        pos = start + len(tag)

        def read_arg(pos: int) -> tuple[str, int]:
            if pos >= len(text) or text[pos] != "{":
                return "", pos
            pos += 1
            depth = 1
            begin = pos
            while pos < len(text) and depth:
                if text[pos] == "{":
                    depth += 1
                elif text[pos] == "}":
                    depth -= 1
                pos += 1
            return text[begin : pos - 1], pos

        path_arg, pos = read_arg(pos)
        width_arg, pos = read_arg(pos)
        caption_arg, pos = read_arg(pos)

        stem = Path(path_arg).stem
        ext = pick_asset_ext(assets_path, stem)
        out.append(
            f"\\begin{{figure}}\n"
            f"\\includegraphics[width={width_arg}]{{{asset_subdir}/{stem}{ext}}}\n"
            f"\\caption{{{caption_arg}}}\n"
            f"\\label{{fig:{stem}}}\n"
            f"\\end{{figure}}"
        )
        i = pos
    return "".join(out)


def aggressive_preprocess(tex_body: str) -> str:
    """Second-pass fixes for chapters that fail the LaTeX → Typst pandoc path."""

    def verbatim_block(m: re.Match[str]) -> str:
        body = m.group(1).strip("\n")
        return "\n\n\\begin{verbatim}\n" + body + "\n\\end{verbatim}\n\n"

    text = re.sub(r"\\begin\{verbatim\}(.*?)\\end\{verbatim\}", verbatim_block, tex_body, flags=re.S)
    text = re.sub(
        r"(?<!\\begin\{figure\}\n)(\\includegraphics(?:\[[^\]]*\])?\{[^}]+\})",
        r"\\begin{figure}\n\1\n\\end{figure}",
        text,
    )
    text = re.sub(r"\\fbox\{", r"\\begin{quote}", text)
    text = re.sub(r"\\begin\{minipage\}\{[^}]*\}", "", text)
    text = re.sub(r"\\end\{minipage\}", r"\\end{quote}", text)
    text = re.sub(r"\\footnote\{([^}]*)\}", r" (\1)", text)
    return text


def run_pandoc(tex_body: str, from_fmt: str = "latex", to_fmt: str = "typst") -> str:
    wrapper = (
        "\\documentclass{report}\n"
        "\\usepackage{graphicx}\n"
        "\\usepackage{hyperref}\n"
        "\\usepackage{url}\n"
        "\\usepackage{longtable}\n"
        "\\begin{document}\n"
        f"{tex_body}\n"
        "\\end{document}\n"
    )
    proc = subprocess.run(
        ["pandoc", f"-f{from_fmt}", f"-t{to_fmt}", "-"],
        input=wrapper if from_fmt == "latex" else tex_body,
        capture_output=True,
        text=True,
    )
    if proc.returncode != 0:
        raise RuntimeError(proc.stderr.strip() or "pandoc failed")
    return proc.stdout


def pandoc_by_sections(tex_body: str) -> str:
    """Fallback: convert each \\section chunk separately and concatenate."""

    chunks = re.split(r"(?=\\section\{)", tex_body)
    parts: list[str] = []
    for chunk in chunks:
        chunk = chunk.strip()
        if not chunk:
            continue
        try:
            parts.append(run_pandoc(aggressive_preprocess(chunk)))
        except RuntimeError:
            parts.append(f"// section conversion failed\n{chunk[:500]}\n")
    if not parts:
        raise RuntimeError("section fallback produced no output")
    return "\n\n".join(parts)


def pandoc_to_typst(tex_body: str) -> str:
    bodies = [tex_body, aggressive_preprocess(tex_body)]
    last_err = "pandoc failed"
    for body in bodies:
        try:
            return postprocess_typst(run_pandoc(body))
        except RuntimeError as exc:
            last_err = str(exc)
    try:
        return postprocess_typst(pandoc_by_sections(bodies[-1]))
    except RuntimeError:
        pass
    try:
        md = run_pandoc(bodies[-1], from_fmt="latex", to_fmt="markdown")
        return postprocess_typst(run_pandoc(md, from_fmt="markdown", to_fmt="typst"))
    except RuntimeError as exc:
        raise RuntimeError(last_err + " | markdown fallback: " + str(exc)) from exc


def postprocess_typst(text: str) -> str:
    text = re.sub(r"#emph\[([^\]]+)\]", r"_\1_", text)
    text = re.sub(r"#strong\[([^\]]+)\]", r"*\1*", text)
    text = re.sub(r"#link\(\"([^\"]+)\"\)\[([^\]]*)\]", r"#link(\"\1\")[\2]", text)
    # Chapter files live under */chapters/; assets sit in */assets/.
    text = re.sub(r'image\("assets/', r'image("../assets/', text)
    # Pandoc sometimes emits broken label()/ref() wrappers; keep readable text only.
    text = re.sub(r'#label\("[^"]*"\)', "", text)
    text = re.sub(r'label\("[^"]*"\)', "", text)
    # Cross-refs without bibliography entries → inline code (keeps @All83-style cites).
    text = re.sub(
        r"@((?:cha|sec|cap|fig):[\w-]+|<[\w:-]+>|[a-z][\w-]*)",
        r"`\1`",
        text,
    )
    text = text.replace("$CB_HOME", "`CB_HOME`")
    text = text.replace("```", "")
    text = re.sub(r"``([^`]+)`", r"\1", text)
    return text


def extract_bibliography(refs_tex: Path) -> str:
    text = read_tex(refs_tex)
    entries: list[tuple[str, str]] = []
    for m in re.finditer(r"\\bibitem(?:\[[^\]]*\])?\{([^}]+)\}(.*?)(?=\\bibitem|\\end\{thebibliography\})", text, re.S):
        key = m.group(1).strip()
        body = m.group(2).strip()
        body = re.sub(r"\\url\{([^}]+)\}", r"\1", body)
        body = re.sub(r"\\emph\{([^}]+)\}", r"\1", body)
        body = re.sub(r"\\textit\{([^}]+)\}", r"\1", body)
        body = re.sub(r"\\textbf\{([^}]+)\}", r"\1", body)
        body = re.sub(r"\\em\s+", "", body)
        body = re.sub(r"\\textit\{([^}]+)\}", r"\1", body)
        body = re.sub(r"\\textit\{([^}]+)\}", r"\1", body)
        body = re.sub(r"\\textit\{([^}]+)\}", r"\1", body)
        body = re.sub(r"\\\w+\b", "", body)
        body = re.sub(r"\{|\}", "", body)
        body = re.sub(r"\s+", " ", body).strip()
        entries.append((key, body))

    lines = ["# References bibliography (Hayagriva YAML)", ""]
    for key, body in entries:
        safe = body.replace("'", "''")
        lines.append(f"{key}:")
        lines.append("  type: misc")
        lines.append(f"  title: '{safe}'")
        lines.append("")
    return "\n".join(lines)


def write_title_typ(manual_key: str, out_dir: Path, cfg: dict) -> None:
    if manual_key == "user-manual":
        content = f'''#import "../lib/cb.typ": *

#align(center)[#image("assets/telos.png", width: 12cm)]
#v(1.5em)

#title-page(
  document-title: "{cfg["document_title"]}",
  version: "{cfg["version"]}",
  date: "{cfg["date"]}",
  author: "Manfred A. Jeusfeld (ed.)",
  affiliation: "University of Skövde, 54128 Skövde, Sweden",
  logo: none,
  abstract: [
    ConceptBase.cc (in short ConceptBase) is a multi-user deductive object manager
    intended for conceptual modeling, metamodeling, and coordination in design
    environments. The system implements O-Telos, a dialect of Telos integrating
    deductive and object-oriented paradigms.
  ],
)
'''
    elif manual_key == "prog-manual":
        content = f'''#import "../lib/cb.typ": *

#title-page(
  document-title: "{cfg["document_title"]}",
  version: "{cfg["version"]}",
  date: "{cfg["date"]}",
  author: "ConceptBase Team",
  affiliation: "",
  logo: none,
  abstract: [
    Programmer reference for ConceptBase.cc client APIs and server interfaces.
  ],
)
'''
    else:
        content = f'''#import "../lib/cb.typ": *

#title-page(
  document-title: "{cfg["document_title"]}",
  version: "",
  date: "",
  author: "René Soiron",
  affiliation: "",
  logo: none,
  abstract: [
    Step-by-step tutorial for ConceptBase.cc modeling, queries, rules, and constraints.
  ],
)
'''
    (out_dir / cfg["title_typ"]).write_text(content)


def write_main_typ(manual_key: str, out_dir: Path, chapters: list[str], cfg: dict) -> None:
    include_lines = []
    for ch in chapters:
        stem = Path(ch).stem
        if stem.lower() == "title":
            include_lines.append(f'#include "{cfg["title_typ"]}"')
        else:
            include_lines.append(f'#include "chapters/{stem}.typ"')

    bib_line = '  bibliography: "../references.yml",' if manual_key == "user-manual" else ""
    bib_include = (
        '\n#pagebreak()\n#bibliography("../references.yml", title: "References", style: "ieee")\n'
        if manual_key == "user-manual"
        else ""
    )
    content = f'''#import "../lib/cb.typ": *

#show: cb-doc.with(
  title: "{cfg["document_title"]}",
{bib_line}
)

{chr(10).join(include_lines)}
{bib_include}'''
    (out_dir / "main.typ").write_text(content)


def pick_asset_ext(out_assets: Path, stem: str) -> str:
    for ext in (".png", ".pdf", ".jpg", ".jpeg", ".svg"):
        if (out_assets / f"{stem}{ext}").exists():
            return ext
    return ".png"


def copy_assets(archive_dir: Path, out_assets: Path) -> None:
    out_assets.mkdir(parents=True, exist_ok=True)
    for src in archive_dir.iterdir():
        if src.suffix.lower() in {".png", ".pdf", ".jpg", ".jpeg", ".svg"}:
            shutil.copy2(src, out_assets / src.name)
        elif src.suffix.lower() == ".eps":
            png = src.with_suffix(".png")
            pdf = src.with_suffix(".pdf")
            if png.exists():
                shutil.copy2(png, out_assets / png.name)
            elif pdf.exists():
                shutil.copy2(pdf, out_assets / pdf.name)


def convert_chapter(
    tex_path: Path,
    out_path: Path,
    asset_subdir: str,
    relnr: str = "8.5",
    reldate: str = "2026-04-26",
    asset_root: Path | None = None,
) -> None:
    body = read_tex(tex_path)
    body = preprocess_tex(
        body, asset_subdir, relnr=relnr, reldate=reldate, asset_root=asset_root
    )
    typ = pandoc_to_typst(body)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(typ)


def migrate_manual(manual_key: str, archive_root: Path, out_root: Path) -> None:
    cfg = MANUALS[manual_key]
    archive_dir = archive_root / cfg["archive_dir"]
    out_dir = out_root / manual_key
    out_assets = out_dir / "assets"

    if out_dir.exists():
        shutil.rmtree(out_dir)
    out_dir.mkdir(parents=True)
    copy_assets(archive_dir, out_assets)

    chapters = parse_inputs_for_manual(archive_dir, cfg["main_tex"], manual_key)

    if cfg.get("monolithic_main"):
        main_stem = Path(cfg["main_tex"]).stem
        if main_stem + ".tex" not in chapters:
            chapters.insert(0, cfg["main_tex"])

    write_title_typ(manual_key, out_dir, cfg)

    for ch in chapters:
        if ch.lower() == "title.tex":
            continue
        src = archive_dir / ch
        if not src.exists():
            print(f"skip missing {src}", file=sys.stderr)
            continue
        dst = out_dir / "chapters" / f"{Path(ch).stem}.typ"
        try:
            if ch == cfg["main_tex"] and cfg.get("monolithic_main"):
                text = read_tex(src)
                body = re.search(r"\\begin\{document\}(.*)\\end\{document\}", text, re.S)
                if not body:
                    raise RuntimeError("no document body")
                body_text = body.group(1)
                body_text = re.sub(r"\\input\{[^}]+\}", "", body_text)
                body_text = re.sub(r"\\maketitle\b", "", body_text)
                body_text = preprocess_tex(
                    body_text,
                    "assets",
                    relnr=cfg.get("version", "8.5"),
                    reldate=cfg.get("date", "2026-04-26"),
                    asset_root=out_assets,
                )
                typ = pandoc_to_typst(body_text)
                dst.parent.mkdir(parents=True, exist_ok=True)
                dst.write_text(typ)
            else:
                convert_chapter(
                    src,
                    dst,
                    "assets",
                    relnr=cfg.get("version", "8.5"),
                    reldate=cfg.get("date", "2026-04-26"),
                    asset_root=out_assets,
                )
            print(f"converted {manual_key}/{ch}")
        except RuntimeError as exc:
            print(f"FAILED {ch}: {exc}", file=sys.stderr)
            dst.parent.mkdir(parents=True, exist_ok=True)
            dst.write_text(f"// pandoc failed for {ch}\n// {exc}\n")

    main_chapters = [c for c in chapters if c.lower() != "title.tex"]
    write_main_typ(manual_key, out_dir, ["title.tex"] + main_chapters, cfg)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--archive", type=Path, default=ARCHIVE_DOC)
    parser.add_argument("--out", type=Path, default=OUT_ROOT)
    args = parser.parse_args()

    if not shutil.which("pandoc"):
        print("pandoc not found in PATH", file=sys.stderr)
        return 1

    refs = args.archive / "UserManual" / "References.tex"
    if refs.exists():
        bib = extract_bibliography(refs)
        (args.out / "references.yml").write_text(bib)
        print(f"wrote references.yml ({bib.count('type:')} entries)")

    for key in MANUALS:
        migrate_manual(key, args.archive, args.out)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
