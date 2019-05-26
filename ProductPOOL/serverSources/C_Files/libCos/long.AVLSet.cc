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
#include <iostream.h>
#include "long.AVLSet.h"
#include <stdlib.h>


/*
 constants & inlines for maintaining balance & thread status in tree nodes
*/

#define AVLBALANCEMASK    3
#define AVLBALANCED       0
#define AVLLEFTHEAVY      1
#define AVLRIGHTHEAVY     2

#define LTHREADBIT        4
#define RTHREADBIT        8


static inline int bf(longAVLNode* t)
{
  return t->stat & AVLBALANCEMASK;
}

static inline void set_bf(longAVLNode* t, int b)
{
  t->stat = (t->stat & ~AVLBALANCEMASK) | (b & AVLBALANCEMASK);
}


static inline int rthread(longAVLNode* t)
{
  return t->stat & RTHREADBIT;
}

static inline void set_rthread(longAVLNode* t, int b)
{
  if (b)
    t->stat |= RTHREADBIT;
  else
    t->stat &= ~RTHREADBIT;
}

static inline int lthread(longAVLNode* t)
{
  return t->stat & LTHREADBIT;
}

static inline void set_lthread(longAVLNode* t, int b)
{
  if (b)
    t->stat |= LTHREADBIT;
  else
    t->stat &= ~LTHREADBIT;
}

/*
 traversal primitives
*/


longAVLNode* longAVLSet::leftmost()
{
  longAVLNode* t = root;
  if (t != 0) while (t->lt != 0) t = t->lt;
  return t;
}

longAVLNode* longAVLSet::rightmost()
{
  longAVLNode* t = root;
  if (t != 0) while (t->rt != 0) t = t->rt;
  return t;
}

longAVLNode* longAVLSet::succ(longAVLNode* t)
{
  longAVLNode* r = t->rt;
  if (!rthread(t)) while (!lthread(r)) r = r->lt;
  return r;
}

longAVLNode* longAVLSet::pred(longAVLNode* t)
{
  longAVLNode* l = t->lt;
  if (!lthread(t)) while (!rthread(l)) l = l->rt;
  return l;
}


Pix longAVLSet::seek(long  key)
{
  longAVLNode* t = root;
  if (t == 0)
    return 0;
  for (;;)
  {
    int cmp = longCMP(key, t->item);
    if (cmp == 0)
      return Pix(t);
    else if (cmp < 0)
    {
      if (lthread(t))
        return 0;
      else
        t = t->lt;
    }
    else if (rthread(t))
      return 0;
    else
      t = t->rt;
  }
}


/*
 The combination of threads and AVL bits make adding & deleting
 interesting, but very awkward.

 We use the following statics to avoid passing them around recursively
*/

static int _need_rebalancing;   // to send back balance info from rec. calls
static long*   _target_item;     // add/del_item target
static longAVLNode* _found_node; // returned added/deleted node
static int    _already_found;   // for deletion subcases

static longAVLNode** _hold_nodes;       // used for rebuilding trees
static int  _max_hold_index;              // # elements-1 in _hold_nodes


void longAVLSet:: _add(longAVLNode*& t)
{
  int cmp = longCMP(*_target_item, t->item);
  if (cmp == 0)
  {
    _found_node = t;
    return;
  }
  else if (cmp < 0)
  {
    if (lthread(t))
    {
      ++count;
      _found_node = new longAVLNode(*_target_item);
      set_lthread(_found_node, 1);
      set_rthread(_found_node, 1);
      _found_node->lt = t->lt;
      _found_node->rt = t;
      t->lt = _found_node;
      set_lthread(t, 0);
      _need_rebalancing = 1;
    }
    else
      _add(t->lt);
    if (_need_rebalancing)
    {
      switch(bf(t))
      {
      case AVLRIGHTHEAVY:
        set_bf(t, AVLBALANCED);
        _need_rebalancing = 0;
        return;
      case AVLBALANCED:
        set_bf(t, AVLLEFTHEAVY);
        return;
      case AVLLEFTHEAVY:
	{
        longAVLNode* l = t->lt;
        if (bf(l) == AVLLEFTHEAVY)
        {
          if (rthread(l))
            t->lt = l;
          else
            t->lt = l->rt;
          set_lthread(t, rthread(l));
          l->rt = t;
          set_rthread(l, 0);
          set_bf(t, AVLBALANCED);
          set_bf(l, AVLBALANCED);
          t = l;
          _need_rebalancing = 0;
        }
        else
        {
          longAVLNode* r = l->rt;
          set_rthread(l, lthread(r));
          if (lthread(r))
            l->rt = r;
          else
            l->rt = r->lt;
          r->lt = l;
          set_lthread(r, 0);
          set_lthread(t, rthread(r));
          if (rthread(r))
            t->lt = r;
          else
            t->lt = r->rt;
          r->rt = t;
          set_rthread(r, 0);
          if (bf(r) == AVLLEFTHEAVY)
            set_bf(t, AVLRIGHTHEAVY);
          else
            set_bf(t, AVLBALANCED);
          if (bf(r) == AVLRIGHTHEAVY)
            set_bf(l, AVLLEFTHEAVY);
          else
            set_bf(l, AVLBALANCED);
          set_bf(r, AVLBALANCED);
          t = r;
          _need_rebalancing = 0;
          return;
        }
	}
      }
    }
  }
  else
  {
    if (rthread(t))
    {
      ++count;
      _found_node = new longAVLNode(*_target_item);
      set_rthread(t, 0);
      set_lthread(_found_node, 1);
      set_rthread(_found_node, 1);
      _found_node->lt = t;
      _found_node->rt = t->rt;
      t->rt = _found_node;
      _need_rebalancing = 1;
    }
    else
      _add(t->rt);
    if (_need_rebalancing)
    {
      switch(bf(t))
      {
      case AVLLEFTHEAVY:
        set_bf(t, AVLBALANCED);
        _need_rebalancing = 0;
        return;
      case AVLBALANCED:
        set_bf(t, AVLRIGHTHEAVY);
        return;
      case AVLRIGHTHEAVY:
	{
        longAVLNode* r = t->rt;
        if (bf(r) == AVLRIGHTHEAVY)
        {
          if (lthread(r))
            t->rt = r;
          else
            t->rt = r->lt;
          set_rthread(t, lthread(r));
          r->lt = t;
          set_lthread(r, 0);
          set_bf(t, AVLBALANCED);
          set_bf(r, AVLBALANCED);
          t = r;
          _need_rebalancing = 0;
        }
        else
        {
          longAVLNode* l = r->lt;
          set_lthread(r, rthread(l));
          if (rthread(l))
            r->lt = l;
          else
            r->lt = l->rt;
          l->rt = r;
          set_rthread(l, 0);
          set_rthread(t, lthread(l));
          if (lthread(l))
            t->rt = l;
          else
            t->rt = l->lt;
          l->lt = t;
          set_lthread(l, 0);
          if (bf(l) == AVLRIGHTHEAVY)
            set_bf(t, AVLLEFTHEAVY);
          else
            set_bf(t, AVLBALANCED);
          if (bf(l) == AVLLEFTHEAVY)
            set_bf(r, AVLRIGHTHEAVY);
          else
            set_bf(r, AVLBALANCED);
          set_bf(l, AVLBALANCED);
          t = l;
          _need_rebalancing = 0;
          return;
        }
	}
      }
    }
  }
}

    
Pix longAVLSet::add(long  item)
{
  if (root == 0)
  {
    ++count;
    root = new longAVLNode(item);
    set_rthread(root, 1);
    set_lthread(root, 1);
    return Pix(root);
  }
  else
  {
    _target_item = &item;
    _need_rebalancing = 0;
    _add(root);
    return Pix(_found_node);
  }
}


void longAVLSet::_del(longAVLNode* par, longAVLNode*& t)
{
  int comp;
  if (_already_found)
  {
    if (rthread(t))
      comp = 0;
    else
      comp = 1;
  }
  else 
    comp = longCMP(*_target_item, t->item);
  if (comp == 0)
  {
    if (lthread(t) && rthread(t))
    {
      _found_node = t;
      if (t == par->lt)
      {
        set_lthread(par, 1);
        par->lt = t->lt;
      }
      else
      {
        set_rthread(par, 1);
        par->rt = t->rt;
      }
      _need_rebalancing = 1;
      return;
    }
    else if (lthread(t))
    {
      _found_node = t;
      longAVLNode* s = succ(t);
      if (s != 0 && lthread(s))
        s->lt = t->lt;
      t = t->rt;
      _need_rebalancing = 1;
      return;
    }
    else if (rthread(t))
    {
      _found_node = t;
      longAVLNode* p = pred(t);
      if (p != 0 && rthread(p))
        p->rt = t->rt;
      t = t->lt;
      _need_rebalancing = 1;
      return;
    }
    else                        // replace item & find someone deletable
    {
      longAVLNode* p = pred(t);
      t->item = p->item;
      _already_found = 1;
      comp = -1;                // fall through below to left
    }
  }

  if (comp < 0)
  {
    if (lthread(t))
      return;
    _del(t, t->lt);
    if (!_need_rebalancing)
      return;
    switch (bf(t))
    {
    case AVLLEFTHEAVY:
      set_bf(t, AVLBALANCED);
      return;
    case AVLBALANCED:
      set_bf(t, AVLRIGHTHEAVY);
      _need_rebalancing = 0;
      return;
    case AVLRIGHTHEAVY:
      {
      longAVLNode* r = t->rt;
      switch (bf(r))
      {
      case AVLBALANCED:
        if (lthread(r))
          t->rt = r;
        else
          t->rt = r->lt;
        set_rthread(t, lthread(r));
        r->lt = t;
        set_lthread(r, 0);
        set_bf(t, AVLRIGHTHEAVY);
        set_bf(r, AVLLEFTHEAVY);
        _need_rebalancing = 0;
        t = r;
        return;
      case AVLRIGHTHEAVY:
        if (lthread(r))
          t->rt = r;
        else
          t->rt = r->lt;
        set_rthread(t, lthread(r));
        r->lt = t;
        set_lthread(r, 0);
        set_bf(t, AVLBALANCED);
        set_bf(r, AVLBALANCED);
        t = r;
        return;
      case AVLLEFTHEAVY:
	{
        longAVLNode* l = r->lt;
        set_lthread(r, rthread(l));
        if (rthread(l))
          r->lt = l;
        else
          r->lt = l->rt;
        l->rt = r;
        set_rthread(l, 0);
        set_rthread(t, lthread(l));
        if (lthread(l))
          t->rt = l;
        else
          t->rt = l->lt;
        l->lt = t;
        set_lthread(l, 0);
        if (bf(l) == AVLRIGHTHEAVY)
          set_bf(t, AVLLEFTHEAVY);
        else
          set_bf(t, AVLBALANCED);
        if (bf(l) == AVLLEFTHEAVY)
          set_bf(r, AVLRIGHTHEAVY);
        else
          set_bf(r, AVLBALANCED);
        set_bf(l, AVLBALANCED);
        t = l;
        return;
	}
      }
    }
    }
  }
  else
  {
    if (rthread(t))
      return;
    _del(t, t->rt);
    if (!_need_rebalancing)
      return;
    switch (bf(t))
    {
    case AVLRIGHTHEAVY:
      set_bf(t, AVLBALANCED);
      return;
    case AVLBALANCED:
      set_bf(t, AVLLEFTHEAVY);
      _need_rebalancing = 0;
      return;
    case AVLLEFTHEAVY:
      {
      longAVLNode* l = t->lt;
      switch (bf(l))
      {
      case AVLBALANCED:
        if (rthread(l))
          t->lt = l;
        else
          t->lt = l->rt;
        set_lthread(t, rthread(l));
        l->rt = t;
        set_rthread(l, 0);
        set_bf(t, AVLLEFTHEAVY);
        set_bf(l, AVLRIGHTHEAVY);
        _need_rebalancing = 0;
        t = l;
        return;
      case AVLLEFTHEAVY:
        if (rthread(l))
          t->lt = l;
        else
          t->lt = l->rt;
        set_lthread(t, rthread(l));
        l->rt = t;
        set_rthread(l, 0);
        set_bf(t, AVLBALANCED);
        set_bf(l, AVLBALANCED);
        t = l;
        return;
      case AVLRIGHTHEAVY:
	{
        longAVLNode* r = l->rt;
        set_rthread(l, lthread(r));
        if (lthread(r))
          l->rt = r;
        else
          l->rt = r->lt;
        r->lt = l;
        set_lthread(r, 0);
        set_lthread(t, rthread(r));
        if (rthread(r))
          t->lt = r;
        else
          t->lt = r->rt;
        r->rt = t;
        set_rthread(r, 0);
        if (bf(r) == AVLLEFTHEAVY)
          set_bf(t, AVLRIGHTHEAVY);
        else
          set_bf(t, AVLBALANCED);
        if (bf(r) == AVLRIGHTHEAVY)
          set_bf(l, AVLLEFTHEAVY);
        else
          set_bf(l, AVLBALANCED);
        set_bf(r, AVLBALANCED);
        t = r;
        return;
	}
      }
      }
    }
  }
}

        

void longAVLSet::del(long  item)
{
  if (root == 0) return;
  _need_rebalancing = 0;
  _already_found = 0;
  _found_node = 0;
  _target_item = &item;
  _del(root, root);
  if (_found_node)
  {
    delete(_found_node);
    if (--count == 0)
      root = 0;
  }
}

// build an ordered array of pointers to tree nodes back into a tree
// we know that at least one element exists

static longAVLNode* _do_treeify(int lo, int hi, int& h)
{
  int lh, rh;
  int mid = (lo + hi) / 2;
  longAVLNode* t = _hold_nodes[mid];
  if (lo > mid - 1)
  {
    set_lthread(t, 1);
    if (mid == 0)
      t->lt = 0;
    else
      t->lt = _hold_nodes[mid-1];
    lh = 0;
  }
  else
  {
    set_lthread(t, 0);
    t->lt = _do_treeify(lo, mid-1, lh);
  }
  if (hi < mid + 1)
  {
    set_rthread(t, 1);
    if (mid == _max_hold_index)
      t->rt = 0;
    else
      t->rt = _hold_nodes[mid+1];
    rh = 0;
  }
  else 
  {
    set_rthread(t, 0);
    t->rt = _do_treeify(mid+1, hi, rh);
  }
  if (lh == rh)
  {
    set_bf(t, AVLBALANCED);
    h = lh + 1;
  }
  else if (lh == rh - 1)
  {
    set_bf(t, AVLRIGHTHEAVY);
    h = rh + 1;
  }
  else if (rh == lh - 1)
  {
    set_bf(t, AVLLEFTHEAVY);
    h = lh + 1;
  }
  else                          // can't happen
    abort();

  return t;
}

static longAVLNode* _treeify(int n)
{
  longAVLNode* t;
  if (n == 0)
    t = 0;
  else
  {
    int b;
    _max_hold_index = n-1;
    t = _do_treeify(0, _max_hold_index, b);
  }
  delete _hold_nodes;
  return t;
}


void longAVLSet::_kill(longAVLNode* t)
{
  if (t != 0)
  {
    if (!lthread(t)) _kill(t->lt);
    if (!rthread(t)) _kill(t->rt);
    delete t;
  }
}


longAVLSet::longAVLSet(longAVLSet& b)
{
  if ((count = b.count) == 0)
  {
    root = 0;
  }
  else
  {
    _hold_nodes = new longAVLNodePtr [count];
    longAVLNode* t = b.leftmost();
    int i = 0;
    while (t != 0)
    {
      _hold_nodes[i++] = new longAVLNode(t->item);
      t = b.succ(t);
    }
    root = _treeify(count);
  }
}


int longAVLSet::operator == (longAVLSet& y)
{
  if (count != y.count)
    return 0;
  else
  {
    longAVLNode* t = leftmost();
    longAVLNode* u = y.leftmost();
    for (;;)
    {
      if (t == 0)
        return 1;
      else if (!(longEQ(t->item, u->item)))
        return 0;
      else
      {
        t = succ(t);
        u = y.succ(u);
      }
    }
  }
}

int longAVLSet::operator <= (longAVLSet& y)
{
  if (count > y.count)
    return 0;
  else
  {
    longAVLNode* t = leftmost();
    longAVLNode* u = y.leftmost();
    for (;;)
    {
      if (t == 0)
        return 1;
      else if (u == 0)
        return 0;
      int cmp = longCMP(t->item, u->item);
      if (cmp == 0)
      {
        t = succ(t);
        u = y.succ(u);
      }
      else if (cmp < 0)
        return 0;
      else
        u = y.succ(u);
    }
  }
}

void longAVLSet::operator |=(longAVLSet& y)
{
  longAVLNode* t = leftmost();
  longAVLNode* u = y.leftmost();
  int rsize = count + y.count;
  _hold_nodes = new longAVLNodePtr [rsize];
  int k = 0;
  for (;;)
  {
    if (t == 0)
    {
      while (u != 0)
      {
        _hold_nodes[k++] = new longAVLNode(u->item);
        u = y.succ(u);
      }
      break;
    }
    else if (u == 0)
    {
      while (t != 0)
      {
        _hold_nodes[k++] = t;
        t = succ(t);
      }
      break;
    }
    int cmp = longCMP(t->item, u->item);
    if (cmp == 0)
    {
      _hold_nodes[k++] = t;
      t = succ(t);
      u = y.succ(u);
    }
    else if (cmp < 0)
    {
      _hold_nodes[k++] = t;
      t = succ(t);
    }
    else
    {
      _hold_nodes[k++] = new longAVLNode(u->item);
      u = y.succ(u);
    }
  }
  root = _treeify(k);
  count = k;
}

void longAVLSet::operator &= (longAVLSet& y)
{
  longAVLNode* t = leftmost();
  longAVLNode* u = y.leftmost();
  int rsize = (count < y.count)? count : y.count;
  _hold_nodes = new longAVLNodePtr [rsize];
  int k = 0;
  for (;;)
  {
    if (t == 0)
      break;
    if (u == 0)
    {
      while (t != 0)
      {
        longAVLNode* tmp = succ(t);
        delete t;
        t = tmp;
      }
      break;
    }
    int cmp = longCMP(t->item, u->item);
    if (cmp == 0)
    {
      _hold_nodes[k++] = t;
      t = succ(t);
      u = y.succ(u);
    }
    else if (cmp < 0)
    {
      longAVLNode* tmp = succ(t);
      delete t;
      t = tmp;
    }
    else
      u = y.succ(u);
  }
  root = _treeify(k);
  count = k;
}


void longAVLSet::operator -=(longAVLSet& y)
{
  longAVLNode* t = leftmost();
  longAVLNode* u = y.leftmost();
  int rsize = count;
  _hold_nodes = new longAVLNodePtr [rsize];
  int k = 0;
  for (;;)
  {
    if (t == 0)
      break;
    else if (u == 0)
    {
      while (t != 0)
      {
        _hold_nodes[k++] = t;
        t = succ(t);
      }
      break;
    }
    int cmp = longCMP(t->item, u->item);
    if (cmp == 0)
    {
      longAVLNode* tmp = succ(t);
      delete t;
      t = tmp;
      u = y.succ(u);
    }
    else if (cmp < 0)
    {
      _hold_nodes[k++] = t;
      t = succ(t);
    }
    else
      u = y.succ(u);
  }
  root = _treeify(k);
  count = k;
}

int longAVLSet::owns(Pix i)
{
  if (i == 0) return 0;
  for (longAVLNode* t = leftmost(); t != 0; t = succ(t)) 
    if (Pix(t) == i) return 1;
  return 0;
}

int longAVLSet::OK()
{
  int v = 1;
  if (root == 0) 
    v = count == 0;
  else
  {
    int n = 1;
    longAVLNode* trail = leftmost();
    longAVLNode* t = succ(trail);
    while (t != 0)
    {
      ++n;
      v &= longCMP(trail->item, t->item) < 0;
      trail = t;
      t = succ(t);
    }
    v &= n == count;
  }
  if (!v) error("invariant failure");
  return v;
}
