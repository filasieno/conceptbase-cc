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
* File:        %M%
* Version:     %I%
* Creation:    13-Jul-1988, Hans Nissen (UPA)
* Last Change: %G%, Lutz Bauer  (RWTH)
* Release:     %R%
* -----------------------------------------------------------------------------
*
* This module is a part of the Object Processor. It has got two important
* works to do:
*
*  (1) It valuates select Expressions
*      of the form select(_firstArgument,_selectSymbol,_objectIdentifier) which
*      appears in SML-Fragments.
*  (2) It changes identifiers of the form "#xyz" appearing in SML-Fragments
*      into it corresponding select-expression.
*
*  The first point prepares the SML-Fragment to change it into propvals.
*
*  The second point gets a SML-Fragment wich is just build out of
*  propvals. So the computed values of select-expressions appears in it.
*  But values of the form "#xyz" are not allowed as identifiers. So they
*  must be changed into select-expressions.
*
*  Exported predicates:
*  --------------------
*
*      + changeIdentifierExp/3
*           replace select-expressions in SMLfragments if the second
*           argument is "replaceSelectExpression" and insert select-
*           expressions if the second argument is "insertSelectExpression".
*      + eval/3
*           ... does the work for a single object identifier
*      + eval/4
*           ... does the work for a single object identifier in a specified Module context  8-Nov-1995 LWEB
*
*
*  select Expressions of the form xy->zx ('InstanceOf') and
*  xy=>zx ('isA') can now be considered.                    21-May-1990 UB
*
* 2-Sep-1992/kvt predicate CMLsymboltable/2 does no longer exist
*
* 7-Dec-1992/kvt: Format of smlfragment changed (cf. CBNEWS[148])
*
* 6-Jul-1994/CQ:
	In ReplaceSelectExpression(select(x,op,y),..): x and y (not only x) are
		considered recursively by ReplaceSelectExpression
	In InsertSelectExpression: Destination of link is also replaced by a select expression
*
* 9-Dez-1996/LWEB:
	Es wurde ein neues eval/4 eingefuehrt, dass ein eval/3 in einem vorgegebenen Modulkontext
	durchfuehrt. Diese eval/4 wird momentan lediglich in parseAss.dcg aufgerufen.

	ReplaceSelectExpression/2 wurde fuer die Ersetzung von Expressions unter Modulen erweitert.
	Zusaetzlich wurde eine Select-Expression select(_name,'@',_module) eingefuehrt.
	Soll ein Name durch ReplaceSelectExpression/2 ersetzt werden, der nicht im aktuellen
	Modulkontext eindeutig ist, so wird eine Fehlermeldung SEXPR3 ausgegeben.
*/

/*:- setdebug.      26-Nov-1988/MJf*/

:- module('SelectExpressions',[
'changeIdentifierExp'/3
,'eval'/3
,'eval'/4
,'do_processIfDeriveExpr'/2
,'evalClassList'/3
,'delayedReplaceSelectExpression'/2
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').


:- use_module('Literals.swi.pl').
:- use_module('validProposition.swi.pl').
:- use_module('PropositionProcessor.swi.pl').

:- use_module('GlobalParameters.swi.pl').
:- use_module('ErrorMessages.swi.pl').


:- use_module('GeneralUtilities.swi.pl').

:- use_module('BIM2C.swi.pl').



:- use_module('ModelConfiguration.swi.pl').

:- use_module('PrologCompatibility.swi.pl').




:- use_module('MetaUtilities.swi.pl').
:- use_module('cbserver.swi.pl').


/** for memorizing the old module context temporarily during evaluating a **/
/** select expression.                                                    **/
:- dynamic 't_msp_SelExp'/1 .


:- style_check(-singleton).





/* ********************** changeIdentifierExp ************************* */
/* 					             HWN 13-Jul-1988   */
/* changeIdentifierExp (_inputFragment,_option,_outputFragment)         */
/*   _inputFragment: ground: term   	  			       */
/*   _option: ground: one of "replaceSelectExpression"                  */
/*                           "insertSelectExpression"                   */
/*   _outputFragment: free: term           			       */
/*								       */
/*  This predicate gets as input an SML-Fragment with select            */
/*  expressions and returns an SML_Fragment without any select          */
/*  expressions, if the option is "replaceSelectExpression".This means  */
/*  that any select expression will be replaced by its corresponding    */
/*  value.                                                              */
/*  If the option is "insertSelectExpression" then any expression of    */
/*  the form "#xyz" used as identifier is replaced by its corresponding */
/*  select-expression.                                                  */
/*                                                    01-Aug-1988/MJf   */
/* ******************************************************************** */

changeIdentifierExp('SMLfragment'(what(_objectIdentInput),
                               in_omega(_inOmegaInput),
                               in(_inInput),
                               isa(_isaInput),
                               with(_attrListInput)),
		     _option,
	             'SMLfragment'(what(_objectIdentOutput),
                               in_omega(_inOmegaOutput),
                               in(_inOutput),
                               isa(_isaOutput),
                               with(_attrListOutput))
                         ) :-
   evalWhatClass(_objectIdentInput,_option,_objectIdentOutput),!,
   evalClassList(_inOmegaInput,_option,_inOmegaOutput),!,
   evalClassList(_inInput,_option,_inOutput),!,
   evalClassList(_isaInput,_option,_isaOutput),!,
   evalAttrList(_attrListInput,_option,_attrListOutput),!.






/*********************** evalWhatObject *******************************/
/*						    HWN 20-Jul-1988  */
/*  evalWhatObject (_objectIdentinput,_option,_objectIdentOutput)     */
/*   _objectIdentInput: ground:                                       */
/*   _option: ground                                                  */
/*   _objectIdentOutput: free                                         */
/*								     */
/*  This predicate is in the same way defined as evalClassList, but   */
/*  you transform only one objectname.                                */
/*								     */
/**********************************************************************/

evalWhatClass(_objectIdentInput,_option,_objectIdentOutput) :-
	eval(_objectIdentInput,_option,_objectIdentOutput).




/*********************** evalClassList ********************************/
/*						     HWN 14-Jul-1988 */
/* evalClassList (_inputList,_option,_outputList)         	     */
/*  _inputList: ground: list	        			     */
/*  _option: ground						     */
/*  _outputList: free: list		          		     */
/*								     */
/*  The option is "replaceSelectExpression" :                         */
/*  This predicate gets as input a list of classdefinitions of the    */
/*  form "class(_identifier,_time,_timeRelList)". This identifier     */
/*  is allowed to be a select-expression. The return of the predicate */
/*  is the list of classdefinitions where the select-expression is    */
/*  replaced by its corresponding value.                              */
/*							   	     */
/*  The option is "insertSelectExpression" :                          */
/*  The predicate gets the same input as before, but the identifier   */
/*  could be an atom of the form "#xyz". This atom must be replaced   */
/*  by a select-expression.                                           */
/*								     */
/**********************************************************************/

evalClassList([],_,[]).

evalClassList([class(_identifier)|_tail],_option,
               [class(_evalIdentifier)|_evaltail]) :-
	eval(_identifier,_option, _evalIdentifier),!,
	evalClassList(_tail,_option,_evaltail).



/************************* evalAttrList *************************/
/*		         		      HWN 19-Jul-1988  */
/*  evalAttrList (_attrListInput,_option,_attrListOutput)       */
/*   _attrListInput: ground: list			       */
/*   _option: ground					       */
/*   _attrListOutput: free: list		        	       */
/*							       */
/*  This predicate controls the substitution or insertion of the*/
/*  select-expressions appearing in attribute declarations. The */
/*  substitution or insertion is done by the predicate          */
/*  "evalPropertyList/2"                                        */
/*							       */
/****************************************************************/

evalAttrList([],_,[]).

evalAttrList([attrdecl(_catList,_propList)|_tail],
	      _option,
	      [attrdecl(_catList,_evalPropList)|_evaltail]) :-
	evalPropertyList(_propList,_option,_evalPropList),!,
	evalAttrList(_tail,_option,_evaltail).


/************************ evalPropertyList *********************/
/*                                             HWN 19-Jul-1988 */
/*  evalPropertyList (_inputList,_otion,_outputList)           */
/*   _inputList: ground: list				      */
/*   _option: ground					      */
/*   _outputList: free: list				      */
/*							      */
/*   In this predicate the substitution or the insertion of the*/
/*   select-expression appearing in a attribute list is done by*/
/*   calling the predicate eval/3                              */
/*   							      */
/***************************************************************/

evalPropertyList([],_,[]).

evalPropertyList([property(_l,[_smlfrag])|_tail],
                 _option,
		 [property(_l,[_newsmlfrag])|_evaltail]) :-
	changeIdentifierExp(_smlfrag,_option,_newsmlfrag),
	evalPropertyList(_tail,_option,_evaltail).


evalPropertyList([property(_l,_identifier)|_tail],
                 _option,
		 [property(_l,_evalIdentifier)|_evaltail]) :-
	eval(_identifier,_option,_evalIdentifier),!,
	evalPropertyList(_tail,_option,_evaltail).


/*************************** eval *******************************/
/*		          	               HWN 14-Jul-1988 */
/*  eval ( _identifier,_option, _evalIdentifier)		       */
/*   _identifier: ground: atom: term			       */
/*   _option: ground					       */
/*   _evalIdentifier: free: atom: term			       */
/*							       */
/*  eval calls InsertSelectExpression if the option is          */
/*  insertSelectExpression and ReplaceSelectExpression if the   */
/*  option is replaceSelectExpression.                          */
/*							       */
/****************************************************************/

/** eval/3 **/

eval(_tt,insertSelectExpression,_tt) :-
	atom(_tt),
	pc_atomconcat('tt(',_,_tt),
	!.

eval(_inputIdentifier, insertSelectExpression, _outputIdentifier) :-
  'InsertSelectExpression'(_inputIdentifier,_outputIdentifier,0),   /** 3rd parameter is for nesting control **/
  !.

/** shortcut **/
eval(_id,replaceSelectExpression,_id) :-
  is_id(_id),
  !.
eval(_id,replaceSelectExpression_try,_id) :-
  is_id(_id),
  !.

eval(_inputIdentifier,replaceSelectExpression,_outputIdentifier) :-
  processIfDeriveExpr(_inputIdentifier,_inputIdentifier1),
  'ReplaceSelectExpression'(strict,_inputIdentifier1,_outputIdentifier),
  !.

/** ticket #350: allow delayed evaluation of certain select expressions **/
eval(_inputIdentifier,replaceSelectExpression_try,_outputIdentifier) :-
  processIfDeriveExpr(_inputIdentifier,_inputIdentifier1),
  'ReplaceSelectExpression'(try,_inputIdentifier1,_outputIdentifier),
  !.


/** eval/4 **/

eval(_mod,_inputIdentifier, _m, _outputIdentifier) :-
  getModule(_omod),
  pc_update(t_msp_SelExp(_omod)),
  setModule(_mod),
  eval(_inputIdentifier, _m, _outputIdentifier),
  setModule(_omod).

eval(_,_,_,_) :-
  t_msp_SelExp(_omod),
  setModule(_omod),
  !,
  fail.



/** processIfDeriveExpr converts a derive expression (term) into an **/
/** atom that represents the derive expression where all object     **/
/** names are replaced by object identifiers.                       **/
/** Related to ticket 194.                                          **/
  
processIfDeriveExpr(derive(_x,_substlist),_objname) :-
  do_processIfDeriveExpr(derive(_x,_substlist),_idexpr),
  pc_atom_to_term(_objname,_idexpr).
  

processIfDeriveExpr(_x,_x).



do_processIfDeriveExpr(derive(_x,_substlist),derive(_xid,_substlistid)) :-
  strict_name2id(_x,_xid),
  do_processIfDeriveExpr(_substlist,_substlistid).

do_processIfDeriveExpr([],[]) :- !.

do_processIfDeriveExpr([substitute(_v,_param)|_rest],
                       [substitute(_vnew,_param)|_restids]) :-
  makeDeriveExprId(_v,_vnew),
  do_processIfDeriveExpr(_rest,_restids).

do_processIfDeriveExpr([specialize(_param,_v)|_rest],
                       [specialize(_param,_vid)|_restids]) :-
  makeDeriveExprId(_v,_vid),
  do_processIfDeriveExpr(_rest,_restids).


makeDeriveExprId(_v,_vid) :-
  atom(_v),
  strict_name2id(_v,_vid),
  !.

/** ~this and ~this_par are used in intermediate code generated from **/
/** view definitions. We need to pass these variables unchanged.     **/
makeDeriveExprId(_v,_v) :-
  atom(_v),
  pc_atomprefix('~',1,_v),
  !.

/** ticket #335: check when an object name cannot be found **/
makeDeriveExprId(_x,_) :-
  atom(_x),
  report_error('PFNFE','SelectExpressions', [_x]),
  !,
  fail.


makeDeriveExprId(derive(_x,_substlist),derive(_xid,_substlistid)) :-
  do_processIfDeriveExpr(derive(_x,_substlist),derive(_xid,_substlistid)).


strict_name2id(_id,_id) :-
  is_id(_id),
  !.

strict_name2id(_x,_id) :-
  atom(_x),
  name2id(_x,_id),
  !.



  



/* ****************** ReplaceSelectExpression ****************** */
/*					     HWN 20-Jul-1988    */
/*  ReplaceSelectExpression(_mode,                               */
/*                          _inputIdentifier,_outputIdentifier)	*/
/*   _mode: ground ('strict' or 'try')                           */
/*   _inputIdentifier: ground					*/
/*   _outputIdentifier: free					*/
/*								*/
/*  This predicate replaces select-expressions by its            */
/*  corresponding values. If the inputIdentifier is a simple     */
/*  identifier replace is the identity.				*/
/*  5-Jun-1989/MJf: The replacement of object names by their     */
/*  "aliases" (see SML_Aliases.pro) is considered, too.          */
/*						8-Jun-1989/MJf  */
/* The right part of the select expression is considered, too    */
/*                                                   6-Jul-1994  */
/* ************************************************************* */

'ReplaceSelectExpression'(_input,_output) :-
  'ReplaceSelectExpression'(strict,_input,_output).  /** default: strict mode **/
  

/**** case 1: arg1 is already an object id */

'ReplaceSelectExpression'(_,_id, _id) :-
  is_id(_id),  
  !.

/**** case 2: a simple object name */

'ReplaceSelectExpression'(_,_name, _id) :-
	atom(_name),
	name2allid(_name,[_id]),
	!.

'ReplaceSelectExpression'(_,_name, _) :-
	atom(_name),
	name2allid(_name,_a),
	_a \= [],
	!,					/* 19-Apr-95 LWEB Ambiguous selection */
	id2uniquename(_a,_ul),
	report_error('SEXPR3','SelectExpressions', [_name, _ul]),
	!,
	fail.


/****  case 1b:  module qualifier @ ****/
'ReplaceSelectExpression'(_,select(_oname,'@',_modname),_id) :- 		/* Replace name */
	name2id(_modname,_modid),
	retrieve_proposition_noimport(_modid,'P'(_id,_,_oname,_)),
	!.



'ReplaceSelectExpression'(_,select(_oname,'@',_modname),_) :-
	getModule(_m),
	id2name(_m,_mn),
	report_error('SEXPR4','SelectExpressions',
                               [_mn,_oname,_modname]),
	!,
	fail.




/**** case 2: select expressions                         */
/**** by now, we only replace the '!' and '^' operators, */
/**** '|' and '.' are not considered here!               */

'ReplaceSelectExpression'(_,select(_selectExp,'!',_label),_evalIdentifier) :-
	atom(_label),
	'ReplaceSelectExpression'(_selectExp,_evalInSelect),
 	id2name(_evalInSelect,_),
       findall(_id,
                prove_literal('P'( _id, _evalInSelect, _label, _)),
                [_evalIdentifier]),
	!.


'ReplaceSelectExpression'(_,select(_selectExp,'^',_label),_evalIdentifier) :-
	atom(_label),
	'ReplaceSelectExpression'(_selectExp,_evalInSelect),
	id2name(_evalInSelect,_),
        findall(_y,
                prove_literal('P'( _, _evalInSelect, _label, _y)),
                [_evalIdentifier]),
	!.

/** now indicating instanceof- and isa-Relations (->,=>) is possible  21-May-1990 **/
/**									      UB **/


'ReplaceSelectExpression'(_,select(_selectExp,'->',_selectExp2),_evalIdentifier) :-
	'ReplaceSelectExpression'(_selectExp,_evalInSelect),
	'ReplaceSelectExpression'(_selectExp2,_class),
	id2name(_evalInSelect,_),
	id2name(_class,_),
       findall(_id,
                prove_literal('P'(_id,_evalInSelect,'*instanceof',_class)),
                [_evalIdentifier]),
	!.


'ReplaceSelectExpression'(_,select(_selectExp,'=>',_selectExp2),_evalIdentifier) :-
	'ReplaceSelectExpression'(_selectExp,_evalInSelect),
	'ReplaceSelectExpression'(_selectExp2,_class),
	id2name(_evalInSelect,_),
	id2name(_class,_),
        findall(_id,
                prove_literal('P'(_id,_evalInSelect,'*isa',_class)),
                [_evalIdentifier]),
	!.


/** if the return list has got zero or more than one element : ERROR **/
/** ticket #350: ObjectTransformer calles this with mode=try; hence no error ir generated here **/
/** The select expressions has to be replaced then in FragmentToPropositions **/
'ReplaceSelectExpression'(strict,select(_selectExp,_selectSymbol,_label),_) :-
	report_error('SEXPR1','SelectExpressions',
                               [_selectExp,_selectSymbol,_label]),
	!,
	fail.

/**** Falls Objekt noch nicht existiert, kann ID noch nicht eingesetzt werden. ****/
'ReplaceSelectExpression'(_,_name, _name) :-
	!.





/** ticket #350: if a frame has an attribute a, then it may refer to a in another attribute of itself, e.g.
    OBJECT with
      attribute
        link: OBJECT;   
        iLink: OBJECT!link
    end
  Attribute like iLink cannot be replaced before Object!link is told.
**/

delayedReplaceSelectExpression(select(_x,_op,_arg),_id) :-
  eval(select(_x,_op,_arg),replaceSelectExpression,_id),
  !.

delayedReplaceSelectExpression(_x,_x) :-
  !.


/* *********** I n s e r t S e l e c t E x p r e s s i o n ************ */
/*					               HWN 20-Jul-1988 */
/* InsertSelectExpression(_inputIdentifier,_outputIdentifier,_depth)    */
/*   _inputIdentifier: ground: 				               */
/*   _outputIdentifier: free				               */
/*   _depth: ground: integer				               */
/*							               */
/* This predicate replaces atoms of the form "#xyz" by                  */
/* its corresponding select-expression. Other forms of                  */
/* correct identifiers won't be changed.          	               */
/* The parameter _depth counts the calls of insert. If                  */
/* this number is equal to a constant it is defined as                  */
/* an error because the outputIdentifier may not be                     */
/* calculated in an finite amount of time. This constant                */
/* is stored at the predicate get_cb_feature(maximalDepth,x).           */
/* 5-Jan-1989/MJf: For individuals which have a string label this       */
/* string is returned as the _outputIdentifier (see also treatment of   */
/* assertions in FragmentToPropositions)                                */
/* 5-Jun-1989/MJf: Reversly to 'ReplaceSelectExpression' object iden-   */
/* tifiers of individual are replaced with their name (label component) */
/* and their alias.                                                     */
/*					               5-Jun-1989/MJf  */
/* ******************************************************************** */

/**** Overflow condition: more than maximalDepth recursions of */
/**** 'InsertSelectExpression' */

'InsertSelectExpression'(_id, _id, _d) :-
  get_cb_feature(maximalDepth,_maximalDepth),
  _d > _maximalDepth,
  report_error('SEXPR2','SelectExpressions',[_id]),
  !.

/**** make different cases for different kinds of objects */

'InsertSelectExpression'(_id, _s, _d) :-
  retrieve_proposition('P'(_id,_x,_l,_y)),
  ( case_instanceof('P'(_id,_x,_l,_y), _s, _d);
    case_isa('P'(_id,_x,_l,_y), _s, _d);
    case_attribute('P'(_id,_x,_l,_y), _s, _d);
    case_individual('P'(_id,_x,_l,_y), _s)
  ),
  !.

/*
InsertSelectExpression(_id,_id2,_):-
    please(wq,off),
    pc_atom_to_term(_id2,_id).
*/

'InsertSelectExpression'(_id,_id,_).		/*4-Apr-95 LWEB*/

/**** catch-all for constants like strings, integers, reals etc.          */
/**** since they aren't to be found by the above retrieve, 9-Jun-1989/MJf */

case_individual('P'(_id,_id,_l,_id), _l) :-
  	assertion_string(_l),!.

/* _id corresponds to a name which is non-ambigous in the current Module context */
case_individual('P'(_id,_id,_l,_id),_name) :- 	/* 5-Apr-95 LWEB   Test if Proposition is ambiguous in this context */
	id2name(_id,_name),
	name2allid(_name,[_]),!.

/* _id corresponds to a name which IS ambigous in the current Module context */
/* ambigous names are replaced with a module qualifier  name@module */
case_individual('P'(_id,_id,_l,_id), select(_l,'@',_n) ) :-	/* 5-Apr-95 LWEB */
	get_module_name(_id,_n),
	_n \== 'System',
	!.



/**** Instantiation and specialization links are now replaced by the */
/**** appropiate select expression.                   21-May-1990 UB */
/**** Destination of link is also replaced by a select expression    6-Jul-1994 CQ*/


/** this alias is not useful with CBGraph; ticket #357
case_instanceof(P(_id,_x,'*instanceof',_y), InstanceOf, _d) :-
		_x == id_0,     
		_x == _y,
		!.
**/
case_instanceof('P'(_id,_x,'*instanceof',_y), select('Proposition','->','Proposition'),_d) :-
		_x == id_0,  /** id_0 = Proposition **/   
		_x == _y,
		!.

case_instanceof('P'(_id,_x,'*instanceof',_y), select(_s,'->',_s2),_d) :-
		_d1 is _d + 1,
		'InsertSelectExpression'(_x,_s,_d1),
		'InsertSelectExpression'(_y,_s2,_d1),
		!.

/** id_0 = Proposition **/
/** this alias is not useful with CBGraph; ticket #357
case_instanceof(P(_id,_x,'*isa',_y), IsA, _d) :-
		_x == id_0,     
		_x == _y,
		!.
**/
case_instanceof('P'(_id,_x,'*isa',_y), select('Proposition','=>','Proposition'),_d) :-
		_x == id_0,  /** id_0 = Proposition **/   
		_x == _y,
		!.

case_isa('P'(_id,_x,'*isa',_y), select(_s,'=>',_s2), _d) :-
		_d1 is _d + 1,
		'InsertSelectExpression'(_x,_s,_d1),
		'InsertSelectExpression'(_y,_s2,_d1),
		!.


/**** Attributes are replaced by an appropriate select expression     */
/**** (if possible); more than maxDepth recursions ==> no replacement */
/**** OR: The id isn't system-generated ==> we take the external name */
/**** of this id.                                                     */


case_attribute('P'(_id,_x,attribute,_y), select('Proposition','!',attribute), _d) :-
		_x == id_0,     /** id_0 = Proposition **/
		!.


case_attribute('P'(_id,_x,_l,_y), select(_s,'!',_l), _d) :-
	  attribute('P'(_id,_x,_l,_y)),
 	 _d1 is _d + 1,
	  'InsertSelectExpression'(_x,_s,_d1),
 	 !.


