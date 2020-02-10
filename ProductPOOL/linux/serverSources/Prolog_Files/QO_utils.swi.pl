/**
The ConceptBase.cc Copyright

Copyright 1987-2020 The ConceptBase Team. All rights reserved.

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
**/

:- module('QO_utils',[
'allNull'/1
,'applyMask'/3
,'clearRecords'/1
,'dropKeys'/2
,'intToReal'/2
,'max'/2
,'orMaskList'/2
,'perm'/2
,'remDups'/2
,'save_div'/3
,'save_minus'/3
,'save_mult'/3
,'save_plus'/3
,'select'/3
,'setAllOne'/2
,'splitListAtElem'/4
,'subset'/2
,'sumlist'/2
,'sumlistReal'/2
,'undefined'/1
,'union'/3
,'writeFacts'/2
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').

:- use_module('GeneralUtilities.swi.pl').
:- use_module('PrologCompatibility.swi.pl').







:- style_check(-singleton).



/************************/
/* basic list utilities */
/************************/
/** wenn nicht anders vermerkt, dann sind die Praedikate aus       **/
/** Dateien in Unterverzeichnissen von $BIM_PROLOG_DIR/src/prolog/ **/
/** entnommen                                                      **/




dropKeys([],[]).
dropKeys([_k-_e|_keyList],[_e|_eList]) :-
	dropKeys(_keyList,_eList).



/** perm/2: aus lists/listut.pro **/
perm([], []).
perm(_List, [_First|_Perm]) :-
        select(_First, _List, _Rest),
        perm(_Rest, _Perm).



remove(_elem,[],[]).
remove(_elem,[_elem|_list],_list) :- !.
remove(_elem,[_otherElem|_list],[_otherElem|_newList]) :-
	_otherElem \== _elem,
	remove(_elem,_list,_newList).



/** remDups/2: entferne alle Duplikate **/


remDups([],[]).
remDups([_h|_t],_newT) :-
	memberchk(_h,_t),!,
	remDups(_t,_newT).
remDups([_h|_t],[_h|_newT]) :-
	remDups(_t,_newT).





/** select/3:  aus sets/setutl.pro **/
select(_Element, [_Element|_Rest], _Rest).
select(_Element, [_Head|_Tail], [_Head|_Rest]) :-
        select(_Element, _Tail, _Rest).

/**
splitListAtElem:
	Eingabe: Liste (nicht leer)
	E/A	 Element _x
	Ausgabe: Liste a: Sequenz bis _x ausschliesslich
		 Liste b: Sequenz ab _x ausschliesslich
**/


splitListAtElem([_x|_xs],_x,[],_xs).
splitListAtElem([_x|_xs],_y,[_x|_prefix],_suffix) :-
	splitListAtElem(_xs,_y,_prefix,_suffix).

/** subset/2:  aus sets/setutl.pro **/
subset([], _).
subset([_Element|_Residue], _Set) :-
        memberchk(_Element, _Set),
        !,
        subset(_Residue, _Set).



/** sumlist/2:  aus lists/listut.pro **/


sumlist(_Numbers, _Total) :-
        sumlist(_Numbers, 0, _Total).

        sumlist([], _Total, _Total).
        sumlist([_Head|_Tail], _Sofar, _Total) :-
	       _Head \== infinity,!,
               _Next is _Sofar + _Head,
               sumlist(_Tail, _Next, _Total).
	sumlist([infinity|_], _, infinity).

/** Berechne Summe und wandle sie nach Real um **/
sumlistReal(_Numbers, _Total) :-
	sumlist(_Numbers, _Total1),
	intToReal(_Total1,_Total).

/** union/3:  aus sets/setutl.pro **/
union([], _Set2, _Set2).
union([_Element|_Residue], _Set, _Union) :-
        memberchk(_Element, _Set),
        !,
        union(_Residue, _Set, _Union).
union([_Element|_Residue], _Set, [_Element|_Union]) :-
        union(_Residue, _Set, _Union).




/***********************/
/** Conversion        **/
/***********************/


intToReal(_i,_r) :-
	integer(_i),
	_r is float(_i).

intToReal(_r,_r) :-
	float(_r).


/***********************/
/** Arithmetik        **/
/***********************/


save_plus(_x,_y,_sum) :-
	_x \== infinity, _y \== infinity,
	_sum is _x + _y,
	!.

save_plus(_x,_y,infinity).



save_minus(_x,_y,_sum) :-
	_x \== infinity, _y \== infinity,
	_sum is _x - _y,
	!.
save_minus(_x,_y,infinity).




save_mult(0.0,_,0.0) :- !.
save_mult(_,0.0,0.0) :- !.
save_mult(_x,_y,_mult) :-
	_x \== infinity, _y \== infinity,
	_mult is _x * _y,
	!.
save_mult(_x,_y,infinity).




save_div(0.0,0.0,1.0) :-
	!.
save_div(0.0,_,0.0) :-
	!.
save_div(_x,_y,_mult) :-
	_x \== infinity, _y \== infinity,_y > 0,
	_mult is _x / _y,!.
save_div(_x,_y,infinity).




max(_list,_max) :-
	max(_list,0,_max).

max([],_max,_max).
max([_el|_list],_oldMax,_max) :-
	_el > _oldMax,!,
	max(_list,_el,_max).
max([_|_list],_oldMax,_max) :-
	max(_list,_oldMax,_max).


/***********************/
/** Masken            **/
/***********************/

/** Masken sind Listen mit den Elementen 0 oder 1 **/



allNull([]).
allNull([0|_mask]) :-
	allNull(_mask).



setAllOne([],[]).
setAllOne([_|_list],[1|_mask]) :-
	setAllOne(_list,_mask).




orMaskList([_mask|_maskList],_newMask) :-
	orMaskListAcc(_maskList,_mask,_newMask).



orMaskListAcc([],_mask,_mask).
orMaskListAcc([_mask|_masks],_oldMask,_resMask) :-
	orMasks(_oldMask,_mask,_newMask),
	orMaskListAcc(_masks,_newMask,_resMask).



orMasks([],[],[]).
orMasks([0|_m1],[0|_m2],[0|_res]) :-
	!,
	orMasks(_m1,_m2,_res).
orMasks([_|_m1],[_|_m2],[1|_res]) :-
	orMasks(_m1,_m2,_res).





applyMask(_,[],[]).
applyMask([_el|_list],[1|_mask],[_el|_newList]) :-
	!,
	applyMask(_list,_mask,_newList).
applyMask([_el|_list],[0|_mask],_newList) :-
	!,
	applyMask(_list,_mask,_newList).






/***********************/
/** record-database   **/
/***********************/


clearRecords(_keyStart) :-
	findall(_key,
		  (
		    pc_current_key(_key,_domkey),
		    pc_atomconcat(_keyStart,_,_key),
		    pc_erase(_key,_domkey)
		  ),
		_).



undefined(_x) :-
	_x = undef,!.



writeFacts(_file,[]).
writeFacts(_file,[_fact|_factList]) :-
	writeq(_file,_fact),
	write(_file,'.'),write(_file,'\n'),
	writeFacts(_file,_factList).

