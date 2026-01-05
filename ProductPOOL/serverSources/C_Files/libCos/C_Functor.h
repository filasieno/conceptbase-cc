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
#include "Tupel.h"

/**
   Das ist die C-Implementierung des BP\_Functors.  
   Er enthaelt einen Namen, die Anzahl von Parametern,
   die Parameter als char** und nochmal als long**.
*/
class C_Functor 
{
     /**der Name des Functors */
    char *Name;
     /**Anzahl der Parameter*/
    int Len;
     /**Parameter als String (NULL, wenn frei)*/
    char **konstanten;
     /**Parameter als long. 
        (nur moeglich, wenn Parameter in der Form id\_<long>, sonst -1)*/
    long *oids;

public:
     /**erzeugt einen leeren Functor*/
    C_Functor();
     /**erzeugt einen neuen Functor, indem func kopiert wird*/
    C_Functor(const C_Functor &func):Name(0),Len(0),konstanten(0)
    {
        if (func.konst())
            set(func.name(),func.len(),func.konst());
        else
            set(func.name(),func.len());
    };
     /**erzeugt einen vollstaendigen Functor (Name, Anzahl, Konstanten)*/
    C_Functor(char *n,int a,char**);
     /**wie oben, nur werden keine Konstanten gespeichert*/
    C_Functor(char *n,int a);
     /**setzt Name und Anzahl der Parameter*/
    void set(char* n,int a);
     /**setzt Name, Anzahl der Parameter und Konstanten des Functors*/
    void set(char* n,int a, char**);
     /**vergleicht 2 Functoren*/
    int operator==(const C_Functor &funct) const;
     /**gibt TRUE zurueck, falls das Tupel kompatibel zum Functor ist*/
    inline int operator==(const Tupel &tupel) const;
     /**gibt die einzelnen Konstanten zur\"uck*/
    char* operator[](int i) const;
    ~C_Functor();
    void test() const;
     /**liefert den Namen*/
    char* name() const;
     /**liefert die Anzahl der Konstanten*/
    int len() const;
     /**liefert Zeiger auf den Array der gespeicherten oids*/
    long* oid() const 
    {
        return oids;
    }
     /**liefert Zeiger auf den Array der Konstanten*/
    char** konst() const {return konstanten;};  
};



inline int C_Functor::operator==(const Tupel &tupel) 
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
                if (strcmp((tupel[a].get_symid()).get_name(),konstanten[a])) 
                {
                     //printf("'%s' != '%s'\n",((SYMID)tupel[a]).get_name(),konstanten[a]);                    
                    return 0;
                }
            }
        }
    }
    return 1;
}
