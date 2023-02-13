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
*
* File:         TellAndAsk.pro
* Version:      11.2
*
*
* Date released : 97/01/06  (YY/MM/DD)
*
* SCCS-Source-Pool : /home/CBase/CB_NewStruct/ProductPOOL/serverSources/Prolog_Files/SCCS/s.TellAndAsk.pro
* Date retrieved : 97/05/27 (YY/MM/DD)
* ----------------------------------------------------------
*
* This Prolog module is the "programming" interface of the ConceptBase
* kernel. It provides the TELL,UNTELL and ASK procedure to the KB.
*
*
*  12-Mar-1990 HWN  : a string is now a list of characters and a bimstring
*		      is a list of ASCII numbers.
*
*  12-Mar_1990 HWN  : the predicate error_report is now called with
*		      a bimstring and not a list of characters
*
*  18-Dec-2001 MJf  : use pc_erase_all to get rid of temporary facts generated during
*                     secure_process_query (module AnswerTransformUtilities.pro)
*
*
*
* Aenderung Metaformeln (10.1.96)
* mit modus  wird in MetaBDMEvaluation geprueft,
* ob man sich in einer Tell oder Ask
* Operation befindet.
* Beim Ask brauchen die Prozedurtrigger
* fuer Metaformeln nicht geprueft zu werden.
*
* Jul-97 retell wird eingebaut. Man kann was untell und
* gleichzeitig auch was tell, erst danach fuehrt der
* Integritaetscheck durch.
*
*
* Exported predicates:
* --------------------
*
*   + TELL/2
*	Arg1 is a bimstring of CML text to be stored in the KB,
*	arg2 returns a success/failure message.
*   + UNTELL/2
*	Arg1 is a bimstring of CML text to be 'untold' in the KB,
*	arg2 returns a success/failure message.
*   + ASK/6
*   + HYPO_ASK/7
*	extended ASK for hypothetical queries
*
*   + retell/3
*/

:- module('TellAndAsk',[
'ASK'/6
,'EliminateClassInList'/2
,'HYPO_ASK'/7
,'ObjNameStringToList'/2
,'RETELL'/3
,'TELL'/2
,'UNTELL'/2
,'retellflag'/1
,'CurrentUpdateMode'/1
,'SetUpdateMode'/1
,'RemoveUpdateMode'/1
,'switchUpdateMode'/2
,'setCheckUpdateMode'/1
,'removeCheckUpdateMode'/0
,'currentCheckUpdateMode'/1
,'UNTELL_FRAGMENTS'/2
,'transformToCall'/2
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').


:- use_module('GeneralUtilities.swi.pl').
:- use_module('LanguageInterface.swi.pl').
:- use_module('ObjectProcessor.swi.pl').



:- use_module('ErrorMessages.swi.pl').

:- use_module('ExternalCodeLoader.swi.pl').









:- use_module('Literals.swi.pl').

:- use_module('PrologCompatibility.swi.pl').





:- use_module('ECAruleManager.swi.pl').

:- use_module('AnswerTransformUtilities.swi.pl').
:- use_module('tokens_dcg.swi.pl').

:- use_module('parseAss_dcg.swi.pl').

:- dynamic 'modus'/1 .
:- dynamic 'checkupdate_modus'/1 .
:- dynamic 'retellflag'/1 .
  /*Wird in ObjectProcessor gesetzt */

/*
Aenderung Metaformeln
mit modus  wird in MetaBDMEvaluation geprueft,
ob man sich in einer Tell oder Ask
Operation befindet.
Beim Ask brauchen die Prozedurtrigger
fuer Metaformeln nicht geprueft zu werden.
*/
:- dynamic 'modus'/1 .



:- style_check(-singleton).




/* =================== */
/* Exported predicates */
/* =================== */


/* *************************** T E L L ************************** */
/*                                                                */
/* TELL(_cmltext,_completion)                                     */
/*   _cmltext: ground : pointer (C-String)                        */
/*   _completion: free                                            */
/*                                                                */
/* The string _cmltext is parsed, compiled and stored in the KB   */
/* if no errors occured. The parameter _cmltext can contain       */
/* one or more CML frames. Example:                               */
/* If an error occured _completion is set to 'error', otherwise   */
/* to 'noerror'. Note: 'noerror' is changed to 'ok' before sent   */
/* via IPC.                                                       */
/*                                                                */
/* The _cmltext has to be deallocated by the caller.              */
/* ************************************************************** */

'TELL'(_cmltext,_compl) :-
  checkArgs(_cmltext,_compl),
  build_fragments_from_cstring(_cmltext,_fraglist),
  !,
  tell_objproc(_fraglist,_compl),

  pc_time(process_ECA_ExecutionQueue(_ntrig),_t1),   /** see also ticket #93 **/
/**  profile(process_ECA_ExecutionQueue(_ntrig)),  _t1=xxx,  **/

  (_ntrig=0;
  'WriteListOnTrace'(low,['   ... ',_t1, ' sec used to process ',_ntrig,' deferred ECA rule triggers'])
  ),

  'RemoveUpdateMode'('UPDATE'),
  !.

'TELL'(_cmltext,error) :-
  pc_pointer(_cmltext),
  save_stringtoatom(_cmltext,_cmltextatom),
  report_error('SYNERR','TellAndAsk',[_cmltextatom]),
  'RemoveUpdateMode'('UPDATE').


checkArgs(_cmltext,_compl) :-
  'SetUpdateMode'('UPDATE'),
  pc_pointer(_cmltext), 
  var(_compl),
  !.  /** avoid backtracking **/


/* ************************ U N T E L L ************************* */
/*                                                                */
/* UNTELL(_cmltext,_completion)                                   */
/*   _cmltext: ground : pointer (C-String)                        */
/*   _completion: free                                            */
/*                                                                */
/* The string _cmltext is parsed, and an untell_objproc operation */
/* is performed. The parameter _cmltext can contain one or more   */
/* Telos Frames.                                                  */
/* If an error occured _completion is set to 'error', otherwise   */
/* to 'noerror'. Note: 'noerror' is changed to 'ok' before sent via IPC. */
/*                                                                */
/* The _cmltext has to be deallocated by the caller.              */
/* ************************************************************** */

'UNTELL'(_cmltext,_compl) :-
  checkArgs(_cmltext,_compl),
  build_fragments_from_cstring(_cmltext,_fraglist),
  !,
  untell_objproc(_fraglist,_compl),
  pc_time(process_ECA_ExecutionQueue(_ntrig),_t1),  /** see also ticket #93 **/
  (_ntrig=0;
  'WriteListOnTrace'(low,['   ... ',_t1, ' sec used to process ',_ntrig,' deferred ECA rule triggers'])
  ),
  'RemoveUpdateMode'('UPDATE'),
  !.

'UNTELL'(_cmltext,error) :-
  pc_pointer(_cmltext),
  save_stringtoatom(_cmltext,_cmltextatom),
  report_error('SYNERR','TellAndAsk',[_cmltextatom]),
  retract(modus('UPDATE')).



'UNTELL_FRAGMENTS'(_fraglist,_compl) :-
  'CurrentUpdateMode'(_OLD),
  switchUpdateMode('UPDATE',_OLD),
  untell_objproc(_fraglist,_compl),
  switchUpdateMode(_OLD,'UPDATE'),
  !.

'UNTELL_FRAGMENTS'(_fraglist,_error) :-
  report_error('SYNERR','TellAndAsk',[currentfragment]),
  'RemoveUpdateMode'('UPDATE').



/*************************RETELL*************************************/
/* RETELL(_untelltxt,_telltxt,_compl)                               */
/* The strings untelltxt and telltxt are parsed and an retell_objproc*/
/* is performed. If an error occurs during parsing, an SYNERR is    */
/* generated.                                                       */
/*************************RETELL*************************************/

'RETELL'(_untell,_tell,_compl) :-
        'SetUpdateMode'('UPDATE'),
	pc_stringtoatom(_cmltext_untell,_untell),
	build_fragments_from_cstring(_cmltext_untell,_fraglist_untell),
	pc_stringtoatom(_cmltext_tell,_tell),
	build_fragments_from_cstring(_cmltext_tell,_fraglist_tell),
	!,
	retell_objproc(_fraglist_untell,_fraglist_tell,_compl),
        pc_time(process_ECA_ExecutionQueue(_ntrig),_t1),  /** see also ticket #93 **/
	(_ntrig=0;
	'WriteListOnTrace'(low,['   ... ',_t1, ' sec used to process ',_ntrig,' deferred ECA rule triggers'])
	),
        'RemoveUpdateMode'('UPDATE').



/*bei Syntaxerrorfall*/
'RETELL'(_cmltextatom_untell,_cmltextatom_tell,error) :-
	report_error('SYNERR','TellAndAsk',[_cmltextatom_untell]),
	report_error('SYNERR','TellAndAsk',[_cmltextatom_tell]),
        'RemoveUpdateMode'('UPDATE').








/* ************************* A S K ******************************** */
/*                                                                  */
/*	ASK ( _queryformat, _query, _ansrep, _rbtime, _c, _rt )  */
/*		_queryformat : ground				*/
/*		_query : ground : pointer (C-String)			   */
/*		_ansrep : ground				   */
/*		_rbtime : ground 				   */
/*		_c : free 					   */
/*		_rt : free					   */
/*								   */
/*	performs an ASK operation.                       */
/*	_c signals success of evaluation, _rt contains answer.     */
/*								   */
/* **************************************************************** */

'ASK'( 'FRAMES', _frames, _ansrep, _rbtime, _c, _rt ) :-
        'SetUpdateMode'('QUERY'),
	setCheckUpdateMode('NO'),  /** assume that this query call makes no persistent updates **/
	pc_pointer(_frames),
	'AskFrames'( _frames, _rbtime, _ansrep, _c, _rt ),
        process_ECA_ExecutionQueue(_ntrig),  /** see also ticket #93 **/
        'RemoveUpdateMode'('QUERY').

'ASK'( 'OBJNAMES', _objnames, _ansrep, _rbtime, _c, _rt ) :-
        'SetUpdateMode'('QUERY'),
	setCheckUpdateMode('NO'),   /** assume that this query call makes no persistent updates **/
	pc_pointer(_objnames),
	'AskObjNames'( _objnames, _rbtime, _ansrep, _c, _rt ),
        pc_time(process_ECA_ExecutionQueue(_ntrig),_t1),  /** see also ticket #93 **/
	(_ntrig=0;
	'WriteListOnTrace'(low,['   ... ',_t1, ' sec used to process ',_ntrig,' deferred ECA rule triggers'])
	),
        'RemoveUpdateMode'('QUERY').


/* *********************** H Y P O _ A S K ************************ */
/*                                                                  */
/*	HYPO_ASK ( _objects, _queryformat, _query, _ansrep, _rbtime, _c, _rt )  */
/*		_objects : ground : pointer (C-String)		   */
/*		_queryformat : ground				*/
/*		_query : ground : pointer (C-String)			   */
/*		_ansrep : ground				   */
/*		_rbtime : ground 				   */
/*		_c : free 					   */
/*		_rt : free					   */
/*								   */
/*	HYPO_ASK/7 performs hypothetical ASK operation.               */
/*           CML-Objects in _objects are interpreted as */
/*	hypotheses and stored temporarily in the KB during the     */
/*	evaluation process.                                        */
/*	_c signals success of evaluation, _rt contains answer.     */
/*	_objects and _query have to be deallocated by the caller.		   */
/* **************************************************************** */

'HYPO_ASK'( _objects, 'FRAMES', _frames, _ansrep, _rbtime, _c, _rt ) :-
        'SetUpdateMode'('UPDATE'),
	setCheckUpdateMode('NO'),   /** assume by default that this query call makes no persistent updates **/
	pc_pointer(_objects), pc_pointer(_frames),
	'HypoAskFrames'( _objects, _frames, _rbtime, _ansrep, _c, _rt ),
        process_ECA_ExecutionQueue(_ntrig),  /** see also ticket #93 **/
        'RemoveUpdateMode'('UPDATE').

'HYPO_ASK'( _objects, 'OBJNAMES', _objnames, _ansrep, _rbtime, _c, _rt ) :-
        'SetUpdateMode'('UPDATE'),
	setCheckUpdateMode('NO'),   /** assume by default that this query call makes no persistent updates **/
	pc_pointer(_objects), pc_pointer(_objnames),
	'HypoAskObjNames'( _objects, _objnames, _rbtime, _ansrep, _c, _rt ),
        process_ECA_ExecutionQueue(_ntrig),  /** see also ticket #93 **/
        'RemoveUpdateMode'('UPDATE').


/* ================== */
/* Private predicates */
/* ================== */



/* ***************************** A s k ***************************** */
/*								    */
/*	Ask ( _query, _RBtime, _ansrep, _c, _rt )                   */
/*		_query : ground                                     */
/*		_RBtime : ground                                    */
/*		_ansrep : ground                                    */
/*		_c : free                                           */
/*		_rt : free                                          */
/*								    */
/*	Query _query is sent to the Object/QueryProcessor if it     */
/*	is an instance of QueryClass or a derive-expression         */
/*	(= implicit instance of QueryClass derived by an instance   */
/*	GenericQueryClass) or a SMLfragment. If _query contains     */
/*	the BIMstring representation (=SML source text) of a Query- */
/*	Class it is transformed to a SMLfragment and then sent to   */
/*	the Object/QueryProcessor. The parameters _RBtime and       */
/*	_ansrep contain information about the rollback time of      */
/*	the KB and the answer representation format which are       */
/*	required for the evaluation.                                */
/*	_c signals 'ok' in case of a successful evaluation, 'error' */
/*	otherwise. _rt contains the answers to _query .             */
/*                                                                   */
/* 27-Jun-1991/MJf: Answer _a = no_definition from ask_objproc means */
/* that _query was not defined ---> return 'error' as completion.    */
/* See also CBNEWS[125].                                             */
/*		 						    */
/* ***************************************************************** */


'AskFrames'(_frames,_rbtime,_ansrep, _c, _rt) :-
	pc_pointer(_frames),
	build_fragments_from_cstring(_frames,_fragmentlist),
	!,
	'FragmentListToObjnameList'(_fragmentlist,_objnamelist),
	ask_objproc(ask(_fragmentlist,_objnamelist,_ansrep),_rbtime,_rt),
        produceCompletionAndReturn(_rt,_c),
	!.

'AskFrames'(_frames,_rbtime,_ansrep,error,_rt) :-
	save_stringtoatom(_frames,_framesAtom),
	report_error('SYNERR','TellAndAsk',[_framesAtom]).

'AskObjNames'(_objnames,_rbtime,_ansrep,_c,_rt) :-
	pc_pointer(_objnames),
	transformToCall(_objnames,_sml_objnamelist),  /* parse objnames */
	'EliminateClassInList'(_sml_objnamelist,_objnamelist),
	ask_objproc(ask(_objnamelist,_ansrep),_rbtime,_rt),
        produceCompletionAndReturn(_rt,_c),
	!.


produceCompletionAndReturn(_answer,error) :-
  (stringBufferCompare(_out,_answer,'no_definition');
   stringBufferCompare(_out,_answer,'queryprocessing_failed')),
  _out == 0,
  !.


produceCompletionAndReturn(_answer,error) :-
  stratificationErrorRaised,
  checkToEmptyCacheOnStratificationError,   /** do not use this cache in the next transaction **/
  !.

produceCompletionAndReturn(_answer,ok).

'EliminateClassInList'( [], [] ) :-
	!.

'EliminateClassInList'( [class(_a)|_b], [_a|_d]) :-
	'EliminateClassInList'(_b,_d).





/** ObjNameStringToList is used in OB.builtin and possibly other places; we use the classical C-parser here **/

'ObjNameStringToList'(_objnames,_call) :-
  transformToCall(_objnames,c_parser,[],_call).




/** for ASK/HYPOASK we use transforToCall instead ObjNameStringToList  **/
/** It guesses whether to parse a call with the C-Parser or with the   **/
/** more flexible Prolog-Parser.                                       **/

transformToCall(_objnames,_call) :-
  classifyCall(_objnames,_calltype,_charlist),  /** either classical (C-parser) or shortcut (Prolog parser **/
  transformToCall(_objnames,_calltype,_charlist,_call).



/** The classical C-based parser does not accept function shortcuts nor arithmetic **/
/** arithmetic expressions. It is however less stringent on testing existence of   **/
/** arguments of query calls. That is unfortunately required by some user-defined  **/
/** builtin query classes.                                                         **/

transformToCall(_objnames,c_parser,_,_objnamelist) :-
	te_classlist_parser(_objnamestruct,_objnames),
	getClassListParseErrNo(_errno,_objnamestruct),
	_errno == 0,
	!,
	getClassListFromClassListParseOutput(_c_classlist,_objnamestruct),
	'ClassListCToProlog'(_c_classlist,_objnamelist),
	'Destroy_ClassList'(_c_classlist),
	!. 

/** if c_parser fails (errno > 0), we still can try the Prolog parser **/
transformToCall(_objnames,c_parser,_charlist,_objnamelist) :-
        transformToCall(_objnames,prolog_parser,_charlist,_objnamelist).

/** Ticket #234:                                                                **/
/** The Prolog-based parser also accepts function shortcuts and arithmetic      **/
/** expressions.                                                                **/

transformToCall(_objnames,prolog_parser,_charlist,[_call]) :-
        buildTokens(_tokens,_charlist,[]),
        buildQuerycall(_call,_tokens,[]),
        !.


/** We classify a query call on existence of square brackets and   **/
/** substitution symbols (':','/'). If both are present, we        **/
/** tag the call as a classical call to be parsed by the C-parser. **/

classifyCall(_objnames,_calltype,_charlist) :-
   pc_pointer(_objnames),
   pc_stringtoatom(_objnames,_atom),
   pc_atomtolist(_atom,_charlist),
   doClassifyCall(_charlist,_calltype),
   !.

/** exceptions that should be parsed by prolog_parser **/
doClassifyCall(['l','i','s','t','M','o','d','u','l','e'|_],prolog_parser) :- !.
doClassifyCall(['b','u','l','k'|_],prolog_parser) :- !.

/** regular query calls parsed by c_parser **/
doClassifyCall(_charlist,c_parser) :-
  hasSquareBracket(_charlist,_restcharlist),
  hasSubstitutions(_restcharlist),
  !.
/** all the rest by prolog_parser **/
doClassifyCall(_charlist,prolog_parser).

hasSquareBracket(['['|_rest],_rest) :-!.

hasSquareBracket([_|_rest],_newrest) :-
  hasSquareBracket(_rest,_newrest).

hasSubstitutions(['/'|_]) :- !.
hasSubstitutions([':'|_]) :- !.
hasSubstitutions([_|_rest]) :-
  hasSubstitutions(_rest).





'FragmentListToObjnameList'([],[]) :-
	!.

'FragmentListToObjnameList'([_frag|_frags],[_obj|_objs]) :-
	_frag = 'SMLfragment'(what(_obj),_,_,_,_),
	'FragmentListToObjnameList'(_frags,_objs),
	!.

'FragmentListToObjnameList'([_frag|_],_) :-
	write('FragmentListToObjnameList: bad format: '),
	write(_frag), nl.


/* ********************* H y p o A s k ***************************** */
/*								    */
/*	Hypo_Ask ( _objects, _queries, _RBtime, _ansrep, _c, _rt )  */
/*		_objects : ground                                   */
/*		_queries : ground                                   */
/*		_RBtime : ground                                    */
/*		_ansrep : ground                                    */
/*		_c : free                                           */
/*		_rt : free                                          */
/*								    */
/*	The CML-Objects _objects are stored temporarily as          */
/*	hypotheses for the query evaluation in the KB by the        */
/*	ObjectProcessor. If these objects do not have fragment      */
/*	format they are transformed to this format. Together with   */
/*	the list of queries _queries (instances of QueryClass or    */
/*	derive-expressions) which shall be evaluated they are sent  */
/*	to the ObjectProcessor. The parameters _RBtime and          */
/*	_ansrep contain information about the rollback time of      */
/*	the KB and the answer representation format which are       */
/*	required for the evaluation.                                */
/*	_c signals 'ok' in case of a successful evaluation, 'error' */
/*	otherwise. _rt contains the answers to _query .             */
/*		 						    */
/* ***************************************************************** */

'HypoAskFrames'(_objects,_queries,_rbtime,_ansrep,_c,_rt) :-
	pc_pointer(_objects), pc_pointer(_queries),
	build_fragments_from_cstring(_objects,_objectlist),
	build_fragments_from_cstring(_queries,_querylist),
	!,
	'FragmentListToObjnameList'(_querylist,_qobjnames),
	append(_objectlist,_querylist,_objlist),
	ask_objproc(ask(_objlist,_qobjnames,_ansrep),_rbtime,_rt),
	produceCompletionAndReturn(_rt,_c),
	!.

'HypoAskFrames'(_objects,_frames,_rbtime,_ansrep,error,_rt) :-
	save_stringtoatom(_frames,_framesAtom),
	report_error('SYNERR','TellAndAsk',[_framesAtom]).


'HypoAskObjNames'(_objects,_queries,_rbtime,_ansrep,_c,_rt) :-
	pc_pointer(_objects), pc_pointer(_queries),
	build_fragments_from_cstring(_objects,_objectlist),
	transformToCall(_queries,_qlist),
	'EliminateClassInList'(_qlist,_querylist),
	!,
	ask_objproc(ask(_objectlist,_querylist,_ansrep),_rbtime,_rt),
    produceCompletionAndReturn(_rt,_c),
  	!.



/* ****************** A s c i i T o C h a r s ******************* */
/*                                                                */
/* AsciiToChars(_alist,_clist)                                    */
/*   _alist: ground,list of ascii numbers                         */
/*   _clist: any: list of atoms (length=1)                        */
/*                                                                */
/* The ascii list is transformed to a list of characters. CR, LF  */
/* and HT are transformed to blanks (' '). See also module        */
/* ScanFormatUtilities.                                           */
/*                                                                */
/* 23-Jan-1991/MJf: CR, LF and HT are no longer transformed to    */
/* blanks. This enhances greatly the readability of assertions    */
/* that span over severeal lines. ScanFormatUtilities has been    */
/* adapted accordingly.                                           */
/*                                                                */
/* ************************************************************** */

'AsciiToChars'([],[]).

'AsciiToChars'([_a|_arest],[_c|_crest]) :-
   pc_ascii(_c,_a),
   'AsciiToChars'(_arest,_crest).


/** UpdateMode is either QUERY or UPDATE. The flag tells the CBserver **/
/** whether it is running an update or a query. Magically, the Update **/
/** Mode can switch from QUERY to UPDATE and back, in case of compli- **/
/** cated builtin queries.                                            **/

'SetUpdateMode'(_mode) :-
  assert(modus(_mode)),
  syncCheckUpdateMode(_mode).  /** syncronize the UpdateMode with CheckUpdateMode **/


/** switchUpdateMode should be used to alter the UpdateMode in the implementation **/
/** of builtin queries. The _oldmode is returned.                                 **/
/** Use as follows in Prolog code for builtin queries that actually update the    **/
/** database:                                                                     **/
/**                                                                               **/
/**   process_<name>(...) :-                                                      **/
/**    'TellAndAsk':switchUpdateMode('UPDATE',_oldmode),                          **/
/**    ...                                                                        **/
/**    'TellAndAsk':switchUpdateMode(_oldmode,_).                                 **/

switchUpdateMode(_newmode,_oldmode) :-
  modus(_oldmode),
  _newmode \== _oldmode,
  'RemoveUpdateMode'(_oldmode),
  'SetUpdateMode'(_newmode),
  !.
switchUpdateMode(_mode,_mode).

'RemoveUpdateMode'(_mode) :-
  retract(modus(_mode)).

'CurrentUpdateMode'(_mode) :-
  modus(_mode).


/** ************************************************************************** **/
/**                                                               18-May-2006  **/
/** Check Update Mode                                                          **/
/**                                                                            **/
/** Normally, ASK transactions are not allowed to alter the database state,    **/
/** more precesely, the database state should be the unchanged after an ASK    **/
/** transaction. During an ASK, some intermedia objects might have to be       **/
/** created, for example numbers as results of functions like COUNT.           **/
/** Such temporary objects are deleted at the end of the ASK transaction.      **/
/** However, we can trigger ECA rules by ASK and typically such ECA rules      **/
/** change the database state in the action part. It would be almost useless   **/
/** of such changes would be lost after the ASK transaction has been executed. **/
/** A second example are some user-define builtin query classes. They might    **/
/** also change the database state. To control this situation, a flag          **/
/**      checkupdate_modus                                                     **/
/** is introduced. The value YES means that a transaction is allowed to change **/
/** the database state. These changes shall persist after the transaction has  **/
/** ended (and be submitted to the checkUpdate test(.                          **/
/**                                                                            **/
/** When an ASK transaction starts processing, then the CheckUpdateMode is set **/
/** to NO (normally, an ASK is not allowed to change the database state per-   **/
/** sistently).                                                                **/
/** In case of ECA rules being invoked, the CheckUpdateMode is set to YES in   **/
/** when the first action block is executed (see ECAactionManager.pro). In the **/
/** case of builin query classes, one has to call                              **/
/**     'TellAndAsk':setCheckUpdateMode(YES)                                   **/
/** explicitely in the body of the clause process_<name> where <name> is the   **/
/** name of the builtin query class.                                           **/
/**                                                                            **/
/** All other transactions are by default allowed to make persistent database  **/
/** updates. This hold in particular for TELL and UNTELL.                      **/
/** See also ticket #102.                                                      **/
/**                                                                            **/
/** ************************************************************************** **/

/** when the UpdateMode is set to UPDATE, then we will make sure that the **/
/** CheckUpdateMode is set to YES. This makes it easier to deal with      **/
/** builtin queries that update the database.                             **/

syncCheckUpdateMode('UPDATE') :-
  setCheckUpdateMode('YES').
syncCheckUpdateMode(_).
  

setCheckUpdateMode(_mode) :-
  checkupdate_modus(_mode),  /** is already in the _mode **/
  !.

setCheckUpdateMode(_mode) :-
  checkupdate_modus(_oldmode),
  _oldmode \= _mode,
  retract(checkupdate_modus(_oldmode)),
  assert(checkupdate_modus(_mode)),
  deleteAskQueryBuffers_success,    /** remove the potentially outdated ask query buffers **/
/**  write(checkupdate_modus(_mode)),nl,  **/
  !.

setCheckUpdateMode(_mode) :-
  assert(checkupdate_modus(_mode)).

removeCheckUpdateMode :-
  checkupdate_modus(_mode),
  retract(checkupdate_modus(_mode)),
  !.
removeCheckUpdateMode.

currentCheckUpdateMode(_mode) :-
  checkupdate_modus(_mode).
currentCheckUpdateMode('YES').  /** by default, we will assume that a transaction may update the database persistently **/




