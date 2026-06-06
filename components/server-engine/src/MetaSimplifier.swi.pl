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
% File:         MetaSimplifier.pro
% Version:      2.3
%
%
% Date released : 96/02/12  (YY/MM/DD)
%
% SCCS-Source-Pool : /home/CBase/CB_NewStruct/ProductPOOL/serverSources/Prolog_Files/SCCS/s.MetaSimplifier.pro
% Date retrieved : 96/02/12 (YY/MM/DD)
% *************************************************************************
%
% The MetaSimplifier module implements the algorithm for simplifying
% metaformulas. It adds partial evaluation of metaformulas to the
% existing formula evaluation.
%
% Procedure overview
%
% Input: meta formula f, i.e. a formula with class variables kv
% Output: 3 sets:
% 	set of generated formulas gf
% 	set of procedure triggers (insert) it
% 	set of procedure triggers (delete) dt
%
% Procedure (for constraints)
%  1. Test whether formula f is a metaformula
%  2. Transform this formula into the format
%     forall([x1,..,xk],[L1,...,Ln],subFormula)
%     so that kv is a subset of [x1,..,xk]
%  3. Choose a sequence of literals from [L1,..,Ln]
%     (OBDA [L1,...,Lk])
%     so that all elements from kv can be bound by evaluating
%     these literals; then call step 4 with f and L = [L1,...Lk]
%  4. Evaluate these literals
%     4.0 If L = [], then stop;
%         otherwise
%     	let L = [Li,...,Lk] be the remaining literal sequence to evaluate
%     	4.1  Compute the extension of Li: Ext(Li) = [Li1,...,Lij]
%     	4.2  Generate a set of formulas f_i
%             by replacing the variables of Li with the respective
%             constants from Ext(Li)
%     	4.3  Add the following trigger to it:
%                 "If the extension of Li is enlarged by a new element Li(j+1),
%                  then generate the corresponding formula as in 4.2
%                  and call 4.4 with this new formula"
%     	4.4  For each formula f_im from f_i, add the following trigger to dt:
%                 "If L_im is deleted from Ext(Li), then delete f_im and all objects
%                  generated from the formula f_im"
%     	4.5  Call step 4 for each formula from f_i with [Li+1,...,Lk]
%
%
%  For rules the procedure is analogous, except that
% a different format is chosen. While constraints use only
% universally quantified literals that are replaced, rules use
% both universally and existentially quantified literals.
%
%
%
%
%
%

:- module('MetaSimplifier',[
'metaSimplifier'/7
,'testIfMetaFormula'/3
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').
:- use_module('MetaBindingPath.swi.pl').
:- use_module('MetaFormulas.swi.pl').
:- use_module('MetaLiterals.swi.pl').
:- use_module('MetaRFormulas.swi.pl').
:- use_module('MetaRFormToAssText.swi.pl').
:- use_module('MetaTriggerGen.swi.pl').
:- use_module('GeneralUtilities.swi.pl').
:- use_module('MetaUtilities.swi.pl').
:- use_module('RangeformSimplifier.swi.pl').
:- use_module('ErrorMessages.swi.pl').
:- use_module('GlobalParameters.swi.pl').
:- use_module('SemanticOptimizer.swi.pl').
:- style_check(-singleton).
%
% testMS(forall([p,c,m,d,x],[In(x,PseudoClass),In(m,PseudoClass),In(p,Nec),In(x,c),P(p,c,m,d)],exists([y],[In(y,d),A(x,m,y)],TRUE)),_peFormulas,_trigger,_substList).
% testMS(forall([p,c,m,d,x],[In(p,Single),In(x,c),P(p,c,m,d)],forall([y,z],[In(y,d),In(z,d),A(x,m,y),A(x,m,z)],and([Eq(y,z)]))),_peFormulas,_trigger,_substList).
% testMS(forall([p,c,m,d,y],[In(p,RevSingle),In(y,d),P(p,c,m,d)],forall([x1,x2],[In(x1,c),In(x2,c),A(x1,m,y),A(x2,m,y)],and([Eq(x1,x2)]))),_peFormulas,_triggerList,_substList).
% testMS(forall ([p,c,m,d],[In(p,NonCircular) ,P(p,c,m,d)],forall( [x,y], [In(x,c),A(x,m,y)],and([not(Eq(x,y))]))),_peFormulas,_triggerList,_substList).
% testMS(forall([c],[In(c,NonEmptyClass)],exists([x],[In(x,c)],TRUE)),_peFormulas,_triggerList,_substList).
% testMS(forall([c],[In(c,EmptyClass)],forall([x],[In(x,c)],FALSE)),_peFormulas,_triggerList,_substList).
% testMS(forall( [p,c,m], [In(p,TransClosed),P(p,c,m,c)],forall([x,y],[In(x,c),In(y,c)], exists ([z],[In(z,c),A(x,m,z),A(z,m,y) ],and([A(x,m,y)])))),_peFormulas,_triggerList,_substList).
% testMS(forall([x,m,y],[In(x,Pred),In(y,Pred),In(m,Module),In(x,m),A(x,uses,y)],or([In(y,m),A(m,imports,y)])),_peFormulas,_triggerList,_substList).
%
%
% makes no sense, only because of "not"
%
% testMS(forall([p,c,m,d,x,y],[In(p,Nec),In(x,c),P(p,c,m,d),In(y,d)],and([not(A(c,m,y)),A(x,m,y)])),_peFormulas,_trigger,_substList).
%
%  	Functor "rangeconstr" and removal of In literals with the system classes "Class"
% 	and "Proposition" from the search set
%
% metaSimplifier(rangeconstr(forall([c,d,p],[In(c,Class),In(d,Class),In(p,Proposition),In(p,Necessary)],forall([m],[In(m,Proposition),P(p,c,m,d)],forall([x],[In(x,Proposition),In(x,c)],exists([y],[In(y,Proposition),In(y,d),A(x,m,y)],TRUE))))),_f,_t,_substList).
% metaSimplifier(rangeconstr(forall([p],[In(p,Proposition),In(p,Necessary)],forall([m,x,c],[In(m,Proposition),In(x,Proposition),In(c,Class),In(x,c)],forall([d],[In(d,Class),P(p,c,m,d)],exists([y],[In(y,Proposition),In(y,d),A(x,m,y)],TRUE))))),_f,_t,_substList).

testIfMetaFormula(_mode,_f,'redundant') :-
	simpleFormula(_f),
	isRedundant(_mode,_f),
	!.
testIfMetaFormula(_,_f,'simple') :-
	simpleFormula(_f),!.
testIfMetaFormula(_,_f,'meta') :-
	metaFormula(_f).
% **************************************************
% metaSimplifier(_f,_e,_fStrings,_iTrigs,_dTrigs,_substs,_classes)
%
% Parameter
% _f: input formula (metaformula)
% _e: instances of predicates evaluated so far
% _fStrings: generated formulas
% _iTrigs: triggers that fire on insertions
% _dTrigs: triggers that fire on deletions
% _substs: substitutions
% _classes: classes attached to the generated formulas
%
% *************************************************

metaSimplifier(_f,_ePredsTillNow,[],[],[],[],[]) :-
	filterParameterFormula(_ePredsTillNow),!.
%  ticket #266: simple formulas that are redundant are not generated

metaSimplifier(rangeconstr(_rf),_ePredsTillNow,[],[],[],[],[]) :-
        simpleFormula(_rf),
        isRedundant(constraint,_rf),
        'WriteTrace'(high,'MetaSimplifier',['Formula ',nl,idterm(_rf),nl,'is always true and thus ignored']),
        !.
metaSimplifier(rangeconstr(_rf),_ePredsTillNow,_formulaStrings,_insertTriggerList,_deleteTriggerList,_substList,_classList) :-
	!,
	metaSimplify(_rf,_formulas1,_ePredList,_triggerList1,_substList),!,
	encloseConstraint(rangeconstr,_formulas1,_formulas,_triggerList1,_triggerList2),!,
	findFormulasClasses(_formulas,_classList),!,
	reCompileRFormulaList(_formulas,_formulaStrings),!,
	buildInsertTriggerList(_triggerList2,_ePredsTillNow,_insertTriggerList),
        !,
	buildDeleteTriggerList(_formulaStrings,_ePredsTillNow,_ePredList,_deleteTriggerList),
        !.
%  ticket #301: simple rules that are redundant are not generated

metaSimplifier(rangerule(_vars,_rf,_conclLit),_ePredsTillNow,[],[],[],[],[]) :-
        simpleFormula(rangerule(_vars,_rf,_conclLit)),
        isRedundant(rule,rangerule(_vars,_rf,_conclLit)),
        'WriteTrace'(high,'MetaSimplifier',['Rule ',idterm(rangerule(_vars,_rf,_conclLit)),' is redundant and thus ignored.']),
        !.
metaSimplifier(rangerule(_vars,_f,_lit),_ePredsTillNow,_formulaStrings,_insertTriggerList,_deleteTriggerList,_substList,_classList) :-
	!,
	metaSimplify(rangerule(_vars,_f,_lit),_formulas1,_ePredList,_triggerList1,_substList),!,
	encloseRule(rangerule,_formulas1,_vars,_substList,_lit,_rangeruleList,_triggerList1,_triggerList2),!,
	findFormulasClasses(_rangeruleList,_classList),!,
        reCompileRFormulaList(_rangeruleList,_formulaStrings),!,
	buildInsertTriggerList(_triggerList2,_ePredsTillNow,_insertTriggerList),
        !,
	buildDeleteTriggerList(_formulaStrings,_ePredsTillNow,_ePredList,_deleteTriggerList),
        !.
metaSimplifier(_formula,_,_,_,_,_,_) :-
	report_error('MSERR0','MetaSimplifier',[_formula]),
	fail.

metaSimplify(rangerule(_vars,_f,_lit),[_f],[[]],[],[subst([],[])]) :-
	simpleFormula(rangerule(_vars,_f,_lit)),!.
metaSimplify(_f,[_f],[[]],[],[subst([],[])]) :-
	simpleFormula(_f),!.
%  	the rule case must be handled separately because
% 	it is not a range-restricted rule
% 	but a formula in the proper sense.
% 	The MetaSimplify algorithm works on the condition part of rules.
% 	Substitutions found during that process are carried over to the
% 	inference literal. Nevertheless the inference literal must be
% 	considered when testing the meta-formula property:
% 	Example: axiom 12 as a rule:
%         rule
%         ax12:
%         $ forall x,c/VAR (exists p,d/VAR
%              In(p,Proposition!IsA) and P(p,d,'*isa',c) and In(x,d)) ==> In(x,c)$
% 	end
% 	Only through the inference literal is c a meta-variable.
%

metaSimplify(rangerule(_litVars,_fInMF,_conclLit),_accForm,_ePredList,_triggerList,_substList) :-
	!,
	metaFormulaAnalysis(rangerule(_litVars,_fInMF,_conclLit),_mLits,_mVars,_status),
	%  first error case:
	% 	   status \== 0: formula contains A(x,m,y) and x cannot be bound
	% 	   to a class via In(x,c)

	(_status == 0;(report_error('MSERR1','MetaSimplifier',[_mLits]),fail)),!,
	delPseudoIns(_fInMF,_fT1MF),
        exploitFunctionalDependencies(_mVars,_fT1MF,_fFD),  % ticket #276
	convertIntoMFFormRule(_fFD,_f,_status2),
	%  second error case:
	% 	   status2 \== 0
	% 	   formula cannot be converted to the format forall x1,..,xk EPred(x1,..,xk) ==> phi
	% 	   (for constraints)
	%

	(_status2 == 0;(report_error('MSERR2','MetaSimplifier',[_fFD]),fail)),!,
	computeSearchSpaceRule(_f,_cons,_vars,_lits),
 	listDifference(_mVars,_vars,_testList),
	%  third error case:
	% 	   there are meta-variables that cannot be bound by partial evaluation

	(empty(_testList);(report_error('MSERR3','MetaSimplifier',[_testList]),fail)),!,
        findBindingPath(_mVars,_cons,_vars,_lits,_bPath),
 	metaSimplifyFlist([_f],[_bPath],[[]],_ePredList1,_triggerList,_accForm1,[subst([],[])],_substList1),
	filterSimpleFormulas(rule,_mVars,_accForm1,_accForm,_substList1,_substList,_ePredList1,_ePredList).
metaSimplify(_fInMF,_accForm,_ePredList,_triggerList,_substList) :-
	metaFormulaAnalysis(_fInMF,_mLits,_mVars,_status),
	%  not_empty(_mVars) applies because this is not simpleFormula due to the cut
	%  first error case:
	% 	   status \== 0: formula contains A(x,m,y) and x cannot be bound to a class via
	% 	   In(x,c)

	(_status == 0;(report_error('MSERR1','MetaSimplifier',[_mLits]),fail)),!,
	delPseudoIns(_fInMF,_fT1MF),
        %  evaluate certain literals in _fInMF that can have only one solution
        %  ticket #276

        exploitFunctionalDependencies(_mVars,_fT1MF,_fFD),
	convertIntoMFForm(_fFD,_f,_status2),
	%  second error case:
	% 	   status2 \== 0
	% 	   formula cannot be converted to the format forall x1,..,xk EPred(x1,..,xk) ==> phi
	% 	   (for constraints)
	%

	(_status2 == 0;(report_error('MSERR2','MetaSimplifier',[_fFD]),fail)),!,
 	computeSearchSpace(_f,_cons,_vars,_lits),
 	listDifference(_mVars,_vars,_testList),
	%  third error case:
	% 	   there are meta-variables that cannot be bound by partial evaluation

	(empty(_testList);(report_error('MSERR3','MetaSimplifier',[_testList]),fail)),!,
        findBindingPath(_mVars,_cons,_vars,_lits,_bPath),
 	metaSimplifyFlist([_f],[_bPath],[[]],_ePredList1,_triggerList,_accForm1,[subst([],[])],_substList1),
	filterSimpleFormulas(constraint,_mVars,_accForm1,_accForm,_substList1,_substList,_ePredList1,_ePredList),
        !.
%  first try to find a binding path _bPath with the optimistic cost level

findBindingPath(_mVars,_cons,_vars,_lits,_bPath) :-
   get_cb_feature(optimisticCostLevel,_mcost),  % ticket #246
   findBindingPathWithCostLevel(_mVars,_cons,_vars,_lits,_mcost,_bPath),
   !.
%  if not sucessful, try the maximum cost level

findBindingPath(_mVars,_cons,_vars,_lits,_bPath) :-
   get_cb_feature(maxCostLevel,_mcost),  % ticket #246
   findBindingPathWithCostLevel(_mVars,_cons,_vars,_lits,_mcost,_bPath),
   'WriteTrace'('veryhigh','MetaSimplifier',['Binding path found within the extended search space of maximum cost level']),
   !.
%  a binding path could not be found:
%   fourth error case:
% 	    there are meta-variables for which no literal evaluation strategy
% 	    was found in the search space. Allowed evaluation patterns are
% 	    defined in MetaLiterals.pro. The cost of an evaluation step may
% 	    not exceed the value given in the 5th argument of
% 	    findBindingPathsForVars.
%

findBindingPath(_mVars,_cons,_vars,_lits,_) :-
   report_error('MSERR4','MetaSimplifier',[_lits]),
   !,
   fail.

findBindingPathWithCostLevel(_mVars,_cons,_vars,_lits,_mcost,_bPath) :-        
	findBindingPathsForVars(_mVars,_cons,_vars,_lits,_mcost,_bPaths),
	not_empty(_bPaths),
 	selectCheapestPath(_mVars,_cons,_bPaths,_bPath,0),
        !.
%  rather complex partial evaluation of a meta formula where the formula is defined in the same
%  transaction where some data (extension for the ePreds) is told

metaSimplifyFlist([],_,[],[],[],[],_,[]) .
metaSimplifyFlist([_f|_formulas],[_bList|_bLists],[_fEPredsTillNow|_ePredListTillNow],_ePredList,_triggerList,_genForm,[_oldSubst|_oldSubsts],_substList) :-
	metaSimplifyFormula(_f,_bList,_fTriggerList,_genForm1,_fEPredsTillNow,_ePredList1,_oldSubst,_substList1),
	metaSimplifyFlist(_formulas,_bLists,_ePredListTillNow,_ePredList2,_formulasTriggerList,_genForm2,_oldSubsts,_substList2),
	append(_fTriggerList,_formulasTriggerList,_triggerList),
 	append(_genForm1,_genForm2,_genForm),
	append(_ePredList1,_ePredList2,_ePredList),
	append(_substList1,_substList2,_substList).

metaSimplifyFormula(_f,'Binds'(_,_,[],_),[],[_f],_fEPredsTillNow,[_fEPredsTillNow],_subst,[_subst]).
metaSimplifyFormula(_f,'Binds'(_c,_v,[_ePred|_bindingPath],_cost),
	[_trigInsert|_peTriggerList],_genFormulas,_fEPredsTillNow,_ePredList,_oldSubst,_substList) :-
        exploitFunctionalDependencies(_c,_f,_f1),  % ticket #276
	transformEquivalent(_ePred,_f1,_subFormula,_constants),
	computeExtension(_ePred,_constants,_extList),
	partialEvaluate(_subFormula,_ePred,_extList,_peFormulas,_oldSubst,_peSubstList,'Binds'(_c,_v,_bindingPath,_cost),_pePaths),
	saveDataForInsertTrigger(_fEPredsTillNow,_ePred,_extList,_constants,_subFormula,_oldSubst,_trigInsert),
	buildListOfLists(_fEPredsTillNow,_extList,_ePredListNew),
	metaSimplifyFlist(_peFormulas,_pePaths,_ePredListNew,_ePredList,_peTriggerList,_genFormulas,_peSubstList,_substList).
