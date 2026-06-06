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
*   SYMTBL.h
*
*   Creation:      15.5.1993
*   Created by:    Thomas List
*   last Change:   7.7.1993
*   Changed by:    Thomas List
*   version 0.1
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
        /** Eine Hash-Tabelle, die zum Laden der Symboltabelle uses is, um Symbolnummern
          in SYMID's umzuwandeln. Die Hashtabelle is nach dem Laden entfernt.
          */
  SYMIDREFCHSet *idtable;
        /** Menge der unbenutzten Eintr\"age - da die Eintr\"age jedoch unterschiedliche L\"ange
          habe can are new Labels always hinten angeh\"angt!
          */
  longAVLSet unused_filepos;
        /// file-stream
  fstream symfile;
        /// number of Eintr\"age
  long filesize;
        //die next zu vergebende SymID
  long nextID;

  char *symfilename;
    
  public:
        /// constructor: \"oeffnet die Angegebene file als Symboltabelle
  SYMTBL(char*);
        /// constructor: initialistert die Symboltabelle - es fehlt still ein filename
  SYMTBL();
        /// Destruktor
  ~SYMTBL();
        //because destructor not aufgerufen is, destroy
  void destroy();
        /// L\"ad dieangegebene file als Symboltabelle
  int load(char*);
        /// l\"oscht die Hash-Tabelle
  int load_done();
        /** tr\"agt den TOID in die Menge der TOID's ein, die den Symboltabelleneintrag
          Nr. id use and returns a SYMID auf diesen Eintrag return. Wird beim
          Laden needed.
          @param id Id des Symboltabelleneintrags (wie er im .telos-file steht)
          @param toid der TOID, der diesen Label benutzt
          @param symid  R\"uckgabewert: SYMID zum Label-Id
          */
  int use(long,TOID,SYMID&);
        /// tr\"agt toid in die Menge der TOID's ein, die symid use.
  int mark_use(TOID,SYMID);
        //schreibt ein neues Symbolfile without "Luecken"
  int save(char*);
        /// legt, if n\"otig, einen neuen Eintrag an and gives den zu label matchingn SYMID return
  int create(char*,SYMID&);
        /** L\"oscht toid from den zum label geh\"orenden Eintrag, is der Eintrag after that not more
          uses is der Eintrag gek\"oscht
          */
  int destroy(char*,TOID);
        /** L\"oscht toid from dem Eintrag SYMID, is der Eintrag after that not more
          uses is der Eintrag gek\"oscht
          */
  int del(SYMID,TOID);
        //Loescht den symid from der Symboltabelle, if in ihm no toid-referenzen existieren
  int del(SYMID);
        /// returns the zu label geh\"orenden SYMID
  int get_symb(char*,SYMID&);
        /** kopiert den zu symid geh\"orenden Label nach label
          @param symid der SYMID, dessen Label gesucht ist
          @param label ein Feld das gro\3 genug sein must um den Label auzunehmen
          */
  int get_name(SYMID,char*);
        /// returns the TOID-Menge der TOID's die den angegebenen Label use
  int name_uses(char*,TOIDSET&);
        /// returns the TOID-Menge der TOID's die den SYMID use
  int symb_uses(SYMID,TOIDSET&);
        /// returns alle TOID's auf die der with * angegebene Label pa\3t
  int star_search(char*, TOIDSET&);
        /// returns a pointer auf die TOID-Menge der TOID's die den angegebenen Label use
  TOIDSET* name_uses(char*);
        /// returns a pointer auf die TOID-Menge der TOID's, die den angegebenen SYMID use
  TOIDSET* symb_uses(SYMID);
        /** benennt den Label of symid um. Ist der new Label already in der Symboltabelle enthalten
          schl\"agt die Operation fehl.
          */
  int rename(char*,SYMID);
        /// returns ae Menge aller Telos objecte, die attributee are. 
  void get_attributes(TOIDSET&);
        /// returns the Menge aller Telos objecte, die Individuals sind
  void get_individuals(TOIDSET&);
        /// Testfunktion
  void show_set();
};


#endif

