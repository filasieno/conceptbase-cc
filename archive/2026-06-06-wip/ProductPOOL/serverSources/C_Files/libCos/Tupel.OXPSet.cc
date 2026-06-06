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
#include "tuple.OXPSet.h"


Pix TupelOXPSet::seek(Tupel  item)
{
  int l = p.low();
  int h = p.high();
  while (l <= h)
  {
    int mid = (l + h) / 2;
    int cmp = TupelCMP(item, p[mid]);
    if (cmp == 0)
      return p.index_to_Pix(mid);
    else if (cmp < 0)
      h = mid - 1;
    else
      l = mid + 1;
  }
  return 0;
}

Pix TupelOXPSet::add(Tupel  item)
{
  if (count == 0) 
  {
    ++count;
    return p.index_to_Pix(p.add_high(item));
  }
  int l = p.low();
  int h = p.high();
  while (l <= h)
  {
    int mid = (l + h) / 2;
    int cmp = TupelCMP(item, p[mid]);
    if (cmp == 0)
      return p.index_to_Pix(mid);
    else if (cmp < 0)
        h = mid - 1;
    else
      l = mid + 1;
  }
  // add on whichever side is shortest
  ++count;
  if (l == p.fence())
    return p.index_to_Pix(p.add_high(item));
  else if (l == p.low())
    return p.index_to_Pix(p.add_low(item));
  else 
  {
    if (p.fence() - l < l - p.low())
    {
      h = p.add_high(p.high_element());
      for (int i = h - 1; i > l; --i) p[i] = p[i-1];
    }
    else
    {
      --l;
      h = p.add_low(p.low_element());
      for (int i = h + 1; i < l; ++i) p[i] = p[i+1];
    }
    p[l] = item;
    return p.index_to_Pix(l);
  }
}

void TupelOXPSet::del(Tupel  item)
{
  int l = p.low();
  int h = p.high();
  while (l <= h)
  {
    int mid = (l + h) / 2;
    int cmp = TupelCMP(item, p[mid]);
    if (cmp == 0)
    {
      --count;
      if (p.high() - mid < mid - p.low())
      {
        for (int i = mid; i < p.high(); ++i) p[i] = p[i+1];
        p.del_high();
      }
      else
      {
        for (int i = mid; i > p.low(); --i) p[i] = p[i-1];
        p.del_low();
      }
      return;
    }
    else if (cmp < 0)
      h = mid - 1;
    else
      l = mid + 1;
  }
}

int TupelOXPSet::operator <= (TupelOXPSet& b)
{
  if (count > b.count) return 0;
  int i = p.low();
  int j = b.p.low();
  for (;;)
  {
    if (i >= p.fence())
      return 1;
    else if (j >= b.p.fence()) 
      return 0;
    int cmp = TupelCMP(p[i], b.p[j]);
    if (cmp == 0)
    {
      ++i; ++j;
    }
    else if (cmp < 0)
      return 0;
    else
      ++j;
  }
}

int TupelOXPSet::operator == (TupelOXPSet& b)
{
  int n = count;
  if (n != b.count) return 0;
  if (n == 0) return 1;
  int i = p.low();
  int j = b.p.low();
  while (n-- > 0) if (!TupelEQ(p[i++], b.p[j++])) return 0;
  return 1;
}


void TupelOXPSet::operator |= (TupelOXPSet& b)
{
  if (&b == this || b.count == 0)
    return;
  else if (b.count <= 2) // small b -- just add
    for (Pix i = b.first(); i; b.next(i)) add(b(i));
  else
  {
    // strategy: merge into top of p, simultaneously killing old bottom
    int oldfence = p.fence();
    int i = p.low();
    int j = b.p.low();
    for (;;)
    {
      if (i == oldfence)
      {
        while (j < b.p.fence()) p.add_high(b.p[j++]);
        break;
      }
      else if (j == b.p.fence())
      {
        while (i++ < oldfence) 
        {
          p.add_high(p.low_element());
          p.del_low();
        }
        break;
      }
      int cmp = TupelCMP(p[i], b.p[j]);
      if (cmp <= 0)
      {
        ++i;
        if (cmp == 0)  ++j;
        p.add_high(p.low_element());
        p.del_low();
      }
      else
        p.add_high(b.p[j++]);
    }
    count = p.length();
  }
}



void TupelOXPSet::operator -= (TupelOXPSet& b)
{
  if (&b == this)
    clear();
  else if (count != 0 && b.count != 0)
  {
    int i = p.low();
    int k = i;
    int j = b.p.low();
    int oldfence = p.fence();
    for (;;)
    {
      if (i >= oldfence)
        break;
      else if (j >= b.p.fence())
      {
        if (k != i)
          while (i < oldfence) p[k++] = p[i++];
        else
          k = oldfence;
        break;
      }
      int cmp = TupelCMP(p[i], b.p[j]);
      if (cmp == 0)
      {
        ++i; ++j;
      }
      else if (cmp < 0)
      {
        if (k != i) p[k] = p[i];
        ++i; ++k;
      }
      else
        j++;
    }
    while (k++ < oldfence)
    {
      --count;
      p.del_high();
    }
  }
}

void TupelOXPSet::operator &= (TupelOXPSet& b)
{
  if (b.count == 0)
    clear();
  else if (&b != this && count != 0)
  {
    int i = p.low();
    int k = i;
    int j = b.p.low();
    int oldfence = p.fence();
    for (;;)
    {
      if (i >= oldfence || j >= b.p.fence())
        break;
      int cmp = TupelCMP(p[i], b.p[j]);
      if (cmp == 0)
      {
        if (k != i) p[k] = p[i];
        ++i; ++k; ++j;
      }
      else if (cmp < 0)
        ++i;
      else
        ++j;
    }
    while (k++ < oldfence)
    {
      --count;
      p.del_high();
    }
  }
}

int TupelOXPSet::OK()
{
  int v = p.OK();
  v &= count == p.length();
  for (int i = p.low(); i < p.high(); ++i) v &= TupelCMP(p[i], p[i+1]) < 0;
  if (!v) error("invariant failure");
  return v;
}
