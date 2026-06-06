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

:- module('RuleBase',[
'allBound'/1
,'findRecRules'/2
,'genPrologCodeFromInfos'/0
,'getHeadFromRuleInfo'/2
,'getHeadLiterals'/2
,'getOptParFromRuleInfo'/2
,'getTailFromRuleInfo'/2
,'getVartabFromRuleInfo'/2
,'initDatalogRulesInfo'/5
,'initDatalogRulesInfo'/7
,'isAux'/1
,'makeTmpRuleInfosPerm'/0
,'orderLocalRules'/3
,'remove_tmpRuleInfos'/0
,'store_ruleinfos'/1
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').
:- use_module('CodeCompiler.swi.pl').
:- use_module('CodeStorage.swi.pl').
:- use_module('QO_costBase.swi.pl').
:- use_module('QO_literals.swi.pl').
:- use_module('QO_optimize.swi.pl').
:- use_module('GeneralUtilities.swi.pl').
:- use_module('QO_utils.swi.pl').
:- use_module('Literals.swi.pl').
:- use_module('ModelConfiguration.swi.pl').
:- use_module('PrologCompatibility.swi.pl').
:- use_module('MetaUtilities.swi.pl').
:- style_check(-singleton).
% =========================================================
%
%  The ruleBase module manages information for generating
%  Prolog rules of an application.
%  Prolog rules are generated from Datalog rules.
%  The ruleInfo entries of the corresponding Datalog rules
%  are the basis for generating Prolog code.
%
%  The following information is stored in ruleInfo entries:
%
%  ruleId:  unique system-generated identifier
%
%  ruleCat: category of the rule:
%           Possible values
%           * view:  rule for view maintenance
%           * query: Code einer Query
%           * rule:  code of a deductive rule
%           * system: rule is not user-defined
%
%  objId:   ID of the object whose validity is required
%           for the rule to be valid
%
%  ids: ID struct for query or rule parameters
%           e.g. for handleCode$CodeStorage
%           (may be removed when handleCode is replaced)
%
%  head:    head literal of the rule
%
%  body:    set of literals in the rule body
%
%  depsOn:  set of ruleIds the current rule depends on
%
%  vartab:  variable table from range-form translation
%
%  optPar:  optimization parameters
%
%  relAlgExp: relational algebra expression
%
%
%  During a transaction it is used for each newly generated
%  Datalog rule a temporary ruleInfo entry is generated,
%  with functor 'tmpRuleInfo'. It is filled incrementally and
%  stored persistently as 'ruleInfo' facts when the transaction ends.
%
%  When generating the Datalog rules, "normal"
%  rules and auxiliary rules are distinguished. Auxiliary rules are
%  always local to a rule or query, their
%  head literals can therefore only occur in the Datalog rules
%  occur that belong to a specific rule/query
%  belong. The components of the dependency graph
%  in which this rule occurs, are therefore static,
%  i.e. no new "dependsOn" entries involving these
%  auxiliary rules can arise in a later transaction. Therefore it makes sense,
%  to distinguish global and local dependencies:
%
%   * rules with head literals that at any
%     position can occur, e.g. In- or
%     Adot literals, must be managed in a global
%     dependency graph.
%
%   * Auxiliary rules are only considered "locally", i.e.
%     during the transaction in which they are defined.
%
% =========================================================
% ---------------------------------------------------------
%  Initialize rule infos
%
%  After generating Datalog rules for a query, deductive
%  rule, etc., a ruleInfo term is created for each generated
%  rule. Some fields are still undefined.
%
% ---------------------------------------------------------

initDatalogRulesInfo([],_cat,_id,_ids,_vartab).
initDatalogRulesInfo([(_head :- _tail)|_rules],_cat,_id,_ids,_vartab) :-
	initDatalogRuleInfo(_head,_tail,_cat,_id,_ids,_vartab),
	initDatalogRulesInfo(_rules,_cat,_id,_ids,_vartab).

initDatalogRuleInfo(_head,_tail,_cat,_id,_ids,_vartab) :-
	buildNewRuleId(_ruleId),
	findDepObjId(_cat,_id,_objId),
	buildNewRuleInfo(_head,_tail,_cat,_objId,_ids,_ruleId,_vartab,_ruleInfo),
	assert(_ruleInfo),!.
%  Special case for VMruleGenerator, when the required ruleId is to be returned.

initDatalogRulesInfo(_head,_tail,_cat,_id,_ids,_vartab,_ruleId) :-
	buildNewRuleId(_ruleId),
	findDepObjId(_cat,_id,_objId),
	buildNewRuleInfo(_head,_tail,_cat,_objId,_ids,_ruleId,_vartab,_ruleInfo),
	assert(_ruleInfo),!.
% --------------------------------
%
%  buildNewRuleInfo
%  Initialize entries
%
% --------------------------------

buildNewRuleInfo(_head,_tailConjunct,_cat,_objId,_ids,_ruleId,_vartab,_ruleInfo) :-
	'Conjunct2List'(_tailConjunct,_tail),
	undefined(_depsOn),
	undefined(_optPar),
	undefined(_relAlgExp),
	_ruleInfo = tmpRuleInfo(_ruleId,
							_cat,
							_objId,
							_ids,
							_head,
							_tail,
							_depsOn,
							_vartab,
							_optPar,
							_relAlgExp).
% --------------------------------
%
%  buildNewRuleId
%  Generierung eines eindeutigen
%  Id's for a Datalog rule
%
% --------------------------------

buildNewRuleId(_ruleId) :-
	getFlag('Session_counter',_sc),
	getFlag('ID_counter',_idc),
	_newIdc is _idc + 1,
	setFlag('ID_counter',_newIdc),
	pc_inttoatom(_sc,_sca),
	pc_inttoatom(_idc,_idca),
	pc_atomconcat(['Rule_',_sca,'_',_idca],_ruleId),!.
% -------------------------------------------------
%
%  findDepObjId
%  Determination of the object whose validity
%  prerequisite for the validity of a Datalog rule.
%
%  For a deductive rule, the instance-of relation of
%  the corresponding attribute link to Class!rule is a
%  prerequisite for validity. It is computed here.
%
% -------------------------------------------------
%  Case 1: Datalog code belongs to a deductive rule ->
%            ruleId stores the object ID of the assertion text.
%  1: MSFOL rule

findDepObjId(rule,_ruleId,_objId) :-
	!,
	select2id('Class!rule',_ruleClass),
	prove_literal('To'(_objId,_ruleId)),
	prove_literal('In'(_objId,_ruleClass)),!.
%  Case 2: otherwise

findDepObjId(_cat,_objId,_objId) :-
	prove_literal('In'(_objId,_qClass)),!.
%  Inverse to findDepObjId for a deductive rule (MSFOL)

getRuleIdFromDepObjId(_depObjId,_ruleId) :-
	prove_literal('To'(_depObjId,_ruleId)),!.
% =======  ruleInfo -  local dependency graph ========
%
%  buildLocalDependencyGraph
%
%
%
%
%
% =========================================================

buildLocalDependencyGraph :-
	getLocalRuleCodeIdsWithCat(_ruleIds),
	buildLocalDependenciesForRuleIds(_ruleIds).

buildLocalDependenciesForRuleIds([]) :- !.
buildLocalDependenciesForRuleIds([_ruleCodeId|_ruleCodeIds]) :-
	buildLocalDependenciesForRuleId(_ruleCodeId),
	buildLocalDependenciesForRuleIds(_ruleCodeIds).

buildLocalDependenciesForRuleId([_ruleId,_cat]) :-
	tmpRuleInfo(_ruleId,_cat,_objId,_ids,
				_head,_tail,_depsOn,
				_vartab,_optPar,_relAlgExp),
	removeSecondaryFunctors(_tail,_tailClean),
	findLocalRuleReferencesInTail(_tail,_referenced),
	retract(tmpRuleInfo(_ruleId,_cat,_objId,_ids,
						_head,_tail,_depsOn,
						_vartab,_optPar,_relAlgExp)),
	assert(tmpRuleInfo(_ruleId,_cat,_objId,_ids,
						_head,_tail,_referenced,
						_vartab,_optPar,_relAlgExp)),!.
% ---------------------------------------------------------
%  checkSpecialBindings
%  If an auxiliary rule is only called in negated
%  form, then during optimization the rule assumes
%  that all variables in the head are bound.
% ---------------------------------------------------------

checkSpecialBindings :-
	getLocalRuleCodeIdsWithUndefOptPar(_ruleIds),
	checkSpecialBindings(_ruleIds).
checkSpecialBindings([]).
checkSpecialBindings([_ruleId|_ruleIds]) :-
	tmpRuleInfo(_ruleId,_cat,_objId,_ids,
				_head,_tail,_depsOn,
				_vartab,_optPar,_relAlgExp),
	filterNotsWithAux(_tail),
	checkSpecialBindings(_ruleIds).

filterNotsWithAux([]).
filterNotsWithAux([not(_lit)|_lits]) :-
	isAux(_lit),
	_lit =.. [_functor|_],
	(
		(pc_is_a_key('QO_notLit',_functor),pc_recorded('QO_notLit',_functor,0));
		 pc_rerecord('QO_notLit',_functor,0)
	),!,
	filterNotsWithAux(_lits).
filterNotsWithAux([_lit|_lits]) :-
	isAux(_lit),
	_lit =.. [_functor|_],
	(
		(pc_is_a_key('QO_notLit',_functor),pc_rerecord('QO_notLit',_functor,1));
		true
	),!,
	filterNotsWithAux(_lits).
filterNotsWithAux([_|_lits]) :-
	filterNotsWithAux(_lits).

allBound(_head) :-
	_head =.. [_functor|_],
	pc_is_a_key('QO_notLit',_functor),
	pc_recorded('QO_notLit',_functor,0),!.
% ---------------------------------------------------------
%  findLocalRuleReferencesInTail
%  Input: list of literals
%  Output: list of IDs of the rules that in the body of the
%           current rule are referenced
%           In doing so, only those in the current
%           considers rules added by the transaction.
%
%
% ---------------------------------------------------------

findLocalRuleReferencesInTail(_lits,_allRulesReferenced) :-
	findLocalRuleReferencesInTail(_lits,[],_allRulesReferenced1),!,
	makeflat(_allRulesReferenced1,_allRulesReferenced).
findLocalRuleReferencesInTail([],_allRulesReferenced,_allRulesReferenced).
findLocalRuleReferencesInTail([not(_lit)|_lits],_rulesPrev,_ruleIds) :-
	!,
	findLocalRuleReferencesInTail([_lit|_lits],_rulesPrev,_ruleIds).
findLocalRuleReferencesInTail(['In'(_x,_class)|_lits],_rulesPrev,_allRules) :-
	findall(_ruleId,
		tmpRuleInfo(_ruleId,_,_,_,
					'In'(_,_class),_,_,
					_,undef,_),
		_rulesReferenced),
	_rulesReferenced \==[],!,
	findLocalRuleReferencesInTail(_lits,[_rulesReferenced|_rulesPrev],_allRules).
findLocalRuleReferencesInTail(['Adot'(_p,_,_)|_lits],_rulesPrev,_allRules) :-
	findall(_ruleId,
		tmpRuleInfo(_ruleId,_,_,_,
					'Adot'(_p,_,_),_,_,
					_,undef,_),
		_rulesReferenced),
	_rulesReferenced \==[],!,
	findLocalRuleReferencesInTail(_lits,[_rulesReferenced|_rulesPrev],_allRules).
findLocalRuleReferencesInTail([_lit|_lits],_rulesPrev,_allRules) :-
     _lit =.. [_functor|_],
     ( is_id(_functor);
       pc_atomconcat('ID_',_,_functor)
      ),
	findall(_ruleId,
			(
		 	 tmpRuleInfo(_ruleId,_,_,_,_head,_,_,_,undef,_relAlgExp),
			 _head =.. [_functor|_]
			),
		_rulesReferenced),
	_rulesReferenced \==[],!,
	findLocalRuleReferencesInTail(_lits,[_rulesReferenced|_rulesPrev],_allRules).
findLocalRuleReferencesInTail([_lit|_lits],_rulesPrev,_ruleIds) :-
	findLocalRuleReferencesInTail(_lits,_rulesPrev,_ruleIds).
%  seems to be duplicated -> not refactored
%  findLocalRuleReferencesInTail([_lit|_lits],_allRulesReferenced) :-
% 	findall(_ruleId,
% 			(
% 			 _lit =.. [_functor|_],
%                          ( is_id(_functor);
%                            pc_atomconcat('ID_',_,_functor)
%                           ),
% 		 	 tmpRuleInfo(_ruleId,_,_,_,_head,_,_,_,undef,_relAlgExp),
% 			 _head =.. [_functor|_]
% 			),
% 		_rulesReferenced),
% 	_rulesReferenced \==[],!,
% 	findLocalRuleReferencesInTail(_lits,_ruleIds),
% 	append(_rulesReferenced,_ruleIds,_allRulesReferenced).
%
% ---------------------------------------------------------
%  orderLocalRules
%  Datalog rules created during the current transaction
%  are ordered for optimization:
% ---------------------------------------------------------

orderLocalRules(_ruleIds,_recCycles,_ruleIdsOrdered) :-
	makeflat(_recCycles,_recRules1),!,
	remDups(_recRules1,_recRules),
	storeRecRuleIds(_recRules),
	orderLocalRules(_ruleIds,[],_recRules,_ruleIdsOrdered).
%  Case 1: All rules ordered

orderLocalRules([],_rulesOrdered,_,_rulesOrdered) :- !.
%  Case 2: There are rules where all references in the body
%            angeordnet sind

orderLocalRules(_rulesNotHandled,_rulesHandled,_recRules,_rulesOrdered) :-
	findall(_ruleId,
		(member(_ruleId,_rulesNotHandled),
		 tmpRuleInfo(_ruleId,_cat,_objId,_ids,_head,_tail,_depIds,_vartab,_optPar,_relAlgExp),
		 subtract(_depIds,_rulesHandled,_rem),
		 _rem == []),
		_rulesReady),
	_rulesReady \== [],!,
	append(_rulesHandled,_rulesReady,_newRulesHandled),
	subtract(_rulesNotHandled,_rulesReady,_newRulesNotHandled),
	orderLocalRules(_newRulesNotHandled,_newRulesHandled,_recRules,_rulesOrdered).
%  Case 3: handling cyclic dependencies: when a cycle occurs,
%            an attempt is made to find a rule where all references
%            once the cyclic dependencies in the body are handled,

orderLocalRules(_rulesNotHandled,_rulesHandled,_recRules,_rulesOrdered) :-
	findall(_ruleId,
		(member(_ruleId,_rulesNotHandled),
		 tmpRuleInfo(_ruleId,_cat,_objId,_ids,_head,_tail,_depIds,_vartab,_optPar,_relAlgExp),
		 subtract(_depIds,_rulesHandled,_rem),
		 subset(_rem,_recRules)),
		_rulesReady),
	_rulesReady \== [],!,
	append(_rulesHandled,_rulesReady,_newRulesHandled),
	subtract(_rulesNotHandled,_rulesReady,_newRulesNotHandled),
	orderLocalRules(_newRulesNotHandled,_newRulesHandled,_recRules,_rulesOrdered).
%  case 4: If case 3 fails, all cyclic dependencies
%            are resolved brutally, i.e. marked as "handled"

orderLocalRules(_rulesNotHandled,_rulesHandled,_recRules,_rulesOrdered) :-
	append(_rulesHandled,_recRules,_newRulesHandled),
	subtract(_rulesNotHandled,_recRules,_newRulesNotHandled),
	orderLocalRules(_newRulesNotHandled,_newRulesHandled,_recRules,_rulesOrdered).
% ---------------------------------------------------------
%  findRecRules
%  Input: list of ruleIds
%  Output: list of lists of ruleIds
%
%  When a Datalog rule is optimized, calculating
%  the cost function requires that the rules
%  referenced in the body of the current rule are
%  already optimized. Problems arise when
%  rules depend on each other cyclically (direct or
%  indirect recursion).
%
%  For each rule the cycles are determined in which
%  it participates, i.e. all paths in the dependency
%  graph that begin and end with the rule are searched.
%
%  Disadvantage: the output list contains duplicate
%            cycles. If a cycle has n nodes, it appears n times.
%
%  During this search, visited nodes are logged. If a node
%  is visited a second time, the search is aborted because
%  otherwise it would not terminate.
% ---------------------------------------------------------

findRecRules([],[]) :- !.
findRecRules([_recRuleCand|_recRuleCands],_recRules) :-
	findCompleteCyclesWithRule(_recRuleCand,_cycles),
	findRecRules(_recRuleCands,_recRules1),
	append(_cycles,_recRules1,_recRules),!.
% ---------------------------------------------------------
%  findCompleteCyclesWithRule/2
%  Input: ruleId r
%  Output: list of lists of ruleIds
%           Each entry describes a cycle that
%           starts and ends with rule r
% ---------------------------------------------------------

findCompleteCyclesWithRule(_recRuleCand,_resultList) :-
	tmpRuleInfo(_recRuleCand,_cat,_objId,_ids,_head,_tail,_depIds,_vartab,_optPar,_relAlgExp),
	findall(_result,
		findCycleWithRule(_recRuleCand,_recRuleCand,[],_depIds,_result),
		_resultList).
%  case 1: start rule is part of a cycle

findCycleWithRule(_recRuleCand,_,_rulesVisited,_dependsOn,[_recRuleCand|_rulesVisited]) :-
	memberchk(_recRuleCand,_dependsOn),!.
%  case 2: a cycle exists but the start rule is not part of it;
% 	   the last inspected rule is start and end point
% 	   -> search failure

findCycleWithRule(_recRuleCand,_lastRule,[_lastRule|_rulesVisited],_dependsOn,_) :-
	memberchk(_lastRule,_rulesVisited),!,fail.
%  case 3: no cycle discovered yet

findCycleWithRule(_recRuleCand,_lastRule,_rulesVisited,_dependsOn,_cycle) :-
	member(_ruleId,_dependsOn),
	tmpRuleInfo(_ruleId,_cat,_objId,_ids,_head,_tail,_depIds,_vartab,_optPar,_relAlgExp),
	findCycleWithRule(_recRuleCand,_ruleId,[_ruleId|_rulesVisited],_depIds,_cycle).
% =======  ruleInfo - rule translation ==================
%
%  For facts with functor 'tmpRuleInfo', Prolog code is
%  generated here (only infos that are not yet optimized are collected).
%  This predicate decouples creation of Datalog code
%  from executable Prolog code.
%
%  Datalog code is stored temporarily in tmpRuleInfo facts.
%  Facts created during a transaction are collected here
%  and Prolog code is generated from them.
%
%  This predicate does not belong here but in a
%  higher-level module
% =========================================================

genPrologCodeFromInfos :-
	buildLocalDependencyGraph,
	getLocalRuleCodeIdsWithUndefOptPar(_ruleIds),
	checkSpecialBindings(_ruleIds),
	!,
	optimizeDatalogRules(_ruleIds,_optDataOut),
	prepareGenerationOfExecCode(_optDataOut,_codeToCompile),
	sortExecCode(_codeToCompile,_codeSorted),
	generateCodeForClusters(_codeSorted),
	merken_Saved_ruleIds.
% ---------------------------------------------------------
%  merken_Saved_ruleIds
%  Remember all already stored rule-code IDs
% ---------------------------------------------------------

merken_Saved_ruleIds:-
	getLocalRuleCodeIds(_ruleIds1),
	(pc_recorded(ruleIdslist,_ruleIds2);_ruleIds2=[]),
	append(_ruleIds1,_ruleIds2,_ruleIds),
	pc_rerecord(ruleIdslist,_ruleIds).
% ---------------------------------------------------------
%  getLocalRuleCodeIds
%  Collect the RuleCode-Ids of all Datalog rules,
%  generated in the current transaction,
%  including all already optimized or not optimized;
%  all already stored rules or not stored.
% ---------------------------------------------------------

getLocalRuleCodeIds(_ruleIds) :-
	save_setof(_ruleId,
		(_cat,_objId,_ids,_head,_tail,_depsOn,_vartab,_optPar,_relAlgExp)^tmpRuleInfo(_ruleId,_cat,_objId,_ids,_head,_tail,_depsOn,_vartab,_optPar,_relAlgExp),
		_ruleIds).
% ---------------------------------------------------------
%  getRuleCodeIdsToSave
%  Collect rule-code IDs of all Datalog rules
%  generated and optimized in the current transaction
%  but not yet stored as PrologCode.
% ---------------------------------------------------------

getRuleCodeIdsToSave(_ruleIds):-
	(pc_recorded(ruleIdslist,_ruleIds2);_ruleIds2=[]),
	save_setof(_ruleId,
		(_cat,_objId,_ids,_head,_tail,_depsOn,_vartab,_optPar,_relAlgExp)^(
		tmpRuleInfo(_ruleId,_cat,_objId,_ids,_head,_tail,_depsOn,_vartab,_optPar,_relAlgExp),
		\+(member(_ruleId,_ruleIds2))),
	_ruleIds).
% ---------------------------------------------------------
%  getLocalRuleCodeIdsWithCat:
%  Collect rule-code IDs of all Datalog rules
%  generated in the current transaction
% ---------------------------------------------------------

getLocalRuleCodeIdsWithCat(_ruleIds) :-
	save_setof([_ruleId,_cat],
		(_objId,_ids,_head,_tail,_depsOn,_vartab,_optPar,_relAlgExp)^tmpRuleInfo(_ruleId,_cat,_objId,_ids,_head,_tail,_depsOn,_vartab,undef,_relAlgExp),
		_ruleIds).
% ---------------------------------------------------------
%  getLocalRuleCodeIdsWithUndefOptPar
%  Collect rule-code IDs of all Datalog rules
%  generated in the current transaction
%  whose OptPar is undef, i.e. not yet optimized
% ---------------------------------------------------------

getLocalRuleCodeIdsWithUndefOptPar(_ruleIds) :-
	assert(vmrule(nix,nix)),  % so vmrule is known in setof
	save_setof(_ruleId,
		(_cat,_objId,_ids,_head,_tail,_depsOn,_vartab,_relAlgExp)^(tmpRuleInfo(_ruleId,_cat,_objId,_ids,_head,_tail,_depsOn,_vartab,undef,_relAlgExp),\+(vmrule(_ruleId,_))),
		_ruleIds),
	retract(vmrule(nix,nix)).

prepareGenerationOfExecCode([],[]).
prepareGenerationOfExecCode([_ruleId-_codeList|_optRules],
                            [ruleData(query,_ruleId,_objId,_codeList)|_rulesCode]) :-
	tmpRuleInfo(_ruleId,query,_objId,_,_,_,_,_,_,_),
	prepareGenerationOfExecCode(_optRules,_rulesCode).
prepareGenerationOfExecCode([_ruleId-_codeList|_optRules],
                            [ruleData(mquery,_ruleId,_objId,_objId,_codeList)|_rulesCode]) :-
	tmpRuleInfo(_ruleId,mquery,_objId,_,_,_,_,_,_,_),
	prepareGenerationOfExecCode(_optRules,_rulesCode).
prepareGenerationOfExecCode([_ruleId-_codeList|_optRules],
                            [ruleData(rule,_ruleId,_ids,_codeList)|_rulesCode]) :-
	tmpRuleInfo(_ruleId,rule,_,_ids,_,_,_,_,_,_),
	prepareGenerationOfExecCode(_optRules,_rulesCode).
prepareGenerationOfExecCode([_ruleId-_codeList|_optRules],
                            [ruleData(vmrule,_ruleId,_ids,_codeList)|_rulesCode]) :-
	tmpRuleInfo(_ruleId,vmrule,_,_ids,_,_,_,_,_,_),
	prepareGenerationOfExecCode(_optRules,_rulesCode).
%
% 	1. main rule
% 	2. auxiliary rules
% 		2.1 non-recursive rules by cost
% 		2.2 recursive rules
%

sortExecCode([],[]) :- !.
sortExecCode(_ruleData,_ruleDataOut) :-
	getRuleCodeIdsToSave(_ruleIds),
	getRulesByDepObj(_ruleIds,_ruleGroupList),
	getRecRuleIds(_recRules),
	buildRuleClusters(_ruleGroupList,_recRules,_ruleCluster),
	sortRuleData(_ruleCluster,_ruleData,_ruleDataOut).

getRulesByDepObj(_ruleIds,_ruleGroupListByDepObj) :-
	prepareSorting(_ruleIds,_ruleListUnsorted),
	keysort(_ruleListUnsorted,_ruleList),
	groupKeyList(_ruleList,_ruleGroupList),
	keysort(_ruleGroupList,_ruleGroupListByDepObj1),
	mergeKeyList(_ruleGroupListByDepObj1,_ruleGroupListByDepObj).

prepareSorting([],[]).
prepareSorting([_ruleId|_ruleIds],[_headKey-_ruleId|_rulePairs]) :-
	buildHeadKey(_ruleId,_headKey),
	prepareSorting(_ruleIds,_rulePairs).

buildHeadKey(_ruleId,_adotKey) :-
	tmpRuleInfo(_ruleId,_cat,_objId,_ids,'Adot'(_cc,_x,_y),_tail,_depsOn,_vartab,_optPar,_relAlgExp),!,
	pc_atomconcat('Adot',_cc,_adotKey),!.
buildHeadKey(_ruleId,_inKey) :-
	tmpRuleInfo(_ruleId,_cat,_objId,_ids,'In'(_x,_c),_tail,_depsOn,_vartab,_optPar,_relAlgExp),!,
	pc_atomconcat('In',_c,_inKey),!.
buildHeadKey(_ruleId,_ltKey) :-
	tmpRuleInfo(_ruleId,_cat,_objId,_ids,'LTevalQuery'(_depObj,_),_tail,_depsOn,_vartab,_optPar,_relAlgExp),!,
	pc_atomconcat('LTevalQuery',_depObj,_ltKey),!.
%  for e.g. del(id_3232(_)) build key as delid_3232, not as before as del, ambiguous!

buildHeadKey(_ruleId,_Key) :-
	tmpRuleInfo(_ruleId,_cat,_objId,_ids,_head,_tail,_depsOn,_vartab,_optPar,_relAlgExp),
	_head =.. [_functor1|[_term]],
	member(_functor1,[plus,minus,new,red,del,ins]),
	!,
	_term =.. [_functor2|_args],
	pc_atomconcat(_functor1,_functor2,_Key).
buildHeadKey(_ruleId,_functor) :-
	tmpRuleInfo(_ruleId,_cat,_objId,_ids,_head,_tail,_depsOn,_vartab,_optPar,_relAlgExp),!,
	_head =.. [_functor|_args].
% sortRuleData sorts _ruleData by the given ruleId order (from ruleCluster)!

sortRuleData([],_,[]).
sortRuleData([_ruleCluster|_ruleClusters],_ruleData,_ruleDatasorted) :-
	sortRuleDataForCluster(_ruleCluster,_ruleData,_ruleDatasorted1),
	sortRuleData(_ruleClusters,_ruleData,_ruleDatasorted2),
	append(_ruleDatasorted1,_ruleDatasorted2,_ruleDatasorted).

sortRuleDataForCluster([],_,[]).
sortRuleDataForCluster([_ruleId|_ruleIdrest],_ruleData,[ruleData(_mode,_ruleId,_idPar,_rule)|_rest]) :-
	member(ruleData(_mode,_ruleId,_idPar,_rule),_ruleData),!,
	sortRuleDataForCluster(_ruleIdrest,_ruleData,_rest).
sortRuleDataForCluster([_ruleId|_ruleIdrest],_ruleData,[ruleData(_mode,_ruleId,_idPar1,_idPar2,_rule)|_rest]) :-
	member(ruleData(_mode,_ruleId,_idPar1,_idPar2,_rule),_ruleData),!,
	sortRuleDataForCluster(_ruleIdrest,_ruleData,_rest).
%  Group rules by head key ->
%    rules with the same head are combined.
%    Sorting by depending object is prepared.
%
%    The same depending object implies logical cohesion of the rules.
%

groupKeyList([],[]).
groupKeyList([_key-_ruleId|_keyList],[_objId-[_ruleId|_listOfElems]|_remainder]) :-
	tmpRuleInfo(_ruleId,_cat,_objId,_ids,_head,_tail,_depsOn,_vartab,_optPar,_relAlgExp),
	find_keys(_key,_keyList,_listOfElems,_newKeyList),
	groupKeyList(_newKeyList,_remainder).

find_keys(_key,[],[],[]) :-
	!.
find_keys(_key,[_key-_x|_xs],[_x|_ys],_zs) :-
	!,
	find_keys(_key,_xs,_ys,_zs).
find_keys(_key,[_x|_xs],_ys,[_x|_zs]) :-
	find_keys(_key,_xs,_ys,_zs).

mergeKeyList([],[]).
mergeKeyList([_objId-_ruleIds|_keyList],_keyListMerged) :-
	mergeKeyList(_keyList,[_objId-_ruleIds],_keyListMerged).
mergeKeyList([],_keyList,_keyList).
mergeKeyList([_objId-_newRules|_others],[_objId-_ruleIds|_merged],_keyListMerged) :-
	!,
	append(_ruleIds,_newRules,_rulesMerged),
	mergeKeyList(_others,[_objId-_rulesMerged|_merged],_keyListMerged).
mergeKeyList([_objId-_newRules|_others],[_otherObjId-_ruleIds|_merged],_keyListMerged) :-
	_objId \== _otherObjId,
	mergeKeyList(_others,[_objId-_newRules|[_otherObjId-_ruleIds|_merged]],_keyListMerged).

buildRuleClusters([],_,[]).
buildRuleClusters([_objId-_ruleGroup|_ruleGroupList],_recRules,[_ruleCluster|_ruleClusters]) :-
	buildRuleCluster(_ruleGroup,_recRules,_ruleCluster),
	buildRuleClusters(_ruleGroupList,_recRules,_ruleClusters).

buildRuleCluster(_ruleGroup,_recRules,_ruleCluster) :-
	getLTEvalRules(_ruleGroup,_newRuleGroup,_ltEvalRules),
	intersect_plus(_newRuleGroup,_recRules,_recRulesInGroup,_nonRecRulesInGroup),
	getCostsForRuleIds(_nonRecRulesInGroup,_nrWithCosts1),
	keysort(_nrWithCosts1,_nrWithCosts),
	dropKeys(_nrWithCosts,_nr),
	getCostsForRuleIds(_recRulesInGroup,_rWithCosts1),
	keysort(_rWithCosts1,_rWithCosts),
	dropKeys(_rWithCosts,_r),
	append(_r,_ltEvalRules,_rules1),
	append(_nr,_rules1,_ruleCluster).
%  arg3 = arg1 and arg2, arg4 arg1 - arg2

intersect_plus([],_xs,[],[]) :- !.
intersect_plus([_x|_xs],_ys,[_x|_zs],_ws) :-
	member(_x,_ys),
	!,
	intersect_plus(_xs,_ys,_zs,_ws).
intersect_plus([_x|_xs],_ys,_zs,[_x|_ws]) :-
	intersect_plus(_xs,_ys,_zs,_ws).

getLTEvalRules([],[],[]).
getLTEvalRules([_ruleId|_ruleIds],_otherRules,[_ruleId|_ltEvals]) :-
	tmpRuleInfo(_ruleId,_cat,_objId,_ids,_head,_tail,_depsOn,_vartab,_optPar,_relAlgExp),
	_head =.. ['LTevalQuery'|_],!,
	getLTEvalRules(_ruleIds,_otherRules,_ltEvals).
getLTEvalRules([_ruleId|_ruleIds],[_ruleId|_otherRules],_ltEvals) :-
	getLTEvalRules(_ruleIds,_otherRules,_ltEvals).

getCostsForRuleIds([],[]).
getCostsForRuleIds([_ruleId|_ruleIds],[_cost-_ruleId|_cAndRuleIds]) :-
	tmpRuleInfo(_ruleId,_cat,_objId,_ids,_head,_tail,_depsOn,_vartab,_optPar,_relAlgExp),
	getArgs(_head,_args),
	buildAdAllFreeForArgs(_args,_ad),
	getCostsSum(_head,_ad,_cost),
	getCostsForRuleIds(_ruleIds,_cAndRuleIds).

generateCodeForClusters([]) .
generateCodeForClusters([ruleData(_mode,_ruleId,_idPar,_ruleList)|_rdList]) :-
	((_mode == rule);(_mode == query)),!,
	generatePROLOGCode(_ruleList,_prologCode),
	handleCode(_mode,_idPar,_prologCode),
	generateCodeForClusters(_rdList).
generateCodeForClusters([ruleData(_mode,_ruleId,_idPar,_ruleList)|_rdList]) :-
	_mode == vmrule,
	!,
	generatePROLOGCode(_ruleList,_prologCode),
	handleCode(_mode,_ruleId,_prologCode),
	generateCodeForClusters(_rdList).
%  only for debugging purposes

generateCodeForCluster([_ruleInfo|_triList]) :-
		writeq(_ruleInfo),nl,
		write('*** no code generated ***'),nl,
		generateCodeForCluster(_triList).

store_ruleinfos([]):-!.
store_ruleinfos([_first|_rest]):-
	assert(_first),
	!,
	store_ruleinfos(_rest).
% ---------------------------------------------------------
%  storeRuleInfosToFile
% ---------------------------------------------------------

storeRuleInfosToFile(_ruleidlist) :-
	get_application(_appname),
	appFilename('ruleinfo',_appname,_fullFileName),
    pc_fopen(ruleinfofile,_fullFileName,a),
	writeRuleIds(_ruleidlist).

writeRuleIds([]) :-
	pc_fclose(ruleinfofile).
writeRuleIds([_ruleid|_rest]) :-
	ruleInfo(_ruleid,_cat,_oid,_ids,_head,_body,_depsOn,_vartab,_optPar,_relAlgExp),
	writeFacts(ruleinfofile,[ruleInfo(_ruleid,_cat,_oid,_ids,_head,_body,_depsOn,_vartab,_optPar,_relAlgExp)]),
	writeRuleIds(_rest).
% ---------------------------------------------------------
%  makeTmpRuleInfosPerm/0.
%
%  ruleInfos created during a transaction are added to the
%  permanent ones. The functor is changed from 'tmpRuleInfo' to 'ruleInfo'.
%
% ---------------------------------------------------------

'TmpRuleInfosToRuleInfos'([_ruleId|_rest]) :-
	retract(tmpRuleInfo(_ruleId,_cat,_objId,_ids,_head,_tail,_depsOn,_vartab,_optPar,_relAlgExp)),
	assert(ruleInfo(_ruleId,_cat,_objId,_ids,_head,_tail,_depsOn,_vartab,_optPar,_relAlgExp)),
	'TmpRuleInfosToRuleInfos'(_rest).
'TmpRuleInfosToRuleInfos'([]).

makeTmpRuleInfosPerm :-
	'TmpRuleInfosToRuleInfos'(_ruleidlist),
	pc_erase(ruleIdslist),
 	storeRuleInfosToFile(_ruleidlist).
% ---------------------------------------------------------
%  remove_tmpRuleInfos/0
%
%  ruleInfos created during a transaction are deleted.
%  Required when the transaction failed or was an ASK.
%
% ---------------------------------------------------------

remove_tmpRuleInfos :-
	retractall(tmpRuleInfo(_ruleId,_cat,_objId,_ids,_head,_tail,_depsOn,_vartab,_optPar,_relAlgExp)).

getVartabFromRuleInfo(_ruleId,_vartab) :-
	tmpRuleInfo(_ruleId,_cat,_objId,_ids,_head,_tail,_depsOn,_vartab,_optPar,_relAlgExp),!.
getVartabFromRuleInfo(_ruleId,_vartab) :-
	ruleInfo(_ruleId,_cat,_objId,_ids,_head,_tail,_depsOn,_vartab,_optPar,_relAlgExp),!.

getHeadFromRuleInfo(_ruleId,_head) :-
	tmpRuleInfo(_ruleId,_cat,_objId,_ids,_head,_tail,_depsOn,_vartab,_optPar,_relAlgExp),!.
getHeadFromRuleInfo(_ruleId,_head) :-
	ruleInfo(_ruleId,_cat,_objId,_ids,_head,_tail,_depsOn,_vartab,_optPar,_relAlgExp),!.

getTailFromRuleInfo(_ruleId,_tail) :-
	tmpRuleInfo(_ruleId,_cat,_objId,_ids,_head,_tail,_depsOn,_vartab,_optPar,_relAlgExp),!.
getTailFromRuleInfo(_ruleId,_tail) :-
	ruleInfo(_ruleId,_cat,_objId,_ids,_head,_tail,_depsOn,_vartab,_optPar,_relAlgExp),!.

getAlgExpFromRuleInfo(_ruleId,_algExp) :-
	tmpRuleInfo(_ruleId,_cat,_objId,_ids,_head,_tail,_depsOn,_vartab,_optPar,_algExp),!.
getAlgExpFromRuleInfo(_ruleId,_algExp) :-
	ruleInfo(_ruleId,_cat,_objId,_ids,_head,_tail,_depsOn,_vartab,_optPar,_algExp),!.

getOptParFromRuleInfo(_ruleId,_optPar) :-
	tmpRuleInfo(_ruleId,_cat,_objId,_ids,_head,_tail,_depsOn,_vartab,_optPar,_algExp),!.
getOptParFromRuleInfo(_ruleId,_optPar) :-
	ruleInfo(_ruleId,_cat,_objId,_ids,_head,_tail,_depsOn,_vartab,_optPar,_algExp),!.

getDepsOnFromRuleInfo(_ruleId,_optPar) :-
	tmpRuleInfo(_ruleId,_cat,_objId,_ids,_head,_tail,_depsOn,_vartab,_optPar,_algExp),!.
getDepsOnFromRuleInfo(_ruleId,_optPar) :-
	ruleInfo(_ruleId,_cat,_objId,_ids,_head,_tail,_depsOn,_vartab,_optPar,_algExp),!.
% --------------------------------
%
%  isAux
%  Test whether the passed
%  Datalog rule head belongs to a
%  auxiliary rule, i.e. has a functor
%  that begins with 'ID_'
%
% --------------------------------

isAux(_head) :-
	_head =.. [_functor|_],
	pc_atomconcat('ID_',_,_functor),!.

setAlgExpInRuleInfo(_ruleId,_algExp) :-
	retract(tmpRuleInfo(_ruleId,_cat,_objId,_ids,_head,_tail,_depsOn,_vartab,_optPar,_oldAlgExp)),
	assert(tmpRuleInfo(_ruleId,_cat,_objId,_ids,_head,_tail,_depsOn,_vartab,_optPar,_algExp)),!.
setAlgExpInRuleInfo(_ruleId,_algExp) :-
	retract(ruleInfo(_ruleId,_cat,_objId,_ids,_head,_tail,_depsOn,_vartab,_optPar,_oldAlgExp)),
	assert(ruleInfo(_ruleId,_cat,_objId,_ids,_head,_tail,_depsOn,_vartab,_optPar,_algExp)),!.

getHeadLiterals([],[]).
getHeadLiterals([_ruleId|_ruleIds],[_ruleId-_head|_headLits]) :-
	(
	tmpRuleInfo(_ruleId,_cat,_objId,_ids,_head,_tail,_depIds,_vartab,_optPar,_relAlgExp);
	ruleInfo(_ruleId,_cat,_objId,_ids,_head,_tail,_depIds,_vartab,_optPar,_relAlgExp)
	),
	getHeadLiterals(_ruleIds,_headLits).

storeRecRuleIds(_recRules) :-
	pc_rerecord('QO_ruleBase',recRules,_recRules).

getRecRuleIds(_recRules) :-
	(pc_recorded('QO_ruleBase',recRules,_recRules);
	 _recRules = []),!.
