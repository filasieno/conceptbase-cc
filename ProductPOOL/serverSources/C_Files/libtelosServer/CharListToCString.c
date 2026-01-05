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
#include <string.h>
#include "CharListToCString.h"

char *CharListToCString( PROLOG_TERM charlist, unsigned len ) {
    PROLOG_TERM arg;
#ifdef BIM

    PROLOG_TERM atom_val;
#endif

    char* string;
    char* s;
    unsigned count = 0;
    int success = 1;

    string = (char *)malloc( len+1 );

    while( PL_TERM_IS_LIST( charlist ) && !PL_TERM_IS_ATOM(charlist)) {
        if( count >= len ) {
            printf("BIMToCString: BIMString longer than expected!\n");
            success = 0;
            break;
        }
        else {
            INIT_TERM(arg);
            if(!GET_ARG( charlist, 1, arg )) {
                printf("BIMtoCString: error from get_term_arg #1!\n");
                success = 0;
                break;
            }
            else {
                if( !PL_TERM_IS_ATOM(arg)) {
                    printf("BIMtoCString: atom expected #1!\n");
                    success = 0;
                    break;
                }
                else {
#ifdef BIM
                    BIM_Prolog_get_term_value( arg, BP_T_ATOM, &atom_val );
                    s = BIM_Prolog_atom_to_string(atom_val);
#else

                    PL_get_atom_chars(arg, &s);
#endif

                    string[count] = *s;

                }

                if(!GET_ARG( charlist, 2, charlist )) {
                    printf("BIMtoCString: error from get_term_arg #2!\n");
                    success = 0;
                    break;
                }
            }  /* else */
            ++count;
        }  /* else */
    }  /* while */

    if( !PL_TERM_IS_ATOM(charlist)) {
        printf("BIMtoCString: atom expected #2!\n");
        success = 0;
    }
    else {
#ifdef BIM
        BIM_Prolog_get_term_value( charlist, BP_T_ATOM, &atom_val );
        if( strcmp( BIM_Prolog_atom_to_string(atom_val), "[]" ) &&
            strcmp( BIM_Prolog_atom_to_string(atom_val), "nil" ) ) {
#else
        if(!(PL_is_atom(charlist) && PL_unify_nil(charlist))) {
#endif
            printf("BIMtoCString: empty list (\"[]\" or \"nil\") expected!\n");
            success = 0;
        }
        else
            string[count] = (char)0;
    }

    if( !success ) {
        free(string);
        string = 0;
    }
    /*else
    printf("BIMToCString: %s\n",string);*/

    return string;
}  /* CharListToCString */
