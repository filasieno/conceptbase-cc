/**
The ConceptBase.cc Copyright

Copyright 1987-2025 The ConceptBase Team. All rights reserved.

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
ECAactionManager.pro
:::::::::::::

*/

:- module('ECAactionManager',[
'execute_actionblock'/5
,'init_eca_execute'/0
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').

:- use_module('ObjectTransformer.swi.pl').



:- use_module('ErrorMessages.swi.pl').
:- use_module('GeneralUtilities.swi.pl').
:- use_module('PropositionProcessor.swi.pl').
:- use_module('ECAqueryEvaluator.swi.pl').
:- use_module('Literals.swi.pl').

:- use_module('ECAruleManager.swi.pl').
:- use_module('FragmentToHistoryPropositions.swi.pl').


:- use_module('ScanFormatUtilities.swi.pl').



:- use_module('FragmentToPropositions.swi.pl').
:- use_module('SelectExpressions.swi.pl').
:- use_module('PrologCompatibility.swi.pl').






:- use_module('MetaUtilities.swi.pl').
:- use_module('TellAndAsk.swi.pl').



:- use_module('BIM2C.swi.pl').




:- use_module('cbserver.swi.pl').

:- use_module('validProposition.swi.pl').






:- style_check(-singleton).



/** This is the main interface to execute ECA actions. The parameter _r identifies the **/
/** ECArule, _blocktype specifies whether the DO or ELSE part is being executed, _v is **/
/** a running variable for _answers to the IF part of the ECArule, and finally _actions**/
/** is a list of actions to be executed. The first two parameters are included for     **/
/** generating readable traces.                                                        **/

execute_actionblock(_r,_blocktype,_v,_answers,_actions):-
        reset_counter_if_undefined('error_number@ECA'),   /** use instead of ECAexecute_error **/
	setCheckUpdateMode('YES'),   /** if the original transction was an ASK, then we now have to consider it as updating the database **/
/**
        reset_counter_if_undefined('error_number@F2P'),
        reset_counter_if_undefined('error_number@F2HP'),
**/
	execute_actionblock1(_r,_blocktype,_v,_answers,_actions),
	!,
        'error_number@ECA'(0).

execute_actionblock(_r,_blocktype,_v,_answers,_actions):-
	report_error( 'ECA2', 'ECAactionManager' , [objectName(_r),_actions]),
	!,
	fail.

/******************************************************************/
/* execute_actionblock/5						                     */
/* Fuehrt die Aktionen aus und bindet dabei die Variable an die   */
/* Ergebnisse einer Query!                                        */
/* r ist ruleid, v die Variable, answers das Queryergebnis.       */
/******************************************************************/

/** for actionlists generated in mode ImmediateDeferred **/
/** actions in actionslists can be lists of lists! **/
execute_actionblock1(_r,_blocktype,void,list,_actions) :- 
       execute_actions(_r,_blocktype,_actions).


/* noanswer - nur dieser Fall */
execute_actionblock1(_r,_blocktype,_,noanswer,_actions) :-
	!,
	execute_actions(_r,_blocktype,_actions).

execute_actionblock1(_r,_blocktype,_v,_ans,_actions) :-
	_v == [],
	_ans = [_|_],
	!,
	execute_actions(_r,_blocktype,_actions).

/* ein Element in Liste - nur dieser Fall */
execute_actionblock1(_r,_blocktype, _v,[_a1],_actions) :-
	_v = _a1,
	!,
	execute_actions(_r,_blocktype,_actions).

/* sonst - Element aus Liste nehmen, Actions bearbeiten und ueber Backtracking in naechsten Fall */
execute_actionblock1(_r,_blocktype,_v,[_a1|_answers],_actions) :-
	_v = _a1,
	execute_actions(_r,_blocktype,_actions),
	fail.

/* Restlichen Elemente bearbeiten */
execute_actionblock1(_r,_blocktype,_v,[_a1|_answers],_actions) :-
	execute_actionblock1(_r, _blocktype,_v,_answers,_actions) .

/* Bei leerer Antwort ist nichts zu tun */
execute_actionblock1(_r,_blocktype,_,[],_) :- !.


/******************************************************************/
/* execute_actions/3						                         */
/* Fuehrt die aktionen der rule r aus.                            */
/******************************************************************/
execute_actions(_,_blocktype,[]).

/** actions can be a list of lists, ticket #244 **/
execute_actions(_r,_blocktype,[_a|_rest]) :-
        is_list(_a),
/* WriteTrace(veryhigh,ECAactionManager,['Execute ',idterm(_a)]), */
        execute_actions(_r,_blocktype,_a),
        execute_actions(_r,_blocktype,_rest).

/* Fuehrt eine Ask-Operation aus, die Ergebnisse werden an */
/* eine Variable gebunden, die in den naechsten Aktionen verwendet */
/* werden kann. */
execute_actions(_r,_blocktype,['Ask'(_v,_q)|_actions]):-
	evalECAquery('Ask'(_v,_q),_answers),
	!,
	/* _answers \== [], */ /* Warum kann Antwortmenge nicht leer sein? CQ/21.1.99 */
        'WriteTrace'(high , 'ECAactionManager' , [idterm(_r),' --> ',_blocktype,' Ask ', idterm(_q)]),
	execute_actionblock(_r,_blocktype,_v,_answers,_actions).

execute_actions(_r,_blocktype,[noop|_actions]):-
	!,
	execute_actions(_r,_blocktype,_actions).

execute_actions(_r,_blocktype,[reject|_]):-
	((prove_literal('A'(_r,rejectMsg,_msgID)),
	  id2name(_msgID,_msg)
	 );
	 _msg = '"Reject action encountered."'
	),
        increment('error_number@F2P'),
	report_error('ECA_REJECT','ECAactionManager',[objectName(_r),uq(_msg)]),
        'WriteTrace'(high , 'ECAactionManager' , [idterm(_r),' --> ',_blocktype,' ', reject]),
	!,
	fail.

/* Tell/Untell/Call action */
execute_actions(_r,_blocktype,[_a|_actions]):-
	_a=..[_f|_],
	_f \== 'Ask' ,
	exec_action(_r,_blocktype,_a),
	!,
	execute_actions(_r,_blocktype,_actions).

/* Fehler */
execute_actions(_rid,_blocktype,[_a|_]):-
	id2name(_rid,_r),
    report_error( 'ECA15', 'ECAactionManager' , [_r,formula(_a)]),
	!,
        increment('error_number@ECA').




/******************************************************************/
/* exec_action/3	                                                 */
/******************************************************************/

exec_action(_r,_blocktype,_a) :-
  preWriteTrace(high , 'ECAactionManager' , _a, [idterm(_r),' --> ',_blocktype,' ', idterm(_a)]),
  do_exec_action(_a),
  postWriteTrace(high , 'ECAactionManager' , _a, [idterm(_r),' --> ',_blocktype,' ', idterm(_a)]),
  !.


/** CALL actions are traced after the execution; the rest before **/
preWriteTrace(_prio,_module,'CALL'(_),_message) :-
  !.  
preWriteTrace(_prio,_module,_,_message) :-
  'WriteTrace'(_prio,_module,_message).


postWriteTrace(_prio,_module,'CALL'(_),_message) :-
  'WriteTrace'(_prio,_module,_message),
  !.  
postWriteTrace(_prio,_module,_,_message) :-
  !.


/** for transaction support; tickets #250/#278 **/
do_exec_action(tBegin) :-
  branchExecutionQueue,
  !.

do_exec_action(tEnd) :-
  checkEndOfSubQueue(_),
  !.

do_exec_action('Raise'(_query)) :-
  process_ecarules('Ask',[_query],_defactions,_defrules),
  addlist_ECA_ExecutionQueue(_defactions),
  addlist_ECA_ExecutionQueue(_defrules),
  !.

do_exec_action('Tell'('In'(_on,_c))):-
	name2id(_on,_o),   /** _on=_o if _o is already an id **/
	prove_literal('In_s'(_o,_c)),
	!.

do_exec_action('Tell'('In'(_oe,_ce))):-
   transformObjectReferences([_oe,_ce],[_o,_c],_flag),
   !,
   store_Object_depOnFlag_nofire(_flag,'SMLfragment'( what(_o),
		      in_omega([]),
		      in([class(_c)]),
		      isa([]),
		      with([])),_errno),
   makeId(_o,_o1),
   makeId(_c,_c1),
   expandTellToSuperclasses(_o1,_c1,_listOfTells),
   process_ecarules('ECAaction',_listOfTells,_deferredactions,_deferredrules),
   !,
   _errno = 0 ,
   addlist_ECA_ExecutionQueue(_deferredactions),  /** see also ticket #93 **/
   addlist_ECA_ExecutionQueue(_deferredrules).


do_exec_action('Tell'('Isa'(_cn,_dn))):-
   makeId(_cn,_c),
   makeId(_dn,_d),
   prove_literal('Isa_e'(_c,_d)),
   !.

do_exec_action('Tell'('Isa'(_ce,_de))):-
   transformObjectReferences([_ce,_de],[_c,_d],_flag),
   !,
   store_Object_depOnFlag_nofire(_flag,'SMLfragment'(what(_c),
			in_omega([]),
	  	    	in([]),
			isa([class(_d)]),
			with([])),_errno),
   makeId(_c,_c1),
   makeId(_d,_d1),
   process_ecarules('ECAaction',['Tell'('Isa'(_c1,_d1))],_deferredactions,_deferredrules),
   !,
   _errno = 0,
   addlist_ECA_ExecutionQueue(_deferredactions),  /** see also ticket #93 **/
   addlist_ECA_ExecutionQueue(_deferredrules).


do_exec_action('Tell'('Adot'(_cc,_x,_y))) :-
   eval(_x,replaceSelectExpression,_xid),
   eval(_y,replaceSelectExpression,_yid),
   prove_literal('Adot'(_cc,_xid,_yid)),
   !.

do_exec_action('Tell'('Adot'(_cc,_xe,_ye))) :-
   transformObjectReferences([_xe,_ye],[_x,_y],_flag),
   make_label(_x,_l,_label),
   !,
   store_Object_depOnFlag_nofire(_flag,'SMLfragment'(what(_x), in_omega([]), in([]), isa([]),
            with([attrdecl([ id(_cc) ], [property(_label, _y)])])),_errno),
	!,
   _errno = 0,
   process_ecarules('ECAaction',['Tell'('Adot'(_cc,_x,_y))],_deferredactions,_deferredrules), 
   addlist_ECA_ExecutionQueue(_deferredactions),  /** see also ticket #93 **/
   addlist_ECA_ExecutionQueue(_deferredrules).


/** ticket #247: partially support A predicate **/
do_exec_action('Tell'('A'(_xe,_l,_ye))) :-
   makeId(_xe,_x),
   makeId(_ye,_y),
   find_attributeclasses(_x,[_l],[_cc]),    /** there is a unique concerned class for x.l **/
   !,
   do_exec_action('Tell'('Adot'(_cc,_x,_y))).
 



do_exec_action('Tell'('Adot_label'(_cc,_x,_y,_l))) :-
   eval(_x,replaceSelectExpression,_xid),
   eval(_y,replaceSelectExpression,_yid),
   prove_literal('Adot'(_cc,_xid,_yid,_l)),
   !.

do_exec_action('Tell'('Adot_label'(_cc,_xe,_ye,_label))) :-
   transformObjectReferences([_xe,_ye],[_x,_y],_flag),
   get_name_for_tell(_label,_labelout),     /** _label can be set in the ECA rule itself, 17-Jul-2000/MJf **/
   !,
   store_Object_depOnFlag(_flag,'SMLfragment'(what(_x), in_omega([]), in([]), isa([]),
            with([attrdecl([ id(_cc) ], [property(_labelout, _y)])])),_deferredactions,_deferredrules,_errno),
   !,
   _errno = 0,
   addlist_ECA_ExecutionQueue(_deferredactions),  /** see also ticket #93 **/
   addlist_ECA_ExecutionQueue(_deferredrules).



/** ticket #247: partially support A_label predicate **/
do_exec_action('Tell'('A_label'(_xe,_m,_ye,_n))) :-
   makeId(_xe,_x),
   makeId(_ye,_y),
   find_attributeclasses(_x,[_m],[_cc]),    /** there is a unique concerned class for x.l **/
   !,
   do_exec_action('Tell'('Adot_label'(_cc,_x,_y,_n))).




/** no object names allowed in lit! ticket #245 **/
do_exec_action('Untell'(_lit)) :-
       ground(_lit),
       not_prove_literal(_lit),
       'WriteTrace'(high , 'ECAactionManager', ['Already untrue: ', idterm('Untell'(_lit))]),
       !.

do_exec_action('Untell'('In'(_xn,id_6))) :-    /** id_6=Attribute **/
       name2id(_xn,_x),
       untell_in(_x,[class(id_6)]),
       process_ecarules('ECAaction',['Untell'('In'(_x,id_6))],_deferredactions,_deferredrules),!,
       addlist_ECA_ExecutionQueue(_deferredactions),  /** see also ticket #93 **/
       addlist_ECA_ExecutionQueue(_deferredrules).

do_exec_action('Untell'('In'(_xn,id_7))) :-    /** id_7=Individual **/
       name2id(_xn,_x),
       untell_in(_x,[class(id_7)]),
       process_ecarules('ECAaction',['Untell'('In'(_x,id_7))],_deferredactions,_deferredrules),!,
       addlist_ECA_ExecutionQueue(_deferredactions),  /** see also ticket #93 **/
       addlist_ECA_ExecutionQueue(_deferredrules).

do_exec_action('Untell'('In'(_on,_c))):-
	name2id(_on,_o),
	prove_literal('In_s'(_o,_c)),
	untell_in(_o,[class(_c)]),
        expandUntellToSuperclasses(_o,_c,_listOfUntells),
	process_ecarules('ECAaction',_listOfUntells,_deferredactions,_deferredrules),!,
        addlist_ECA_ExecutionQueue(_deferredactions),  /** see also ticket #93 **/
        addlist_ECA_ExecutionQueue(_deferredrules).

do_exec_action('Untell'('Isa'(_cn,_dn))):-
	name2id(_cn,_c),
        name2id(_dn,_d),
	prove_literal('Isa_e'(_c,_d)),
	untell_isa(_c,[class(_d)]),
	process_ecarules('ECAaction',['Untell'('Isa'(_c,_d))],_deferredactions,_deferredrules),!,
        addlist_ECA_ExecutionQueue(_deferredactions),  /** see also ticket #93 **/
        addlist_ECA_ExecutionQueue(_deferredrules).

do_exec_action('Untell'('Adot'(_cc,_x,_y))) :-
	name2id(_x,_xid),
	name2id(_y,_yid),
        findall(id(_attrid),prove_C_Aidot(_cc,_xid,_label,_attrid),_labels1),    /** ticket #211 **/
        addAttributeIdIfEmpty(_cc,_xid,_yid,_labels1,_labels),                   /** ticket #254 **/
	untell_eca_adot('Adot'(_cc,_xid,_yid),_labels,_deferredactions,_deferredrules),
	!,
        addlist_ECA_ExecutionQueue(_deferredactions),  /** see also ticket #93 **/
        addlist_ECA_ExecutionQueue(_deferredrules).

do_exec_action('Untell'('Adot_label'(_cc,_x,_y,_label))) :-
	name2id(_x,_xid),
	name2id(_y,_yid),
	untell_eca_adot('Adot'(_cc,_xid,_yid),[_label],_deferredactions,_deferredrules),
	!,
        addlist_ECA_ExecutionQueue(_deferredactions),  /** see also ticket #93 **/
        addlist_ECA_ExecutionQueue(_deferredrules).


/** limited support for Retell: only allowed for attribution literals (x l y) **/
/** and (x m/l y) where x gets a new attribute value y.                       **/
do_exec_action('Retell'('Adot'(_cc,_x,_y))) :-
	name2id(_x,_xid),
	prove_literal('Adot'(_cc,_xid,_yidold)),  /** fetch the old attribute value **/
	retell_IfNecessary('Adot'(_cc,_x,_y),_xid,_yidold),
	!.

do_exec_action('Retell'('Adot_label'(_cc,_x,_y,_label))) :-
        retellAdotLabel('Adot_label'(_cc,_x,_y,_label)),
        !.

do_exec_action('Retell'(_lit)) :-
	'WriteListOnTrace'(low,['Retell failed for literal ',idterm(_lit)]),
	!,fail.


do_exec_action('CALL'(_a)):-
	'WriteTrace'(veryhigh,'ECAactionManager',['Calling Prolog predicate: ',idterm(_a)]),
	pcall(_a).



/** special treatment for Retell Adot_label **/
/** The object store still returns some old deleted values that might be the **/
/** same as the new value but is in fact already untold. So we need to find  **/
/** the current value for y that is not the same as the new value            **/
retellAdotLabel('Adot_label'(_cc,_x,_y,_label)) :-
	name2id(_x,_xid),
	prove_literal('Adot_label'(_cc,_xid,_yidold,_label)), 
        _yidold \== _y,  /** there is an attribute with a different value **/
	do_exec_action('Untell'('Adot_label'(_cc,_xid,_yidold,_label))),
        do_exec_action('Tell'('Adot_label'(_cc,_x,_y,_label))),
	!.
retellAdotLabel('Adot_label'(_cc,_x,_y,_label)).



/** if new value equals old values, then nothing has to be done **/

retell_IfNecessary('Adot'(_cc,_x,_y),_xid,_yidold) :-
  _y == _yidold,
  !.

/** otherwise: do a combination of Untell/Tell **/
retell_IfNecessary('Adot'(_cc,_x,_y),_xid,_yidold) :-
  do_exec_action('Untell'('Adot'(_cc,_xid,_yidold))),  /** ticket #245 **/
  do_exec_action('Tell'('Adot'(_cc,_x,_y))).




/** prove_C_Aidot does not find attributes that are merely under category 'attribute' **/
/** We thus have to add these attributes to support Untell (x attribute y)            **/
addAttributeIdIfEmpty(id_6,_xid,_yid,[],_attrids) :-    /** id_6=Attribute **/
        findall(id(_attrid),isAttributeProposition(_attrid,_xid,_n,_yid),_attrids),
        !.
addAttributeIdIfEmpty(_,_,_,_attrids,_attrids).


isAttributeProposition(_attrid,_xid,_n,_yid) :-
        retrieve_proposition('P'(_attrid,_xid,_n,_yid)),
        attribute('P'(_attrid,_xid,_n,_yid)).


expandUntellToSuperclasses(_o,_c,_listOfUntells) :-
  save_setof('Untell'('In'(_o,_sc)),implicitInstance(_o,_c,_sc),_listOfUntells).

expandTellToSuperclasses(_o,_c,_listOfTells) :-
  save_setof('Tell'('In'(_o,_sc)),implicitInstance(_o,_c,_sc),_listOfTells).


implicitInstance(_o,_c,_sc) :-
  prove_literal('Isa'(_c,_sc)),    /** _sc is a superclass, possibly _c itself **/
  (_c=_sc;
  \+ prove_literal('In_s'(_o,_sc))   /** _o not explicit instance of _sc **/
  ).  





untell_eca_adot('Adot'(_cc,_x,_y),_labels,_deferredactions,_deferredrules) :-
	name2id(_x,_xid),  /** transform to id's **/
        name2id(_y,_yid),
        do_untell_eca_adot('Adot'(_cc,_xid,_yid),_labels,_deferredactions,_deferredrules).


/** do_untell_eca_adot does the work for untell_eca_adot. The first parameter is the id of the object **/
/** 'Attribute' (attribute category 'attribute'). It must be included in the attrdecl to remove an    **/
/** attribute completely.                                                                             **/

do_untell_eca_adot(_,[],[],[]).

/** issue #44 **/
/** Hier auch process_ecarules fuer In(id,id_6) generieren? **/

/** case 1: The attribute category label is just 'attribute' **/
do_untell_eca_adot('Adot'(id_6,_xid,_yid),[attribute],_deferredactions,_deferredrules) :-
	!,
	untell_with(_xid,[ attrdecl([ id(id_6) ], [property(attribute, _yid)])]),  /** id_6=Attribute **/
	process_ecarules('ECAaction',['Untell'('Adot'(id_6,_xid,_yid))],_deferredactions,_deferredrules).

/** case 2: The attribute category label is not just 'attribute' **/
do_untell_eca_adot('Adot'(_cc,_xid,_yid),[_label|_labels],_defacts,_defrules) :-
	!,
	untell_with(_xid,[ attrdecl([ id(id_6),id(_cc)], [property(_label, _yid)])]),  /** id_6=Attribute **/
	do_untell_eca_adot('Adot'(_cc,_xid,_yid),_labels,_defacts1,_defrules1),
	process_ecarules('ECAaction',['Untell'('Adot'(_cc,_xid,_yid))],_deferredactions,_deferredrules), 
	append(_deferredactions,_defacts1,_defacts),
	append(_deferredrules,_defrules1,_defrules).


/* Nuetzliches Praedikat fuer ECA-Regeln */
/* Erzeugt ein neues Individual mit teilweise generiertem */
/* Objektnamen, arg1 ist der Prefix fuer den Objektnamen. */



'CreateIndividual'(_oid,_id) :-
	id2name(_oid,_label),
	'CreateIndividual'(_label,_id,1),
	!.

'CreateIndividual'(_l,_id,_nr) :-
	pc_atomconcat([_l,'_',_nr],_label),
	\+ retrieve_proposition('P'(_id,_id,_label,_id)),
	'STORE'('P'(_id,_id,_label,_id)),
	!.

'CreateIndividual'(_l,_id,_nr) :-
	_nr1 is _nr + 1,
	'CreateIndividual'(_l,_id,_nr1).





'CreateNew'(_class,_id) :-
	makeName(_class,_label),
	makeId(_class,_classid),
	'CreateNew'(_classid,_label,_id,1),
	!.

'CreateNew'(_classid,_l,_id,_nr) :-
	pc_atomconcat([_l,'_',_nr],_label),
	\+ retrieve_proposition('P'(_id,_id,_label,_id)),
	'STORE'('P'(_id,_id,_label,_id)),
	'STORE'('P'(_idinst,_id,'*instanceof',_classid)),
	!.

'CreateNew'(_classid,_l,_id,_nr) :-
	_nr1 is _nr + 1,
	'CreateNew'(_l,_id,_nr1).





/** newLabel is like CreateIndividual but it does not create the object; it simply returns a new label **/
newLabel(_prefix_id,_newlabel) :-
        makeName(_prefix_id,_prefix),
        do_newLabel(_prefix,_newlabel,1).

do_newLabel(_prefix,_label,_nr) :-
	pc_atomconcat([_prefix,'_',_nr],_label),
        \+ name2id(_label,_id),   /** this label is not yet used as object name **/
	!.

do_newLabel(_prefix,_label,_nr) :-
	_nr1 is _nr + 1,
	do_newLabel(_prefix,_label,_nr1).




/* Nuetzliches Praedikat fuer ECA-Regeln */
/* Erzeugt ein neues Attribut, unabhaengig davon ob Adot(cc,x,y) */
/* schon gilt, und gibt den ID des Attributs zurueck. */



'CreateAttribute'(_cc,_x,_y,_id) :-
	eval(_x,replaceSelectExpression,_xid),
	eval(_y,replaceSelectExpression,_yid),
	eval(_cc,replaceSelectExpression,_ccid),
	id2name(_ccid,_ml),
	make_label(_xid,_ml,_label),
	'STORE'('P'(_id,_xid,_label,_yid)),
	'STORE'('P'(_,_id,'*instanceof',_ccid)),
	!.

/* Nuetzliches Praedikat fuer ECA-Regeln */
/* Erzeugt ein neues Attribut mit angegebenem Label */



'CreateAttributeWithLabel'(_cc,_x,_y,_label) :-
	eval(_x,replaceSelectExpression,_xid),
	eval(_y,replaceSelectExpression,_yid),
	eval(_cc,replaceSelectExpression,_ccid),
	\+(prove_literal('Adot_label'(_ccid,_xid,_yid,_label))),
	'STORE'('P'(_id,_xid,_label,_yid)),
	'STORE'('P'(_,_id,'*instanceof',_ccid)),
	!.


init_eca_execute :-
	reset_counter_if_undefined('error_number@ECA').

/** simple variant: just pick a system-generated unique label **/
make_label(_o,_l,_label):-
        uniqueAtom(_label).

/** complex: choosing a readable label (disabled due to efficiency reasons)
make_label(_o,_l,_label):-
	id2name(_o,_on),
	pc_atomconcat([_on,'_',_l],_label),
	\+ prove_literal(P(_,_o,_label,_)),
	!.

make_label(_o,_l,_label):-
	make_label(_o,_l,_label,1).

make_label(_o,_l,_label,_nr) :-
	id2name(_o,_on),
	pc_atomconcat([_on,'_',_l,_nr],_label),
	\+ prove_literal(P(_,_o,_label,_)),
	!.

make_label(_o,_l,_label,_nr) :-
	_nr1 is _nr+1,
	make_label(_o,_l,_label,_nr1).
**/




/* IDs und gueltige Objektnamen */
get_name_for_tell(_n,_name) :-
	name2id(_n,_id),
	!,
	outFragmentObjectName(_id,_name).

/* Der Rest */
get_name_for_tell(_n,_n) :-
	atom(_n).



/** 10-Feb-2006/M.Jeusfeld: ECA rules can produce TELL operations with arguments being **/
/** all identifiers or with arguments where some of them are object names. We need to  **/
/** distinguish their treatment. In case 1 (allIds), we call store_Object_internal, in **/
/** the other case, we call store_Object.                                              **/

store_Object_depOnFlag(allIds,_fragment,_deferredactions,_deferredrules,_errno) :-
   store_Object_internal(_fragment,_deferredactions,_deferredrules,_errno),
   !.

store_Object_depOnFlag(_,_fragment,_deferredactions,_deferredrules,_errno) :-
   store_Object(_fragment,_deferredactions,_deferredrules,_errno).


store_Object_depOnFlag_nofire(allIds,_fragment,_errno) :-
   store_Object_internal_nofire(_fragment,_errno),
   !.

store_Object_depOnFlag_nofire(_,_fragment,_errno) :-
   store_Object_nofire(_fragment,_errno).



transformObjectReferences(_inputlist,_inputlist,allIds) :-
  is_allIds(_inputlist),
  !.

transformObjectReferences(_inputlist,_outputlist,allNames) :-
  do_transformObjectReferences(_inputlist,_outputlist).

do_transformObjectReferences([],[]) :- !.


do_transformObjectReferences([_x|_restinput],[_xout|_restoutput]) :-
  get_name_for_tell(_x,_xout),
  !,
  do_transformObjectReferences(_restinput,_restoutput).

do_transformObjectReferences([_x|_restinput],_) :-
   write('*** ECA_actionManager.pro: This call of do_transformObjectReferences should never occur!'),nl,
   write('*** Could not transform object reference '),write(_x),nl,
   !.





