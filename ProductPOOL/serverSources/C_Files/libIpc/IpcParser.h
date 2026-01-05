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
/*
*
* File:        IpcParser.h
* Version:     1.2
* Creation:    Aug-1994, Christoph Radig (RWTH-Aachen)
* Last Change: 10 Dez 1996 , Lutz Bauer (RWTH-Aachen)
* Release:     1
* -----------------------------------------------------------------------------
*/
/* The following structures define the treelike structure that is put out by the IpcParser.

  IMPORTANT: If these structures are modified, the Prolog code that knows about them has to be adapted!
*/


#define IPC_FRAMES	1
#define IPC_OBJNAMES	2

#include "prolog.h"

typedef struct ipcStringList {
	char *string;
	struct ipcStringList *next;
} IpcStringList;

typedef struct ipcStrings {
	char *strings[2];
} IpcStrings;

typedef struct ipcQuery {
	int type;  /* IPC_FRAMES (1) or IPC_OBJNAMES (2)*/
	char *frames;
	char *objnames;
} IpcQuery;

typedef struct ipcMeAsk {
	IpcQuery* query;
	char *ansrep;
	char *rbtime;
} IpcMeAsk;

typedef struct ipcMeHypoAsk {
	char *objects;
	IpcQuery *query;
	char *ansrep;
	char *rbtime;
} IpcMeHypoAsk;

typedef union ipcArgs {
	char *frames;  /* ME_FRAMES */
	IpcStrings strings;  /* several ME_xxx */
	IpcStringList *stringList;  /* ME_STRINGLIST */
	IpcMeAsk ask;  /* ME_ASK */
	IpcMeHypoAsk hypoAsk;  /* ME_HYPO_ASK */
} IpcArgs;

typedef struct ipcMethodArgs {
	char *method;
	int type;  /* nur fuer interne Zwecke */
	IpcArgs args;
	char* module;
} IpcMethodArgs;

typedef struct ipcMessage {
	char *sender;
	char *receiver;
	IpcMethodArgs *mArgs;
} IpcMessage;

typedef struct ipcParserOutput {
	int err;  /* 0: ok, else error */
	IpcMessage *im;  /* contains the ipc message, if err == 0 */
} IpcParserOutput;



/* the following functions are used by the IpcParser to construct the output tree: */

#ifdef __cplusplus
extern "C" {
#endif

IpcMessage *newIpcMessage( char *sender, char *receiver, IpcMethodArgs *mArgs );
/* IN: sender, receiver, mArgs: must be allocated.
*/

IpcMethodArgs *newMeFrames( char *method, char *frames, char* module );
/* IN: method, frames: must be allocated.
*/

IpcMethodArgs *newMeStrings( char *method, char *string1, char *string2, char* module  );
/* IN: method: must be allocated.
   IN: string1, string2: must be NULL or allocated.
*/

IpcMethodArgs *newMeAsk( char *method, IpcQuery *query, char *ansrep, char *rbtime, char* module  );
/* IN: method, query, ansrep, rbtime: must be allocated.
*/

IpcMethodArgs *newMeHypoAsk( char *method, char *objects, IpcQuery *query, char *ansrep, char *rbtime, char* module  );
/* IN: method, objects, query, ansrep, rbtime: must be allocated.
*/

IpcMethodArgs *newMeStringList( char *method, IpcStringList *stringList, char* module  );
/* IN: method, stringList: must be allocated.
*/

IpcQuery *newIpcQuery( int type, char *frames, char *objnames );
/* IN: type:     IPC_FRAMES oder IPC_OBJNAMES
   IN: frames:   if type == IPC_FRAMES: must be allocated.
                 otherwise NULL.
   IN: objnames: if type == IPC_OBJNAMES: must be allocated.
                 otherwise NULL.
*/

IpcStringList *newIpcStringList( char *string );
/* IN: string: must be allocated. */

IpcStringList *appendToIpcStringList( IpcStringList *l1, IpcStringList *l2 );
/* append l2 to l1 and return l1.
   IN:  l1, l2: must be allocated.
   RET: == l1
*/


/* The following functions are used by the IpcParser to destruct the output tree.
   Just call DeleteIpcMessage to delete the whole tree.
*/

void DeleteIpcMessage( IpcMessage *im );
/* IN: im: != NULL
*/

void DeleteIpcMethodArgs( IpcMethodArgs *ma );
/* IN: ma: != NULL
*/

void DeleteIpcQuery( IpcQuery *iq );
/* IN: iq: != NULL
*/

void DeleteIpcStringList( IpcStringList *al );
/* IN: al: may be NULL.
*/

IpcMessage* GetMessageFromIpcParserOutput(IpcParserOutput* ipo);

int GetErrFromIpcParserOutput(IpcParserOutput* ipo);

int GetIpcMessageAsTerm(IpcParserOutput* ipo, PROLOG_TERM ipcTerm);

IpcParserOutput* IpcParse( char* inputBuffer );

#ifdef __cplusplus
}
#endif
