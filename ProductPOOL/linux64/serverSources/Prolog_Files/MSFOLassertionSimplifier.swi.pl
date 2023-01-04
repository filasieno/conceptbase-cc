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
* File :       %M%
* Version :   %I%
* Creation:    17-Aug-1989, Martin Staudt (UPA)
* Last change: %E%, Martin Staudt (RWTH)
* SCCS-Source-Pool : %P%
* Date retrieved : %D% (YY/MM/DD)
*
*
*
*  This file contains predicates for simplification
*  of MSFOLassertions
*
*
*------------------------------------------------------------
*
* was AssertionSimplifier.pro
*
*/


:- module('MSFOLassertionSimplifier',[
'generateMiniScopeForm'/2
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').


/*===========================================================*/
/*=                  IMPORTED PREDICATES                    =*/
/*===========================================================*/

:- use_module('GeneralUtilities.swi.pl').


:- use_module('MSFOLassertionUtilities.swi.pl').
:- use_module('VarTabHandling.swi.pl').




:- use_module('AssertionTransformer.swi.pl').
:- use_module('PrologCompatibility.swi.pl').


:- use_module('MSFOLassertionTransformer.swi.pl').

/*===========================================================*/
/*=              LOCAL PREDICATE DECLARATION                =*/
/*===========================================================*/








:- dynamic 'meta'/1 .


:- style_check(-singleton).




/*===========================================================*/
/*=             EXPORTED PREDICATES DEFINITION              =*/
/*===========================================================*/

/*************************************************************/
/** generateMiniScopeForm(_formula ,_miniscopeFormula)**/
/**                                                         **/
/**  _formula : ground : MSFOLassertiontree                 **/
/** _miniscopeFormula  : free                               **/
/**                                                         **/
/** _miniscopeFormula is miniscope form of _formula.        **/
/** Transformation is done by using an algorithm similar to **/
/** the one proposed in                                     **/
/** 'Towards an Efficient Evaluation of General Queries :   **/
/** Quantifier and Disjunction Processing Revisited',       **/
/** Francois Bry, Proc. ACM-SIGMOD '89                      **/
/**                                                         **/
/*************************************************************/

generateMiniScopeForm( 'MSFOLconstraint'(_formulaMSFOL), 'MSFOLconstraint'(_miniscopeMSFOL)) :-
	testMeta(_formulaMSFOL),!, /*1.10 RS*/
	generateMiniScopeForm2( _formulaMSFOL, _miniscopeMSFOL).

generateMiniScopeForm( 'MSFOLrule'(_vars,_conditionMSFOL,_conclusionMSFOL), 'MSFOLrule'(_vars,_minicondMSFOL,_conclusionMSFOL)) :-
	testMeta(_conditionMSFOL), /*1.10 RS*/
	((meta(0),testMeta(_conclusionMSFOL));(true)),!,
	generateMiniScopeForm2( _conditionMSFOL, _minicondMSFOL1),
	convertCondition(_vars,_minicondMSFOL1,_bdmconditionMSFOL),
	!,
	pushNegationInvards(_bdmconditionMSFOL, _minicondMSFOL).

/*===========================================================*/
/*=                LOCAL PREDICATES DEFINITION              =*/
/*===========================================================*/

generateMiniScopeForm2(_formulaMSFOL,_miniscopeMSFOL) :-
	simplify(_formulaMSFOL,_miniscope_negMSFOL),
	/** in der Miniscope-Form tauchen u.U. noch not's auf (sagt EK). Diese werden nach innen gezogen.
	**/
	pushNegationInvards(_miniscope_negMSFOL, _miniscopeMSFOL).

/*************************************************************/
/** simplify ( _formula , _result )                         **/
/**                                                         **/
/**  _formula : ground                                      **/
/**  _result : free                                         **/
/**                                                         **/
/** Simplify processes recursive application of the Bry     **/
/** algorithm to _formula with result _result.              **/
/**                                                         **/
/*************************************************************/


/** Falls das Ergebnis von simplify ein Term ist, der seinerseits mit _junktor beginnt, werden dessen Unterterme mit dem aktuellen Term verschmolzen.
**/

simplify(or([]),or([])) :- !.

simplify(or([_t|_tlist]),or(_result)) :-
	simplify(_t,_st),
	junktorTree(or,_st,_sts),
	simplify(or(_tlist),or(_stlist)),
	append(_sts,_stlist,_result).

simplify(and([]),and([])) :- !.

simplify(and([_t|_tlist]),and(_result)) :-
	simplify(_t,_st),
	junktorTree(and,_st,_sts),
	simplify(and(_tlist),and(_stlist)),
	append(_sts,_stlist,_result).



simplify(impl(_t1,_t2),or(_res)) :-
	simplify(not(_t1),_s1),
	simplify(_t2,_s2),
	junktorTree(or,_s1,_r1),
	junktorTree(or,_s2,_r2),
	append(_r1,_r2,_res).


simplify(not(impl(_t1,_t2)),and(_res)) :-
	simplify(_t1,_s1),
	simplify(not(_t2),_s2),
	junktorTree(and,_s1,_r1),
	junktorTree(and,_s2,_r2),
	append(_r1,_r2,_res).



simplify(not(not(_t)),_r) :-
	simplify(_t,_r).


simplify(not(and([])),or([])).

simplify(not(and([_t|_tlist])),or(_result)) :-
	simplify(not(_t),_st),
	junktorTree(or,_st,_sts),
	simplify( not(and(_tlist)) ,or(_stlist) ),
	append(_sts,_stlist,_result).


simplify(not(or([])),and([])).

simplify(not(or([_t|_tlist])),and(_result)) :-
	simplify(not(_t),_st),
	junktorTree(and,_st,_sts),
	simplify( not(or(_tlist)) ,and(_stlist) ),
	append(_sts,_stlist,_result).


/** 26-May-2004/M.Jeusfeld: CBNEWS.doc[212]
simplify(forall(_var,_type,_t),_r) :-
	simplify(not(exists(_var,_type,not(_t))),_r).
**/

/** 26-May-2004/M.Jeusfeld: CBNEWS.doc[212] **/
simplify(forall(_var,_type,_t),forall(_var,_type,_r1)) :-
  simplify(_t,_r1),
  !.


simplify(not(forall(_var,_type,_t)),_r) :-
	simplify(exists(_var,_type,not(_t)),_r).

simplify(exists(_var,_type,_t),_r) :-
	simplify(_t,_r1),
	reduceScope(exists(_var,_type,_r1),_r).

simplify(not(exists(_var,_type,_t)),_r) :-
	simplify(_t,_r1),
	reduceScope(not(exists(_var,_type,_r1)),_r).

simplify(not(lit('TRUE')),lit('FALSE')).

simplify(not(lit('FALSE')),lit('TRUE')).

simplify(not(lit(_l)),not(lit(_l))).

simplify(lit(_l),lit(_l)).
/*************************************************************/
/** testMeta(_term)					   **/
/** 							   **/
/** _term: Term, dessen Blaetter Ausdruecke der Form        **/
/** 	  lit(<Literal>) sind				   **/
/** 							   **/
/** testMeta prueft, ob es sich bei einem solchen Ausdruck  **/
/** um eine Metaformel handelt.				   **/
/*************************************************************/



testMeta(_) :-
	isQuery,
	pc_update(meta(0)),!. /** Queries werden nicht durch den Metaformel-Compiler behandelt **/

testMeta(_term) :-
	flatten(_term,_lits),
	containsMetaLit(_lits),!,
	pc_update(meta(1)).
testMeta(_term) :-
	pc_update(meta(0)).


containsMetaLit(['In'(_x,_c)|_lits]) :-
	'VarTabVariable'(_c),!.
containsMetaLit([_|_lits]) :-
	containsMetaLit(_lits).

flatten(lit(_l),[_l]) :- !.
flatten(_term,_litList) :-
	_term =.. [_|_subTerms],
	flattenList(_subTerms,_litList).

flattenList([],[]).
flattenList([_t|_ts],_litList) :-
	flatten(_t,_l1),
	flattenList(_ts,_l2),
	append(_l1,_l2,_litList).





/*************************************************************/
/** reduceScope ( _formula , _result )                      **/
/**                                                         **/
/**   _formula : ground                                     **/
/**   _result : free                                        **/
/**                                                         **/
/** reduceScope tries to reduce the scope of exists-        **/
/** quantifier preceding (sub) formula _formula.            **/
/**                                                         **/
/*************************************************************/

reduceScope(_t,_t) :-
	meta(1),!.




reduceScope(exists(_var,_type,and(_ts)), _result) :-
	reduceScope8(exists(_var,_type,and(_ts)), _result).

reduceScope(not(exists(_var,_type,and(_ts))), _result) :-
	reduceScope9(not(exists(_var,_type,and(_ts))), _result).

reduceScope(exists(_var,_type,and(_ts)),_result) :-
	reduceScope10(exists(_var,_type,and(_ts)),_result).

reduceScope(not(exists(_var,_type,and(_ts))),_result) :-
	reduceScope11(not(exists(_var,_type,and(_ts))),_result).

reduceScope(exists(_var,_type,or(_ts)),_result) :-
	reduceScope14(exists(_var,_type,or(_ts)),_result).

reduceScope(not(exists(_var,_type,or(_ts))), _result) :-
	reduceScope15(not(exists(_var,_type,or(_ts))), _result).

reduceScope(exists(_var,_type,lit(_l)), _result) :-
	reduceScope16(exists(_var,_type,lit(_l)), _result).

reduceScope(not(exists(_var,_type,lit(_l))), _result) :-
	reduceScope17(not(exists(_var,_type,lit(_l))), _result).

/**
reduceScope(exists(_x,_type1,exists(_y,_type2,_f)), _result) :-
	reduceScope18(exists(_x,_type1,exists(_y,_type2,_f)),_result).
**/

reduceScope(_t,_t) :- !.

/********************************************************************************/

/*************************************************************/
/** reduceScope8(exists(_v,_t,and(_andlist)), _result       **/
/**                                                         **/
/** entspricht Regel 8 des Bry-Algorithmus                  **/
/** Enthaelt _andlist einen Unterbaum t, in dem die Variable**/
/** _v nicht vorkommt, so wird t aus dem Gueltigkeitsbereich**/
/** des exists-Quantors herausgezogen.                      **/
/*************************************************************/
/* 15-Feb-1993/kvt: Rules 6/7 can be made applicable, if the context of
  the exists quantifier is known: e.g.  'exists x/X a and b'  where
  x does occur neither in a nor in b can be reduced to
  'a and b and exists x/X TRUE'.
*/

/** Case 1:  Only two clauses are within the scope of the   **/
/**          exists quantifier. We must have at least two   **/
/**          subtrees in an and-list.                       **/

/** Case 1a: Both clauses can be moved out of the scope of  **/
/**          the quantifier                                 **/

reduceScope8(exists(_var,_type,and([_t1,_t2])),
            and([_t1,_t2,exists(_var,_type,lit('TRUE'))])) :-

	notOccurs(_var,_t1),
	notOccurs(_var,_t2).


/** Case 1b: One of the clauses can be moved out of the     **/
/**          scope of the exists quantifier. These explicit **/
/**          clauses prohibit the construction of an        **/
/**          and-list with only one element.                **/

reduceScope8(exists(_var,_type,and([_t1,_t2])),and([_t1|_rs])) :-
	notOccurs(_var,_t1),
	!,
	reduceScope(exists(_var,_type,_t2),_nt),
	junktorTree(and,_nt,_rs).

reduceScope8(exists(_var,_type,and([_t1,_t2])),and(_result)) :-
	!, /** avoid backtracking to general case **/
	notOccurs(_var,_t2),
	!,
	reduceScope(exists(_var,_type,_t1),_nt),
	junktorTree(and,_nt,_rs),
	append(_rs,[_t2],_result).


/** Case 2:  The and-list has more than two elements        **/

reduceScope8(exists(_var,_type,and(_andlist)),
            and([_t|_rs])) :-

	member(_t,_andlist),
	notOccurs(_var,_t),
	!,
	delete(_t,_andlist,_newandlist),
	reduceScope(exists(_var,_type,and(_newandlist)),_st),
	junktorTree(and,_st,_rs).



/*************************************************************/
/** reduceScope9(not(exists(_v,_t,and(_andlist))), _result  **/
/**                                                         **/
/** entspricht Regel 9 des Bry-Algorithmus                  **/
/** Wie Regel 8 nur fuer den not(exists..)-Fall.            **/
/** Enthaelt _andlist einen Unterbaum t, in dem die Variable**/
/** _v nicht vorkommt, so wird t aus dem Gueltigkeitsbereich**/
/** des exists-Quantors herausgezogen.                      **/
/*************************************************************/


/** Case 1:  Only two clauses are within the scope of the   **/
/**          exists quantifier. We must have at least two   **/
/**          subtrees in an and-list.                       **/

/** Case 1a: Both clauses can be moved out of the scope of  **/
/**          the quantifier                                 **/

reduceScope9(not(exists(_var,_type,and([_t1,_t2]))),
            or([_nt1,_nt2,not(exists(_var,_type,lit('TRUE')))])) :-

	notOccurs(_var,_t1),
	notOccurs(_var,_t2),
	simplify(not(_t1),_nt1),
	simplify(not(_t2),_nt2).


/** Case 1b: One of the clauses can be moved out of the     **/
/**          scope of the exists quantifier. These explicit **/
/**          clauses prohibit the construction of an        **/
/**          and-list with only one element.                **/

reduceScope9(not(exists(_var,_type,and([_t1,_t2]))),or([_nt1|_rs])) :-
	notOccurs(_var,_t1),
	!,
	simplify(not(_t1),_nt1),
	reduceScope(not(exists(_var,_type,_t2)),_nt),
	junktorTree(or,_nt,_rs).
/*korrigiert, 13-02.96, MSt; im Kopf stand _t statt _nt1*/

reduceScope9(not(exists(_var,_type,and([_t1,_t2]))),or(_result)) :-
	!, /** avoid backtracking to general case **/
	notOccurs(_var,_t2),
	!,
	simplify(not(_t2),_nt2),
	reduceScope(not(exists(_var,_type,_t1)),_nt),
	junktorTree(or,_nt,_rs),
	append(_rs,[_nt2],_result).


/** Case 2:  The and-list has more than two elements        **/

reduceScope9(not(exists(_var,_type,and(_andlist))),
            or([_nt|_rs])) :-

	member(_t,_andlist),
	notOccurs(_var,_t),
	!,
	delete(_t,_andlist,_newandlist),
	simplify(not(_t),_nt),
	reduceScope(not(exists(_var,_type,and(_newandlist))),_st),
	junktorTree(or,_st,_rs).



/*************************************************************/
/** reduceScope10(exists(_v,_t,and(_andlist)), _result      **/
/**                                                         **/
/** entspricht Regel 10 des Bry-Algorithmus                 **/
/** Enthaelt die _andlist einen or-Unterbaum t, in dem eine **/
/** Teilformel f vorkommt, wird das Distributivgesetz ange- **/
/** wendet. In einem spaeteren Schritt kann f dann aus dem  **/
/** Gueltigkeitsbereich von _v gezogen werden.              **/
/*************************************************************/

reduceScope10(exists(_var,_type,and(_andlist)),_res) :-
	member(or(_orlist),_andlist),
	member(_t,_orlist),
	notOccursInSubFormula(_var,_t),
	!,
	delete(or(_orlist),_andlist,_neuandlist),
	delete(_t,_orlist,_neuorlist),
	(
	  (_neuorlist = [_oritem], /** einelementig **/
	  reduceScope(exists(_var,_type, or([and([_t|_neuandlist]),and([_oritem|_neuandlist])])),_res) )
	;
	  reduceScope(exists(_var,_type, or([and([_t|_neuandlist]),and([or(_neuorlist)|_neuandlist])])),_res)
	).

/*************************************************************/
/** reduceScope11(not(exists(_v,_t,and(_andlist))), _result **/
/**                                                         **/
/** entspricht Regel 11 des Bry-Algorithmus                 **/
/** Wie Regel 10 nur fuer den not(exists..)-Fall.           **/
/** Enthaelt die _andlist einen or-Unterbaum t, in dem eine **/
/** Teilformel f vorkommt, wird das Distributivgesetz ange- **/
/** wendet. In einem spaeteren Schritt kann f dann aus dem  **/
/** Gueltigkeitsbereich von _v gezogen werden.              **/
/*************************************************************/

reduceScope11(not(exists(_var,_type,and(_andlist))),_res) :-
	member(or(_orlist),_andlist),
	member(_t,_orlist),
	notOccursInSubFormula(_var,_t),
	!,
	delete(or(_orlist),_andlist,_neuandlist),
	delete(_t,_orlist,_neuorlist),
	(( _neuorlist = [_oritem], /** einelementig **/
	 reduceScope(not(exists(_var,_type,or([and([_t|_neuandlist]),and([_oritem|_neuandlist])]))),_res)  )
	 ;
	reduceScope(not(exists(_var,_type,or([and([_t|_neuandlist]),and([or(_neuorlist)|_neuandlist])]))),_res)
	).


/**kvt**/
/** ACHTUNG: 14/15 verletzen die Rektifikationseigenschaft  **/
/**          der Formel. Dies wird jedoch spaeter voraus-   **/
/**          gesetzt.                                       **/

/*************************************************************/
/** reduceScope14(exists(_v,_t,or(_orlist)), _result)       **/
/**                                                         **/
/** entspricht Regel 14 des Bry-Algorithmus                 **/
/** Wenn _orlist einen Unterbaum t enthaelt, in dem eine    **/
/** Teilformel f vorkommt, in der _v nicht vorkommt, dann   **/
/** wird der exists-Quantor aufgesplittet. Da in einer      **/
/** Formel die Variablen eindeutig sein muessen, werden die **/
/** Variablen in den durch den Split neu entstandenen Teil- **/
/** termen durch neue Variablen substituiert.               **/
/*************************************************************/

/* Rule 14/15 : exists quantifiers are only distributed over disjunctions */
/*              if this is necessary for moving out some subexpression    */
/*              which does not contain the quantified variable            */

reduceScope14(exists(_var,_type,or([_t1,_t2])), or(_res)) :-
	!,
	(notOccursInSubFormula(_var,_t1);
	notOccursInSubFormula(_var,_t2)),

	_et1 = exists(_var,_type,_t1),
	_et2 = exists(_var,_type,_t2),

	renameVar(_var,_et1,_et2,_st1,_st2),

	reduceScope(_st1,_nt1),
	reduceScope(_st2,_nt2),
	junktorTree(or,_nt1,_rts1),
	junktorTree(or,_nt2,_rts2),
	append(_rts1,_rts2,_res).

reduceScope14(exists(_var,_type,or(_ts)),or(_res)) :-
	member(_t,_ts),
	notOccursInSubFormula(_var,_t),
	delete(_t,_ts,_dts),

	_et1 = exists(_var,_type,_t),
	_et2 = exists(_var,_type,or(_dts)),

	renameVar(_var,_et1,_et2,_st1,_st2),

	reduceScope(_st1,_nt1),
	reduceScope(_st2,_nt2),
	junktorTree(or,_nt1,_rts1),
	junktorTree(or,_nt2,_rts2),
	append(_rts1,_rts2,_res).

/*************************************************************/
/** reduceScope15(not(exists(_v,_t,or(_orlist))),_res)      **/
/**                                                         **/
/** entspricht Regel 15 des Bry-Algorithmus                 **/
/** Wie Regel 14 nur fuer den not(exists..)-Fall.           **/
/** Wenn _orlist einen Unterbaum t enthaelt, in dem eine    **/
/** Teilformel f vorkommt, in der _v nicht vorkommt, dann   **/
/** wird der exists-Quantor aufgesplittet. Da in einer      **/
/** Formel die Variablen eindeutig sein muessen, werden die **/
/** Variablen in den durch den Split neu entstandenen Teil- **/
/** termen durch neue Variablen substituiert.               **/
/*************************************************************/

reduceScope15(not(exists(_var,_type,or([_t1,_t2]))), and(_res)) :-
	!,
	(notOccursInSubFormula(_var,_t1);
	notOccursInSubFormula(_var,_t2)),

	_et1 = (not(exists(_var,_type,_t1))),
	_et2 = (not(exists(_var,_type,_t2))),

	renameVar(_var,_et1,_et2,_st1,_st2),

	reduceScope(_st1,_nt1),
	reduceScope(_st2,_nt2),
	junktorTree(and,_nt1,_rts1),
	junktorTree(and,_nt2,_rts2),
	append(_rts1,_rts2,_res).

reduceScope15(not(exists(_var,_type,or(_ts))),and(_res)) :-
	member(_t,_ts),
	notOccursInSubFormula(_var,_t),
	delete(_t,_ts,_dts),

	_et1 = (not(exists(_var,_type,_t))),
	_et2 = (not(exists(_var,_type,or(_dts)))),

	renameVar(_var,_et1,_et2,_st1,_st2),

	reduceScope(_st1,_nt1),
	reduceScope(_st2,_nt2),
	junktorTree(and,_nt1,_rts1),
	junktorTree(and,_nt2,_rts2),
	append(_rts1,_rts2,_res).

/*************************************************************/
/** reduceScope16(exists(_var,_,lit(_l)), _res)             **/
/**                                                         **/
/** nicht im Bry-Algorithmus                                **/
/** Ziehe das Literal lit(_l) aus dem exists-Ausdruck heraus**/
/** wenn die Variable _var in _l nicht vorkommt.            **/
/*************************************************************/

reduceScope16(exists(_x,_t,_lit), and([exists(_x,_t,lit('TRUE')),_lit]) ) :-
	notOccurs(_x,_lit).

/*************************************************************/
/** reduceScope17(exists(_var,_,lit(_l)), _res)             **/
/**                                                         **/
/** nicht im Bry-Algorithmus                                **/
/** wie reduceScope16, nur fuer not exists Fall             **/
/** Ziehe das Literal lit(_l) aus dem not exists-Ausdruck   **/
/** heraus, wenn die Variable _var in _l nicht vorkommt.    **/
/*************************************************************/

reduceScope17(not(exists(_x,_t,_lit)), or([not(exists(_x,_t,lit('TRUE'))),not(_lit)]) ) :-
	notOccurs(_x,_lit).


/*************************************************************/
/** reduceScope18(exists(_x,_,exists(_y,_,_f)),_res)        **/
/**                                                         **/
/** nicht im Bry-Algorithmus                                **/
/** Vertausche zwei getypte exists-Quantoren, wenn nach der **/
/** Vertauschung die Hoffnung besteht, den Gueltigkeits-    **/
/** bereich von _x noch weiter einzuschraenken.             **/
/*************************************************************/

reduceScope18(exists(_x,_type1,exists(_y,_type2,_f)),_result) :-
	not(notOccursInSubFormula(_y,_f)),
	notOccursInSubFormula(_x,_f),
	simplify(exists(_y,_type2,exists(_x,_type1,_f)),_result).

/*************************************************************/
/** notOccursInSubformula ( _var , _formula )               **/
/**                                                         **/
/** _var : ground                                           **/
/** _formula : ground                                       **/
/**                                                         **/
/** checks wether formula _formula contains an (!) atomic   **/
/** subformula which does not (!) contain variable _var.    **/
/*************************************************************/


notOccursInSubFormula(_var,exists(_,_,_t)) :-
	notOccursInSubFormula(_var,_t).

notOccursInSubFormula(_var,and([_t])) :-
	notOccursInSubFormula(_var,_t).

notOccursInSubFormula(_var,and([_t1|_ts])) :-
	notOccursInSubFormula(_var,_t1);
	notOccursInSubFormula(_var,and(_ts)).

notOccursInSubFormula(_var,or([_t])) :-
	notOccursInSubFormula(_var,_t).

notOccursInSubFormula(_var,or([_t1|_ts])) :-
	notOccursInSubFormula(_var,_t1);
	notOccursInSubFormula(_var,or(_ts)).

notOccursInSubFormula(_var,not(_t)) :-
	notOccursInSubFormula(_var,_t).

notOccursInSubFormula(_var,lit(_t)) :-
	notOccurs(_var,lit(_t)).

/*************************************************************/
/** junktorTree( _junktor , _tree, _treelist )              **/
/**                                                         **/
/*************************************************************/

junktorTree(_junktor,_t,_ts) :-
	_t =.. [_junktor,_ts], /** and/or have arity 1 **/
	!.

junktorTree(_junktor,_t,[_t]).

/*************************************************************/
/** notOccurs( _var,_term )                                 **/
/**                                                         **/
/** like not(occurs(_var,_term)) but fails if _term is      **/
/** TRUE or FALSE, too.                                     **/
/*************************************************************/

notOccurs(_,lit('TRUE')) :-
	!,
	fail.

notOccurs(_,lit('FALSE')) :-
	!,
	fail.

notOccurs(_var,_term) :-
	\+(occurs(_var,_term)).


occurs(_v,_v) :- !.

occurs(_,[]) :-
    !,
    fail.

occurs(_v,[_t|_]) :-
    occurs(_v,_t).

occurs(_v,[_|_r]) :-
    !,
    occurs(_v,_r).

occurs(_v,_t) :-
    _t =.. [_f|_args],
    !,
    occurs(_v,_args).


renameVar(_var,_t1,_t2,_t1,_t2).

/** Dies sollte renameVar/5 eigentlich tun
**/
/**
renameVar(_var,_t1,_t2,_rt1,_rt2) :-
    * build new variablenames *
	atom(_var),
	pc_atomconcat(_var,'#1',_nvar1),
	pc_atomconcat(_var,'#2',_nvar2),
    * substitute them in the terms _t1 and _t2 *
	substituteVar(_var,_nvar1,_t1,_rt1),
	substituteVar(_var,_nvar2,_t2,_rt2),
	!,
    * pc_update the variable table *
	VarTabLookup(_var,_t),
	VarTabInsert([_nvar1,_nvar2],_t),
	VarTabDelete(_var,_t).

**/

/*************************************************************/
/** convertCondition(_conclvars,_condition,_bdmcondition)   **/
/**                                                         **/
/** konvertiert eine Formel in das fuer die BDM-Behandlung  **/
/** noetige Format.                                         **/
/** Beispiel:                                               **/
/** convertCondition([a,b],F,_bdm) liefert in _bdm den Term **/
/** forall(a,c1,forall(b,c2,not(F)))                        **/
/** wobei c1 bzw. c2 die zu a bzw. b zugehoerigen Klassen   **/
/** sind                                                    **/
/** Diese merkwuerdig erscheinende Transformation braucht   **/
/** man, um die _condition ein eine Rangeform bringen zu    **/
/** koennen.                                                **/
/*************************************************************/

convertCondition([],_condition,not(_condition)).

convertCondition([_v|_vs],_condition,forall(_v,_t,_bdmcondition)) :-
	typeForVar(_v,_t),
	convertCondition(_vs,_condition,_bdmcondition).


typeForVar(_v,_t) :-
  'VarTabLookup'(_v,_t),
  checkArgLabel(_t),   /** under rare circumstances, _t could be tagged as UNKNOWN by parseAss.dcg **/
  !.
