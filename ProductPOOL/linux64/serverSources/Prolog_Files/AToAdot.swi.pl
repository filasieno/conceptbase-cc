/**
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
**/
/*************************************************************************
*
* File:         AToAdot.pro
* Version:      12.1
*
*
* Date released : 98/04/03  (YY/MM/DD)
*
* SCCS-Source-Pool : /home/CBase/CB_NewStruct/ProductPOOL/SCCS/serverSources/Prolog_Files/s.AToAdot.pro
* Date retrieved : 99/06/29 (YY/MM/DD)
**************************************************************************
*
* Im Modul AToAdot ist die Ersetzung von A-Literalen durch Adot-Literalen
* verkapselt.
* Frueher wurde diese Ersetzung schon beim Parsen durchgefuehrt. Ist jedoch
* eine Formel eine Metaformel, d.h. enthaelt sie Klassenvariablen, so kann
* die ConcernedClass eines A-Literals erst nach der partiellen Auswertung
* bestimmt werden. Deswegen wurde ein Praedikat AToAdot eingefuehrt, welches
* die Ersetzung auf der Rangeform durchfuehrt.
*
***************************************************************************/

:- module('AToAdot',[
'aToAdot'/2
,'replaceAsWithAdots'/2
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').

:- use_module('BDMLiteralDeps.swi.pl').
:- use_module('MetaRFormulas.swi.pl').
:- use_module('GeneralUtilities.swi.pl').
:- use_module('PrologCompatibility.swi.pl').

:- use_module('Literals.swi.pl').
:- use_module('ErrorMessages.swi.pl').
:- use_module('MetaUtilities.swi.pl').





:- style_check(-singleton).




/***************************************************************************
*
* replaceAsWithAdots(_rfIn,_rfOut)
*
* _rfIn (ground): Rangeformula
* _rfOut (free) : Rangeformula, with A-Literals replaced by Adot-Literals
*
****************************************************************************/



replaceAsWithAdots(_rf,_rfNew) :-
	rFormulaParts(_rf,_functor,_vars,_lits,_subFormula),
	memberchk(_functor,[rangeconstr,rangerule]),!,
	replaceAsWithAdots(_subFormula,_newSF),
	save_aToAdot(_lits,_newLits),
	rFormulaParts(_rfNew,_functor,_vars,_newLits,_newSF).


replaceAsWithAdots(_rf,_rfNew) :-
	rFormulaParts(_rf,_functor,_vars,_lits,_subFormula),
	memberchk(_functor,[forall,exists]),!,
	save_aToAdot(_lits,_newLits),
	replaceAsWithAdots(_subFormula,_newSF),
	rFormulaParts(_rfNew,_functor,_vars,_newLits,_newSF).


replaceAsWithAdots(_rf,_rfNew) :-
	rFormulaParts(_rf,_functor,[],[],_subFormulaList),
	memberchk(_functor,[and,or]),!,
	replaceAsWithAdotsRFList(_subFormulaList,_newSFList),
	rFormulaParts(_rfNew,_functor,[],[],_newSFList).


replaceAsWithAdots(_rf,_rfNew) :-
	rFormulaParts(_rf,_functor,[],[],_lit),
	_functor == 'not',
	save_aToAdot([_lit],[_rfNew1]),
	rFormulaParts(_rfNew,'not',[],[],_rfNew1).


replaceAsWithAdots(_rf,_rfNew) :-
	rFormulaParts(_rf,_functor,[],[],_lit),
	_functor == 'lit',
	save_aToAdot([_lit],[_rfNew]).

/********************************* local predicates **********************/

/************************************************************************
*
* replaceAsWithAdotsRFList(_rfListIn,_rfListOut)
*
* applies  replaceAsWithAdots to a list of Rangeformulas
*
* _rfListIn (ground): List of Rangeformulas
* _rfListOut (free) : List of Rangeformulas, with A-Literals replaced by
*                     Adot-Literals
*
*************************************************************************/



replaceAsWithAdotsRFList([],[]).
replaceAsWithAdotsRFList([_sf|_subFormulaList],[_nSF|_newSFList]) :-
	replaceAsWithAdots(_sf,_nSF),
	replaceAsWithAdotsRFList(_subFormulaList,_newSFList).


save_aToAdot(_lits,_newlits) :-
  pToPa(_lits,_lits1),
  aToAdot(_lits1,_newlits),
  checkAdots(_newlits),
  !.


/** This check makes sure that if an individual object is used as concerned class of an **/
/** attribution predicate (x m y), then an error is raised. See ticket #205.            **/
checkAdots([]) :- !.

checkAdots(['Adot'(_cc,_x,_y)|_rest]) :-
  prove_literal('In_e'(_cc,id_7)),   /** id_7=Individual **/
  report_error('INDIVCC','AToAdot',[objectName(_cc)]),
  increment('error_number@F2P'),   /** individuals not allowed as concerned classes of Adot literals **/
  !.

checkAdots(['Adot_label'(_cc,_x,_y,_l)|_rest]) :-
  prove_literal('In_e'(_cc,id_7)),   /** id_7=Individual **/
  report_error('INDIVCC','AToAdot',[objectName(_cc)]),
  increment('error_number@F2P'),   /** individuals not allowed as concerned classes of Adot literals **/
  !.

checkAdots(['Adot'(_cc,_x,_y)|_rest]) :-
  (_x = derive(_q,_args);
   _y = derive(_q,_args)),
  report_error('DERIVEARG','AToAdot',[objectName(_q)]),
  increment('error_number@F2P'),   /** derive expressions not allowed in Adot literals **/
  !.

checkAdots(['Adot_label'(_cc,_x,_y,_l)|_rest]) :-
  (_x = derive(_q,_args);
   _y = derive(_q,_args)),
  report_error('DERIVEARG','AToAdot',[objectName(_q)]),
  increment('error_number@F2P'),   /** derive expressions not allowed in Adot literals **/
  !.

checkAdots([_|_rest]) :- 
  checkAdots(_rest).

/************************************************************************
*
* aToAdot(_lit,_dottedLit)
*
* _lit (ground): Literal
* _dottedLit (free) : If _lit is A/3 or Ai/3, then _dotted lit is
*                     Adot/4 resp. Aidot/4
*
*************************************************************************/


aToAdot([],[]).

aToAdot(['A_label'(_x,_l,_y,_la)|_lits],['Adot_label'(_cc,_x,_y,_la)|_newLits]) :-
	'ConcernedClass'('A'(_x,_l,_y),_cc),!,
	aToAdot(_lits,_newLits).

/** ticket #330 **/
aToAdot(['Ae_label'(_x,_l,_y,_la)|_lits],['Aedot_label'(_cc,_x,_y,_la)|_newLits]) :-
	'ConcernedClass'('A'(_x,_l,_y),_cc),!,
	aToAdot(_lits,_newLits).

aToAdot(['A'(_x,_l,_y)|_lits],['Adot'(_cc,_x,_y)|_newLits]) :-
	'ConcernedClass'('A'(_x,_l,_y),_cc),!,
	aToAdot(_lits,_newLits).

/** ticket #207: improve support for A_e **/
aToAdot(['A_e'(_x,_l,_y)|_lits],['Aedot'(_cc,_x,_y)|_newLits]) :-
        'ConcernedClass'('A'(_x,_l,_y),_cc),!,
        aToAdot(_lits,_newLits).

aToAdot(['Ai'(_x,_l,_y)|_lits],['Aidot'(_cc,_x,_y)|_newLits]) :-
	'ConcernedClass'('Ai'(_x,_l,_y),_cc),!,
	aToAdot(_lits,_newLits).

aToAdot(['Mod'(_lit,_m)|_lits],['Mod'(_newlit,_m)|_newlits]) :-
	'M_SearchSpace'(_omod),
	pc_update('M_SearchSpace'(_m)),
	aToAdot([_lit],[_newlit]),
	pc_update('M_SearchSpace'(_omod)),
	aToAdot(_lits,_newlits).

aToAdot([_lit|_lits],[_lit|_newLits]) :-
	aToAdot(_lits,_newLits).


/************************************************************************
*
* pToPa(_lits,_newlits)
*
* _lits (ground): list of literals
* _newlits (free) : literals where P-literals are replaced by Pa-literals where possible and useful
*
*************************************************************************/


pToPa(_lits,_newlits) :-
  do_pToPa(_lits,_lits,_newlits),
  !.
pToPa(_lits,_lits). /** never fail **/

do_pToPa(_alllits,[],[]).

do_pToPa(_alllits,['P'(_id,_x,_l,_y)|_restlits],['Pa'(_id,_x,_l,_y)|_restnewlits]) :-
   memberchk('In'(_id,id_6),_alllits),  /** id_6=Attribute **/
   'WriteTrace'(veryhigh,'AToAdot',['replace P-predicate by ---> ',idterm('Pa'(_id,_x,_l,_y))]),
   do_pToPa(_alllits,_restlits,_restnewlits).

/**
* This case actually is not leading to better code since the Pa predicate would not lead
* to an elimination of In(id,ac) by SemanticOptimizer.
do_pToPa(_alllits,[P(_id,_x,_l,_y)|_restlits],[Pa(_id,_x,_l,_y)|_restnewlits]) :-
   memberchk(In(_id,_ac),_alllits),
   is_id(_ac),
   prove_literal(Pa(_ac,_c,_m,_d)),  
   do_pToPa(_alllits,_restlits,_restnewlits).
**/
  

do_pToPa(_alllits,[_lit|_restlits],[_lit|_restnewlits]) :-
   do_pToPa(_alllits,_restlits,_restnewlits).




