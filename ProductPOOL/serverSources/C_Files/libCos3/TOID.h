/*
The ConceptBase.cc Copyright

Copyright 1987-2020 The ConceptBase Team. All rights reserved.

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
Matthias Jarke, RWTH Aachen, Informatik 5, Ahornstr. 55, 52056 Aachen, Germany
Christoph Quix, RWTH Aachen, Informatik 5, Ahornstr. 55, 52056 Aachen, Germany


This license is a FreeBSD-style copyright license.
Legal home of the FreeBSD copyright license: http://www.freebsd.org/copyright/freebsd-license.html
*/
/**********************************************************************
*
*   TOID.h
*
*   Creation:      8.12.1992
*   Created by:    Thomas List, Hans-Georg Esser, Christoph Ignatzy
*   last Change:   8.7.1993
*   Changed by:    Thomas List
*   Version 2.1a
*
*
**********************************************************************/

#ifndef _TOID
#define _TOID

  #define OUT 0
  #define IN 1

  #include "TIMELINE.h"


/** Telos-Objekt Id.
  Eine Instanz von TOID ist im Wesentlichen ein Zeiger auf ein Telos-Objekt (TOBJ). Alle
  Zugriffe auf das Telos-Objekt finden \"uber die Klasse TOID statt. Es kann mehrere TOID's
  f\"ur ein Telos-Objekt geben. Sind alle TOID's, die auf ein TOBJ zeigen gel\"oscht, so
  kann das Telos-Objekt nicht mehr gefunden werden und blockiert Speicher. Insbesondere wird
  durch den Destruktor nicht der Speicherbereich des Telos-Objekts freigegeben! Fast alle Methoden
  von TOBJ sind \"uber TOID ansprechbar.
  */
class TOID {
        /// Zeiger auf das Telos-Objekt
    class TOBJ* TelosObj;
public:
        /// Konstruktor
    TOID () { TelosObj = 0; };
        /// Der Zeigerwert wird auf den numerischen Wert des Parameters gesetzt
    void set(long);
        /// Der Zeigerwert wird als long-Wert zur\"uckgegeben
    long get();
        /// Ausgabe der Werte
    void test();
        /// Ein neues Telos-Objekt mit Id ID wird angelegt
    void create(long);
        /// Das Telos-Objekt wird aus dem Speicher gel\"oscht
    void destroy();

        /// Der Id des Telos-Objekts wird gesetzt
    void SetId (long );
        /// liefert den ID des Telos-Objekts
    long GetId ()const;
        /** Speichert den OID des Telos-Objekts in s\\
          FRAGE: ist das n\"otig?
          */
    void GetOid(char *s);
        /// ruft Update\_index im Telos-Objekt auf
    void Update_index(int, TOID);
        /// ruft Del\_index im Telos-Objekt auf
    void Del_index(int, TOID);

        /// F\"ugt das Objekt in die Index-Struktur ein
    void Connect();
        /// L\"oscht das Objekt aus der Indextruktur
    void Disconnect();

        /// Vergleichsoperator: Gleichheit, wenn beide TOID's auf das gleiche Telos-Objekt zeigen
    int identical( TOID toid ) { return TelosObj == toid.TelosObj; };

        /// Zuweisungsoperator
    TOID& operator=( TOID );
        /// Vergleichsoperator (vergleicht die ID's der Objekte)
    int operator==( TOID );
        /// Vergleichsoperator (vergleicht ID's)
    int operator==( TOBJ* );
        /// kleiner-gleich Operator (vergleicht ID's)
    int operator <= (TOID);


    // Aequivalente Funktionen zu TOBJ

        /// Update von TOBJ
    void Update(TOID,TOID);
        /// Update von TOBJ
    void Update(long,long);
        /// Update\_StartRime von TOBJ
    void Update_StartTime(TIMEPOINT);
        // Update\_EndTime von TOBJ
    void Update_EndTime(TIMEPOINT);
        /// Update\_Label on TOBJ
    void Update_Label(class SYMID&);
        /// SetTemp von TOBJ
    void SetTemp(int);
        /// UnsetTemp von TOBJ
    void UnsetTemp();

        /// Src von TOBJ
    TOID Src ();
        /// Dst von TOBJ
    TOID Dst ();
        /// Lab von TOBJ
    SYMID Lab ();
        /// Valid von TOBJ
    class TIMELINE Valid ();
        /// is\_valid von TOBJ
    int is_valid(TIMEPOINT, int);
        /// is\_valid von TOBJ
    int is_valid(TIMEPOINT, int, TOID);
        /// is\_valid von TOBJ
    int is_valid(TIMEPOINT, int, TOID, int, int);
        /// is\_strictly\_valid von TOBJ
    int is_strictly_valid(TIMEPOINT, int, TOID);
        /// STime on TOBJ
    class TIMEPOINT STime();
        /// ETime von TOBJ
    class TIMEPOINT ETime();

        /// IofI von TOBJ
    class TOIDSETSTL& IofI ();
        /// IofO von TOBJ
    class TOIDSETSTL& IofO ();
        /// IsaI von TOBJ
    class TOIDSETSTL& IsaI ();
        /// IsaO von TOBJ
    class TOIDSETSTL& IsaO ();
        /// AtrI von TOBJ
    class TOIDSETSTL& AtrI ();
        /// AtrO von TOBJ
    class TOIDSETSTL& AtrO ();
    
        /*
         * fuer die Module
         */

        /// SetSystemModul von TOBJ
    void SetSystemModule(TOID);
        /// Update\_Module von TOBJ
    void Update_Module(TOID);
        /// Update\_Module von TOBJ
    void Update_Module(long);
        /// GetModule von TOBJ
    class TOID GetModule();
        /// SetModule von TOBJ
    int SetModule();
        /// UnsetModul von TOBJ
    int UnsetModule();
        /// Contains von TOBJ
    class TOIDSETSTL& Contains();
        /// Export von TOBJ
    class TOIDSETSTL& Export();
        /// Import von TOBJ
    class TOIDSETSTL& Import();
        /// NewExport von TOBJ
    int NewExport(TOID);
        /// DeleteExport von TOBJ
    int DeleteExport(TOID);
        /// MewImport von TOBJ
    int NewImport(TOID);
        /// DeleteImport von TOBJ
    int DeleteImport(TOID);
 };

inline bool operator<(const TOID& t1,const TOID& t2)

{  
    return t1.GetId()<t2.GetId();
};

#endif
