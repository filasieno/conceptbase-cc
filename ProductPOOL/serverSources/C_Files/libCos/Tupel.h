/*
The ConceptBase.cc Copyright

Copyright 1987-2019 The ConceptBase Team. All rights reserved.

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
#ifndef _TUPEL
#define _TUPEL

#include "TOID.h"
#include "SYMID.h"
#include "Literals.h"

#define TUPEL_FREE  0
#define TUPEL_OID   1
#define TUPEL_SYMID 2
#define TUPEL_UNDEF -1

/** Ein Tupel-Element ist ein einzelner Eintrag eines Tupels. Als Typ ist
    moeglich: TOID, SYMID, FREE und UNDEF */
class TupelElement 
{
    int type;
    union 
    {
        TOID *toid;
        SYMID *symid;
    } element;
    
    void create_toid();
    void create_symid();
    

    
public:
    TupelElement();
    TupelElement(int);
    ~TupelElement();
    TupelElement(const TOID&);
    

    TupelElement &operator=(const SYMID&);
    TupelElement &operator=(const TOID&);
    TupelElement &operator=(const TupelElement&);
    TupelElement &operator=(const int&);
    int           operator==(const TupelElement&) const;
    int           operator<=(const TupelElement&) const;
    int match(const TupelElement&) const;
    TOID &get_toid() { return *element.toid; };
    SYMID &get_symid() const { return *element.symid; };
    
    operator TOID() const
    {
        return *element.toid;
    }
    operator SYMID() const
    {
        return *element.symid;
    }
    void test() const;
    int GetType() const
    {
        return type;
    };
};

inline bool operator<(const TupelElement& t1,const TupelElement& t2)

{
    if (t1.GetType()!=t2.GetType()) return 0;
    if (t1.GetType()==TUPEL_OID) return (TOID)t1<(TOID)t2;
    if (t1.GetType()==TUPEL_FREE) return false;
    return t1.get_symid() < t2.get_symid();
};

class AttrList
{
    int *attr;
    int size;
    
public:
        /*
    AttrList() 
            : attr(NULL),size(0)
    {}
    */
    AttrList(int ns);
    int& operator[](const int& i) { return attr[i]; }
    int operator()(const int&i) const { return attr[i]; }
    int length() const { return size; }
    
};



class Tupel
{
    TupelElement *tupel;
    char size;
    char sort_by;
    
public:
    Tupel();
    Tupel(const char);
    Tupel(const Tupel&);
    Tupel(const TupelElement&,const TupelElement& = TUPEL_UNDEF,const TupelElement& = TUPEL_UNDEF);
    
    ~Tupel();
    
    
    
    Tupel& operator=(const Tupel&);
    TupelElement& operator[](int);
    TupelElement operator[](int) const;
    
    int           operator == (const Tupel&) const;
    int           operator <= (const Tupel&) const;
    int match(const Tupel&) const;
    Tupel proj(const AttrList&);
    
    
    void test() const;
    int GetSize() const { return size; }
    int SetKey(int key) { return sort_by=key; }
    void SetSize(char i) {size=i;};
    int contains(const TupelElement*);
};

inline bool operator<(const Tupel& t1,const Tupel& t2)

{
    printf("Tupel< operator aufgerufen!!!!!\n");
    if (t1.GetSize()!=t2.GetSize()) return false;
    return (t1[0]<t2[0]);
};

#endif
