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
#include "C_Functor.h"
#include <stdio.h>
#include "string.h"
#include <stdlib.h>

C_Functor::C_Functor()
{
    Name=NULL;
    konstanten=NULL;
}

C_Functor::C_Functor(char *n,int a) 
{
    Name=NULL;
    konstanten=NULL;
    set(n,a);
}  
  
void C_Functor::set(char *n,int a) 
{
    if (Name!=NULL) return;
    Name=new char[strlen(n)+1];
    strncpy(Name,n,strlen(n)+1);
    Len=a;
}

void C_Functor::set(char *n,int a, char** k) 
{    
    if (Name!=NULL) return;
    Name=new char[strlen(n)+1];
    strncpy(Name,n,strlen(n)+1);
    Len=a;
   
    if (k==NULL) return;
    konstanten=new char*[a];
    oids=new long[a];
    for (int c=0;c<a;c++) 
    {
        if (k[c])
        { 
            konstanten[c]=new char[strlen(k[c])+1];
            strncpy(konstanten[c],k[c],strlen(k[c])+1);
            oids[c]=0;
            if (sscanf(k[c],"id_%ld",&oids[c]) != 1) 
                for (unsigned int a=0;a<strlen(k[c]);a++) oids[c]+=(unsigned short)k[c][a];
            
        } else {konstanten[c]=NULL;oids[c]=-1;} 
    }
     //printf("set: ");test();
}

void C_Functor::test()
    const
{
    if (konstanten)
    {
        printf("Functor: %s[",Name);
        for (int c=0;c<Len;c++)
            if (konstanten[c]) 
                if (oids[c]!=-1) printf("%ld ",oids[c]); else printf("%s ",konstanten[c]);
        else printf("_ ");
        printf("]\n");
    } else printf("Functor: %s/%d\n",Name,Len);
    
}
    
char* C_Functor::name()
    const
{
    return Name;
}
int C_Functor::len()
    const
{
    return Len;
}

C_Functor::~C_Functor()
{
    if (Name) delete[] Name;
    if (konstanten) delete[] konstanten;
}

char* C_Functor::operator[](int i)
    const
{
    if (i<Len) return konstanten[i]; else return NULL;
}

int C_Functor::operator==(const C_Functor &funct)
    const
{
    if (funct.len()!=len()) return 0;
    if (strlen(funct.name())!=strlen(name())) return 0;
    if (strncmp(funct.name(),name(),strlen(name()))) return 0;
    
    if ((konstanten==NULL) || (funct.konst()==NULL)) return 1;
    for (int c=0;c<Len;c++) 
        if (funct[c] && konstanten[c])
            {if (strcmp(funct[c],konstanten[c])) return 0;}
        else if (funct[c] || konstanten[c]) return 0;
    return 1;
}

/*
int C_Functor::operator==(const Tupel &tupel) 
    const
{
    if ((len()==0) || (konst()==NULL)) return 1;
    if (tupel.GetSize()!=len()) return 0;
    for (int a=0;a<len();a++)
    {

        if (konstanten[a]!=NULL)
        {  
            if (tupel[a].GetType()==TUPEL_OID) 
            {
                if (oids[a]!=-1) 
                {
                    if (oids[a]!=((TOID)(tupel[a])).GetId()) 
                    {
                         //printf("%d!=%d\n",oids[a],((TOID)(tupel[a])).GetId());
                        return 0; 
                    } 
                } else printf("*******C_Functor::operator== ups************\n");
            } else {
                if (strcmp(((SYMID)tupel[a]).get_name(),konstanten[a])) 
                {
                     //printf("'%s' != '%s'\n",((SYMID)tupel[a]).get_name(),konstanten[a]);                    
                    return 0;
                }
            }
        }
    }
    return 1;
}
*/
