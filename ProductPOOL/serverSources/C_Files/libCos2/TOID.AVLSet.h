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


#ifndef _TOIDAVL_h
#ifdef __GNUG__
#pragma interface
#endif
#define _TOIDAVL_h 1

#include "TOID.Set.h"

struct TOIDAVLNode
{
  TOID                 item;
  TOIDAVLNode*         lt;
  TOIDAVLNode*         rt;
  char                stat;
                      TOIDAVLNode(TOID& h, TOIDAVLNode* l=0, TOIDAVLNode* r=0);
                      ~TOIDAVLNode();
};

inline TOIDAVLNode::TOIDAVLNode(TOID& h, TOIDAVLNode* l, TOIDAVLNode* r)
:item(h), lt(l), rt(r), stat(0) {}

inline TOIDAVLNode::~TOIDAVLNode() {}

typedef TOIDAVLNode* TOIDAVLNodePtr;


class TOIDAVLSet : public TOIDSet
{
protected:
  TOIDAVLNode*   root;

                TOIDAVLSet(TOIDAVLNode* p, int l);

  TOIDAVLNode*   leftmost();
  TOIDAVLNode*   rightmost();
  TOIDAVLNode*   pred(TOIDAVLNode* t);
  TOIDAVLNode*   succ(TOIDAVLNode* t);
  void          _kill(TOIDAVLNode* t);
  void          _add(TOIDAVLNode*& t);
  void          _del(TOIDAVLNode* p, TOIDAVLNode*& t);

public:
                TOIDAVLSet();
                TOIDAVLSet(TOIDAVLSet& a);
                ~TOIDAVLSet();

  Pix           add(TOID& item);
  void          del(TOID& item);
  int           contains(TOID& item);

  void          clear();

  Pix           first();
  void          next(Pix& i);
  TOID&          operator () (Pix i);
  int           owns(Pix i);
  Pix           seek(TOID& item);

  Pix           last();
  void          prev(Pix& i);

  void          operator |= (TOIDAVLSet& b);
  void          operator -= (TOIDAVLSet& b);
  void          operator &= (TOIDAVLSet& b);

  int           operator == (TOIDAVLSet& b);
  int           operator != (TOIDAVLSet& b);
  int           operator <= (TOIDAVLSet& b); 

  int           OK();
};

inline TOIDAVLSet::~TOIDAVLSet()
{
  _kill(root);
}

inline TOIDAVLSet::TOIDAVLSet()
{
  root = 0;
  count = 0;
}

inline TOIDAVLSet::TOIDAVLSet(TOIDAVLNode* p, int l)
{
  root = p;
  count = l;
}

inline int TOIDAVLSet::operator != (TOIDAVLSet& b)
{
  return ! ((*this) == b);
}

inline Pix TOIDAVLSet::first()
{
  return Pix(leftmost());
}

inline Pix TOIDAVLSet::last()
{
  return Pix(rightmost());
}

inline void TOIDAVLSet::next(Pix& i)
{
  if (i != 0) i = Pix(succ((TOIDAVLNode*)i));
}

inline void TOIDAVLSet::prev(Pix& i)
{
  if (i != 0) i = Pix(pred((TOIDAVLNode*)i));
}

inline TOID& TOIDAVLSet::operator () (Pix i)
{
  if (i == 0) error("null Pix");
  return ((TOIDAVLNode*)i)->item;
}

inline void TOIDAVLSet::clear()
{
  _kill(root);
  count = 0;
  root = 0;
}

inline int TOIDAVLSet::contains(TOID& key)
{
  return seek(key) != 0;
}

#endif
