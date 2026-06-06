#!/usr/bin/env python3
"""Translate German text in source-code comments under components/ to English.

Uses phrase and safe technical-term replacements only (no short German
articles/prepositions) to avoid corrupting words like 'vorkommenden'.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2] / "components"

EXTENSIONS = {
    ".c",
    ".h",
    ".cpp",
    ".java",
    ".pl",
    ".tcl",
    ".py",
    ".sh",
    ".y",
    ".l",
    ".yy",
    ".swi.pl",
}

SKIP_DIRS = {"build", ".git", "node_modules", "target", "generated"}

PHRASES: list[tuple[str, str]] = [
    ("Server-Struktur zur Kommunikation mit der C-Library", "Server structure for communication with the C library"),
    ("Inhalt des Tokens nach einem Fehler", "content of the token after an error"),
    ("einen Select-expression oder einfachen id", "a select expression or simple id"),
    ("Speichert die Methode und Argumente einer Ipcmessage in dem", "Stores the method and arguments of an IPC message in the"),
    ("die ipcmessage die gespeichert werden soll", "the IPC message to be stored"),
    ("Die Information wird fuer OB.log", "The information is needed for OB.log"),
    ("benoetigt und spaeter (nach der TA) geschrieben", "needed and written later (after the TA)"),
    ("Konkateniert eine Liste von Pointern (auf Strings) und Atomen", "Concatenates a list of pointers (to strings) and atoms"),
    ("zusammen zu einer Liste. Sublistenelem. werden durch Komma", "into one list. Sublist elements are separated by commas"),
    ("Zusammengebautes Atom aus Plist", "Atom assembled from plist"),
    ("Liste von Pointern und Atomen", "list of pointers and atoms"),
    ("lokale Hilfsfunktion, die in einer Liste von Literalen", "local helper function that, in a list of literals"),
    ("Sucht in einer Liste von OIDs das groesste Objekt heraus", "Finds the largest object in a list of OIDs"),
    ("Sucht in einer Liste von OIDs das kleinste Objekt heraus", "Finds the smallest object in a list of OIDs"),
    ("Wahr, wenn _c ein Zeichen ist, das in einem Identifier vorkommen kann", "True when _c is a character that may occur in an identifier"),
    ("(wird von replace_scope_res_in_assertion benutzt)", "(used by replace_scope_res_in_assertion)"),
    ("splitatom ist *nicht* Suffix von", "splitatom is *not* a suffix of"),
    ("oder Prefix von part2", "or a prefix of part2"),
    ("mit modus  wird in MetaBDMEvaluation geprueft,", "with modus, MetaBDMEvaluation checks"),
    ("ob man sich in einer Tell oder Ask", "whether one is in a tell or ask"),
    ("fuer Metaformeln nicht geprueft zu werden.", "that meta formulas are not checked."),
    ("Frueher wurde diese Ersetzung schon beim Parsen durchgefuehrt. Ist jedoch", "Previously this replacement was already done during parsing. However"),
    ("bestimmt werden. Deswegen wurde ein Praedikat AToAdot eingefuehrt, welches", "be determined. Therefore a predicate AToAdot was introduced, which"),
    ("Hier soll zuerst cancelMe ausfuehren und dann informiert javaserver zu close the connection.", "Here cancelMe should run first, then javaserver is notified to close the connection."),
    ("gilt auch fuer []", "also applies to []"),
    ("speichern der beim parsen erzeugten Variablentabelle", "store the variable table produced by the parser"),
    ("Fan-Outs des Literals lit mit Belegungsmuster ad", "fan-outs of literal lit with binding pattern ad"),
    ("Informationen aus der Variablentabelle Beruecksichtigung", "taking the variable table into account"),
    ("eine Variablentabelle angelegt, in der zu", "a variable table is created in which"),
    ("ist die Variablentabelle bereits angelegt, dann", "if the variable table is already created, then"),
    ("initialisieren der Variablentabelle", "initialize the variable table"),
    ("in die Variablentabelle aufgenommen", "added to the variable table"),
    ("damit System keinen unendlichen loop erzeugt.", "so the system does not create an infinite loop."),
    ("ueberpruefe fuer untell ob temporaere export attribute existieren", "check for untell whether temporary export attributes exist"),
    ("fuehre Axiomueberpruefung nach und nach fuer jedes Modul durch", "run axiom checking module by module"),
    ("Durch Backtracking wird is_specialization_of immer wieder aufgerufen und immer", "Through backtracking is_specialization_of is called repeatedly and always"),
    ("liefert was aus, wegen Zykel. Deshalb wird IsA_3 vorausgezetzt fuer IsA_4.", "returns something because of a cycle. Therefore IsA_3 is assumed for IsA_4."),
    ("hier wird das \"this\" genommen", "here \"this\" is taken"),
    ("Wandelt die Antwortmenge eines Views in das fuer Client-", "Converts the answer set of a view into the client-"),
    ("Bei der Transformation koennen attrdeclaration mit leerer", "During transformation, attrdeclaration with empty"),
    ("Die externen Quellen konnten ein anderes Syntax haben", "External sources could use different syntax"),
    ("wenn einige Sonderzeichenen in 'Label' vorkommen", "when special characters occur in 'Label'"),
    ("Bei Generieren der Regeln oder Ruleinfos werden Atom wie", "When generating rules or rule infos, atoms like"),
    ("dann wenn diese Labels ein Atom mit Hochkomma sind", "then when these labels are atoms with quotes"),
    ("1) wenn das Label in Kombinationen wie:", "1) when the label appears in combinations like:"),
    ("2) wenn das Label in Kombinationen wie:", "2) when the label appears in combinations like:"),
    ("ist es egal was die Labels ersetzt wird.", "it does not matter what the labels are replaced with."),
    ("/* Fuer die Faelle, dass die Kombinationen Ids sind.*/", "/* For cases where the combinations are IDs. */"),
    ("/*ID fuer diese Label schon generiert!*/", "/* ID for this label already generated! */"),
    ("/*Zuerstmal generieren eine ID fuer diese Label!*/", "/* First generate an ID for this label! */"),
    ("Aug-97/CQ, Element muessen identisch sein, sonst unerwuenschte Unifikation!", "Aug-97/CQ, elements must be identical, otherwise unwanted unification!"),
    ("ist ein name2id mit vorgegebenen Modulkontext (muss ground sein)", "is a name2id with a given module context (must be ground)"),
    ("kommen koennen)", "can occur)"),
    ("Eingabe:", "Input:"),
    ("Ausgabe:", "Output:"),
    ("Description of predicate:", "Description of predicate:"),
    ("Description of arguments:", "Description of arguments:"),
    ("wird in", "is placed in"),
    ("wird von", "is used by"),
    ("wird fuer", "is used for"),
    ("wird bei", "is applied when"),
    ("wird durch", "is performed by"),
    ("wird die", "the ... is"),
    ("wird das", "the ... is"),
    ("wird der", "the ... is"),
    ("wird ein", "a ... is"),
    ("wird eine", "a ... is"),
    ("wird nicht", "is not"),
    ("wird immer", "is always"),
    ("wird nun", "is now"),
    ("werden nicht", "are not"),
    ("werden hier", "are initialized here"),
    ("werden durch", "are separated by"),
    ("werden fuer", "are used for"),
    ("werden von", "are used by"),
    ("werden zu", "are combined into"),
    ("werden die", "the ... are"),
    ("wurde so", "was extended so"),
    ("wurde ein", "a ... was added"),
    ("wurde eine", "a ... was added"),
    ("wurde nun", "was now"),
    ("und dann", "and then"),
    ("und die", "and the"),
    ("und das", "and the"),
    ("und der", "and the"),
    ("und alle", "and all"),
    ("und wenn", "and when"),
    ("und nicht", "and not"),
    ("und zwar", "namely"),
    ("oder die", "or the"),
    ("oder der", "or the"),
    ("oder das", "or the"),
    ("oder ein", "or a"),
    ("oder eine", "or a"),
    ("nicht geprueft", "not checked"),
    ("nicht immer", "not always"),
    ("nicht nur", "not only"),
    ("nicht minimal", "not minimal"),
    ("nicht leer", "not empty"),
    ("nicht erlaubt", "not allowed"),
    ("nicht terminiert", "does not terminate"),
    ("nicht abfangen", "cannot be caught"),
    ("nicht auftauchen", "does not occur"),
    ("wenn moeglich", "if possible"),
    ("wenn ein", "when a"),
    ("wenn die", "when the"),
    ("wenn das", "when the"),
    ("wenn der", "when the"),
    ("wenn alle", "when all"),
    ("wenn nicht", "if not"),
    ("diese Labels", "these labels"),
    ("diese Regel", "this rule"),
    ("diese Liste", "this list"),
    ("dieser", "this"),
    ("diese", "this"),
    ("ist die", "is the"),
    ("ist ein", "is a"),
    ("ist eine", "is a"),
    ("ist der", "is the"),
    ("ist das", "is the"),
    ("ist nur", "is only"),
    ("ist egal", "does not matter"),
    ("ist nicht", "is not"),
    ("sind die", "are the"),
    ("sind nicht", "are not"),
    ("sind alle", "are all"),
    ("sind fuer", "are for"),
    ("Liste von", "list of"),
    ("Liste der", "list of the"),
    ("Liste mit", "list with"),
    ("Liste aller", "list of all"),
    ("Eingabe:", "Input:"),
    ("Ausgabe:", "Output:"),
    ("fuer jedes", "for each"),
    ("fuer jede", "for each"),
    ("fuer jeden", "for each"),
    ("fuer alle", "for all"),
    ("fuer die", "for the"),
    ("fuer das", "for the"),
    ("fuer den", "for the"),
    ("fuer eine", "for a"),
    ("fuer ein", "for a"),
    ("fuer OB.log", "for OB.log"),
    ("fuer Metaformeln", "for meta formulas"),
    ("fuer View", "for view"),
    ("fuer Regeln", "for rules"),
    ("fuer IpcParser", "for IpcParser"),
    ("fuer list_dir", "for list_dir"),
    ("fuer updateGlobalCounters", "for updateGlobalCounters"),
    ("fuer den Attributwert", "for the attribute value"),
    ("fuer eine", "for a"),
    ("fuer ein", "for a"),
    ("nach der", "after the"),
    ("nach dem", "after the"),
    ("nach einem", "after a"),
    ("vor dem", "before the"),
]

# Single-word replacements (word boundaries only), applied after phrases.
SINGLE_WORDS: list[tuple[str, str]] = [
    ("wurde", "was"),
    ("wurden", "were"),
    ("werden", "are"),
    ("wird", "is"),
    ("fuer", "for"),
    ("Fuer", "For"),
    ("und", "and"),
    ("oder", "or"),
    ("nicht", "not"),
    ("wenn", "when"),
    ("auch", "also"),
    ("noch", "still"),
    ("nur", "only"),
    ("schon", "already"),
    ("alle", "all"),
    ("jede", "each"),
    ("jedes", "each"),
    ("jeder", "each"),
    ("sind", "are"),
    ("ist", "is"),
    ("soll", "shall"),
    ("kann", "can"),
    ("muss", "must"),
    ("ohne", "without"),
    ("bei", "when"),
    ("bis", "until"),
]

# Safe terms: length >= 5 and unlikely to match inside English words.
SAFE_TERMS: list[tuple[str, str]] = [
    ("Variablentabelle", "variable table"),
    ("Variablentabellen", "variable tables"),
    ("Literalsequenz", "literal sequence"),
    ("Literalliste", "literal list"),
    ("Regelmenge", "rule set"),
    ("Hilfsfunktion", "helper function"),
    ("Modulkontext", "module context"),
    ("Modulaenderungen", "module changes"),
    ("Fehlermeldung", "error message"),
    ("Fehlerbehandlung", "error handling"),
    ("Praedikat", "predicate"),
    ("Praedikate", "predicates"),
    ("Belegungsmuster", "binding pattern"),
    ("Belegungsmuster", "binding pattern"),
    ("Beruecksichtigung", "consideration"),
    ("Zusammengebautes", "Assembled"),
    ("Sublistenelem.", "Sublist elements"),
    ("Antwortmenge", "answer set"),
    ("Axiomueberpruefung", "axiom checking"),
    ("attrdeclaration", "attrdeclaration"),
    ("intensional", "intensional"),
    ("Groesstes", "Largest"),
    ("groesstes", "largest"),
    ("groesste", "largest"),
    ("kleinste", "smallest"),
    ("Konkateniert", "Concatenates"),
    ("konkateniert", "concatenates"),
    ("Speichert", "Stores"),
    ("speichert", "stores"),
    ("Schreibt", "Writes"),
    ("schreibt", "writes"),
    ("Sucht", "Searches"),
    ("sucht", "searches"),
    ("Initialisierung", "initialization"),
    ("Rueckgabe", "return value"),
    ("Kopfliteral", "head literal"),
    ("Fixpunkt", "fixpoint"),
    ("allquantifiziert", "universally quantified"),
    ("allquantifizierte", "universally quantified"),
    ("Existenzquantor", "existential quantifier"),
    ("Quantifizierungen", "quantifications"),
    ("Quantifizierung", "quantification"),
    ("Generalisierung", "generalization"),
    ("Spezialisierung", "specialization"),
    ("SourceKlasse", "source class"),
    ("Source-Klasse", "source class"),
    ("Dest-Klasse", "destination class"),
    ("durchgefuehrt", "performed"),
    ("durchgefuehrte", "performed"),
    ("eingefuehrt", "introduced"),
    ("eingebaut", "built in"),
    ("ueberprueft", "checked"),
    ("ueberpruefe", "check"),
    ("ueberpruefen", "check"),
    ("geprueft", "checked"),
    ("benoetigt", "needed"),
    ("benoetigten", "needed"),
    ("benoetigt werden", "are needed"),
    ("ausfuehren", "execute"),
    ("ausfuehrt", "executes"),
    ("ausgewertet", "evaluated"),
    ("erzeugt", "generated"),
    ("erzeugten", "generated"),
    ("erzeugen", "generate"),
    ("erweitert", "extended"),
    ("entfernt", "removed"),
    ("entfernen", "remove"),
    ("entfaellt", "is omitted"),
    ("ersetzt", "replaced"),
    ("ersetzen", "replace"),
    ("ersetzung", "replacement"),
    ("Ersetzung", "replacement"),
    ("abgespeichert", "stored"),
    ("gespeichert", "stored"),
    ("gespeicherten", "stored"),
    ("geschrieben", "written"),
    ("angelegt", "created"),
    ("angelegten", "created"),
    ("angelegte", "created"),
    ("aufgenommen", "added"),
    ("aufloest", "dissolves"),
    ("getrennt", "separated"),
    ("zusaetzlich", "additionally"),
    ("vollstaendig", "complete"),
    ("vollstaendige", "complete"),
    ("vollstaendigen", "complete"),
    ("temporaere", "temporary"),
    ("temporaeren", "temporary"),
    ("temporaer", "temporary"),
    ("permanent gemacht", "made permanent"),
    ("inkrementell", "incrementally"),
    ("geaendert", "changed"),
    ("veraendert", "changed"),
    ("unerwuenschte", "unwanted"),
    ("identisch", "identical"),
    ("Ansonsten", "Otherwise"),
    ("ansonsten", "otherwise"),
    ("Aehnlich", "Similar"),
    ("aehnlich", "similar"),
    ("Analog", "Analogous"),
    ("analog", "analogous"),
    ("Frueher", "Previously"),
    ("frueher", "previously"),
    ("Deswegen", "Therefore"),
    ("deswegen", "therefore"),
    ("Deshalb", "Therefore"),
    ("deshalb", "therefore"),
    ("jedoch", "however"),
    ("leider", "unfortunately"),
    ("nirgendwo", "nowhere"),
    ("immer wieder", "repeatedly"),
    ("immer", "always"),
    ("wieder", "again"),
    ("bereits", "already"),
    ("zuerst", "first"),
    ("spaeter", "later"),
    ("zusammen", "together"),
    ("schrittweise", "stepwise"),
    ("zusaetzlich", "additionally"),
    ("betroffen", "affected"),
    ("betroffenen", "affected"),
    ("betroffene", "affected"),
    ("eingehen", "apply"),
    ("koennen", "can"),
    ("koennte", "could"),
    ("koennten", "could"),
    ("muessen", "must"),
    ("muesste", "should"),
    ("duerfen", "may"),
    ("sollen", "shall"),
    ("duerfen erst dann", "may only"),
    ("sollte", "should"),
    ("definiertern", "defined"),
    ("definierten", "defined"),
    ("generierten", "generated"),
    ("generiert", "generated"),
    ("generieren", "generate"),
    ("konstruiert", "constructed"),
    ("konstruieren", "construct"),
    ("enthaelt", "contains"),
    ("enthalten", "contain"),
    ("verblieben", "remaining"),
    ("verbliebene", "remaining"),
    ("redundante", "redundant"),
    ("reduziert", "reduced"),
    ("reduzierte", "reduced"),
    ("bestimmt", "determined"),
    ("bestimmen", "determine"),
    ("bestimmten", "certain"),
    ("bestimmte", "certain"),
    ("speziellste", "most specific"),
    ("speziellsten", "most specific"),
    ("abschliessende", "stratified"),
    ("Sonderzeichenen", "special characters"),
    ("Hochkomma", "quotes"),
    ("Hochkommas", "quotes"),
    ("Kombinationen", "combinations"),
    ("Kombination", "combination"),
    ("Variablen", "variables"),
    ("Variable", "variable"),
    ("Konstanten", "constants"),
    ("Konstante", "constant"),
    ("Literale", "literals"),
    ("Literal", "literal"),
    ("Argumente", "arguments"),
    ("Argument", "argument"),
    ("Attribut", "attribute"),
    ("Attribute", "attributes"),
    ("Methode", "method"),
    ("Methoden", "methods"),
    ("Funktion", "function"),
    ("Prozedur", "procedure"),
    ("Struktur", "structure"),
    ("Speicher", "memory"),
    ("Zeiger", "pointer"),
    ("Verzeichnis", "directory"),
    ("Datei", "file"),
    ("Dateien", "files"),
    ("Fehler", "error"),
    ("Objekt", "object"),
    ("Objekte", "objects"),
    ("Klasse", "class"),
    ("Klassen", "classes"),
    ("Liste", "list"),
    ("Listen", "lists"),
    ("Wert", "value"),
    ("Werte", "values"),
    ("Maske", "mask"),
    ("Masken", "masks"),
    ("Position", "position"),
    ("Rumpf", "body"),
    ("Kopf", "head"),
    ("Wahr", "True"),
    ("wahr", "true"),
    ("gilt", "applies"),
    ("damit", "so that"),
    ("hier", "here"),
    ("dort", "there"),
    ("falls", "if"),
    ("Fall", "case"),
    ("Faelle", "cases"),
    ("Fuer", "For"),
    ("fuer", "for"),
    ("benutzt", "used"),
    ("benutze", "use"),
    ("benutzen", "use"),
    ("Kommunikation", "communication"),
    ("Parsen", "parsing"),
    ("Ersetzung", "replacement"),
    ("Losungen", "solutions"),
    ("gemaess", "according to"),
    ("Warum", "Why"),
    ("schwachen", "weak"),
    ("uebersetzt", "translated"),
    ("ueber", "about"),
    ("Ueber", "About"),
    ("Angaben", "specifications"),
    ("vorkommenden", "occurring"),
    ("vorkommen", "occur"),
    ("vorkommt", "occurs"),
    ("getrennt waren", "were separated"),
]

GERMAN_HINT = re.compile(
    r"(ü|ä|ö|ß|Ü|Ä|Ö|"
    r"\b(fuer|Fuer|wird|werden|wurde|wurden|nicht|und|oder|wenn|diese|dieser|"
    r"Liste|Eingabe|Ausgabe|Funktion|Hilfsfunktion|Speichert|Konkateniert|"
    r"Praedikat|benoetigt|geprueft|erzeugt|Literale|Variablen|Konstanten|"
    r"Struktur|Kommunikation|Fehler|Methode|Klasse|Objekt|Attribut|"
    r"Schreibt|Sucht|Wahr|Fixpunkt|Regelmenge|Modul|groesst|klein|"
    r"benutzt|ersetzt|entfernt|koennen|muessen|duerfen|Variablentabelle|"
    r"Frueher|durchgefuehrt|eingefuehrt|Zusammengebautes|getrennt|"
    r"Belegungsmuster|Beruecksichtigung|Modulaenderungen)\b)",
    re.IGNORECASE,
)


def is_comment_line(line: str, in_block: bool) -> bool:
    stripped = line.lstrip()
    if in_block:
        return True
    if stripped.startswith("//"):
        return True
    if stripped.startswith("/*"):
        return True
    if stripped.startswith("*") and not stripped.startswith("**"):
        return True
    if stripped.startswith("%"):
        return True
    return False


def translate_text(text: str) -> str:
    out = text
    for de, en in PHRASES:
        out = out.replace(de, en)
    for de, en in sorted(SAFE_TERMS, key=lambda x: -len(x[0])):
        out = re.sub(rf"\b{re.escape(de)}\b", en, out)
    for de, en in SINGLE_WORDS:
        out = re.sub(rf"\b{re.escape(de)}\b", en, out)
    return out


def process_line(line: str) -> str:
    if not GERMAN_HINT.search(line):
        return line

    m = re.match(r"^(\s*)(/\*+|//|%|\*?)(.*)$", line)
    if not m:
        m2 = re.match(r"^(\s*)(.*)$", line)
        if not m2:
            return line
        prefix, body = m2.group(1), m2.group(2)
        if not GERMAN_HINT.search(body):
            return line
        translated = translate_text(body)
        return prefix + translated + ("\n" if line.endswith("\n") else "")

    prefix, marker, body = m.group(1), m.group(2), m.group(3)
    suffix = ""
    if body.rstrip().endswith("*/"):
        body = body.rstrip()[:-2].rstrip()
        suffix = " */"
    translated = translate_text(body)
    newline = "\n" if line.endswith("\n") else ""
    return f"{prefix}{marker}{translated}{suffix}{newline}"


def process_file(path: Path) -> bool:
    text = path.read_text(encoding="latin-1", errors="replace")
    lines = text.splitlines(keepends=True)
    in_block = False
    changed = False
    out_lines: list[str] = []

    for line in lines:
        stripped = line.lstrip()
        if "/*" in stripped and "*/" not in stripped:
            in_block = True
        if is_comment_line(line, in_block) and GERMAN_HINT.search(line):
            new_line = process_line(line)
            if new_line != line:
                changed = True
            out_lines.append(new_line)
        else:
            out_lines.append(line)
        if in_block and "*/" in stripped:
            in_block = False

    if changed:
        path.write_text("".join(out_lines), encoding="latin-1")
    return changed


def main() -> int:
    root = Path(sys.argv[1]) if len(sys.argv) > 1 else ROOT
    changed_files = 0
    for path in sorted(root.rglob("*")):
        if not path.is_file():
            continue
        if any(part in SKIP_DIRS for part in path.parts):
            continue
        if path.suffix not in EXTENSIONS and not path.name.endswith(".swi.pl"):
            continue
        if process_file(path):
            print(path.relative_to(root))
            changed_files += 1
    print(f"updated {changed_files} files under {root}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
