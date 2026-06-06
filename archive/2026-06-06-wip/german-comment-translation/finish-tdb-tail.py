#!/usr/bin/env python3
"""Replace remaining mixed German/English comment blocks in TDB.h, TIMELINE.h."""

from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]

TDB_REPLACEMENTS = [
    (
        """        /** computes a TOID for a given label. Unlike name2toid,
          checked, ob sich der toid in tmp3 befindet. Ist dies der case the ... is toid von
          moved from tmp3 to tmp1. In this way implicitly shared objects are converted to explicitly shared
          Objekten gemacht.\\\\
          FRAGE: kommt this Funktio without Modul aus???????
          @param s der Label als C-String
          @param toid das Ergebnis
          @return 1 if toid was found, 0 otherwise
          */""",
        """        /** Computes a TOID for a given label. Unlike name2toid, checks whether
          the TOID is in tmp3. If so the TOID is moved from tmp3 to tmp1. Thus implicitly
          told objects become explicitly told objects.\\\\
          QUESTION: can this function work without module?
          @param s the label as C string
          @param toid the result
          @return 1 if TOID was found, 0 otherwise
          */""",
    ),
    (
        """        /** Computes zu einem TOID the OID-Darstellung f\\"er ConceptBase (id\\_<nr>).
          @param toid the TOID
          @param s the string that should hold the result. The memory must be large enough
          dafor sein.
          */""",
        """        /** Computes the OID representation for ConceptBase (id\\_<nr>).
          @param toid the TOID
          @param s the string that should hold the result. The buffer must be large enough.
          */""",
    ),
    (
        """        /** Computes einen OID (id\\_<nr>) mit Hilfe the Hashtabelle in einen TOID um.
          @param s the OID als C-String
          @param toid the Ergebnis
          */""",
        """        /** Converts an OID (id\\_<nr>) to a TOID using the hash table.
          @param s the OID as C string
          @param toid the result
          */""",
    ),
    (
        """        /** Computes zu einem OID the passenthe TOID. Zusa\\"atzlich is ggf. a gefundene solution
          von tmp3 nach tmp1 verschoben. Dis erm\\"oglicht the Handhabung von impliziten Tells.\\\\
          FRAGE: was is now benutztm oid2toid or name2toid or beides?
          @param s the OID als C-String
          @param toid the Ergebnis
          */""",
        """        /** Computes the matching TOID for an OID. Additionally a found solution
          may be moved from tmp3 to tmp1. This enables handling of implicit tells.\\\\
          QUESTION: should oid2toid or name2toid or both be used now?
          @param s the OID as C string
          @param toid the result
          */""",
    ),
    (
        """        /** Computes zu einem einfachen Select-Ausdruck (vgl ConceptBase) einen TOID.
          Der Select-Ausdruck is als string gegeben (not the Prolog-select()-structure),
          darf keine Klammern and only the Operatoren !, -> and => contain. Diese function
          haupts\\"achlich used um attribute mit Namen, wie attributes, InstanceOf usw.
          handzuhaben.\\\\
          ACHTUNG: the inputstring s is ver\\"andert!!!!\\\\
          FRAGE: kann man the umgehen?\\\\
          FRAGE: wie siehts here mit Modulen aus, Auch eine Takes overpr\\"ufung the attributee
          auf validity fehlt!
          @param s the select-Ausdruck
          @param toid the Ergebnis
          */""",
        """        /** Computes a TOID for a simple select expression (cf. ConceptBase).
          The select expression is given as a string (not the Prolog select() structure),
          must contain no parentheses and only the operators !, -> and =>. This function
          is mainly used to handle attributes with names such as Attribute, InstanceOf, etc.\\\\
          WARNING: the input string s is modified!!!!\\\\
          QUESTION: can this be avoided?\\\\
          QUESTION: what about modules? Attribute validity checks are also missing!
          @param s the select expression
          @param toid the result
          */""",
    ),
    (
        """        /** Computes zu einem toid einen Select-Ausdruck - is vermutlich not used.
          FRAGE: the ... is still gebraucht?
          @param toid the TOID
          @param s String, the the Ergebnis aufnehmen must kann
          */""",
        """        /** Computes a select expression for a TOID - probably unused.
          QUESTION: is this still needed?
          @param toid the TOID
          @param s string that must hold the result
          */""",
    ),
    (
        """        /** Checks whether a TOID is implicitly told - i.e. contained in tmp3.
          @param toid der TOID
          @result 1, when ja, 0 sonst
          */""",
        """        /** Checks whether a TOID is implicitly told - i.e. contained in tmp3.
          @param toid the TOID
          @result 1 if yes, 0 otherwise
          */""",
    ),
    (
        """        /** Legt ein neues Individual - Telos-object an.
          Das neue object bekommt still keinen ID vergeben. Das object bekommt als Startzeit
          the current transaction time and as module the current module.
          @param s Der Label des neuen Individuals
          @return Ein TOID zu dem neuen object
          */""",
        """        /** Creates a new individual Telos object.
          The new object does not yet receive an ID. Start time is the current transaction
          time and module is the current module.
          @param s label of the new individual
          @return TOID of the new object
          */""",
    ),
    (
        """        /** Legt ein neues attribute - Telos-object an.
          Das neue object bekommt still keinen ID vergeben. Das object bekommt als Startzeit
          the current transaction time and as module the current module.
          @param s Der Label des neuen Attributs
          @param src die Source-Komponente
          @param dst die Destination-Komponente
          @return Ein TOID zu dem neuen object
          */""",
        """        /** Creates a new attribute Telos object.
          The new object does not yet receive an ID. Start time is the current transaction
          time and module is the current module.
          @param s label of the new attribute
          @param src source component
          @param dst destination component
          @return TOID of the new object
          */""",
    ),
    (
        """        /** Entfernt the zubelonging Telos-object aus the memory.
          Dazu the ... is Symbnoltabelle entspechend upgedatet and the
          Telos-object removed. Alle weiteren TOIDs zu thism object
          are so that ung\\"ultig - ein Zugrif auf this TOIDs hat einen
          Absturz zur Folge.
          @param toid der TOID zu dem zu l\\"oschenden object
          */""",
        """        /** Removes the associated Telos object from memory.
          Updates the symbol table accordingly and removes the Telos object. All other
          TOIDs for this object become invalid; accessing them causes a crash.
          @param toid TOID of the object to delete
          */""",
    ),
    (
        """        /** Ruft the Umbenennungsfunktion the symbol table auf. Dabei the ... is Label
          of the symbol table entry from oldname to newname. Attention, a
          rename z.B. auf *instanceof is katastrophale Folgen haben.
          @param newname the new label entry
          @param oldname the label entry to be renamed
          @return 1 on success, 0 if an error occurred (oldname not found, newname
          schon vergeben)
          */""",
        """        /** Calls the symbol table rename function. Sets the symbol table entry label
          from oldname to newname. Warning: renaming e.g. to *instanceof has catastrophic effects.
          @param newname the new label entry
          @param oldname the label entry to rename
          @return 1 on success, 0 on error (oldname not found or newname already taken)
          */""",
    ),
    (
        """        /** inserts ein neues object in thedatabase ein. Das object should vorher mit
          Create\\_node or Create\\_link generated worden sein. Das object bekommt here
          seine ID vergeben and is to disk written. Zudem the ... is Indexstruktur
          aktualisiert (Connect). Die Daten are mit einer tempor\\"ar-Markierung auf
          die Platte written - the ... is Programm unregul\\"aer beendet are beim
          next Laden this Daten ignoriert. Der TOID is placed in tmp1 inserted.
          @param toid das neue object
          @return der Id des neuen Objekts
          */""",
        """        /** Inserts a new object into the database. The object should have been created
          with Create\\_node or Create\\_link. Here it receives its ID and is written to disk.
          The index structure is updated (Connect). Data is written with a temporary marker;
          if the program terminates abnormally, this data is ignored on next load. The TOID
          is inserted into tmp1.
          @param toid the new object
          @return ID of the new object
          */""",
    ),
    (
        """        /** Wie insert - only the ... is TOID in tmp3 inserted.
          @param toid das neue object
          @return der Id des neuen Objekts
          @see insert
          */""",
        """        /** Like insert - but the TOID is inserted into tmp3.
          @param toid the new object
          @return ID of the new object
          @see insert
          */""",
    ),
    (
        """        /** Takes the data from tmp1 into akt. tmp3 should be empty! The
          Daten auf the Platte aktualisiert, i.e. the set is auf akt gesetzt.\\\\
          Irgendwo schwirren da still temp-flags rum - ein explizites Flag and the end time,
          MAL GENAU ANSEHEN.
          */""",
        """        /** Commits data from tmp1 to akt. tmp3 should be empty! Data on disk is
          updated, i.e. the set is moved to akt.\\\\
          TODO: temp flags and end time still need a closer look.
          */""",
    ),
    (
        """        /** Verwirft the Daten aus tmp1 and tmp3. Dazu must the Indexstrukturen
          deleted are, das object gelo\\"scht and the Hashtabelle upgedatet are/
          */""",
        """        /** Discards data from tmp1 and tmp3. Index structures must be deleted,
          the object removed, and the hash table updated.
          */""",
    ),
    (
        """        /** Das object is used by akt nach tmp2 verschoben and bekommt ein tmp-Flag gesetzt.
          @param toid der TOID des Objekts
          */""",
        """        /** Moves the object from akt to tmp2 and sets a tmp flag.
          @param toid TOID of the object
          */""",
    ),
    (
        """        /** The objects are finally made historical. In particular the
          Platte upgedatet are.
          */""",
        """        /** Makes objects finally historical. In particular updates disk.
          */""",
    ),
    (
        """        /** The objects are moved back from tmp2 to akt, i.e.
          die L\\"oschoperation is r\\"uckg\\"angig gemacht.
         */""",
        """        /** Moves objects back from tmp2 to akt, i.e. undoes the delete operation.
         */""",
    ),
    (
        """        /** the search space for the next Suchoperationen is gesetzt.
           @param whatset der neue search space. Der Parameter besteht aus einer bit-or
           Verkn\\"upfung von ACTUAL\\_DB, HISTORY\\_DB, TEMP\\_DB\\_TELL and TEMP\\_DB\\_UNTELL.
           */""",
        """        /** Sets the search space for the next search operations.
           @param whatset the new search space: bit-or of ACTUAL\\_DB, HISTORY\\_DB,
           TEMP\\_DB\\_TELL and TEMP\\_DB\\_UNTELL.
           */""",
    ),
    (
        """        /** the search space is - abweichend von set\\_search\\_space - for the next
          Suchoperation ver\\"aendert.
          @param whatset der neue search space
          @see set_search_space delete_overrules
          */""",
        """        /** Overrides the search space for the next search operation (unlike set\\_search\\_space).
          @param whatset the new search space
          @see set_search_space delete_overrules
          */""",
    ),
    (
        """        /** the search time point is for the next Operationen gesetzt.
          @param whattime der neue search time point
          */""",
        """        /** Sets the search time point for the next operations.
          @param whattime the new search time point
          */""",
    ),
    (
        """        /** like start_seek - however with additional module component. Es are no module inheritance
          beachtet, however search with free module component is possible.
          @param descriptor a query descriptor that is initialized and then
                  used to query the results
          @param id the ID component; only considered if FREE_ID is not set in pattern
          @param src the src component; only considered if FREE_SRC is not set in pattern
          @param label the label component (as SYMID); only considered if FREE_LAB is not set in pattern
          @param slabel the label as C string
          @param dst the dst component; only considered if FREE_DST is not set in pattern
          @param pattern the search pattern - bit-or combination of
                 FREE\\_ID, FREE\\_SRC, FREE\\_LAB and FREE\\_DST sowie FREE\\_MODUL
          @param module the Modulkomponente, is only beachtet, if in Pattern
                 FREE\\_MODUL not gesetzt is.
          @see start_seek
          */""",
        """        /** Like start_seek with an additional module component. Module inheritance is not
          considered, but search with free module component is possible.
          @param descriptor a query descriptor that is initialized and then
                  used to query the results
          @param id the ID component; only considered if FREE_ID is not set in pattern
          @param src the src component; only considered if FREE_SRC is not set in pattern
          @param label the label component (as SYMID); only considered if FREE_LAB is not set in pattern
          @param slabel the label as C string
          @param dst the dst component; only considered if FREE_DST is not set in pattern
          @param pattern the search pattern - bit-or combination of
                 FREE\\_ID, FREE\\_SRC, FREE\\_LAB and FREE\\_DST and FREE\\_MODUL
          @param module the module component; only considered if FREE\\_MODUL is not set in pattern
          @see start_seek
          */""",
    ),
    (
        """        /** Startet a 2-stellige Literalsuche
          @param descriptor a query descriptor that is initialized and then
                  used to query the results
          @param id1 Die erste Komponente, is only beachtet, if in Pattern FREE\\_ID1 not gesetzt is
          @param id2 Die zweite Komponente, is only beachtet, if in Pattern FREE\\_ID2 not gesetzt is
          @param pattern the search pattern - bit-or combination of
                 FREE\\_ID1 and FREE\\_ID2
          @param Whatlit the literal, m\\"oglich: In\\_s, In\\_i and system\\_class
        */""",
        """        /** Starts a 2-ary literal search.
          @param descriptor a query descriptor that is initialized and then
                  used to query the results
          @param id1 first component; only considered if FREE\\_ID1 is not set in pattern
          @param id2 second component; only considered if FREE\\_ID2 is not set in pattern
          @param pattern the search pattern - bit-or combination of FREE\\_ID1 and FREE\\_ID2
          @param Whatlit the literal; possible values: In\\_s, In\\_i and system\\_class
        */""",
    ),
    (
        """        /** Startet a 4-stellige Literalsuche
          @param descriptor a query descriptor that is initialized and then
                  used to query the results
          @param cc Die CC Komponente, is only beachtet, if in Pattern FREE\\_ID not gesetzt is
          @param x Die X component, is only beachtet, if in Pattern FREE\\_SRC not gesetzt is
          @param ml Die ML-Komponente (als SYMID), is only beachtet, if in Pattern
                 FREE\\_LAB not gesetzt is
          @param mlhelp Der Meta-Label als C-String
          @param y Die Y component, is only beachtet, if in Pattern FREE\\_DST not gesetzt is
          @param pattern the search pattern - bit-or combination of
                 FREE\\_ID, FREE\\_SRC, FREE\\_LAB and FREE\\_DST sowie FREE\\_MODUL
          @param Whatlit the Literal, m\\"oglich: Adot
        */""",
        """        /** Starts a 4-ary literal search.
          @param descriptor a query descriptor that is initialized and then
                  used to query the results
          @param cc CC component; only considered if FREE\\_ID is not set in pattern
          @param x X component; only considered if FREE\\_SRC is not set in pattern
          @param ml ML component (as SYMID); only considered if FREE\\_LAB is not set in pattern
          @param mlhelp meta-label as C string
          @param y Y component; only considered if FREE\\_DST is not set in pattern
          @param pattern the search pattern - bit-or combination of
                 FREE\\_ID, FREE\\_SRC, FREE\\_LAB and FREE\\_DST and FREE\\_MODUL
          @param Whatlit the literal; possible value: Adot
        */""",
    ),
    (
        """        /** Startet a *-Suche
          @param descriptor a query descriptor that is initialized and then
                  used to query the results
          @param label Ein Label mit *
        */
    void start_star( QUERY1&, char*);
        /** Returns a solution of the query descriptor \\\\
          VERMUTLICH Takes overfl\\"ussig!
          */""",
        """        /** Starts a star search.
          @param descriptor a query descriptor that is initialized and then
                  used to query the results
          @param label a label with *
        */
    void start_star( QUERY1&, char*);
        /** Returns one solution of the query descriptor.\\\\
          Probably redundant!
          */""",
    ),
    (
        """        /** Deinitialisiert the Descriptor\\\\
          VERMUTLICH Takes overfl\\"ussig!
          */""",
        """        /** Deinitializes the descriptor.\\\\
          Probably redundant!
          */""",
    ),
    (
        """        /** setzt the Transaktions-Zeit
          @param now die neue Transaktionszeit
          */""",
        """        /** Sets the transaction time.
          @param now the new transaction time
          */""",
    ),
    (
        """        /** Setzt ein neues Systemmodul and tr\\"agt alles objects in thiss module ein.
          This is used to set the system module when building the system database.
          This function should not be used in ConceptBase operation.
          @param system_mod the new system module
          */""",
        """        /** Sets a new system module and registers all objects in that module.
          Used when building the system database. Do not use during normal ConceptBase operation.
          @param system_mod the new system module
          */""",
    ),
    (
        """        /** The current module is set. All following requests refer to this
          Modul.
          @param toid das neue Modul
          */""",
        """        /** Sets the current module. All following requests refer to this module.
          @param toid the new module
          */""",
    ),
    (
        """        /** the module context is - abweichend von set\\_module - for the next
          Suchoperation ver\\"aendert.
          @param toid das neue Modul
          @see set_module delete_overrules
          */""",
        """        /** Overrides the module context for the next search operation (unlike set\\_module).
          @param toid the new module
          @see set_module delete_overrules
          */""",
    ),
    (
        """        /** Initializes the object given by toid as a module object. Only then
          can the object imports and exports verwalten.
          @param toid the affected object
          */""",
        """        /** Initializes the object given by toid as a module object. Only then
          can it manage imports and exports.
          @param toid the affected object
          */""",
    ),
    (
        """        /** Computes the module index structure (imports and exports). This function is
          nach the Lathe the Datenbank einmal aufgerufen
          */""",
        """        /** Computes the module index structure (imports and exports). Called once
          after loading the database.
          */""",
    ),
    (
        """        /** Tr\\"agt ein object als neuer Export im aktuellen module ein. Das object must ein
          attribute-Link mit Label export sein.
          @param toid das zu exportierende object
          */""",
        """        /** Registers an object as a new export in the current module. Must be an
          attribute link with label export.
          @param toid the object to export
          */""",
    ),
    (
        """        /** Deletes einen Export des aktuellen modules.
          @param der zu l\\"oschende Export-Link
          */""",
        """        /** Deletes an export of the current module.
          @param toid the export link to delete
          */""",
    ),
    (
        """        /** Tr\\"agt ein object als neuer Import im aktuellen module ein. Das object must ein
          attribute-Link mit Label import sein.
          @param toid das zu importierende object
          */""",
        """        /** Registers an object as a new import in the current module. Must be an
          attribute link with label import.
          @param toid the object to import
          */""",
    ),
    (
        """        /** Deletes einen Import des aktuellen modules.
          @param der zu l\\"oschende Import-Link
          */""",
        """        /** Deletes an import of the current module.
          @param toid the import link to delete
          */""",
    ),
]

TIMELINE_OLD = """/** validitysintervall.
  Die class stellt den Abschnitt auf der Zeitlinie dar, in dem ein Telos-object
  g\\"ultig is. Das Intervall is links geschlossen and rechts offen. Hat das
  Intervall die Grenzen a < b, so is the object zum Zeitpunkt a g\\"ultig, zum Zeitpunkt
  b however not. Ist a==b, so is the object zu keinem Zeitpunkt g\\"ultig.
  */"""

TIMELINE_NEW = """/** Validity interval.
  Represents the segment on the timeline where a Telos object is valid. The interval
  is left-closed and right-open. If a < b, the object is valid at time a but not at b.
  If a==b, the object is never valid.
  */"""


def main():
    tdb = ROOT / "components/libcbcos/src/TDB.h"
    text = tdb.read_text(encoding="latin-1")
    n = 0
    for old, new in TDB_REPLACEMENTS:
        if old in text:
            text = text.replace(old, new)
            n += 1
        else:
            print("MISSING TDB block:", old[:60], "...")
    tdb.write_text(text, encoding="latin-1")
    print(f"TDB.h: {n}/{len(TDB_REPLACEMENTS)} blocks replaced")

    tl = ROOT / "components/libcbcos/src/TIMELINE.h"
    tlt = tl.read_text(encoding="latin-1")
    if TIMELINE_OLD in tlt:
        tl.write_text(tlt.replace(TIMELINE_OLD, TIMELINE_NEW), encoding="latin-1")
        print("TIMELINE.h: class comment replaced")
    else:
        print("TIMELINE.h: block not found")

    # Fix private member comments
    tlt = tl.read_text(encoding="latin-1")
    tlt = tlt.replace("/// Startzeitpunkt", "/// start time point")
    tlt = tlt.replace("/// end timepunkt", "/// end time point")
    tl.write_text(tlt, encoding="latin-1")


if __name__ == "__main__":
    main()
