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

/* Funtions to parse prolog-like terms */

#ifndef _CBTERM_H_
#define _CBTERM_H_

#ifdef  __cplusplus
extern "C" {
#endif

#include <string.h>
#include <stdlib.h>
#include "CBdll.h"

	/** Constant char for list functor */
	extern const char* CBlistFunctor;

	/** Structure for Prolog-like terms used frequently by ConceptBase */
	struct cbt {

		/** Functor of a term (may be CBlistFunctor to indicate a list)
		 * @see CBlistFunctor */
		char* pFunctor;

		/** Pointer to the arguments of the term */
		struct cbt* pArgs;

		/** Pointer to the next term in the list */
		struct cbt* pNext;

		/** String representation of the term */
		char* string;

		/** Non-Zero if an error occured while parsing a (sub-)term */
		int error;
	};

	/** The type definition for cbt
	 * @see cbt */
	typedef struct cbt cbterm;

	/** Parse the string and return a term
	 * @param term the string
	 * @return a pointer to the parsed term
	 * */
	LIBCB_API cbterm* STDCALL parse_term(const char* term);

	cbterm* parse_term2(const char* term,char** rest);
	char* parse_identifier(const char* term,char** rest);
	cbterm* parse_identTerm(const char* in,char** rest);
	cbterm* parse_termList(const char* in, char** rest);
	cbterm* parse_termList2(const char* in, char** rest);

	/** Check if the term is a list
	 * @param t the term
	 * @return non-zero when true
	 * */
	LIBCB_API int STDCALL is_list(cbterm* t);

	/** Check if the term is a constant
	 * @param t the term
	 * @return non-zero when true
	 * */
	LIBCB_API int STDCALL is_constant(cbterm* t);

	/** Get an argument of a term
	 * @param t the term
	 * @param num the position of the argument
	 * @return pointer to the argument, NULL on error
	 * */
	LIBCB_API cbterm* STDCALL get_arg(cbterm* t, int num);

	/** Delete a term. Deallocates the memory used by the term.
	 * @param t the term to delete
	 * */
	LIBCB_API void STDCALL delete_term(cbterm* t);

	/**
	 * Internal utility method. Return true if c is character that may
	 * occur in an identifier.
	 */
	int is_ident_char(const char c);

#ifdef  __cplusplus
}
#endif

#endif

