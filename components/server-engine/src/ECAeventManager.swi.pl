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
% :::::::::::::
% ECAeventManager.pro
% :::::::::::::
%

:- module('ECAeventManager',[
'append_activerule2event'/3
,'append_rule2event'/3
,'delete_rule2event'/3
,'drive_events_from_rule'/2
,'drive_rules_from_events'/2
,'fast_diff'/3
,'getEventsFromTmpProps'/2
,'same_event'/2
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').
:- use_module('GeneralUtilities.swi.pl').
:- use_module('ECAutilities.swi.pl').
:- use_module('PrologCompatibility.swi.pl').
:- use_module('PropositionProcessor.swi.pl').
:- use_module('PropositionsToLiterals.swi.pl').
:- use_module('Literals.swi.pl').
:- style_check(-singleton).
% ********************************************************************
%  append_rule2event/3
% ********************************************************************

append_rule2event(_r,_e1,immediate):-
	('e@ECAevent'(_e2,_imm,_imm_def,_def),
	 same_event(_e1,_e2),
	 !,
	 (pc_member(_r,_imm),
	  !;
	  insert_rule(_r,_imm,_immnew)
	 ),
	 assert('e@ECATEMP'(_e1,_immnew,_imm_def,_def))
	 ;
	 assert('e@ECATEMP'(_e1,[_r],[],[] ))
	).
append_rule2event(_r,_e1,imm_def):-
	('e@ECAevent'(_e2,_imm,_imm_def,_def),
	 same_event(_e1,_e2),
	 !,
	 (pc_member(_r,_imm_def),! ;insert_rule(_r,_imm_def,_imm_defnew)),
	 assert('e@ECATEMP'(_e1,_imm,_imm_defnew,_def))
	;
	assert('e@ECATEMP'(_e1,[],[_r],[] ))).
append_rule2event(_r,_e1,deferred):-
	('e@ECAevent'(_e2,_imm,_imm_def,_def),
	 same_event(_e1,_e2),
 	 !,
	 (pc_member(_r,_def),! ;insert_rule(_r,_def,_defnew)),
	 assert('e@ECATEMP'(_e1,_imm,_imm_def,_defnew))
	;
	assert('e@ECATEMP'(_e1,[],[],[_r] ))) .
% ********************************************************************
%  append_activerule2event/3
% ********************************************************************

append_activerule2event(_r,_e1,immediate):-
	'e@ECAevent'(_e2,_imm,_imm_def,_def),
	same_event(_e1,_e2),
	retract('e@ECAevent'(_e2,_imm,_imm_def,_def)),
	!,
	'WriteTrace'(veryhigh,'ECAeventManager',['- ',idterm(e(_e1,_imm,_imm_def,_def))]),
	insert_activerule(_r,_imm,_immnew),
	assert('e@ECAevent'(_e1,_immnew,_imm_def,_def)),
	'WriteTrace'(veryhigh,'ECAeventManager',['+ ',idterm(e(_e1,_immnew,_imm_def,_def))])
	;
	assert('e@ECAevent'(_e1,[_r],[],[] )),
    'WriteTrace'(veryhigh,'ECAeventManager',['+ ',e(_e1,[_r],[],[])]).
append_activerule2event(_r,_e1,imm_def):-
	'e@ECAevent'(_e2,_imm,_imm_def,_def),
	same_event(_e1,_e2),
	retract('e@ECAevent'(_e2,_imm,_imm_def,_def)),
	!,
	'WriteTrace'(veryhigh,'ECAeventManager',['- ',idterm(e(_e1,_imm,_imm_def,_def))]),
	insert_activerule(_r,_imm_def,_imm_defnew),
	 assert('e@ECAevent'(_e1,_imm,_imm_defnew,_def)),
	'WriteTrace'(veryhigh,'ECAeventManager',['+ ',idterm(e(_e1,_imm,_imm_defnew,_def))])
	;
	assert('e@ECAevent'(_e1,[],[_r],[] )),
	'WriteTrace'(veryhigh,'ECAeventManager',['+ ',idterm(e(_e1,[],[_r],[]))]).
append_activerule2event(_r,_e1,deferred):-
	'e@ECAevent'(_e2,_imm,_imm_def,_def),
	same_event(_e1,_e2),
	retract('e@ECAevent'(_e2,_imm,_imm_def,_def)),
	!,
	'WriteTrace'(veryhigh,'ECAeventManager',['- ',idterm(e(_e1,_imm,_imm_def,_def))]),
	insert_activerule(_r,_def,_defnew),
	assert('e@ECATEMP'(_e1,_imm,_imm_def,_defnew)),
	'WriteTrace'(veryhigh,'ECAeventManager',['+ ',idterm(e(_e1,_imm,_imm_def,_defnew))])
	;
	assert('e@ECATEMP'(_e1,[],[],[_r] )),
	'WriteTrace'(veryhigh,'ECAeventManager',['+ ',idterm(e(_e1,[],[],[_r]))]).
% ********************************************************************
%  delete_rule2event/3
% ********************************************************************

delete_rule2event(_n,_e1,immediate) :-
	'e@ECAevent'(_e2,_imm,_imm_def,_def),
	same_event(_e1,_e2),
	retract('e@ECAevent'(_e2,_imm,_imm_def,_def)),
	!,
	'WriteTrace'(veryhigh,'ECAeventManager',['- ',idterm(e(_e1,_imm,_imm_def,_def))]),
	delete_all(_n,_imm,_imm1),
	!,
	assert('e@ECAevent'(_e1,_imm1,_imm_def,_def)),
	'WriteTrace'(veryhigh,'ECAeventManager',['+ ',idterm(e(_e1,_imm1,_imm_def,_def))]).
delete_rule2event(_n,_e1,imm_def) :-
	'e@ECAevent'(_e2,_imm,_imm_def,_def),
	same_event(_e1,_e2),
	retract('e@ECAevent'(_e2,_imm,_imm_def,_def)),
	!,
	'WriteTrace'(veryhigh,'ECAeventManager',['- ',idterm(e(_e1,_imm,_imm_def,_def))]),
	delete_all(_n,_imm_def,_imm_def1),
	!,
	assert('e@ECAevent'(_e1,_imm,_imm_def1,_def)),
	'WriteTrace'(veryhigh,'ECAeventManager',['+ ',idterm(e(_e1,_imm,_imm_def1,_def))]).
delete_rule2event(_n,_e1,deferred) :-
	'e@ECAevent'(_e2,_imm,_imm_def,_def),
	same_event(_e1,_e2),
	retract('e@ECAevent'(_e2,_imm,_imm_def,_def)),
	!,
	'WriteTrace'(veryhigh,'ECAeventManager',['- ',idterm(e(_e1,_imm,_imm_def,_def))]),
	delete_all(_n,_def,_def1),
	!,
	assert('e@ECAevent'(_e1,_imm,_imm_def,_def1)),
	'WriteTrace'(veryhigh,'ECAeventManager',['+ ',idterm(e(_e1,_imm,_imm_def,_def1))]).
delete_rule2event(_,_,_).
% ********************************************************************
%  insert_rule/3
% ********************************************************************

insert_rule(_r,[],[_r]).
insert_rule(_r,[_r1|_rest],[_r1|_newrest]):-
	'eca@ECATEMP'(_r,_,_,_,_,_,_m,_,_,_,_,'Now'),
	'eca@ECAruleManager'(_r1,_,_,_,_,_,_m1,_,_,_,_,'Now'),
	'priority@ECATEMP'(_r,_af,_be),
	'priority@ECAruleManager'(_r1,_af1,_be1),
	 high_priority(rule(_r1,_m1,_af1,_be1),rule(_r,_m,_af,_be)),!,
	 insert_rule(_r,_rest,_newrest).
insert_rule(_r,[_r1|_rest1],_rulelist):-!,
	'priority@ECATEMP'(_r,_af,_be),
	intersect(_rest1,_af,_inters),
	difference(_rest1,_inters,_list),
	append(_inters,[_r,_r1|_list],_rulelist).

insert_activerule(_r,[],[_r]).
insert_activerule(_r,[_r1|_rest],[_r1|_newrest]):-
	'eca@ECAruleManager'(_r,_,_,_,_,_,_m,_,_,_,_,'Now'),
	'eca@ECAruleManager'(_r1,_,_,_,_,_,_m1,_,_,_,_,'Now'),
	'priority@ECAruleManager'(_r,_af,_be),
	'priority@ECAruleManager'(_r1,_af1,_be1),
	 high_priority(rule(_r1,_m1,_af1,_be1),rule(_r,_m,_af,_be)),!,
	 insert_activerule(_r,_rest,_newrest).
insert_activerule(_r,[_r1|_rest1],_rulelist):-!,
	'priority@ECAruleManager'(_r,_af,_be),
	intersect(_rest1,_af,_inters),
	difference(_rest1,_inters,_list),
	append(_inters,[_r,_r1|_list],_rulelist).

high_priority(rule(_r1,_m1,_af1,_be1),rule(_r,_m,_af,_be)):-
	high_modus(_m1,_m)
	;
	pc_member(_r1,_af)
	;
	pc_member(_r,_be1)
	;
	(\+ pc_member(_r,_af1),
	\+ pc_member(_r,_be1),
	\+ pc_member(_r1,_af),
	\+ pc_member(_r1,_be)).
% ********************************************************************
% drive_events_from_rule/2
% ********************************************************************

drive_events_from_rule(_r,_events):-
	'r@ECAruleManager'(_r,_e,_a,_do,_else,_d,_queue),
	drive_events([_a],_aske),
	drive_events(_do,_doe),
	drive_events(_else,_elsee),
	append(_aske,_doe,_events1),
	append(_events1,_elsee,_events).

drive_events([],[]).
drive_events([noop|_actions],_events):-
	drive_events(_actions,_events).
drive_events([reject|_actions],_events):-
	drive_events(_actions,_events).
drive_events([_a|_actions],_events):-
	_a =.. ['CALL'|_],!,
	drive_events(_actions,_events).
drive_events(['Ask'(_v,true)|_actions],_events):-
	drive_events(_actions,_events).
drive_events(['Ask'(_v,false)|_actions],_events):-
	drive_events(_actions,_events).
drive_events([_a|_actions],[_e|_events]):-
	drive_event(_a,_e),
	drive_events(_actions,_events).

drive_event(_e,_e) :-
	_e =.. [_f|_],
	pc_member(_f,['Ask','Tell','Untell','Retell']).
% ********************************************************************
% drive_rules_from_events/2
% ********************************************************************

drive_rules_from_events([],[]).
drive_rules_from_events([_e|_events],_rules):-
	'e@ECAevent'(_e,_imm,_imm_def,_def),!,
	append([_imm,_imm_def,_def],_rules1),
	drive_rules_from_events(_events,_rules2),
	append(_rules1,_rules2,_rules).
drive_rules_from_events([_e|_events],_rules):-
	drive_rules_from_events(_events,_rules).
% ***************************************************************
%
%  getEventsFromTmpProps(_eventType,_listOfEvents)
%
%  Description of arguments:
% listOfEvents : events for temporary propositions
% eventType    : Tell/Untell
%
%  Description of predicate:
%   Generates an event list from the temporary propositions that have
%   been added since the last call.
%  (RecordDB init takes place in init_eca_state$ECAruleManager)
% ***************************************************************
%  7-Apr-2006/M.Jeusfeld: Use retrieve_temp_ins_set instead of the
%  save_setof. The procedure  retrieve_temp_ins_set already
%  returns a sorted list of propositions. No need to construct it
%  tuple-at-a-time from itself.

getEventsFromTmpProps('Tell',_listOfEvents) :-
	(pc_recorded('ECAEventManager','LastProp',_lastprop);_lastprop=id_0),
	!,
% 	save_setof(P(_a,_b,_c,_d),P(_a,_b,_c,_d)^retrieve_temp_ins(P(_a,_b,_c,_d)),_tmpprops2),

        retrieve_temp_ins_set('P'(_a,_b,_c,_d),_tmpprops2), 
        getNewProps(_lastprop,_tmpprops2,_newprops),
        getLastProp(_lastprop,_newprops,_newlastprop),
	pc_rerecord('ECAEventManager','LastProp',_newlastprop),
        getNewProps(_lastprop,_tmpprops2,_newprops),
% 	fast_diff(_tmpprops2,_tmpprops,_newprops),

	prop2lit('Tell',_newprops,_lits),
	save_setof('Tell'(_l),[_l]^pc_member(_l,_lits),_listOfEvents).
%  the Untell case does not yet use retrieve_temp_del_set because I am unsure
%  whether it returns the result in a sorted list. M.Jeusfeld 7-Apr-2006

getEventsFromTmpProps('Untell',_listOfEvents) :-
	(pc_recorded('ECAEventManager','TempDelProps',_tmpprops);_tmpprops=[]),
	!,
	save_setof('P'(_a,_b,_c,_d),'P'(_a,_b,_c,_d)^retrieve_temp_del('P'(_a,_b,_c,_d)),_tmpprops2), 
%         retrieve_temp_del_set(P(_a,_b,_c,_d),_tmpprops2),

	pc_rerecord('ECAEventManager','TempDelProps',_tmpprops2),
	fast_diff(_tmpprops2,_tmpprops,_newprops),
	prop2lit('Untell',_newprops,_lits),
	save_setof('Untell'(_l),[_l]^pc_member(_l,_lits),_listOfEvents).

getNewProps(_lastprop,['P'(_id,_x,_l,_y)|_rest],['P'(_id,_x,_l,_y)|_rest]) :-
  _id @> _lastprop,
  !.
getNewProps(_lastprop,['P'(_id,_x,_l,_y)|_rest],_newprops) :-
  getNewProps(_lastprop,_rest,_newprops).
getNewProps(_lastprop,[],[]).

getLastProp(_old,[],_old) :- !.
getLastProp(_old,['P'(_id,_x,_l,_y)],_id) :- !.
getLastProp(_old,['P'(_id,_x,_l,_y)|_rest],_newlast) :-
  getLastProp(_old,_rest,_newlast).
%  fast_diff cpmputes the difference between 2 sorted lists -> has complexity O(n) instead O(n^2)

fast_diff(_xs,[],_xs) :- !.
fast_diff([],_,[]) :- !.
fast_diff([_x|_r],[_x|_r2],_n) :-
	!,
	fast_diff(_r,_r2,_n).
fast_diff([_x|_r],[_y|_r2],[_x|_n]) :-
	_x @< _y,
	!,
	fast_diff(_r,[_y|_r2],_n).
%  if x > y then we need to skip y and proceed with the rest r2; we do not
%  yet know whether or not we need to drop x; ticket #245

fast_diff([_x|_r],[_y|_r2],_n) :-
	!,  % x > y
	fast_diff([_x|_r],_r2,_n).

same_event(_e1,_e2) :-
	var(_e1),
	!,
	var(_e2).
same_event(_e1,_e2) :-
	atom(_e1),
	!,
	atom(_e2),
	_e1 == _e2 .
same_event([_e1|_e1s],[_e2|_e2s]) :-
	!,
	same_event(_e1,_e2),
	same_event(_e1s,_e2s).
same_event(_e1,_e2) :-
	_e1 =.. [_func|_args1],
	!,
	_e2 =.. [_func|_args2],
	same_event(_args1,_args2).
