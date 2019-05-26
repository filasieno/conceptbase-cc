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
// This may look like C code, but it is really -*- C++ -*-
/* 
Copyright (C) 1988 Free Software Foundation
    written by Doug Lea (dl@rocky.oswego.edu)

This file is part of the GNU C++ Library.  This library is free
software; you can redistribute it and/or modify it under the terms of
the GNU Library General Public License as published by the Free
Software Foundation; either version 2 of the License, or (at your
option) any later version.  This library is distributed in the hope
that it will be useful, but WITHOUT ANY WARRANTY; without even the
implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
PURPOSE.  See the GNU Library General Public License for more details.
You should have received a copy of the GNU Library General Public
License along with this library; if not, write to the Free Software
Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.
*/

#ifdef __GNUG__
#pragma implementation
#endif
#include "SYMIDREF.CHSet.h"

// A CHSet is implemented as an array (tab) of buckets, each of which
// contains a pointer to a list of SYMIDREFCHNodes.  Each node contains a
// pointer to the next node in the list, and a pointer to the SYMIDREF.
// The end of the list is marked by a next node pointer which is odd
// when considered as an integer (least significant bit = 1).  The
// assumption is that CHNodes will all begin on even addresses.  If
// the odd pointer is right-shifted by one bit, it becomes the index
// within the tab array of the next bucket (that is, bucket i has
// next bucket pointer 2*(i+1)+1).

// The bucket pointers are initialized by the constructor and
// used to support the next(Pix&) method.

// This implementation is not portable to machines with different
// pointer and integer sizes, or on which CHNodes might be aligned on
// odd byte boundaries, but allows the same pointer to be used for
// chaining within a bucket and to the next bucket.


static inline int goodCHptr(SYMIDREFCHNode* t)
{
  return ((((unsigned)t) & 1) == 0);
}

static inline SYMIDREFCHNode* index_to_CHptr(int i)
{
  return (SYMIDREFCHNode*)((i << 1) + 1);
}

static inline int CHptr_to_index(SYMIDREFCHNode* t)
{
  return ( ((unsigned) t) >> 1);
}

SYMIDREFCHSet::SYMIDREFCHSet(unsigned int sz)
{
  tab = (SYMIDREFCHNode**)(new SYMIDREFCHNodePtr[size = sz]);
  for (unsigned int i = 0; i < size; ++i) tab[i] = index_to_CHptr(i+1);
  count = 0;
}

SYMIDREFCHSet::SYMIDREFCHSet(SYMIDREFCHSet& a)
{
  tab = (SYMIDREFCHNode**)(new SYMIDREFCHNodePtr[size = a.size]);
  for (unsigned int i = 0; i < size; ++i) tab[i] = index_to_CHptr(i+1);
  count = 0;
  for (Pix p = a.first(); p; a.next(p)) add(a(p));
}


Pix SYMIDREFCHSet::seek(SYMIDREF& key)
{
  unsigned int h = SYMIDREFHASH(key) % size;

  for (SYMIDREFCHNode* t = tab[h]; goodCHptr(t); t = t->tl)
    if (SYMIDREFEQ(key, t->hd))
      return Pix(t);

  return 0;
}


Pix SYMIDREFCHSet::add(SYMIDREF& item)
{
  unsigned int h = SYMIDREFHASH(item) % size;
  SYMIDREFCHNode* t;
  for (t = tab[h]; goodCHptr(t); t = t->tl)
    if (SYMIDREFEQ(item, t->hd))
      return Pix(t);

  ++count;
  t = new SYMIDREFCHNode(item, tab[h]);
  tab[h] = t;
  return Pix(t);
}


void SYMIDREFCHSet::del(SYMIDREF& key)
{
  unsigned int h = SYMIDREFHASH(key) % size;

  SYMIDREFCHNode* t = tab[h]; 
  SYMIDREFCHNode* trail = t;
  while (goodCHptr(t))
  {
    if (SYMIDREFEQ(key, t->hd))
    {
      if (trail == t)
        tab[h] = t->tl;
      else
        trail->tl = t->tl;
      delete t;
      --count;
      return;
    }
    trail = t;
    t = t->tl;
  }
}


void SYMIDREFCHSet::clear()
{
  for (unsigned int i = 0; i < size; ++i)
  {
    SYMIDREFCHNode* p = tab[i];
    tab[i] = index_to_CHptr(i+1);
    while (goodCHptr(p))
    {
      SYMIDREFCHNode* nxt = p->tl;
      delete(p);
      p = nxt;
    }
  }
  count = 0;
}

Pix SYMIDREFCHSet::first()
{
  for (unsigned int i = 0; i < size; ++i) if (goodCHptr(tab[i])) return Pix(tab[i]);
  return 0;
}

void SYMIDREFCHSet::next(Pix& p)
{
  if (p == 0) return;
  SYMIDREFCHNode* t = ((SYMIDREFCHNode*)p)->tl;
  if (goodCHptr(t))
    p = Pix(t);
  else
  {
    for (unsigned int i = CHptr_to_index(t); i < size; ++i) 
    {
      if (goodCHptr(tab[i]))
      {
        p =  Pix(tab[i]);
        return;
      }
    }
    p = 0;
  }
}

int SYMIDREFCHSet::operator == (SYMIDREFCHSet& b)
{
  if (count != b.count)
    return 0;
  else
  {
    SYMIDREFCHNode* p;
    unsigned int i;
    for (i = 0; i < size; ++i)
      for (p = tab[i]; goodCHptr(p); p = p->tl)
        if (b.seek(p->hd) == 0)
          return 0;
    for (i = 0; i < b.size; ++i)
      for (p = b.tab[i]; goodCHptr(p); p = p->tl)
        if (seek(p->hd) == 0)
          return 0;
    return 1;
  }
}

int SYMIDREFCHSet::operator <= (SYMIDREFCHSet& b)
{
  if (count > b.count)
    return 0;
  else
  {
    for (unsigned int i = 0; i < size; ++i)
      for (SYMIDREFCHNode* p = tab[i]; goodCHptr(p); p = p->tl)
        if (b.seek(p->hd) == 0)
          return 0;
    return 1;
  }
}

void SYMIDREFCHSet::operator |= (SYMIDREFCHSet& b)
{
  if (&b == this || b.count == 0)
    return;
  for (unsigned int i = 0; i < b.size; ++i)
    for (SYMIDREFCHNode* p = b.tab[i]; goodCHptr(p); p = p->tl)
      add(p->hd);
}

void SYMIDREFCHSet::operator &= (SYMIDREFCHSet& b)
{
  for (unsigned int i = 0; i < size; ++i)
  {
    SYMIDREFCHNode* t = tab[i]; 
    SYMIDREFCHNode* trail = t;
    while (goodCHptr(t))
    {
      SYMIDREFCHNode* nxt = t->tl;
      if (b.seek(t->hd) == 0)
      {
        if (trail == tab[i])
          trail = tab[i] = nxt;
        else
          trail->tl = nxt;
        delete t;
        --count;
      }
      else
        trail = t;
      t = nxt;
    }
  }
}

void SYMIDREFCHSet::operator -= (SYMIDREFCHSet& b)
{
  for (unsigned int i = 0; i < size; ++i)
  {
    SYMIDREFCHNode* t = tab[i]; 
    SYMIDREFCHNode* trail = t;
    while (goodCHptr(t))
    {
      SYMIDREFCHNode* nxt = t->tl;
      if (b.seek(t->hd) != 0)
      {
        if (trail == tab[i])
          trail = tab[i] = nxt;
        else
          trail->tl = nxt;
        delete t;
        --count;
      }
      else
        trail = t;
      t = nxt;
    }
  }
}

int SYMIDREFCHSet::OK()
{
  int v = tab != 0;
  int n = 0;
  for (unsigned int i = 0; i < size; ++i)
  {
      SYMIDREFCHNode* p;
      for (p = tab[i]; goodCHptr(p); p = p->tl) ++n;
      v &= (unsigned) CHptr_to_index(p) == (unsigned)(i + 1);
  }
  v &= count == n;
  if (!v) error("invariant failure");
  return v;
}
