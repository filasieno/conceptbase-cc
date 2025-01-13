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
// This may look like C code, but it is really -*- C++ -*-
/* 
Copyright (C) 1988 Free Software Foundation
    written by Doug Lea (dl@rocky.oswego.edu)
    based on code by Marc Shapiro (shapiro@sor.inria.fr)

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
#include <iostream.h>
#include <builtin.h>
#include "Tupel.Plex.h"

// IChunk support

void TupelIChunk::error(const char* msg) const
{
  (*lib_error_handler)("TupelIChunk", msg);
}

void TupelIChunk::index_error() const
{
  error("attempt to use invalid index");
}

void TupelIChunk::empty_error() const
{
  error("invalid use of empty chunk");
}

void TupelIChunk::full_error() const
{
  error("attempt to extend chunk beyond bounds");
}

TupelIChunk:: ~TupelIChunk() {}

TupelIChunk::TupelIChunk(Tupel*     d,    
                     int      baseidx,
                     int      lowidx,
                     int      fenceidx,
                     int      topidx)
{
  if (d == 0 || baseidx > lowidx || lowidx > fenceidx || fenceidx > topidx)
    error("inconsistent specification");
  data = d;
  base = baseidx;
  low = lowidx;
  fence = fenceidx;
  top = topidx;
  nxt = prv = this;
}

void TupelIChunk:: re_index(int lo)
{
  int delta = lo - low;
  base += delta;
  low += delta;
  fence += delta;
  top += delta;
}


void TupelIChunk::clear(int lo)
{
  int s = top - base;
  low = base = fence = lo;
  top = base + s;
}

void TupelIChunk::cleardown(int hi)
{
  int s = top - base;
  low = top = fence = hi;
  base = top - s;
}

int TupelIChunk:: OK() const
{
  int v = data != 0;             // have some data
  v &= base <= low;              // ok, index-wise
  v &= low <= fence;
  v &= fence <= top;

  v &=  nxt->prv == this;      // and links are OK
  v &=  prv->nxt == this;
  if (!v) error("invariant failure");
  return(v);
}


// error handling


void TupelPlex::error(const char* msg) const
{
  (*lib_error_handler)("Plex", msg);
}

void TupelPlex::index_error() const
{
  error("attempt to access invalid index");
}

void TupelPlex::empty_error() const
{
  error("attempted operation on empty plex");
}

void TupelPlex::full_error() const
{
  error("attempt to increase size of plex past limit");
}

// generic plex ops

TupelPlex:: ~TupelPlex()
{
  invalidate();
}  


void TupelPlex::append (const TupelPlex& a)
{
  for (int i = a.low(); i < a.fence(); a.next(i)) add_high(a[i]);
}

void TupelPlex::prepend (const TupelPlex& a)
{
  for (int i = a.high(); i > a.ecnef(); a.prev(i)) add_low(a[i]);
}

void TupelPlex::reverse()
{
  Tupel tmp;
  int l = low();
  int h = high();
  while (l < h)
  {
    tmp = (*this)[l];
    (*this)[l] = (*this)[h];
    (*this)[h] = tmp;
    next(l);
    prev(h);
  }
}


void TupelPlex::fill(const Tupel  x)
{
  for (int i = lo; i < fnc; ++i) (*this)[i] = x;
}

void TupelPlex::fill(const Tupel  x, int lo, int hi)
{
  for (int i = lo; i <= hi; ++i) (*this)[i] = x;
}


void TupelPlex::del_chunk(TupelIChunk* x)
{
  if (x != 0)
  {
    x->unlink();
    Tupel* data = (Tupel*)(x->invalidate());
    delete [] data;
    delete x;
  }
}


void TupelPlex::invalidate()
{
  TupelIChunk* t = hd;
  if (t != 0)
  {
    TupelIChunk* tail = tl();
    while (t != tail)
    {
      TupelIChunk* nxt = t->next();
      del_chunk(t);
      t = nxt;
    } 
    del_chunk(t);
    hd = 0;
  }
}

int TupelPlex::reset_low(int l)
{
  int old = lo;
  int diff = l - lo;
  if (diff != 0)
  {
    lo += diff;
    fnc += diff;
    TupelIChunk* t = hd;
    do
    {
      t->re_index(t->low_index() + diff);
      t = t->next();
    } while (t != hd);
  }
  return old;
}




