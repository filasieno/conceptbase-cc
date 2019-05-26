/**
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
**/
/*
* File:         VarTabHandling.pro
* Version:      2.3
*
*
* Date released : 96/01/10  (YY/MM/DD)
*
* SCCS-Source-Pool : /home/CBase/CB_NewStruct/ProductPOOL/serverSources/Prolog_Files/SCCS/s.VarTabHandling.pro
* Date retrieved : 96/01/17 (YY/MM/DD)
* -----------------------------------------------------------------------------
*
* This file provides predicates for the management of
* variable tables.
*
* Exported predicates:
* VarTabInit/0.
* VarTabInsert/2
* VarTabLookup/2
* VarTabLookup_ranges/1
* VarTabLookup_vars/1
* VarTabLookup/3   (obsolete)
* VarTabDelete/2
* VarTabVariable/1
* VarTabConstant/1
*
* Changes:
* 7-Sep-94/CQ:  Minor changes on VarTabInsert and VarTabLookup
*		see CBNEWS[176]
*
* Metaformel-Aenderungen
* neues Praedikat VarTabInsertRanges
* im AssertionTransformer wird dieses Praedikat benutzt, um die
* Variablentabelle zu fuellen.
*
* RS, 24.1.96
* Das inkrementelle Aendern der Variablentabelle in saveVarTabInsert
* wird wieder deaktiviert.
* Grund: Es ist nicht klar, welche Eintrage aus der rangeform
* in die Variablentabelle duerfen ind welche nicht.
* Beispiel: or(a,b), a und b sind rangeformen und a enthaelt
* In(x,c) und b enthaelt In(x,d)
* Welcher Klasse x angehoert haengt von den Wahrheitswerten von
* a und b ab.
* Da kein adhoc-Verfahren gefunden wurde, wird VarTabInsertRanges
* deaktiviert.
*
*/

:- module('VarTabHandling',[
'VarTabConstant'/1
,'VarTabDelete'/2
,'VarTabDestroy'/0
,'VarTabInit'/0
,'VarTabInsert'/2
,'VarTabInsertRanges'/1
,'VarTabLookup'/2
,'VarTabLookup_ranges'/1
,'VarTabLookup_vars'/1
,'VarTabVariable'/1
,'saveVarTabInsert'/2
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').


:- use_module('ErrorMessages.swi.pl').
:- use_module('GeneralUtilities.swi.pl').

:- use_module('MetaUtilities.swi.pl').

:- dynamic 'VarTab@VarTabHandling'/2 .


:- style_check(-singleton).



/*************************************************************/
/** VarTabInit                                              **/
/**                                                         **/
/** deletes all old entries from VarTab@VarTabHandling      **/
/*************************************************************/
'VarTabInit' :-
	!,
	'VarTabDelete'(_,_).

/*************************************************************/
/** VarTabDestroy                                           **/
/**                                                         **/
/** deletes all old entries from VarTab@VarTabHandling      **/
/*************************************************************/
'VarTabDestroy' :-
	!,
	'VarTabDelete'(_,_).

/*************************************************************/
/** VarTabInsertRanges(_rangeList)                          **/
/**                                                         **/
/**                                                         **/
/** _rangeList is a list with elements of the form          **/
/** range(_var,_type)                                       **/
/** these are inserted into the _vartab                     **/
/*************************************************************/
'VarTabInsertRanges'([]).
'VarTabInsertRanges'([range(_v,_t)|_rangeList]) :-
/*
      Diese Stelle kann wieder aktiviert werden,
      wenn im Modul MetaRFormulas.pro nur die
      In-Literale gefunden werden, die in die
      Variablentabelle eingetragen werden sollen.
      (siehe oben, RS, 24.1.96)
*/

      saveVarTabInsert([_v],_t),
      'VarTabInsertRanges'(_rangeList).


/*************************************************************/
/** VarTabInsert(_vars,_type)                               **/
/**                                                         **/
/** _vars : ground : list of variables to be inserted       **/
/** _type : ground : class of these variables               **/
/**                                                         **/
/** Inserts an item to the current variable table. If there **/
/** exists already an entry for this variable an error      **/
/** message is returned.                                    **/
/*************************************************************/

'VarTabInsert'([],_) :- !.

/* VarTabInsert(_vars,[_type]) :-
	VarTabInsert(_vars,_type). */

'VarTabInsert'(_vars,_type) :-
	\+(is_list(_type)),
	!,
	'VarTabInsert'(_vars,[_type]).

'VarTabInsert'([_var],_type) :-
	ground(_var),
	ground(_type),
	\+ 'VarTab@VarTabHandling'(_var,_),
	!,
	asserta('VarTab@VarTabHandling'(_var,_type)),
        !.



'VarTabInsert'([_var],_newtype) :-
	ground(_var),
	'VarTab@VarTabHandling'(_var,_type),
	report_error('ASSSYNERR6','VarTabHandling',[_var,objectName(_type)]),
	/** increment('errornumber@assertionparser'), might be necessary to stop backtracking to other (wrong solutions) **/
	!,
	'VarTabDelete'(_,_),
	fail.

'VarTabInsert'([_var|_vars],_type) :-
	'VarTabInsert'([_var],_type),
	!,
	'VarTabInsert'(_vars,_type).


/********************************************************************************/
/*  saveVarTabInsert(_varlist,_typelist)                                        */
/*                                                                              */
/*   Traegt die Elemente aus _varlist dann in die VarTab ein, wenn sie noch     */
/*   nicht darin enthalten sind.                                                */
/*                                                                              */
/********************************************************************************/

saveVarTabInsert([],_) :- !.

saveVarTabInsert([_v|_t],_typelist) :-
	'VarTabVariable'(_v),
	'VarTab@VarTabHandling'(_v,_typelist),
	!,
	saveVarTabInsert(_t,_typelist).

saveVarTabInsert([_v|_t],_typelist) :-
	'VarTabVariable'(_v),

/*
	Ist die Variable schon in der Tabelle, so werden
	neue Eintraege ignoriert.

      Diese Stelle kann wieder aktiviert werden,
      wenn im Modul MetaRFormulas.pro nur die
      In-Literale gefunden werden, die in die
      Variablentabelle eingetragen werden sollen.
      (siehe oben, RS, 24.1.96)

	retract('VarTab@VarTabHandling'(_v,_typelistOld)),
	listDifference(_typelist,_typelistOld,_newTypeList),
	append(_typelistOld,_newTypeList,_typeListToSave),
	asserta('VarTab@VarTabHandling'(_v,_typeListToSave)),
*/
	!,
	saveVarTabInsert(_t,_typelist).



saveVarTabInsert([_v|_t],_typelist) :-
	\+('VarTabVariable'(_v)),
	!,
	'VarTabInsert'([_v],_typelist),
	saveVarTabInsert(_t,_typelist).


/*************************************************************/
/** VarTabDelete(_var,_type)                                **/
/** _var : free or ground or list                           **/
/** _type : free or ground                                  **/
/** Allows three methods to delete enties from the current  **/
/** variable table                                          **/
/** 1) _var is a list : deletes entries of variables        **/
/**    occurring in the list                                **/
/** 2) _type ist ground: deletes all entries for type _type **/
/** 3) both are free: deletes all entries                   **/
/*************************************************************/

'VarTabDelete'(_var,_) :- _var == [],!.

'VarTabDelete'([_var|_vars],_type) :-
	ground(_var),
	'VarTabDelete'(_var,_type),
	'VarTabDelete'(_vars,_type).

/**
VarTabDelete(_var,_type) :-
  retract('VarTab@VarTabHandling'(_var,_type)),
  fail.
VarTabDelete(_var,_type).
**/

'VarTabDelete'(_var,_type) :-
	findall(_,
		retract('VarTab@VarTabHandling'(_var,_type)),
		_).

/*************************************************************/
/** VarTabLookup_vars(_result)                              **/
/** VarTabLookup_ranges(_result)                            **/
/** _result : should be free : list of results              **/
/**                                                         **/
/** if mode is                                              **/
/** 'vars'  : returns a list of all variables occuring in   **/
/**           the current variable table                    **/
/** 'ranges': returns a list of all entries, where an entry **/
/**           has the form 'range(_var,_type)'              **/
/**						 	   **/
/** Replaced for VarTabLookup(_mode,_result) to avoid	   **/
/** conflicts with variables like 'vars' and 'ranges'       **/
/** /CQ 1-9-1994						   **/
/*************************************************************/

'VarTabLookup_vars'(_result) :-
	!,
	findall(_x,
	      'VarTab@VarTabHandling'(_x,_t),
	      _result
	     ).

'VarTabLookup_ranges'(_result) :-
	!,
	findall(range(_x,_t),
	      'VarTab@VarTabHandling'(_x,_t),
	      _result
	     ).

/*************************************************************/
/** VarTabLookup(_var,_type)      			   **/
/** _var : free or ground                                   **/
/** _type : free or ground                                  **/
/**                                                         **/
/** VarTabLookup/2 allows three lookup methods from the     **/
/** current variable table                                  **/
/** 1) _var is ground: returns the typelist of _var         **/
/** 2) _type is ground: returns a list of Variables that    **/
/**    have type _type                                      **/
/** 3) both are ground: fails, if specified entry does not  **/
/**    exist                                                **/
/*************************************************************/


'VarTabLookup'(_var,_type) :-
	ground(_var),
	!,
	'VarTab@VarTabHandling'(_var,_type).

'VarTabLookup'(_var,_type) :-
	ground(_type),
	is_list(_type),
	!,
	findall(_x,'VarTab@VarTabHandling'(_x,_type),_var).

/*************************************************************/
/** VarTabLookup(_var,_type,_result) 			   **/
/** _var : free or ground                                   **/
/** _type : free or ground                                  **/
/** _result : should be free : list of results              **/
/**                                                         **/
/** VarTabLookup/3 allows three lookup methods from the     **/
/** current variable table                                  **/
/** 1) _var is ground: returns the type of _var             **/
/** 2) _type is ground: returns a list of Variables that    **/
/**    have type _type                                      **/
/** 3) both are ground: fails, if specified entry does not  **/
/**    exist                                                **/
/*************************************************************/

/** VarTabLookup/3 is obsolete, VarTabLookup/2 does the same
	/CQ 2-Sep-1994

VarTabLookup(_var,_type,_result) :-
	ground(_type),
	!,
	findall(_x,
	      'VarTab@VarTabHandling'(_x,_type),
	      _result
	     ).
**/

/*************************************************************/
/** VarTabVariable(_x)                                      **/
/** VarTabConstant(_x)                                      **/
/**                                                         **/
/*************************************************************/

'VarTabVariable'(_x) :-
	'VarTabLookup'(_x,_).

/** steht _x nicht in der VarTab so muss es eine Konstante sein
**/
'VarTabConstant'(_x) :-
	\+('VarTabVariable'(_x)).


