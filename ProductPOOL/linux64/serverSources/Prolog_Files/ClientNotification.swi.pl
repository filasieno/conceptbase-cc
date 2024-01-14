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
/*
*
* File:         %M%
* Version:      %I%
* Creation:     23-04-96, Christoph Quix (RWTH)
* Last Change   : %E%, Christoph Quix (RWTH)
*
* SCCS-Source-Pool : %P%
* Date retrieved : %D% (YY/MM/DD)
* ----------------------------------------------------------
*
*
* Exported predicates:
* --------------------
*
*
*   + handle_notification_request/2 (CBserverInterface)
*
*/

:- module('ClientNotification',[
'delete_all_notification_requests'/1
,'handle_notification_request'/4
,'notify'/2
,'notifyClients'/2
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').

:- use_module('CBserverInterface.swi.pl').
:- use_module('GeneralUtilities.swi.pl').






:- use_module('Literals.swi.pl').
:- use_module('ViewEvaluator.swi.pl').
:- use_module('TellAndAsk.swi.pl').
:- use_module('ViewMonitor.swi.pl').



:- use_module('QueryCompiler.swi.pl').

:- use_module('PrologCompatibility.swi.pl').











:- dynamic 'notify'/2 .
:- dynamic 'internalNotify'/1 .


:- style_check(-singleton).


handle_notification_request(_sender,_toolid,[],[]).

handle_notification_request(_sender,_toolid,[_arg|_args],[yes|_rresp]) :-
	atom(_arg),
	pc_atomconcat('delete(',_arg2,_arg),
	pc_atomconcat(_arg3,')',_arg2),
	!,
	pc_atomconcat('view(',_arg4,_arg3),
	pc_atomconcat(_arg5,')',_arg4),
	pc_stringtoatom(_objnames,_arg5),
	'ObjNameStringToList'(_objnames,_objnamelist),
	_objnamelist = [class(_term)],
	retract(notify(_toolid,view(_term))),
	handle_notification_request(_sender,_toolid,_args,_rresp).

handle_notification_request(_sender,_toolid,[_arg|_args],[_resp2|_rresp]) :-
	atom(_arg),
	pc_atomconcat('view(',_arg4,_arg),
	pc_atomconcat(_arg5,')',_arg4),
	!,
	pc_stringtoatom(_objnames,_arg5),
	'ObjNameStringToList'(_objnames,_objnamelist),
	_objnamelist = [class(_term)],
	assert(notify(_toolid,view(_term))),
	get_response(view(_term),_resp),
	((_toolid == _sender,
	  _resp2 = _resp
	 );
	 (writeNotifyMessage([_toolid],[_resp]),
	  _resp2 = yes
	)),
	handle_notification_request(_sender,_toolid,_args,_rresp).



delete_all_notification_requests(_toolid) :-
	retractall(notify(_toolid,_term)).



notifyClients(_msg,_term) :-
	save_setof(internal(_pred),notify(internal(_pred),_term),_internalpreds),
	!,
	save_setof(_toolid,(notify(_toolid,_term),_toolid \= internal(_)),_tools),
	!,
	handle_internal_clients(_internalpreds,_msg),
	!,
	writeNotifyMessage(_tools,[_msg]),
	!.

handle_internal_clients([],_).
handle_internal_clients([internal(_pred)|_rest],_msg) :-
	pc_has_a_definition(_pred),
	!,
	pc_update(internalNotify(_msg)),
	call(_pred),
	!,
	handle_internal_clients(_rest,_msg).

/* when _pred failed above */
handle_internal_clients([_|_rest],_msg) :-
	handle_internal_clients(_rest,_msg).


get_response(view(_name),_ansp) :-
	!,
	init_view_maintenance(_name,_ans),
	save_setof(_t,member(_t,_ans),_sortedans),
	add_plus(_sortedans,_ansp).

get_response(_,yes).


add_plus([],[]).

add_plus([_h|_t],[plus(_h)|_nt]) :-
	add_plus(_t,_nt).



/* init_view_maintenance(_name,_ans) :-
	pc_atom_to_term(_aname,_name),
	pc_recorded(_aname,ViewMonitor,view(_qid,_dexp,_dexps,_ruleids,_vmtype,_ans)),
	!. */
/* TODO: Maintain materialization !!! */

init_view_maintenance(_dexp,_ans) :-
	get_vm_type(_dexp,_vmtype),
	(_dexp = derive(_qname,_slistname); (_dexp = _qname, _slistname = [])),
	name2id(_qname,_qid),
	slist2id(_slistname,_slist),
	get_derive_exp_for_subqueries(_qid,_slist,_subqueries),
	get_derive_exp_for_subviews(_qid,_subviews),
	pc_atomconcat('vm_',_qid,_vmid),
	append([derive(_vmid,_slist)|_subqueries],_subviews,_dexps),
	((_vmtype == naiveVM, _ruleids = []);
	 (_vmtype \== naiveVM,
	  get_rules_for_vm(_dexps,_ruleids)
	)),
	make_query_goals_for_dexps(_dexps,_qgoals),
    evaluate_view(_dexp,'VIEW',_ans),
	save_setof(_t,member(_t,_ans),_sortedans),
	pc_atom_to_term(_aname,_dexp),
	pc_rerecord(_aname,'ViewMonitor',view(_qid,_dexp,_qgoals,_ruleids,_vmtype,_sortedans)),
	((_vmtype == topDownVM,
	  store_rules_for_topdown_vm([view(_qid,_dexp,_qgoals,_ruleids,_vmtype,_sortedans)])
	 );
	 true
	),
	!.




get_vm_type(derive(_name,_slist),topDownVM) :-
	name2id(_name,_id),
	name2id('TopDownVM',_vmid),
	prove_literal('In'(_id,_vmid)),
	!.

get_vm_type(derive(_name,_slist),bottomUpVM) :-
	name2id(_name,_id),
	name2id('BottomUpVM',_vmid),
	prove_literal('In'(_id,_vmid)),
	!.

/* default for views with parameters */
get_vm_type(derive(_,_),naiveVM) :-
	!.


get_vm_type(_name,topDownVM) :-
	name2id(_name,_id),
	name2id('TopDownVM',_vmid),
	prove_literal('In'(_id,_vmid)),
	!.

get_vm_type(_name,naiveVM) :-
	name2id(_name,_id),
	name2id('NaiveVM',_vmid),
	prove_literal('In'(_id,_vmid)),
	!.

/* default for views without parameters */
get_vm_type(_id,bottomUpVM).


make_query_goals_for_dexps([],[]).
make_query_goals_for_dexps([derive(_qid,_slist)|_dexps],[_qg|_qgoals]) :-
	get_QueryStruct(_qid,_qs),
	generate_GenQueryArgs(_,_qs,_slist,_args,_),
	_qg1 =.. [_qid|_args],
	pc_atom_to_term(_atmp,_qg1),
	pc_atom_to_term(_atmp,_qg),
	make_query_goals_for_dexps(_dexps,_qgoals).



slist2id([],[]).
slist2id([_h|_t],[_nh|_nt]) :-
	arg(1,_h,_name),
	arg(2,_h,_par),
	name2id(_name,_id),
	functor(_h,_func,_),
	_nh =.. [_func,_id,_par],
	slist2id(_t,_nt).

