/*
The ConceptBase.cc Copyright

Copyright 1987-2020 The ConceptBase Team. All rights reserved.

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

#include "SWI-Prolog.h"

#include "prolog.h"

#include "te_PrologUtilities.h"
#include "te_smlCToProlog.h"
#include "te_smlGetFragmentSpace.h"
#include "CharListToCString.h"


foreign_t swi_getFrameParseErrNo(term_t retterm, term_t pterm) {

    FrameParseOutput* fpo;
    int ret;

    if(!PL_is_integer(pterm))
        PL_fail;

    PL_get_pointer(pterm,(void**)&fpo);

    ret=getFrameParseErrNo(fpo);

    if(PL_unify_integer(retterm,ret))
        PL_succeed;
    PL_fail;

}

foreign_t swi_getFrameParseErrLine(term_t retterm, term_t pterm) {

    FrameParseOutput* fpo;
    int ret;

    if(!PL_is_integer(pterm))
        PL_fail;

    PL_get_pointer(pterm,(void**)&fpo);

    ret=getFrameParseErrLine(fpo);

    if(PL_unify_integer(retterm,ret))
        PL_succeed;
    PL_fail;

}

foreign_t swi_getFrameParseErrToken(term_t retterm, term_t pterm) {

    FrameParseOutput* fpo;
    char* ret;

    if(!PL_is_integer(pterm))
        PL_fail;

    PL_get_pointer(pterm,(void**)&fpo);

    ret=getFrameParseErrToken(fpo);

    if(ret && PL_unify_atom_chars(retterm,ret))
        PL_succeed;
    if(!ret && PL_unify_atom_chars(retterm,"'no error token available'"))
        PL_succeed;
    PL_fail;

}

foreign_t swi_getFragmentListFromFrameParseOutput(term_t retterm, term_t pterm) {

    FrameParseOutput* fpo;
    te_SMLfragmentList* ret;

    if(!PL_is_integer(pterm))
        PL_fail;

    PL_get_pointer(pterm,(void**)&fpo);

    ret=getFragmentListFromFrameParseOutput(fpo);

    if(PL_unify_pointer(retterm,ret))
        PL_succeed;
    PL_fail;

}

foreign_t swi_getClassListFromClassListParseOutput(term_t retterm, term_t pterm) {

    ClassListParseOutput* clpo;
    te_ClassList* ret;

    if(!PL_is_integer(pterm))
        PL_fail;

    PL_get_pointer(pterm,(void**)&clpo);

    ret=getClassListFromClassListParseOutput(clpo);

    if(PL_unify_pointer(retterm,ret))
        PL_succeed;
    PL_fail;

}


foreign_t swi_getClassListParseErrNo(term_t retterm, term_t pterm) {

    ClassListParseOutput* clpo;
    int ret;

    if(!PL_is_integer(pterm))
        PL_fail;

    PL_get_pointer(pterm,(void**)&clpo);

    ret=getClassListParseErrNo(clpo);

    if(PL_unify_integer(retterm,ret))
        PL_succeed;
    PL_fail;

}

foreign_t swi_FragmentListCToProlog(term_t flpterm, term_t pterm) {
    te_SMLfragmentList* flp;
    term_t pterm2;

    if(!PL_is_integer(flpterm))
        PL_fail;

    PL_get_pointer(flpterm,(void**)&flp);

    pterm2=PL_new_term_ref();
    FragmentListCToProlog(flp,pterm2);
    if(PL_unify(pterm,pterm2))
        PL_succeed;
    PL_fail;
}


foreign_t swi_get_term_space(term_t retterm, term_t lenterm) {

    int len,ret;

    if(!PL_is_integer(lenterm))
        PL_fail;

    PL_get_integer(lenterm,&len);

    ret=get_term_space(len);

    if(PL_unify_integer(retterm,ret))
        PL_succeed;
    PL_fail;
}

foreign_t swi_ClassListCToProlog(term_t clpterm, term_t pterm) {
    te_ClassList* clp;
    term_t pterm2;

    if(!PL_is_integer(clpterm))
        PL_fail;

    PL_get_pointer(clpterm,(void**)&clp);

    pterm2=PL_new_term_ref();
    ClassListCToProlog(clp,pterm2);

    if(PL_unify(pterm,pterm2))
        PL_succeed;
    PL_fail;
}

foreign_t swi_getFragmentListSpace(term_t retterm, term_t pterm) {
    te_SMLfragmentList* flp;
    int ret;

    if(!PL_is_integer(pterm))
        PL_fail;

    PL_get_pointer(pterm,(void**)&flp);

    ret=getFragmentListSpace(flp);

    if(PL_unify_integer(retterm,ret))
        PL_succeed;
    PL_fail;
}

foreign_t swi_CharListToCString(term_t retterm, term_t charlist, term_t lenterm) {
    int len;
    char* ret;

    if(!PL_is_integer(lenterm))
        PL_fail;

    PL_get_integer(lenterm,&len);

    ret=CharListToCString(charlist,len);

    if(PL_unify_pointer(retterm,ret))
        PL_succeed;
    PL_fail;
}

void install_libtelosServer() {

    /* te_PrologUtilities */
    REGISTER_FOREIGN("ExternalCodeLoader","getFrameParseErrNo",2,swi_getFrameParseErrNo,0);
    REGISTER_FOREIGN("ExternalCodeLoader","getFrameParseErrToken",2,swi_getFrameParseErrToken,0);
    REGISTER_FOREIGN("ExternalCodeLoader","getFrameParseErrLine",2,swi_getFrameParseErrLine,0);
    REGISTER_FOREIGN("ExternalCodeLoader","getFragmentListFromFrameParseOutput",2,swi_getFragmentListFromFrameParseOutput,0);
    REGISTER_FOREIGN("ExternalCodeLoader","getClassListFromClassListParseOutput",2,swi_getClassListFromClassListParseOutput,0);
    REGISTER_FOREIGN("ExternalCodeLoader","getClassListParseErrNo",2,swi_getClassListParseErrNo,0);

    /* te_smlCToProlog */
    REGISTER_FOREIGN("ExternalCodeLoader","FragmentListCToProlog",2,swi_FragmentListCToProlog,0);
    REGISTER_FOREIGN("ExternalCodeLoader","get_term_space",2,swi_get_term_space,0);
    REGISTER_FOREIGN("ExternalCodeLoader","ClassListCToProlog",2,swi_ClassListCToProlog,0);

    /* te_smlGetFragmentSpace */
    REGISTER_FOREIGN("ExternalCodeLoader","getFragmentListSpace",2,swi_getFragmentListSpace,0);

    /* CharListToCString */
    REGISTER_FOREIGN("ExternalCodeLoader","CharListToCString",3,swi_CharListToCString,0);
}
