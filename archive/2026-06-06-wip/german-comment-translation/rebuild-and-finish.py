#!/usr/bin/env python3
"""Rebuild comment translations from all batch results + archive originals, then finish."""

from __future__ import annotations

import importlib.util
import json
import re
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[3]
OUT = Path(__file__).resolve().parent
ARCHIVE = REPO / "archive/2026-06-06-wip/ProductPOOL"
COMPONENTS = REPO / "components"

ARCHIVE_MAP = {
    "components/server-engine/src": ARCHIVE / "linux/serverSources/Prolog_Files",
    "components/libcbcos/src": ARCHIVE / "serverSources/C_Files/libCos",
    "components/libcbgeneral/src": ARCHIVE / "serverSources/C_Files/libGeneral",
    "components/libcbipc/src": ARCHIVE / "serverSources/C_Files/libIpc",
    "components/libcbtelos": ARCHIVE / "serverSources/C_Files/libTelos",
    "components/libcbtelosserver/src": ARCHIVE / "serverSources/C_Files/libTelosServer",
}

JAVADOC_PHRASES = [
    ("Initialisiert die Instanz als ", "Initializes the instance as a "),
    ("Initialisiert the Instanz als ", "Initializes the instance as a "),
    ("-Anfrage.", " query."),
    ("-Anfrage (", " query ("),
    ("-Anfrage.", " query."),
    ("Suchmenge", "search set"),
    ("Suchzeitpunkt", "search time point"),
    ("Suchmodul", "search module"),
    ('Ber\\"ucksichtigung von Modulvererbungen', "consideration of module inheritance"),
    ("Berücksichtigung von Modulvererbungen", "consideration of module inheritance"),
    ("Id-Komponente", "ID component"),
    ("Src-Komponente", "src component"),
    ("Dst-Komponente", "dst component"),
    ("Label-Komponente als SYMID", "label component as SYMID"),
    ("Label-Komponente als C-String", "label component as C string"),
    ("X-Komponente", "X component"),
    ("Y-Komponente", "Y component"),
    ("Meta-Label als SYMID", "meta-label as SYMID"),
    ("Metal-Label als C-String", "meta-label as C string"),
    ("Suchmuster", "search pattern"),
    ("Zeiger uf die Datenbank", "pointer to the database"),
    ("Zeiger uf the Datenbank", "pointer to the database"),
    ("Zeiger auf die Datenbank", "pointer to the database"),
    ("1. Komponente", "1st component"),
    ("2. Komponente", "2nd component"),
    ("FRAGE:", "QUESTION:"),
    ("ANTWORT:", "ANSWER:"),
    ("Warum kommt Adot ohne Zeiger auf die Datenbank aus?",
     "Why does Adot come without a pointer to the database?"),
    ("Warum kommt Adot ohne Zeiger auf the Datenbank aus?",
     "Why does Adot come without a pointer to the database?"),
    ("Alle Query-Methoden werden aus der Datenbank heraus",
     "All query methods are invoked from the database"),
    ("Alle Query-methods aus the Datenbank heraus", "All query methods are invoked from the database"),
    ("aufgerufen. Trans gibt die erzeugte Query an TDB weiter.",
     "Trans passes the created query on to TDB."),
    ("aufgerufen. Trans returns the erzeugte Query an TDB weiter.",
     "Trans passes the created query on to TDB."),
    ("kopiert denLabel in das angegebene char-Feld", "copies the label into the given char field"),
    ("kopiert denLabel in the angegebene char-Feld", "copies the label into the given char field"),
    ('Konstruktor: \\"oeffnet die Angegebene Datei als Symboltabelle',
     'Constructor: opens the given file as symbol table'),
    ('Konstruktor: \\"oeffnet the Angegebene Datei als Symboltabelle',
     'Constructor: opens the given file as symbol table'),
]

FINISH_PHRASES = [
    ("geworfen are.", "thrown."),
    ("geworfen are", "thrown"),
    ("sollte eine CBConnectionBrokenException", "a CBConnectionBrokenException should be"),
    ("(e.g. Server-Absturz) geworfen.", "(e.g. server crash) thrown."),
    ("Zeigt im TransactionTime-Feld die angegebene Zeit an",
     "Displays the given time in the TransactionTime field"),
    ("Zeigt im TransactionTime-Feld the angegebene Zeit an",
     "Displays the given time in the TransactionTime field"),
    ("Transaktionszeit in Millisekunden", "transaction time in milliseconds"),
    ("Ansonst the ... is solutions according to the angegebene Pattern transformiert.",
     "Otherwise the solutions are transformed according to the given pattern."),
    ("Die Bearbeitung the Prolog-Code-Erzeugung is placed in RuleBase erst after the Optimierung gemacht.",
     "Processing of Prolog code generation in RuleBase is done only after optimization."),
    ("stattdessen is here nach Datalog-Code-Erzeugung initDatalogRulesInfo gemacht.",
     "instead initDatalogRulesInfo is done here after Datalog code generation."),
    ("is performed by the angegebene predicate determined.",
     "is determined by the given predicate."),
    ("attribute gehaengt is(i).", "attribute is attached (i)."),
    ("speichere the ID's von System and Module zur spaeteren Optimierung in speziellen Fakten ab",
     "store the IDs of system and module for later optimization in special facts"),
    ("Fall 3: Normales Tell", "Case 3: normal tell"),
    ("_lastvar = object, the am Ende of the Select-Ausdrucks eingesetzt must",
     "_lastvar = object that must be used at the end of the select expression"),
    ("Dies sollte renameVar/5 actually tun", "This should actually be done by renameVar/5"),
    ("case 1c) forall-Quantor, mit einer class, without classesliste. Sollte man u.U. mit case 1a) verbinden.",
     "case 1c) forall quantifier with one class, without class list. Could be merged with case 1a)."),
    ("import/export Beziehungen in betroffenen Modulen sichtbar to do (siehe Technische Doku Modulserver)",
     "make import/export relations visible in affected modules (see module server technical documentation)"),
    ("Optimierung the replacement again rueckgaengig gemacht is.",
     "optimization has undone the replacement again."),
    ("Nach the Optimierung the ... is replacement", "After optimization the replacement is"),
    ("rest : Rest the Sliste, the not eingesetzt konnten",
     "rest: remainder of the S list that could not be inserted"),
    ("von build_xjoin eingesetzt worthe ist", "is used by build_xjoin"),
    ("_fq sollte ID sein, bringt aber Probleme beim Erzeugen von Prolog-Termen TL/7.94",
     "_fq should be ID, but causes problems when creating Prolog terms TL/7.94"),
    ("Form auf, then can when the Optimierung this", "form, then when optimization this"),
    ("sortRuleData is _ruleData nach the angegebene ruleId-Order(aus ruleCluster) sortiert!",
     "sortRuleData sorts _ruleData by the given ruleId order (from ruleCluster)!"),
    ("Falls object still not existiert, can ID still not eingesetzt are.",
     "If the object does not yet exist, the ID still cannot be inserted."),
    ("Prologcode-Erzeugung is after the Optimierung in RuleBase gemacht, here macht after the Compilierung only",
     "Prolog code generation is done after optimization in RuleBase; here after compilation only"),
    ("the Initialisierung von the Ruleinfos.(vgl. QueryCompiler.)",
     "the initialization of the rule infos is done. (cf. QueryCompiler.)"),
    ("Diese function should not ConceptBase Betrieb eingesetzt are.",
     "This function should not be used in ConceptBase operation."),
    ("@param system_mod the neue Systemmodul", "@param system_mod the new system module"),
    ("Initialisiert the durch toid angegebene object zu einem Modul-object. Erst dann",
     "Initializes the object given by toid as a module object. Only then"),
    ("can the object imports and exports verwalten.", "can the object manage imports and exports."),
    ("\\\"Ubernimmt the Daten aus tmp1 nach akt. tmp3 sollte dabei leer sein! Die",
     "Takes the data from tmp1 into akt. tmp3 should be empty! The"),
    ("Daten auf the Platte aktualisiert, i.e. the set is auf akt gesetzt.\\\\",
     "data on disk is updated, i.e. the set is set to akt.\\\\"),
    ("Irgendwo schwirren da still temp-flags rum - ein explizites Flag and the Endzeit,",
     "Some temp flags are still floating around somewhere - an explicit flag and the end time,"),
    ("MAL GENAU ANSEHEN.", "NEEDS CLOSE REVIEW."),
]

# ExternalConnection block — full English from archive German
EXTERNAL_CONNECTION_EN = """\
1) To communicate with the external data source server, the external JEB server must be started first.
	go to .../JEBserver, then start with runjava host port 	( host and port indicate where the CB server runs, e.g. warhol 4001)

2) First the external source must be defined in CB. Here the URL of the source and of the driver must be given.

Individual mainlibrary in ExternalDataSource with
  attribute,url
     eurl : "JEB-JDBC:twz1.jdbc.mysql.jdbcMysqlDriver:jdbc:z1MySQL://warhol:3306/mainlibrary"
  attribute,driver
     edriver : "i5.cb.jdbc.JEBJdbcDriver"
end

The driver attribute gives the URL of the driver to connect to; in this case the bridge between JEB and JDBC: JEBJdbcDriver.
The driver is loaded during connection setup. Then it tries to connect to the data source. The URL of the data source is
given in the url attribute. Often additional drivers are needed; their URLs are also given in url.
Generally this can have a form like: "Prefix:URLs of further drivers:URL of the data source".
E.g. JEB-JDBC:twz1.jdbc.mysql.jdbcMysqlDriver:jdbc:z1MySQL://warhol:3306/mainlibrary



During storage of this source definition the metadata from this source is also loaded. The metadata corresponds to the
schema definitions and is stored under ExternalObject. This information serves as entry points for the external data
to be loaded later.

e.g.:
Individual itemInmainlibrary in ExternalObject with
  attribute,field
     "author_name": LONGVARCHAR;
     "title" : LONGVARCHAR;
     "subject" : LONGVARCHAR
  attribute,key
     itemkey : "SET(NULL)"
  attribute,datasource
     EmployeeDatasource : mainlibrary
end

NOTE:
	1) To avoid possible name conflicts, all imported names in CB are designated as "external name" + "In" + "name of the source".
	e.g. for the table item in mainlibrary it is named itemInmainlibrary in CB.
	2) Because external sources may have different syntax than ours, all attributes are quoted with " ",
	so almost anything can be represented in CB.


3) Next external views can be constructed. An external view corresponds to a direct query to the external source.
It is specified by a source name and a query string.

Individual Author in ExternalQuery with
  attribute,datasource
     Adatasource : mainlibrary
  attribute,query
     tquery : "select author_name, title from item"
end

Here a view is constructed that should return all books with names and authors. One notices that the corresponding attributes
are missing! These are necessary, otherwise it would not be consistent to store the associated data (books with names and authors) under this
view.
This attribute extension is done automatically during view storage. The actual view in CB then looks as follows:

Individual Author in ExternalQuery with
  attribute,datasource
     Adatasource : mainlibrary
  attribute,query
     tquery : "select author_name, title from item"
  attriut, field
     "author_name" : LONGVARCHAR;
     "title" : LONGVARCHAR
end


To make view definition easier for users, generic external views are also provided.
These views contain parameterized query strings in which similar queries can be combined.
To use these, one only needs to give the name and the matching parameters.


Individual BookofAuthor in GenericExternalQuery with
  attribute,datasource
     Adatasource : mainlibrary
  attribute,query
     tquery : "select title from item where author_name=\\"[author]\\""
  attribute,parameter
     author : String
end



NOTE:
	1) " and \\ are special symbols and should be escaped with \\.
	2) Parameters are usually declared as String. The quotes are however automatically removed when parsing the query string,
	e.g. "select ... where salary=[x]" and x is "1000.0", then after parsing: "select...where salary=1000.0".
	If quotes in the query string are still needed, they must be embedded in the query string oneself, as in the example above.


4) Furthermore one can specify how these external objects (ExternalObject, ExternalQuery) should be loaded and stored.
Normally all external data is loaded into CB without integrity checking to reduce loading time. But if IC is necessary,
one can re-enable IC by specifying the check attribute of ExternalQuery or ExternalObject.
e.g.
itemInmainlibrary with
  check
	icheck: TRUE
end

Furthermore one notices that all external objects currently exist only virtually in CB, because all their instances still lie in
external sources. However this data may also have been materialized in CB beforehand in order to achieve fast evaluation.

itemInmainlibrary with
  store
	istore: TRUE
end

Using the store attribute of ExternalQuery and ExternalObject, one can specify whether instances should be materialized or not.
When store=True is set in CB, the associated instances are automatically imported from external sources and stored persistently in CB.


5) Queries:
After all metadata is imported and all ExternalQuery/GenericExternalQuery are defined, we can
query the external source main. A query can reference external objects (ExternalObject, ExternalQuery and GenericExternalQuery),
whose instances are either already materialized in CB or exist only virtually in CB. During query evaluation, if external
objects are affected and their instances are not yet imported into CB, they are then loaded from external sources and stored
short-term in CB.

Query with ExternalObject:

Aut1 in QueryClass isA String with
  attribute,computed_attribute
     title : String;
     subject: String
  attribute,constraint
     ac : $exists i/itemInmainlibrary A(i, "author_name", this) and A(i, "title", ~title) and A(i, "subject", ~subject)$
end

Query with ExternalQuery:

Aut2 in QueryClass isA String with
  attribute,computed_attribute
     title : String
  attribute,constraint
     ac : $exists a/Author A(a, "author_name", this) and A(a, "title", ~title)$
end

Query with GenericExternalQuery:

BookOfAut in QueryClass isA BookofAuthor["David Flanagan" / author] with
  attribute,retrieved_attribute
     "title" : VARCHAR
end


"""

LOCALCBCLIENT_BLOCK = """\
        /* Only IOException is thrown!
         * CBMessageException when the length of the response could not be read,
         *   the NumberException occurs in the Integer constructor.
         * CBTimeOutException is thrown when a timeout occurs,
         *   i.e. the server response did not arrive within a certain time.
         *   This is signaled by InterruptedIOException in the readLine method.
         *   However InterruptedIOException is also thrown on connection abort
         * (e.g. server crash). Then a CBConnectionBrokenException should be
         * thrown.
         * TODO: case distinction for this and RESET when ConnectionBroken
         **/
"""


def load_all_translations() -> dict[tuple[str, int], str]:
    """Map (relative_file, line_no) -> translated text from all batch results."""

    mapping: dict[tuple[str, int], str] = {}
    for path in sorted(OUT.rglob("batch-*-result.json")):
        data = json.loads(path.read_text(encoding="utf-8"))
        for section in data:
            rel = section["file"]
            for ln in section["lines"]:
                key = (rel, ln["line"])
                mapping[key] = ln.get("translated", ln["original"])
    return mapping


def archive_path(rel: str) -> Path | None:
    for prefix, base in ARCHIVE_MAP.items():
        if rel.startswith(prefix + "/"):
            name = rel[len(prefix) + 1 :]
            candidate = base / name
            if candidate.exists():
                return candidate
    return None


def translate_comment_line(line: str) -> str:
    prefix = line[: len(line) - len(line.lstrip())]
    body = line[len(prefix) :]
    for src, dst in JAVADOC_PHRASES + FINISH_PHRASES:
        body = body.replace(src, dst)
    # Residual common tokens (only when clearly German compound remains)
    tokens = [
        (" fuer ", " for "), (" f\"ur ", " for "), (" muessen ", " must "),
        (" koennen ", " can "), (" werden ", " are "), (" wird ", " is "),
        (" wurde ", " was "), (" die ", " the "), (" der ", " the "),
        (" das ", " the "), (" den ", " the "), (" dem ", " the "),
        (" eine ", " a "), (" einer ", " a "), (" eingegeben ", " entered "),
        (" angegebene ", " given "), (" angegeben ", " given "),
        (" erzeugt ", " created "), (" gespeichert ", " stored "),
        (" geladen ", " loaded "), (" Regel", "rule"), (" Formel", "formula"),
        (" Objekt", "object"), (" Klasse", "class"), (" Modul", "module"),
        (" Datenbank", "database"), (" Daten", "data"), (" Sicht", "view"),
        (" Anfrage", "query"), (" Attribut", "attribute"),
        (" Integritaet", "integrity"), (" Optimierung", "optimization"),
        (" Bearbeitung", "processing"), (" Erzeugung", "generation"),
        (" Gueltigkeit", "validity"), (" Identifikator", "identifier"),
        (" Kategorie", "category"), (" Verwaltung", "management"),
        (" Instanz", "instance"), (" Methode", "method"), (" Funktion", "function"),
        (" Verbindung", "connection"), (" Quelle", "source"), (" Treiber", "driver"),
        (" Benutzer", "user"), (" Fehler", "error"), (" Liste", "list"),
        (" Eintrag", "entry"), (" Eintraege", "entries"), (" Wert", "value"),
        (" Werte", "values"), (" Schritt", "step"), (" Fall", "case"),
        (" Bemerkung", "note"), (" Beispiel", "example"), (" Hinweis", "hint"),
        (" zuerst ", " first "), (" danach ", " then "), (" dabei ", " thereby "),
        (" dafuer ", " for this "), (" dazu ", " for this "), (" damit ", " so that "),
        (" noch ", " still "), (" nur ", " only "), (" auch ", " also "),
        (" schon ", " already "), (" hier ", " here "), (" dort ", " there "),
        (" waehrend ", " during "), (" nach ", " after "), (" vor ", " before "),
        (" ohne ", " without "), (" mit ", " with "), (" aus ", " from "),
        (" bei ", " at "), (" auf ", " on "), (" an ", " at "),
        (" sind ", " are "), (" ist ", " is "), (" war ", " was "),
        (" waren ", " were "), (" haben ", " have "), (" hat ", " has "),
        (" soll ", " should "), (" sollte ", " should "), (" muss ", " must "),
        (" kann ", " can "), (" konnte ", " could "), (" duerfen ", " may "),
        (" nicht ", " not "), (" kein ", " no "), (" keine ", " no "),
        (" allen ", " all "), (" alle ", " all "), (" jeder ", " each "),
        (" jedes ", " each "), (" dieser ", " this "), (" diese ", " this "),
        (" dieses ", " this "), (" dessen ", " whose "), (" deren ", " whose "),
    ]
    for src, dst in tokens:
        body = body.replace(src, dst)
    body = re.sub(r"\bthe the\b", "the", body)
    body = re.sub(r"\s+", lambda m: m.group(0) if "\t" in m.group(0) else " ", body)
    return prefix + body


def apply_block_replace(path: Path, start_marker: str, end_marker: str, new_block: str) -> bool:
    text = path.read_text(encoding="latin-1", errors="replace")
    start = text.find(start_marker)
    if start < 0:
        return False
    end = text.find(end_marker, start)
    if end < 0:
        return False
    updated = text[:start] + new_block + text[end:]
    path.write_text(updated, encoding="latin-1")
    return True


def main() -> int:
    translations = load_all_translations()
    applied = skipped = 0

    # 1) Apply all known batch translations where original still matches
    by_file: dict[str, list[tuple[int, str, str]]] = {}
    for (rel, line_no), translated in translations.items():
        # recover original from any batch file
        by_file.setdefault(rel, []).append((line_no, "", translated))

    for result_file in sorted(OUT.rglob("batch-*-result.json")):
        data = json.loads(result_file.read_text(encoding="utf-8"))
        for section in data:
            rel = section["file"]
            for ln in section["lines"]:
                by_file.setdefault(rel, [])
                entry = (ln["line"], ln["original"], ln.get("translated", ln["original"]))
                # dedupe by line
                existing = {e[0]: e for e in by_file[rel]}
                existing[ln["line"]] = entry
                by_file[rel] = list(existing.values())

    for rel, entries in sorted(by_file.items()):
        src = REPO / rel
        if not src.exists():
            continue
        lines = src.read_text(encoding="latin-1", errors="replace").splitlines()
        changed = False
        for line_no, original, translated in entries:
            idx = line_no - 1
            if 0 <= idx < len(lines) and lines[idx] == original:
                lines[idx] = translated
                applied += 1
                changed = True
            elif 0 <= idx < len(lines) and lines[idx] == translated:
                skipped += 1
        if changed:
            src.write_text("\n".join(lines) + "\n", encoding="latin-1")

    print(f"batch replay: applied={applied} skipped={skipped}")

    # 2) Special block replacements
    ec = COMPONENTS / "server-engine/src/ExternalConnection.swi.pl"
    if ec.exists():
        text = ec.read_text(encoding="latin-1", errors="replace")
        m = re.search(r"/\*\n\n1\)", text)
        if m:
            start = m.start() + 2
            end = text.find("\n*/", start)
            if end > 0:
                text = text[:start] + "\n" + EXTERNAL_CONNECTION_EN + text[end:]
                ec.write_text(text, encoding="latin-1")
                print("replaced ExternalConnection tutorial block")

    lcb = COMPONENTS / "java/cbapi/src/main/java/i5/cb/api/LocalCBclient.java"
    if lcb.exists():
        if apply_block_replace(
            lcb,
            "        /* Es are only IOException geworfen !!!!",
            "         **/",
            LOCALCBCLIENT_BLOCK,
        ) or apply_block_replace(
            lcb,
            "        /* Only IOException is thrown!",
            "         **/",
            LOCALCBCLIENT_BLOCK,
        ):
            print("replaced LocalCBclient exception comment block")

    # 3) Finish pass on remaining German comment lines
    spec = importlib.util.spec_from_file_location("extract_manifest", OUT / "extract-manifest.py")
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)

    finished = 0
    for path in sorted(COMPONENTS.rglob("*")):
        if not path.is_file() or "build" in path.parts or "generated" in path.parts:
            continue
        if path.suffix not in {".c", ".h", ".cpp", ".java", ".pl", ".tcl", ".py", ".sh"} and not path.name.endswith(".swi.pl"):
            continue
        rel = str(path.relative_to(REPO))
        lines = path.read_text(encoding="latin-1", errors="replace").splitlines()
        changed = False
        for idx, line in enumerate(lines):
            if not mod.is_comment_line(line, False) and not line.lstrip().startswith("*"):
                continue
            if not mod.GERMAN.search(line) and not mod.FALSE_POSITIVE.search(line):
                # also catch corruption without GERMAN match
                if not re.search(
                    r"(geworfen are|the Instanz|angegebene|gehaengt is|gemacht\.|"
                    r"Initialisiert the|koennen|muessen|Suchmenge|Datenbank|"
                    r"Ber\\\"ucksichtigung|Integritaet|Regel[^a-zA-Z]|Formel)",
                    line,
                    re.I,
                ):
                    continue
            if mod.FALSE_POSITIVE.search(line):
                continue
            new_line = translate_comment_line(line)
            if new_line != line:
                lines[idx] = new_line
                finished += 1
                changed = True
        if changed:
            path.write_text("\n".join(lines) + "\n", encoding="latin-1")

    print(f"finish pass: {finished} lines updated")

    sections = mod.extract_sections()
    summary = {
        "remaining_sections": len(sections),
        "remaining_lines": sum(len(s["lines"]) for s in sections),
        "remaining_files": len({s["file"] for s in sections}),
    }
    (OUT / "completion-summary.json").write_text(json.dumps(summary, indent=2))
    print(json.dumps(summary, indent=2))
    return 0 if not sections else 1


if __name__ == "__main__":
    raise SystemExit(main())
