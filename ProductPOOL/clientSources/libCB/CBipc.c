/*
The ConceptBase.cc Copyright

Copyright 1987-2021 The ConceptBase Team. All rights reserved.

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

#include <stdlib.h>

#include "CBipc.h"
#include "CBdebug.h"


SOCKET open_socket(char* host, int port) {
	
	
	struct sockaddr_in inaddr;
	struct hostent *server;
	SOCKET fd;
	int buf;
	
#ifdef MSWindows
	WORD wVersionRequested;
	WSADATA wsadata;
	int dllstat;
	
	
	// Load WinSock DLL
	wVersionRequested=0x0101;

    dllstat = WSAStartup( wVersionRequested, &wsadata );
    if (dllstat) {
		CBdebug(5, "open_socket: No usable WINSOCK.DLL found\n" );
        exit(1);
	}
	else 
		if (LOBYTE( wsadata.wVersion) != 1 &&
			HIBYTE( wsadata.wVersion) != 1)  {
			CBdebug(5, "open_socket: WINSOCK.DLL does not support version 1.1\n" );
			WSACleanup();
			exit(1);
		}
#endif

	
	/* Get the Internet address */
	memset(&inaddr,0, sizeof(inaddr));
	server = gethostbyname (host);
	if (server == (struct hostent *) 0) {
		CBdebug(5,"open_socket: gethostbyname failed\n");
		return 0;
    }

	memcpy(&inaddr.sin_addr,server->h_addr,server->h_length);
	inaddr.sin_family = AF_INET;
	inaddr.sin_port = htons ((u_short) port);
	
	/* Open the socket */
	fd = socket (PF_INET, SOCK_STREAM, 0);
	#ifdef MSWindows
	  if (fd == INVALID_SOCKET)
	#else	  
	  if (fd < 0) 
    #endif
	 {
		 CBdebug(5, "open_socket: socket failed\n");
		 return 0;
	 }
	
	/* Try to connect to the open socket */
	if (connect (fd, (struct sockaddr *)&inaddr, sizeof(inaddr)) == 0) {
		CBdebug(10,"open_socket: Connected on Ipc Channel\n");
		/* Set the receive buffer to 64k */
		buf=65536;
		setsockopt(fd, SOL_SOCKET, SO_RCVBUF,(char *) &buf, sizeof(buf));
		return fd;
	}
	else {
		#ifdef MSWindows
		closesocket(fd);
		#else
		close(fd);
		#endif
		CBdebug(10,"open_socket: Ipc Connect failed!\n");
		return 0;
	}
}
	
	
int close_socket(SOCKET fd) {
	
#ifdef MSWindows
	return closesocket(fd);
#else
	return close(fd);
#endif
	
}




size_t read_socket(SOCKET fd,char* buf, size_t sz) {
	return recv(fd,buf,sz,0);
}


size_t write_socket(SOCKET fd,char* buf, size_t sz) {
	return send(fd,buf,sz,0);
}


int read_socket_with_timeout(SOCKET fd, char* buf,size_t len, int timeout) {
	
	unsigned int num=0;
	
	while ((num<len) && (input_pending(fd,timeout)>0)) {
		num+=read_socket(fd,&buf[num],len-num);
		buf[num]=0;
	}
		
	if(num<len) {
			CBdebug2(5,"read_socket_with_timeout: Got only %d instead of %d characters!\n",num,len);
			return 0;
	}
	else
		return 1;
	
}



char* read_string_until_timeout(SOCKET fd, int timeout) {
	
	int l,max,num;
	char *s1,*s2,c=1;
	
	max=1024;
	l=0;
	
	s1=(char*) malloc(max);
	num=read_socket(fd,&c,1);
	while(num && c && (c!=EOF) && (input_pending(fd,timeout)>0)) {
		s1[l]=c;
		num=read_socket(fd,&c,1);
		l++;
		if (l>=max)  { 
			max+=1024;
			s2=(char*) malloc(max);
			strncpy(s2,s1,l);
			free(s1);
			s1=s2;
		}
	}
	if (c==EOF) {
		s1[l]='\0';
		return s1;
	}
	else {
		CBdebug(5,"read_string_until_timeout: Connection timeout!\n");
		free(s1);
		return NULL;
	}
}



char* read_string_until_char_or_timeout(SOCKET fd,char ch,int timeout)  {
	

	int l,max,num=1;
	char *s1,*s2,c=ch+1;

	max=1024;
	l=0;
	
	s1=(char*) malloc(max);

	if (input_pending(fd,timeout)>0) {
		while((num==1) && (c!=ch) && (c!=EOF) && (input_pending(fd,timeout)>0))  {
			num=read_socket(fd,&c,1);
			s1[l]=c;
			l++;
			if (l>=max)  {
				max+=1024;
				s2=(char*) malloc(max);
				strncpy(s2,s1,l);
				free(s1);
				s1=s2;
			}
		}
	}
	else {
		free(s1);
		CBdebug(5,"read_string_until_char_or_timeout: Connection timeout\n");
		return NULL;
	}
	
	if (c==ch) {
		s1[l]='\0';
		return s1;
	}
	else {
		free(s1);
		CBdebug(5,"read_string_until_char_or_timeout: Connection broken\n");
		return NULL;
	}
}



int input_pending(SOCKET fd, unsigned int seconds) {
	
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
	
	if (r>=0)
		return r;
	else {
		CBdebug1(5,"input_pending: select returns %d!\n",r);
		return r;
	}
}

