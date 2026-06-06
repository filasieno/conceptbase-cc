#!/usr/bin/env python3
"""Finish German comment translation: extract remaining, translate, apply, verify."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[3]
OUT = Path(__file__).resolve().parent

# Longest phrases first
PHRASES: list[tuple[str, str]] = [
    ("Integritaetsueberpruefung", "integrity constraint check"),
    ("Integritaetsbedingungen", "integrity constraints"),
    ("Integritaetsbedingung", "integrity constraint"),
    ("Integritaetsverletzung", "integrity constraint violation"),
    ("Integritaetscheck", "integrity check"),
    ("Integritaetstest", "integrity test"),
    ("Abhaengigkeitsgraphen", "dependency graphs"),
    ("Abhaengigkeiten", "dependencies"),
    ("Abhaengigkeit", "dependency"),
    ("Regelabhaengigkeit", "rule dependency"),
    ("Klassenbindung", "class binding"),
    ("Klassenvariable", "class variable"),
    ("Klassenvariablen", "class variables"),
    ("Variablentabelle", "variable table"),
    ("Bedingungsformel", "condition formula"),
    ("Berechnungsergebnis", "computation result"),
    ("Folgerungsliteral", "conclusion literal"),
    ("Folgerungsteil", "conclusion part"),
    ("Belegungsmuster", "occupancy pattern"),
    ("Zusammengebautes", "assembled"),
    ("Quantifizierung", "quantification"),
    ("Anfrageoptmierer", "query optimizer"),
    ("Anfragestring", "query string"),
    ("Formelauswerter", "formula evaluator"),
    ("MetaFormel", "metaformula"),
    ("Metaformel", "metaformula"),
    ("Datalog-Regel", "Datalog rule"),
    ("MSFOL-Regel", "MSFOL rule"),
    ("RegelCode-Ids", "rule code IDs"),
    ("RegelCode IDs", "rule code IDs"),
    ("RegelCode-Ids", "rule code IDs"),
    ("Regelruempfen", "rule bodies"),
    ("Regelrumpf", "rule body"),
    ("Regelkopf", "rule head"),
    ("Objektspeichers", "object store"),
    ("Objektbaum", "object tree"),
    ("Objektbaumes", "object tree"),
    ("Objekt_Id", "object ID"),
    ("Skriptdateien", "script files"),
    ("Skriptdatei", "script file"),
    ("Skriptfile", "script file"),
    ("Hilfsfunktion", "helper function"),
    ("Vorbereitende", "Preparatory"),
    ("Einschraenkung", "restriction"),
    ("Vorbehandlung", "preprocessing"),
    ("vollstaendigen", "complete"),
    ("vollstaendige", "complete"),
    ("vollstaendig", "complete"),
    ("zusaetzlichen", "additional"),
    ("zusaetzlich", "additionally"),
    ("herausgeloescht", "removed"),
    ("zurueckgegeben", "returned"),
    ("zurueckliefern", "return"),
    ("zurueckgenommen", "taken back"),
    ("zurueckzuliefern", "to return"),
    ("zuruecksetzen", "reset"),
    ("durchgefuehrt", "performed"),
    ("durchsuchende", "searching"),
    ("aufgefuehrt", "performed"),
    ("ueberpruefe", "check"),
    ("Ueberpruefung", "check"),
    ("uebernommen", "adopted"),
    ("uebergeben", "passed"),
    ("uebergebene", "passed"),
    ("ueberhaupt", "at all"),
    ("repraesentiert", "represents"),
    ("Wertebzgl", "value w.r.t."),
    ("initialisiert", "initialized"),
    ("merkwuerdig", "odd"),
    ("eindeutige", "unique"),
    ("eigentlich", "actually"),
    ("Ansonsten", "Otherwise"),
    ("Ausserdem", "Furthermore"),
    ("Schliesslich", "Finally"),
    ("Aehnlich", "Similarly"),
    ("Beachte", "Note"),
    ("Vorgehen", "approach"),
    ("Bestimmung", "determination"),
    ("Behandlung", "handling"),
    ("Bezeichnung", "designation"),
    ("Auswertung", "evaluation"),
    ("Auswerten", "evaluate"),
    ("Compilieren", "compile"),
    ("Untersuchen", "examine"),
    ("Verarbeiten", "process"),
    ("Beruecksichtigung", "consideration"),
    ("Konkateniert", "concatenates"),
    ("Abspeichern", "store"),
    ("Einfuegeoperation", "insert operation"),
    ("Loeschoperation", "delete operation"),
    ("Loeschung", "deletion"),
    ("geloescht", "deleted"),
    ("loeschenden", "to be deleted"),
    ("loeschende", "to be deleted"),
    ("zu loeschenden", "to be deleted"),
    ("einzutragenden", "to be inserted"),
    ("Praedikate", "predicates"),
    ("Praedikat", "predicate"),
    ("BDMPraedikat", "BDM predicate"),
    ("Identifikator", "identifier"),
    ("Zeichenkette", "character string"),
    ("Milisekunden", "milliseconds"),
    ("Betriebssystems", "operating system"),
    ("Modulkontext", "module context"),
    ("Kopfliteral", "head literal"),
    ("Klausel", "clause"),
    ("deduktiven", "deductive"),
    ("deduktive", "deductive"),
    ("ded.Regel", "ded. rule"),
    ("this Regel", "this rule"),
    ("der Regel", "the rule"),
    ("dieser Regel", "this rule"),
    ("eine Regel", "a rule"),
    ("aktuellen Regel", "current rule"),
    ("betroffenen Regel", "affected rule"),
    ("ID der Regel", "ID of the rule"),
    ("dazu die Regel", "the associated rule"),
    ("zu loeschende Regel", "rule to be deleted"),
    ("Fall 1: Regel", "Case 1: rule"),
    ("body : Rumpf einer Regel", "body: body of a rule"),
    ("body einer Regel", "body of a rule"),
    ("einer Regel", "of a rule"),
    ("Regelterm", "rule term"),
    ("Regeln", "rules"),
    ("Regel", "rule"),
    ("Formeln", "formulas"),
    ("Formel", "formula"),
    ("generierte Formeln", "generated formulas"),
    ("generierten Formeln", "generated formulas"),
    ("Redundante Formeln", "Redundant formulas"),
    ("Meta-Formeln", "meta-formulas"),
    ("Klassen", "classes"),
    ("Klasse", "class"),
    ("einfache Klassen", "simple classes"),
    ("Objekte", "objects"),
    ("Objekt", "object"),
    ("Telos-Constraint Objekts", "Telos constraint object"),
    ("Fehlermeldungen hier ignorieren", "ignore error messages here"),
    ("Fallunterscheidung dafuer", "case distinction for this"),
    ("oeffentliche method", "public method"),
    ("gewaehlte Element", "selected element"),
    ("einzelnen Actions eingetragen are", "individual actions must be registered"),
    ("not benutzten", "unused"),
    ("koennen entstehen", "can arise"),
    ("groesst moegliche Wert hier zu sein", "largest possible value here"),
    ("nur fuer interne Zwecke", "for internal purposes only"),
    ("ein \"normales\" Objekt", "a \"normal\" object"),
    ("und sonst nichts", "and nothing else"),
    ("hier sollte die Hash-Tabelle eingesetzt werdern", "the hash table should be used here"),
    ("hier sollte die Hash-Tabelle eingesetzt werden", "the hash table should be used here"),
    ("Neues Special-Objekt generieren", "Generate new special object"),
    ("fuer SelectExpressions benoetigt", "needed for SelectExpressions"),
    ("fuer complexRef", "for complexRef"),
    ("Variablen/Funktionen fuer die Stringverwaltung", "Variables/functions for string management"),
    ("Variablen fuer InputBuffer", "Variables for InputBuffer"),
    ("wird der mod_context zurueckgegeben", "the mod_context is returned"),
    ("Falls nicht, wird DEFAULT zurueckgegeben", "Otherwise DEFAULT is returned"),
    ("Hier brauchen wir mit der setexp nichts zu machen, da die schon", "Here we do not need to do anything with setexp, since it is already"),
    ("Diese list is here initialisiert", "This list is initialized here"),
    ("Diese list", "This list"),
    ("Diese variable is used for die Optimierung", "This variable is used for optimization"),
    ("Diese In-literals", "These in-literals"),
    ("Diese Parameter must therefore also im head der Subquery auftauchen", "These parameters must therefore also appear in the head of the subquery"),
    ("Diese Vereinfachung is moeglich, da die Antworten der Query", "This simplification is possible because the answers of the query"),
    ("nach dem ersten Argument sortiert sind! Das ist", "are sorted by the first argument! That is"),
    ("Hier muesste man eigentlich noch testen, ob es dieses Attribute hier", "Here one should actually also test whether this attribute exists here"),
    ("kann ein SubView dahinter stecken. Dann muss auch dafuer ein Element erstellt", "a SubView may be behind it. Then an element must also be created for it"),
    ("classes, deren Instanzen in Bedingungsliteralen this Regel", "classes whose instances appear in condition literals of this rule"),
    ("Hier kein Cut, da verschiedene Conditions moeglich", "No cut here, since various conditions are possible"),
    ("Diese merkwuerdig erscheinende Transformation braucht", "This oddly looking transformation needs"),
    ("_cs (i) : classes, an die die Formeln gehaengt are", "_cs (i): classes to which the formulas are attached"),
    ("_fids (o) : oidsder generierten Formeln", "_fids (o): OIDs of the generated formulas"),
    ("Dieser Ausdruck is together mit der Information about die arguments", "This expression together with the information about the arguments"),
    ("and generiere sowohl NF2- als also ArgExp's dafuer namely", "and generate both NF2 and ArgExp's for it namely"),
    ("dafuer auch eine ViewArgExp", "also a ViewArgExp for it"),
    ("Hier must man eine Nest-Operation for the Subquery machen,", "Here one must perform a nest operation for the subquery,"),
    ("Hier must mehrere cases unterschieden are, z.B. ob es", "Here several cases must be distinguished, e.g. whether there"),
    ("erzeugten Formeln zusammenfasst.", "summarizes the generated formulas."),
    ("_ID:  oid des Formeltexts", "_ID: OID of the formula text"),
    ("eine list with zu loeschenden Formeln and eine mit einzutragenden", "a list with formulas to delete and one with formulas to insert"),
    ("ids:     ID-Struct for Query or Regel, Parameter", "ids: ID struct for query or rule, parameters"),
    ("welcher den Funktor 'tmpRuleInfo' besitzt. Dieser is", "which has the functor 'tmpRuleInfo'. This is"),
    ("Query, ded.Regel, etc. is used for each der generated", "query, ded. rule, etc. is used for each of the generated"),
    ("Dieser is here berechnet.", "This is computed here."),
    ("Alle already stored RegelCode-Ids are gemerkt", "All already stored rule code IDs are noted"),
    ("Collect the RegelCode-Ids of all Datalog rules,", "Collect the rule code IDs of all Datalog rules,"),
    ("Aus der alten list the ... is angegebene Element herausgeloescht", "From the old list the specified element is removed"),
    ("Hier the ... is Sichtenwartungsalgorithmus gestartet.", "Here the view maintenance algorithm is started."),
    ("!, Hier kein Cut, da mehrfach Suche moeglich", "!, no cut here, since multiple search is possible"),
    ("Diese In-literals kommen eigentlich only when GenericQueries zur", "These in-literals actually occur only when GenericQueries for"),
    ("Bindung der Parameter vor, alles andere sollten Meta-Formeln sein", "parameter binding, everything else should be meta-formulas"),
    ("Hier bemerkt man, in this list von attributes Katagorie, shall", "Here one notices, in this list of attribute category, shall"),
    ("Hier a ... iszele argument geparst and eine list of Char is geliefert.", "Here a serialized argument is parsed and a list of Char is returned."),
    ("Hier a ... ise Pfad-Ausdruck hinter einander geparst and abgearbeitet, z.B. '.dept.head' . Dieser Ausdruck repraesentiert", "Here path expressions are parsed and processed in sequence, e.g. '.dept.head'. This expression represents"),
    ("Wertebzgl. den SMLfragmentlsite, z.B. '.dept' repraesentiert Werte unter Kategorie dept in Bezug auf den angegebenen", "values w.r.t. the SML fragment site, e.g. '.dept' represents values under category dept with respect to the given"),
    ("Hier for the case das initial_variable failed, d.h. Forschleife fertig!", "Here for the case that initial_variable failed, i.e. forward loop finished!"),
    ("Hier a ... ise list of Atom/Term in list of CharListe umgewandelt.", "Here a list of Atom/Term is converted into a list of CharListe."),
    ("Warte Menge der geloeschten Import/Export Attribute", "Waiting set of deleted import/export attributes"),
    ("Diese Fakten are used by retrieve_temp/1 im PropositionProcessor.pro needed  -  um geloeschte", "These facts are used by retrieve_temp/1 in PropositionProcessor.pro - for deleted"),
    ("Decker, Manthey eingegeben are, so is checked, ob mit this Regel", "Decker, Manthey are entered, then it is checked whether with this rule"),
    ("die spezielle class 'MSFOLrule', so is checked, ob mit this Regel", "the special class 'MSFOLrule', then it is checked whether with this rule"),
    ("von der Loeschung ihres Folgerungsliterals", "from the deletion of its conclusion literal"),
    ("Integritaetsbedingungen are mit dem object, das instanziiert are", "integrity constraints with the object that is instantiated"),
    ("is mit den dann affected Integritaetsbedingungen and still weiter", "with the then affected integrity constraints and further"),
    ("Mit jeder betroffenen Regel:", "For each affected rule:"),
    ("von den Integritaetsbedingungen (1.Arg.) betroffen sind.", "affected by the integrity constraints (1st arg.)."),
    ("Die Integritaetsbedingungen are mit allen Elementen evaluated.", "The integrity constraints are evaluated with all elements."),
    ("Es sind keine Integritaetsbedingungen zu ueberpruefen.", "There are no integrity constraints to check."),
    ("Zur Semantik this Formeln: sie entsprechen dem Vorschlag for Formeln aus", "On the semantics of these formulas: they correspond to the proposal for formulas from"),
    ("thiss Formelauswerters in literals umgewandelt are and in die restlichen", "this formula evaluator converted into literals and into the remaining"),
    ("Formula). Der Formelauswerter ermoeglicht den Gebrauch der in der obigen", "formula). The formula evaluator enables the use of those in the above"),
    ("and negative literals are jetzt als auswertbare Formeln zugelassen.", "and negative literals are now allowed as evaluable formulas."),
    ("Das ist ein ziemlich unschoener Hack, aber Manfred", "This is a rather ugly hack, but Manfred"),
    ("Diese Prozedurtrigger are Trigger der Form applyPredicateIfInsert bzw.", "These procedure triggers are triggers of the form applyPredicateIfInsert resp."),
    ("were um eine Stelle extended. Diese Stelle contains die _id des Telos-Constraint Objekts. Sie dient", "was extended by one position. This position contains the _id of the Telos constraint object. It serves"),
    ("Dieser Test is wichtig, weil unter", "This test is important because under"),
    ("vorgegeben. Diese Komponente is not in CBIva integriert,", "specified. This component is not integrated in CBIva,"),
    ("Berechnet die Modul-Indexstruktur (imports and exports). Diese function is", "Computes the module index structure (imports and exports). This function is"),
    ("Hier: Unix-Version, entsprechende Windows-Funktionen  sind hier", "Here: Unix version, corresponding Windows functions are here"),
    ("_rangeform : the formula of the integrity constraint that is processed w.r.t. the literal", "_rangeform: the formula of the integrity constraint that is processed w.r.t. the literal"),
    ("_ranges    : Tabelle, die variables ihre \"Ranges\" (classes) zuordnet (i)", "_ranges: table mapping variables to their \"Ranges\" (classes) (i)"),
    ("_sign      : Vorzeichen des Literals (i)", "_sign: sign of the literal (i)"),
    ("Hier auch N2 erzeugen, da es in ConceptBase keine eindeutige", "Here also create N2, since in ConceptBase there is no unique"),
    ("rule : Regel", "rule: rule"),
    ("for each head literal a ... ise mask determined. Diese list", "for each head literal a ... ise mask is determined. This list"),
    ("argument ein Element aus _vars haben. Diese In-literals", "argument must have an element from _vars. These in-literals"),
    ("gebunden are can", "cannot be bound"),
    ("must therefore also im head", "must therefore also appear in the head"),
    ("must mehrere cases unterschieden are", "several cases must be distinguished"),
    ("must man eine", "one must"),
    ("must die einzelnen", "the individual"),
    ("is here berechnet", "is computed here"),
    ("is here initialisiert", "is initialized here"),
    ("is moeglich", "is possible"),
    ("is wichtig", "is important"),
    ("is used for die Optimierung", "is used for optimization"),
    ("is together mit der", "together with the"),
    ("is angegebene", "specified"),
    ("is gestartet", "is started"),
    ("is geliefert", "is returned"),
    ("is geparst", "is parsed"),
    ("is abgearbeitet", "is processed"),
    ("is umgewandelt", "is converted"),
    ("is instanziiert are", "is instantiated"),
    ("is checked, ob mit", "it is checked whether with"),
    ("eingegeben are", "are entered"),
    ("gehaengt are", "are attached"),
    ("unterschieden are", "distinguished"),
    ("eingetragen are", "registered"),
    ("betroffen sind", "are affected"),
    ("sortiert sind", "are sorted"),
    ("umgewandelt are", "converted"),
    ("zugelassen", "allowed"),
    ("benoetigt", "needed"),
    ("benotigt", "needed"),
    ("fuer ", "for "),
    ("Fuer ", "For "),
    ("muessen", "must"),
    ("muesste", "should"),
    ("koennen", "can"),
    ("duerfen", "may"),
    ("wurde ", "was "),
    ("wurden ", "were "),
    ("werden ", "are "),
    ("wird ", "is "),
    ("wird.", "is."),
    ("wird,", "is,"),
    ("hier ", "here "),
    ("Hier ", "Here "),
    ("hier.", "here."),
    ("hier,", "here,"),
    ("hier:", "here:"),
    ("hier zu sein", "to be here"),
    ("dafuer ", "for this "),
    ("dafuer.", "for this."),
    ("dazu die ", "the associated "),
    ("dazu ", "for this "),
    ("damit ", "so that "),
    ("dann ", "then "),
    ("dem ", "the "),
    ("den ", "the "),
    ("der ", "the "),
    ("die ", "the "),
    ("das ", "the "),
    ("des ", "of the "),
    ("z.B. ", "e.g. "),
    ("bzw.", "resp."),
    ("bzw. ", "resp. "),
    ("d.h. ", "i.e. "),
    ("namely ", "namely "),
    ("noch ", "still "),
    ("nur ", "only "),
    ("auch ", "also "),
    ("schon ", "already "),
    ("sowohl ", "both "),
    ("als also ", "as well as "),
    ("und sonst", "and otherwise"),
    ("und nun", "and now"),
    ("und dann", "and then"),
    ("ob es", "whether there"),
    ("ob mit", "whether with"),
    ("da es", "since there"),
    ("da die", "since the"),
    ("da verschiedene", "since various"),
    ("da mehrfach", "since multiple"),
    ("weil unter", "because under"),
    ("weil ", "because "),
    ("wenn ", "when "),
    ("wenn dem", "when the"),
    ("mit dem", "with the"),
    ("mit den", "with the"),
    ("mit this", "with this"),
    ("mit allen", "with all"),
    ("mit jeder", "with each"),
    ("von den", "of the"),
    ("von der", "of the"),
    ("in der", "in the"),
    ("in die", "into the"),
    ("in Bezug auf", "with respect to"),
    ("im head", "in the head"),
    ("im PropositionProcessor", "in PropositionProcessor"),
    ("an die", "to the"),
    ("zu ueberpruefen", "to check"),
    ("zu sein", "to be"),
    ("zu machen", "to do"),
    ("zuordnet", "maps"),
    ("entstehen when", "arise when"),
    ("scheint der", "seems to be the"),
    ("gibt den", "returns the"),
    ("gibt ", "returns "),
    ("liefert ", "returns "),
    ("erzeugt ", "creates "),
    ("erzeugen,", "create,"),
    ("erzeugen ", "create "),
    ("berechnet.", "computed."),
    ("berechnet ", "computed "),
    ("Berechnet ", "Computes "),
    ("Speichert ", "Stores "),
    ("Sucht ", "Searches "),
    ("Schreibt ", "Writes "),
    ("Suchen ", "Search "),
    ("Verarbeiten ", "Process "),
    ("Erstellen ", "Create "),
    ("Erkennen ", "Recognize "),
    ("Gehen ", "Go "),
    ("Nicht mehr", "No longer"),
    ("not mehr", "no longer"),
    ("oidsder", "OIDs of the"),
    ("Rumpf", "body"),
    ("Vorzeichen", "sign"),
    ("Tabelle", "table"),
    ("Menge", "set"),
    ("Methode", "method"),
    ("function is", "function is"),
    ("Liste", "list"),
    ("list ", "list "),
    ("Zykel", "cycle"),
    ("Zyklischen", "cyclic"),
    ("zyklischen", "cyclic"),
    ("Heuristik", "heuristic"),
    ("Fixpunkt", "fixpoint"),
    ("Literale", "literals"),
    ("Variablen", "variables"),
    ("Konstanten", "constants"),
    ("Struktur", "structure"),
    ("Kommunikation", "communication"),
    ("Fehler", "error"),
    ("Attribut", "attribute"),
    ("Attribute", "attributes"),
    ("Eingabe", "input"),
    ("Ausgabe", "output"),
    ("Instanzen", "instances"),
    ("instance", "instance"),
    ("Sichtenwartungsalgorithmus", "view maintenance algorithm"),
    ("Forschleife", "forward loop"),
    ("Folgerungsliterals", "conclusion literal"),
    ("Loeschung", "deletion"),
    ("Loesungen", "solutions"),
    ("Loesung", "solution"),
    ("Loesch", "delete"),
    ("Loeschen", "Delete"),
    ("Loesche ", "Delete "),
    ("Aenderung", "change"),
    ("Aenderungen", "changes"),
    ("Aendern", "change"),
    ("Aufloesung", "resolution"),
    ("zustaendig", "responsible"),
    ("tatsaechlich", "actually"),
    ("vorbereitet", "prepared"),
    ("gesammelt", "collected"),
    ("gestrichen", "removed"),
    ("getrennt", "separated"),
    ("enthaelt", "contains"),
    ("besitzt", "has"),
    ("gilt", "applies"),
    ("gilt auch", "also applies"),
    ("steht", "stands"),
    ("stehen", "stand"),
    ("waeren", "would be"),
    ("koennten", "could"),
    ("auftret", "occur"),
    ("auflost", "resolves"),
    ("auftauchen", "appear"),
    ("bearbeitet", "processed"),
    ("verarbeitet", "processed"),
    ("angezeigt", "displayed"),
    ("durchlaeuft", "traverses"),
    ("weitersuchen", "continue searching"),
    ("auffuellen", "fill up"),
    ("geschaffen", "created"),
    ("funktioniert", "works"),
    ("funktionierte", "worked"),
    ("erfolgt", "takes place"),
    ("ignorieren", "ignore"),
    ("uebergibt", "passes"),
    ("integriert", "integrated"),
    ("entsprechende", "corresponding"),
    ("interne Zwecke", "internal purposes"),
    ("normales", "normal"),
    ("groesst", "largest"),
    ("moegliche", "possible"),
    ("moeglich", "possible"),
    ("ziemlich", "rather"),
    ("unschoener", "ugly"),
    ("einzelne", "individual"),
    ("einzelnen", "individual"),
    ("dieselbe", "the same"),
    ("rekursive", "recursive"),
    ("rekursiven", "recursive"),
    ("geparsten", "parsed"),
    ("geparst ", "parsed "),
    ("herleitbaren", "derivable"),
    ("anonyme", "anonymous"),
    ("erstbeste", "first best"),
    ("spezialisierte", "specialized"),
    ("geeigneter", "suitable"),
    ("Betrachtet", "Considers"),
    ("betrachteten", "considered"),
    ("bezueglich", "regarding"),
    ("bzgl", "w.r.t."),
    ("bzgl.", "w.r.t."),
    ("ueber ", "over "),
    ("Ueber ", "Over "),
    ("Frueher", "Previously"),
    ("Nachschauen", "look up"),
    ("Zwecke", "purposes"),
    ("Temperory", "Temporary"),
    ("temperory", "temporary"),
    ("separate", "separate"),
    ("seperate", "separate"),
    ("theen ", "the "),
    ("when dem", "when the"),
    ("analog zu", "analogous to"),
    ("analogous zu dem", "analogous to the"),
    ("Dieses predicate", "This predicate"),
    ("Dabei is", "In doing so"),
    ("already ein", "already a"),
    ("intosaetzliche", "intensional"),
    ("es handelt sich", "it is"),
    ("Neues Special", "New special"),
    ("Vorausgesetzt", "Assuming"),
    ("Vorausgezetzt", "Assuming"),
    ("vorausgesetzt", "assumed"),
    ("wegen", "because of"),
    ("damit", "so that"),
    ("gemerkt", "noted"),
    ("werdern", "were"),
]

WORD_BOUNDARY_FIXES = [
    (re.compile(r"\bthiss\b"), "this"),
    (re.compile(r"\bshall\b"), "should"),
    (re.compile(r"\bare can\b"), "cannot"),
    (re.compile(r"\bcan \*/"), "*/"),
    (re.compile(r"\s+are\s*,\s*"), ", "),
    (re.compile(r"\s+are\s+"), " "),
    (re.compile(r"\s+is\s+"), " is "),
    (re.compile(r"  +"), " "),
]


def translate_line(line: str) -> str:
    if not line.strip():
        return line
    # Preserve leading whitespace
    prefix = line[: len(line) - len(line.lstrip())]
    body = line[len(prefix) :]
    for src, dst in PHRASES:
        body = body.replace(src, dst)
    for pat, repl in WORD_BOUNDARY_FIXES:
        body = pat.sub(repl, body)
    return prefix + body


def translate_sections(sections: list[dict]) -> list[dict]:
    out: list[dict] = []
    for section in sections:
        entry = dict(section)
        new_lines = []
        for ln in section["lines"]:
            translated = translate_line(ln["original"])
            new_lines.append(
                {"line": ln["line"], "original": ln["original"], "translated": translated}
            )
        entry["lines"] = new_lines
        out.append(entry)
    return out


def apply_translations(sections: list[dict]) -> tuple[int, int]:
    replacements: dict[str, dict[int, tuple[str, str]]] = {}
    for section in sections:
        path = section["file"]
        if path not in replacements:
            replacements[path] = {}
        for ln in section["lines"]:
            replacements[path][ln["line"]] = (ln["original"], ln.get("translated", ln["original"]))

    applied = skipped = 0
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
                skipped += 1
                continue
            if lines[idx] == original:
                lines[idx] = translated
                applied += 1
                changed = True
            elif lines[idx] == translated:
                skipped += 1
            else:
                print(f"MISMATCH {rel_path}:{line_no}", file=sys.stderr)
                skipped += 1
        if changed:
            src.write_text("\n".join(lines) + "\n", encoding="latin-1")
    return applied, skipped


def main() -> int:
    # Patch import: extract-manifest.py is not importable as extract_manifest
    import importlib.util

    spec = importlib.util.spec_from_file_location(
        "extract_manifest", OUT / "extract-manifest.py"
    )
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)

    total_applied = 0
    for pass_no in range(1, 2):  # single pass only — multi-pass corrupts mixed lines
        sections = mod.extract_sections()
        if not sections:
            print(f"pass {pass_no}: clean — no German sections remain")
            break
        translated = translate_sections(sections)
        applied, skipped = apply_translations(translated)
        total_applied += applied
        print(
            f"pass {pass_no}: sections={len(sections)} "
            f"lines={sum(len(s['lines']) for s in sections)} "
            f"applied={applied} skipped={skipped}"
        )
        if applied == 0:
            print("no progress — stopping", file=sys.stderr)
            break

    sections = mod.extract_sections()
    summary = {
        "total_sections": len(sections),
        "total_lines": sum(len(s["lines"]) for s in sections),
        "files": len({s["file"] for s in sections}),
        "total_applied": total_applied,
    }
    (OUT / "completion-summary.json").write_text(json.dumps(summary, indent=2))
    print(json.dumps(summary, indent=2))
    return 0 if not sections else 1


if __name__ == "__main__":
    raise SystemExit(main())
