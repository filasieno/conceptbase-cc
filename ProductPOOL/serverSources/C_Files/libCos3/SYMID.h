/*
The ConceptBase.cc Copyright

Copyright 1987-2023 The ConceptBase Team. All rights reserved.

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
/**************************************************************
*
*   SYMID.h
*
*   Creation:      15.5.1993
*   Created by:    Thomas List
*   last Change:   7.7.1993
*   Changed by:    Thomas List
*   Version 0.1
*
*
***************************************************************/

#ifndef _SYMID
#define _SYMID

#include "TOIDSETSTL.h"
#include <stdio.h>
#include <string.h>

#define NONE 0
#define ISA 1
#define INSTANCEOF 2
#define UNDEF -1
/* the undef is used if the information about the label is not there*/


/** Ein Symboltabelleneintrag.
 */
class SYMBOL {
private:
        /// Label
    char *name;
        /// Quersumme der Character von name (schnellere ueberpruefung)
    int quersumme;
        /// Menge der TOID's die diesen Label benutzen
    TOIDSETSTL uses;
    
    /// Id des Symboltabelleneintrags
    long id;
        /// Position des Symboltabelleneintrags im File
    long filepos;
 public:
        /// Erzeugt einen neuen Eintrag mit dem angegebenen Label 
   SYMBOL(char*);
        /// L\"oscht den Eintrag
   ~SYMBOL();
        /// ersetzt den alten Label durch den neu angegebenen Label
   int rename(char*);
        /// f\"ugt den TOID in die uses-Menge ein
   int add(TOID);
        /// l\"oscht den TOID aus der uses-Menge
   int del(TOID);
        /// liefert die L\"ange des Labels
   int get_length();
        /// kopiert denLabel in das angegebene char-Feld
   int get_name(char*) const;
     ///liefert die quersumme von name zurueck
    int get_sum() const;
        /// liefert einen Zeiger auf den Label
   char *get_name() { return name; };
        /// liefert den Typ des Labels (instanceof, isa oder none)
   int get_type();
        /// liefert einen Zeiger auf die uses-Menge
   TOIDSETSTL* get_uses();
        /// liefert die uses-Menge
   int get_uses(TOIDSETSTL&);
        /// liefert 1, falls die uses-Menge leer ist
   int empty();
        /// liefert den Id des Eintrags
   long getid();
        /// setzt den Id des Eintrags
   long setid(long);
        /// setzt die Position im File des Eintrags
   long setfilepos(long);
        /// liefert die Fileposition des Eintrags
   long getfilepos();
        /// Testfunktion
   void test();
};

/** Symboltabelleneintrags-ID.
  Analog zu TOID ist SYMID ein Zeiger auf einen Symboltabelleneintrag.
  @see TOID
  */
class SYMID {
  private:
        /// Der Symboltabelleneintrag
    SYMBOL *SymbolObj;
  public:
        /// legt einen neuen Symboltabelleneintrag mit den angegebenen Label an
    SYMID(char*);
        /** ich hoffe das wird nicht benutzt \\
          REWORK: raus damit
          */
    SYMID(TOID);
        /// erzeugt einen neuen SYMID mit dem gleichen Eintrag wie der des Parameters
    SYMID( const SYMID&);
//    SYMID( SYMID&);
        /// erzeugt einen SYMID ohne Symboltabelleneintrag
    SYMID();
        /// rename on SYMBOL
    int rename(char*);
        /// add von SYMBOL
    int add(TOID);
        /// del von SYMBOL
    int del(TOID);
        /// destroy von SYMBOL
    int destroy();
        /// empty von SYMBOL
    int empty();
        /// setfilepos von SYMBOL
    long setfilepos(long);
        /// getfilepos von SYMBOL
    long getfilepos();
        /// setid von SYMBOL
    long setid(long);
        /// getid von SYMBOL
    long getid();
        /// get\_uses von SYMBOL
    TOIDSETSTL* get_uses();
        /// get\_uses von SYMBOL
    int get_uses(TOIDSETSTL&);
        /// get\_length von SYMBOL
    int get_length();
        ///liefert die quersumme von SYMBOL
    int get_sum() const;
        /// get\_name von SYMBOL
    int get_name(char*);
        /// get\_name von SYMBOL
    char *get_name() const { return (SymbolObj)?SymbolObj->get_name():(char*)NULL; };
        /// get\_type von SYMBOL
    int get_type();
        /// erzeugt einen String f\"ur die OB.telos - Datei und speichert in im angegebenen Feld
    int get_savestring(char*);
        /// Zuweisungsoperator
    SYMID& operator = (const SYMID&);
        /// Vergleichsoperator (vergleicht Alphabetisch)
    int operator == (const SYMID&);
        /// Vergleichsoperator (vergleicht Alphabetisch)
    int operator <= (const SYMID&);
    void test(){SymbolObj->test();};
};

inline bool operator<(const SYMID& t1,const SYMID& t2)

{
    if (!t1.get_name() || !t2.get_name()) return 0;
    return (strcmp(t1.get_name(),t2.get_name()) < 0);
};

#endif

