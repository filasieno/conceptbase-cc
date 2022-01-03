/*
The ConceptBase.cc Copyright

Copyright 1987-2022 The ConceptBase Team. All rights reserved.

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
#include "TOIDSET.h"
#include "TOID.h"
#include "SYMID.h"
#include "TIMEPOINT.h"
#include "SYMTBL.h"
#include "Literals.h"
#include "TDB.defs.h"

/** Anfrage an den Objektspeicher.
  
    Jede retrieve\_propsition oder prove\_literal-Anfrage erzeugt eine Instanz von QUERY.
    Die Instanz ruft die Rechenvorschrift auf oder berechnet ggf. selber das Ergebnis,
    speichert die L\"osungen zwischen (bzw. eine Obermenge der L\"osungen) und stellt eine
    Methode zur Verf\"ugung, um diese L\"osungen einzeln abzurufen.

    Bisher gibt es 8 verschiedene QUERY-Childrens. Sie unterscheiden sich im Grunde nur in der set-Methode
    Die einzige Ausnahme ist AQUERY, da hier ein L\"osungset zur\"uckgegeben wird, das nicht im
    Objektspeicher ist, sondern neu erzeugt wurde. Hier sind noch eine mext-Methode (um die valid-\"uberpruefung
    zu verhindern) und ein Destructor (um den Speicher der L\"osung wieder freizugeben) hinzugekommen.

    */

class QUERY {
public:
        /// L\"osungsmenge
    TOIDSET space;
        /// Suchzeitpunkt
    TIMEPOINT time;
        /// Modul, in dem die L\"osung liegen soll
    TOID module;
        /// Flag, das angibt, ob Modulvererbungen beachtet werden sollen (1) oder nicht (0) 
    int strict;
        /// Suchraum (akt, tmp, ....)
    int searchspace;
        /// id-Komponente der Anfrage (bei retrieve\_proposition)
    TOID id;
        /// src-Komponente der Anfrage (bei retrieve\_proposition)
    TOID src;
        /// dst-Komponente der Anfrage (bei retrieve\_proposition)
    TOID dst;
        /// label-Komponente der Anfrage (bei retrieve\_proposition)
    SYMID label;
        /** label als C-String
          (wird ben\"otigt um eine dummy-Antwort zu erzeugem falls keine L\"osungen gefunden wurden)
          */
    char *slabel;
        /// Suchmuster (Bitmuster, das angibt welce Komponenten belegt sind (bit=1 <=> Kopmonente frei!))
    int	Pattern;
        /// Laufindex auf space
    Pix	i;		// search-index
        /// Flag, das angibt ob bereits L\"osungen abgefragt wurden
    int	start;		// start-flag
        /// Flag das angibt ob die L\"osungen auf G\"ultigkeit zum Suchzeitpunkt \"uberpr\"uft werden m\"ussen)
    int	ishist;		// history-flag
    

        /// Konstruktor
    QUERY();
        /// Destruktor
    virtual ~QUERY();
    
        /** Liefert das n\"achste Ergebnis der Anfrage.
          @param found TOID des Ergebnisses, falls vorhanden
          @return 1, wenn noch ein Ergenbis gefunden wurde, 0 sonst
          */
    virtual int next(TOID&);
        /** Liefert einen TOID mit der Id-Komponente der Anfrage, falls diese gesetzt war.
          @param toid der TOID von Id, falls vorhanden
          @return 1, falls Id gesettz war, 0 sonst \\
          Diese Funktion wird benutzt um eine pseudo-L\"osung aufzubauen, wenn next 0 liefert.
          Dies ist n\"otig, da sonst die Prolog-Schnittstelle einen Fehler liefert.
          */
    int DummyId(TOID&);
        /** Liefert einen TOID mit der Src-Komponente der Anfrage, falls diese gesetzt war.
          @param toid der TOID von Src, falls vorhanden
          @return 1, falls Src gesetzt war, 0 sonst \\
          Diese Funktion wird benutzt um eine pseudo-L\"osung aufzubauen, wenn next 0 liefert.
          Dies ist n\"otig, da sonst die Prolog-Schnittstelle einen Fehler liefert.
          */
    int DummySrc(TOID&);
        /** Liefert einen TOID mit der Dst-Komponente der Anfrage, falls diese gesetzt war.
          @param toid der TOID von Dst, falls vorhanden
          @return 1, falls Dst gesetzt war, 0 sonst \\
          Diese Funktion wird benutzt um eine pseudo-L\"osung aufzubauen, wenn next 0 liefert.
          Dies ist n\"otig, da sonst die Prolog-Schnittstelle einen Fehler liefert.
          */
    int DummyDst(TOID&);
        /** Liefert den String des Labels der Anfrage, falls dieser gesetzt war.
          @param s ein Zeiger auf einen Speicherbereich, der gro\3 genug sein mu\3 um den String aufzunehmen
          @return 1, falls der Label gesetzt war, 0 sonst \\
          Diese Funktion wird benutzt um eine pseudo-L\"osung aufzubauen, wenn next 0 liefert.
          Dies ist n\"otig, da sonst die Prolog-Schnittstelle einen Fehler liefert.
          */
    int DummyLab(char*);
        /** Liefert einen TOID mit der Id 1 -Komponente der Anfrage, falls diese gesetzt war.
          @param toid der TOID von Id 1, falls vorhanden
          @return 1, falls Id 1 gesetzt war, 0 sonst \\
          Diese Funktion wird benutzt um eine pseudo-L\"osung aufzubauen, wenn next 0 liefert.
          Dies ist n\"otig, da sonst die Prolog-Schnittstelle einen Fehler liefert.
          */
    int DummyId1(TOID&);
        /** Liefert einen TOID mit der Id 2 -Komponente der Anfrage, falls diese gesetzt war.
          @param toid der TOID von Id 2, falls vorhanden
          @return 1, falls Id 2 gesetzt war, 0 sonst \\
          Diese Funktion wird benutzt um eine pseudo-L\"osung aufzubauen, wenn next 0 liefert.
          Dies ist n\"otig, da sonst die Prolog-Schnittstelle einen Fehler liefert.
          */
    int DummyId2(TOID&);
        /** Liefert einen TOID mit der CC-Komponente der Anfrage, falls diese gesetzt war.
          @param toid der TOID von CC, falls vorhanden
          @return 1, falls CC gesezt war, 0 sonst \\
          Diese Funktion wird benutzt um eine pseudo-L\"osung aufzubauen, wenn next 0 liefert.
          Dies ist n\"otig, da sonst die Prolog-Schnittstelle einen Fehler liefert.
          */
    int DummyCC(TOID&);
        /** Liefert einen TOID mit der Modul-Komponente der Anfrage, falls diese gesetzt war.
          @param toid der TOID von Modul, falls vorhanden
          @return 1, falls Modul gesetzt war, 0 sonst \\
          Diese Funktion wird benutzt um eine pseudo-L\"osung aufzubauen, wenn next 0 liefert.
          Dies ist n\"otig, da sonst die Prolog-Schnittstelle einen Fehler liefert.
          */
    int DummyModule(TOID&);
        /// Liefert das Suchmuster
    int ask_pattern() { return Pattern; };
    
//    void done();
        /// Testfunktion
    void test();
};

//Query fuer 2 stellige Literale
class QUERY2:public QUERY
{
    public: 
    virtual void set(int,TIMEPOINT,TOID,TOID,TDB*,int,TOID,int)=0;
};

//Query fuer 3 stellige Literale
class QUERY3:public QUERY
{
    public: 
    virtual void set(int,TIMEPOINT, TOID, SYMID,char*, TOID, int,
                     TOID, int)=0;
};

//Query fuer 4 stellige Literale (Adot,P)
class QUERY4a:public QUERY
{
    public: 
    virtual void set(int,TIMEPOINT,TOID,TOID,SYMID,char*,TOID,TDB*,int,TOID,int)=0;    
};
//Query fuer 4 stellige Literale, zweite Version (ALabel)
class QUERY4b:public QUERY
{
    public: 
    virtual void set(int,TIMEPOINT,TOID,SYMID,char*,SYMID,char*,TOID,int,TOID,int)=0;    
};

//Query fuer starQuerier
class QUERY1:public QUERY
{
    public:
    virtual void set(int,TIMEPOINT,char*,SYMTBL*,TOID,int)=0;    
};


//QUERY fuer ein PLiteral
class PQUERY:public QUERY4a 
{
     /** Initialisiert die Instanz als retrieve\_proposition-Anfrage.
         @param whatset  Suchmenge
         @param ntime    Suchzeitpunkt
         @param nmodule  Suchmodul
         @param nstrict  Ber\"ucksichtigung von Modulvererbungen
         @param nid      Id-Komponente
         @param nsrc     Src-Komponente
         @param nlabel   Label-Komponente als SYMID
         @param nslabel  Label-Komponente als C-String
         @param ndst     Dst-Komponente
         @param nPattern Suchmuster
     */
public:
    virtual void set(int,TIMEPOINT,TOID,TOID,SYMID,char*,TOID,TDB*,int,TOID,int);
    
};


class inSQUERY:public QUERY2
{
    public: 
    virtual void set(int, TIMEPOINT, TOID, TOID,TDB*, int, TOID, int);
     /** Initialisiert die Instanz als prove\_literal(In\_s)-Anfrage.
         @param whatset  Suchmenge
         @param ntime    Suchzeitpunkt
         @param id1      1. Komponente
         @param id2      2. Komponente
         @param nPattern Suchmuster
         @param nmodule  Suchmodul
         @param nstrict  Ber\"ucksichtigung von Modulvererbungen\\
     */    
};

class inIQUERY:public QUERY2
{
    public:
    virtual void set(int, TIMEPOINT, TOID, TOID,TDB*,int ,TOID,int);
        /** Initialisiert die Instanz als prove\_literal(In\_s)-Anfrage.
          @param whatset  Suchmenge
          @param ntime    Suchzeitpunkt
          @param id1      1. Komponente
          @param id2      2. Komponente
          @param nPattern Suchmuster
          @param nmodule  Suchmodul
          @param nstrict  Ber\"ucksichtigung von Modulvererbungen\\
        */    
};

class SystemQUERY:public QUERY2
{
    public: 
    virtual void set(int, TIMEPOINT, TOID, TOID,TDB*, int, TOID, int);
    /** Initialisiert die Instanz als prove\_literal(In\_o)-Anfrage (system-in)
          @param whatset  Suchmenge
          @param ntime    Suchzeitpunkt
          @param x        1. Komponente
          @param c        2. Komponente
          @param nPattern Suchmuster
          @param db       Zeiger uf die Datenbank
          @param nmodule  Suchmodul
          @param nstrict  Ber\"ucksichtigung von Modulvererbungen
    */
};

class AdotQUERY:public QUERY4a
{
    virtual void set(int,TIMEPOINT, TOID, TOID, SYMID, 
		     char*, TOID,TDB*, int,TOID, int);
        /** Initialisiert die Instanz als prove\_literal(Adot)
          @param whatset  Suchmenge
          @param ntime    Suchzeitpunkt
          @param cc       Concerned Class
          @param x        X-Komponente
          @param ml       Meta-Label als SYMID
          @param helpml   Metal-Label als C-String
          @param y        Y-Komponente
          @param nPattern Suchmuster
          @param nmodule  Suchmodul
          @param nstrict  Ber\"ucksichtigung von Modulvererbungen \\

          FRAGE: Warum kommt Adot ohne Zeiger auf die Datenbank aus?
          ANTWORT: Alle Query-Methoden werden aus der Datenbank heraus
                   aufgerufen. Trans gibt die erzeugte Query an TDB weiter.
          */    
};

class starQUERY:public QUERY1
{
    virtual void set(int,TIMEPOINT,char*,SYMTBL*,TOID,int);
};

class AQUERY:public QUERY3
{
    virtual void set(int,TIMEPOINT, TOID, SYMID,
                     char*, TOID, int,
                     TOID, int);
    virtual int next(TOID&);
    public: virtual ~AQUERY();
};

class ALQUERY:public QUERY4b
{
    SYMID mlabel;
    virtual void set(int,TIMEPOINT, TOID, SYMID,
                     char*, SYMID, char*, TOID, int,
                     TOID, int);
    virtual int next(TOID&);
    public: virtual ~ALQUERY();
};

class IsaQUERY:public QUERY2
{
    virtual void set(int,TIMEPOINT, TOID,TOID,TDB*, int,
                     TOID, int);
//    public:
//    virtual ~IsaQUERY();
//    virtual int next(TOID&);    

};

