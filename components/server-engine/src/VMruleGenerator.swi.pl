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
% File:         VMruleGenerator.pro
% Version:      11.3
% Creation:    1996, Christoph Quix (RWTH)
% Last Change: 01/19/98, Christoph Quix (RWTH)
% Date released : 98/01/19  (YY/MM/DD)
%
% SCCS-Source-Pool : /home/CBase/CB_NewStruct/ProductPOOL/SCCS/serverSources/Prolog_Files/s.VMruleGenerator.pro
% Date retrieved : 98/03/18 (YY/MM/DD)
%
% ----------------------------------------------------------------------------
%
% In this module, view-maintenance rules are generated from normal
% Datalog rules and stored via CodeCompiler and CodeStorage.
%
% Exported predicates:
% ---------------------
%    store_vm_rules/2  (LTcompiler and ViewCompiler)
% 		stores VM rules for a list of rules
%    get_relevant_rule/2  (cfixpoint)
%       retrieves for a given literal the relevant rules
%    load_vmrule/1   (PROLOGruleProcessor)
%       builds the record database for the rule
%

:- module('VMruleGenerator',[
'conjunction'/3
,'current_view'/3
,'del_rec_db'/3
,'get_rec_db'/3
,'get_relevant_rule'/2
,'is_delta'/1
,'load_vmrule'/1
,'store_rec_db'/3
,'store_vm_rules'/2
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').
:- use_module('CodeCompiler.swi.pl').
:- use_module('CodeStorage.swi.pl').
:- use_module('GeneralUtilities.swi.pl').
:- use_module('GlobalParameters.swi.pl').
:- use_module('RuleBase.swi.pl').
:- use_module('PrologCompatibility.swi.pl').
:- dynamic 'current_view'/3 .
:- style_check(-singleton).
% ***************************************************************
% ***************************************************************
%  Part 1
%  Generating view maintenance rules from Datalog rules
% ***************************************************************
% ***************************************************************
% ===================================================
%  store_vm_rules(_id,_list)
%
%  Transforms the Datalog rules from the list into
%  VM rules. _id is the Oid of the view/the rule/...
%  Algorithm from Staudt/Jarke 1995 (AIB 13)
%     Incremental maintenance of externally
%     materialized Views.
%
% ===================================================

store_vm_rules(view(_OID,_IDS,_Vartab),_rlist) :-
	get_cb_feature('ViewMaintenanceRules',on),
	pc_update(current_view(_OID,_IDS,_Vartab)),
	process_rules(_rlist).
store_vm_rules(_,_) :-
	get_cb_feature('ViewMaintenanceRules',off).
% ===================================================
%  process_rules(_list)
%
% ===================================================

process_rules([]).
process_rules([_r|_t]) :-
	store_delta_rules(_r),
	process_rules(_t).
% ===================================================
%  store_delta_rules(_rule)
%
% ===================================================

store_delta_rules((_head :- _body )) :-
	store_dis(_head,_body),
	store_nis(_head,_body),
	store_r(_head,_body),
	store_iis(_head,_body),
	store_eis(_head,_body).
store_delta_rules(_fact) :-
	_fact \= (_h :- _b).
% ===================================================
%  store_dis(_head,_body)
%
% ===================================================

store_dis(_head,_body) :-
	get_delta_bodies(_body,_delbodies,del),
	store_rules(del(_head),_delbodies).
% ===================================================
%  store_nis(_head,_body)
%
% ===================================================
 %  N1 rule not generated; proved with prove_literal instead.
 %  Otherwise N1 rules would not be recognized as relevant by cfixpoint.

store_nis(_head,_body) :-
%     store_rule((new(_head) :- _head , not del(_head))),
 %  N1

	store_rule((new(_head) :- red(_head))),  % N2
	store_rule((new(_head) :- ins(_head))).  % N3
% 	store_base_nis(_body).
  %  Already stored in cfixpoint
% ===================================================
%  store_base_nis(_head,_body)
%
% ===================================================
 %  Do not generate the N1 rule; it is proved with prove_literal instead.
 %  Otherwise N1 rules would not be recognized as relevant by cfixpoint.
 %  Also create N2 here, since ConceptBase has no unique
 %  distinction between base predicates (In, Adot, ...) and
 %  predicates derived from rules.

store_base_nis(_lit) :-
	_lit \= (_,_),
	base_literal(_lit),
% 	store_rule((new(_lit) :- _lit, not del(_lit))),
  %  N1

	store_rule((new(_lit) :- red(_lit))),  % N2
	store_rule((new(_lit) :- ins(_lit))).  % N3
store_base_nis(_lit) :-
	_lit \= (_,_),
	\+ base_literal(_lit).
store_base_nis((_lit,_lits)) :-
	store_base_nis(_lit),
	store_base_nis(_lits).

base_literal('Adot'(_,_,_,_)).
base_literal('A'(_,_,_)).
base_literal('Ai'(_,_,_,_)).
base_literal('In'(_,_)).
base_literal('Isa'(_,_)).
base_literal('From'(_,_)).
base_literal('To'(_,_)).
base_literal('UNIFIES'(_,_)).
base_literal('IDENTICAL'(_,_)).
base_literal('GE'(_,_)).
base_literal('LE'(_,_)).
base_literal('LT'(_,_)).
base_literal('GT'(_,_)).
base_literal('EQ'(_,_)).
base_literal('NE'(_,_)).
base_literal('TRUE').
base_literal('Known'(_,_)).
% ===================================================
%  store_r(_head,_body)
%
% ===================================================

store_r(_head,_body) :-
	add_body_functor(_body,new,_newbody),
	store_rule((red(_head) :- del(_head), _newbody)).
% ===================================================
%  store_iis(_head,_body)
%
% ===================================================

store_iis(_head,_body) :-
	get_delta_bodies(_body,_insbodies,ins),
	add_new_to_bodies(_insbodies,_newbodies),
	store_rules(ins(_head),_newbodies).
% ===================================================
%  store_eis(_head,_body)
%
% ===================================================

store_eis(_head,_body) :-
	store_rule((plus(_head) :- ins(_head), not(_head))),
	store_rule((minus(_head) :- del(_head), not(ins(_head)), not(red(_head)))).
% ===================================================
%  store_rules(_head,_bodylist)
%
% ===================================================

store_rules(_head,[]).
store_rules(_head,[_body1|_rbodies]) :-
	store_rule((_head :- _body1)),
	store_rules(_head,_rbodies).
%  The Prolog code of the generated rule for view maintenance is only
%  generated after optimization and then stored accordingly; here we
%  only perform simple initialization of the rule info for the VM rules.

store_rule((_head :-_tail)) :-
	current_view(_OID,_IDS,_Vartab),
%  Here RuleInfo initialization must return a unique ruleId as viewId.

	initDatalogRulesInfo(_head,_tail,vmrule,_OID,_IDS,_Vartab,_viewid),
	store_rule_info(_viewid,(_head :-_tail)).
% ===================================================
%  get_delta_bodies(_lits,_deltas,_head)
%
%  _lits is a rule body, _head is the functor
%  for the Deltaliteral, and _deltas is a list
%  of rule bodies with the inserted deltas
%
% ===================================================

get_delta_bodies(_lits,_deltas,_head) :-
	get_delta_bodies(true,_lits,_deltas,_head).
get_delta_bodies(true,(_first,_rest),[(_deltafirst,_rest)|_deltas],_head) :-
	!,
	create_delta(_first,_head,_deltafirst),
	get_delta_bodies(_first,_rest,_deltas,_head).
get_delta_bodies(true,_lit,[_deltalit],_head) :-
	_lit \= (_,_),
	!,
	create_delta(_lit,_head,_deltalit).
get_delta_bodies(_lits,(_first,_rest),[_body|_deltas],_head) :-
	_lits \= true,
	!,
	create_delta(_first,_head,_deltafirst),
	conjunction((_deltafirst,_lits),_rest,_body),
	conjunction(_lits,_first,_flits),
	get_delta_bodies(_flits,_rest,_deltas,_head).
get_delta_bodies(_lits,_first,[(_deltafirst,_lits)],_head) :-
	_lits \= true,
	_first \= (_,_),
	create_delta(_first,_head,_deltafirst).
% ===================================================
%  conjunction(_r1,_r2,_r3)
%
%  Joins two rule bodies while preserving correct
%  parenthesization (i.e., without adding extra
%  parentheses).
%
% ===================================================

conjunction(_lit,_rest,(_lit,_rest)) :-
	_lit \= (_,_).
conjunction((_first,_lits),_rest,(_first,_restlits)) :-
	conjunction(_lits,_rest,_restlits).
% ===================================================
%  add_body_functor(_lits,_func._flits)
%
%  Adds the functor _func to each literal in the
%  rule body.
%
% ===================================================

add_body_functor(_lit,_f,_flit) :-
	_lit \= (_,_),
	create_delta(_lit,_f,_flit).
add_body_functor((_lit,_rlits),_f,(_flit,_frlits)) :-
	add_body_functor(_lit,_f,_flit),
	add_body_functor(_rlits,_f,_frlits).
% ===================================================
%  add_new_to_bodies(_bodylist,_newbodylist)
%
%  Every literal in the body list additionally
%  receives the functor new(_l), unless it already
%  has the form ins(_).
%
% ===================================================

add_new_to_bodies([],[]).
add_new_to_bodies([_h|_t],[_newh|_newt]) :-
	add_new_to_bodies2(_h,_newh),
	add_new_to_bodies(_t,_newt).

add_new_to_bodies2(_lit,_newlit) :-
	_lit \= (_,_),
	((_lit \= ins(_), _lit \= del(_), _lit \= minus(_), _lit \= plus(_),
	   create_delta(_lit,new,_newlit)
	 );
	 ( is_delta(_lit), _lit \= red(_),lit \= new(_),
	  _newlit = _lit
	)).
add_new_to_bodies2((_lit,_rlits),(_newlit,_newrlits)) :-
	add_new_to_bodies2(_lit,_newlit),
	add_new_to_bodies2(_rlits,_newrlits).
% ===================================================
%  create_delta(_lit,_functor,_deltalit)
%
% ===================================================

create_delta(not(_l),del,plus(_l)).
create_delta(not(_l),ins,minus(_l)).
create_delta(not(_l),new,not(new(_l))).
create_delta(_l,del,del(_l)) :- _l \= (not(_)).
create_delta(_l,ins,ins(_l)) :- _l \= (not(_)).
create_delta(_l,new,new(_l)) :- _l \= (not(_)).

is_delta(ins(_)).
is_delta(del(_)).
is_delta(red(_)).
% is_delta(new(_)).

is_delta(plus(_)).
is_delta(minus(_)).
% ***************************************************************
% ***************************************************************
%  Part 2
%  Loading, storing, and deleting rules
% ***************************************************************
% ***************************************************************
% ***************************************************************
%
%  load_vmrule(_vmrule)
%
%  Description of arguments:
%   vmrule : term of the form vmrule(id, rule)
%
%  Description of predicate:
%   The PROLOGruleProcessor loads the rules from OB.rule. For the
%   VM rules, an index is created with store_rule_info for efficient
%   access.
% ***************************************************************

load_vmrule(vmrule(_id,_r)) :-
	store_rule_info(_id,_r),
	assert(vmrule(_id,_r)).
% ***************************************************************
%
%  store_rule_info(_id,_rule)
%
%  Description of arguments:
%       id   : rule ID (not an object-store ID!)
%     rule   : the rule
%
%  Description of predicate:
%    For each delta predicate, the rules in which it occurs are
%    stored. This lets cfixpoint access the relevant rules faster,
%    i.e., the rules in which something has changed.
% ***************************************************************

store_rule_info(_id,_r) :-
	get_delta(_r,_delta),
	store_info(_id,_delta),
	fail.
store_rule_info(_id,_r).

store_info(_id,_delta) :-
	_delta =..[_f,_lit],
	compute_key(_lit,_f,_key,_domain),
	store_rec_db(_key,_domain,_id),
	!.

get_delta((_head :- _body),_delta) :-
	get_delta(_body,_delta).
get_delta((_delta,_rest),_delta) :-
	is_delta(_delta).
get_delta((_,_rest),_delta) :-
	get_delta(_rest,_delta).
get_delta(_delta,_delta) :-
	_delta \= (_,_),
	is_delta(_delta).
% ***************************************************************
%
%  compute_key(_lit,_delta,_key,_domain)
%
%  Description of arguments:
%  lit   : literal (without delta) for which the key is computed
%  delta : delta functor as an atom
%  key   : key
%  domain: record-database domain
%
%  Description of predicate:
%    For the literal delta(lit), a key is computed. The key consists
%    of the word 'key' and the bound variables of the literal
%    (for In(_x, id) the key is 'keyid'). domain has the prefix
%    'VM_' with delta, the literal's functor, and the binding
%    pattern as suffixes (for In(_x, id) with delta ins the domain
%    is 'VM_insInfb').
% ***************************************************************

compute_key(_lit,_delta,_key,_domain) :-
	_lit =.. [_f|_args],
	compute_key2(_args,_pat,'key',_key),
	pc_atomconcat(['VM_',_delta,_f,_pat],_domain).

compute_key2([],'',_k,_k).
compute_key2([_h|_r],_pat,_k,_k2) :-
	(var(_h);variable(_h)),
	compute_key2(_r,_pat2,_k,_k2),
	pc_atomconcat(f,_pat2,_pat).
compute_key2([_h|_r],_pat,_k,_k3) :-
        getArgSave(_h,_hatom),  % 9-Jul2004/M.Jeusfeld
	pc_atomconcat(_k,_hatom,_k2),
	compute_key2(_r,_pat2,_k2,_k3),
	pc_atomconcat(b,_pat2,_pat).
% ***************************************************************
%
%  get_relevant_rule(_lit,_rule)
%
%  Description of arguments:
%      lit : a delta literal
%     rule : a rule in which lit occurs
%
%  Description of predicate:
%    Fetches the corresponding rules for delta literal lit (via backtracking).
% ***************************************************************

get_relevant_rule(_lit,_r) :-
	generate_keys(_lit,_key,_domain),
	pc_current_key(_key,_domain),
	get_rec_db(_key,_domain,_id),
	pc_recorded(vmrules,'VMruleGenerator',_ruleids),
	member(_id,_ruleids),
	vmrule(_id,_r),
	bind_vars(_lit,_r).
% ***************************************************************
%
%  bind_vars(_lit,_rule)
%
%  Description of arguments:
%      lit : literal with variable bindings
%     rule : rule whose variables are to be bound
%
%  Description of predicate:
%    A delta literal contains variables that also appear in the rule.
%    During evaluation these variables must be bound consistently,
%    because they may occur multiple times in the rule.
% ***************************************************************

bind_vars(_lit,_lit) :-!.
bind_vars(_lit,(_r:-_b)) :-
	bind_vars(_lit,_b),
	!.
bind_vars(_lit,(_lit,_r)) :-!.
bind_vars(_lit,(_,_r)) :-
	bind_vars(_lit,_r),
	!.
bind_vars(_lit,_):-!.
% ***************************************************************
%
%  generate_keys(_lit,_key,_domain)
%
%  Description of predicate:
%    For the delta literal, all possible keys must be generated. In
%    lit itself all arguments are bound, but the literal may be used
%    with free variables in a rule body. Therefore all possible
%    binding patterns must be generated via backtracking (see
%    compute_key).
%
% ***************************************************************

generate_keys(_lit,_key,_domain) :-
	_lit =.. [_delta,_lit2],
	_lit2 =.. [_f|_args],
	generate_keys2(_args,_pat,'key',_key),
	pc_atomconcat(['VM_',_delta,_f,_pat],_domain).

generate_keys2([],'',_k,_k).
generate_keys2([_h|_r],_pat,_k,_k2) :-
	generate_keys2(_r,_pat2,_k,_k2),
	pc_atomconcat(f,_pat2,_pat).
generate_keys2([_h|_r],_pat,_k,_k3) :-
        getArgSave(_h,_hatom),  % 9-Jul2004/M.Jeusfeld
	pc_atomconcat(_k,_hatom,_k2),
	generate_keys2(_r,_pat2,_k2,_k3),
	pc_atomconcat(b,_pat2,_pat).
%  Since the introduction of complex query calls (CBNEWS[215]
%  arguments of query literals can be other query literals.
%  Hence, the old assumption that an argument is either an
%  atom or a variable ('_*') is no longer true. getArgSave
%  returns for query literals their functor, which is always
%  an atom. This solves the problem of wrong calls of
%  pc_atomconcat.

getArgSave(_a,_a) :- atom(_a),!.
getArgSave(_x,_x) :- var(_x),!.
getArgSave(_qlit,_qid) :-
  compound(_qlit),
  _qlit =.. [_qid|_].
% * RECORD-DATABASE *
%  Storing

store_rec_db(_key,_value) :-
	store_rec_db(_key,0,_value).
%  case 1: key already used, therefore extend the value list

store_rec_db(_key,_domain,_value) :-
	pc_recorded(_key,_domain,_old),
	pc_rerecord(_key,_domain,[_value|_old]),
	!.
%  case 2: key unused, therefore store value as list

store_rec_db(_key,_domain,_value) :-
	pc_record(_key,_domain,[_value]),
	!.
%  Access

get_rec_db(_key,_value) :-
	get_rec_db(_key,0,_value).
get_rec_db(_key,_domain,_value) :-
	pc_recorded(_key,_domain,_list),
	%  Retrieve each element from the list via backtracking

	member(_value,_list).
%  Delete an element

del_rec_db(_key,_domain,_value) :-
	pc_recorded(_key,_domain,_old),
	delete(_value,_old,_new),
	((_new \= [],pc_rerecord(_key,_domain,_new));
	 (_new =[],pc_erase(_key,_domain))
	),
	!.
