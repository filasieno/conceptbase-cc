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
/* Konkateniert zwei SML-Strings mit dazwischengefuegtem Blank
 * Rueckgabe: neuer SML-String
 * Parameter: zwei Strings, deren Speicher freigeben wird */

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
/* Liest Zeichen von f solange wie moeglich
 * Rueckgabe: Pointer auf eingelesen Text und
 *            Laenge des Texts (in *len)
 * Parameter: Filepointer */

	int l,max,wait,ret;
	char *s1,*s2;
	char c;
	unsigned char lenBytes[4];
	unsigned long lenToReceive;

	l=0;
	c=0;
	/* Lese erstes Byte: Indikator fuer altes oder neues Format */
	while(l==0 && input_pending(fd,10)) {
		l=recv(fd,&c,1,0);
	    debug2("first while: %c,%d\n",c,l);
	}

    /* Das erste Zeichen nach dem Connect ist manchmal EOF (haengt irgendwie mit Solaris 2.4 zusammen),
	   (oder auch 0, bei SWI-Prolog), deshalb ignoriere dieses Zeichen und lese noch eins. */
	if (c==EOF || c==0) {
        debug("c==EOF or c==0\n");
		l=0;
		/* Diese while-Schleife funktioniert nicht unter Linux.
		   Ohne input_pending führt das zu Endlosschleife beim Absturz eines Clients.
		   Mit input_pending geht es auch nicht, da input_pending scheitert, obwohl
		   eigentlich noch Input da sein sollte. D.h. Schleife bricht ab, c=0 und
		   am Anfang wird nur Müll gelesen. */
		/* while(l==0 && input_pending(fd,10)) {
			l=recv(fd,&c,1,0);
		} */
		/* Neue Lösung: Wenn wir EOF oder 0 am Anfang lesen (kommt nur beim Connect vor),
		   dann lesen wir noch ein (genau 1!) Zeichen, und das sollte dann der wirkliche
		   Beginn der ipcmsg sein. */
    	l=recv(fd,&c,1,0);
	}

	debug2("first char: %c %d\n",c,c);
	if(c!='X') {
		/* altes Format der IPC-Message ohne Laenge
		 * Message wird Zeichen fuer Zeichen gelesen, solange bis kein
         * Input mehr da ist und das wahrscheinliche Ende der Nachricht
         * (Zeichenfolge ").\n" ist ein Indiz) erkannt wird. Problem ist,
         * ").\n" zufaellig irgendwo innerhalb der Nachricht vorkommt, dann
         * kann das Lesen schon mal zu frueh abgebrochen werden. */
        debug("alte ipcmsg\n");
		max=1024;
		wait=10;
		s1=(char *)malloc(max);
		s1[0]=c;

		while(!input_pending(fd,wait))  {
			ret=recv(fd,&(s1[l]),1,0);
			/* alte Methoden zum Lesen:read(fd,&(s1[l]),1);*/ /* s1[l]=getc(f); */
			debug2("ipc_read: %c,%d\n",s1[l],ret);
	 		if (s1[l]== '\n' && l>10 && s1[l-1]=='.' && s1[l-2]==')')
				wait=0;  /* Gelegentlich liest der CBserver die Zeichen schneller ein als die Zeichen
						  * vom Client geschrieben werden. Deshalb ist i.A. eine Sekunde Wartezeit
						  * erforderlich. Damit aber nicht nach jeder IPC-Message
						  * eine Sekunde gewartet werden muss, wird beim lesen von einem Zeilenende
						  * nicht gewartet. (").\n" schliesst normalerweise ein IPC-Message ab) */
			else
				wait=10;

			if (ret<=0) {
				/* Es soll gelesen werden, obwohl kein Input da ist
				 * -> Client wird abgeschossen */
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
	/* Neue Methode: die ersten vier Bytes geben die Laenge der Nachricht an. */
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
	while(l<lenToReceive && !input_pending(fd,wait)) {
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

/* Ueberprueft, ob schreiben auf angebenem Socket moeglich ist.
 * Falls nicht, wird einige Sekunden gewartet bis es moeglich ist (Rueckgabe >0),
 * oder abgebrochen (Rueckgabe <=0 )*/
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

/* IPC Answer ausgeben
 * normales fputs/write schlaegt manchmal fehl, wenn
 * Antwort sehr lang ist. Daher vor dem Senden der Nachricht
 * kontrollieren, ob Schreiben moeglich ist (write_possible)
 * und ggf. mehrere Sendeversuche machen,
 * bis Nachricht komplett ruebergeschickt wurde. */
int ipc_write(int fd, char* ans) {

	int slen,ret;
	char bufLen[20];
	int len=strlen(ans);

	slen=0;

	/* Laenge der Nachricht zuerst senden */
	sprintf(bufLen,"%d\n",len);
	send(fd,bufLen,strlen(bufLen),0);

	while(slen<len) {
		if(write_possible(fd,10)>0) {
			ret=send(fd,ans+slen,len-slen,0);
			if(ret>0)
				slen+=ret;
			else {
				perror("IPC interface");
				if (errno!=EAGAIN) { /* Versuch nur dann wiederholen, wenn "resource temporarily unavailable" */
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
		/* abschliessendes NEWLINE senden */
		send(fd,"\n",1,0);
		return len;
	}
	else
		return -1;
}
