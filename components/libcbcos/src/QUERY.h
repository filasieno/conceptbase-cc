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

#include "TOIDSETSTL.h"
#include "TOID.h"
#include "SYMID.h"
#include "TIMEPOINT.h"
#include "SYMTBL.h"
#include "Literals.h"
#include "TDB.defs.h"

/** Query to the object store.
  
    Each retrieve\_proposition or prove\_literal query creates an instance of QUERY.
    The instance invokes the computation rule or may compute the result itself,
    caches the solutions (or a superset) and provides a method to retrieve them one by one.

    There are 8 different QUERY subclasses. They differ basically only in the set method.
    The only exception is AQUERY, which returns a solution set that is not in the
    object store but was newly created. It also has a next method (to skip validity checking)
    and a destructor (to free the solution memory).

    */

class QUERY {
public:
        /// solution set
    TOIDSETSTL space;
        /// search time point
    TIMEPOINT time;
        /// module in which the solution should lie
    TOID module;
        /// flag indicating whether module inheritance is considered (1) or not (0)
    int strict;
        /// search space (akt, tmp, ....)
    int searchspace;
        /// id component of the query (for retrieve\_proposition)
    TOID id;
        /// src component of the query (for retrieve\_proposition)
    TOID src;
        /// dst component of the query (for retrieve\_proposition)
    TOID dst;
        /// label component of the query (for retrieve\_proposition)
    SYMID label;
        /** label as C string
          (needed to generate a dummy response if no solutions were found)
          */
    char *slabel;
        /// search pattern (bit mask: bit=1 means component is free)
    int	Pattern;
        /// running index into space
    TOIDMap::iterator i;		// search-index
        /// Flag indicating whether solutions have already been queried
    int	start;		// start-flag
         /// Flag indicating whether solutions must be checked for validity at the search time point
    int	ishist;		// history-flag
    

        /// Constructor
    QUERY();
        /// Destructor
    virtual ~QUERY();
    
        /** Returns the next result of the query.
          @param found TOID of the result, if present
          @return 1 if a result was found, 0 otherwise
          */
    virtual int next(TOID&);
        /** Returns a TOID with the id component of the query, if this was set.
          @param toid TOID of Id, if present
          @return 1 if Id was set, 0 otherwise \\
          This function is used to build a pseudo-solution when next returns 0.
          This is necessary, because otherwise the Prolog interface returns an error.
          */
    int DummyId(TOID&);
        /** Returns a TOID with the source component of the query, if this was set.
          @param toid TOID of Src, if present
          @return 1 if Src was set, 0 otherwise \\
          This function is used to build a pseudo-solution when next returns 0.
          This is necessary, because otherwise the Prolog interface returns an error.
          */
    int DummySrc(TOID&);
        /** Returns a TOID with the Dst component of the query, if this was set.
          @param toid TOID of Dst, if present
          @return 1 if Dst was set, 0 otherwise \\
          This function is used to build a pseudo-solution when next returns 0.
          This is necessary, because otherwise the Prolog interface returns an error.
          */
    int DummyDst(TOID&);
        /** Returns the string of the query label, if it was set.
          @param s pointer to a buffer large enough to hold the string
          @return 1 if label was set, 0 otherwise \\
          This function is used to build a pseudo-solution when next returns 0.
          This is necessary because otherwise the Prolog interface returns an error.
          */
    int DummyLab(char*);
        /** Returns a TOID with Id 1 - component of the query, if this was set.
          @param toid TOID of Id 1, if present
          @return 1 if Id 1 was set, 0 otherwise \\
          This function is used to build a pseudo-solution when next returns 0.
          This is necessary, otherwise the Prolog interface returns an error.
          */
    int DummyId1(TOID&);
        /** Returns a TOID for the query's Id-2 component, if it was set.
          @param toid TOID of Id 2, if present
          @return 1 if Id 2 was set, 0 otherwise \\
          This function is used to build a pseudo-solution when next returns 0.
          This is necessary because otherwise the Prolog interface returns an error.
          */
    int DummyId2(TOID&);
        /** Returns a TOID with the CC component of the query, if this was set.
          @param toid TOID of CC, if present
          @return 1 if CC was set, 0 otherwise \\
          This function is used to build a pseudo-solution when next returns 0.
          This is necessary because otherwise the Prolog interface returns an error.
          */
    int DummyCC(TOID&);
        /** Returns a TOID with the module component of the query, if this was set.
          @param toid TOID of module, if present
          @return 1 if module was set, 0 otherwise \\
          This function is used to build a pseudo-solution when next returns 0.
          This is necessary, because otherwise the Prolog interface returns an error.
          */
    int DummyModule(TOID&);
        /// Returns the search pattern
    int ask_pattern() { return Pattern; };
    
//    void done();
        /// test function
    void test();
};

// Query for 2-ary literals
class QUERY2:public QUERY
{
    public: 
    virtual void set(int,TIMEPOINT,TOID,TOID,TDB*,int,TOID,int)=0;
};

// Query for 3-ary literals
class QUERY3:public QUERY
{
    public: 
    virtual void set(int,TIMEPOINT, TOID, SYMID,char*, TOID, int,
                     TOID, int)=0;
};

// Query for 4-ary literals (Adot,P)
class QUERY4a:public QUERY
{
    public: 
    virtual void set(int,TIMEPOINT,TOID,TOID,SYMID,char*,TOID,TDB*,int,TOID,int)=0;    
};
// Query for 4-ary literals, second version (ALabel)
class QUERY4b:public QUERY
{
    public: 
    virtual void set(int,TIMEPOINT,TOID,SYMID,char*,SYMID,char*,TOID,int,TOID,int)=0;    
};

// Query for star search
class QUERY1:public QUERY
{
    public:
    virtual void set(int,TIMEPOINT,char*,SYMTBL*,TOID,int)=0;    
};


// QUERY for a PLiteral
class PQUERY:public QUERY4a 
{
     /** Initializes the instance as a retrieve\_proposition query.
         @param whatset search set
         @param ntime search time point
         @param nmodule search module
         @param nstrict consideration of module inheritance
         @param nid ID component
         @param nsrc src component
         @param nlabel label component as SYMID
         @param nslabel label component as C string
         @param ndst dst component
         @param nPattern search pattern
     */
public:
    virtual void set(int,TIMEPOINT,TOID,TOID,SYMID,char*,TOID,TDB*,int,TOID,int);
    
};


class attrSQUERY:public QUERY2
{
    public:
    virtual void set(int, TIMEPOINT, TOID, TOID,TDB*, int, TOID, int);
     /** Initializes the instance as a prove\_literal(Attr\_s) query.
         @param whatset search set
         @param ntime search time point
         @param id1 1st component
         @param id2 2nd component (Dummy)
         @param nPattern search pattern
         @param nmodule search module
         @param nstrict consideration of module inheritance\\
     */
};

class inSQUERY:public QUERY2
{
    public: 
    virtual void set(int, TIMEPOINT, TOID, TOID,TDB*, int, TOID, int);
     /** Initializes the instance as a prove\_literal(In\_s) query.
         @param whatset search set
         @param ntime search time point
         @param id1 1st component
         @param id2 2nd component
         @param nPattern search pattern
         @param nmodule search module
         @param nstrict consideration of module inheritance\\
     */ 
};

class inIQUERY:public QUERY2
{
    public:
    virtual void set(int, TIMEPOINT, TOID, TOID,TDB*,int ,TOID,int);
        /** Initializes the instance as a prove\_literal(In\_s) query.
          @param whatset search set
          @param ntime search time point
          @param id1 1st component
          @param id2 2nd component
          @param nPattern search pattern
          @param nmodule search module
          @param nstrict consideration of module inheritance\\
        */ 
};

class SystemQUERY:public QUERY2
{
    public: 
    virtual void set(int, TIMEPOINT, TOID, TOID,TDB*, int, TOID, int);
    /** Initializes the instance as a prove\_literal(In\_o) query (system-in)
          @param whatset search set
          @param ntime search time point
          @param x 1st component
          @param c 2nd component
          @param nPattern search pattern
          @param db pointer to the database
          @param nmodule search module
          @param nstrict consideration of module inheritance
    */
};

class AdotQUERY:public QUERY4a
{
    virtual void set(int,TIMEPOINT, TOID, TOID, SYMID, 
		     char*, TOID,TDB*, int,TOID, int);
        /** Initializes the instance as a prove\_literal(Adot)
          @param whatset search set
          @param ntime search time point
          @param cc Concerned Class
          @param x X component
          @param ml meta-label as SYMID
          @param helpml meta-label as C string
          @param y Y component
          @param nPattern search pattern
          @param nmodule search module
          @param nstrict consideration of module inheritance \\

          QUESTION: Why does Adot come without a pointer to the database?
          ANSWER: All query methods are invoked from the database
                   Trans passes the created query on to TDB.
          */ 
};


class AidotQUERY:public QUERY4a
{
    virtual void set(int,TIMEPOINT, TOID, TOID, SYMID,
                     char*, TOID,TDB*, int,TOID, int);
        /** Initializes the instance as a prove\_literal(Adot)
          @param whatset search set
          @param ntime search time point
          @param cc Concerned Class
          @param x X component
          @param ml meta-label as SYMID
          @param helpml meta-label as C string
          @param y Y component
          @param nPattern search pattern
          @param nmodule search module
          @param nstrict consideration of module inheritance \\

          QUESTION: Why does Adot come without a pointer to the database?
          ANSWER: All query methods are invoked from the database
                   Trans passes the created query on to TDB.
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

