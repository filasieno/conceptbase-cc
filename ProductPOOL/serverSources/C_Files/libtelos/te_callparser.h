/*
The ConceptBase.cc Copyright

Copyright 1987-2025 The ConceptBase Team. All rights reserved.

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
/*
 * Structures and functions that are used by the Telos parser.
 */

#include "telosdll.h"
#include "fragment.h"

/**
 * FrameParseOutput is the structure returned by the function
 * te_frame_parser. It contains either a list of fragments or
 * information about the parse error.
 *
 */
typedef struct frameParseoutput {
	  /** the list of fragments */
        te_SMLfragmentList *smlfrag;
      /** 0 if ok, 1 if parse error, 2 if input is null */
        int                 error;
      /** If there was an parse error, this should indicate the token that caused the error. */
        char               *errortoken;
      /** If there was an parse error, this should be the line number of the error. */
        int                 errorline;
} FrameParseOutput;

/**
 * ClassListParseOutput is the structure returned by the function
 * te_classlist_parser. It contains either a list of classes or
 * information about the parse error.
 */
typedef struct classlistParseoutput {
	    /** A list of classes (object names) */
        te_ClassList       *classlist;
      /** Non-zero if an error occured */
        int                 error;
      /** If there was an parse error, this should indicate the token that caused the error. */
        char               *errortoken;
      /** If there was an parse error, this should be the line number of the error. */
        int                 errorline;
} ClassListParseOutput;


/** Calls the Telos Parser to parse frames.
 * @param indata a string containing the input frames
 * @return a pointer to a FrameParseOut structure
 * */
LIBTELOS_API FrameParseOutput* STDCALL te_frame_parser(char *indata);

/** Calls the Telos Parser to parse a list of object names.
 * @param indata a string containing the object names
 * @return a pointer to a ClassListParseOut structure
 * */
LIBTELOS_API ClassListParseOutput* STDCALL te_classlist_parser(char *indata);
