#!/usr/bin/env python3
"""Re-translate libcbcos header comments from archive German originals."""

from __future__ import annotations

import re
from pathlib import Path

REPO = Path(__file__).resolve().parents[3]
ARCH = REPO / "archive/2026-06-06-wip/ProductPOOL/serverSources/C_Files/libCos"
DEST = REPO / "components/libcbcos/src"

PHRASES = [
    ("Anfrage an den Objektspeicher", "Query to the object store"),
    ("retrieve\\_propsition", "retrieve\\_proposition"),
    ("prove\\_literal-Anfrage", "prove\\_literal query"),
    ("erzeugt eine Instanz von QUERY", "creates an instance of QUERY"),
    ("Die Instanz ruft die Rechenvorschrift auf oder berechnet ggf. selber das Ergebnis",
     "The instance invokes the computation rule or may compute the result itself"),
    ("speichert die L\\\"osungen zwischen (bzw. eine Obermenge der L\\\"osungen) und stellt eine",
     "caches the solutions (or a superset) and provides a"),
    ("Methode zur Verf\\\"ugung, um diese L\\\"osungen einzeln abzurufen",
     "method to retrieve these solutions one by one"),
    ("Bisher gibt es 8 verschiedene QUERY-Childrens", "There are 8 different QUERY subclasses"),
    ("Sie unterscheiden sich im Grunde nur in der set-Methode",
     "They differ basically only in the set method"),
    ("Die einzige Ausnahme ist AQUERY, da hier ein L\\\"osungset zur\\\"uckgegeben wird, das nicht im",
     "The only exception is AQUERY, which returns a solution set that is not in the"),
    ("Objektspeicher ist, sondern neu erzeugt wurde", "object store but was newly created"),
    ("Hier sind noch eine mext-Methode (um die valid-\\\"uberpruefung",
     "It also has a next method (to skip validity checking"),
    ("zu verhindern) und ein Destructor (um den Speicher der L\\\"osung wieder freizugeben) hinzugekommen",
     ") and a destructor (to free the solution memory)"),
    ("Symboltabelle", "symbol table"),
    ("Die Symboltabelle speichert s\\\"amtliche Label-Eintr\\\"age ab, die in der Datenbank vorkommen",
     "The symbol table stores all label entries occurring in the database"),
    ("Jeder Eintrag hat zudem eine Indexmenge, in der die TOID's aufgelistet sind, die diesen",
     "Each entry also has an index set listing the TOIDs that use this"),
    ("Label benutzen", "label"),
    ("Flag das anzeigt, ob die Symboltabelle ge\\\"offnet ist", "flag indicating whether the symbol table is open"),
    ("Die Eigentliche Symbolmenge", "The actual symbol set"),
    ("Eine Hash-Tabelle, die zum Laden der Symboltabelle benutzt wird, um Symbolnummern",
     "A hash table used when loading the symbol table to map symbol numbers"),
    ("in SYMID's umzuwandeln. Die Hashtabelle wird nach dem Laden entfernt",
     "to SYMIDs. The hash table is removed after loading"),
    ("Menge der unbenutzten Eintr\\\"age - da die Eintr\\\"age jedoch unterschiedliche L\\\"ange",
     "set of unused entries - because entries have different lengths"),
    ("habe k\\\"onnen werden neue Labels immer hinten angeh\\\"angt",
     "new labels are always appended at the end"),
    ("Konstruktor", "Constructor"),
    ("\\\"oeffnet die Angegebene Datei als Symboltabelle", "opens the given file as symbol table"),
    ("initialistert die Symboltabelle - es fehlt noch ein Dateiname",
     "initializes the symbol table - filename still missing"),
    ("Destruktor", "Destructor"),
    ("L\\\"ad dieangegebene Datei als Symboltabelle", "loads the given file as symbol table"),
    ("l\\\"oscht die Hash-Tabelle", "deletes the hash table"),
    ("tr\\\"agt den TOID in die Menge der TOID's ein, die den Symboltabelleneintrag",
     "inserts the TOID into the set of TOIDs using symbol table entry"),
    ("Nr. id benutzen und gibt einen SYMID auf diesen Eintrag zur\\\"uck. Wird beim",
     "no. id and returns a SYMID for that entry. Used when"),
    ("Laden ben\\\"otigt", "loading"),
    ("Id des Symboltabelleneintrags (wie er im .telos-file steht)",
     "id of the symbol table entry (as in the .telos file)"),
    ("der TOID, der diesen Label benutzt", "TOID using this label"),
    ("R\\\"uckgabewert: SYMID zum Label-Id", "return value: SYMID for the label id"),
    ("tr\\\"agt toid in die Menge der TOID's ein, die symid benutzen",
     "inserts toid into the set of TOIDs using symid"),
    ("legt, falls n\\\"otig, einen neuen Eintrag an und gibt den zu label passenden SYMID zur\\\"uck",
     "creates a new entry if needed and returns the SYMID matching label"),
    ("L\\\"oscht toid aus den zum label geh\\\"orenden Eintrag, wird der Eintrag danach nicht mehr",
     "removes toid from the entry for label; if the entry is no longer"),
    ("benutzt wird der Eintrag gek\\\"oscht", "used it is deleted"),
    ("L\\\"oscht toid aus dem Eintrag SYMID, wird der Eintrag danach nicht mehr",
     "removes toid from SYMID entry; if no longer"),
    ("liefert den zu label geh\\\"orenden SYMID", "returns the SYMID for label"),
    ("kopiert den zu symid geh\\\"orenden Label nach label",
     "copies the label for symid into label"),
    ("der SYMID, dessen Label gesucht ist", "SYMID whose label is sought"),
    ("ein Feld das gro\\3 genug sein muss um den Label auzunehmen",
     "a field large enough to hold the label"),
    ("liefert die TOID-Menge der TOID's die den angegebenen Label benutzen",
     "returns the TOID set of TOIDs using the given label"),
    ("liefert die TOID-Menge der TOID's die den SYMID benutzen",
     "returns the TOID set of TOIDs using the SYMID"),
    ("liefert alle TOID's auf die der mit * angegebene Label pa\\3t",
     "returns all TOIDs matching the * label pattern"),
    ("benennt den Label von symid um. Ist der neue Label bereits in der Symboltabelle enthalten",
     "renames the label of symid. If the new label already exists in the symbol table"),
    ("schl\\\"agt die Operation fehl", "the operation fails"),
    ("Eine Instanz dieser Klasse ist eine vollst\\\"andige Telos-Datenbank",
     "An instance of this class is a complete Telos database"),
    ("Momentan sollte nur eine Instanz existieren", "Currently only one instance should exist"),
    ("Alle Anfragen von aussen an den Objektspeicher werden von dieser",
     "All external requests to the object store are handled by this"),
    ("Klasse bearbeitet", "class"),
    ("g\\\"ultig sein, um L\\\"osung der Anfrage zu sein",
     "valid to be a solution of the query"),
    ("this objects nachtr\\\"aglich regul\\\"ar eingetragen",
     "if this object is registered later regularly"),
    ("ist es nach tmp1 verschoben", "it is moved to tmp1"),
    ("Modul, in dem die L\\\"osung liegen soll", "module in which the solution should lie"),
    ("Flag, das angibt, ob Modulvererbungen beachtet werden sollen",
     "flag whether module inheritance should be considered"),
    ("Suchraum (akt, tmp, ....)", "search space (akt, tmp, ...)"),
    ("L\\\"osungsmenge", "solution set"),
    ("Suchzeitpunkt", "search time point"),
]

COMMENT_START = re.compile(r"^\s*(//|/\*\*?|\*|///)")


def translate_line(line: str) -> str:
    if not COMMENT_START.match(line) and "/*" not in line[:3]:
        return line
    prefix = line[: len(line) - len(line.lstrip())]
    body = line[len(prefix) :]
    for src, dst in sorted(PHRASES, key=lambda x: -len(x[0])):
        body = body.replace(src, dst)
    # generic umlaut escapes
    body = (
        body.replace('f\\"ur ', "for ")
        .replace('F\\"ur ', "For ")
        .replace('L\\"osung', "solution")
        .replace('l\\"oscht', "deletes")
        .replace('L\\"oscht', "Deletes")
        .replace('k\\"onnen', "can")
        .replace('m\\"ussen', "must")
        .replace('w\\"ahrend', "during")
        .replace('n\\"achste', "next")
        .replace('g\\"ultig', "valid")
        .replace('zur\\"uck', "back")
        .replace('ge\\"offnet', "open")
        .replace('ben\\"otigt', "needed")
        .replace('angeh\\"angt', "appended")
        .replace('gek\\"oscht', "deleted")
        .replace('R\\"uckgabewert', "return value")
        .replace('Verf\\"ugung', "use")
        .replace('vollst\\"andige', "complete")
        .replace('vollst\\"andig', "complete")
        .replace('nachtr\\"aglich', "subsequently")
        .replace('regul\\"ar', "regularly")
        .replace('über', "over")
        .replace('ä', "ae")
        .replace('ö', "oe")
        .replace('ü', "ue")
        .replace('ß', "ss")
    )
    # leftover German tokens
    for src, dst in [
        (" Die ", " The "), (" der ", " the "), (" die ", " the "), (" das ", " the "),
        (" den ", " the "), (" dem ", " the "), (" eine ", " a "), (" einer ", " a "),
        (" und ", " and "), (" oder ", " or "), (" nicht ", " not "), (" nur ", " only "),
        (" auch ", " also "), (" noch ", " still "), (" beim ", " when "),
        (" wird ", " is "), (" werden ", " are "), (" gibt ", " there are "),
        (" ist ", " is "), (" sind ", " are "), (" kann ", " can "),
        ("Jeder ", "Each "), ("Menge ", "set "), ("Eintrag", "entry"),
        ("Anzahl der", "number of"), ("benutzen", "use"),
        ("initialistert", "initializes"), ("Destruktor", "Destructor"),
        ("Anfrage", "query"), ("Objektspeicher", "object store"),
        ("Datenbank", "database"), ("Modul", "module"),
    ]:
        body = body.replace(src, dst)
    body = re.sub(r"\bthe the\b", "the", body)
    return prefix + body


def process_pair(name: str) -> int:
    dest = DEST / name
    if not dest.exists():
        return 0
    lines = dest.read_text(encoding="latin-1").splitlines()
    changed = 0
    out = []
    for line in lines:
        s = line.lstrip()
        if s.startswith(("//", "/*", "*", "///")) or "/**" in s:
            new = translate_line(line)
            if new != line:
                changed += 1
            out.append(new)
        else:
            out.append(line)
    dest.write_text("\n".join(out) + "\n", encoding="latin-1")
    return changed


def main() -> None:
    total = 0
    for path in sorted(DEST.glob("*.h")):
        n = process_pair(path.name)
        if n:
            print(f"{path.name}: {n} lines")
            total += n
    print(f"total {total}")


if __name__ == "__main__":
    main()
