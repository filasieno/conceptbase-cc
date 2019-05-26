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


#ifndef _SYMIDREFSet_h
#ifdef __GNUG__
#pragma interface
#endif
#define _SYMIDREFSet_h 1

#include <Pix.h>
#include "SYMIDREF.defs.h"

class SYMIDREFSet
{
protected:

  int                   count;

public:
  virtual              ~SYMIDREFSet();

  int                   length();                // current number of items
  int                   empty();

  virtual Pix           add(SYMIDREF& item) = 0;      // add item; return Pix
  virtual void          del(SYMIDREF& item) = 0;      // delete item
  virtual int           contains(SYMIDREF& item);     // is item in set?

  virtual void          clear();                 // delete all items

  virtual Pix           first() = 0;             // Pix of first item or 0
  virtual void          next(Pix& i) = 0;        // advance to next or 0
  virtual SYMIDREF&          operator () (Pix i) = 0; // access item at i

  virtual int           owns(Pix i);             // is i a valid Pix  ?
  virtual Pix           seek(SYMIDREF& item);         // Pix of item

  void                  operator |= (SYMIDREFSet& b); // add all items in b
  void                  operator -= (SYMIDREFSet& b); // delete items also in b
  void                  operator &= (SYMIDREFSet& b); // delete items not in b

  int                   operator == (SYMIDREFSet& b);
  int                   operator != (SYMIDREFSet& b);
  int                   operator <= (SYMIDREFSet& b); 

  void                  error(const char* msg);
  virtual int           OK() = 0;                // rep invariant
};

inline SYMIDREFSet::~SYMIDREFSet() {}

inline int SYMIDREFSet::length()
{
  return count;
}

inline int SYMIDREFSet::empty()
{
  return count == 0;
}

#endif
