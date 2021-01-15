{*
The ConceptBase.cc Copyright

Copyright 1987-2021 The ConceptBase Team. All rights reserved.

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
{
*
* File:         %M%
* Version:      %I%
* Creation:     1997  F. Lashgari (RWTH)
* Last Change   : %E%, Christoph Quix (RWTH)
*
* SCCS-Source-Pool : %P%
* Date retrieved : %D% (YY/MM/DD)
*

}

#MODULE(ECAruleProcessor)
#EXPORT(ECATELL/2)
#EXPORT(ECAUNTELL/2)
#EXPORT(activate_flag/2)
#EXPORT(store_ecarules/1)
#ENDMODDECL()


#IMPORT(name2id/2,GeneralUtilities)
#IMPORT(setUnion/3,GeneralUtilities)
#IMPORT(name2id_list/2,GeneralUtilities)
#IMPORT(id2name/2,GeneralUtilities)
#IMPORT(id2name_list/2,GeneralUtilities)
#IMPORT(append/3,GeneralUtilities)
#IMPORT(pc_member/2,PrologCompatibility)
#IMPORT(WriteTrace/3,GeneralUtilities)
#IMPORT(length/2,GeneralUtilities)
#IMPORT(delete_all/3,GeneralUtilities)
#IMPORT(report_error/3,ErrorMessages)
#IMPORT(retrieve_proposition/1,PropositionProcessor)
#IMPORT(tell_objproc/2,ObjectProcessor)
#IMPORT(untell_objproc/2,ObjectProcessor)
#IMPORT(get_transaction_time/1,TransactionTime)
#IMPORT(set_transaction_time/0,TransactionTime)
#IMPORT(queue_message/3,CBserverInterface)
#IMPORT(active_sender/1,CBserverInterface)
#IMPORT(thisToolId/1,CBserverInterface)
#IMPORT(append_rule2event/3,ECAeventManager )
#IMPORT(append_activerule2event/3,ECAeventManager )
#IMPORT(delete_rule2event/3,ECAeventManager )
#IMPORT(drive_events_from_rule/2,ECAeventManager )
#IMPORT(drive_rules_from_events/2,ECAeventManager )
#IMPORT(same_event/2,ECAeventManager )
#IMPORT(no_intersection/2,ECAutilities )
#IMPORT(difference/3,ECAutilities )
#IMPORT(difference_var/3,ECAutilities )
#IMPORT(prove_literal/1,Literals )
#IMPORT(create_if_builtin_object/1,FragmentToPropositions )
#IMPORT(SetUpdateMode/1,TellAndAsk)
#IMPORT(RemoveUpdateMode/1,TellAndAsk)
#IMPORT(current_ecarule/1,ECAruleCompiler)
#IMPORT(pc_unifiable/2,PrologCompatibility)
#IMPORT(pc_atomconcat/2,PrologCompatibility)
#IMPORT(pc_atomconcat/3,PrologCompatibility)
#IMPORT(pc_atom_to_term/2,PrologCompatibility)
#IMPORT(replace_ids/2,Literals )

#IF(SWI)
:- style_check(-singleton).
#ENDIF(SWI)



{****************************************************************}
{ ECATELL/2						 	 }
{ ECATELL( _list_of_ecarules , _completion)	 	 }
{	_completion == noerror  or  == error			 }
{****************************************************************}

ECATELL([],noerror).

ECATELL([_eca|_r],_c) :-
        SetUpdateMode(UPDATE),
	do_tell_ecarules(_eca),
        RemoveUpdateMode(_),
	ECATELL(_r,_c).

ECATELL(_,error):-RemoveUpdateMode(_),!.

{****************************************************************}
{ ECAUNTELL/2						 	 }
{ ECAUNTELL( _list_of_ecarules , _completion)	 	 }
{	_completion == noerror  or  == error			 }
{****************************************************************}

ECAUNTELL([],noerror).

ECAUNTELL([_id|_r],noerror) :-
        SetUpdateMode(UPDATE),
	'eca@ECAruleManager'(_id,_e,_q,_do,_else,_p,_m,_ac,_d,_queue,_t,Now),
	do_untell_ecarules(eca(_id,_e,_q,_do,_else,_p,_m,_ac,_d,_queue)),
	!,
        RemoveUpdateMode(_),
	ECAUNTELL(_r,_c).

ECAUNTELL(_,error):-	 RemoveUpdateMode(_),!.

{****************************************************************}
{ do_tell_ecarules/1						 }
{ do_tell_ecarules( ecarule )					 }
{								 }
{****************************************************************}

{ Fall 1: ECA Regel existiert bereits genauso, dann nichts tun }
do_tell_ecarules(eca(_n,_e,Ask(_v,_query),_do,_else,_p,_m,_a,_d,_queue)) :-
	'eca@ECAruleManager'(_n,_e1,Ask(_v1,_query1),_do1,_else1,_p1,_m1,_ac1,_d1,_queue,_t1, Now),
    eca(_n,_e1,Ask(_v1,_query1),_do1,_else1,_p1,_m1,_a,_d1,_queue) =
       eca(_n, _e, Ask(_v, _query), _do, _else, _p, _m,_a, _d,_queue),
	!.

{ Fall 2: ECA Regel existiert bereits, aber mit anderer Definition!}
do_tell_ecarules(eca(_n,_e,Ask(_v,_query),_do,_else,_p,_m,_act,_d,_queue)) :-
	'eca@ECAruleManager'(_n,_,_,_,_,_,_,_,_,_,_, Now),!,
	id2name(_n,_nname),							{ LWEB }
	report_error( ECA8, ECAruleProcessor , [_nname]),
	!,
	fail.


{ Fall 3: Normales Tell }
do_tell_ecarules(eca(_n,_e,Ask(_v,_query),_do,_else,_p,_m,_active,_d,_queue)) :-
	id2name(_n,_Nn),
	get_transaction_time(_tt),
	check_priority_definition(_n,_p),
	!,
	store_tmp_ecarule(eca(_n,_e,Ask(_v,_query),_do,_else,_p,_m,_active,_d,_queue,tt(_tt))),
	!,
	make_temp2persist,
	((_active == true,
	  find_uptodated_rules(_n,_e,[],_update_rules),
	  update_ECAgraphs([],_,_update_rules),
	  find_events(_n,_events),
      update_nest_predicates_tell(_n,_events),
	  assert('nest@ECAruleManager'(_n,_update_rules,_events)),
	  WriteTrace(veryhigh,ECAruleProcessor,['+',nest(_n,_update_rules,_events)]),
	  analyse_rulegraph(_n,_nest,_cycle,g(_n,_list)),
{*	  replace_ids_in_graph(_list,_listname), *}
	  WriteTrace(veryhigh,ECAruleProcessor,['ECA RULE GRAPH >>> ',g(_Nn,_list)])
	 );
	 (_active = false
	)).


do_tell_ecarules(_) :-
	WriteTrace(veryhigh,ECAruleProcessor,['>>> deleting temporary ECArule predicates']),
	delete_ECAtemp,
	!,
	current_ecarule(_name),
	report_error(ECA_TELL_ERR,ECAruleProcessor,[_name]),
	fail.

{****************************************************************}
{ do_untell_ecarules/1						 }
{ do_untell_ecarules( ecarule )					 }
{								 }
{****************************************************************}

{ Fall 1: Regel existiert nicht, bzw. ist nicht sichtbar im aktuellen Modul }
do_untell_ecarules(eca(_n,_e,Ask(_v,_query),_do,_else,_p,_m,_ac,_d,_queue)) :-
	id2name(_n,_Nn),
	not(retrieve_proposition(P(_n,_,_,_))),						{ LWEB: ueberpruefe ob Regel sichtbar ist }
	delete_ECAtemp,
    report_error( ECA5, ECAruleProcessor , [_Nn]),
	!,
	fail.

{ Fall 2: Regel loeschen }
do_untell_ecarules(eca(_n,_e,Ask(_v,_query),_do,_else,_p,_m,_ac,_d,_queue)) :-
	'eca@ECAruleManager'(_n,_e,Ask(_v,_query),_do,_else,_p,_m,_ac,_d,_queue,_t, Now),!,
  	get_transaction_time(_tt),
    delete_ecarule(eca(_n,_e,Ask(_v,_query),_do,_else,_p,_m,_ac,_d,_queue,tt(_tt))),
    make_temp2persist,
	!.

{ Fall 3: Sonstiger Fehler (bei delete_ecarule) }
do_untell_ecarules(eca(_n,_e,Ask(_v,_query),_do,_else,_p,_m,_ac,_d,_queue)) :-
	id2name(_n,_Nn),
	'eca@ECAruleManager'(_n,_,_,_,_,_,_,_,_,_,_,Now),
	!,
	delete_ECAtemp,
    report_error( ECA4, ECAruleProcessor , [_Nn]),
	!,
	fail.





{****************************************************************}
{make_temp2persist/0						 }
{****************************************************************}
make_temp2persist :-
	retract('eca@ECATEMP'(_n,_e,_a,_do,_else,_p,_m,_ac,_d,_queue,_t,Now)),
	assert('eca@ECAruleManager'(_n,_e,_a,_do,_else,_p,_m,_ac,_d,_queue,_t,Now)),
 	WriteTrace(veryhigh,ECAruleProcessor,['+',eca(_n,_e,_a,_do,_else,_p,_m,_ac,_d,_queue,_t,Now)]),
	fail.

make_temp2persist :-
	retract('eca@ECATEMP'(_n,_e,_a,_do,_else,_p,_m,_ac,_d,_queue,_t1,_t2)),
	{_t2 \== Now ,}
	retract('eca@ECAruleManager'(_n,_e1,_a1,_do1,_else1,_p1,_m1,_ac1,_d1,_queue,_t1,Now)),
 	WriteTrace(veryhigh,ECAruleProcessor,['-',eca(_n,_e1,_a1,_do1,_else1,_p1,_m1,_ac1,_d1,_queue,_t1,Now)]),
	assert('eca@ECAruleManager'(_n,_e,_a,_do,_else,_p,_m,_ac,_d,_queue,_t1,_t2)),
 	WriteTrace(veryhigh,ECAruleProcessor,['+',eca(_n,_e,_a,_do,_else,_p,_m,_ac,_d,_queue,_t1,_t2)]),
	fail.


make_temp2persist :-
	'priority@ECATEMP'(_r,_af,_be),
	retract('priority@ECAruleManager'(_r,_af1,_be1)),
 	WriteTrace(veryhigh,ECAruleProcessor,['- ',priority(_r,_af1,_be1)]),
	retract('priority@ECATEMP'(_r,_af,_be)),
	assert('priority@ECAruleManager'(_r,_af,_be)),
 	WriteTrace(veryhigh,ECAruleProcessor,['+ ',priority(_r,_af,_be)]),
	fail.

make_temp2persist :-
	retract('priority@ECATEMP'(_r,_af,_be)),
	assert('priority@ECAruleManager'(_r,_af,_be)),
 	WriteTrace(veryhigh,ECAruleProcessor,['+ ',priority(_r,_af,_be)]),
	fail.

make_temp2persist :-
	retract('r@ECATEMP'(_n,_e,_a,_do,_else,_d,_queue)),
	assert('r@ECATEMP'(_n,_e,_a,_do,_else,_d,_queue)),
	retract('r@ECAruleManager'(_n,_e1,_a1,_do1,_else1,_d1,_queue1)),
 	WriteTrace(veryhigh,ECAruleProcessor,['- ',r(_n,_e1,_a1,_do1,_else1,_d1,_queue1)]),
	retract('r@ECATEMP'(_n,_e,_a,_do,_else,_d,_queue)),
	assert('r@ECAruleManager'(_n,_e,_a,_do,_else,_d,_queue)),
 	WriteTrace(veryhigh,ECAruleProcessor,['+ ',r(_n,_e,_a,_do,_else,_d,_queue)]),
	fail.

make_temp2persist :-
	retract('r@ECATEMP'(_n,_e,_a,_do,_else,_d,_queue)),
	assert('r@ECAruleManager'(_n,_e,_a,_do,_else,_d,_queue)),
 	WriteTrace(veryhigh,ECAruleProcessor,['+ ',r(_n,_e,_a,_do,_else,_d,_queue)]),
	fail.

make_temp2persist :-
	'e@ECATEMP'(_e1,_imm,_imm_def,_def),
	'e@ECAevent'(_e2,_imm1,_imm_def1,_def1),
	same_event(_e1,_e2),
	retract('e@ECATEMP'(_e1,_imm,_imm_def,_def)),
 	WriteTrace(veryhigh,ECAruleProcessor,['- ',e(_e2,_imm1,_imm_def1,_def1)]),
	retract('e@ECAevent'(_e2,_imm1,_imm_def1,_def1)),
 	WriteTrace(veryhigh,ECAruleProcessor,['+ ',e(_e1,_imm,_imm_def,_def)]),
	assert('e@ECAevent'(_e1,_imm,_imm_def,_def)),
	fail.

make_temp2persist :-
	retract('e@ECATEMP'(_e,_imm,_imm_def,_def)),
	assert('e@ECAevent'(_e,_imm,_imm_def,_def)),
 	WriteTrace(veryhigh,ECAruleProcessor,['+ ',e(_e,_imm,_imm_def,_def)]),
	fail.


make_temp2persist :- !.

{****************************************************************}
{delete_ECAtemp/0						 }
{****************************************************************}
delete_ECAtemp :-
	retractall('eca@ECATEMP'(_,_,_,_,_,_,_,_,_,_,_,_)),
	retractall('r@ECATEMP'(_,_,_,_,_,_,_)),
	retractall('priority@ECATEMP'(_,_,_)),
	retractall('e@ECATEMP'(_,_,_,_)).

{****************************************************************}
{ store_eca_rules/1						 }
{ Wird von ConfigurationUtilities beim Laden einer Applikation }
{ aufgerufen. }
{****************************************************************}

store_ecarules([]):- !.

store_ecarules([eca(_n,_e,_a,_do,_else,_p,_m,_ac,_d,_queue,_t1,_t2)|_r]):-
	assert('eca@ECAruleManager'(_n,_e,_a,_do,_else,_p,_m,_ac,_d,_queue,_t1,_t2)),!,
	store_ecarules(_r).

{* compatibility with  old databases *}
store_ecarules([eca(_n,_e,_a,_do,_else,_p,_m,_ac,_d,_t1,_t2)|_r]):-
	assert('eca@ECAruleManager'(_n,_e,_a,_do,_else,_p,_m,_ac,_d,currentqueue,_t1,_t2)),!,
	store_ecarules(_r).


store_ecarules([e(_e,_imm,_imm_def,_def)|_rest]) :-
	assert('e@ECAevent'(_e,_imm,_imm_def,_def)),
	store_ecarules(_rest).


store_ecarules([r(_n,_e,_a,_do,_else,_d,_queue)|_rest]) :-
	assert('r@ECAruleManager'(_n,_e,_a,_do,_else,_d,_queue)),
	store_ecarules(_rest).

{* compatibility with  old databases *}
store_ecarules([r(_n,_e,_a,_do,_else,_d)|_rest]) :-
	assert('r@ECAruleManager'(_n,_e,_a,_do,_else,_d,currentqueue)),
	store_ecarules(_rest).



store_ecarules([priority(_r,_af,_be)|_rest]) :-
	assert('priority@ECAruleManager'(_r,_af,_be)),
	store_ecarules(_rest).

store_ecarules([nest(_r,_nest,_events)|_rest]) :-
	assert('nest@ECAruleManager'(_r,_nest,_events)),
	store_ecarules(_rest).

store_ecarules([_clause|_rest]) :-
	write('ERROR in ECAruleProcessor.pro!!! ECA clause read from ECA file is malformed:'),
        write(_clause),nl,
	store_ecarules(_rest).


{****************************************************************}
{ store_ecarule/1						 }
{****************************************************************}

store_tmp_ecarule(eca(_n,_e,_a,_do,_else,_p,_m,_ac,_d,_queue,_t)):-
	assert('eca@ECATEMP'(_n,_e,_a,_do,_else,_p,_m,_ac,_d,_queue,_t,Now)),
	(_ac == true ,!,assert('r@ECATEMP'(_n,_e,_a,_do,_else,_d,_queue)),
	append_rule2event(_n,_e,_m),!
	;
	true).


{****************************************************************}
{ delete_ecarule/1						 }
{****************************************************************}

delete_ecarule(eca(_n,_e,_a,_do,_else,_p,_m,_ac,_d,_queue,_t)):-
	'eca@ECAruleManager'(_n,_e,_a,_do,_else,_p,_m,_ac,_d,_queue,_t1,Now),
	assert('eca@ECATEMP'(_n,_e,_a,_do,_else,_p,_m,_ac,_d,_queue,_t1,_t)),
	delete_nest(_n),
	delete_priority(_n,_p),
	(_ac== true,!,
	 retract('r@ECAruleManager'(_n,_e,_a,_do,_else,_d,_queue)),
     WriteTrace(veryhigh,ECAruleProcessor,['- ',r(_n,_e,_a,_do,_else,_d,_queue)]),
	 delete_rule2event(_n,_e,_m)
	 ;
	 true).


{****************************************************************}
{ report_warning/1						 }
{****************************************************************}
report_warning(_w) :-
   WriteTrace(low,ECAruleProcessor,['<<< WARNING >>>: ',_w]),
   !.



{****************************************************************}
{check_priority_definition/2					 }
{****************************************************************}
check_priority_definition(_n,priority(after(_af),before(_be))):-
	(pc_member(_n,_af);pc_member(_n,_be)),
	!,
    id2name(_n,_nname),
    report_error( ECA6, ECAruleProcessor , [_nname]),!,fail.

check_priority_definition(_r,priority(after(_af),before(_be))):-
	no_intersection(_af,_be),
	!,
	check_existens(_r,_af,_be),
	check_priority_after(_r,_af,_be),
	!,
	check_priority_before(_r,_af,_be),
	!,
	assert('priority@ECATEMP'(_r,_af,_be)).

check_priority_definition(_r,priority(after(_af),before(_be))):-
	id2name(_r,_rname),
    report_error( ECA6, ECAruleProcessor , [_rname]),
	!,
	fail.


check_priority_after(_r,_af,[]).
check_priority_after(_r,_af,[_b|_be]):-
	check_after(_r,_af,_b),
	!,
	check_priority_after(_r,_af,_be).

check_after(_r,[],_b):-
	'priority@ECAruleManager'(_b,_af,_be),
	(pc_member(_r,_af),!);
	assert('priority@ECATEMP'(_b,[_r|_af],_be)).

check_after(_r,[_a|_arest],_b):-
	'priority@ECAruleManager'(_a,_af,_be),
	(\+ pc_member(_b,_af),!,
	check_after(_r,_arest,_b),!
	;
	id2name_list([_r,_a,_b],_l),
	report_error(ECA7,ECAruleProcessor,_l),!,fail).


check_priority_before(_r,[],_be).
check_priority_before(_r,[_a|_af],_be):-
	check_before(_r,_a,_be),!,
	check_priority_before(_r,_af,_be).

check_before(_r,_a,[]):-
	'priority@ECAruleManager'(_a,_af,_be),
	(pc_member(_r,_be),!
	;
	assert('priority@ECATEMP'(_a,_af,[_r|_be])) ).

check_before(_r,_a,[_b|_brest]):-
	'priority@ECAruleManager'(_b,_af,_be),
	(\+ pc_member(_a,_be),!,
	check_before(_r,_a,_brest),!
	;
	id2name_list([_r,_a,_b],_l),
	report_error(ECA7,ECAruleProcessor,_l),!,fail).



check_existens(_,[],[]).
check_existens(_r,[],[_b|_be]):-
	('priority@ECAruleManager'(_b,_,_),!,
	check_existens(_r,[],_be)
	;
	id2name_list([_r,_b],_l),
	report_error(ECA9,ECAruleProcessor,_l),!,fail).

check_existens(_r,[_a|_af],_be):-
	('priority@ECAruleManager'(_a,_,_),!,
	check_existens(_r,_af,_be)
	;
	id2name_list([_r,_a],_l),
	report_error(ECA9,ECAruleProcessor,_l),!,fail).



append_withlist(_name,_attr,_p,_l1,[attrdecl([_attr],[property(_s1,_s2)])|_l1]):-
	make_string(_name,_attr,_s1),
	make_string(_p,_s2).

make_string(_x,_string) :-
	pc_atom_to_term(_atom,_x),
	pc_atomconcat('"',_atom,_s1),
	pc_atomconcat(_s1,'"',_string).

make_string(_x,_y,_string):-
	atom(_x),
	pc_atomconcat(_x,'_',_a1),
	pc_atomconcat(_a1,_y,_string).


{****************************************************************}
{ delete_nest/1 }
{****************************************************************}

delete_nest(_nid) :-
	retract('nest@ECAruleManager'(_nid,_nest,_events)),
	WriteTrace(veryhigh,ECAruleProcessor,['-',nest(_nid,_nest,_events)]),
	update_nest_predicates_untell(_nid),
	update_ECAgraphs([],_,_nest).



delete_priority(_n,priority(after(_af),before(_be))):-
	delete_after(_n,_af),
	delete_before(_n,_be),
	retract('priority@ECAruleManager'(_n,_af,_be)),
	WriteTrace(veryhigh,ECAruleProcessor,['- ','priority@ECAruleManager'(_n,_af,_be)]).


delete_after(_,[]).
delete_after(_r,[_a|_rest]):-
	retract('priority@ECAruleManager'(_a,_af,_be)),
	WriteTrace(veryhigh,ECAruleProcessor,['- ','priority@ECAruleManager'(_a,_af,_be)]),
	delete_all(_r,_be,_newb),
	assert('priority@ECAruleManager'(_a,_af,_newb)),
	WriteTrace(veryhigh,ECAruleProcessor,['+ ','priority@ECAruleManager'(_a,_af,_newb)]),
	delete_after(_r,_rest).

delete_before(_,[]).
delete_before(_r,[_b|_rest]):-
	retract('priority@ECAruleManager'(_b,_af,_be)),
	WriteTrace(veryhigh,ECAruleProcessor,['- ','priority@ECAruleManager'(_b,_af,_be)]),
	delete_all(_r,_af,_newaf),
	assert('priority@ECAruleManager'(_b,_newaf,_be)),
	WriteTrace(veryhigh,ECAruleProcessor,['+ ','priority@ECAruleManager'(_b,_newaf,_be)]),
	delete_before(_r,_rest).

{*************************************************************************}
{ activate_flag/2			 }
{ id ist id der ECAregel }
{ flag ist true oder false }
{*************************************************************************}

{ Fall 1: Auf true setzen, wenn schon true ist ==> ok }
activate_flag(_id,true) :-
	'eca@ECAruleManager'(_id,_e,_a,_do,_else,_p,_m,true,_d,_queue,_t, Now),
	!.

{ Fall 2: Auf true setzen, wenn false war }
activate_flag(_n,true) :-
	id2name(_n,_Nn),
	'eca@ECAruleManager'(_n,_e,_a,_do,_else,_p,_m,false,_d,_queue,_t, Now),
	!,
	retract('eca@ECAruleManager'(_n,_e,_a,_do,_else,_p,_m,false,_d,_queue,_t, Now)),
	WriteTrace(veryhigh,ECAruleProcessor,['-',eca(_n,_e,_a,_do,_else,_p,_m,false,_d,_queue,_t, Now)]),
	get_transaction_time(_tt),
    assert('eca@ECAruleManager'(_n,_e,_a,_do,_else,_p,_m,true,_d,_queue,_t, Now)),
    WriteTrace(veryhigh,ECAruleProcessor,['+',eca(_n,_e,_a,_do,_else,_p,_m,true,_d,_queue,_t, Now)]),
    assert('r@ECAruleManager'(_n,_e,_a,_do,_else,_d,_queue)),
    WriteTrace(veryhigh,ECAruleProcessor,['+ ',r(_n,_e,_a,_do,_else,_d,_queue)]),
    append_activerule2event(_n,_e,_m),
	find_uptodated_rules(_n,_e,[],_update_rules),
	find_events(_n,_events),
	update_ECAgraphs([],_,_update_rules),
	update_nest_predicates_tell(_n,_events),
	assert('nest@ECAruleManager'(_n,_update_rules,_events)),
	WriteTrace(veryhigh,ECAruleProcessor,['+',nest(_n,_nest,_events)]),
	analyse_rulegraph(_n,_nest,_cycle,g(_n,_list)),
{*	replace_ids_in_graph(_list,_listname), *}	{ LWEB }
	WriteTrace(veryhigh,ECAruleProcessor,['ECA RULE GRAPH >>> ',g(_Nn,_list)]),
        make_temp2persist.     {* ticket #255 *}



{ Fall 3: Auf false setzen, wenn schon false ist ==> ok }
activate_flag(_id,false) :-
	'eca@ECAruleManager'(_id,_e,_a,_do,_else,_p,_m,false,_d,_queue,_t, Now),
	!.

{ Fall 4: Auf false setzen, wenn true war }
activate_flag(_n,false) :-
	'eca@ECAruleManager'(_n,_e,_a,_do,_else,_p,_m,true,_d,_queue,_t, Now),
	!,
    retract('eca@ECAruleManager'(_n,_e,_a,_do,_else,_p,_m,true,_d,_queue,_t, Now)),
    WriteTrace(veryhigh,ECAruleProcessor,['-',eca(_n,_e,_a,_do,_else,_p,_m,true,_d,_queue,_t, Now)]),
    get_transaction_time(_tt),
    assert('eca@ECAruleManager'(_n,_e,_a,_do,_else,_p,_m,false,_d,_queue,_t, Now)),
    WriteTrace(veryhigh,ECAruleProcessor,['-',eca(_n,_e,_a,_do,_else,_p,_m,false,_d,_queue,_t, Now)]),
    retract('r@ECAruleManager'(_n,_e,_a,_do,_else,_d,_queue)),
    WriteTrace(veryhigh,ECAruleProcessor,['- ',r(_n,_e,_a,_do,_else,_m,_d,_queue)]),
    delete_rule2event(_n,_e,_m),
    retract('nest@ECAruleManager'(_n,_nest,_events)),
    WriteTrace(veryhigh,ECAruleProcessor,['-',nest(_n,_nest,_events)]),
    update_nest_predicates_untell(_n),
    update_ECAgraphs([],_,_nest).


{****************************************************************}
{ analyse_rulegraph/4						 }
{****************************************************************}

analyse_rulegraph(_r,_nest,_cycle,g(_r,_glist)):-
	drive_after_rules(_r,_rules),
	build_list_of_graphs(_rules,[_r],_nest,[],_cycle,_glist),
	(_cycle == [],!
	 ;
         replace_ids(_cycle,_cycle_with_names),
	 pc_atom_to_term(_atom,_cycle_with_names),
	 pc_atomconcat('There is a possiblity of cycles in the rule execution graph ! \n , cycle candidates :',_atom,_warning),
	 report_warning(_warning) ).


build_list_of_graphs([],_nest,_nest,_cycle,_cycle,[]).

build_list_of_graphs([_r|_rest],_back,_after,_acycle,_bcycle,[_r|_glist]):-
	pc_member(_r,_back),
	pc_member(_r,_acycle),!,
	build_list_of_graphs(_rest,_back,_after,_acycle,_bcycle,_glist).

build_list_of_graphs([_r|_rest],_back,_after,_acycle,_bcycle,[_r|_glist]):-
	pc_member(_r,_back),!,
	build_list_of_graphs(_rest,_back,_after,[_r|_acycle],_bcycle,_glist).

build_list_of_graphs([_r|_rest],_back,_after,_acycle,_bcycle,[g(_r,_rlist)|_glist]):-
	drive_after_rules(_r,_rules),
	build_list_of_graphs(_rules,[_r|_back],_after1,_acycle,_cycle1,_rlist),
	build_list_of_graphs(_rest,_back,_after2,_acycle,_cycle2,_glist),
	setUnion(_after1,_after2,_after),
	setUnion(_cycle1,_cycle2,_bcycle).

drive_after_rules(_r,_rules) :-
	drive_events_from_rule(_r,_events1),
	build_set(_events1,_events),
	drive_rules_from_events(_events,_rules).


{****************************************************************}
{ update_ECAgraphs/1						 }
{****************************************************************}
update_ECAgraphs(_after,_after,[]) .

update_ECAgraphs(_before,_after,[_n|_rest]) :-
	pc_member(_n,_before),
	update_ECAgraphs(_before,_after,_rest).

update_ECAgraphs(_before,_after,[_n|_rest]) :-
	analyse_rulegraph(_n,_nest,_cycle,g(_n,_list)),
	WriteTrace(veryhigh,ECAruleProcessor,['ECA RULE GRAPH >>> ',g(_n,_list)]),
	'nest@ECAruleManager'(_n,_update,_events),
	update_ECAgraphs([_n|_before],_after1,_update),
	update_ECAgraphs(_after1,_after,_rest).


find_events(_n,_events):-
	drive_events_from_rule(_n,_events1),
	build_set(_events1,_events).

build_set([],[]).
build_set([_r|_t],_nt):-
        match_member(_r,_t),!,
        build_set(_t,_nt).

build_set([_r|_t],[_r|_nt]):-
        build_set(_t,_nt).


match_member(_a,[_b|_t]):-
        pc_unifiable(_a,_b),
#IF(BIM)
        varlist(_a,_av),
        varlist(_b,_bv),
#ELSE(BIM)
        free_variables(_a,_av),
        free_variables(_b,_bv),
#ENDIF(BIM)
        length(_av,_na),length(_bv,_nb),
        _na=_nb,! .

match_pc_member(_a,[_b|_t]):-
        match_member(_a,_t).



find_uptodated_rules(_n,_e,_arules,_brules):-
	_ne = 'nest@ECAruleManager'(_r,_nest,_events),
	call(_ne),
	\+(pc_member(_r,_arules)),
	match_member2(_e,_events),
	find_uptodated_rules(_n,_e,[_r|_arules],_brules).

find_uptodated_rules(_n,_e,_rules,_rules).

match_member2(_e1,[_e2|_rest]):-
	pc_unifiable(_e1,_e2),
	! .

match_member2(_e1,[_e2|_rest]):-
	match_member(_e1,_rest).


update_nest_predicates_untell(_n):-
	_ne = 'nest@ECAruleManager'(_r,_nest,_events),
	call(_ne),
	pc_member(_n,_nest),
	delete_all(_n,_nest,_newnest),
	retract('nest@ECAruleManager'(_r,_nest,_events)),
    WriteTrace(veryhigh,ECAruleProcessor,['-',nest(_r,_nest,_events)]),
	assert('nest@ECAruleManager'(_r,_newnest,_events)),
    WriteTrace(veryhigh,ECAruleProcessor,['+',nest(_r,_newnest,_events)]),
	update_nest_predicates_untell(_n).


update_nest_predicates_untell(_).


update_nest_predicates_tell(_n,_events):-
	_ne = 'r@ECAruleManager'(_r,_e,_,_,_,_,_),
	call(_ne),
	'nest@ECAruleManager'(_r,_nest,_revents),
	match_member2(_e,_events),
	\+ pc_member(_n,_nest),
	retract('nest@ECAruleManager'(_r,_nest,_revents)),
    WriteTrace(veryhigh,ECAruleProcessor,['-',nest(_r,_nest,_revents)]),
	assert('nest@ECAruleManager'(_r,[_n|_nest],_revents)),
    WriteTrace(veryhigh,ECAruleProcessor,['+',nest(_r,[_n|_nest],_revents)]),
	update_nest_predicates_tell(_n,_events).


update_nest_predicates_tell(_,_).



{ ID's in der Graph-Representation durch Namen ersetzen (fuer ECARULE_GRAPH) }		{ LWEB }
replace_ids_in_graph([],[]).
replace_ids_in_graph([g(_nid,_list)|_rest],[g(_n,_listnames)|_nrest])	:-
	id2name(_nid,_n),
	replace_ids_in_graph(_list,_listnames),
	replace_ids_in_graph(_rest,_nrest),!.
replace_ids_in_graph([_nid|_rest],[_n|_nrest])	:-
	id2name(_nid,_n),
	replace_ids_in_graph(_rest,_nrest),!.


