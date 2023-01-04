/**
The ConceptBase.cc Copyright

Copyright 1987-2022 The ConceptBase Team. All rights reserved.

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
* File:        QueryProcessor.pro
* Version:     7.3
* Creation:    29-Aug-1988, Manfred Jeusfeld (UPA)
* Last Change: 28 Oct 1994, Manfred Jeusfeld (RWTH)
* Release:     7
* -----------------------------------------------------------------------------
*
* This Prolog module is part of the ConceptBase system which is a run-time
* system for the System Modelling Language (SML).
* The QueryProcessor tries to find answers for the ask_objproc questions
* of the ObjectProcessor.
*
*
* Exported predicates:
* --------------------
*
*   + process_query/2
*
* 7-Dec-1992/kvt
: Format of smlfragment changed (cf. CBNEWS[148])
*
* 26-Jan-1993/DG: InstanceOf is changed into In
* (by deleting the time component, see CBNEWS[154])
*
*/

:- module('QueryProcessor',[
'process_query'/2
,'foldBulkQuery'/3
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').


:- use_module('ObjectProcessor.swi.pl').
:- use_module('ExternalConnection.swi.pl').
:- use_module('QAmanager.swi.pl').
:- use_module('SearchSpace.swi.pl').

:- use_module('ExternalCodeLoader.swi.pl').
:- use_module('Literals.swi.pl').

:- use_module('SelectExpressions.swi.pl').


:- use_module('GeneralUtilities.swi.pl').

:- use_module('AnswerTransformator.swi.pl').
:- use_module('ECAruleManager.swi.pl').


:- use_module('PrologCompatibility.swi.pl').


:- use_module('cbserver.swi.pl').
:- use_module('SystemBuiltin.swi.pl').

:- use_module('MSFOLassertionParserUtilities.swi.pl').
:- use_module('MetaUtilities.swi.pl').



:- style_check(-singleton).




/* =================== */
/* Exported predicates */
/* =================== */


/* ********************** p r o c e s s _ q u e r y ************************** */
/*	                                                                      */
/*	process_query ( _q , _answer )                                        */
/*		_q : ground                                                   */
/*		_answer : free                                                */
/*                                                                             */
/*	_answer is answer to query _q where _q is one of the following:       */
/*                                                                             */
/*	a) ask([_builtinquery],_ar) 	where _cmlobject is the name of a     */
/*	                  		stored instance of BuiltinQueryClass  */
/*			           	resp. a derive-expression based on a  */
/*                                       stored generic query class            */
/*	b) ask([_bulkquerycall],_ar)	where _bulkquerycall has the form     */
/*                                       bulkquery([_q|_args]); the arguments  */
/*                                       are folded with _q into a _qlist to   */
/*                                       be processed.                         */
/*	c) ask(_queries,_ar) 		where _queries is a list of stored    */
/*                                       instances of QueryClass, but not of   */
/*                                       BuiltinQueryClass                     */
/*	d) ask(_objects,_queries,_ar) where _objects is alist of SMLfragments */
/*					which are placed in KB tem-           */
/*					porarily for the evaluation,_queries  */
/*					is a list of query identifiers (i.e.  */
/*					object names or derive-expressions    */
/*					concerning query classes in KB or     */
/*					in _objects.                          */
/* *************************************************************************** */

/* a) */
process_query(ask([_builtinquery],_ansrep),_answer) :-
        ( _builtinquery = derive(_f,_slist) ; functor(_builtinquery,_f,_) ),
	name2id(_f,_fID),
	prove_literal('In'(_fID,id_77)),  /** id_77 = BuiltinQueryClass **/
	!,
	/** _builtinquery is not changed with respect to OID/name because a builtin query will be called with its name **/
	/** ECA rules are not triggered by calling builtin queries **/
    	(process_builtin_queryclass(_builtinquery,_ansrep,_answer);
     	appendBuffer(_answer,'queryprocessing_failed') /** orginally: 'no', see also TellAndAsk, 12-Jul-1994/MJf*/
	),
	!.

/* b) */

process_query(ask([bulkquery([plainarg(_qid)|_args])],_ansrep),_answer) :-
/** write('Args: '),write(_args),nl, **/
        extractExistingArgs(_args,_goodargs),  /** filter out undefined objects **/
        foldBulkQuery(_qid,_goodargs,_qlist),
        setFlag(bulkQuery,on),  /** influences query processing and answer generation **/
        process_query(ask([],_qlist,_ansrep),_answer),
        setFlag(bulkQuery,off), 
	!.

/* c) */
process_query(ask(_qlist,_ansrep),_answer) :-
	process_query(ask([],_qlist,_ansrep),_answer),
	!.


/* d1) no temporary objects */
/* ==> in this case, ECA rules might have to be triggered if RBtime=Now*/
process_query(ask([],_qlist,_ansrep),_answer) :-
	get_KBsearchSpace(_m,_RBtime),
	(	(_RBtime = 'Now',
		process_ecarules('Ask',_qlist,_defactions,_defrules)
		);
		true	/** if RBtime \= Now then we don't trigger ECA rules **/
	),
        'error_number@F2P'(0),
	handle_queries(_qlist,_RBtime,_ansrep,_m,_answer),

	(       (_RBtime = 'Now',
		fire_def_actions(_defactions),
		fire_def_ecarules(_defrules)
		);
		true
	),
	!.

/* d2): some termporary objects */
/* in this case we will tell the qfragments only temporarily; */
/* when the query is answered, they shall be removed          */
/* ==> in this case, we will no trigger ECA rules             */
process_query(ask(_qfragments,_qlist,_ansrep),_answer) :-
    _qfragments \== [],
    get_KBsearchSpace(_m,_RBtime),
    set_KBsearchSpace(newOB,'Now'),
    tell_tmp_objproc(_qfragments,_c),
    _c == noerror,
	(	(_RBtime = 'Now',
		process_ecarules('Ask',_qlist,_defactions,_defrules)
		);
		true	/** if RBtime \= Now then we don't trigger ECA rules **/
	),
        'error_number@F2P'(0),
    setCacheModeDefault,    /** answer queries by using cache (if enabled) **/
    (
       (handle_queries(_qlist,_RBtime,_ansrep,_m,_answer),
        remove_tmp_infos,
        checkToEmptyCacheOnSearchSpaceChange,    /** cache to be erased due to change in object base **/
        !
       );
       (remove_tmp_infos,
        checkToEmptyCacheOnSearchSpaceChange,
        fail
       )
    ),

	(       (_RBtime = 'Now',
		fire_def_actions(_defactions),
		fire_def_ecarules(_defrules)
		);
		true
	),

   !.



/* 27-Jun-1991/MJf: If no clause applies then return 'no_definition'.    */
/* See also TellAndAsk and CBNEWS[125]. We assume that all legal queries */
/* are evaluated and yield an answer (possibly 'no').                    */

process_query(_q,_answer):-
    appendBuffer(_answer,'no_definition').




/* ================== */
/* Private predicates */
/* ================== */



/* ********** p r o c e s s _ b u i l t i n _ q u e r y c l a s s *********** */
/*                                                                            */
/*	process_builtin_queryclass ( _q, _ansrep, _answer )                  */
/*			_q : ground					     */
/*			_ansrep : ground				     */
/*			_answer : free 					     */
/*									     */
/*	_q is assumed to be a derive-expressions containing an instance      */
/*	of BuiltinQueryClass. For all(!) parameters there must be            */
/*	substitutions. The ordering of these substitutions must be the       */
/*	same as specified in the code to the BuiltinQueryClass. The code     */
/*	is activated by calling the predicate processBuiltin with the        */
/*       arguments of the derive-expression and a result parameter as 2nd     */
/*       argument.                                                            */
/*	The evaluation result is transformed with respect to the answer      */
/*	format _ansrep and reported back in _answer.                         */
/*                                                                            */
/* ************************************************************************** */





process_builtin_queryclass(_q,_ansrep,_answer) :-
        (
	_q =..[derive,_f,_args];
        (atom(_q),_f=_q,_args=[])   /** this case is for builtin queries without parameters **/
        ),
        makeName(_f,_fname),
        adaptAnswerRep(_q,_ansrep,_ansrep_new),   /** get rid of 'default' as answer format **/
	setFlag(currentAnswerFormat,_ansrep_new),  /**  for JSONIC, ticket #422  **/
        processBuiltin(_fname,_ans,_args),
	transform_builtin_answer(_ans,_ansrep_new,_answer).


/************************************************************/
/** subst_selectexp_by_ids_in_litlist(                     **/
/**    _inLitList,                                         **/
/**    _outLitList)                                        **/
/** lokale Hilfsfunktion, die in einer Liste von Literalen **/
/** _inLitList alle Selectausdruecke durch OIDs ersetzt    **/
/**                                                        **/
/************************************************************/

subst_selectexp_by_ids_in_litlist([],[]).

subst_selectexp_by_ids_in_litlist([_lit|_lits],[_lit_withIDs|_lits_withIDs]):-
	_lit =.. [_fun|_args],
	subst_selectexp_by_ids_in_arglist(_args,_nargs),
	_lit_withIDs =.. [_fun|_nargs],
	subst_selectexp_by_ids_in_litlist(_lits,_lits_withIDs).

subst_selectexp_by_ids_in_arglist([],[]).


subst_selectexp_by_ids_in_arglist([_arg|_args],[_arg|_nargs]) :-
	var(_arg),
	subst_selectexp_by_ids_in_arglist(_args,_nargs).

subst_selectexp_by_ids_in_arglist([_arg|_args],[_narg|_nargs]) :-

	eval(_arg,replaceSelectExpression,_narg),
	subst_selectexp_by_ids_in_arglist(_args,_nargs).


/************************************************************/
/** foldBulkQuery(_qid,_args,_qlist)                       **/
/**    _qid: id of a query class with one argument         **/
/**    _args: list of possible arguments for _qid          **/
/**    _qlist: folded list of query calls                  **/
/** if qid is a query class with a single parameter p  and **/
/** _args is a list like [x1,x2,..], then _qlist is a list **/
/** of query calls                                         **/
/**   derive(_qid,[substitute(x1,p)],                      **/
/**   derive(_qid,[substitute(x2,p)],                      **/
/**   ...                                                  **/
/** The arguments in _args have the form plainarg(_a) from **/
/** parseAss.buildQuerycall                                **/
/**                                                        **/
/************************************************************/

foldBulkQuery(_qid,[],[]) :- !.

foldBulkQuery(_qid,[_x1|_restargs],[derive(_qid,_substArg)|_restcalls]) :-
   plainToSubsts(_qid,[_x1],_substArg),
   foldBulkQuery(_qid,_restargs,_restcalls).



extractExistingArgs([],[]) :- !.

extractExistingArgs([plainarg(_x)|_restargs],[plainarg(_x)|_resteargs]) :-
   is_id(_x),!,
   extractExistingArgs(_restargs,_resteargs).

extractExistingArgs([unknown(_x)|_restargs],_resteargs) :-
   extractExistingArgs(_restargs,_resteargs).

extractExistingArgs([_x|_restargs],_resteargs) :-
   extractExistingArgs(_restargs,_resteargs).


  



