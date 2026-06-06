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
*   Version 0.1
*
*
**********************************************************************/

#ifndef _SYMTBL
#define _SYMTBL


#include <fstream>
#include <stdlib.h>
#include <string.h>

#include "SYMID.h"
#include "SYMIDSTLSET.h"
#include "longSETSTL.h"
#include "TOID.h"
#include "SYMIDREF.h"
#include "SYMIDREFHashSet.h"

#include "secure_put.h"

#define NONPERSISTENT 0
#define PERSISTENT 1
#define MAXPERSISTENCYLEVEL 1

/** Symbol table.
   The symbol table stores all label entries occurring in the database.
   Each entry also has an index set listing the TOIDs that use this label.
   */
class SYMTBL {

private:
        /// flag indicating whether the symbol table is open
  int open;                    // indicates if a file is opened
        /// the actual symbol set
  SYMIDSTLSET symbols;
        /** Hash table used when loading the symbol table to convert symbol numbers
          into SYMIDs. The hash table is removed after loading.
          */
  SYMIDREFHashSet *idtable;
        /** Set of unused entries - because entries have different lengths,
          new labels are always appended at the end!
          */
  longSETSTL unused_filepos;
        /// file stream
  fstream symfile;
        /// number of entries
  long filesize;
        // next SYMID to assign
  long nextID;

  char *symfilename;

        /// specifies whether the database has to be maintained persistently
  int persistency_level;

  public:

        /// Constructor: opens the given file as symbol table
  SYMTBL(char*);
        /// Constructor: initializes the symbol table - filename still missing
  SYMTBL();
        /// Destructor
  ~SYMTBL();
        // destroy because destructor may not be called
  void destroy();
        /// Loads the given file as symbol table
  int load(char*);
        /// removes the hash table
  int load_done();
        /** inserts the TOID into the set of TOIDs that use the symbol table entry
          register TOID id and return a SYMID for this entry. Used when
          loading.
          @param id id of the symbol table entry (as it appears in the .telos file)
          @param toid TOID using this label
          @param symid return value: SYMID for the label id
          */
  int use(long,TOID,SYMID&);
        /// inserts toid into the set of TOIDs that use symid.
  int mark_use(TOID,SYMID);
        // writes a new symbol file without gaps
  int save(char*);
        /// creates, if necessary, a new entry and returns the SYMID matching label
  int create(char*,SYMID&);
        /** Deletes toid from the entry belonging to the label; the entry is no longer there after that
          used it is deleted
          */
    int destroy(char*,TOID);
        /** Deletes toid from the SYMID entry; if no longer used the entry is deleted
          */
  int del(SYMID,TOID);
        // Deletes symid from the symbol table if it contains no TOID references
  int del(SYMID);
        /// returns the SYMID belonging to label
  int get_symb(char*,SYMID&);
        /** Copies the label belonging to symid into label
          @param symid the SYMID whose label is requested
          @param label a buffer large enough to hold the label
          */
  int get_name(SYMID,char*);
        /// Returns the set of TOIDs that use the given label
  int name_uses(char*,TOIDSETSTL&);
        /// returns the TOID set of TOIDs that use the SYMID
  int symb_uses(SYMID,TOIDSETSTL&);
        /// returns all TOIDs matching the label specified with *
  int star_search(char*, TOIDSETSTL&);
        /// returns a pointer to the TOID set of TOIDs that use the specified label
  TOIDSETSTL* name_uses(char*);
        /// returns a pointer to the TOID set of TOIDs that use the given SYMID
  TOIDSETSTL* symb_uses(SYMID);
        /** Renames the label of symid. If the new label is already in the symbol table,
          the operation fails.
          */
    int rename(char*,SYMID);
        /// Returns a set of all Telos objects that are attributes.
  void get_attributes(TOIDSETSTL&);
        /// returns the set of all Telos objects that are individuals
  void get_individuals(TOIDSETSTL&);
        /// test function
  void show_set();
        /// sets persistency level
  void set_persistency_level(int);
        /// returns persistency level
  int get_persistency_level();
	/// return the next free identifier to be used by the symbol table
  long get_nextID();
};




#endif

