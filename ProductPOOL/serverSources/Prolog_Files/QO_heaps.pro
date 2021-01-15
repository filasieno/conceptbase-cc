{*
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
*}
{**************************************************************************}
{* File   : HEAPS.PL                                                      *}
{* Author : R.A.O'Keefe                                                   *}
{* Updated: 29 November 1983                                              *}
{* Purpose: Implement heaps in Prolog.                                    *}
{*                                                                        *}
{* A heap is a labelled binary tree where the key of each node is less    *}
{* than or equal to the keys of its sons.  The point of a heap is that    *}
{* we can keep on adding new elements to the heap and we can keep on      *}
{* taking out the minimum element.  If there are N elements total, the    *}
{* total time is O(NlgN).  If you know all the elements in advance, you   *}
{* are better off doing a merge-sort, but this file is for when you       *}
{* want to do say a best-first search, and have no idea when you start    *}
{* how many elements there will be, let alone what they are.              *}
{*                                                                        *}
{* A heap is represented as a triple t(N, Free, Tree) where N is the      *}
{* number of elements in the tree, Free is a list of integers which       *}
{* specifies unused positions in the tree, and Tree is a tree made of     *}
{*     t			terms for empty subtrees and              *}
{*     t(Key,Datum,Lson,Rson)	terms for the rest                        *}
{* The nodes of the tree are notionally numbered like this:               *}
{*       			    1                                     *}
{*     	     2				    3                             *}
{*          4               6               5               7             *}
{*      8      12      10     14       9       13      11     15          *}
{*   ..  ..  ..  ..  ..  ..  ..  ..  ..  ..  ..  ..  ..  ..  ..  ..       *}
{* The idea is that if the maximum number of elements that have been in   *}
{* the heap so far is M, and the tree currently has K elements, the tree  *}
{* is some subtreee of the tree of this form having exactly M elements,   *}
{* and the Free list is a list of K-M integers saying which of the        *}
{* positions in the M-element tree are currently unoccupied.  This free   *}
{* list is needed to ensure that the cost of passing N elements through   *}
{* the heap is O(NlgM) instead of O(NlgN).  For M say 100 and N say 10^4  *}
{* this means a factor of two.  The cost of the free list is slight.      *}
{* The storage cost of a heap in a copying Prolog (which Dec-10 Prolog is *}
{* not) is 2K+3M words.                                                   *}
{**************************************************************************}

#MODULE(QO_heaps)
#EXPORT(add_to_heap/4)
#EXPORT(get_from_heap/4)
#EXPORT(list_to_heap/2)
#ENDMODDECL()

#IF(SWI)
:- style_check(-singleton).
#ENDIF(SWI)



        {*******************************************************************}
        {* add_to_heap(+OldHeap, +Key, +Datum, -NewHeap)                   *}
        {* inserts the new Key-Datum pair into the heap.  The insertion is *}
        {* not stable, that is, if you insert several pairs with the same  *}
        {* Key it is not defined which of them will come out first, and it *}
        {* is possible for any of them to come out first depending on the  *}
        {* history of the heap.  If you need a stable heap, you could add  *}
        {* a counter to the heap and include the counter at the time of    *}
        {* insertion in the key.  If the free list is empty, the tree will *}
        {* be grown, otherwise one of the empty slots will be re-used.  (I *}
        {* use imperative programming language, but the heap code is as    *}
        {* pure as the trees code, you can create any number of variants   *}
        {* starting from the same heap, and they will share what common    *}
        {* structure they can without interfering with each other.)        *}
        {*******************************************************************}

add_to_heap(t(_M,[],_OldTree), _Key, _Datum, t(_N,[],_NewTree)) :- !,
	_N is _M+1,
	add_to_heap(_N, _Key, _Datum, _OldTree, _NewTree).
add_to_heap(t(_M,[_H|_T],_OldTree), _Key, _Datum, t(_N,_T,_NewTree)) :-
	_N is _M+1,
	add_to_heap(_H, _Key, _Datum, _OldTree, _NewTree).


add_to_heap(1, _Key, _Datum, _, t(_Key,_Datum,t,t)) :- !.
add_to_heap(_N, _Key, _Datum, t(_K1,_D1,_L1,_R1), t(_K2,_D2,_L2,_R2)) :-
	_E is _N mod 2,
	_M is _N // 2,
	sort2(_Key, _Datum, _K1, _D1, _K2, _D2, _K3, _D3),
	add_to_heap(_E, _M, _K3, _D3, _L1, _R1, _L2, _R2).


add_to_heap(0, _N, _Key, _Datum, _L1, _R, _L2, _R) :- !,
	add_to_heap(_N, _Key, _Datum, _L1, _L2).
add_to_heap(1, _N, _Key, _Datum, _L, _R1, _L, _R2) :- !,
	add_to_heap(_N, _Key, _Datum, _R1, _R2).


sort2(_Key1, _Datum1, _Key2, _Datum2, _Key1, _Datum1, _Key2, _Datum2) :-
	_Key1 @< _Key2,
	!.
sort2(_Key1, _Datum1, _Key2, _Datum2, _Key2, _Datum2, _Key1, _Datum1).

        {*********************************************************************}
        {* get_from_heap(+OldHeap, ?Key, ?Datum, -NewHeap)                   *}
        {* returns the Key-Datum pair in OldHeap with the smallest Key,      *}
        {* and also a New Heap which is the Old Heap with that pair deleted. *}
        {* The easy part is picking off the smallest element.  The hard part *}
        {* is repairing the heap structure.  repair_heap/4 takes a pair of   *}
        {* heaps and returns a new heap built from their elements, and the   *}
        {* position number of the gap in the new tree.  Note that            *}
        {* repair_heap is *not* tail-recursive.                              *}
        {*********************************************************************}

get_from_heap(t(_N,_Free,t(_Key,_Datum,_L,_R)), _Key, _Datum, t(_M,[_Hole|_Free],_Tree)) :-
	_M is _N-1,
	repair_heap(_L, _R, _Tree, _Hole).


repair_heap(t(_K1,_D1,_L1,_R1), t(_K2,_D2,_L2,_R2), t(_K2,_D2,t(_K1,_D1,_L1,_R1),_R3), _N) :-
	_K2 @< _K1,
	!,
	repair_heap(_L2, _R2, _R3, _M),
	_N is 2*_M+1 .
repair_heap(t(_K1,_D1,_L1,_R1), t(_K2,_D2,_L2,_R2), t(_K1,_D1,_L3,t(_K2,_D2,_L2,_R2)), _N) :- !,
	repair_heap(_L1, _R1, _L3, _M),
	_N is 2*_M .
repair_heap(t(_K1,_D1,_L1,_R1), t, t(_K1,_D1,_L3,t), _N) :- !,
	repair_heap(_L1, _R1, _L3, _M),
	_N is 2*_M .
repair_heap(t, t(_K2,_D2,_L2,_R2), t(_K2,_D2,t,_R3), _N) :- !,
	repair_heap(_L2, _R2, _R3, _M),
	_N is 2*_M+1 .
repair_heap(t, t, t, 1) :- !.

        {*********************************************************}
        {* heap_size(+_Heap, ?Size)                              *}
        {* reports the number of elements currently in the heap. *}
        {*********************************************************}

heap_size(t(_Size,_,_), _Size).

        {*******************************************************************}
        {* heap_to_list(+Heap, -List)                                      *}
        {* returns the current set of Key-Datum pairs in the Heap as a     *}
        {* List, sorted into ascending order of Keys.  This is included    *}
        {* simply because I think every data structure foo ought to have   *}
        {* a foo_to_list and list_to_foo relation (where, of course, it    *}
        {* makes sense!) so that conversion between arbitrary data         *}
        {* structures is as easy as possible.  This predicate is basically *}
        {* just a merge sort, where we can exploit the fact that the tops  *}
        {* of the subtrees are smaller than their descendants.             *}
        {*******************************************************************}

heap_to_list(t(_,_,_Tree), _List) :-
	heap_tree_to_list(_Tree, _List).


heap_tree_to_list(t, []) :- !.
heap_tree_to_list(t(_Key,_Datum,_Lson,_Rson), [_Key-_Datum|_Merged]) :-
	heap_tree_to_list(_Lson, _Llist),
	heap_tree_to_list(_Rson, _Rlist),
	heap_tree_to_list(_Llist, _Rlist, _Merged).


heap_tree_to_list([_H1|_T1], [_H2|_T2], [_H2|_T3]) :-
	_H2 @< _H1,
	!,
	heap_tree_to_list([_H1|_T1], _T2, _T3).
heap_tree_to_list([_H1|_T1], _T2, [_H1|_T3]) :- !,
	heap_tree_to_list(_T1, _T2, _T3).
heap_tree_to_list([], _T, _T) :- !.
heap_tree_to_list(_T, [], _T).

        {*********************************************************************}
        {* list_to_heap(+List, -Heap)                                        *}
        {* takes a list of Key-Datum pairs (such as keysort could be used to *}
        {* sort) and forms them into a heap.  We could do that a wee bit     *}
        {* faster by keysorting the list and building the tree directly, but *}
        {* this algorithm makes it obvious that the result is a heap, and    *}
        {* could be adapted for use when the ordering predicate is not @<    *}
        {* and hence keysort is inapplicable.                                *}
        {*********************************************************************}

list_to_heap(_List, _Heap) :-
	list_to_heap(_List, 0, t, _Heap).


list_to_heap([], _N, _Tree, t(_N,[],_Tree)) :- !.
list_to_heap([_Key-_Datum|_Rest], _M, _OldTree, _Heap) :-
	_N is _M+1,
	add_to_heap(_N, _Key, _Datum, _OldTree, _MidTree),
	list_to_heap(_Rest, _N, _MidTree, _Heap).

        {*******************************************************************}
        {* min_of_heap(+Heap, ?Key, ?Datum)                                *}
        {* returns the Key-Datum pair at the top of the heap (which is of  *}
        {* course the pair with the smallest Key), but does not remove it  *}
        {* from the heap.  It fails if the heap is empty.                  *}
        {*                                                                 *}
        {* min_of_heap(+Heap, ?Key1, ?Datum1, ?Key2, ?Datum2)              *}
        {* returns the smallest (Key1) and second smallest (Key2) pairs in *}
        {* the heap, without deleting them.  It fails if the heap does not *}
        {* have at least two elements.                                     *}
        {*******************************************************************}

min_of_heap(t(_,_,t(_Key,_Datum,_,_)), _Key, _Datum).


min_of_heap(t(_,_,t(_Key1,_Datum1,_Lson,_Rson)),_Key1,_Datum1,_Key2,_Datum2):-
	min_of_heap(_Lson, _Rson, _Key2, _Datum2).


min_of_heap(t(_Ka,_Da,_,_), t(_Kb,_Db,_,_), _Kb, _Db) :-
	_Kb @< _Ka, !.
min_of_heap(t(_Ka,_Da,_,_), _, _Ka, _Da).
min_of_heap(t, t(_Kb,_Db,_,_), _Kb, _Db).


