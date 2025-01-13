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


/* File:  ipc.h
 *
 * Definitions for functions to communicate via an IPC channel
 */

#ifndef _IPC_H_
#define _IPC_H_

/* Linux */
#ifdef LINUX 
   #include <sys/types.h>
   #include <sys/time.h>

   #ifndef UNIX
      #define UNIX 1
   #endif
#endif

/* MacOS */
#ifdef MACOS 
   #include <sys/types.h>
   #include <sys/time.h>

   #ifndef UNIX
      #define UNIX 1
   #endif
#endif


/* Solaris 2.x */
#ifdef SOLARIS
   #include <sys/flock_impl.h>
   #ifndef UNIX
      #define UNIX 1
   #endif
#endif


/* MS Windows */
#ifdef WIN32
   #define MSWindows
   #include "winsock.h"
#endif


/* MS Visual C++ only */
#ifndef _MSC_VER
#include <unistd.h>
#endif


/* Common to all plattforms */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


/* Common to all UNIX plattforms */
#ifdef UNIX
   #include <sys/socket.h>
   #include <netinet/in.h>
   #include <sys/un.h>
   #include <netdb.h>
   #define SOCKET int
#endif



#ifdef  __cplusplus
extern "C" {
#endif

	/** Open a socket to the specified host and port.
	 * @param host the hostname
	 * @param port the portnumber
	 * @return file descriptor for the socket
	 * */
	SOCKET open_socket(char* host, int port);

	/** Close a socket.
	 * @param s file descriptor of the socket
	 * @return 0 if successfull
	 * */
	int close_socket(SOCKET s);

	/** Read characters from the socket.
	 * @param s the socket
	 * @param buf a buffer where the characters are stored
	 * @param sz the number of characters to read
	 * @return the number of characters read
	 * */
	size_t read_socket(SOCKET s, char* buf, size_t sz);

	/** Write characters to a socket.
	 * @param  s the socket
	 * @param buf a buffer where the characters are stored
	 * @param sz the number of characters to write
	 * @return the number of characters written
	 * */
	size_t write_socket(SOCKET s, char* buf, size_t sz);

	/** Read characters from socket until specified timeout is reached.
	 * @param s the socket
	 * @param buf a buffer where the characters are stored
	 * @param sz the number of characters to read
	 * @param timeout timeout in seconds
	 * @return 0 on error, 1 when successful
	 * @see read_socket
	 * */
	int read_socket_with_timeout(SOCKET s, char* buf, size_t sz,int timeout);

	/** Read a string from the socket until timeout is reached.
	 * @param s the socket
	 * @param timeout timeout in seconds
	 * @return the string
	 * */
	char* read_string_until_timeout(SOCKET s,int timeout);

	/** Read a string from the socket until timeout is reached or a specified
	 * character has been read.
	 * @param s the socket
	 * @param ch the character
	 * @param timeout timeout in seconds
	 * @return the string
	 * */
	char* read_string_until_char_or_timeout(SOCKET s,char ch, int timeout);

	/** Looks for input on the socket.
	 * @param s the socket
	 * @param seconds time to wait for input
	 * @return >0 if input is pending, 0 if no input, <0 on error
	 * */
	int input_pending(SOCKET s, unsigned int seconds);


#ifdef  __cplusplus
}
#endif

#endif
