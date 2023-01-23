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


#ifndef _StatisticCHSet_h
#ifdef __GNUG__
#pragma interface
#endif
#define _StatisticCHSet_h 1

#include "Statistic.Set.h"
#include "Statistic.CHNode.h"

class StatisticCHSet : public StatisticSet
{
protected:
  StatisticCHNode**   tab;
  unsigned int  size;

public:
                StatisticCHSet(unsigned int sz = DEFAULT_INITIAL_CAPACITY);
                StatisticCHSet(StatisticCHSet& a);
                ~StatisticCHSet();

  Pix           add(Statistic& item);
  void          del(Statistic& item);
  int           contains(Statistic& item);

  void          clear();

  Pix           first();
  void          next(Pix& i);
  Statistic&          operator () (Pix i);
  Pix           seek(Statistic& item);

  void          operator |= (StatisticCHSet& b);
  void          operator -= (StatisticCHSet& b);
  void          operator &= (StatisticCHSet& b);

  int           operator == (StatisticCHSet& b);
  int           operator != (StatisticCHSet& b);
  int           operator <= (StatisticCHSet& b); 

  int           OK();
};

inline StatisticCHSet::~StatisticCHSet()
{
  clear();
  delete tab;
}

inline int StatisticCHSet::contains(Statistic& key)
{
  return seek(key) != 0;
}

inline Statistic& StatisticCHSet::operator () (Pix i)
{
  if (i == 0) error("null Pix");
  return ((StatisticCHNode*)i)->hd;
}

inline int StatisticCHSet::operator != (StatisticCHSet& b)
{
  return ! ((*this) == b);
}

#endif
