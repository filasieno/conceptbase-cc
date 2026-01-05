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
#include <stdlib.h>

#include "SWI-Prolog.h"

typedef struct externalPredicate
{ char          *module_name;           /* Name of the module */
  char          *predicate_name;        /* Name of the predicate */
  short         arity;                  /* Arity of the predicate */
  pl_function_t function;               /* Implementing functions */
  short         flags;                  /* Or of PL_FA_... */
} ExternalPredicate;

ExternalPredicate *externalPredicates;

#define MAX_PREDICATES 1000


void addExternalPredicate(char* module, char* name,short arity,pl_function_t fct,short flags) {

    int i=0;

    while(externalPredicates[i].predicate_name && i<MAX_PREDICATES)
        i++;

    if(i>=(MAX_PREDICATES-1)) {
        printf("Too many external predicates, increase MAX_PREDICATES in swiMain.c");
        exit(1);
    }
    externalPredicates[i].module_name=module;
    externalPredicates[i].predicate_name=name;
    externalPredicates[i].arity=arity;
    externalPredicates[i].function=fct;
    externalPredicates[i].flags=flags;

    externalPredicates[i+1].module_name=NULL;
    externalPredicates[i+1].predicate_name=NULL;
    externalPredicates[i+1].arity=0;
    externalPredicates[i+1].function=NULL;
    externalPredicates[i+1].flags=0;
}

void registerAllExternalPredicates() {

    int i=0;
    while(externalPredicates[i].predicate_name) {
    	PL_register_foreign_in_module(externalPredicates[i].module_name,
    		externalPredicates[i].predicate_name,
    		externalPredicates[i].arity,
    		externalPredicates[i].function,
    		externalPredicates[i].flags);
    	i++;
    }

}

int main(int argc, char** argv) {

    predicate_t mainPred;
    int ret;
    term_t term;

    externalPredicates=(ExternalPredicate*) malloc(sizeof(ExternalPredicate)*MAX_PREDICATES);
    externalPredicates->module_name=NULL;
    externalPredicates->predicate_name=NULL;
    externalPredicates->arity=0;
    externalPredicates->function=NULL;
    externalPredicates->flags=0;

    install_libCos();
    install_libIpc();
    install_libGeneral();
    install_libtelos();
    install_libtelosServer();

    registerAllExternalPredicates();

    /* Run SWI-Prolog in traditional mode so that double quoted strings are lists of character codes */
    /* Pro posed by krietzsche to address issue #27                                                  */
#ifdef PL_ACTION_TRADITIONAL
    PL_action(PL_ACTION_TRADITIONAL);
#endif

    if(!PL_initialise(argc,argv))
        PL_halt(1);

    mainPred=PL_predicate("startCBserver",0,"startCBserver");
    term=PL_new_term_refs(1);
    ret=PL_call_predicate(NULL,PL_Q_NORMAL,mainPred,term);

    PL_halt(ret ? 0:1);

    return 0;
}
