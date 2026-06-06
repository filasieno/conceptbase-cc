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

#include <stdio.h>
#include "TDB.h"
#include "Literals.h"
#include "TDB.defs.h"
#include "TOID.h"
#include "SYMID.h"
#include "TIMELINE.h"

//#define LitOutput 1


/*****************************************************************************

FUNCTION
	void	apply_source( set )

DESCRIPTION
        a set of objects { (id,src,lab,dst) | id,src,dst in Oid }
        is converted to the set { (src,_,_,_) }

HISTORY
	01.08.90 RG	created
	22.11.94 TL     changed to C++ model

BUGS

*****************************************************************************/

void	apply_source( TOIDSETSTL &Set, TOIDSETSTL &newset,TIMEPOINT timepoint,
		      int searchspace, TOID module, int pattern ) 
{
	TOIDSetIterator	ind;
	TOID		toid;

	if (!Set.length()) return;

	ind = Set.begin();
	while( ind != Set.end() )
	{
	    toid = Set(ind).Src();
	    if (Set(ind).is_valid(timepoint,searchspace,module,pattern,0)) 
		    // check the link itself, not the src.
		    // if it is valid
		{
		    newset.add(toid);
		} 
	    ind++;
	}

}


/*****************************************************************************

FUNCTION
	void	apply_desti( set )

DESCRIPTION
        a set of objects { (id,src,lab,dst) | id,src,dst in Oid }
        is converted to the set { (dst,_,_,_) }

HISTORY
	01.08.90 RG	created
	22.11.94 TL     changed to C++ model

BUGS

*****************************************************************************/

void	apply_desti( TOIDSETSTL &Set, TOIDSETSTL &newset,TIMEPOINT timepoint,
		     int searchspace, TOID module, int pattern ) 
{
	TOIDSetIterator        ind;
	TOID		toid;

	if (!Set.length()) return;

	ind = Set.begin();
	while( ind != Set.end() )
	{
		toid = Set(ind).Dst();
		if (Set(ind).is_valid(timepoint,searchspace, module, pattern,0)) 
		    // check the link itself, not the dest. 
		    // if it is valid
		{
		    newset.add(toid);
		}
		ind++;
	}
}


/*****************************************************************************

FUNCTION
        void    apply_self( set )

DESCRIPTION
        a set of objects { (id,src,lab,dst) | id,src,dst in Oid }
        just filtered against timepoint/searchspace/module

HISTORY
        10.09.08 MJF    created

BUGS

*****************************************************************************/

void    apply_self( TOIDSETSTL &Set, TOIDSETSTL &newset,TIMEPOINT timepoint,
                     int searchspace, TOID module, int pattern )
{
        TOIDSetIterator        ind;
        TOID            toid;

        if (!Set.length()) return;

        ind = Set.begin();
        while( ind != Set.end() )
        {
                toid = Set(ind);
                if (Set(ind).is_valid(timepoint,searchspace, module, pattern,0))
                    // check the link itself, not the dest.
                    // if it is valid
                {
                    newset.add(toid);
                }
                ind++;
        }
}





/*****************************************************************************

FUNCTION
	void	getInstances( set, newset )

DESCRIPTION
        

HISTORY
	13.01.98	created by MP

BUGS

*****************************************************************************/




void	getInstances( TOID toid, TOIDSETSTL &newset, TIMEPOINT timepoint,
                         int searchspace, TOID module, int pattern )
{
    TOIDSETSTL         helpset;
	/*
	 *   for the TOID get the Iof-links
	 *   arriving
	 */
    helpset |= toid.IofI();
    /*
     *  convert (id,src,*isa,dst) to (scr,_,_,_)
     */
    apply_source(helpset, newset, timepoint, searchspace, module, pattern);
}


/*****************************************************************************

FUNCTION
	void	getSuperObjects( set, newset )

DESCRIPTION
        

HISTORY
	13.01.98	created by MP

BUGS

*****************************************************************************/




void	getSuperObjects( TOID toid, TOIDSETSTL &newset, TIMEPOINT timepoint,
                         int searchspace, TOID module, int pattern )
{
    TOIDSETSTL         helpset;
    helpset |= toid.IofO();
    apply_desti(helpset, newset, timepoint, searchspace, module, pattern);
}


/*****************************************************************************

FUNCTION
	void	generalization( set, newset )

DESCRIPTION
        

HISTORY
	01.08.90 RG	created
	22.11.94 TL     changed to C++ model

BUGS

*****************************************************************************/




void	generalization( TOIDSETSTL &Set, TOIDSETSTL &newset, TIMEPOINT timepoint,
			int searchspace, TOID module, int pattern )
{
    TOID		toid;
    TOIDSetIterator   ind;
    TOIDSETSTL         helpset;
    
    ind = Set.begin();
    while( ind != Set.end() )
    {
	toid = Set(ind);
	/*
	 *   for each element of the set get the IsA-links
	 *   going out of it
	 */
	helpset |= toid.IsaO();
	ind++;
    }
    /*
     *  convert (id,src,*isa,dst) to (dst,_,_,_)
     */
    apply_desti(helpset, newset, timepoint, searchspace, module, pattern);
}





/*****************************************************************************

FUNCTION
	void	specialization( set, newset )

DESCRIPTION

HISTORY
	01.08.90 RG	created
	22.11.94 TL     changed for C++ model

BUGS

*****************************************************************************/

void	specialization( TOIDSETSTL &Set, TOIDSETSTL &newset, TIMEPOINT timepoint, 
			int searchspace, TOID module, int pattern )
{
    TOID        toid;
    TOIDSetIterator         ind;
    TOIDSETSTL     helpset;

    ind = Set.begin();
    while (ind != Set.end())
    {
	toid = Set(ind);
	/*
	 *   for each element of the set get the IsA-links
	 *   going into it
	 */
	helpset |= toid.IsaI();
	ind++;
    }

    /*
     *  convert (id,src,*isa,dst) to (src,_,_,_)
     */
    apply_source(helpset, newset, timepoint, searchspace, module, pattern);

}




/*****************************************************************************

FUNCTION
	void	closure( set )

DESCRIPTION
        calculate the isA closure of a given set according to
        accfun = specialization or generalization

HISTORY
	01.08.90 RG	created
	22.11.94 TL     changed for C++ model

BUGS

*****************************************************************************/

void	closure( TOIDSETSTL &Set, 
		 TOIDSETSTL &newset, 
		 void (*accfun)(TOIDSETSTL&, TOIDSETSTL& , TIMEPOINT, int, TOID, int), 
		 TIMEPOINT timepoint,
		 int searchspace, TOID module, int pattern) 
{
    TOIDSETSTL         delta;
    
    newset.clear();
    newset |= Set;
    delta |= Set;

    do 
    {
	TOIDSETSTL helpset;
	(*accfun)(delta, helpset, timepoint, searchspace, module, pattern );
	helpset -= newset;
	delta.clear();
	delta |= helpset;

	newset |= delta;

    } while (!delta.empty());


}





/*****************************************************************************

FUNCTION
	void	In_i_Literal( x, c, patten, solution )

DESCRIPTION

HISTORY
	22.11.94 TL     created

BUGS

*****************************************************************************/


void In_i_Literal( TOID x, TOID c, int pattern, TOIDSETSTL &solution,
		   TIMEPOINT timepoint, int searchspace, TOID module )
{
#ifdef LitOutput    
    printf("In_i_Literal\n");
#endif
    if ( (pattern & FREE_ID_1) && (pattern & FREE_ID_2) )  
    {
	printf("   ConceptBase Object Storage:\n");
	printf("   Warning: In_i - Literal called with two free variables\n");
	printf("            The storage module is not able to calculate \n");
        printf("            this query, but this should never be called!\n");
	return;
    }
    if ( !(pattern & FREE_ID_1) && !(pattern & FREE_ID_2) )
    {
	TOIDSETSTL helpset,helpset2;
	apply_desti(x.IofO(),helpset,timepoint, searchspace, module, pattern );
	closure(helpset, helpset2, generalization, timepoint, searchspace, module, pattern );
	if (helpset2.contains(c))
	    solution.add(x);                 // only to indicate that there
	return;                              // is a solution
    }
    if ( !(pattern & FREE_ID_1)) 
    {
	TOIDSETSTL helpset;
	apply_desti(x.IofO(),helpset,timepoint, searchspace, module, pattern );
	closure(helpset, solution, generalization, timepoint, searchspace, module, pattern );
	return;
    }
    if ( !(pattern & FREE_ID_2)) 
    {
	TOIDSETSTL helpset1,helpset2,helpset3;
	helpset1.add(c);
	closure(helpset1, helpset2, specialization, timepoint, searchspace, module, pattern );
	for (TOIDSetIterator ind = helpset2.begin();ind!=helpset2.end();ind++) 
	    {
		helpset3 |= helpset2(ind).IofI();
	    }
	apply_source(helpset3,solution,timepoint,searchspace, module, pattern);
        return;
    }
}


/*****************************************************************************

FUNCTION
        void    Attr_s_Literal( x, a, pattern, solution )

DESCRIPTION
	returns all attributes a  originating from x 

HISTORY
        04.09.08 MJf    created

BUGS

*****************************************************************************/

void
Attr_s_Literal( TOID x, TOID a, int pattern, TOIDSETSTL &solution,
                   TIMEPOINT timepoint, int searchspace, TOID module )
{
#ifdef LitOutput
    printf("Attr_s_Literal\n");
#endif
    if ( (pattern & FREE_ID_1) && (pattern & FREE_ID_2) )
    {
        printf("   ConceptBase Object Storage:\n");
        printf("   Warning: Attr_s - Literal called with two free variables\n");
        printf("            The storage module is not able to calculate \n");
        printf("            this query, but this should never be called!\n");
        return;
    }
    if ( !(pattern & FREE_ID_1) && !(pattern & FREE_ID_2) )
    {
        TOIDSETSTL helpset;
        apply_self(x.AtrO(),helpset,timepoint, searchspace, module, pattern );
        if (helpset.contains(a))
            solution.add(x);                  // only to indicate that there
        return;                               // is a solution
    }
    if ( !(pattern & FREE_ID_1))
    {
        apply_self(x.AtrO(),solution,timepoint, searchspace, module, pattern );
        return;
    }
    if ( !(pattern & FREE_ID_2))
    {
        apply_source(a.AtrI(),solution,timepoint, searchspace, module, pattern );
        return;
    }

}


/*****************************************************************************

FUNCTION
	void	In_s_Literal( x, c, pattern, solution )

DESCRIPTION

HISTORY
	30.11.94 TL     created

BUGS

*****************************************************************************/

void 
In_s_Literal( TOID x, TOID c, int pattern, TOIDSETSTL &solution,
		   TIMEPOINT timepoint, int searchspace, TOID module )
{
#ifdef LitOutput     
    printf("In_s_Literal\n");
#endif
    if ( (pattern & FREE_ID_1) && (pattern & FREE_ID_2) )  
    {
	printf("   ConceptBase Object Storage:\n");
	printf("   Warning: In_s - Literal called with two free variables\n");
	printf("            The storage module is not able to calculate \n");
        printf("            this query, but this should never be called!\n");
	return;
    }
    if ( !(pattern & FREE_ID_1) && !(pattern & FREE_ID_2) )
    {
	TOIDSETSTL helpset;
	apply_desti(x.IofO(),helpset,timepoint, searchspace, module, pattern );
	if (helpset.contains(c))
	    solution.add(x);                  // only to indicate that there
	return;                               // is a solution
    }
    if ( !(pattern & FREE_ID_1)) 
    {
	apply_desti(x.IofO(),solution,timepoint, searchspace, module, pattern );
	return;
    }
    if ( !(pattern & FREE_ID_2)) 
    {
	apply_source(c.IofI(),solution,timepoint, searchspace, module, pattern );
        return;
    }
}

/*****************************************************************************

FUNCTION
	void	In_o_Literal( x, c, patten, solution )

DESCRIPTION
        In-relations to system omega classes (without search-space and time checks)

HISTORY
	22.11.94 TL     created

BUGS

*****************************************************************************/


void In_o_Literal_wo_timecheck( TOID x, TOID c, int pattern, TOIDSETSTL &solution, TDB *database, int searchspace)
{
#ifdef LitOutput
    printf("In_o_Literal_wo_timecheck\n");
#endif
   SYMID symid;
   TOID toid;
   char xinstanceof[]= "*instanceof";
   char xisa[]="*isa";

   if (pattern & FREE_ID_1 && pattern & FREE_ID_2)
   {
       printf("COS Error: unable to handle In_o(_,_)\n");
       return;
   }

   if (pattern & FREE_ID_1)
   {
       int c2=0;
       if (!strcmp(c.Lab().get_name(),"attribute")) {
	   c2 = SYSTEM_CLASS_ATTRIBUTE;
       } else if (!strcmp(c.Lab().get_name(),"*isa")) {
	   c2 = SYSTEM_CLASS_ISA;
       } else if (!strcmp(c.Lab().get_name(),"*instanceof")) {
	   c2 = SYSTEM_CLASS_INSTANCEOF;
       } else if (!strcmp(c.Lab().get_name(),"Proposition")) {
	   c2 = SYSTEM_CLASS_PROPOSITION;
       } else if (!strcmp(c.Lab().get_name(),"Individual")) {
	   c2 = SYSTEM_CLASS_INDIVIDUAL;
       } else {
	   c2 = 0;
       }


       switch (c2)
       {
       case SYSTEM_CLASS_PROPOSITION:
	   if (searchspace & ACTUAL_DB)
	       solution |= database->Akt();

	   if (searchspace & TEMP_DB_TELL)
	   {
	       solution |= database->Tmp1();
	       solution |= database->Tmp3();
	   }

           if (searchspace & TEMP_DB_UNTELL)
               solution |= database->Tmp2();
           

	   if (searchspace & HISTORY_DB)
	       solution |= database->Hist();
	   break;
       case SYSTEM_CLASS_INSTANCEOF:
	   if (database->Symb().get_symb(xinstanceof,symid))
	   {
	       solution |= *(symid.get_uses());
	   }
	   break;
       case SYSTEM_CLASS_ISA:
	   if (database->Symb().get_symb(xisa,symid))
	   {
	       solution |= *(symid.get_uses());
	   }
	   break;
       case SYSTEM_CLASS_ATTRIBUTE:
	   database->Symb().get_attributes(solution);
	   break;
       case SYSTEM_CLASS_INDIVIDUAL:
	   database->Symb().get_individuals(solution);
	   break;
       }
   }
   else
   {
       char select[30];
       if (x == x.Src() && x == x.Dst()) {
	   strcpy(select,"Individual");
       } else if (!strcmp(x.Lab().get_name(),"*isa")) {
	   strcpy(select,"Proposition=>Proposition");
       } else if (!strcmp(x.Lab().get_name(),"*instanceof")) {
	   strcpy(select,"Proposition->Proposition");
       } else {
	   strcpy(select,"Proposition!attribute");
       }
       if (database->select2toid(select,toid)) 
       {
	   solution.add(toid);
       }
       strcpy(select,"Proposition");
       if (database->select2toid(select,toid)) 
       {
	   solution.add(toid);
       }
       if (!(pattern & FREE_ID_2))
       {
           if (!solution.contains(c))
               solution.clear();
           else
           {
               solution.clear();
               solution.add(c);
           }
       }
   }
}

/*****************************************************************************

FUNCTION
	void	In_o_Literal( ... )

DESCRIPTION        
        In_o literal with time and/or search-space checks

HISTORY
	12.03.97 TL     created

BUGS

*****************************************************************************/


void In_o_Literal( TOID x, TOID c, int pattern, TOIDSETSTL &solution, TDB *database,
		   TIMEPOINT timepoint, int searchspace, TOID module )
{
#ifdef LitOutput
    printf(" In_o_Literal\n");
#endif
    TOIDSETSTL tmp;
    TOIDSetIterator ind;
    
    In_o_Literal_wo_timecheck(x,c,pattern,tmp,database,searchspace);
    
    for (ind=tmp.begin();ind!=tmp.end();ind++)
    {
        if (tmp(ind).is_valid(timepoint,searchspace,module))
            solution.add(tmp(ind));
    }
}


/*****************************************************************************

FUNCTION
	void	Adot_Literal( x, c, patten, solution )

DESCRIPTION        
                    

HISTORY
	30.11.94 TL     created

BUGS

*****************************************************************************/

void Adot_Literal( TOID cc, TOID x, SYMID ml, TOID y, 
		   int pattern, TOIDSETSTL &solution, 
		   TIMEPOINT timepoint, int searchspace, TOID module )
{
#ifdef LitOutput
    printf("Adot_Literal\n");
#endif    
    TOIDSetIterator ind,ind2;
    TOID toid;
    int method;

  /* printf("Adot-Literal: (");
   * if (!(pattern & 1)) printf("id_%d,",cc.GetId()); else printf("_,");
   * if (!(pattern & 2)) printf("id_%d,",x.GetId()); else printf("_,");
   * if (!(pattern & 4)) printf("%s,",ml.get_name()); else printf("_,");
   * if (!(pattern & 8)) printf("id_%d",y.GetId()); else printf("_");
   * printf(")\n");
   */

    if (pattern & FREE_CC) 
	{
	    printf("   ConceptBase Object Storage:\n");
	    printf("   Warning: Adot - Literal called with free concerned\n");
	    printf("            class. The storage module is not able to calculate \n");
	    printf("            this query, but this should never be called!\n");
	    return;
	}

/* the ml argument must be the label of the object identified by cc
   We skip this test since we assume that the formula compiler will take
   care of this. Moreover, the ml argument as a whole might be abandoned
   (ticket 195)

    if (!(pattern & FREE_ML))
	{
	    if (!(ml == cc.Lab())) 
		return;
	}
*/


    /*
     *  Choose evaluation strategy for the Adot literal.
     *  Two approaches: from ConcernedClass, or from X or Y.
     *  If X or Y is given, use the number of incoming (or outgoing) attributes.
     *  30-Oct-2008/M.Jeusfeld: compare with size of cc extension instead of constant
     */


    if ((pattern & FREE_X) && (pattern & FREE_Y)) 
    {
	method = ADOT_METHOD_CC;
    } 
    else if (!(pattern & FREE_X) && !(pattern & FREE_Y))
    { 
	method = ADOT_METHOD_X_Y;
    }
    else if (!(pattern & FREE_X) && (x.AtrO().length() <= cc.IofI().length()))
    {
	method = ADOT_METHOD_X;
    }
    else if (!(pattern & FREE_Y) && (y.AtrI().length() <= cc.IofI().length()))
    {
	method = ADOT_METHOD_Y;
    }
    else
    {
	method = ADOT_METHOD_CC;
    }

    if (method == ADOT_METHOD_CC)
    {
	TOIDSETSTL helpset,ccset;
	ccset.add(cc);
	closure(ccset, helpset, specialization, timepoint, searchspace, module, pattern );
	for (ind2 = helpset.begin();ind2!=helpset.end();ind2++) 
	{
	    if (!helpset(ind2).IofI().length()) continue;
	    for (ind = helpset(ind2).IofI().begin();ind!=helpset(ind2).IofI().end();ind++)
	    {
		if (!helpset(ind2).IofI()(ind).is_valid(timepoint,searchspace,module,pattern,0)) continue;
		toid = helpset(ind2).IofI()(ind).Src();
		if (!toid.is_valid(timepoint,searchspace,module,pattern,0)) continue;
		if (!(FREE_X & pattern)) if (!(x == toid.Src())) continue;
		if (!(FREE_Y & pattern)) if (!(y == toid.Dst())) continue;
		solution.add(toid);
		if (!(FREE_X & pattern) && !(FREE_Y & pattern)) break;
	    }
	}
	return;
    }

    if (method == ADOT_METHOD_X)
    {

	TOIDSETSTL helpset,helpset2;
        if (x.AtrO().length()==0) return;
	for (ind = x.AtrO().begin();ind!=x.AtrO().end();ind++)
	{
	    helpset.clear();
	    helpset2.clear();
           
	    apply_desti(x.AtrO()(ind).IofO(),helpset2, timepoint, searchspace, module, pattern );
            
	    closure(helpset2, helpset, generalization, timepoint, searchspace, module, pattern );
	    if (helpset.contains(cc)) solution.add(x.AtrO()(ind));
	}
	return;
    }

    if (method == ADOT_METHOD_Y)
    {

	TOIDSETSTL helpset,helpset2;
	if (!y.AtrI().length()) return;
	for (ind = y.AtrI().begin();ind!=y.AtrI().end();ind++)
	{
	    helpset.clear();
	    helpset2.clear();
	    apply_desti(y.AtrI()(ind).IofO(),helpset2, timepoint, searchspace, module, pattern );
	    closure(helpset2, helpset, generalization, timepoint, searchspace, module, pattern );
	    if (helpset.contains(cc)) solution.add(y.AtrI()(ind));
	}
	return;
    }

    if (method == ADOT_METHOD_X_Y)
    {
	TOIDSETSTL helpset,helpset2;
	if (x.AtrO().length() < y.AtrI().length())
	{
	    if (!x.AtrO().length()) return;
	    for (ind = x.AtrO().begin();ind!=x.AtrO().end();ind++)
	    {
		if (!y.AtrI().contains(x.AtrO()(ind))) continue;
		helpset.clear();
		helpset2.clear();
		apply_desti(x.AtrO()(ind).IofO(),helpset2, timepoint, searchspace, module, pattern );
		closure(helpset2, helpset, generalization, timepoint, searchspace, module, pattern );
		if (helpset.contains(cc)) 
		{
		    solution.add(x.AtrO()(ind));
		    return ;  // at most one solution possible!
		}
	    }
	    return;
	} 
	else 
	{
	    if (!y.AtrI().length()) return;
	    for (ind = y.AtrI().begin();ind!=y.AtrI().end();ind++)
	    {
		if (!x.AtrO().contains(y.AtrI()(ind))) continue;
		helpset.clear();
		helpset2.clear();
		apply_desti(y.AtrI()(ind).IofO(),helpset2, timepoint, searchspace, module, pattern );
		closure(helpset2, helpset, generalization, timepoint, searchspace, module, pattern );
		if (helpset.contains(cc)) 
		{
		    solution.add(y.AtrI()(ind));
		    return ;  // at most one solution possible!
		}
	    }
	    return;
	}
    }


}

/*****************************************************************************

FUNCTION
	void	Aidot_Literal( x, c, pattern, solution )

DESCRIPTION        
                    

HISTORY
	26.01.2009 M.Jeusfeld     created (adapted from Adot_Literal)

BUGS

*****************************************************************************/

void Aidot_Literal( TOID cc, TOID x, SYMID ml, TOID y, 
		   int pattern, TOIDSETSTL &solution, 
		   TIMEPOINT timepoint, int searchspace, TOID module )
{
#ifdef LitOutput
    printf("Aidot_Literal\n");
#endif    
    TOIDSetIterator ind,ind2;
    TOID toid;
    int method;

  /* printf("Aidot-Literal: (");
   * if (!(pattern & 1)) printf("id_%d,",cc.GetId()); else printf("_,");
   * if (!(pattern & 2)) printf("id_%d,",x.GetId()); else printf("_,");
   * if (!(pattern & 4)) printf("%s,",ml.get_name()); else printf("_,");
   * if (!(pattern & 8)) printf("id_%d",y.GetId()); else printf("_");
   * printf(")\n");
   */


    if (pattern & FREE_CC) 
	{
	    printf("   ConceptBase Object Storage:\n");
	    printf("   Warning: Adot - Literal called with free concerned\n");
	    printf("            class. The storage module is not able to calculate \n");
	    printf("            this query, but this should never be called!\n");
	    return;
	}

/* the ml argument must be the label of the object identified by cc
   We skip this test since we assume that the formula compiler will take
   care of this. Moreover, the ml argument as a whole might be abandoned
   (ticket 195)

    if (!(pattern & FREE_ML))
	{
	    if (!(ml == cc.Lab())) 
		return;
	}
*/


    /*
     *  Choose evaluation strategy for the Aidot literal.
     *  Two approaches: from ConcernedClass, or from X or Y.
     *  If X or Y is given, use the number of incoming (or outgoing) attributes.
     *  30-Oct-2008/M.Jeusfeld: compare with size of cc extension instead of constant
     */


    if ((pattern & FREE_X) && (pattern & FREE_Y)) 
    {
	method = ADOT_METHOD_CC;
    } 
    else if (!(pattern & FREE_X) && !(pattern & FREE_Y))
    { 
	method = ADOT_METHOD_X_Y;
    }
    else if (!(pattern & FREE_X) && (x.AtrO().length() <= cc.IofI().length()))
    {
	method = ADOT_METHOD_X;
    }
    else if (!(pattern & FREE_Y))
    {
	method = ADOT_METHOD_Y;
    }
    else
    {
	method = ADOT_METHOD_CC;
    }

    if (method == ADOT_METHOD_CC)
    {
	TOIDSETSTL helpset,ccset;
	ccset.add(cc);
	closure(ccset, helpset, specialization, timepoint, searchspace, module, pattern );
	for (ind2 = helpset.begin();ind2!=helpset.end();ind2++) 
	{
	    if (!helpset(ind2).IofI().length()) continue;
	    for (ind = helpset(ind2).IofI().begin();ind!=helpset(ind2).IofI().end();ind++)
	    {
		if (!helpset(ind2).IofI()(ind).is_valid(timepoint,searchspace,module,pattern,0)) continue;
		toid = helpset(ind2).IofI()(ind).Src();
		if (!toid.is_valid(timepoint,searchspace,module,pattern,0)) continue;
		if (!(FREE_X & pattern)) if (!(x == toid.Src())) continue;
		if (!(FREE_Y & pattern)) if (!(y == toid)) continue;
		solution.add(toid);
		if (!(FREE_X & pattern) && !(FREE_Y & pattern)) break;
	    }
	}
	return;
    }

    if (method == ADOT_METHOD_X)
    {

	TOIDSETSTL helpset,helpset2;
        if (x.AtrO().length()==0) return;
	for (ind = x.AtrO().begin();ind!=x.AtrO().end();ind++)
	{
	    helpset.clear();
	    helpset2.clear();
           
	    apply_desti(x.AtrO()(ind).IofO(),helpset2, timepoint, searchspace, module, pattern );
            
	    closure(helpset2, helpset, generalization, timepoint, searchspace, module, pattern );
	    if (helpset.contains(cc)) solution.add(x.AtrO()(ind));
	}
	return;
    }

// if Y (=id of an attribute) is bound then there is at most one possible solution for x

    if (method == ADOT_METHOD_Y)
    {

	TOIDSETSTL helpset,helpset2;
	helpset.clear();
	helpset2.clear();
	apply_desti(y.IofO(),helpset2, timepoint, searchspace, module, pattern );
	closure(helpset2, helpset, generalization, timepoint, searchspace, module, pattern );
	if (helpset.contains(cc)) solution.add(y);
	return;
    }

// if both X,Y are bound, we require that X is the source of the attribute Y

    if (method == ADOT_METHOD_X_Y)
    {

	TOIDSETSTL helpset,helpset2;
        if (!(x==y.Src())) return;
	helpset.clear();
	helpset2.clear();
	apply_desti(y.IofO(),helpset2, timepoint, searchspace, module, pattern );
	closure(helpset2, helpset, generalization, timepoint, searchspace, module, pattern );
	if (helpset.contains(cc)) solution.add(y);
	return;
    }


}





/*****************************************************************************

FUNCTION
	void	P_Literal_wo_timecheck( ... )

DESCRIPTION        
        P literal without time or search-space checks

HISTORY
	12.03.97 TL     created

BUGS

*****************************************************************************/



void P_Literal_wo_timecheck( TOID id, TOID src, SYMID label, TOID dst, 
                int pattern, TOIDSETSTL &solution, class TDB *database,
                TIMEPOINT timepoint, int searchspace)
{
#ifdef LitOutput
    printf("P_Literal_wo_timecheck\n");
    if (!(FREE_ID & pattern)) printf("id=%ld\n",id.GetId());
    if (!(FREE_SRC & pattern)) printf("src=%ld\n",src.GetId());
    if (!(FREE_LAB & pattern)) printf("lab=%s\n",label.get_name());
    if (!(FREE_DST & pattern)) printf("dst=%ld\n",dst.GetId);
#endif

   /*
   *  id given: get information about id
   *  if the id is given, there are 0-1 solutions! Check if the id
   *  itself is the solution!
   */
   if (!(FREE_ID & pattern)) 
       {
	   /* the id's should be compared "!=", but this
	      operator is not defined! */
	   if (!(FREE_SRC & pattern) && !(id.Src()==src)) return;
	   if (!(FREE_DST & pattern) && !(id.Dst()==dst)) return;
	   if (!(FREE_LAB & pattern) && !(id.Lab()==label)) return;
	   if (id.is_valid(timepoint,searchspace)) solution.add(id);
	   return;
       }

	   
   /*
   * label given AND neither src nor dst are given!
   */
   if ( !(FREE_LAB & pattern) && (FREE_SRC & pattern) && (FREE_DST & pattern) ) 
   { 
       solution |= *(label.get_uses());
       return;
   }


/*************************************************************************
 *
 *             s r c   d s t   &   l a b e l   I n f o r m a t i o n
 *
 *************************************************************************/


   TOIDSETSTL src_information,
           dst_information;

   int     is_Label, 
           Label_type;

   is_Label = !(FREE_LAB & pattern);
   Label_type = (is_Label) ? label.get_type() : UNDEF;

   if (is_Label)
   {

           /*
            *    case 1
            *         possible individuals as solutions
            *         - (_,id,lab,id) has solution (id,id,lab,id)
            *         - (_id must not be bound, see above)
            */
       
       TOID toid;
       
       if ( ( (FREE_SRC & pattern) || ((toid=src).Lab() == label ) )
            &&
	    ( (FREE_DST & pattern) || ((toid=dst).Lab() == label ) ) )
       {
	   solution.add(toid);
       }
       
           /*
            *    case 2
            *         Possible attribute, IsA, or InstanceOf relations
            */
       
       TOIDSETSTL *src_information_ref=NULL, *dst_information_ref=NULL;
       
       if (!(FREE_SRC & pattern)) 	// this means: src is given
       {
           switch (Label_type) 
           {
           case ISA:
	       src_information_ref = &src.IsaO();
               break;
           case INSTANCEOF:
	       src_information_ref = &src.IofO();
               break;
	   default:
	       src_information_ref = &src.AtrO();
               break;
           }
       }
       
       
       
       if (!(FREE_DST & pattern)) 	// this means: dst is given
       {
           switch (Label_type) 
           {
           case ISA:
	       dst_information_ref = &dst.IsaI();
               break;
           case INSTANCEOF:
	       dst_information_ref = &dst.IofI();
               break;
	   default:
	       dst_information_ref = &dst.AtrI();
               break;
           }
       }
       
       if (!(FREE_SRC & pattern) && !(FREE_DST & pattern))
               /* in this case, BOTH src and dst are given */
       {
           
	   if (src_information_ref->length() < dst_information_ref->length())
	   {
	       if (!src_information_ref->length()) return;
	       for (TOIDSetIterator i=src_information_ref->begin();i!=src_information_ref->end();i++)
	       {
                       /*
                        * if Label_type == NONE the label must be checked;
                        *  for InstanceOf or IsA the label is automatically correct,
                        *  but only pointers are compared
                        */
		   if (!((*src_information_ref)(i).Lab() == label)) continue;
		   if (dst_information_ref->contains((*src_information_ref)(i)))
		       solution.add((*src_information_ref)(i));
	       }
	   }
	   else 
           {
	       if (!dst_information_ref->length()) return;
	       for (TOIDSetIterator i=dst_information_ref->begin();i!=dst_information_ref->end();i++)
	       {
                       /*
                        * if Label_type == NONE the label must be checked;
                        *  for InstanceOf or IsA the label is automatically correct,
                        *  but only pointers are compared
                        */
		   if (!((*dst_information_ref)(i).Lab() == label)) continue;
		   if (src_information_ref->contains((*dst_information_ref)(i)))
		       solution.add((*dst_information_ref)(i));
	       }
           }
	   return;
       }
       
       if(!(FREE_SRC & pattern))
               /* only src is given */
       {
	   if (!src_information_ref->length()) return;
	   if (Label_type != NONE)
	   {
	       solution |= *src_information_ref;
	   } 
	   else 
	   {
	       for (TOIDSetIterator i=src_information_ref->begin();i!=src_information_ref->end();i++)
	       {
		   if ((*src_information_ref)(i).Lab() == label)
		       solution.add((*src_information_ref)(i));
	       }
	   }	       
	   return;
       }


       if (!(FREE_DST & pattern))
               /* only dst is given */
       {
	   if (!dst_information_ref->length()) return;
	   if (Label_type != NONE)
	   {
	       solution |= *dst_information_ref;
	   } 
	   else 
	   {
	       for (TOIDSetIterator i=dst_information_ref->begin();i!=dst_information_ref->end();i++)
	       {
		   if ((*dst_information_ref)(i).Lab() == label)
		       solution.add((*dst_information_ref)(i));
	       }
	   }	       
	   return;
       }
       
           /*
            * everything should already be finished here!
            */
       printf("Error #223 in TOID.cc\n");

   }


       /*
        *   cases where the label is unknown
        */


       /*
        *  src given: get information about src
        */
   if (!(FREE_SRC & pattern)) 	// this means: src is given
   {
           // possible attribute, IsA, or InstanceOf solutions
       src_information |= src.IsaO();
       src_information |= src.IofO();
       src_information |= src.AtrO( );
           // possible individual solution
       if (src == src.Src())
	   src_information.add(src);       
   }


       /*
        *  dst given: get information about dst
        */
   if (!(FREE_DST & pattern)) 
   {
           // possible attribute, IsA, or InstanceOf solutions
       dst_information |= dst.IsaI();
       dst_information |= dst.IofI();
       dst_information |= dst.AtrI();
           // possible individual solution
       if (dst == dst.Src())
	   dst_information.add(dst);
   }


       /*
        *  Compare solutions
        */
   if (!(FREE_SRC & pattern) && !(FREE_DST & pattern))
           /* in this case, BOTH src and dst are given */
   {
       solution |= src_information;
       solution &= dst_information;
       return;
   }
   

   if(!(FREE_SRC & pattern))
           /* only src is given */
   {
       solution |= src_information;
       return;
   }



   if (!(FREE_DST & pattern))
           /* only dst is given */
   {
       solution |= dst_information;
       return;
   }


/*************************************************************************
 *
 *          n o   r e a l   I n f o r m a t i o n 
 *
 *************************************************************************/


   /* create the smallest space of possible results */

   if (searchspace & ACTUAL_DB)
       solution |= database->Akt();

   if (searchspace & TEMP_DB_TELL)
   {
       solution |= database->Tmp1();
       solution |= database->Tmp3();
   }

   if (searchspace & TEMP_DB_UNTELL)
       solution |= database->Tmp2();

   if (searchspace & HISTORY_DB)
       solution |= database->Hist();

   if (searchspace & ACTUAL_DB)
   {
#if DLEVEL >= 5
       printf("*** Literals.cc warning: complete DB scan \n");
#endif
   }



}


/*****************************************************************************

FUNCTION
	void	P_Literal( ... )

DESCRIPTION        
        P literal with time and/or search-space checks

HISTORY
	12.03.97 TL     created

BUGS

*****************************************************************************/


void P_Literal( TOID id, TOID src, SYMID label, TOID dst, 
                int pattern, TOIDSETSTL &solution, class TDB *database,
                             TIMEPOINT timepoint, int searchspace, TOID module )
{
     // printf("P_Literal\n");
    
    TOIDSETSTL tmp;
    TOIDSetIterator ind;
    
    P_Literal_wo_timecheck(id,src,label,dst,pattern,tmp,database,timepoint,searchspace);
    
    for (ind=tmp.begin();ind!=tmp.end();ind++)
    {
        if (tmp(ind).is_valid(timepoint,searchspace,module))
            solution.add(tmp(ind));
    }
}

// addSolution uses a special ID assignment scheme in the solution set to find
// (and prevent) duplicate entries quickly; used in ALit
void addSolution(TOIDSETSTL &solution,TOID &lab,TOID &scrdst)
{
     TOID *toid=new TOID;
     TOIDSetIterator ind;
         // adjust this line if too many hash collisions occur
     long ID=scrdst.Src().GetId()*7+scrdst.Dst().GetId()*11+lab.GetId()*13;
      //printf("addsolution...%d (Label=%s id=%ld)\n",solution.length(),lab.Lab().get_name(),ID);          
     toid->create(ID);
     toid->Update_Label(*(new SYMID(lab.Lab().get_name())));
     toid->Update(scrdst.Src(),scrdst.Dst());
     int lengthDelta=solution.length();
     solution.add(*toid);
     lengthDelta-=solution.length();
     if (!lengthDelta) // if length unchanged, the new entry reused an existing ID
     {
             //    printf("******************ID collision...*******************");
         while (((ind=solution.seek(*toid))!=solution.end()))
         {
             
/*             printf("compare: (%ld,%s,%ld) with (%ld,%s,%ld) result: %d %d %d\n",
 *                   (solution)(ind).Src().GetId(),(solution)(ind).Lab().get_name(),(solution)(ind).Dst().GetId(),
 *                   toid->Src().GetId(),toid->Lab().get_name(),toid->Dst().GetId(),
 *                   ((solution)(ind).Src().GetId()!=toid->Src().GetId()),
 *                   (strcmp((solution)(ind).Lab().get_name(),toid->Lab().get_name())),
 *                   ((solution)(ind).Dst().GetId()!=toid->Dst().GetId()));  */
 
             if (((solution)(ind).Src().GetId()!=toid->Src().GetId())
                 || ((solution)(ind).Dst().GetId()!=toid->Dst().GetId())
                 || (strcmp((solution)(ind).Lab().get_name(),toid->Lab().get_name())))
             {
                     // entries are not identical
                     // first check entry in normal solution, then overflow entries (<0)
                 if (ID>0) ID=-1; else ID--;
                 toid->SetId(ID);
             }
             else
             {
                 /*printf("Entry was already present.\n");*/
                 return; // entry already in overflow list -> done
             } 
         }
#ifdef CB_TRACE         
         printf("Current number of hash collisions: %ld\n",-ID);
#endif         
         if (ID<-5)
         {
             printf("***********************************************************************************\n");
             printf("*  The number of overflow entries in Literals.cc::addSolution() is greater than 5!! *\n");
             printf("***********************************************************************************\n");
         }
         solution.add(*toid);
//         printf("new ID=%ld\n",ID);
     } 
}
    
/*****************************************************************************

FUNCTION
	void	A_Literal( ... )

DESCRIPTION        
        A-Literal with time and/or search-space checks

HISTORY
	19.12.97 MP     created

BUGS
       none

*****************************************************************************/


void A_Literal( TOID x, SYMID ml, TOID y,
                int pattern, TOIDSETSTL &solution,
                TIMEPOINT timepoint, int searchspace, TOID module )
{
#ifdef LitOutput
    printf("A_Literal\n");
#endif

    TOIDSETSTL helpset,helpset2;
    if (!(pattern & FREE_ML))
    {
         // printf("ML=%s\n",ml.get_name());

            // ML is bound and a help set of all possible meta labels is created
//        printf("ML is bound, creating label set with specializations...");
        
        TOIDSETSTL MLabelSet;
        MLabelSet|=*(ml.get_uses());
        closure(MLabelSet, helpset, specialization, timepoint, searchspace, module, pattern );
        //printf("create MetaLabelHelpset (%d)\n",helpset.length());
    }
    
    TOIDSETSTL *x_information_ref=NULL;
    TOIDSETSTL *y_information_ref=NULL;
    
    if (!(pattern & FREE_X))
    {
         //printf("X is bound, creating AtrO set...\n");
        x_information_ref = &x.AtrO();
         //printf("(%d) done\n",x_information_ref->length());
    }
    
    
    if (!(pattern & FREE_Y))
    {
        // printf("Y is bound, creating AtrI set...");
        y_information_ref = &y.AtrI();
        
        // printf("(%d) done\n",y_information_ref->length());
    }
    if ((pattern & FREE_X) && (pattern & FREE_Y) && (pattern & FREE_ML))
    {
        printf("***********************************************************************************\n");
        printf("***********************************************************************************\n"); 
        printf("**   ConceptBase Object Storage:                                                 **\n");
	printf("**   Warning: ALiteral called with three free variables                          **\n");
	printf("**            The storage module is not able to calculate                        **\n");
        printf("**            this query, but this should never be called!                       **\n");
        printf("***********************************************************************************\n");
        printf("***********************************************************************************\n");
        return;
    }

    if ((pattern & FREE_X) && (pattern & FREE_Y)) {

            // X,Y free and ML bound
         if (helpset.length()==0) return;
         for (TOIDSetIterator index=helpset.begin();index!=helpset.end();index++)
         {
              //printf("determine instances of %s(id=%ld)...",(helpset)(index).Lab().get_name(),(helpset)(index).GetId());
             helpset2.clear();
             getInstances((helpset)(index), helpset2, timepoint, searchspace, module, pattern );
              //printf("%d found.\n",helpset2.length());
              //printf("return %d solutions\n",solution.length());
                 // helpset2 is at the instance level...
             if (helpset2.length()==0) return;
             for (TOIDSetIterator index2=helpset2.begin();index2!=helpset2.end();index2++)
             {
                  //printf("examining %s\n",(helpset2)(index2).Lab().get_name());
                 addSolution(solution,((helpset)(index)),((helpset2)(index2)));
             }
         }
         return;
    }

    if ((!(pattern & FREE_X)) && (!(pattern & FREE_Y)))
    {
             // X and Y bound
        if (x_information_ref->length() < y_information_ref->length())
        {
            if (!x_information_ref->length()) return;
//            printf("proceed from src\n");
            for (TOIDSetIterator i=x_information_ref->begin();i!=x_information_ref->end();i++)
            {
                if (y_information_ref->contains((*x_information_ref)(i)))
                {
                        // ML is free
                    if (pattern & FREE_ML)
                    {
                        helpset.clear();
                        getSuperObjects((*x_information_ref)(i), helpset, timepoint, searchspace, module, pattern );
                        helpset2.clear();
                        closure(helpset, helpset2, generalization, timepoint, searchspace, module, pattern );
                        if (!helpset2.length()) return;
                        for (TOIDSetIterator index2=helpset2.begin();index2!=helpset2.end();index2++)
                        {
                            addSolution(solution,((helpset2)(index2)),((*x_information_ref)(i)));
                        }
                    }
                    else
                    {
                            // ML is bound
                        bool run=true;
                        for (TOIDSetIterator index=helpset.begin();((index!=helpset.end()) && run);index++)
                        {
                            helpset2.clear();
                            getInstances((helpset)(index), helpset2, timepoint, searchspace, module, pattern );
//                            printf("%d instances found\n",helpset2.length());
                                // helpset2 is at the instance level...
                            for (TOIDSetIterator  index2=helpset2.begin();index2!=helpset2.end();index2++)
                            {
                                if ((*x_information_ref)(i)==helpset2(index2))
                                {
                                    addSolution(solution,((helpset)(index)),((*x_information_ref)(i)));
                                    run=false;
                                    break;
                                }
                            }
                        }
                    }
                } 
            }
            return;
        }
        else
        {
//            printf("proceed from dst\n");
            if (!y_information_ref->length()) return;
            for (TOIDSetIterator i=y_information_ref->begin();i!=y_information_ref->end();i++)
            {
            	bool run=true;
                if (x_information_ref->contains((*y_information_ref)(i)))
		{
                        // ML is free
                    if (pattern & FREE_ML)
                    {
                        helpset.clear();
                        getSuperObjects((*y_information_ref)(i), helpset, timepoint, searchspace, module, pattern );
                        helpset2.clear();
                        closure(helpset, helpset2, generalization, timepoint, searchspace, module, pattern );
                        if (!helpset2.length()) return;
                        for (TOIDSetIterator index2=helpset2.begin();index2!=helpset2.end();index2++)
                        {
                            addSolution(solution,((helpset2)(index2)),((*y_information_ref)(i)));
                        }
                    }
                    else
                            // ML is bound
                        for (TOIDSetIterator index=helpset.begin();((index!=helpset.end()) && run);index++)
                        {
                            helpset2.clear();
                            getInstances((helpset)(index), helpset2, timepoint, searchspace, module, pattern );
                            //printf("%d instances found\n",helpset2.length());
                            // helpset2 is at the instance level...
                            for (TOIDSetIterator index2=helpset2.begin();index2!=helpset2.end();index2++)
                            {
                                //printf("examining %s\n",(helpset2)(index2).Lab().get_name());
                                if ((*y_information_ref)(i)==helpset2(index2))
                                {
                                    addSolution(solution,((helpset)(index)),((*y_information_ref)(i)));
                                    run=false;
                                    break;
                                }
                            }
                        }
		}
            }
        }
        return;
    }

     // Now come the cases where X or (without and) Y is free
    if (pattern & FREE_X)
    {
        if (pattern & FREE_ML)
        {
              // ML free, X free, Y bound
            if (y_information_ref->length())
            {
                for (TOIDSetIterator i=y_information_ref->begin();i!=y_information_ref->end();i++)
                {
                    helpset.clear();
                    getSuperObjects((*y_information_ref)(i), helpset, timepoint, searchspace, module, pattern );
                    helpset2.clear();
                    closure(helpset, helpset2, generalization, timepoint, searchspace, module, pattern );
                    if (!helpset2.length()) return;
                    for (TOIDSetIterator index2=helpset2.begin();index2!=helpset2.end();index2++)
                    {
                        addSolution(solution,((helpset2)(index2)),((*y_information_ref)(i)));
                    }
                }
            }
            return;
        }
        else
        {
                // ML bound, X free, Y bound
            if (!y_information_ref->length()) return;
            for (TOIDSetIterator i=y_information_ref->begin();i!=y_information_ref->end();i++)
            {
            	bool run=true;
                for (TOIDSetIterator index=helpset.begin();((index!=helpset.end()) && run);index++)
                {
                    helpset2.clear();
                    getInstances((helpset)(index), helpset2, timepoint, searchspace, module, pattern );
                        // helpset2 is at the instance level...
                    for (TOIDSetIterator index2=helpset2.begin();index2!=helpset2.end();index2++)
                    {
                        if ((*y_information_ref)(i)==helpset2(index2))
                        {
                            addSolution(solution,(helpset)(index),(*y_information_ref)(i));
                            run=false; // also break the next outer loop
                            break;
                        }
                    }
                }
            }
            return;
        }    
    }
    else
    {
        if (pattern & FREE_ML)
        {
              // ML free, X bound, Y free
            if (x_information_ref->length())
            {
                for (TOIDSetIterator i=x_information_ref->begin();i!=x_information_ref->end();i++)
                {
                    helpset.clear();
                    getSuperObjects((*x_information_ref)(i), helpset, timepoint, searchspace, module, pattern );
                    helpset2.clear();
                    closure(helpset, helpset2, generalization, timepoint, searchspace, module, pattern );
                    if (!helpset2.length()) return;
                    for (TOIDSetIterator index2=helpset2.begin();index2!=helpset2.end();index2++)
                    {
                        addSolution(solution,((helpset2)(index2)),((*x_information_ref)(i)));
                    }
                }
                return;
            }
        }
        else
        {
                // ML bound, X bound, Y free
            if (!x_information_ref->length()) return;
            for (TOIDSetIterator i=x_information_ref->begin();i!=x_information_ref->end();i++)
            {
            	bool run=true;
                for (TOIDSetIterator index=helpset.begin();((index!=helpset.end()) && run);index++)
                {
                    helpset2.clear();
                    getInstances((helpset)(index), helpset2, timepoint, searchspace, module, pattern );
                    //printf("TOID: %ld\n",((helpset)(index)).GetId());
                    //printf("%d instances found\n",helpset2.length());
                        // helpset2 is at the instance level...
                    for (TOIDSetIterator index2=helpset2.begin();index2!=helpset2.end();index2++)
                    {
                        if ((*x_information_ref)(i)==helpset2(index2))
                        {
                            //printf("FOUND: %ld \n",((*x_information_ref)(i)).GetId());
                            addSolution(solution,(helpset)(index),(*x_information_ref)(i));
                            run=false;
                            //index=helpset.end(); // also break the next outer loop
                            break;
                        }
                    }
                }  
            }
        }
    }    
}


void addSolutionALabel(TOIDSETSTL &solution,TOID &lab,TOID &scrdst)
{
     TOID *toid=new TOID;
     TOIDSetIterator ind;
         // adjust this line if too many hash collisions occur
     long ID=scrdst.Src().GetId()*7+scrdst.Dst().GetId()*11+lab.GetId()*13;
//     printf("addsolution...%d (Label=%s id=%ld)\n",solution.length(),lab.Lab().get_name(),ID);          
     toid->create(ID);
     toid->Update_Label(*(new SYMID(lab.Lab().get_name())));
     toid->Update(scrdst,scrdst);
     int lengthDelta=solution.length();
     solution.add(*toid);
     lengthDelta-=solution.length();
     if (!lengthDelta) // if length unchanged, the new entry reused an existing ID
     {
             //    printf("******************ID collision...*******************");
         while (((ind=solution.seek(*toid))!=solution.end()))
         {
             
/*             printf("compare: (%ld,%s,%ld) with (%ld,%s,%ld) result: %d %d %d\n",
 *                   (solution)(ind).Src().GetId(),(solution)(ind).Lab().get_name(),(solution)(ind).Dst().GetId(),
 *                   toid->Src().GetId(),toid->Lab().get_name(),toid->Dst().GetId(),
 *                   ((solution)(ind).Src().GetId()!=toid->Src().GetId()),
 *                   (strcmp((solution)(ind).Lab().get_name(),toid->Lab().get_name())),
 *                   ((solution)(ind).Dst().GetId()!=toid->Dst().GetId()));  */
 
             if (((solution)(ind).Src().GetId()!=toid->Src().GetId())
                 || ((solution)(ind).Dst().GetId()!=toid->Dst().GetId())
                 || (strcmp((solution)(ind).Lab().get_name(),toid->Lab().get_name())))
             {
                     // entries are not identical
                     // first check entry in normal solution, then overflow entries (<0)
                 if (ID>0) ID=-1; else ID--;
                 toid->SetId(ID);
             }
             else
             {
                 /*printf("Entry was already present.\n");*/
                 return; // entry already in overflow list -> done
             } 
         }
#ifdef CB_TRACE         
         printf("Current number of hash collisions: %ld\n",-ID);
#endif         
         if (ID<-5)
         {
             printf("***********************************************************************************\n");
             printf("*  The number of overflow entries in Literals.cc::addSolution() is greater than 5!! *\n");
             printf("***********************************************************************************\n");
         }
         solution.add(*toid);
//         printf("new ID=%ld\n",ID);
     } 
}


/*****************************************************************************

FUNCTION
	void	Adot_Label_Literal( ... )

DESCRIPTION        
        Adot-Label_Literal with time and/or search-space checks

HISTORY
	3.09.98 MP     created 

BUGS
       unknown

*****************************************************************************/


void Adot_Label_Literal( TOID cc, TOID x, SYMID ml, TOID y, SYMID l,
                         int pattern, TOIDSETSTL &solution,
                         TIMEPOINT timepoint, int searchspace, TOID module )
{
#ifdef LitOutput
    printf("Adot_Label\n");
#endif
    
    if (!(pattern & 16)) 
    {
         // label is bound
        TOIDSETSTL toidset;
        Adot_Literal(cc,x,ml,y,pattern-16,toidset,timepoint,searchspace,module);
        for (TOIDSetIterator i=toidset.begin();i!=toidset.end();i++)
        {
            if (toidset(i).Lab()==l) 
            {
                solution.add(toidset(i));
            }
        }
    } else {
         // label is free
        Adot_Literal(cc,x,ml,y,pattern-16,solution,timepoint,searchspace,module);
    }
     //solution.test();
}




/*****************************************************************************

FUNCTION
	void	A_Label_Literal( ... )

DESCRIPTION        
        A-Label_Literal with time and/or search-space checks

HISTORY
	21.07.98 MP     created

BUGS
       unknown

*****************************************************************************/


void A_Label_Literal( TOID x, SYMID ml, SYMID l, TOID y,
                      int pattern, TOIDSETSTL &solution,
                      TIMEPOINT timepoint, int searchspace, TOID module )
{
#ifdef LitOutput
    printf("A_Label_Literal\n");
#endif
    
    TOIDSETSTL helpset,helpset2;
    if (!(pattern & FREE_ML))
    {
            // ML is bound and a help set of all possible meta labels is created
         //   printf("ML is bound, creating label set with specializations...");
        
        TOIDSETSTL MLabelSet;
        MLabelSet|=*(ml.get_uses());
        closure(MLabelSet, helpset, specialization, timepoint, searchspace, module, pattern );
//       printf("(%d) done\n",helpset.length());
    }
    
    TOIDSETSTL *x_information_ref=NULL;
    TOIDSETSTL *y_information_ref=NULL;
    
    if (!(pattern & FREE_X))
    {
         //      printf("X is bound, creating AtrO set...");
        x_information_ref = &x.AtrO();
         //printf("(%d) done\n",x_information_ref->length());
    }
    
    
    if (!(pattern & FREE_Y))
    {
         //printf("Y is bound, creating AtrI set...");
        y_information_ref = &y.AtrI();
         //printf("(%d) done\n",y_information_ref->length());
    }
    if ((pattern & FREE_X) && (pattern & FREE_Y) && (pattern & FREE_ML))
    {
        printf("***********************************************************************************\n");
        printf("***********************************************************************************\n"); 
        printf("**   ConceptBase Object Storage:                                                 **\n");
	printf("**   Warning: ALabel-Literal called with three free variables                    **\n");
	printf("**            The storage module is not able to calculate                        **\n");
        printf("**            this query, but this should never be called!                       **\n");
        printf("***********************************************************************************\n");
        printf("***********************************************************************************\n");
        return;
    }

    if ((pattern & FREE_X) && (pattern & FREE_Y)) {

            // X,Y free and ML bound
         if (helpset.length()==0) return;
         for (TOIDSetIterator index=helpset.begin();index!=helpset.end();index++)
         {
              //printf("determine instances of %s(id=%ld)...",(helpset)(index).Lab().get_name(),(helpset)(index).GetId());
            helpset2.clear();
            getInstances((helpset)(index), helpset2, timepoint, searchspace, module, pattern );
             //printf("%d found.\n",helpset2.length());
                                // helpset2 is at the instance level...
            if (helpset2.length()==0) return;
            for (TOIDSetIterator index2=helpset2.begin();index2!=helpset2.end();index2++)
            {
                                //printf("examining %s\n",(helpset2)(index2).Lab().get_name());
                if (!(pattern & FREE_CC))
                    if (!((helpset2)(index2).Lab()==l)) continue;
                addSolutionALabel(solution,((helpset)(index)),((helpset2)(index2))); 
            }
         }
         return;
    }
    
    if ((!(pattern & FREE_X)) && (!(pattern & FREE_Y)))
    {
             // X and Y bound
        if (x_information_ref->length() < y_information_ref->length())
        {
            if (!x_information_ref->length()) return;
//            printf("proceed from src\n");
            for (TOIDSetIterator i=x_information_ref->begin();i!=x_information_ref->end();i++)
            {
                if (y_information_ref->contains((*x_information_ref)(i)))
                    if (!(pattern & FREE_CC))
                        if (!((*x_information_ref)(i).Lab()==l)) continue;
                        // ML is free
                    if (pattern & FREE_ML)
                    {
                        helpset.clear();
                        getSuperObjects((*x_information_ref)(i), helpset, timepoint, searchspace, module, pattern );
                        helpset2.clear();
                        closure(helpset, helpset2, generalization, timepoint, searchspace, module, pattern );
                        if (!helpset2.length()) return;
                        for (TOIDSetIterator index2=helpset2.begin();index2!=helpset2.end();index2++)
                        {
                            addSolutionALabel(solution,((helpset2)(index2)),((*x_information_ref)(i)));
                        }
                    }
                    else
                    {
                    	bool run=true;
                            // ML is bound
                        for (TOIDSetIterator index=helpset.begin();((index!=helpset.end()) && run);index++)
                        {
                            helpset2.clear();
                            getInstances((helpset)(index), helpset2, timepoint, searchspace, module, pattern );
//                            printf("%d instances found\n",helpset2.length());
                                // helpset2 is at the instance level...
                            for (TOIDSetIterator index2=helpset2.begin();index2!=helpset2.end();index2++)
                            {
                                if ((*x_information_ref)(i)==helpset2(index2))
                                {
                                    addSolutionALabel(solution,((helpset)(index)),((*x_information_ref)(i)));
                                    run=false;
                                    break;
                                }
                            }
                        }
                    }
                
            }
            return;
        }
        else
        {
//            printf("proceed from dst\n");
            if (!y_information_ref->length()) return;
            for (TOIDSetIterator i=y_information_ref->begin();i!=y_information_ref->end();i++)
            {
            	bool run=true;
                if (x_information_ref->contains((*y_information_ref)(i)))
                    if (!(pattern & FREE_CC))
                        if (!((*y_information_ref)(i).Lab()==l)) continue;
                        // ML is free
                    if (pattern & FREE_ML)
                    {
                        helpset.clear();
                        getSuperObjects((*y_information_ref)(i), helpset, timepoint, searchspace, module, pattern );
                        helpset2.clear();
                        closure(helpset, helpset2, generalization, timepoint, searchspace, module, pattern );
                        if (!helpset2.length()) return;
                        for (TOIDSetIterator index2=helpset2.begin();index2!=helpset2.end();index2++)
                        {
                            addSolutionALabel(solution,((helpset2)(index2)),((*y_information_ref)(i)));
                        }
                    }
                    else
                            // ML is bound
                        for (TOIDSetIterator index=helpset.begin();((index!=helpset.end()) && run);index++)
                        {
                            helpset2.clear();
                            getInstances((helpset)(index), helpset2, timepoint, searchspace, module, pattern );
//                            printf("%d instances found\n",helpset2.length());
                                // helpset2 is at the instance level...
                            for (TOIDSetIterator index2=helpset2.begin();index2!=helpset2.end();index2++)
                            {
//                                printf("examining %s\n",(helpset2)(index2).Lab().get_name());
                                if ((*y_information_ref)(i)==helpset2(index2))
                                {
                                    addSolutionALabel(solution,((helpset)(index)),((*y_information_ref)(i)));
                                    run=false;
                                    break;
                                }
                            }
                        }
            }
        }
        return;
    }


        // Now come the cases where X or (without and) Y is free
    if (pattern & FREE_X)
    {
        if (pattern & FREE_ML)
        {
              // ML free, X free, Y bound
            if (y_information_ref->length())
            {
                for (TOIDSetIterator i=y_information_ref->begin();i!=y_information_ref->end();i++)
                {
                    if (!(pattern & FREE_CC))
                        if (!((*y_information_ref)(i).Lab()==l)) continue;
                    helpset.clear();
                    getSuperObjects((*y_information_ref)(i), helpset, timepoint, searchspace, module, pattern );
                    helpset2.clear();
                    closure(helpset, helpset2, generalization, timepoint, searchspace, module, pattern );
                    if (!helpset2.length()) return;
                    for (TOIDSetIterator index2=helpset2.begin();index2!=helpset2.end();index2++)
                    {
                        addSolutionALabel(solution,((helpset2)(index2)),((*y_information_ref)(i)));
                    }
                }
            }
            return;
        }
        else
        {
                // ML bound, X free, Y bound
            if (!y_information_ref->length()) return;
            for (TOIDSetIterator i=y_information_ref->begin();i!=y_information_ref->end();i++)
            {
            	bool run=true;
                if (!(pattern & FREE_CC))
                    if (!((*y_information_ref)(i).Lab()==l)) continue;
                for (TOIDSetIterator index=helpset.begin();((index!=helpset.end()) && run);index++)
                {
                    helpset2.clear();
                    getInstances((helpset)(index), helpset2, timepoint, searchspace, module, pattern );
                        // helpset2 is at the instance level...
                    for (TOIDSetIterator index2=helpset2.begin();index2!=helpset2.end();index2++)
                    {
                        if ((*y_information_ref)(i)==helpset2(index2))
                        {
                            addSolutionALabel(solution,(helpset)(index),(*y_information_ref)(i));
                            run=false; // also break the next outer loop
                            break;
                        }
                    }
                }
            }
            return;
        }    
    }
    else
    {
        if (pattern & FREE_ML)
        {
              // ML free, X bound, Y free
            if (x_information_ref->length())
            {
                for (TOIDSetIterator i=x_information_ref->begin();i!=x_information_ref->end();i++)
                {
                    if (!(pattern & FREE_CC))
                        if (!((*x_information_ref)(i).Lab()==l)) continue;
                    helpset.clear();
                    getSuperObjects((*x_information_ref)(i), helpset, timepoint, searchspace, module, pattern );
                    helpset2.clear();
                    closure(helpset, helpset2, generalization, timepoint, searchspace, module, pattern );
                    if (!helpset2.length()) return;
                    for (TOIDSetIterator index2=helpset2.begin();index2!=helpset2.end();index2++)
                    {
                        addSolutionALabel(solution,((helpset2)(index2)),((*x_information_ref)(i)));
                    }
                }
                return;
            }
        }
        else
        {
                // ML bound, X bound, Y free
            if (!x_information_ref->length()) return;
            for (TOIDSetIterator i=x_information_ref->begin();i!=x_information_ref->end();i++)
            {
            	bool run=true;
                if (!(pattern & FREE_CC))
                    if (!((*x_information_ref)(i).Lab()==l)) continue;
                for (TOIDSetIterator  index=helpset.begin();((index!=helpset.end()) && run);index++)
                {
                    helpset2.clear();
                    getInstances((helpset)(index), helpset2, timepoint, searchspace, module, pattern );
                        // helpset2 is at the instance level...
                    for (TOIDSetIterator  index2=helpset2.begin();index2!=helpset2.end();index2++)
                    {
                        if ((*x_information_ref)(i)==helpset2(index2))
                        {
                            addSolutionALabel(solution,(helpset)(index),(*x_information_ref)(i));
                            run=false;
                            break;
                        }
                    }
                }  
            }
        }
    }    
}



void Isa_Literal(TOID c1,TOID c2,int pattern, TOIDSETSTL &solution,
                TIMEPOINT timepoint, int searchspace, TOID module )
{
#ifdef LitOutput
    printf("Isa_Literal\n");
#endif
    
        // the isa literal; c1 is interpreted as src and c2 as dst
    TOIDSETSTL helpset1,helpset2;
    if ((pattern & FREE_ID_1) && (pattern & FREE_ID_2))
    {
        printf("***********************************************************************************\n");
        printf("***********************************************************************************\n"); 
        printf("**   ConceptBase Object Storage:                                                 **\n");
	printf("**   Warning: Isa-Literal called with two free variables                         **\n");
	printf("**            The storage module is not able to calculate                        **\n");
        printf("**            this query, but this should never be called!                       **\n");
        printf("***********************************************************************************\n");
        printf("***********************************************************************************\n");
        return;
    }
    if (!(pattern & FREE_ID_1) && !(pattern & FREE_ID_2))
    {
            // c1 and c2 are given
        helpset2.add(c1);
        closure(helpset2, helpset1, generalization, timepoint, searchspace, module, pattern );
        if (helpset1.contains(c2))
        {
                //solution is: (c1 from ID,c1,_,c2)
            solution.add(c1);
        }
        return;
    }
    if (!(pattern & FREE_ID_1))
    {
            // only c1 is given
        helpset2.add(c1);
        closure(helpset2, helpset1, generalization, timepoint, searchspace, module, pattern );
            //solution is: (_,c1,_,helpset1)
        if (!helpset1.length()) return;
        for (TOIDSetIterator i=helpset1.begin();i!=helpset1.end();i++)
        {
            solution.add((helpset1)(i));            
        }
        return;
    }
    if (!(pattern & FREE_ID_2))
    {
            // only c2 is given
        helpset2.add(c2);
        closure(helpset2, helpset1, specialization, timepoint, searchspace, module, pattern );
            //solution is: (_,helpset1,_,c2)
        if (!helpset1.length()) return;
        for (TOIDSetIterator i=helpset1.begin();i!=helpset1.end();i++)
        {
            solution.add((helpset1)(i));            
        }
        return;
    }
}

// Link id originates from x
// function was not tested
void From(TOID id,TOID toid,int pattern, TOIDSETSTL &solution,
          TIMEPOINT timepoint, int searchspace, TOID module ) 
{
#ifdef LitOutput
    printf("From\n");
#endif
    
    TOIDSETSTL helpset;
    helpset|=toid.AtrO();
    solution.clear();
    for (TOIDSetIterator i=helpset.begin();i!=helpset.end();i++)
    {
        if ((helpset)(i).GetId()==id.GetId())
        {
            if  (helpset(i).is_valid(timepoint,searchspace,module,pattern,0))
            {
                solution.add(toid);
                return;
            }
        }
    }
    return;
}

// Link id goes into toid
// function was not tested
void To(TOID id,TOID toid,int pattern, TOIDSETSTL &solution,
        TIMEPOINT timepoint, int searchspace, TOID module ) 
{
#ifdef LitOutput
    printf("To\n");
#endif
    
    TOIDSETSTL helpset;
    helpset|=toid.AtrI();
    solution.clear();
    for (TOIDSetIterator i=helpset.begin();i!=helpset.end();i++)
    {
        if ((helpset)(i).GetId()==id.GetId())
        {
            if  (helpset(i).is_valid(timepoint,searchspace,module,pattern,0))
            {
                solution.add(toid);
                return;
            }
        }
    }
    return;
}


        
// id has label l
// function was not tested
void Label(TOID id,TOID l,int pattern, TOIDSETSTL &solution,
          TIMEPOINT timepoint, int searchspace, TOID module ) 
{
#ifdef LitOutput
     printf("Label\n");
#endif
    
    if ((id.Lab()==l.Lab()) && (id.is_valid(timepoint,searchspace,module,pattern,0)))
    {
        solution.add(id);
    }
}

























