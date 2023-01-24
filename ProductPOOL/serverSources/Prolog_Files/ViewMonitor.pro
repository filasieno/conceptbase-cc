{*
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


This license is a FreeBSD-style copyright license.
Legal home of the FreeBSD copyright license: http://www.freebsd.org/copyright/freebsd-license.html
*}
{
*
* File:         ViewMonitor.pro
* Version:      11.2
* Creation:    1996, Christoph Quix (RWTH)
* Last Change: 10/28/96, Christoph Quix (RWTH)
* Date released : 96/10/28  (YY/MM/DD)
*
* SCCS-Source-Pool : /home/CBase/CB_NewStruct/ProductPOOL/serverSources/Prolog_Files/SCCS/s.ViewMonitor.pro
* Date retrieved : 96/12/04 (YY/MM/DD)
*
*----------------------------------------------------------------------------
*
* Hier wird der Sichtenwartungsalgorithmus gestartet.
*
*
* Exported predicates:
*---------------------
*    start_view_maintenance/3 to ObjectProcessor
*    doing_view_maintenance/1 to cfixpoint
*
* Change history :
* ----------------
*  None
*}


#MODULE(ViewMonitor)
#EXPORT(doing_view_maintenance/1)
#EXPORT(get_derive_exp_for_subqueries/3)
#EXPORT(get_derive_exp_for_subviews/2)
#EXPORT(get_rules_for_vm/2)
#EXPORT(if_exist_view/0)
#EXPORT(start_view_maintenance/3)
#EXPORT(store_rules_for_topdown_vm/1)
#ENDMODDECL()


#IMPORT(deduce/2,cfixpoint)
#IMPORT(prove_literal/1,Literals)
#IMPORT(set_KBsearchSpace/2,SearchSpace)
#IMPORT(get_KBsearchSpace/2,SearchSpace)
#IMPORT(evaluate_view_wo_mat/3,ViewEvaluator)
#IMPORT(notifyClients/2,ClientNotification)
#IMPORT(name2id/2,GeneralUtilities)
#IMPORT(id2name/2,GeneralUtilities)
#IMPORT(split_atom/4,GeneralUtilities)
#IMPORT(member/2,GeneralUtilities)
#IMPORT(append/3,GeneralUtilities)
#IMPORT(save_setof/3,GeneralUtilities)
#IMPORT(length/2,GeneralUtilities)
#IMPORT(convert_label/3,GeneralUtilities)
#IMPORT(fact/1,cfixpoint)
#IMPORT(ofact/1,cfixpoint)
#IMPORT(base_predicate/1,cfixpoint)
#IMPORT(retrieve_temp_ins/1,PropositionProcessor)
#IMPORT(retrieve_temp_del/1,PropositionProcessor)
#IMPORT(Query/1,QueryCompiler)
#IMPORT(View/2,QueryCompiler)
#IMPORT(SubQuery/2,QueryCompiler)
#IMPORT(get_QueryStruct/2,QueryCompiler)
#IMPORT(transform_subquery_update_elem/5,AnswerTransformator)
#IMPORT(transform_main_update_elem/5,AnswerTransformator)
#IMPORT(notify/2,ClientNotification)
#IMPORT(WriteTrace/3,GeneralUtilities)
#IMPORT(prop2lit/3,PropositionsToLiterals)
#IMPORT(getRuleIdsForHead/3,Datalog2Algebra)
#IMPORT(getRuleIdsForHeads/3,Datalog2Algebra)
#IMPORT(generate_GenQueryArgs/5,QueryCompiler)
#IMPORT(fast_diff/3,ECAeventManager)
#IMPORT(pc_atomconcat/2,PrologCompatibility)
#IMPORT(pc_atomconcat/3,PrologCompatibility)
#IMPORT(pc_rerecord/2,PrologCompatibility)
#IMPORT(pc_rerecord/3,PrologCompatibility)
#IMPORT(pc_recorded/2,PrologCompatibility)
#IMPORT(pc_recorded/3,PrologCompatibility)
#IMPORT(pc_current_key/1,PrologCompatibility)
#IMPORT(pc_current_key/2,PrologCompatibility)
#IMPORT(pc_update/1,PrologCompatibility)
#IMPORT(pc_time/2,PrologCompatibility)
#IMPORT(pc_atompart/4,PrologCompatibility)
#IMPORT(pc_atom_to_term/2,PrologCompatibility)


{ Speichert den Modus: tell, untell, none }
#DYNAMIC(doing_view_maintenance/1)


{ temp. Praedikat zum Aufsammeln der Notifikationen }
#DYNAMIC(notifyTemp/2)


#DYNAMIC(view_maintenance_type/1)


#LOCAL(prove_ins_literal/1)
#LOCAL(prove_del_literal/1)
#LOCAL(prove_red_literal/1)
#LOCAL(prove_new_literal/1)
#LOCAL(prove_old_literal/1)
#LOCAL(prove_plus_literal/1)
#LOCAL(prove_minus_literal/1)

#DYNAMIC(prove_ins_literal/1)
#DYNAMIC(prove_del_literal/1)
#DYNAMIC(prove_red_literal/1)
#DYNAMIC(prove_new_literal/1)
#DYNAMIC(prove_old_literal/1)
#DYNAMIC(prove_plus_literal/1)
#DYNAMIC(prove_minus_literal/1)

#IF(SWI)
:- style_check(-singleton).
#ENDIF(SWI)


{===================================================}
{* start_view_maintenance(_mode)                   *}
{*                                                 *}
{* Holt die temporaeren Daten, speichert die in    *}
{* facts ab, und startet den Fixpunktauswerter.    *}
{*                                                 *}
{===================================================}
start_view_maintenance(_mode,_insdedlits,_deldedlits) :-
	pc_update(doing_view_maintenance(_mode)),
	{ if_exist_view, }
	pc_time(start_view_maintenance2(_mode,_insdedlits,_deldedlits),_T),
#IF(BIM)
	printf(stdout,'   %.2f sec used for View Maintenance\n',_T),
#ELSE(BIM)
    write('   '),write(_T),write(' sec used for View Maintenance'),nl,
#ENDIF(BIM)
	pc_update(doing_view_maintenance(no)).

start_view_maintenance(_mode,_,_) :-
	pc_update(doing_view_maintenance(no)).

start_view_maintenance2(_,_,_) :-
	views_for_maintenance(naiveVM,_views),
	_views \== [],
	!,
	evaluate_diffs(_views,_diffs),
	WriteTrace(veryhigh,ViewMonitor,['Solutions of View Maintenance:',_diffs]),
	output_solutions(_diffs).

start_view_maintenance2(_mode,_insdedlits,_deldedlits) :-
	views_for_maintenance(bottomUpVM,_views),
	_views \== [],
	!,
	WriteTrace(veryhigh,ViewMonitor,['Starting View Maintenance ...']),
	findall(P(_aa,_bb,_c,_d),retrieve_temp_ins(P(_aa,_bb,_c,_d)),_inslits1),
	findall(P(_aa,_bb,_c,_d),retrieve_temp_del(P(_aa,_bb,_c,_d)),_dellits1),
	prop2lit(Tell,_inslits1,_inslits2),
	prop2lit(Untell,_dellits1,_dellits2),
	retractall(fact(_)),
	retractall(ofact(_)),
	assert_facts(_inslits1,tell),
	assert_facts(_inslits2,tell),
	assert_facts(_insdedlits,tell),
	assert_facts(_dellits1,untell),
	assert_facts(_dellits2,untell),
	assert_facts(_deldedlits,untell),
	WriteTrace(veryhigh,ViewMonitor,['Inserted Propositions:',_inslits1]),
	WriteTrace(veryhigh,ViewMonitor,['Inserted Literals:',_inslits2]),
	WriteTrace(veryhigh,ViewMonitor,['New deduced literals by new inserted rules:',_insdedlits]),
	WriteTrace(veryhigh,ViewMonitor,['Deleted Propositions:',_dellits1]),
	WriteTrace(veryhigh,ViewMonitor,['Deleted Literals:',_dellits2]),
	WriteTrace(veryhigh,ViewMonitor,['Old deduced literals by deleted rules::',_deldedlits]),
	pc_rerecord(vmrules,VMruleGenerator,[]),
	init_rules_for_vm(_views),
	set_KBsearchSpace(oldOB,Now),
	deduce([plus_f,minus_f],_sol),
	WriteTrace(veryhigh,ViewMonitor,['Solutions of View Maintenance:',_sol]),
	output_solutions(_sol).

start_view_maintenance2(_mode,_insdedlits,_deldedlits) :-
	views_for_maintenance(topDownVM,_views),
	_views \== [],
	!,
	WriteTrace(veryhigh,ViewMonitor,['Starting View Maintenance ...']),
	findall(P(_aa,_bb,_c,_d),retrieve_temp_ins(P(_aa,_bb,_c,_d)),_inslits1),
	findall(P(_aa,_bb,_c,_d),retrieve_temp_del(P(_aa,_bb,_c,_d)),_dellits1),
	prop2lit(Tell,_inslits1,_inslits2),
	prop2lit(Untell,_dellits1,_dellits2),
	assert_facts(_inslits1,tell),
	assert_facts(_inslits2,tell),
	assert_facts(_insdedlits,tell),
	assert_facts(_dellits1,untell),
	assert_facts(_dellits2,untell),
	assert_facts(_deldedlits,untell),
	WriteTrace(veryhigh,ViewMonitor,['Inserted Propositions:',_inslits1]),
	WriteTrace(veryhigh,ViewMonitor,['Inserted Literals:',_inslits2]),
	WriteTrace(veryhigh,ViewMonitor,['New deduced literals by new inserted rules:',_insdedlits]),
	WriteTrace(veryhigh,ViewMonitor,['Deleted Propositions:',_dellits1]),
	WriteTrace(veryhigh,ViewMonitor,['Deleted Literals:',_dellits2]),
	WriteTrace(veryhigh,ViewMonitor,['Old deduced literals by deleted rules::',_deldedlits]),
	topdown_vm(_views,_sol),
	WriteTrace(veryhigh,ViewMonitor,['Solutions of View Maintenance:',_sol]),
	output_solutions(_sol).


if_exist_view :-
	name2id(View,_vid),
	prove_literal(In(_av,_vid)),
	id2name(_av,_viewname),
	(notify(_,view(_viewname));notify(_,view(derive(_viewname,_slist)))).



views_for_maintenance(_vmtype,_views) :-
	findall(view(_qid,_dexp,_dexps,_ruleids,_vmtype,_ans),
		(pc_current_key(_atomdexp,ViewMonitor),
		 pc_recorded(_atomdexp,ViewMonitor,view(_qid,_dexp,_dexps,_ruleids,_vmtype,_ans))
		),
		_views).




init_rules_for_vm([]).

init_rules_for_vm([view(_qid,_dexp,_dexps,_ruleids,_vmtype,_ans)|_views]) :-
	pc_recorded(vmrules,VMruleGenerator,_ruleids2),
	append(_ruleids2,_ruleids,_ruleids3),
	pc_rerecord(vmrules,VMruleGenerator,_ruleids3),
	init_rules_for_vm(_views).

get_rules_for_vm(_dexps,_ruleids) :-
	pc_rerecord(vmrules,VMruleGenerator,[]),
	get_vmheads_for_dexps(_dexps,_heads),
	getRuleIdsForHeads(_heads,vmrule,_ruleids).

get_vmheads_for_dexps([],[]).
get_vmheads_for_dexps([derive(_id,_slist)|_ids],[plus(_term),minus(_term)|_heads]) :-
	get_QueryStruct(_id,_qs),
	generate_GenQueryArgs(_,_qs,_slist,_args,_),
	length(_args,_n),
	functor(_term,_id,_n),
	get_vmheads_for_dexps(_ids,_heads).




get_subquery(_qid,_sq) :-
	prove_literal(P(_,_qid,_label,_)),
        convert_label(_qid,_label,_label1),
	pc_atomconcat(['vm_',_qid,'_',_label1],_sq),
	get_QueryStruct(_sq,_).

get_subview(_qid,_vmid) :-
	prove_literal(A(_qid,partof,_v)),
	pc_atomconcat('vm_',_v,_vmid),
	get_QueryStruct(_vmid,_).


get_derive_exp_for_subqueries(_qid,_slist,_sqs) :-
	findall(derive(_sq,_slist),
		get_subquery(_qid,_sq),
		_sqs).

get_derive_exp_for_subviews(_qid,_subviews) :-
	findall(_sv,
		get_subview(_qid,_sv),
		_vmids),
	get_subqueries_for_subviews(_vmids,_subqueries),
	get_subviews_for_subviews(_vmids,_subviews1),
	insert_derive(_vmids,_subviews2),
	append(_subqueries,_subviews1,_tmp1),
	append(_tmp1,_subviews2,_subviews).

insert_derive([],[]).
insert_derive([_vmid|_ids],[derive(_vmid,[])|_ds]) :-
	insert_derive(_ids,_ds).



get_subqueries_for_subviews([],[]).
get_subqueries_for_subviews([_vmid|_vmids],_subqueries) :-
	pc_atomconcat('vm_',_qid,_vmid),
	get_derive_exp_for_subqueries(_qid,[],_subqueries1),
	get_subqueries_for_subviews(_vmids,_subqueries2),
	append(_subqueries1,_subqueries2,_subqueries).

get_subviews_for_subviews([],[]).
get_subviews_for_subviews([_vmid|_vmids],_subqueries) :-
	pc_atomconcat('vm_',_qid,_vmid),
	get_derive_exp_for_subviews(_qid,_subqueries1),
	get_subviews_for_subviews(_vmids,_subqueries2),
	append(_subqueries1,_subqueries2,_subqueries).






evaluate_diffs([],[]).

evaluate_diffs([view(_qid,_dexp,_dexps,_ruleids,_vmtype,_oldans)|_views],_diffs) :-
	evaluate_view_wo_mat(_dexp,VIEW,_ans),
	save_setof(_t,member(_t,_ans),_sortedans),
	compute_diff(_oldans,_sortedans,_diff),
	store_diff(_diff,_dexp),
	{ pc_atom_to_term(_atomdexp,_dexp), }
	{ pc_rerecord(_atomdexp,ViewMonitor,view(_qid,_dexp,_dexps,_ruleids,_vmtype,_sortedans)), }
	evaluate_diffs(_views,_diffs1),
	append(_diff,_diffs1,_diffs).

compute_diff([],[],[]).

compute_diff([_x|_xs],[_x|_ys],_diffs) :-
	!,
	compute_diff(_xs,_ys,_diffs).

compute_diff([_x|_xs],_ys,[minus(_x)|_diffs]) :-
	not(member(_x,_ys)),
	!,
	compute_diff(_xs,_ys,_diffs).

compute_diff(_xs,[_y|_ys],[plus(_y)|_diffs]) :-
	not(member(_y,_xs)),
	!,
	compute_diff(_xs,_ys,_diffs).

store_diff([],_).

store_diff([_t|_ts],_n) :-
	assert(notifyTemp(_t,view(_n))),
	store_diff(_ts,_n).


{===================================================}
{* assert_facts(_list)                             *}
{*                                                 *}
{* Speichert eine Liste von Fakten in facts und    *}
{* ofacts ab.                                      *}
{*                                                 *}
{===================================================}

assert_facts([],_).
assert_facts([_h|_t],tell) :-
	assert(fact(ins(_h))),
	assert(ofact(ins(_h))),
	assert_facts(_t,tell).

assert_facts([_h|_t],untell) :-
	assert(fact(del(_h))),
	assert(ofact(del(_h))),
	assert_facts(_t,untell).

{===================================================}
{* output_solutions(_sollist)                      *}
{*                                                 *}
{* Gibt die Loesungen der ViewMaintenance aus.     *}
{*                                                 *}
{===================================================}

output_solutions(_l) :-
	set_KBsearchSpace(oldOB,Now),
	output_solutions_m(_l),
	set_KBsearchSpace(newOB,Now),
	output_solutions_p(_l),
	handle_notifications.


handle_notifications :-
	retract(notifyTemp(_t,_v)),
	!,
	findall(_nt,retract(notifyTemp(_nt,_v)),_ts),
	update_materialization(_v,[_t|_ts]),
	notifyClients([_t|_ts],_v),
	handle_notifications.

handle_notifications :- !.

update_materialization(view(_v),_terms) :-
	pc_atom_to_term(_atomdexp,_v),
	pc_recorded(_atomdexp,ViewMonitor,view(_qid,_dexp,_qgoals,_ruleids,_vmtype,_ans)),
	update_materialization(_terms,_ans,_newans),
	pc_rerecord(_atomdexp,ViewMonitor,view(_qid,_dexp,_qgoals,_ruleids,_vmtype,_newans)).

update_materialization(_ts,_ans,_nans) :-
	save_setof(_elem,member(plus(_elem),_ts),_pluselems),
	save_setof(_elem,member(minus(_elem),_ts),_minuselems),
	fast_diff(_ans,_minuselems,_nans1),
	fast_add(_pluselems,_nans1,_nans).


fast_add([],_ts,_ts).
fast_add(_ps,[],_ps).

fast_add([_p|_ps],[_p|_ts],[_p|_nts]) :-
	!,
	fast_add(_ps,_ts,_nts).

fast_add([_p|_ps],[_t|_ts],[_p|_nts]) :-
	_p @< _t,
	!,
	fast_add(_ps,[_t|_ts],_nts).

fast_add(_ps,[_t|_ts],[_t|_nts]) :-
	fast_add(_ps,_ts,_nts).



output_solutions_p([]).

output_solutions_p([plus(_l)|_t]) :-
	_l =.. [_vmid|_],
	pc_atomconcat('vm_',_id,_vmid),
	(SubQuery(_id,_name);View(_id,_name)),
	get_main_view(_id,_viewname),
	!,
    findall(_,
		(
		pc_current_key(_atomdexp,ViewMonitor),
		pc_recorded(_atomdexp,ViewMonitor,view(_qid,_dexp,_qgoals,_ruleids,_vmtype,_ans)),
		member(_l,_qgoals),
		transform_update_elem(_id,_l,_n),
		member(_e,_n),
		assertz(notifyTemp(plus(_e),view(_dexp)))
	   	),_),
	output_solutions_p(_t).



output_solutions_p([plus(_l)|_t]) :-
	term_id2name(_l,_n),
	notifyClients(plus(_l),plus(_l)),
	output_solutions_p(_t).

output_solutions_p([_|_t]) :-
	output_solutions_p(_t).


output_solutions_m([]).

output_solutions_m([minus(_l)|_t]) :-
	_l =.. [_vmid|_],
	pc_atomconcat('vm_',_id,_vmid),
	(SubQuery(_id,_name);View(_id,_name)),
	get_main_view(_id,_viewname),
	!,
    findall(_,
		(pc_current_key(_atomdexp,ViewMonitor),
		pc_recorded(_atomdexp,ViewMonitor,view(_qid,_dexp,_qgoals,_ruleids,_vmtype,_ans)),
		member(_l,_qgoals),
		transform_update_elem(_id,_l,_n),
		member(_e,_n),
		assertz(notifyTemp(minus(_e),view(_dexp)))
	   	),_),
	output_solutions_m(_t).

output_solutions_m([minus(_l)|_t]) :-
	term_id2name(_l,_n),
	notifyClients(minus(_l),minus(_l)),
	output_solutions_m(_t).

output_solutions_m([_|_t]) :-
	output_solutions_m(_t).


term_id2name([],[]):-!.
term_id2name([_arg|_args],[_narg|_nargs]) :-
	!,
	term_id2name(_arg,_narg),
	term_id2name(_args,_nargs).

term_id2name(_l,_n) :-
	not(atom(_l)),
	!,
	_l =.. [_f|_args],
	term_id2name(_f,_fn),
	term_id2name(_args,_nargs),
	_n =.. [_fn|_nargs].

term_id2name(_l,_n) :-
	atom(_l),
	!,
	((pc_atomconcat('vm_',_,_l),_n=_l);
	 SubQuery(_l,_n);
	 id2name(_l,_n);
	 _n=_l
	),
	!.


{*******************************************************************}
{                                                                   }
{ get_main_view(_id,_name)                                          }
{                                                                   }
{ Description of arguments:                                         }
{      id : ID eines Views/SubViews/SubQuery                        }
{    name : Name des HauptViews, zu dem ID gehoert                  }
{                                                                   }
{ Description of predicate:                                         }
{                                                                   }
{*******************************************************************}

#MODE((get_main_view(i,o)))


get_main_view(_id,_name) :-
	SubQuery(_id,_x),
	!,
	pc_atomconcat('id_',_r1,_id),
	split_atom(_r1,'_',_num,_attr),
	not(pc_atompart(_num,'_',_,_)),
	pc_atomconcat(['id_',_num],_qID),
	Query(_qID),
	get_main_view(_qID,_name).

get_main_view(_id,_name) :-
	name2id(SubView,_vid),
	prove_literal(In_s(_id,_vid)),
	!,
	(prove_literal(A(_mid,partof,_id));
	 (prove_literal(P(_,_derexp,'*isa',_id)),
	  prove_literal(A(_mid,partof,_derexp))
	)),
	!,
	get_main_view(_mid,_name).

get_main_view(_id,_name) :-
	name2id(View,_vid),
	prove_literal(In_s(_id,_vid)),
	!,
	id2name(_id,_name).



transform_update_elem(_id,_elem,[_trans]) :-
	SubQuery(_id,_qname),
	!,
	_elem =..[_q|_arglist],
	get_QueryStruct(_q,_qs),
	transform_subquery_update_elem(_arglist,_qs,_id,_qname,_trans).


transform_update_elem(_id,_elem,_translist) :-
   	View(_id,_qname),
	!,
	_elem =..[_q|_arglist],
	get_QueryStruct(_q,_qs),
	transform_main_update_elem(_arglist,_qs,_id,_qname,_translist).



{ ********** }
{ TOPDOWN VM }
{ ********** }

topdown_vm([],[]).
topdown_vm([view(_qid,_dexp,_qgoals,_ruleids,_vmtype,_ans)|_views],_sol) :-
	topdown_vm2(_qgoals,_sol1),
	topdown_vm(_views,_sol2),
	append(_sol1,_sol2,_sol).

topdown_vm2([],[]).
topdown_vm2([_qg|_qgoals],_sol) :-
	save_setof(plus(_qg),
		prove_plus_literal(_qg),
		_ps),
	save_setof(minus(_qg),
		prove_minus_literal(_qg),
		_ms),
	!,
	append(_ps,_ms,_sol1),
	topdown_vm2(_qgoals,_sol2),
	append(_sol1,_sol2,_sol).


store_rules_for_topdown_vm([]).
store_rules_for_topdown_vm([view(_qid,_dexp,_dexps,_ruleids,_vmtpye,_ans)|_views]) :-
	store_rules_for_topdown_vm2(_ruleids),
	store_rules_for_topdown_vm(_views).

store_rules_for_topdown_vm2([]).

store_rules_for_topdown_vm2([_ruleid|_ruleids]) :-
	ruleInfo(_ruleid,_,_,_,_head,_body,_,_,_,_),
	store_rule_for_topdown_vm(_head,_body),
	store_rules_for_topdown_vm2(_ruleids).

store_rules_for_topdown_vm2([_ruleid|_ruleids]) :-
	store_rules_for_topdown_vm2(_ruleids).

store_rule_for_topdown_vm(_head1,_body1) :-
	pc_atom_to_term(_atom,(_head1,_body1)),
	pc_atom_to_term(_atom,(_head,_body)),
	make_exec_head(_head,_execlit),
	make_exec_body(_body,_execbody),
	assert((_execlit :- _execbody)).

make_exec_head(ins(_l),prove_ins_literal(_l)) :- !.
make_exec_head(del(_l),prove_del_literal(_l)) :- !.
make_exec_head(red(_l),prove_red_literal(_l)) :- !.
make_exec_head(new(_l),prove_new_literal(_l)) :- !.
make_exec_head(plus(_l),prove_plus_literal(_l)) :- !.
make_exec_head(minus(_l),prove_minus_literal(_l)) :- !.

make_exec(not(_l),not(_e)) :- !,make_exec(_l,_e).
make_exec(ins(_l),prove_ins_literal(_l)) :- !.
make_exec(del(_l),prove_del_literal(_l)) :- !.
make_exec(red(_l),prove_red_literal(_l)) :- !.
make_exec(new(_l),prove_new_literal(_l)) :- !.
make_exec(plus(_l),prove_plus_literal(_l)) :- !.
make_exec(minus(_l),prove_minus_literal(_l)) :- !.
make_exec(_l,prove_old_literal(_l)).

make_exec_body([],true).
make_exec_body([_l],_e) :-
	!,
	make_exec(_l,_e).

make_exec_body([_l|_ls],(_e,_es)) :-
	!,
	make_exec(_l,_e),
	make_exec_body(_ls,_es).



{ base rules}

prove_ins_literal(_l) :-
	fact(ins(_l)).

prove_ins_literal(Adot_label(_cc,_x,_y,_l)) :-
	prove_ins_literal(Adot(_cc,_x,_y)),
	prove_new_literal(Adot_label(_cc,_x,_y,_l)).

prove_del_literal(_l) :-
	fact(del(_l)).

prove_del_literal(Adot_label(_cc,_x,_y,_l)) :-
	prove_del_literal(Adot(_cc,_x,_y)),
	prove_old_literal(Adot_label(_cc,_x,_y,_l)).

prove_red_literal(Adot(_cc,_x,_y)) :-
	prove_del_literal(Adot(_cc,_x,_y)),
	prove_new_literal(Adot(_cc,_x,_y)).

prove_red_literal(Adot_label(_cc,_x,_y,_l)) :-
	prove_del_literal(Adot_label(_cc,_x,_y,_l)),
	prove_new_literal(Adot_label(_cc,_x,_y,_l)).





{===================================================}
{* prove_new_literal(_lit)                         *}
{*                                                 *}
{* Testet, ob Literal auch im neuem Zustand gilt.  *}
{*                                                 *}
{===================================================}

prove_new_literal(_l) :-
	(prove_ins_literal(_l);
	prove_red_literal(_l)).

{ Versuche prove_literal auf New OB}
prove_new_literal(_x) :-
	get_KBsearchSpace(_oldsp,_oldtt),
	set_KBsearchSpace(newOB,Now),
	prove_literal(_x),
	resetNewSearchSpace(_oldsp,_oldtt).

{ Versuche das base_predicate auf NewOB }
{ prove_new_literal(_x) :-
	get_KBsearchSpace(_oldsp,_oldtt),
	set_KBsearchSpace(newOB,Now),
	base_predicate(_x),
	_x,
	resetNewSearchSpace(_oldsp,_oldtt).
}

{ Wenn nichts geht, dann auf oldOB zuruecksetzen und Ende }
prove_new_literal(_x) :-
	set_KBsearchSpace(oldOB,Now),
	fail.

resetNewSearchSpace(_sp,_tt) :-
	set_KBsearchSpace(_sp,_tt).

{REDO}
resetNewSearchSpace(_sp,_tt) :-
	set_KBsearchSpace(newOB,Now),
	fail.


{===================================================}
{* prove_old_literal(_lit)                         *}
{*                                                 *}
{* Testet, ob Literal auch im altem Zustand gilt.  *}
{*                                                 *}
{===================================================}


prove_old_literal(_x) :-
	get_KBsearchSpace(_oldsp,_oldtt),
	set_KBsearchSpace(oldOB,Now),
	prove_literal(_x),
	resetOldSearchSpace(_oldsp,_oldtt).

{ prove_old_literal(_x) :-
	get_KBsearchSpace(_oldsp,_oldtt),
	set_KBsearchSpace(oldOB,Now),
	base_predicate(_x),
	_x,
	resetOldSearchSpace(_oldsp,_oldtt).
}

prove_old_literal(_x) :-
	set_KBsearchSpace(oldOB,Now),
	fail.

resetOldSearchSpace(_sp,_tt) :-
	set_KBsearchSpace(_sp,_tt).

{REDO}
resetOldSearchSpace(_sp,_tt) :-
	set_KBsearchSpace(oldOB,Now),
	fail.



