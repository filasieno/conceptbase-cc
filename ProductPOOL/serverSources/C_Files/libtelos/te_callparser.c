/*
The ConceptBase.cc Copyright

Copyright 1987-2019 The ConceptBase Team. All rights reserved.

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
* File:         %M%
* Version:      %I%
* Creation:
* Last Change   : %E%, Christoph Quix (RWTH)
*
* SCCS-Source-Pool : %P%
* Date retrieved : %D% (YY/MM/DD)
*
*/



/* include section */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "te_callparser.h"
#include "te_smlutil.h"

/* extern declarations */
extern int te_parser_parse();
extern void init_te_parser_InputBuffer( char *buf, unsigned bufSize );

/* global Variable */
char *te_ParseBuffer;  /* Buffer zur Uebergabe des Strings an den Parser */
int te_parse_mode=1;  /* 0 = parse Classlist
                       1 = parse Frames */
char *mod_context;


/** Calls the Telos Parser to parse frames.
 * @param indata a string containing the input frames
 * @return a pointer to a FrameParseOut structure with
 * \begin{description}
 * \item[error] 0 if ok, 1 if parse error, 2 if input is null
 * \item[smlfrag] List of SMLfragments
 * \item[errorline] Line number where the parse error occured
 * \item[errortoken] Token where the error occured
 * \end{description}
 * */
LIBTELOS_API FrameParseOutput* STDCALL te_frame_parser( char *indata )
{
    extern te_SMLfragmentList *te_sml; /* enthaelt geparste SMLfragmentList */
    extern char *te_tokenaftererror;   /* Inhalt des Tokens nach einem Fehler */
    extern int te_errorline;           /* enthaelt # der gescannten Zeilen */
    FrameParseOutput *parseOut;

    mod_context = 0; 	/* Loesche Hilfsvariablen im Scanner */

    if( (parseOut = (FrameParseOutput *) malloc(sizeof(FrameParseOutput))) ) {
		parseOut->smlfrag = NULL;
		parseOut->error = 0;
		parseOut->errortoken = NULL;
		parseOut->errorline = 0;

		if( !strlen( indata ) )
	    	parseOut->error = 2;
		else {
			te_tokenaftererror = NULL;
			te_errorline = 0;
			init_te_parser_InputBuffer(indata, strlen(indata));
			te_parse_mode = 1;

			parseOut->error = te_parser_parse();

			if( !parseOut->error )
				parseOut->smlfrag = te_sml;
			else {
				parseOut->errortoken = te_tokenaftererror;
				parseOut->errorline = te_errorline;
			}
		}
    }
    return parseOut;
}  /* te_frame_parser */


/** Calls the Telos Parser to parse a list of object names.
 * @param indata a string containing the input frames
 * @return a pointer to a FrameParseOut structure with
 * \begin{description}
 * \item[error] 0 if ok, 1 if parse error, 2 if input is null
 * \item[smlfrag] List of SMLfragments
 * \item[errorline] Line number where the parse error occured
 * \item[errortoken] Token where the error occured
 * \end{description}
 * */
LIBTELOS_API ClassListParseOutput* STDCALL te_classlist_parser( char *indata)
{
    extern te_ClassList *te_classes;   /* enthaelt geparste Classlisten */
    extern char *te_tokenaftererror;   /* Inhalt des Tokens nach einem Fehler */
    extern int te_errorline;           /* enthaelt # der gescannten Zeilen */
    ClassListParseOutput *parseOut;

    mod_context = 0; /* Loesche Hilfsvariablen im Scanner */

    if( (parseOut = (ClassListParseOutput *) malloc(sizeof(ClassListParseOutput))) ) {
		parseOut->classlist = NULL;
		parseOut->error = 0;
		parseOut->errortoken = NULL;
		parseOut->errorline = 0;

		if( !strlen( indata ) )
	    	parseOut->error = 2;
		else {
			te_tokenaftererror = NULL;
			te_errorline = 0;
			init_te_parser_InputBuffer(indata, strlen(indata));
            te_parse_mode=0;

			parseOut->error = te_parser_parse();

			if( !parseOut->error )
				parseOut->classlist = te_classes;
			else {
				parseOut->errortoken = te_tokenaftererror;
				parseOut->errorline = te_errorline;
			}
		}
    }
    return parseOut;
}  /* te_classlist_parser */
