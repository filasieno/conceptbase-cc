/*
The ConceptBase.cc Copyright

Copyright 1987-2021 The ConceptBase Team. All rights reserved.

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
#include "Tupel.STLSet.h"

void TupelSTLSet::test()
{
    printf("[");
    for (Pix ind=TupelSTLSet::first();ind;TupelSTLSet::next(ind))
    {        
        TupelSTLSet::operator()(ind).test();
        printf(" ");
    }
    printf("](%d)\n",length());    
}

/*
void TupelSTLSet::test2()
{
    printf("[");
    for (iter_dummy=p.begin();iter_dummy!=p.end();iter_dummy++)
    {
        (*iter_dummy).test();
        printf(" ");
    }
    printf("]\n");    
}
*/

int TupelSTLSet::length()
{
    return p.size();
}


int TupelSTLSet::empty()
{
    return p.empty();
}

Pix TupelSTLSet::add(Tupel item)
{
    pair<iterator_,bool> iter_bool=p.insert(item);
    if (!iter_bool.second) return NULL;
    return (Pix)&iter_bool.first;
}

void TupelSTLSet::del(Tupel item)
{
    iter_dummy=p.find(item);
    if (iter_dummy==p.end()) return;
    p.erase(iter_dummy);
}

int TupelSTLSet::contains(Tupel item)
{
    iter_dummy=p.find(item);
    return iter_dummy!=p.end();
}

void TupelSTLSet::clear()
{
    p.clear();
}

Pix TupelSTLSet::first()
{
    iter=p.begin();
    if (iter==p.end()) return NULL;
    else return (Pix)&iter;
}

void TupelSTLSet::next(Pix &ind)
{
    iter=(*(iterator_*)ind);
    ++iter;
    if (iter==p.end()) 
    {
        ind=NULL;
    }
    else ind=(Pix)&iter;
}

Tupel& TupelSTLSet::operator()(Pix ind)
{
    return (*(*(iterator_*)ind));
}

void TupelSTLSet::operator|=(TupelSTLSet& tupelset)
{
    for (iterator_ i=tupelset.p.begin();i!=tupelset.p.end();++i)
    {
        p.insert(*i);
    }
}

void TupelSTLSet::operator-=(TupelSTLSet& tupelset)
{
    iter_dummy=tupelset.p.begin();
    iterator_ iter_dummy2;
    while (iter_dummy!=tupelset.p.end())
    {
        iter_dummy2=p.find((Tupel)(*iter_dummy));
        if (iter_dummy2!=p.end()) 
        {
            p.erase(iter_dummy2);
        }
        ++iter_dummy;
    }
}

int TupelSTLSet::owns(Pix ind)
{
     //kann man so nicht definieren, weil die iteratoren fest mit einer Menge verbunden sind...
    ind=NULL;
    return 1;
}

Pix TupelSTLSet::seek(Tupel item)
{
    return (Pix)&p.find(item);
}
