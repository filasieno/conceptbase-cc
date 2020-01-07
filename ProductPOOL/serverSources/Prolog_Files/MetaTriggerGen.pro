{*
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
*}
{************************************************************************
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
***************************************************************************
*
* Das Modul MetaTriggerGen dient der Erzeugung und Manipulation von Trigggern
* der Form
* applyPredicateIfInsert und
* applyPredicateIfDelete
*
* Ziel:
* Auf diese Trigger soll nur noch ueber dieses Modul zugegriffen
* werden und nicht ueber Praedikate aus BDMKBMS
* (noch nicht vollstaendig umgesetzt in MetaBDMEvaluation)
*
}

#MODULE(MetaTriggerGen)
#EXPORT(buildDeleteTriggerList/4)
#EXPORT(buildInsertTriggerList/3)
#EXPORT(deleteDeleteTriggerForFormulaWithID/1)
#EXPORT(encloseConstraintTrigger/3)
#EXPORT(encloseRuleTrigger/5)
#EXPORT(getEPred/2)
#EXPORT(getGenFormulaId/2)
#EXPORT(getPreviousEPreds/2)
#EXPORT(getTriggerProcedure/2)
#EXPORT(saveDataForInsertTrigger/7)
#EXPORT(setEPred/3)
#EXPORT(splitInsertTriggerList/3)
#EXPORT(store_procedureTrigger/5)
#EXPORT(testAlternativeDeleteTrigger/2)
#ENDMODDECL()


#IMPORT(ConcernedClass/2,BDMLiteralDeps)
#IMPORT(tell_BDMProcTrigger/1,BDMIntegrityChecker)
#IMPORT(delete_BDMFormulas/1,BDMKBMS)
#IMPORT(retrieve_BDMFormula/1,BDMKBMS)
#IMPORT(change_BDMFormula/2,BDMKBMS)
#IMPORT(substituteLits/4,MetaLiterals)
#IMPORT(substituteRF/4,MetaRFormulas)
#IMPORT(append/3,GeneralUtilities)
#IMPORT(listDifference/3,MetaUtilities)
#IMPORT(removeMultiEntries/2,MetaUtilities)
#IMPORT(retrieve_proposition/1,PropositionProcessor)
#IMPORT(isTokenAsClass/1,RangeformSimplifier)
#IMPORT(createModTerm/4,PrologCompatibility)

#IF(SWI)
:- style_check(-singleton).
#ENDIF(SWI)



{deleteAllDeleteTriggerForFormulas([]).
deleteAllDeleteTriggerForFormulas([_dt|_dts]) :-
	deleteAllDeleteTriggerForFormula(_dt),
	deleteAllDeleteTriggerForFormulas(_dts).
}
deleteDeleteTriggerForFormulaWithID(_deleteTrigger) :-
	getGenFormulaId(_deleteTrigger,_genFormulaIDWithNumber),
	_genFormulaIDWithNumber =..[id,_genFormulaID,_number],
	_number \== 0,
	findall( 'applyPredicateIfDelete@BDMCompile'(_lit,_mfID, _procedure),
		(
		retrieve_BDMFormula('applyPredicateIfDelete@BDMCompile'(_lit,_mfID,_procedure)),
		createModTerm(deleteGeneratedFormula,AssertionTransformer,[_genFormulaID,_number,_mfID,_mode],_procedure)
                ),
		_deleteTriggerList),
	delete_BDMFormulas(_deleteTriggerList).
	deleteDeleteTriggerForFormulaWithID(_deleteTrigger) :-
	getGenFormulaId(_deleteTrigger,_genFormulaIDWithNumber),
	_genFormulaIDWithNumber =..[id,_genFormulaID,_number],
	_number == 0,
	findall( 'applyPredicateIfDelete@BDMCompile'(_lit,_mfID, _procedure),
		(
		retrieve_BDMFormula('applyPredicateIfDelete@BDMCompile'(_lit,_mfID,_procedure)),
		createModTerm(deleteGeneratedFormula,AssertionTransformer,[_genFormulaID,_,_mfID,_mode],_procedure)
                ),
		_deleteTriggerList),
	delete_BDMFormulas(_deleteTriggerList).



testAlternativeDeleteTrigger(_dt,_dt) :-
	getGenFormulaId(_dt,id(_,_number)),
	_number == 0,!.
testAlternativeDeleteTrigger(_dt,_dt) :-
{	getGenFormulaId(_dt,id(_,_number)),
	_number > 0,}
	testFormulaCounter(_dt,_nr),
	_nr > 0,!.
testAlternativeDeleteTrigger(_dt,_newDt) :-
{	getGenFormulaId(_dt,id(_,_number)),
	_number > 0,}
	_dt =.. ['applyPredicateIfDelete@BDMCompile',_lit,_mfID,_procedure],
    createModTerm(deleteGeneratedFormula,AssertionTransformer,[_genFormulaID,_number,_mfID,_mode],_procedure),
    createModTerm(deleteGeneratedFormula,AssertionTransformer,[_genFormulaID,0,_mfID,_mode],_newProcedure),
	_newDt =.. ['applyPredicateIfDelete@BDMCompile',_lit,_mfID,_newProcedure].

{* existiert eine weiterere delete-trigger-Gruppe, die auf die Formel zeigt ?*}
testFormulaCounter(_dt,_number) :-
	getGenFormulaId(_dt,id(_genFormulaID,_number)),
	retrieve_BDMFormula('applyPredicateIfDelete@BDMCompile'(_,_,_procedure)),
	_procedure =.. [_,_genFormulaID,_number2,_,_],
	_number \== _number2,!.
testFormulaCounter(_dt,0).


encloseConstraintTrigger(_,[],[]).
encloseConstraintTrigger(_functor,[_t|_triggerList],[_nt|_nTriggerList]) :-
	_t =.. [Trigger,Insert,_arg12,_arg13,_arg4,_arg15,_],
	_nArg4 =.. [_functor,_arg4],
	_nt =.. [Trigger,Insert,_arg12,_arg13,_nArg4,_arg15],
	encloseConstraintTrigger(_functor,_triggerList,_nTriggerList).

encloseRuleTrigger(_,[],_,_,[]).
encloseRuleTrigger(_functor,[_t|_triggerList],_vars,_lit,[_nt|_nTriggerList]) :-
	_t =.. [Trigger,Insert,_arg12,_arg13,_arg4,_arg15,subst(_v,_c)],
	listDifference(_vars,_v,_newVars),
	substituteLits([_lit],_v,_c,[_newLit]),
	_nArg4 =.. [_functor,_newVars,_arg4,_newLit],
	_nt =.. [Trigger,Insert,_arg12,_arg13,_nArg4,_arg15],
	encloseRuleTrigger(_functor,_triggerList,_vars,_lit,_nTriggerList).


buildInsertTriggerList([],_,[]).
buildInsertTriggerList([_inTr|_inTrs],_oldEPreds,[_outTr|_outTrs]) :-
	convertInsertTrigger(_inTr,_oldEPreds,_outTr),!,
	buildInsertTriggerList(_inTrs,_oldEPreds,_outTrs).
buildInsertTriggerList([_trig|_inTrs],_oldEPreds,_outTrs) :-
	buildInsertTriggerList(_inTrs,_oldEPreds,_outTrs).


buildDeleteTriggerList([],_,_,[]) :- !.
buildDeleteTriggerList(_formulas,_ePredsTillNow,_newEPreds,_dTriggerList) :-
	computeDuplicateTagList(_formulas,_duplTaggedFormulas),
	filterOldDeleteTrigger(_duplTaggedFormulas,_ePredsTillNow,_dTriggerList1),
	filterNewDeleteTrigger(_duplTaggedFormulas,_newEPreds,_dTriggerList2),
	mergeDeleteTrigger(_dTriggerList1,_dTriggerList2,_dTriggerList).

{* 9-Mar-2005/MJf: solve Ticket #53 *}
getGenFormulaId(_deleteTrigger,id(_genFormulaID,_nr)) :-
	getTriggerProcedure(_deleteTrigger,_proc),
#IF(BIM)
	_proc =.. [_,_genFormulaID,_nr,_,_].
#ELSE(BIM)
        _proc =.. [_colon,_modulequalifier,_proc1],    {* term proc has the form mod:fun(...) where ':' is regarded as top functor *}
        _proc1 =.. [_,_genFormulaID,_nr,_,_].
#ENDIF(BIM)

getTriggerProcedure(_deleteTrigger,_proc) :-
	_deleteTrigger =.. ['applyPredicateIfDelete@BDMCompile',_,_,_proc].

getPreviousEPreds(_insTrigger,_ePredsTillNow) :-
	_insTrigger =.. ['applyPredicateIfInsert@BDMCompile',_,_,_ePredsTillNow,_].




saveDataForInsertTrigger(_ePredsTillNow,_ePred,_extList,_constants,_consequens,_oldSubst,_trigInsert):-
	_trigInsert = Trigger(Insert,EPred(_ePred,_constants,_extList),MetaSimplify,_consequens,_ePredsTillNow,_oldSubst).


store_procedureTrigger(_rfID,_mode,_genInsertTrigger,_genDeleteTrigger,_genFormulaIDs) :-
	buildProcedureTrigger(_rfID,_mode,_genInsertTrigger,_genDeleteTrigger,_genFormulaIDs,_procTrigger),
	tell_BDMProcTrigger(_procTrigger).



{*******Local Part******}

buildDeleteTrigger(duplicateMarked(_f,_nr),[],[]).
buildDeleteTrigger(duplicateMarked(_f,_nr),[_lit|_ePreds],[_dTrigger|_dTriggerList]) :-
	_dTrigger = 'applyPredicateIfDelete@BDMCompile'(_lit,Remove(id(_f,_nr))),
	buildDeleteTrigger(duplicateMarked(_f,_nr),_ePreds,_dTriggerList).



buildProcedureTrigger(_rfID,_mode,_genInsertTrigger,_genDeleteTrigger,_genFormulaIDs,_procTrigger) :-
	buildProcedureInsertTrigger(_rfID,_mode,_genInsertTrigger,_insTrigs),
	buildProcedureDeleteTriggerForAllFormulas(_rfID,_mode,_genFormulaIDs,_genDeleteTrigger,_delTrigs),
	append(_insTrigs,_delTrigs,_procTrigger).

buildProcedureInsertTrigger(_,_,[],[]).
buildProcedureInsertTrigger(_rfID,_mode,['applyPredicateIfInsert@BDMCompile'(_literal,_procedure1)|_trigs],_pTrigs) :-
	_literal = EPred(_ePred,_extList),
	_ePred =..[P,_,_,_,_],!,
	buildProcedureInsertTrigger(_rfID,_mode,_trigs,_pTrigs).
buildProcedureInsertTrigger(_rfID,_mode,['applyPredicateIfInsert@BDMCompile'(_literal,_procedure1)|_trigs],_pTrigs) :-
	_literal = EPred(_ePred,_extList),
	isTokenAsClass([_ePred]),!,
	buildProcedureInsertTrigger(_rfID,_mode,_trigs,_pTrigs).

buildProcedureInsertTrigger(_rfID,_mode,['applyPredicateIfInsert@BDMCompile'(_literal,_procedure1)|_trigs],[_pTrig|_pTrigs]) :-

	_literal = EPred(_ePred,_extList),
	_procedure1 =.. [_func2,_rangeform,_ePredsTillNow],
	createModTerm(handleMetaFormula,AssertionTransformer,[_rangeform,[_ePred|_ePredsTillNow],_mode,_rfID],_procedure),
	_pTrig =.. ['applyPredicateIfInsert@BDMCompile',_literal,_rfID,_ePredsTillNow,_procedure],
	buildProcedureInsertTrigger(_rfID,_mode,_trigs,_pTrigs).


buildProcedureDeleteTriggerForAllFormulas(_,_,[],[],[]).
buildProcedureDeleteTriggerForAllFormulas(_rfID,_mode,[_gfID|_genFormulaIDs],[_gfTrigList|_genFormulasTrigs],_delTrigs) :-
	buildProcedureDeleteTrigger(_rfID,_mode,_gfID,_gfTrigList,_delTrigs1),
	buildProcedureDeleteTriggerForAllFormulas(_rfID,_mode,_genFormulaIDs,_genFormulasTrigs,_delTrigs2),
	append(_delTrigs1,_delTrigs2,_delTrigs).


buildProcedureDeleteTrigger(_,_,_,[],[]).
buildProcedureDeleteTrigger(_rfID,_mode,_genFormulaID,['applyPredicateIfDelete@BDMCompile'(_literal,_procedure1)|_trigs],[_pTrig|_pTrigs]) :-
	_procedure1 =.. [_func2,_rangeformWithDupCtr],
	_rangeformWithDupCtr =.. [id,_rangeform,_anzDups],
	createModTerm(deleteGeneratedFormula,AssertionTransformer,[_genFormulaID,_anzDups,_rfID,_mode],_procedure),
	_pTrig =.. ['applyPredicateIfDelete@BDMCompile',_literal,_rfID,_procedure],
	buildProcedureDeleteTrigger(_rfID,_mode,_genFormulaID,_trigs,_pTrigs).



convertInsertTrigger(Trigger(Insert,EPred(In(_x,_ClassID),[_ClassID],_extensions),MetaSimplify,_consequens,_ePreds),_oldEPreds,_insertTrigger) :-
	substituteRF(_consequens,[_x],[_newVar],_newConsequens),
	append(_oldEPreds,_ePreds,_allEPreds),
	_insertTrigger = 'applyPredicateIfInsert@BDMCompile'(EPred(In(_newVar,_ClassID),_extensions),MetaSimplify(_newConsequens,_allEPreds)).


convertInsertTrigger(Trigger(Insert,EPred(In(_x,_ClassID),[_x],_extensions),MetaSimplify,_consequens,_ePreds),_oldEPreds,_insertTrigger) :-
	substituteRF(_consequens,[_ClassID],[_newVar],_newConsequens),
	append(_oldEPreds,_ePreds,_allEPreds),
	_insertTrigger = 'applyPredicateIfInsert@BDMCompile'(EPred(In(_x,_newVar),_extensions),MetaSimplify(_newConsequens,_allEPreds)).

convertInsertTrigger(Trigger(Insert,EPred(A(_x,_m,_y),[_x,_m],_extensions),MetaSimplify,_consequens,_ePreds),_oldEPreds,_insertTrigger) :-
	substituteRF(_consequens,[_y],[_newVar],_newConsequens),
	append(_oldEPreds,_ePreds,_allEPreds),
	_insertTrigger = 'applyPredicateIfInsert@BDMCompile'(EPred(A(_x,_m,_newVar),_extensions),MetaSimplify(_newConsequens,_allEPreds)).

{* ticket #404 *}
convertInsertTrigger(Trigger(Insert,EPred(A(_x,_m,_y),[_m,_y],_extensions),MetaSimplify,_consequens,_ePreds),_oldEPreds,_insertTrigger) :-
	substituteRF(_consequens,[_x],[_newVar],_newConsequens),
	append(_oldEPreds,_ePreds,_allEPreds),
	_insertTrigger = 'applyPredicateIfInsert@BDMCompile'(EPred(A(_newVar,_m,_y),_extensions),MetaSimplify(_newConsequens,_allEPreds)).

convertInsertTrigger(Trigger(Insert,EPred(A(_x,_m,_y),[_m],_extensions),MetaSimplify,_consequens,_ePreds),_oldEPreds,_insertTrigger) :-
	substituteRF(_consequens,[_x,_y],[_newVar1,_newVar2],_newConsequens),
	append(_oldEPreds,_ePreds,_allEPreds),
	_insertTrigger = 'applyPredicateIfInsert@BDMCompile'(EPred(A(_newVar1,_m,_newVar2),_extensions),MetaSimplify(_newConsequens,_allEPreds)).

convertInsertTrigger(Trigger(Insert,EPred(Isa(_c,_d),[_d],_extensions),MetaSimplify,_consequens,_ePreds),_oldEPreds,_insertTrigger) :-
	substituteRF(_consequens,[_c],[_newVar],_newConsequens),
	append(_oldEPreds,_ePreds,_allEPreds),
	_insertTrigger = 'applyPredicateIfInsert@BDMCompile'(EPred(Isa(_newVar,_d),_extensions),MetaSimplify(_newConsequens,_allEPreds)).

convertInsertTrigger(Trigger(Insert,EPred(Isa(_c,_d),[_c],_extensions),MetaSimplify,_consequens,_ePreds),_oldEPreds,_insertTrigger) :-
	substituteRF(_consequens,[_d],[_newVar],_newConsequens),
	append(_oldEPreds,_ePreds,_allEPreds),
	_insertTrigger = 'applyPredicateIfInsert@BDMCompile'(EPred(Isa(_c,_newVar),_extensions),MetaSimplify(_newConsequens,_allEPreds)).

convertInsertTrigger(Trigger(Insert,EPred(Isa(_c,_d),[],_extensions),MetaSimplify,_consequens,_ePreds),_oldEPreds,_insertTrigger) :-
	substituteRF(_consequens,[_c,_d],[_newVar1,_newVar2],_newConsequens),
	append(_oldEPreds,_ePreds,_allEPreds),
	_insertTrigger = 'applyPredicateIfInsert@BDMCompile'(EPred(Isa(_newVar1,_newVar2),_extensions),MetaSimplify(_newConsequens,_allEPreds)).

{* ticket #162 *}
convertInsertTrigger(Trigger(Insert,EPred(A_label(_x,_m,_y,_n),[_m],_extensions),MetaSimplify,_consequens,_ePreds),_oldEPreds,_insertTrigger) :-
        substituteRF(_consequens,[_x,_y,_n],[_newVar1,_newVar2,_newVar3],_newConsequens),
        append(_oldEPreds,_ePreds,_allEPreds),
        _insertTrigger = 'applyPredicateIfInsert@BDMCompile'(EPred(A_label(_newVar1,_m,_newVar2,_newVar3),_extensions),
                                         MetaSimplify(_newConsequens,_allEPreds)).

{* ticket #330: like A_label *}
convertInsertTrigger(Trigger(Insert,EPred(Ae_label(_x,_m,_y,_n),[_m],_extensions),MetaSimplify,_consequens,_ePreds),_oldEPreds,_insertTrigger) :-
        substituteRF(_consequens,[_x,_y,_n],[_newVar1,_newVar2,_newVar3],_newConsequens),
        append(_oldEPreds,_ePreds,_allEPreds),
        _insertTrigger = 'applyPredicateIfInsert@BDMCompile'(EPred(Ae_label(_newVar1,_m,_newVar2,_newVar3),_extensions),
                                         MetaSimplify(_newConsequens,_allEPreds)).


{* ticket #207: A_e is a valid Epred just like A *}
convertInsertTrigger(Trigger(Insert,EPred(A_e(_x,_m,_y),[_m],_extensions),MetaSimplify,_consequens,_ePreds),_oldEPreds,_insertTrigger) :-
        substituteRF(_consequens,[_x,_y],[_newVar1,_newVar2],_newConsequens),
        append(_oldEPreds,_ePreds,_allEPreds),
        _insertTrigger = 'applyPredicateIfInsert@BDMCompile'(EPred(A_e(_newVar1,_m,_newVar2),_extensions),MetaSimplify(_newConsequens,_allEPreds)).



filterOldDeleteTrigger([],_,[]).
filterOldDeleteTrigger([_f|_formulas],_ePredList,[_fDTriggerList|_formulasDTriggerList]) :-
	buildDeleteTrigger(_f,_ePredList,_fDTriggerList),
	filterOldDeleteTrigger(_formulas,_ePredList,_formulasDTriggerList).


filterNewDeleteTrigger([],[],[]).
filterNewDeleteTrigger([_f|_formulas],[_fEPredList|_formulasEPredList],[_fDTriggerList|_formulasDTriggerList]) :-
	buildDeleteTrigger(_f,_fEPredList,_fDTriggerList),
	filterNewDeleteTrigger(_formulas,_formulasEPredList,_formulasDTriggerList).


getEPred('applyPredicateIfInsert@BDMCompile'(_ePred,_,_,_),_ePred).
getEPred('applyPredicateIfDelete@BDMCompile'(_ePred,_,_),_ePred).

mergeDeleteTrigger([],[],[]).
mergeDeleteTrigger([_fDOldList|_fsDOldList],[_fDNewList|_fsDNewList],[_fDList|_fsDList]) :-
	append(_fDOldList,_fDNewList,_fDList1),
	removeMultiEntries(_fDList1,_fDList),
	mergeDeleteTrigger(_fsDOldList,_fsDNewList,_fsDList).

splitInsertTriggerList([],[],[]).
splitInsertTriggerList([_t|_insertTrigger],[_t|_triggerRules],_triggerCons) :-
	_t =.. [_,_,_,_,_proc],
	_proc =.. [_,_,_,_mode,_],
	_mode == rule,!,
	splitInsertTriggerList(_insertTrigger,_triggerRules,_triggerCons).
splitInsertTriggerList([_t|_insertTrigger],_triggerRules,[_t|_triggerCons]) :-
	splitInsertTriggerList(_insertTrigger,_triggerRules,_triggerCons).


setEPred('applyPredicateIfInsert@BDMCompile'(_,_arg2,_arg3,_arg4),
	'applyPredicateIfInsert@BDMCompile'(_ePred,_arg2,_arg3,_arg4),_ePred).
setEPred('applyPredicateIfDelete@BDMCompile'(_,_arg2,_arg3),
	'applyPredicateIfDelete@BDMCompile'(_ePred,_arg2,_arg3),_ePred).



{-----------------------------------------------
initDuplicateTagList(_l1,_l2)
}

initDuplicateTagList([],[]).
initDuplicateTagList([_h|_t],[duplicateMarked(_h,0)|_newT]) :-
	initDuplicateTagList(_t,_newT).

{
computeDuplicateTagList(_l1,_l2)
}
computeDuplicateTagList(_l,_res) :-
	initDuplicateTagList(_l,_l1),
	computeDuplicateTagList_1(_l1,_res).

computeDuplicateTagList_1([],[]).

computeDuplicateTagList_1([duplicateMarked(_h,_mark)|_tail],[duplicateMarked(_h,_mark)|_newTail]) :-
	_mark > 0,!,
	computeDuplicateTagList_1(_tail,_newTail).

computeDuplicateTagList_1([duplicateMarked(_formula,0)|_tail],[duplicateMarked(_formula,_number)|_newTail]) :-
{*test if formula already exists in ObjectBase *}
	retrieve_proposition(P(_id,_id,_formula,_id)),
{*test if formula is generated*}
	findall( 'applyPredicateIfDelete@BDMCompile'(_lit,_mfID, _procedure),
		(
		retrieve_BDMFormula('applyPredicateIfDelete@BDMCompile'(_lit,_mfID,_procedure)),
		createModTerm(deleteGeneratedFormula,AssertionTransformer,[_id,_number,_mfID,_mode],_procedure)
                ),
		_deleteTriggerList),
	deleteTriggerList \== [],!,
	getMaximumNumber(_deleteTriggerList,_number),
	markDuplicates(duplicateMarked(_formula,_),1,_,_number,_tail,_tailMarked),
	computeDuplicateTagList_1(_tailMarked,_newTail).

computeDuplicateTagList_1([duplicateMarked(_formula,0)|_tail],[duplicateMarked(_formula,_number)|_newTail]) :-
{*test if formula already exists in ObjectBase *}
	retrieve_proposition(P(_id,_id,_formula,_id)),
{*test if formula is generated*}
	findall( 'applyPredicateIfDelete@BDMCompile'(_lit,_mfID, _procedure),
		(
		retrieve_BDMFormula('applyPredicateIfDelete@BDMCompile'(_lit,_mfID,_procedure)),
		createModTerm(deleteGeneratedFormula,AssertionTransformer,[_id,_number,_mfID,_mode],_procedure)
                ),
		_deleteTriggerList),
	deleteTriggerList == [],!,fail.

computeDuplicateTagList_1([duplicateMarked(_h,0)|_tail],[duplicateMarked(_h,_mark)|_newTail]) :-
	markDuplicates(duplicateMarked(_h,0),0,_mark,1,_tail,_tailMarked),
	computeDuplicateTagList_1(_tailMarked,_newTail).

markDuplicates(_,_mark,_mark,_,[],[]).
markDuplicates(duplicateMarked(_elem,_),_oldMark,_newMark,_count,
	[duplicateMarked(_elem,0)|_tail],[duplicateMarked(_elem,_newCount)|_newTail]) :-
	_newCount is _count + 1,
	markDuplicates(duplicateMarked(_elem,_),1,_newMark,_newCount,_tail,_newTail).
markDuplicates(duplicateMarked(_elem,_),_oldMark,_newMark,_count,
	[duplicateMarked(_otherElem,_otherMark)|_tail],[duplicateMarked(_otherElem,_otherMark)|_newTail]) :-
	_elem \== _otherElem,
	markDuplicates(duplicateMarked(_elem,_),_oldMark,_newMark,_count,_tail,_newTail).


getMaximumNumber(_dtList,_max) :-
	getMaxNumber(_dtList,0,_maxTest),
	((_maxTest == 0,setNumber(_dtList,1),_max = 2);(_maxTest \== 0, _max is _maxTest + 1)),!.

getMaxNumber([],_max,_max).
getMaxNumber([_dt|_dts],_max,_newMax) :-
	_dt =.. ['applyPredicateIfDelete@BDMCompile',_,_,_procedure],
	getCurrentNumber(_procedure,_number),
	((_number > _max,_max1 = _number);(_max1 = _max)),!,
	getMaxNumber(_dts,_max1,_newMax).

setNumber([],_).
setNumber([_dt|_dts],_number) :-
	_dt =.. ['applyPredicateIfDelete@BDMCompile',_lit,_mfID,_procedure],
	createModTerm(deleteGeneratedFormula,AssertionTransformer,[_genFormulaID,_oldNumber,_mfID,_mode],_procedure),
	createModTerm(deleteGeneratedFormula,AssertionTransformer,[_genFormulaID,_number,_mfID,_mode],_newProcedure),
	_newDt =.. ['applyPredicateIfDelete@BDMCompile',_lit,_mfID,_newProcedure],
	change_BDMFormula(_dt,_newDt),
	setNumber(_dts,_number).


{* retrieve the number argument from a trigger term *} {* ticket #376 *}
getCurrentNumber(_procedure,_number) :-
	createModTerm(_functor,AssertionTransformer,[_,_number,_,_],_procedure).  


