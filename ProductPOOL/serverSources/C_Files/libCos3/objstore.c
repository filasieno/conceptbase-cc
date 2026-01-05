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
#include "trans_c.h"
#include "bim2c.h"
#include "prolog.h"


/* ******************************************************** */
/*                  retrieve_C_proposition                  */
/* ******************************************************** */

void c_retrieve_prop_query(char* tuple[4], PROLOG_TERM resTerm) {
    int nr,i;
    char** result;
    PROLOG_TERM term;
    PROLOG_TERM arg[4];
    PROLOG_FUNC mFunc;

    nr=c_getquery(tuple);
    mFunc=GET_PRED( STR2ATOM(FALSE,"P"), 4 );
    while(nr!=(-1) && c_find(nr,&result)!=0) {
        INIT_LIST(resTerm);
        INIT_TERM(term);
        GET_ARG(resTerm, 1, term );
        UNIFY_FUNC(term,mFunc);
        for(i=0;i<4;i++) {
            INIT_TERM(arg[i]);
            GET_ARG(term,i+1,arg[i]);
            UNIFY_ATOM(arg[i], STR2ATOM(FALSE,result[i]) );
        }
		GET_ARG( resTerm, 2, term );
		resTerm = term;
    }
    UNIFY_ATOM( resTerm, STR2ATOM(TRUE,"[]") );
    if(nr!=(-1))
        freequery(nr);
}


/* ******************************************************** */
/*               retrieve_C_proposition_module              */
/* ******************************************************** */

void c_retrieve_prop_module_query(char* tuple[5], PROLOG_TERM resTerm) {
    int nr,i;
    char** result;
    PROLOG_TERM term;
    PROLOG_TERM arg[5];
    PROLOG_FUNC mFunc;

    nr=c_getqueryM(tuple);
    mFunc=GET_PRED( STR2ATOM(FALSE,"P"), 5 );
    while(nr!=(-1) && c_findM(nr,&result)!=0) {
        INIT_LIST(resTerm);
        INIT_TERM(term);
        GET_ARG(resTerm, 1, term);
        UNIFY_FUNC(term,mFunc);
        for(i=0;i<5;i++) {
            INIT_TERM(arg[i]);
            GET_ARG(term,i+1,arg[i]);
            UNIFY_ATOM(arg[i], STR2ATOM(FALSE,result[i]) );
        }
		GET_ARG( resTerm, 2, term );
		resTerm = term;
    }
    UNIFY_ATOM( resTerm, STR2ATOM(TRUE,"[]") );
    if(nr!=(-1))
        freequery(nr);
}


/* ******************************************************** */
/*                        Attr_s                            */
/* ******************************************************** */

void c_Attr_s_query(char* tuple[2], PROLOG_TERM resTerm) {
    int nr,i;
    char** result;
    PROLOG_TERM term;
    PROLOG_TERM arg[2];
    PROLOG_FUNC mFunc;

    nr=c_Attr_s_getquery(tuple);
    mFunc=GET_PRED( STR2ATOM(FALSE,"M"), 2 );
    while(nr!=(-1) && c_Attr_s_find(nr,&result)!=0) {
        INIT_LIST(resTerm);
        INIT_TERM(term);
        GET_ARG(resTerm, 1, term);
        UNIFY_FUNC(term,mFunc);
        for(i=0;i<2;i++) {
            INIT_TERM(arg[i]);
            GET_ARG(term,i+1,arg[i]);
            UNIFY_ATOM(arg[i], STR2ATOM(FALSE,result[i]) );
        }
                GET_ARG( resTerm, 2, term );
                resTerm = term;
    }
    UNIFY_ATOM( resTerm, STR2ATOM(TRUE,"[]") );
    if(nr!=(-1))
        Literal_freequery(nr,7);
}


/* ******************************************************** */
/*                        In_s                              */
/* ******************************************************** */

void c_In_s_query(char* tuple[2], PROLOG_TERM resTerm) {
    int nr,i;
    char** result;
    PROLOG_TERM term;
    PROLOG_TERM arg[2];
    PROLOG_FUNC mFunc;

    nr=c_In_s_getquery(tuple);
    mFunc=GET_PRED( STR2ATOM(FALSE,"M"), 2 );
    while(nr!=(-1) && c_In_s_find(nr,&result)!=0) {
        INIT_LIST(resTerm);
        INIT_TERM(term);
        GET_ARG(resTerm, 1, term);
        UNIFY_FUNC(term,mFunc);
        for(i=0;i<2;i++) {
            INIT_TERM(arg[i]);
            GET_ARG(term,i+1,arg[i]);
            UNIFY_ATOM(arg[i], STR2ATOM(FALSE,result[i]) );
        }
		GET_ARG( resTerm, 2, term );
		resTerm = term;
    }
    UNIFY_ATOM( resTerm, STR2ATOM(TRUE,"[]") );
    if(nr!=(-1))
        Literal_freequery(nr,0);
}


/* ******************************************************** */
/*                        In_i                              */
/* ******************************************************** */

void c_In_i_query(char* tuple[2], PROLOG_TERM resTerm) {
    int nr,i;
    char** result;
    PROLOG_TERM term;
    PROLOG_TERM arg[2];
    PROLOG_FUNC mFunc;

    nr=c_In_i_getquery(tuple);
    mFunc=GET_PRED( STR2ATOM(FALSE,"M"), 2 );
    while(nr!=(-1) && c_In_i_find(nr,&result)!=0) {
        INIT_LIST(resTerm);
        INIT_TERM(term);
        GET_ARG(resTerm, 1, term);
        UNIFY_FUNC(term,mFunc);
        for(i=0;i<2;i++) {
            INIT_TERM(arg[i]);
            GET_ARG(term,i+1,arg[i]);
            UNIFY_ATOM(arg[i], STR2ATOM(FALSE,result[i]) );
        }
		GET_ARG( resTerm, 2, term );
		resTerm = term;
    }
    UNIFY_ATOM( resTerm, STR2ATOM(TRUE,"[]") );
    if(nr!=(-1))
        Literal_freequery(nr,1);
}


/* ******************************************************** */
/*                        Isa                               */
/* ******************************************************** */

void c_Isa_query(char* tuple[2], PROLOG_TERM resTerm) {
    int nr,i;
    char** result;
    PROLOG_TERM term;
    PROLOG_TERM arg[2];
    PROLOG_FUNC mFunc;

    nr=c_Isa_getquery(tuple);
    mFunc=GET_PRED( STR2ATOM(FALSE,"M"), 2 );
    while(nr!=(-1) && c_Isa_find(nr,&result)!=0) {
        INIT_LIST(resTerm);
        INIT_TERM(term);
        GET_ARG(resTerm, 1, term);
        UNIFY_FUNC(term,mFunc);
        for(i=0;i<2;i++) {
            INIT_TERM(arg[i]);
            GET_ARG(term,i+1,arg[i]);
            UNIFY_ATOM(arg[i], STR2ATOM(FALSE,result[i]) );
        }
		GET_ARG( resTerm, 2, term );
		resTerm = term;
    }
    UNIFY_ATOM( resTerm, STR2ATOM(TRUE,"[]") );
    if(nr!=(-1))
        Literal_freequery(nr,6);
}

/* ******************************************************** */
/*                        sys_class                         */
/* ******************************************************** */

void c_sys_class_query(char* tuple[2], PROLOG_TERM resTerm) {
    int nr,i;
    char** result;
    PROLOG_TERM term;
    PROLOG_TERM arg[2];
    PROLOG_FUNC mFunc;

    nr=c_sys_class_getquery(tuple);
    mFunc=GET_PRED( STR2ATOM(FALSE,"M"), 2 );
    while(nr!=(-1) && c_sys_class_find(nr,&result)!=0) {
        INIT_LIST(resTerm);
        INIT_TERM(term);
        GET_ARG(resTerm, 1, term);
        UNIFY_FUNC(term,mFunc);
        for(i=0;i<2;i++) {
            INIT_TERM(arg[i]);
            GET_ARG(term,i+1,arg[i]);
            UNIFY_ATOM(arg[i], STR2ATOM(FALSE,result[i]) );
        }
		GET_ARG( resTerm, 2, term );
		resTerm = term;
    }
    UNIFY_ATOM( resTerm, STR2ATOM(TRUE,"[]") );
    if(nr!=(-1))
        Literal_freequery(nr,4);
}



/* ******************************************************** */
/*                        Adot                              */
/* ******************************************************** */

void c_Adot_query(char* tuple[4], PROLOG_TERM resTerm) {
    int nr,i;
    char** result;
    PROLOG_TERM term;
    PROLOG_TERM arg[4];
    PROLOG_FUNC mFunc;

    nr=c_Adot_getquery(tuple);
    mFunc=GET_PRED( STR2ATOM(FALSE,"M"), 4 );
    while(nr!=(-1) && c_Adot_find(nr,&result)!=0) {
        INIT_LIST(resTerm);
        INIT_TERM(term);
        GET_ARG(resTerm, 1, term);
        UNIFY_FUNC(term,mFunc);
        for(i=0;i<4;i++) {
            INIT_TERM(arg[i]);
            GET_ARG(term,i+1,arg[i]);
            UNIFY_ATOM(arg[i], STR2ATOM(FALSE,result[i]) );
        }
		GET_ARG( resTerm, 2, term );
		resTerm = term;
    }
    UNIFY_ATOM( resTerm, STR2ATOM(TRUE,"[]") );
    if(nr!=(-1))
        Literal_freequery(nr,2);
}


void c_Aidot_query(char* tuple[4], PROLOG_TERM resTerm) {
    int nr,i;
    char** result;
    PROLOG_TERM term;
    PROLOG_TERM arg[4];
    PROLOG_FUNC mFunc;

    nr=c_Aidot_getquery(tuple);
    mFunc=GET_PRED( STR2ATOM(FALSE,"M"), 4 );
    while(nr!=(-1) && c_Aidot_find(nr,&result)!=0) {
        INIT_LIST(resTerm);
        INIT_TERM(term);
        GET_ARG(resTerm, 1, term);
        UNIFY_FUNC(term,mFunc);
        for(i=0;i<4;i++) {
            INIT_TERM(arg[i]);
            GET_ARG(term,i+1,arg[i]);
            UNIFY_ATOM(arg[i], STR2ATOM(FALSE,result[i]) );
        }
                GET_ARG( resTerm, 2, term );
                resTerm = term;
    }
    UNIFY_ATOM( resTerm, STR2ATOM(TRUE,"[]") );
    if(nr!=(-1))
        Literal_freequery(nr,8);    // Aidot is literal number 8 in list Literals of Literals.h
}




/* ******************************************************** */
/*                        A                                 */
/* ******************************************************** */

void c_A_query(char* tuple[3], PROLOG_TERM resTerm) {
    int nr,i;
    char** result;
    PROLOG_TERM term;
    PROLOG_TERM arg[3];
    PROLOG_FUNC mFunc;

    nr=c_A_getquery(tuple);
    mFunc=GET_PRED( STR2ATOM(FALSE,"M"), 3 );
    while(nr!=(-1) && c_A_find(nr,&result)!=0) {
        INIT_LIST(resTerm);
        INIT_TERM(term);
        GET_ARG(resTerm, 1, term);
        UNIFY_FUNC(term,mFunc);
        for(i=0;i<3;i++) {
            INIT_TERM(arg[i]);
            GET_ARG(term,i+1,arg[i]);
            UNIFY_ATOM(arg[i], STR2ATOM(FALSE,result[i]) );
        }
		GET_ARG( resTerm, 2, term );
		resTerm = term;
    }
    UNIFY_ATOM( resTerm, STR2ATOM(TRUE,"[]") );
    if(nr!=(-1))
        Literal_freequery(nr,5);
}



/* ******************************************************** */
/*                        star_name2id                      */
/* ******************************************************** */

void c_star_query(char* label, PROLOG_TERM resTerm) {
    int nr;
    char* result;
    PROLOG_TERM term;

    nr=c_star_getquery(label);
    while(nr!=(-1) && c_star_find(nr,&result)!=0) {
        INIT_LIST(resTerm);
        INIT_TERM(term);
        GET_ARG(resTerm, 1, term);
        UNIFY_ATOM(term,STR2ATOM(FALSE,result));
		GET_ARG( resTerm, 2, term );
		resTerm = term;
    }
    UNIFY_ATOM( resTerm, STR2ATOM(TRUE,"[]") );
    if(nr!=(-1))
        Literal_freequery(nr,3);
}
