/*
The ConceptBase.cc Copyright

Copyright 1987-2026 The ConceptBase Team. All rights reserved.

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
*   version 2.1a
*
*
**********************************************************************/
 
#ifndef _TDB

#define _TDB

#include "TDB.defs.h"
#include "TOBJ.h"
#include "TOID.h"
#include "TOIDSET.h"
#include "SYMTBL.h"
#include "TIMEPOINT.h"
#include "long.AVLSet.h"
#include "TOIDREF.h"
#include "TOIDREF.CHSet.h"
#include "secure_put.h"
#include "Statistics.h"
#include "literals.h"
#include "version.h"
#include <stdio.h>
#include <fstream.h>
#ifdef ALGEBRA
#include "algebra.h"
#endif
#include "BPextern.h"
#include "QUERY.h"

#define VERSION_ID "ConceptBase-Objektspeicher version %3d.%2d\n"
/*
 *   The Disk-Offset ist the strlen of VERSION_ID (including \n)
 *
 */

#define DISK_OFFSET 42


/** IO-Class for TOID.

  Die Class stellt einen TOID als String dar. Dieser String is for storing der Daten
  auf Platte nebutzt.
  */
class TOIO
{
        /// die Strings, die den TOID darstellen
    char idChar[4],srcChar[4],dstChar[4],labelChar[4],StartTimeChar[4];
    char StartTimeUChar[2],EndTimeChar[4],EndTimeUChar[2],moduleChar[4],setChar[4];
    
private:
   // helper functions for binary lesen and schreiben auf Platte
    void long2string(long, char*);
        //konvertiert long byteweise nach char* without Terminierung
    void string2long(char*,long&); 
        //konvertiert char byteweise nach long
    void short2string(short,char*);
    void string2short(char*,short&);
    
    
public:
        /// constructor - creates einen "neutralen" String (alle Eintr\"age -1)
    TOIO();
        /** constructor - creates einen String f\"ur
          @param toid, der sich in Suchmenge
          @param set (akt, hist,...) befindet.
          */
    TOIO(TOID,int);
        /// L\"oscht den String, d.h. creates den neutralenString (alle Eintr\"age -1)
        //creates einen neuen String from den uebergebenen werten
    TOIO(long,long,long,long,long,short,long,short,long,int);
    
    void clear();
        /** liesst die data des Strings from and creates ein entsprechendes TOBJ.
          @param id    Id des neuen Objekts
          @param toid  TOID for das new Objekt
          @param label Symboltabellenverweis des neuen Objekts
          @param set   Suchraum
          @return 0, if der String der neutrale String ist (Id = -1), 1 sonst\\

          Der Wert the pointer of den TOIDs src and dst is auf den long-Wert der Ids
          set (src should auf id\_101 zeigen => src.*TheObject = 101). In diesem Zustand
          creates jeder Zugriff der den pointer referenziert sofort zu einem Absturz!
          */
    int get(long&, TOID&, long&, int&);
};

fstream& operator << (fstream&, TOIO);
fstream& operator >> (fstream&, TOIO&);

/** Datenbank-object.\\

  An instance dieser Class ist ine complete Telos-Datenbank. Momentan should only
  eine Instanz exisitieren. Alle queries of aussen an den Objektspeicher are of dieser
  Class bearbeitet. Alle Telos objects der Datenbank haben genau einen Eintrag in einer der
  Mengen akt, hist, tmp1, tmp2 or tmp3.
  */
class TDB {
        /// Die Menge der current G\"ultigen (not tempor\"aren)  objects, d.h. der objects mit Endzeit unendlich
    TOIDSET akt;
        /** Die Menge der objects, die w\"ahrend der current Transaktion in die Datenbak eingef\"ugt wurden
           (bis auf Objekte aus tmp3)
           */
    TOIDSET tmp1;
        /// Die Menge der objects, die w\"ahrend der current Transaktion gel\"oscht wurden.
    TOIDSET tmp2;
        /** Die Menge der objects, die w\"ahrend der current Transaktion implizit creates wurden.
          d.h. this Objekte wurden angelegt um die referentielle Integrit\"at zu gew\"arleisten. Wird eines
          this Objekte nachtr\"aglich regul\"ar eingetragen, is es nach tmp1 verschoben
          */
    TOIDSET tmp3;
        /// Die Menge der gel\"oschten (not tempor\"aren) objects, d.h. objects mit Endzeit ungleich undendlich
    TOIDSET hist;
        /// Hashtabelle, die ID's, wie sie in ConceptBase uses are, auf TOID mapped
    TOIDREFCHSet *toidtable;
        /// Symboltabelle, alle Label-Eintr\"age of Telos objecten are here verwaltet
    SYMTBL Symbols;

        /// Suchraum (akt, tmp,...) for die folgenden queries
    int next_search_space;
        /** Suchraum only for die next query, so that can kurzzeitig der Suchraum ge\"andert
          werden, without next\_search\_space zu `"andern.
          */
    int overrule_search_space;
    
        /** time point for die n\"achsten Suchanfragen, ein Telos object must zu diesem time point
          g\"ultig sein, um solution der query zu sein.
          */
    TIMEPOINT next_search_time;
        /** Transaktionszeit, new Telos objecte bekommen diesen time point als Startzeit, gel\"oschte
          Telos objects bekommen diesen Zeitpunkt als Endzeit.
          */
    TIMEPOINT transaction_time;
        /// Gr\"osster Id, der in der Datenbank vorkommt
    long MaxID;
        /** Menge of not uses.n Ids. Diese IDs can entstehen if Telos objecte from
          der Datenbank entfernt are (dies ist not das ConceptBase-l\"oschen). Werden neue
          Objekte creates are zuerst die IDs aus dieser Menge neu vergeben
          */
    longAVLSet unused_ID;

        /// Stream, about den Telos objects auf Platte geschrieben are or read are
    fstream telosfile;
    
        /// Statistik-object
    Statistics stats;

      /*
       *
       *  for die module
       *
       */
    
        /** Das System-Modul. Das System-Modul hat in dem Modulkonzept eine besondere Bedeutung
          and must bekannt sein. N\"aheres s. Moduldokumentation.
          */
    TOID system_module;
        /// Das Modul, in dem die resultse der folgenden queries sichtbar sein m\"ussen
    TOID next_module;
        /// \"Uberschribt das Suchmodul for die next query
    TOID overrule_module;
        /// Flag das Angibt, ob overrule\_module set ist
     int is_overrule_module;
      

  public:
    /*
    *   constructor/destructor
    */

        /// constructor: initializes the variables and legt die Hashtabelle an
    TDB();
        /** Destruktor: l\"oscht die Hashtabelle and l\"oscht alle Telos objecte about die
          Suchmengen
          */
    ~TDB();

    /*  
    *  open/close telos-database
    */

        /** l\"adt eine Datebank of Platte.


           Exists the Telos file not so is sie neu angelegt and der Versionsstring wird
           geschrieben.\\

           TODO: Es fehlt still eine \"Uberpr\"ufung derVersionsnummer!!!!\\

           Otherwise are die Daten line by line with the help of the TOIO Class eingelesen. Die so
           neu angelegten TOIDs are in die entsprechenden Mengen eingef\"ugt. Da no tempor\"aren
           Daten abstored are can das only die Mengen akt and hist sein.\\

           Danach are alle Daten kurzzeitig in einer Menge (helpset) vereinigt um die Indexstruktur
           aufzubauen. In particular are dabei die long-Werte in src and dst durch pointer ersetzt.

           Als System-Modul is das Modul angenommen, in dem Proposition enthalten ist. Hat dieses
           Modul den Id 0, so is per name2toid nach dem Label System gesucht. Schl\"agt diese
           Suche fehl is das Programm per exit beendet! Ist das Systemmodul zum aktuellen Zeitpunkt
           not g\"ultig is ebenfalls abgebrochen.

           @param name Name and Pfad der Datenbank (z.B. ...../database/OB). An den filenamen
           are die Enndungen .telos and .symbol angeh\"angt um das Telos- bzw. Symboltabellenfile
           zu laden.
           @return 1 on success, 0 if ein error occurred ist. M\"ogliche error sind:
           filename zu lang (max 190 Zeichen), Symboltabelle konnte not geladen werden
           or Versionskontrolle fehlgeschlagen.
           */
    int open( char* );

        /// schein \"uberfl\"ussig zu sein -> TODO
    int close();

    /*
    *  convert internal formats to strings
    */
        /** is forwarded to SYMTBL. Berechnent zu a Label einen SYMID
          @param s der Label
          @param symid der SYMID
          */
    int get_symb(char*,SYMID&);
        /** is forwarded to SYMTBL. Computes for dem TOID den Label
          @param toid der TOID
          @param s der Label
          */
    int toid2name( TOID, char*);
        /** berechnet zu a gegebenen Label einen TOID.
          Dabei is der gesetzte Suchzeitpunkt and das Modul ber\"ucksichtigt. Die Berechnung
          findet in name2toid(char*, TOID\&, TOID) statt.
          @param s der Label als C-String 
          @param toid the result
          */
    int name2toid( char*, TOID&);
        /** berechnet zu a gegebenen Label einen TOID.\\
          Die Berechnung ist only bei Individuals eindeutig, bei attributeen is die first g\"ultige
          solution genommen. Die Suche gliedert sich in 3 Teile. Zuerst is nach solutions in dem
          angegebenen Modul and im System-Modul gesucht. Dies ist wichtig um die h\"aufig auftretenden
          queries nach z.B. Class or QueryClass effizient zu berechnen. Danach are imports und
          exports ber\"ucksichtigt and then - rekursiv - nested modules.
          @param s der Label als C-String
          @param toid the result
          @param modul das Modul
          @return 1, if toid gefunden, 0 sonst
          */
    int name2toid( char*, TOID&,TOID);
        /** berechnet zu a gegebenen Label about alle module die matchingn and g\"ultigen
          TOIDs.
          @param s der Label als C-String
          @param toidset die resultmenge
          @return 1, if toid gefunden, 0 sonst
          */
    int name2toidset( char*, TOIDSET&);
        /** berechnet zu a gegebenen Label einen TOID. Im Unterschied zu name2toid is
          \"uberpr\"uft, ob sich der toid in tmp3 befindet. Ist this der Fall is der toid von
          tmp3 nach tmp1 verschoben. Damit are implizit getellte Objekte zu explizit getellten
          Objekten gemacht.\\
          FRAGE: kommt this Funktio without Modul aus???????
          @param s der Label als C-String
          @param toid the result
          @return 1, if toid gefunden, 0 sonst
          */
    int create_name2toid( char*, TOID&);
        /** Computes for a TOID die OID-Darstellung f\"er ConceptBase (id\_<nr>).
          @param toid der TOID
          @param s der String, der the result aufnehmen soll. Der memoryplatz must large enough
          dafor sein.
          */
    void toid2oid( TOID, char*);
        /** Computes a OID (id\_<nr>) with the help of the Hashtabelle in einen TOID um.
          @param s der OID als C-String
          @param toid the result
          */
    int oid2toid( char*, TOID&);
        /** Computes for a OID den matchingn TOID. Additionally, if found, a solution
          of tmp3 nach tmp1 verschoben. Dis erm\"oglicht die Handhabung of impliziten Tells.\\
          FRAGE: was is nun uses. oid2toid or name2toid or beides?
          @param s der OID als C-String
          @param toid the result
          */
    int create_oid2toid( char*, TOID&);
        /** Computes for a einfachen select-expression (vgl ConceptBase) einen TOID.
          Der Select-expression ist als string gegeben (nicht die Prolog-select()-structure),
          darf no Klammern and only die Operatoren !, -> and => enthalten. This function
          haupts\"achlich uses um attribute mit Namen, wie attributee, InstanceOf usw.
          handzuhaben.\\
          ACHTUNG: der Eingabestring s is ver\"andert!!!!\\
          FRAGE: can man das umgehen?\\
          FRAGE: wie siehts here mit Modulen aus, Auch eine \"Uberpr\"ufung der attributee
          auf G\"ultigkeit fehlt!
          @param s der select-expression
          @param toid the result
          */
    int select2toid(char*, TOID&);
        /** Computes for a toid einen select-expression - is probably unused.
          FRAGE: is das still used?
          @param toid der TOID
          @param s String, der the result aufnehmen m\"ussen kann
          */
    int toid2select(TOID,char*);
        /** Checks, ob ein TOID implizit getellt is - should heissen in tmp3 enthalten is.
          @param toid der TOID
          @result 1, if ja, 0 sonst
          */
    int check_implicit(TOID);

    /*
    *  create/delete new objects
    */
        /** Legt ein neues Individual - Telos object an.
          Das new Objekt bekommt still keinen ID vergeben. Das Objekt bekommt als Startzeit
          die aktuelle Transaktion-Zeit and als Modul das aktuelle Modul.
          @param s Der Label des neuen Individuals
          @return Ein TOID zu dem neuen Objekt
          */
    TOID Create_node(char*);
        /** Legt ein neues attribute - Telos object an.
          Das new Objekt bekommt still keinen ID vergeben. Das Objekt bekommt als Startzeit
          die aktuelle Transaktion-Zeit and als Modul das aktuelle Modul.
          @param s Der Label des neuen attributes
          @param src die Source-Komponente
          @param dst die Destination-Komponente
          @return Ein TOID zu dem neuen Objekt
          */
    TOID Create_link(char*, TOID, TOID);
        /** Removes the zugeh\"orige Telos object from dem memory.
          Dazu is die Symbnoltabelle entspechend upgedatet and das
          Telos object entfernt. Alle weiteren TOIDs zu diesem Objekt
          sind so that ung\"ultig - ein Zugrif auf this TOIDs hat einen
          Absturz zur Folge.
          @param toid der TOID zu dem zu l\"oschenden Objekt
          */
    void Destroy(TOID);
        /** Ruft die Umbenennungsfunktion der Symboltabelle auf. Dabei is der Label
          des Symboltabelleneintrags of oldname auf newname gesetzt. Achtung, ein
          rename z.B. auf *instanceof is katastrophale Folgen haben.
          @param newname der new Labeleintrag
          @param oldname der umzubenennende Labeleintrag
          @return 1 on success, 0 if ein error auftrat (oldname not gefunden, newname
          already vergeben)
          */
    int rename(char*,char*);

    /*
    *  insert/delete object to/from telos-database
    */

        /** f\"ugt ein neues object in die Datenbank ein. Das object sollte before mit
          Create\_node or Create\_link creates worden sein. Das Objekt bekommt hier
          seine ID vergeben and is auf Platte geschrieben. Zudem is die Indexstruktur
          aktualisiert (Connect). Die Daten are mit einer tempor\"ar-Markierung auf
          die Platte geschrieben - is das Programm unregul\"aer beendet are beim
          n\"achsten Laden this Daten ignoriert. Der TOID is in tmp1 eingef\"ugt.
          @param toid das new Objekt
          @return der Id des neuen Objekts
          */
    long insert(TOID&);
        /** Wie insert - only is der TOID in tmp3 eingef\"ugt.
          @param toid das new Objekt
          @return der Id des neuen Objekts
          @see insert
          */
    long insert_implicit(TOID&);
        /** \"Ubernimmt die data from tmp1 nach akt. tmp3 sollte dabei leer sein! Die
          Daten are auf der Platte aktualisiert, d.h. die Menge is auf akt gesetzt.\\
          Irgendwo schwirren da still temp-flags rum - ein explizites Flag and die Endzeit,
          MAL GENAU ANSEHEN.
          */
    int insert_commit();
        /** Verwirft die data from tmp1 and tmp3. Dazu muessen die Indexstrukturen
          gel\"oscht werden, das Objekt gelo\"scht and die Hashtabelle upgedatet werden/
          */
    void insert_abort();
        /** Das object is of akt nach tmp2 verschoben and bekommt ein tmp-Flag gesetzt.
          @param toid der TOID des Objekts
          */
    int remove( TOID );
        /** Die objects are endg\"ultig hitorisch gemacht. Dabei must in particular die
          Platte upgedatet werden.
          */
    void remove_end();
        /** Die objects are of tmp2 return nach akt verschoben, dh
          die L\"oschoperation is r\"uckg\"angig gemacht.
         */
    void remove_abort();

    /*
    *  search in the database
    */
        /** der Suchraum for die n\"achsten Suchoperationen is gesetzt.
           @param whatset der new Suchraum. Der Parameter besteht aus einer bit-oder
           Verkn\"upfung of ACTUAL\_DB, HISTORY\_DB, TEMP\_DB\_TELL and TEMP\_DB\_UNTELL.
           */
    void set_search_space( int );
        /** der Suchraum is - abweichend of set\_search\_space - for die n\"achste
          Suchoperation ver\"aendert.
          @param whatset der new Suchraum
          @see set_search_space delete_overrules
          */
    void set_overrule_search_space( int );
        /** Alle gesetzten Overrules are gel\"oscht. Das sind overrule\_search\_space
          and overrule\_module.
          @see set_overrule_search_space set_overrule_module
          */
    void delete_overrules();
        /** der Suchzeitpunkt is for die n\"achsten Operationen gesetzt.
          @param whattime der new Suchzeitpunkt
          */
    void set_search_time(TIMEPOINT);

    TIMEPOINT get_next_search_time() {return next_search_time;};
    int get_overrule_search_space(){return overrule_search_space;};
    int get_is_overrule_module(){return is_overrule_module;};
    TOID& get_overrule_module(){return overrule_module;};    
    TOID& get_next_module(){return next_module;};    
    int get_next_search_space(){return next_search_space;};
    
    

        /** Startet eine retrieve\_proposition Suche. Dabei are Suchzeitpunkt,
          Suchmenge and Modul sowie die overrules beachtet.
          @param descriptor Ein Query-Descriptor, der initialisiert is and danach
                  zur Abfrage der resultse uses are kann
          @param id Die ID-Komponente, is only beachtet, if in Pattern FREE\_ID not set ist
          @param label Die Label-Komponente (als SYMID), is only beachtet, if in Pattern
                 FREE\_LAB not set ist
          @param slabel Der Label als C-String
          @param src Die Src-Komponente, is only beachtet, if in Pattern FREE\_SRC not set ist
          @param dst Die Dst-Komponente, is only beachtet, if in Pattern FREE\_DST not set ist
          @param Pattern das Suchmuster - Bit-oder Kombination aus
                 FREE\_ID, FREE\_SRC, FREE\_LAB and FREE\_DST
          */
    void start_seek( QUERY4a& , TOID, TOID, SYMID, char*, TOID, int );
        /** wie start\_seek - jedoch mit zus\"atzlicher Modulkomponente. Es are no Modulvererbungen
          beachtet, jeoch can mit freier Modulkomponente gesucht werden.
          @param descriptor Ein Query-Descriptor, der initialisiert is and danach
                  zur Abfrage der resultse uses are kann
          @param id Die ID-Komponente, is only beachtet, if in Pattern FREE\_ID not set ist
          @param src Die Src-Komponente, is only beachtet, if in Pattern FREE\_SRC not set ist
          @param label Die Label-Komponente (als SYMID), is only beachtet, if in Pattern
                 FREE\_LAB not set ist
          @param slabel Der Label als C-String
          @param dst Die Dst-Komponente, is only beachtet, if in Pattern FREE\_DST not set ist
          @param Pattern das Suchmuster - Bit-oder Kombination aus
                 FREE\_ID, FREE\_SRC, FREE\_LAB and FREE\_DST sowie FREE\_MODUL
          @param module die Modulkomponente, is only beachtet, if in Pattern
                 FREE\_MODUL not set ist.
          @see start_seek
          */
    void start_seek( QUERY4a& , TOID, TOID, SYMID, char*, TOID, int, TOID );
        /** Startet eine 2-stellige Literalsuche
          @param descriptor Ein Query-Descriptor, der initialisiert is and danach
                  zur Abfrage der resultse uses are kann
          @param id1 Die first Komponente, is only beachtet, if in Pattern FREE\_ID1 not set ist
          @param id2 Die zweite Komponente, is only beachtet, if in Pattern FREE\_ID2 not set ist
          @param Pattern das Suchmuster - Bit-oder Kombination aus
                 FREE\_ID1 and FREE\_ID2
          @param Whatlit das Literal, m\"oglich: In\_s, In\_i and system\_class
        */
    void start_Literal( QUERY2&, TOID, TOID, int, Literals );
        /** Startet eine 4-stellige Literalsuche
          @param descriptor Ein Query-Descriptor, der initialisiert is and danach
                  zur Abfrage der resultse uses are kann
          @param cc Die CC Komponente, is only beachtet, if in Pattern FREE\_ID not set ist
          @param x Die X-Komponente, is only beachtet, if in Pattern FREE\_SRC not set ist
          @param ml Die ML-Komponente (als SYMID), is only beachtet, if in Pattern
                 FREE\_LAB not set ist
          @param mlhelp Der Meta-Label als C-String
          @param y Die Y-Komponente, is only beachtet, if in Pattern FREE\_DST not set ist
          @param Pattern das Suchmuster - Bit-oder Kombination aus
                 FREE\_ID, FREE\_SRC, FREE\_LAB and FREE\_DST sowie FREE\_MODUL
          @param Whatlit das Literal, m\"oglich: Adot
        */
    void start_Literal3( QUERY3&, TOID, SYMID, char*, TOID, int, Literals);
        /** Startet a *-Suche
          @param descriptor Ein Query-Descriptor, der initialisiert is and danach
                  zur Abfrage der resultse uses are kann
          @param label Ein Label mit *
        */

    void start_Literal4( QUERY4b&, TOID, SYMID,char*,SYMID,char*,TOID,int, Literals);
    void start_Literal4( QUERY4a&, TOID, TOID, SYMID, char*, TOID, int, Literals);
        /** Startet a *-Suche
          @param descriptor Ein Query-Descriptor, der initialisiert is and danach
                  zur Abfrage der resultse uses are kann
          @param label Ein Label mit *
        */
    void start_star( QUERY1&, char*);
        /** Returns a solution des Query-Descriptors \\
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
          @param now die new Transaktionszeit
          */
    void set_transaction_time( TIMEPOINT );
        /** Bl\"odsinnige function \\
          RAUS DAMIT or richtig neuschreiben
          */
    TIMEPOINT query_transaction_time( TOID );

    /*
     * for die module
     */

        /** Setzt ein neues Systemmodul and tr\"agt alles objects in dieses Modul ein.
          Das is used um das Systemmodul beim Aufbau der Systemdatenbank zu setzen.
          This function should not ConceptBase Betrieb eingesetzt werden.
          @param system_mod das new Systemmodul
          */
    void SystemModule(TOID);
        /** Das current Modul is gesetzt. Alle folgenden query beziehen sich auf dieses
          Modul.
          @param toid das new Modul
          */
    void set_module(TOID);
        /** der Modulkontext is - abweichend of set\_module - for die n\"achste
          Suchoperation ver\"aendert.
          @param toid das new Modul
          @see set_module delete_overrules
          */
    void set_overrule_module(TOID);
        /** Initialisiert das durch toid angegebene object zu a Modul-object. Erst then
          can das Objekt imports and exports verwalten.
          @param toid das betroffene Objekt
          */
    void initialize_module(TOID);
        /** Computes the module index structure (imports and exports). This function is
          nach dem Laden der Datenbank einmal aufgerufen
          */
    void initialize_modules();
        /** Tr\"gt ein object als neuer Export im current Modul ein. Das object must ein
          attribute-Link mit Label export sein.
          @param toid das zu exportierende Objekt
          */
    int new_export(TOID);
        /** L\"oscht einen Export des current Moduls.
          @param der zu l\"oschende Export-Link
          */
    int delete_export(TOID);
        /** Tr\"agt ein object als neuer Import im current Modul ein. Das object must ein
          attribute-Link mit Label import sein.
          @param toid das zu importierende Objekt
          */
    int new_import(TOID);
        /** L\"oscht einen Import des current Moduls.
          @param der zu l\"oschende Import-Link
          */
    int delete_import(TOID);

    
    int delEntryOlderthan(TOIDSET&, TIMEPOINT);

    void delete_history_db(TIMEPOINT);

    int updateStartTime(TOIDSET& ,TIMEPOINT, int);

    int UnuseOnDisk(TOID);

    
    
    
    /*
     *   
     *
     */


        /// returns the Akt-Menge
    TOIDSET & Akt()
    {
        return akt;
    }

        /// returns the tmp1-Menge
    TOIDSET & Tmp1()
    {
        return tmp1;
    }

        /// returns the tmp2-Menge
    TOIDSET & Tmp2()
    {
        return tmp2;
    }

        /// returns the tmp3-Menge
    TOIDSET & Tmp3()
    {
        return tmp3;
    }

        /// returns the hist-Menge
    TOIDSET & Hist()
    {
        return hist;
    }

        /// returns the Sykboltabelle
    SYMTBL & Symb()
    {
        return Symbols;
    }

#ifdef ALGEBRA
        /*
         *  for die algebra
         */
    
    void
    AlgebraToProlog(AlgDescription* ad, BP_Term term);
    void SetHead(Literal*,BP_Term);
    void SetHead(AlgDescription* alg,BP_Term);
    AlgDescription *PrologToAlg(BP_Term term);
        /* rechnet einen algebra expression from
          @param ad Der Alsgebra expression */
    void CalculateAlgebra(AlgDescription* ad);
    Relation* _PrologToAlg(BP_Term term);
    Relation* LiteralToAlg(BP_Term term);
    JoinCondition *JoinConditionToAlg(BP_Term term, int mod=0);
    AttrList *ArgListToAlg(BP_Term term);
    
    Fixpoint *PrologToFixpoint(BP_Term term);

    void Faktenlist(BP_Term, Fixpoint *fix);    
    stratified_rules *PrologToStratified_rules(BP_Term term);
    
    void
    TupelCToProlog(Tupel &t, BP_Term term,int arity);
#endif    
    
    
        /*
         *  test-methods
         */
    
    void test_akt()  { printf("akt  > ");akt.test();};
    void test_tmp1() { printf("tmp1 > ");tmp1.test();};
    void test_tmp2() { printf("tmp2 > ");tmp2.test();};
    void test_tmp3() { printf("tmp3 > ");tmp3.test();};
    void test_hist() { printf("hist > ");hist.test();}; 

    void test_all();
#ifdef ALGEBRA
    void alg_test(Relation& rel);
#endif    
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
