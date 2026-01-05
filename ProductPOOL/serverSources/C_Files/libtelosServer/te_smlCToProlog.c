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
/* The following functions convert the C fragment structure into the corresponding Prolog term.
*/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "te_smlGetFragmentSpace.h"
#include "te_smlCToProlog.h"


/* some shortcuts: */
/* #define UNIFY  BIM_Prolog_unify_term_value
#define STR2ATOM BIM_Prolog_string_to_atom
#define GET_ARG  BIM_Prolog_get_term_arg
#define GET_PRED BIM_Prolog_get_predicate
#define PROTECT(a) (a) = BIM_Prolog_protect_term( a )
#define UNPROTECT(a) (a) = BIM_Prolog_unprotect_term( a )
#define SPACE(n) BIM_Prolog_term_space( n )
*/

/* Prolog functors: */
static PROLOG_FUNC substfunc, specialfunc;
static PROLOG_FUNC derivefunc, selectfunc;
static PROLOG_FUNC classfunc;
static PROLOG_FUNC propertyfunc;
static PROLOG_FUNC attrdeclfunc;
static PROLOG_FUNC smlfunc;
static PROLOG_FUNC classfunc;
static PROLOG_FUNC whatfunc, in_omegafunc, infunc, isafunc, withfunc;
static PROLOG_FUNC selectExpBfunc,enumfunc,restfunc, scopefunc;

/* prototypes: */
static void ObjectIdCToProlog( const ObjectIdentifier *oid, PROLOG_TERM term );


int get_term_space( int size )
/* Notloesung: BIM_Prolog_term_space kann aus unerfindlichen Gruenden nicht direkt von Prolog aufgerufen werden.
*/
{
#ifdef BIM
    return BIM_Prolog_term_space( size );
#else

    return 1;
#endif
}


static void init_functors() {
    substfunc    = GET_PRED( STR2ATOM(TRUE,"substitute"), 2 );
    specialfunc  = GET_PRED( STR2ATOM(TRUE,"specialize"), 2 );
    derivefunc   = GET_PRED( STR2ATOM(TRUE,"derive"), 2 );
    selectfunc   = GET_PRED( STR2ATOM(TRUE,"select"), 3 );
    classfunc    = GET_PRED( STR2ATOM(TRUE,"class"), 1 );
    propertyfunc = GET_PRED( STR2ATOM(TRUE,"property"), 2 );
    attrdeclfunc = GET_PRED( STR2ATOM(TRUE,"attrdecl"), 2 );
    smlfunc      = GET_PRED( STR2ATOM(TRUE,"SMLfragment"), 5 );
    classfunc    = GET_PRED( STR2ATOM(TRUE,"class"), 1 );
    whatfunc     = GET_PRED( STR2ATOM(TRUE,"what"), 1 );
    in_omegafunc = GET_PRED( STR2ATOM(TRUE,"in_omega"), 1 );
    infunc       = GET_PRED( STR2ATOM(TRUE,"in"), 1 );
    isafunc      = GET_PRED( STR2ATOM(TRUE,"isa"), 1 );
    withfunc     = GET_PRED( STR2ATOM(TRUE,"with"), 1 );
    selectExpBfunc= GET_PRED( STR2ATOM(TRUE,"selectExpB"),3);
    enumfunc     = GET_PRED( STR2ATOM(TRUE,"enumeration"),1);
    restfunc     = GET_PRED( STR2ATOM(TRUE,"restriction"),2);
    scopefunc    = GET_PRED( STR2ATOM(TRUE,"scope_res"),2);
}  /* init_functors */


/*
static void statistics( const char *s )
{
    BP_Functor statfunc = GET_PRED( STR2ATOM(FALSE,"statistics"), 0 );

    printf( "%s:\n", s );
    BIM_Prolog_call_predicate( statfunc );
    putchar('\n');
}
*/


static void BindingListCToProlog( const BindingList *blist, PROLOG_TERM term ) {
    const BindingList *lauf;
    PROLOG_TERM arg, arg1,arg2,term1,term2;

    INIT_TERM(term2);
    term1=term2;
    lauf = blist;
    while( lauf ) {
        INIT_LIST( term2);  /* 2 */
        if( lauf->lab1 && lauf->lab2 ) {
            INIT_TERM(arg);
            GET_ARG( term2, 1, arg );
            if( !strcmp( lauf->op, "/" ) ) {
                UNIFY_FUNC( arg, substfunc );  /* 3 */
            }
            else  /* lauf->op == ":" */
            {
                UNIFY_FUNC( arg, specialfunc );  /* 3 */
            }
            INIT_TERM(arg1);
            GET_ARG( arg, 1, arg1 );
            ObjectIdCToProlog( lauf->lab1, arg1 );  /* n */

            INIT_TERM(arg2);
            GET_ARG( arg, 2, arg2 );
            ObjectIdCToProlog( lauf->lab2, arg2 );  /* n */
        }
        else
            printf("Error in BindingListCToProlog!\n");  /* error! */
        INIT_TERM(arg);
        GET_ARG( term2, 2, arg );
        term2=arg;
        lauf = lauf->next;
    }  /* while */
    UNIFY_ATOM( term2, STR2ATOM(TRUE,"[]") );  /* 0 */
    UNIFY_TERMS(term,term1);
}  /* BindingListCToProlog */


static void ObjectIdCToProlog( const ObjectIdentifier *oid, PROLOG_TERM term ) {
    PROLOG_TERM arg,term2;

    INIT_TERM(term2);
    if( !oid )
        UNIFY_ATOM( term2, STR2ATOM(TRUE,"[]") );  /* error? */
    else {
        if (oid->id) {
            if (oid->bind) {  /* derive expression: */
                UNIFY_FUNC( term2, derivefunc );  /* 3 */

                INIT_TERM(arg);
                GET_ARG( term2, 1, arg );
                UNIFY_ATOM( arg, STR2ATOM(FALSE,oid->id) );  /* 0 */

                INIT_TERM(arg);
                GET_ARG( term2, 2, arg );
                BindingListCToProlog( oid->bind, arg );  /* n */
            }
            else  /* label: */
                UNIFY_ATOM( term2, STR2ATOM(FALSE,oid->id) );  /* 0 */
        }
        else {  /* select expression: */
            UNIFY_FUNC( term2, selectfunc );  /* 4 */

            INIT_TERM(arg);
            GET_ARG( term2, 1, arg );
            if( !oid->obj_left )
                printf("Error #1 in ObjectIdCToProlog!\n");  /* error! */
            else
                ObjectIdCToProlog( oid->obj_left, arg );  /* n */

            INIT_TERM(arg);
            GET_ARG( term2, 2, arg );
            if( !oid->selector )
                printf("Error #2 in ObjectIdCToProlog!\n");  /* error! */
            else
                UNIFY_ATOM( arg, STR2ATOM(FALSE,oid->selector) );  /* 0 */

            INIT_TERM(arg);
            GET_ARG( term2, 3, arg );
            if( !oid->obj_right )
                printf("Error #3 in ObjectIdCToProlog!\n");  /* error! */
            else
                ObjectIdCToProlog( oid->obj_right, arg );  /* n */
        }
    }
    UNIFY_TERMS(term,term2);
}  /* ObjectIdCToProlog */


void ClassListCToProlog( const te_ClassList *clist, PROLOG_TERM term ) {
    const te_ClassList *lauf;
    PROLOG_TERM arg,term1,term2;

    INIT_TERM(term2);
    term1=term2;
    init_functors();

    lauf = clist;
    while( lauf ) {
        INIT_LIST( term2);  /* 2 */
        if( !lauf->Class )
            printf("Error in ClassListCToProlog!\n");  /* error! */
        else {
            INIT_TERM(arg);
            GET_ARG( term2, 1, arg );
            UNIFY_FUNC( arg,classfunc );  /* 2 */
            GET_ARG( arg, 1, arg );
            ObjectIdCToProlog( lauf->Class, arg );  /* n */
        }
        INIT_TERM(arg);
        GET_ARG( term2, 2, arg );
        term2=arg;
        lauf = lauf->next;
    }  /* while */
    UNIFY_ATOM( term2, STR2ATOM(TRUE,"[]") );  /* 0 */
    UNIFY_TERMS(term,term1);
}  /* ClassListCToProlog */


static void AttrCategoryListCToProlog( const AttrClassList *aclist, PROLOG_TERM term ) {
    const AttrClassList *lauf;
    PROLOG_TERM arg,term1,term2;

    INIT_TERM(term2);
    term1=term2;
    lauf = aclist;
    while( lauf ) {
        INIT_LIST( term2);  /* 2 */
        if( !lauf->Class )
            printf("Error in AttrCategoryListCToProlog!\n");  /* error! */
        else {
            INIT_TERM(arg);
            GET_ARG( term2, 1, arg );
            UNIFY_ATOM( arg,STR2ATOM(FALSE, lauf->Class) );  /* 0 */
        }
        INIT_TERM(arg);
        GET_ARG( term2, 2, arg);
        term2=arg;
        lauf = lauf->next;
    }  /* while */
    UNIFY_ATOM( term2, STR2ATOM(TRUE,"[]") );  /* 0 */
    UNIFY_TERMS(term,term1);
}  /* AttrCategoryListCToProlog */


static void SpecObjIdCToProlog(const SpecObjId *o, PROLOG_TERM term)  {

    PROLOG_TERM arg1,arg2,term2;

    INIT_TERM(term2);
    if (o->oid) /* ein "normales" Objekt und sonst nichts */
        ObjectIdCToProlog(o->oid, term2);
    else  {
        if (o->specobjright)  { /* :: wurde benutzt */
            UNIFY_FUNC(term2,scopefunc);
            INIT_TERM(arg1);
            GET_ARG(term2,1,arg1);
            UNIFY_ATOM(arg1,STR2ATOM(FALSE,o->label));
            INIT_TERM(arg2);
            GET_ARG(term2,2,arg2);
            SpecObjIdCToProlog(o->specobjright,arg2);
        }
        else  { /* es ist nur ein Label */
            UNIFY_ATOM(term2,STR2ATOM(FALSE,o->label));
        }
    }
    UNIFY_TERMS(term,term2);
}

/* Forward */
static void SelectExpCToProlog(const SelectExpB *selectExp, PROLOG_TERM term);

static void RestrictionCToProlog(const Restriction *rest, PROLOG_TERM term) {

    PROLOG_TERM arg1,arg2,arg3,term2;

    INIT_TERM(term2);
    UNIFY_FUNC(term2,restfunc);
    INIT_TERM(arg1);
    GET_ARG(term2,1,arg1);
    UNIFY_ATOM(arg1,STR2ATOM(FALSE,rest->label));

    INIT_TERM(arg2);
    GET_ARG(term2,2,arg2);

    if (rest->Class)
        ObjectIdCToProlog(rest->Class,arg2);

    if (rest->enumeration) {
        UNIFY_FUNC(arg2,enumfunc);
        INIT_TERM(arg3);
        GET_ARG(arg2,1,arg3);
        ClassListCToProlog(rest->enumeration,arg3);
    }

    if (rest->selectExp) {
        SelectExpCToProlog(rest->selectExp,arg2);
    }
    UNIFY_TERMS(term,term2);
}


static void SelectExpCToProlog(const SelectExpB *selectExp, PROLOG_TERM term) {

    PROLOG_TERM arg1,arg2,arg3,term2;

    INIT_TERM(term2);
    UNIFY_FUNC(term2,selectExpBfunc);
    INIT_TERM(arg2);
    GET_ARG(term2,2,arg2);

    switch (selectExp->Operator) {
        case '.':
            UNIFY_ATOM(arg2, STR2ATOM(FALSE,"dot"));
            break;
        case '|':
            UNIFY_ATOM(arg2, STR2ATOM(FALSE,"bar"));
            break;
        default:
            printf(" Error in SelectExpCToProlog()!\n");
            exit(1);
    }
    INIT_TERM(arg1);
    GET_ARG( term2, 1,arg1);
    if (selectExp->objectleft)
        SpecObjIdCToProlog(selectExp->objectleft,arg1);
    if (selectExp->restleft)
        RestrictionCToProlog(selectExp->restleft,arg1);
    if (selectExp->labelleft)
        UNIFY_ATOM(arg1,STR2ATOM(FALSE,selectExp->labelleft));

    INIT_TERM(arg3);
    GET_ARG( term2,3,arg3);
    if (selectExp->selectExp)
        SelectExpCToProlog(selectExp->selectExp,arg3);
    if (selectExp->labelright)
        UNIFY_ATOM(arg3,STR2ATOM(FALSE,selectExp->labelright));
    if (selectExp->restright)
        RestrictionCToProlog(selectExp->restright,arg3);
    UNIFY_TERMS(term,term2);
}


static void ObjectSetCToProlog(const ObjectSet *oset, PROLOG_TERM term) {

    PROLOG_TERM arg,term2;
    INIT_TERM(term2);

    if (oset->enumeration) { /* Enumeration */
        UNIFY_FUNC(term2,enumfunc);
        INIT_TERM(arg);
        GET_ARG(term2,1,arg);
        ClassListCToProlog(oset->enumeration,arg);
    }

    if (oset->selectExp) /* SelectExpression B */
        SelectExpCToProlog(oset->selectExp,term2);

    if (oset->complexRef) /* complexRef */
        FragmentListCToProlog(oset->complexRef,term2);
    UNIFY_TERMS(term,term2);
}


static void PropertyListCToProlog( const PropertyList *plist, PROLOG_TERM term ) {
    const PropertyList *lauf;
    PROLOG_TERM arg, arg1,term1,term2;

    INIT_TERM(term2);
    term1=term2;
    lauf = plist;
    while( lauf ) {
        INIT_LIST( term2);  /* 2 */
        if( lauf->label ) {
            INIT_TERM(arg);
            GET_ARG( term2, 1, arg );
            UNIFY_FUNC( arg, propertyfunc );  /* 3 */

            INIT_TERM(arg1);
            GET_ARG( arg, 1, arg1 );
            UNIFY_ATOM( arg1, STR2ATOM(FALSE, lauf->label) );  /* 0 */

            INIT_TERM(arg1);
            GET_ARG( arg, 2, arg1 );

            if (lauf->value) /* normal objectid */
                ObjectIdCToProlog( lauf->value, arg1 );  /* n */
            if (lauf->objectSet) /* set of objects */
                ObjectSetCToProlog(lauf->objectSet, arg1);
        }
        else
            printf("Error in PropertyListCToProlog!\n");  /* error! */
        INIT_TERM(arg);
        GET_ARG( term2, 2, arg );
        term2=arg;
        lauf = lauf->next;
    }  /* while */
    UNIFY_ATOM( term2,STR2ATOM(TRUE,"[]") );  /* 0 */
    UNIFY_TERMS(term,term1);
}  /* PropertyListCToProlog */


static void AttrDeclListCToProlog( const AttrDeclList *adlist, PROLOG_TERM term ) {
    const AttrDeclList *lauf;
    PROLOG_TERM arg, arg1,term1,term2;
    INIT_TERM(term2);
    term1=term2;
    lauf = adlist;
    while( lauf ) {
        INIT_LIST( term2);  /* 2 */
        INIT_TERM(arg);
        GET_ARG( term2, 1, arg );
        UNIFY_FUNC( arg, attrdeclfunc );  /* 3 */

        INIT_TERM(arg1);
        GET_ARG( arg, 1,arg1 );
        AttrCategoryListCToProlog( lauf->classList, arg1 );  /* n */
        INIT_TERM(arg1);
        GET_ARG( arg, 2,arg1 );
        PropertyListCToProlog( lauf->attrList, arg1 );  /* n */
        INIT_TERM(arg);
        GET_ARG( term2, 2, arg);
        term2=arg;
        lauf = lauf->next;
    }  /* while */
    UNIFY_ATOM( term2, STR2ATOM(TRUE,"[]") );  /* 0 */
    UNIFY_TERMS(term,term1);
}  /* AttrDeclListCToProlog */


void FragmentCToProlog( const te_SMLfragmentList *c_fragment, PROLOG_TERM fragment )
/* converts C structure of SMLfragment into Prolog term SMLfragment(_,_,_,_,_).
*/
{
    PROLOG_TERM arg, arg1,term2;

    init_functors();
    INIT_TERM(term2);
    UNIFY_FUNC( term2, smlfunc );  /* 6 */

    INIT_TERM(arg);
    /* what: */
    GET_ARG( term2, 1, arg );
    UNIFY_FUNC( arg,whatfunc );  /* 2 */
    INIT_TERM(arg1);
    GET_ARG( arg, 1, arg1 );
    ObjectIdCToProlog( c_fragment->id, arg1 );  /* n */

    /* in_omega: */
    INIT_TERM(arg);
    GET_ARG( term2, 2, arg );
    UNIFY_FUNC( arg,in_omegafunc );  /* 2 */
    INIT_TERM(arg1);
    GET_ARG( arg, 1,arg1 );
    ClassListCToProlog( c_fragment->inOmega, arg1 );  /* n */

    /* in: */
    INIT_TERM(arg);
    GET_ARG( term2, 3, arg );
    UNIFY_FUNC( arg, infunc );  /* 2 */
    INIT_TERM(arg1);
    GET_ARG( arg, 1, arg1 );
    ClassListCToProlog( c_fragment->in, arg1 );  /* n */

    /* isa: */
    INIT_TERM(arg);
    GET_ARG( term2, 4, arg );
    UNIFY_FUNC( arg,isafunc );  /* 2 */
    INIT_TERM(arg1);
    GET_ARG( arg, 1, arg1 );
    ClassListCToProlog( c_fragment->isa, arg1 );  /* n */

    /* with: */
    INIT_TERM(arg);
    GET_ARG( term2, 5, arg );
    UNIFY_FUNC( arg, withfunc );  /* 2 */
    INIT_TERM(arg1);
    GET_ARG( arg, 1, arg1 );
    AttrDeclListCToProlog( c_fragment->with, arg1 );  /* n */

    UNIFY_TERMS(fragment,term2);
}  /* FragmentCToProlog */


void FragmentListCToProlog( const te_SMLfragmentList *c_fragmentlist, PROLOG_TERM fragmentlist )
/* converts C structure of SMLfragmentList into Prolog list of fragments: [SMLfragment(_,_,_,_,_), SMLfragment(_,_,_,_,_), ... ].
*/
{
    PROLOG_TERM arg,term1,term2;

    INIT_TERM(term2);
    term1=term2;
    while( c_fragmentlist ) {
        INIT_LIST( term2);
        INIT_TERM(arg);
        GET_ARG( term2, 1, arg );
        FragmentCToProlog( c_fragmentlist, arg );
        INIT_TERM(arg);
        GET_ARG( term2, 2, arg );
        term2 = arg;
        c_fragmentlist = c_fragmentlist->next;
    }
    UNIFY_ATOM( term2,STR2ATOM(TRUE,"[]") );
    UNIFY_TERMS(fragmentlist,term1);
}  /* FragmentListCToProlog */
