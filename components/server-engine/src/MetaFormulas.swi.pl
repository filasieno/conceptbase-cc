%
% The ConceptBase.cc Copyright
%
% Copyright 1987-2020 The ConceptBase Team. All rights reserved.
%
% Redistribution and use in source and binary forms, with or without modification, are permitted
% provided that the following conditions are met:
%
%    1. Redistributions of source code must retain the above copyright notice, this list of
%       conditions and the following disclaimer.
%    2. Redistributions in binary form must reproduce the above copyright notice, this list of
%       conditions and the following disclaimer in the documentation and/or other materials
%       provided with the distribution.
%
% THIS SOFTWARE IS PROVIDED BY THE CONCEPTBASE TEAM ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
% INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
% PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE CONCEPTBASE TEAM OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
% (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
% OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
% OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%
% The views and conclusions contained in the software and documentation are those of the authors
% and should not be interpreted as representing official policies, either expressed or implied,
% of the ConceptBase Team.
%
%
% The ConceptBase Team is represented by
%
% Manfred Jeusfeld, University of Skovde, 54128 Skovde, Sweden
% Matthias Jarke, RWTH Aachen, Informatik 5, Ahornstr. 55, 52056 Aachen, Germany
% Christoph Quix, RWTH Aachen, Informatik 5, Ahornstr. 55, 52056 Aachen, Germany
%
%
% This license is a FreeBSD-style copyright license.
% Legal home of the FreeBSD copyright license: http://www.freebsd.org/copyright/freebsd-license.html
%
% **********************************************************************
%
% File:         MetaFormulas.pro
% Version:      2.4
%
%
% Date released : 96/02/12  (YY/MM/DD)
%
% SCCS-Source-Pool : /home/CBase/CB_NewStruct/ProductPOOL/serverSources/Prolog_Files/SCCS/s.MetaFormulas.pro
% Date retrieved : 96/02/12 (YY/MM/DD)
% *************************************************************************
%
% In module MetaFormulas, predicates are collected that process metaformulas
% as a subset of all possible formulas in range form.
%
%
% Examples for exported predicates:
% partialEvaluate, given a meta formula and an evaluating predicate,
% generates a set of simplified formulas in which the evaluating
% predicate has been replaced by its extension.
%
%
%
%

:- module('MetaFormulas',[
'computeSearchSpace'/4
,'computeSearchSpaceRule'/4
,'convertIntoMFForm'/3
,'convertIntoMFFormRule'/3
,'determineSimpleFormulaClass'/4
,'filterParameterFormula'/1
,'filterSimpleFormulas'/8
,'metaFormula'/1
,'metaFormulaAnalysis'/4
,'partialEvaluate'/8
,'simpleFormula'/1
,'transformEquivalent'/4
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').
:- use_module('MetaBindingPath.swi.pl').
:- use_module('MetaLiterals.swi.pl').
:- use_module('MetaRFormulas.swi.pl').
:- use_module('GeneralUtilities.swi.pl').
:- use_module('MetaUtilities.swi.pl').
:- use_module('Literals.swi.pl').
:- use_module('RangeformSimplifier.swi.pl').
:- use_module('VarTabHandling.swi.pl').
:- use_module('PrologCompatibility.swi.pl').
:- use_module('SemanticOptimizer.swi.pl').
:- use_module('AToAdot.swi.pl').
:- style_check(-singleton).
% --------------EXPORT PART -------------------------
% --------------------------------------------
%
% computeSearchSpace(_rf,_cons,_vars,_lits):
% The partial evaluatyion process used is only correct for
% forall - quantified constraints.
% This predicate reduces the search space to those literals
% in the direct scope of a forall-quantifier
% Example:
%  computeSearchSpace(forall([p,c,m,d,x],[In(p,Nec),In(x,c),P(p,c,m,d)],
% exists([y],[In(y,d),A(x,m,y)],TRUE)),_cons,_vars,_lits).
%   _cons = [Nec]
%   _vars = [p,c,m,d,x]
%   _lits = [In(p,Nec),In(x,c),P(p,c,m,d)]
%
%
%    computeSearchSpace is only called
%    after the universal quantifiers have been
%    merged as far as possible with convertIntoMFForm.
%

computeSearchSpace(_rf,_cons,_vars,_lits) :-
	rFormulaParts(_rf,forall,_vars,_lits,_),!,
 	collectArguments(_lits,_args),
 	rFormulaAnalysis(_rf,_,_allCons,_),
	listIntersection(_args,_allCons,_cons).
computeSearchSpace(_rf,[],[],[]).

computeSearchSpaceRule(_rf,_cons,_vars,_lits) :-
	computeSearchSpaceAccRule(_rf,[],_vars1,[],_lits1),
	removeMultiEntries(_vars1,_vars),
 	removeMultiEntries(_lits1,_lits),!,
 	collectArguments(_lits,_args),
 	rFormulaAnalysis(_rf,_,_allCons,_),
	listIntersection(_args,_allCons,_cons).
computeSearchSpaceRule(_rf,[],[],[]).

convertIntoMFForm(_f,_newF,0) :-
	convertIntoMFForm1(_f,_newF,0),
	testIfPartialEvaluable(_newF),!.
convertIntoMFForm(_f,_newF,-1).

convertIntoMFFormRule(_f,_newF,0) :-
	convertIntoMFForm1Rule(_f,_newF,0),!.
convertIntoMFFormRule(_f,_newF,-1).
% 	determineSimpleFormulaClass:
% 	The "$...$" form of one produced by partial evaluation
% 	the obtained formula is stored as the value of an attribute
% 	attached to a certain class under the category "rule" or "constraint".
% 	This class is determined here from the metaformula.
%
% 		Try to find the first In literal in the scope
% 		of the outermost universal quantifier of the metaformula
% 		that contains a class variable.
% 		Example:
% 		 $ forall p,x,m,c,d/VAR
% 			In(p,Class!necessary) and In(x,c) and P(p,c,m,d) ==>
% 				exists y/VAR  In(y,d) and A(x,m,y) $
% 		Meta-variables (class variables) are c and d
% 		first In literal: In(x,c)
% 		Therefore:
% 		Attach simplified formulas to the instances of c
%
%
%
% 	The sought In literal is to appear as a partially instantiated
% 	literal in the simplified formula. This
% 	is the case when the In literal is not in the set
% 	of literals that are evaluated (i.e. in the set of
% 	the "E predicates")
%

determineSimpleFormulaClass(_f,_mLits,'Binds'(_,_,_bLits,_),_c) :-
	listDifference(_mLits,_bLits,_mLitsInst),
	determineSimpleFormulaClass(_f,_mLitsInst,_c).
determineSimpleFormulaClass(_f,_mLits,_c) :-
	rFormulaParts(_f,forall,_vars,_lits,_subFormula),
	listIntersection(_lits,_mLits,_testList),
	member('In'(_x,_c),_testList),!.
determineSimpleFormulaClass(_f,_mLits,_c) :-
	rFormulaParts(_f,forall,_vars,_lits,_subFormula),
	listIntersection(_lits,_mLits,_testList),
	nonmember('In'(_x,_c),_testList),
	determineSimpleFormulaClass(_subFormula,_mLits,_c).

filterParameterFormula(_ePredList) :-
	filterParameterFormula2(_ePredList,id_65),!.  % id_65 = QueryClass
filterParameterFormula2([_ePred|_ePredList],_qid) :-
	_ePred =.. [_f|_args],
	'TestQueryClass'(_args,_qid),!.
filterParameterFormula2([_ePred|_ePredList],_qid) :-
	filterParameterFormula2(_ePredList,_qid).

filterSimpleFormulas(_mode,_mVars,_accForm1,_accForm,_substList1,_substList,_ePredList1,_ePredList) :-
	reverse(_accForm1,_accForm2),
	reverse(_substList1,_substList2),
	reverse(_ePredList1,_ePredList2),
	%  id_65 = QueryClass

	filterSimpleFormulas2(_mode,_mVars,_accForm2,_accForm,_substList2,_substList,_ePredList2,_ePredList,id_65),!.

findFormulasClasses([],_,[]).
findFormulasClasses([subst(_vList,_cList)|_substs],'Class',['Class'|_classList]):- !,
	findFormulasClasses(_substs,'Class',_classList).
findFormulasClasses([subst(_vList,_cList)|_substs],_var,[_class|_classList]) :-
	findFormulaClass(_vList,_var,_cList,_class),
	findFormulasClasses(_substs,_var,_classList).
%
% metaFormula(_f) succeeds if _f is a metaformula
%
%

metaFormula(_f) :-
	metaFormulaAnalysis(_f,_,_mVarList,_),
 	not_empty(_mVarList).
%
% metaFormulaAnalysis(_f,_mPredicates,_mVariables,_status)
% _f is a _formula
% _mPredicates are the In-Predicates in this _formula containing
% class-variables
% _mVarsiables are those class - variables
% _status:
% the A(x,m,y) literals are tested:
% If a literal of the form In(x,c) exists for x, so that x could
% be bound to a class, then the status is 0
% If x can't be bound the status is -1
% (See Def. 7.-1. in Jeusfeld, 92).
% Examples:
% metaFormulaAnalysis(forall([p,c,m,d,x],[In(p,Nec),In(x,c),P(p,c,m,d)],exists([y],[In(y,d),A(x,m,y)],TRUE)),_mLits,_mVars,_status).
%   _mLits = [In(x,c),In(y,d)]
%   _mVars = [c,d]
%   _status = 0
%
% metaFormulaAnalysis(forall([p,c,m,d,x],[In(p,Nec),P(p,c,m,d)],exists([y],[In(y,d),A(x,m,y)],TRUE)),_mLits,_mVars,_status).
%   _mLits = [In(y,d)]
%   _mVars = [d]
%   _status = -1
%

metaFormulaAnalysis(_f,_mPredicates,_mVariables,_status) :-
	collect_InLits_ALits_and_Vars(_f,_aPreds,_iPreds,_vars),
	findMetaInPreds(_iPreds,_vars,_mPredicates,_mVariables1,_,_boundVars),
 	removeMultiEntries(_mVariables1,_mVariables),
	append(_mVariables,_boundVars,_testVars),
 	findMetaAPreds(_aPreds,_testVars,_mAPreds),
        setAnswerStatus(_mAPreds,_status),
        !.

setAnswerStatus(_mAPreds,0) :-
  empty(_mAPreds),!.  % we have no meta-A predicates left in the formula
setAnswerFlag(_mAPreds,-1).  % otherwise: some were left unfortunately
%
% partialEvaluate(_rf,_ePred,_extList,_xiList,_rFormulaList,_oldPath,_newPaths):
% _rf: RangeFormula
% _ePred: Prediacte to substitute with its extension
% _extList: Extension of this predicate
% _xiList: Variables to substitute with constants
% _rFormulaList: Set of formulas in which _ePred is replaced with one extension
% _oldPath: binding Path before evaluation of ePred
% _newPaths: for each formula in _rFormulalist this list contains the new path
% Example:
% partialEvaluate(forall([p,c,m,d,x],[In(p,Nec),In(x,c),P(p,c,m,d)],exists([y],[In(y,d),A(x,m,y)],TRUE)),In(p,Nec),[In(against,Nec),In(suffers,Nec)],[p],_newRF,Binds([p,c,m,d],[x,y],[In(p,Nec),P(p,c,m,d)],2),_newPath).
%   _newRF = [forall([c,m,d,x],[In(against,Nec),In(x,c),P(against,c,m,d)],exists([y],[In(y,d),A(x,m,y)],TRUE)),forall([c,m,d,x],[In(suffers,Nec),In(x,c),P(suffers,c,m,d)],exists([y],[In(y,d),A(x,m,y)],TRUE))]
%   _newPath = [Binds([against,c,m,d],[x,y],[In(against,Nec),P(against,c,m,d)],2),Binds([suffers,c,m,d],[x,y],[In(suffers,Nec),P(suffers,c,m,d)],2)]
%

partialEvaluate(_rf,_ePred,_extList,_rFormulaList,_oldSubst,_newSubstList,_oldPath,_newPaths) :-
% 	write(litParts([_ePred],_vars)),nl,nl,

	litParts(_ePred,_,_vars),
% 	write(litParts([_ePred],_vars)),nl,nl,
% 	write(substituteVarsWithCons(_extList,_vars,_rf,_rFormulaList,_oldSubst,_newSubstList,_oldPath,_newPaths)),nl,nl,

	substituteVarsWithCons(_extList,_vars,_rf,_rFormulaList,_oldSubst,_newSubstList,_oldPath,_newPaths)
	% , write(substituteVarsWithCons(_extList,_vars,_rf,_rFormulaList,_oldSubst,_newSubstList,_oldPath,_newPaths)),nl,nl

.
%
% simpleFormula(_f) succeeds if _f contains no metavariables
% Example:
% simpleFormula(exists([y],[In(y,d),A(x,m,y)],TRUE))
% Yes
%
%

simpleFormula(_f) :-
	metaFormulaAnalysis(_f,_,_mVarList,_),
 	empty(_mVarList).
%
% transformEquivalent(_eLit,_rFormula,forall(_varsInst,[_eLit],_subFormula),_actCons):
% _rFormula is transformed into
% forall([x1,...,xk][E(x1,...,xk)],_subFormula)
% Example:
% transformEquivalent(In(p,Nec),forall([p,c,m,d,x],[In(p,Nec),In(x,c),P(p,c,m,d)],exists([y],[In(y,d),A(x,m,y)],TRUE)),_newRF,_newCons).
%  _newRF = forall([p],[In(p,Nec)],forall([c,m,d,x],[In(x,c),P(p,c,m,d)],exists([y],[In(y,d),A(x,m,y)],TRUE)))
%   _newCons = [Nec]
% Yes
%
%
%

transformEquivalent(_eLit,_rFormula,_subFormula,_actCons) :-
	rFormulaParts(_rFormula,_functor,_actVars,_actLits,_sF1),
	memberchk(_functor,[forall,exists]),
	rFormulaAnalysis(_rFormula,_,_cons,_),
	collectArguments([_eLit],_arguments),
	listIntersection(_arguments,_cons,_actCons),
 	listIntersection(_arguments,_actVars,_varsInst),
 	listDifference(_actVars,_varsInst,_remVars),
 	listDifference(_actLits,[_eLit],_remLits),
 	((_remLits \== [],_subFormula=..[_functor,_remVars,_remLits,_sF1]);(_subFormula=_sF1)),!.
% ---------------LOCAL PART --------------------------

collect_InLits_ALits_and_Vars(_rf,_aPreds,_iPreds,_vars) :-
	collectAllLiteralsAndVariables(_rf,_allLits,_vars),
	filterInPreds(_allLits,_iPreds),
	filterAPreds(_allLits,_aPreds).

computeSearchSpaceAccRule(forall(_actVars,_actLits1,_subFormula),_varsTillNow,_vars,_litsTillNow,_lits) :-
	!,append(_varsTillNow,_actVars,_varsNow),
	append(_litsTillNow,_actLits1,_litsNow),
	computeSearchSpaceAccRule(_subFormula,_varsNow,_vars,_litsNow,_lits).
computeSearchSpaceAccRule(exists(_actVars,_actLits1,_subFormula),_varsTillNow,_vars,_litsTillNow,_lits) :-
	!,append(_varsTillNow,_actVars,_varsNow),
	append(_litsTillNow,_actLits1,_litsNow),
	computeSearchSpaceAccRule(_subFormula,_varsNow,_vars,_litsNow,_lits).
computeSearchSpaceAccRule(_rf,_varsTillNow,_varsTillNow,_litsTillNow,_litsTillNow).

convertIntoMFForm1(forall(_vars,_lits,_sf),_newFormula,_status) :-
	convertIntoMFForm1(_sf,_newSF,_status),
	uniteForalls(forall(_vars,_lits,_newSF),_newFormula),!.
convertIntoMFForm1(exists(_vars,_lits,_sf),exists(_vars,_lits,_newSF),_status) :-
	convertIntoMFForm1(_sf,_newSF,_status),!.
convertIntoMFForm1(or(_formulaList),forall([],_cond,_cons),_status) :-
	% write(testIfImpl(_formulaList)),nl,nl,

	testIfImpl(_formulaList),
	% write(splitIntoCondAndCons(_formulaList,_cond,_cons1,0)),nl,nl,

	splitIntoCondAndCons(_formulaList,_cond,_cons1,0),!,
	% write(convertIntoMFForm1(_cons1,_cons,_status)),nl,nl,

	convertIntoMFForm1(_cons1,_cons,_status),!.
convertIntoMFForm1(_f,_f,0) :- !.

convertIntoMFForm1Rule(forall(_vars,_lits,_sf),_newFormula,_status) :-
	convertIntoMFForm1Rule(_sf,_newSF,_status),
	uniteForalls(forall(_vars,_lits,_newSF),_newFormula).
convertIntoMFForm1Rule(exists(_vars,_lits,_sf),exists(_newVars,_newLits,_newSF),_status) :-
	convertIntoMFForm1Rule(_sf,_newSF1,_status),
	uniteExists(exists(_vars,_lits,_newSF1),exists(_newVars,_newLits,_newSF)).
convertIntoMFForm1Rule(or(_formulaList),forall([],_cond,_cons),_status) :-
	testIfImpl(_formulaList),
	splitIntoCondAndCons(_formulaList,_cond,_cons1,0),!,
	convertIntoMFForm1Rule(_cons1,_cons,_status).
convertIntoMFForm1Rule(and(_formulaList) ,exists(_vars,_lits,_newSF), 0) :-
	testIfAllExistsAndCompress(and(_formulaList),exists(_vars,_lits,_newSF)).
convertIntoMFForm1Rule(_f,_f,0).

filterSimpleFormulas2(_mode,_,[],[],[],[],[],[],_):- !.
filterSimpleFormulas2(_mode,_mVars,[_f|_],[],_,[],_,[],_) :-
	collect_InLits_ALits_and_Vars(_f,_,_,_vars),
	listIntersection(_vars,_mVars,_testList),
	_testList \== [],!.
filterSimpleFormulas2(_mode,_mVars,[_f1|_formulas],_simpleFormulas,[subst(_vlist,_clist)|_substs],_simpleSubsts,[_ePreds1|_ePredsList],_simpleEPredsList,_qid) :-
	'SystemGenerated'(_clist),!,
	'WriteTrace'(high,'MetaFormulas',['Formula ',_f1,' contains system generated label -> ignored']), !,
	filterSimpleFormulas2(_mode,_mVars,_formulas,_simpleFormulas,_substs,_simpleSubsts,_ePredsList,_simpleEPredsList,_qid) .
filterSimpleFormulas2(_mode,_mVars,[_f1|_formulas],_simpleFormulas,[subst(_vlist,_clist)|_substs],_simpleSubsts,[_ePreds1|_ePredsList],_simpleEPredsList,_qid) :-
	'TestQueryClass'(_clist,_qid),!,
	'WriteTrace'(high,'MetaFormulas',['Subsitution ',subst(_vlist,_clist) ,' contains QueryClass as substitution -> Formula ignored']), !,
	filterSimpleFormulas2(_mode,_mVars,_formulas,_simpleFormulas,_substs,_simpleSubsts,_ePredsList,_simpleEPredsList,_qid) .
filterSimpleFormulas2(_mode,_mVars,[_f1|_formulas],_simpleFormulas,[subst(_vlist,_clist)|_substs],_simpleSubsts,[_ePreds1|_ePredsList],_simpleEPredsList,_qid) :-
	isRedundant(_mode,_f1),!,
	'WriteTrace'(high,'MetaFormulas',['The ',_mode,' formula ',idterm(_f1),' is redundant -> ignored']), !,
	filterSimpleFormulas2(_mode,_mVars,_formulas,_simpleFormulas,_substs,_simpleSubsts,_ePredsList,_simpleEPredsList,_qid) .
filterSimpleFormulas2(_mode,_mVars,[_f1|_formulas],[_f|_simpleFormulas],[_subst|_substs],[_subst|_simpleSubsts],[_ePreds1|_ePredsList],[_ePreds1|_simpleEPredsList],_qid) :-
	uniteForalls(_f1,_f),!,
	filterSimpleFormulas2(_mode,_mVars,_formulas,_simpleFormulas,_substs,_simpleSubsts,_ePredsList,_simpleEPredsList,_qid) .

findFormulaClass([_var|_],_var,[_class|_],_class) :- !.
findFormulaClass([_v|_vList],_var,[_|_clist],_class) :-
	_v \== _var,
	findFormulaClass(_vList,_var,_clist,_class).

findMetaInPreds([],_,[],[],[],[]) .
%  The In predicate comes in three flavors In(x,c),In_e(x,c),In_s(x,c); ticket #314

findMetaInPreds([_inLit|_inLits],_varList,[_inLit|_mInLits],[_c|_mVars],_sInLits,[_x|_bVars]):-
	litParts(_inLit,_In,[_x,_c]),
	memberchk(_In,['In','In_e','In_s']),
	memberchk(_c,_varList),
	findMetaInPreds(_inLits,_varList,_mInLits,_mVars,_sInLits,_bVars).
findMetaInPreds([_inLit|_inLits],_varList,_mInLits,_mVars,[_inLit|_sInLits],[_x|_bVars]) :-
 	litParts(_inLit,_In,[_x,_c]),
	memberchk(_In,['In','In_e','In_s']),
	nonmember(_c,_varList),
	findMetaInPreds(_inLits,_varList,_mInLits,_mVars,_sInLits,_bVars).
%  ticket #404: handle Isa-predicate

findMetaInPreds([_inLit|_inLits],_varList,[_inLit|_mInLits],[_c|_mVars],_sInLits,[_x|_bVars]):-
	litParts(_inLit,_In,[_x,_c]),
	memberchk(_In,['Isa']),
	memberchk(_c,_varList),
	memberchk(_x,_varList),  % both shall not be a variable
	findMetaInPreds(_inLits,_varList,_mInLits,_mVars,_sInLits,_bVars).
findMetaInPreds([_inLit|_inLits],_varList,_mInLits,_mVars,[_inLit|_sInLits],[_x|_bVars]):-
	litParts(_inLit,_In,[_x,_c]),
	memberchk(_In,['Isa']),
	nonmember(_c,_varList),
	findMetaInPreds(_inLits,_varList,_mInLits,_mVars,_sInLits,_bVars).
%  11-Nov-2003/M.Jeusfeld

findMetaInPreds([_inLit|_inLits],_varList,[_inLit|_mInLits],[_m|_mVars],_sInLits,_bVars):-
        litParts(_inLit,'A',[_x,_m,_y]),
        memberchk(_m,_varList),
        findMetaInPreds(_inLits,_varList,_mInLits,_mVars,_sInLits,_bVars).
%  ticket #404

findMetaInPreds([_inLit|_inLits],_varList,_mInLits,_mVars,[_inLit|_sInLits],_bVars):-
        litParts(_inLit,'A',[_x,_m,_y]),
        nonmember(_m,_varList),
        findMetaInPreds(_inLits,_varList,_mInLits,_mVars,_sInLits,_bVars).
findMetaInPreds([_inLit|_inLits],_varList,[_inLit|_mInLits],[_m|_mVars],_sInLits,_bVars):-
        litParts(_inLit,'A_label',[_x,_m,_y,_n]),
        memberchk(_m,_varList),
        findMetaInPreds(_inLits,_varList,_mInLits,_mVars,_sInLits,_bVars).
findMetaInPreds([_inLit|_inLits],_varList,[_inLit|_mInLits],_mVars,_sInLits,_bVars):-
        litParts(_inLit,'A_label',[_x,_m,_y,_n]),
        nonmember(_m,_varList),
        findMetaInPreds(_inLits,_varList,_mInLits,_mVars,_sInLits,_bVars).
%  ticket #207: support A_e like A

findMetaInPreds([_inLit|_inLits],_varList,[_inLit|_mInLits],[_m|_mVars],_sInLits,_bVars):-
        litParts(_inLit,'A_e',[_x,_m,_y]),
        memberchk(_m,_varList),
        findMetaInPreds(_inLits,_varList,_mInLits,_mVars,_sInLits,_bVars).
findMetaInPreds([_inLit|_inLits],_varList,[_inLit|_mInLits],_mVars,_sInLits,_bVars):-
        litParts(_inLit,'A_e',[_x,_m,_y]),
        nonmember(_m,_varList),
        findMetaInPreds(_inLits,_varList,_mInLits,_mVars,_sInLits,_bVars).
%  7-Apr-2005/M.Jeusfeld
%
% findMetaInPreds([_inLit|_inLits],_varList,[_inLit|_mInLits],[_m|_mVars],_sInLits,_bVars):-
%         litParts(_inLit,Label,[_x,_m]),
%         memberchk(_m,_varList),
%         findMetaInPreds(_inLits,_varList,_mInLits,_mVars,_sInLits,_bVars).
% findMetaInPreds([_inLit|_inLits],_varList,[_inLit|_mInLits],_mVars,_sInLits,_bVars):-
%         litParts(_inLit,Label,[_x,_m]),
%         nonmember(_m,_varList),
%         findMetaInPreds(_inLits,_varList,_mInLits,_mVars,_sInLits,_bVars).
%
%  14-Nov-2007: Label(x,m) is no longer qualifying a formula as meta formula (ticket #164)
%  ticket #404

findMetaInPreds([_inLit|_inLits],_varList,_mInLits,_mVars,[_inLit|_sInLits],_bVars):-
        findMetaInPreds(_inLits,_varList,_mInLits,_mVars,_sInLits,_bVars).

findMetaAPreds([],_,[]) .
findMetaAPreds([_aPred|_aPreds],_boundVars,[_aPred|_mAPreds]) :-
	litParts(_aPred,'A',[_x,_,_]),
	'VarTabVariable'(_x),
	nonmember(_x,_boundVars),!,
	findMetaAPreds(_aPreds,_boundVars,_mAPreds).
%  7-Apr-2005/M.Jeusfeld

findMetaAPreds([_aPred|_aPreds],_boundVars,[_aPred|_mAPreds]) :-
        litParts(_aPred,'Label',[_x,_]),
        'VarTabVariable'(_x),
        nonmember(_x,_boundVars),!,
        findMetaAPreds(_aPreds,_boundVars,_mAPreds).
findMetaAPreds([_aPred|_aPreds],_boundVars,_mAPreds) :-
	findMetaAPreds(_aPreds,_boundVars,_mAPreds).

inspectRange_In_A([],[],[]) .
inspectRange_In_A(['A'(_x,_m,_y)|_litList],['A'(_x,_m,_y)|_aPredsLitList],_iPredsLitList) :- !,
	inspectRange_In_A(_litList,_aPredsLitList,_iPredsLitList).
inspectRange_In_A(['In'(_x,_y)|_litList],_aPredsLitList,['In'(_x,_y)|_iPredsLitList]) :- !,
	inspectRange_In_A(_litList,_aPredsLitList,_iPredsLitList).
inspectRange_In_A([not(_lit)|_litList],_aPredsLitList,_iPredsLitList) :- !,
	inspectRange_In_A([_lit|_litList],_aPredsLitList,_iPredsLitList).
inspectRange_In_A([_lit|_litList],_aPredsLitList,_iPredsLitList) :-
	litParts(_lit,_functor,_),
	inspectRange_In_A(_litList,_aPredsLitList,_iPredsLitList).

substituteVarsWithCons([],_,_,[],_,[],_,[]) .
substituteVarsWithCons([_ext|_exts],_vars,_rf,[_newRf|_newRfs],_oldSubst,[_nS|_newSubstList],_path,[_newPath|_newPaths]) :-
	litParts(_ext,_,_args),
	substituteRF(_rf,_vars,_args,_newRf1),
	optimizeIfSimple(_newRf1, _newRf),
	substituteBP(_path,_vars,_args,_newPath),
	buildNewSubstList(_oldSubst,_vars,_args,_nS),
	substituteVarsWithCons(_exts,_vars,_rf,_newRfs,_oldSubst,_newSubstList,_path,_newPaths).

optimizeIfSimple(_rf,_orf) :-
  simpleFormula(_rf),
  getFlag(optimizeLevel,_old),  % ticket #346: only set optimize level to 0 when needed
  setFlag(optimizeLevel,0),
  optimizeRangeform(rangeconstr(_rf), rangeconstr(_orf)),
  setFlag(optimizeLevel,_old),
  !.
optimizeIfSimple(_rf,_rf).

buildNewSubstList(_oldSubst,[],[],_oldSubst).
buildNewSubstList(_oldSubst,[_v|_vars],[_v|_cons],_newSubst) :- !,
	buildNewSubstList(_oldSubst,_vars,_cons,_newSubst).
buildNewSubstList(_oldSubst,[_v|_vars],[_c|_cons],subst([_v|_newSubstV],[_c|_newSubstC])) :-
	buildNewSubstList(_oldSubst,_vars,_cons,subst(_newSubstV,_newSubstC)).

'SystemGenerated'([_id|_ids]) :-
	pc_atomconcat('#',_,_id),
	'WriteTrace'(veryhigh,'MetaFormulas',['Warning: ', _id,' is system generated label']), !.
'SystemGenerated'([_id|_ids]) :-
	pc_atomconcat(_nrAtom,generated,_id),
	pc_inttoatom(_nr,_nrAtom),
	'WriteTrace'(veryhigh,'MetaFormulas',['Warning: ', _id,' is system generated label']), !.
'SystemGenerated'([_id|_ids]) :-
	'SystemGenerated'(_ids).

'TestQueryClass'([_id|_ids],_qid) :-
	is_id(_id),
	prove_literal('In'(_id,_qid)),
	\+ prove_literal('In'(_id,id_46)),  % id_46=MSFOLrule
        !,
	'WriteTrace'(veryhigh,'MetaFormulas',['Warning: ', _id,' is instance of query class']), !.
'TestQueryClass'([_id|_ids],_qid) :-
	is_id(_id),
	prove_literal('Isa'(_id,_qid)),!,
	'WriteTrace'(veryhigh,'MetaFormulas',['Warning: ', _id,' is a query class']), !.
'TestQueryClass'([_id|_ids],_qid) :-
	'TestQueryClass'(_ids,_qid).

getVariableSubst(_v,subst([_v|_vars],[_c|_cons]),_c).
getVariableSubst(_v,subst([_v1|_vars],[_|_cons]),_c) :-
	_v1 \== _v,
	getVariableSubst(_v,subst(_vars,_cons),_c).
