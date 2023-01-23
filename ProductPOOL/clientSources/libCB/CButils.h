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

#ifndef _CBUTILS_H_
#define _CBUTILS_H_

#include "CBdll.h"
#include "CBinterface.h"

#ifdef __cplusplus
extern "C" {
#endif

	/** Decode a string. ConceptBase encodes all strings with '"' and \\. To
	 * get the plain string, use this function.
	 * @param s the string to decode
	 * @return the decoded string
	 * */
	LIBCB_API char* STDCALL CBdecodeString(const char* s);

	/** Encode a String. ConceptBase encodes all strings with '"' and \\.
	 * Use this function if you want to use Strings in Telos frames.
	 * @param s the string to encode
	 * @return the encoded string
	 * */
	LIBCB_API char* STDCALL CBencodeString(const char* s);

	/** Return the length of an encoded string. This function is called
	 * by CBencodeString to allocate the memory of the encoded string.
	 * @param the string to encode
	 * @return approximately the length of the encoded string
	 * */
	LIBCB_API unsigned STDCALL CBgetEncodedLength(const char* s);

	/** Parse a comma-separated list of labels. ConceptBase returns
	 * sometimes comma-separated list of labels. This function makes
	 * an array of strings out of one plain string.
	 * @param labelList string with comma-separated-list
	 * @return an array of strings
	 * */
	LIBCB_API char** STDCALL CBgetLabels(const char* labelList);


#ifdef __cplusplus
}
#endif


#endif
