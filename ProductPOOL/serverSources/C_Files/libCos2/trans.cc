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
#include "Literals.h"
#include "trans.h"
#include <stdio.h>
#include <stdlib.h>


#define MAXIDLENGTH 15
#define MAXBUFFERLENGTH 32768


TDB *database;                         // die Datenbank 

QUERYLIST *querylist;                  // Query-Verwaltung fuer retrieve_proposition-Aufrufe
QUERYLIST *literals[LITANZ];           // Query-Verwaltung fuer Literale

TOID Attribute, IsA, InstanceOf, Individual, Proposition;
				       // wozu sollen die schon gut sein? 
int gotAttribute=0, 
    gotIsA=0, 
    gotInstanceOf=0,
    gotIndividual=0,
    gotProposition=0;

static char retrieve_proposition_ID[] = "CBserver";	
                                        //  ID-Name fuer Prolog (retr. prop)
					//  wird fuer Backtracking-Simulation benutzt
static char *Literal_ID[LITANZ] = { "In_s", "In_i", "Adot", "star", "sys_class", "ALit", "Isa" };

					//  Prolog-C++, C++-Prolog benutzt
 static char Ptrans[MAXBUFFERLENGTH];
 static char Ptrans2[5][MAXIDLENGTH]; 

static Histogramm *histogramm=NULL;

 QUERYLIST::QUERYLIST() {		// Verwaltet 20 Querys als Zeiger auf einen Query
   anz = 0;
   for (int i=0;i<MAXQUERY;i++) querys[i]=0;
 }

 QUERYLIST::~QUERYLIST()  {
   freequery(-1);
 }

 void QUERYLIST::init() {
   anz=0;
 }

 QUERY& QUERYLIST::getpos(int i) {	// Funktion zum Ansprechen des i-ten Querys
   return *querys[i];
 }

/*
 *int QUERYLIST::addquery() {		// legt neuen Query an und gibt Referenz-Nummer
 *  if (anz == MAXQUERY) {			// zurueck
 *    #if DLEVEL >= 10
 *    cout << "Querylist overflow\n";
 *    cout.flush();
 *    #endif
 *    return -1;
 *  }
 *  querys[anz++] = new(QUERY);
 *  #if DLEVEL >= 5
 *  printf("Query No. %i added to querylist.\n",anz-1);
 *  cout.flush();
 *  #endif
 *  return anz-1;
 *}
 */

 int QUERYLIST::addquery(QUERY* query) {		
     if (anz == MAXQUERY) {
     #if DLEVEL >= 5
         cout << "Querylist overflow\n";
     cout.flush();
     #endif
     return -1;
     }
   querys[anz++] = query;
   #if DLEVEL >= 5
   printf("Query No. %i added to querylist.\n",anz-1);
   cout.flush();
   #endif
   return anz-1;
 }


 int QUERYLIST::freequery(int q) {
   #if DLEVEL >= 5
   printf("freequery(%d).\n",q);
   #endif					// q==-1: loescht die gesamte Query-Liste
   if (q == -1) {			// Kann von Prolog aufgerufen werden, wenn
    for (int i=0;i<anz;i++) {		// alle Backtracking-Anfragen beendet wurden,
     if (querys[i]) delete(querys[i]);	// d.h. wenn sichergestellt ist, dass alle
     querys[i] = 0;			// bis dahin angeforderten Querys frei sind
    } 
    anz=0;
    #if DLEVEL >= 5
    printf("Clearing querylist.\n");
    #endif
    return 1;
   }  

   if (!querys[q]) {		// q != -1:
     #if DLEVEL >= 5
     printf("Trying to remove not-existing query!\n");  // Wenn angefragter Query nicht existiert: Fehlermeldung
     #endif
     return 0;			// (tritt auf, wenn sich ein Query selbt loescht und danach
   }				//  von Prolog nocheinmal geloescht wird)

   for (int i=q;i<anz;i++) { 
     delete(querys[i]);		// sonst: Query loeschen
     querys[i] = 0;
     #if DLEVEL >= 5
     printf("Query %i removed.\n",i);
     #endif
   }
   anz = q;
   return 1;
 }


  

int init( char *filename ) 
{
  char hilfsname[200];
  strncpy(hilfsname,filename,199);
  int i;
  for (i=0;hilfsname[i];i++){};   // hack for Concept Base
  if (hilfsname[--i] == '.') hilfsname[i]=0;
  printf("open extern C-database %s ...\n",hilfsname);
  database = new TDB;
  if (!database->open(hilfsname))
  {
//      delete database;
      return 0;
  }
// printf("database opened\n");
  database->set_search_space(ACTUAL_DB);
  database->set_search_time(TIMEPOINT(INFINITY,0));  
//  for (int j=0;j<4;j++) Ptrans[j] = trans2[j];
  querylist = new QUERYLIST;
  for (int j=0;j<LITANZ;j++) literals[j] = new QUERYLIST;
  printf("ready.\n");
  return 1;
} 

int done() {
  printf("closing down extern C-database...\n");
  delete querylist;
  for (int j=0;j<LITANZ;j++) delete literals[j];
  delete database;  
  printf("done.\n");
  return 1;
}

/*
* Stuff for searching (retrieve_proposition) the database
*/


int freequery(int i) {			// Aufgabe der Queryliste
   querylist->freequery(i);
   return 1;
 }

int getquery(char *tuple[4]) { 
  TOID toid1,toid2,toid3;
  SYMID symid1;
  int pattern=0;

  #if DLEVEL >= 5
  printf("Starting PQuery: ");
  #endif

  if (!*tuple[0]) pattern |= FREE_ID;
  else {
   #if DLEVEL >= 5
   printf("ID: %s*",tuple[0]);
   #endif
   database->oid2toid(tuple[0],toid1);
  }

  if (!*tuple[1]) pattern |= FREE_SRC;
  else {
    #if DLEVEL >= 5
    printf("SRC: %s* ",tuple[1]);
    #endif
    database->oid2toid(tuple[1],toid2);
  }

  if (!*tuple[2]) {
    pattern |= FREE_LAB;
  }
  else {
    #if DLEVEL >= 5
    printf("LAB: %s* ",tuple[2]);
    #endif
    if (!database->get_symb(tuple[2],symid1))
    {
	database->delete_overrules();
	return -1;
    }
  }

  if (!*tuple[3]) pattern |= FREE_DST;
  else {
    #if DLEVEL >= 5
    printf("DST: %s* ",tuple[3]);
    #endif
    database->oid2toid(tuple[3],toid3);
  }
   
  #if DLEVEL >= 5
  printf("\n\n");
  #endif
  
  int nr=querylist->addquery(new PQUERY);	
  if (nr == -1)
  {
      printf("\nConceptBase Object Storage:\n");
      printf("Error: Query Stack overflow for Query:\n");
      printf(" retrieve_proposition(P(");
      if (pattern & FREE_ID)
	  printf("_,");
      else
	  printf("%s,",tuple[0]);

      if (pattern & FREE_SRC)
	  printf("_,");
      else
	  printf("%s,",tuple[1]);

      if (pattern & FREE_LAB)
	  printf("_,");
      else
	  printf("%s,",tuple[2]);

      if (pattern & FREE_DST)
	  printf("_))\n");
      else
	  printf("%s))\n",tuple[3]);
      exit (2);
      return -1;
  }
  #if DLEVEL >= 5
  printf("(Nr. %d)\n",nr);
  cout.flush();
  #endif
  database->start_seek(*((QUERY4a*) &(querylist->getpos(nr))) ,toid1,toid2,symid1,
                       tuple[2],toid3,pattern);

  #if DLEVEL >= 5
  cout << "getquery: ready.\n";
  cout.flush();
  #endif
  return nr;
 } 

int getqueryM(char *tuple[5]) { 
  TOID toid1,toid2,toid3,module;
  SYMID symid1;
  int pattern=0;

  #if DLEVEL >= 5
  printf("Starting PQueryM: ");
  #endif

  if (!*tuple[0]) pattern |= FREE_ID;
  else {
   #if DLEVEL >= 5
   printf("ID: %s*",tuple[0]);
   #endif
   database->oid2toid(tuple[0],toid1);
  }

  if (!*tuple[1]) pattern |= FREE_SRC;
  else {
    #if DLEVEL >= 5
    printf("SRC: %s* ",tuple[1]);
    #endif
    database->oid2toid(tuple[1],toid2);
  }

  if (!*tuple[2]) {
    pattern |= FREE_LAB;
  }
  else {
    #if DLEVEL >= 5
    printf("LAB: %s* ",tuple[2]);
    #endif
    if (!database->get_symb(tuple[2],symid1))
    {
	database->delete_overrules();
    #if DLEVEL >= 5
    printf("LAB: %s get_symb false ",tuple[2]);
    #endif
	return -1;
    }
    #if DLEVEL >= 5
    printf("LAB: %s get_symb true ",tuple[2]);
    #endif
  }

  if (!*tuple[3]) pattern |= FREE_DST;
  else {
    #if DLEVEL >= 2
    printf("DST: %s* ",tuple[3]);
    #endif
    database->oid2toid(tuple[3],toid3);
  }
  
  if (!*tuple[4]) pattern |= FREE_MODULE;
  else {
    #if DLEVEL >= 2
    printf("Module: %s* ",tuple[4]);
    #endif
    database->oid2toid(tuple[4],module);
  }
  
  #if DLEVEL >= 2
  printf("\n");
  #endif

  int nr=querylist->addquery(new PQUERY);	
  if (nr == -1)
  {
      printf("\nConceptBase Object Storage:\n");
      printf("Error: Query Stack overflow for Query:\n");
      printf(" retrieve_proposition(P(");
      if (pattern & FREE_ID)
	  printf("_,");
      else
	  printf("%s,",tuple[0]);

      if (pattern & FREE_SRC)
	  printf("_,");
      else
	  printf("%s,",tuple[1]);

      if (pattern & FREE_LAB)
	  printf("_,");
      else
	  printf("%s,",tuple[2]);

      if (pattern & FREE_DST)
	  printf("_,");
      else
	  printf("%s,",tuple[3]);

      if (pattern & FREE_MODULE)
	  printf("_))\n");
      else
	  printf("%s))\n",tuple[4]);
      exit (2);
      return -1;
  }
  #if DLEVEL >= 8
  printf("(Nr. %d)\n",nr);
  cout.flush();
  #endif
  database->start_seek(*((QUERY4a*) &(querylist->getpos(nr))),toid1,toid2,symid1,
                       tuple[2],toid3,pattern,module);

  #if DLEVEL >= 4
  cout << "getquery: ready.\n";
  cout.flush();
  #endif
  return nr;
 } 


int getid(char **s) {
  *s = retrieve_proposition_ID;    
  return 1;
 }          
  
int find(int i,char *out[]) 	//  Suchen: organisiert Datenaustausch,
{
#if DLEVEL >= 5
    printf("Pfind (Nr.%d) ",i);
    cout.flush();
#endif
    TOID toid;
    int j;
#if DLEVEL >= 12
    querylist->getpos(i).test();
#endif


    if (database->get_tuple(querylist->getpos(i),toid)) 
	{

	    for (j=0;j<4;j++) out[j] = Ptrans2[j];
	    out[2] = Ptrans;

	    database->toid2oid(toid,Ptrans2[0]);
	    database->toid2oid(toid.Src(),Ptrans2[1]);
	    toid.Lab().get_name(Ptrans);
	    database->toid2oid(toid.Dst(),Ptrans2[3]);
	    
#if DLEVEL >= 5
	    printf("returning(%s %s %s %s).\n",out[0],out[1],out[2],out[3]);
#endif

#if DLEVEL >= 12
	    querylist->getpos(i).test();
	    printf("\n");
#endif
	    return 1;
	}

    out[0] = Ptrans2[0];
    if (querylist->getpos(i).DummyId(toid))
	database->toid2oid(toid,out[0]);
    else out[0][0] = 0;


    out[1] = Ptrans2[1];
    if (querylist->getpos(i).DummySrc(toid)) 
	database->toid2oid(toid,out[1]);
    else out[1][0] = 0;


    out[3] = Ptrans2[3];
    if (querylist->getpos(i).DummyDst(toid))
	database->toid2oid(toid,out[3]);
    else out[3][0] = 0;

    out[2] = Ptrans;
    if (!querylist->getpos(i).DummyLab(out[2]))
	out[2][0]=0;

#if DLEVEL >= 5
    printf("nothing found (%s,%s,%s,%s)\n",out[0],out[1],out[2],out[3]);
#endif



#if DLEVEL >= 5
    cout << "find: ready.\n";
    cout.flush();
#endif
    return 0;
}

int findM(int i,char *out[]) 	//  Suchen: organisiert Datenaustausch,
{
#if DLEVEL >= 5
    printf("findM (Nr.%d) ",i);
    cout.flush();
#endif
    TOID toid;
    int j;
#if DLEVEL >= 12
    querylist->getpos(i).test();
#endif

    if (database->get_tuple(querylist->getpos(i),toid)) 
	{

	    for (j=0;j<5;j++) out[j] = Ptrans2[j];
	    out[2] = Ptrans;

	    database->toid2oid(toid,Ptrans2[0]);
	    database->toid2oid(toid.Src(),Ptrans2[1]);
	    toid.Lab().get_name(Ptrans);
	    database->toid2oid(toid.Dst(),Ptrans2[3]);
	    database->toid2oid(toid.GetModule(),Ptrans2[4]);
	    
#if DLEVEL >= 5
	    printf("returning(%s %s %s %s %s).\n",out[0],out[1],out[2],out[3],out[4]);
#endif

#if DLEVEL >= 12
	    querylist->getpos(i).test();
	    printf("\n");
#endif
	    return 1;
	}

    out[0] = Ptrans2[0];
    if (querylist->getpos(i).DummyId(toid))
	database->toid2oid(toid,out[0]);
    else out[0][0] = 0;


    out[1] = Ptrans2[1];
    if (querylist->getpos(i).DummySrc(toid)) 
	database->toid2oid(toid,out[1]);
    else out[1][0] = 0;


    out[3] = Ptrans2[3];
    if (querylist->getpos(i).DummyDst(toid))
	database->toid2oid(toid,out[3]);
    else out[3][0] = 0;

    out[2] = Ptrans;
    if (!querylist->getpos(i).DummyLab(out[2]))
	out[2][0]=0;

    out[4] = Ptrans2[4];
    if (querylist->getpos(i).DummyModule(toid))
	database->toid2oid(toid,out[4]);
    else out[4][0] = 0;


#if DLEVEL >= 5
    printf("nothing found (%s,%s,%s,%s)\n",out[0],out[1],out[2],out[3]);
#endif



#if DLEVEL >= 3
    cout << "find: ready.\n";
    cout.flush();
#endif
    return 0;
}

/*
* Stuff for prooving literals
*/


int Literal_freequery(int i,int WhatLit) {      // Aufgabe der Queryliste
   literals[WhatLit]->freequery(i);
   return 1;
 }

int Literal_getquery(char *tuple[2],int WhatLit) { 
/*
* the array contains the 2 parameters (oid's or free)
*/
  TOID toid1,toid2;
  int pattern=0;

  #if DLEVEL >= 5
  printf("Starting Literal-Query (%d): ",WhatLit);
  #endif

  if (!*tuple[0]) pattern |= FREE_ID_1;
  else {
   #if DLEVEL >= 5
   printf("first oid: %s*",tuple[0]);
   #endif
   database->oid2toid(tuple[0],toid1);
  }

  if (!*tuple[1]) pattern |= FREE_ID_2;
  else {
  #if DLEVEL >= 5
    printf("second oid: %s* ",tuple[1]);
    #endif
    database->oid2toid(tuple[1],toid2);
  }

  int nr=-1;
  
  switch (WhatLit) {
  case In_s: nr=literals[WhatLit]->addquery(new inSQUERY);break;
  case In_i: nr=literals[WhatLit]->addquery(new inIQUERY);break;
  case system_class: nr=literals[WhatLit]->addquery(new SystemQUERY);break;
  case Isa:nr=literals[WhatLit]->addquery(new IsaQUERY);break;
  default: printf("in Literal_getQuery(...) wurde ein nicht auswertbarer Literal-typ uebergeben(%d)...\n",WhatLit);break;
  };

  if (nr == -1)
  {
      printf("\nConceptBase Object Storage:\n");
      printf("Error: Query Stack overflow for Query:\n");
      printf("prove_literal(");
      switch (WhatLit) {
      case In_s: printf("in_s(");break;
      case In_i: printf("in_i(");break;
      case Isa: printf("Isa(");break;          
      case system_class: printf("sys_class(");break;
      default:   break;
      }
      if (pattern & FREE_ID_1)
	  printf("_,");
      else
	  printf("%s,",tuple[0]);

      if (pattern & FREE_ID_2)
	  printf("_))\n");
      else
	  printf("%s))\n",tuple[1]);

      exit (2);
      return -1;
  }
  #if DLEVEL >= 5
  printf("(Nr. %d)\n",nr);
  cout.flush();
  #endif

  database->start_Literal(*((QUERY2*) &(literals[WhatLit]->getpos(nr))),toid1,toid2,pattern,
    Literals(WhatLit));

  #if DLEVEL >= 5
  cout << "getquery: ready.\n";
  cout.flush();
  #endif
  return nr;
}


int Literal_getid(char **s,int WhatLit) {
  *s = Literal_ID[WhatLit];    
  return 1;
}          
  
int Literal_find(int i,char *out[],int WhatLit) 	//  Suchen: organisiert Datenaustausch,
{
#if DLEVEL >= 5
    printf("Literal_find (Nr.%d) ",WhatLit);
    cout.flush();
#endif
    TOID toid;
    int j;
#if DLEVEL >= 12
    literals[WhatLit]->getpos(i).test();
#endif

    
    if (database->get_tuple(literals[WhatLit]->getpos(i),toid)) 
	{

	    for (j=0;j<2;j++) out[j] = Ptrans2[j];
            
            switch (literals[WhatLit]->getpos(i).ask_pattern()) 
		{
		case FREE_ID_1:
		    database->toid2oid(toid,out[0]);
		    if (literals[WhatLit]->getpos(i).DummyId2(toid))
			database->toid2oid(toid,out[1]);
		    break;
		case FREE_ID_2:
		    database->toid2oid(toid,out[1]);
		    if (literals[WhatLit]->getpos(i).DummyId1(toid))
			database->toid2oid(toid,out[0]);
		    break;
		case FREE_ID_1 + FREE_ID_2:
		    database->toid2oid(toid.Src(),out[0]);
		    database->toid2oid(toid.Dst(),out[1]);
		    break;
		case 0:
		    if (literals[WhatLit]->getpos(i).DummyId1(toid))
			database->toid2oid(toid,out[0]);
		    if (literals[WhatLit]->getpos(i).DummyId2(toid))
			database->toid2oid(toid,out[1]);
		    break;
		default:
		    break;
                }
#if DLEVEL >= 5
	    printf("returning(%s#%s).\n",out[0],out[1]);
#endif

#if DLEVEL >= 5
	    literals[WhatLit]->getpos(i).test();
	    printf("\n");
#endif
	    return 1;
	}

    out[0] = Ptrans2[0];
    if (literals[WhatLit]->getpos(i).DummyId1(toid))
	database->toid2oid(toid,out[0]);
    else out[0][0] = 0;

    out[1] = Ptrans2[1];
    if (literals[WhatLit]->getpos(i).DummyId2(toid)) 
	database->toid2oid(toid,out[1]);
    else out[1][0] = 0;

 
#if DLEVEL >= 5
    printf("nothing found (%s,%s)\n",out[0],out[1]);
#endif
    
#if DLEVEL >= 5
    cout << "find: ready.\n";
    cout.flush();
#endif
    return 0;
}




int Literal4_getquery(char *tuple[4],int WhatLit) { 
/*
* the array contains the 4 parameters (oid's or free)
*/
  TOID cc,x,y;
  SYMID ml,l;
  
  int pattern=0;

  if (WhatLit==Adot)
  {
#if DLEVEL >= 5
      printf("Adot()\n");
#endif
      
      if (!*tuple[0]) {pattern |= FREE_CC;}
      else {
          database->oid2toid(tuple[0],cc);
      }
      
      if (!*tuple[1]) {pattern |= FREE_X;}
      else {
          database->oid2toid(tuple[1],x);
      }
      
      if (!*tuple[2]) {pattern |= FREE_ML;}
      else {
          database->get_symb(tuple[2],ml);
      }
      
      if (!*tuple[3]) {pattern |= FREE_Y;}
      else {
          database->oid2toid(tuple[3],y);
      }
  }
  if (WhatLit==ALabelLit)
  {
#if DLEVEL >= 5
      printf("ALabel()\n");
#endif
      
      if (!*tuple[0]) {pattern |= FREE_X;}
      else {
          database->oid2toid(tuple[0],x);
      }
      
      if (!*tuple[1]) {pattern |= FREE_ML;}
      else {
          database->get_symb(tuple[1],ml);
      }
      
      if (!*tuple[2]) {pattern |= FREE_LAB;}
      else {
          database->get_symb(tuple[2],ml);
      }
      
      if (!*tuple[3]) {pattern |= FREE_Y;}
      else {
          database->oid2toid(tuple[3],y);
      }
  }      

  int nr=-1;
  switch (WhatLit) {
  case Adot: nr=literals[WhatLit]->addquery(new AdotQUERY);break;
  case ALabelLit: nr=literals[WhatLit]->addquery(new ALQUERY);break;
  default: printf("Literalstyp %d konnte nicht ausgewertet werden (Literal4_getQuery)!\n",WhatLit);
  }
      
  if (nr == -1)
  {
      printf("\nConceptBase Object Storage:\n");
      printf("Error: Query Stack overflow for Query:\n");
      printf(" prove_literal(");
      switch (WhatLit) {
      case Adot: printf("Adot(");break;
      case ALabelLit: printf("ALabelLiteral(");break;
      default:   break;
      }
      if (pattern & FREE_X)
	  printf("_,");
      else
	  printf("%s,",tuple[0]);

      if (pattern & FREE_ML)
	  printf("_,");
      else
	  printf("%s,",tuple[1]);

      if (pattern & FREE_LAB)
	  printf("_,");
      else
	  printf("%s,",tuple[2]);

      if (pattern & FREE_Y)
	  printf("_))\n");
      else
	  printf("%s))\n",tuple[3]);
      exit (2);
      return -1;
  }
  #if DLEVEL >= 5
  printf("(Nr. %d)\n",nr);
  cout.flush();
  #endif

  switch(WhatLit)
  {    
  case Adot: database->start_Literal4(*((QUERY4a*) &(literals[WhatLit]->getpos(nr))),cc,x,ml,tuple[2],y
                                           ,pattern,Literals(WhatLit));
  case ALabelLit:database->start_Literal4(*((QUERY4b*) &(literals[WhatLit]->getpos(nr))),x,ml,tuple[1],l,tuple[2],y
                                      ,pattern,Literals(WhatLit));
  }
  
     

  #if DLEVEL >= 5
  cout << "Lit 4 getquery: ready.\n";
  cout.flush();
  #endif
  return nr;
}


int Literal4_find(int i,char *out[],int WhatLit) 	//  Suchen: organisiert Datenaustausch,
{
#if DLEVEL >= 5
    printf("Literal4_find (Nr.%d) ",i);
    cout.flush();
#endif
    TOID toid,cc;
    int j;
#if DLEVEL >= 12
    literals[WhatLit]->getpos(i).test();
#endif
    
    if (database->get_tuple(literals[WhatLit]->getpos(i),toid)) 
	{
	    // no concerned class: nothing to do! 
	    if (!literals[WhatLit]->getpos(i).DummyCC(cc)) 
		return 0;

	    for (j=0;j<4;j++) out[j] = Ptrans2[j];
	    out[2] = Ptrans;

	    database->toid2oid(cc,out[0]);
	    database->toid2oid(toid.Src(),out[1]);
	    cc.Lab().get_name(out[2]);
	    database->toid2oid(toid.Dst(),out[3]);
#if DLEVEL >= 5
	    printf("returning(%s %s %s %s).\n",out[0],out[1],out[2],out[3]);
#endif
	    
#if DLEVEL >= 12
	    querylist->getpos(i).test();
	    printf("\n");
#endif
	    return 1;
	}

    out[0] = Ptrans2[0];
    if (literals[WhatLit]->getpos(i).DummyId(cc))
	database->toid2oid(cc,out[0]);
    else out[0][0] = 0;

    out[1] = Ptrans2[1];
    if (literals[WhatLit]->getpos(i).DummySrc(toid)) 
	database->toid2oid(toid,out[1]);
    else out[1][0] = 0;

    out[3] = Ptrans2[3];
    if (literals[WhatLit]->getpos(i).DummyDst(toid))
	database->toid2oid(toid,out[3]);
    else out[3][0] = 0;

    out[2] = Ptrans;
    if (!literals[WhatLit]->getpos(i).DummyLab(out[2]))
	out[2][0]=0;
    
#if DLEVEL >= 5
    printf("nothing found (%s,%s,%s,%s)\n",out[0],out[1],out[2],out[3]);
#endif
    
    
#if DLEVEL >= 5
    cout << "find: ready.\n";
    cout.flush();
#endif
    return 0;
    
}


/*******************************  3 stellige Literale ****************************************/


int Literal3_getquery(char *tuple[3],int WhatLit) { 
/*
* the array contains the 3 parameters (oid's or free)
*/
  TOID x,y;
  SYMID ml;
  
  int pattern=0;

  #if DLEVEL >= 5
  printf("A()\n");
  #endif

  if (!*tuple[0]) {pattern |= FREE_X;}
  else {
    database->oid2toid(tuple[0],x);
  }

  if (!*tuple[1]) {pattern |= FREE_ML;}
  else {
    database->get_symb(tuple[1],ml);
  }

  if (!*tuple[2]) {pattern |= FREE_Y;}
  else {
    database->oid2toid(tuple[2],y);
  }

  int nr=-1;
  switch (WhatLit) {
  case ALit: nr=literals[WhatLit]->addquery(new AQUERY);break;
  default:
      {
#if DLEVEL >= 3
          printf("Literalstyp %d konnte nicht ausgewertet werden (Literal3_getQuery)!\n",WhatLit);
#endif
      }
  
  }
      
  if (nr == -1)
  {
      printf("\nConceptBase Object Storage:\n");
      printf("Error: Query Stack overflow for Query:\n");
      printf(" prove_literal(");
      switch (WhatLit) {
      case ALit: printf("ALiteral(");break;
      default:   break;
      }
      if (pattern & FREE_X)
	  printf("_,");
      else
	  printf("%s,",tuple[0]);

      if (pattern & FREE_ML)
	  printf("_,");
      else
	  printf("%s,",tuple[1]);

      if (pattern & FREE_Y)
	  printf("_))\n");
      else
	  printf("%s))\n",tuple[2]);
      exit (2);
      return -1;
  }
  #if DLEVEL >= 10
  printf("(Nr. %d)\n",nr);
  cout.flush();
  #endif

  database->start_Literal3(*((QUERY3*) &(literals[WhatLit]->getpos(nr))),x,ml,tuple[1],y
			   ,pattern,Literals(WhatLit));

  #if DLEVEL >= 10
  cout << "Lit 3 getquery: ready.\n";
  cout.flush();
  #endif
  return nr;
}


int Literal3_find(int i,char *out[],int WhatLit) 	//  Suchen: organisiert Datenaustausch,
{
#if DLEVEL >= 5
    printf("Literal3_find (Nr.%d) ",i);
    cout.flush();
#endif
    TOID toid;
    int j;
#if DLEVEL >= 12
    literals[WhatLit]->getpos(i).test();
#endif
    
    if (database->get_tuple(literals[WhatLit]->getpos(i),toid)) 
	{
	    for (j=0;j<3;j++) out[j] = Ptrans2[j];
	    out[1] = Ptrans; 
            
	    database->toid2oid(toid.Src(),out[0]);
	    toid.Lab().get_name(out[1]);
	    database->toid2oid(toid.Dst(),out[2]);
#if DLEVEL >= 5
	    printf("returning(%s %s %s).\n",out[0],out[1],out[2]);
#endif
	    
#if DLEVEL >= 12
	    querylist->getpos(i).test();
	    printf("\n");
#endif
	    return 1;
	}

    out[0] = Ptrans2[0];
    if (literals[WhatLit]->getpos(i).DummySrc(toid)) 
	database->toid2oid(toid,out[0]);
    else out[0][0] = 0;

    out[2] = Ptrans2[2];
    if (literals[WhatLit]->getpos(i).DummyDst(toid))
	database->toid2oid(toid,out[2]);
    else out[2][0] = 0;

    out[1] = Ptrans;
    if (!literals[WhatLit]->getpos(i).DummyLab(out[1]))
	out[1][0]=0;
    
#if DLEVEL >= 5
    printf("nothing found (%s,%s,%s)\n",out[0],out[1],out[2]);
#endif
    
    
#if DLEVEL >= 10
    cout << "find: ready.\n";
    cout.flush();
#endif
    return 0;
    
}


int star_getquery(char *label) { 

  #if DLEVEL >= 5
  printf("Starting star-Query\n");
  #endif


  int nr=literals[3]->addquery(new starQUERY);	// 3 == star
  if (nr == -1)
  {
      printf("\nConceptBase Object Storage:\n");
      printf("Error: Query Stack overflow for Query:");
      printf(" get_object_star(%s)\n",label);
      exit (2);
      return -1;
  }
  #if DLEVEL >= 8
  printf("(Nr. %d)\n",nr);
  cout.flush();
  #endif

  database->start_star(*((QUERY1*) &(literals[star]->getpos(nr))),label);

  #if DLEVEL >= 4
  cout << "getquery: ready.\n";
  cout.flush();
  #endif
  return nr;
}


  
int star_find(int i,char *out[]) 	//  Suchen: organisiert Datenaustausch,
{
#if DLEVEL >= 5
    printf("Literal_find (Nr.%d)\n",i);
    cout.flush();
#endif
    TOID toid;
    int j;
#if DLEVEL >= 12
    literals[star]->getpos(i).test();
#endif

    
    if (database->get_tuple(literals[star]->getpos(i),toid)) 
	{

	    for (j=0;j<1;j++) out[j] = Ptrans2[j];  

	    database->toid2oid(toid,out[0]);
	    
#if DLEVEL >= 3
	    printf("returning(%s).\n",out[0]);
#endif

#if DLEVEL >= 4
	    literals[star]->getpos(i).test();
	    printf("\n");
#endif
	    return 1;
	}

    out[0] = Ptrans2[0];
 
#if DLEVEL >= 3
    printf("nothing found\n");
#endif
    
#if DLEVEL >= 3
    cout << "find: ready.\n";
    cout.flush();
#endif
    return 0;
}





int rename_object(char* newname, char* oldname) {
#if DLEVEL >= 6
    printf("rename on %s :- %s\n",newname,oldname);
#endif
    return database->rename(newname,oldname);
}



/*
*  creation of new nodes
*/

int create_node(char *s[4]) 
{
#if DLEVEL >= 5
    printf("create_node on %s.\n",s[2]);
#endif
    
    TOID toid=database->Create_node(s[2]);
    database->insert(toid);

    database->toid2oid(toid,Ptrans2[0]);
    database->toid2oid(toid,Ptrans2[1]);
    toid.Lab().get_name(Ptrans);
    database->toid2oid(toid,Ptrans2[3]); 
    
    for (int i=0;i<4;i++) 
	s[i]=Ptrans2[i];
    s[2] = Ptrans;
    
#if DLEVEL >= 5
    printf("ID of %s is %s.\n",s[2],s[0]);
#endif
    
    return 1;
}

int create_implicit_node(char *s[4]) 
{		
#if DLEVEL >= 5
    printf("create_implicit_node on %s.\n",s[2]);
#endif

    TOID toid=database->Create_node(s[2]);
    database->insert_implicit(toid);

    database->toid2oid(toid,Ptrans2[0]);
    database->toid2oid(toid,Ptrans2[1]);
    toid.Lab().get_name(Ptrans);
    database->toid2oid(toid,Ptrans2[3]); 
  
    for (int i=0;i<4;i++) 
	s[i]=Ptrans2[i];
    s[2]=Ptrans;
    
#if DLEVEL >= 5
    printf("ID of %s is %s.\n",s[2],s[0]);
#endif
    
    return 1;
}

int create_link(char *s[4]) 
{
#if DLEVEL >= 5
    printf("create_link on %s %s %s.\n",s[1],s[2],s[3]);
#endif
    TOID toid,toid1,toid2;

    if (database->oid2toid(s[1],toid1) && database->oid2toid(s[3],toid2)) 
	{
	    toid = database->Create_link(s[2],toid1,toid2);		
	    database->insert(toid);

	    database->toid2oid(toid,Ptrans2[0]);
	    database->toid2oid(toid.Src(),Ptrans2[1]);
	    toid.Lab().get_name(Ptrans);
	    database->toid2oid(toid.Dst(),Ptrans2[3]); 
	    for (int i=0;i<4;i++) 
		s[i]=Ptrans2[i];
	    s[2]=Ptrans;

#if DLEVEL >= 5
	    printf("ID of %s,%s,%s is %s.\n",s[1],s[2],s[3],s[0]);
#endif
	    return 1;
	}
    return 0;
}

void insert_commit() {
  database->insert_commit();
 }

void insert_abort() {
  database->insert_abort();
 }

int name2id(char *in,char **out) 
{
#if DLEVEL >= 5
    printf("name2id on %s: ",in);
#endif
    

    *out=Ptrans;
    TOID toid;
    if (database->oid2toid(in,toid)) 
	{
	    strcpy(Ptrans,in);
#if DLEVEL >= 5
	    printf("%s.\n",*out);
#endif
	    return 1;
	}

    if (database->name2toid(in,toid)) 
	{
	    database->toid2oid(toid,Ptrans);
#if DLEVEL >= 5
	    printf("%s.\n",*out);
#endif
	    return 1;
	}
#if DLEVEL >= 5
    printf("failed\n");
#endif
    Ptrans[0]=0;
    return 0;
}

int create_name2id(char *in,char **out) 
{
#if DLEVEL >= 5
    printf("create_name2id on %s.\n",in);
#endif


    *out=Ptrans;

    TOID toid;

    if (database->create_oid2toid(in,toid)) 
       {
	   strcpy(Ptrans,in);
	   return 1;
       }
    if (database->create_name2toid(in,toid)) 
	{
	    database->toid2oid(toid,Ptrans);
	    return 1;
	}
    Ptrans[0]=0;
    return 0;
}


int select2id(char *in,char **out) 
{
#if DLEVEL >= 2
    printf("select2id on %s.\n",in);
#endif
    
    *out=Ptrans;

    TOID toid;
    if (database->select2toid(in,toid)) 
	{
	    database->toid2oid(toid,Ptrans);
	    return 1;
	} 
    if (database->oid2toid(in,toid)) 
	{
	    strcpy(Ptrans,in);
	    return 1;
	}
    Ptrans[0]=0;
    return 0;
}



int id2name(char *in,char **out) 
{
#if DLEVEL >= 5
    printf("id2name on %s.\n",in);
#endif

    *out = Ptrans;

    TOID toid;
    if (database->oid2toid(in,toid)) 
	{
	    database->toid2name(toid,Ptrans);
#if DLEVEL >= 5
	    printf("done.\n");
#endif
	    return 1;
	}
    if (database->name2toid(in,toid)) 
	{
	    strcpy(Ptrans,in);
	    return 1;
       }

    Ptrans[0]=0;
    return 0;
}

int id2select(char *in,char **out) 
{
#if DLEVEL >= 8
    printf("id2select on %s.\n",in);
#endif

    *out = Ptrans;

    TOID toid;
    if (database->oid2toid(in,toid)) 
	{
	    database->toid2select(toid,Ptrans);
	    return 1;
	}
    if (database->select2toid(in,toid)) 
	{
	    strcpy(Ptrans,in);
	    return 1;
	}
    *out =  Ptrans;
    Ptrans[0]=0;
    return 0;
 }

int id2time(char *in, int *milsec, int *sec, int *min, int *hour, int *mday, int *mon, int *year) 
{
    TOID toid;
    if (database->oid2toid(in,toid)) 
	{
	    database->query_transaction_time(toid).GetTime
		(*milsec, *sec, *min, *hour, *mday, *mon, *year);
	    return 1;
	}
    

    return 0;
}

int check_implicit(char *in) 
{
    TOID toid;
    if (database->oid2toid(in,toid)) 
	{
	    return database->check_implicit(toid);
	}
    return 0;
}

int remove_(char *in) 
{
#if DLEVEL >= 5
    printf("remove on %s.\n",in);
#endif
    TOID toid;
    if (database->oid2toid(in,toid)) 
	{
	    return database->remove(toid);
	}
    return 0;
}

void remove_end() 
{
#if DLEVEL >= 5
    printf("remove end.\n");
#endif
    database->remove_end();
}

void remove_abort() 
{
#if DLEVEL >= 5
    printf("remove abort.\n");
#endif
    database->remove_abort();
}

void set_act() 
{
    database->set_search_space(ACTUAL_DB);
}
  
void set_temp() 
{
    database->set_search_space(TEMP_DB_TELL+TEMP_DB_UNTELL);
}

void set_overrule_temp() 
{
    database->set_overrule_search_space(TEMP_DB_TELL+TEMP_DB_UNTELL);
}

void set_overrule_temp_tell() 
{
    database->set_overrule_search_space(TEMP_DB_TELL);
}

void set_overrule_temp_untell() 
{
    database->set_overrule_search_space(TEMP_DB_UNTELL);
}

void set_overrule_act()
{
    database->set_overrule_search_space(ACTUAL_DB);
}
  
void set_hist() 
{
    database->set_search_space(HISTORY_DB);
}

void set_act_temp()
{
    database->set_search_space(ACTUAL_DB+TEMP_DB_TELL+TEMP_DB_UNTELL);
}


void set_new_db()
{
    database->set_search_space(ACTUAL_DB+TEMP_DB_TELL);
}

void set_old_db()
{
    database->set_search_space(ACTUAL_DB+TEMP_DB_UNTELL);
}

void set_current_db()
{
    database->set_search_space(ACTUAL_DB);
}


void set_act_hist() 
{
    database->set_search_space(ACTUAL_DB+HISTORY_DB);
}

int get_sys_class(char *in, char **out) 
{
#if DLEVEL >= 8
    printf("get_sys_class on %s: ",in);
#endif
    TOID toid;

    *out = Ptrans;
    if (database->oid2toid(in,toid)) 
    {
	if (toid.Lab().get_type() == INSTANCEOF) 
	{
	    if (!gotInstanceOf)
	    {
		char test[30];
		strcpy(test,"Proposition->Proposition");
		database->select2toid(test,InstanceOf);
		gotInstanceOf = 1;
	    }
	    database->toid2oid(InstanceOf,Ptrans);
#if DLEVEL >= 8
	    printf("%s.\n",*out);
#endif
	    return 1;
	}
	if (toid.Lab().get_type() == ISA) 
	{
	    if (!gotIsA)
	    {
		char test[30];
		strcpy(test,"Proposition=>Proposition");
		database->select2toid(test,IsA);
		gotIsA = 1;
	    }
	    database->toid2oid(IsA,Ptrans);
#if DLEVEL >= 8
	    printf("%s.\n",*out);
#endif
	    return 1;
	}
	if (toid == toid.Src() && toid == toid.Dst()) 
  	{
	    if (!gotIndividual)
	    {
		char test[30];
		strcpy(test,"Individual");
		database->select2toid(test,Individual);
		gotIndividual = 1;
	    }
	    database->toid2oid(Individual,Ptrans);
#if DLEVEL >= 8
	    printf("%s.\n",*out);
#endif
	    return 1;
	}
	if (!gotAttribute)
	{
	    char test[30];
	    strcpy(test,"Proposition!attribute");
	    database->select2toid(test,Attribute);
	    gotAttribute = 1;
	}
	database->toid2oid(Attribute,Ptrans);
	return 1;
    }
    Ptrans[0]=0;
    return 0;
}

int get_prop_id(char **out) 
{
#if DLEVEL >= 8
    printf("get_prop_id\n");
#endif

    *out = Ptrans;

    if (!gotProposition)
    {
	char test[30];
	strcpy(test,"Proposition");
	database->select2toid(test,Proposition);
	gotProposition = 1;
    }
    database->toid2oid(Proposition,Ptrans);
    return 1;
}

void set_time_point(int milsec, int sec, int min, int hour, int mday, int mon, int year) 
{
#if DLEVEL >= 1
    printf("set_time_point %d %d %d %d %d %d %d\n",milsec,sec,min,hour,mday,mon,year);
#endif
    TIMEPOINT timepoint;
    timepoint.SetTime(milsec,sec,min,hour,mday,mon,year);
    database->set_transaction_time(timepoint);
}

void set_search_point(int milsec, int sec, int min, int hour, int mday, int mon, int year) 
{
#if DLEVEL >= 1
    printf("set_search_point %d %d %d %d %d %d %d\n",milsec,sec,min,hour,mday,mon,year);
#endif
    TIMEPOINT timepoint;
    timepoint.SetTime(milsec,sec,min,hour,mday,mon,year);
    database->set_search_time(timepoint);
}

void delete_history_db(int ms,int s,int mi,int h,int d,int m,int y)
{
//    printf("trans.cc: delete_history_db(%d,%d,%d,%d,%d,%d,%d)\n",ms, s, mi, h, d, m, y);
    TIMEPOINT timepoint;
    timepoint.SetTime(ms, s, mi, h, d, m, y);
    database->delete_history_db(timepoint);
}
    

int update_zaehler(char *in, int box, long *result) 
{
    TOID toid;
    if (database->oid2toid(in,toid)) 
    {
	database->update_zaehler(toid,box,*result,1);
	return 1;
    }
    return 0;
}

int update_zaehler_ohne_huelle(char *in, int box, long *result) 
{
    TOID toid;
    if (database->oid2toid(in,toid)) 
    {
	database->update_zaehler(toid,box,*result,0);
	return 1;
    }
    return 0;
}

int get_zaehler(char *in, int box, long *result) 
{
    TOID toid;
    if (database->oid2toid(in,toid)) 
    {
	return database->get_zaehler(toid,box,*result);
    }
    return 0;
}

int update_histogramm(char *in, int dir) 
{
    TOID toid;
    if (database->oid2toid(in,toid)) 
    {
	database->update_histogramm(toid,dir);
	return 1;
    }
    return 0;
}

int update_histogramm_with_restr(char *in, int dir, char *src, char *dst) 
{
    int restr_dir=0;
    TOID toid;
    TOID src_restr, dst_restr;

    if (src[0])
    { 
	restr_dir |= SRC;
	if (!database->oid2toid(src,src_restr))
	    return 0;
    }

    if (dst[0]) 
    {
	restr_dir |= DST;
	if (!database->oid2toid(dst,dst_restr))
	    return 0;
    }

    if (database->oid2toid(in,toid)) 
    {
	database->update_histogramm(toid,dir,src_restr,dst_restr,restr_dir);
	return 1;
    }
    return 0;
}

int start_get_histogramm(char *in, int dir)
{
    TOID toid;

    if (database->oid2toid(in,toid)) {
	histogramm = database->get_histogramm(toid,dir);
	if (!histogramm) return 0;
    return 1;
    }
    return 0;
}

int get_histogramm(char **out, long *count)
{
    TOID toid;
    long l;

    *out = Ptrans;

    if (!histogramm) return 0;

    histogramm->get(toid,l);

    database->toid2oid(toid,Ptrans);
    *count = l;

    histogramm = histogramm->walk();
    return 1;
}





/*
 *
 *   > > >   M O D U L E    < < <
 *
 */


int set_module(char *in)
{
#if DLEVEL >= 5
    printf("set_module %s\n",in);
#endif
    TOID toid;
    if (database->oid2toid(in,toid))
    {
	database->set_module(toid);
	return 1;
    }
    return 0;
}

int set_overrule_module(char *in)
{
#if DLEVEL >= 5
    printf("set_overrule_module %s\n",in);
#endif
    TOID toid;
    if (database->oid2toid(in,toid))
    {
	database->set_overrule_module(toid);
	return 1;
    }
    return 0;
}

int system_module(char *in)
{
#if DLEVEL >= 5
    printf("system_module %s\n",in);
#endif
    TOID toid;
    if (database->oid2toid(in,toid))
    {
	database->SystemModule(toid);
	return 1;
    }
    return 0;
}


int initialize_module(char *in) {
#if DLEVEL >= 5
    printf("initialize_module %s\n",in);
#endif
    TOID toid;
    if (database->oid2toid(in,toid))
    {
	database->initialize_module(toid);
	return 1;
    }
    return 0;
}


int new_export(char *in) {
#if DLEVEL >= 5
    printf("new export %s\n",in);
#endif
    TOID toid;
    if (database->oid2toid(in,toid))
    {
	database->new_export(toid);
	return 1;
    }
    return 0;
}

int delete_export(char *in) {
#if DLEVEL >= 5
    printf("delete export %s\n",in);
#endif
    TOID toid;
    if (database->oid2toid(in,toid))
    {
	database->delete_export(toid);
	return 1;
    }
    return 0;
}

int new_import(char *in) {
#if DLEVEL >= 5
    printf("new import %s\n",in);
#endif
    TOID toid;
    if (database->oid2toid(in,toid))
    {
	database->new_import(toid);
	return 1;
    }
    return 0;
}

int delete_import(char *in) {
#if DLEVEL >= 5
    printf("delete import %s\n",in);
#endif
    TOID toid;
    if (database->oid2toid(in,toid))
    {
	database->delete_import(toid);
	return 1;
    }
    return 0;
}



void test() 
{
    database->test_all();
}

#ifdef ALGEBRA
void algebra_test(BP_Term input, BP_Term output)
{
    printf("Beginne C-Auswertung...\n");    
    stratified_rules *stratified=database->PrologToStratified_rules(input);
    //printf("Algebra erzeugt\n");
    if (stratified) {
         //stratified->StrukturTest();
         //printf("check rules\n");
        stratified->CheckRules();
         //stratified->test();
         //printf("calc\n");
        stratified->calc();
         //stratified->test();
         //printf("algtoprolog\n");
        database->AlgebraToProlog(stratified->GetMainRule(),output);
    } else printf("********* Prologterm konnte nicht uebersetzt werden **********\n");
    printf("C-Auswertung beendet\n");
}
#endif

