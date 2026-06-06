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


/** Telos object ID.
  A TOID instance is essentially a pointer to a Telos object (TOBJ). All access to the
  Telos object goes through the TOID class. There can be several TOIDs for one Telos object.
  If all TOIDs pointing to a TOBJ are deleted, the Telos object can no longer be found and
  blocks memory. In particular, the destructor does not free the Telos object's memory!
  Almost all TOBJ methods are reachable through TOID.
  */
class TOID {
        /// pointer to the Telos object
    class TOBJ* TelosObj;
public:
        /// Constructor
    TOID () { TelosObj = 0; };
        /// Sets the pointer value to the numeric value of the parameter
    void set(long);
        /// The pointer value is returned as a long value
    long get();
        /// output of the values
    void test();
        /// Creates a new Telos object with the given ID
    void create(long);
        /// Deletes the Telos object from memory
    void destroy();

        /// Sets the ID of the Telos object
    void SetId (long );
        /// returns the ID of the Telos object
    long GetId ()const;
        /** Stores the OID of the Telos object in s\\
          QUESTION: is this necessary?
          */
    void GetOid(char *s);
        /// Calls Update\_index on the Telos object
    void Update_index(int, TOID);
        /// Calls Del\_index on the Telos object
    void Del_index(int, TOID);

        /// Inserts the object into the index structure
    void Connect();
        /// Removes the object from the index structure
    void Disconnect();

        /// Equality comparison: true when both TOIDs point to the same Telos object
    int identical( TOID toid ) { return TelosObj == toid.TelosObj; };

        /// Assignment operator
    TOID& operator=( TOID );
        /// Comparison operator (compares the IDs of the objects)
    int operator==( TOID );
        /// Comparison operator (compares IDs)
    int operator==( TOBJ* );
        /// Less-than-or-equal operator (compares IDs)
    int operator <= (TOID);


    // Functions equivalent to TOBJ

        /// Update on TOBJ
    void Update(TOID,TOID);
        /// Update on TOBJ
    void Update(long,long);
        /// Update\_StartTime on TOBJ
    void Update_StartTime(TIMEPOINT);
        // Update\_EndTime on TOBJ
    void Update_EndTime(TIMEPOINT);
        /// Update\_Label on TOBJ
    void Update_Label(class SYMID&);
        /// SetTemp on TOBJ
    void SetTemp(int);
        /// UnsetTemp on TOBJ
    void UnsetTemp();

        /// Src on TOBJ
    TOID Src ();
        /// Dst on TOBJ
    TOID Dst ();
        /// Lab on TOBJ
    SYMID Lab ();
        /// Valid on TOBJ
    class TIMELINE Valid ();
        /// is\_valid on TOBJ
    int is_valid(TIMEPOINT, int);
        /// is\_valid on TOBJ
    int is_valid(TIMEPOINT, int, TOID);
        /// is\_valid on TOBJ
    int is_valid(TIMEPOINT, int, TOID, int, int);
        /// is\_strictly\_valid on TOBJ
    int is_strictly_valid(TIMEPOINT, int, TOID);
        /// STime on TOBJ
    class TIMEPOINT STime();
        /// ETime on TOBJ
    class TIMEPOINT ETime();

        /// IofI on TOBJ
    class TOIDSETSTL& IofI ();
        /// IofO on TOBJ
    class TOIDSETSTL& IofO ();
        /// IsaI on TOBJ
    class TOIDSETSTL& IsaI ();
        /// IsaO on TOBJ
    class TOIDSETSTL& IsaO ();
        /// AtrI on TOBJ
    class TOIDSETSTL& AtrI ();
        /// AtrO on TOBJ
    class TOIDSETSTL& AtrO ();
    
        /*
         * for the modulee
         */

        /// SetSystemModule on TOBJ
    void SetSystemModule(TOID);
        /// Update\_Module on TOBJ
    void Update_Module(TOID);
        /// Update\_Module on TOBJ
    void Update_Module(long);
        /// GetModule on TOBJ
    class TOID GetModule();
        /// SetModule on TOBJ
    int SetModule();
        /// UnsetModule on TOBJ
    int UnsetModule();
        /// Contains on TOBJ
    class TOIDSETSTL& Contains();
        /// Export on TOBJ
    class TOIDSETSTL& Export();
        /// Import on TOBJ
    class TOIDSETSTL& Import();
        /// NewExport on TOBJ
    int NewExport(TOID);
        /// DeleteExport on TOBJ
    int DeleteExport(TOID);
        /// NewImport on TOBJ
    int NewImport(TOID);
        /// DeleteImport on TOBJ
    int DeleteImport(TOID);
 };

inline bool operator<(const TOID& t1,const TOID& t2)

{  
    return t1.GetId()<t2.GetId();
};

#endif
