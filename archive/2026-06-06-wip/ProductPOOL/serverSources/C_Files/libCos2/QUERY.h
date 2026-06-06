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
#include "TOIDSET.h"
#include "TOID.h"
#include "SYMID.h"
#include "TIMEPOINT.h"
#include "SYMTBL.h"
#include "literals.h"
#include "TDB.defs.h"

/** query an den Objektspeicher.
  
    Jede retrieve\_propsition or prove\_literal-query creates eine Instanz of QUERY.
    Die Instanz ruft die evaluation rule auf or berechnet ggf. selber the result,
    speichert die solutions between (bzw. eine Obermenge der solutions) and stellt eine
    Methode zur Verf\"ugung, um this solutions einzeln abzurufen.

    Bisher there is 8 verschiedene QUERY-Childrens. Sie unterscheiden sich im Grunde only in der set-Methode
    Die einzige Ausnahme ist AQUERY, da here ein solutionset returned wird, das not im
    Objektspeicher ist, sondern neu creates wurde. Hier sind still eine mext-Methode (um die valid-\"uberpruefung
    zu verhindern) and ein Destructor (um den memory der solution wieder freizugeben) hinzugekommen.

    */

class QUERY {
public:
        /// solutionsmenge
    TOIDSET space;
        /// Suchzeitpunkt
    TIMEPOINT time;
        /// Modul, in dem die solution liegen should
    TOID module;
        /// Flag, das angibt, ob Modulvererbungen beachtet are sollen (1) or not (0) 
    int strict;
        /// Suchraum (akt, tmp, ....)
    int searchspace;
        /// id-Komponente der query (bei retrieve\_proposition)
    TOID id;
        /// src-Komponente der query (bei retrieve\_proposition)
    TOID src;
        /// dst-Komponente der query (bei retrieve\_proposition)
    TOID dst;
        /// label-Komponente der query (bei retrieve\_proposition)
    SYMID label;
        /** label als C-String
          (wird needed um eine dummy-Antwort zu erzeugem if no solutions gefunden wurden)
          */
    char *slabel;
        /// Suchmuster (Bitmuster, das angibt welce Komponenten belegt are (bit=1 <=> Kopmonente frei!))
    int	Pattern;
        /// Laufindex auf space
    Pix	i;		// search-index
        /// Flag, das angibt ob already solutions abgefragt wurden
    int	start;		// start-flag
        /// Flag das angibt ob die solutions auf G\"ultigkeit zum Suchzeitpunkt \"uberpr\"uft are m\"ussen)
    int	ishist;		// history-flag
    

        /// constructor
    QUERY();
        /// Destruktor
    virtual ~QUERY();
    
        /** Returns das next result der query.
          @param found TOID des resultses, if vorhanden
          @return 1, if still ein Ergenbis gefunden wurde, 0 sonst
          */
    virtual int next(TOID&);
        /** Returns an TOID mit der Id-Komponente der query, if this set war.
          @param toid der TOID of Id, if vorhanden
          @return 1, if Id gesettz war, 0 otherwise \\
          This function is used to build a pseudo-solution, if next 0 liefert.
          This is necessary because otherwise the Prolog interface returns an error.
          */
    int DummyId(TOID&);
        /** Returns an TOID mit der Src-Komponente der query, if this set war.
          @param toid der TOID of Src, if vorhanden
          @return 1, if Src set war, 0 otherwise \\
          This function is used to build a pseudo-solution, if next 0 liefert.
          This is necessary because otherwise the Prolog interface returns an error.
          */
    int DummySrc(TOID&);
        /** Returns an TOID mit der Dst-Komponente der query, if this set war.
          @param toid der TOID of Dst, if vorhanden
          @return 1, if Dst set war, 0 otherwise \\
          This function is used to build a pseudo-solution, if next 0 liefert.
          This is necessary because otherwise the Prolog interface returns an error.
          */
    int DummyDst(TOID&);
        /** Returns den String des Labels der query, if this set war.
          @param s ein pointer auf einen memorybereich, der gro\3 genug sein mu\3 um den String aufzunehmen
          @return 1, if der Label set war, 0 otherwise \\
          This function is used to build a pseudo-solution, if next 0 liefert.
          This is necessary because otherwise the Prolog interface returns an error.
          */
    int DummyLab(char*);
        /** Returns an TOID mit der Id 1 -Komponente der query, if this set war.
          @param toid der TOID of Id 1, if vorhanden
          @return 1, if Id 1 set war, 0 otherwise \\
          This function is used to build a pseudo-solution, if next 0 liefert.
          This is necessary because otherwise the Prolog interface returns an error.
          */
    int DummyId1(TOID&);
        /** Returns an TOID mit der Id 2 -Komponente der query, if this set war.
          @param toid der TOID of Id 2, if vorhanden
          @return 1, if Id 2 set war, 0 otherwise \\
          This function is used to build a pseudo-solution, if next 0 liefert.
          This is necessary because otherwise the Prolog interface returns an error.
          */
    int DummyId2(TOID&);
        /** Returns an TOID mit der CC-Komponente der query, if this set war.
          @param toid der TOID of CC, if vorhanden
          @return 1, if CC gesezt war, 0 otherwise \\
          This function is used to build a pseudo-solution, if next 0 liefert.
          This is necessary because otherwise the Prolog interface returns an error.
          */
    int DummyCC(TOID&);
        /** Returns an TOID mit der Modul-Komponente der query, if this set war.
          @param toid der TOID of Modul, if vorhanden
          @return 1, if Modul set war, 0 otherwise \\
          This function is used to build a pseudo-solution, if next 0 liefert.
          This is necessary because otherwise the Prolog interface returns an error.
          */
    int DummyModule(TOID&);
        /// Returns das Suchmuster
    int ask_pattern() { return Pattern; };
    
//    void done();
        /// Testfunktion
    void test();
};

//Query for 2 stellige Literale
class QUERY2:public QUERY
{
    public: 
    virtual void set(int,TIMEPOINT,TOID,TOID,TDB*,int,TOID,int)=0;
};

//Query for 3 stellige Literale
class QUERY3:public QUERY
{
    public: 
    virtual void set(int,TIMEPOINT, TOID, SYMID,char*, TOID, int,
                     TOID, int)=0;
};

//Query for 4 stellige Literale (Adot,P)
class QUERY4a:public QUERY
{
    public: 
    virtual void set(int,TIMEPOINT,TOID,TOID,SYMID,char*,TOID,TDB*,int,TOID,int)=0;    
};
//Query for 4 stellige Literale, zweite version (ALabel)
class QUERY4b:public QUERY
{
    public: 
    virtual void set(int,TIMEPOINT,TOID,SYMID,char*,SYMID,char*,TOID,int,TOID,int)=0;    
};

//Query for starQuerier
class QUERY1:public QUERY
{
    public:
    virtual void set(int,TIMEPOINT,char*,SYMTBL*,TOID,int)=0;    
};


//QUERY for ein PLiteral
class PQUERY:public QUERY4a 
{
     /** Initialisiert die Instanz als retrieve\_proposition-query.
         @param whatset  Suchmenge
         @param ntime    Suchzeitpunkt
         @param nmodule  Suchmodul
         @param nstrict  Ber\"ucksichtigung of Modulvererbungen
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
     /** Initialisiert die Instanz als prove\_literal(In\_s)-query.
         @param whatset  Suchmenge
         @param ntime    Suchzeitpunkt
         @param id1      1. Komponente
         @param id2      2. Komponente
         @param nPattern Suchmuster
         @param nmodule  Suchmodul
         @param nstrict  Ber\"ucksichtigung of Modulvererbungen\\
     */    
};

class inIQUERY:public QUERY2
{
    public:
    virtual void set(int, TIMEPOINT, TOID, TOID,TDB*,int ,TOID,int);
        /** Initialisiert die Instanz als prove\_literal(In\_s)-query.
          @param whatset  Suchmenge
          @param ntime    Suchzeitpunkt
          @param id1      1. Komponente
          @param id2      2. Komponente
          @param nPattern Suchmuster
          @param nmodule  Suchmodul
          @param nstrict  Ber\"ucksichtigung of Modulvererbungen\\
        */    
};

class SystemQUERY:public QUERY2
{
    public: 
    virtual void set(int, TIMEPOINT, TOID, TOID,TDB*, int, TOID, int);
    /** Initialisiert die Instanz als prove\_literal(In\_o)-query (system-in)
          @param whatset  Suchmenge
          @param ntime    Suchzeitpunkt
          @param x        1. Komponente
          @param c        2. Komponente
          @param nPattern Suchmuster
          @param db       pointer uf die Datenbank
          @param nmodule  Suchmodul
          @param nstrict  Ber\"ucksichtigung of Modulvererbungen
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
          @param nstrict  Ber\"ucksichtigung of Modulvererbungen \\

          FRAGE: Warum kommt Adot without pointer auf die Datenbank aus?
          ANTWORT: Alle Query-Methoden are aus der Datenbank heraus
                   aufgerufen. Trans returns the createse Query an TDB weiter.
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

