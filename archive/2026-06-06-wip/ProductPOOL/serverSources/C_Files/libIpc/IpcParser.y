/*
The ConceptBase Copyright

Copyright 1988-2009 The ConceptBase Team. All rights reserved.

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

Matthias Jarke, RWTH Aachen, Informatik 5, Ahornstr. 55, 52056 Aachen, Germany
Manfred Jeusfeld, Tilburg University, Warandelaan 2, 5037 AB Tilburg, The Netherlands
Christoph Quix, RWTH Aachen, Informatik 5, Ahornstr. 55, 52056 Aachen, Germany


This license is a FreeBSD copyright license.
Legal home of the FreeBSD copyright license: http://www.freebsd.org/copyright/freebsd-license.html
*/
%{
/*
*
* File:        	IpcParser.y
* version:     	1.4
* Creation:    Aug-1994, Christoph Radig (RWTH)
* Last Change: 	10 Dec 1996, Lutz Bauer (RWTH)
* Release:     	1
* ----------------------------------------------------- */

/* parser for ipc messages used in ConceptBase */

#include <stdlib.h>  /* malloc */
#include <string.h>
#include "IpcParser.h"


/* Typen: */

#ifdef __cplusplus
  extern "C" {
#endif

int Ipcerror( char * );

#ifdef __cplusplus
  }
#endif

extern int Ipclex();


/* global variables: */

static IpcParserOutput *theIpcParserOutput=NULL;
/* FILE *theIpcParserInputFile; */
/* static IpcMessage *theIpcMessage; */

%}

%union {
	char*			s;
	IpcMessage*		im;
	IpcMethodArgs*	ma;
	IpcQuery*		q;
	IpcStrings*		strings;
	IpcStringList*		stringList;
}

%token IPCMESSAGE
%token <s> ME_FRAMES  ME_NOARGS ME_1STRING ME_2STRINGS  ME_OPTIPCID  ME_ASK  ME_HYPO_ASK  ME_STRINGLIST LPI_CALL
%token  FRAMES  OBJNAMES
%token <s> STRING
%token <s> IPCID

%type <im> ipcmessage
%type <s> sender
%type <s> receiver
%type <ma> method_and_args
%type <s> method
%type <s> telosframes
%type <s> optipcid
%type <s> ipcid
%type <s> modulearg
%type <q> query
%type <s> ansrep
%type <s> rbtime
%type <s> objnames
%type <stringList> stringlist
%type <stringList> ne_stringlist
%type <stringList> strings
%type <stringList> string

%start	ipcmessage

%%

ipcmessage		:	IPCMESSAGE  '('  sender  ','  receiver  ','  method_and_args  ')'  '.'
					{ theIpcParserOutput->im = newIpcMessage( $3, $5, $7 ); }
                                | error  { theIpcParserOutput->err=1; theIpcParserOutput->im=NULL; }
				;
sender			:	STRING
					{ $$ = $1;}
				;
receiver		:	STRING
					{ $$ = $1; }
				;
method_and_args	:	ME_FRAMES  ','  '['  telosframes  modulearg ']'
					{ $$ = newMeFrames( $1, $4, $5 ); }
				|  ME_NOARGS  ','  '['  ']'
					{ $$ = newMeStrings( $1, NULL, NULL, NULL ); }
				|  ME_1STRING ',' '[' STRING ']'
					{ $$ = newMeStrings( $1, $4, NULL, NULL ); }
				|  ME_2STRINGS  ','  '['  STRING  ','  STRING modulearg ']'
					{ $$ = newMeStrings( $1, $4, $6, $7 ); }
				|  ME_STRINGLIST  ','  '['  stringlist modulearg ']'
					{ $$ = newMeStringList( $1, $4, $5 ); }
				|  ME_OPTIPCID  ','  '['  optipcid  ']'
					{ $$ = newMeStrings( $1, $4, NULL, NULL ); }
				|  ME_ASK  ','  '['  query  ','  ansrep  ','  rbtime modulearg ']'
					{ $$ = newMeAsk( $1, $4, $6, $8, $9); }
				| ME_HYPO_ASK  ','  '['  telosframes  ','  query  ','  ansrep  ','  rbtime modulearg ']'
					{ $$ = newMeHypoAsk( $1, $4, $6, $8, $10, $11 ); }
				| LPI_CALL ',' '[' STRING ']'
				        { $$ = newMeStrings($1, $4, NULL, NULL); }
				;

modulearg			: ',' STRING {$$ = $2; }
				| /* empty */ { $$ = NULL; }
				  ;

method		:	ME_FRAMES
				|  ME_NOARGS
				|  ME_1STRING
				|  ME_2STRINGS
				|  ME_STRINGLIST
				|  ME_OPTIPCID
				|  ME_ASK
				|  ME_HYPO_ASK
				;
telosframes		:	STRING { $$ = $1;}
				;
optipcid		:	/* empty */
					{ $$ = NULL ; }
				|  ipcid
					{ $$ = $1 ; }
				;
ipcid			:	method
					{ $$ = $1 ; }
				|  IPCID
					{ $$ = $1 ; }
				;
query			:	FRAMES  ','  telosframes
					{ $$ = newIpcQuery( IPC_FRAMES, $3, NULL ); }
				|  OBJNAMES  ','  objnames
					{ $$ = newIpcQuery( IPC_OBJNAMES, NULL, $3 ); }
				;
ansrep			:	STRING
					{ $$ = $1; }
				;
rbtime			:	STRING
					{ $$ = $1; }
				;
objnames		:	STRING
					{ $$ = $1; }
				;
stringlist		:	'['  ']'
					{ $$ = NULL; }
				|  ne_stringlist
					{ $$ = $1; }
				;
ne_stringlist		:	'['  strings  ']'
					{ $$ = $2; }
				;
strings			:	string
					{ $$ = $1; }
				|  strings  ','  string
					{ $$ = appendToIpcStringList( $1, $3 ); }
				;
string			:	STRING
					{ $$ = newIpcStringList( $1 ); }
				;

%%

#include <stdio.h>


int Ipcerror( char *s )
{
	fprintf( stderr, "IpcParser: %s\n", s );
	return 1;
}

void initIpcInputBuffer( char *buf, unsigned bufSize );

#ifdef __cplusplus
  extern "C" {
#endif

IpcParserOutput* IpcParse( char* inputBuffer )
{
	extern FILE *Ipcin;

    if(theIpcParserOutput==NULL) {
        theIpcParserOutput=(IpcParserOutput*)malloc(sizeof(IpcParserOutput));
    }
	/*Ipcin = inputfile;*/
	initIpcInputBuffer( inputBuffer, strlen(inputBuffer) );

	theIpcParserOutput->err = Ipcparse();  /* Aufruf des YACC-Parsers: */

        /* print out malformed IpcMessage if encountered */
        if (theIpcParserOutput->err != 0) {
           fprintf( stderr, ">>> IpcParser.y: Malformed IPC message with length %d\n",strlen(inputBuffer));
           fprintf( stderr, "Content: %-0.200s\n\n",inputBuffer);
        }

    return theIpcParserOutput;
}  /* IpcParse */

#ifdef __cplusplus
  }
#endif


#ifdef MAIN
int main()
{
	int err = 0;
	IpcParserOutput tipo;

/*	while( !feof( stdin ) && !err ) {	*/
		IpcParse( stdin, &tipo );

/*	}*/
	return err;
}
#endif


