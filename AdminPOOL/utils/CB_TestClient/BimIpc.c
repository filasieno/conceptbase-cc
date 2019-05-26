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

static char SccsID[]="@(#)CB_ipc.c	1.4\t2/27/91";

#include <sys/types.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <fcntl.h>
#include <netinet/in.h>
#include <netdb.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <errno.h>

#define LISTEN_QUEUE SOMAXCONN

extern int errno;


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

static error( errnr )
int errnr;
{
   BIM_Prolog_errormessage( "IPC Error : " );
   switch ( errnr )
   {
      case ERR_SOCKET_FAILED :
         BIM_Prolog_errormessage( "Socket creation failed.\n" );
         break;
      case ERR_BIND_FAILED :
         BIM_Prolog_errormessage( "Unable to bind socket to name.\n" );
         break;
      case ERR_LISTEN_FAILED :
         BIM_Prolog_errormessage( "Listen to socket failed.\n" );
         break;
      case ERR_UNBLOCK_FAILED :
         BIM_Prolog_errormessage( "Unable to unblock communication file.\n" );
         break;
      case ERR_CONNECT_FAILED :
         BIM_Prolog_errormessage( "Connect failed.\n" );
         break;
      case ERR_ACCEPT_FAILED :
         BIM_Prolog_errormessage( "Accept failed.\n" );
         break;
      case ERR_UNKNOWN_HOST :
         BIM_Prolog_errormessage( "Can't find host address.\n" );
         break;
      case ERR_SELECT_FAILED :
         BIM_Prolog_errormessage( "Select failed.\n" );
         break;
      default :
         BIM_Prolog_errormessage( "Unknown error.\n" );
         break;
   }

} /* error */


/************************************************************************/
/*
   Setup_service : A service is set up so that clients can connect to it.
   IN  : portnr = number of port to use for service
   OUT : service = service file descriptor
   RET : error code ( 0 = ok , >0 = error )
*/

int setup_service( portnr , service )
int portnr;
int *service;
{
   int serv;
   struct sockaddr_in addr;
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
      close( serv );
      return( 1 );
   }

   addr.sin_family = AF_INET;
   addr.sin_port =  htons((u_short)portnr);
   addr.sin_addr.s_addr = INADDR_ANY;
   if ( bind( serv , (struct sockaddr *)&addr , sizeof(addr) ) < 0 )
   {
      error( ERR_BIND_FAILED );
      close( serv );
      return( 2 );
   }

   if ( listen( serv , LISTEN_QUEUE ) < 0 )
   {
      error( ERR_LISTEN_FAILED );
      close( serv );
      return( 3 );
   }

   if ( ( flags = fcntl( serv , F_GETFL , 0 ) ) < 0 ||
        ( flags = fcntl( serv , F_SETFL , flags|O_NONBLOCK ) ) < 0 )
   {
      error( ERR_UNBLOCK_FAILED );
      close( serv );
      return( 4 );
   }

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

int accept_request( service , fd , inp , out )
int service;
int *fd;
FILE **inp, **out;
{
   struct sockaddr_in from;
   int fromlen;
   int connection;

   /* SE inserted for long messages */
   int buf = 32768;
   int buflen = 4;

   fromlen = sizeof(from);
   connection = accept( service , (struct sockaddr *)&from , &fromlen );
   if ( connection < 0 && errno == EWOULDBLOCK )
      return( -1 );
   if ( connection < 0 )
   {
      error( ERR_ACCEPT_FAILED );
      return( 1 );
   }

   /* SE inserted for long messages */
   setsockopt(connection, SOL_SOCKET, SO_SNDBUF, (char *) &buf, buflen);

   *fd = connection;
   *inp = fdopen( connection , "r" );
   *out = fdopen( connection , "w" );
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

int connect_service( portnr , hostname , fd , inp , out )
int portnr;
char *hostname;
int *fd;
FILE **inp, **out;
{
   struct hostent *hep;
   struct sockaddr_in addr;
   int connection;
   int flags;

   /* SE inserted for long messages */
   int buf = 32768;
   int buflen = 4;

   if ( ! ( hep = gethostbyname(hostname) ) )
   {
      error( ERR_UNKNOWN_HOST );
      return( 1 );
   }

   memset( &addr, 0, sizeof(addr) );
   memmove( &addr.sin_addr, hep->h_addr, hep->h_length );
#ifndef MACH_CP486
   addr.sin_family = hep->h_addrtype;
#else
   addr.sin_family = AF_INET;
#endif
   addr.sin_port = htons((u_short)portnr);
   if ( ( connection = socket( AF_INET , SOCK_STREAM , 0 ) ) < 0 )
   {
      error( ERR_SOCKET_FAILED );
      return( 2 );
   }

   if ( connect( connection , (struct sockaddr *)&addr , sizeof(addr) ) < 0 )
   {
      error( ERR_CONNECT_FAILED );
      close( connection );
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

shutdown_service( service, inp , out  )
int service;
FILE *inp, *out;
{
   if( inp ) fclose( inp );
   if( out ) fclose( out );
   shutdown( service, 2 ); /* MB: the 2. arg lacked; '2' means: discard all */
   close( service );

} /* shutdown_service */


/************************************************************************/
/*
   Select_input_0 : Indicated files are selected for input.  
   Blocks indefinitely if no input pending.
   IN  : rfds = requested file descriptors mask
   OUT : sfds = selected file descriptors mask
   RET : error code ( 0 = ok , >0 = error )
*/

int select_input_0( rfds , sfds )
int rfds;
int *sfds;
{
#ifdef MACH_CP486
   if ( Xselect(sizeof(int)*8,&rfds,0,0,0) == -1 )
#else
   if ( select(sizeof(int)*8,&rfds,0,0,0) == -1 )
#endif
   {
      error( ERR_SELECT_FAILED );
      return( errno );
   }
   *sfds = rfds;
   return( 0 );

} /* select_input_0 */


/************************************************************************/
/*
   Select_input_1 : Indicated files are selected for input.  
   Blocks for indicated timeout if no input pending.
   IN  : rfds = requested file descriptors mask
         timeout = timeout in seconds
   OUT : sfds = selected file descriptors mask
   RET : error code ( 0 = ok , >0 = error )
*/

int select_input_1( rfds , sfds , timeout )
int rfds;
int *sfds;
int timeout;
{
   struct timeval tv;

   tv.tv_sec = timeout;
   tv.tv_usec = 0;
#ifdef MACH_CP486
   if ( Xselect(sizeof(int)*8,&rfds,0,0,&tv) == -1 )
#else
   if ( select(sizeof(int)*8,&rfds,0,0,&tv) == -1 )
#endif
   {
      error( ERR_SELECT_FAILED );
      return( errno );
   }
   *sfds = rfds;
   return( 0 );

} /* select_input_1 */


/************************************************************************/
/*
   Input_pending : File is checked for pending input.  
   Blocks for indicated timeout if no input pending.
   IN  : fptr = requested file pointer
         timeout = timeout in seconds
   RET : code ( 0 = input pending , -1 = no input , >0 = error )
*/

int input_pending( fptr , timeout )
FILE *fptr;
int timeout;
{
   struct timeval tv;
   int fds;

   tv.tv_sec = timeout;
   tv.tv_usec = 0;
   if ( fptr->_cnt > 0 ) return( 0 );
   fds = 1 << fileno(fptr);
#ifdef MACH_CP486
   if ( Xselect(sizeof(int)*8,&fds,0,0,&tv) == -1 )
#else
   if ( select(sizeof(int)*8,&fds,0,0,&tv) == -1 )
#endif
   {
      error( ERR_SELECT_FAILED );
      return( errno );
   }
   return( ( fds ) ? 0 : -1 );

} /* input_pending */



char *read_text_file (char *fname)  {
    /* Liest Text aus einem File
     * Rueckgabe: Pointer auf Text-String
     * Parameter: Filename */

    int max,l;
    char *s1,*s2;
    FILE *f;

    max=1024;
    l=0;
    s1=(char *)malloc(max);
    f=fopen(fname,"r");
    if(f)  {
        while((s1[l]=getc((FILE *)f))!=EOF)  {
            l++;
            if (l>=max)  {
                max+=1024;
                s2=(char *)malloc(max);
                strncpy(s2,s1,l);
                free(s1);
                s1=s2;
            }
        }
        s1[l]='\0';
        fclose(f);
        return s1;
    }
    else
        return 0;
}


