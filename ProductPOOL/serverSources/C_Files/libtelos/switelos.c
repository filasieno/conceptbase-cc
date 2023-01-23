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

#include "SWI-Prolog.h"

#include "prolog.h"

#include "te_callparser.h"
#include "te_smlutil.h"

foreign_t swi_te_frame_parser(term_t fpoterm, term_t interm) {

    char* indata;
    FrameParseOutput* fpo;

    if(!PL_is_integer(interm))
        PL_fail;

    PL_get_pointer(interm,(void**)&indata);

    fpo=te_frame_parser(indata);

    if(PL_unify_pointer(fpoterm,fpo))
        PL_succeed;
    PL_fail;
}

/* Forward declaration */
char* get_mod_context();
foreign_t swi_get_mod_context(term_t modterm) {

    char* mod;
    mod=get_mod_context();

    if(mod && PL_unify_atom_chars(modterm,mod))
        PL_succeed;
    PL_fail;
}

foreign_t swi_DestroySMLfrag(term_t fragterm) {

    te_SMLfragmentList* frag;

    if(!PL_is_integer(fragterm))
        PL_fail;

    PL_get_pointer(fragterm,(void**)&frag);
    DestroySMLfrag(frag);
    PL_succeed;
}


foreign_t swi_te_classlist_parser(term_t cpoterm, term_t interm) {

    ClassListParseOutput* cpo;
    char* indata;

    if(!PL_is_integer(interm))
        PL_fail;

    PL_get_pointer(interm,(void**)&indata);

    cpo=te_classlist_parser(indata);

    if(PL_unify_pointer(cpoterm,cpo))
        PL_succeed;
    PL_fail;
}

foreign_t swi_Destroy_ClassList(term_t clterm) {

    te_ClassList* cl;

    if(!PL_is_integer(clterm))
        PL_fail;

    PL_get_pointer(clterm,(void**)&cl);
    Destroy_ClassList(cl);
    PL_succeed;
}

void install_libtelos() {

    REGISTER_FOREIGN("ExternalCodeLoader","te_frame_parser",2,swi_te_frame_parser,0);
    REGISTER_FOREIGN("ExternalCodeLoader","get_mod_context",1,swi_get_mod_context,0);
    REGISTER_FOREIGN("ExternalCodeLoader","DestroySMLfrag",1,swi_DestroySMLfrag,0);
    REGISTER_FOREIGN("ExternalCodeLoader","te_classlist_parser",2,swi_te_classlist_parser,0);
    REGISTER_FOREIGN("ExternalCodeLoader","Destroy_ClassList",1,swi_Destroy_ClassList,0);

}
