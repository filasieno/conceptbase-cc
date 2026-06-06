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
#include "tuple.STLBag.h"

void TupelSTLBag::test()
{
    printf("[");
    for (Pix ind=TupelSTLBag::first();ind;TupelSTLBag::next(ind))
    {        
        TupelSTLBag::operator()(ind).test();
        printf(" ");
    }
    printf("](%d)\n",length());    
}


void TupelSTLBag::test2()
{
    printf("[");
    for (iter_dummy=p.begin();iter_dummy!=p.end();iter_dummy++)
    {
        (*iter_dummy).test();
        printf(" ");
    }
    printf("]\n");    
}

int TupelSTLBag::length()
{
    return p.size();
}


int TupelSTLBag::empty()
{
    return p.empty();
}

Pix TupelSTLBag::add(Tupel item)
{
    p.push_front(item);
    return (Pix)&p.begin();
}

void TupelSTLBag::del(Tupel item)
{
    p.remove(item);
}

int TupelSTLBag::contains(Tupel item)
{
    for (iter_dummy=p.begin();iter_dummy!=p.end();iter_dummy++)
    {
        if ((*iter_dummy)==item) return 1;
    }
    return 0;
}

void TupelSTLBag::clear()
{
    while (!p.empty()) p.pop_front();
}

Pix TupelSTLBag::first()
{
    iter=p.begin();
    if (iter==p.end()) return NULL;
    else return (Pix)&iter;
}

void TupelSTLBag::next(Pix &ind)
{
    iter=(*(iterator_*)ind);
    iter++;
    if (iter==p.end()) 
    {
        ind=NULL;
    }
    else ind=(Pix)&iter;
}

Tupel& TupelSTLBag::operator()(Pix ind)
{
    return (*(*(iterator_*)ind));
}

void TupelSTLBag::operator|=(TupelSTLBag& tupelbag)
{
    for (iterator_ i=tupelbag.p.begin();i!=tupelbag.p.end();i++)
    {
        p.push_front(*i);
    }
}

void TupelSTLBag::operator-=(TupelSTLBag& tupelbag)
{
    iter_dummy=tupelbag.p.begin();
    while (iter_dummy!=tupelbag.p.end())
    {
        p.remove(*iter_dummy);
        iter_dummy++;
    }
}

int TupelSTLBag::owns(Pix ind)
{
     //can man so not definieren, because die iteratoren fest mit of a Menge verbunden are...
    ind=NULL;
    return 1;
}

Pix TupelSTLBag::seek(Tupel item)
{
     //nach contains ist iter_dummy auf das element gesetzt! (siehe contains)
    if (contains(item)) return (Pix)&iter_dummy;
    else return NULL;
}
