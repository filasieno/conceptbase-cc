/**
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
**/
/*************************************************************************
*
* File:         %M%
* Version:      %I%
*
*
* Date released : %E%  (YY/MM/DD)
*
* SCCS-Source-Pool : %P%
* Date retrieved : %D% (YY/MM/DD)
**************************************************************************
*
* Das Modul Metautilities beinhaltet nuetzliche Hilfspraedikate
*
* Beispiel
* Ids2NamesInTerm(_termIDs,_termNames,_constList)
* Ersetze die IDs aus _constList in den Prolog-Termen _termIDs
* durch die entsprechenden Namen und erzeuge so _termNames
*
* Dieses Modul soll demnaechst verschwinden. Die hier definierten
* Praedikate sollten nach GeneralUtilities wandern
*
*/

:- module('MetaUtilities',[
'Ids2NamesInTerm'/3
,'IdsAndNamesInLit'/3
,'buildListOfLists'/3
,'empty'/1
,'exchangeElems'/4
,'findPositionsInList'/3
,'getElemsInPos'/3
,'giveNthMember'/3
,'is_id'/1
,'listDifference'/3
,'listDifference2'/3
,'listIntersection'/3
,'nonmember'/2
,'not_empty'/1
,'position'/3
,'remDupsSim'/6
,'removeMultiEntries'/2
,'removePosElem'/3
,'saveSetof'/3
,'subSetList'/2
,'substElemsInList'/4
,'substituteArgsAtPositions'/4
,'termListToAtom'/2
,'termToAtom'/2
,'writeList'/1
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').

:- use_module('BIM2C.swi.pl').
:- use_module('GeneralUtilities.swi.pl').
:- use_module('Literals.swi.pl').
:- use_module('RangeformSimplifier.swi.pl').
:- use_module('PrologCompatibility.swi.pl').








:- use_module('QO_preproc.swi.pl').

:- use_module('ScanFormatUtilities.swi.pl').



:- style_check(-singleton).



'Ids2NamesInTerm'(_termIDs,_termNames,_constList) :-
	getNamesOfIds(_constList,_names),
	substIdsWithNames(_termIDs,_termNames,_constList,_names).


'IdsAndNamesInLit'(_lit,_ids,_names) :-
	_lit =.. [_|_ids],
	getNamesOfIds(_ids,_names),
	write2Lists(_ids,_names).



/*--------------------------------------------		*/
buildListOfLists(_,[],[]).
buildListOfLists(_ePredsTillNow,[_ePred|_extList],[[_ePred|_ePredsTillNow]|_ePredList]) :-
	buildListOfLists(_ePredsTillNow,_extList,_ePredList).


/*--------------------------------------------
 empty(x) succeeds if x is the empty list
 Parameter:
 list.
*/

empty(_list) :-
	nonvar(_list),
	_list == [] .

/*-----------------------------------------------
exchangeElems(l1,l2,e,l3)
l3 is l1, but with e instead on Positions l2
Parameters:
List(a)
* List(Integer)
* a
* List(a).
*/
exchangeElems(_l1,_l2,_e,_l3) :-
	exchangeElems(1,_l1,_l2,_e,_l3).


/*-----------------------------------------------
 findPositionsInList(l1,l2,l3)
l3 contains lists of the positions of the members of l1 in l2
Parameters
List(a)
* List(a)
* List(List(Integer)).
*/
findPositionsInList([],_,[]) .
findPositionsInList([_x|_xs],_args,[_p|_pos]) :-
	findPositions(_args,1,_x,[],_p),
 	findPositionsInList(_xs,_args,_pos).

/*-----------------------------------------------
getElemsInPos(_list,_positions,_elems).
*/
getElemsInPos(_list,[],[]).
getElemsInPos(_list,[_p|_positions],[_e|_elems]) :-
	giveNthMember(_list,_p,_e),
	getElemsInPos(_list,_positions,_elems).




getNamesOfIds([],[]).

/** 31-Mar-2005/M. Jeusfeld: this clause prevents ids which are **/
/** instance of a couple of so-called simple classes (e.g.      **/
/** Booealen, Integer, GraphicalType etc.) to be converted to   **/
/** object names. I do not see a reason for this special        **/
/** treatment. Hence, the clause is disabled from now on.       **/

/**
getNamesOfIds([_id|_ids],[_id|_names]) :-
        is_id(_id),   
	id2select(_id,_),
	simpleClass(_c),
	prove_literal(In(_id,_c)),!,
	getNamesOfIds(_ids,_names).
**/

getNamesOfIds([_id|_ids],[_name|_names]) :-
        is_id(_id),   /** this really is an object identifier **/
	id2select(_id,_name),!,
	getNamesOfIds(_ids,_names).
getNamesOfIds([_id|_ids],[_id|_names]) :-
	getNamesOfIds(_ids,_names).



/*-----------------------------------------------
giveNthmember(_l,_n,_a): _a is the _nth member of _l,  0 < _n  < length(_l) +1
List(a)
* Integer
* a.
*/

giveNthMember(_l,_n,_a) :-
	not_empty(_l),
	_n>0,
	length(_l,_length),
	_length  >= _n,!,
 	giveNthMember(1,_n,_l,_a).


/** is_id(_id) chechs whether _id is a ConceptBase object identifier **/
/** The syntax for an identifier is:                                 **/
/**              id_<digits>                                         **/
/** where <digits> is a nonempty sequence of decimal digits. Access  **/
/** to objects in the C-based object store is only allowed for       **/
/** syntactically correct object identifiers that are existing.      **/

is_id(_id) :-
	atom(_id),
	pc_atomprefix('id_',3,_id),
/**
        name(_rest,_restdigits),  
        testOnDigits(_restdigits),
**/
        !.

testOnDigits([_d]) :- isDigit(_d),!.

testOnDigits([_d|_rest]) :-
  isDigit(_d),
  testOnDigits(_rest).

/** ASCII codes 48 to 57 represent digits 0,...,9                  **/
/** NOTE: This might have to be changed when moving to UNICODE     **/
/** but probably nothing changes due to embedding of UTF8 in ASCII **/
isDigit(_d) :-
  _d >= 48,
  _d =< 57 .   /** blank necessary to recognize 57 as an integer, not as a floating real **/

/*----------------------------------------------
listDifference(a,b,c)
c is a without b
Parameters:
List(a)		% InputList
* List(a)	% List of elems to remove
* List(a).	% InputList with elems from second List removed
*/
listDifference([],_,[]) .
listDifference([_x|_xs],_ys,_zs) :-
	memberchk(_x,_ys),
 	listDifference(_xs,_ys,_zs).

listDifference([_x|_xs],_ys,[_x|_zs]) :-
	nonmember(_x,_ys),
 	listDifference(_xs,_ys,_zs).

/*
listDifference2
*/
listDifference2([],_,[]) .
listDifference2([_x|_xs],_ys,_zs) :-
	member2(_x,_ys),
 	listDifference2(_xs,_ys,_zs).

listDifference2([_x|_xs],_ys,[_x|_zs]) :-
	nonmember2(_x,_ys),
 	listDifference2(_xs,_ys,_zs).


/*----------------------------------------------
ListIntersection(a,b,c)
c contains all elements which are in a and also in b
Parameters:
List(a)
* List(a)
* List(a).
*/
listIntersection([],_,[]) .
listIntersection([_x|_xs],_ys,[_x|_zs]) :-
	memberchk(_x,_ys),
 	listIntersection(_xs,_ys,_zs).

listIntersection([_x|_xs],_ys,_zs) :-
	nonmember(_x,_ys),
 	listIntersection(_xs,_ys,_zs).

/*--------------------------------------------
member2(_e,_l) : _e is unifiable with a member
of  _l
*/



member2(_Element,[_testEl|_]) :- pc_unifiable(_Element, _testEl).
member2(_Element, [_|_list]) :-
	member2(_Element,_list).



/*--------------------------------------------
nonmember(_e,_l) : _e is not member of  _l
_e and _l must be ground, because no unification
is performed
*/
nonmember(_, []).
nonmember(_X, [_H|_T]) :-
	_X \== _H,
	nonmember(_X, _T).

/*--------------------------------------------
nonmember2(_e,_l) : succeeds tests if _e can't
be unified with a member of _l
*/
nonmember2(_, []).
nonmember2(_X, [_H|_T]) :-
	_X \= _H,
	nonmember2(_X, _T).

/*--------------------------------------------
not_ empty(x) succeeds if x is the empty list
 Parameter:
 list.
*/
not_empty(_list) :-
	nonvar(_list),
	_list \== [] .

/*---------------------------------------------
position(_elem,_lis,_pos)
Parameters:
a
* List(a)
* Integer.
*/
position(_elem,_lis,_pos) :- 	 position2(_elem,_lis,1,_pos).

/*-----------------------------------------------
remDupsSim(_l1,_l2,_l3,newL1,_newL2,_newL3).
The duplicates in _l1, which have equal entries in _l2 and _l3 are removed,
all corresponding elements in
_l2 and _l3 also
*/
remDupsSim([],[],[],[],[],[]).
remDupsSim([_l1|_l1s],[_l2|_l2s],[_l3|_l3s],_newL1,_newL2,_newL3):-
	memberchk(_l1,_l1s),
	testEquality(_l1,_l2,_l3,_l1s,_l2s,_l3s),!,
	remDupsSim(_l1s,_l2s,_l3s,_newL1,_newL2,_newL3).
remDupsSim([_l1|_l1s],[_l2|_l2s],[_l3|_l3s],[_l1|_newL1],[_l2|_newL2],[_l3|_newL3]):-
	remDupsSim(_l1s,_l2s,_l3s,_newL1,_newL2,_newL3).



/*---------------------------------------------
removeMultiEntries(a,b)
b is list a with all duplicates removed
*/
removeMultiEntries([],[]) .
removeMultiEntries([_x|_xs],_ys) :-
	memberchk(_x,_xs),
	removeMultiEntries(_xs,_ys).

removeMultiEntries([_x|_xs],[_x|_ys]) :-
	nonmember(_x,_xs),
 	removeMultiEntries(_xs,_ys).

/*--------------------------------------------
removePosElem(_pos,_oldlist,_newlist)
succeeds if _newlist is _oldlist with element on position _pos removed
*/

removePosElem(_pos,_list,_list) :-
	_pos < 0,!.
removePosElem(_pos,_list,_list) :-
	 length(_list,_length),
 	_pos >_length,!.
removePosElem(_pos,_oldList,_newList) :-
	removePosElem(1,_pos,_oldList,_newList).


/*----------------------------------------------
saveSetof(_a,_p,_c):
_c is a list of all instances of a for which prediacte
_p succeeds. If no solution exists, _c is the
empty list.

The standard setof predicate fails, if no solution exists
*/


:- module_transparent saveSetof/3 .


saveSetof(_a,_b,_c) :-
	setof(_a,_b,_c),!.
saveSetof(_,_,[]).

/*----------------------------------------------
subSetList(a,b) succeeds if the set of elements of a is a subset
of the set of elements of b
a and b must be ground
*/
subSetList(_a,_b) :-
	is_list(_a),
	is_list(_b),
	subSetList1(_a,_b).


/*-----------------------------------------------
substElemsInList(l,oldElems,newElems,newL):
newL is l with all oldElems replaced by the belonging newElems:
Example:
substElemsInList([1,2,3,4,5,4,3,2,1],[6,4],[66,44],l).
l = [1,2,3,44,5,44,3,2,1] ?
Parameters:
List(a)
* List(a)
* List(a)
* List(a).
*/

substElemsInList(_list,[],_,_list) .
substElemsInList(_listOld,[_oldElem|_oldElems],[_newElem|_newElems],_listNew) :-
	nonmember(_oldElem,_listOld),
 	substElemsInList(_listOld,_oldElems,_newElems,_listNew).

substElemsInList(_listOld,[_oldElem|_oldElems],[_newElem|_newElems],_listNew) :-
	save_memberchk(_oldElem,_listOld),
 	substElemInList(_listOld,_oldElem,_newElem,_listNewer),
 	substElemsInList(_listNewer,_oldElems,_newElems,_listNew).


/** Ticket #265: We need to make sure that variable arguments are not matching in **/
/** save_membercheck. The _newElems in substElemsInList can contain such Prolog   **/
/** variables while _list and _oldElems typycally cantains constants.             **/

save_memberchk(_x,[_x1|_]) :-
   _x == _x1,                     /** _x1 can be a variable; may not unify **/
   !.
save_memberchk(_x,[_|_rest]) :-
  save_memberchk(_x,_rest).



substIdsWithNames(_termIDs,_termNames,_ids,_names) :-
	_termIDs =.. _itemList,
	substIdsInItemList(_itemList,_ids,_names,_newItemList),
	_termNames =.. _newItemList.


substIdsInItemList([],_,_,[]).
substIdsInItemList([_item|_itemList],_ids,_names,[_item|_newItemList]) :-
	var(_item),
	substIdsInItemList(_itemList,_ids,_names,_newItemList).
substIdsInItemList([_item|_itemList],_ids,_names,[_newItem|_newItemList]) :-
	atomic(_item),
	substElemsInList([_item],_ids,_names,[_newItem]),
	substIdsInItemList(_itemList,_ids,_names,_newItemList).
substIdsInItemList([_item|_itemList],_ids,_names,[_newItem|_newItemList]) :-
	is_list(_item),!,
	substIdsInItemList(_item,_ids,_names,_newItem),
	substIdsInItemList(_itemList,_ids,_names,_newItemList).
substIdsInItemList([_item|_itemList],_ids,_names,[_newItem|_newItemList]) :-
	compound(_item),
	_item =.. _itemList1,
	substIdsInItemList(_itemList1,_ids,_names,_newItemList1),
	_newItem =.. _newItemList1,
	substIdsInItemList(_itemList,_ids,_names,_newItemList).




/*
substituteArgsAtPositions(_arguments,_cons,_pos,_newArguments).
*/
substituteArgsAtPositions(_arguments,[],[],_arguments).
substituteArgsAtPositions(_arguments,[_c|_cons],[_pList|_pos],_newArguments):-
	sort(_pList,_pList1),
	substituteArgsAtPos(1,_arguments,_c,_pList1,_newArguments1) ,
	substituteArgsAtPositions(_newArguments1,_cons,_pos,_newArguments).


termToAtom(_atom,_atom) :-
    atom(_atom),!.

/** special cases for In(x,c), A(x,m,y) etc. which are all converted to their infix form: **/

termToAtom('In'(_x,_c),_atom) :-
  atom(_x),atom(_c),
  !,
  pc_atomconcat(['(',_x,' in ',_c,')'],_atom).

termToAtom('A'(_x,_m,_y),_atom) :-
  atom(_x),atom(_m),atom(_y),
  !,
  pc_atomconcat(['(',_x,' ',_m,' ',_y,')'],_atom).

termToAtom('AL'(_x,_m,_n,_y),_atom) :-
  atom(_x),atom(_m),atom(_y),
  !,
  pc_atomconcat(['(',_x,' ',_m,'/',_n,' ',_y,')'],_atom).

termToAtom('IDENTICAL'(_x,_y),_atom) :-
  atom(_x),atom(_y),
  !,
  pc_atomconcat(['(',_x,' == ',_y,')'],_atom).

termToAtom('EQ'(_x,_y),_atom) :-
  atom(_x),atom(_y),
  !,
  pc_atomconcat(['(',_x,' = ',_y,')'],_atom).

termToAtom('LT'(_x,_y),_atom) :-
  atom(_x),atom(_y),
  !,
  pc_atomconcat(['(',_x,' < ',_y,')'],_atom).

termToAtom('GT'(_x,_y),_atom) :-
  atom(_x),atom(_y),
  !,
  pc_atomconcat(['(',_x,' > ',_y,')'],_atom).

termToAtom('LE'(_x,_y),_atom) :-
  atom(_x),atom(_y),
  !,
  pc_atomconcat(['(',_x,' <= ',_y,')'],_atom).

termToAtom('GE'(_x,_y),_atom) :-
  atom(_x),atom(_y),
  !,
  pc_atomconcat(['(',_x,' >= ',_y,')'],_atom).

termToAtom('NE'(_x,_y),_atom) :-
  atom(_x),atom(_y),
  !,
  pc_atomconcat(['(',_x,' <> ',_y,')'],_atom).    /** ticket #266: '\=' is stored as '='; hence we need to use '<>' **/
                                                  /** probably a property of pc_atomconcat                          **/


termToAtom(_lit,_atom) :-
  isComplexComparisonLit(_lit),!,
  _lit =.. [_fun,_arg1,_arg2],
  argToAtom(_arg1,_atom1),
  argToAtom(_arg2,_atom2),
  _newlit =..  [_fun,_atom1,_atom2],
  termToAtom(_newlit,_atom).


/** query literals should also be converted to readable forms **/
termToAtom(_lit,_atom) :-
  isQlit(_lit),
  _lit=..[_id|[_this|_args]],
  outObjectName(_id,_idname),
  'QueryArgExp'(_id,_qargexps),
  convertArgs(_qargexps,_args,_argsname),
  !,
  pc_atomconcat(_idname,_argsname,_atomquery),
  pc_atomconcat(['(',_this,' in ',_atomquery,')'],_atom).


termToAtom(_term,_atom) :-
    \+(atom(_atom)),
	termListToAtom([_term],_atom).

argToAtom(_arg,_atom) :-
  isQlit(_arg),!,
  _arg=..[_id|['_'|_args]],
  outObjectName(_id,_idname),
  'QueryArgExp'(_id,_qargexps),
  convertArgs(_qargexps,_args,_argsname),
  pc_atomconcat(_idname,_argsname,_atom).

argToAtom(_atom,_atom) :-
  atom(_atom).


writeList([]) :- nl,nl.
writeList([_l|_ls]) :-
	write(_l),nl,
	writeList(_ls).

write2Lists([],_) :- !.
write2Lists(_,[]) :- !.
write2Lists([_e1|_t1],[_e2|_t2]) :-
	write(_e1),write('   '),write(_e2),nl,
	write2Lists(_t1,_t2).

/*-----------------------------LOCAL PART --------------------------*/


exchangeElems(_,[],_,_,[]) .
exchangeElems(_,_,[],_,[]) .
exchangeElems(_pos,[_e|_es],_testList,_c,[_e|_rs]) :-
	nonmember(_pos,_testList),
 	_newPos is _pos+1,
	 exchangeElems(_newPos,_es,_testList,_c,_rs).
exchangeElems(_pos,[_|_es],_testList,_c,[_c|_rs]) :-
	memberchk(_pos,_testList),
	 _newPos is _pos+1,
 	exchangeElems(_newPos,_es,_testList,_c,_rs).

giveNthMember(_n,_n,[_x|_],_x) :- !.
giveNthMember(_i,_n,[_|_xs],_x) :-
	 _i  <_n,!,
 	_newI is _i+1,
 	giveNthMember(_newI,_n,_xs,_x).

findPositions([],_,_,_lis,_lis) .
findPositions([_x|_xs],_pos,_x,_found,_erg) :-
	 _nPos is _pos+1,
 	findPositions(_xs,_nPos,_x,[_pos|_found],_erg).
findPositions([_y|_xs],_pos,_x,_found,_erg) :-
	 _y \== _x,
 	_nPos is _pos+1,
	 findPositions(_xs,_nPos,_x,_found,_erg).


findDuplicateMemberWithCorr(_,[],_,_).
findDuplicateMemberWithCorr(_el,[_el|_t1],_h2,[_h2|_t2],[_h3|_t3]) :-!,
	findDuplicateMemberWithCorr(_el,_t1,_t2,_t3).
findDuplicateMemberWithCorr(_el,[_h1|_t1],_el2,[_h2|_t2],[_h3|_t3]) :-
	findDuplicateMemberWithCorr(_el,_t1,_t2,_t3).


getIdsFromSubstLists1([],[]).
getIdsFromSubstLists1([subst(_,_idList)|_substs],_ids) :-
	getIdsFromSubstLists1(_substs,_ids1),
	append(_idList,_ids1,_ids).


position2(_,[],_,-1) .
position2(_elem,[_elem|_],_pos,_pos) .
position2(_elem,[_otherElem|_lis],_oldPos,_pos) :-
	_otherElem \==_elem,
 	_newPos is _oldPos+1,
 	position2(_elem,_lis,_newPos,_pos).

removePosElem(_pos,_pos,[_o|_oldList],_oldList).
removePosElem(_actPos,_pos,[_o|_oldList],[_o|_newList]) :-
	_actPos < _pos,!,
	_newActPos is _actPos + 1,
	removePosElem(_newActPos,_pos,_oldList,_newList).

subSetList1([],_) .
subSetList1([_x|_xs],_list) :-
	member(_x,_list),
	subSetList1(_xs,_list).

substElemInList([],_,_,[]) .
substElemInList([_x1|_xs],_x,_y,[_y|_ys]) :-
        _x1 == _x,
	substElemInList(_xs,_x,_y,_ys).
substElemInList([_z|_xs],_x,_y,[_z|_ys]) :-
	_z \== _x,
	 substElemInList(_xs,_x,_y,_ys).


substituteArgsAtPos(_,[],_c,_,[]).
substituteArgsAtPos(_,_args,_,[],_args) :- !.
substituteArgsAtPos(_count,[_arg|_arguments],_c,[_count|_pList],[_c|_newArguments]) :-
	_nc is _count + 1,
	substituteArgsAtPos(_nc,_arguments,_c,_pList,_newArguments).
substituteArgsAtPos(_count,[_arg|_arguments],_c,[_p|_pList],[_arg|_newArguments]) :-
	_p \== _count,
	_nc is _count + 1,
	substituteArgsAtPos(_nc,_arguments,_c,[_p|_pList],_newArguments).




termListToAtom([],'').
termListToAtom([_h],_atom) :-
	_h =.. [_atom|[]] ,!.

termListToAtom([_h],_atom) :-
	_h =.. [_functor|_list] ,!,
	_list \== [],!,
	termListToAtomList(_list,_atom1),
	pc_atomconcat([_functor,'(',_atom1,')'],_atom).

termListToAtom([_h|_tail],_atom) :-
	_h =.. [_atom1|[]] ,!,
	termListToAtom(_tail,_atom2),
	pc_atomconcat([_atom1,_atom2],_atom).

termListToAtom([_h|_tail],_atom) :-
	_h =.. [_functor|_list] ,
	_list \== [],!,
	termListToAtomList(_list,_atom1),
	pc_atomconcat([_functor,'(',_atom1,')'],_atom2),
	termListToAtom(_tail,_atom3),
	pc_atomconcat([_atom2,_atom3],_atom).

termListToAtomList([],'').
termListToAtomList([_h],_atom) :-
	_h =.. [_atom|[]] ,!.

termListToAtomList([_h],_atom) :-
	_h =.. [_functor|_list] ,!,
	_list \== [],!,
	termListToAtomList(_list,_atom1),
	pc_atomconcat([_functor,'(',_atom1,')'],_atom).

termListToAtomList([_h|_tail],_atom) :-
	_h =.. [_atom1|[]] ,!,
	termListToAtomList(_tail,_atom2),
	pc_atomconcat([_atom1,',',_atom2],_atom).

termListToAtomList([_h|_tail],_atom) :-
	_h =.. [_functor|_list] ,
	_list \== [],!,
	termListToAtomList(_list,_atom1),
	pc_atomconcat([_functor,'(',_atom1,')'],_atom2),
	termListToAtomList(_tail,_atom3),
	pc_atomconcat([_atom2,',',_atom3],_atom).


testEquality(_l1,_l2,_l3,[_l1|_],[_l2|_],[_l3|_]) :- !.
testEquality(_l1,_l2,_l3,[_|_test1List],[_|_test2List],[_|_test3List]) :-
	testEquality(_l1,_l2,_l3,_test1List,_test2List,_test3List).



