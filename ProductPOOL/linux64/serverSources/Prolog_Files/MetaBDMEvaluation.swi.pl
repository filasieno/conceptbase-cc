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
*
* File:         MetaBDMEvaluation.pro
* Version:      2.4
* Last Change: 12 Feb 1996, Rene Soiron (RWTH)
* Date released : 96/02/12  (YY/MM/DD)
*
* SCCS-Source-Pool : /home/CBase/CB_NewStruct/ProductPOOL/serverSources/Prolog_Files/SCCS/s.MetaBDMEvaluation.pro
* Date retrieved : 96/02/12 (YY/MM/DD)

* Das Modul MetaBDMEvaluation dient der Handhabung der Prozedurtrigger fuer
* Metaformeln.
*
* Diese Prozedurtrigger sind Trigger der Form applyPredicateIfInsert bzw.
* applyPredicateIfDelete.
*
* Wurde aus einer Metaformel eine vereinfachte Formel erzeugt, so wird
* die partielle Auswertung protokolliert.
* Beispiel
* Metaformel necessary:
* Class with
*  constraint
*         necConstraint:
*         $ forall p,x,m/VAR c,d/VAR In(p,Class!necessary) and P(p,c,m,d)
*		and In(x,c) ==> exists y/VAR  In(y,d) and A(x,m,y) $
* end
*
* Klassenvariablen: c und d
*
* Vereinfachte Formeln werden erzeugt, indem die Extension von (In(p,Class!necessary) and P(p,c,m,d))
* berechnet wird. Fuer jede Loesung wird eine Formel erzeugt, in der c,m und d durch ihre Instantiierungen
* ersetzt werden.
*
* Beispiel: Extension von In(p,Class!necessary): In(Patient!suffers,Class!necessary)
*
* erzeugte Formel:
* $forall x/Patient   (exists y/Illness   A(x,suffers,y))$
*
* Aendert sich nun die Extension von In(p,Class!necessary), so muessen entsprechend
* neue Formeln generiert bzw. generierte Formeln geloescht werden. Dazu dient dieses Modul
*
*/
:- module('MetaBDMEvaluation',[
'TestMetaFormulaTrigger'/1
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').


:- use_module('BDMKBMS.swi.pl').


:- use_module('MetaTriggerGen.swi.pl').







:- use_module('GeneralUtilities.swi.pl').
:- use_module('MetaUtilities.swi.pl').






:- use_module('Literals.swi.pl').



:- use_module('SearchSpace.swi.pl').





:- use_module('ErrorMessages.swi.pl').
:- use_module('TellAndAsk.swi.pl').
:- use_module('validProposition.swi.pl').




:- style_check(-singleton).




'TestMetaFormulaTrigger'('Insert') :-
	'CurrentUpdateMode'('UPDATE'),
	handleRuleTriggerInsertCase,
	'WriteTrace'(veryhigh,'MetaBDMEvaluation',['TestMetaFormulaConstraintTrigger']),
	'TestMetaFormulaConstraintTrigger'(_insertTriggerConstraints,_oldInsertTriggerCons,_newExtensionsCons),
	'WriteTrace'(veryhigh,'MetaBDMEvaluation',['TestMetaFormulaDeleteTrigger']),
	'TestMetaFormulaTrigger_Delete'(_deleteTrigger),
	((_deleteTrigger == []);(report_error('INSERT_AND_DELETE_REQUEST', 'MetaBDMEvaluation', ['Insert','Delete']))),!,
	'WriteTrace'(veryhigh,'MetaBDMEvaluation',['fire insert-trigger',nl]),
	fireInsertTrigger(_insertTriggerConstraints,_oldInsertTriggerCons,_newExtensionsCons),!.


'TestMetaFormulaTrigger'('Delete') :-
	'CurrentUpdateMode'('UPDATE'),
	get_KBsearchSpace(_oldP1,_oldP2),
	set_KBsearchSpace(newOB,'Now'),
	handleDeleteTriggerDeleteCase,
	'WriteTrace'(veryhigh,'MetaBDMEvaluation',['TestMetaFormulaDeleteTrigger']),
	'TestMetaFormulaRuleTrigger'(_insertTriggerRules,_,_),
	((_insertTriggerRules == []);(report_error('INSERT_AND_DELETE_REQUEST', 'MetaBDMEvaluation', ['Delete','Insert']))),!,
	'WriteTrace'(veryhigh,'MetaBDMEvaluation',['TestMetaFormulaDeleteTrigger']),
	'TestMetaFormulaConstraintTrigger'(_insertTriggerConstraints,_,_),
	((_insertTriggerConstraints == []);(report_error('INSERT_AND_DELETE_REQUEST', 'MetaBDMEvaluation', ['Delete','Insert']))) ,!,
	set_KBsearchSpace(_oldP1,_oldP2),
	'WriteTrace'(veryhigh,'MetaBDMEvaluation',['update insert-Trigger']),
	cleanUpInsertTrigger.


'TestMetaFormulaTrigger'(_) :-
	'CurrentUpdateMode'('QUERY'),
	!.

'TestMetaFormulaTrigger'('Insert') :-
	_errorMode = 'Delete',!,
	report_error('INSERT_AND_DELETE_REQUEST', 'MetaBDMEvaluation', ['Insert',_errorMode]),
	fail.

'TestMetaFormulaTrigger'('Delete') :-
	_errorMode = 'Insert',!,
	report_error('INSERT_AND_DELETE_REQUEST', 'MetaBDMEvaluation', ['Delete',_errorMode]),
	fail.


/**
Bei Einfuegungen: Zunaechst Regeln behandeln

Ablauf:
1. Einfuegung (EDB oder IDB veraendert)?
2. Metaformel-Einfuege-Trigger aktiviert ?
3. Wenn ja, neue Regeln eintragen und nach 1.

**/
handleRuleTriggerInsertCase :-
	'WriteTrace'(veryhigh,'MetaBDMEvaluation',['TestMetaFormulaRuleTrigger']),!,
	'TestMetaFormulaRuleTrigger'(_insertTriggerRules,_oldInsertTriggerRules,_newExtensionsRules),
	fireInsertTrigger(_insertTriggerRules,_oldInsertTriggerRules,_newExtensionsRules),
	handleRuleTriggerInsertCase(_insertTriggerRules).

handleRuleTriggerInsertCase([]) :-
	'WriteTrace'(veryhigh,'MetaBDMEvaluation',['TestMetaFormulaRuleTrigger --> Fixpoint reached']),!.
handleRuleTriggerInsertCase(_triggerFired) :-
	/*_triggerFired \== []*/
	'WriteTrace'(veryhigh,'MetaBDMEvaluation',['TestMetaFormulaRuleTrigger']),
	'TestMetaFormulaRuleTrigger'(_insertTriggerRules,_oldInsertTriggerRules,_newExtensionsRules),
	fireInsertTrigger(_insertTriggerRules,_oldInsertTriggerRules,_newExtensionsRules),
	handleRuleTriggerInsertCase(_insertTriggerRules).




handleDeleteTriggerDeleteCase :-
	'WriteTrace'(veryhigh,'MetaBDMEvaluation',['TestMetaFormulaTriggerDelete1']),
	'TestMetaFormulaTrigger_Delete'(_deleteTrigger),
	fireDeleteTrigger(_deleteTrigger),
	changeInsertTriggerExtension(_deleteTrigger),
	handleDeleteTriggerDeleteCase(_deleteTrigger).

handleDeleteTriggerDeleteCase([]) :- !.
handleDeleteTriggerDeleteCase(_triggerFired) :-
	/*_triggerFired \== 0*/
	'WriteTrace'(veryhigh,'MetaBDMEvaluation',['TestMetaFormulaDeleteTrigger2']),
	'TestMetaFormulaTrigger_Delete'(_deleteTrigger),
	fireDeleteTrigger(_deleteTrigger),
	changeInsertTriggerExtension(_deleteTrigger),
	handleDeleteTriggerDeleteCase(_deleteTrigger).




handleDeleteCase([]) :- !. /*No trigger were fired*/
handleDeleteCase(_) :-
	'TestMetaFormulaTrigger'('Delete').

handleInsertCase([],[]) :- !. /*No trigger were fired*/
handleInsertCase(_,_) :-
	'TestMetaFormulaTrigger'('Insert').


'TestMetaFormulaRuleTrigger'(_insertTriggerToFire,_oldInsertTrigger ,_newExtensions) :-
	findall('applyPredicateIfInsert@BDMCompile'(_ePred,_rfID,_previousEPreds, _Procedure),
                 (
		 retrieve_BDMFormula( 'applyPredicateIfInsert@BDMCompile'(_ePred,_rfID,_previousEPreds, _Procedure)),
		 isVisible(_rfID)
                 ),
		_insertTrigger),!,
	(
	(_insertTrigger == [],  _insertTriggerToFire = [] )
	;
	(splitInsertTriggerList(_insertTrigger,_insertTriggerRules,_),!,
	/** id_65 = QueryClass **/
	findInsertTriggerToFire(_insertTriggerRules,_insertTriggerToFire,_oldInsertTrigger,_newExtensions,id_65))),!.


'TestMetaFormulaConstraintTrigger'(_insertTriggerToFire,_oldInsertTrigger,_newExtensions) :-
	findall('applyPredicateIfInsert@BDMCompile'(_ePred,_rfID,_previousEPreds, _Procedure),
                 (
		 retrieve_BDMFormula( 'applyPredicateIfInsert@BDMCompile'(_ePred,_rfID,_previousEPreds, _Procedure)),
		 isVisible(_rfID)
                 ),
		_insertTrigger),!,
	(
	   (  _insertTrigger == [] ,  _insertTriggerToFire = [] )
	;
	(splitInsertTriggerList(_insertTrigger,_,_insertTriggerConstraints),!,
	/** id_65 = QueryClass **/
	findInsertTriggerToFire(_insertTriggerConstraints,_insertTriggerToFire,_oldInsertTrigger,_newExtensions,id_65))),!.


'TestMetaFormulaTrigger_Delete'(_deleteTriggerToFire) :-
	findall( 'applyPredicateIfDelete@BDMCompile'(_lit,_rfID, _Procedure),
		(
                 retrieve_BDMFormula( 'applyPredicateIfDelete@BDMCompile'(_lit,_rfID, _Procedure)),
		 isVisible(_rfID)
                ),
		_deleteTrigger),!,
	findDeleteTriggerToFire(_deleteTrigger,_deleteTriggerToFire),!.


findDeleteTriggerToFire([],[]).
findDeleteTriggerToFire(['applyPredicateIfDelete@BDMCompile'(_lit,_rfID,_Procedure)|_deleteTrigger],_deleteTriggerToFire) :-
	prove_upd_literal(_lit),!,/*nl,*/
	findDeleteTriggerToFire(_deleteTrigger,_deleteTriggerToFire).

findDeleteTriggerToFire([_t|_deleteTrigger],[_t|_deleteTriggerToFire]) :-
	_t =.. [_,_lit,_,_],
        visibleLit(_lit),    /** only triggers on literals whose object ids are visble need to be tested! **/
	!,
	findDeleteTriggerToFire(_deleteTrigger,_deleteTriggerToFire).

findDeleteTriggerToFire([_t|_deleteTrigger],_deleteTriggerToFire) :-
   findDeleteTriggerToFire(_deleteTrigger,_deleteTriggerToFire).


/** a literal is 'visible' in the current module context if the constant arguments that represent object ids **/
/** are visible in the current module context                                                                **/
visibleLit(_lit) :-
  _lit =.. [_functor|_args],
  checkVisibleArgs(_args).

checkVisibleArgs([]) :- !.

checkVisibleArgs([_x|_rest]) :-
  is_id(_x),
  !,
  isVisible(_x),
  checkVisibleArgs(_rest).

checkVisibleArgs([_|_rest]) :-
  checkVisibleArgs(_rest).



fireDeleteTrigger([]).
fireDeleteTrigger([_deleteTrigger|_deleteTriggerToFire]) :-
	testAlternativeDeleteTrigger(_deleteTrigger,_newDeleteTrigger),
	getTriggerProcedure(_newDeleteTrigger,_p),
	!,call(_p),!,
	deleteDeleteTriggerForFormulaWithID(_deleteTrigger),
	fireDeleteTrigger(_deleteTriggerToFire).

findInsertTriggerToFire([],[],[],[],_).
findInsertTriggerToFire([_t|_insertTriggerRules],_insertTriggerToFire,_oldInsertTrigger,_newExtensions,_qid) :-
	getEPred(_t,'EPred'(_literal,_extList)),
	_literal =.. ['In',_x,_c],
	is_id(_c),
	prove_upd_literal('In'(_c,_qid)),!,
	findInsertTriggerToFire(_insertTriggerRules,_insertTriggerToFire,_oldInsertTrigger,_newExtensions,_qid).


findInsertTriggerToFire([_t|_insertTriggerRules],[_newT|_insertTriggerToFire],[_t|_oldInsertTrigger],[_literalsAdded|_newExtensions],_qid) :-
	getEPred(_t,'EPred'(_literal,_extList)),
	save_setof(_literal,(prove_upd_literal(_literal),ground(_literal)),_newExtList),  /** use cache; ticket #246 **/
	listDifference(_newExtList,_extList,_literalsAdded),
	not_empty(_literalsAdded),!,
	setEPred(_t,_newT,'EPred'(_literal,_newExtList)),
	findInsertTriggerToFire(_insertTriggerRules,_insertTriggerToFire,_oldInsertTrigger,_newExtensions,_qid).

findInsertTriggerToFire([_t|_insertTriggerRules],_insertTriggerToFire,_oldInsertTrigger,_newExtensions,_qid) :-
	findInsertTriggerToFire(_insertTriggerRules,_insertTriggerToFire,_oldInsertTrigger,_newExtensions,_qid).


fireInsertTrigger(_insertTrigger,_oldInsertTrigger,_newExtensions) :-
	filterInsertTrigger(_insertTrigger,_oldInsertTrigger,_newExtensions,_listOfProcedures),
	'CallProcedures'(_listOfProcedures),!.

  



changeInsertTriggerExtension([]) :- !.
changeInsertTriggerExtension(['applyPredicateIfDelete@BDMCompile'(_lit,_,_p)|_dTriggerList]) :-
	findall('applyPredicateIfInsert@BDMCompile'('EPred'(_literal,_extList),_rfID,_previousEPreds, _Procedure),
	(retrieve_BDMFormula('applyPredicateIfInsert@BDMCompile'('EPred'(_literal,_extList),_rfID,_previousEPreds, _Procedure)),memberchk(_lit,_extList)),
	_insertTriggerToChange),
	removeLitFromExtension(_lit,_insertTriggerToChange),
	changeInsertTriggerExtension(_dTriggerList).

removeLitFromExtension(_,[]).
removeLitFromExtension(_lit,[_t|_insertTriggerToChange]) :-
	getEPred(_t,'EPred'(_literal,_extList)),
	listDifference(_extList,[_lit],_newExtList),
	setEPred(_t,_newT,'EPred'(_literal,_newExtList)),
	change_BDMFormula(_t,_newT),
	removeLitFromExtension(_lit,_insertTriggerToChange).


filterInsertTrigger([],[],[],[]).
filterInsertTrigger( ['applyPredicateIfInsert@BDMCompile'(_lit,_rfID,_previousEPreds,_Procedure)| _trigger],[_oldT|_oldTrigger],[_newExt|_newExts],_ProcedureList) :-
	prove_upd_literals(_previousEPreds),!,
	change_BDMFormula(_oldT,'applyPredicateIfInsert@BDMCompile'(_lit,_rfID,_previousEPreds,_Procedure)),
	replaceVariables('applyPredicateIfInsert@BDMCompile'(_lit,_rfID,_previousEPreds,_Procedure),
		_newExt,_ProcedureList1),
	filterInsertTrigger(_trigger,_oldTrigger,_newExts,_ProcedureList2),
	append(_ProcedureList1,_ProcedureList2,_ProcedureList).
filterInsertTrigger( [_t|_trigger],[_oldT|_oldTrigger],[_newExt|_newExts],_Procedures) :-
	filterInsertTrigger(_trigger,_oldTrigger,_newExts,_Procedures).


replaceVariables(_,[],[]).
replaceVariables(_t,[_e|_exts],[_p|_procedures]) :-
	copy_term(_t,'applyPredicateIfInsert@BDMCompile'('EPred'(_lit,_),_,_previousEPreds,_p)),
	_lit = _e,
	replaceVariables(_t,_exts,_procedures).

cleanUpInsertTrigger :-
	findall('applyPredicateIfInsert@BDMCompile'(_lit,_rfID,_previousEPreds,_Procedure),
		(retrieve_BDMFormula( 'applyPredicateIfInsert@BDMCompile'(_lit,_rfID,_previousEPreds, _Procedure))),
		_ListOfTrigger),
	get_KBsearchSpace(_oldP1,_oldP2),
	set_KBsearchSpace(newOB,'Now'),
	testPreviousEPreds(_ListOfTrigger,_triggerToDelete),
	set_KBsearchSpace(_oldP1,_oldP2),
	delete_BDMFormulas(_triggerToDelete).

testPreviousEPreds(_ListOfTrigger,_triggerToDelete) :-
	testPreviousEPreds(_ListOfTrigger,[],_triggerToDelete).

testPreviousEPreds([],_toDelete,_toDelete).
testPreviousEPreds([_t|_listOfTrigger],_toDelete,_allToDelete) :-
	getPreviousEPreds(_t,_previousEPreds),
	prove_upd_literals(_previousEPreds),!,
	testPreviousEPreds(_listOfTrigger,_toDelete,_allToDelete).
testPreviousEPreds([_t|_listOfTrigger],_toDelete,_allToDelete) :-
	getPreviousEPreds(_t,_previousEPreds),
	testPreviousEPreds(_listOfTrigger,[_t|_toDelete],_allToDelete).



'CallProcedures'([]).
'CallProcedures'([_p|_procs]) :-
	!, /** no backtracking when calling procedure trigger **/
	call(_p),!,
	'CallProcedures'(_procs).




