/**
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
Matthias Jarke, RWTH Aachen, Informatik 5, Ahornstr. 55, 52056 Aachen, Germany
Christoph Quix, RWTH Aachen, Informatik 5, Ahornstr. 55, 52056 Aachen, Germany


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
* Das Modul MetaRFormulas dient der Bearbeitung einer Formel in Rangeform
*
* Beispiel fuer ein Praedikat:
* rFormulaParts zerlegt eine Rangeform-Struktur in ihre Bestandteile:
* rFormulaParts(forall(_vars,_rangePreds,_subFormula),
* forall,_vars,_rangePreds,_subFormula)
*
*/

:- module('MetaRFormulas',[
'collectAllLiteralsAndVariables'/3
,'compressExists'/4
,'delPseudoIns'/2
,'elimEmptyForalls'/2
,'encloseConstraint'/5
,'encloseRule'/8
,'filterAPreds'/2
,'filterInPreds'/2
,'findFormulasClasses'/2
,'getRangesFromRangeForm'/2
,'rFormulaAnalysis'/4
,'rFormulaParts'/5
,'splitIntoCondAndCons'/4
,'substituteRF'/4
,'testIfAllExistsAndCompress'/2
,'testIfImpl'/1
,'testIfPartialEvaluable'/1
,'uniteExists'/2
,'uniteForalls'/2
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').


:- use_module('MetaLiterals.swi.pl').




:- use_module('MetaTriggerGen.swi.pl').

:- use_module('GeneralUtilities.swi.pl').
:- use_module('MetaUtilities.swi.pl').









:- use_module('Literals.swi.pl').



:- use_module('BDMLiteralDeps.swi.pl').



:- style_check(-singleton).





/*Test predicates:*/
/*
uniteForalls(forall([y,x],[In(x,Doctor),In(y,Doctor)],forall([],[],forall([z],[In(z,Doctor),A(x,boss,z),A(z,boss,y)],FALSE))),_rf).

*/
/*testRF1(forall([p,c,m,d,x],[In(p,Nec),In(x,c),P(p,c,m,d)],exists([y],[In(y,d),A(x,m,y)],TRUE)),[p,c,m,d,x],[P,C,M,D,X],_newRF).
testRF1(and([forall([p,c,m,d,x],[In(p,Nec),In(x,c),P(p,c,m,d)],FALSE),exists([y],[In(y,d),A(x,m,y)],TRUE)]),[p,c,m,d,x],[P,C,M,D,X],_newRF).
testRF1(forall([p,c,m,d,x,y],[In(p,Nec),In(x,c),P(p,c,m,d),In(y,d)],and([not(A(c,m,y)),A(x,m,y)])),[c],[C],_newRF).
testRF2(forall([p,c,m,d,x],[In(p,Nec),In(x,c),P(p,c,m,d)],exists([y],[In(y,d),A(x,m,y)],TRUE)),_vars,_cons,_lits).
testRF2(and([forall([p,c,m,d,x],[In(p,Nec),In(x,c),P(p,c,m,d)],FALSE),exists([y],[In(y,d),A(x,m,y)],TRUE)]),_vars,_cons,_lits).
*/
testRF1(_rFormula,_vars,_cons,_rfNew) :-
 	substituteRF(_rFormula,_vars,_cons,_rfNew).
testRF2(_rFormula,_vars,_cons,_lits) :-
	rFormulaAnalysis(_rFormula,_vars,_cons,_lits).


/*--------------EXPORT PART ------------------------*/
/*--------------------------------------------------*/
/*--------------------------------------------------*/

convertIntoImpl(rangeconstr(_rf),rangeconstr(_f)) :-
	convertIntoImpl(_rf,_f).
convertIntoImpl(rangerule(_vars,_rf,_lit),rangerule(_vars,_f,_lit)) :-
	convertIntoImpl(_rf,_f).
convertIntoImpl(forall(_vars,_lits,_sf),forall(_vars,_lits,_newSF)) :-!,
	convertIntoImpl(_sf,_newSF).
convertIntoImpl(exists(_vars,_lits,_sf),exists(_vars,_lits,_newSF)) :-!,
	convertIntoImpl(_sf,_newSF).
convertIntoImpl(or(_formulaList),forall([],_cond,_cons)) :-
	testIfImpl(_formulaList),
	splitIntoCondAndCons(_formulaList,_cond,_cons1,0),
	convertIntoImpl(_cons1,_cons).
convertIntoImpl(or(_formulaList),or(_formulaList)) :-
	testIfImpl(_formulaList),
	splitIntoCondAndCons(_formulaList,_cond,_cons1,_status),
	_status \== 0,!.
convertIntoImpl(_f,_f).



delPseudoIns(_f1,_f) :-
	rFormulaParts(_f1,_functor,_vars,_rangePreds,_sf1),
	memberchk(_functor,[forall,exists]),!,
	removeMultiEntries(_rangePreds,_rangePreds1),
	listDifference2(_rangePreds1,['In'(_,'VAR')],_newRPreds),
	delPseudoIns(_sf1,_sf),
	rFormulaParts(_f,_functor,_vars,_newRPreds,_sf).
delPseudoIns(_f1,_f) :-
	rFormulaParts(_f1,_functor,_vars,_rangePreds,_sf),
	memberchk(_functor,[and,or]),!,
	removeMultiEntries(_sf,_sf1),
	listDifference2(_sf1,['In'(_,'VAR')],_sf2),
	delPseudoInsList(_sf2,_newSf),
	rFormulaParts(_f,_functor,_vars,_rangePreds,_newSf).
delPseudoIns(_f,_f).


elimEmptyForalls(forall([],_lits,forall(_vars,_lits1,_subRF)),_newRF):-
	!,append(_lits,_lits1,_newLits),
	  elimEmptyForalls(forall(_vars,_newLits,_subRF),_newRF).
elimEmptyForalls(_rf,_rf).



encloseConstraint(_functor,_formulaList,_newFormulaList,_triggerList,_newTriggerList) :-
	encloseConstraintFormula(_functor,_formulaList,_newFormulaList),
	encloseConstraintTrigger(_functor,_triggerList,_newTriggerList).

encloseConstraintFormula(_,[],[]).
encloseConstraintFormula(_functor,[_f|_formulas],[_newFormula|_newFormulas]) :-
	_newFormula =.. [_functor,_f],
	encloseConstraintFormula(_functor,_formulas,_newFormulas).

encloseRule(_functor,_formulaList,_vars,_substList,_lit,_newFormulaList,_triggerList,_nTriggerList) :-
	encloseRuleFormula(_functor,_formulaList,_vars,_substList,_lit,_newFormulaList),
	encloseRuleTrigger(_functor,_triggerList,_vars,_lit,_nTriggerList).

encloseRuleFormula(_,[],_,[],_,[]).
encloseRuleFormula(_functor,[_f|_formulas],_vars,[subst(_v,_c)|_substList],_lit,[_newF|_newFormulas]) :-
	listDifference(_vars,_v,_newVars),
	substituteLits([_lit],_v,_c,[_newLit]),
	_newF =.. [_functor,_newVars,_f,_newLit],
	encloseRuleFormula(_functor,_formulas,_vars,_substList,_lit,_newFormulas).

findFormulasClasses([],[]).
findFormulasClasses([_rf|_rfs],[_class|_classes]) :-
	findFormulaClass(_rf,_class),
	findFormulasClasses(_rfs,_classes).


rangeRuleToRFormula(rangerule(_vars,_rFormula,_literal),_newRF,_vars,_literal):-
	insertLiteral(_rFormula,_literal,_newRF).


/*
rFormulaAnalysis(_rangeFormula,_varList,_consList,_literalList):
_rangeFormula is a rangeformula
_varList is the list of variables occuring
_consLst is the list of constants occuring
_literalList is the list of literals occuring

*/


rFormulaAnalysis(_rangeFormula,_varList,_consList,_literalList) :-
	collectAllLiteralsAndVariables(_rangeFormula,_literalList,_varList),
	collectArguments(_literalList,_argumentList),
	listDifference(_argumentList,_varList,_consList).

/*
rFormulaParts(_rf,_quantor,_vars,_lits,_subFormula1,_subFormula2)
This predicate divides a rangeFormula into its parts.
*/
rFormulaParts(rangeconstr(_rf),rangeconstr,[],[],_rf) :- !.
rFormulaParts(rangerule(_vars,_rf,_lit),rangerule,_vars,[_lit],_rf) :- !.
rFormulaParts(forall(_vars,_rangePreds,_rFormula),forall,_vars,_rangePreds,_rFormula) :- !.
rFormulaParts(exists(_vars,_rangePreds,_rFormula),exists,_vars,_rangePreds,_rFormula) :- !.
rFormulaParts(and(_rFormulaList),and,[],[],_rFormulaList) :- !.
rFormulaParts(or(_rFormulaList),or,[],[],_rFormulaList) :- !.
rFormulaParts(not(_lit),'not',[],[],_lit) :- !.
rFormulaParts(_lit,lit,[],[],_lit) .

/*
substituteRF(_oldRF,_vars,_cons,_newRF)
in _oldRF all members of _vars are substituted with the
corresponding members of _cons to obtain _newRF
*/

substituteRF(_rf,[],[],_rf) :- !.
substituteRF(_rf,_subVars,_subCons,_newRf) :-
	rFormulaParts(_rf,_functor,_vars,_preds,_subRF),
/*	write(rFormulaParts(_rf,_functor,_vars,_preds,_subRF)),nl,nl,*/
	memberchk(_functor,[rangeconstr]),!,
	substituteRF(_subRF,_subVars,_subCons,_newSubRF) ,
	rFormulaParts(_newRf,_functor,[],[],_newSubRF).
substituteRF(_rf,_subVars,_subCons,_newRf) :-
	rFormulaParts(_rf,_functor,_vars,_preds,_subRF),
/*	write(rFormulaParts(_rf,_functor,_vars,_preds,_subRF)),nl,nl,*/
	memberchk(_functor,[rangerule]),!,
	listDifference(_vars,_subVars,_newVars),
/*	write(listDifference(_vars,_subVars,_newVars)),nl,nl,*/
/*	write(substituteLits(_preds,_subVars,_subCons,_newPreds)),nl,nl,*/
	substituteLits(_preds,_subVars,_subCons,_newPreds) ,
/*	write(substituteLits(_preds,_subVars,_subCons,_newPreds)),nl,nl,*/
	substituteRF(_subRF,_subVars,_subCons,_newSubRF) ,
	rFormulaParts(_newRf,_functor,_newVars,_newPreds,_newSubRF).
substituteRF(_rf,_subVars,_subCons,_newRf) :-
/*	write(rFormulaParts(_rf,_functor,_vars,_preds,_subRF)),nl,nl,*/
	rFormulaParts(_rf,_functor,_vars,_preds,_subRF),
/*	write(rFormulaParts(_rf,_functor,_vars,_preds,_subRF)),nl,nl,*/
	memberchk(_functor,[forall,exists]),!,
/*	write(collectArguments(_preds,_argList)),nl,nl,*/
	collectArguments(_preds,_argList),
/*	write(collectArguments(_preds,_argList)),nl,nl,	*/
/*	write(listDifference(_vars,_subVars,_newVars)),nl,nl,*/
	listDifference(_vars,_subVars,_newVars),
/*	write(listDifference(_vars,_subVars,_newVars)),nl,nl,*/
/*	write(substituteLits(_preds,_subVars,_subCons,_newPreds)),nl,nl,*/
	substituteLits(_preds,_subVars,_subCons,_newPreds) ,
/*	write(substituteLits(_preds,_subVars,_subCons,_newPreds)),nl,nl,*/
	substituteRF(_subRF,_subVars,_subCons,_newSubRF) ,
	rFormulaParts(_newRf,_functor,_newVars,_newPreds,_newSubRF).
substituteRF(_rf,_subVars,_subCons,_newRf) :-
	rFormulaParts(_rf,_functor,_vars,_preds,_subRFList),
	memberchk(_functor,[and,or]),!,
	substituteRFList(_subRFList,_subVars,_subCons,_newSubRFList),
	rFormulaParts(_newRf,_functor,_newVars,_preds,_newSubRFList).
substituteRF(_lit,_subVars,_subCons,_newLit) :- !,
	substituteLits([_lit],_subVars,_subCons,[_newLit]).
substituteRF(not(_lit),_subVars,_subCons,not(_newLit)) :- !,
	substituteLits([_lit],_subVars,_subCons,[_newLit]).

testIfPartialEvaluable(forall(_vars,_lits,_subFormula)) :- !.

testIfAllExistsAndCompress(and(_formulaList),exists(_vars,_lits,_newSF)) :-
/*	write(compressAllExists(_formulaList,_newFormulaList)),nl,nl,*/
	compressAllExists(_formulaList,_newFormulaList),
/*	write(collectExists(_newFormulaList,_vars,_lits,TRUE,_newSF)),nl,nl,*/
	collectExists(_newFormulaList,_vars,_lits,'TRUE',_newSF).

compressAllExists([],[]).
compressAllExists([exists(_oldVars,_oldLits,_oldSubFormula)|_fs],[exists(_vars,_lits,_subFormula)|_newFs]) :-
	!,compressExists(exists(_oldVars,_oldLits,_oldSubFormula),_vars,_lits,_subFormula),
	compressAllExists(_fs,_newFs).
compressAllExists([_f|_fs],[_f|_newFs]) :-
	compressAllExists(_fs,_newFs).

uniteExists(exists(_vars,_lits,_subFormula),exists(_newVars,_newLits,_newSubFormula)) :-
	compressExists(exists(_vars,_lits,_subFormula),_newVars,_newLits,_newSubFormula).

uniteForalls(forall(_vars1,_lits1,forall(_vars2,_lits2,_sf)),forall(_nv1,_nl1,_nsf)) :-
/*	write(uniteForalls(forall(_vars2,_lits2,_sf),forall(_nv2,_nl2,_nsf))),nl,*/
	!,uniteForalls(forall(_vars2,_lits2,_sf),forall(_nv2,_nl2,_nsf)),
/*	write(uniteForalls(forall(_vars2,_lits2,_sf),forall(_nv2,_nl2,_nsf))),nl,*/
	append(_vars1,_nv2,_nv1),
/*	write(append(_vars1,_nv2,_nv1)),nl,*/
	append(_lits1,_nl2,_nl1)
/*	,write(append(_lits1,_nl2,_nl1)),nl*/.
uniteForalls(_rf,_rf).



compressExists(exists(_vars,_lits,_subFormula),_newVars,_newLits,_newSubFormula) :-
	!,
	compressExists(_subFormula,_subVars,_subLits,_newSubFormula),
	append(_vars,_subVars,_newVars),
	append(_lits,_subLits,_newLits).
compressExists(_f,[],[],_f).

collectExists([],[],[],_subFormula,_subFormula).
collectExists([exists(_vars,_lits,_subFormula)|_fs],_newVars,_newLits,_subFormulaOld,_newSF) :-
	((_subFormulaOld == 'TRUE',_newSubFormula = _subFormula) ; (_subFormula == 'TRUE')),
	collectExists(_fs,_fsVars,_fsLits,_newSubFormula,_newSF),
	append(_vars,_fsVars,_newVars),
	append(_lits,_fsLits,_newLits).



getRangesFromRangeForm(_rFormula1,_varClasses) :-
	convertIntoImpl(_rFormula1,_rFormula),
	collectAllLiteralsAndVariables(_rFormula,_literals,_variables),
	filterInPreds(_literals,_inLits),
	findVarClasses(_variables,_inLits,_varClasses1),
	optimizeVarClasses(_varClasses1,_varClasses).

/*-----------------------------LOCAL PART --------------------------*/


optimizeVarClasses([],[]) :- !.

optimizeVarClasses([range(_var,_varclasses)|_rest],[range(_var,_varclasses1)|_opmimized_rest]) :-
  minimizeClasses(_varclasses,_varclasses1),
  optimizeVarClasses(_rest,_opmimized_rest),
  !.

optimizeVarClasses(_x,_x).  /** never fail **/

minimizeClasses(_clist1,_clist2) :-
  name2id('Proposition',_Proposition),
  setDifference(_clist1,[_Proposition],_clist2),
  _clist2 \= [],
  !.
minimizeClasses(_x,_x).
  


  



collectAllLiteralsAndVariables(_rFormula,_literals,_variables) :-
	collectAllLiteralsAndVariables(_rFormula,[],_literals1,[],_variables1),
	removeMultiEntries(_literals1,_literals),
	removeMultiEntries(_variables1,_variables).


/*
All Variables are quantified ->
-	Variables are found as first argument of the forall/exists RFormulas
_	no duplicate variables occur

*/

collectAllLiteralsAndVariables(_rf,_litsUntilNow,_lits,_varsUntilNow,_vars) :-
	rFormulaParts(_rf,_functor,_vars1,_lits1,_subRF),
	memberchk(_functor,[rangerule,rangeconstr]),!,
	append(_varsUntilNow,_vars1,_vars2),
	append(_litsUntilNow,_lits1,_lits2),
	collectAllLiteralsAndVariables(_subRF,_lits2,_lits,_vars2,_vars).
collectAllLiteralsAndVariables(_rf,_litsUntilNow,_lits,_varsUntilNow,_vars) :-
	rFormulaParts(_rf,_functor,_vars1,_lits1,_subRF),
	memberchk(_functor,[forall,exists]),!,
	append(_varsUntilNow,_vars1,_vars2),
	append(_litsUntilNow,_lits1,_lits2),
	collectAllLiteralsAndVariables(_subRF,_lits2,_lits,_vars2,_vars).
collectAllLiteralsAndVariables(_rf,_litsUntilNow,_lits,_varsUntilNow,_vars) :-
	rFormulaParts(_rf,_functor,[],[],_rfList),
	memberchk(_functor,[and,or]),!,
	collectAllLiteralsAndVariablesFromList(_rfList,_rfListVars,_rfListLits),
	append(_varsUntilNow,_rfListVars,_vars),
	append(_litsUntilNow,_rfListLits,_lits).
collectAllLiteralsAndVariables(not(_lit),_l,[not(_lit)|_l],_vars,_vars):- !.
collectAllLiteralsAndVariables(_lit,_l,[_lit|_l],_vars,_vars):- !.


collectAllLiteralsAndVariablesFromList([],[],[]).
collectAllLiteralsAndVariablesFromList([_rf|_rfList],_vars,_lits) :-
	collectAllLiteralsAndVariables(_rf,_rfLits,_rfVars),
	collectAllLiteralsAndVariablesFromList(_rfList,_rfListVars,_rfListLits) ,
	append(_rfVars,_rfListVars,_vars) ,
	append(_rfLits,_rfListLits,_lits).


delPseudoInsList([],[]).
delPseudoInsList([_f|_fs],[_newF|_newFs]) :-
	delPseudoIns(_f,_newF),
	delPseudoInsList(_fs,_newFs).

insertLiteral(forall(_vars,_lits,_subRF),_lit,forall(_vars,_lits,_newSubRF)) :- !,
	insertLiteral(_subRF,_lit,_newSubRF).
insertLiteral(exists(_vars,_lits,_subRF),_lit,exists(_vars,_lits,_newSubRF)) :- !,
	insertLiteral(_subRF,_lit,_newSubRF).
insertLiteral(and(_formulas),_lit,and([_lit|_formulas])) :- !,
	insertLiteral(_subRF,_lit,_newSubRF).
insertLiteral(or(_formulas),_lit, or([_lit|_formulas])) :- !,
	insertLiteral(_subRF,_lit,_newSubRF).
insertLiteral('TRUE',_lit,_lit) :- !.
insertLiteral('FALSE',_lit,_lit) :- !.
insertLiteral(_lit1,_lit,and([_lit1,_lit])).


/** Ticket #155: we no longer demand that _c is an instance of Class to select it **/
/** as the class that will store the readable text of the generated assertion.    **/
/** The procedure do_store_generated_assertion in FragmentToProposition will make **/
/** sure that _c is an instance of Class.                                         **/
/** By this, we try hard to find a suitable 'host class' for a generated          **/
/** assertion.                                                                    **/

findFormulaClass(rangerule(_vars,_,'In'(_x,_c)),_c1) :- 
	is_id(_c),
	coreClass(_c,_c1),
	!.

findFormulaClass(rangerule(_vars,_rf,_lit),_c) :-
	findFormulaClass(_rf,_c).

findFormulaClass(rangerule(_vars,_,_lit),_c1) :-
	'ConcernedClass'(_lit,_c),
	coreClass(_c,_c1),
        !.

findFormulaClass(rangeconstr(_rf),_c) :-
	!,
	findFormulaClass(_rf,_c).


findFormulaClass(_rf,_c) :-
	rFormulaParts(_rf,_quantor,_vars,_lits,_subformula),
	memberchk(_quantor,[forall,exists]),
        generateCandidateClasses(_vars,_lits,_candidates),
        selectFromCandidates(_candidates,_c),
	!.

findFormulaClass(_rf,_c) :-
	rFormulaParts(_rf,_quantor,_vars,_lits,_subformula),
	memberchk(_quantor,[forall,exists]),
	findFormulaClass(_subformula,_c).

findFormulaClass(_rf,_c) :-
	rFormulaParts(_rf,_quantor,_vars,_lits,_subformulaList),
	memberchk(_quantor,[and,or]),
	findFormulaListClass(_subformulaList,_c),!.

findFormulaClass('In'(_x,_c),_c1) :-
	is_id(_c),
	coreClass(_c,_c1),
	!.

/** the cases below are very unlikely to occur in a formula **/
findFormulaClass('A'(_c,_m,_y),_c) :-
	name2id('Class',_id),
	is_id(_c),
	prove_literal('In'(_c,_id)),!.

findFormulaClass('A'(_x,_m,_c),_c) :-
        name2id('Class',_id),
        is_id(_c),
        prove_literal('In'(_c,_id)),!.

findFormulaClass('A_label'(_c,_m,_y,_n),_c) :-
        name2id('Class',_id),
        is_id(_c),
        prove_literal('In'(_c,_id)),!.

findFormulaClass('A_label'(_x,_m,_c,_n),_c) :-
        name2id('Class',_id),
        is_id(_c),
        prove_literal('In'(_c,_id)),!.

/** ticket #207: support A_e like A **/
findFormulaClass('A_e'(_c,_m,_y),_c) :-
        name2id('Class',_id),
        is_id(_c),
        prove_literal('In'(_c,_id)),!.
findFormulaClass('A_e'(_x,_m,_c),_c) :-
        name2id('Class',_id),
        is_id(_c),
        prove_literal('In'(_c,_id)),!.


findFormulaClass('IsA'(_c,_d),_c1) :-
        is_id(_c),
	coreClass(_c,_c1),
        !.

findFormulaClass('IsA'(_d,_c),_c1) :-
        is_id(_c),
	coreClass(_c,_c1),
        !.



/**Catchall **/
/** We might want to select a class in the current module but we know nothing about module content here **/
/** So, we take the class Class if all the above cases failed.                                          **/
findFormulaClass(_,_id) :-
	name2id('Class',_id).


findFormulaListClass([_f|_fs],_class) :-
	findFormulaClass(_f,_class),
	name2id('Class',_id),
	_class \== _id,!.
findFormulaListClass([_|_fs],_class) :-
	findFormulaListClass(_fs,_class).


/** generateCandidateClasses produces a list of class id's  that are candidates **/
/** to host the rule/constraint attribute for the generated assertion.          **/
/** The procedure selectFromCandidates then selects a suitable candidate from   **/
/** the list, avoiding Proposition,Individual,String,Integer and Real.          **/

generateCandidateClasses(_vars,_lits,_candidates) :-
   findall(_cand,isCandididateClass(_vars,_lits,_cand),_candidates),
   !.

isCandididateClass(_vars,_lits,_c) :-
	member(_x,_vars),  /** _c is only a good candidate if _x is a variable in the formula **/
	member('In'(_x,_c1),_lits),
	is_id(_c1),
        coreClass(_c1,_c).

isCandididateClass(_vars,_lits,_c) :-
	member(_lit,_lits),
	_lit \= 'In'(_,_),
	findFormulaClass(_lit,_c).

coreClass(_c,_sc) :-
  prove_literal('In'(_c,id_65)),  /** id_65=QueryClass **/
  prove_literal('Isa'(_c,_sc)),  /** use superclass of a query class that is not a query class **/
  \+ prove_literal('In'(_sc,id_65)),  /** id_65=QueryClass **/
  !.

coreClass(_c,_c) :-
  prove_literal('In'(_c,id_7)),  /** id_7=Individual **/
  !.

coreClass(_c1,_c) :-
  prove_literal('From'(_c1,_d)),
  _d \== _c1,
  coreClass(_d,_c).
  
selectFromCandidates(_candidates,_c) :-
  name2id('Class',_p0),
  name2id('Proposition',_p1),
  name2id('Individual',_p2),
  name2id('String',_p3),
  name2id('Integer',_p4),
  name2id('Real',_p5),
  setDifference(_candidates,[_p0,_p1,_p2,_p3,_p4,_p5],_goodcandidates),
  member(_c,_goodcandidates),
  !.
/** if we have no good candidate, we take the first of the original candidates **/
selectFromCandidates(_candidates,_c) :-
  member(_c,_candidates),
  !.





filterAPreds([],[]).
filterAPreds(['A'(_x,_m,_y)|_lits],['A'(_x,_m,_y)|_newLits]):-!,
	filterAPreds(_lits,_newLits).
filterAPreds([not('A'(_x,_m,_y))|_lits],[not('A'(_x,_m,_y))|_newLits]) :-
	!,filterAPreds(_lits,_newLits).
filterAPreds([_l|_lits],_newLits):-
	litParts(_l,_f,_),_f \== 'A',
	filterAPreds(_lits,_newLits).

filterInPreds([],[]).
filterInPreds(['In'(_x,_c)|_lits],['In'(_x,_c)|_newLits]) :-
	!,filterInPreds(_lits,_newLits).
/** also filter In_e and In_s; ticket #314 **/
filterInPreds(['In_e'(_x,_c)|_lits],['In_e'(_x,_c)|_newLits]) :-
	!,filterInPreds(_lits,_newLits).
filterInPreds(['In_s'(_x,_c)|_lits],['In_s'(_x,_c)|_newLits]) :-
	!,filterInPreds(_lits,_newLits).

/** ticket #404 **/
filterInPreds(['Isa'(_x,_c)|_lits],['Isa'(_x,_c)|_newLits]) :-
	!,filterInPreds(_lits,_newLits).

/** 11-Nov-2003/M.Jeusfeld **/
filterInPreds(['A'(_x,_m,_y)|_lits],['A'(_x,_m,_y)|_newLits]) :-
        !,filterInPreds(_lits,_newLits).
filterInPreds([not('A'(_x,_m,_y))|_lits],[not('A'(_x,_m,_y))|_newLits]) :-
        !,filterInPreds(_lits,_newLits).

/*7-Apr-2005/M.Jeusfeld **/
filterInPreds(['Label'(_x,_m)|_lits],['Label'(_x,_m)|_newLits]) :-
        !,filterInPreds(_lits,_newLits).
filterInPreds([not('Label'(_x,_m))|_lits],[not('Label'(_x,_m))|_newLits]) :-
        !,filterInPreds(_lits,_newLits).


filterInPreds([not('In'(_x,_c))|_lits],[not('In'(_x,_c))|_newLits]):-
	!,filterInPreds(_lits,_newLits).
filterInPreds([_l|_lits],_newLits):-
	litParts(_l,_f,_),_f \== 'In',
	filterInPreds(_lits,_newLits).


findVarClasses([],_,[]).
findVarClasses([_var|_vars],_literals,[range(_var,_classList)|_varRanges]) :-
	findall(_class,member('In'(_var,_class),_literals),_classList),
	findVarClasses(_vars,_literals,_varRanges).


substituteRFList([],_,_,[]).
substituteRFList([_subRF|_subRFList],_subVars,_subCons,[_newSubRF|_newSubRFList]) :-
	substituteRF(_subRF,_subVars,_subCons,_newSubRF),
	substituteRFList(_subRFList,_subVars,_subCons,_newSubRFList).



splitIntoCondAndCons([_f],[],_f,0).
splitIntoCondAndCons([_f|_fs],[_lit|_fsNew],_cons,_status):-
	_f =.. ['not'|[_lit]],
	simpleLiteral(_lit),
	splitIntoCondAndCons(_fs,_fsNew,_cons,_status).
splitIntoCondAndCons([_f|_],[],_f,-1) :-
	_f =.. ['not'|_lit],
	not(simpleLiteral(_lit)).



testIfImpl([_f]).
testIfImpl([_f|_fs]) :-
	_f =.. ['not'|[_lit]],
	simpleLiteral(_lit),
	testIfImpl(_fs).




