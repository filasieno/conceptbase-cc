/**
The ConceptBase.cc Copyright

Copyright 1987-2025 The ConceptBase Team. All rights reserved.

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
/*
*
*
* File:         %M%
* Version:      %I%
*
*
* Date released : %E%  (YY/MM/DD)
*
* SCCS-Source-Pool : %P%
* Date retrieved : %D% (YY/MM/DD)
* ----------------------------------------------------------
*
* Im Modul RangeformSimplifier wird untersucht, ob eine Formel
* redundant ist. Dies bedeutet, dass die Formel In oder A - Literale
* enthaelt, die keine Loesung besitzen koennen.
*
*
* Beispiel constraint
* forall c,x In(c,Integer) and In(x,c) ==> ....
*
* Diese Formel ist eine Metaformel. Als vereinfachte Formel wird
* z.B.
* forall x In(x,4) ==> ....
* generiert.
* Das Objekt "4" kann aber keine Instanzen haben. Deswegen ist die
* Formel immer wahr, da der Bedingungsteil falsch ist.
*
* bei Regeln ist zu beachten, dass diese zwar syntaktisch Implikationen sind,
* die Implikation aber bedeutet:
*
* Fuege die Folgerung ein, wenn der Bedingungsteil wahr ist.
* redundante Regeln sind, solche, die nicht feuern koennen, weil
* der Bedingungsteil falsch ist.
*
* In der rangeform ist dieser Bedingungsteil negiert ->
* redundant sind die Regeln, deren negierter Bedingungsteil wahr ist ->
* Regeln deren Bedingungsteil die obige Form hat, also
*
* forall <false>
*
* sind redundant.
*
* Weiterhin sind Regeln der Form forall x/c ==> In(x,c) und redundant und
* fuehren bei der Berechnung der Instanzen von c zu Endlosschleifen. Ein
* einfacher Fall wird zur Zeit abgefangen.
*/



:- module('RangeformSimplifier',[
'isRedundant'/2
,'isTokenAsClass'/1
,'simpleClass'/1
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').


:- use_module('BDMLiteralDeps.swi.pl').
:- use_module('MetaRFormulas.swi.pl').


:- use_module('GeneralUtilities.swi.pl').

:- use_module('BIM2C.swi.pl').


:- use_module('Literals.swi.pl').


:- use_module('MetaUtilities.swi.pl').

:- use_module('SemanticOptimizer.swi.pl').



:- style_check(-singleton).





/* ***************** i s R e d u n d a n t ************************** */
/*                                                                    */
/* Parameter                                                          */
/* _mode: 'rule' oder 'constraint'                                    */
/* _f: Formel in rangeform                                            */
/*                                                                    */
/* ruft zur Zeit nur ClassIsToken auf, vielleicht gibt es aber noch   */
/* mehr redundante Formeln und jemand hat eine Idee, wie man das      */
/* feststellt.                                                        */
/*                                                                    */
/* ****************************************************************** */

isRedundant(_mode,_f) :-
	'ClassIsToken'(_mode,_f),!.


isRedundant(rule,rangerule(_vars,_f,_lit)) :-
   'ConclusionInCondition'(rule,rangerule(_vars,_f,_lit)),
   'WriteTrace'(veryhigh,'RangeformSimplifier',['The conclusion predicate ',idterm(_lit), ' occurs in the condition ',
              idterm(_f), ' of the rule.']),
   !.


/** ticket #301: the condition of a rangerule is represented as  **/
/** forall(_vars, _cond, FALSE); the whole rule can be ignored   **/
/** if the condition is always false.                            **/

isRedundant(rule,forall(_vars, _cond, 'FALSE')) :-
   alwaysFalse(_cond),
   'WriteTrace'(veryhigh,'RangeformSimplifier',['The rule condition ',idterm(_cond), ' is always false.']),
   !.


/** Ticket #266: remove also tautologies **/
isRedundant(constraint,_f) :-
	alwaysTrue(_f),
        !.




/* ***************** C o n c l u s i o n I n C o n d i t i o n******* */
/*                                                                    */
/* Parameter                                                          */
/* _mode: rule oder constraint                                        */
/* _f: Formel in rangeform                                            */
/*                                                                    */
/* findet Regeln der Form  $forall In(x,c) and ... ==> In(x,c)$       */
/* stehen                                                             */
/*                                                                    */
/* ****************************************************************** */

'ConclusionInCondition'(rule,rangerule(_vars,_f,_lit)) :-
	rFormulaParts(_f,forall,_,_,_sf),_sf == 'FALSE',!,
	getAllLitsForallQuant(_f,_lits),!,
	memberchk(_lit,_lits).




/* ***************** C l a s s I s T o k e n ************************ */
/*                                                                    */
/* Parameter                                                          */
/* _mode: rule oder constraint                                        */
/* _f: Formel in rangeform                                            */
/*                                                                    */
/* sammelt die In und A Literale auf, diee in einem Allquantor        */
/* stehen                                                             */
/*                                                                    */
/* ****************************************************************** */



'ClassIsToken'(constraint,rangeconstr(forall(_v,_l,_s))) :-
	!,
	getInsAndAsForallQuant(rangeconstr(forall(_v,_l,_s)),_inLits,_aLits),!,
	isTokenAsClass(_inLits,_aLits),!.

'ClassIsToken'(rule,rangerule(_vars,forall(_v,_l,_s),_lit)) :-
	!,
        getInsAndAsForallQuant(forall(_v,_l,_s),_inLits,_aLits),!,
        isTokenAsClass(_inLits,_aLits),!.



/** Dieses Muster tritt nur im MetaSimplifier auf, wenn der
   rangerule bzw rangeconstr- Funktor voruebergehend
   geloescht wurde
   isRedundant wird auch von dort aufgerufen, um festzustellen, ob
   eine Formel redundant ist. Allerdings funktioniert die Pruefung
   nur fuer in-Literale, da die Variablentabelle fuer die concernedClass
   berechnung erst nach der Rueckuebersetzung der generierten FOrmeln
   ins $$ - Format gefuellt wird.
**/
'ClassIsToken'(constraint,_f) :-
	rFormulaParts(_f,forall,_,_,_),!,
	getInsForallQuant(_f,_inLits),!,
	isTokenAsClass(_inLits),!.

'ClassIsToken'(rule,_f) :-
        rFormulaParts(_f,forall,_,_,_),!,
        getInsForallQuant(_f,_inLits),!,
        isTokenAsClass(_inLits),!.



/* ***************** g e t I n s ( A n d A s ) F o r a l l Q u a n t  */
/*                                                                    */
/* Parameter                                                          */
/* _f: Formel in rangeform                                            */
/* _inLits: In -Literale                                              */
/* _aLits: A-Literale                                                 */
/*                                                                    */
/* sammelt die In und A Literale auf, die in einem Allquantor         */
/* stehen                                                             */
/*                                                                    */
/* ****************************************************************** */


getInsAndAsForallQuant(_f,_inLits,_aLits) :-
	rFormulaParts(_f,forall,_,_range,_sf),!,
	filterInPreds(_range,_inLits1),!,
	filterAPreds(_range,_aLits1),!,
	getInsAndAsForallQuant(_sf,_inLits2,_aLits2),!,
	append(_inLits1,_inLits2,_inLits),!,
	append(_aLits1,_aLits2,_aLits),!.
getInsAndAsForallQuant(_,[],[]).

getInsForallQuant(_f,_inLits) :-
	rFormulaParts(_f,forall,_,_range,_sf),!,
	filterInPreds(_range,_inLits1),!,
	getInsForallQuant(_sf,_inLits2),!,
	append(_inLits1,_inLits2,_inLits),!.
getInsForallQuant(_,[]).


getAllLitsForallQuant(_f,_lits) :-
	rFormulaParts(_f,forall,_,_range,_sf),!,
	getAllLitsForallQuant(_sf,_otherLits),!,
	append(_range,_otherLits,_lits),!.
getAllLitsForallQuant(_f,[]).

isTokenAsClass(_inLits,_) :-
	isTokenAsClass(_inLits),!.
isTokenAsClass(_,_aLits) :-
	isTokenAsClass(_aLits),!.


isTokenAsClass(['In'(_x,_c)|_]) :-
	is_id(_c),!,
	noToken(_c),!,fail.

isTokenAsClass(['In'(_x,_c)|_]) :-
	is_id(_c),!,
	simpleClass(_id),
	prove_literal('In'(_c,_id)),!.

isTokenAsClass(['In'(_x,_c)|_ins]) :-
	isTokenAsClass(_ins).

isTokenAsClass(['A'(_x,_m,_y)|_]) :-
	is_id(_x),
	select2id(_m,_id),
	!,
	'ConcernedClass'('A'(_x,_m,_y),_cc),
	prove_literal('P'(_cc,_c,_m,_d)),
	((simpleClass(_idc),prove_literal('In'(_c,_idc)));(simpleClass(_idd),prove_literal('In'(_d,_idd)))),!.

isTokenAsClass(['A'(_x,_m,_y)|_]) :-
	select2id(_m,_id),
	!,
	'ConcernedClass'('A'(_x,_m,_y),_cc),
	prove_literal('P'(_cc,_c,_m,_d)),
	((simpleClass(_idc),prove_literal('In'(_c,_idc)));(simpleClass(_idd),prove_literal('In'(_d,_idd)))),!.


isTokenAsClass(['A'(_x,_m,_y)|_as]) :-
	isTokenAsClass(_as).

simpleClassGround(_id) :-
	id2name(_id,_name),
	memberchk(_name,['Boolean','Integer','Real','String','TransactionTime',
	'MSFOLassertion','MSFOLrule','MSFOLconstraint',
	metaMSFOLconstraint,metaMSFOLrule,
	'BDMConstraintCheck','BDMRuleCheck',
	'LTruleEvaluator','ExternalReference',
	'BuiltinQueryClass','AnswerRepresentation',
	'GraphicalType','X11_Color','ATK_TextAlign',
	'ATK_Fonts','ATK_LineCap','ATK_ShapeStyle']),!.

simpleClass(_id) :-
	member(_name,['Boolean','Integer','Real','String','TransactionTime',
	'MSFOLassertion','MSFOLrule','MSFOLconstraint',
	metaMSFOLconstraint,metaMSFOLrule,
	'BDMConstraintCheck','BDMRuleCheck',
	'LTruleEvaluator','ExternalReference',
	'BuiltinQueryClass','AnswerRepresentation',
	'GraphicalType','X11_Color','ATK_TextAlign',
	'ATK_Fonts','ATK_LineCap','ATK_ShapeStyle']),
	name2id(_name,_id).

noToken(_id) :-
	id2name(_id,_name),
	memberchk(_name,['Class','Individual','Proposition','Attribute','InstanceOf','Isa']),!.
