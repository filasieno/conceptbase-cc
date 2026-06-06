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
* File:        FileIO.c
* Version:     1.4
* Creation:    22-Mar-1995 Christoph Quix (RWTH)
* Last change: 24 Mar 1995,  Christoph Quix (RWTH)
* Release:     1
* ----------------------------------------------------------- */
/* Description:
 * general functions for the CBserver
 *
 * Changes:
 *
*/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#ifdef _WIN32
  #include <winsock.h>
  #include <io.h>
#else
  #include <unistd.h>
  #include <sys/socket.h>
  #include <sys/time.h>
#endif

#include <errno.h>

/* #define DEBUG */
#ifdef DEBUG
#define debug(X) printf(X)
#define debug1(X,Y) printf(X,Y)
#define debug2(X,Y,Z) printf(X,Y,Z)
#else
#define debug(X)
#define debug1(X,Y)
#define debug2(X,Y,Z)
#endif

/* ------------------------------------------------------------*/
char *read_text_file (char *fname)  {
/* Reads text from a file.
 * Returns: pointer to text string
 * Args: file name */

	int max,l;
	char *s1,*s2;
	FILE *f;

	max=1024;
	l=0;
	s1=(char *)malloc(max);
	f=fopen(fname,"r");

	if (f)  {
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

/* ------------------------------------------------------------*/
char *concat_sml_string(char *s1, char *s2)  {
/* Concatenates two SML strings with a blank inserted between them.
 * Returns: new SML string
 * Args: two strings whose memory is freed */

	char *s3;
	int i,j;

	s3=(char *)malloc(strlen(s1)+strlen(s2)+3);

	for(i=0;s1[i];i++)
		s3[i]=s1[i];

	s3[i++]=' ';

	for(j=0;s2[j];j++)
		s3[i+j]=s2[j];

	s3[i+j]='\0';

	free(s1);
	free(s2);

	return s3;
}


/* ------------------------------------------------------------*/
/* FORWARD: (declared in BimIpc.c) */
int input_pending(int fd, int timeout);

/* ------------------------------------------------------------*/
char *ipc_read(int fd, int *len)  {
/* Reads characters from fd for as long as possible.
 * Returns: pointer to read text and text length (in *len)
 * Args: file descriptor */

	int l,max,wait,ret;
	char *s1,*s2;
	char c;
	unsigned char lenBytes[4];
	unsigned long lenToReceive;

	l=0;
	c=0;
	/* Read first byte: indicator for old or new format */
	while(l==0 && input_pending(fd,10)) {
		l=recv(fd,&c,1,0);
	    debug2("first while: %c,%d\n",c,l);
	}

    /* The first character after connect is sometimes EOF (related to Solaris 2.4)
	   or 0 (with SWI-Prolog); ignore it and read one more. */
	if (c==EOF || c==0) {
        debug("c==EOF or c==0\n");
		l=0;
		/* This while loop does not work under Linux.
		   Without input_pending it loops forever when a client crashes.
		   With input_pending it also fails because input_pending returns false
		   although input should still be available. The loop breaks with c=0 and
		   only garbage is read at the start. */
		/* while(l==0 && input_pending(fd,10)) {
			l=recv(fd,&c,1,0);
		} */
		/* New solution: if we read EOF or 0 at the beginning (only on connect),
		   read exactly one more character; that should be the real start of the IPC message. */
    	l=recv(fd,&c,1,0);
	}

	debug2("first char: %c %d\n",c,c);
	if(c!='X') {
		/* Old IPC message format without length prefix.
		 * Message is read character by character until no more input is available
         * and the probable end of the message (string ").\n") is seen. Problem:
         * if ").\n" appears inside the message, reading may stop too early. */
        debug("alte ipcmsg\n");
		max=1024;
		wait=10;
		s1=(char *)malloc(max);
		s1[0]=c;

		while(!input_pending(fd,wait))  {
			ret=recv(fd,&(s1[l]),1,0);
			/* old read methods: read(fd,&(s1[l]),1); */ /* s1[l]=getc(f); */
			debug2("ipc_read: %c,%d\n",s1[l],ret);
	 		if (s1[l]== '\n' && l>10 && s1[l-1]=='.' && s1[l-2]==')')
				wait=0;  /* Occasionally the CB server reads faster than the client writes.
						  * Usually one second wait is required. To avoid waiting a full second
						  * after every IPC message, no wait is applied when reading a line end.
						  * (").\n" normally terminates an IPC message) */
			else
				wait=10;

			if (ret<=0) {
				/* Tried to read although no input is available
				 * -> client has crashed */
				*len=0;
				return 0;
			}

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
		*len=l;
		return s1;
	}
	/* New method: the first four bytes give the message length. */
	debug("neue ipcmsg\n");
	l=0;
	wait=10;
	while(l<4 && !input_pending(fd,wait)) {
		ret=recv(fd,&(lenBytes[l]),4-l,0);
		if(ret<0) {
			*len=0;
			return 0;
		}
		l=l+ret;
	}
	lenToReceive=lenBytes[0]*256*256*256+lenBytes[1]*256*256+lenBytes[2]*256+lenBytes[3];
	debug1("lenToReceive: %ld\n", lenToReceive);
	l=0;
	s1=(char*) malloc(lenToReceive+1);
	while((unsigned long)l < lenToReceive && !input_pending(fd,wait)) {
		ret=recv(fd,s1+l,lenToReceive-l,0);
		debug1("received %d bytes\n",ret);
		if(ret<0) {
			*len=0;
			return 0;
		}
		l=l+ret;
	}
	s1[l]='\0';
	*len=lenToReceive;
	return s1;
}

/* Checks whether writing to the given socket is possible.
 * If not, waits up to the given number of seconds until it is (>0),
 * or aborts (<=0). */
int write_possible(int fd, unsigned int seconds) {

        fd_set set;
        struct timeval timeout;

        /* Initialize the file descriptor set. */
        FD_ZERO (&set);
        FD_SET (fd, &set);

        /* Initialize the timeout data structure. */
        timeout.tv_sec = seconds;
        timeout.tv_usec = 0;

        /* `select' returns 0 if timeout, 1 if input available, -1 if error. */
        return select (FD_SETSIZE,
				  NULL, &set, NULL,
				  &timeout);

}

/* Send IPC answer.
 * Normal fputs/write sometimes fails when the answer is very long. Therefore
 * before sending check whether writing is possible (write_possible) and retry
 * until the message has been sent completely. */
int ipc_write(int fd, char* ans) {

	int slen,ret;
	char bufLen[20];
	int len=strlen(ans);

	slen=0;

	/* Send message length first */
	sprintf(bufLen,"%d\n",len);
	send(fd,bufLen,strlen(bufLen),0);

	while(slen<len) {
		if(write_possible(fd,10)>0) {
			ret=send(fd,ans+slen,len-slen,0);
			if(ret>0)
				slen+=ret;
			else {
				perror("IPC interface");
				if (errno!=EAGAIN) { /* only retry when "resource temporarily unavailable" */
					return -1;
				}
				else
					fprintf(stderr,"Trying again!\n");
			}
			/* printf("send: %d errno:%d\n",slen,errno); */
		}
		else {
			fprintf(stderr,"Client not ready for reading answer!\n");
			return -1;
		}
	}

	if (slen==len)  {
		/* send terminating NEWLINE */
		send(fd,"\n",1,0);
		return len;
	}
	else
		return -1;
}
