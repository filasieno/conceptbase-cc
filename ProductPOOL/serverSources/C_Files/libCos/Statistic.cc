/*
The ConceptBase.cc Copyright

Copyright 1987-2024 The ConceptBase Team. All rights reserved.

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

#include <stdlib.h>
#include "Statistic.h"


int Statistic::operator==(Statistic s) {
  return toid == s.toid;
}

int Statistic::operator<=(Statistic s) {
  return toid <= s.toid;
}

Statistic& Statistic::operator=(Statistic neu) {
 toid = neu.toid;
 anzahl = neu.anzahl;
 src_hist = neu.src_hist;
 dst_hist = neu.dst_hist;
 return *this;
}

long& Statistic::operator[](int i) {
    return anzahl[i];
}


Statistic::Statistic()
{
    anzahl = NULL;
    src_hist = NULL;
    dst_hist = NULL;
}

Statistic::Statistic(TOID neu) 
{
    toid = neu;
    anzahl = NULL;
    src_hist = dst_hist = NULL;
}

void
Statistic::create()
{
    anzahl = new long[BOX_ANZAHL];
    for (int i=0;i<BOX_ANZAHL;i++)
	anzahl[i] = -1;
}

void
Statistic::destroy() 
{
    delete anzahl;
    delete src_hist;
    delete dst_hist;
}

void Statistic::hist_insert(int what, TOID neu, long anz)
{
    switch (what) {
    case HISTOGRAMM_SRC:
	if (!src_hist) src_hist = new Histogramm(neu,anz);
	else src_hist->insert(neu,anz);
	break;
    case HISTOGRAMM_DST:
	if (!dst_hist) dst_hist = new Histogramm(neu,anz);
	else dst_hist->insert(neu,anz);
	break;
    default:
	break;
    }
}

void Statistic::hist_insert(int what, TOID neu)
{
    switch (what) {
    case HISTOGRAMM_SRC:
	if (!src_hist) src_hist = new Histogramm(neu);
	else src_hist->insert(neu);
	break;
    case HISTOGRAMM_DST:
	if (!dst_hist) dst_hist = new Histogramm(neu);
	else dst_hist->insert(neu);
	break;
    default:
	break;
    }
}

long Statistic::hist_get(int what, TOID neu)
{
    switch (what) {
    case HISTOGRAMM_SRC:
	if (!src_hist) return -1;
	else return src_hist->get(neu);
	break;
    case HISTOGRAMM_DST:
	if (!dst_hist) return -1;
	else return dst_hist->get(neu);
	break;
    default:
	return -1;
	break;
    }
}

Histogramm *Statistic::hist_walk(int what)
{
    switch (what) {
    case HISTOGRAMM_SRC:
	return src_hist;
	break;
    case HISTOGRAMM_DST:
	return dst_hist;
	break;
    default:
	return (Histogramm*)(NULL);
	break;
    }
}

void Statistic::hist_delete(int what)
{
    switch (what) {
    case HISTOGRAMM_SRC:
	if (src_hist) delete src_hist;
	src_hist = NULL;
	break;
    case HISTOGRAMM_DST:
	if (dst_hist) delete dst_hist;
	dst_hist = NULL;
	break;
    default:
	break;
    }
}


unsigned int hash(Statistic& s) 
{
  return (unsigned int) s.toid.GetId() % (STATISTICHASHINIT);
}



Histogramm::Histogramm(TOID neu) {
    toid = neu;
    next = NULL;
    anzahl = -1;
}

Histogramm::Histogramm(TOID neu, long anz) {
    toid = neu;
    next = NULL;
    anzahl = anz;
}

Histogramm::~Histogramm() {
    if (next) delete next;
}

int Histogramm::insert(TOID neu, long anz) {
    if (toid == neu) 
	return anzahl = anz;
    if (next == NULL)
    {
	next = new Histogramm(neu,anz);
	return anz;
    }
    next->insert(neu,anz);
    return anz;
}

int Histogramm::insert(TOID neu) {
    insert(neu,-1);
    return -1;
}

long Histogramm::get(TOID id) {
    if (toid == id) return anzahl;
    else if (next == NULL) return -1;
    else return next->get(id);
}

void Histogramm::get(TOID& id, long& count) {
    id = toid;
    count = anzahl;
}

Histogramm* Histogramm::walk() {
    return next;
}
