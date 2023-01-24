{*
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
*}
#MODULE(QO_search)
#EXPORT(bestFirstSearch/3)
#ENDMODDECL()


#IMPORT(add_to_heap/4,QO_heaps)
#IMPORT(get_from_heap/4,QO_heaps)
#IMPORT(list_to_heap/2,QO_heaps)
#IMPORT(initState/2,QO_costs)
#IMPORT(getCostFromState/2,QO_costs)
#IMPORT(costLitsFromState/3,QO_costs)
#IMPORT(getLatestLitFromState/2,QO_costs)
#IMPORT(getOrderFromState/2,QO_costs)
#IMPORT(updateState/3,QO_costs)
#IMPORT(bestFirst/0,QO_optimize)
#IMPORT(append/3,GeneralUtilities)
#IMPORT(max/2,QO_utils)
#IMPORT(length/2,GeneralUtilities)
#IMPORT(reverse/2,GeneralUtilities)
#IMPORT(delete/3,GeneralUtilities)
#IMPORT(get_cb_feature/2,GlobalParameters)
#IMPORT(WriteTrace/3,GeneralUtilities)
#IMPORT(member/2,GeneralUtilities)
#IMPORT(pc_atomconcat/2,PrologCompatibility)
#IMPORT(pc_atomconcat/3,PrologCompatibility)

#IF(SWI)
:- style_check(-singleton).
#ENDIF(SWI)



{*********************************************

Best first Methode:

Die Sequenzen werden sukzessive von links nach
rechts aufgebaut. Dabei wird immer mit der bisher
bestimmten guenstigsten Teilsequenz weiter
gearbeitet. Die bereits berechneten Teilsequenzen
werden mit einem Heap verwaltet, wobei die Kosten
der Teilsequenz als Schluessel dienen.


Literatur:
David E. Smith and Michael R. Genesereth
Ordering Conjunctive Queries
Artificial Intelligence
1985
Vol 26, pp. 171 - 215
dort: Beschreibung Best First: p. 191ff
 *********************************************}


{*********************************************}
{* searchMode:                               *}
{*             *  ohne Einschraenkung        *}
{*             *  Cheapest-First             *}
{*                                           *}
{* ohne Einschraenkung:                      *}
{* die best-first Suche wird vollstaendig    *}
{* durchgefuehrt, d.h. in jedem Schritt wird *}
{* eine Sequenz vom Heap entfernt und der    *}
{* guenstigste Nachbar bzw. der guenstigste  *}
{* Nachfolger werden hinzugefuegt.           *}
{*                                           *}
{* Cheapest-first:                           *}
{* Nur der Nachfolger einer Sequenz wird dem *}
{* Heap hinzugefuegt, nicht der Nachbar      *}
{* --> Verfahren entartet zu Cheapest-first  *}
{*                                           *}
{*********************************************}

{* Absolute Untergrenze fuer maximale Iterationszahl *}
#DYNAMIC(lower/1)

lower(100).



#MODE( initMaxIter(i,o))

initMaxIter(_l,_max) :-
	bestFirst,
	lower(_limit),
	_max1 is _l * _l,
	((_max1 < _limit,_max is _limit);
	 (_max = _max1)),!.
initMaxIter(_l,1).





getStateFromBFState(bfstate(_state,_remLits,_length,_prevState,_remNeighbours),_state).
getRemLitsFromBFState(bfstate(_state,_remLits,_length,_prevState,_remNeighbours),_remLits).
getLengthFromBFState(bfstate(_state,_remLits,_length,_prevState,_remNeighbours),_length).
getPrevStateFromBFState(bfstate(_state,_remLits,_length,_prevState,_remNeighbours),_prevState).
getRemNeighboursFromBFState(bfstate(_state,_remLits,_length,_prevState,_remNeighbours),_remNeighbours).




#MODE( bestFirstSearch(i,o))

bestFirstSearch(_head,_lits,_lits) :-
        functor(_head,_func,_),
        (member(_func,[ins,del,red,plus,minus]);
         pc_atomconcat('vm_',_,_func)
        ),
        !.

bestFirstSearch(_head,_literals,_sequence) :-
	list_to_heap([],_emptyHeap),
	length(_literals,_l),
	initMaxIter(_l,_maxIter),
	initBFState(_head,_literals,_initState),
	addToHeapList(_emptyHeap,_initState,_heap),
	bestFirstSearchWithHeap(_heap,1,_maxIter,_resState),
	!,
	getStateFromBFState(_resState,_state),
	getOrderFromState(_state,_order),
	reverse(_order,_sequence).


bestFirstSearch(_head,_literals,_sequence) :-
	list_to_heap([],_emptyHeap),
	initBFState(_head,_literals,_initState),
	addToHeapList(_emptyHeap,_initState,_heap),
	cheapestFirstSearchWithHeap(_heap,_resState),
	!,
	getStateFromBFState(_resState,_state),
	getOrderFromState(_state,_order),
	reverse(_order,_sequence).

bestFirstSearch(_,_lits,_lits).
	{ alten Optimierer aufrufen im notfall }


#MODE( initBFstate(i,o,o,o))

initBFState(_head,_literals,[_cost-bfstate(_state,_remLits,1,_initState,_remLits)]) :-
	initState([_head|_literals],_initState),
	costLitsFromState(_literals,_initState,_litsAndCost),
	keysort(_litsAndCost,_litsAndCostSorted1),
	filterInf(_litsAndCostSorted1,_litsAndCostSorted),
	_litsAndCostSorted = [_-_cheapestLit|_remNeighbours],
	dropCosts(_remNeighbours,_remLits),
	updateState(_initState,_cheapestLit,_state),
	getCostFromState(_state,_cost),
	!.


#MODE( bestFirstSearchWithHeap(i,i,i,o))

bestFirstSearchWithHeap(_heap,_iter,_maxIter,_resState) :-
	_iter < _maxIter,
	writeDot,
	!,
	get_from_heap(_heap,_cost,_bfState,_newHeap1),
	findCheapestNeighbour(_bfState,_neighbourState),
	addToHeapList(_newHeap1,_neighbourState,_newHeap2),
	findCheapestSuccessor(_bfState,_succState,_state),
	!,
	(
		(

		  _state == found,
		  _resState = _bfState
		);
		(

		  _succState \== [],
		  addToHeapList(_newHeap2,_succState,_newHeap),
		  _newIter is _iter + 1,
		  bestFirstSearchWithHeap(_newHeap,_newIter,_maxIter,_resState)
		)

	),
	!.


bestFirstSearchWithHeap(_heap,_iter,_maxIter,_resState) :-
	_iter >= _maxIter,
	writeDot,
	WriteTrace(veryhigh,QO_search,[_iter,' Iterations -> switching to cheapest-first ']),
	!,
	fail.


#MODE( cheapestFirstSearch(i,o))

cheapestFirstSearchWithHeap(_heap,_resState) :-
	writeDot,
	get_from_heap(_heap,_cost,_bfState,_newHeap1),
	findCheapestSuccessor(_bfState,_succState,_state),
	(
		(
		  _state == found,
		  _resState = _bfState
		);
		(
		  addToHeapList(_newHeap1,_succState,_newHeap),
		  cheapestFirstSearchWithHeap(_newHeap,_resState)
		)
	),
	!.




#MODE( findCheapestNeighbour(i,o))

findCheapestNeighbour(bfstate(_state,_remLits,_length,_prevState,_remNeighbours),
		      [_cost-bfstate(_newState,_newRemLits,_length,_prevState,_newRemNeighbours)]) :-
	_remNeighbours \== [],
	getLatestLitFromState(_state,_latestLit),
	_remNeighbours = [_newLit|_newRemNeighbours],
	updateState(_prevState,_newLit,_newState),
	delete(_newLit,_remLits,_newRemLits1),
	_newRemLits = [_latestLit|_newRemLits1],
	getCostFromState(_newState,_cost),
	_cost \== infinity,!.

findCheapestNeighbour(bfstate(_state,_remLits,_length,_prevState,_remNeighbours),
		     []).

#MODE( findCheapestSuccessor(i,o,o))

findCheapestSuccessor(bfstate(_state,_remLits,_length,_oldState,_oldRemLits),
		      [0.0-bfstate(_state,_remLits,_length,_oldState,_oldRemLits)],found) :-
	_remLits == [],!.

findCheapestSuccessor(bfstate(_state,_remLits,_length,_,_),
		      [_cost-bfstate(_newState,_newRemLits,_newLength,_state,_newRemLits)],go) :-
	_remLits \== [],!,
	costLitsFromState(_remLits,_state,_litsAndCost),
	keysort(_litsAndCost,_litsAndCostSorted1),
	filterInf(_litsAndCostSorted1,_litsAndCostSorted),
	_litsAndCostSorted = [_-_cheapestLit|_remNeighbours],
	dropCosts(_remNeighbours,_newRemLits),
	updateState(_state,_cheapestLit,_newState),
	_newLength is _length + 1,
	getCostFromState(_newState,_cost),
	_cost \== infinity,
	!.

findCheapestSuccessor(bfstate(_state,_remLits,_length,_,_),
		      [],go).


#MODE( addToHeapList(i,i,i,o))

addToHeapList(_heap,[],_heap).
addToHeapList(_heap,[_c-_s],_newHeap) :-
	add_to_heap(_heap,_c,_s,_newHeap),!.



#MODE( dropCosts(i,o))

dropCosts([],[]).
dropCosts([_c-_l|_clList],[_l|_lList]) :-
	dropCosts(_clList,_lList).


#MODE( filterInf(i,o))

filterInf(_cList,_newCList) :-
	filterInf(_cList,[],_newCList).

filterInf([infinity-_l|_cList],_oldInf,_newCList) :-
	!,
	filterInf(_cList,[infinity-_l|_oldInf],_newCList).
filterInf(_clist,_oldInf,_newCList) :-
	append(_clist,_oldInf,_newCList).



writeDot :-
	get_cb_feature(TraceMode,veryhigh),
	!,
	write('.').

writeDot.
