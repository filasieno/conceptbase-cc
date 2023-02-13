/**
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
**/

/*
:::::::::::::
ECAruleManager.pro
:::::::::::::


* exported predicates
* -----------------
*
* + process_ecarules/4
*		Berechnet die aus einer SML-FragmentListe auszufuehrenden immediate Actions
*		und fuehrt diese aus.  Die deferred Actions und deferred ECA-Regeln werden zurueckgeliefert.
*
* + fire_def_ecarules/1
*		Fuehre die deferred ECA-Regeln aus/
*
* + fire_def_actions/1
*		Fuehre die deferred ECA-Actions aus
*
* + init_eca_state/0
*/

:- module('ECAruleManager',[
'fire_def_actions'/1
,'fire_def_ecarules'/1
,'existsECArule'/0
,'init_eca_state'/0
,'process_ecarules'/4
,'process_ECA_ExecutionQueue'/1
,'addlist_ECA_ExecutionQueue'/1
,'reset_ECA_ExecutionQueue'/0
,'branchExecutionQueue'/0
,'checkEndOfSubQueue'/1
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').


:- use_module('ECAqueryEvaluator.swi.pl').

:- use_module('ECAactionManager.swi.pl').

:- use_module('ECAeventManager.swi.pl').
:- use_module('ECAutilities.swi.pl').
:- use_module('GeneralUtilities.swi.pl').
:- use_module('PropositionProcessor.swi.pl').
:- use_module('Literals.swi.pl').


:- use_module('PrologCompatibility.swi.pl').


:- use_module('ErrorMessages.swi.pl').




















:- use_module('SearchSpace.swi.pl').
:- use_module('GlobalParameters.swi.pl').







:- dynamic 'depth_cycle@ECAruleManager'/2 .


:- style_check(-singleton).




/******************************************************************/
/* process_ecarules/4						 */
/******************************************************************/


process_ecarules(_,[],[],[]):- ! .

process_ecarules('Tell',_fragments, _deferredactions, _deferred_rules):-
	existsECArule,
	!,
	getEventsFromTmpProps('Tell',_listofEvents),
	do_ecarules(_listofEvents, _deferredactions, _deferred_rules).

process_ecarules('Untell',_fragments, _deferredactions, _deferred_rules):-
	existsECArule,
	!,
	getEventsFromTmpProps('Untell',_listofEvents),
	do_ecarules(_listofEvents, _deferredactions, _deferred_rules).

process_ecarules('Ask',_listofqueries, _deferredactions, _deferred_rules):-
        existsECArule,
        !,
        build_ask_events(_listofqueries,_listofEvents),
        do_ecarules(_listofEvents, _deferredactions, _deferred_rules).

/**Used for Untell triggered by ECAactions **/
process_ecarules('ECAaction',_listofEvents,_deferredactions,_deferred_rules) :-
        existsECArule,
        !,
        do_ecarules(_listofEvents, _deferredactions, _deferred_rules).


/* Keine ECA-Regel vorhanden */
process_ecarules(_,_,[],[]).


:- dynamic 'cachedExistsECArule'/0 .

existsECArule :-
	get_cb_feature(ecaControl,off),   /** ECA rules are globally turned off **/
	!,
	fail.

existsECArule :-
	cachedExistsECArule,
	!.

existsECArule :-
	name2id('ECArule',_ECArule),
	prove_edb_literal('In_e'(_e,_ECArule)),   /** only explicit instantiation plus instantiation via inheritance **/
	name2id('FALSE',_fid),
	\+(prove_literal('A'(_e,'ECArule',active,_fid))),
        assert(cachedExistsECArule),
        !.




/******************************************************************/
/* do_ecarules/3		 */
/******************************************************************/

do_ecarules([],[], []).

do_ecarules([_e|_es],_defacts,_defs) :-
	findall('e@ECAevent'(_e,_all_imm,_all_immdef,_all_def1),'e@ECAevent'(_e,_all_imm,_all_immdef,_all_def1),_events),
	do_ecarules2(_events,_defacts1,_defs1),
	do_ecarules(_es,_defacts2,_defs2),
	append(_defacts1,_defacts2,_defacts),
	append(_defs1,_defs2,_defs).

do_ecarules2([],[], []).
do_ecarules2(['e@ECAevent'(_event,_all_imm,_all_immdef,_all_def1)|_restevents], _deferredactions, _def):-
	!,
	filter_rules(_all_imm,_imm),
	filter_rules(_all_immdef,_immdef),
	filter_rules(_all_def1,_def1),
	fire_ecarules(_event,_imm),
	!,
	eval_immdef_ecarules(_event,_immdef, _deferredactions1),
	do_ecarules2(_restevents, _deferredactionrest, _defrest),
	append(_deferredactions1, _deferredactionrest, _deferredactions),
        appendDefRules(_event,_def1,_defrest,_def).

appendDefRules(_event,[],_defrest,_defrest) :- !.

appendDefRules(_event,_def1,_defrest,_def) :- 
  append([def_rules(_event,_def1)], _defrest, _def).






/******************************************************************/
/* fire_ecarules/2						 */
/******************************************************************/
fire_ecarules(_,[]).

fire_ecarules(_e,[_r|_rest]):-
	'r@ECAruleManager'(_r,_e,_a,_do,_else,_d,_queue),
	check_depth_of_cycle(_e,_r,_d),
	!,
	switchExecutionQueue(_queue),
	init_eca_execute,
	!,
        'WriteTrace'(high,'ECAruleManager',['Execute immediate rule ', idterm(_r), ' on event ',idterm(_e)]),
	fire_ecarule(_e,_r),
	!,
	fire_ecarules(_e,_rest).

fire_ecarules(_e,[_r|_rest]):-
	retractall('depth_cycle@ECAruleManager'(_,_)),
    report_error( 'ECA0', 'ECAruleManager' , [_r,_e]),
	!,
	fail.

/******************************************************************/
/* fire_def_ecarules/1						 */
/******************************************************************/

fire_def_ecarules([]) :- !.
fire_def_ecarules([def_rules(_e,[])]) :- !.
fire_def_ecarules([_r]):-
	!,
	fire_def_ecarules1([_r]).

fire_def_ecarules([_r|_rest]):-
	fire_def_ecarules1([_r]),!,
	fire_def_ecarules(_rest).

fire_def_ecarules1([]).

fire_def_ecarules1([def_rules(_e,[])]).

fire_def_ecarules1([def_rules(_e,[_r])]):-
	'r@ECAruleManager'(_r,_e,_a,_do,_else,_d,_queue),
	check_depth_of_cycle(_e,_r,_d),!,
	switchExecutionQueue(_queue),
	init_eca_execute,!,
	fire_ecarule(_e,_r),!.

fire_def_ecarules1([def_rules(_e,[_r|_rest])]):-
	'r@ECAruleManager'(_r,_e,_a,_do,_else,_d,_queue),
	check_depth_of_cycle(_e,_r,_d),!,
	switchExecutionQueue(_queue),
	init_eca_execute,!,
	fire_ecarule(_e,_r),!,
	fire_def_ecarules1([def_rules(_e,_rest)]).


fire_def_ecarules1([def_rules(_e,[_r|_rest])]):-
	retractall('depth_cycle@ECAruleManager'(_,_)),
    report_error( 'ECA0', 'ECAruleManager' , [_r,_e]),
	!,
	fail.


/******************************************************************/
/* fire_ecarule/2						 */
/******************************************************************/

fire_ecarule(_e,_r) :-
        'WriteTrace'(veryhigh,'ECAruleManager',['Fire rule ',idterm(_r), ' for event ', idterm(_e)]),
        do_fire_ecarule(_e,_r).

do_fire_ecarule(_e,_r):-
	'r@ECAruleManager'(_r,_e,'Ask'(_v,_q),_do,_else,_d,_queue),
	_v == [],
	pc_time(evalECAquery('Ask'(_v,_q),_answers),_tq),
	traceSlowECArule(_r,_tq,'eval IF-part(1)'),
	!,
	((answerEmptyOrFalse(_answers),
          fire_actions(_r,_,false,_do,_else)
	 );
	 (answerTrueOrNonEmpty(_answers),
	  fire_actions(_r,_,true,_do,_else)
	 )
	).

do_fire_ecarule(_e,_r):-
	'r@ECAruleManager'(_r,_e,'Ask'(_v,_q),_do,_else,_d,_queue),
	var(_v),
/**        profile(evalAndFire(_r,_q,_do,_else)), **/
        pc_time(evalAndFire(_r,_q,_do,_else),_te),   /**  will backtrack over all solutions to _q **/
	traceSlowECArule(_r,_te,'eval IF- and DO-parts'),

        !.



do_fire_ecarule(_e,_r):-
	'r@ECAruleManager'(_r,_e,'Ask'(_v,_q),_do,_else,_d,_queue),
	ground(_v),
	pc_time(evalECAquery('Ask'(_v,_q),_answers),_tq),
	traceSlowECArule(_r,_tq,'eval IF-part(2)'),
	!,
	(pc_member(_v,_answers),
	 !,
	fire_actions(_r,_,true,_do,_else)
	;
	fire_actions(_r,_,false,_do,_else)).

do_fire_ecarule(_e,_r):-
	 report_error( 'ECA1', 'ECAruleManager' , [formula(_e),objectName(_r)]),
	 !,
	 fail.


/** cases for variable-free answers **/
answerEmptyOrFalse([]).
answerEmptyOrFalse(allnew([])).
answerEmptyOrFalse(allold([])).
answerEmptyOrFalse(false).

answerTrueOrNonEmpty(_a) :- \+ answerEmptyOrFalse(_a).



/** report slow ECArules if tracemode >= veryhigh **/
traceSlowECArule(_r,_t,_n) :- 
   _t < 0.25,  /** measured in sec **/
   !.

traceSlowECArule(_r,_t,_n) :-
   'WriteTrace'(veryhigh,'ECAruleManager',['Slow ECArule ',idterm(_r),': ',_t,' sec needed for ',_n]). 



/** evalAndFire will first find all answers to _q . Then, it will match _q **/
/** with all answers, one by one. Each match will also bind variables in   **/
/** _do and _else. Hence, the _do part of the ECA rule is called for each  **/
/** matching answer to the IF part _q. This should solve ticket #83.       **/

evalAndFire(_r,_q,_do,_else) :-
	pc_time(evalECAquery('Ask'(_q),_answers),_tq),
	traceSlowECArule(_r,_tq,'eval IF-part(2)'),
        fire_actions_for_answers(_q,_answers,_r,_do,_else).


/** if _answers is empty, then we need to evaluate the _else part **/
/** Note that we need the cut here before the fire_actions        **/
/** because the _else action may contain a 'reject'. In this      **/
/** case, fire_actions_for_answers must fail as well to force     **/
/** fire_eca_rule into the fail case as well. Only then will      **/
/** the transaction be aborted.                                   **/

fire_actions_for_answers(_q,[],_r,_do,_else) :- 
   !,
   fire_actions(_r,_,false,_do,_else).

/** if _answers is not empty, then we evaluate the _do part for all **/
/** matches of _q to elements in _answers.                          **/

fire_actions_for_answers(_q,_answers,_r,_do,_else) :-
  pc_member(_q,_answers),  /** instantiates the free variables in _q and _do **/
/**
  WriteTrace(veryhigh,ECAruleManager,['Handling action for answer:',idterm(_q)]),
**/
  fire_actions(_r,_,true,_do,_else),
  fail.

fire_actions_for_answers(_q,_answers,_r,_do,_else).




/** For ImmediateDeferred ECArules: **/

unfold_actions_for_answers(_q,[],_r,_do,_else, 'ELSE',_else) :-
  !.


/** collect the actions for the answers in the style of Clocksin&Mellish findall **/
unfold_actions_for_answers(_q,_answers,_r,_do,_else,_,_actions) :-
   asserta('found@ECA'('%mark')),
   pc_member(_q,_answers),
   asserta('found@ECA'(_do)),
   fail.

unfold_actions_for_answers(_q,_answers,_r,_do,_else,'DO',_actions) :-
  unfold_collect_found([],_actions).

unfold_collect_found(_s,_l) :-
  unfold_get_next(_x),
  !,
  unfold_collect_found([_x|_s],_l).

unfold_collect_found(_l,_l).

unfold_get_next(_x) :-
  retract('found@ECA'(_x)),
  !,
  _x \== '%mark'.


  


/******************************************************************/
/* fire_def_actions/1						 */
/******************************************************************/


fire_def_actions([]).


/** ticket #244 **/
fire_def_actions([actionlist(_r,_blocktype,_actions)|_rest]):-
	init_eca_execute,!,
        execute_actionblock(_r,_blocktype,void,list,_actions),
        fire_def_actions(_rest).

fire_def_actions([action(_a1,_,noanswer,_a4)]):-
	init_eca_execute,!,
	fire_actions(_a1,_,true,_a4,_).
fire_def_actions([action(_a1,_a2,_a3,_a4)]):-
	init_eca_execute,!,
	fire_actions(_a1,_a2,_a3,_a4,_),!.
fire_def_actions([action(_a1,_a2,noanswer,_a4)|_r]):-
	init_eca_execute,!,
	fire_actions(_a1,_a2,true,_a4,_),!,
	fire_def_actions(_r).
fire_def_actions([action(_a1,_a2,_a3,_a4)|_r]):-
	init_eca_execute,!,
	fire_actions(_a1,_a2,_a3,_a4,_),!,
	fire_def_actions(_r).






/******************************************************************/
/* fire_actions/5						 */
/******************************************************************/
fire_actions(_r,_,[],_,_else):-
	!,execute_actionblock(_r,'ELSE',_,noanswer,_else).

fire_actions(_r,_,false,_,_else):-
	!,execute_actionblock(_r,'ELSE',_,noanswer,_else).

fire_actions(_r,_,true,_do,_):-
	!,execute_actionblock(_r,'DO',_,noanswer,_do).

fire_actions(_r,_v,_answers,_do,_):-
	_answers \== [] ,!,
	execute_actionblock(_r,'DO',_v,_answers,_do).




/******************************************************************/
/* eval_immdef_ecarules/3					 */
/*eval_immdef_ecarules(_event,list_of_rules,[(rule,list_of_actions),...])*/
/******************************************************************/

eval_immdef_ecarules(_,[],[]).
eval_immdef_ecarules(_e,[_r|_rest],[_action_tupel|_actionblocks]):-
	'r@ECAruleManager'(_r,_e,_a,_do,_else,_d,_queue),
	check_depth_of_cycle(_e,_r,_d),!,
	switchExecutionQueue(_queue),
        'WriteTrace'(veryhigh,'ECAruleManager',['Evaluate condition of ',idterm(_r), ' for event ', idterm(_e)]),
	eval_immdef_query(_e,_r,_action_tupel),!,
	eval_immdef_ecarules(_e,_rest,_actionblocks).

eval_immdef_ecarules(_e,[_r|_],[_|_]):-
        report_error( 'ECA0', 'ECAruleManager' , [_r,_e]),!,fail.

/******************************************************************/
/* eval_immdef_query/3					 	 */
/*eval_immdef_query(_event,rule,list_of_actions)			 */
/******************************************************************/



/** ticket #244 **/
eval_immdef_query(_e,_r, actionlist(_r,_blocktype,_actions)) :-
        'r@ECAruleManager'(_r,_e,'Ask'(_v,_q),_do,_else,_d,_queue),
	evalECAquery('Ask'(_q),_answers),
        unfold_actions_for_answers(_q,_answers,_r,_do,_else, _blocktype,_actions),
/**        WriteTrace(low,ECAruleManager,['Unfolded actions ',idterm(_actions)]), **/
        !.

/** legacy code **/
eval_immdef_query(_e,_r, _action_tupel) :-
	'r@ECAruleManager'(_r,_e,'Ask'(_v,_q),_do,_else,_d,_queue),
	var(_v),
	evalECAquery('Ask'(_v,_q),_answers),!,
	build_actiontupel(_r,_v,_answers,_do,_else,_action_tupel).

eval_immdef_query(_e,_r, _action_tupel) :-
	'r@ECAruleManager'(_r,_e,'Ask'(_v,_q),_do,_else,_d,_queue),
	ground(_v),
	evalECAquery('Ask'(_v,_q),_answers),!,
	(pc_member(_v,_answers),!,
	build_actiontupel(_r,_,true,_do,_else,_action_tupel)
	;
	build_actiontupel(_r,_,false,_do,_else,_action_tupel)).


eval_immdef_query(_e,_r,_):-
	 report_error( 'ECA1', 'ECAruleManager' , [formula(_e),objectName(_r)]),!,fail.

/******************************************************************/
/* build_actionblock/6					 	 */
/******************************************************************/
build_actiontupel(_r,_,[],_,_else,action(_r,_,noanswer,_else)).

build_actiontupel(_r,_,false,_,_else,action(_r,_,noanswer,_else)).

build_actiontupel(_r,_,true,_do,_,action(_r,_,noanswer,_do)).

build_actiontupel(_r,_v,_answers,_do,_,action(_r,_v,_answers,_do)):-
	_answers \== [].


/******************************************************************/
/* init_eca_state/0						 */
/******************************************************************/
init_eca_state :-
	retractall('depth_cycle@ECAruleManager'(_,_)),
	pc_rerecord('ECAEventManager','TempInsProps',[]),
	pc_rerecord('ECAEventManager','LastProp',id_0),
	pc_rerecord('ECAEventManager','TempDelProps',[]).


/******************************************************************/
/* check_depth_of_cycle/3					 */
/******************************************************************/
check_depth_of_cycle(_e,_r,_d):-
	((
	  pcall('depth_cycle@ECAruleManager'(_r,_depth)),
	  !,
	  _dNow is _depth + 1,
	  pc_update('depth_cycle@ECAruleManager'(_r,_dNow))
	 );
	 pc_update('depth_cycle@ECAruleManager'(_r,1))
    ),
	!,
	check_depth(_e,_r,_d).



check_depth(_e,_r,0):- !.  /** depth 0 means no limitation! **/

/** fail the ECArule evaluation if its depth has been exceeded **/
check_depth(_e,_r,_d):-
	'depth_cycle@ECAruleManager'(_r,_depth),
	_depth > _d,
        id2name(_r,_rname),
        'WriteTrace'(low,'ECAruleManager',['The maximum depth ',_d,' of ECArule ',_rname,' has been reached!']),
        pc_rerecord(ecaDepthReached,true),
        !,
        fail.

check_depth(_e,_r,_d).

/******************************************************************/
/* 	filter_rules/2					 */
/******************************************************************/

/* 19-Mar-1996 LWEB :  Filtriere  ECA Regeln aus _rules heraus, die im aktuellen Modulkontext nicht sichtbar sind */
filter_rules([],[]).
filter_rules([_r|_rest],[_r|_nrest])  :-
	retrieve_proposition('P'(_r,_r,_,_r)),
	filter_rules(_rest,_nrest).
filter_rules([_r|_rest],_nrest)  :-
	filter_rules(_rest,_nrest).



/** 7-Mar-2006/M.Jeusfeld: delay the firing of ECA rules/actions by imposing **/
/** a strict ecxecution order upon them. This replaces the old depth-first   **/
/** strategy that was in place before. In that regime, the newest trigger    **/
/** was executed first. This led to partial evaluations of some ECA rules    **/
/** which were interfered by ECA rule firings induced by the partial         **/
/** evaluation of the original ECA rule. See also ticket #93.                **/


/** Data structures:                                                         **/
/**                                                                          **/
/** NEXT_FREE: number of the next position to which an ECA rule or action    **/
/** to be fired will be allocated to.                                        **/
/** LAST_FIRED: position of the last ECA rule/action that has been dealt     **/
/** with                                                                     **/

/** Logic of the ECA_ExecutionQueue:                                         **/
/**                                                                          **/
/**  The two counters are set to their initial states by                     **/
/**  reset_ECA_ExecutionQueue. The initial state is NEXT_FREE=1 and          **/
/**  LAST_FIRED=0. In this state, there are now ECA elements in the queue.   **/
/**  The reset is done in BEGIN_TRANSACTION of CBserverInterface.pro.        **/
/**                                                                          **/
/**  The procedure addlist_ECA_ExecutionQueue will add a list of _elem to    **/
/**  the execution queue. The elements can be either def_rules(_e,_rules)    **/
/**  specifying that _rules were deferred for event _e, or actions. The      **/
/**  first type of element occurs when a deferred ECArule was triggered.     **/
/**  The second type of element occurs for ECArules of the mode              **/
/**  ImmediateDeferred (condition checked immediately, action executed       **/
/**  deferred. The procedure addlist_ECA_ExecutionQueue is called in         **/
/**  ObjectProcessor.pro as well as in ECAactionManager.pro. It replaces     **/
/**  there the calls fire_def_ecarules and fire_def_actions.                 **/
/**  The trick is that elements in the execution queue shall be processed    **/
/**  in the order in which they were entered (rather than 'last entered=     **/
/**  first to be executed' as done previously.                               **/
/**                                                                          **/
/**  The procedure process_ECA_ExecutionQueue will execute the elements      **/
/**  in the execution queue in the right order. It is called in              **/
/**  ObjectProcessor.pro and in TellAndAsk.pro.                              **/

/** For TRANSACTIONAL ECArules, we maintain several executions queues. The   **/
/** pre-defined are q0 (main) and q1 (generic sub-queue). The sub-queue q1   **/
/** is employed via the TRANSACTIONAL construct of ECArules or via a tBegin  **/
/** action (see ticket #279). Further user-defined queues are created via    **/
/** the "FOR x" construct of ECArules.                                       **/


reset_ECA_ExecutionQueue :-
  get_ECAqueues(_qlist),
  reset_ECAqueues(_qlist),
  set_ECAqueues([q1,q0]),        /** these are our fixed execution queues **/
  setCurrentQueue(q0),           /** start always with main queue **/
  pc_store(ecaDepthReached,false),
  !.

reset_ECA_ExecutionQueue.

/** We can have any number of ECA execution queues via the "FOR x" construct **/
/** of ECA rules.                                                            **/
reset_ECAqueues([]) :- !.

reset_ECAqueues([_q|_rest]) :-
  reset_ECA_ExecutionQueue(_q),
  reset_ECAqueues(_rest).



set_ECAqueues(_qlist) :-
  pc_store('ECA_QUEUES',_qlist).

get_ECAqueues(_qlist) :-
  pc_recorded('ECA_QUEUES',_qlist),
  !.
get_ECAqueues([q1,q0]).   /** if not yet defined: return q1,q0 **/


/** add a new user-defined ECA queue **/

add_ECAqueue(_q) :-
  get_ECAqueues(_qlist),
  \+ pc_member(_q,_qlist),
  reset_ECA_ExecutionQueue(_q),
  pc_store('ECA_QUEUES',[_q|_qlist]),
  'WriteTrace'(high,'ECAruleManager',['New ECA execution queue created: ',_q,' (sub-queue ',idterm(_q),')']),
  !.
add_ECAqueue(_q).




reset_ECA_ExecutionQueue(_EXECUTION_QUEUE) :-
  counterKeys(_EXECUTION_QUEUE,_NEXT_FREE,_LAST_FIRED),
  pc_recorded(_NEXT_FREE,_next),
  pc_recorded(_LAST_FIRED,_last),
  pc_rerecord(_NEXT_FREE,1),
  pc_rerecord(_LAST_FIRED,0),
  pc_erase_all(_EXECUTION_QUEUE),
  !.


reset_ECA_ExecutionQueue(_EXECUTION_QUEUE) :-
  counterKeys(_EXECUTION_QUEUE,_NEXT_FREE,_LAST_FIRED),
  pc_record(_NEXT_FREE,1),
  pc_record(_LAST_FIRED,0),
  !.



setCurrentQueue(_q) :-
  pc_store('CURRENT_QUEUE',_q).

getCurrentQueue(_EXECUTION_QUEUE) :-
  pc_recorded('CURRENT_QUEUE',_EXECUTION_QUEUE).


/** called by ECAactionManager for tBegin **/
branchExecutionQueue :-
  getCurrentQueue(q1),   /** we did already branch to the sub-queue **/
  !.

branchExecutionQueue :-
  getCurrentQueue(q0),
  setCurrentQueue(q1),   /** otherwise we perform the switch **/
  'WriteTrace'(high,'ECAruleManager',['Branch to sub-queue ',q1]),
  !.

branchExecutionQueue.  /** never fail **/


/** Ticket #279: switch the queue as indicated by ON-part of the current ECArule  **/
switchExecutionQueue(currentqueue) :- !.    /** default value: no change of queue **/

switchExecutionQueue(_newqueue) :-
  getCurrentQueue(_EXECUTION_QUEUE),
  _EXECUTION_QUEUE \== _newqueue,
  add_ECAqueue(_newqueue),
  setCurrentQueue(_newqueue),
  'WriteTrace'(high,'ECAruleManager',['Switch to sub-queue ',idterm(_newqueue)]),
  !.

switchExecutionQueue(_).




/** produce the labels of the counters _NEXT_FREE,_LAST_FIRED **/
counterKeys(_EXECUTION_QUEUE,_NEXT_FREE,_LAST_FIRED) :-
  pc_atomconcat(_EXECUTION_QUEUE,'nx',_NEXT_FREE),   
  pc_atomconcat(_EXECUTION_QUEUE,'lf',_LAST_FIRED).  



getCurrentKeys(_EXECUTION_QUEUE,_NEXT_FREE,_LAST_FIRED) :-
  getCurrentQueue(_EXECUTION_QUEUE),
  counterKeys(_EXECUTION_QUEUE,_NEXT_FREE,_LAST_FIRED).


/** triggers to empty rules sets can be ignored **/
add_ECA_ExecutionQueue(def_rules(_e,[])) :-
  !.

/** isolated noops (no operations) do not need to be scheduled as well **/
add_ECA_ExecutionQueue(actionlist(_r,_blocktype,[noop])) :-
  !.

/** unfold event trigger to multiple rules into multiple triggers to single rules **/
add_ECA_ExecutionQueue(def_rules(_e,[_r|_rest])) :-
  do_add_ECA_ExecutionQueue(def_rules(_e,[_r])),
  add_ECA_ExecutionQueue(def_rules(_e,_rest)),
  !.

add_ECA_ExecutionQueue(_elem) :-
  do_add_ECA_ExecutionQueue(_elem).



do_add_ECA_ExecutionQueue(_elem) :-
  getCurrentKeys(_EXECUTION_QUEUE,_NEXT_FREE,_LAST_FIRED),
  pc_recorded(_NEXT_FREE,_next),
  pc_recorded(_LAST_FIRED,_last),
  do_add_ECA_ExecutionQueue(_elem, _EXECUTION_QUEUE, _NEXT_FREE, _next, _last).

do_add_ECA_ExecutionQueue(_elem).  /** never fail **/



do_add_ECA_ExecutionQueue(_elem, _EXECUTION_QUEUE, _NEXT_FREE, _next, _last) :-
  _to is _next-1,
  _from is _last+1,
  alreadyScheduled(_elem, _EXECUTION_QUEUE, _from,_to),
  !.


do_add_ECA_ExecutionQueue(_elem, _EXECUTION_QUEUE, _NEXT_FREE, _next, _last) :-
  pc_inttoatom(_next,_nextatom),
  pc_record(_nextatom,_EXECUTION_QUEUE,_elem),
  _newnext is _next + 1,
  pc_rerecord(_NEXT_FREE,_newnext),
  'WriteTrace'(high,'ECAruleManager',['Added ',idterm(_elem),' at position ',
             _next,' of queue ',idterm(_EXECUTION_QUEUE)]),

  !.



/** Check whether _elem occurs in the list of scheduled elements **/
/** that have not yet been processed. Then, we do not need to    **/
/** schedule _elem again.                                        **/
/** Goal is to avoid unnecessary ECA rule triggers.              **/

alreadyScheduled(_elem,_EXECUTION_QUEUE, _current,_to) :-
  _current =< _to,
  pc_inttoatom(_current,_currentatom),
  pc_recorded(_currentatom,_EXECUTION_QUEUE,_elem),
/**  write(_elem),write(' was already queued'),nl, **/
  !.
alreadyScheduled(_elem,_EXECUTION_QUEUE, _current,_to) :-
  _current =< _to,
  _newcurrent is _current+1,
  alreadyScheduled(_elem,_EXECUTION_QUEUE,_newcurrent,_to).
  

addlist_ECA_ExecutionQueue([]) :- !.
addlist_ECA_ExecutionQueue([_elem|_rest]) :-
/**  ground(_elem),    action_lists may contain variables to be bound by Ask(lit) actions **/
  add_ECA_ExecutionQueue(_elem),
  addlist_ECA_ExecutionQueue(_rest).
addlist_ECA_ExecutionQueue(_).  /** never fail **/








/** this is just for reporting some performance statistics       **/
/** We sum up the number of triggers from both queues q0 and q1  **/

computeNumberofTriggers(_all) :-
  get_ECAqueues(_qlist),
  sumUpQueueSizes(0,_qlist,_all),
  !.

sumUpQueueSizes(_sofar,[],_sofar) :- !.

sumUpQueueSizes(_sofar,[_q|_rest],_all) :-
  counterKeys(_q,_NEXT_FREE_Q,_),
  pc_recorded(_NEXT_FREE_Q,_next_q),
  _trig_q is _next_q - 1,
  _new_sofar is _sofar + _trig_q,
  traceMessage(_q,_trig_q),
  sumUpQueueSizes(_new_sofar,_rest,_all).


traceMessage(_q,_trig_q) :-
  (_q=q0;_q=q1),
  'WriteTrace'(veryhigh,'ECAruleManager',[_q,': ',_trig_q, ' triggers.']),
  !.

traceMessage(_q,_trig_q) :-
  'WriteTrace'(veryhigh,'ECAruleManager',[_q,' (=queue for ',idterm(_q),'): ',_trig_q, ' triggers.']),
  !.



process_ECA_ExecutionQueue(_) :-
  process_ECA_ExecutionQueue.

process_ECA_ExecutionQueue(_all) :-
  computeNumberofTriggers(_all),
  (retract(cachedExistsECArule);true),  /** need to remove this cached fact for next transaction **/
  !.

process_ECA_ExecutionQueue('?').  /** never fail **/

process_ECA_ExecutionQueue :-
  pc_recorded(ecaDepthReached,false),  /** maximum depth of ECA rules has not yet been reached **/
  getCurrentKeys(_EXECUTION_QUEUE,_NEXT_FREE,_LAST_FIRED),
  pc_recorded(_NEXT_FREE,_next),
  pc_recorded(_LAST_FIRED,_last),
  _next > _last+1,
  do_process_ECA_ExecutionQueue(_EXECUTION_QUEUE,_NEXT_FREE,_LAST_FIRED),       /** inner iteration **/
  process_ECA_ExecutionQueue.          /** outer iteration **/


do_process_ECA_ExecutionQueue(_EXECUTION_QUEUE,_NEXT_FREE,_LAST_FIRED) :-
  repeat,
     pc_recorded(_LAST_FIRED,_last),
     pc_recorded(_NEXT_FREE,_next),
     _current is _last+1,
     _all is _next-1,
     pc_inttoatom(_current,_currentatom),
     pc_recorded(_currentatom,_EXECUTION_QUEUE,_elem),
     'WriteTrace'(high,'ECAruleManager',['Execute position ', _current,'/',_all,' of queue ',idterm(_EXECUTION_QUEUE)]),
     pc_rerecord(_LAST_FIRED,_current),  /** need to update the pointer here because ECA elem can force queue switch **/
     process_ECA_elem(_elem),
     pc_erase(_currentatom,_EXECUTION_QUEUE),   /** erase the elem just processed from the queue **/
     reportProgress(_last,_next), 
     checkEndOfSubQueue(_Q),  /** _Q=current queue; can have been changed by ECA elem **/
  (_current is _next-1;pc_recorded(ecaDepthReached,true); _Q \== _EXECUTION_QUEUE),
  !.

/** Leave the inner iteration with success if                        **/
/**   a) all elems of _EXECUTION_QUEUE are processed                 **/
/**   b) the maximum nesting depth for ECA rules has been exceeded   **/
/**   c) the current execution queue has been switched by an         **/
/**      action like tBegin                                          **/



/** if we are currently processing the sub-queue q1 and this q1 is empty **/
/** we need to return to the main queue q0.                              **/



do_checkEndOfSubQueue(_q) :-
  getCurrentKeys(_q,_NEXT_FREE,_LAST_FIRED),
  pc_recorded(_NEXT_FREE,_next),
  pc_recorded(_LAST_FIRED,_last),
  _next is _last + 1,     /** queue_q is completely processed **/
  'WriteTrace'(high,'ECAruleManager',['No more triggers in queue ',idterm(_q)]),
  switchToNextQueue,
  !.
do_checkEndOfSubQueue(_).  /** never fail **/

switchToNextQueue :-
  get_ECAqueues(_qlist),
  setNextNonEmpty(_qlist).



/** the current queue is empty; so find the next non-empty queue to **/
/** continue; as fail-safe switch to q0                             **/

setNextNonEmpty([q0]) :-
  setCurrentQueue(q0). /** return to main queue q0 **/

setNextNonEmpty([_q|_rest]) :-
  getCurrentKeys(_q,_NEXT_FREE,_LAST_FIRED),
  pc_recorded(_NEXT_FREE,_next),
  pc_recorded(_LAST_FIRED,_last),
  _next > _last + 1,     /** queue _q is NOT completely processed **/
  setCurrentQueue(_q).   /** set current queue to this non-empty queue **/

setNextNonEmpty([_|_rest]) :-
  setNextNonEmpty(_rest).





/** for tEnd **/

checkEndOfSubQueue(_Q) :-
  getCurrentQueue(_Q),
  do_checkEndOfSubQueue(_Q).





reportProgress(_last,_next) :-
  _last is (_last // 200) * 200,   /** last processed trigger is multitude of 100 **/
  _all is _next-1,
  'WriteListOnTrace'(low,['   ... processed ',_last,' out of ',_all, ' triggers']),
  !.
reportProgress(_,_).




process_ECA_elem(def_rules(_e,_ecarule_ids)) :-
  fire_def_ecarules([def_rules(_e,_ecarule_ids)]),
  !.

process_ECA_elem(action(_a1,_a2,_a3,_a4)) :-
  fire_def_actions([action(_a1,_a2,_a3,_a4)]),
  !.


/** ticket #244 **/
process_ECA_elem(actionlist(_r,_blocktype,_actions)) :-
  fire_def_actions([actionlist(_r,_blocktype,_actions)]),
  !.

process_ECA_elem(_elem) :-
  'WriteTrace'(low,'ECAruleManager',['Could not process ECA elem ',idterm(_elem)]),
  !.




  
