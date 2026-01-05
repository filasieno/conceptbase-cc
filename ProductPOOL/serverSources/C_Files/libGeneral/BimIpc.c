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
* File:        BimIpc.c
* Version:     1.3
* Creation:    27-Feb-1991, Manfred Jeusfeld (UPA)
* Last Change: 4/22/92, Martin Staudt (RWTH)
* Release:     1
* -----------------------------------------------------------------------------
*
* This C module is part of the ConceptBase system which is a run-time
* system for the System Modelling Language (SML).
* Actually, it is a corrected version of $BIM_PROLOG_DIR/src/ipc.c
*
********* History *******
* 26.2.91   MB
*   they didn't used htons() (man byteorder), so it doesn't work on systems
*   with a different byteorder (e.g. some VAX)
*   changed this in connect_service and setup_service
* 27.2.91 MB
*   also shutdown (in shutdown_service) needs TWO arguments;
*   added the second
* 24.04.91 SE
*    added setsockopt for handling long messages
* 18.01.94 RG
*    shutdown_service closes the streams explicitly
*/



/************************************************************************/
/*                                                                      */
/*   BIM_Prolog Inter Process Communication Package                     */
/*                                                                      */
/*   Author :  Alain Callebaut                                          */
/*             Katholieke Universiteit Leuven                           */
/*             Department of Computer Science                           */
/*             Celestijnenlaan 200A                                     */
/*             B-3030 HEVERLEE                                          */
/*                                                                      */
/*   Date :     1-Jun-1987                                              */
/*   Changed : 27.2.1991 M.Baumeister                                   */
/*                                                                      */
/************************************************************************/

#include <sys/types.h>
#include <fcntl.h>

#ifdef _WIN32
  #include <winsock.h>
  #include <io.h>
#else
  #include <sys/time.h>
  #include <sys/socket.h>
  #include <netinet/in.h>
  #include <netdb.h>
  #include <unistd.h>
#endif

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>

#include <string.h>

#ifdef BIM
#include "BPextern.h"
#define PROLOG_ERRMSG(A) BIM_Prolog_errormessage(A)
#else
#define PROLOG_ERRMSG(A) fprintf(stderr,A)
#endif

#define LISTEN_QUEUE SOMAXCONN



/************************************************************************/
/*
Error messages
*/

#define ERR_SOCKET_FAILED 1
#define ERR_BIND_FAILED 2
#define ERR_LISTEN_FAILED 3
#define ERR_UNBLOCK_FAILED 4
#define ERR_ACCEPT_FAILED 5
#define ERR_CONNECT_FAILED 6
#define ERR_UNKNOWN_HOST 7
#define ERR_SELECT_FAILED 8

static void error( int errnr )
{
	PROLOG_ERRMSG( "IPC Error : " );
	switch ( errnr )
	{
	case ERR_SOCKET_FAILED :
		PROLOG_ERRMSG( "Socket creation failed.\n" );
		break;
	case ERR_BIND_FAILED :
		PROLOG_ERRMSG( "Unable to bind socket to name.\n" );
		break;
	case ERR_LISTEN_FAILED :
		PROLOG_ERRMSG( "Listen to socket failed.\n" );
		break;
	case ERR_UNBLOCK_FAILED :
		PROLOG_ERRMSG( "Unable to unblock communication file.\n" );
		break;
	case ERR_CONNECT_FAILED :
		PROLOG_ERRMSG( "Connect failed.\n" );
		break;
	case ERR_ACCEPT_FAILED :
		PROLOG_ERRMSG( "Accept failed.\n" );
		break;
	case ERR_UNKNOWN_HOST :
		PROLOG_ERRMSG( "Can't find host address.\n" );
		break;
	case ERR_SELECT_FAILED :
		PROLOG_ERRMSG( "Select failed.\n" );
		break;
	default :
		PROLOG_ERRMSG( "Unknown error.\n" );
		break;
	}

} /* error */


void loadWinSock() {
#ifdef _WIN32
    /* setup winsock library */
	WORD wVersionRequested;
	WSADATA wsadata;
	int dllstat;

	// Load WinSock DLL
	wVersionRequested=MAKEWORD( 1, 1 );


    dllstat = WSAStartup( wVersionRequested, &wsadata );
    if (dllstat) {
		fprintf(stderr, "open_socket: No usable WINSOCK.DLL found\n" );
        exit(1);
	}
	else
		if (LOBYTE( wsadata.wVersion) != 1 &&
			HIBYTE( wsadata.wVersion) != 1)  {
			fprintf(stderr, "open_socket: WINSOCK.DLL does not support version 1.1\n" );
			WSACleanup();
			exit(1);
		}
#endif
}


/************************************************************************/
/*
Setup_service : A service is set up so that clients can connect to it.
IN  : portnr = number of port to use for service
OUT : service = service file descriptor
RET : error code ( 0 = ok , >0 = error )
*/

int setup_service( int portnr , int *service )
{
	int serv;
	struct sockaddr_in addr;
#ifdef _WIN32
	long lFlag;
#endif
	int flags = 1;


	if ( ( serv = socket( AF_INET , SOCK_STREAM , 0 ) ) < 0 )
	{
		error( ERR_SOCKET_FAILED );
		return( 1 );
	}

	/* 2.3.93 RG flags must be 'TRUE' to enable reuse of address */
	/* this avoids the fail of a listen or bind on an already used socket */
	if( setsockopt(serv, SOL_SOCKET, SO_REUSEADDR, (char *) &flags, sizeof(flags)) )
	{
		error( ERR_SOCKET_FAILED );
#ifdef _WIN32
		closesocket( serv );
#else
		close( serv );
#endif
		return( 1 );
	}

	addr.sin_family = AF_INET;
	addr.sin_port =  htons((u_short)portnr);
	addr.sin_addr.s_addr = INADDR_ANY;
	if ( bind( serv , (struct sockaddr *)&addr , sizeof(addr) ) < 0 )
	{
		error( ERR_BIND_FAILED );
#ifdef _WIN32
		closesocket( serv );
#else
		close( serv );
#endif
		return( 2 );
	}

	if ( listen( serv , LISTEN_QUEUE ) < 0 )
	{
		error( ERR_LISTEN_FAILED );
#ifdef _WIN32
		closesocket( serv );
#else
		close( serv );
#endif
		return( 3 );
	}

#ifndef _WIN32
	if ( ( flags = fcntl( serv , F_GETFL , 0 ) ) < 0 ||
        ( flags = fcntl( serv , F_SETFL , flags|O_NONBLOCK ) ) < 0 )
	{
		error( ERR_UNBLOCK_FAILED );
		close( serv );
		return( 4 );
	}
#else
	lFlag=1;
	if(ioctlsocket(serv,FIONBIO,&lFlag)) {
		error( ERR_UNBLOCK_FAILED );
		closesocket( serv );
		return 4;
	}
#endif
	*service = serv;
	return( 0 );

} /* setup_service */


/************************************************************************/
/*
Accept_request : If request from a client is present, it is accepted.
IN  : service = service file descriptor
OUT : fd = file descriptor
inp = input file pointer
out = output file pointer
RET : error code ( -1 = no request , 0 = request accepted , >0 = error )
*/

int accept_request( int service , int *fd , FILE **inp , FILE **out )
{
	struct sockaddr_in from;
	unsigned int fromlen;
	int connection;

	/* SE inserted for long messages */
	int buf = 65536*4-1; /* 256kb scheint der groesst moegliche Wert hier zu sein */
	int buflen = sizeof(buf);

	fromlen = sizeof(from);
	connection = accept( service , (struct sockaddr *)&from , &fromlen );
#ifdef _WIN32
	if ( connection < 0 && errno == WSAEWOULDBLOCK )
#else
		if ( connection < 0 && errno == EWOULDBLOCK )
#endif
			return( -1 );
		if ( connection < 0 )
		{
			error( ERR_ACCEPT_FAILED );
			return( 1 );
		}

		/* SE inserted for long messages */
		setsockopt(connection, SOL_SOCKET, SO_SNDBUF, (char *) &buf, buflen);

		*fd = connection;
#ifdef _WIN32
		connection=_open_osfhandle(connection,0);
#endif
		*inp = fdopen( connection , "rb" );
		*out = fdopen( connection , "wb" );
		return( 0 );

} /* accept_request */


/************************************************************************/
/*
Connect_service : A connection to a service is established.
IN  : portnr = number of port to use for service
hostname = name of the host on which the service runs
OUT : fd = file descriptor
inp = input file pointer
out = output file pointer
RET : error code ( -1 = no service , 0 = connected , >0 = error )
*/

int connect_service( int portnr , char* hostname , int *fd , FILE **inp , FILE **out )
{
	struct hostent *hep;
	struct sockaddr_in addr;
	int connection;

	/* SE inserted for long messages */
	int buf = 65536*4-1; /* 256kb scheint der groesst moegliche Wert hier zu sein */
	int buflen = sizeof(buf);

	if ( ! ( hep = gethostbyname(hostname) ) )
	{
		error( ERR_UNKNOWN_HOST );
		return( 1 );
	}

	memset( &addr, 0, sizeof(addr) );
	memmove( &addr.sin_addr, hep->h_addr, hep->h_length );
	addr.sin_family = AF_INET;
	addr.sin_port = htons((u_short)portnr);
	if ( ( connection = socket( AF_INET , SOCK_STREAM , 0 ) ) < 0 )
	{
		error( ERR_SOCKET_FAILED );
		return( 2 );
	}

	if ( connect( connection , (struct sockaddr *)&addr , sizeof(addr) ) < 0 )
	{
		error( ERR_CONNECT_FAILED );
#ifdef _WIN32
		closesocket( connection );
#else
		close( connection );
#endif
		return( -1 );
	}
	/*
	if ( ( flags = fcntl( connection , F_GETFL , 0 ) ) < 0 ||
	( flags = fcntl( connection , F_SETFL , flags|FNDELAY ) ) < 0 )
	{
	error( ERR_UNBLOCK_FAILED );
	close( connection );
	return( 3 );
	}
	*/

	/* SE inserted for long messages */
	setsockopt(connection, SOL_SOCKET, SO_RCVBUF, (char *) &buf, buflen);

	*fd = connection;
	*inp = fdopen( connection , "r" );
	*out = fdopen( connection , "w" );
	return( 0 );

} /* connect_service */


/************************************************************************/
/*
Shutdown_service : The service is terminated.
IN  : service = service file descriptor
inp, out = streams to close explicitly ( 18.01.94 RG )
*/

void shutdown_service( int service, FILE *inp , FILE *out  )
{
	if( inp ) fclose( inp );
	if( out ) fclose( out );
	shutdown( service, 2 ); /* MB: the 2. arg lacked; '2' means: discard all */
#ifdef _WIN32
	closesocket( service );
#else
	close( service );
#endif

} /* shutdown_service */


/************************************************************************/
/*
Select_input_0 : Indicated files are selected for input.
Blocks indefinitely if no input pending.
IN  : rfds = array of file descriptors
      len = length of array
OUT : resfd = file descriptor ready for reading
RET : error code ( 0 = ok , >0 = error )
*/

int select_input_n( int* rfds , int len, int *resfd ) {
	fd_set set;
	int i,res,max;

    /* Initialize the file descriptor set. */
    FD_ZERO (&set);
    max=0;
    for(i=0;i<len;i++) {
		FD_SET (rfds[i], &set);
		if(rfds[i]>max)
			max=rfds[i];
	}

	if ( select(max+1,&set,0,0,NULL) == -1 ) {
		error( ERR_SELECT_FAILED );
		return( errno );
	}

	res=0;
	for(i=0;i<len;i++) {
		if(FD_ISSET(rfds[i],&set)) {
			*resfd=rfds[i];
			return 0;
		}
   	}
	fprintf(stderr,"WARNING: select returns without a fd\n");
	return( 0 );

} /* select_input_0 */


/************************************************************************/
/*
Input_pending : File is checked for pending input.
Blocks for indicated timeout if no input pending.
IN  : fptr = requested file pointer
timeout = timeout in seconds
RET : code ( 0 = input pending , -1 = no input , >0 = error )
*/


int input_pending(int fd, unsigned int seconds) {

    fd_set set;
    struct timeval timeout;
    int r;

    /* Initialize the file descriptor set. */
    FD_ZERO (&set);
    FD_SET (fd, &set);

    /* Initialize the timeout data structure. */
    timeout.tv_sec = seconds;
    timeout.tv_usec = 0;

    /* `select' returns 0 if timeout, 1 if input available, -1 if error. */
    r=select (FD_SETSIZE,
		&set, NULL, NULL,
		&timeout);

    if (r<0) {
        fprintf(stderr,"input_pending: select returns %d!\n",r);
        return( errno );
    }
    else if(r==0) {
		return -1;
    }
    else {
		return 0;
	}
}


