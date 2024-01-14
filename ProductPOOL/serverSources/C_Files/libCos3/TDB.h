/*
The ConceptBase.cc Copyright

Copyright 1987-2024 The ConceptBase Team. All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted
provided that the following conditions are met:

   1. Redistributions of source code must retain the above copyright notice, this list of
      conditions and the following disclaimer.
   2. Redistributions in binary form must reproduce the above copyright notice, this list of
      conditions and the following disclaimer in the documentation and/or other materials
      provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE CONCEPTBASE TEAM ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE CONCEPTBASE TEAM OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

The views and conclusions contained in the software and documentation are those of the authors
and should not be interpreted as representing official policies, either expressed or implied,
of the ConceptBase Team.


The ConceptBase Team is represented by

Manfred Jeusfeld, University of Skovde, 54128 Skovde, Sweden


This license is a FreeBSD-style copyright license.
Legal home of the FreeBSD copyright license: http://www.freebsd.org/copyright/freebsd-license.html
*/
/**********************************************************************
*
*   TDB.h:
*
*   Creation:      8.12.1992
*   Created by:    Thomas List, Hans-Georg Esser, Christoph Ignatzy
*   last Change:   9.9.1993
*   Changed by:    Thomas List
*   Version 2.1a
*
*
**********************************************************************/

#ifndef _TDB

#define _TDB
#include "TDB.defs.h"
#include "TOBJ.h"
#include "TOID.h"
#include "TOIDSETSTL.h"
#include "SYMTBL.h"
#include "TIMEPOINT.h"
#include "longSETSTL.h"
#include "TOIDREF.h"
#include "TOIDREFHashSet.h"
#include "secure_put.h"
#include "Statistics.h"
#include "Literals.h"
#include "Version.h"
#include <stdio.h>
#include <fstream>
#ifdef ALGEBRA
#include "Algebra.h"
#endif
#include "QUERY.h"

#define VERSION_ID "ConceptBase-Objektspeicher Version %3d.%2d\n"
/*
 *   The Disk-Offset is the strlen of VERSION_ID (including \n)
 *
 */

#define DISK_OFFSET 42


/** IO-Klasse f\"ur TOID.

  Die Klasse stellt einen TOID als String dar. Dieser String wird zum Abspeichern der Daten
  auf Platte nebutzt.
  */
class TOIO
{
        /// die Strings, die den TOID darstellen
    char idChar[4],srcChar[4],dstChar[4],labelChar[4],StartTimeChar[4];
    char StartTimeUChar[2],EndTimeChar[4],EndTimeUChar[2],moduleChar[4],setChar[4];

private:
   // Hilfsfkten zum binaeren lesen und schreiben auf Platte
    void long2string(long, char*);
        //konvertiert long byteweise nach char* ohne Terminierung
    void string2long(char*,long&);
        //konvertiert char byteweise nach long
    void short2string(short,char*);
    void string2short(char*,short&);


public:
        /// Konstruktor - erzeugt einen "neutralen" String (alle Eintr\"age -1)
    TOIO();
        /** Konstruktor - erzeugt einen String f\"ur
          @param toid, der sich in Suchmenge
          @param set (akt, hist,...) befindet.
          */
    TOIO(TOID,int);
        /// L\"oscht den String, d.h. erzeugt den neutralenString (alle Eintr\"age -1)
        //erzeugt einen neuen String aus den uebergebenen werten
    TOIO(long,long,long,long,long,short,long,short,long,int);

    void clear();
        /** liesst die Daten des Strings aus und erzeugt ein entsprechendes TOBJ.
          @param id    Id des neuen Objekts
          @param toid  TOID f\"ur das neue Objekt
          @param label Symboltabellenverweis des neuen Objekts
          @param set   Suchraum
          @return 0, falls der String der neutrale String ist (Id = -1), 1 sonst\\

          Der Wert der Zeiger von den TOIDs src und dst wird auf den long-Wert der Ids
          gesetzt (src soll auf id\_101 zeigen => src.*TheObject = 101). In diesem Zustand
          erzeugt jeder Zugriff der den Zeiger referenziert sofort zu einem Absturz!
          */
    int get(long&, TOID&, long&, int&);
};

fstream& operator << (fstream&, TOIO);
fstream& operator >> (fstream&, TOIO&);

/** Datenbank-Objekt.\\

  Eine Instanz dieser Klasse ist ine vollst\"andige Telos-Datenbank. Momentan sollte nur
  eine Instanz exisitieren. Alle Anfragen von aussen an den Objektspeicher werden von dieser
  Klasse bearbeitet. Alle Telosobjekte der Datenbank haben genau einen Eintrag in einer der
  Mengen akt, hist, tmp1, tmp2 oder tmp3.
  */
class TDB {
        /// Die Menge der aktuell G\"ultigen (nicht tempor\"aren)  Objekte, d.h. der Objekte mit Endzeit unendlich
    TOIDSETSTL akt;
        /** Die Menge der Objekte, die w\"ahrend der aktuellen Transaktion in die Datenbak eingef\"ugt wurden
           (bis auf Objekte aus tmp3)
           */
    TOIDSETSTL tmp1;
        /// Die Menge der Objekte, die w\"ahrend der aktuellen Transaktion gel\"oscht wurden.
    TOIDSETSTL tmp2;
        /** Die Menge der Objekte, die w\"ahrend der aktuellen Transaktion implizit erzeugt wurden.
          d.h. diese Objekte wurden angelegt um die referentielle Integrit\"at zu gew\"arleisten. Wird eines
          diese Objekte nachtr\"aglich regul\"ar eingetragen, wird es nach tmp1 verschoben
          */
    TOIDSETSTL tmp3;
        /// Die Menge der gel\"oschten (nicht tempor\"aren) Objekte, d.h. Objekte mit Endzeit ungleich undendlich
    TOIDSETSTL hist;
        /// Hashtabelle, die ID's, wie sie in ConceptBase benutzt werden, auf TOID mapped
    TOIDREFHashSet *toidtable;
        /// Symboltabelle, alle Label-Eintr\"age von Telos-Objekten werden hier verwaltet
    SYMTBL Symbols;

        /// Suchraum (akt, tmp,...) f\"ur die folgenden Anfragen
    int next_search_space;
        /** Suchraum nur f\"ur die n\"achste Anfrage, damit kann kurzzeitig der Suchraum ge\"andert
          werden, ohne next\_search\_space zu `"andern.
          */
    int overrule_search_space;

        /** Zeitpunkt f\"ur die n\"achsten Suchanfragen, ein Telos-Objekt muss zu diesem Zeitpunkt
          g\"ultig sein, um L\"osung der Anfrage zu sein.
          */
    TIMEPOINT next_search_time;
        /** Transaktionszeit, neue Telos-Objekte bekommen diesen Zeitpunkt als Startzeit, gel\"oschte
          Telosobjekte bekommen diesen Zeitpunkt als Endzeit.
          */
    TIMEPOINT transaction_time;
        /// Gr\"osster Id, der in der Datenbank vorkommt
    long MaxID;
        /** Menge von nicht benutzten Ids. Diese IDs k\"onnen entstehen wenn Telos-Objekte aus
          der Datenbank entfernt werden (dies ist nicht das ConceptBase-l\"oschen). Werden neue
          Objekte erzeugt werden zuerst die IDs aus dieser Menge neu vergeben
          */
    longSETSTL unused_ID;

        /// Stream, \"uber den Telosobjekte auf Platte geschrieben werden bzw gelesen werden
    fstream telosfile;

        /// Statistik-Objekt
    Statistics stats;

      /*
       *
       *  fuer die Module
       *
       */

        /** Das System-Modul. Das System-Modul hat in dem Modulkonzept eine besondere Bedeutung
          und muss bekannt sein. N\"aheres s. Moduldokumentation.
          */
    TOID system_module;
        /// Das Modul, in dem die Ergebnisse der folgenden Anfragen sichtbar sein m\"ussen
    TOID next_module;
        /// \"Uberschribt das Suchmodul f\"ur die n\"achste Anfrage
    TOID overrule_module;
        /// Flag das Angibt, ob overrule\_module gesetzt ist
     int is_overrule_module;




  public:
    /*
    *   constructor/destructor
    */

        /// Konstruktor: initialisiert die Variablen und legt die Hashtabelle an
    TDB();
        /** Destruktor: l\"oscht die Hashtabelle und l\"oscht alle Telos-Objekte \"uber die
          Suchmengen
          */
    ~TDB();

    /*
    *  open/close telos-database
    */

        /** l\"adt eine Datebank von Platte.


           Existiert die Telos-Datei nicht so wird sie neu angelegt und der Versionsstring wird
           geschrieben.\\

           TODO: Es fehlt noch eine \"Uberpr\"ufung derVersionsnummer!!!!\\

           Ansonsten werden die Daten Zeilenweise mit Hilfe der TOIO Klasse eingelesen. Die so
           neu angelegten TOIDs werden in die entsprechenden Mengen eingef\"ugt. Da keine tempor\"aren
           Daten abgespeichert werden k\"onnen das nur die Mengen akt und hist sein.\\

           Danach werden alle Daten kurzzeitig in einer Menge (helpset) vereinigt um die Indexstruktur
           aufzubauen. Insbesondere werden dabei die long-Werte in src und dst durch Zeiger ersetzt.

           Als System-Modul wird das Modul angenommen, in dem Proposition enthalten ist. Hat dieses
           Modul den Id 0, so wird per name2toid nach dem Label System gesucht. Schl\"agt diese
           Suche fehl wird das Programm per exit beendet! Ist das Systemmodul zum aktuellen Zeitpunkt
           nicht g\"ultig wird ebenfalls abgebrochen.

           @param name Name und Pfad der Datenbank (z.B. ...../database/OB). An den Dateinamen
           werden die Enndungen .telos und .symbol angeh\"angt um das Telos- bzw. Symboltabellenfile
           zu laden.
           @return 1 bei Erfolg, 0 falls ein Fehler aufgetreten ist. M\"ogliche Fehler sind:
           Dateiname zu lang (max 190 Zeichen), Symboltabelle konnte nicht geladen werden
           oder Versionskontrolle fehlgeschlagen.
           */
    int open( char* );

        /// schein \"uberfl\"ussig zu sein -> TODO
    int close();

    /*
    *  convert internal formats to strings
    */
        /** wird an SYMTBL weitergeleitet. Berechnent zu einem Label einen SYMID
          @param s der Label
          @param symid der SYMID
          */
    int get_symb(char*,SYMID&);
        /** wird an SYMTBL weitergeleitet. Berechnet zu dem TOID den Label
          @param toid der TOID
          @param s der Label
          */
    int toid2name( TOID, char*);
        /** berechnet zu einem gegebenen Label einen TOID.
          Dabei wird der gesetzte Suchzeitpunkt und das Modul ber\"ucksichtigt. Die Berechnung
          findet in name2toid(char*, TOID\&, TOID) statt.
          @param s der Label als C-String
          @param toid das Ergebnis
          */
    int name2toid( char*, TOID&);
        /** berechnet zu einem gegebenen Label einen TOID.\\
          Die Berechnung ist nur bei Individuals eindeutig, bei Attributen wird die erste g\"ultige
          L\"osung genommen. Die Suche gliedert sich in 3 Teile. Zuerst wird nach L\"osungen in dem
          angegebenen Modul und im System-Modul gesucht. Dies ist wichtig um die h\"aufig auftretenden
          Anfragen nach z.B. Class oder QueryClass effizient zu berechnen. Danach werden imports und
          exports ber\"ucksichtigt und dann - rekursiv - nested modules.
          @param s der Label als C-String
          @param toid das Ergebnis
          @param modul das Modul
          @return 1, falls toid gefunden, 0 sonst
          */
    int name2toid( char*, TOID&,TOID);
        /** berechnet zu einem gegebenen Label \"uber alle Module die passenden und g\"ultigen
          TOIDs.
          @param s der Label als C-String
          @param toidset die Ergebnismenge
          @return 1, falls toid gefunden, 0 sonst
          */
    int name2toidset( char*, TOIDSETSTL&);
        /** berechnet zu einem gegebenen Label einen TOID. Im Unterschied zu name2toid wird
          \"uberpr\"uft, ob sich der toid in tmp3 befindet. Ist dies der Fall wird der toid von
          tmp3 nach tmp1 verschoben. Damit werden implizit getellte Objekte zu explizit getellten
          Objekten gemacht.\\
          FRAGE: kommt diese Funktio ohne Modul aus???????
          @param s der Label als C-String
          @param toid das Ergebnis
          @return 1, falls toid gefunden, 0 sonst
          */
    int create_name2toid( char*, TOID&);
        /** Berechnet zu einem TOID die OID-Darstellung f\"er ConceptBase (id\_<nr>).
          @param toid der TOID
          @param s der String, der das Ergebnis aufnehmen soll. Der Speicherplatz muss gross genug
          daf\"ur sein.
          */
    void toid2oid( TOID, char*);
        /** Berechnet einen OID (id\_<nr>) mit Hilfe der Hashtabelle in einen TOID um.
          @param s der OID als C-String
          @param toid das Ergebnis
          */
    int oid2toid( char*, TOID&);
        /** Berechnet zu einem OID den passenden TOID. Zusa\"atzlich wird ggf. eine gefundene L\"osung
          von tmp3 nach tmp1 verschoben. Dis erm\"oglicht die Handhabung von impliziten Tells.\\
          FRAGE: was wird nun benutztm oid2toid oder name2toid oder beides?
          @param s der OID als C-String
          @param toid das Ergebnis
          */
    int create_oid2toid( char*, TOID&);
        /** Berechnet zu einem einfachen Select-Ausdruck (vgl ConceptBase) einen TOID.
          Der Select-Ausdruck ist als string gegeben (nicht die Prolog-select()-Struktur),
          darf keine Klammern und nur die Operatoren !, -> und => enthalten. Diese Funktion
          haupts\"achlich benutzt um attribute mit Namen, wie Attribute, InstanceOf usw.
          handzuhaben.\\
          ACHTUNG: der Eingabestring s wird ver\"andert!!!!\\
          FRAGE: kann man das umgehen?\\
          FRAGE: wie siehts hier mit Modulen aus, Auch eine \"Uberpr\"ufung der Attribute
          auf G\"ultigkeit fehlt!
          @param s der select-Ausdruck
          @param toid das Ergebnis
          */
    int select2toid(char*, TOID&);
        /** Berechnet zu einem toid einen Select-Ausdruck - wird vermutlich nicht benutzt.
          FRAGE: wird das noch gebraucht?
          @param toid der TOID
          @param s String, der das Ergebnis aufnehmen m\"ussen kann
          */
    int toid2select(TOID,char*);
        /** \"Uberpr\"uft, ob ein TOID implizit getellt ist - soll heissen in tmp3 enthalten ist.
          @param toid der TOID
          @result 1, wenn ja, 0 sonst
          */
    int check_implicit(TOID);

    /*
    *  create/delete new objects
    */
        /** Legt ein neues Individual - Telos-Objekt an.
          Das neue Objekt bekommt noch keinen ID vergeben. Das Objekt bekommt als Startzeit
          die aktuelle Transaktion-Zeit und als Modul das aktuelle Modul.
          @param s Der Label des neuen Individuals
          @return Ein TOID zu dem neuen Objekt
          */
    TOID Create_node(char*);
        /** Legt ein neues Attribut - Telos-Objekt an.
          Das neue Objekt bekommt noch keinen ID vergeben. Das Objekt bekommt als Startzeit
          die aktuelle Transaktion-Zeit und als Modul das aktuelle Modul.
          @param s Der Label des neuen Attributs
          @param src die Source-Komponente
          @param dst die Destination-Komponente
          @return Ein TOID zu dem neuen Objekt
          */
    TOID Create_link(char*, TOID, TOID);
        /** Entfernt das zugeh\"orige Telos-Objekt aus dem Speicher.
          Dazu wird die Symbnoltabelle entspechend upgedatet und das
          Telos-Objekt entfernt. Alle weiteren TOIDs zu diesem Objekt
          sind damit ung\"ultig - ein Zugrif auf diese TOIDs hat einen
          Absturz zur Folge.
          @param toid der TOID zu dem zu l\"oschenden Objekt
          */
    void Destroy(TOID);
        /** Ruft die Umbenennungsfunktion der Symboltabelle auf. Dabei wird der Label
          des Symboltabelleneintrags von oldname auf newname gesetzt. Achtung, ein
          rename z.B. auf *instanceof wird katastrophale Folgen haben.
          @param newname der neue Labeleintrag
          @param oldname der umzubenennende Labeleintrag
          @return 1 bei Erfolg, 0 falls ein Fehler auftrat (oldname nicht gefunden, newname
          schon vergeben)
          */
    int rename(char*,char*);

    /*
    *  insert/delete object to/from telos-database
    */

        /** f\"ugt ein neues Objekt in die Datenbank ein. Das Objekt sollte vorher mit
          Create\_node oder Create\_link erzeugt worden sein. Das Objekt bekommt hier
          seine ID vergeben und wird auf Platte geschrieben. Zudem wird die Indexstruktur
          aktualisiert (Connect). Die Daten werden mit einer tempor\"ar-Markierung auf
          die Platte geschrieben - wird das Programm unregul\"aer beendet werden beim
          n\"achsten Laden diese Daten ignoriert. Der TOID wird in tmp1 eingef\"ugt.
          @param toid das neue Objekt
          @return der Id des neuen Objekts
          */
    long insert(TOID&);
        /** Wie insert - nur wird der TOID in tmp3 eingef\"ugt.
          @param toid das neue Objekt
          @return der Id des neuen Objekts
          @see insert
          */
    long insert_implicit(TOID&);
        /** \"Ubernimmt die Daten aus tmp1 nach akt. tmp3 sollte dabei leer sein! Die
          Daten werden auf der Platte aktualisiert, d.h. die Menge wird auf akt gesetzt.\\
          Irgendwo schwirren da noch temp-flags rum - ein explizites Flag und die Endzeit,
          MAL GENAU ANSEHEN.
          */
    int insert_commit();
        /** Verwirft die Daten aus tmp1 und tmp3. Dazu muessen die Indexstrukturen
          gel\"oscht werden, das Objekt gelo\"scht und die Hashtabelle upgedatet werden/
          */
    void insert_abort();

        /** Das Objekt wird von akt nach tmp2 verschoben und bekommt ein tmp-Flag gesetzt.
          @param toid der TOID des Objekts
          */
    int remove( TOID );

        /** The object TOID is removed permanently from tmp1.
           See also ticket #92
          @param toid:  TOID of the object to be removed from tmp1
          */
    int removetmp( TOID );

        /** Die Objekte werden endg\"ultig hitorisch gemacht. Dabei muss insbesondere die
          Platte upgedatet werden.
          */
    void remove_end();
        /** Die Objekte werden von tmp2 zur\"uck nach akt verschoben, dh
          die L\"oschoperation wird r\"uckg\"angig gemacht.
         */
    void remove_abort();

    /*
    *  search in the database
    */
        /** der Suchraum f\"ur die n\"achsten Suchoperationen wird gesetzt.
           @param whatset der neue Suchraum. Der Parameter besteht aus einer bit-oder
           Verkn\"upfung von ACTUAL\_DB, HISTORY\_DB, TEMP\_DB\_TELL und TEMP\_DB\_UNTELL.
           */
    void set_search_space( int );
        /** der Suchraum wird - abweichend von set\_search\_space - f\"ur die n\"achste
          Suchoperation ver\"aendert.
          @param whatset der neue Suchraum
          @see set_search_space delete_overrules
          */
    void set_overrule_search_space( int );

        /** Alle gesetzten Overrules werden gel\"oscht. Das sind overrule\_search\_space
          und overrule\_module.
          @see set_overrule_search_space set_overrule_module
          */
    void delete_overrules();

        /** set the persistency level
          */
    void set_persistency_level( int );


        /** der Suchzeitpunkt wird f\"ur die n\"achsten Operationen gesetzt.
          @param whattime der neue Suchzeitpunkt
          */
    void set_search_time(TIMEPOINT);

    TIMEPOINT get_next_search_time() {return next_search_time;};
    int get_overrule_search_space(){return overrule_search_space;};
    int get_is_overrule_module(){return is_overrule_module;};
    TOID& get_overrule_module(){return overrule_module;};
    TOID& get_next_module(){return next_module;};
    int get_next_search_space(){return next_search_space;};



        /** Startet eine retrieve\_proposition Suche. Dabei werden Suchzeitpunkt,
          Suchmenge und Modul sowie die overrules beachtet.
          @param descriptor Ein Query-Descriptor, der initialisiert wird und danach
                  zur Abfrage der Ergebnisse benutzt werden kann
          @param id Die ID-Komponente, wird nur beachtet, falls in Pattern FREE\_ID nicht gesetzt ist
          @param label Die Label-Komponente (als SYMID), wird nur beachtet, falls in Pattern
                 FREE\_LAB nicht gesetzt ist
          @param slabel Der Label als C-String
          @param src Die Src-Komponente, wird nur beachtet, falls in Pattern FREE\_SRC nicht gesetzt ist
          @param dst Die Dst-Komponente, wird nur beachtet, falls in Pattern FREE\_DST nicht gesetzt ist
          @param Pattern das Suchmuster - Bit-oder Kombination aus
                 FREE\_ID, FREE\_SRC, FREE\_LAB und FREE\_DST
          */
    void start_seek( QUERY4a& , TOID, TOID, SYMID, char*, TOID, int );
        /** wie start\_seek - jedoch mit zus\"atzlicher Modulkomponente. Es werden keine Modulvererbungen
          beachtet, jeoch kann mit freier Modulkomponente gesucht werden.
          @param descriptor Ein Query-Descriptor, der initialisiert wird und danach
                  zur Abfrage der Ergebnisse benutzt werden kann
          @param id Die ID-Komponente, wird nur beachtet, falls in Pattern FREE\_ID nicht gesetzt ist
          @param src Die Src-Komponente, wird nur beachtet, falls in Pattern FREE\_SRC nicht gesetzt ist
          @param label Die Label-Komponente (als SYMID), wird nur beachtet, falls in Pattern
                 FREE\_LAB nicht gesetzt ist
          @param slabel Der Label als C-String
          @param dst Die Dst-Komponente, wird nur beachtet, falls in Pattern FREE\_DST nicht gesetzt ist
          @param Pattern das Suchmuster - Bit-oder Kombination aus
                 FREE\_ID, FREE\_SRC, FREE\_LAB und FREE\_DST sowie FREE\_MODUL
          @param module die Modulkomponente, wird nur beachtet, falls in Pattern
                 FREE\_MODUL nicht gesetzt ist.
          @see start_seek
          */
    void start_seek( QUERY4a& , TOID, TOID, SYMID, char*, TOID, int, TOID );
        /** Startet eine 2-stellige Literalsuche
          @param descriptor Ein Query-Descriptor, der initialisiert wird und danach
                  zur Abfrage der Ergebnisse benutzt werden kann
          @param id1 Die erste Komponente, wird nur beachtet, falls in Pattern FREE\_ID1 nicht gesetzt ist
          @param id2 Die zweite Komponente, wird nur beachtet, falls in Pattern FREE\_ID2 nicht gesetzt ist
          @param Pattern das Suchmuster - Bit-oder Kombination aus
                 FREE\_ID1 und FREE\_ID2
          @param Whatlit das Literal, m\"oglich: In\_s, In\_i und system\_class
        */
    void start_Literal( QUERY2&, TOID, TOID, int, Literals );
        /** Startet eine 4-stellige Literalsuche
          @param descriptor Ein Query-Descriptor, der initialisiert wird und danach
                  zur Abfrage der Ergebnisse benutzt werden kann
          @param cc Die CC Komponente, wird nur beachtet, falls in Pattern FREE\_ID nicht gesetzt ist
          @param x Die X-Komponente, wird nur beachtet, falls in Pattern FREE\_SRC nicht gesetzt ist
          @param ml Die ML-Komponente (als SYMID), wird nur beachtet, falls in Pattern
                 FREE\_LAB nicht gesetzt ist
          @param mlhelp Der Meta-Label als C-String
          @param y Die Y-Komponente, wird nur beachtet, falls in Pattern FREE\_DST nicht gesetzt ist
          @param Pattern das Suchmuster - Bit-oder Kombination aus
                 FREE\_ID, FREE\_SRC, FREE\_LAB und FREE\_DST sowie FREE\_MODUL
          @param Whatlit das Literal, m\"oglich: Adot
        */
    void start_Literal3( QUERY3&, TOID, SYMID, char*, TOID, int, Literals);
        /** Startet eine *-Suche
          @param descriptor Ein Query-Descriptor, der initialisiert wird und danach
                  zur Abfrage der Ergebnisse benutzt werden kann
          @param label Ein Label mit *
        */

    void start_Literal4( QUERY4b&, TOID, SYMID,char*,SYMID,char*,TOID,int, Literals);
    void start_Literal4( QUERY4a&, TOID, TOID, SYMID, char*, TOID, int, Literals);
        /** Startet eine *-Suche
          @param descriptor Ein Query-Descriptor, der initialisiert wird und danach
                  zur Abfrage der Ergebnisse benutzt werden kann
          @param label Ein Label mit *
        */
    void start_star( QUERY1&, char*);
        /** Liefert eine L\"osung des Query-Descriptors \\
          VERMUTLICH \"Uberfl\"ussig!
          */
    int get_tuple(QUERY&,TOID&);
        /** Deinitialisiert den Descriptor\\
          VERMUTLICH \"Uberfl\"ussig!
          */
//    void end_seek( QUERY& );

    /*
    *  set time
    */

        /** setzt die Transaktions-Zeit
          @param now die neue Transaktionszeit
          */
    void set_transaction_time( TIMEPOINT );


        /** retrieve the start time of an object TOID
          */
    TIMEPOINT query_start_time( TOID );

        /** retrieve the end time of an object TOID
          */
    TIMEPOINT query_end_time( TOID );



    /*
     * fuer die Module
     */

        /** Setzt ein neues Systemmodul und tr\"agt alles Objekte in dieses Modul ein.
          Das wird benutzt um das Systemmodul beim Aufbau der Systemdatenbank zu setzen.
          Diese Funktion sollte nicht ConceptBase Betrieb eingesetzt werden.
          @param system_mod das neue Systemmodul
          */
    void SystemModule(TOID);
        /** Das aktuelle Modul wird gesetzt. Alle folgenden Anfrage beziehen sich auf dieses
          Modul.
          @param toid das neue Modul
          */
    void set_module(TOID);
        /** der Modulkontext wird - abweichend von set\_module - f\"ur die n\"achste
          Suchoperation ver\"aendert.
          @param toid das neue Modul
          @see set_module delete_overrules
          */
    void set_overrule_module(TOID);
        /** Initialisiert das durch toid angegebene Objekt zu einem Modul-Objekt. Erst dann
          kann das Objekt imports und exports verwalten.
          @param toid das betroffene Objekt
          */
    void initialize_module(TOID);
        /** Berechnet die Modul-Indexstruktur (imports und exports). Diese Funktion wird
          nach dem Laden der Datenbank einmal aufgerufen
          */
    void initialize_modules();
        /** Tr\"gt ein Objekt als neuer Export im aktuellen Modul ein. Das Objekt muss ein
          Attribut-Link mit Label export sein.
          @param toid das zu exportierende Objekt
          */
    int new_export(TOID);
        /** L\"oscht einen Export des aktuellen Moduls.
          @param der zu l\"oschende Export-Link
          */
    int delete_export(TOID);
        /** Tr\"agt ein Objekt als neuer Import im aktuellen Modul ein. Das Objekt muss ein
          Attribut-Link mit Label import sein.
          @param toid das zu importierende Objekt
          */
    int new_import(TOID);
        /** L\"oscht einen Import des aktuellen Moduls.
          @param der zu l\"oschende Import-Link
          */
    int delete_import(TOID);


    int delEntryOlderthan(TOIDSETSTL&, TIMEPOINT);

    void delete_history_db(TIMEPOINT);

    int updateStartTime(TOIDSETSTL& ,TIMEPOINT, int);

    int UnuseOnDisk(TOID);




    /*
     *
     *
     */


        /// liefert die Akt-Menge
    TOIDSETSTL & Akt()
    {
        return akt;
    }

        /// liefert die tmp1-Menge
    TOIDSETSTL & Tmp1()
    {
        return tmp1;
    }

        /// liefert die tmp2-Menge
    TOIDSETSTL & Tmp2()
    {
        return tmp2;
    }

        /// liefert die tmp3-Menge
    TOIDSETSTL & Tmp3()
    {
        return tmp3;
    }

        /// liefert die hist-Menge
    TOIDSETSTL & Hist()
    {
        return hist;
    }

        /// liefert die Sykboltabelle
    SYMTBL & Symb()
    {
        return Symbols;
    }



        /*
         *  test-methods
         */

    void test_akt()  { printf("akt  > ");akt.test();};
    void test_tmp1() { printf("tmp1 > ");tmp1.test();};
    void test_tmp2() { printf("tmp2 > ");tmp2.test();};
    void test_tmp3() { printf("tmp3 > ");tmp3.test();};
    void test_hist() { printf("hist > ");hist.test();};

    void test_all();
    /*
     * Statistics
     */

    int get_zaehler(TOID,int,long&);
    void update_zaehler(TOID, int, long&, int );
    void update_histogramm(TOID, int );
    void update_histogramm(TOID, int, TOID, TOID, int );
    Histogramm *get_histogramm(TOID, int );

  };

#endif
