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

:- module('QO_preproc',[
'initOptStructures'/1
,'isQlit'/1
,'isComplexQlit'/1
,'isComplexComparisonLit'/1
,'postprocRule'/3
,'preOptimize'/3
,'preprocRule'/3
,'preprocRuleList'/3
,'isFunctionLit'/2
,'postProcEcaCond'/4
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').
:- use_module('QueryCompiler.swi.pl').
:- use_module('QO_heur.swi.pl').
:- use_module('QO_literals.swi.pl').
:- use_module('QO_vartab.swi.pl').
:- use_module('QO_utils.swi.pl').
:- use_module('GeneralUtilities.swi.pl').
:- use_module('PrologCompatibility.swi.pl').
:- use_module('Literals.swi.pl').
:- use_module('MetaUtilities.swi.pl').
:- use_module('GlobalParameters.swi.pl').
:- style_check(-singleton).
% ================= preOptimize   =====================================
% --------------------------------------------------------------------
%
%  preOptimize:
%  Preparatory optimization of the Datalog rules:
%
%  * final A -> Adot replacement
%  * minimization of argument lists
%
% --------------------------------------------------------------------

preOptimize(_ruleSetIn,_ranges,_ruleSet) :-
	%  1. store the variable table produced by the parser

	removeRFVartab,
	storeRFVartab(_ranges),
	%  2. final semantic optimization

	semOptDatalogList(_ruleSetIn,_ruleSetOut1),
	%  3. minimization of argument lists

	fixMinArgRuleSet(_ruleSetOut1,_ruleSet),!.
% ================= semOpt_Datalog ====================================

semOptDatalogList([],[]).
semOptDatalogList([(_head :- _ruleTerm)|_ruleSetIn],[(_head :- _newRuleTerm)|_ruleSet]) :-
	'Conjunct2List'(_ruleTerm,_lits0),
	semOpt_Datalog(_lits0,_lits1),
	'List2Conjunct'(_lits1,_newRuleTerm),
	semOptDatalogList(_ruleSetIn,_ruleSet).
% --------------------------------------------------------------------
%  	semOpt_Datalog
% 	   1. A to Adot:
% 		at the Datalog level a stratified
% 		replacement of A literals by Adot literals
% 		is performed
%          2. In-literals remove
% 		In-literals that have redundant class bindings
% 		contain, are removed
%
% --------------------------------------------------------------------

semOpt_Datalog(_litsIn,_litsOut) :-
	%  Determine classes

	getConstAndVarsList(_litsIn,_const,_vars),
	getInLitsWithConstClass(_litsIn,_const,_inLits),
	getVarClassesInRFVT(_vars,_inLits,_varsWithClasses),
	%  Step 1: A to Adot replacement

	replaceAsWithAdots(_litsIn,_const,_varsWithClasses,_litsOut1),
	%  Step 2: remove redundant In literals

	removeRedundantInLitsForFunctions(_litsOut1,_litsOut1,_litsOut2),
	removeRedundantInLits(_litsOut2,_vars,_litsOut),
    !.
semOpt_Datalog(_lits,_lits).
% --------------------------------------------------------------------
%
%  Find the In literals with constant class that still remain.
%
% --------------------------------------------------------------------

getInLitsWithConstClass([],_,[]).
getInLitsWithConstClass(['In'(_x,_c)|_lits],_const,['In'(_x,_c)|_inLits]) :-
	memberchk(_c,_const),
	!,
	getInLitsWithConstClass(_lits,_const,_inLits).
getInLitsWithConstClass([_|_lits],_const,_inLits) :-
	getInLitsWithConstClass(_lits,_const,_inLits).
% --------------------------------------------------------------------
%
%  getVarClassesInRFVT
%  Determine the classes of the variables in the literal sequence from
%  the variable table produced by the parser and from the In literals
%  remaining in the sequence.
%
% --------------------------------------------------------------------

getVarClassesInRFVT(_vars,_inLits,_varClasses) :-
	initVCList(_vars,_vcList0),
	updateVCListRFVT(_vcList0,_vcList1),
	updateVCListIn(_inLits,_vcList1,_varClasses).
% --------------------------------------------------------------------
%
%  getVarClassesAdot
%  Determine the classes of the variables only from the class bindings
%  that arise from the Adot literals, to discover redundant In literals
%
% --------------------------------------------------------------------

getVarClassesAdot(_vars,_lits,_varClasses) :-
	initVCList(_vars,_vcList0),
	updateVCListAdot(_lits,_vcList0,_varClasses).
% --------------------------------------------------------------------
%
%  initVCList
%  Input: list of variables
%  Output: list with elements of the form _var-_classList
%           In _classList the classes of _var are collected
% 	    This list is initialized here
% --------------------------------------------------------------------

initVCList([],[]).
initVCList([_var|_vars],[_var-[]|_vcList]) :-
	initVCList(_vars,_vcList).

updateVCListRFVT([],[]).
updateVCListRFVT([_c-_classes|_vcs],[_c-_newClasses|_newVcs]) :-
	getClassesFromRFVT(_c,_rfClasses),
	append(_rfClasses,_classes,_newClasses),
	updateVCListRFVT(_vcs,_newVcs).
% --------------------------------------------------------------------
%
%  updateVCListIn
%  Input: list of pairs _var-_classlist
% 	    list of literals
%  Output: If a literal In(_x,c) appears in the literal list, where
%           c is constant and _x is a variable, then c is added to
% 	    the class list of _x
% --------------------------------------------------------------------

updateVCListIn([],_vcList,_vcList).
updateVCListIn(['In'(_x,_c)|_ins],_vcListIn,_vcList) :-
	isConst(_c),!,
	select(_x-_classes,_vcListIn,_vcListRem),
	updateVCListIn(_ins,[_x-[_c|_classes]|_vcListRem],_vcList).
updateVCListIn(['In'(_x,_c)|_ins],_vcListIn,_vcList) :-
	updateVCListIn(_ins,_vcListIn,_vcList).
% --------------------------------------------------------------------
%
%  updateVCListAdot
%  Input: list of pairs _var-_classlist
% 	    list of literals
%  Output: If a literal Adot(p,_x,_y) appears, then for _x (_y) the
%           source class (destination class) of the attribute category
% 	    is added to the class list.
% --------------------------------------------------------------------

updateVCListAdot([],_vcList,_vcList).
updateVCListAdot(['Adot'(_c,_x,_y)|_lits],_vcListIn,_vcList) :-
	isConst(_l),!,
	getSource(_c,_s),getDest(_c,_d),
	(
		(
			isVar(_x),
	  		select(_x-_classesX,_vcListIn,_vcListRem1),
	  		_vcList1 = [_x-[_s|_classesX]|_vcListRem1]
		);
	 	(
			isConst(_x),_vcList1 = _vcListIn)
	),
	(
		(
			isVar(_y),
          		select(_y-_classesY,_vcList1,_vcListRem2),
          		_vcList2 = [_y-[_d|_classesY]|_vcListRem2]
		);
         	(
			isConst(_y),_vcList2 = _vcList1
		)
	),
	updateVCListAdot(_lits,_vcList2,_vcList).
updateVCListAdot([_|_lits],_vcListIn,_vcList) :-
	updateVCListAdot(_lits,_vcListIn,_vcList).
%  ------------------------------------------------------------------
%  replaceAsWithAdots
%  Input: literal sequence
% 	    list of the constants
% 	    list of the variables with their classes
%  Output: literal sequence in which A literals (if possible) are
% 	    replaced by Adot literals
%
%  ------------------------------------------------------------------

replaceAsWithAdots([],_,_,[]).
replaceAsWithAdots(['A'(_x,_l,_y)|_lits],_const,_varsWithClasses,['Adot'(_cc,_x,_y)|_newLits]) :-
	%  label must be constant

	memberchk(_l,_const),
	%  Find all objects with label _l

	findall(_ccCand,(qo_prove_literal('Label'(_ccCand,_l))),_ccList),
	%  find the possible concerned classes

	filterConcernedClass('A'(_x,_l,_y),_ccList,_const,_varsWithClasses,_ccListTemp),
	_ccListTemp \== [],
	_ccListTemp = [_ccCand|_otherCCs],!,
	%  the most specific concerned class is chosen

	findMostSpecialAttrCat(_otherCCs,_ccCand,_cc),
	replaceAsWithAdots(_lits,_const,_varsWithClasses,_newLits).
replaceAsWithAdots([_lit|_lits],_const,_vars,[_lit|_newLits]) :-
        acceptableInQueryConstraint(_lit),  % 24-Jun-2004/M.Jeusfeld
	replaceAsWithAdots(_lits,_const,_vars,_newLits).
%  24-Jun-2004/M.Jeusfeld
%  We normally do not tolerate a literal A(x,m,y) in the COMPILED code for a
%  query constraint (like we don't accept it for other formulas). However,
%  if the flag forceConcernedClass is switched off, we still accept it for
%  backward compatibility with older ConceptBase versions.

acceptableInQueryConstraint('A'(_x,_m,_y)) :-
  get_cb_feature(forceConcernedClass,'strict'),
  increment('error_number@F2P'),
  !,
  fail.
acceptableInQueryConstraint(_lit).
%  ------------------------------------------------------------------
%
%  filterConcernedClass:
%  for the set of attributes with the given label it is tested
%  whether they qualify as concerned class
%
%  ------------------------------------------------------------------

filterConcernedClass(_,[],_,_,[]).
filterConcernedClass('A'(_x,_l,_y),[_cc|_ccCands],_const,_varsWithClasses,[_cc|_ccList]) :-
	%  read source class

	getSource(_cc,_sc),
	(
		(
			%  _x is constant and source class is a class
			% 			   of _x
			%

	 		memberchk(_x,_const),
			qo_prove_literal('In'(_x,_sc))
		);
		(
			%  _x is variable and source class is a class of _x
			% 				or a specialization/generalization of one of these
			% 				classes
			%

			select(_x-_classesX,_varsWithClasses,_),
			(
				(memberchk(_sc,_classesX));
				(listContainsRealSubClass(_sc,_classesX));
				(listContainsRealSuperClass(_sc,_classesX))
			),!
		)
	),
	%  Target class: analogous procedure

	getDest(_cc,_dc),
	(
		(
			%  _y is constant and destination class is a class
			% 			   of _y
			%

	 		memberchk(_y,_const),
			qo_prove_literal('In'(_y,_dc))
		);
		(
			%  _y is variable and destination class is a class of _y
			% 				or a specialization/generalization
			% 				of one of these classes
			%

			select(_y-_classesY,_varsWithClasses,_),
			(
				(memberchk(_dc,_classesY));
				(listContainsRealSubClass(_dc,_classesY));
				(listContainsRealSuperClass(_dc,_classesY))
			),!
		)
	),!,
	filterConcernedClass('A'(_x,_l,_y),_ccCands,_const,_varsWithClasses,_ccList).
filterConcernedClass('A'(_x,_l,_y),[_|_ccCands],_const,_vars,_ccList) :-
	filterConcernedClass('A'(_x,_l,_y),_ccCands,_const,_vars,_ccList).
% ***************************************************************
%
%  removeRedundantInLitsForFunctions(_lits,_alllits,_olits)
%
%  Description of arguments:
%     lits : list of the literals still to be considered
%  alllits : list of all literals of this rule
%    olits : Reduced list without redundant literals
%
%  Description of predicate:
%   Removes In literals for variables that appear as the result of a
%   function call.
% ***************************************************************

removeRedundantInLitsForFunctions([],_alllits,[]).
removeRedundantInLitsForFunctions(['In'(_x,_c)|_lits],_alllits,_olits) :-
	isConst(_c),
	pc_member(_lit,_lits),
	_lit =.. [_fid,_x|_args],
	id2name(_fid,_),
	name2id('Function',_funcid),
	prove_literal('In'(_fid,_funcid)),
	!,
	removeRedundantInLitsForFunctions(_lits,_alllits,_olits).
removeRedundantInLitsForFunctions([_lit|_lits],_alllits,[_lit|_olits]) :-
	removeRedundantInLitsForFunctions(_lits,_alllits,_olits).
%  ------------------------------------------------------------------
%
%  removeRedundantInLits
%  Those through implicit class binding through Adot-literals
%  redundant In-literals are removed
%
%  ------------------------------------------------------------------

removeRedundantInLits(_litsIn,_vars,_litsOut) :-
	getVarClassesAdot(_vars,_litsIn,_varClasses),
	testRedundantIns(_litsIn,_varClasses,[],_litsOut).

testRedundantIns([],_,_,[]).
%  In-literals for Label/TransactionTime remove

testRedundantIns(['In'(_x,_c)|_lits],_varClasses,_rlits,_litsOut) :-
	isConst(_c),
	name2id('TransactionTime',_ttid),
	name2id('Label',_lid),
	(_c == _ttid; _c == _lid),
	!,
	testRedundantIns(_lits,_varClasses,_rlits,_litsOut).
testRedundantIns(['In'(_x,_c)|_lits],_varClasses,_rlits,_litsOut) :-
	isConst(_c),
	select(_x-_classes,_varClasses,_),
	listContainsSubClass(_c,_classes),!,
	testRedundantIns(_lits,_varClasses,_rlits,_litsOut).
testRedundantIns(['In'(_x,_c)|_lits],_varClasses,_rlits,_litsOut) :-
	isConst(_c),
	name2id('Proposition',_pid),
    _c == _pid,
    (pc_member(_l,_lits);pc_member(_l,_rlits)),
    _l =.. [_|_args],
	pc_member(_x,_args),
	!,
	testRedundantIns(_lits,_varClasses,_rlits,_litsOut).
testRedundantIns([_l|_lits],_varClasses,_rlits,[_l|_litsOut]) :-
	testRedundantIns(_lits,_varClasses,[_l|_rlits],_litsOut).
% ================= fixMinArgs ========================================
% --------------------------------------------------------------------
%  the rule set passed to the query optimizer is like
%  is preprocessed as follows:
%
%  For certain intensionally defined literals the number of
%  arguments is minimized. In the rule head only such arguments appear
%  that are actually used in the rule bodies.
%  Reason: with n arguments, 2^n different binding patterns must
%  be stored for the costs.
%
% --------------------------------------------------------------------

fixMinArgRuleSet(_ruleSetIn,_ruleSetOut) :-
	buildRuleTermList(_ruleSetIn,_ruleTermList),
	fixMinArgList(_ruleTermList,_ruleTermListOut),
	ruleTermList2ConjunctList(_ruleTermListOut,_ruleSetOut).
% --------------------------------------------------------------------
%
%  buildRuleTermList:
%  the input rule set is split into a list of terms of the form
%  rule(<head-literal>,<rule-body>), with the rule body represented
%  as a list of literals.
%
% --------------------------------------------------------------------

buildRuleTermList([],[]).
buildRuleTermList([(_head :- _tail)|_ruleSetIn],[rule(_head,_bodyLits)|_ruleTermList]) :-
	'Conjunct2List'(_tail,_bodyLits),
	buildRuleTermList(_ruleSetIn,_ruleTermList).

ruleTermList2ConjunctList([],[]).
ruleTermList2ConjunctList([rule(_head,_bodyLits)|_ruleTermList],[(_head :- _tail)|_ruleSetOut]) :-
	'List2Conjunct'(_bodyLits,_tail),
	ruleTermList2ConjunctList(_ruleTermList,_ruleSetOut).
% --------------------------------------------------------------------
%
%  minimizeArgumentList:
%  in the input rule set the argument lists of the
%  system-generated intensionally defined literals are not minimal
%  The argument lists contain not only the variables that are
%  used in the various rule bodies.
%
%  minimizeArgumentList reduces the arguments of the literals to those
%  that are really needed.
%
%  This predicate may only be applied to temporary rules produced by
%  the query translator. Furthermore it must be ensured that at least
%  one argument remains for each literal.
% --------------------------------------------------------------------

testMinArgList :-
	_ruleList =
		[
		rule(a('_b','_c','_d'),[a('_a','_b','_c'),b('_a','_b','_d')]),
		rule(b('_a','_b','_c'),[a('_a','_b','_b')])
		],
	testMinArgList(_ruleList).
testMinArgList(_ruleListIn) :-
	minimizeArgumentList(_ruleListIn,_ruleList),
	_ruleList \== _ruleListIn,!,
	testMinArgList(_ruleList).
testMinArgList(_ruleList).

fixMinArgList(_ruleListIn,_ruleListOut) :-
	minimizeArgumentList(_ruleListIn,_ruleList),
	_ruleList \== _ruleListIn,!,  % fixed point not yet reached
	fixMinArgList(_ruleList,_ruleListOut).
fixMinArgList(_ruleList,_ruleList).

minimizeArgumentList(_ruleListIn,_ruleListOut) :-
	buildArgumentMasks(_ruleListIn,_headMasks),
	checkArgumentsInRules(_ruleListIn,_headMasks,_ruleListOut).
% --------------------------------------------------------------------
%
%  buildArgumentMasks
%  For each head literal a mask is determined. This list
%  contains for each argument position a "1" when the argument
%  is needed, otherwise a "0".
%
%  First, all rule remnants of a head literal are determined.
%  If a variable from the rule head appears in a rule body, then
%  it is needed. If it does not appear, it has no influence
%  on the calculation result.
%
%  Two cases must be distinguished:
%  a) if besides the rules in the given rule set there are additional
%     rules in which the head literal can appear in the body, then
%     its arity must not be changed. Examples:
%     In literals, Adot literals, top-level literals of queries
%
%  b) the first case does not apply exactly when the head literal
%  represents a sub-rule produced by the translator. Then
%     all occurrences of the literal in the given rule
%     set are contained and the arity can be changed.
%
% --------------------------------------------------------------------

buildArgumentMasks([],[]).
buildArgumentMasks([rule(_head,_bodyLits)|_ruleTermListIn],[newHead(_functor,_headMask)|_newHeads]) :-
	_head =.. [_functor|_],
	findRulesForHead(_head,_ruleTermListIn,_otherRules,_remRules),
	findArgumentMaskForHead([rule(_head,_bodyLits)|_otherRules],_headMask),
	buildArgumentMasks(_remRules,_newHeads).
% --------------------------------------------------------------------
%
%  findRulesForHead:
%  Input: head literal l
%           rule set  r
%  Output: Set 1: All rules from r with head literal l
%           Set 2: all other rules from r
%
% --------------------------------------------------------------------

findRulesForHead(_,[],[],[]).
findRulesForHead(_head,[rule(_head,_literals)|_rtListIn],[rule(_head,_literals)|_rtListHead],_otherRules) :-
	!,
	findRulesForHead(_head,_rtListIn,_rtListHead,_otherRules).
findRulesForHead(_head,[rule(_otherHead,_literals)|_rtListIn],_rtListHead,[rule(_otherHead,_literals)|_otherRules]) :-
	findRulesForHead(_head,_rtListIn,_rtListHead,_otherRules).
% --------------------------------------------------------------------
%
%  findArgumentMaskForHead
%  Input: rule set for one head literal
%  Output: mask for the arguments of the head literal
%
%  For each rule body it is determined which variable arguments
%  of the head literal are used in the body. If a variable is
%  used in no rule body, the calculation result is independent
%  of the binding of this variable.
%
%  This information is encoded per rule body with a mask that
%  for each argument of the head literal contains the following
%  entries:
%
%  1: argument is a constant or
%     argument is a variable and appears in the body
%  0: argument is a variable and does not appear in the body
%
%  The masks of the rule remnants are then combined with or.
%  If all entries are 0, the first argument alone is marked as
%  still needed for safety reasons. This prevents literals without
%  arguments from occurring.
%
% --------------------------------------------------------------------

findArgumentMaskForHead(_ruleList,_newHeadMask) :-
	buildHeadMaskList(_ruleList,_headMaskList),
	orMaskList(_headMaskList,_newHeadMask1),
	ensureAtLeastOneArg(_newHeadMask1,_newHeadMask),!.

buildHeadMaskList([],[]).
buildHeadMaskList([_ruleTerm|_ruleTerms],[_mask|_maskList]) :-
	buildHeadMaskForRule(_ruleTerm,_mask),
	buildHeadMaskList(_ruleTerms,_maskList).

buildHeadMaskForRule(rule(_head,_literals),_headMask) :-
	dynamicArgumentList(_head),!,
	getVarsList(_literals,_varsInLits),
	_head =.. [_|_argsHead],
	buildHeadMask(_argsHead,_varsInLits,_headMask).
buildHeadMaskForRule(rule(_head,_literals),_headMask) :-
	_head =.. [_|_argsHead],
	setAllOne(_argsHead,_headMask).

buildHeadMask([],_,[]).
buildHeadMask([_argInHead|_argsInHead],_varsInLits,[1|_mask]) :-
	isConst(_argInHead),!,
	buildHeadMask(_argsInHead,_varsInLits,_mask).
buildHeadMask([_argInHead|_argsInHead],_varsInLits,[1|_mask]) :-
	memberchk(_argInHead,_varsInLits),!,
	buildHeadMask(_argsInHead,_varsInLits,_mask).
buildHeadMask([_argInHead|_argsInHead],_varsInLits,[0|_mask]) :-
	buildHeadMask(_argsInHead,_varsInLits,_mask).

dynamicArgumentList(_head) :-
	_head =.. [_functor|_],
	pc_atomprefix('ID_',3,_functor),!.

ensureAtLeastOneArg(_mask,[1]) :-
	allNull(_mask),!.
ensureAtLeastOneArg(_mask,_mask).
% --------------------------------------------------------------------
%
%  checkArgumentsInRules
%  Input: rule set
%           masks for the head literals
%  Output: reduced rules
%
%  The masks created for the head literals are applied to the
%  supplied rule set. All arguments marked with "0" are
%  hidden.
%
% --------------------------------------------------------------------

checkArgumentsInRules([],_,[]).
checkArgumentsInRules([rule(_head,_literals)|_ruleListIn],_headMasks,[rule(_newHead,_newLiterals)|_ruleListOut]) :-
	applyMasksToLits([_head],_headMasks,[_newHead]),
	applyMasksToLits(_literals,_headMasks,_newLiterals),
	checkArgumentsInRules(_ruleListIn,_headMasks,_ruleListOut).

applyMasksToLits([],_,[]).
applyMasksToLits([not(_lit)|_lits],_headMasks,[not(_newLit)|_newLits]) :-
	_lit =.. [_functor|_args],
	select(newHead(_functor,_mask),_headMasks,_),!,
	applyMask(_args,_mask,_newArgs),
	_newLit =.. [_functor|_newArgs],
	applyMasksToLits(_lits,_headMasks,_newLits).
applyMasksToLits([_lit|_lits],_headMasks,[_newLit|_newLits]) :-
	_lit =.. [_functor|_args],
	select(newHead(_functor,_mask),_headMasks,_),!,
	applyMask(_args,_mask,_newArgs),
	_newLit =.. [_functor|_newArgs],
	applyMasksToLits(_lits,_headMasks,_newLits).
applyMasksToLits([_lit|_lits],_headMasks,[_lit|_newLits]) :-
	applyMasksToLits(_lits,_headMasks,_newLits).
% ================= fixMinArgs Ende ===================================
% ================= preOptimize Ende ==================================
% --------------------------------------------------------------------
%
%  initOptStructures
%  Initialize the variable tables of the query optimizer
%  Table 1: vartab of the range form
%  Table 2: internal table of the optimizer
% --------------------------------------------------------------------

initOptStructures(_vartab) :-
	removeRFVartab,
	storeRFVartab(_vartab),
	cleanVT.
% --------------------------------------------------------------------
%
%  preprocRuleList:
%  Preprocessing of the passed to the query optimizer
%  rule set
%
% --------------------------------------------------------------------

preprocRuleList(_ruleSetIn,_ranges,_ruleSetOut) :-
	%  further steps still to be implemented:
	%  * heuristic for handling recursive dependencies
	%  * arrangement of the rules so that the costs of intensionally
	%    defined predicates are determined before they
	%    occur in the rule body

	orderRuleSet(_ruleSetIn,_ruleSetOut).
% --------------------------------------------------------------------
%
%  preprocRule:
% 	a single rule passed to the query optimizer
%       Datalog rule is prepared
% 	preprocessed
%
%  Input: 	rule term
% 		variable table of the parser
%  Output:	head literal
% 		literal list of the literals in the body
%
%  Steps:
% 		complete A to Adot replacement
% 		for parameterized queries:
% 		  In with class variable:
% 		  replace by constant
% 		remove redundant literals
% 		early reduction for negated literals
%
%
% --------------------------------------------------------------------

preprocRule((_head :- _ruleTerm),_head,_literals) :-
	'Conjunct2List'(_ruleTerm,_lits1),
	getParamIns((_head :- _ruleTerm),_paramIns),
	replaceParamIns(_lits1,_paramIns,_lits2),
	applyLitFilters(_lits2,_literals,
                        [cleanLiterals,earlyRedNegPre,transformFunctionCalls]),
        !.
%  Ticket #176: Replace (x in F(y)) by (x = F(y))
%  Note that the In-Predicate is replaced internally by F(x,y)

transformFunctionCalls([],[]) :- !.
transformFunctionCalls([_funcall|_restlits],[_newfuncall|_newrestlits]) :-
   isFunctionLit(_funcall),
   _funcall =.. [_funid,_x|_args],
   _newfuncall =.. ['EQ',_x,_funcall],
   transformFunctionCalls(_restlits,_newrestlits).
transformFunctionCalls([_otherlit|_restlits],[_otherlit|_newrestlits]) :-
   transformFunctionCalls(_restlits,_newrestlits).
% --------------------------------------------------------------------
%
%  postprocRule:
% 	the Datalog rule passed to the query optimizer is
% 	postprocessed
%
%  Steps:
% 	* restore In literals with class variable for parameter queries
% 	* re-insert negated literals removed by early reduction
%
% --------------------------------------------------------------------

postprocRule(_literals,_head,(_head :- _ruleTerm)) :-
    restoreParamIns(_literals,_lits1),
    removeBoundParamIns(_head,_lits1,_ilits),
    applyLitFilters(_ilits,_olits,
                    [earlyRedNegPost,
                     moveBackInLits,
                     guardComplexQueryParameters,
                     removeInsOfFunctionResult,
                     preferGoodLitsDatalog,  % use a heuristic from ticket #292 here as well
                     moveUnifiesForward,
                     move_EQ_Forward,  % ticket #175
                     move_FromTo_Forward,
                     moveBoundForward  % ticket #147
                    ]),
%     WriteTrace(veryhigh,QO_preprec,['Postprocessing --> ',idterm(_olits)]),

    'List2Conjunct'(_olits,_ruleTerm),
    !.
%  For some reason, the ConceptBase re-inserts literals In(x,class)
%  where x is already bound by a function call F(x,...) in a
%  literal list. This is at least the case when F(x,...) is a
%  complex query call.If F is a function, e.g. computing some
%  arithmetic expression, the In(x,class) is not satisfiable since
%  the object x is created on the fly. So, if we have a literal list
%  [In(x,class),...,F(x,...),...] and class is the range of F, then
%  we can remove In(x,class) from the literal list.
%  This is aprt of the solution of ticket #122.

removeInsOfFunctionResult([],[]) :- !.
removeInsOfFunctionResult(['In'(_x,_class)|_rest],_rest) :-
  is_id(_class),  % _class is a constant, not a variable
  pc_member(_Flit,_rest),  % there is some literal _Flit in _rest
  isFunctionLit(_Flit),  % and it is a function call ...
  _Flit =.. [_fun|[_x|_args]], 
  prove_literal('Isa_e'(_fun,_class)),  % and the class is the range of the function
  !.
%  then we abolish In(_x,_class).
%
% {* otherwise, we keep it and proceed with the rest

removeInsOfFunctionResult([_lit|_rest],[_lit|_restcleaned])   :-
  removeInsOfFunctionResult(_rest,_restcleaned).
%  predicates like In(p,c) can be removed from the body of queries
%  if the are required parameter, i.e. bound(p) is in the body. Such
%  queries/functions cannot specialize parameters. They can only
%  substitute them. Ticket #290.

removeBoundParamIns(_head,_lits,_newlits) :-
  _head =.. [_fun,_thisarg|_restargs],
  is_id(_fun),
  !,
  doremoveBoundParamIns(_restargs,_lits,_newlits).
removeBoundParamIns(_head,_lits,_lits).

doremoveBoundParamIns([],_lits,_lits).
doremoveBoundParamIns([_param,_class|_rest],_lits,_newlits) :-
  pc_member(bound(_param),_lits),  % so param:class is a parameter definition of the query/function
  delete('In'(_param,_class),_lits,_lesslits),
  'WriteTrace'(veryhigh,'QO_preproc',['In'(_param,_class),' inserted for a required parameter is redundant.']),
  doremoveBoundParamIns(_rest,_lesslits,_newlits).
doremoveBoundParamIns([_param,_class|_rest],_lits,_newlits) :-
  doremoveBoundParamIns(_rest,_lits,_newlits).
%  never fail

doremoveBoundParamIns(_,_lits,_lits).
% --------------------------------------------------------------------
% 		Handling of parameters:
% 			The current class of a parameter
% 			is syntactically a variable that is
% 			always bound at call time.
% 			This variable is replaced for optimization
% 			by the default class of the parameter.
%  After optimization the replacement is
%  undone again.
% --------------------------------------------------------------------

getParamIns((_head :- _body),_inLits) :-
		get_pattern(_head,_pattern,_parclasslist),
		get_in_with_parclass(_parclasslist,_body,_inLits,_),!.
getParamIns(_,[]) :- !.

replaceParamIns(_litsIn,_paramIns,_litsOut) :-
	replaceParamIns1(_paramIns,_litsIn,_litsOut,_replaced),
	pc_rerecord('QOTemp_paramIns',_replaced),!.

replaceParamIns1([],_lits,_lits,[]).
replaceParamIns1(['In'(_x,_c)|_inLits],_litsIn,_lits,['In'(_x,_class)-'In'(_x,_c)|_replaced]) :-
	select('In'(_x,_c),_litsIn,_litsRem),
	getClassFromRFVT(_x,_class),
	replaceParamIns1(_inLits,['In'(_x,_class)|_litsRem],_lits,_replaced).

restoreParamIns(_litsIn,_litsOut) :-
	pc_recorded('QOTemp_paramIns',_replaced),
	restoreParamIns1(_replaced,_litsIn,_litsOut).

restoreParamIns1([],_lits,_lits).
restoreParamIns1(['In'(_x,_class)-'In'(_x,_c)|_paramIns],_litsIn,_lits) :-
	exchangeLits(_litsIn,'In'(_x,_class),'In'(_x,_c),_litsNew),
	restoreParamIns1(_paramIns,_litsNew,_lits).

exchangeLits([_lit1|_lits],_lit1,_lit2,_lits2) :-
	moveToNextLitWithSameVariable(_lit2,[],_lits,_lits2).
exchangeLits([_l|_lits],_lit1,_lit2,[_l|_newLits]) :-
	_l \== _lit1,
	exchangeLits(_lits,_lit1,_lit2,_newLits).

moveToNextLitWithSameVariable(_lit,_lits,[],_lits2) :-
    !,
    append(_lits,[_lit],_lits2).
moveToNextLitWithSameVariable(_lit,_processedLits,[_firstLit|_rest],_lits2) :-
    _lit = 'In'(_x,_c),
    _firstLit =.. [_f|_args],
    pc_member(_x,_args),
    !,
    append(_processedLits,[_lit|[_firstLit|_rest]],_lits2).
moveToNextLitWithSameVariable(_lit,_processedLits,[_firstLit|_rest],_lits2) :-
    !,
    append(_processedLits,[_firstLit],_moreLits),
    moveToNextLitWithSameVariable(_lit,_moreLits,_rest,_lits2).
% ============== order_rules  ========================================

orderRuleSet(_ruleSetIn,_ruleSet) :-
	buildRuleTermList(_ruleSetIn,_ruleTermList),
	fixMinArgList(_ruleTermList,_ruleTermListOut),
	_ruleSet = _ruleSetIn.
% ===========================================================
%  get_in_with_parclass(_vars,_lits,_inlits,_restlits)
%  Extract from lits the In literals whose second
%  argument is an element from _vars. These In literals
%  are returned in _inlits, the rest in _restlits.
% ===========================================================

get_in_with_parclass([],_body,[],_body).
get_in_with_parclass(_list,('In'(_x,_c),_body),['In'(_x,_c)|_rins],_newbody) :-
	pc_member(_c,_list),
	delete(_c,_list,_rlist),
	get_in_with_parclass(_rlist,_body,_rins,_newbody).
get_in_with_parclass(_list,'In'(_x,_c),['In'(_x,_c)],true) :-
	pc_member(_c,_list).
get_in_with_parclass(_list,(_lit,_rlits),_ins,_newlits) :-
	get_in_with_parclass(_list,_rlits,_ins,_new),
  	((_new == true,
	  _newlits = _lit
	 );
	 (_new \== true,
	  _newlits = (_lit,_new)
	 )
	).
get_in_with_parclass(_list,_lit,[],_lit) :-
	_lit \= (_,_).
% ===========================================================
%  Move In literals with attribute or Proposition to the
%  back if the variable also appears elsewhere.
%  Common case for system queries (find_....)
% ===========================================================

moveBackInLits(_input,_output) :-
    moveBackInLits2(_input,[],[],_output).

moveBackInLits2([],_goodlits,_badlits,_alllits) :-
    append(_goodlits,_badlits,_alllits),
    !.
moveBackInLits2(['In'(_x,_c)|_restlits],_goodlits,_badlits,_alllits) :-
    isVar(_x),
    isVar(_c),
    %  In(_x,_c) must not be a literal for parameter binding.

    pc_recorded('QOTemp_paramIns',_paramIns),
    not(pc_member('In'(_x,_class)-'In'(_x,_c),_paramIns)),
    pc_member(_lit,_restlits),  % does the variable appear elsewhere?
    _lit =.. [_f|_vars],
    pc_member(_x,_vars),
    !,
    append(_badlits,['In'(_x,_c)],_badlits2),
    moveBackInLits2(_restlits,_goodlits,_badlits2,_alllits).
moveBackInLits2(['In'(_x,_c)|_restlits],_goodlits,_badlits,_alllits) :-
    isConst(_c),
    isVar(_x),
    id2name(_c,_n),
    pc_member(_n,['Proposition',attribute]),
    pc_member(_lit,_restlits),  % does the variable appear elsewhere?
    _lit =.. [_f|_vars],
    pc_member(_x,_vars),
    !,
    append(_badlits,['In'(_x,_c)],_badlits2),
    moveBackInLits2(_restlits,_goodlits,_badlits2,_alllits).
moveBackInLits2([_lit|_restlits],_goodlits,_badlits,_alllits) :-
    append(_goodlits,[_lit],_goodlits2),
    moveBackInLits2(_restlits,_goodlits2,_badlits,_alllits).
%  7-Jul-2004/M.Jeusfeld: Make sure that variables in complex query calls
%  are bound by In(var,c), if such a literal In(var,c) exists in the
%  formula.
%  19-Jul-2007/M.Jeusfeld: we need to introduce a monster loop, since a
%  binding literal may itself require a guard. See also ticket #142.
%  Maximal depth is used to limit the recursion level; this is potentially
%  leading to incomplete reshufflings but we want to exclude infinite loops.
%  A value of 1000 should be sufficient even for very complex inputlists.

guardComplexQueryParameters(_inputlits,_outputlits) :-
  do_guardComplexQueryParameters(1000,_inputlits,_outputlits),
  !.
%  never fail; should never occur

guardComplexQueryParameters(_lits,_lits) :-
  write('!!! Forbidden clause of guardComplexQueryParameters in QO_preproc.pro executed.'),nl,
  write('!!! Inform ConceptBase development team!'),nl.
%  empty literal lists do not require reshuffling of literals

do_guardComplexQueryParameters(_,[],[]) :- !.
%  stop computation, when we reached the minimum level.

do_guardComplexQueryParameters(0,_list,_list) :- 
  write('!!! guardComplexQueryParameters in QO_preproc.pro exited due to possible endless loop.'),
  write('!!! The generated code may be incorrect. Inform ConceptBase development team!'),
  nl,
  !. 
%  reshuffle once and then proceed depending on whether insertlits is empty or not

do_guardComplexQueryParameters(_level,[_complexQlit|_rest],_outputlits) :-
  requiresGuard(_complexQlit),
  reshuffleOnQlit(_complexQlit,_rest,_insertlits,_taillits),
  proceedGuarding(_level,_insertlits,_complexQlit,_taillits,_outputlits),
  !.
%  if the _lit does not require a guard, we proceed

do_guardComplexQueryParameters(_level,[_lit|_rest],[_lit|_outputlits]) :-
  _newlevel is _level-1,
  do_guardComplexQueryParameters(_newlevel,_rest,_outputlits),
  !.
%  never fail; should never occur

do_guardComplexQueryParameters(_,_lits,_lits) :-
  write('!!! Forbidden clause of do_guardComplexQueryParameters in QO_preproc.pro executed.'),nl,
  write('!!! Inform ConceptBase development team!'),nl.
%  if _insertlits=[], we can proceed with _taillits

proceedGuarding(_level,_insertlits,_complexQlit,_taillits,_outputlits) :-
  _insertlits=[],
  !,
  _newlevel is _level-1,
  do_guardComplexQueryParameters(_newlevel,_taillits,_outputlits1),
  append([_complexQlit],_outputlits1,_outputlits),
  !.
%  otherwise, we need to do a monster iteration

proceedGuarding(_level,_insertlits,_complexQlit,_taillits,_outputlits) :-
  _newlevel is _level-1,
  do_guardComplexQueryParameters(_newlevel,_taillits,_outputlits1),
  append(_insertlits,[_complexQlit],_lits1),
  append(_lits1,_outputlits1,_outputlits_sofar),
  do_guardComplexQueryParameters(_newlevel,_outputlits_sofar,_outputlits),  % monster iteration
  !.
%  the following types of literal require their variables to be bound by a 'guarding' literal

requiresGuard(_lit) :-
  isComplexQlit(_lit);
  isComplexComparisonLit(_lit);  % also take care when a comparison literal contains functional args
  isProperComparisonLit(_lit);  % also take care of proper comparison literals, ticket #77
  isFunctionLit(_lit);  % also take care of normal function queries, ticket #122
  isWeakAuxLit(_lit).  % also take care of  weak auxiliary literals, ticket #125
%  find in _restlits those _insertlits that need be be placed
%  before _complexQlit. The remainder is in _taillits

reshuffleOnQlit(_complexQlit,_restlits,_insertlits,_taillits) :-
  save_setof(_var,'IsComplexVar'(_var,_complexQlit),_complexVars), 
  processVarBindings(_complexVars,_restlits,_insertlits,_taillits),
  !.

processVarBindings(_complexVars,_restlits,_insertlits,_taillits) :-
  do_processVarBindings(_complexVars,_restlits,_taillits,[],_insertlits),
  !.

do_processVarBindings([],_sofarTail,_sofarTail,_sofarInsert,_sofarInsert) :- !.
do_processVarBindings([_var|_restvars],_sofarTail,_tail,_sofarInsert,_insert) :-
  foundVarBinding(_var,_sofarTail,_newsofarTail,_inLit),
  !,
  append(_sofarInsert,[_inLit],_newsofarInsert),
  do_processVarBindings(_restvars,_newsofarTail,_tail,_newsofarInsert,_insert).
do_processVarBindings([_var|_restvars],_sofarTail,_tail,_sofarInsert,_insert) :-
   do_processVarBindings(_restvars,_sofarTail,_tail,_sofarInsert,_insert).
%  we try to find a good binding literal for the variable _var

foundVarBinding(_var,[_badLit|_restl],[_badLit|_rest2],_bindLit) :-
  badBindingLit(_badLit),  % this is not a good binding lit
  foundVarBinding(_var,_rest1,_rest2,_bindLit),  % first try if we find a better one
  !.
%  if _bindLit is good or we didn't find a better one before
%  then we take it.

foundVarBinding(_var,[_bindLit|_restTail],_restTail,_bindLit) :-
  matchVarBind(_var,_bindLit),
  !.
%  if the first candidate did not qualify, search in _rest1 for a candidate

foundVarBinding(_var,[_someLit|_rest1],[_someLit|_rest2],_bindLit) :-
  foundVarBinding(_var,_rest1,_rest2,_bindLit).
%  19-Jul-2007/M.Jeusfeld: EQ and UNIFIES can bind variables as well
%  if the variables is one of the arguments of EQ/UNIFIES.
%  This is necessary for a full support of EQ/UNIFIES.
%  See also ticket #142.

matchVarBind(_x,'EQ'(_x1,_x2)) :-
  (_x=_x1;_x=_x2),
  !.
matchVarBind(_x,'UNIFIES'(_x1,_x2)) :-
  (_x=_x1;_x=_x2),
  !.
matchVarBind(_x,_bindLit) :-
  \+ isComparisonLit(_bindLit),  % other comparison literals like LT have no binding power
  \+ isComplexComparisonLit(_bindLit),  % same with complex comparison literals
  _bindLit =.. [_fun|_args],
  memberchk(_x,_args),  
  !.
%  a bad binding literal would be for example In(x,Integer) because such an x
%  might have to be computed by an agrregate function like SUM/COUNT etc.

badBindingLit('In'(_x,_c))  :-
  is_id(_c),
  name2id('BuiltinClass',_BuiltinClassId),  % this has Integer,Real,String as instances
  prove_edb_literal('In_e'(_c,_ClassOfC)),
  prove_edb_literal('In_e'(_ClassOfC,_BuiltinClassId)),
  !.
%  also treat comparison literals which have functionals args
%  see also ticket #46, 26-Jan-2005/M.Jeusfeld

'IsComplexVar'(_var,_complexQlit) :-
  isComplexComparisonLit(_complexQlit),
  _complexQlit =.. [_qid|_args],  % both args can be query literals
  findall(_qlit,(pc_member(_qlit,_args),isQlit(_qlit)),_qlits),
  scanComplexVar(_var,_qlits).
%  28-Sep-2005: take care of normal comparison lits as well
%  see also ticket #77

'IsComplexVar'(_var,_complit) :-
  isComparisonLit(_complit),
  _complit =.. [_qid,_arg1,_arg2],
  scanComplexVar(_var,[_arg1,_arg2]).
%  10-Oct-2006/M.Jeusfeld: also take care of function literals
%  Their arguments need to be bound as well, ticket #122

'IsComplexVar'(_var,_funlit) :-
  isFunctionLit(_funlit),
  _funlit =.. [_qid|[_thisvar|_args]],
  scanComplexVar(_var,_args).
'IsComplexVar'(_var,_complexQlit) :-
  compound(_complexQlit),
  _complexQlit =.. [_qid|[_thisvar|_args]],  % first arg is the place for the '~this' variable
  findall(_qlit,(pc_member(_qlit,_args),isQlit(_qlit)),_qlits),
  scanComplexVar(_var,_qlits).
%  this case is new for ticket #125

'IsComplexVar'(_var,_complexQlit) :-
  isWeakAuxLitCandidate(_complexQlit,_fun,_args),
  scanComplexVar(_var,_args).

simpleVar(_x) :-
  atom(_x),
  pc_atomprefix('_',1,_x),
  !.

scanComplexVar(_x,_x) :-
  simpleVar(_x),
  !.
scanComplexVar(_var,[_arg|_rest]) :-
  scanComplexVar(_var,_arg).
scanComplexVar(_var,[_|_rest]) :-
  scanComplexVar(_var,_rest),
  !.
scanComplexVar(_var,_term) :-
  compound(_term),
  _term =.. [_qid|[_thisvar|_args]],
  is_id(_qid), 
  scanComplexVar(_var,_args).

isComplexQlit(_lit) :-
  compound(_lit),
  _lit =.. [_qid|_args],
  is_id(_qid),
  pc_member(_otherLit,_args),
  isQlit(_otherLit),
  !.
%  26-Jan-2005/M.Jeusfeld: check wether _lit is a comparison literal whose args are
%  function expressions like produced from (COUNT[Person/class] > 1)

isComplexComparisonLit(_lit) :-
  _lit =.. [_fun,_op1,_op2],
  memberchk(_fun,['EQ','NE','LT','GT','LE','GE']),
  (
  isQlit(_op1);
  isQlit(_op2)
  ),
  !.
%  _lit is a normal comparison literal

isComparisonLit(_lit) :-
  _lit =.. [_fun,_op1,_op2],
  memberchk(_fun,['EQ','NE','LT','GT','LE','GE']),
  (simpleVar(_op1);is_id(_op1)),
  (simpleVar(_op2);is_id(_op2)),
  !.
%  _lit is a proper comparison literal, i.e. excluding EQ

isProperComparisonLit(_lit) :-
  _lit =.. [_fun,_op1,_op2],
  memberchk(_fun,['NE','LT','GT','LE','GE']),
  (simpleVar(_op1);is_id(_op1)),
  (simpleVar(_op2);is_id(_op2)),
  !.
%  _lit is a literal calling a function

isFunctionLit(_lit) :-
   _lit =.. [_fun|_],
   is_id(_fun),
   prove_edb_literal('In_e'(_fun,id_106)),  % id_106=Function
   !.
isFunctionLit(_lit,_fun) :-
   _lit =.. [_fun|_],
   is_id(_fun),
   prove_edb_literal('In_e'(_fun,id_106)),  % id_106=Function
   !.

isQlit(_lit) :-
  compound(_lit),
  _lit =.. [_qid|_args],
  _args \== [],
  is_id(_qid), 
  !.
%  15-Nov-2006/M.Jeusfeld
%  A weak auxiliary literal is a literal of the form ID_<digits>(_x1,_x2,...)
%  where some variable _xi is occurring in a literal of the rule body  in
%  which it is expected to be bound.
%  If the literal in the rule body requires the variable _xi to be bound, then
%  we should rearrange the order of literals in the calling rule in such a
%  way that _xi is bound.
%
%  Example:
%
%   Rule 1:   lit1(...) :-  ID_1234(_x),In(_x,_c).
%   Rule 2:   ID_1234(_x) :- GE(_x,100).
%
%  Here, the call of ID_1234(_x) in rule 1 has a free variable _x. If the
%  call is matched against rule 2, then the comparison literal GE(_x,100) is
%  called with a free variable _x. This is not allowed and leads to wrong
%  results. If we however re-arrange the rules as follows:
%
%   Rule 1:   lit1(...) :-  In(_x,_c),ID_1234(_x).
%   Rule 2:   ID_1234(_x) :- GE(_x,100).
%
%  then _x will be bound before ID_1234(_x) is called. So effectively, the
%  auxiliary literal ID_1234 has to be treated like the other literals
%  requiring a guard (see requiresGuard(_lit)).
%
%  Note: We call literals like ID_1234(_x) an auxiliary literal because
%  the ConceptBase rule compiler generates rules with such predicate names
%  in case of complex logical expressions, e.g. involving negation or
%  disjunction.
%  See also ticket #125.

isWeakAuxLitCandidate(_lit,_fun,_args) :-
  _lit =.. [_fun|_args],
  pc_atomconcat('ID_',_digits,_fun),
  !.

isWeakAuxLit(_lit) :-
  isWeakAuxLitCandidate(_lit,_fun,_args),
  tmpRuleInfo(_ruleid,_cat,_oid,_ids,_lit,_body,_depsOn,_vartab,_new_optPar,_relAlgExp),
  save_setof(_var,'IsComplexVar'(_var,_lit),_complexVars), 
  memberHeadlist(_blit,_body,_precedinglits),
  requiresGuard2(_blit),  % the body literal may require a guard for its variable(s)
  processVarBindings(_complexVars,_precedinglits,[],_),  % preceding lits don't bind complex vars of _blit
  'IsComplexVar'(_v,_blit),
  scanComplexVar(_v,_args),  % so the variable v occurs in both literals
  !.
%  requiresGuard2 is like requiresGuard except that is does not check on
%  isWeakAuxLit. If it would do so, we would have a potential infinite
%  loop. This exclusion makes isWeakLit an incomplete implementation of
%  what we originally intended. This is tolerable, since we anyway talk
%  about reordering of literals only. It is hard to imagine that the
%  restriction of requiresGuard2 imposes any practical problem. It would
%  require that an auxiliary rule (i.e. with a auxiliary predicate as
%  conclusion) itself calls another auxiliary rule which has a literal
%  that requires a guard. That's possible but very unlikely to ever be
%  generated from a Telos formula.
%  I must admit that I am myself unhappy with this argumentation on
%  likelihood. But I don't want to program a complicated data flow
%  analysis of Datalog rule sets. Using numbers in formulas is
%  the root of the problems in tickets #77, #122 and #125. They will
%  always make trouble with Datalog because we generate results of
%  arithmetic expressions on the fly, e.g. in IPLUS[1/i1,1000/i2].

requiresGuard2(_lit) :-
  isComplexQlit(_lit);
  isComplexComparisonLit(_lit);  % also take care when a comparison literal contains functional args
  isComparisonLit(_lit);  % also take care of normal comparison literals, ticket #77
  isFunctionLit(_lit).  % also take care of normal function queries, ticket #122
moveUnifiesForward(_in,_out) :-
    moveUnifiesForward2(_in,_unifiesLits,_restLits),
    !,
    append(_unifiesLits,_restLits,_out),
    !.

moveUnifiesForward2([],[],[]).
moveUnifiesForward2(['UNIFIES'(_x,_y)|_t],['UNIFIES'(_x,_y)|_unifiesLits],_out) :-
    !,
    moveUnifiesForward2(_t,_unifiesLits,_out).
%  18-Jul-2007/M.Jeusfeld: treat EQ analogously to UNIFIES. It has now the same
%  variable binding power as UNIFIES (thanks ticket #142). Moreover, we want to
%  make sure that it is evaluated before other comparison literals like LT.
%  So, UNIFIES and EQ are evaluated as soon as possible to enforce variable
%  bindings.
%  If we wouldn't do this, we might end up with a conjunction
%      LT(x,20),EQ(x,10)
%  This would be wrongly evaluated to false. The sequence EQ(x,10),LT(10,20)
%  delivers the expected result true.

moveUnifiesForward2(['EQ'(_x,_y)|_t],['EQ'(_x,_y)|_unifiesLits],_out) :-
    isComparisonLit('EQ'(_x,_y)),
    !,
    moveUnifiesForward2(_t,_unifiesLits,_out).
moveUnifiesForward2([_l|_t],_unifiesLits,[_l|_out]) :-
    moveUnifiesForward2(_t,_unifiesLits,_out).
%  Move In(x,c) after EQ(x,f(y))
%  So a conjunction
%    _lits1,In(x,c),_lits2,EQ(x,f(y)),_lits3
%  is transformed to
%    _lits1,_lits2,EQ(x,f(y)),In(x,c),_lits3
%  provided that x is simple variable.
%  The reason is that x will be bound by evaluating EQ.
%  This evaluation may lead to the creation of a new
%  object x.
%  The EQ predicate may be hidden in an auxiliary rule
%  such as ID_123(_x,_y) :- EQ(_x,f(_y)).
%  Then, the literal ID_123(_x,_y) is treated like
%  EQ(_x,f(_y)).
%  See ticket #175.

move_EQ_Forward([],[]) :- !.
move_EQ_Forward(['In'(_x,_c)|_rest],_out) :-
    simpleVar(_x),
    (pc_member('EQ'(_x,_y),_rest);pc_member('EQ'(_y,_x),_rest)),
    isBindingEQ('EQ'(_x,_y)),
    moveLitAfterLit('In'(_x,_c),'EQ'(_x,_y),_rest,_newrest),
    !,
    move_EQ_Forward(_newrest,_out).
move_EQ_Forward(['In'(_x,_c)|_rest],_out) :-
    pc_member(_lit,_rest),
    pseudoEQLit(_lit,_x),  % _x must be a simple variable
    moveLitAfterLit('In'(_x,_c),_lit,_rest,_newrest),
    !,
    move_EQ_Forward(_newrest,_out).
move_EQ_Forward([_l|_t],[_l|_out]) :-
    move_EQ_Forward(_t,_out).
%  2011-09-29/MJ: I think we need to check all rules with head _lit, not just one

pseudoEQLit(_lit,_simplevar) :-
  _lit =.. [_fun|_args],
  pc_atomconcat('ID_',_digits,_fun),
  tmpRuleInfo(_ruleid,_cat,_oid,_ids,_lit,_body,_depsOn,_vartab,_new_optPar,_relAlgExp),
  pc_member('EQ'(_x,_y),_body),
  isBindingEQ('EQ'(_x,_y)),
  fetchSimpleVar(_x,_y,_args,_simplevar),
  !.

isBindingEQ('EQ'(_x,_y)) :-
  isComplexComparisonLit('EQ'(_x,_y)).
isBindingEQ('EQ'(_x,_y)) :-
  isComparisonLit('EQ'(_x,_y)),
  (is_id(_x);is_id(_y)).

fetchSimpleVar(_x,_y,_args,_x) :-
  simpleVar(_x),
  pc_member(_x,_args),  % better: memberchk???
  !.
fetchSimpleVar(_x,_y,_args,_y) :-
  simpleVar(_y),
  pc_member(_y,_args),
  !.
%  move_FromTo_Forward is similar to move_EQ_Forward. The reasoning is as follows.
%  If a predicate In(_p,_ac) occurs before a predicate From(_p,_x) where _x is bound,
%  then In(_p,_ac) should be evaluated after From(_p,_x). The parameter _ac is
%  an attribute category that typically has more solutions than the number of
%  attributes of a given object _x.

move_FromTo_Forward(_inputlits,_outputlits) :-
  move_FromTo_Forward(_inputlits,_inputlits,_outputlits).
move_FromTo_Forward([],_,[]) :- !.
move_FromTo_Forward(['In'(_p,_ac)|_rest],_alllits,_out) :-
    simpleVar(_p),
    isConst(_ac),
    isFromToLit(_lit,_alllits,_rest),
    moveLitAfterLit('In'(_p,_ac),_lit,_rest,_newrest),
    !,
    move_FromTo_Forward(_newrest,_alllits,_out).
move_FromTo_Forward([_l|_t],_alllits,[_l|_out]) :-
    move_FromTo_Forward(_t,_alllits,_out).

isFromToLit(_lit,_alllits,_restlits) :-
  (_lit='From'(_p,_x);_lit='To'(_p,_x)),
  pc_member(_lit,_restlits),
  (pc_member(bound(_x),_alllits);isConst(_x)).
%  moveLitAfterLit(_lit1,_lit2,_inputlits,_outputlits) moves the literal _lit1 after
%  the first occurence of _lit2.

moveLitAfterLit('In'(_x,_c),_eqlit,[_eqlit|_rest],[_eqlit,'In'(_x,_c)|_rest]) :- !.
moveLitAfterLit('In'(_x,_c),_eqlit,[_otherlit|_rest],[_otherlit|_newrest]) :-
  moveLitAfterLit('In'(_x,_c),_eqlit,_rest,_newrest).
%  catchall

moveLitAfterLit('In'(_x,_c),_eqlit,[],['In'(_x,_c)]).
%  The 'bound' literal must in all cases be moved towards the begin of a clause
%  body. The purpose of 'bound' is to test whether required parameters of a
%  call of a generaic query class are actually bound. See Literals.pro
%  for the implementation of 'bound' and ticket #147 for some further explana-
%  tion.

moveBoundForward(_in,_out) :-
    moveBoundForward2(_in,_boundLits,_restLits),
    !,
    append(_boundLits,_restLits,_out),
    !.

moveBoundForward2([],[],[]).
moveBoundForward2([bound(_x)|_t],[bound(_x)|_boundLits],_out) :-
    !,
    moveBoundForward2(_t,_boundLits,_out).
moveBoundForward2([_l|_t],_boundLits,[_l|_out]) :-
    moveBoundForward2(_t,_boundLits,_out).
%  postProcEcaCond applies some optimizations also used for Datalog rules
%  to ECA conditions. The transformation preferGoodLits is special for
%  ECA but might be applied to Datalog as well.
%  if the condition is not a conjunction of predicates, then we cannot
%  optimize it like Datalog.

postProcEcaCond(nolist,_event,_cond,_cond) :- !.
postProcEcaCond(_mix,_event,'Ask'(_m,_inlits),'Ask'(_m,_outlits)) :-
  do_postProcEcaCond(_mix,_event,_inlits,_outlits).
postProcEcaCond(_mix,_event,_cond,_cond).  % never fail
do_postProcEcaCond(_mix,_event,_inlits,_outlits) :-
   applyLitFilters(_inlits,_lits3,
                        [cleanLiterals,earlyRedNegPre,transformFunctionCalls]),
   preferGoodLits(_mix,_event,_lits3,_lits3a),
   applyLitFilters(_lits3a,_outlits,
                        [earlyRedNegPost,moveBackInLits,guardComplexQueryParameters,
                         removeInsOfFunctionResult,moveUnifiesForward,move_EQ_Forward,
                         move_FromTo_Forward]),
   !.
%  "Good" lits are those predicates that efficiently bind a free variable
%  We move such predicates towards the beggining of a conjunction.
%  Currently, we only regard Adot(id_cat,a1,a2) as a a good lit iff one
%  of the two arguments is either bound or constant AND the other one is
%  a variable. So, after evaluating Adot(idcat,a1,a2) we have exactly one
%  less free variable in the rest of the conjunction. The re-arrangement
%  thus aims at quickly and efficiently getting rid of free variables.
%  The parameter _event gives as the start setting for the bound
%  variables.

preferGoodLits(_mix,_event,_lits,_newlits) :-
  _mix \= nolist,  % so it is a conjunction of predicates
  initBoundVars(_event,_bvars),
  get_cb_feature(iterMax,_max),
  iterateGoodLits(_max,_bvars,_lits,_newlits),  % do maximum _max iterations
  !.
preferGoodLits(_mix,_event,_lits,_lits).

initBoundVars(_event,_bvars) :-
  _event =.. [_op|_lit],
  getVars(_lit,_bvars),
  !.
initBoundVars(_event,[]).
%  iterateGoodLits iterates the reshuffling of "good lits" for n times
%  or stops when no reshuffling took place.

iterateGoodLits(0,_bvars,_lits,_lits) :- 
  'WriteTrace'(veryhigh,'QO_preproc',['Maximum number of join order iterations (CBserver parameter -im) used for current formula.']),
  !.
iterateGoodLits(_n,_bvars,_lits,_newlits) :- 
  _n > 0,
  do_preferGoodLits(_bvars,_lits,_newlits1),
  _n1 is _n - 1,
  exitOrContinueGoodLits(_n1,_bvars,_lits,_newlits1,_newlits).
%  last iteration did not change the order: we found the 'optimum'

exitOrContinueGoodLits(_n,_bvars,_lits,_lits,_lits) :- !.  
%  else iterate with the intermediate sultion newlits1

exitOrContinueGoodLits(_n,_bvars,_lits,_newlits1,_newlits) :-
  iterateGoodLits(_n,_bvars,_newlits1,_newlits).

do_preferGoodLits(_bvars,_lits,_newlits) :-
  separateGoodFromRest(_bvars,_lits,[],[],_good,_rest),
  append(_good,_rest,_newlits).  % good before rest
separateGoodFromRest(_bvars,[],_good,_rest,_good,_rest) :- !.
%  case 1: we found a good lit: goes to "good_sofar"

separateGoodFromRest(_bvars,[_lit|_restlits],_good_sofar,_rest_sofar,_good,_rest) :- 
  _lit = 'Adot'(_id_cat,_arg1,_arg2),
  is_id(_id_cat),
  oneArgBound(_bvars,_arg1,_arg2,_newbvar),
  append(_good_sofar,[_lit],_new_good_sofar),  % keep the relative order of predicates intact
  separateGoodFromRest([_newbvar|_bvars],_restlits,_new_good_sofar,_rest_sofar,_good,_rest).
%  case 2: otherwise goes to "rest_sofar"

separateGoodFromRest(_bvars,[_lit|_restlits],_good_sofar,_rest_sofar,_good,_rest) :- 
  append(_rest_sofar,[_lit],_new_rest_sofar),
  separateGoodFromRest(_bvars,_restlits,_good_sofar,_new_rest_sofar,_good,_rest).
%  we only consider predicates that bind exactly one argument here

oneArgBound(_bvars,_arg1,_arg2,_arg2) :-
  (is_id(_arg1);pc_member(_arg1,_bvars)),
  \+ pc_member(_arg2,_bvars),
  pc_atomconcat('_',_,_arg2),  % arg2 is will be bound after evaluating literal
  !.
oneArgBound(_bvars,_arg1,_arg2,_arg1) :-
  (is_id(_arg2);pc_member(_arg2,_bvars)),
  \+ pc_member(_arg1,_bvars),
  pc_atomconcat('_',_,_arg1),  % arg1 is will be bound after evaluating literal
  !.
%  same as preferGoodLits but now only for a the condition of a Datalog rule

preferGoodLitsDatalog(_lits,_newlits) :-
  initBoundVarsFromList(_lits,_bvars),
  get_cb_feature(iterMax,_max),
  iterateGoodLits(_max,_bvars,_lits,_newlits),  % do maximum _max iterations
  !.
preferGoodLitsDatalog(_lits,_lits).

initBoundVarsFromList([],[]) :- !.
initBoundVarsFromList([bound(_v)|_restlits],[_v|_restbvars]) :-
  !,
  initBoundVarsFromList(_restlits,_restbvars).
initBoundVarsFromList([_lit|_restlits],_restbvars) :-
  initBoundVarsFromList(_restlits,_restbvars).
%  meta-program to simplify the application of literal reorderings

applyLitFilters(_lits,_lits,[]) :- !.
applyLitFilters(_ilits,_olits,[_filter|_rest]) :-
  callFilter(_filter,_ilits,_tlits),
  applyLitFilters(_tlits,_olits,_rest).

callFilter(_filter,_ilits,_tlits) :-
 _filterGoal =.. [_filter,_ilits,_tlits],
  call(_filterGoal),
  traceFilterEffect(_filter,_ilits,_tlits), 
  !.
callFilter(_filter,_ilits,_ilits).

traceFilterEffect(_filter,_ilits,_tlits) :-
  get_cb_feature('TraceMode',_tracemode),
  conforms(veryhigh,_tracemode),
  toBeObserved(_filter), 
  _ilits \= _tlits,
  'WriteTrace'(veryhigh,'QO_preproc',['Filter ',_filter,' --> ',idterm(_tlits)]),
  !.
traceFilterEffect(_filter,_ilits,_tlits).

toBeObserved(_filter) :-
 pc_member(_filter,[
                     %  cleanLiterals,
                     %  earlyRedNegPre,
                     %  transformFunctionCalls,
                     %  earlyRedNegPost,
                     %  moveBackInLits,
                     %  moveUnifiesForward,
                     %  guardComplexQueryParameters,
                     %  removeInsOfFunctionResult,
                     %  moveBoundForward,
                     %  move_EQ_Forward,
                     %  move_FromTo_Forward,

                     preferGoodLitsDatalog
                 ]),
  !.
