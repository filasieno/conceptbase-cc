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
* File:        	IpcString.c
* Version:     	1.3
* Creation:    Aug-1994, Christoph Radig (RWTH)
* Last Change: 	15 Dec 1994, Christoph Quix (RWTH)
* Release:     	1
* ----------------------------------------------------- */

#include <stdlib.h>
#include <string.h>
#include "IpcString.h"


char* encodeIpcString( const char* string )
{
    /* Groesse des Ausgabestrings berechnen: */
    char *s = (char *) malloc( getLengthOfEncodedString( string ) + 1 );
    const char *p = string;

    char *s2 = s;
    *s2++ = '\"';

    while( *p ) {
	if( *p == '\"' || *p == '\\' )
	    *s2++ = '\\';
	*s2++ = *p++;
    }
    *s2++ = '\"';
    *s2 = '\0';

    return s;
}  /* encodeIpcString */


char* decodeIpcString( const char* ipcstring )
{
	const char *p = ipcstring+1;  /* erstes " abschneiden */
	char *s = (char *) malloc( strlen(ipcstring)+1 );
	char *s2 = s;

	while( *p ) {
		if( *p != '\\' )
			*s2++ = *p++;
		else {
			++p;  /* ersten backslash ignorieren */
			*s2++ = *p++;  /* nachfolgendes Zeichen kopieren */
		}
	}
	--s2;  /* letztes " abschneiden */
	*s2 = '\0';

	return s;
}  /* decodeIpcString */


unsigned getLengthOfEncodedString( const char* string )
{
    unsigned i = 2;  /* for "" */

    while( *string ) {
	++i;
	if( *string == '\"' || *string == '\\' )
	    ++i;
	++string;
    }
    return i;
}
