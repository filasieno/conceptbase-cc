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


#include <stdlib.h>
#include <string.h>

#include "CButils.h"
#include "CBdebug.h"

LIBCB_API char* STDCALL CBdecodeString(const char* s)  {

	int l,l2;
	char* s2;

	if(!s)
	   return NULL;

	/* Return a duplicate if string is not encoded */
	if(s[0]!='"' || s[strlen(s)-1]!='"')
	    return strdup(s);

	l=1;
	l2=0;
	s2=malloc(strlen(s));

	while(s[l]) {
		if (s[l]=='\\')
			l++;
		s2[l2]=s[l];
		l++;
		l2++;
	}

	s2[l2-1]=0;

	return s2;

}






LIBCB_API char* STDCALL CBencodeString(const char *s)  {

	int l,l2;
	char* s2;

	if (!s)
		return strdup("\"\"");

	s2=malloc(CBgetEncodedLength(s)+5);

	s2[0]='"';
	l=0;
	l2=1;
	while(s[l]) {
		if ((s[l]=='"') || (s[l]=='\\')) {
			s2[l2]='\\';
			l2++;
		}
		s2[l2]=s[l];
		l2++;
		l++;
	}
	s2[l2]='"';
	s2[l2+1]=0;

	return s2;
}


LIBCB_API unsigned STDCALL CBgetEncodedLength(const char *string)  {

    unsigned i = 2;  /* for "" */

    while( *string ) {
        ++i;
        if( *string == '\"' || *string == '\\' )
            ++i;
        ++string;
    }
    return i;
}


/* copies a comma-separated list of strings
 * into a string array */
LIBCB_API char** STDCALL CBgetLabels(const char *list) {

	char** files;
	char* s;
	char* tmp;
	int i,ende;
	int com;

	com=0;
	for(i=0;list[i];i++) {
		if (list[i]==',')
			com++;
	}

	/* Allocate memory for filelist */
	files=(char**) malloc(sizeof(char*)*(com+100));
	tmp=strdup(list);

	/* initialize string */
	for(i=0;i<(com+100);i++)
		files[i]=0;

	ende=0;
	i=0;
	s=tmp;

	/* copy strings to string array */
	while (!ende) {
		while((*tmp) && (*tmp)!=',') {
			tmp++;
		}
		if (!(*tmp))
			ende=1;

		(*tmp)=0;
		files[i]=strdup(s);
		i++;
		tmp++;
		s=tmp;
	}
	files[i]=NULL;

	return files;

}
