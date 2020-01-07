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
/*
*
* File:        IpcAnswer.c
* Version:     1.2
* Creation:    Aug-1994, Christoph Radig (RWTH-Aachen)
* Last Change: 18 Jan 1995 , Christoph Quix (RWTH-Aachen)
* Release:     1
* -----------------------------------------------------
*/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "IpcString.h"
#include "IpcAnswer.h"


char* make_ipcanswerstring( char* receiver, char* completion, char* arg3, int* len )
{
    char* s_rec;
    char* s_compl;
    char* s_arg3;
    char* s_answer;

    s_rec = encodeIpcString( receiver );
    s_compl = completion;
    s_arg3 = encodeIpcString( arg3 );

    s_answer = (char*)malloc( 15 + strlen(s_rec) + strlen(s_compl) + strlen(s_arg3) );
    sprintf( s_answer, "ipcanswer(%s,%s,%s).", s_rec, s_compl, s_arg3 );

    free( s_rec );
    free( s_arg3 );

    *len = strlen(s_answer);
    return s_answer;
}

