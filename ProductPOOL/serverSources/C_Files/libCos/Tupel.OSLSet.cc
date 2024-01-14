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
#include "Tupel.OSLSet.h"


Pix TupelOSLSet::seek(Tupel  item)
{
  for (Pix i = p.first(); i != 0; p.next(i))
  {
    int cmp = TupelCMP(item, p(i));
    if (cmp == 0)
      return i;
    else if (cmp < 0)
      return 0;
  }
  return 0;
}

Pix TupelOSLSet::add(Tupel  item)
{

  Pix i = p.first();
  if (i == 0) 
  {
    ++count;
    return p.prepend(item);
  }
  int cmp = TupelCMP(item, p(i));
  if (cmp == 0)
    return i;
  else if (cmp < 0)
  {
    ++count;
    return p.prepend(item);
  }
  else
  {
    Pix trail = i;
    p.next(i);
    for (;;)
    {
      if (i == 0)
      {
        ++count;
        return p.append(item);
      }
      cmp = TupelCMP(item, p(i));
      if (cmp == 0)
        return i;
      else if (cmp < 0)
      {
        ++count;
        return p.ins_after(trail, item);
      }
      else
      {
        trail = i;
        p.next(i);
      }
    }
  }
}

void TupelOSLSet::del(Tupel  item)
{
  Pix i = p.first();
  if (i == 0)
    return;
  int cmp = TupelCMP(item, p(i));
  if (cmp < 0)
    return;
  else if (cmp == 0)
  {
    --count;
    p.del_front();
  }
  else
  {
    Pix trail = i;
    p.next(i);
    while (i != 0)
    {
      cmp = TupelCMP(item, p(i));
      if (cmp < 0)
        return;
      else if (cmp == 0)
      {
        --count;
        p.del_after(trail);
        return;
      }
      else
      {
        trail = i;
        p.next(i);
      }
    }
  }
}
        

int TupelOSLSet::operator <= (TupelOSLSet& b)
{
  if (count > b.count) return 0;
  Pix i = first();
  Pix j = b.first();
  for (;;)
  {
    if (i == 0)
      return 1;
    else if (j == 0)
      return 0;
    int cmp = TupelCMP(p(i), b.p(j));
    if (cmp == 0)
    {
      next(i); b.next(j);
    }
    else if (cmp < 0)
      return 0;
    else
      b.next(j);
  }
}

int TupelOSLSet::operator == (TupelOSLSet& b)
{
  if (count != b.count) return 0;
  if (count == 0) return 1;
  Pix i = p.first();
  Pix j = b.p.first();
  while (i != 0)
  {
    if (!TupelEQ(p(i),b.p(j))) return 0;
    next(i);
    b.next(j);
  }
  return 1;
}


void TupelOSLSet::operator |= (TupelOSLSet& b)
{
  if (&b == this || b.count == 0)
    return;
  else
  {
    Pix j = b.p.first();
    Pix i = p.first();
    Pix trail = 0;
    for (;;)
    {
      if (j == 0)
        return;
      else if (i == 0)
      {
        for (; j != 0; b.next(j))
        {
          ++count;
          p.append(b.p(j));
        }
        return;
      }
      int cmp = TupelCMP(p(i), b.p(j));
      if (cmp <= 0)
      {
        if (cmp == 0) b.next(j);
        trail = i;
        next(i);
      }
      else
      {
        ++count;
        if (trail == 0)
          trail = p.prepend(b.p(j));
        else
          trail = p.ins_after(trail, b.p(j));
        b.next(j);
      }
    }
  }
}


void TupelOSLSet::operator -= (TupelOSLSet& b)
{
  if (&b == this)
    clear();
  else if (count != 0 && b.count != 0)
  {
    Pix i = p.first();
    Pix j = b.p.first();
    Pix trail = 0;
    for (;;)
    {
      if (j == 0 || i == 0)
        return;
      int cmp = TupelCMP(p(i), b.p(j));
      if (cmp == 0)
      {
        --count;
        b.next(j);
        if (trail == 0)
        {
          p.del_front();
          i = p.first();
        }
        else
        {
          next(i);
          p.del_after(trail);
        }
      }
      else if (cmp < 0)
      {
        trail = i;
        next(i);
      }
      else
        b.next(j);
    }
  }
}

void TupelOSLSet::operator &= (TupelOSLSet& b)
{
  if (b.count == 0)
    clear();
  else if (&b != this && count != 0)
  {
    Pix i = p.first();
    Pix j = b.p.first();
    Pix trail = 0;
    for (;;)
    {
      if (i == 0)
        return;
      else if (j == 0)
      {
        if (trail == 0)
        {
          p.clear();
          count = 0;
        }
        else
        {
          while (i != 0)
          {
            --count;
            next(i);
            p.del_after(trail);
          }
        }
        return;
      }
      int cmp = TupelCMP(p(i), b.p(j));

      if (cmp == 0)
      {
        trail = i;
        next(i);
        b.next(j);
      }
      else if (cmp < 0)
      {
        --count;
        if (trail == 0)
        {
          p.del_front();
          i = p.first();
        }
        else
        {
          next(i);
          p.del_after(trail);
        }
      }
      else
        b.next(j);
    }
  }
}


int TupelOSLSet::OK()
{
  int v = p.OK();
  v &= count == p.length();
  Pix trail = p.first();
  if (trail == 0)
    v &= count == 0;
  else
  {
    Pix i = trail; next(i);
    while (i != 0)
    {
      v &= TupelCMP(p(trail), p(i)) < 0;
      trail = i;
      next(i);
    }
  }
  if (!v) error("invariant failure");
  return v;
}

void TupelOSLSet::test()
{
    printf("[");
    for (Pix ind=first();ind;next(ind))
    {
        (*this)(ind).test();
        printf(" ");
    }
    printf("](%d)\n",length());
    
}
