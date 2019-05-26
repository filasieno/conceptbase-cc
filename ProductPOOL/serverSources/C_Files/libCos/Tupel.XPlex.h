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

#ifndef _TupelXPlex_h
#ifdef __GNUG__
#pragma interface
#endif
#define _TupelXPlex_h 1

#include "Tupel.Plex.h"

class TupelXPlex: public TupelPlex
{
  TupelIChunk*       ch;           // cached chunk

  void             make_initial_chunks(int up = 1);

  void             cache(int idx) const;
  void             cache(const Tupel* p) const;

  Tupel*             dopred(const Tupel* p) const;
  Tupel*             dosucc(const Tupel* p) const;

  void             set_cache(const TupelIChunk* t) const; // logically, 
                                               // not physically const
public:
                   TupelXPlex();                 // set low = 0;
                                               // fence = 0;
                                               // csize = default

                   TupelXPlex(int ch_size);      // low = 0; 
                                               // fence = 0;
                                               // csize = ch_size

                   TupelXPlex(int lo,            // low = lo; 
                            int ch_size);      // fence=lo
                                               // csize = ch_size

                   TupelXPlex(int lo,            // low = lo
                            int hi,            // fence = hi+1
                            const Tupel  initval,// fill with initval,
                            int ch_size = 0);  // csize= ch_size
                                               // or fence-lo if 0

                   TupelXPlex(const TupelXPlex&);
  
  void             operator= (const TupelXPlex&);

// virtuals


  Tupel&             high_element ();
  Tupel&             low_element ();

  const Tupel&       high_element () const;
  const Tupel&       low_element () const;

  Pix              first() const;
  Pix              last() const;
  void             prev(Pix& ptr) const;
  void             next(Pix& ptr) const;
  int              owns(Pix p) const;
  Tupel&             operator () (Pix p);
  const Tupel&       operator () (Pix p) const;

  int              low() const; 
  int              high() const;
  int              valid(int idx) const;
  void             prev(int& idx) const;
  void             next(int& x) const;
  Tupel&             operator [] (int index);
  const Tupel&       operator [] (int index) const;
    
  int              Pix_to_index(Pix p) const;
  Pix              index_to_Pix(int idx) const;    

  int              can_add_high() const;
  int              can_add_low() const;
  int              full() const;

  int              add_high(const Tupel  elem);
  int              del_high ();
  int              add_low (const Tupel  elem);
  int              del_low ();

  void             fill(const Tupel  x);
  void             fill(const Tupel  x, int from, int to);
  void             clear();
  void             reverse();
    
  int              OK () const; 

};


inline void TupelXPlex::prev(int& idx) const
{
  --idx;
}

inline void TupelXPlex::next(int& idx) const
{
  ++idx;
}

inline  int TupelXPlex::full () const
{
  return 0;
}

inline int TupelXPlex::can_add_high() const
{
  return 1;
}

inline int TupelXPlex::can_add_low() const
{
  return 1;
}

inline  int TupelXPlex::valid (int idx) const
{
  return idx >= lo && idx < fnc;
}

inline int TupelXPlex::low() const
{
  return lo;
}

inline int TupelXPlex::high() const
{
  return fnc - 1;
}

inline Tupel& TupelXPlex:: operator [] (int idx)
{
  if (!ch->actual_index(idx)) cache(idx);
  return *(ch->pointer_to(idx));
}

inline const Tupel& TupelXPlex:: operator [] (int idx) const
{
  if (!ch->actual_index(idx)) cache(idx);
  return *((const Tupel*)(ch->pointer_to(idx)));
}

inline  Tupel& TupelXPlex::low_element ()
{
  if (empty()) index_error();
  return *(hd->pointer_to(lo));
}

inline  const Tupel& TupelXPlex::low_element () const
{
  if (empty()) index_error();
  return *((const Tupel*)(hd->pointer_to(lo)));
}

inline  Tupel& TupelXPlex::high_element ()
{
  if (empty()) index_error();
  return *(tl()->pointer_to(fnc - 1));
}

inline const Tupel& TupelXPlex::high_element () const
{
  if (empty()) index_error();
  return *((const Tupel*)(tl()->pointer_to(fnc - 1)));
}

inline  int TupelXPlex::Pix_to_index(Pix px) const
{
  Tupel* p = (Tupel*)px;
  if (!ch->actual_pointer(p)) cache(p);
  return ch->index_of(p);
}

inline  Pix TupelXPlex::index_to_Pix(int idx) const
{
  if (!ch->actual_index(idx)) cache(idx);
  return (Pix)(ch->pointer_to(idx));
}

inline Pix TupelXPlex::first() const
{
  return Pix(hd->TupelIChunk::first_pointer());
}

inline Pix TupelXPlex::last() const
{
  return Pix(tl()->TupelIChunk::last_pointer());
}

inline void TupelXPlex::prev(Pix& p) const
{
  Pix q = Pix(ch->TupelIChunk::pred((Tupel*) p));
  p = (q == 0)? Pix(dopred((const Tupel*) p)) : q;
}

inline void TupelXPlex::next(Pix& p) const
{
  Pix q = Pix(ch->TupelIChunk::succ((Tupel*) p));
  p = (q == 0)? Pix(dosucc((const Tupel*)p)) : q;
}

inline Tupel& TupelXPlex:: operator () (Pix p)
{
  return *((Tupel*)p);
}

inline const Tupel& TupelXPlex:: operator () (Pix p) const
{
  return *((const Tupel*)p);
}

inline void TupelXPlex::set_cache(const TupelIChunk* t) const
{
  ((TupelXPlex*)(this))->ch = (TupelIChunk*)t;
}

#endif
