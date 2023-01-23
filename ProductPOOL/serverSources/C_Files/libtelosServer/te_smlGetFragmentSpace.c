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


This license is a FreeBSD-style copyright license.
Legal home of the FreeBSD copyright license: http://www.freebsd.org/copyright/freebsd-license.html
*/
/* 
*
* File:         %M%
* Version:      %I%
* Creation:     ???
* Last Change   : %E%, Christoph Quix (RWTH)
*
* SCCS-Source-Pool : %P%
* Date retrieved : %D% (YY/MM/DD)
* -----------------------------------------------------
*/

 /* The following functions compute the amount of memory needed
   for converting an smlFragmentList into the corresponding Prolog term.
   Called by FragmentCToProlog().

   remarks:
   - According to BIM, one shouldn't care about heap space / garbage collection when constructing terms externally by unification. However, garbage collection during construction destroys the (partially instantiated) term. So we have to check if there is enough heap space before calling FragmentCToProlog().
   - I'm not sure if each appearance of nil requires one cell or not. For the sake of security, I suppose it does. 24.11.93 CR
*/

#include <stdlib.h>
#include <string.h>
#include "te_smlGetFragmentSpace.h"


static size_t getObjectIdSpace( const ObjectIdentifier *oid );


static size_t getBindingListSpace( const BindingList *blist )
{
    const BindingList *lauf;
    size_t n = 0;

    lauf = blist;
    while( lauf )
    {
	n += 2;  /* list */
	if( lauf->lab1 && lauf->lab2 )
	{
	    if( !strcmp( lauf->op, "/" ) )
		n += 3;  /* substitute */
	    else  /* lauf->op == ":" */
		n += 3;  /* specialize */

	    n += getObjectIdSpace( lauf->lab1 );
	    n += getObjectIdSpace( lauf->lab2 );
	}
	lauf = lauf->next;
    }  /* while */
    n += 1;  /* nil */
    return n;
}  /* getBindingListSpace */


static size_t getObjectIdSpace( const ObjectIdentifier *oid )
{
    size_t n = 0;
    
    if( oid ) {
	if (oid->id) {
	    if (oid->bind) {  /* derive expression: */
		n += 3;  /* derive */
		n += 1;  /* oid->id */
		n += getBindingListSpace( oid->bind );
	    }
	    else  /* label: */
		n += 1;  /* oid->id */
	}
	else {  /* select expression: */
	    n += 4; /* selectfunc */

	    if( oid->obj_left )
		n += getObjectIdSpace( oid->obj_left );
	    if( oid->selector )
		n += 1;
	    if( oid->obj_right )
		n += getObjectIdSpace( oid->obj_right );
	}
    }
    return n;
}  /* getObjectIdSpace */


static size_t getClassListSpace( const te_ClassList *clist )
{
    const te_ClassList *lauf;
    size_t n = 0;

    lauf = clist;
    while( lauf )
    {
	n += 2;  /* list */
	if( lauf->Class ) {
	    n += 2;  /* class */
	    n += getObjectIdSpace( lauf->Class );
	}
	lauf = lauf->next;
    }  /* while */
    n += 1;  /* nil */
    return n;
}  /* getClassListSpace */


static size_t getAttrCategoryListSpace( const AttrClassList *aclist )
{
    const AttrClassList *lauf;
    size_t n = 0;

    lauf = aclist;
    while( lauf )
    {
	n += 2;  /* list */
	if( lauf->Class )
	    n += 1;  /* lauf->Class */
	lauf = lauf->next;
    }  /* while */
    n += 1;  /* nil */
    return n;
}  /* getAttrCategoryListSpace */

static size_t getSpecObjIdSpace(const SpecObjId *o)  {

	size_t n=0;

	if (o->oid) /* ein "normales" Objekt und sonst nichts */
		n=getObjectIdSpace(o->oid);
	else  {
		if (o->specobjright)  { /* :: wurde benutzt */
			n+=3; /* Functor */
			n+=1; /* Label */
			n+=getSpecObjIdSpace(o->specobjright);
		}
		else  { /* es ist nur ein Label */
			n+=1; /* Label */
		}
	}

	return n;
}
	

/* Forward */
static size_t getSelectExpBSpace(const SelectExpB *se);

static size_t getRestrictionSpace(const Restriction *rest) {

    size_t n=0;

    n+=3;  /* restriction functor */
    n+=1;  /* the label string */
	
    if (rest->Class)
		n+=getObjectIdSpace(rest->Class);
    if (rest->enumeration) {
		n+=getClassListSpace(rest->enumeration);
		n+=2; /* enumeration functor */
    }
    if (rest->selectExp) {
		n+=getSelectExpBSpace(rest->selectExp);
		n+=2; /* selectExpB functor */
    }
	
    return n;
}

static size_t getSelectExpBSpace(const SelectExpB *se) {

    size_t n=0;

    if (se->objectleft)
		n+=getSpecObjIdSpace(se->objectleft);
    if (se->restleft)
		n+=getRestrictionSpace(se->restleft);
	if (se->labelleft)
		n+=1;
    if (se->selectExp)
		n+=getSelectExpBSpace(se->selectExp);
    if (se->labelright)
		n+=1;
    if (se->restright)
		n+=getRestrictionSpace(se->restright);

    n+=4; /* functor */

    return n;
}
    
static size_t getObjectSetSpace(const ObjectSet *os) {

    size_t n=0;

    if (os->enumeration) {
	n+=getClassListSpace(os->enumeration);
	n+=2; /* enumeration-functor */
    }
    if (os->selectExp) {
	n+=getSelectExpBSpace(os->selectExp);
	n+=2; /* selectExpB functor */
    }
    if (os->complexRef)
	n+=getFragmentListSpace(os->complexRef);

    return n;
}


static size_t getPropertyListSpace( const PropertyList *plist )
{
    const PropertyList *lauf;
    size_t n = 0;
    
    lauf = plist;
    while( lauf ) {
	n += 2;  /* list */
	if( lauf->label && lauf->value ) {
	    n += 3;  /* property */
	    n += 1;  /* lauf->label */
	    if (lauf->value)
	    n += getObjectIdSpace( lauf->value );
	    if (lauf->objectSet)
	    n += getObjectSetSpace(lauf->objectSet);
	}
	lauf = lauf->next;
    }  /* while */
    n += 1;  /* nil */
    return n;
}  /* getPropertyListSpace */


static size_t getAttrDeclListSpace( const AttrDeclList *adlist )
{
    const AttrDeclList *lauf;
    size_t n = 0;

    lauf = adlist;
    while( lauf ) {
	n += 2;  /* list */
	n += 3;  /* attrdecl */
	n += getAttrCategoryListSpace( lauf->classList );
	n += getPropertyListSpace( lauf->attrList );
	lauf = lauf->next;
    }  /* while */
    n += 1;  /* nil */
    return n;
}  /* getAttrDeclListSpace */


size_t getFragmentSpace( const te_SMLfragmentList *c_fragment )
{
    return 6 +  /* SMLfragment/5 */
           2 + getObjectIdSpace( c_fragment->id ) +
           2 + getClassListSpace( c_fragment->inOmega ) +
           2 + getClassListSpace( c_fragment->in ) +
           2 + getClassListSpace( c_fragment->isa ) +
           2 + getAttrDeclListSpace( c_fragment->with );
}  /* getFragmentSpace */


size_t getFragmentListSpace( const te_SMLfragmentList *c_fragmentlist )
{
    size_t n = 0;
    const te_SMLfragmentList *p = c_fragmentlist;
    
    while( p ) {
	n += 2;  /* list */
	n += getFragmentSpace( p );
	p = p->next;
    }
    n += 1;  /* nil */
    return n;
}  /* getFragmentListSpace */
