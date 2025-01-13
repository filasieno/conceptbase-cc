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

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SWI-Prolog.h"

#include "prolog.h"

#include "unixToProlog.h"
#include "StringBuffer.h"
#include "TermCache.h"


foreign_t swi_getpid(term_t retterm) {

    int ret;

    ret=getpid();

    if(!PL_unify_integer(retterm,ret))
        PL_fail;
    PL_succeed;
}

foreign_t swi_strdup(term_t retterm, term_t pterm) {

    char* ret;
    char* p;

    if(!PL_is_integer(pterm))
        PL_fail;

    PL_get_pointer(pterm,(void**)&p);
    ret=strdup(p);

    if(!PL_unify_pointer(retterm,ret))
        PL_fail;
    PL_succeed;
}


foreign_t swi_systemclock(term_t yearterm, term_t monthterm, term_t dayterm, term_t hourterm, term_t minterm, term_t secterm, term_t msecterm) {

    int sec,min,hour,day,month,year;
    long msec;

    systemclock(&year,&month,&day,&hour,&min,&sec,&msec);

    if(PL_unify_integer(yearterm,year) &&
        PL_unify_integer(monthterm,month) &&
        PL_unify_integer(dayterm,day) &&
        PL_unify_integer(hourterm,hour) &&
        PL_unify_integer(minterm,min) &&
        PL_unify_integer(secterm,sec) &&
        PL_unify_integer(msecterm,msec))
        PL_succeed;
    PL_fail;
}

foreign_t swi_sleepsec(term_t secterm) {

    int sec;

    if(!PL_is_integer(secterm))
        PL_fail;

    PL_get_integer(secterm,&sec);

    sleepsec(sec);

    PL_succeed;

}

foreign_t swi_username(term_t uterm) {

    char* user;

    username(&user);

    if(user && PL_unify_atom_chars(uterm,user))
        PL_succeed;
    PL_fail;
}

foreign_t swi_hostname(term_t hterm) {

    char* host;

    hostname(&host);

    if(host && PL_unify_atom_chars(hterm,host))
        PL_succeed;
    PL_fail;
}

foreign_t swi_memfree(term_t pterm) {

    void* p;

    if(!PL_is_integer(pterm))
        PL_fail;

    PL_get_pointer(pterm,(void**)&p);
    memfree(p);
    PL_succeed;
}


foreign_t swi_sec_time(term_t retterm) {

    int ret;

    ret=sec_time();

    if(PL_unify_integer(retterm,ret))
        PL_succeed;
    PL_fail;
}

foreign_t swi_initBuffer(term_t retterm, term_t lenterm) {

    int len;
    StringBuffer* ret;

    if(!PL_is_integer(lenterm))
        PL_fail;

    PL_get_integer(lenterm,&len);

    ret=initBuffer(len);

    if(PL_unify_pointer(retterm,ret))
        PL_succeed;
    PL_fail;
}

foreign_t swi_appendBuffer(term_t sbterm, term_t atomterm) {

    StringBuffer* sb;
    char* atom;

    if(!PL_is_integer(sbterm) || !PL_is_atom(atomterm))
        PL_fail;

    PL_get_pointer(sbterm,(void**)&sb);
    PL_get_atom_chars(atomterm,&atom);

    appendBuffer(sb,atom);
    PL_succeed;
}

foreign_t swi_prependBuffer(term_t sbterm, term_t atomterm) {

    StringBuffer* sb;
    char* atom;

    if(!PL_is_integer(sbterm) || !PL_is_atom(atomterm))
        PL_fail;

    PL_get_pointer(sbterm,(void**)&sb);
    PL_get_atom_chars(atomterm,&atom);

    prependBuffer(sb,atom);
    PL_succeed;
}

foreign_t swi_appendBufferP(term_t sbterm, term_t pterm) {

    StringBuffer* sb;
    char* p;

    if(!PL_is_integer(sbterm) || !PL_is_integer(pterm))
        PL_fail;

    PL_get_pointer(sbterm,(void**)&sb);
    PL_get_pointer(pterm,(void**)&p);

    appendBuffer(sb,p);
    PL_succeed;
}

foreign_t swi_prependBufferP(term_t sbterm, term_t pterm) {

    StringBuffer* sb;
    char* p;

    if(!PL_is_integer(sbterm) || !PL_is_integer(pterm))
        PL_fail;

    PL_get_pointer(sbterm,(void**)&sb);
    PL_get_pointer(pterm,(void**)&p);

    prependBuffer(sb,p);
    PL_succeed;
}

foreign_t swi_deleteBuffer(term_t sbterm) {

    StringBuffer* sb;

    if(!PL_is_integer(sbterm))
        PL_fail;

    PL_get_pointer(sbterm,(void**)&sb);

    deleteBuffer(sb);
    PL_succeed;
}

foreign_t swi_getStringFromBuffer(term_t retterm, term_t sbterm) {

    StringBuffer* sb;
    char* ret;

    if(!PL_is_integer(sbterm))
        PL_fail;

    PL_get_pointer(sbterm,(void**)&sb);

    ret=getStringFromBuffer(sb);
    if(ret && PL_unify_atom_chars(retterm,ret))
        PL_succeed;
    PL_fail;
}

foreign_t swi_getPointerFromBuffer(term_t retterm, term_t sbterm) {

    StringBuffer* sb;
    char* ret;

    if(!PL_is_integer(sbterm))
        PL_fail;

    PL_get_pointer(sbterm,(void**)&sb);

    ret=getStringFromBuffer(sb);
    if(PL_unify_pointer(retterm,ret))
        PL_succeed;
    PL_fail;
}


foreign_t swi_stringBufferCompare(term_t retterm, term_t sbterm, term_t cmpterm) {

    StringBuffer* sb;
    char* cmp;
    int ret;

    if(!PL_is_integer(sbterm) || !PL_is_atom(cmpterm))
        PL_fail;

    PL_get_pointer(sbterm,(void**)&sb);
    PL_get_atom_chars(cmpterm,&cmp);

    ret=stringBufferCompare(sb,cmp);
    if(PL_unify_integer(retterm,ret))
        PL_succeed;
    PL_fail;
}

foreign_t swi_displayAnswerOnTrace(term_t sbterm, term_t lenterm) {

    StringBuffer* sb;
    int len;

    if(!PL_is_integer(sbterm) || !PL_is_integer(lenterm))
        PL_fail;

    PL_get_pointer(sbterm,(void**)&sb);
    PL_get_integer(lenterm,&len);

    displayAnswerOnTrace(sb,len);
    PL_succeed;
}

foreign_t swi_replaceEmptyBuffer(term_t sbterm) {

    StringBuffer* sb;
    if(!PL_is_integer(sbterm))
        PL_fail;

    PL_get_pointer(sbterm,(void**)&sb);

    replaceEmptyBuffer(sb);
    PL_succeed;
}

foreign_t swi_replaceCharacterInBuffer(term_t sbterm, term_t find, term_t replacement) {

    StringBuffer* sb;
    char* f;
    char* r;

    if(!PL_is_integer(sbterm) || !PL_is_atom(find) || !PL_is_atom(replacement))
        PL_fail;

    PL_get_pointer(sbterm,(void**)&sb);
    PL_get_atom_chars(find,&f);
    PL_get_atom_chars(replacement,&r);

    replaceCharacterInBuffer(sb,f,r);
    PL_succeed;
}


foreign_t swi_getLengthFromBuffer(term_t retterm, term_t sbterm) {

    StringBuffer* sb;
    int ret;

    if(!PL_is_integer(sbterm))
        PL_fail;

    PL_get_pointer(sbterm,(void**)&sb);

    ret=getLengthFromBuffer(sb);
    if(ret && PL_unify_atom_chars(retterm,ret))
        PL_succeed;
    PL_fail;
}

/* Forward declarations for file system functions */
/* use only void* pointers as structures depend on operating system */

int UF_unlink( char *path );
int Win_FindFirstFile(char* dirname, void** handlePtr, void** findDataPtr);
char* getFileNameFromFindData(void* findData);
int Win_FindNextFile(void* hdlPtr, void** findDataPtr);
void Win_FindClose(void* hdlPtr);
void* UF_opendir( char *dirname );
void* UF_readdir( void *dirp );
int UF_closedir( void *dirp );
char* getFileNameFromDirEntry( void *de );


foreign_t swi_UF_opendir(term_t retterm, term_t dirterm) {

    void* ret;
    char* dir;

    if(!PL_is_atom(dirterm))
        PL_fail;

    PL_get_atom_chars(dirterm,&dir);

    ret=UF_opendir(dir);

    if(PL_unify_pointer(retterm,ret))
        PL_succeed;
    PL_fail;
}

foreign_t swi_UF_readdir(term_t retterm, term_t dirterm) {

    void* ret;
    void* dir;

    if(!PL_is_integer(dirterm))
        PL_fail;

    PL_get_pointer(dirterm,(void**)&dir);

    ret=UF_readdir(dir);

    if(PL_unify_pointer(retterm,ret))
        PL_succeed;
    PL_fail;
}

foreign_t swi_UF_closedir(term_t dirterm) {

    void* dir;

    if(!PL_is_integer(dirterm))
        PL_fail;

    PL_get_pointer(dirterm,(void**)&dir);

    UF_closedir(dir);

    PL_succeed;
}

foreign_t swi_UF_unlink(term_t retterm, term_t fterm) {

    int ret;
    char* fname;

    if(!PL_is_atom(fterm))
        PL_fail;

    PL_get_atom_chars(fterm,&fname);

    ret=UF_unlink(fname);

    if(PL_unify_integer(retterm,ret))
        PL_succeed;
    PL_fail;
}

foreign_t swi_getFileNameFromDirEntry(term_t retterm, term_t dterm) {

    char* ret;
    void* d;

    if(!PL_is_integer(dterm))
        PL_fail;

    PL_get_pointer(dterm,(void**)&d);

    ret=getFileNameFromDirEntry(d);

    if(ret && PL_unify_atom_chars(retterm,ret))
        PL_succeed;
    PL_fail;
}

foreign_t swi_Win_FindFirstFile(term_t retterm, term_t dterm, term_t hdlterm, term_t fdterm) {

    int ret;
    char* d;
    void* hdl;
    void* fd;

    if(!PL_is_atom(dterm))
        PL_fail;

    PL_get_atom_chars(dterm,&d);

    ret=Win_FindFirstFile(d,&hdl,&fd);

    if( PL_unify_integer(retterm,ret) &&
        PL_unify_pointer(hdlterm,hdl) &&
        PL_unify_pointer(fdterm,fd))
        PL_succeed;
    PL_fail;
}

foreign_t swi_Win_FindNextFile(term_t retterm, term_t hdlterm, term_t fdterm) {

    int ret;
    void* hdl;
    void* fd;

    if(!PL_is_integer(hdlterm))
        PL_fail;

    PL_get_pointer(hdlterm,(void**)&hdl);

    ret=Win_FindNextFile(hdl,&fd);

    if( PL_unify_integer(retterm,ret) &&
        PL_unify_pointer(fdterm,fd))
        PL_succeed;
    PL_fail;
}


foreign_t swi_Win_FindClose(term_t hdlterm) {

    void* hdl;

    if(!PL_is_integer(hdlterm))
        PL_fail;

    PL_get_pointer(hdlterm,(void**)&hdl);

    Win_FindClose(hdl);

    PL_succeed;
}

foreign_t swi_getFileNameFromFindData(term_t retterm, term_t dterm) {

    char* ret;
    void* d;

    if(!PL_is_integer(dterm))
        PL_fail;

    PL_get_pointer(dterm,(void**)&d);

    ret=getFileNameFromFindData(d);

    if(ret && PL_unify_atom_chars(retterm,ret))
        PL_succeed;
    PL_fail;

}


/* Forward declarations for BimIpc.c */

void loadWinSock();
int setup_service( int portnr , int *service );
int accept_request( int service , int *fd , FILE **inp , FILE **out );
int connect_service( int portnr , char* hostname , int *fd , FILE **inp , FILE **out );
void shutdown_service( int service, FILE *inp , FILE *out  );
int select_input_n( int* rfds , int len, int *resfd );
int input_pending(int fd, unsigned int seconds);

foreign_t swi_loadWinSock() {
    loadWinSock();
    PL_succeed;
}

foreign_t swi_setup_service(term_t retterm, term_t portterm, term_t servterm) {

    int ret,port,service;

    if(!PL_is_integer(portterm))
        PL_fail;

    PL_get_integer(portterm,&port);

    ret=setup_service(port,&service);

    if(PL_unify_integer(retterm,ret) && PL_unify_integer(servterm,service))
        PL_succeed;
    PL_fail;
}

foreign_t swi_accept_request(term_t retterm, term_t servterm, term_t fdterm, term_t inpterm, term_t outterm) {

    int ret,service,fd;
    FILE* inp;
    FILE* out;

    if(!PL_is_integer(servterm))
        PL_fail;

    PL_get_integer(servterm,&service);

    ret=accept_request(service,&fd,&inp,&out);

    if(PL_unify_integer(retterm,ret) && PL_unify_integer(fdterm,fd) &&
        PL_unify_pointer(inpterm,inp) && PL_unify_pointer(outterm,out))
        PL_succeed;
    PL_fail;
}

foreign_t swi_connect_service(term_t retterm, term_t portterm, term_t hostterm, term_t fdterm, term_t inpterm, term_t outterm) {

    int ret,port,fd;
    char* host;
    FILE* inp;
    FILE* out;

    if(!PL_is_integer(portterm) || !PL_is_atom(hostterm))
        PL_fail;

    PL_get_integer(portterm,&port);
    PL_get_atom_chars(hostterm,&host);

    ret=connect_service(port,host,&fd,&inp,&out);

    if(PL_unify_integer(retterm,ret) && PL_unify_integer(fdterm,fd) &&
        PL_unify_pointer(inpterm,inp) && PL_unify_pointer(outterm,out))
        PL_succeed;
    PL_fail;
}

foreign_t swi_shutdown_service(term_t servterm, term_t inpterm, term_t outterm) {

    int serv;
    FILE* inp;
    FILE* out;

    if(!PL_is_integer(servterm))
        PL_fail;

    PL_get_integer(servterm,&serv);

    if(PL_is_integer(inpterm) && PL_is_integer(outterm)) {
        PL_get_pointer(inpterm,(void**)&inp);
        PL_get_pointer(outterm,(void**)&out);
    }
    else {
        inp=NULL;
        out=NULL;
    }

    shutdown_service(serv,inp,out);

    PL_succeed;
}

/* static array to avoid re-allocation for each call of select input */
static int swiRfdsSelectInput[1000];
foreign_t swi_select_input_n(term_t retterm, term_t rfdsterm, term_t lenterm, term_t resfdterm) {

    int ret,len,i;
    int resfd;
    int *rfds;
    term_t head, list;

    if(!PL_is_list(rfdsterm) || !PL_is_integer(lenterm))
        PL_fail;

    PL_get_integer(lenterm,&len);
    if(len<1000)
        rfds=swiRfdsSelectInput;
    else
        rfds=(int*)malloc(sizeof(int)*len);

    list=PL_copy_term_ref(rfdsterm);
    head=PL_new_term_ref();
    i=0;
    while(PL_get_list(list,head,list)) {
        if(PL_is_integer(head))
            PL_get_integer(head,&(rfds[i]));
        else
            PL_fail;
        i++;
    }

    ret=select_input_n(rfds,len,&resfd);

    if(PL_unify_integer(retterm,ret) && PL_unify_integer(resfdterm,resfd))
        PL_succeed;
    PL_fail;
}

foreign_t swi_input_pending(term_t retterm, term_t fdterm, term_t secterm) {

    int ret,fd,sec;

    if(!PL_is_integer(fdterm) || !PL_is_integer(secterm))
        PL_fail;

    PL_get_integer(fdterm,&fd);
    PL_get_integer(secterm,&sec);

    ret=input_pending(fd,sec);

    if(PL_unify_integer(retterm,ret))
        PL_succeed;
    PL_fail;
}



/* Forward-Declarations for FileIO.c */
char *read_text_file (char *fname);
char *concat_sml_string(char *s1, char *s2);
char *ipc_read(int fd, int *len);
int ipc_write(int fd, char* ans);


foreign_t swi_read_text_file(term_t retterm, term_t fterm) {

    char* ret;
    char* fname;

    if(!PL_is_atom(fterm))
        PL_fail;

    PL_get_atom_chars(fterm,&fname);

    ret=read_text_file(fname);

    if(PL_unify_pointer(retterm,ret))
        PL_succeed;
    PL_fail;
}

foreign_t swi_concat_sml_string(term_t retterm, term_t s1term, term_t s2term) {

    char* ret;
    char* s1;
    char* s2;

    if(!PL_is_integer(s1term) || !PL_is_integer(s2term))
        PL_fail;

    PL_get_pointer(s1term,(void**)&s1);
    PL_get_pointer(s2term,(void**)&s2);

    ret=concat_sml_string(s1,s2);

    if(PL_unify_pointer(retterm,ret))
        PL_succeed;
    PL_fail;
}

foreign_t swi_ipc_read(term_t retterm, term_t fdterm, term_t lenterm) {

    char* ret;
    int len,fd;

    if(!PL_is_integer(fdterm))
        PL_fail;

    PL_get_integer(fdterm,&fd);

    ret=ipc_read(fd,&len);

    if(PL_unify_pointer(retterm,ret) && PL_unify_integer(lenterm,len))
        PL_succeed;
    PL_fail;
}

foreign_t swi_ipc_write(term_t retterm, term_t fdterm, term_t ansterm) {

    int ret;
    char* ans;
    int fd;

    if(!PL_is_integer(fdterm) || !PL_is_integer(ansterm))
        PL_fail;

    PL_get_integer(fdterm,&fd);
    PL_get_pointer(ansterm,(void**)&ans);

    ret=ipc_write(fd,ans);

    if(PL_unify_integer(retterm,ret))
        PL_succeed;
    PL_fail;
}


foreign_t swi_stringtoatom(term_t strpointer, term_t atom) {

    char* str;

    if(PL_is_integer(strpointer)) {
        PL_get_pointer(strpointer,(void**)&str);
        if(str && PL_unify_atom_chars(atom,str))
            PL_succeed;
        PL_fail;
    }

    if(PL_is_atom(atom)) {
        PL_get_atom_chars(atom,&str);
        if(PL_unify_pointer(strpointer,str))
            PL_succeed;
        PL_fail;
    }

    fprintf(stderr,"*** Warning: Invalid arguments in stringtoatom\n");
    PL_fail;
}

foreign_t swi_pointer(term_t pointer) {

    void* p;

    if(PL_is_integer(pointer) && PL_get_pointer(pointer,&p))
        PL_succeed;
    PL_fail;
}

foreign_t swi_isNullPointer(term_t pointer) {

    void* p;

    if(PL_is_integer(pointer) && PL_get_pointer(pointer,&p) && !p)
        PL_succeed;
    PL_fail;
}

foreign_t pc_record_ext(term_t key1Pointer,
                        term_t key2Pointer,
                        term_t termPointer) {
    if(!PL_is_variable(termPointer)) {
      record_t record;
      int solve;
      // Transform term_t (term pointers) to char*.
      char* key1Str;
      char* key2Str;
      if(PL_is_atom(key1Pointer)) PL_get_atom_chars(key1Pointer,&key1Str);
      else PL_fail;
      if(PL_is_atom(key2Pointer)) PL_get_atom_chars(key2Pointer,&key2Str);
      else PL_fail;
      //printf("pc_record_ext(%s, %s, term_t): read record\n", key1Str, key2Str);
      // Persistently store the term, record is a pointer to the stored term
      // created by the SWI-PL API for later accessing.
      //printf("pc_record_ext(..): Create record\n");
      record = PL_record(termPointer);
      //printf("pc_record_ext(..): record = %d\n", (int)record);
      // Store this record persistently in the map, so it is accessible under
      // the given double key.
      solve = pc_record(key1Str, key2Str, record);
      //printf("pc_record_ext(..): stored record.\n");
      // Translate the local SUCCEED constant to a foreign_t
      if(solve == SUCCEED) PL_succeed;
      else PL_fail;
    } else PL_fail;
}

foreign_t pc_rerecord_ext(term_t key1Pointer,
                          term_t key2Pointer,
                          term_t termPointer) {
    if(!PL_is_variable(termPointer)) {
      // Transform term_t (term pointers) to char*.
      char* key1Str;
      char* key2Str;
      record_t record;
      if(PL_is_atom(key1Pointer)) PL_get_atom_chars(key1Pointer,&key1Str);
      else PL_fail;
      if(PL_is_atom(key2Pointer)) PL_get_atom_chars(key2Pointer,&key2Str);
      else PL_fail;
      //printf("pc_rerecord_ext(%s, %s, term_t): read record\n", key1Str, key2Str);
      // Persistently store the term, record is a pointer to the stored term
      // created by the SWI-PL API for later accessing.
      //printf("pc_rerecord_ext(..): create new record\n");
      record = PL_record(termPointer);
      // Store this record persistently in the map, so it is accessible under
      // the given double key.
      //printf("pc_rerecord_ext(..): rewrite record\n");
      pc_rerecord(key1Str, key2Str, record);
      //printf("pc_rerecord_ext(..): done\n");
      PL_succeed;
    } else PL_fail;
}

foreign_t pc_recorded_ext(term_t key1Pointer,
                          term_t key2Pointer,
                          term_t termPointer) {
    char* key1Str;
    char* key2Str;
    record_t record;
    int solve;
    if(PL_is_atom(key1Pointer)) PL_get_atom_chars(key1Pointer,&key1Str);
    else PL_fail;
    if(PL_is_atom(key2Pointer)) PL_get_atom_chars(key2Pointer,&key2Str);
    else PL_fail;
    // Retrieve the record from the map.

    //printf("pc_recorded_ext(%s, %s, term_t): read record from TermCache\n", key1Str, key2Str);
    solve = pc_recorded(key1Str, key2Str, &record);
    //printf("solve = %d (0=Fail), pc_recorded_ext(..): record = %d\n", solve,   (int)record);
    //printf("solve = %d (0=Fail)\n", solve);
    if(solve == SUCCEED) {
      // Don't know why, but using the termPointer directly doesn't work.
      term_t t2 = PL_new_term_ref();
      // Use the record to retrieve the term for the PL API.
      PL_recorded(record, t2);
      // Unification is now needed to return the actual term.
      if(PL_unify(termPointer, t2)) {
        PL_succeed;
      } else {
        PL_fail;
      }
    } else {
      PL_fail;
    }
}


int is_a_key(term_t key1Pointer, term_t key2Pointer) {
    // Transform term_t (term pointers) to char*.
    char* key1Str;
    char* key2Str;
    if(PL_is_atom(key1Pointer)) PL_get_atom_chars(key1Pointer,&key1Str);
    else PL_fail;
    if(PL_is_atom(key2Pointer)) PL_get_atom_chars(key2Pointer,&key2Str);
    else PL_fail;
    return pc_is_a_key(key1Str, key2Str);
}

foreign_t pc_is_a_key_ext(term_t key1Pointer, term_t key2Pointer) {
    int solve = is_a_key(key1Pointer, key2Pointer);
    if(solve == SUCCEED) PL_succeed;
    else PL_fail;
}

foreign_t pc_erase_ext(term_t key1Pointer, term_t key2Pointer) {
    // Transform term_t (term pointers) to char*.
    char* key1Str;
    char* key2Str;
    record_t record;
    int solve;
    if(PL_is_atom(key1Pointer)) PL_get_atom_chars(key1Pointer,&key1Str);
    else PL_fail;
    if(PL_is_atom(key2Pointer)) PL_get_atom_chars(key2Pointer,&key2Str);
    else PL_fail;
    // Retrieve the record from the map.
    solve = pc_recorded(key1Str, key2Str, &record);
    if(solve == SUCCEED) {
      // Delete the record from the map.
      pc_erase(key1Str, key2Str);
      // Delete the associated term from the SWI-PL API.
      PL_erase(record);
      PL_succeed;
    } else {
      PL_fail;
    }
}

foreign_t pc_erase_all_ext(term_t key2Pointer) {
    // Transform term_t (term pointers) to char*.
    char* key2Str;
    if(PL_is_atom(key2Pointer)) PL_get_atom_chars(key2Pointer,&key2Str);
    else PL_fail;
    pc_erase_all(key2Str);
    PL_succeed;
}

foreign_t pc_current_key_ext(term_t key1Pointer, term_t key2Pointer, term_t resultList) {
    char* key1Str;
    char* key2Str;
    if(PL_is_atom(key2Pointer)) PL_get_atom_chars(key2Pointer,&key2Str);
    else PL_fail;
    if(!PL_is_variable(key1Pointer)) {
      // Test whether (key1, key2) is a valid key and create list with one element.
      //Retrieve key1 string.
      PL_get_atom_chars(key1Pointer,&key1Str);
      if(is_a_key(key1Pointer, key2Pointer) == SUCCEED) {
        PROLOG_TERM tmp;
        PROLOG_TERM cons;
        PROLOG_FUNC keyStruct;

        //Init terms.
        INIT_TERM(cons);
        INIT_TERM(tmp);
        //INIT_TERM(resultList);
        INIT_LIST(resultList);
        //Retrieve head of list.
        GET_ARG(resultList, 1, cons);
        //Create key structure.
        keyStruct = GET_PRED(STR2ATOM(FALSE, "double_key"), 2);
        //Assign key structure to cons
        UNIFY_FUNC(cons, keyStruct);
        //Retrieve first argument of key structure in cons.
        GET_ARG(cons, 1, tmp);
        //Unifiy with key1
        UNIFY_ATOM(tmp, STR2ATOM(FALSE, key1Str));
        //Retrieve second argument of key structure in cons.
        GET_ARG(cons, 2, tmp);
        //Unify with key2
        UNIFY_ATOM(tmp, STR2ATOM(FALSE, key2Str));

        //Reinit cons.
        INIT_TERM(cons);
        //Retrieve tail of list.
        GET_ARG(resultList, 2, cons);
        //Unify with empty list.
        UNIFY_ATOM(cons, STR2ATOM(TRUE, "[]"));
        PL_succeed;
      } else {
        PL_fail;
      }
    } else {
      int solve;
      key1Str = 0;
      // resultList has to be a list of record_ts.
      solve = pc_current_key(key1Str, key2Str, resultList);
      if(solve == SUCCEED) PL_succeed;
      else PL_fail;
    }
}


/* Predicate to debug CBserver/SWI-Prolog. It checks
  the Prolog stacks which might be corrupted by buggy
  foreign code or bugs in SWI-Prolog. Insert calls to
  this predicate in the Prolog-Code to identify the
  statement in the Prolog which damages the stack.

  To enable this predicate, you have to recompile SWI-Prolog
  with the additional flags -DSECURE_GC=1 -DO_SECURE=1.
  Only then the functions scan_global and checkStacks will
  be available.
 */
foreign_t swi_checkStacks(term_t numterm) {
    printf("checkStacks not enabled, edit swiGeneral.c and recompile SWI-Prolog\n");
/*    static int iCheckStacks;
    int num;

    if(!PL_is_integer(numterm))
        PL_fail;
    PL_get_integer(numterm,&num);

    printf("***** checking PROLOG stack: %d :: %d *****\n",num,iCheckStacks++);
    if(!scan_global(0))
       printf("***** scan global problem *****\n");
    checkStacks(NULL,NULL); */
    PL_succeed;
}

void install_libGeneral() {

    /* Some OS functions */
    REGISTER_FOREIGN("ExternalCodeLoader","getpid",1,swi_getpid,0);
    REGISTER_FOREIGN("ExternalCodeLoader","strdup",2,swi_strdup,0);
    REGISTER_FOREIGN("ExternalCodeLoader","systemclock",7,swi_systemclock,0);
    REGISTER_FOREIGN("ExternalCodeLoader","sleepsec",1,swi_sleepsec,0);
    REGISTER_FOREIGN("ExternalCodeLoader","username",1,swi_username,0);
    REGISTER_FOREIGN("ExternalCodeLoader","hostname",1,swi_hostname,0);
    REGISTER_FOREIGN("ExternalCodeLoader","memfree",1,swi_memfree,0);
    REGISTER_FOREIGN("ExternalCodeLoader","sec_time",1,swi_sec_time,0);

    /* StringBuffer */
    REGISTER_FOREIGN("ExternalCodeLoader","initBuffer",2,swi_initBuffer,0);
    REGISTER_FOREIGN("ExternalCodeLoader","appendBuffer",2,swi_appendBuffer,0);
    REGISTER_FOREIGN("ExternalCodeLoader","prependBuffer",2,swi_prependBuffer,0);
    REGISTER_FOREIGN("ExternalCodeLoader","appendBufferP",2,swi_appendBufferP,0);
    REGISTER_FOREIGN("ExternalCodeLoader","prependBufferP",2,swi_prependBuffer,0);
    REGISTER_FOREIGN("ExternalCodeLoader","deleteBuffer",1,swi_deleteBuffer,0);
    REGISTER_FOREIGN("ExternalCodeLoader","getStringFromBuffer",2,swi_getStringFromBuffer,0);
    REGISTER_FOREIGN("ExternalCodeLoader","getPointerFromBuffer",2,swi_getPointerFromBuffer,0);
    REGISTER_FOREIGN("ExternalCodeLoader","stringBufferCompare",3,swi_stringBufferCompare,0);
    REGISTER_FOREIGN("ExternalCodeLoader","displayAnswerOnTrace",2,swi_displayAnswerOnTrace,0);
    REGISTER_FOREIGN("ExternalCodeLoader","replaceEmptyBuffer",1,swi_replaceEmptyBuffer,0);
    REGISTER_FOREIGN("ExternalCodeLoader","replaceCharacterInBuffer",3,swi_replaceCharacterInBuffer,0);
    REGISTER_FOREIGN("ExternalCodeLoader","getLengthFromBuffer",2,swi_getStringFromBuffer,0);

    /* UnixFileSys */
    REGISTER_FOREIGN("ExternalCodeLoader","UF_opendir",2,swi_UF_opendir,0);
    REGISTER_FOREIGN("ExternalCodeLoader","UF_readdir",2,swi_UF_readdir,0);
    REGISTER_FOREIGN("ExternalCodeLoader","UF_closedir",1,swi_UF_closedir,0);
    REGISTER_FOREIGN("ExternalCodeLoader","UF_unlink",2,swi_UF_unlink,0);
    REGISTER_FOREIGN("ExternalCodeLoader","getFileNameFromDirEntry",2,swi_getFileNameFromDirEntry,0);

    /* WinFileSys */
    REGISTER_FOREIGN("ExternalCodeLoader","Win_FindFirstFile",4,swi_Win_FindFirstFile,0);
    REGISTER_FOREIGN("ExternalCodeLoader","Win_FindNextFile",3,swi_Win_FindNextFile,0);
    REGISTER_FOREIGN("ExternalCodeLoader","Win_FindClose",1,swi_Win_FindClose,0);
    REGISTER_FOREIGN("ExternalCodeLoader","getFileNameFromFindData",2,swi_getFileNameFromFindData,0);

    /* BimIpc */
    REGISTER_FOREIGN("ExternalCodeLoader","loadWinSock",0,swi_loadWinSock,0);
    REGISTER_FOREIGN("ExternalCodeLoader","setup_service",3,swi_setup_service,0);
    REGISTER_FOREIGN("ExternalCodeLoader","accept_request",5,swi_accept_request,0);
    REGISTER_FOREIGN("ExternalCodeLoader","connect_service",6,swi_connect_service,0);
    REGISTER_FOREIGN("ExternalCodeLoader","shutdown_service",3,swi_shutdown_service,0);
    REGISTER_FOREIGN("ExternalCodeLoader","select_input_n",4,swi_select_input_n,0);
    REGISTER_FOREIGN("ExternalCodeLoader","input_pending",3,swi_input_pending,0);

    /* FileIO */
    REGISTER_FOREIGN("ExternalCodeLoader","read_text_file",2,swi_read_text_file,0);
    REGISTER_FOREIGN("ExternalCodeLoader","concat_sml_string",3,swi_concat_sml_string,0);
    REGISTER_FOREIGN("ExternalCodeLoader","ipc_read",3,swi_ipc_read,0);
    REGISTER_FOREIGN("ExternalCodeLoader","ipc_write",3,swi_ipc_write,0);

    /* Some external predicates required for PrologCompatibility */
    REGISTER_FOREIGN("ExternalCodeLoader","swi_stringtoatom",2,swi_stringtoatom,0);
    REGISTER_FOREIGN("ExternalCodeLoader","swi_pointer",1,swi_pointer,0);
    REGISTER_FOREIGN("ExternalCodeLoader","swi_isNullPointer",1,swi_isNullPointer,0);

    /* Also required for PrologCompatibility: Caching of prolog terms. */
    REGISTER_FOREIGN("ExternalCodeLoader","pc_record_ext",3,pc_record_ext,0);
    REGISTER_FOREIGN("ExternalCodeLoader","pc_rerecord_ext",3,pc_rerecord_ext,0);
    REGISTER_FOREIGN("ExternalCodeLoader","pc_recorded_ext",3,pc_recorded_ext,0);
    REGISTER_FOREIGN("ExternalCodeLoader","pc_is_a_key_ext",2,pc_is_a_key_ext,0);
    REGISTER_FOREIGN("ExternalCodeLoader","pc_erase_ext",2,pc_erase_ext,0);
    REGISTER_FOREIGN("ExternalCodeLoader","pc_erase_all_ext",1,pc_erase_all_ext,0);
    REGISTER_FOREIGN("ExternalCodeLoader","pc_current_key_ext",3,pc_current_key_ext,0);

    REGISTER_FOREIGN("ExternalCodeLoader","swi_checkStacks",1,swi_checkStacks,0);

}
