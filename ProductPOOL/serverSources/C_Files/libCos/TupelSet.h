/*
The ConceptBase.cc Copyright

Copyright 1987-2023 The ConceptBase Team. All rights reserved.

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
#include <set>
#include "Pix.h"
#include "Tupel.h"

struct TupelVergleich 
{
    bool operator()(Tupel t1,Tupel t2)
        const
    {
        if (t1.GetSize()!=t2.GetSize()) 
        {
            printf("fatal error: wrong tupelsize detected in set-compare-function\n");
            return true;
        }
         //alle elemente durchgehen
        for (int a=0;a<t1.GetSize();a++)
        {
             //bis ein vergleichbares paar gefunden wurde (zwei OIDs)
            if ((t1[a].GetType()==t2[a].GetType()) && (t1[a].GetType()==1))
            {
                 if (((TOID)t1[a]).GetId()<((TOID)t2[a]).GetId()) return true;
                 if (((TOID)t1[a]).GetId()>((TOID)t2[a]).GetId()) return false;
            }
        }
        return false;
    }
};

inline bool operator<(const TOID& t1,const TOID& t2)

{
    return 1;
};

inline bool operator<(const SYMID& t1,const SYMID& t2)

{
    return 1;
};

inline bool operator<(const TupelElement& t1,const TupelElement& t2)

{
    return 1;
};

class TupelMenge
{   
public:
    set<Tupel,TupelVergleich > Menge;
    int count;
    set<Tupel,TupelVergleich >::iterator iter;
    set<Tupel,TupelVergleich >::iterator iter_dummy;

    TupelMenge(){};
    virtual ~TupelMenge(){};
    
    int length();
    int empty();
    Pix add(Tupel);
    void del(Tupel);
    int contains(Tupel);
    void clear();
    Pix first();
    void next(Pix&);
    Tupel& operator()(Pix);
    int owns(Pix);
    Pix seek(Tupel);
    void operator|=(TupelMenge&);
    void operator-=(TupelMenge&);
};


class TupelSet2
{
public:
    TupelSet2(){};
    virtual ~TupelSet2()
    {
        delete &p;
    };

    TupelMenge p;
  
    int length(){return p.length();};
    int empty(){return p.empty();};
    Pix add(Tupel item){return p.add(item);};
    void del(Tupel item ){p.del(item);};
    int contains(Tupel item){return p.contains(item);};
    void clear(){p.clear();};
    Pix first(){return p.first();};
    void next(Pix& ind){p.next(ind);};
    Tupel& operator()(Pix ind){return p(ind);};
    int owns(Pix ind){return p.owns(ind);};
    Pix seek(Tupel item){return p.seek(item);};
    void operator|=(TupelSet2& tset){p|=tset.p;};
    void operator-=(TupelSet2& tset){p-=tset.p;};
};

