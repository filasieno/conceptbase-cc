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


/** A symbol table entry.
 */
class SYMBOL {
private:
        /// Label
    char *name;
        /// checksum of the characters of name (faster verification)
    int quersumme;
        /// TOIDs that use this label
    TOIDSETSTL uses;
    
    /// ID of the symbol table entry
    long id;
        /// File position of the symbol table entry
    long filepos;
 public:
        /// Creates a new entry with the specified label 
   SYMBOL(char*);
        /// Deletes the entry
   ~SYMBOL();
        /// Replaces the old label with the newly given label
   int rename(char*);
        /// Inserts the TOID into the uses set
   int add(TOID);
        /// Removes the TOID from the uses set
   int del(TOID);
        /// returns the length of the label
   int get_length();
        /// copies the label into the given char field
   int get_name(char*) const;
     ///returns the checksum of name
    int get_sum() const;
        /// returns a pointer to the label
   char *get_name() { return name; };
        /// returns the type of the label (instanceof, isa or none)
   int get_type();
        /// returns a pointer to the uses set
   TOIDSETSTL* get_uses();
        /// returns the uses set
   int get_uses(TOIDSETSTL&);
        /// returns 1 if the uses set is empty
   int empty();
        /// returns the Id of the entry
   long getid();
        /// Sets the ID of the entry
    long setid(long);
        /// Sets the file position of the entry
   long setfilepos(long);
        /// returns the file position of the entry
   long getfilepos();
        /// Test function
   void test();
};

/** symbol tableneintrags-ID.
  Analogous to TOID, SYMID is a pointer to a symbol table entry.
  @see TOID
  */
class SYMID {
  private:
        /// The symbol table entry
    SYMBOL *SymbolObj;
  public:
        /// Creates a new symbol table entry with the given label
    SYMID(char*);
        /** I hope this is not used \\
          REWORK: remove this
          */
    SYMID(TOID);
        /// Creates a new SYMID with the same entry as the parameter
    SYMID( const SYMID&);
//    SYMID( SYMID&);
        /// Creates a SYMID without a symbol table entry
    SYMID();
        /// rename on SYMBOL
    int rename(char*);
        /// add on SYMBOL
    int add(TOID);
        /// del on SYMBOL
    int del(TOID);
        /// destroy on SYMBOL
    int destroy();
        /// empty on SYMBOL
    int empty();
        /// setfilepos on SYMBOL
    long setfilepos(long);
        /// getfilepos on SYMBOL
    long getfilepos();
        /// setid on SYMBOL
    long setid(long);
        /// getid on SYMBOL
    long getid();
        /// get\_uses on SYMBOL
    TOIDSETSTL* get_uses();
        /// get\_uses on SYMBOL
    int get_uses(TOIDSETSTL&);
        /// get\_length on SYMBOL
    int get_length();
        /// returns the checksum of SYMBOL
    int get_sum() const;
        /// get\_name on SYMBOL
    int get_name(char*);
        /// get\_name on SYMBOL
    char *get_name() const { return (SymbolObj)?SymbolObj->get_name():(char*)NULL; };
        /// get\_type on SYMBOL
    int get_type();
        /// Creates a string for the OB.telos file and stores it in the given field
    int get_savestring(char*);
        /// Assignment operator
    SYMID& operator = (const SYMID&);
        /// Comparison operator (alphabetical)
    int operator == (const SYMID&);
        /// Comparison operator (alphabetical)
    int operator <= (const SYMID&);
    void test(){SymbolObj->test();};
};

inline bool operator<(const SYMID& t1,const SYMID& t2)

{
    if (!t1.get_name() || !t2.get_name()) return 0;
    return (strcmp(t1.get_name(),t2.get_name()) < 0);
};

#endif

