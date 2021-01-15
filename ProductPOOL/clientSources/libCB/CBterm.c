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
/* The grammar for parsing a simple prolog term
 *
 * 1 term        -> identifier identTerm
 * 2             |  []
 * 3             |  [ termList ]
 *
 * 4 identTerm   -> EMPTY
 * 5             | ()
 * 6             | ( termList )
 *
 * 7 termList    -> term termList2
 *
 * 8 termList2   -> , termList
 * 9             |  EMPTY
 *
 * term, identTerm, termList and termList2 return CBterm*
 * identifier returns a char*
 *
 * */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "CBterm.h"

const char* CBlistFunctor="[]";

LIBCB_API cbterm* STDCALL parse_term(const char* term) {
	char* rest;
	return parse_term2(term,&rest);
}

cbterm* parse_term2(const char* term,char** restout) {

	char* tmp;
	char* rest;
	cbterm* t=(cbterm*) malloc(sizeof(cbterm));
	int len;

	t->pArgs=NULL;
	t->pNext=NULL;
	t->pFunctor=NULL;
	t->string=NULL;
	t->error=0;

	if (term) {
		/* Rule 1 */
		if (term[0]!='[') {
			tmp=parse_identifier(term,&rest);

			/* Special case: "nil" is the same as empty list */
			if(tmp && !strcmp(tmp,"nil")) {
				t->pFunctor=strdup(CBlistFunctor);
				t->pArgs=NULL;
				t->pNext=NULL;
				(*restout)=rest;
				free(tmp);
			}
			else {
				if (tmp) {
					t->pArgs=parse_identTerm(rest,restout);
					if (t->pArgs && t->pArgs->error)
						t->error=1;
					t->pFunctor=strdup(tmp);
					t->pNext=NULL;
					free(tmp);
				}
				else {
					t->error=1;
					(*restout)=NULL;
				}
			}
		}
		else {
			/* Rule 2 */
			if (term[1]==']') {
				t->pFunctor=strdup(CBlistFunctor);
				t->pArgs=NULL;
				t->pNext=NULL;
				(*restout)=(char*) &(term[2]);
			}
			/* Rule 3 */
			else  {
				t->pFunctor=strdup(CBlistFunctor);
				t->pArgs=parse_termList(&(term[1]),&rest);
				if (!t->pArgs || t->pArgs->error)
					t->error=3;
				t->pNext=NULL;
				if (t->pArgs && rest && rest[0]==']') {
					(*restout)=rest+1;
				}
				else {
					(*restout)=NULL;
					t->error=3;
				}
			}
		}
	}

	if (*restout) {
		len=(*restout) - term;
		t->string=(char*) malloc(len+5);
		strncpy(t->string,term,len);
		t->string[len]=0;
	}
	else {
		t->error=1;
	}

	return t;

}


char* parse_identifier(const char* term,char** rest) {

	int i;
	char* retstr;

	if (!term)
		return NULL;

	i=0;
	retstr=NULL;

	/* Parsing a quoted identifier */
	if (term[0]=='"') {
		i++;
		while(term[i] && (term[i] !='"')) {
			if (term[i] == '\\')
				i++;
			i++;
		}
		if (term[i]) {
			retstr=(char*) malloc(i+2);
			strncpy(retstr,term,i+1);
			retstr[i+1]=0;
			(*rest)=(char*) &(term[i+1]);
			return retstr;
		}
		else
			return NULL;
	}

	/* Parsing an assertion string */
	if (term[0]=='$') {
		i++;
		while(term[i] && (term[i] !='$')) {
			if (term[i] == '\\')
				i++;
			i++;
		}
		if (term[i]) {
			retstr=(char*) malloc(i+2);
			strncpy(retstr,term,i+1);
			retstr[i+1]=0;
			(*rest)=(char*) &(term[i+1]);
			return retstr;
		}
		else
			return NULL;
	}

	/* Parsing a normal identifier */
	while(is_ident_char(term[i])) {
		i++;
	}

	retstr=(char*) malloc(i+1);
	strncpy(retstr,term,i);
	retstr[i]=0;
	(*rest)=(char*) &(term[i]);
	return retstr;
}


cbterm* parse_identTerm(const char* in,char** rest) {

	cbterm* tmp;

	/* Rule 4 */
	if (in[0]!='(') {
		(*rest)=(char*) in;
		return NULL;
	}
	else {
		/* Rule 5 */
		if (in[1]==')') {
			(*rest)=(char*) &(in[2]);
			return NULL;
		}
		/* Rule 6 */
		else  {
			tmp=parse_termList(&(in[1]),rest);
			if (tmp && (*rest) && (*rest)[0]==')') {
				(*rest)++;
				return tmp;
			}
			else {
				(*rest)=NULL;
				free(tmp);
				return NULL;
			}
		}
	}
}


cbterm* parse_termList(const char* in, char** rest) {

	char* restout;
	cbterm* tmp;

	restout=(*rest);

	/* Rule 7 */
	tmp=parse_term2(in,&restout);

	if(tmp && !tmp->error) {
		tmp->pNext=parse_termList2(restout,rest);
		if (tmp->pNext && tmp->pNext->error)
			tmp->error=tmp->pNext->error;
		return tmp;
	}
	/* Error */
	else {
		(*rest)=(char*) in;
		tmp->error=7;
		return tmp;
	}
}


cbterm* parse_termList2(const char* in, char** rest) {

	cbterm* tmp;

	/* Rule 8 */
	if (in && (in[0]==',')) {
		tmp=parse_termList(&(in[1]),rest);
		return tmp;
	}
	/* Rule 9 */
	else {
		(*rest)=(char*) in;
		return NULL;
	}
}

LIBCB_API int STDCALL is_list(cbterm* t) {
	return  !strcmp(t->pFunctor,CBlistFunctor);
}

LIBCB_API int STDCALL is_constant(cbterm* t) {
	return  (!t->pArgs);
}

LIBCB_API cbterm* STDCALL get_arg(cbterm* t,int num) {

	int p;

	t=t->pArgs;

	for(p=1;((p<num) && t);p++)
		t=t->pNext;
	return t;
}


int is_ident_char(const char c) {
	return  c && strchr("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_#@%&*+?-=>.|^!",c);
}


LIBCB_API void STDCALL delete_term(cbterm* t) {

	if (t) {
		free(t->pFunctor);
		delete_term(t->pArgs);
		delete_term(t->pNext);
		free(t->string);

		free(t);
	}
}
