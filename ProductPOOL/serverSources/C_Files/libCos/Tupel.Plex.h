/*
The ConceptBase.cc Copyright

Copyright 1987-2021 The ConceptBase Team. All rights reserved.

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

#ifndef _TupelPlex_h
#ifdef __GNUG__
#pragma interface
#endif
#define _TupelPlex_h 1

#include <std.h>
#include <Pix.h>
#include "Tupel.defs.h"

// Plexes are made out of TupelIChunks

#include <stddef.h>

class TupelIChunk
{
//public: // kludge until C++ `protected' policies settled
protected:      

  Tupel*           data;           // data, from client

  int            base;           // lowest possible index
  int            low;            // lowest valid index
  int            fence;          // highest valid index + 1
  int            top;            // highest possible index + 1

  TupelIChunk*     nxt;            // circular links
  TupelIChunk*     prv;

public:

// constructors

                 TupelIChunk(Tupel*     d,       // ptr to array of elements
                        int      base_idx, // initial indices
                        int      low_idx,  
                        int      fence_idx,
                        int      top_idx);

  virtual       ~TupelIChunk();

// status reports

  int            size() const;    // number of slots

  virtual int    empty() const ;
  virtual int    full() const ; 

  int            can_grow_high () const ;  // there is space to add data
  int            can_grow_low () const;        
  
  int            base_index() const;   // lowest possible index;
  int            low_index() const;    // lowest actual index;
  virtual int    first_index() const;  // lowest valid index or fence if none
  virtual int    last_index() const;   // highest valid index or low-1 if none
  int            fence_index() const;  // highest actual index + 1
  int            top_index() const;    // highest possible index + 1

// indexing conversion

  int            possible_index(int i) const; // i between base and top
  int            actual_index(int i) const;   // i between low and fence
  virtual int    valid_index(int i) const;    // i not deleted (mainly for mchunks)

  int            possible_pointer(const Tupel* p) const; // same for ptr
  int            actual_pointer(const Tupel* p) const; 
  virtual int    valid_pointer(const Tupel* p) const; 

  Tupel*           pointer_to(int i) const ;   // pointer to data indexed by i
                                      // caution: i is not checked for validity
  int            index_of(const Tupel* p) const; // index of data pointed to by p
                                      // caution: p is not checked for validity

  virtual int    succ(int idx) const;     // next valid index or fence if none
  virtual int    pred(int idx) const;     // previous index or low - 1 if none

  virtual Tupel*   first_pointer() const;   // pointer to first valid pos or 0
  virtual Tupel*   last_pointer() const;    // pointer to first valid pos or 0
  virtual Tupel*   succ(Tupel*  p) const;     // next pointer or 0
  virtual Tupel*   pred(Tupel* p) const;     // previous pointer or 0

// modification

  virtual Tupel*   grow_high ();      // return spot to add an element
  virtual Tupel*   grow_low ();  

  virtual void   shrink_high ();    // logically delete top index
  virtual void   shrink_low ();     

  virtual void   clear(int lo);     // reset to empty ch with base = lo
  virtual void   cleardown(int hi); // reset to empty ch with top = hi
  void           re_index(int lo);  // re-index so lo is new low

// chunk traversal

  TupelIChunk*     next() const;
  TupelIChunk*     prev() const;

  void           link_to_prev(TupelIChunk* prev);
  void           link_to_next(TupelIChunk* next);
  void           unlink();

// state checks

  Tupel*           invalidate();     // mark self as invalid; return data
                                   // for possible deletion

  virtual int    OK() const;             // representation invariant

  void   error(const char*) const;
  void   empty_error() const;
  void   full_error() const;
  void   index_error() const;
};

// TupelPlex is a partly `abstract' class: few of the virtuals
// are implemented at the Plex level, only in the subclasses

class TupelPlex
{
protected:      

  TupelIChunk*       hd;          // a chunk holding the data
  int              lo;          // lowest  index
  int              fnc;         // highest index + 1
  int              csize;       // size of the chunk

  void             invalidate();              // mark so OK() is false
  void             del_chunk(TupelIChunk*);        // delete a chunk

  TupelIChunk*       tl() const;                // last chunk;
  int              one_chunk() const;         // true if hd == tl()

public:

// constructors, etc.

                    TupelPlex();                  // no-op

  virtual           ~TupelPlex();

  
// Access functions 
    
  virtual Tupel&      operator [] (int idx) = 0; // access by index;
  virtual Tupel&      operator () (Pix p) = 0;   // access by Pix;

  virtual Tupel&      high_element () = 0;      // access high element
  virtual Tupel&      low_element () = 0;       // access low element

// read-only versions for const Plexes

  virtual const Tupel& operator [] (int idx) const = 0; // access by index;
  virtual const Tupel& operator () (Pix p) const = 0;   // access by Pix;

  virtual const Tupel& high_element () const = 0;      // access high element
  virtual const Tupel& low_element () const = 0;       // access low element


// Index functions

  virtual int       valid (int idx) const = 0;      // idx is an OK index

  virtual int       low() const = 0;         // lowest index or fence if none
  virtual int       high() const = 0;        // highest index or low-1 if none

  int               ecnef() const;         // low limit index (low-1)
  int               fence() const;         // high limit index (high+1)

  virtual void      prev(int& idx) const= 0; // set idx to preceding index
                                          // caution: pred may be out of bounds

  virtual void      next(int& idx) const = 0;       // set to next index
                                          // caution: succ may be out of bounds

  virtual Pix       first() const = 0;        // Pix to low element or 0
  virtual Pix       last() const = 0;         // Pix to high element or 0
  virtual void      prev(Pix& pix) const = 0;  // preceding pix or 0
  virtual void      next(Pix& pix) const = 0;  // next pix or 0
  virtual int       owns(Pix p) const = 0;     // p is an OK Pix

// index<->Pix 

  virtual int       Pix_to_index(Pix p) const = 0;   // get index via Pix
  virtual Pix       index_to_Pix(int idx) const = 0; // Pix via index

// Growth

  virtual int       add_high(const Tupel  elem) =0;// add new element at high end
                                                // return new high

  virtual int       add_low(const Tupel  elem) = 0;   // add new low element,
                                                // return new low

// Shrinkage

  virtual int       del_high() = 0;           // remove the element at high end
                                          // return new high
  virtual int       del_low() = 0;        // delete low element, return new lo

                                          // caution: del_low/high
                                          // does not necessarily 
                                          // immediately call Tupel::~Tupel


// operations on multiple elements

  virtual void      fill(const Tupel  x);          // set all elements = x
  virtual void      fill(const Tupel  x, int from, int to); // fill from to to
  virtual void      clear() = 0;                // reset to zero-sized Plex
  virtual int       reset_low(int newlow); // change low index,return old
  virtual void      reverse();                   // reverse in-place
  virtual void      append(const TupelPlex& a);    // concatenate a copy
  virtual void      prepend(const TupelPlex& a);   // prepend a copy

// status

  virtual int       can_add_high() const = 0;
  virtual int       can_add_low() const = 0;
  
  int               length () const;       // number of slots

  int               empty () const;        // is the plex empty?
  virtual int       full() const = 0;      // it it full?

  int               chunk_size() const;    // report chunk size;

  virtual int       OK() const = 0;        // representation invariant

  void		    error(const char* msg) const;
  void		    index_error() const;
  void		    empty_error() const;
  void		    full_error() const;
};


// TupelIChunk ops

inline int TupelIChunk:: size() const
{
  return top - base;
}


inline int TupelIChunk:: base_index() const
{
  return base;
}

inline  int TupelIChunk:: low_index() const
{
  return low;
}

inline  int  TupelIChunk:: fence_index() const
{
  return fence;
}

inline  int  TupelIChunk:: top_index() const
{
  return top;
}

inline  Tupel* TupelIChunk:: pointer_to(int i) const
{
  return &(data[i-base]);
}

inline  int  TupelIChunk:: index_of(const Tupel* p) const
{
  return ((int)p - (int)data) / sizeof(Tupel) + base;
}

inline  int  TupelIChunk:: possible_index(int i) const
{
  return i >= base && i < top;
}

inline  int  TupelIChunk:: possible_pointer(const Tupel* p) const
{
  return p >= data && p < &(data[top-base]);
}

inline  int  TupelIChunk:: actual_index(int i) const
{
  return i >= low && i < fence;
}

inline  int  TupelIChunk:: actual_pointer(const Tupel* p) const
{
  return p >= data && p < &(data[fence-base]);
}

inline  int  TupelIChunk:: can_grow_high () const
{
  return fence < top;
}

inline  int  TupelIChunk:: can_grow_low () const
{
  return base < low;
}

inline  Tupel* TupelIChunk:: invalidate()
{
  Tupel* p = data;
  data = 0;
  return p;
}


inline TupelIChunk* TupelIChunk::prev() const
{
  return prv;
}

inline TupelIChunk* TupelIChunk::next() const
{
  return nxt;
}

inline void TupelIChunk::link_to_prev(TupelIChunk* prev)
{
  nxt = prev->nxt;
  prv = prev;
  nxt->prv = this;
  prv->nxt = this;
}

inline void TupelIChunk::link_to_next(TupelIChunk* next)
{
  prv = next->prv;
  nxt = next;
  nxt->prv = this;
  prv->nxt = this;
}

inline void TupelIChunk::unlink()
{
  TupelIChunk* n = nxt;
  TupelIChunk* p = prv;
  n->prv = p;
  p->nxt = n;
  prv = nxt = this;
}

inline  int TupelIChunk:: empty() const
{
  return low == fence;
}

inline  int  TupelIChunk:: full() const
{
  return top - base == fence - low;
}

inline int TupelIChunk:: first_index() const
{
  return (low == fence)? fence : low;
}

inline int TupelIChunk:: last_index() const
{
  return (low == fence)? low - 1 : fence - 1;
}

inline  int  TupelIChunk:: succ(int i) const
{
  return (i < low) ? low : i + 1;
}

inline  int  TupelIChunk:: pred(int i) const
{
  return (i > fence) ? (fence - 1) : i - 1;
}

inline  int  TupelIChunk:: valid_index(int i) const
{
  return i >= low && i < fence;
}

inline  int  TupelIChunk:: valid_pointer(const Tupel* p) const
{
  return p >= &(data[low - base]) && p < &(data[fence - base]);
}

inline  Tupel* TupelIChunk:: grow_high ()
{
  if (!can_grow_high()) full_error();
  return &(data[fence++ - base]);
}

inline  Tupel* TupelIChunk:: grow_low ()
{
  if (!can_grow_low()) full_error();
  return &(data[--low - base]);
}

inline  void TupelIChunk:: shrink_high ()
{
  if (empty()) empty_error();
  --fence;
}

inline  void TupelIChunk:: shrink_low ()
{
  if (empty()) empty_error();
  ++low;
}

inline Tupel* TupelIChunk::first_pointer() const
{
  return (low == fence)? 0 : &(data[low - base]);
}

inline Tupel* TupelIChunk::last_pointer() const
{
  return (low == fence)? 0 : &(data[fence - base - 1]);
}

inline Tupel* TupelIChunk::succ(Tupel* p) const
{
  return ((p+1) <  &(data[low - base]) || (p+1) >= &(data[fence - base])) ? 
    0 : (p+1);
}

inline Tupel* TupelIChunk::pred(Tupel* p) const
{
  return ((p-1) <  &(data[low - base]) || (p-1) >= &(data[fence - base])) ? 
    0 : (p-1);
}


// generic Plex operations

inline TupelPlex::TupelPlex() {}

inline int TupelPlex::chunk_size() const
{
  return csize;
}

inline  int TupelPlex::ecnef () const
{
  return lo - 1;
}


inline  int TupelPlex::fence () const
{
  return fnc;
}

inline int TupelPlex::length () const
{
  return fnc - lo;
}

inline  int TupelPlex::empty () const
{
  return fnc == lo;
}

inline TupelIChunk* TupelPlex::tl() const
{
  return hd->prev();
}

inline int TupelPlex::one_chunk() const
{
  return hd == hd->prev();
}

#endif
