/*
The ConceptBase.cc Copyright

Copyright 1987-2024 The ConceptBase Team. All rights reserved.

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
* File:        	IpcParser.c
* Version:     	1.5
* Creation:    Aug-1994, Christoph Radig (RWTH)
* Last Change: 	10 Dec 1994, Lutz Bauer (RWTH)
* Release:     	1
* ----------------------------------------------------- */

#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
#include <string.h>
#include "IpcParser.h"
#include "prolog.h"

enum { IPC_ME_FRAMES = 1, IPC_ME_NOARGS, IPC_ME_STRINGS, IPC_ME_ASK, IPC_ME_HYPO_ASK, IPC_ME_STRINGLIST
};

/* tree construction: */

IpcMessage *newIpcMessage( char *sender, char *receiver, IpcMethodArgs *mArgs )
{
    assert( sender != NULL );
    assert( receiver != NULL );
    assert( mArgs != NULL );

        IpcMessage *im = (IpcMessage *)malloc( sizeof(IpcMessage) );
	im->sender = sender;
	im->receiver = receiver;
	im->mArgs = mArgs;
	return im;
}  /* newIpcMessage */


IpcMethodArgs *newMeFrames( char *method, char *frames, char* module )
{
	IpcMethodArgs *ma = (IpcMethodArgs *)malloc( sizeof(IpcMethodArgs) );
	ma->method = method;
	ma->type = IPC_ME_FRAMES;
	ma->args.frames = frames;
	ma->module = module;
	return ma;
}  /* newMeFrames */


IpcMethodArgs *newMeStrings( char *method, char *string1, char *string2, char* module)
{
    assert( method );
    assert( string1 || !string2 );

	IpcMethodArgs *ma = (IpcMethodArgs *)malloc( sizeof(IpcMethodArgs) );
	ma->method = method;
	if(string1==NULL)
	    ma->type=IPC_ME_NOARGS;
	else
	    ma->type = IPC_ME_STRINGS;
	ma->args.strings.strings[0] = string1;
	ma->args.strings.strings[1] = string2;
	ma->module = module;
	return ma;
}  /* newMeStrings */


IpcMethodArgs *newMeAsk( char *method, IpcQuery *query, char *ansrep, char *rbtime, char* module )
{
	IpcMethodArgs *ma = (IpcMethodArgs *)malloc( sizeof(IpcMethodArgs) );
	ma->method = method;
	ma->type = IPC_ME_ASK;
	ma->args.ask.query  = query;
	ma->args.ask.ansrep = ansrep;
	ma->args.ask.rbtime = rbtime;
	ma->module = module;
	return ma;
}  /* newMeAsk */


IpcMethodArgs *newMeHypoAsk( char *method, char *objects, IpcQuery *query, char *ansrep, char *rbtime, char* module)
{
	IpcMethodArgs *ma = (IpcMethodArgs *)malloc( sizeof(IpcMethodArgs) );
	ma->method = method;
	ma->type = IPC_ME_HYPO_ASK;
	ma->args.hypoAsk.objects = objects;
	ma->args.hypoAsk.query   = query;
	ma->args.hypoAsk.ansrep  = ansrep;
	ma->args.hypoAsk.rbtime  = rbtime;
	ma->module = module;
	return ma;
}  /* newMeHypoAsk */


IpcMethodArgs *newMeStringList( char *method, IpcStringList *stringList, char* module)
{
   	IpcMethodArgs *ma = (IpcMethodArgs *)malloc( sizeof(IpcMethodArgs) );
	ma->method = method;
	ma->type = IPC_ME_STRINGLIST;
	ma->args.stringList = stringList;
	ma->module = module;
	return ma;
}  /* newMeStringList */


IpcQuery *newIpcQuery( int type, char *frames, char *objnames )
{
    assert( type == IPC_FRAMES || type == IPC_OBJNAMES );

	IpcQuery *q = (IpcQuery *)malloc( sizeof(IpcQuery) );
	q->type = type;
	switch( type ) {
	    case IPC_FRAMES:
		q->frames = frames;
		q->objnames = NULL;
		break;

	    case IPC_OBJNAMES:
		q->frames = NULL;
		q->objnames = objnames;
		break;
	}
	return q;
}  /* newIpcQuery */


IpcStringList *newIpcStringList( char *string )
{
	IpcStringList *sl = (IpcStringList *)malloc( sizeof(IpcStringList) );
	sl->string = string;
	sl->next = 0;
	return sl;
}  /* newIpcStringList */


IpcStringList *appendToIpcStringList( IpcStringList *l1, IpcStringList *l2 )
{
	IpcStringList *p = l1;
	if( !p ) return l2;
	while( p->next )
		p = p->next;
	p->next = l2;
	return l1;
}  /* appendToIpcStringList */



/* tree destruction: */

void DeleteIpcMessage( IpcMessage *im )
{
    assert( im );

    free( im->sender );
    free( im->receiver );
    DeleteIpcMethodArgs( im->mArgs );
    free( im );
}  /* DeleteIpcMessage */


void DeleteIpcMethodArgs( IpcMethodArgs *ma )
{
    assert( ma );

    free( ma->method );
    switch( ma->type ) {
	case IPC_ME_FRAMES:
	    free( ma->args.frames );
	    if (ma->module)
		free( ma->module);
	    break;

	case IPC_ME_STRINGS:
	case IPC_ME_NOARGS:
	    if( ma->args.strings.strings[0] )
		free( ma->args.strings.strings[0] );
	    if( ma->args.strings.strings[1] )
		free( ma->args.strings.strings[1] );
	    if (ma->module)
		free( ma->module);
	    break;

	case IPC_ME_STRINGLIST:
	    DeleteIpcStringList( ma->args.stringList );
	    if (ma->module)
		free( ma->module);
	    break;

	case IPC_ME_ASK:
	    DeleteIpcQuery( ma->args.ask.query );
	    free( ma->args.ask.ansrep );
	    free( ma->args.ask.rbtime );
	    if (ma->module)
		free( ma->module);
	    break;

	case IPC_ME_HYPO_ASK:
	    free( ma->args.hypoAsk.objects );
	    DeleteIpcQuery( ma->args.hypoAsk.query );
	    free( ma->args.hypoAsk.ansrep );
	    free( ma->args.hypoAsk.rbtime );
	    if (ma->module)
		free( ma->module);
	    break;

	default:
	    assert( 0 );  /* error */
    }
}  /* DeleteIpcMethodArgs */


void DeleteIpcQuery( IpcQuery *iq )
{
    assert( iq );
    assert( iq->type == IPC_FRAMES || iq->type == IPC_OBJNAMES );


    switch( iq->type ) {
	case IPC_FRAMES:
	    assert( iq->frames );
	    assert( !iq->objnames );
	    free( iq->frames );
	    break;

	case IPC_OBJNAMES:
	    assert( !iq->frames );
	    assert( iq->objnames );
	    free( iq->objnames );
	    break;
    }
}  /* DeleteIpcQuery */


void DeleteIpcStringList( IpcStringList *al )
{
    if( al ) {
	free( al->string );
	DeleteIpcStringList( al->next );
	free( al );
    }
}  /* DeleteIpcStringList */



IpcMessage* GetMessageFromIpcParserOutput(IpcParserOutput* ipo) {
    return ipo->im;
}

int GetErrFromIpcParserOutput(IpcParserOutput* ipo) {
    return ipo->err;
}

int GetIpcMessageAsTerm(IpcParserOutput* ipo, PROLOG_TERM ipcTerm) {
    PROLOG_FUNC ipcFunc;
    PROLOG_TERM senderTerm;
    PROLOG_TERM receiverTerm;
    PROLOG_TERM methodTerm;
    PROLOG_TERM argsTerm;
    PROLOG_TERM framesTerm;
    PROLOG_TERM tmpTerm;
    PROLOG_TERM modTerm;
    PROLOG_TERM listTerm;
    IpcStringList* ipcStrList;
    IpcMessage* im=ipo->im;

    if(!im)
        return 0;

    ipcFunc=GET_PRED( STR2ATOM(FALSE,"ipcmessage"), 4 );
    UNIFY_FUNC(ipcTerm,ipcFunc);

    INIT_TERM(senderTerm);
    GET_ARG(ipcTerm,1,senderTerm);
    UNIFY_ATOM(senderTerm,STR2ATOM(FALSE,im->sender));

    INIT_TERM(receiverTerm);
    GET_ARG(ipcTerm,2,receiverTerm);
    UNIFY_ATOM(receiverTerm,STR2ATOM(FALSE,im->receiver));

    INIT_TERM(methodTerm);
    GET_ARG(ipcTerm,3,methodTerm);
    UNIFY_ATOM(methodTerm,STR2ATOM(FALSE,im->mArgs->method));

    INIT_TERM(argsTerm);
    GET_ARG(ipcTerm,4,argsTerm);

    /* ME_FRAMES */
    if(im->mArgs->type==IPC_ME_FRAMES) {
        INIT_LIST(argsTerm);
        INIT_TERM(framesTerm);
        GET_ARG(argsTerm,1,framesTerm);
        UNIFY_POINTER(framesTerm,im->mArgs->args.frames);
        if(im->mArgs->module) {
            INIT_TERM(tmpTerm);
            GET_ARG(argsTerm,2,tmpTerm);
            argsTerm=tmpTerm;
            INIT_LIST(argsTerm);
            INIT_TERM(modTerm);
            GET_ARG(argsTerm,1,modTerm);
            UNIFY_ATOM(modTerm,STR2ATOM(FALSE,im->mArgs->module));
        }
        INIT_TERM(tmpTerm);
        GET_ARG(argsTerm,2,tmpTerm);
        UNIFY_ATOM( tmpTerm, STR2ATOM(TRUE,"[]") );
        return 1;
    }

    /* ME_NOARGS */
    if(im->mArgs->type==IPC_ME_NOARGS) {
        UNIFY_ATOM(argsTerm, STR2ATOM(TRUE,"[]") );
        return 1;
    }

    /* ME_STRINGS (one string only), LPI_CALL */
    if(im->mArgs->type==IPC_ME_STRINGS &&
        (!strcmp(im->mArgs->method,"SET_MODULE_CONTEXT") || !strcmp(im->mArgs->method,"LPI_CALL"))) {
        INIT_LIST(argsTerm);
        INIT_TERM(tmpTerm);
        GET_ARG(argsTerm,1,tmpTerm);
        UNIFY_ATOM(tmpTerm,STR2ATOM(FALSE,im->mArgs->args.strings.strings[0]));
        INIT_TERM(tmpTerm);
        GET_ARG(argsTerm,2,tmpTerm);
        UNIFY_ATOM(tmpTerm, STR2ATOM(TRUE,"[]") );
        return 1;
    }

    /* ME_STRINGS (two strings) */
    if(im->mArgs->type==IPC_ME_STRINGS &&
        (!strcmp(im->mArgs->method,"NOTIFICATION_REQUEST") || !strcmp(im->mArgs->method,"ENROLL_ME"))) {
        INIT_LIST(argsTerm);
        INIT_TERM(tmpTerm);
        GET_ARG(argsTerm,1,tmpTerm);
        UNIFY_ATOM(tmpTerm,STR2ATOM(FALSE,im->mArgs->args.strings.strings[0]));
        INIT_TERM(tmpTerm);
        GET_ARG(argsTerm,2,tmpTerm);
        argsTerm=tmpTerm;
        INIT_LIST(argsTerm);
        INIT_TERM(tmpTerm);
        GET_ARG(argsTerm,1,tmpTerm);
        UNIFY_ATOM(tmpTerm,STR2ATOM(FALSE,im->mArgs->args.strings.strings[1]));
        if(im->mArgs->module) {
            INIT_TERM(tmpTerm);
            GET_ARG(argsTerm,2,tmpTerm);
            argsTerm=tmpTerm;
            INIT_LIST(argsTerm);
            INIT_TERM(modTerm);
            GET_ARG(argsTerm,1,modTerm);
            UNIFY_ATOM(modTerm,STR2ATOM(FALSE,im->mArgs->module));
        }
        INIT_TERM(tmpTerm);
        GET_ARG(argsTerm,2,tmpTerm);
        UNIFY_ATOM(tmpTerm, STR2ATOM(TRUE,"[]") );
        return 1;
    }

    /* ME_STRINGLIST */
    if(im->mArgs->type==IPC_ME_STRINGLIST) {
        INIT_LIST(argsTerm);
        INIT_TERM(listTerm);
        GET_ARG(argsTerm,1,listTerm);
        ipcStrList=im->mArgs->args.stringList;
        while(ipcStrList) {
            INIT_LIST(listTerm);
            INIT_TERM(tmpTerm);
            GET_ARG(listTerm,1,tmpTerm);
            UNIFY_ATOM(tmpTerm,STR2ATOM(FALSE,ipcStrList->string));
            ipcStrList=ipcStrList->next;
            INIT_TERM(tmpTerm);
            GET_ARG(listTerm,2,tmpTerm);
            listTerm=tmpTerm;
        }
        UNIFY_ATOM(listTerm, STR2ATOM(TRUE,"[]") );
        if(im->mArgs->module) {
            INIT_TERM(tmpTerm);
            GET_ARG(argsTerm,2,tmpTerm);
            argsTerm=tmpTerm;
            INIT_LIST(argsTerm);
            INIT_TERM(modTerm);
            GET_ARG(argsTerm,1,modTerm);
            UNIFY_ATOM(modTerm,STR2ATOM(FALSE,im->mArgs->module));
        }
        INIT_TERM(tmpTerm);
        GET_ARG(argsTerm,2,tmpTerm);
        UNIFY_ATOM(tmpTerm, STR2ATOM(TRUE,"[]") );
        return 1;
    }

    /* ME_OPTIPCID */
    if(!strcmp(im->mArgs->method,"STOP_SERVER") || !strcmp(im->mArgs->method,"NEXT_MESSAGE")) {
        if(im->mArgs->args.strings.strings[0]) {
            INIT_LIST(argsTerm);
            INIT_TERM(tmpTerm);
            GET_ARG(argsTerm,1,tmpTerm);
            UNIFY_ATOM(tmpTerm,STR2ATOM(FALSE,im->mArgs->args.strings.strings[0]));
            INIT_TERM(tmpTerm);
            GET_ARG(argsTerm,2,tmpTerm);
            UNIFY_ATOM(tmpTerm, STR2ATOM(TRUE,"[]") );
        }
        else {
            UNIFY_ATOM(argsTerm, STR2ATOM(TRUE,"[]") );
        }
        return 1;
    }

    /* ME_ASK */
    if(im->mArgs->type==IPC_ME_ASK) {
        INIT_LIST(argsTerm);

        /* Query Format */
        INIT_TERM(tmpTerm);
        GET_ARG(argsTerm,1,tmpTerm);
        if(im->mArgs->args.ask.query->type==IPC_FRAMES) {
            UNIFY_ATOM(tmpTerm,STR2ATOM(FALSE,"FRAMES"));
        }
        else {
            UNIFY_ATOM(tmpTerm,STR2ATOM(FALSE,"OBJNAMES"));
        }
        INIT_TERM(tmpTerm);
        GET_ARG(argsTerm,2,tmpTerm);
        argsTerm=tmpTerm;

        /* Query */
        INIT_LIST(argsTerm);
        INIT_TERM(tmpTerm);
        GET_ARG(argsTerm,1,tmpTerm);
        if(im->mArgs->args.ask.query->type==IPC_FRAMES) {
            UNIFY_POINTER(tmpTerm,im->mArgs->args.ask.query->frames);
        }
        else {
            UNIFY_POINTER(tmpTerm,im->mArgs->args.ask.query->objnames);
        }
        INIT_TERM(tmpTerm);
        GET_ARG(argsTerm,2,tmpTerm);
        argsTerm=tmpTerm;

        /* Answer Representation */
        INIT_LIST(argsTerm);
        INIT_TERM(tmpTerm);
        GET_ARG(argsTerm,1,tmpTerm);
        UNIFY_ATOM(tmpTerm,STR2ATOM(FALSE,im->mArgs->args.ask.ansrep));
        INIT_TERM(tmpTerm);
        GET_ARG(argsTerm,2,tmpTerm);
        argsTerm=tmpTerm;

        /* Rollback Time */
        INIT_LIST(argsTerm);
        INIT_TERM(tmpTerm);
        GET_ARG(argsTerm,1,tmpTerm);
        UNIFY_ATOM(tmpTerm,STR2ATOM(FALSE,im->mArgs->args.ask.rbtime));
        if(im->mArgs->module) {
            INIT_TERM(tmpTerm);
            GET_ARG(argsTerm,2,tmpTerm);
            argsTerm=tmpTerm;
            INIT_LIST(argsTerm);
            INIT_TERM(modTerm);
            GET_ARG(argsTerm,1,modTerm);
            UNIFY_ATOM(modTerm,STR2ATOM(FALSE,im->mArgs->module));
        }
        INIT_TERM(tmpTerm);
        GET_ARG(argsTerm,2,tmpTerm);
        UNIFY_ATOM(tmpTerm, STR2ATOM(TRUE,"[]") );
        return 1;
    }

    /* ME_HYPO_ASK */
    if(im->mArgs->type==IPC_ME_HYPO_ASK) {
        INIT_LIST(argsTerm);

        /* Objects */
        INIT_TERM(tmpTerm);
        GET_ARG(argsTerm,1,tmpTerm);
        UNIFY_POINTER(tmpTerm,im->mArgs->args.hypoAsk.objects);
        INIT_TERM(tmpTerm);
        GET_ARG(argsTerm,2,tmpTerm);
        argsTerm=tmpTerm;

        /* Query Format */
        INIT_LIST(argsTerm);
        INIT_TERM(tmpTerm);
        GET_ARG(argsTerm,1,tmpTerm);
        if(im->mArgs->args.hypoAsk.query->type==IPC_FRAMES) {
            UNIFY_ATOM(tmpTerm,STR2ATOM(FALSE,"FRAMES"));
        }
        else {
            UNIFY_ATOM(tmpTerm,STR2ATOM(FALSE,"OBJNAMES"));
        }
        INIT_TERM(tmpTerm);
        GET_ARG(argsTerm,2,tmpTerm);
        argsTerm=tmpTerm;

        /* Query */
        INIT_LIST(argsTerm);
        INIT_TERM(tmpTerm);
        GET_ARG(argsTerm,1,tmpTerm);
        if(im->mArgs->args.hypoAsk.query->type==IPC_FRAMES) {
            UNIFY_POINTER(tmpTerm,im->mArgs->args.hypoAsk.query->frames);
        }
        else {
            UNIFY_POINTER(tmpTerm,im->mArgs->args.hypoAsk.query->objnames);
        }
        INIT_TERM(tmpTerm);
        GET_ARG(argsTerm,2,tmpTerm);
        argsTerm=tmpTerm;

        /* Answer Representation */
        INIT_LIST(argsTerm);
        INIT_TERM(tmpTerm);
        GET_ARG(argsTerm,1,tmpTerm);
        UNIFY_ATOM(tmpTerm,STR2ATOM(FALSE,im->mArgs->args.hypoAsk.ansrep));
        INIT_TERM(tmpTerm);
        GET_ARG(argsTerm,2,tmpTerm);
        argsTerm=tmpTerm;

        /* Rollback Time */
        INIT_LIST(argsTerm);
        INIT_TERM(tmpTerm);
        GET_ARG(argsTerm,1,tmpTerm);
        UNIFY_ATOM(tmpTerm,STR2ATOM(FALSE,im->mArgs->args.hypoAsk.rbtime));
        if(im->mArgs->module) {
            INIT_TERM(tmpTerm);
            GET_ARG(argsTerm,2,tmpTerm);
            argsTerm=tmpTerm;
            INIT_LIST(argsTerm);
            INIT_TERM(modTerm);
            GET_ARG(argsTerm,1,modTerm);
            UNIFY_ATOM(modTerm,STR2ATOM(FALSE,im->mArgs->module));
        }
        INIT_TERM(tmpTerm);
        GET_ARG(argsTerm,2,tmpTerm);
        UNIFY_ATOM(tmpTerm, STR2ATOM(TRUE,"[]") );
        return 1;
    }

    return 0;

}
