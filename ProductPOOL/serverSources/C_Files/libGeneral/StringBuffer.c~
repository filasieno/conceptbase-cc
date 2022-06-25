/*
The ConceptBase.cc Copyright

Copyright 1987-2022 The ConceptBase Team. All rights reserved.

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
#include <string.h>
#include <stdio.h>
#include <math.h>

#include "StringBuffer.h"

/*
void main(){
	printf("Beginn des StringBufferTest \n");
	StringBufferClass*  buffer=new StringBufferClass;
	StringBuffer* Test=buffer->initBuffer(1024);
	for(int i=0;i<300;i++){
		buffer->appendBuffer(Test,"Hallo Welt ");
		printf("Buffergr÷že : %i \n",Test->len);
		printf("Genutzer Speicher : %i \n",Test->used);
		//printf("BufferInhalt: %s \n",Test->content);
	}
	printf("BufferInhalt: %s \n",Test->content);
	buffer->deleteBuffer(Test);
}
*/


StringBuffer* initBuffer(int length) {
	StringBuffer* NewBuffer=malloc(sizeof(StringBuffer));
	NewBuffer->content=(char*) malloc(length);
	*(NewBuffer->content)=0; // terminating NULL char
	NewBuffer->len=length;
	NewBuffer->used=1;  // terminating NULL char takes 1 byte 
	NewBuffer->scale=length;
	return NewBuffer;
}

void appendBuffer(StringBuffer* buf,char* appStr) {
    int newsize,applen;
    applen=strlen(appStr);
	//check if enough space available
        //issue #38: keep security distance of at least 7 (?) to the buffer->len 
	if((applen+ buf->used) < buf->len - 7){
		strcat(buf->content,appStr);
		buf->used+=applen;
	}
	//increase buffer size
	else{
		//allocating scale more bytes if string buf->content+appStr string is too large for buf
		newsize= (buf->len)+(buf->scale);
		if(applen > (newsize -(buf->used))){
			newsize=(buf->len)+ applen;
		}
		buf->content= (char *) realloc(buf->content,newsize);
		strcat(buf->content,appStr);
		buf->len=newsize;
		buf->used+=strlen(appStr);
		//double scale for next increase; thus the buffer grows exponentially in terms of number of increase steps
		buf->scale=2*(buf->scale);
	}
//printf("(Used %d characters used in stringbuffer, real used %d)\n",buf->used,strlen(buf->content));
}


void prependBuffer(StringBuffer* buf, char* str) {
	int i,len;
	/* check if enough space available */
	len=strlen(str);
        //issue #38: keep security distance of at least 7 (?) to the buffer->len 
	if((len+ buf->used) >= buf->len - 7){
		//allocating scale more byte
		int newsize= (buf->len)+(buf->scale);
		if(len > (newsize -(buf->used))){
			newsize=(buf->len)+ len;
		}
		buf->content= (char *) realloc(buf->content,newsize);
		buf->len=newsize;
		buf->used+=strlen(str);
	}

	/* shift right existing string for len bytes */
	for(i=buf->used;i>=0;i--) {
		buf->content[i+len]=buf->content[i];
	}
	memcpy(buf->content,str,len);
}

void deleteBuffer(StringBuffer *buf) {
     if(buf->len>0) {
        buf->len=0;
        buf->used=0;
	if (buf->content != NULL) {
	   free(buf->content);
	}
	buf->content = NULL;
	if (buf != NULL) {
	   free(buf);
	}
	buf = NULL;
     }
}

char* getStringFromBuffer(StringBuffer* buf) {
	return buf->content;
}

int stringBufferCompare(StringBuffer* buf,char* cmp) {
    return strcmp(buf->content,cmp);
}

void displayAnswerOnTrace(StringBuffer* buf,int traceMode){
    char old;
	if( traceMode < 3 && buf->used>1000){
	    old=(buf->content)[1000];
	    (buf->content)[1000]='\0';
		printf("%s... (%d characters skipped)",buf->content,buf->used-1000);
		(buf->content)[1000]=old;
	}
	else
		printf("%s",buf->content);
//    printf("(%d characters used in stringbuffer of size %d)",buf->used,buf->len);
    fflush(stdout);

}

void replaceEmptyBuffer(StringBuffer* buf){
	if(strcmp(buf->content,"") == 0 || strcmp(buf->content,"no_definition") == 0 || strcmp(buf->content,"queryprocessing_failed")==0){
		char nilstring[]="nil";
		strncpy(buf->content,nilstring,3);
		(buf->content)[3]='\0';
	}
}

void replaceCharacterInBuffer(StringBuffer* buf, char* find, char* replacement) {

    char* s=buf->content;
    while(*s) {
        if(*s==*find) *s=*replacement;
        s++;
    }
}

/* getLengthFromBuffer returns the number of used chars in StringBuffer */
int getLengthFromBuffer(StringBuffer* buf) {
	return buf->used;
}

