/*
The ConceptBase.cc Copyright

Copyright 1987-2021 The ConceptBase Team. All rights reserved.

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

#include "IpcParser.h"
#include "IpcAnswer.h"
#include "IpcString.h"

#include <stdio.h>
#ifdef __cplusplus
extern "C" {
#endif


foreign_t swi_IpcParse(term_t retterm, term_t pterm) {

    char* inputBuffer;
    IpcParserOutput* ret;

    if(!PL_is_integer(pterm))
        PL_fail;

    PL_get_pointer(pterm,(void**)&inputBuffer);
    ret=IpcParse(inputBuffer);

    if(!PL_unify_pointer(retterm,ret))
        PL_fail;
    PL_succeed;
}

foreign_t swi_GetMessageFromIpcParserOutput(term_t retterm, term_t pterm) {

    IpcParserOutput* ipo;
    IpcMessage* im;

    if(!PL_is_integer(pterm))
        PL_fail;

    PL_get_pointer(pterm,(void**)&ipo);
    im=GetMessageFromIpcParserOutput(ipo);

    if(!PL_unify_pointer(retterm,im))
        PL_fail;
    PL_succeed;
}


foreign_t swi_GetErrFromIpcParserOutput(term_t retterm, term_t pterm) {

    IpcParserOutput* ipo;
    int err;

    if(!PL_is_integer(pterm))
        PL_fail;

    PL_get_pointer(pterm,(void**)&ipo);
    err=GetErrFromIpcParserOutput(ipo);

    if(!PL_unify_integer(retterm,err))
        PL_fail;
    PL_succeed;
}

foreign_t swi_DeleteIpcMessage(term_t pterm) {

    IpcMessage* im;

    if(!PL_is_integer(pterm))
        PL_fail;

    PL_get_pointer(pterm,(void**)&im);
    DeleteIpcMessage(im);

    PL_succeed;
}

foreign_t swi_encodeIpcString(term_t retterm, term_t pterm) {

    char* input;
    char* ret;

    if(!PL_is_integer(pterm))
        PL_fail;

    PL_get_pointer(pterm,(void**)&input);
    ret=encodeIpcString(input);

    if(!PL_unify_pointer(retterm,ret))
        PL_fail;
    PL_succeed;
}

foreign_t swi_make_ipcanswerstring(term_t retterm, term_t recterm, term_t complterm, term_t arg3term, term_t lenterm) {

    char* ret;
    char* rec;
    char* completion;
    char* arg3;
    int len;

    if(!PL_is_atom(recterm) || !PL_is_atom(complterm) || !PL_is_integer(arg3term))
        PL_fail;

    PL_get_atom_chars(recterm,&rec);
    PL_get_atom_chars(complterm,&completion);
    PL_get_pointer(arg3term,(void**)&arg3);

    ret=make_ipcanswerstring(rec,completion,arg3,&len);

    if(PL_unify_pointer(retterm,ret) && PL_unify_integer(lenterm,len))
        PL_succeed;
    PL_fail;
}


foreign_t swi_GetIpcMessageAsTerm(term_t retterm, term_t ipoterm, term_t resterm) {

    int ret;
    IpcParserOutput* ipo;
    term_t resterm2;
    if(!PL_is_integer(ipoterm))
        PL_fail;

    PL_get_pointer(ipoterm,(void**)&ipo);

    resterm2=PL_new_term_ref();
    ret=GetIpcMessageAsTerm(ipo,resterm2);

    if(PL_unify_integer(retterm,ret) && PL_unify(resterm,resterm2))
        PL_succeed;
    PL_fail;
}

void install_libIpc() {

    REGISTER_FOREIGN("ExternalCodeLoader","IpcParse",2,(void*)swi_IpcParse,0);
    REGISTER_FOREIGN("ExternalCodeLoader","GetMessageFromIpcParserOutput",2,(void*)swi_GetMessageFromIpcParserOutput,0);
    REGISTER_FOREIGN("ExternalCodeLoader","GetErrFromIpcParserOutput",2,(void*)swi_GetErrFromIpcParserOutput,0);
    REGISTER_FOREIGN("ExternalCodeLoader","DeleteIpcMessage",1,(void*)swi_DeleteIpcMessage,0);
    REGISTER_FOREIGN("ExternalCodeLoader","encodeIpcString",2,(void*)swi_encodeIpcString,0);
    REGISTER_FOREIGN("ExternalCodeLoader","make_ipcanswerstring",5,(void*)swi_make_ipcanswerstring,0);
    REGISTER_FOREIGN("ExternalCodeLoader","GetIpcMessageAsTerm",3,(void*)swi_GetIpcMessageAsTerm,0);

}


#ifdef __cplusplus
}
#endif
