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

#define VERSION_ID "ConceptBase object store Version %3d.%2d\n"
/*
 *   The Disk-Offset is the strlen of VERSION_ID (including \n)
 *
 */

#define DISK_OFFSET 42


/** IO class for TOID.

  Represents a TOID as a string. This string is used when storing data to disk.
  */
class TOIO
{
        /// strings representing the TOID
    char idChar[4],srcChar[4],dstChar[4],labelChar[4],StartTimeChar[4];
    char StartTimeUChar[2],EndTimeChar[4],EndTimeUChar[2],moduleChar[4],setChar[4];

private:
   // helper functions for binary read/write to disk
    void long2string(long, char*);
        // converts long byte-wise to char* without termination
    void string2long(char*,long&);
        // converts char byte-wise to long
    void short2string(short,char*);
    void string2short(char*,short&);


public:
        /// Constructor - creates a neutral string (all entries -1)
    TOIO();
        /** Constructor - creates a string for
          @param toid that lies in search set
          @param set (akt, hist,...)
          */
    TOIO(TOID,int);
        /// Clears the string, i.e. creates the neutral string (all entries -1)
        // creates a new string from the given values
    TOIO(long,long,long,long,long,short,long,short,long,int);

    void clear();
        /** Reads the string data and creates a corresponding TOBJ.
          @param id    ID of the new object
          @param toid  TOID for the new object
          @param label symbol table reference of the new object
          @param set   search space
          @return 0 if the string is the neutral string (Id = -1), 1 otherwise\\

          The pointer values of src and dst TOIDs are set to the long values of the IDs
          (src should point to id\_101 => src.*TheObject = 101). In this state any access
          that references the pointer causes an immediate crash!
          */
    int get(long&, TOID&, long&, int&);
};

fstream& operator << (fstream&, TOIO);
fstream& operator >> (fstream&, TOIO&);

/** Database object.\\

  An instance of this class is a complete Telos database. Currently only one instance should exist.
  All external requests to the object store are handled by this class. All Telos objects in the
  database have exactly one entry in one of the sets akt, hist, tmp1, tmp2 or tmp3.
  */
class TDB {
        /// Set of currently valid (non-temporary) objects, i.e. objects with infinite end time
    TOIDSETSTL akt;
        /** Set of objects inserted during the current transaction into the database
           (except objects from tmp3)
           */
    TOIDSETSTL tmp1;
        /// Set of objects deleted during the current transaction.
    TOIDSETSTL tmp2;
        /** Set of objects implicitly created during the current transaction,
          i.e. created to preserve referential integrity. If such an object is
          subsequently registered regularly, it is moved to tmp1
          */
    TOIDSETSTL tmp3;
        /// Set of deleted (non-temporary) objects, i.e. objects with finite end time
    TOIDSETSTL hist;
        /// Hash table mapping IDs as used in ConceptBase to TOIDs
    TOIDREFHashSet *toidtable;
        /// Symbol table; all label entries of Telos objects are managed here
    SYMTBL Symbols;

        /// Search space (akt, tmp, ...) for the following queries
    int next_search_space;
        /** Search space for the next query only; allows temporarily changing the search space
          without modifying next\_search\_space.
          */
    int overrule_search_space;

        /** Time point for the next search queries; a Telos object must be valid at this time
          to be a solution of the query.
          */
    TIMEPOINT next_search_time;
        /** Transaction time; new Telos objects get this as start time, deleted
          Telos objects get this as end time.
          */
    TIMEPOINT transaction_time;
        /// Largest ID occurring in the database
    long MaxID;
        /** Set of unused IDs. These IDs can arise when Telos objects are removed from
          the database (not ConceptBase deletion). When new objects are created,
          IDs from this set are reassigned first
          */
    longSETSTL unused_ID;

        /// Stream over which Telos objects are written to or read from disk
    fstream telosfile;

        /// Statistics object
    Statistics stats;

      /*
       *
       *  for modules
       *
       */

        /** The system module. The system module has special meaning in the module concept
          and must be known. See module documentation.
          */
    TOID system_module;
        /// Module in which results of the following queries must be visible
    TOID next_module;
        /// Overrides the search module for the next query
    TOID overrule_module;
        /// Flag indicating whether overrule\_module is set
     int is_overrule_module;




  public:
    /*
    *   constructor/destructor
    */

        /// Constructor: initializes variables and creates the hash table
    TDB();
        /** Destructor: removes the hash table and deletes all Telos objects over the
          search sets
          */
    ~TDB();

    /*
    *  open/close telos-database
    */

        /** Loads a database from disk.


           If the Telos file does not exist it is created and the version string is written.\\

           TODO: Version number check is still missing!!!!\\

           Otherwise data are read line by line using the TOIO class. Newly created TOIDs are
           inserted into the corresponding sets. Because no temporary data can be stored,
           only the akt and hist sets are used.\\

           Afterwards all data are briefly united in a set (helpset) to build the index structure.
           In particular long values in src and dst are replaced by pointers.

           The system module is assumed to be the module containing Proposition. If this
           module has id 0, name2toid is used to search for label System. If this search
           fails the program exits! If the system module is not valid at the current time,
           loading is aborted as well.

           @param name name and path of the database (e.g. ...../database/OB). Suffixes .telos
           and .symbol are appended to load the Telos and symbol table files.
           @return 1 on success, 0 on error. Possible errors: filename too long (max 190 chars),
           symbol table could not be loaded, or version check failed.
           */
    int open( char* );

        /// seems redundant -> TODO
    int close();

    /*
    *  convert internal formats to strings
    */
        /** Forwards to SYMTBL. Computes a SYMID for a label
          @param s the label
          @param symid the SYMID
          */
    int get_symb(char*,SYMID&);
        /** Forwards to SYMTBL. Computes the label for a TOID
          @param toid the TOID
          @param s the label
          */
    int toid2name( TOID, char*);
        /** Computes a TOID for a given label.
          Uses the configured search time point and module. Computation is in name2toid(char*, TOID&, TOID).
          @param s the label as C string
          @param toid the result
          */
    int name2toid( char*, TOID&);
        /** Computes a TOID for a given label.\\
          Unique for individuals; for attributes the first valid solution is taken. Search has three parts:
          first in the given module and system module (important for frequent Class/QueryClass queries),
          then imports and exports, then nested modules recursively.
          @param s the label as C string
          @param toid the result
          @param module the module
          @return 1 if toid found, 0 otherwise
          */
    int name2toid( char*, TOID&,TOID);
        /** Computes matching valid TOIDs for a given label across all modules.
          @param s the label as C string
          @param toidset the result set
          @return 1 if TOID was found, 0 otherwise
          */
    int name2toidset( char*, TOIDSETSTL&);
        /** Computes a TOID for a given label. Unlike name2toid, checks whether
          the TOID is in tmp3. If so the TOID is moved from tmp3 to tmp1. Thus implicitly
          told objects become explicitly told objects.\\
          QUESTION: can this function work without module?
          @param s the label as C string
          @param toid the result
          @return 1 if TOID was found, 0 otherwise
          */
    int create_name2toid( char*, TOID&);
        /** Computes the OID representation for ConceptBase (id\_<nr>).
          @param toid the TOID
          @param s the string that should hold the result. The buffer must be large enough.
          */
    void toid2oid( TOID, char*);
        /** Converts an OID (id\_<nr>) to a TOID using the hash table.
          @param s the OID as C string
          @param toid the result
          */
    int oid2toid( char*, TOID&);
        /** Computes the matching TOID for an OID. Additionally a found solution
          may be moved from tmp3 to tmp1. This enables handling of implicit tells.\\
          QUESTION: should oid2toid or name2toid or both be used now?
          @param s the OID as C string
          @param toid the result
          */
    int create_oid2toid( char*, TOID&);
        /** Computes a TOID for a simple select expression (cf. ConceptBase).
          The select expression is given as a string (not the Prolog select() structure),
          must contain no parentheses and only the operators !, -> and =>. This function
          is mainly used to handle attributes with names such as Attribute, InstanceOf, etc.\\
          WARNING: the input string s is modified!!!!\\
          QUESTION: can this be avoided?\\
          QUESTION: what about modules? Attribute validity checks are also missing!
          @param s the select expression
          @param toid the result
          */
    int select2toid(char*, TOID&);
        /** Computes a select expression for a TOID - probably unused.
          QUESTION: is this still needed?
          @param toid the TOID
          @param s string that must hold the result
          */
    int toid2select(TOID,char*);
        /** Checks whether a TOID is implicitly told - i.e. contained in tmp3.
          @param toid the TOID
          @result 1 if yes, 0 otherwise
          */
    int check_implicit(TOID);

    /*
    *  create/delete new objects
    */
        /** Creates a new individual Telos object.
          The new object does not yet receive an ID. Start time is the current transaction
          time and module is the current module.
          @param s label of the new individual
          @return TOID of the new object
          */
    TOID Create_node(char*);
        /** Creates a new attribute Telos object.
          The new object does not yet receive an ID. Start time is the current transaction
          time and module is the current module.
          @param s label of the new attribute
          @param src source component
          @param dst destination component
          @return TOID of the new object
          */
    TOID Create_link(char*, TOID, TOID);
        /** Removes the associated Telos object from memory.
          Updates the symbol table accordingly and removes the Telos object. All other
          TOIDs for this object become invalid; accessing them causes a crash.
          @param toid TOID of the object to delete
          */
    void Destroy(TOID);
        /** Calls the symbol table rename function. Sets the symbol table entry label
          from oldname to newname. Warning: renaming e.g. to *instanceof has catastrophic effects.
          @param newname the new label entry
          @param oldname the label entry to rename
          @return 1 on success, 0 on error (oldname not found or newname already taken)
          */
    int rename(char*,char*);

    /*
    *  insert/delete object to/from telos-database
    */

        /** Inserts a new object into the database. The object should have been created
          with Create\_node or Create\_link. Here it receives its ID and is written to disk.
          The index structure is updated (Connect). Data is written with a temporary marker;
          if the program terminates abnormally, this data is ignored on next load. The TOID
          is inserted into tmp1.
          @param toid the new object
          @return ID of the new object
          */
    long insert(TOID&);
        /** Like insert - but the TOID is inserted into tmp3.
          @param toid the new object
          @return ID of the new object
          @see insert
          */
    long insert_implicit(TOID&);
        /** Commits data from tmp1 to akt. tmp3 should be empty! Data on disk is
          updated, i.e. the set is moved to akt.\\
          TODO: temp flags and end time still need a closer look.
          */
    int insert_commit();
        /** Discards data from tmp1 and tmp3. Index structures must be deleted,
          the object removed, and the hash table updated.
          */
    void insert_abort();

        /** Moves the object from akt to tmp2 and sets a tmp flag.
          @param toid TOID of the object
          */
    int remove( TOID );

        /** The object TOID is removed permanently from tmp1.
           See also ticket #92
          @param toid:  TOID of the object to be removed from tmp1
          */
    int removetmp( TOID );

        /** Makes objects finally historical. In particular updates disk.
          */
    void remove_end();
        /** Moves objects back from tmp2 to akt, i.e. undoes the delete operation.
         */
    void remove_abort();

    /*
    *  search in the database
    */
        /** Sets the search space for the next search operations.
           @param whatset the new search space: bit-or of ACTUAL\_DB, HISTORY\_DB,
           TEMP\_DB\_TELL and TEMP\_DB\_UNTELL.
           */
    void set_search_space( int );
        /** Overrides the search space for the next search operation (unlike set\_search\_space).
          @param whatset the new search space
          @see set_search_space delete_overrules
          */
    void set_overrule_search_space( int );

        /** All set overrules are deleted. This clears overrule\_search\_space
          and overrule\_module.
          @see set_overrule_search_space set_overrule_module
          */
    void delete_overrules();

        /** set the persistency level
          */
    void set_persistency_level( int );


        /** Sets the search time point for the next operations.
          @param whattime the new search time point
          */
    void set_search_time(TIMEPOINT);

    TIMEPOINT get_next_search_time() {return next_search_time;};
    int get_overrule_search_space(){return overrule_search_space;};
    int get_is_overrule_module(){return is_overrule_module;};
    TOID& get_overrule_module(){return overrule_module;};
    TOID& get_next_module(){return next_module;};
    int get_next_search_space(){return next_search_space;};



        /** Starts a retrieve\_proposition search. At search time,
          search set and module as well as overrules are considered.
          @param descriptor a query descriptor that is initialized and then
                  used to query the results
          @param id the ID component; only considered if FREE_ID is not set in pattern
          @param label the label component (as SYMID); only considered if FREE_LAB is not set in pattern
          @param slabel the label as C string
          @param src the src component; only considered if FREE_SRC is not set in pattern
          @param dst the dst component; only considered if FREE_DST is not set in pattern
          @param pattern the search pattern - bit-or combination of
                 FREE\_ID, FREE\_SRC, FREE\_LAB and FREE\_DST
          */
    void start_seek( QUERY4a& , TOID, TOID, SYMID, char*, TOID, int );
        /** Like start_seek with an additional module component. Module inheritance is not
          considered, but search with free module component is possible.
          @param descriptor a query descriptor that is initialized and then
                  used to query the results
          @param id the ID component; only considered if FREE_ID is not set in pattern
          @param src the src component; only considered if FREE_SRC is not set in pattern
          @param label the label component (as SYMID); only considered if FREE_LAB is not set in pattern
          @param slabel the label as C string
          @param dst the dst component; only considered if FREE_DST is not set in pattern
          @param pattern the search pattern - bit-or combination of
                 FREE\_ID, FREE\_SRC, FREE\_LAB and FREE\_DST and FREE\_MODUL
          @param module the module component; only considered if FREE\_MODUL is not set in pattern
          @see start_seek
          */
    void start_seek( QUERY4a& , TOID, TOID, SYMID, char*, TOID, int, TOID );
        /** Starts a 2-ary literal search.
          @param descriptor a query descriptor that is initialized and then
                  used to query the results
          @param id1 first component; only considered if FREE\_ID1 is not set in pattern
          @param id2 second component; only considered if FREE\_ID2 is not set in pattern
          @param pattern the search pattern - bit-or combination of FREE\_ID1 and FREE\_ID2
          @param Whatlit the literal; possible values: In\_s, In\_i and system\_class
        */
    void start_Literal( QUERY2&, TOID, TOID, int, Literals );
        /** Starts a 4-ary literal search.
          @param descriptor a query descriptor that is initialized and then
                  used to query the results
          @param cc CC component; only considered if FREE\_ID is not set in pattern
          @param x X component; only considered if FREE\_SRC is not set in pattern
          @param ml ML component (as SYMID); only considered if FREE\_LAB is not set in pattern
          @param mlhelp meta-label as C string
          @param y Y component; only considered if FREE\_DST is not set in pattern
          @param pattern the search pattern - bit-or combination of
                 FREE\_ID, FREE\_SRC, FREE\_LAB and FREE\_DST and FREE\_MODUL
          @param Whatlit the literal; possible value: Adot
        */
    void start_Literal3( QUERY3&, TOID, SYMID, char*, TOID, int, Literals);
    void start_Literal4( QUERY4b&, TOID, SYMID,char*,SYMID,char*,TOID,int, Literals);
    void start_Literal4( QUERY4a&, TOID, TOID, SYMID, char*, TOID, int, Literals);
        /** Starts a star search.
          @param descriptor a query descriptor that is initialized and then
                  used to query the results
          @param label a label with *
        */
    void start_star( QUERY1&, char*);
        /** Returns one solution of the query descriptor.\\
          Probably redundant!
          */
    int get_tuple(QUERY&,TOID&);
        /** Deinitializes the descriptor.\\
          Probably redundant!
          */
//    void end_seek( QUERY& );

    /*
    *  set time
    */

        /** Sets the transaction time.
          @param now the new transaction time
          */
    void set_transaction_time( TIMEPOINT );


        /** retrieve the start time of an object TOID
          */
    TIMEPOINT query_start_time( TOID );

        /** retrieve the end time of an object TOID
          */
    TIMEPOINT query_end_time( TOID );



    /*
     * for modules
     */

        /** Sets a new system module and registers all objects in that module.
          Used when building the system database. Do not use during normal ConceptBase operation.
          @param system_mod the new system module
          */
    void SystemModule(TOID);
        /** Sets the current module. All following requests refer to this module.
          @param toid the new module
          */
    void set_module(TOID);
        /** Overrides the module context for the next search operation (unlike set\_module).
          @param toid the new module
          @see set_module delete_overrules
          */
    void set_overrule_module(TOID);
        /** Initializes the object given by toid as a module object. Only then
          can it manage imports and exports.
          @param toid the affected object
          */
    void initialize_module(TOID);
        /** Computes the module index structure (imports and exports). Called once
          after loading the database.
          */
    void initialize_modules();
        /** Registers an object as a new export in the current module. Must be an
          attribute link with label export.
          @param toid the object to export
          */
    int new_export(TOID);
        /** Deletes an export of the current module.
          @param toid the export link to delete
          */
    int delete_export(TOID);
        /** Registers an object as a new import in the current module. Must be an
          attribute link with label import.
          @param toid the object to import
          */
    int new_import(TOID);
        /** Deletes an import of the current module.
          @param toid the import link to delete
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


        /// returns the akt set
    TOIDSETSTL & Akt()
    {
        return akt;
    }

        /// returns the tmp1 set
    TOIDSETSTL & Tmp1()
    {
        return tmp1;
    }

        /// returns the tmp2 set
    TOIDSETSTL & Tmp2()
    {
        return tmp2;
    }

        /// returns the tmp3 set
    TOIDSETSTL & Tmp3()
    {
        return tmp3;
    }

        /// Returns the hist set
    TOIDSETSTL & Hist()
    {
        return hist;
    }

        /// returns the symbol table
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
