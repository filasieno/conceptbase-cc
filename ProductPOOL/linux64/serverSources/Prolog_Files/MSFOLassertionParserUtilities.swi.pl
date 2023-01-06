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
Matthias Jarke, RWTH Aachen, Informatik 5, Ahornstr. 55, 52056 Aachen, Germany
Christoph Quix, RWTH Aachen, Informatik 5, Ahornstr. 55, 52056 Aachen, Germany


This license is a FreeBSD-style copyright license.
Legal home of the FreeBSD copyright license: http://www.freebsd.org/copyright/freebsd-license.html
**/
/*
*
*
* File:         MSFOLassertionParserUtilities.pro
* Version:      12.1
*
*
* Date released : 98/04/03  (YY/MM/DD)
*
* SCCS-Source-Pool : /home/CBase/CB_NewStruct/ProductPOOL/SCCS/serverSources/Prolog_Files/s.MSFOLassertionParserUtilities.pro
* Date retrieved : 99/02/25 (YY/MM/DD)
**************************************************************************
* -----------------------------------------------------------------------------
*
* This file contains predicates which perform additional action while
* parsing but are unrelated to parsing
*
* Metaformel-Aenderung(10.1996)
* Die Transformation von A nach Adot wird im Modul
* AToAdot durchgefuehrt
*
* buildDottedLiteral gibt es nur noch als dummy
*
* 9-Dez-1996/LWEB: es gibt eine neue Version resolveDeriveExpression/3 und eine neue Version
* buildDottedLiteral/3, die jeweils in einem speziellen Modulkontext arbeiten
*/

:- module('MSFOLassertionParserUtilities',[
'buildDottedOrDeriveLiterals'/2
,'expandQuantifier'/4
,'getAttrClass'/3
,'getAttrTargetClass'/4
,'infixToLiteral'/4
,'metaInfixToLiteral'/4
,'explicatedToLiteral'/4
,'replaceSelectExpB'/4
,'replaceSelectExpBList'/4
,'resolveDeriveExpression'/2
,'resolveDeriveExpression'/3
,'validConclusion'/2
,'splitRule'/3
,'validMSFOLassertion'/1
,'temp_msp'/1
,'plainToSubsts'/3
,'makeAddition'/4
,'makeMultiplication'/4
,'isVariable'/2
,'isKeyword'/1
,'containsNoReservedWord'/1
,'transformIdentifier'/2
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').


:- use_module('GeneralUtilities.swi.pl').




:- use_module('ErrorMessages.swi.pl').
:- use_module('validProposition.swi.pl').
:- use_module('QueryCompiler.swi.pl').

:- use_module('BDMLiteralDeps.swi.pl').
:- use_module('Literals.swi.pl').
:- use_module('VarTabHandling.swi.pl').




:- use_module('PropositionProcessor.swi.pl').
:- use_module('SelectExpressions.swi.pl').
:- use_module('ScanFormatUtilities.swi.pl').






:- use_module('ModelConfiguration.swi.pl').

:- use_module('PrologCompatibility.swi.pl').





:- use_module('MetaUtilities.swi.pl').

:- use_module('QO_preproc.swi.pl').




:- dynamic 't_msp'/1 .


:- style_check(-singleton).




/*************************************************************/
/** infixToLiteral/4                                        **/
/** Builds literals from infix notation                     **/
/*************************************************************/




/**InstanceOf and IsA **/
infixToLiteral(_lit2,_op1, ident(in),_op2) :-
	_lit1 = 'In'(_op1,_op2),
	!,
	resolveDeriveExpression(_lit1,_lit2).

infixToLiteral('Isa'(_op1,_op2),_op1,ident(isA),_op2).
infixToLiteral('Isa'(_op1,_op2),_op1,ident(isa),_op2).

/** Arithmetic operations **/
infixToLiteral(_lit,_expr1,_operator,_expr2) :-
   check_replace_derive_expression(_expr1,_op1),   /** arguments can be functional expressions; see ticket #46 **/
   check_replace_derive_expression(_expr2,_op2),
   comparisonLit(_fun,_operator,_op1,_op2),
   _lit =.. [_fun,_op1,_op2],
   !.


/** Object Identity **/
infixToLiteral('IDENTICAL'(_op1,_op2),_op1,'==',_op2).

/** else assume that it is an attribute value **/
infixToLiteral(_adotLiteral,_who,ident(_attrlabel),_attr) :-
	\+(member(_attrlabel,[ 'forall','exists', 'and', 'or'])),
	\+(member(_attr, ['forall','exists', 'and', 'or'])),
	buildDottedLiteral('A'(_who,_attrlabel,_attr),_adotLiteral).


/** Use UNIFIES instead of EQ if one one of the arguments is not numerical. **/
/** This check currently only works on constants, not on variables.         **/
/** 20100608: UNIFIES should not be used since complex expressions can also
   occur involving non-numericals; EQ is generic and the better choice 
comparisonLit(UNIFIES,'=',_op1,_op2) :-
  (nonNumerical(_op1);
  nonNumerical(_op2)),
  !.
**/

comparisonLit('LT','<',_,_).
comparisonLit('GT','>',_,_).
comparisonLit('LE','=<',_,_).
comparisonLit('LE','<=',_,_).
comparisonLit('GE','>=',_,_).
comparisonLit('EQ','=',_,_).
comparisonLit('NE','<>',_,_).
comparisonLit('NE','\\=',_,_).   /** variant for NE (not equal) **/
comparisonLit('NE','\\==',_,_).  /** variant for NE (not equal) **/

nonNumerical(_arg) :-
  is_id(_arg),
  name2id('Integer',_IntId),
  \+ prove_literal('In'(_arg,_IntId)),
  name2id('Real',_RealId),
  \+ prove_literal('In'(_arg,_RealId)),
  !.


metaInfixToLiteral(_lit2,_op1, ident(in),_op2) :-
	_lit1 = 'In2'(_op1,_op2),
	!,
	resolveDeriveExpression(_lit1,_lit2).

metaInfixToLiteral(_A2Literal,_who,ident(_attrlabel),_attr) :-
	\+(member(_attrlabel,[ 'forall','exists', 'and', 'or'])),
	\+(member(_attr, ['forall','exists', 'and', 'or'])),
        _A2Literal = 'A2'(_who,_attrlabel,_attr).



/** literals enclosed by ':' are using the non-derived variants, i.e.  **/
/** :(x in c): = In_e(x,c)                                             **/
/** :(x isA c): = Isa_e(x,c)                                           **/
/** :(x m y): = A_e(x,m,y).                                            **/
/** See ticket #220.                                                   **/


explicatedToLiteral(_lit2,_op1, ident(in),_op2) :-
	_lit1 = 'In_e'(_op1,_op2),
	!,
	resolveDeriveExpression(_lit1,_lit2).

explicatedToLiteral(_lit2,_op1, ident(isA),_op2) :-
	_lit1 = 'Isa_e'(_op1,_op2),
	!,
	resolveDeriveExpression(_lit1,_lit2).

explicatedToLiteral(_AeLiteral,_who,ident(_attrlabel),_attr) :-
	\+(member(_attrlabel,[ 'forall','exists', 'and', 'or'])),
	\+(member(_attr, ['forall','exists', 'and', 'or'])),
        _AeLiteral = 'A_e'(_who,_attrlabel,_attr).


explicatedToLiteral(_ALeLiteral,_who,[ident(_attrcat),ident(_attrlabel)],_attr) :-
	\+(member(_attrcat,[ 'forall','exists', 'and', 'or'])),
	\+(member(_attrlabel,[ 'forall','exists', 'and', 'or'])),
	\+(member(_attr, ['forall','exists', 'and', 'or'])),
        _ALeLiteral = 'Ae_label'(_who,_attrcat,_attr,_attrlabel).



/*************************************************************/
/** expandQuantifier(_quant,_vtypes,_r,_resultTree)         **/
/**                                                         **/
/** _quant : ground : either 'forall' or 'exists'           **/
/** _vtypes : ground: the vartype list belonging to _quant  **/
/** _r : partial : the subtree following the quantifiers    **/
/** _resultTree : free                                      **/
/**                                                         **/
/** The assertion language allows abbreviations of two kinds**/
/** 1) 'forall x_1,...,x_n / Class'                         **/
/** 2) 'forall x_1/Class_1 ... x_n/Class_n                  **/
/** These expressions may also be mixed                     **/
/** The predicate expandQuantifier/4 expands this shorthand **/
/** to a simple tree structure where each quantifier has    **/
/** exactly one vartype.                                    **/
/*************************************************************/




expandQuantifier(_q,[ vtype([_v],_type) ],_F,_resultF):-
	!,
	_resultF =.. [_q,_v,_type,_F].

expandQuantifier(_q,[ vtype([_v|_vs],_type) ],_F,_resultF):-
	!,
	expandQuantifier(_q,[vtype(_vs,_type)],_F,_F1),
	_resultF =.. [_q,_v,_type,_F1].

expandQuantifier(_q,[_vtype|_vtypes],_F,_resultF) :-
	expandQuantifier(_q,_vtypes,_F,_F1),
	expandQuantifier(_q,[_vtype],_F1,_resultF).

/*************************************************************/
/** validMSFOLassertion(_t)                                 **/
/**                                                         **/
/** _t : ground : syntaxtree of an assertion                **/
/**                                                         **/
/** Checks wether constants and variables have different    **/
/** names.                                                  **/
/*************************************************************/




/** This clause shall be deleted later !! **/

validMSFOLassertion('MSFOLassertion'(_t)) :-
	validMSFOLassertion(_t,[]).


validMSFOLassertion('MSFOLconstraint'(_t)) :-
	'VarTabLookup_vars'(_vars),
	((member('~this',_vars),
	  !,
	  validMSFOLassertion(_t,['~this'])
	 );
	 validMSFOLassertion(_t,[])
	).

validMSFOLassertion('MSFOLrule'(_vars,_condition,_)) :-
	validMSFOLassertion(_condition,_vars).

/*****************************************/
/** validMSFOLassertion/2 does the work **/
/*****************************************/



validMSFOLassertion(forall(_v,_,_f),_validVars) :-
	validMSFOLassertion(_f,[_v|_validVars]).

validMSFOLassertion(exists(_v,_,_f),_validVars) :-
	validMSFOLassertion(_f,[_v|_validVars]).

validMSFOLassertion(not(_f),_validVars) :-
	validMSFOLassertion(_f,_validVars).

validMSFOLassertion(and([]),_) :- !.

validMSFOLassertion(and([_f|_fs]),_validVars) :-
	validMSFOLassertion(_f,_validVars),
	validMSFOLassertion(and(_fs),_validVars).

validMSFOLassertion(or([]),_) :- !.

validMSFOLassertion(or([_f|_fs]),_validVars) :-
	validMSFOLassertion(_f,_validVars),
	validMSFOLassertion(or(_fs),_validVars).

validMSFOLassertion(impl(_f1,_f2),_validVars) :-
	validMSFOLassertion(_f1,_validVars),
	validMSFOLassertion(_f2,_validVars).

validMSFOLassertion(lit(_l),_validVars) :-
	_l =.. [_fun|_args],
	validMSFOLassertion(args(_args),_validVars).

validMSFOLassertion(args([]),_) :- !.

validMSFOLassertion(args([_arg|_args]),_validVars) :-
	member(_arg,_validVars),
	!,
	validMSFOLassertion(args(_args),_validVars).

validMSFOLassertion(args([_arg|_args]),_validVars) :-
	'VarTabVariable'(_arg),
	report_error('ASSSYNERR5','MSFOLassertionParserUtilities',[_arg]),
	!,
	fail.


/** ticket #189: need to check all arguments whether they are tagged as unknown **/
validMSFOLassertion(args([_arg|_args]),_validVars) :-
	atom(_arg),
	pc_atomconcat('%%UNKNOWN--',_,_arg),
        increment('error_number@F2P'),
        !,
        fail.

validMSFOLassertion(args([_|_args]),_validVars) :-
	validMSFOLassertion(args(_args),_validVars).



/** Ticket #206: improve parsing of MSFOLrules **/

/** splitRule(_f,_cond,_concl) simply takes a syntax tree for a rule **/
/** and splits it into condition and conclsuion. The forall-part is  **/
/** not included in _f. The two cases take care for the two forms of **/
/** deductive rules in ConceptBase.                                  **/

/** case 1: "forall vars lit" stands for "forall vars TRUE ==> lit" **/
splitRule(lit(_concl),lit('TRUE'),lit(_concl)).  

/** case 2: just split cond==>concl into cond and concl parts **/
splitRule(impl(_cond,_concl),_cond,_concl).



/*************************************************************/
/** validConclusion(_concllit,_conclvars)                   **/
/** _concllit : Literal                                     **/
/** Variables that should occur in that Literal             **/
/**                                                         **/
/** Checks wether _concllit is a correct conclusion of a    **/
/** rule,i.e                                                **/
/** (i)  _concllit must be one of In/2, Isa/2, A/3  and     **/
/** (ii) the variables occuring in _concllit must be a      **/
/**      subset of _conclvars                               **/
/*************************************************************/


validConclusion(lit('In'(_a1,_a2)),_conclvars) :-
	!,
	checkConclVars([_a1,_a2],_conclvars).

validConclusion(lit('A'(_a1,_l,_a2)),_conclvars) :-
	!,
	checkConclVars([_a1,_a2],_conclvars).

validConclusion(lit('Adot'(_cc,_a1,_a2)),_conclvars) :-
	!,
	checkConclVars([_a1,_a2],_conclvars).

/** 14-Nov-2007/M. Jeusfeld: support AL predicate for conlusions of deductive rules **/
/** Note that A_label is replaced by Adot_label in a by the rule compiler but that  **/
/** this replacement occurs before calling validConclusion.                         **/
/** See also ticket #164.                                                           **/

validConclusion(lit('A_label'(_a1,_m,_a2,_l)),_conclvars) :-
        !,
        checkConclVars([_a1,_a2,_l],_conclvars).

validConclusion(lit('Adot_label'(_cc,_a1,_a2,_l)),_conclvars) :-
        !,
        checkConclVars([_a1,_a2,_l],_conclvars).


validConclusion(lit('Mod'(_lit,_m)),_conclvars) :-
	!,
	validConclusion(lit(_lit),_conclvars).

validConclusion(_t,_) :-
	report_error('ASSSYNERR3','MSFOLassertionParserUtilities',[_t]),
	!,
	fail.

/** eliminiere alle this und systemgenerierte Variablen aus der 2. Liste
 * falls diese in der 1. Liste nicht auftauchen **/



checkConclVars(_as,_bs) :-
	member(_var,_bs),
	\+(member(_var,_as)),
	system_var(_var),
	!,
	delete(_var,_bs,_cs),
	checkConclVars(_as,_cs).

/** eliminiere alle Konstanten aus der Liste der zu testenden Variablen**/
checkConclVars(_as,_bs) :-
	member(_a,_as),
	'VarTabConstant'(_a),
	!,
	delete(_a,_as,_cs),
	checkConclVars(_cs,_bs).

/** 30-Nov-2004/M.Jeusfeld: we only demand that the variables in the **/
/** conclusion literal must be forall-quantified. Previously, we     **/
/** had to make sure that the variables of the conclusion literal    **/
/** are exactly the variables that are forall-quantified in the      **/
/** deductive rule. This leads to weird problem with meta-level      **/
/** rule which are partially evaluated and which need to fulfill     **/
/** this demand AFTER the partial evaluation. The new relaxed format **/
/** for deductive rules is much more flexible and actually what we   **/
/** wanted all the time.                                             **/

checkConclVars(_as,_bs) :-
	isSubsetOf(_as,_bs). /** was originall have_same_elements(_as,_bs) **/

checkConclVars(_as,_bs) :-
	report_error('ASSSYNERR4','MSFOLassertionParserUtilities',[_as,_bs]),
	!,
	fail.

system_var('~this').
system_var(_var) :-
	getFlag('Session_id',_prefix),
	pc_atomconcat('#',_nprefix,_prefix),
	pc_atomconcat('var_',_nprefix,_x),
	pc_atomconcat(_x,_y,_var).

/*************************************************************/
/** buildDottedLiteral(_Arglist, _Literal)                  **/
/** _Arglist : ground : must look like                      **/
/**            [_source,_label,_destination]                **/
/** _type : free : the ready built Adot literal             **/
/** uses if possible (i.e. the concerned class exists) the  **/
/** much faster Adot literal instead of AttValue. But       **/
/** nothing changes for the user.                           **/
/*************************************************************/


/*  Metaformel - Aenderung:
   Die Transformation von A nach Adot wird im Modul
   AToAdot durchgefuehrt
*/
buildDottedLiteral(_lit,_lit).



buildDottedLiteral(_m, _lit, _lit).


/*************************************************************/
/** buildDottedOrDeriveLiterals(_lits, _dotlits)            **/
/**   _lits: list of literals                               **/
/**   _dotlits: same list, but with dotted literals         **/
/**                                                         **/
/** buildDottedOrDeriveLiterals/2 replaces A/3 and Ai/3     **/
/** Literals by dotted Literals and derive expressions by   **/
/** querycalls                                              **/
/** Das ist ein ziemlich unschoener Hack, aber Manfred      **/
/** draengelt und quengelt !!                               **/
/*************************************************************/



buildDottedOrDeriveLiterals([],[]).

buildDottedOrDeriveLiterals([lit(_l)|_ls],[lit(_dl)|_dls]) :-
	functor(_l,_f,_),
	member(_f,['A','Ai']),
	buildDottedLiteral(_l,_dl),
	!,
	buildDottedOrDeriveLiterals(_ls,_dls).

buildDottedOrDeriveLiterals([lit(_l)|_ls],[lit(_dl)|_dls]) :-
	functor(_l,'In',_),
	!,
	resolveDeriveExpression(_l,_dl),
	buildDottedOrDeriveLiterals(_ls,_dls).

buildDottedOrDeriveLiterals([lit(_l)|_ls],[lit(_l)|_dls]) :-
	buildDottedOrDeriveLiterals(_ls,_dls).

/*************************************************************/
/** replace_derive_expression(_inlit,_outlit)               **/
/**                                                         **/
/** Wenn _inlit eine derive_expression ist, wird            **/
/*************************************************************/

/** also support In2, see ticket #76                       **/
/** handled analogous to In wrt. replace_derive_expression **/
resolveDeriveExpression(_m,'In2'(_x,_c),'In2'(_x1,_c1)) :-
  resolveDeriveExpression(_m,'In'(_x,_c),'In'(_x1,_c1)).

resolveDeriveExpression(_m,'In'(_i,_f),_dexp) :-				/* LWEB */
	getModule(_omod),
	pc_update(t_msp(_omod)),
	setModule(_m),
	id2name(_f,_),
	retrieve_proposition('P'(_f,_f,_l,_f)),
	atom(_l),
	pc_atom_to_term(_l,_term),
	_term = derive(_qID,_),
	'GenericQuery'(_qID),		/*Zusaetzliche Ueberpruefung, denn auch GenericExternalQuery hat so eine Darstellung...*/
	!,
	replace_derive_expression(_i,_term,_dexp),

	setModule(_omod).

resolveDeriveExpression(_,'In'(_,_),_) :-					/* LWEB */
	t_msp(_omod),
	setModule(_omod),
	!,
	fail.

/** also support In2, see ticket #76 **/
resolveDeriveExpression('In2'(_x,_c),'In2'(_x1,_c1)) :-
  resolveDeriveExpression('In'(_x,_c),'In'(_x1,_c1)).

resolveDeriveExpression('In'(_i,_f),_dexp) :-
	id2name(_f,_),
	retrieve_proposition('P'(_f,_f,_l,_f)),
	atom(_l),

    sub_atom(_l,_,_,_,'derive('),    /* make sure that _l is really a derive expression */

	pc_atom_to_term(_l,_term),
	_term = derive(_qID,_),
	'GenericQuery'(_qID),			/*Zusaetzliche Ueberpruefung, denn auch GenericExternalQuery hat so eine Darstellung...*/
	!,
	replace_derive_expression(_i,_term,_dexp).

resolveDeriveExpression('In'(_i,derive(_gqID,_sl)),_dexp ) :-
	'GenericQuery'(_gqID),			/*Zusaetzliche Ueberpruefung, denn auch GenericExternalQuery hat so eine Darstellung...*/
	!,
	replace_derive_expression(_i,derive(_gqID,_sl),_dexp).


resolveDeriveExpression('In'(_i,derive(_gq,_sl)),_dexp) :-
	pc_atom_to_term(_af,derive(_gq,_sl)),
	report_error('QLERR2' , 'MSFOLassertionParserUtilities',[_gq,_af]),!,fail.


resolveDeriveExpression(_l,_l).


/** 26-Jan-2005/M.Jeusfeld: auxiliary procedure to solve ticket #46 **/
/** replaces derive-expressions for functional arguments if possible**/
/** The anonymous variable '_' is used because we evaluate functions**/
/** only once (one value per input parameter).                      **/
/** See also replace_derive_expression                              **/

check_replace_derive_expression(derive(_q,_s),_lit) :-
  checkIfFunction(_q),  /** top-level query of the expression must be a Function deliverung one value per input **/
  replace_derive_expression('_',derive(_q,_s),_lit),
  !.
check_replace_derive_expression(_x,_x).

checkIfFunction(_q) :-
  prove_literal('In_e'(_q,id_106)),  /** id_106=Function; instantiation to Function is explicit! **/
  !.

checkIfFunction(_q) :-
   report_error('QLERR12' , 'MSFOLassertionParserUtilities',[objectName(_q)]),
   increment('error_number@F2P'),
   !,fail.


/*************************************************************/
/** getAttrClass(_obj,_label,_class)                        **/
/** 							                               **/
/** Zu _label wird die _class gesucht, wo _label definiert  **/
/** ist. _class ist entweder ein Typ von _obj,              **/
/** oder eine Oberklasse eines Types von _obj               **/
/*************************************************************/

getAttrClass(_obj,_l,_id):-
	getObjClass(_obj,_subclasslist),
	member(_id,_subclasslist),
	\+('Query'(_id)),
	prove_literal('P'(_,_id,_l,_)).

getAttrClass(_obj,_l,_id):-
	getObjClass(_obj,_subclasslist),
	member(_subclass,_subclasslist),
	prove_literal('Isa'(_subclass,_id)),
	\+('Query'(_id)),
	prove_literal('P'(_,_id,_l,_)),
	atom(_id).

getAttrClass(_obj,_attr,_):-
	getObjClass(_obj,_subclasslist),
	report_error( 'FPACNF','MSFOLassertionParserUtilities',[_obj,_attr]),
	!,fail.

/** wird in FragmentToPropositions benutzt, habe ich aber
   hier hingestellt, weil es so aehnlich wie
   getAttClass ist (RS, 1.2.95)
**/
getAttrTargetClass(_obj,_l,_targetId,_AClist):-
	getObjClass(_obj,_subclasslist),
	member(_id,_subclasslist),
	\+('Query'(_id)),
	member(_ac,_AClist),
	id2name(_ac,_label),
	prove_literal('P'(_,_id,_label,_targetId)).

getAttrTargetClass(_obj,_l,_targetId,_AClist):-
	getObjClass(_obj,_subclasslist),
	member(_subclass,_subclasslist),
	prove_literal('Isa'(_subclass,_id)),
	\+('Query'(_id)),
	member(_ac,_AClist),
	id2name(_ac,_label),
	prove_literal('P'(_,_id,_label,_targetId)),
	atom(_id).


getObjClass(_obj,[_head|_tail]) :-
	'VarTabLookup'(_obj,[_head|_tail]),
	!.


/** we do not consider instantiation derived from rules here **/
/** see ticket #146                                          **/
getObjClass(_obj,_typelist) :-
	name2id(_obj,_id),
	setof(_class,prove_literal('In_e'(_id,_class)),_typelist),
	!.

getObjClass(_obj,'ERROR') :-
	report_error( 'PFNFE','MSFOLassertionParserUtilities',[_obj]),!,fail.


/*********************************************************************************/
/* replaceSelectExpB(_term, _lastvar, _dest,  _new)                              */
/*                                                                               */
/*  _term     = Select-Ausdruck                                                  */
/*  _lastvar  = Objekt, das am Ende des Select-Ausdrucks eingesetzt werden muss  */
/* 			  (Bsp.: _lastvar in _term)                                         */
/*  _dest     = Klasse, die durch Select-Ausdruck beschrieben wird  (Rueckgabe)  */
/*  _new      = Rueckgabe (aequiv. Term fuer SelectAusdruck)                     */
/*                                                                               */
/*********************************************************************************/

/* Fall 1: x.a;s   (; steht fuer . oder |*/
replaceSelectExpB(selectExpB(_obj,dot,selectExpB(_attr,_op2,_right)), _lastvar, _dest, _new) :-
	atom(_attr),
	createNewVarname(_genvar),
	getAttrClass(_obj,_attr,_class),
	eval(select(_class,'^',_attr),replaceSelectExpression,_type),
	'VarTabInsert'([_genvar],[_type]),
	replaceSelectExpB(selectExpB(_genvar,_op2,_right),_lastvar,_dest,_term2),
	get_ident(_obj,_id),
	buildDottedLiteral('A'(_id,_attr,_genvar),_lit),
	expandQuantifier(exists,[vtype([_genvar],[_type])],and([lit(_lit),_term2]),_new).

/* Fall 2: x.a */
replaceSelectExpB(selectExpB(_obj,dot,_attr),_lastvar,_dest,lit(_lit)) :-
	atom(_attr),
	getAttrClass(_obj,_attr,_class),
	eval(select(_class,'^',_attr),replaceSelectExpression,_dest),
	get_ident(_obj,_id),
	buildDottedLiteral('A'(_id,_attr,_lastvar),_lit).

/* Fall 3: x|a;s */
replaceSelectExpB(selectExpB(_obj,bar,selectExpB(_attr,_op2,_right)), _lastvar, _dest, _new) :-
	atom(_attr),
	createNewVarname(_genvar),
	getAttrClass(_obj,_attr,_class),
	eval(select(_class,'!',_attr),replaceSelectExpression,_type),
	'VarTabInsert'([_genvar],[_type]),
	replaceSelectExpB(selectExpB(_genvar,_op2,_right),_lastvar,_dest,_term2),
	get_ident(_obj,_id),
	expandQuantifier(exists,[vtype([_genvar],[_type])],and([lit('From'(_genvar,_id)),_term2]),_new).

/* Fall 4: x|a */
replaceSelectExpB(selectExpB(_obj,bar,_attr),_lastvar,_dest,_new) :-
	atom(_attr),
	getAttrClass(_obj,_attr,_class),
	eval(select(_class,'!',_attr),replaceSelectExpression,_dest),
	get_ident(_obj,_id),
	_new = lit('From'(_lastvar,_id)).

/* Fall 5: x.(a:r);s*/
replaceSelectExpB(selectExpB(_obj,dot,selectExpB(restriction(_attr,_rest),_op2,_right)),_lastvar,_dest,_new) :-
	atom(_attr),
	createNewVarname(_genvar),
	getAttrClass(_obj,_attr,_class),
	eval(select(_class,'^',_attr),replaceSelectExpression,_type),
	'VarTabInsert'([_genvar],[_type]),
	replaceSelectExpB(selectExpB(_genvar,_op2,_right),_lastvar,_dest,_term2),
	get_ident(_obj,_id),
	buildDottedLiteral('A'(_id,_attr,_genvar),_lit),
	replaceRestriction(_rest,_genvar,_term3),
	expandQuantifier(exists,[vtype([_genvar],[_type])],and([lit(_lit),_term3,_term2]),_new).

/* Fall 6: x.(a:r) */
replaceSelectExpB(selectExpB(_obj,dot,restriction(_attr,_rest)),_lastvar,_type,and([lit(_lit),_term3])) :-
	atom(_attr),
	getAttrClass(_obj,_attr,_class),
	eval(select(_class,'^',_attr),replaceSelectExpression,_type),
	get_ident(_obj,_id),
	buildDottedLiteral('A'(_id,_attr,_lastvar),_lit),
	replaceRestriction(_rest,_lastvar,_term3).

/* Fall 7: x|(a:r);s */
replaceSelectExpB(selectExpB(_obj,bar,selectExpB(restriction(_attr,_rest),_op2,_right)),_lastvar,_dest,_new) :-
	atom(_attr),
	createNewVarname(_genvar),
	createNewVarname(_genvar2),
	getAttrClass(_obj,_attr,_class),
	eval(select(_class,'!',_attr),replaceSelectExpression,_type),
	eval(select(_class,'^',_attr),replaceSelectExpression,_type2),
	'VarTabInsert'([_genvar],[_type]),
	'VarTabInsert'([_genvar2],[_type2]),
	replaceSelectExpB(selectExpB(_genvar,_op2,_right),_lastvar,_dest,_term2),
	replaceRestriction(_rest,_genvar2,_term3),
	get_ident(_obj,_id),
	expandQuantifier(exists,[vtype([_genvar],[_type])],and([lit('From'(_genvar,_id)),lit('To'(_genvar,_genvar2)),_term3,_term2]),_new).

/* Fall 8: x|(a:r) */
replaceSelectExpB(selectExpB(_obj,bar,restriction(_attr,_rest)),_lastvar,_dest,_new) :-
	atom(_attr),
	createNewVarname(_genvar),
	getAttrClass(_obj,_attr,_class),
	eval(select(_class,'!',_attr),replaceSelectExpression,_dest),
	eval(select(_class,'^',_attr),replaceSelectExpression,_type),
	'VarTabInsert'([_genvar],[_type]),
	replaceRestriction(_rest,_genvar,_term3),
	get_ident(_obj,_id),
	expandQuantifier(exists,[vtype([_genvar],[_type])],and([lit('From'(_lastvar,_id)),lit('To'(_lastvar,_genvar)),_term3]),_new).

/* Fehlerbehandlung */
replaceSelectExpB(_t,_v,_d,_n) :-
	report_error('ERRORSELECTEXP','MSFOLassertionParserUtilities',[_t]),
	!,fail.

/*********************************************************************************/
/* replaceSelectExpBList(_term,_destvarlist,_dest,_termlist)                     */
/*                                                                               */
/*  Ruft replaceSelectExpB/4 fuer eine Liste von Variablen auf,                  */
/*  und gibt eine Liste von Termen zurueck                                       */
/*                                                                               */
/*********************************************************************************/

replaceSelectExpBList(_t,[],_d,[]).

replaceSelectExpBList(_t,[_v|_l],_d,[_term|_termlist]) :-
	replaceSelectExpB(_t,_v,_d,_term),
	replaceSelectExpBList(_t,_l,_d2,_termlist).


/*********************************************************************************/
/* replaceRestriction(_rest,_var,_term)                                          */
/*                                                                               */
/* _rest = Enumeration, SelectExpB oder Klasse                                   */
/* _var  = Variable, fuer die die Restriktion gelten soll                        */
/* _term = neuer Term                                                            */
/*                                                                               */
/*********************************************************************************/

/* Fall 1: Enumerations */
replaceRestriction(enumeration([class(_c)]),_var,lit('IDENTICAL'(_var,_c))) :- !.

replaceRestriction(enumeration(_list),_var,or(_termlist)) :-
	replaceEnumeration(_list,_var,_termlist).

/* Fall 2: SelectExpB */
replaceRestriction(selectExpB(_obj,_op,_right),_var,_term) :-
	replaceSelectExpB(selectExpB(_obj,_op,_right),_var,_dest,_term).

/* Fall 3: einfache Klassen */
replaceRestriction(_class,_var,lit('In'(_var,_id))) :-
	atom(_class),
	get_ident(_class,_id).

/*********************************************************************************/
/* replaceEnumeration(_objlist, _var, _term)                                     */
/*                                                                               */
/* _objlist = Liste von Objekten, in der _var enthalten sein soll                */
/* _var     = Variable, die in _objlist enthalten sein soll                      */
/* _term    = Liste von IDENTICAL-Literalen                                      */
/*                                                                               */
/*********************************************************************************/

replaceEnumeration([class(_head)],_var,[lit('IDENTICAL'(_var,_id))]) :-
	get_ident(_head,_id).

replaceEnumeration([class(_head)|_tail], _var, [lit('IDENTICAL'(_var,_id))|_term2]) :-
	get_ident(_head,_id),
	replaceEnumeration(_tail,_var,_term2).


/******************************************/
/** get_ident(_obj,_id)                  **/
/******************************************/

get_ident(_obj,_obj) :-
	'VarTabVariable'(_obj),
	!.

get_ident(_obj,_id) :-
	name2id(_obj,_id),!.

get_ident(_obj,_) :-
	report_error('PFNFE','MSFOLassertionParserUtilities',[_obj]),
	!,fail.


/** 10-Feb-2005/M. Jeusfeld: solve ticket #48 in parseAss.dcg/parseAss_dcg.pro **/
/** The direct call of t_msp/1 in parseAss.dcg could crash onder SWI-Prolog    **/
/** in case the dynamic predicate t_msp is undefined. The new predicate        **/
/** temp_msp is working like t_msp but will not fail In case t_msp is          **/
/** undefined, it will return the current module search space (getModule).     **/
/** Besides, the dynamic predicate t_msp is now defined here and imported by   **/
/** parseAss.dcg.                                                              **/
/** To let parseAss_dcg.pro work under SWI-Prolog, one has to manually replace **/
/** 'not _x' by 'not(_x)'.                                                     **/
/** Note that parseAss.dcg is converted to parseAss_dcg.pro by the program     **/
/** dcg.pro (main call '?- dcg'). Under SWI, the file parseAss_dcg.pro is      **/
/** converted to parseAss_dcg.swi.pl.                                          **/


temp_msp(_m) :-
  pc_has_a_definition(t_msp(_)),
  t_msp(_m),                         /** temporary search space defined **/
  !.

temp_msp(_m) :-
  getModule(_m).  /** else: take current search space **/


/** Convert plain argruments of shortcut function calls to substitutions as **/
/** defined for generic query classes. See Ticket #173.                     **/

plainToSubsts(_funId,_plainArgs,_substArgs) :-
  'QueryArgExp'(_funId,_qargexps),
  filterParameterDeclarations(_qargexps,_labels),
  convertPlainToSubsts(_plainArgs,_labels,_substArgs),
  !.

/** this case should never occur: **/
plainToSubsts(_funId,_plainArgs,_substArgs) :-
  write_lcall(plainToSubsts(_funId,_plainArgs)),nl,
  write('Error plainToSubsts'),nl,
  fail.





filterParameterDeclarations([this,_singleparam],[_lab]) :-
  getParamLabel(_singleparam,_lab),
  !.

filterParameterDeclarations([this|_params],_sortedlabels) :-
  paramLabels(_params,_labels),
  quicksortLabels(_labels,_sortedlabels).


getParamLabel(p(_lab,_d),_lab).
getParamLabel(cp(_lab,_d),_lab).
getParamLabel(rp(_lab,_d),_lab).


paramLabels([_param],[_lab]) :- getParamLabel(_param,_lab),!.

/** skip computed_attribute **/
paramLabels([c(_attr)|_restparams],_restlabels) :- 
  paramLabels(_restparams,_restlabels).

/** skip retrieved_attribute **/
paramLabels([r(_attr)|_restparams],_restlabels) :- 
  paramLabels(_restparams,_restlabels).

paramLabels([_param|_restparams],[_lab|_restlabels]) :- 
  getParamLabel(_param,_lab),
  paramLabels(_restparams,_restlabels).


convertPlainToSubsts([],[],[]) :- !.

convertPlainToSubsts([plainarg(_arg)|_restargs],[_lab|_restlabels],[substitute(_arg,_lab)|_restsubsts]) :-
  convertPlainToSubsts(_restargs,_restlabels,_restsubsts).



/** makeAddition/makMultiplication create the functional forms for **/
/** arithmetic expressions.                                        **/

makeAddition(_x,'+',_y,derive(_PLUS,[substitute(_x,_lab1),substitute(_y,_lab2)])) :- 
  sharpestArgType('+',_x,_y,_PLUS,_lab1,_lab2),
  !.

makeAddition(_x,'-',_y,derive(_MINUS,[substitute(_x,_lab1),substitute(_y,_lab2)])) :-
  sharpestArgType('-',_x,_y,_MINUS,_lab1,_lab2),
  !.

makeMultiplication(_x,'*',_y,derive(_MULT,[substitute(_x,_lab1),substitute(_y,_lab2)])) :- 
  sharpestArgType('*',_x,_y,_MULT,_lab1,_lab2),
  !.

makeMultiplication(_x,'/',_y,derive(_DIV,[substitute(_x,r1),substitute(_y,r2)])) :-
  name2id('DIV',_DIV),
  !.

sharpestArgType(_op,_x,_y,_FUN,_lab1,_lab2) :-
  checkType(_x,_T1),
  checkType(_y,_T2),
  decideOnType(_op,_T1,_T2,_FUN,_lab1,_lab2).

sharpestArgType(_op,_x,_y,_FUN,_lab1,_lab2) :-
  decideforGeneric(_op,_FUN,_lab1,_lab2).




checkType(_x,_T) :-
  'VarTabVariable'(_x),
  'VarTabLookup'(_x,[_T]),
  !.

checkType(_x,_T) :-
  is_id(_x),
  name2id('Integer',_T),
  prove_literal('In'(_x,_T)),
  !.

/** also support expressions like MIN(spSet[x,y]); in this case, the result **/
/** type is bound by the superclass(es) of spSet.                           **/
/** If spSet is a subclass of Integer, then MIN(spSet[x,y]) must be an      **/
/** Integer as well!                                                        **/
checkType(_x,_T) :-
  _x = derive(_minmax,[substitute(_innerexpr,class)]),
  id2name(_minmax,_minmaxname),
  memberchk(_minmaxname,['MIN','MAX']),
  _innerexpr=derive(_fid,_substs),
  name2id('Integer',_T),
  prove_literal('Isa_e'(_fid,_T)),
  !.


checkType(_x,_T) :-
  _x = derive(_fid,_substs),
  name2id('Integer',_T),
  prove_literal('Isa_e'(_fid,_T)),
  !.
  


decideOnType('+',_T1,_T2,_FUNID,i1,i2) :-
  goForInteger(_T1,_T2),
  name2id('IPLUS',_FUNID),
  !.

decideOnType('-',_T1,_T2,_FUNID,i1,i2) :-
  goForInteger(_T1,_T2),
  name2id('IMINUS',_FUNID),
  !.

decideOnType('*',_T1,_T2,_FUNID,i1,i2) :-
  goForInteger(_T1,_T2),
  name2id('IMULT',_FUNID),
  !.

/** otherwise: it will be the generic operations for real numbers **/
decideOnType(_op,_,_,_FUNID,_lab1,_lab2) :-
  decideforGeneric(_op,_FUNID,_lab1,_lab2).


/** goForInteger is true if 'Integer' is the super-type of **/
/** both T1 and T2. Then, we shall use the integer         **/
/** variants of arithmetic operations.                     **/

goForInteger(_T1,_T2) :-
  name2id('Integer',_INT),
  prove_literal('Isa'(_T1,_INT)),
  prove_literal('Isa'(_T2,_INT)),
  !.

/** relaxation of rule for selecting Integer; if one of the args is **/
/** has type Integer, and the has has a type that is not Real, then **/
/** we take Integer.                                                **/

goForInteger(_T1,_T2) :-
  name2id('Integer',_INT),
  prove_literal('Isa'(_T1,_INT)),
  name2id('Real',_REAL),
  \+ prove_literal('Isa'(_T2,_REAL)),
  !.

goForInteger(_T1,_T2) :-
  name2id('Integer',_INT),
  prove_literal('Isa'(_T2,_INT)),
  name2id('Real',_REAL),
  \+ prove_literal('Isa'(_T1,_REAL)),
  !.
  

decideforGeneric('+',_FUNID,r1,r2) :-
  name2id('PLUS',_FUNID),
  !.

decideforGeneric('-',_FUNID,r1,r2) :-
  name2id('MINUS',_FUNID),
  !.

decideforGeneric('*',_FUNID,r1,r2) :-
  name2id('MULT',_FUNID),
  !.

decideforGeneric('/',_FUNID,r1,r2) :-
  name2id('DIV',_FUNID),
  !.



isVariable(_x,_x) :-
'VarTabLookup_vars'(_vars),
  'VarTabVariable'(_x),
  !.  

/** also allow parameter variables without '~' **/
isVariable(_x,_xtilde) :-
  pc_atomconcat('~',_x,_xtilde),
  'VarTabVariable'(_xtilde),
  !.

isKeyword(_k) :-
  memberchk(_k,['UNIFIES','in','isA','not','In','forall','exists','IDENTICAL','Ai','In_e','In_s','new']).


containsNoReservedWord([]) :- !.
containsNoReservedWord([_var|_rest]) :-
  isKeyword(_var),
  !,
  report_error('WRONGVARLABEL','MSFOLassertionParserUtilities',[_var]),
  fail.

containsNoReservedWord([_var|_rest]) :-
  containsNoReservedWord(_rest).




/** transform an identifier from tokens.dcg into a Prolog atom, taking into account **/
/** the treatment of the 'this'variable.                                            **/
/** Identifiers in tokens.dcg are lists of characters! Ticket #311.                 **/

transformIdentifier([t,h,i,s],'~this') :- !.

transformIdentifier(_charlist,_atom) :-
  pc_atomconcat(_charlist,_atom).




