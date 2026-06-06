import os
import glob
import re

HOW_TO_DIR = "components/examples/HOW-TO"
OUT_FILE = "components/doc/how-to.typ"

def escape_typst(text):
    # Basic escaping for Typst
    text = text.replace('\\', '\\\\')
    text = text.replace('#', '\\#')
    text = text.replace('$', '\\$')
    text = text.replace('@', '\\@')
    text = text.replace('<', '\\<')
    text = text.replace('>', '\\>')
    text = text.replace('~', '\\~')
    return text

def main():
    if not os.path.exists(HOW_TO_DIR):
        print(f"Error: {HOW_TO_DIR} does not exist.")
        return

    directories = [d for d in os.listdir(HOW_TO_DIR) if os.path.isdir(os.path.join(HOW_TO_DIR, d))]
    directories.sort()

    with open(OUT_FILE, 'w', encoding='utf-8') as out:
        out.write("#set document(title: \"ConceptBase HOW-TO Guide\", author: \"The ConceptBase Team\")\n")
        out.write("#set page(paper: \"a4\", margin: (x: 2cm, y: 2.5cm))\n")
        out.write("#set text(font: \"New Computer Modern\", size: 11pt)\n")
        out.write("#set heading(numbering: \"1.1.\")\n\n")
        
        out.write("#align(center)[\n")
        out.write("  #text(size: 24pt, weight: \"bold\")[ConceptBase HOW-TO Guide]\n\n")
        out.write("  #v(1em)\n")
        out.write("  #text(size: 14pt)[A collection of tutorials, workflows, and examples]\n")
        out.write("]\n\n")
        out.write("#outline(indent: auto, depth: 2)\n\n")
        out.write("#pagebreak()\n\n")

        for d in directories:
            # Skip ZZ-Outdated or hidden
            if d.startswith("ZZ-") or d.startswith("."):
                continue

            out.write(f"= {escape_typst(d)}\n\n")
            
            dir_path = os.path.join(HOW_TO_DIR, d)
            
            # Find a readme
            readme_candidates = [f for f in os.listdir(dir_path) if 'readme' in f.lower() and f.endswith('.txt')]
            if readme_candidates:
                readme_path = os.path.join(dir_path, readme_candidates[0])
                with open(readme_path, 'r', encoding='utf-8', errors='replace') as r:
                    content = r.read()
                    out.write(f"```text\n{content}\n```\n\n")
            else:
                out.write("_(No README provided for this tutorial.)_\n\n")
                
            # List files
            files = [f for f in os.listdir(dir_path) if os.path.isfile(os.path.join(dir_path, f))]
            if files:
                out.write("== Associated Files\n")
                for f in files:
                    out.write(f"- `{escape_typst(f)}`\n")
                out.write("\n")

            out.write("#pagebreak()\n\n")

    print(f"Typst document generated at {OUT_FILE}")

if __name__ == "__main__":
    main()
