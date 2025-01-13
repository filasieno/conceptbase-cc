/*
The ConceptBase.cc Copyright

Copyright 1987-2025 The ConceptBase Team. All rights reserved.

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
#include "QUERY.h"

QUERY::QUERY ()
{
    slabel = NULL;
}

QUERY::~QUERY ()
{
    space.clear();
    if (slabel) delete[] slabel;
}

 int QUERY::next(TOID &found)
{
  /*
  *  get search-items
  */
  	TOID current;
    if (start)  		// start-flag:
	{
	    i = space.begin();	// get first item
	    start = 0;		// clear start flag
	}
    else i++;		// get next item

    if(i!= space.end())
		current=(*i).second;

    if (Pattern & FREE_MODULE) {
	while ((i != space.end())?!current.is_valid(time,searchspace):0)
	{
	    i++;
	    current=(*i).second;
	}
    }
    else if (strict)
    {

	while ((i != space.end())?!current.is_strictly_valid(time,searchspace,module):0)
	{
	    i++;
	    current=(*i).second;
	}
    }
    else
    {
	while ((i != space.end())?!current.is_valid(time,searchspace,module):0)
	{
	    i++;
	    current=(*i).second;
	}
    }

    if (i == space.end()) return 0;
    found = (*i).second;

    return 1;
}


int QUERY::DummyId(TOID& toid) {
   if (Pattern & FREE_ID) return 0;
   toid=id;
   return 1;
}

int QUERY::DummySrc(TOID& toid) {
   if (Pattern & FREE_SRC) return 0;
   toid=src;
   return 1;
}

int QUERY::DummyDst(TOID& toid) {
   if (Pattern & FREE_DST) return 0;
   toid=dst;
   return 1;
}


int QUERY::DummyLab(char *s) {
    if (Pattern & FREE_LAB) return 0;
    strcpy(s,slabel);
    return 1;
}


int QUERY::DummyId1(TOID& toid) {
   if (Pattern & FREE_ID_1) return 0;
   toid=src;
   return 1;
}

int QUERY::DummyId2(TOID& toid) {
   if (Pattern & FREE_ID_2) return 0;
   toid=dst;
   return 1;
}

int QUERY::DummyCC(TOID& toid) {
   if (Pattern & FREE_CC) return 0;
   toid=id;
   return 1;
}

int QUERY::DummyModule(TOID& toid) {
   if (Pattern & FREE_MODULE) return 0;
   toid=module;
   return 1;
}

//void QUERY::done() {
//  /*
//  *  clear seachspace
//  */
//    space.clear();
//}

void QUERY::test() {
    space.test();
}

/****************************PQUERY**********************************/
 void PQUERY::set(int whatset,TIMEPOINT ntime,TOID nid,
                  TOID nsrc,SYMID nlabel,char *nslabel, TOID ndst, TDB *db,
                  int nPattern, TOID nmodule, int nstrict) {

  /*
  *  init a query-descriptor
  *    whatset                   : searchspace
  *    ntime                     : timepoint
  *    nid,nsrc, nlabel, ndst    : search-components
  *   nPattern                   : search-pattern
  *    *akt, *hist, *tmp1, *tmp2 : pointers to the database-sets
  */


   // i = 0;			// clear search-index
   start = 1;			// set start-flag
				// store parameters:
   time	= ntime;		// -timepoint
   searchspace = whatset;       // -searchspace
   id =	nid;			// -Id
   src = nsrc;			// -source-id
   dst = ndst;			// -destination-id
   label = nlabel;		// -label
   module = nmodule;
   strict = nstrict;
   Pattern = nPattern;		// -pattern
   if (slabel) delete[] slabel;
   slabel = new char[strlen(nslabel)+1];
   strcpy(slabel,nslabel);


   //  *************************************
   //  ******* create search-space:  *******
   //  *************************************


   space.clear();		// clear searchspace

   P_Literal_wo_timecheck(id,src,label,dst,Pattern,space,db,time,whatset);


   #if DLEVEL >= 4
   printf("Objects found (no timecheck!): ");
   space.test();
   printf("\n");
   #endif

};


 void attrSQUERY::set(int whatset,TIMEPOINT ntime, TOID id1, TOID id2,
                    TDB *db,int nPattern,
                    TOID nmodule, int nstrict)
{
   // i = 0;                    // clear search-index
   start = 1;                   // set start-flag
                                // store parameters:
   time = ntime;                // -timepoint
   searchspace = whatset;       // -searchspace
   src = id1;                   // -source-id
   module = nmodule;
   strict = nstrict;

   Pattern = nPattern;          // -pattern

   //  *************************************
   //  ******* create search-space:  *******
   //  *************************************

   #if DLEVEL >= 4
   cout << "QUERY::set_Attr_s\n";
   cout.flush();
   #endif


   space.clear();               // clear searchspace


   Attr_s_Literal(id1,id2,nPattern,space,time,whatset,nmodule);


   #if DLEVEL >= 4
   printf("Objects found (attr_s): ");
   space.test();
   printf("\n");
   #endif
   if (db){}
};



 void inSQUERY::set(int whatset,TIMEPOINT ntime, TOID id1,
                    TOID id2,TDB *db,int nPattern,
                    TOID nmodule, int nstrict)
{
   // i = 0;			// clear search-index
   start = 1;			// set start-flag
				// store parameters:
   time	= ntime;		// -timepoint
   searchspace = whatset;       // -searchspace
   src = id1;			// -source-id
   dst = id2;			// -destination-id
   module = nmodule;
   strict = nstrict;

   Pattern = nPattern;		// -pattern

   //  *************************************
   //  ******* create search-space:  *******
   //  *************************************

   #if DLEVEL >= 4
   cout << "QUERY::set_In_s\n";
   cout.flush();
   #endif


   space.clear();		// clear searchspace


   In_s_Literal(id1,id2,nPattern,space,time,whatset,nmodule);


   #if DLEVEL >= 4
   printf("Objects found (in_s): ");
   space.test();
   printf("\n");
   #endif
   if (db){}
};

 void inIQUERY::set(int whatset,TIMEPOINT ntime, TOID id1,
                  TOID id2,TDB *db,int nPattern,
		  TOID nmodule, int nstrict)
{
   // i = 0;			// clear search-index
   start = 1;			// set start-flag
				// store parameters:
   time	= ntime;		// -timepoint
   searchspace = whatset;       // -searchspace
   src = id1;			// -source-id
   dst = id2;			// -destination-id
   module = nmodule;
   strict = nstrict;
   Pattern = nPattern;		// -pattern

   //  *************************************
   //  ******* create search-space:  *******
   //  *************************************

   #if DLEVEL >= 4
   cout << "QUERY::set_In_i\n";
   cout.flush();
   #endif


   space.clear();		// clear searchspace


   In_i_Literal(id1,id2,nPattern,space,time,whatset,nmodule);


   #if DLEVEL >= 4
   printf("Objects found: (in_i) ");
   space.test();
   printf("\n");
   #endif
   if (db){}
};

void SystemQUERY::set(int whatset, TIMEPOINT ntime, TOID x, TOID c,TDB *db,
                      int nPattern,
                      TOID nmodule, int nstrict)
{
   // i = 0;			// clear search-index
   start = 1;			// set start-flag
				// store parameters:
   time	= ntime;		// -timepoint
   searchspace = whatset;       // -searchspace
   src = x;
   dst = c;
   module = nmodule;
   strict = nstrict;
   Pattern = nPattern;		// -pattern

   //  *************************************
   //  ******* create search-space:  *******
   //  *************************************

   #if DLEVEL >= 4
   cout << "QUERY::set_systemclass\n";
   cout.flush();
   #endif


   space.clear();		// clear searchspace

   In_o_Literal(x,c,nPattern,space,db,time,whatset,nmodule);



   #if DLEVEL >= 4
   printf("Objects found: (systemclass) ");
   space.test();
   printf("\n");
   #endif
   if (db){}
};

void AdotQUERY::set(int whatset,TIMEPOINT ntime, TOID cc, TOID x, SYMID ml,
		     char *helpml, TOID y, TDB *db, int nPattern,
		     TOID nmodule, int nstrict)
{


   // i = 0;			// clear search-index
   start = 1;			// set start-flag
				// store parameters:
   time	= ntime;		// -timepoint
   searchspace = whatset;       // -searchspace
   id  = cc;
   src = x;			// -source-id
   dst = y;			// -destination-id
   label = ml;		// -label
   module = nmodule;
   strict = nstrict;
   Pattern = nPattern;		// -pattern
   if (slabel) delete[] slabel;
   slabel = new char[strlen(helpml)+1];
   strcpy(slabel,helpml);

   //  *************************************
   //  ******* create search-space:  *******
   //  *************************************

   #if DLEVEL >= 4
   cout << "QUERY::set_Adot\n";
   cout.flush();
   #endif


   space.clear();		// clear searchspace

   Adot_Literal(cc,x,ml,y,nPattern,space,time,whatset,nmodule);


   #if DLEVEL >= 4
   printf("Objects found: (Adot) ");
   space.test();
   printf("\n");
   #endif
   if (db){}
}


void AidotQUERY::set(int whatset,TIMEPOINT ntime, TOID cc, TOID x, SYMID ml,
                     char *helpml, TOID y, TDB *db, int nPattern,
                     TOID nmodule, int nstrict)
{


   // i = 0;                    // clear search-index
   start = 1;                   // set start-flag
                                // store parameters:
   time = ntime;                // -timepoint
   searchspace = whatset;       // -searchspace
   id  = cc;
   src = x;                     // -source-id
   dst = y;                     // y actually is the id of an attribute with source x
   label = ml;          // -label
   module = nmodule;
   strict = nstrict;
   Pattern = nPattern;          // -pattern
   if (slabel) delete[] slabel;
   slabel = new char[strlen(helpml)+1];
   strcpy(slabel,helpml);

   //  *************************************
   //  ******* create search-space:  *******
   //  *************************************

   #if DLEVEL >= 4
   cout << "QUERY::set_Aidot\n";
   cout.flush();
   #endif


   space.clear();               // clear searchspace

   Aidot_Literal(cc,x,ml,y,nPattern,space,time,whatset,nmodule);

   #if DLEVEL >= 4
   printf("Objects found: (Aidot) ");
   space.test();
   printf("\n");
   #endif
   if (db){}
}



void AQUERY::set(int whatset,TIMEPOINT ntime, TOID x, SYMID ml,
                            char *helpml, TOID y, int nPattern,
                            TOID nmodule, int nstrict)
{


   // i = 0;			// clear search-index
   start = 1;			// set start-flag
				// store parameters:
   time	= ntime;		// -timepoint
   searchspace = whatset;       // -searchspace
   src = x;			// -source-id
   dst = y;			// -destination-id
   label = ml;		// -label
   module = nmodule;
   strict = nstrict;
   Pattern = nPattern;		// -pattern
   if (slabel) delete[] slabel;
   slabel = new char[strlen(helpml)+1];
   strcpy(slabel,helpml);

   //  *************************************
   //  ******* create search-space:  *******
   //  *************************************

   #if DLEVEL >= 4
   cout << "QUERY::set_ALit\n";
   cout.flush();
   #endif

   space.clear();		// clear searchspace

   A_Literal(x,ml,y,nPattern,space,time,whatset,nmodule);

   #if DLEVEL >= 4
   printf("Objects found: (ALit) ");
   space.test();
   printf("\n");
   #endif

}

int AQUERY::next(TOID &found)
{
    if (start)  		// start-flag:
	{
	    i = space.begin();	// get first item
	    start = 0;		// clear start flag
	}
    else i++;		// get next item

    if (i == space.end()) return 0;
    found = (*i).second;

    return 1;
}

AQUERY::~AQUERY()
{
    space.destruct();
//    if (slabel) delete[] slabel;
}

void IsaQUERY::set(int whatset,TIMEPOINT ntime, TOID x,
                   TOID y,TDB *db, int nPattern, TOID nmodule, int nstrict)
{


   // i = 0;			// clear search-index
   start = 1;			// set start-flag
				// store parameters:
   time	= ntime;		// -timepoint
   searchspace = whatset;       // -searchspace
   src = x;			// -source-id
   dst = y;			// -destination-id
   module = nmodule;
   strict = nstrict;
   Pattern = nPattern;		// -pattern

   //  *************************************
   //  ******* create search-space:  *******
   //  *************************************

   #if DLEVEL >= 5
   cout << "QUERY::set_IsaLit\n";
   cout.flush();
   #endif


   space.clear();		// clear searchspace

   Isa_Literal(x,y,nPattern,space,time,whatset,nmodule);


   #if DLEVEL >= 5
   printf("Objects found: (IsaLit) %d",space.length());
   space.test();
   printf("\n");
   #endif
   if (db){}
}


/*
* IsaQUERY::~IsaQUERY()
*{
*    space.destruct();
*}
*/
/*
* int IsaQUERY::next(TOID &found)
*{
*    if (start)  		// start-flag:
*	{
*	    i = space.first();	// get first item
*	    start = 0;		// clear start flag
*	}    else space.next(i);		// get next item
*
*
*    if (!i) return 0;
*    found = space(i);
*
*    return 1;
*}
*/

void starQUERY::set(int whatset,TIMEPOINT ntime, char *starlabel,SYMTBL *symtbl,TOID nmodule, int nstrict)
{


   // i = 0;			// clear search-index
   start = 1;			// set start-flag
				// store parameters:
   time	= ntime;		// -timepoint
   searchspace = whatset;       // -searchspace
   module = nmodule;
   strict = nstrict;


   //  *************************************
   //  ******* create search-space:  *******
   //  *************************************

   #if DLEVEL >= 4
   cout << "QUERY::set_star\n";
   cout.flush();
   #endif


   space.clear();		// clear searchspace


   symtbl->star_search(starlabel,space);


   #if DLEVEL >= 4
   printf("Objects found: (star) ");
   space.test();
   printf("\n");
   #endif
}

void ALQUERY::set(int whatset,TIMEPOINT ntime, TOID x, SYMID ml,
                  char *helpml,SYMID l,
                  char *helpl, TOID y, int nPattern,
                  TOID nmodule, int nstrict)
{


   // i = 0;			// clear search-index
   start = 1;			// set start-flag
				// store parameters:
   time	= ntime;		// -timepoint
   searchspace = whatset;       // -searchspace
   src = x;			// -source-id
   dst = y;			// -destination-id
   mlabel = ml;		// -label
   label=l;
   module = nmodule;
   strict = nstrict;
   Pattern = nPattern;		// -pattern
   if (slabel) delete[] slabel;
   slabel = new char[strlen(helpml)+1];
   strcpy(slabel,helpml);

   //  *************************************
   //  ******* create search-space:  *******
   //  *************************************

   #if DLEVEL >= 4
   cout << "QUERY::set_ALLit\n";
   cout.flush();
   #endif


   space.clear();		// clear searchspace

   A_Label_Literal(x,ml,l,y,nPattern,space,time,whatset,nmodule);


   #if DLEVEL >= 4
   printf("Objects found: (ALLit) ");
   space.test();
   printf("\n");
   #endif
   if (helpl){}
}

int ALQUERY::next(TOID &found)
{
    if (start)  		// start-flag:
	{
	    i = space.begin();	// get first item
	    start = 0;		// clear start flag
	}
    else i++;	// get next item

    if (i==space.end()) return 0;
    found = (*i).second;

    return 1;
}

ALQUERY::~ALQUERY()
{
    space.destruct();
//    if (slabel) delete[] slabel;
}
