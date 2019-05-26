/*
The ConceptBase.cc Copyright

Copyright 1987-2019 The ConceptBase Team. All rights reserved.

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
*   SYMTBL.h
*
*   Creation:      15.5.1993
*   Created by:    Thomas List
*   last Change:   7.7.1993
*   Changed by:    Thomas List
*   Version 0.1
*
*
**********************************************************************/

#ifndef _SYMTBL
#define _SYMTBL


#include <fstream.h>
#include <stdlib.h>
#include <string.h>

#include "SYMID.h"
#include "SYMID.AVLSet.h"
#include "long.AVLSet.h"
#include "TOID.h"
#include "SYMIDREF.h"
#include "SYMIDREF.CHSet.h"

#include "secure_put.h"

/** Symboltabelle.
   Die Symboltabelle speichert s\"amtliche Label-Eintr\"age ab, die in der Datenbank vorkommen.
   Jeder Eintrag hat zudem eine Indexmenge, in der die TOID's aufgelistet sind, die diesen
   Label benutzen.
   */
class SYMTBL {

private:
        /// Flag das anzeigt, ob die Symboltabelle ge\"offnet ist
  int open;                    // indicates if a file is opened
        /// Die Eigentliche Symbolmenge
  SYMIDAVLSet symbols;
        /** Eine Hash-Tabelle, die zum Laden der Symboltabelle benutzt wird, um Symbolnummern
          in SYMID's umzuwandeln. Die Hashtabelle wird nach dem Laden entfernt.
          */
  SYMIDREFCHSet *idtable;
        /** Menge der unbenutzten Eintr\"age - da die Eintr\"age jedoch unterschiedliche L\"ange
          habe k\"onnen werden neue Labels immer hinten angeh\"angt!
          */
  longAVLSet unused_filepos;
        /// file-stream
  fstream symfile;
        /// Anzahl der Eintr\"age
  long filesize;
        //die naechste zu vergebende SymID
  long nextID;

  char *symfilename;
    
  public:
        /// Konstruktor: \"oeffnet die Angegebene Datei als Symboltabelle
  SYMTBL(char*);
        /// Konstruktor: initialistert die Symboltabelle - es fehlt noch ein Dateiname
  SYMTBL();
        /// Destruktor
  ~SYMTBL();
        //weil destructor nicht aufgerufen wird, destroy
  void destroy();
        /// L\"ad dieangegebene Datei als Symboltabelle
  int load(char*);
        /// l\"oscht die Hash-Tabelle
  int load_done();
        /** tr\"agt den TOID in die Menge der TOID's ein, die den Symboltabelleneintrag
          Nr. id benutzen und gibt einen SYMID auf diesen Eintrag zur\"uck. Wird beim
          Laden ben\"otigt.
          @param id Id des Symboltabelleneintrags (wie er im .telos-file steht)
          @param toid der TOID, der diesen Label benutzt
          @param symid  R\"uckgabewert: SYMID zum Label-Id
          */
  int use(long,TOID,SYMID&);
        /// tr\"agt toid in die Menge der TOID's ein, die symid benutzen.
  int mark_use(TOID,SYMID);
        //schreibt ein neues Symbolfile ohne "Luecken"
  int save(char*);
        /// legt, falls n\"otig, einen neuen Eintrag an und gibt den zu label passenden SYMID zur\"uck
  int create(char*,SYMID&);
        /** L\"oscht toid aus den zum label geh\"orenden Eintrag, wird der Eintrag danach nicht mehr
          benutzt wird der Eintrag gek\"oscht
          */
  int destroy(char*,TOID);
        /** L\"oscht toid aus dem Eintrag SYMID, wird der Eintrag danach nicht mehr
          benutzt wird der Eintrag gek\"oscht
          */
  int del(SYMID,TOID);
        //Loescht den symid aus der Symboltabelle, falls in ihm keine toid-referenzen existieren
  int del(SYMID);
        /// liefert den zu label geh\"orenden SYMID
  int get_symb(char*,SYMID&);
        /** kopiert den zu symid geh\"orenden Label nach label
          @param symid der SYMID, dessen Label gesucht ist
          @param label ein Feld das gro\3 genug sein muss um den Label auzunehmen
          */
  int get_name(SYMID,char*);
        /// liefert die TOID-Menge der TOID's die den angegebenen Label benutzen
  int name_uses(char*,TOIDSET&);
        /// liefert die TOID-Menge der TOID's die den SYMID benutzen
  int symb_uses(SYMID,TOIDSET&);
        /// liefert alle TOID's auf die der mit * angegebene Label pa\3t
  int star_search(char*, TOIDSET&);
        /// liefert einen Zeiger auf die TOID-Menge der TOID's die den angegebenen Label benutzen
  TOIDSET* name_uses(char*);
        /// liefert einen Zeiger auf die TOID-Menge der TOID's, die den angegebenen SYMID benutzen
  TOIDSET* symb_uses(SYMID);
        /** benennt den Label von symid um. Ist der neue Label bereits in der Symboltabelle enthalten
          schl\"agt die Operation fehl.
          */
  int rename(char*,SYMID);
        /// liefert eine Menge aller Telos-Objekte, die Attribute sind. 
  void get_attributes(TOIDSET&);
        /// liefert die Menge aller Telos-Objekte, die Individuals sind
  void get_individuals(TOIDSET&);
        /// Testfunktion
  void show_set();
};


#endif

