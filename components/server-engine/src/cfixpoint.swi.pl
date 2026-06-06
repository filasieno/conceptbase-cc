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
%
%
% File:         cfixpoint.pro
% Version:      11.3
% Creation:    24-July-1990 Martin Staudt (UPA)
% Last Change   : 96/10/28, Christoph Quix (RWTH)
%
% SCCS-Source-Pool : /home/CBase/CB_NewStruct/ProductPOOL/serverSources/Prolog_Files/SCCS/s.cfixpoint.pro
% Date retrieved : 97/06/03 (YY/MM/DD)
% -----------------------------------------------------------------------------
%
% This Prolog module is part of the ConceptBase system which is a run-time
% system for the System Modelling Language (SML).
%
%
% 21-Jan-1993/DG: AttrValue is changed into A and InstanceOf into In by deleting the
% time component (see CBNEWS[154])
%
% 26-Apr-1993/MSt: changes concerning Adot instead of A
%
%

:- module('cfixpoint',[
'base_predicate'/1
,'deduce'/2
,'fact'/1
,'ofact'/1
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').
:- dynamic 'fact'/1 .
:- dynamic 'nfact'/1 .
:- dynamic 'ofact'/1 .
:- dynamic 'conditional_statement'/1 .
:- dynamic 'nconditional_statement'/1 .
:- dynamic 'oconditional_statement'/1 .
:- dynamic 'new_inf_generated'/1 .
:- use_module('PROLOGruleProcessor.swi.pl').
:- use_module('Literals.swi.pl').
:- use_module('GeneralUtilities.swi.pl').
:- use_module('RuleOptimizer.swi.pl').
:- use_module('ViewMonitor.swi.pl').
:- use_module('VMruleGenerator.swi.pl').
:- use_module('SearchSpace.swi.pl').
:- use_module('validProposition.swi.pl').
:- use_module('CodeCompiler.swi.pl').
:- use_module('PrologCompatibility.swi.pl').
:- style_check(-singleton).
%  ***************************** d e d u c e ************************************
%
%  ******************************************************************************

deduce(_goal,_solutions) :-
	establish_ded_goals(_goal),
	%  Phase 1: generate new facts and conditional statements

	start_derivation_phase,
	%  Phase 2: stepwise remove the negated literals of the conditional statements.
	% 	   If all of these can be removed, a new fact has been found.

	start_rewriting_phase,
	!,
	get_ded_solutions(_solutions).
%  **************** s t a r t _ d e r i v a t i o n _ p h a s e *****************
%
%  ******************************************************************************

start_derivation_phase :-
	derive_all.
%  ****************** s t a r t _ r e w r i t i n g _ p h a s e *****************
%
%  ******************************************************************************

start_rewriting_phase :-
	rewrite_all.
%  *********************** e s t a b l i s h _ d e d _ g o a l ******************
%
%  ******************************************************************************

establish_ded_goals([]).
establish_ded_goals([_f|_r]) :-
	establish_ded_goal(_f),
	establish_ded_goals(_r).

establish_ded_goal(_goal) :-
	_goal \= [_|_],!,
	assert(query_goal(_goal)),
	((doing_view_maintenance(no),
	  assert(fact(_goal)),
	  assert(ofact(_goal))
	 );
	 (doing_view_maintenance(_x),
	  _x \== no
	 )
	).
%  *********************** g e t _ d e d _ s o l u t i o n s ******************
%
%  ****************************************************************************

get_ded_solutions(_solutions) :-
	setof(_qgoal,query_goal(_qgoal),_qgoals),
	get_solution(_qgoals,_solutions),
	retractall(fact(_)),
	retractall(query_goal(_)).
get_ded_solutions([]).

get_solution([],[]).
get_solution([_qgoal|_r],_res) :-
	build_goal(_qgoal,_goal),
	setof(_goal,fact(_goal),_solutions),!,
	get_solution(_r,_sol),
	append(_solutions,_sol,_res).
get_solution([_|_r],_res) :-
	get_solution(_r,_res).

build_goal(plus_f,plus(_x)).
build_goal(minus_f,minus(_x)).
build_goal(_qgoal,_goal) :-
	_qgoal =..[_qf|_args],
	pc_atomconcat('query_',_f,_qf),
	get_binding_pattern(_f,_p),
	pc_atomtolist(_p,_pl),
	insert_args(_pl,_args,_nargs),
	_goal =..[_f|_nargs],!.

insert_args([],[],[]).
insert_args([_f|_r],[],[_|_res]) :-
	insert_args(_r,[],_res).
insert_args([b|_pr],[_arg|_rargs],[_arg|_nargs]) :-
	insert_args(_pr,_rargs,_nargs).
insert_args([f|_pr],_args,[_|_nargs]) :-
	insert_args(_pr,_args,_nargs).
%  **************************** d e r i v e _ a l l *****************************
%
%  ******************************************************************************

derive_all :-
	do_derive.
derive_all :-
	pc_update(new_inf_generated(no)),
	retractall(ofact(_)),
	retractall(oconditional_statement(_)),
	update_results,
	derive_all,!.
derive_all.
%  ****************************** d e r i v e ***********************************
%
%  ******************************************************************************
%  derive describes one derivation step

derive :-
	do_derive.
derive :-
	pc_update(new_inf_generated(no)),
	update_results,!.
derive.
%  ************************** r e w r i t e _ a l l *****************************
%
%  ******************************************************************************

rewrite_all :-
	do_rewrite.
rewrite_all :-
	pc_update(new_inf_generated(no)),
	retractall(conditional_statement(_)),
	update_results,
	rewrite_all,!.
rewrite_all.
%  ******************************* r e w r i t e ********************************
%
%  ******************************************************************************

rewrite :-
	do_rewrite.
rewrite :-
	pc_update(new_inf_generated(no)),
	retractall(conditional_statement(_)),
	update_results,!.
rewrite.
%  ************************ d o _ r e w r i t e *********************************
%
%  ******************************************************************************

do_rewrite :-
	conditional_statement((_head :- _body)),
	rewrite_neg_conjunction(_body,_rest),
	reduce(_rest,_nrest),
	(
	(_nrest \== true,
	 not(conditional_statement((_head :- _nrest))),
	 not(nconditional_statement((_head :- _nrest))),
	 assert(nconditional_statement((_head :- _nrest)))
        );
        (_nrest == true,
		not(fact(_head)),
		assert(fact(_head))
        )
        ),
	fail.
%  **************** r e w r i t e _ n e g _ c o n j u n c t i o n ***************
%
%  ******************************************************************************
%  _goal is not derivable. Thus it can be removed from the body of the conditional statement.
%

rewrite_neg_conjunction(not(_goal),true) :-
	not(derivable(_goal)),!.
%  _goal is not a fact, but occurs as the conclusion of a conditional statement

rewrite_neg_conjunction(not(_goal),not(_goal)) :-
	not(fact(_goal)),
	cond_derivable(_goal),!.
%  _goal is not derivable. Therefore it can be removed from the body of the conditional statement.
%

rewrite_neg_conjunction((not(_goal),_neggoals),_rest) :-
	not(derivable(_goal)),
	rewrite_neg_conjunction(_neggoals,_rest),!.
%  _goal is not a fact, but occurs as the conclusion of a conditional statement

rewrite_neg_conjunction((not(_goal),_neggoals),(not(_goal),_rest)) :-
	not(fact(_goal)),
	cond_derivable(_goal),
	rewrite_neg_conjunction(_neggoals,_rest),!.
%  ************************** d e r i v a b l e *********************************
%
%  ******************************************************************************

derivable(_goal) :-
	fact(_goal).
derivable(_goal) :-
	cond_derivable(_goal).
derivable(new(_x)) :-
	prove_new_literal(_x),
	store(new(_x),true).
derivable(_goal) :-
	base_predicate(_goal),
	_goal.

cond_derivable(_goal) :-
	conditional_statement((_goal :- _)).
%  *********************** u p d a t e _ r e s u l t s **************************
%
%  ******************************************************************************

update_results :-
	retract(nfact(_goal)),
	not(nfact(_goal)),
    assert(fact(_goal)),
	assert(ofact(_goal)),
	pc_update(new_inf_generated(yes)),
	fail.
update_results :-
	retract(nconditional_statement((_head :- _body))),
	not(nconditional_statement((_head :-_body))),
	assert(conditional_statement((_head :- _body))),
	assert(oconditional_statement((_head :- _body))),
	pc_update(new_inf_generated(yes)),
	fail.
update_results :-
	new_inf_generated(yes).
%  *************************** d o _ d e r i v e ********************************
%
%  ******************************************************************************
%  from the current state (fact/conditional_statement), all possible new information
%  (nfact/nconditional_statement) is derived and stored.

do_derive :-
	%  choose any relevant rule
	%

   select_rule((_head :- _body)),
	%  test whether the body of the rule is satisfied. In _rest are those literals that could be satisfied, which have been replaced by true.
	%

	prove(_body,_rest),
	%  store new information as nfact or nconditional_statement

	store(_head,_rest),
	fail.
%  ******************************* p r o v e ************************************
%
%  ******************************************************************************
%  goals that are provable (i.e. there are facts for them) can be replaced by true in the body of the rule). prove/2 is successful at least once, since it was already tested before whether the rule is relevant.
%

prove((_fgoal,_rgoals),_rest) :-
	prove_goal(_fgoal,_frest),
	prove(_rgoals,_rrest),
	conjunction(_frest,_rrest,_rest).
prove(_goal,_rest) :-
	_goal \= (_,_),
	prove_goal(_goal,_rest).
%  ************************** p r o v e _ g o a l *******************************
%
%  ******************************************************************************

prove_goal(not(_goal),not(_goal)) :- !.
prove_goal(_goal,_rest) :-
	ground(_goal),
	!,
	prove_ground_goal(_goal,_rest).
prove_goal(_goal,_rest) :-
	prove_partial_goal(_goal,_rest).
%  case 1: the goal can be unified with an already derived fact

prove_partial_goal(_goal,true) :-
    fact(_goal);
	nfact(_goal).
%  new(_x) is no longer proved via VM rules, but directly via
% prove_literal

prove_partial_goal(new(_x),true) :-
        prove_new_literal(_x),
        store(new(_x),true).
%  case 2: the goal can be unified with an EDB predicate. _goal is usually a prove_literal/1 term.

prove_partial_goal(_goal,true) :-
        base_predicate(_goal),
        _goal.
prove_partial_goal(_goal,_cond):-
        conditional_statement((_goal :- _cond));
        nconditional_statement((_goal :- _cond)).

prove_ground_goal(_goal,true) :-
    fact(_goal);
	nfact(_goal),
	!.
prove_ground_goal(new(_x),true) :-
	prove_new_literal(_x),
	store(new(_x),true),
	!.
prove_ground_goal(_goal,true) :-
	base_predicate(_goal),
	_goal,
	!.
%  case 3: negated literals remain in the body of a rule; they are only removed in the second phase
%  prove_goal(not(_goal),not(_goal)) :- !.
 %  see above
%  case 4: There is a conditional statement whose head can unify with _goal. Then the body of this conditional statement is substituted for _goal.
%

prove_ground_goal(_goal,_cond):-
	conditional_statement((_goal :- _cond));
	nconditional_statement((_goal :- _cond)).
	%  No cut here, since various conditions possible
%  ******************************** s t o r e ***********************************
%
%  ******************************************************************************

store(_head,_body) :-
	%  delete as many 'true' literals as possible from the body of a conditional statement

	reduce(_body,_nbody),
	%  if the reduced body consists only of 'true', the derived information is a new fact.
	% 	   otherwise it is a conditional statement. if it is not yet known, it is stored.

	((_nbody == true,
	  not(fact(_head)),
	  not(nfact(_head)),
	  assert(nfact(_head))
	 );
	 (_nbody \== true,
      not(conditional_statement((_head :- _nbody))),
      not(nconditional_statement((_head :- _nbody))),
      assert(nconditional_statement((_head :- _nbody)))
	 );
	 true
	),
	!.
%  ******************************* r e d u c e **********************************
%
%  ******************************************************************************
%  the bodies currently still contain many 'true' literals.
%    this function strips them out

reduce((_goal,_rgoals),(_goal,_nrgoals)) :-
	_goal \== true,
	_rgoals \== true,
	reduce(_rgoals,_nrgoals).
reduce((_goal,true),_goal).
reduce((true,_rgoals),_nrgoals) :-
	_rgoals \== true,
	reduce(_rgoals,_nrgoals).
reduce(_goal,_goal) :-
	_goal \= (_,_).
%  ************************ b a s e _ p r e d i c a t e *************************
%
%  ******************************************************************************

base_predicate(rA(_,_,_,_)).
base_predicate(rInstanceOf(_,_,_)).
base_predicate(rIsA(_,_,_)).
base_predicate(prove_literal(_x)).
base_predicate(prove_new_literal(_x)).
base_predicate(prove_old_literal(_x)).
base_predicate(attribute(_x)).
base_predicate(_goal) :-
	pc_has_a_definition(_goal),
	\+(is_delta(_goal)),
	_goal \= new(_),
	functor(_goal,_fun,_ar),
	specialFunctor(_fun,_ar).
% ===================================================
%  rule(_r)
%
%  fetches the relevant rules during fixpoint evaluation.
%  for magic evaluation these are the "mrules" and some builtin magic rules.
%
%  for view maintenance, in phase 1 these are the
%  get_del/get_ins_rules that compute insertions/deletions of literals (In, Adot,
%  ...) from P tuples. in later phases these are the
%  stored VM rules and the builtin VM rules for new.
%
% ===================================================
%  Magic-Set-Rules

rule(_r) :- magic_rule(_r).
rule(_r) :- get_tmp_PROLOGrules([mrule(_r)]).
rule(_r) :- get_PROLOGrule(mrule(_r),true).
% ===================================================
%  magic_rule(_r)
%
%  Note: Are not complete.
% ===================================================

magic_rule(('Adot_bbb'(_id,_x,_y) :- query_Adot_bbb(_id,_x,_y), prove_literal('Adot'(_id,_x,_y)))).
magic_rule(('Adot_bbf'(_id,_x,_y) :- query_Adot_bbf(_id,_x),prove_literal('Adot'(_id,_x,_y)))).
magic_rule(('Adot_bfb'(_id,_x,_y) :- query_Adot_bfb(_id,_y),prove_literal('Adot'(_id,_x,_y)))).
magic_rule(('Adot_bff'(_id,_x,_y) :- query_Adot_bff(_id),prove_literal('Adot'(_id,_x,_y)))).
magic_rule(('Adot_label_bbbf'(_id,_x,_y,'DEDUCED') :- query_Adot_label_bbbf(_id,_x,_y), 'Adot_bbbb'(_id,_x,_y))).
magic_rule(('Adot_label_bbff'(_id,_x,_y,'DEDUCED') :- query_Adot_label_bbff(_id,_x),'Adot_bbbf'(_id,_x,_y))).
magic_rule(('Adot_label_bfbf'(_id,_x,_y,'DEDUCED') :- query_Adot_label_bfbf(_id,_y),'Adot_bfb'(_id,_x,_y))).
magic_rule(('Adot_label_bfff'(_id,_x,_y,'DEDUCED') :- query_Adot_label_bfff(_id),'Adot_bff'(_id,_x,_y))).
magic_rule((query_Adot_bbb(_id,_x,_y) :- query_Adot_label_bbbf(_id,_x,_y))).
magic_rule((query_Adot_bbf(_id,_x) :- query_Adot_label_bbff(_id,_x))).
magic_rule((query_Adot_bfb(_id,_y) :- query_Adot_label_bfbf(_id,_y))).
magic_rule((query_Adot_bff(_id) :- query_Adot_label_bfff(_id))).
magic_rule(('In_bb'(_i,_c) :- query_In_bb(_i,_c),prove_literal('In'(_i,_c)))).
magic_rule(('In_bf'(_i,_c) :- query_In_bf(_i),prove_literal('In'(_i,_c)))).
magic_rule(('In_fb'(_i,_c) :- query_In_fb(_c),prove_literal('In'(_i,_c)))).
magic_rule(('In_ff'(_i,_c) :- query_In_ff,prove_literal('In'(_i,_c)))).
magic_rule(('GE_bb'(_i1,_i2) :- query_GE_bb(_i1,_i2),prove_literal('GE'(_i1,_i2)))).
% ===================================================
%  base_new_rule(_r)
%
%  these rules are the Ni-rules that no longer need
%  to be generated for each base predicate
%
% ===================================================

base_rule(_r) :-
	% base_new_rule(_r);

	base_A_rule(_r);
	base_label_rule(_r);
	base_red_rule(_r)  % ;
	% base_plus_rule(_r);
  %  temporarily commented out due to performance
	% base_minus_rule(_r)

.  % should also work this way, because only views matter
base_new_rule((new(_lit) :- ins(_lit))) :- base_lit(_lit).
base_new_rule((new(_lit) :- red(_lit))) :- base_lit(_lit).
%  rules for A-literal (derive from Adot)

base_A_rule((ins('A'(_b,_c,_d)) :-
	ins('Adot'(_a,_b,_d)))).
base_A_rule((del('A'(_b,_c,_d)) :-
	del('Adot'(_a,_b,_d)))).
%  Rules for Adot_label and A_label

base_label_rule((ins('Adot_label'(_a,_b,_d,_e)) :-
	ins('Adot'(_a,_b,_d)),
	prove_new_literal('Adot_label'(_a,_b,_d,_e)))).
base_label_rule((del('Adot_label'(_a,_b,_d,_e)) :-
	del('Adot'(_a,_b,_d)),
	prove_old_literal('Adot_label'(_a,_b,_d,_e)))).
base_label_rule((ins('A_label'(_a,_b,_c,_d)) :-
	ins('A'(_a,_b,_c)),
	prove_new_literal('A_label'(_a,_b,_c,_d)))).
base_label_rule((del('A_label'(_a,_b,_c,_d)) :-
	del('A'(_a,_b,_c)),
	prove_old_literal('A_label'(_a,_b,_c,_d)))).
%  only A/Adot among the base literals can be "rederived",
%   because an attribute can have different labels with the same value

base_red_rule((red('Adot'(_a,_b,_d)) :- del('Adot'(_a,_b,_d)), new('Adot'(_a,_b,_d)))).
base_red_rule((red('A'(_a,_b,_c)) :- del('A'(_a,_b,_c)), new('A'(_a,_b,_c)))).
base_red_rule((red('Adot_label'(_a,_b,_d,_e)) :- del('Adot_label'(_a,_b,_d,_e)), new('Adot_label'(_a,_b,_d,_e)))).
base_red_rule((red('A_label'(_a,_b,_c,_d)) :- del('A_label'(_a,_b,_c,_d)), new('A_label'(_a,_b,_c,_d)))).

base_plus_rule((plus(_lit) :- ins(_lit), not(prove_literal(_lit)))) :- base_lit(_lit).

base_minus_rule((minus(_lit) :- del(_lit), not(ins(_lit)), not(red(_lit)))) :- base_lit(_lit).

base_lit('Adot'(_a,_b,_d)).
base_lit('A'(_a,_b,_c)).
base_lit('Adot_label'(_a,_b,_d,_e)).
base_lit('A_label'(_a,_b,_c,_d)).
base_lit('In'(_a,_b)).
base_lit('Isa'(_a,_b)).
base_lit('From'(_a,_b)).
base_lit('To'(_a,_b)).
base_lit('Label'(_a,_b)).
%  ************************** s e l e c t _ r u l e ***************************
%
%  ****************************************************************************
%  Select a rule in whose body a fact or a conditional statement occurs,
%   that was generated in the last step.
%  New version with connection between Deltas and associated rules CQ/1997
%  case 1: Get an ofact/ocond and then the associated rule

select_rule(_r) :-
	doing_view_maintenance(_a),
	_a \== no,
	(ofact(_lit);oconditional_statement((_lit :- _))),
	is_delta(_lit),
	get_relevant_rule(_lit,_r).
%  case 2: examine the base rule for new

select_rule((_h :- _b)) :-
	doing_view_maintenance(_a),
	_a \== no,
	base_rule((_h :- _b)),
	base_relevant(_b).
%  version for the normal fixpoint evaluator:
% first select all rules, and then check whether the body contains
%  an ofact or oconditional

select_rule((_head :- _body)) :-
	doing_view_maintenance(no),
	rule((_head :- _body)),
    relevant(_body).

base_relevant((_l,_r)) :-
	relevant(_l).
base_relevant(_l) :-
	_l \= (_,_),
	relevant(_l).

relevant((_goal,_rgoals)) :-
	relevant(_goal).
relevant((_,_goals)) :-
	relevant(_goals).
relevant(_goal) :-
	_goal \= (_,_),
	_goal \= new(_),
	ofact(_goal).
relevant(_goal) :-
	_goal \= (_,_),
	_goal \= new(_),
	oconditional_statement((_goal :- _)).
% ===================================================
%  prove_new_literal(_lit)
%
%  Tests whether the literal also holds in the new state.
%
% ===================================================
%  try prove_literal on new OB

prove_new_literal(_x) :-
	get_KBsearchSpace(_oldsp,_oldtt),
	set_KBsearchSpace(newOB,'Now'),
	prove_literal(_x),
	resetNewSearchSpace(_oldsp,_oldtt).
%  try the base_predicate on new OB

prove_new_literal(_x) :-
	get_KBsearchSpace(_oldsp,_oldtt),
	set_KBsearchSpace(newOB,'Now'),
	base_predicate(_x),
	_x,
	resetNewSearchSpace(_oldsp,_oldtt).
%  If nothing works, reset to oldOB and exit

prove_new_literal(_x) :-
	set_KBsearchSpace(oldOB,'Now'),
	fail.

resetNewSearchSpace(_sp,_tt) :-
	set_KBsearchSpace(_sp,_tt).
% REDO

resetNewSearchSpace(_sp,_tt) :-
	set_KBsearchSpace(newOB,'Now'),
	fail.
% ===================================================
%  prove_old_literal(_lit)
%
%  Tests whether the literal also holds in the old state.
%
% ===================================================

prove_old_literal(_x) :-
	get_KBsearchSpace(_oldsp,_oldtt),
	set_KBsearchSpace(oldOB,'Now'),
	prove_literal(_x),
	resetOldSearchSpace(_oldsp,_oldtt).
prove_old_literal(_x) :-
	get_KBsearchSpace(_oldsp,_oldtt),
	set_KBsearchSpace(oldOB,'Now'),
	base_predicate(_x),
	_x,
	resetOldSearchSpace(_oldsp,_oldtt).
prove_old_literal(_x) :-
	set_KBsearchSpace(oldOB,'Now'),
	fail.

resetOldSearchSpace(_sp,_tt) :-
	set_KBsearchSpace(_sp,_tt).
% REDO

resetOldSearchSpace(_sp,_tt) :-
	set_KBsearchSpace(oldOB,'Now'),
	fail.
