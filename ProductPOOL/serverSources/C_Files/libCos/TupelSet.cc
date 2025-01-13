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
#include "TupelSet.h"


int TupelMenge::length()
{
    return count;
}

int TupelMenge::empty()
{
    return count==0;
}

Pix TupelMenge::add(Tupel item)
{
    pair<set<Tupel, TupelVergleich >::iterator,bool> iter_bool=Menge.insert(item);
    if (!iter_bool.second) return NULL;
    count++;
    return (Pix)&iter_bool.first;
}

void TupelMenge::del(Tupel item)
{
    iter_dummy=Menge.find(item);
    if (iter_dummy==Menge.end()) return;
    count--;
    Menge.erase(iter_dummy);
}

int TupelMenge::contains(Tupel item)
{
    iter_dummy=Menge.find(item);
    return iter_dummy!=Menge.end();
}

void TupelMenge::clear()
{
    count=0;
    Menge.erase(Menge.begin(),Menge.end());
}

Pix TupelMenge::first()
{
    iter=Menge.begin();
    if (iter==Menge.end()) return NULL;
    else return (Pix)&iter;
}

void TupelMenge::next(Pix &ind)
{
    iter=((*((set<Tupel, TupelVergleich >::iterator*)ind))++);
    if (iter==Menge.end()) ind=NULL;
    else ind=(Pix)&iter;
}

Tupel& TupelMenge::operator()(Pix ind)
{
    return (*(Tupel*)((set<Tupel, TupelVergleich >::iterator*)ind));
}

void TupelMenge::operator|=(TupelMenge& tupelset)
{
    Menge.insert(&(Tupel)(*(tupelset.Menge.begin())),&(Tupel)(*(tupelset.Menge.end())));
}

void TupelMenge::operator-=(TupelMenge& tupelset)
{
    iter_dummy=tupelset.Menge.begin();
    set<Tupel,TupelVergleich >::iterator iter_dummy2;

    while (iter_dummy!=tupelset.Menge.end())
    {
        iter_dummy2=Menge.find((Tupel)(*iter_dummy));
        if (iter_dummy2!=Menge.end()) Menge.erase(iter_dummy2);
        iter_dummy++;
    }
}

int TupelMenge::owns(Pix ind)
{
     //kann man so nicht definieren, weil die iteratoren fest mit einer Menge verbunden sind...
    return 1;
}

Pix TupelMenge::seek(Tupel item)
{
    return (Pix)&Menge.find(item);
}
