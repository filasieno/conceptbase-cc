/**
The ConceptBase.cc Copyright

Copyright 1987-2019 The ConceptBase Team. All rights reserved.

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
**/
/*
*
* File:         %M%
* Version:      %I%
* Creation:     3-Dec-1997 Christoph Quix (RWTH)
* Last Change   : %E%, Christoph Quix (RWTH)
*
* SCCS-Source-Pool : %P%
* Date retrieved : %D% (YY/MM/DD)
*
**************************************************************************
*
* This module translate the frame representation of an ECA rule into
* the term representation used for evaluating the rules.
*
*
*/


:- module('ECAruleCompiler',[
'compile_ecarule'/1
,'current_ecarule'/1
,'makeECAaction'/3
,'makeECAcondition'/3
,'makeECAevent'/3
,'untell_ecarule'/1
,'update_ecarule_del'/1
,'update_ecarule_ins'/1
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').

:- use_module('GeneralUtilities.swi.pl').









:- use_module('ECAutilities.swi.pl').
:- use_module('Literals.swi.pl').
:- use_module('ECAruleProcessor.swi.pl').


:- use_module('MSFOLpreProcessor.swi.pl').
:- use_module('AToAdot.swi.pl').
:- use_module('VarTabHandling.swi.pl').

:- use_module('parseAss_dcg.swi.pl').
:- use_module('ErrorMessages.swi.pl').
:- use_module('PropositionProcessor.swi.pl').


:- use_module('PrologCompatibility.swi.pl').



:- use_module('GlobalParameters.swi.pl').
:- use_module('SemanticOptimizer.swi.pl').
:- use_module('QO_preproc.swi.pl').

:- use_module('QO_search.swi.pl').
:- use_module('QO_literals.swi.pl').
:- use_module('MSFOLassertionTransformer.swi.pl').



:- dynamic 'current_ecarule'/1 .


:- style_check(-singleton).





/*********************************************************************/
/*                                                                   */
/* compile_ecarule(_ecaid)                                           */
/*                                                                   */
/* Description of arguments:                                         */
/*   ecaid : ID of the ecarule                                       */
/*                                                                   */
/* Description of predicate:                                         */
/*   Compiles an ecarule                                             */
/*********************************************************************/



compile_ecarule(_ecaid) :-
	id2name(_ecaid,_ecaname),
	pc_update(current_ecarule(_ecaname)),
	get_ecarule(_ecaid,_event,_condition,_actionlist,_elseactionlist,_queue),
	get_priority(_ecaid,_prior),
	get_mode(_ecaid,_mode),
	get_active(_ecaid,_active),
	get_depth(_ecaid,_depth),
	checkValidECA(_event,_condition,_actionlist,_elseactionlist),
	!,
	'error_number@F2P'(0),
        do_compile_ecarule(_ecaid,_event,_condition,_actionlist,_elseactionlist,_prior,_mode,_active,_depth,_queue),
	!.

do_compile_ecarule(_ecaid,_event,_condition,_actionlist,_elseactionlist,_prior,_mode,_active,_depth,_queue) :-
	get_cb_feature(ecaOptimize,off),
	insertPrologVars(eca(_ecaid,_event,_condition,_actionlist,_elseactionlist,_prior,_mode,_active,_depth,_queue),_newecarule1),
	fixDepth(_newecarule1,_newecarule),
	'ECATELL'([_newecarule],noerror),
	retract(current_ecarule(_ecaname)),
	!.

/** else: optimize the condition **/
do_compile_ecarule(_ecaid,_event,_condition,_actionlist,_elseactionlist,_prior,_mode,_active,_depth,_queue) :-
        simplifyCondition(_event,_condition,_condition0),
	checkPredicateMix(_condition0,_condition1,_mix),
        optimizeECAcondition(_event,_condition1,_condition2),
	_newecarule0 = eca(_ecaid,_event,_condition2,_actionlist,_elseactionlist,_prior,_mode,_active,_depth,_queue),
	insertPrologVars_atom(_newecarule0,_newecarule1),
        _newecarule1 = eca(_ecaid_p,_event_p,_condition2_p,_actionlist_p,_elseactionlist_p,_prior_p,_mode_p,_active_p,_depth_p,_queue_p),
	reorderJoins(_mix,_event_p,_condition2_p,_condition2_u),
	postProcEcaCond(_mix,_event_p,_condition2_u,_condition3a),
	reInsertNewTag(_mix,_condition3a,_condition3),
        _newecarule2 = eca(_ecaid_p,_event_p,_condition3,_actionlist_p,_elseactionlist_p,_prior_p,_mode_p,_active_p,_depth_p,_queue_p),
        insertPrologVars_var(_newecarule2,_newecarule3),
	fixDepth(_newecarule3,_newecarule),
	'ECATELL'([_newecarule],noerror),
	retract(current_ecarule(_ecaname)).




fixDepth(eca(_ecaid,_event,_condition,_actionlist,_elseactionlist,_prior,_mode,_active,_depth,_queue),
    eca(_ecaid,_event,_condition,_actionlist,_elseactionlist,_prior,_mode,_active,_depth1,_queue)) :-
    atom(_depth),
    !,
    pc_inttoatom(_depth1,_depth).

fixDepth(_eca,_eca).


/** try to convert an ECA consition into a flat list of predicates **/
/** representing their conjunction.                                **/

simplifyCondition(_,'Ask'(_mainvar,_cond),'Ask'(_mainvar,_cond1)) :-
  flattenAnd(_cond,_cond1),
  !.
simplifyCondition(_,_a,_a).

flattenAnd(and(_f1,_f2),_list) :-
  flattenAnd(_f1,_l1),
  flattenAnd(_f2,_l2),
  append(_l1,_l2,_list).

flattenAnd(_lit,[_lit]) :-
  _lit \= and(_,_),
  _lit \= or(_,_),
  !.


/** 2011-10-20: de-activate this step because it involves double calls to procedures of        **/
/** postProcEcaCond, and is not improving the quality of the optimization                      **/
/**
reorderJoins(_mix,_event,_condition1,_condition2) :-
  (_mix=allold;_mix=allnew),
  maskBoundEventVars(_mix,_event,_condition1,_condition1m,_mvars),
  optimizeECAJoinOrder(_condition1m,_condition2m),
  unmaskBoundEventVars(_mix,_event,_mvars,_condition2m,_condition2),
  !.
**/
reorderJoins(_mix,_event,_condition,_condition).


/** this is calling the regular Datalog optimizer based on size and instantiation of arguments **/
/** the first arg of bestFirstSearch is for the conclusion predicate; so 'void' in case of ECA **/


optimizeECAJoinOrder('Ask'(_m,_lits),'Ask'(_m,_optlits)) :-
  bestFirstSearch(void,_lits,_optlits),
  !.
optimizeECAJoinOrder(_cond,_cond).




/** check whether an ECA condition refers to the same search space for all **/
/** its predicates.                                                        **/
/** If all predicates are of form new(_lit), then the 2nd parameter        **/
/** contains the condition where the 'new' tag is stripped. This is        **/
/** needed to apply some optimization methods on the condition. We later   **/
/** re-insert the 'new' tag.                                               **/

checkPredicateMix('Ask'(_m,[new(_lit)|_rest]),'Ask'(_m,[_lit|_newrest]),allnew) :-
  checkAllNew(_rest,_newrest),
  !.

checkPredicateMix('Ask'(_m,[_lit|_rest]),'Ask'(_m,[_lit|_newrest]),allold) :-
  _lit \= new(_),
  checkAllOld(_rest,_newrest),
  !.

checkPredicateMix('Ask'(_m,_lits),'Ask'(_m,_lits),mixed) :-
  is_list(_lits),
  !.

checkPredicateMix(_cond,_cond,nolist) :-
  !.



checkAllNew([],[]) :- !.

checkAllNew([new(_lit)|_rest],[_lit|_newrest]) :-
  checkAllNew(_rest,_newrest).

checkAllOld([],[]) :- !.

checkAllOld([_lit|_rest],[_lit|_newrest]) :-
  _lit \= new(_),
  checkAllOld(_rest,_newrest).


/** the new tag was removed earlier: insert it again **/

reInsertNewTag(_mix,'Ask'(_m,[true]),'Ask'(_m,true) ) :- !.
reInsertNewTag(_mix,'Ask'(_m,[false]),'Ask'(_m,false) ) :- !.

reInsertNewTag(allnew,'Ask'(_m,_lits),'Ask'(_m,allnew(_lits)) ) :-
  !.

reInsertNewTag(allold,'Ask'(_m,_lits),'Ask'(_m,allold(_lits)) ) :-
  !.

/** else: do nothing **/
reInsertNewTag(_,_cond,_cond).





getMaskedVars(_event,_mvars) :-
  _event =.. [_op|_lit],
  getVars(_lit,_evars),
  maskedVars(_evars,_mvars),
  !.
getMaskedVars(_event,[]).

maskedVars([],[]) :- !.

maskedVars([_x|_resta],[_mx/_x|_restb]) :-
  atom(_x),
  pc_atomconcat('id_Var',_x,_mx),
  maskedVars(_resta,_restb).

maskedVars([_x|_resta],[_x/_x|_restb]) :-
  maskedVars(_resta,_restb).

maskBoundEventVars(_mix,_event,'Ask'(_m,_lits),'Ask'(_m,_maskedlits),_mvars) :-
  (_mix=allold;_mix=allnew),
  getMaskedVars(_event,_mvars),
  replaceMaskedVars(_mvars,insert,_lits,_maskedlits),
  !.

maskBoundEventVars(_mix,_event,_cond,_cond,[]).


unmaskBoundEventVars(_mix,_event,_mvars,'Ask'(_m,_maskedlits),'Ask'(_m,_lits)) :-
  (_mix=allold;_mix=allnew),
  replaceMaskedVars(_mvars,reset,_maskedlits,_lits),
  !.

unmaskBoundEventVars(_mix,_event,_mvars,_cond,_cond).



replaceMaskedVars(_mvars,_direction,[],[]) :- !.

replaceMaskedVars(_mvars,_direction,[_lit|_lits],[_mlit|_maskedlits]) :-
  _lit =.. [_fun|_args],
  maskArgs(_mvars,_direction,_args,_margs),
  _mlit =.. [_fun|_margs],
  replaceMaskedVars(_mvars,_direction,_lits,_maskedlits).


maskArgs(_mvars,_direction,[],[]) :- !.

maskArgs(_mvars,_direction,[_x|_restargs],[_newx|_restnewargs]) :-
  getNewX(_mvars,_direction,_x,_newx),
  maskArgs(_mvars,_direction,_restargs,_restnewargs).


getNewX(_mvars,insert,_x,_mx) :-
  member( _mx/_x, _mvars),
  !.

getNewX(_mvars,reset,_mx,_x) :-
  member( _mx/_x, _mvars),
  !.

getNewX(_,_,_x,_x).




/** check the well-formedness of the parsed ECArule; in particular we **/
/** check whether some object names were tagged as UNKNOWN by the     **/
/** parse. In such cases, the error number is incremented leading     **/
/** to a rejection of the new ECArule.                                **/

checkValidECA(_event,_condition,_actionlist,_elseactionlist) :-
  checkValidEvent(_event),
  checkValidECACondition(_condition),
  checkNoUNKNOWN(_actionlist),
  checkNoUNKNOWN(_elseactionlist),
  !.  
  /** more checks to be added if needed **/




checkValidEvent(_event) :-
  checkNoUNKNOWN(_event),
  checkEventPredicate(_event).

checkValidECACondition(_condition) :-
  checkNoUNKNOWN(_condition).

checkEventPredicate(_event) :-
  _event =.. [_op,'A'(_x,_m,_y)],
  member(_op,['Tell','Untell']),
  increment('error_number@F2P'),
  report_error('ECA_INVALID_EVENTLIT','ECAruleCompiler',[formula('A'(_x,_m,_y))]),
  !.
checkEventPredicate(_event).


checkNoUNKNOWN(_x) :-
  atom(_x),
  pc_atomconcat('%%UNKNOWN--',_,_x),
  increment('error_number@F2P'),
  !.

checkNoUNKNOWN(_x) :- atom(_x), !.


checkNoUNKNOWN([]) :- !.

checkNoUNKNOWN([_x|_rest]) :-
  checkNoUNKNOWN(_x),
  checkNoUNKNOWN(_rest).
 

checkNoUNKNOWN(_x) :-
  compound(_x),
  _x =.. [_f|_args],
  checkNoUNKNOWN(_f),
  checkNoUNKNOWN(_args).

  
  



/*********************************************************************/
/*                                                                   */
/* update_ecarule(_ecaid)                                            */
/*                                                                   */
/* Description of arguments:                                         */
/*   ecaid : ID of the ecarule                                       */
/*                                                                   */
/* Description of predicate:                                         */
/*   Updates the term of the ecarule, if some attributes are changed.*/
/*********************************************************************/



update_ecarule_ins(_ecaid) :-
    select2id('ECArule!active',_actid),
	retrieve_temp_ins('P'(_,_lid,'*instanceof',_actid)),
	(retrieve_temp_ins('P'(_lid,_ecaid,_,_valueid));
	 retrieve_proposition('P'(_lid,_ecaid,_,_valueid))
	),
	!,
	id2name(_valueid,_value),
	((_value == 'TRUE',
	  activate_flag(_ecaid,true)
	 );
	 (_value == 'FALSE',
	  activate_flag(_ecaid,false)
	)).

update_ecarule_ins(_ecaid) :-
	report_error('ECA_INV_UPDATE','ECAruleCompiler',[objectName(_ecaid)]),
	!,
	fail.




update_ecarule_del(_id) :-
    select2id('ECArule!active',_actid),
	retrieve_temp_del('P'(_,_lid,'*instanceof',_actid)),
	(retrieve_temp_del('P'(_lid,_id,_,_));
	 retrieve_proposition('P'(_lid,_id,_,_))
	),
	!,
	activate_flag(_id,true).



update_ecarule_del(_ecaid) :-
	report_error('ECA_INV_UPDATE','ECAruleCompiler',[objectName(_ecaid)]),
	!,
	fail.



/*********************************************************************/
/*                                                                   */
/* untell_ecarule(_ecaid)                                            */
/*                                                                   */
/* Description of arguments:                                         */
/*   ecaid : ID of the ecarule                                       */
/*                                                                   */
/* Description of predicate:                                         */
/*   Deletes the prolog term of an ECA rule.                         */
/*********************************************************************/




untell_ecarule(_eca) :-
	'ECAUNTELL'([_eca],noerror).





/*********************************************************************/
/*      P R I V A T E    P R E D I C A T E S                         */
/*********************************************************************/




get_ecarule(_ecaid,_event,_condition,_actionlist,_elseactionlist,_queue) :-
	prove_literal('A'(_ecaid,ecarule,_ruleid)),
	id2name(_ruleid,_ruletext),
	parseECArule(_ruletext,_event,_condition,_actionlist,_elseactionlist,_queue).



get_priority(_ecaid,priority(after(_after),before(_before))) :-
	get_priority_after(_ecaid,_after),
	get_priority_before(_ecaid,_before).

get_priority_after(_ecaid,_afterlist) :-
	save_setof(_afterid,[_afterid]^prove_literal('A'(_ecaid,'ECArule',priority_after,_afterid)),_afterlist).

get_priority_before(_ecaid,_afterlist) :-
	save_setof(_afterid,[_afterid]^prove_literal('A'(_ecaid,'ECArule',priority_before,_afterid)),_afterlist).


get_mode(_ecaid,immediate) :-
	name2id('Immediate',_immid),
	prove_literal('A'(_ecaid,'mode',_immid)),
	!.

get_mode(_ecaid,imm_def) :-
	name2id('ImmediateDeferred',_immid),
	prove_literal('A'(_ecaid,'mode',_immid)),
	!.

get_mode(_ecaid,deferred) :-
	name2id('Deferred',_immid),
	prove_literal('A'(_ecaid,'mode',_immid)),
	!.

/*default*/
get_mode(_ecaid,_defaultmode) :- 
	get_cb_feature(ecaDefaultMode,_defaultmode),   /** take the default mode from the get_cb_feature variable **/
	!.





get_active(_ecaid,'true') :-
	name2id('TRUE',_id),
	prove_literal('A'(_ecaid,active,_id)),
	!.

get_active(_ecaid,'false') :-
	name2id('FALSE',_id),
	prove_literal('A'(_ecaid,active,_id)),
	!.

/*default*/
get_active(_ecaid,'true') :- !.




get_depth(_ecaid,_int) :-
	prove_literal('A'(_ecaid,depth,_intid)),
	id2name(_intid,_inta),
	pc_inttoatom(_int,_inta),
	!.


/*default*/
get_depth(_ecaid,0) :- !.






/*********************************************************************/
/*  Parsing of ECA events, conditions, actions                       */
/*********************************************************************/





parseECArule(_ruletext,_event,_condition,_actionlist,_elseactionlist,_queue) :-
	'VarTabInit', /* Vartab is initialized only here, all variables are shared in subformulas */
	preProcess(rule,_ruletext,_tokens),
	buildECArule(ecarule(_event1,_condition1,_actionlist1,_elseactionlist1,_queue),_tokens,[]),
	insertVars(ecarule(_event1,_condition1,_actionlist1,_elseactionlist1,_queue),
			ecarule(_event,_condition,_actionlist,_elseactionlist,_queue)).





makeECAevent(_operation,_lit,_event) :-
	member(_operation,['Tell','Untell',tell,untell]),   /** Retell is not an event; Retell=Untell+Tell **/
        normalizeOpname(_operation,_normopname),
	member(_lit,['A'(_,_,_),'In'(_,_),'Isa'(_,_),'A_label'(_,_,_,_)]),
	aToAdot([_lit],[_lit2]),
	!,
	_event =.. [_normopname,_lit2].

makeECAevent(_ask,'In'(_v,_query),'Ask'('In'(_v,_query))) :-
	member(_ask,['Ask',ask]), 
	id2name(_query,_qname),
	prove_literal('In'(_query,id_65)),  /** id_65=QueryClass **/
	/*Builtin Queries gehen nicht, Probleme mit IDs usw. */
	not(prove_literal('In'(_query,id_77))).   /** id_77=BuiltinQueryClass **/

makeECAevent(_ask,_dexp,'Ask'(_dexp)) :-
	member(_ask,['Ask',ask]), 
	_dexp =.. [_query|_],
	id2name(_query,_qname),
	prove_literal('In'(_query,id_65)),  /** id_65=QueryClass **/
	/*Builtin Queries gehen nicht, Probleme mit IDs usw. */
	not(prove_literal('In'(_query,id_77))).  /** id_77=BuiltinQueryClass **/

makeECAevent(_operation,_lit,_) :-
	current_ecarule(_ecaname),
	report_error('ECA_INV_EVENT','ECAruleCompiler',[_ecaname,_operation,_lit]),
	!,
	fail.



/** if _IF=IFNEW, then all literals get the tag 'new(_lit)', i.e. are evaluated **/
/** against the new database state.                                             **/
makeECAcondition(_IF,_cond_in,_cond_out) :-
  makeECAcondition(_cond_in,_cond1),
  pushNewToLits(_IF,_cond1,_cond_out),
  !.
/** if anything goes wrong: only create the condition as with 'IF' **/
makeECAcondition(_,_cond_in,_cond_out) :-
  makeECAcondition(_cond_in,_cond_out).





makeECAcondition('TRUE',true) :- !.
makeECAcondition('FALSE',false) :- !.

makeECAcondition(new(_lit),new(_lit2)) :-
	!,
	makeECAcondition(_lit,_lit2).

makeECAcondition(not(_lit),not(_lit2)) :-
	!,
	makeECAcondition(_lit,_lit2).

makeECAcondition(and(_f1,_f2),and(_n1,_n2)) :-
	!,
	makeECAcondition(_f1,_n1),
	makeECAcondition(_f2,_n2).

makeECAcondition(or(_f1,_f2),or(_n1,_n2)) :-
	!,
	makeECAcondition(_f1,_n1),
	makeECAcondition(_f2,_n2).

makeECAcondition('A'(_x,_l,_y),_lit2) :-
	!,
	aToAdot(['A'(_x,_l,_y)],[_lit2]).

makeECAcondition('A_label'(_x,_l,_y,_lab),_lit2) :-
	!,
	aToAdot(['A_label'(_x,_l,_y,_lab)],[_lit2]).

/* Condition ist eine Query (wird vom Parser bei GenericQueries gemacht) */
makeECAcondition(_gq,_gq) :-
	!.

makeECAcondition(_lit,_) :-
	current_ecarule(_ecaname),
	report_error('ECA_INV_CONDITION','ECAruleCompiler',[_ecaname,_lit]),
	!,
	fail.


pushNewToLits('IFNEW',true,true) :- !.
pushNewToLits('IFNEW',false,false) :- !.
pushNewToLits('IFNEW',new(_lit),new(_lit)) :- !.
pushNewToLits('IFNEW',not(_lit),not(_lit2)) :-
  pushNewToLits('IFNEW',_lit,_lit2).
pushNewToLits('IFNEW',and(_f1,_f2),and(_n1,_n2)) :-
  pushNewToLits('IFNEW',_f1,_n1),
  pushNewToLits('IFNEW',_f2,_n2).
pushNewToLits('IFNEW',or(_f1,_f2),or(_n1,_n2)) :-
  pushNewToLits('IFNEW',_f1,_n1),
  pushNewToLits('IFNEW',_f2,_n2).
pushNewToLits('IFNEW',_lit,new(_lit)) :- !.

pushNewToLits(_,_f,_f).




/** internal name for ECA operations, we allow some variations in the Telos syntax **/
normalizeOpname(tell,'Tell') :- !.
normalizeOpname(untell,'Untell') :- !.
normalizeOpname(retell,'Retell') :- !.
normalizeOpname(ask,'Ask') :- !.
normalizeOpname(raise,'Raise') :- !.
normalizeOpname(raise,'Raise') :- !.
normalizeOpname(_op,_op).








makeECAaction(_opname,_lit,_action) :-
	normalizeOpname(_opname,_operation),
	member(_operation,['Tell','Retell','Untell']),
	member(_lit,['A'(_,_,_),'In'(_,_),'Isa'(_,_),'Adot'(_,_,_),'A_label'(_,_,_,_),'Adot_label'(_,_,_,_)]),
	aToAdot([_lit],[_lit2]),
	!,
	_action =.. [_operation,_lit2].


makeECAaction(_ask,_lit,'Ask'(_lit)) :-
	member(_ask,['Ask',ask,'ASK']),
	!.

makeECAaction(_call,_lit,'CALL'(_lit)) :-
	member(_call,['Call',call,'CALL']),
	!.

makeECAaction(_raise,_dexp,'Raise'(_dexp)) :-
	member(_raise,['Raise',raise,'RAISE']),
	!.

makeECAaction(_operation,_lit,_) :-
	current_ecarule(_ecaname),
	report_error('ECA_INV_ACTION','ECAruleCompiler',[_ecaname,_operation,_lit]),
	!,
	fail.




insertVars(ecarule(_event,_cond,_actionlist,_elseactionlist,_q),ecarule(_event,_newcond,_newactionlist,_newelseactionlist,_q)) :-
	getVarsOfLit(_event,_eventvars),
	getVarsOfLit(_cond,_condvars),
	difference(_condvars,_eventvars,_resultcondvars1),
	makeset(_resultcondvars1,_resultcondvars),
	testResultVars(_resultcondvars,_resultvar),
	_newcond='Ask'(_resultvar,_cond),
	setUnion(_eventvars,_condvars,_ecvars),
	insertVarsInActionList(_actionlist,_ecvars,_newactionlist),
	insertVarsInActionList(_elseactionlist,_ecvars,_newelseactionlist),
	!.

insertVars(_,_) :-
	current_ecarule(_ecarule),
	report_error('ECA_INCORRECT_VARIABLES','ECAruleCompiler',[_ecarule]),
	!,
	fail.




getVarsOfLit(_var,[_var]) :-
	atom(_var),
	'VarTabVariable'(_var),
	!.

getVarsOfLit(_oid,[]) :-
	atom(_oid),
	!.

getVarsOfLit([],[]) :-
	!.

getVarsOfLit([_a|_as],_vs3) :-
	!,
	getVarsOfLit(_a,_vs1),
	getVarsOfLit(_as,_vs2),
	append(_vs1,_vs2,_vs3).

getVarsOfLit(_f,_vs) :-
	_f =.. [_h|_args],
	!,
	getVarsOfLit(_args,_vs).






/** 27-Oct-2005/M.Jeusfeld: ECA rules in ConceptBase suffer from the **/
/** (not-documented) restriction that there may be at most one free  **/
/** variable in the combined expression for the event (ON-part) and  **/
/** the condition (IF-part). This free variabe is the one that shall **/
/** be iterated over, i.e. the system tries to find all possible     **/
/** fillers for the free variable and will then call the action      **/
/** (DO-part) for all such fillers. It would be far more useful, if  **/
/** any number of free variables would be allowed in the IF-part     **/
/** and that the DO-part would be executed for any combination of    **/
/** fillers for the free variables that match the IF-part condition. **/
/** To do so, we relax the test in testResultVars to allow basically **/
/** any number of free variables. Since testResultVars is supposed   **/
/** return one free variable in its second argument, we just take the**/
/** first one if available. This is a change without overseeing all  **/
/** its consequences. It might well not work at all. But we are      **/
/** confident that it will behave the same if there is at most one   **/
/** free variable.                                                   **/

testResultVars([],[]) :-
	!.
testResultVars([_v|_],_v) :-    /** this restricted to [_v] before **/
	!.







insertVarsInActionList([],_,[]).

insertVarsInActionList([_act|_r],_ecvars,[_nact|_nr]) :-
	getVarsOfLit(_act,_vars),
	difference(_vars,_ecvars,_actvars),
	insertVarsInAction(_act,_actvars,_nact),
	setUnion(_vars,_ecvars,_newvars),
	insertVarsInActionList(_r,_newvars,_nr).


/* Tell/Untell darf keine freie Variablen enthalten */
insertVarsInAction(_act,_vars,_act) :-
	_act =.. [_op|_],
	member(_op,['Tell','Untell','Retell',noop,reject,tBegin,tEnd]),
	!,
	_vars=[].

/* Raise darf bel. viele freie Variablen enthalten */
insertVarsInAction(_act,_vars,_act) :-
	_act =.. ['Raise'|_],
	!.

/* CALL darf bel. viele freie Variablen enthalten */
insertVarsInAction(_act,_vars,_act) :-
	_act =.. ['CALL'|_],
	!.

/* Ask darf max. eine freie Var. haben */
insertVarsInAction('Ask'(_lit),_vars,'Ask'(_var,_lit)) :-
	testResultVars(_vars,_var),
	!.



/* Ersetzt in einem Term alle Atome, die Variablen sind (d.h. in VarTab stehen) */
/* durch Prolog-Variablen. Dabei muessen natuerlich gleiche Variablen gleiche */
/* Prolog-Variablen haben. */


insertPrologVars_atom(_i,_o) :-
  insertPrologVars2(_i,_o).

insertPrologVars_var(_i,_o) :-
  insertPROLOGVars(_i,_o).





insertPrologVars(_i,_o) :-
	insertPrologVars2(_i,_o1),
	insertPROLOGVars(_o1,_o).



insertPrologVars2([],[]) :- !.

insertPrologVars2([_a|_r],[_na|_nr]) :-
	!,
	insertPrologVars2(_a,_na),
	insertPrologVars2(_r,_nr).


insertPrologVars2(_var,_pvar) :-
	atom(_var),
	'VarTabVariable'(_var),
	!,
	pc_atomconcat('_',_var,_pvar).


insertPrologVars2(_ecaterm,_newterm) :-
	_ecaterm =..[_fun|_args],
	_args \== [],
	!,
   	insertPrologVars2(_args,_nargs),
	_newterm=..[_fun|_nargs].


insertPrologVars2(_a,_a).





