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
/*   Hier: Unix-Version, entsprechende Windows-Funktionen  sind hier    */
/*   nur als dummy-Funktionen deklariert (damit das Linken klappt)      */
/*                                                                      */
/************************************************************************/

#include <sys/types.h>
#include <sys/stat.h>
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>

#include <sys/time.h>
#include <sys/resource.h>
#include <dirent.h>
#include <unistd.h>
#include <sys/param.h>

#if defined(__cplusplus)
extern "C" {
#endif

int UF_unlink( char *path ) {
   return( unlink(path) );
}

int UF_mkdir( char *path , mode_t mode ) {
    return mkdir(path, mode);
}

DIR* UF_opendir( char *dirname ) {
   return( opendir(dirname) );
}

struct dirent * UF_readdir( DIR *dirp ) {
    return readdir(dirp);
}

int UF_closedir( DIR *dirp ) {
   return( closedir(dirp) );
}




char* getFileNameFromDirEntry( struct dirent *de ) {
   return de->d_name;
}

#if defined(__cplusplus)
}
#endif


/**************************************************************************/
/* Dummy implementations for Windows Functions */

int Win_FindFirstFile(char* dirname, void* handlePtr, void* findDataPtr) {
	fprintf(stderr,"Call of Win_FindFirstFile in Unix!\n");
	return -1;
}

char* getFileNameFromFindData(void* findData) {
	fprintf(stderr,"Call of getFileNameFromFindData in Unix!\n");
	return NULL;
}

int Win_FindNextFile(void* hdlPtr, void* findDataPtr) {
	fprintf(stderr,"Call of Win_FindNextFile in Unix!\n");
	return -1;
}

void Win_FindClose(void* hdlPtr) {
	fprintf(stderr,"Call of Win_FindClose in Unix!\n");
}
