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

/************************************************************************/
/*                                                                      */
/*   ProLog by BIM   UNIX File System Access/Manipulation               */
/*   Hier: Windows-Version, entsprechende Unix-Funktionen  sind hier    */
/*   nur als dummy-Funktionen deklariert (damit das Linken klappt)      */
/*                                                                      */
/************************************************************************/

#include <sys/types.h>
#include <sys/stat.h>
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>

#include <windows.h>
#include <direct.h>

#if defined(__cplusplus)
extern "C" {
#endif

int UF_unlink( char *path )
{
   return( unlink(path) );
}


int Win_FindFirstFile(char* dirname, HANDLE** handlePtr, WIN32_FIND_DATA** findDataPtr) {
	
	HANDLE *hdl=(HANDLE*)malloc(sizeof(HANDLE));
	WIN32_FIND_DATA *findData=(WIN32_FIND_DATA*)malloc(sizeof(WIN32_FIND_DATA));
	
	*hdl=FindFirstFile(dirname,findData);
	if((*hdl) == INVALID_HANDLE_VALUE) {
		fprintf(stderr,"Error while opening directory %s\n",dirname);
		return -1;
	}
	*handlePtr=hdl;
	*findDataPtr=findData;
	return 0;
		
}

char* getFileNameFromFindData(WIN32_FIND_DATA* findData) {
	return findData->cFileName;
}

int Win_FindNextFile(HANDLE* hdlPtr, WIN32_FIND_DATA** findDataPtr) {
	
	WIN32_FIND_DATA *findData=(WIN32_FIND_DATA*)malloc(sizeof(WIN32_FIND_DATA));

	if(FindNextFile(*hdlPtr,findData)) {
		*findDataPtr=findData;
		return 0;
	}
	// No more files found
	return -1;
}

void Win_FindClose(HANDLE* hdlPtr) {
	FindClose(*hdlPtr);
}

	
/************************************************************************/
/* Dummy definitions of Unix-Functions */
/************************************************************************/

void* UF_opendir( char *dirname ) {
   return NULL;
}

void* UF_readdir( void *dirp ) {
   return NULL;
}


int UF_closedir( void *dirp ) {
   return 0;
}

char* getFileNameFromDirEntry( void *de ) {
   return NULL;
}


#if defined(__cplusplus)
}
#endif
