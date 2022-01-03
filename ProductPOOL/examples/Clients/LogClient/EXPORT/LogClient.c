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
/* Since 9-Oct-2006, the ConceptBase server no longer writes entries into
   the log file OB.log. For this reason, the LogClient has become obsolete
   M. Jeusfeld, 9-Oct-2006
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <CBinterface.h>

#define MAX_CMD_LEN 20
#define MAX_FILES 20


/* Read a command and its argument from File fp. 
 * Memory for command and arg is allocated in the function
 * returns 0 if an error occured */
int readLogCommand(FILE *fp, char** pCmd, char** pArg) {
	
	char ch;
	int i,max;
	char* tmp;

	/* Allocate memory for command */
	*pCmd=(char*)malloc(sizeof(char)*MAX_CMD_LEN);
	i=0;
	
	/* Read command */
	while(!feof(fp) && fread(&ch,1,1,fp) && ch) {
		(*pCmd)[i]=ch;
		i++;
	}
	(*pCmd)[i]=0;
	
	/* Check for error */
	if (feof(fp) || ferror(fp)) {
		free (*pCmd);
		(*pCmd)=(*pArg)=NULL;
		return 0;
	}
	
	/* Allocate memory for argument */
	max=1024;
	(*pArg)=(char*) malloc(sizeof(char)*max);
	i=0;
	
	/* Read argument */
	while(!feof(fp) && fread(&ch,1,1,fp) && ch) {
		(*pArg)[i]=ch;
		i++;
		/* if memory limit is reached, double the allocated memory */
		if (i==max) {
			max=max*2;
			tmp=(char*) malloc(sizeof(char)*max);
			strncpy(tmp,*pArg,i);
			free(*pArg);
			(*pArg)=tmp;
		}
	}
	(*pArg)[i]=0;

	/* check for error */
	if (feof(fp) || ferror(fp)) {
		free (*pCmd);
		free (*pArg);
		(*pCmd)=(*pArg)=NULL;
		return 0;
	}
	
	return 1;
}


/* copies a comma-separated list of strings 
 * into a string array */
char** commaList2charArray(char *list) {
	
	char** files;
	char* s;
	char* tmp;
	int i,ende;
	
	/* Allocate memory for filelist */
	files=(char**) malloc(sizeof(char*)*MAX_FILES);
	tmp=strdup(list);
	
	/* initialize string */
	for(i=0;i<MAX_FILES;i++)
		files[i]=0;
	
	ende=0;
	i=0;
	s=tmp;
	
	/* copy strings to string array */
	while (!ende) {
		while((*tmp) && (*tmp)!=',') {
			tmp++;
		}
		if (!(*tmp))
			ende=1;
		
		(*tmp)=0;
		files[i]=strdup(s);
		i++;
		tmp++;
		s=tmp;
	}
	files[i]=NULL;
	
	return files;
	
}
	

int main(int argc,char* argv[]) {
	

	int PortNr,i;
	int trace,askuser;
	
	char ch;
	char* HostName;
	char* UserName;
	char* command;
	char* arg;
	char** files;
	Answer *ans;

	FILE* fp;

	Server *gserver;
	
	char   *ClientName  = "LogClient";

	
	/* Check command line arguments */
	if( argc < 4 ) {
		fprintf(stderr,"Usage: %s portnr host logfile [-t] [-a]\n",argv[0]);
		return 1;
	}

	/* Handle optional command line arguments */
	trace=0;
	askuser=0;
	for(i=0;i<argc;i++) {
		if (!strcmp(argv[i],"-t"))
			trace=1;
		if (!strcmp(argv[i],"-a"))
			askuser=1;
	}
	
	/* Get the port number from command line */
	PortNr=atoi(argv[1]);
	if (PortNr==0) {
		fprintf(stderr,"Usage: %s portnr host logfile [-t]\n",argv[0]);
		return 1;
	}
	
	/* Get hostname from command line */
	HostName=argv[2];

	/* Get username from environment */
	UserName=getenv("USER");
	if (!UserName)
		UserName="unknown";
	
	/* Open log file */
	fp=fopen(argv[3],"r");
	if (!fp) {
		fprintf(stderr,"Cannot open logfile: %s\n",argv[3]);
		return 1;
	}
		
	/* Connect to CBserver */
    connect_CB_server(PortNr, HostName, ClientName, UserName, &gserver);
	if (!gserver) {
		fprintf(stderr,"Connection failed!\n");
		return 1;
	}

	/* Read commands from logfile until end of file */
	while(readLogCommand(fp,&command,&arg)) {
		
		/* Ask user, if the command should be executed */
		if(askuser) {
			printf("Execute method %s with argument %s [y/n]?\n",command,arg);
			ch=getchar();
			while((ch!='\n') && (getchar()!='\n'));
			if (ch=='n')
				continue;
		}
		
		/* Tell */
		if (!strcmp(command,"tell")) {
			printf("Telling: %s \n\n",arg);
			ans=tellCB( gserver, arg );
		}
		
		/* Untell */
		if (!strcmp(command,"untell")) {
			printf("Untelling: %s \n\n",arg);
			ans=untell( gserver, arg );
		}
		
		/* Tell Model */
		if (!strcmp(command,"tell_model")) {
			printf("Loading models: %s \n\n",arg);
			files=commaList2charArray(arg);
			ans=tell_model( gserver, files );
			for(i=0;i<MAX_FILES;i++) {
				if (files[i])
					free(files[i]);
				free(files);
			}
		}
		
		/* Ask objnames */
		if (!strcmp(command,"ask_objnames")) {
			printf("Ask (OBJNAMES): %s \n\n",arg);
			ans=ask_objnames( gserver, arg, "LABEL","Now" );
			printf("Answer: %s\n\n", ans->return_data);
		}

		/* Ask frames */
		if (!strcmp(command,"ask_frames")) {
			printf("Ask (OBJNAMES): %s \n\n",arg);
			ans=ask_frames( gserver, arg, "LABEL","Now" );
			printf("Answer: %s\n\n", ans->return_data);
		}
		
		/* Check completion */
		if (ans && ans->completion) {
			fprintf(stderr,">>> Server reports error on method: %s(%s)\n\n",command,arg);
			/* disconnect_CB_server(gserver); */
			/* return 1; */
		}
		
		/* free memory for command and argument */
		if (arg)
			free(arg);
		if (command)
			free(command);
		
		/* Wait for user input, if necessary */
		if (trace) {
			printf("      Press return to continue...\n\n");
			getchar();
		}
	}

	/* Close logfile */
	fclose(fp);
	
	/* Close connection to CBserver */
	disconnect_CB_server(gserver);
	
	return 0;
		
}
	
	
	
