#!/usr/bin/env python3
"""Extract German comment sections from components/ into manifest + 20 batches."""

from __future__ import annotations

import json
import re
from pathlib import Path

REPO = Path(__file__).resolve().parents[3]
ROOT = REPO / "components"
OUT = Path(__file__).resolve().parent
SKIP = {"build", ".git", "node_modules", "target", "generated", "doc"}
EXT = {".c", ".h", ".cpp", ".java", ".pl", ".tcl", ".py", ".sh", ".yy", ".l", ".swi.pl"}

GERMAN = re.compile(
    r"(ü|ä|ö|ß|Ü|Ä|Ö|\\\"u|\\\"o|\\\"a|\\\"U|\\\"O|\\\"A|"
    r"L\\\"os|l\\\"os|f\\\"ur |k\\\"onnen|m\\\"ussen|w\\\"ahrend|G\\\"ult|"
    r"n\\\"ach|ge\\\"off|tr\\\"agt|zur\\\"uck|overfl\\\"ussig|"
    r"\b(fuer|Fuer|wird|werden|wurde|wurden|geprueft|benoetigt|erzeugt|Praedikat|"
    r"Praedikate|BDMPraedikat|Variablentabelle|koennen|muessen|duerfen|Integritaet|"
    r"Integritaets|Integritaetsbedingung|Integritaetstest|Formel|Identifikator|"
    r"Abspeichern|bzgl|gefunden|darstellt|bedingung|Modulkontext|groesst|benutzt|"
    r"ueber|Ueber|Frueher|durchgefuehrt|Hilfsfunktion|Speichert|Konkateniert|"
    r"Schreibt|Sucht|Wahr|Fixpunkt|Literale|Variablen|Konstanten|Struktur|"
    r"Kommunikation|Fehler|Methode|Klasse|Objekt|Attribut|Liste|Eingabe|Ausgabe|"
    r"vollstaendig|vollstaendige|zusaetzlich|Ansonsten|Aehnlich|getrennt|"
    r"Zusammengebautes|Belegungsmuster|Beruecksichtigung|Suchen|Verarbeiten|"
    r"Erstellen|Erkennen|Bedingung|Loesch|Loesung|Loesungen|auffuellen|"
    r"weitersuchen|bearbeitet|durchlaeuft|zurueck|zurueckgegeben|zurueckliefern|"
    r"zuruecksetzen|laesst|speichern|Ueberpruefung|Aendern|Aenderung|erfolgt|"
    r"gehoerige|Ergenbis|Erfolg|scheint|gilt|damit|fuehre|ueberpruefe|"
    r"aufgefuehrt|gestrichen|durchsuchende|einzelne|dieselbe|Quantifizierung|"
    r"vereinfachte|vereinfachten|Regelabhaengigkeit|Unterschied|geparsten|"
    r"Anfragestring|erstbeste|anonyme|steht|gilt auch|Durch Backtracking|"
    r"liefert|wegen|Zykel|Vorausgezetzt|Vorausgesetzt|vorausgesetzt|Metaformel|"
    r"MetaFormel|Klassenvariablen|enthaelt|ueberhaupt|Betrachtet|geeigneter|"
    r"Zeichenkette|taetsbedingung|Loeschoperation|Einfuegeoperation|Loeschen|"
    r"geloescht|Ausserdem|Schliesslich|zustaendig|Aufloesung|Heuristik|"
    r"Integritaetsueberpruefung|gef olgerten|gef olgerten|gesammelt|Behandlung|"
    r"zyklischen|Bezeichnung|Auswertung|Klausel|rekursiven|Integritaetsverletzung|"
    r"herleitbaren|uebernommen|uebergeben|zurueckgenommen|zurueckzuliefern|"
    r"Abhaengigkeitsgraphen|Abhaengigkeiten|Einfuege|Skriptdateien|"
    r"Integritaetscheck|funktionierte|alte method|not mehr|"
    r"not uebernommen|must deren|must vorher|must unter|are\.|"
    r"when dem|for VMrule|analog zu|Aenderungen|temperory|"
    r"Vorbereitende|Uebergabe|Speicherplatz|Objektbaum|Objekte|Objekt|"
    r"Regelkopf|Regelrumpf|Regelruempf|Regeln|Regel[^a-z]|Datalog-Regel|"
    r"Klassenbindung|Klassenvariable|Klassen[^a-z]|tatsaechlich|"
    r"Berechnungsergebnis|Anordnung|rekursive|vorbereitet|"
    r"Regelterm|Anfrageoptmierer|uebergebene|auftreten|verwendet are|"
    r"wieder frei|gibt den|"
    r"betrachtenen|Vorbehandlung|Compilieren|Auswerten|Untersuchen|Zerlegen|"
    r"Waehle|vollstaendigen|zusaetzlichen|Kopfliteral|Folgerungsliteral|"
    r"Bedingungsformel|eingegeben was|geachtet are|gebunden are|"
    r"zur Uebergabe|Objektspeichers|VMRegeln|deduktiven|Kategorie der|"
    r"eintragen zu|noch seperate|Und nun|und nun|noch zu|"
    r"aktuellen Regel|dieser Regel|eine Regel|der Regel|"
    r"ID der Regel|in deren|dazu die|Ist das object|"
    r"eventuell not|nach ganz innen|"
    r"hier |sollte |werdern |eingesetzt |merkwuerdig |muesste |dafuer |"
    r"repraesentiert |initialisiert |Optimierung |auftauchen |moeglich |"
    r"gemerkt |Rumpf |unschoener |Vorzeichen |zuordnet |ziemlich |"
    r"oeffentlich |gewaehlte |eingetragen |Fehlermeldungen |ignorieren |"
    r"Fallunterscheidung |integriert |entsprechende |normales |groesst |"
    r"Skriptdatei |Sichtenwartungsalgorithmus |Forschleife |Formelauswerter |"
    r"Wertebzgl |Bezug |gehaengt |oidsder |besitzt |berechnet |gestartet |"
    r"herausgeloescht |angegebene |betroffenen |"
    r"Nachschauen|waeren|koennten|benotigt|auftret|auflost|Milisekunden|Zwecke|"
    r"wurde benutzt|angezeigt|verarbeitet|beschaeftigen|ausschliesslich|"
    r"Abhaengigkeit|Einschraenkung|Folgerungsteil|deduktive|geschaffen|"
    r"spezialisierte|Vorgehen|Beachte|Gehen|Nicht mehr|gef olgerten|Skript|"
    r"Skriptdatei|Skriptfile|Interaktiver|funktioniert|Betriebssystems|"
    r"Bestimmung|Hier befinden|Das aktuelle|Die Instanzen|bezueglich|"
    r"analogous zu dem|Dieses predicate|Dabei is|already ein|"
    r"intosaetzliche|bzw\.|es handelt sich|Neues Special|zurueckgegeben|"
    r"geworfen are|the Instanz|angegebene|gehaengt is|Initialisiert the|"
    r"Suchmenge|Ber\\\"ucksichtigung|Komponente als|Datenbank heraus|"
    r"koennen|muessen|waehrend|naeuchstes|noetig|externe Quelle|"
    r"Integritaetsbedingung|Formelauswerter|Modulvererbungen)\b)",
    re.IGNORECASE,
)

FALSE_POSITIVE = re.compile(
    r"(stored are converted|"
    r"intensional costs w\.r\.t\. the head literal|"
    r"w\.r\.t\. the head literal|"
    r"w\.r\.t\. a head literal|"
    r"w\.r\.t\. the literal)",
    re.IGNORECASE,
)


def is_comment_line(line: str, in_block: bool) -> bool:
    s = line.lstrip()
    if in_block:
        return True
    return s.startswith(("//", "/*", "*", "%")) and not s.startswith("**")


def extract_sections() -> list[dict]:
    sections: list[dict] = []
    section_id = 0

    for path in sorted(ROOT.rglob("*")):
        if not path.is_file():
            continue
        if any(p in SKIP for p in path.parts):
            continue
        if path.suffix not in EXT and not path.name.endswith(".swi.pl"):
            continue
        text = path.read_text(encoding="latin-1", errors="replace")
        lines = text.splitlines()
        in_block = False
        current: dict | None = None

        def flush() -> None:
            nonlocal current, section_id
            if current and current["lines"]:
                section_id += 1
                current["id"] = f"S{section_id:05d}"
                sections.append(current)
            current = None

        rel = str(path.relative_to(REPO))
        for i, line in enumerate(lines, 1):
            stripped = line.lstrip()
            if "/*" in stripped and "*/" not in stripped:
                in_block = True
            is_c = is_comment_line(line, in_block)
            has_de = (
                bool(GERMAN.search(line)) and not FALSE_POSITIVE.search(line)
                if is_c
                else False
            )
            if is_c and has_de:
                if current is None:
                    current = {
                        "file": rel,
                        "start_line": i,
                        "end_line": i,
                        "lines": [],
                    }
                elif i == current["end_line"] + 1:
                    current["end_line"] = i
                else:
                    flush()
                    current = {
                        "file": rel,
                        "start_line": i,
                        "end_line": i,
                        "lines": [],
                    }
                current["lines"].append({"line": i, "original": line})
            elif current is not None and in_block:
                current["end_line"] = i
                current["lines"].append({"line": i, "original": line})
            elif current is not None:
                flush()
            if in_block and "*/" in stripped:
                in_block = False
        flush()

    return sections


def main() -> None:
    sections = extract_sections()
    OUT.mkdir(parents=True, exist_ok=True)

    manifest = OUT / "manifest.txt"
    with manifest.open("w", encoding="utf-8") as f:
        f.write(f"# German comment sections in components/ ({len(sections)} sections)\n")
        f.write("# Map-reduce translation manifest — do NOT use machine translation APIs.\n")
        f.write("# Format: SECTION_ID | file:start-end | L<line>: <original>\n\n")
        for s in sections:
            f.write(f"## {s['id']} | {s['file']}:{s['start_line']}-{s['end_line']}\n")
            for ln in s["lines"]:
                f.write(f"  L{ln['line']}: {ln['original']}\n")
            f.write("\n")

    num_agents = 20
    batches: list[list[dict]] = [[] for _ in range(num_agents)]
    for idx, s in enumerate(sections):
        batches[idx % num_agents].append(s)

    for i, batch in enumerate(batches):
        (OUT / f"batch-{i:02d}.json").write_text(
            json.dumps(batch, ensure_ascii=False, indent=2), encoding="utf-8"
        )

    summary = {
        "total_sections": len(sections),
        "total_lines": sum(len(s["lines"]) for s in sections),
        "files": len({s["file"] for s in sections}),
        "batches": num_agents,
        "manifest": str(manifest),
    }
    (OUT / "summary.json").write_text(json.dumps(summary, indent=2), encoding="utf-8")
    print(json.dumps(summary, indent=2))
    for i, b in enumerate(batches):
        print(f"batch-{i:02d}: {len(b)} sections, {sum(len(s['lines']) for s in b)} lines")


if __name__ == "__main__":
    main()
