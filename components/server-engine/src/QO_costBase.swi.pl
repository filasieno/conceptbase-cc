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
% --------------------------------------------------------------------
%
%  The QO_costBase module manages the intensional costs
%  of a literal. For literals that appear as the head of a Datalog rule
%  two different costs are assigned:
%
% 	* the intensional fan-out
% 	* the cost of rule evaluation
%
%  The intensional fan-out of a literal indicates how many solutions
%  for a literal with a given binding pattern are produced by
%  applying the deductive rules for that literal.
%  The rule evaluation cost describes the effort to produce these solutions.
%
%  For a literal, the total costs arising from all deductive rules
%  are stored. Both costs are the sum of the individual costs
%  for each deductive rule.
%
% --------------------------------------------------------------------

:- module('QO_costBase',[
'buildKey'/3
,'getCost'/4
,'getCostsSum'/3
,'load_int_cost'/1
,'storeAllOptPars'/3
,'storeCost'/4
,'store_optPar_for_LTevalQuery'/4
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').
:- use_module('GeneralUtilities.swi.pl').
:- use_module('QO_utils.swi.pl').
:- use_module('QueryCompiler.swi.pl').
:- use_module('PrologCompatibility.swi.pl').
:- style_check(-singleton).
getCost(not(_lit),_ad,_fanOutInt,_compCostInt) :-
	!,
	getCost(_lit,_ad,_fanOutInt,_compCostInt).
getCost(_lit,_ad,_fanOutInt,_compCostInt) :-
	buildKey(_lit,_ad,_id),
	pc_current_key(_id,'QO_fanOutInt'),!,
	pc_recorded(_id,'QO_fanOutInt',_fanOutInt),
	pc_recorded(_id,'QO_compCostInt',_compCostInt).
getCost(_lit,_ad,0.0,0.0).

getCostsSum(_lit,_ad,_costSum) :-
	getCost(_lit,_ad,_fanOutInt,_compCostInt),
	save_plus(_fanOutInt,_compCostInt,_costSum).

get_ruleid_with_head(_head,_ruleidlist):-
	findall(_ruleid,ruleInfo(_ruleid,_cat,_oid,_ids,_head,_body2,_depsOn,_vartab,_optPar,_relAlgExp),_ruleidlist1),
	findall(_ruleid,tmpRuleInfo(_ruleid,_cat,_oid,_ids,_head,_body2,_depsOn,_vartab,_optPar,_relAlgExp),_ruleidlist2),
	append(_ruleidlist1,_ruleidlist2,_ruleidlist).
% -------------------------------------- store_new_ruleinfo------------------------------------------------------------------------
%  Intensional costs w.r.t. the head literal of a rule are stored in the corresponding ruleInfo.
%  Note that these costs are not complete: only a partial cost for a head literal with
%  variable binding in a rule is stored here. To get the correct cost, one must consult
%  the record. The problem with the record is that it cannot be stored permanently.
%  Therefore partial costs are stored in ruleInfos first; when the DB starts, all costs
%  from ruleInfos are loaded into records.

store_new_ruleinfo(_,_,_,[]):-!.
store_new_ruleinfo(_id,_fanOutInt,_compCostInt,[_ruleid|_r]):-
	(
	 (retract(ruleInfo(_ruleid,_cat,_oid,_ids,_head,_body,_depsOn,_vartab,_optPar,_relAlgExp)),
	  change_optpar(_id,_fanOutInt,_compCostInt,_optPar,_new_optPar),
	  assert(ruleInfo(_ruleid,_cat,_oid,_ids,_head,_body,_depsOn,_vartab,_new_optPar,_relAlgExp))
	 );
	 (retract(tmpRuleInfo(_ruleid,_cat,_oid,_ids,_head,_body,_depsOn,_vartab,_optPar,_relAlgExp)),
	  change_optpar(_id,_fanOutInt,_compCostInt,_optPar,_new_optPar),
	  assert(tmpRuleInfo(_ruleid,_cat,_oid,_ids,_head,_body,_depsOn,_vartab,_new_optPar,_relAlgExp))
	)),
	!,
	store_new_ruleinfo(_id,_fanOutInt,_compCostInt,_r).

change_optpar(_id,_fanOutInt,_compCostInt,undef,[cost(_id,_fanOutInt,_compCostInt)]) :-
	!.
change_optpar(_id,_fanOutInt,_compCostInt,_optPar,[cost(_id,_fanOutInt,_compCostInt)|_optParNew]):-
	((member(cost(_id,_f,_c),_optPar),
	  delete(cost(_id,_f,_c),_optPar,_optParNew)
	 );
	 _optParNew = _optPar
	),
	!.
%  -----------------------------------------  store_optPar  ---------------------------------------------------------------------
%  Stores intensional costs with respect to the head literal of a rule in the associated ruleInfo.
%  The costs are not complete: only a partial cost for a head literal with variable binding in a
%  rule is stored here. To get the correct costs, consult the record, which cannot be stored
%  permanently. Therefore partial costs are stored in ruleInfos first; on DB startup, all costs
%  from ruleInfos are loaded into records.
%  Note also that optPar is a list of intensional costs of the literal with different bindings.
%   -----------------------------------------------------------------------------------------------------------------------------

storeAllOptPars(_ruleid,_optBody,_costs) :-
	retract(ruleInfo(_ruleid,_cat,_oid,_ids,_head,_body,_depsOn,_vartab,_optPar,_relAlgExp)),
	assert(ruleInfo(_ruleid,_cat,_oid,_ids,_head,_optBody,_depsOn,_vartab,_costs,_relAlgExp)),
	!.
storeAllOptPars(_ruleid,_optBody,_costs) :-
	retract(tmpRuleInfo(_ruleid,_cat,_oid,_ids,_head,_body,_depsOn,_vartab,_optPar,_relAlgExp)),
	assert(tmpRuleInfo(_ruleid,_cat,_oid,_ids,_head,_optBody,_depsOn,_vartab,_costs,_relAlgExp)).

store_optPar_for_LTevalQuery(_idlit,_ad,_fanOutInt,_compCostInt) :-
	_idlit =.. [_oid|_args],
	not('SubQuery'(_oid,_)),
	id2name(_oid,_),
	'Query'(_oid),
	freeQueryArgs(_oid,_ad),  % costs for In(_x,_q) are the costs for q(_x,...) with ... free or constant
	!,
	_args = [_this|_],
	_ad = [_thisad|_],
	_lit = 'LTevalQuery'(_oid,'In'(_,_)),
	buildKey(_lit,[_thisad,b],_id),
	get_ruleid_with_head(_lit,_ruleidlist),
	store_new_ruleinfo(_id,_fanOutInt,_compCostInt,_ruleidlist).
store_optPar_for_LTevalQuery(_idlit,_ad,_fanOutInt,_compCostInt).

freeQueryArgs(_id,_ad) :-
	get_QueryStruct(_id,_s),
	_s = [this|_],
	freeQueryArgs2(_s,_ad).

freeQueryArgs2([],[]).
freeQueryArgs2([this|_args],[_h|_rad]) :-
	freeQueryArgs2(_args,_rad).
freeQueryArgs2([r(_)|_args],[f,f|_rad]) :-
	freeQueryArgs2(_args,_rad).
freeQueryArgs2([c(_)|_args],[f|_rad]) :-
	freeQueryArgs2(_args,_rad).
freeQueryArgs2([rp(_,_)|_args],[f,f,b|_rad]) :-
	freeQueryArgs2(_args,_rad).
freeQueryArgs2([cp(_,_)|_args],[f,b|_rad]) :-
	freeQueryArgs2(_args,_rad).
freeQueryArgs2([p(_,_)|_args],[f,b|_rad]) :-
	freeQueryArgs2(_args,_rad).

body2list(_lit,[_lit]) :-
	_lit \= (_,_),
	!.
body2list((_a,_r),[_a|_nr]) :-
	!,
	body2list(_r,_nr).
%  the problem remains that ruleInfos should be deleted when a rule is untold,
% and the pc_record for the literal (head) must also be adjusted for that rule.
%  Costs from ruleInfo.optPar are written back to the object base. For a literal with a
%  given binding, the corresponding cost may appear in several ruleInfo.optPar entries;
%  the sum should be taken.
% **for ConfigurationsUtilities, load_ruleinfos**

load_int_cost([]).
load_int_cost([ruleInfo(_ruleid,_cat,_oid,_ids,_head,_body,_depsOn,_vartab,_optPar,_relAlgExp)|_rest]) :-
	store_cost_from_optPar(_optPar),
	!,
	load_int_cost(_rest).

store_cost_from_optPar(undef).  % for emergency cases
store_cost_from_optPar([]).
store_cost_from_optPar([cost(_id,_fanOutInt,_compCostInt)|_costrest]) :-
	storeTotalCost(_id,_compCostInt),
	!,
	storeLitCost(_id,_fanOutInt),
	!,
	store_cost_from_optPar(_costrest).

storeCost(_lit,_ad,_fanOutInt,_compCostInt) :-
	buildKey(_lit,_ad,_id),
	storeLitCost(_id,_fanOutInt),
	storeTotalCost(_id,_compCostInt),
	!.
%  when caching ruleInfos, the pc_record database must be initialized;
% cost info for a literal is cached as pc_record on startup.

clearLitCosts :-
	pc_erase_all('QO_fanOutInt'),
	pc_erase_all('QO_compCostInt').

cToBList([],[]).
cToBList([_ad|_ads],[_newAd|_newAds]) :-
	cToB(_ad,_newAd),
	cToBList(_ads,_newAds).

cToB(c,b).
cToB(b,b).
cToB(f,f).

buildKey('Adot'(_p,_x,_y),[c,_ad1In,_ad2In],_id) :-
	cToB(_ad1In,_ad1),
	cToB(_ad2In,_ad2),
	pc_atomtolist(_adAtom,[_ad1,_ad2]),
	pc_atomconcat(['Adot',_p,'AD',_adAtom],_id),!.
buildKey('Adot'(_p,_x,_y),[_ad1In,_ad2In],_id) :-
	cToB(_ad1In,_ad1),
	cToB(_ad2In,_ad2),
	pc_atomtolist(_adAtom,[_ad1,_ad2]),
	pc_atomconcat(['Adot',_p,'AD',_adAtom],_id),!.
buildKey('In'(_x,_c),[_adIn,c],_id) :-
	cToB(_adIn,_ad),
	pc_atomtolist(_adAtom,[_ad]),
	pc_atomconcat(['In',_c,'AD',_adAtom],_id),!.
buildKey('In'(_x,_c),[_adIn],_id) :-
	cToB(_adIn,_ad),
	pc_atomtolist(_adAtom,[_ad]),
	pc_atomconcat(['In',_c,'AD',_adAtom],_id),!.
buildKey('LTevalQuery'(_c,'In'(_x,_)),_adIn,_id) :-
	buildKey('In'(_x,_c),_adIn,_id),!.
buildKey(_lit,_adIn,_id) :-
	_lit =.. [_fun|[_term]],  % NOTE: the 2nd argument of ../ is a list!!!
	member(_fun,[plus,minus,new,red,del,ins]),
	buildKey(_term,_adIn,_id1),
	pc_atomconcat(_fun,_id1,_id).
buildKey(_lit,_adIn,_id) :-
	functor(_lit,_fun,_),
	cToBList(_adIn,_ad),
	pc_atomtolist(_adAtom,_ad),
	pc_atomconcat([_fun,'AD',_adAtom],_id).

storeLitCost(_id,_fanOutInt) :-
	(
	  ( pc_current_key(_id,'QO_fanOutInt'),
	    pc_recorded(_id,'QO_fanOutInt',_costOld)
          );
	    _costOld = 0.0
	),!,
	save_plus(_costOld,_fanOutInt,_costNew),
	pc_rerecord(_id,'QO_fanOutInt',_costNew).

storeTotalCost(_id,_compCostInt) :-
	(
	  ( pc_current_key(_id,'QO_compCostInt'),
	    pc_recorded(_id,'QO_compCostInt',_costOld)
          );
	    _costOld = 0.0
	),
	save_plus(_costOld,_compCostInt,_costNew),
	pc_rerecord(_id,'QO_compCostInt',_costNew).
