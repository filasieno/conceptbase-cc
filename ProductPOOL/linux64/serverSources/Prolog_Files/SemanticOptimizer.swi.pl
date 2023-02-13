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
* Creation:    16-Nov-1990, Manfred Jeusfeld (UPA)
* Last Change: 11-Nov-2002, Manfred Jeusfeld (UvT)
* Date released : %E%  (YY/MM/DD)
*
* SCCS-Source-Pool : %P%
* Date retrieved : %D% (YY/MM/DD)
* -----------------------------------------------------------------------------
*
* This module is part of the provides procedures to optimize
* predicative formulas
*
* Was hier eigentlich getan wird ist recht einfach:
*  Die Gueltigkeit eines Literal In(_x,_c), das in einem Range vorkommt, kann bereits durch ein im selben Range
*  vorkommendes Adot(_,_,_) oder Aidot(_,_,_) Literal garantiert sein. In diesem Fall kann das In(_x,_c) weggelassen werden.
*
* Bem: Inzwischen werden auch ein paar weitere Optimierungen vorgenommen.
*
* Literature:
* [MIP-9013] Jeusfeld,M., Krueger,E. (1990). Deductive Integrity Maintenance
*            in an Object-Oriented Setting. Report MIP-9013, Universitaet
*            Passau, Germany.
*
*
*/

:- module('SemanticOptimizer',[
'optimizeRangeform'/2
,'alwaysTrue'/1
,'alwaysFalse'/1
,'exploitFunctionalDependencies'/3
,'exploitFunctionalDependencies'/2
,'optimizeECAcondition'/3
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').


:- use_module('GeneralUtilities.swi.pl').
:- use_module('PrologCompatibility.swi.pl').


:- use_module('BDMLiteralDeps.swi.pl').
:- use_module('PropositionProcessor.swi.pl').
:- use_module('VarTabHandling.swi.pl').

:- use_module('GlobalParameters.swi.pl').


:- use_module('Literals.swi.pl').

:- use_module('AssertionTransformer.swi.pl').
:- use_module('validProposition.swi.pl').


:- use_module('MetaUtilities.swi.pl').
:- use_module('QO_preproc.swi.pl').




:- style_check(-singleton).



/*===========================================================*/
/*=             EXPORTED PREDICATES DEFINITION              =*/
/*===========================================================*/

/*************************************************************/
/** optimizeRangeform(_rangeform,_optimizedRangeform) **/
/**  _rangeform: term (i)                                   **/
/**  _optimizedRangeform: term (o)                          **/
/**                                                         **/
/** The original _rangeform is transformed to an equivalent **/
/** _optimizedRangeform that is expected to be more         **/
/** efficient. The global parameter 'RangeFormOptimizing'   **/
/** controls the sort of optimization.                      **/
/*************************************************************/

/** Fall 1: Regel **/
optimizeRangeform(rangerule(_vars,_condRF,_conclL),rangerule(_vars,_cond_optRF,_conclL)) :-
	!,
	do_optimizeRangeform( _condRF, _cond_optRF).

/** Fall 2: Constraint **/
optimizeRangeform(rangeconstr(_assRF), rangeconstr(_assOptRF)) :-
	!,
	do_optimizeRangeform(_assRF,_assOptRF).





optimizeECAcondition(_event,'Ask'(_mainvar,_cond),'Ask'(_mainvar,_optCond)) :-
  is_list(_cond),
  getLitFromEvent(_event,_elit),
  optimizeRangeByElimination([_elit|_cond],_optCondWithElit),
  _optCondWithElit = [_elit|_optCond],
  !.
optimizeECAcondition(_,_x,_x).

/** the event can make certain literals true, which is useful for **/
/** finding more eliminations                                     **/
getLitFromEvent('Tell'(_elit),_elit) :- !.  /** Tell(_elit) implies that _elit is true) **/
getLitFromEvent(_,void).                  /** otherwise, we prepend 'void' which does not generate eliminations **/



/*************************************************************/
/** Incomplete prover for tautologies and contradictions    **/
/** can be used to prune integrity constraints that are     **/
/** always true.                                            **/
/** Works on the rangeform of formulas                      **/
/*************************************************************/

alwaysTrue(rangeconstr(_f)) :-
  alwaysTrue(_f).

alwaysTrue(forall(_vars,_lits,_f)) :-
  alwaysTrue(_f),
  !.

alwaysTrue(forall(_vars,_lits,_f)) :-
  pc_member(_aLit,_lits),
  alwaysFalse(_aLit),
  !.

alwaysTrue('TRUE').

alwaysTrue('EQ'(_x,_x)).


/** ticket #327: NE(x,y) is only guaranteed to be true if both arguments are different OIDs, i.e. no variables **/
alwaysTrue('NE'(_x,_y)) :-
  atom(_x),
  atom(_y),
  is_id(_x),
  is_id(_y),
  _x \== _y.



alwaysFalse(exists(_vars,_lits,_f)) :-
  alwaysFalse(_f),
  !.

alwaysFalse(exists(_vars,_lits,_f)) :-
  pc_member(_aLit,_lits),
  alwaysFalse(_aLit),
  !.

/** ticket #301 **/
alwaysFalse(_lits) :-
  pc_member(_aLit,_lits),
  alwaysFalse(_aLit),
  !.

alwaysFalse('FALSE').

alwaysFalse('NE'(_x,_x)).

alwaysFalse('EQ'(_x,_y)) :-
  atom(_x),
  atom(_y),
  is_id(_x),
  is_id(_y),
  _x \== _y.


/*===========================================================*/
/*=                LOCAL PREDICATES DEFINITION              =*/
/*===========================================================*/

do_optimizeRangeform(_rangeform,_optimizedRangeform) :-

	get_cb_feature('RangeFormOptimizing',_a),
	(_a == '1'; _a =='3'; _a == '4'),
	applyOptimizationMethods(_rangeform,_optimizedRangeform),
	(
	  _optimizedRangeform=_rangeform
	;
	  'WriteTrace'(high,'SemanticOptimizer', ['Optimize rangeform---> ',_optimizedRangeform])
	),
	!.

/** else: do nothing */
do_optimizeRangeform(_rangeform,_rangeform).


applyOptimizationMethods(_rangeform,_optrangeform) :-
  optRangeform(_rangeform,_optrangeform1),               /** general optimizations **/
  eliminateDomainByEQ(_optrangeform1,_optrangeform).     /** special pattern 1 **/



/*************************************************************/
/**                                                         **/
/** optRangeform(_rangeform,_denseRangeform)                **/
/**   _rangeform: term (i)                                  **/
/**   _denseRangeform: term (o)                             **/
/**                                                         **/
/** Traverse through _rangeform and make the optimizations. **/
/** Please insert other semantic optimizations here         **/
/*************************************************************/

optRangeform(forall(_v,_rangelits,_F),_result) :-
    !,
	optimizeRangeByCrosscheck(_rangelits,_F,_optrangelits1),   /** take care of a special pattern **/
	optimizeRangeByElimination(_optrangelits1,_optrangelits),
	!,
	optRangeform(_F,_optF),
	!,
	optimizeByTrueAndFalse(forall(_v,_optrangelits,_optF),_result),
	!.

optRangeform(exists(_v,_rangelits,_F),_result) :-
    !,
	optimizeRangeByCrosscheck(_rangelits,_F,_optrangelits1),   /** take care of a special pattern **/
	optimizeRangeByElimination(_optrangelits1,_optrangelits),
	!,
	optRangeform(_F,_optF),
	!,
	optimizeByTrueAndFalse(exists(_v,_optrangelits,_optF),_result),
	!.

optRangeform(and(_andlist),_result) :-
    !,
	optimizeAndlist(_andlist,_optandlist),
	!,
	optimizeByTrueAndFalse(and(_optandlist),_result),
	!.

optRangeform(or(_orlist),_result) :-
    !,
	optimizeOrlist(_orlist,_optorlist),
	!,
	optimizeByTrueAndFalse(or(_optorlist),_result),
	!.

optRangeform(not('TRUE'),'FALSE') :- !.

optRangeform(not('FALSE'),'TRUE') :- !.

optRangeform(_F,_F).

/*************************************************************/
/** optimizeAndlist(_andlist,_optandlist)                   **/
/** optimizeOrlist(_orlist,_optorlist)                      **/
/**                                                         **/
/** nutzen soweit moeglich TRUE und FALSE in And- bzw.      **/
/** Orlisten aus.                                           **/
/*************************************************************/

optimizeAndlist([],[]).

optimizeAndlist(['TRUE'|_as],_nas) :-
    !,
	optimizeAndlist(_as,_nas).

optimizeAndlist([_a|_as],_nas) :-
	optRangeform(_a,'TRUE'),
	!,
	optimizeAndlist(_as,_nas).

optimizeAndlist([_a|_as],[_na|_nas]) :-
	optRangeform(_a,_na),
	!,
	optimizeAndlist(_as,_nas).

optimizeOrlist([],[]).

optimizeOrlist(['FALSE'|_as],_nas) :-
    !,
	optimizeOrlist(_as,_nas).

optimizeOrlist([_a|_as],_nas) :-
	optRangeform(_a,'FALSE'),
	!,
	optimizeOrlist(_as,_nas).

optimizeOrlist([_a|_as],[_na|_nas]) :-
	optRangeform(_a,_na),
	!,
	optimizeOrlist(_as,_nas).



/** A formula like
     forall x/C In(String,Proposition) ==> exists y/String (x related y)
  can be optimized to
     forall x/C exists y/String (x related y)
  because the existence of String (In(String,Proposition)) is
  guaranteed by the subformula exists y/String (x related y).
  This optimization rule takes care of simplifying certain formulas
  generated from meta formula, e.g. for 'necessary' attributes.
  The optimization is also applicable for the dual case:
     exists x/C In(String,Proposition) and forall y/String (x related y)
  can be optimized to
     exists x/C forall y/String (x related y)
  We may want to traverse the sub-formula tree to detect all patterns like
  this. But we keep that for the future, i.e. when formuals requiring such
  optimizations are popping up.
**/

optimizeRangeByCrosscheck(_rangelits,_innerFormula,_optrangelits) :-
   (
   _innerFormula=exists(_v1,_innerrangelits,_);
   _innerFormula=forall(_v1,_innerrangelits,_)
   ),
   crossCheckRangeLits(_rangelits,_innerrangelits,_optrangelits),
   !.
optimizeRangeByCrosscheck(_rangelits,_,_rangelits).

crossCheckRangeLits([],_,[]) :- 
   !.

crossCheckRangeLits(['In'(_x,_Proposition)|_rest],_innerrangelits,_optrangelits) :-
  'VarTabConstant'(_x),
  'VarTabConstant'(_Proposition),
  name2id('Proposition',_Proposition),
  show('In'(_y,_x),_innerrangelits),
  crossCheckRangeLits(_rest,_innerrangelits,_optrangelits).

crossCheckRangeLits([_lit|_rest],_innerrangelits,[_lit|_optrangelits]) :-
  crossCheckRangeLits(_rest,_innerrangelits,_optrangelits).


/*************************************************************/
/** optimizeRangeByElimination(_rangelits,_newrangelits)    **/
/**                                                         **/
/** Unnecessary literals of _lits are eliminated in _dlits. **/
/** The term "unnecessary" is defined as follows:           **/
/** _lit "unnecessary" iff                                  **/
/**       and(_lits\_lit)  equiv.  and(_lits)               **/
/**                                                         **/
/** We do not claim that we eliminate all of them.          **/
/*************************************************************/

optimizeRangeByElimination(_rangelits,_newrangelits) :-
  do_optimizeRangeByElimination(_rangelits,_rangelits,[],_newrangelits).


/*************************************************************************************/
/** do_optimizeRangeByElimination(_todo,_allrangelits,_sofar,_newrangelits)
 *   _todo: list of range literals that still have to be optimized via elimination
 *   _allrangelits: original range lits
 *   _sofar: list of currently optimized range lits (i.e. those who are not eliminated)
 *   _newrangelits: the result of the optimization, i.e. the new list of range literals
 **/
/*************************************************************************************/


/** all investigated:*/
do_optimizeRangeByElimination([],_allrangelits,_sofar,_sofar) :- !.

/** a literal _lit can be eliminated: **/
do_optimizeRangeByElimination([_lit|_rest_todo],_allrangelits,_sofar,_newrangelits) :-
  showAlreadyGuaranteed(_lit,_allrangelits),
  !,
  do_optimizeRangeByElimination(_rest_todo,_allrangelits,_sofar,_newrangelits).

/** the literal occurs as a duplicate **/

do_optimizeRangeByElimination([_lit|_rest_todo],_allrangelits,_sofar,_newrangelits) :-
  pc_member(_lit,_rest_todo),
  !,
  'WriteTrace'(veryhigh,'SemanticOptimizer',[_lit,' occurs twice in rangeform. ']),
  do_optimizeRangeByElimination(_rest_todo,_allrangelits,_sofar,_newrangelits).

/** the literal _lit cannot be eliminated:*/
do_optimizeRangeByElimination([_lit|_rest_todo],_allrangelits,_sofar,_newrangelits) :-
  append(_sofar,[_lit],_sofarnew),
  !,
  do_optimizeRangeByElimination(_rest_todo,_allrangelits,_sofarnew,_newrangelits).


/**
 * showAlreadyGuaranteed is a little theorem prover. It proves that the first
 * argument _lit is a logical consequence of the conjunction _rangelits and
 * the object base (class definitions only).
 *
*/

/** These literals are accessing stored objects and are those binding variables **/
/** upon success.                                                               **/
isBinding('Label'(_,_)).
isBinding('From'(_,_)).
isBinding('To'(_,_)).
isBinding('P'(_,_,_,_)).
isBinding('A'(_,_,_)).
isBinding('Ai'(_,_,_)).
isBinding('In'(_,_)).
isBinding('In_e'(_,_)).
isBinding('In_s'(_,_)).
isBinding('In_i'(_,_)).
isBinding('In_o'(_,_)).
isBinding('Isa'(_,_)).
isBinding('Isa_e'(_,_)).
isBinding('A_label'(_,_,_,_)).
isBinding('Ae_label'(_,_,_,_)). /* #330 */
isBinding('Adot'(_,_,_)).  /* #195 */
isBinding('Adot'(_,_,_,_)).
isBinding('Aidot'(_,_,_)).
isBinding('Adot_label'(_,_,_,_)).  /* #195 */
isBinding('Aedot_label'(_,_,_,_)).  /* #330 */
isBinding('A_e'(_,_,_)).
isBinding('Aedot'(_,_,_)). /* #195 */


/** oLevel controls whether a specific showAlreadyGuaranteed clause is applicable or not. **/
/** In oLevel=0, only very few rules are applicable. It is used to remove at least some   **/
/** redundant literals from formulas generated from meta formula when the readable        **/
/** formula text is generated. In that context, we may not remove In(x,c) when x is a     **/
/** a variable. In oLevel=1, essentially all optimization rules are applicable.           **/

oLevel(_n) :-
  getFlag(optimizeLevel,_m),
  _m >= _n.


/*22-Jan-2004/M.Jeusfeld*/
/*26-Jan-2004/M.Jeusfeld*/
/** R1 **/
showAlreadyGuaranteed('In'(_x,'VAR'),_rangelits) :-
  oLevel(1),
  'VarTabVariable'(_x),
  show(_lit,_rangelits),
  isBinding(_lit),
  _lit =.. [_functor|_args],
  pc_member(_x,_args),
  'WriteTrace'(veryhigh,'SemanticOptimizer',['In'(_x,'VAR'),' guaranteed by ', _lit, ' [R1]']),
  !.

/** R2 **/
showAlreadyGuaranteed('In'(_x,_c),_rangelits) :-
  oLevel(1),
  'VarTabConstant'(_c),
  show('Adot'(_cc,_x,_y),_rangelits),
  retrieve_proposition('P'(_cc,_c,_l,_d)),
  'WriteTrace'(veryhigh,'SemanticOptimizer',['In'(_x,_c),' guaranteed by ','Adot'(_cc,_x,_y), ' [R2]']),
  !.

/** R2a **/
showAlreadyGuaranteed('In'(_x,_c),_rangelits) :-
  oLevel(1),
  'VarTabConstant'(_c),
  show('Aidot'(_cc,_x,_a),_rangelits),
  retrieve_proposition('P'(_cc,_c,_l,_d)),
  'WriteTrace'(veryhigh,'SemanticOptimizer',['In'(_x,_c),' guaranteed by ','Aidot'(_cc,_x,_a), ' [R2a]']),
  !.

/** R2b **/
showAlreadyGuaranteed('In'(_a,_cc),_rangelits) :-
  oLevel(1),
  'VarTabConstant'(_c),
  show('Aidot'(_cc,_x,_a),_rangelits),
  retrieve_proposition('P'(_cc,_c,_l,_d)),
  'WriteTrace'(veryhigh,'SemanticOptimizer',['In'(_a,_cc),' guaranteed by ','Aidot'(_cc,_x,_a), ' [R2b]']),
  !.

/** R2c **/
showAlreadyGuaranteed('In'(_x,_c),_rangelits) :-
  oLevel(1),
  'VarTabConstant'(_c),
  show('Aedot'(_cc,_x,_y),_rangelits),
  retrieve_proposition('P'(_cc,_c,_l,_d)),
  'WriteTrace'(veryhigh,'SemanticOptimizer',['In'(_x,_c),' guaranteed by ','Aedot'(_cc,_x,_y), ' [R2c]']),
  !.


/** R3 **/
showAlreadyGuaranteed('In'(_x,_c),_rangelits) :-
  oLevel(1),
  'VarTabConstant'(_c),
  _alit = ('Adot_label'(_cc,_x,_y,_l);'Aedot_label'(_cc,_x,_y,_l)),
  show(_alit,_rangelits),
  retrieve_proposition('P'(_cc,_c,_m,_d)),
  'WriteTrace'(veryhigh,'SemanticOptimizer',['In'(_x,_c),' guaranteed by ',_alit, ' [R3]']),
  !.

/** R4 **/
showAlreadyGuaranteed('In'(_y,_d),_rangelits) :-
  oLevel(1),
  'VarTabConstant'(_d),
  show('Adot'(_cc,_x,_y),_rangelits),
  retrieve_proposition('P'(_cc,_c,_l,_d)),
  'WriteTrace'(veryhigh,'SemanticOptimizer',['In'(_y,_d),' guaranteed by ','Adot'(_cc,_x,_y), ' [R4]']),
  !.

/** R4a **/
showAlreadyGuaranteed('In'(_y,_d),_rangelits) :-
  oLevel(1),
  'VarTabConstant'(_d),
  show('Aedot'(_cc,_x,_y),_rangelits),
  retrieve_proposition('P'(_cc,_c,_l,_d)),
  'WriteTrace'(veryhigh,'SemanticOptimizer',['In'(_y,_d),' guaranteed by ','Aedot'(_cc,_x,_y), ' [R4a]']),
  !.



/** R5 **/
showAlreadyGuaranteed('In'(_y,_d),_rangelits) :-
  oLevel(1),
  'VarTabConstant'(_d),
  _alit = ('Adot_label'(_cc,_x,_y,_l);'Aedot_label'(_cc,_x,_y,_l)),
  show(_alit,_rangelits),
  retrieve_proposition('P'(_cc,_c,_m,_d)),
  'WriteTrace'(veryhigh,'SemanticOptimizer',['In'(_y,_d),' guaranteed by ',_alit, ' [R5]']),
  !.

/** ticket #142: two more clauses to eliminate predicates like (x in Integer) from **/
/** conjunctions like "(x in Integer) and (x=IPLUS[...])".                         **/
/** The instantiation of x to the class (Integer) is guaranteed by the type of     **/
/** the functional expression in the EQ predicate.                                 **/

/** R6 **/
showAlreadyGuaranteed('In'(_x,_c),_rangelits) :-
  oLevel(1),
  'VarTabConstant'(_c),
  show('EQ'(_x,_expr),_rangelits),
  isFunctionLit(_expr,_fun),
  prove_literal('Isa_e'(_fun,_c)),
  'WriteTrace'(veryhigh,'SemanticOptimizer',['In'(_x,_c),' guaranteed by ','EQ'(_x,_expr), ' [R6]']),
  !.

/** R7 **/
showAlreadyGuaranteed('In'(_x,_c),_rangelits) :-
  oLevel(1),
  'VarTabConstant'(_c),
  show('EQ'(_expr,_x),_rangelits),
  isFunctionLit(_expr,_fun),
  prove_literal('Isa_e'(_fun,_c)),
  'WriteTrace'(veryhigh,'SemanticOptimizer',['In'(_x,_c),' guaranteed by ','EQ'(_expr,_x),' [R7]']),
  !.





/** The subsequent optimizations are for the 'weak' predicates forms A,Ai, etc (i.e. not
 * 'dotted'. For them, the so-called concerned class (which is part of the dotted versions)
 * is computed on the fly. It is correct as long as the assumption below is true.
 * An occurence of In(_x,_c) is already guaranteed if there is an occurence of A(_x,_l,_y)
 * within the same conjunction that refers to an attribute category with _x as source component.
 * IMPORTANT: This is only valid if assumption 2 ([MIP-9013],p.18) is fulfilled!
 * See also axiom 9 of the O-Telos-Axioms in
 * http://SunSITE.Informatik.RWTH-Aachen.DE/bscw/bscw.cgi/d206308/O-Telos-Axioms.ps
**/

/** R8 **/
showAlreadyGuaranteed('In'(_x,_c),_rangelits) :-
  oLevel(1),
  'VarTabConstant'(_c),
  show('A'(_x,_l,_y),_rangelits),
  'ConcernedClass'('A'(_x,_l,_y),_class),
  retrieve_proposition('P'(_class,_c,_l,_d)),
  'WriteTrace'(veryhigh,'SemanticOptimizer',['In'(_x,_c),' guaranteed by ','A'(_x,_l,_y),' [R8]']),
  !.

/** R8a **/
showAlreadyGuaranteed('In'(_x,_c),_rangelits) :-
  oLevel(1),
  'VarTabConstant'(_c),
  show('A_e'(_x,_l,_y),_rangelits),
  'ConcernedClass'('A_e'(_x,_l,_y),_class),
  retrieve_proposition('P'(_class,_c,_l,_d)),
  'WriteTrace'(veryhigh,'SemanticOptimizer',['In'(_x,_c),' guaranteed by ','A_e'(_x,_l,_y),' [R8a]']),
  !.


/** R9 **/
showAlreadyGuaranteed('In'(_x,_c),_rangelits) :-
  oLevel(1),
  'VarTabConstant'(_c),
  _alit = ('A_label'(_x,_l,_y,_);'Ae_label'(_x,_l,_y,_)),
  show(_alit,_rangelits),
  'ConcernedClass'('A'(_x,_l,_y),_class),
  retrieve_proposition('P'(_class,_c,_l,_d)),
  'WriteTrace'(veryhigh,'SemanticOptimizer',['In'(_x,_c),' guaranteed by ',_alit,' [R9]']),
  !.

/** R10 **/
showAlreadyGuaranteed('In'(_y,_d),_rangelits) :-
  oLevel(1),
  'VarTabConstant'(_d),
  show('A'(_x,_l,_y),_rangelits),
  'ConcernedClass'('A'(_x,_l,_y),_class),
  retrieve_proposition('P'(_class,_c,_l,_d)),
  'WriteTrace'(veryhigh,'SemanticOptimizer',['In'(_y,_d),' guaranteed by ','A'(_x,_l,_y),' [R10]']),
  !.

/** R10a **/
showAlreadyGuaranteed('In'(_y,_d),_rangelits) :-
  oLevel(1),
  'VarTabConstant'(_d),
  show('A_e'(_x,_l,_y),_rangelits),
  'ConcernedClass'('A_e'(_x,_l,_y),_class),
  retrieve_proposition('P'(_class,_c,_l,_d)),
  'WriteTrace'(veryhigh,'SemanticOptimizer',['In'(_y,_d),' guaranteed by ','A_e'(_x,_l,_y),' [R10a]']),
  !.


/** R11 **/
showAlreadyGuaranteed('In'(_y,_d),_rangelits) :-
  oLevel(1),
  'VarTabConstant'(_d),
  _alit = ('A_label'(_x,_l,_y,_);'Ae_label'(_x,_l,_y,_)),
  show(_alit,_rangelits),
  'ConcernedClass'('A'(_x,_l,_y),_class),
  retrieve_proposition('P'(_class,_c,_l,_d)),
  'WriteTrace'(veryhigh,'SemanticOptimizer',['In'(_y,_d),' guaranteed by ',_alit,' [R11]']),
  !.

/** R12 **/
showAlreadyGuaranteed('In'(_x,_c),_rangelits) :-
  oLevel(1),
  'VarTabConstant'(_c),
  show('Ai'(_x,_l,_id),_rangelits),
  'ConcernedClass'('Ai'(_x,_l,_id),_class),
  retrieve_proposition('P'(_class,_c,_l,_d)),
  'WriteTrace'(veryhigh,'SemanticOptimizer',['In'(_x,_c),' guaranteed by ','Ai'(_x,_l,_id),' [R12]']),
  !.

/** R13 **/
showAlreadyGuaranteed('In'(_id,_attrid),_rangelits) :-
  oLevel(1),
  'VarTabConstant'(_attrid),
  name2id('Attribute',_attrid),
  show('Ai'(_x,_l,_id),_rangelits),   /** added 6-Oct-2003/M.Jeusfeld **/
  'WriteTrace'(veryhigh,'SemanticOptimizer',['In'(_id,'Attribute'),' guaranteed by ','Ai'(_x,_l,_id),' [R13]']),
  !.

/** R13a **/
showAlreadyGuaranteed('In'(_id,_attrid),_rangelits) :-
  oLevel(1),
  'VarTabConstant'(_attrid),
  name2id('Attribute',_attrid),
  show('Aidot'(_cc,_x,_id),_rangelits),  
  'WriteTrace'(veryhigh,'SemanticOptimizer',['In'(_id,'Attribute'),' guaranteed by ','Aidot'(_cc,_x,_id),' [R13a]']),
  !.


/** R14 **/
showAlreadyGuaranteed('In'(_id,_class),_rangelits) :-
  oLevel(1),
  'VarTabConstant'(_class),
  show('Ai'(_x,_l,_id),_rangelits),
  'ConcernedClass'('Ai'(_x,_l,_id),_class),
  'WriteTrace'(veryhigh,'SemanticOptimizer',['In'(_id,_class),' guaranteed by ','Ai'(_x,_l,_id),' [R14]']),
  !.

/** R15 **/
showAlreadyGuaranteed('In'(_x,_propid),_rangelits) :-
  oLevel(0),
  'VarTabConstant'(_x),
  id2name(_propid,_n),_n == 'Proposition',
  show(_lit,_rangelits),
  _lit \= 'In'(_x,_propid),
     (
       (
         _lit =.. [_name|_args],
        (_name='In';_name='A';_name='Ai';_name='Isa';_name='Adot';_name='Adot_label';_name='Aidot'; _name='A_e'; _name='Aedot';
        _name='A_label';_name='Ae_label';_name='Aedot_label';_name='UNIFIES';_name='In2';_name='A2'),
        referencedByArgs(_x,_args)
       );
       _lit = 'To'(_a,_x);
       _lit = 'From'(_a,_x)
     ),
  (id2name(_x,_xn);_x=_xn),
  'WriteTrace'(veryhigh,'SemanticOptimizer',['In'(_x,'Proposition'),' guaranteed by ',_lit,
                                        ' (',_x,'=',_xn,')',' [R15]']),
  !.


/** R16 **/
showAlreadyGuaranteed('In'(_x,_propid),_rangelits) :-
  oLevel(0),
  'VarTabVariable'(_x),
  id2name(_propid,_n),_n == 'Proposition',
  show('In'(_x,_c),_rangelits),
  _c \== _propid,
  id2name(_c,_cn),
  'WriteTrace'(veryhigh,'SemanticOptimizer',['In'(_x,'Proposition'),' guaranteed by ','In'(_x,_c),' (',_c,'=',_cn,')',' [R16]']),
  !.

/** R17 **/
showAlreadyGuaranteed('In'(_x,_propid),_rangelits) :-
  oLevel(1),
  id2name(_propid,_n),_n == 'Proposition',
  show(_lit,_rangelits),
  _lit \= 'In'(_x,_propid),
     (
       (
         _lit =.. [_name|_args],
        (_name='In';_name='A';_name='Ai';_name='Isa';_name='Adot';_name='Adot_label';_name='Aidot'; _name='A_e'; _name='Aedot';
        _name='A_label';_name='Ae_label';_name='Aedot_label';_name='UNIFIES'; _name='EQ'; name='In2';_name='A2';_name='P';_name='Pa'),
        pc_member(_x,_args)
       );
       _lit = 'To'(_a,_x);
       _lit = 'From'(_a,_x)
     ),
  (id2name(_x,_xn);_x=_xn),
  'WriteTrace'(veryhigh,'SemanticOptimizer',['In'(_x,'Proposition'),' guaranteed by ',_lit,
                                        ' (',_x,'=',_xn,')',' [R17]']),
  !.


/** R17a **/ /** Rule for eliminating instatiations to Attribute when Pa -lietarl is used **/
showAlreadyGuaranteed('In'(_a,id_6),_rangelits) :- /** id_6=Attribute **/
  oLevel(1),
  'VarTabVariable'(_a),
  show('Pa'(_a,_x,_n,_y),_rangelits),
  'WriteTrace'(veryhigh,'SemanticOptimizer',['In'(_a,'Attribute'),' guaranteed by ','Pa'(_a,_x,_n,_y),' [R17a]']),
  !.



/** 9-Dec-2003/M.Jeusfeld:                                                               **/
/**    case 1: remove some In(a,Attribute) when a occurs in Adot(a,....)                 **/
/**    case 2: remove In(a,Attribute) when a P(a,x,m,y) is stored as an attribute        **/
/** The two subsequent rules make certain meta-level formulas like isTransitiveClosureOf **/
/** more than twice as fast than without the elimination induced by the two rules.       **/
/** In fact, with these two rules such meta-level formulas are compiled to the same      **/
/** representations as if one had coded the formals at the class level (rather than meta **/
/** class level).                                                                        **/

/** R18 **/
showAlreadyGuaranteed('In'(_a,_propid),_rangelits) :-
  oLevel(1),
  'VarTabConstant'(_a),
  'VarTabConstant'(_propid),
  name2id('Attribute',_propid),
  show('Adot'(_a,_x,_y),_rangelits),
  'WriteTrace'(veryhigh,'SemanticOptimizer',['In'(_a,'Attribute'),' guaranteed by ','Adot'(_a,_x,_y),' [R18]']),
  !.

/** R18a **/
showAlreadyGuaranteed('In'(_a,_propid),_rangelits) :-
  oLevel(1),
  'VarTabConstant'(_a),
  'VarTabConstant'(_propid),
  name2id('Attribute',_propid),
  show('Aedot'(_a,_x,_y),_rangelits),
  'WriteTrace'(veryhigh,'SemanticOptimizer',['In'(_a,'Attribute'),' guaranteed by ','Aedot'(_a,_x,_y),' [R18a]']),
  !.


/** R19 **/
showAlreadyGuaranteed('In'(_a,_propid),_rangelits) :-
  oLevel(0),
  'VarTabConstant'(_a),
  'VarTabConstant'(_propid),
  is_id(_a),
  name2id('Attribute',_propid),
  retrieve_proposition('P'(_a,_x,_m,_y)),
  attribute('P'(_a,_x,_m,_y)),
  'WriteTrace'(veryhigh,'SemanticOptimizer',['In'(_a,'Attribute'),' guaranteed by existing object ','P'(_a,_x,_m,_y),' [R19]']),
  !.

/** R20 **/
showAlreadyGuaranteed('In'(_x,_ttid),_rangelits) :-
  oLevel(1),
  id2name(_ttid,_n),
  (_n == 'TransactionTime'; _n == 'Label'),
  'WriteTrace'(veryhigh,'SemanticOptimizer',['In'(_x,_ttid),' guaranteed by ', 'anything',' [R20]']),
  !.

/** R21 **/
showAlreadyGuaranteed('In'(_x,_T),_rangelits) :-
  oLevel(1),
  'VarTabConstant'(_T),   /** T must be an object name; ticket #185 **/
  show(_lit,_rangelits),
  _lit =.. [_fid,_x|_args],       /** a function call with result x **/
  sharpestResultType(_lit,_T1),   /** the result x must be an instace of T1 **/
  prove_literal('Isa'(_T1,_T)),     /** T1 is a subclass of (or equal to) T **/
  'WriteTrace'(veryhigh,'SemanticOptimizer',['In'(_x,_T),' guaranteed by ',_lit,' [R21]']),
  !.

/** EQ(_x,F(_,args)) is treated like F(x,args), i.e. like case R21 **/
/** The expression F(_,args) is a function call like IPLUS.        **/
/** Functions have known result types.  See also ticket #172.      **/

/** R21a **/
showAlreadyGuaranteed('In'(_x,_T),_rangelits) :-
  oLevel(1),
  'VarTabConstant'(_T),   /** T must be an object name; ticket #185 **/
  (show('EQ'(_x,_qlit),_rangelits);
   show('EQ'(_qlit,_x),_rangelits)),
  sharpestResultType(_qlit,_T1),   /** on succeeds if qlit is a function call! **/
  prove_literal('Isa'(_T1,_T)),
  'WriteTrace'(veryhigh,'SemanticOptimizer',['In'(_x,_T),' guaranteed by ','EQ'(_x,_qlit),' [R21a]']),
  !.




/** 30-Oct-2001/MJf: Meta formulas are generated for solutions of so-called        **/
/** E-Predicates by means of partial evaluation (see MetaSimplifier.pro,           **/
/** AssertionTransformer.pro). When a formula is generated for a ground fact for   **/
/** such an E-Predicate, then we can assume this E-Pred to be true for the whole   **/
/** lifespan of the formula. Hence, we use it for optimization. Below is the case  **/
/** when In(x,c) is guaranteed by an E-Pred A(x,l,y).                              **/

/** Example:
*
*   Class EntityType with
*     attribute
*       superType: EntityType
*     rule
*       membershipRule: $ forall e/VAR E/EntityType
*                          (exists D/EntityType (e in D) and (D superType E)) ==> (e in E) $
*   end
*
* Here, the E-Predicate is A(D,superType,E). Assume the following definitions:
*
*    EntityType Staff with
*    end
*
*    EntityType Technician with
*      superType
*         s1: Staff
*    end
*
* This makes the fact A(Technician,superType,Staff) true and leads to the generation of the
* partially evaluated formula
*
*  $ forall e In(e,Technician) and In(Staff,EntityType) and In(Technician,EntityType) ==> In(e,Staff) $
*
* Here, the two predicates In(Staff,EntityType) and In(Technician,EntityType) are redundant
* since the generated formula depends on the truth of A(Technician,superType,Staff) which
* itself guarantees In(Staff,EntityType) and In(Technician,EntityType).
*
**/

/** R22 **/
showAlreadyGuaranteed('In'(_x,_c),_rangelits) :-
  oLevel(0),
  'VarTabConstant'(_x),
  'VarTabConstant'(_c),
  expanded_ePreds(_epreds),
  (show('A'(_x,_l,_y),_epreds);show('A_label'(_x,_l,_y,_n),_epreds);show('Ae_label'(_x,_l,_y,_n),_epreds);show('A_e'(_x,_l,_y),_epreds)),
  'ConcernedClass'('A'(_x,_l,_y),_class),
  retrieve_proposition('P'(_class,_c,_l,_d)),
  id2name(_x,_xn),
  id2name(_c,_cn),
  'WriteTrace'(veryhigh,'SemanticOptimizer',['In'(_xn,_cn),' fulfilled by the E-Predicates ', _epreds,' [R22]']),
  !.

/** R23 **/
showAlreadyGuaranteed('In'(_x,_c),_rangelits) :-
  oLevel(0),
  'VarTabConstant'(_x),
  'VarTabConstant'(_c),
  expanded_ePreds(_epreds),
  (show('A'(_y,_l,_x),_epreds);show('A_label'(_y,_l,_x,_n),_epreds);show('Ae_label'(_x,_l,_y,_n),_epreds);show('A_e'(_x,_l,_y),_epreds)),
  'ConcernedClass'('A'(_y,_l,_x),_class),
  retrieve_proposition('P'(_class,_d,_l,_c)),
  id2name(_x,_xn),
  id2name(_c,_cn),
  'WriteTrace'(veryhigh,'SemanticOptimizer',['In'(_xn,_cn),' fulfilled by the E-Predicates ', _epreds,' [R23]']),
  !.



/** 8-Nov-2002/M.Jeusfeld: Include new case for combinations In(x,c) and qc(x,...) where   **/
/** c is one of the builtin classes Integer,Real,String and qc is a query class which has  **/
/*  c is superclass (i.e. result type). Removal of such literals In(x,c) is essential when **/
/** the value for _x is actually computed within qc, e.g. by some function like MULT.      **/
/** In such cases, we cannot prove In(x,c) from the database but we know that x is in      **/
/** essentially a vlaue of c, i.e. a real, integer, or string.                             **/
/** Yes, this is a hack but the treatment of classes like Real,Integer,String is anyway    **/
/** special in ConceptBase. We want them to behave mostly like ordinary classes but at the **/
/** same time we want to do some on-the-fly computations.                                  **/
/** Formally, we can generalize the rule below to remove any such In(x,c) regardless       **/
/** whether c is a builtin class or not. However, I don't oversee all consequences at the  **/
/** moment. The generalization would 'only' speed up the performance while the treatment   **/
/** for builtin classes actually is needed for correct computation.                        **/
/** 11-Nov-2002/M.Jeusfeld: Now, this rule is generalized to use any query predicate       **/
/** occurring in _rangelits to remove In(x,c). Note that the query class _qc may have      **/
/** a subclass of _c as result type. This still allows to remove In(x,c) via inheritance.  **/
/** 12-Nov-2002/M.Jeusfeld: Use In_e to derive instantiation to QueryClass; In_e is more   **/
/** efficient since it does not consider user-defined rules (which are not allowed to      **/
/** derive instantiation to QueryClass anyway).                                            **/
/** 7-Oct-2003/M.Jeusfeld: Now we restrict again to BuiltinQueryClasses. The optimization  **/
/** from 11-Nov-2003 has rendered the query BillsMetaBoss from examples/QUERIES to deliver **/
/** an incomplete answer. The literal In(m,Manager) is optimized away. Though this is      **/
/** logically correct, the incremental evaluation of BillsMetaBoss in Literals.pro appears **/
/** to need this literal as a generator. A more sound solution to the problem would be to  **/
/** analyze the magic cache evaluator in Literals.pro but we leave this for later.         **/
/** 20-Nov-2003/M.Jeusfeld: Extended scope of this rule to cover also Function, not just   **/
/** BuiltinQueryClass. Added two more cases in order to eliminate In(x,Real) and           **/
/** In(x,Integer) whenever possible. Without this, we can hardly define queries that       **/
/** compute numbers by possibly calling other queries like MULT.                           **/

/** CASE 1 **/
/** R24 **/
showAlreadyGuaranteed('In'(_x,_c),_rangelits) :-
  oLevel(1),
  'VarTabConstant'(_c),
  show(_query_call,_rangelits),
  _query_call =..[_qc|[_x|_restargs]],         /** qc(_x,....) **/
  is_id(_qc),   /** pc_atomconcat('id_',_,_qc), **/     /** _qc is indeed an object id **/
  isFunctionOrBuiltinQueryClass(_qc),
  retrieve_proposition('P'(_,_qc,'*isa',_d)),             /** and has _d as result type **/
  prove_literal('Isa'(_d,_c)),                            /** and d is equal to c or a subclass **/
  id2name(_c,_cn),
  id2name(_qc,_qcn),
  'WriteTrace'(veryhigh,'SemanticOptimizer',['In'(_x,_cn),' guaranteed by call of call of query ',_qcn,' [R24]']),
  !.

/** CASE 2 **/ /** 2nd case: Instead qc(x,....) we have In(x,qc) **/
/** R25 **/
showAlreadyGuaranteed('In'(_x,_c),_rangelits) :-
  oLevel(1),
  'VarTabConstant'(_c),
  show('In'(_x,_qc),_rangelits),                           /** similar as above but just an In predicate **/
  'VarTabConstant'(_qc),
  isFunctionOrBuiltinQueryClass(_qc),
  retrieve_proposition('P'(_,_qc,'*isa',_d)),             /** and has _d as result type **/
  prove_literal('Isa'(_d,_c)),                            /** and d is equal to c or a subclass **/
  id2name(_c,_cn),
  id2name(_qc,_qcn),
  'WriteTrace'(veryhigh,'SemanticOptimizer',['In'(_x,_cn),' guaranteed by query predicate ','In'(_x,_qcn),' [R25]']),
  !.

/** CASE 3a: In(_x,_c) guaranteed by qc(_x,...) with (qc isA _c) **/
/** R26 **/
showAlreadyGuaranteed('In'(_x,_c),_rangelits) :-
  oLevel(1),
  'VarTabConstant'(_c),
  'IntegerOrReal'(_c),                           /** Hence, In(x,Real) or In(x,Integer) is subject to removal **/
  show(_query_call,_rangelits),
  _query_call =..[_qc|[_x|_restargs]],         /** qc(_x,....) **/
  is_id(_qc),   /** pc_atomconcat('id_',_,_qc), **/     /** _qc is indeed an object id **/
  isGenericQueryClass(_qc),
  retrieve_proposition('P'(_,_qc,'*isa',_d)),             /** and has _d as result type **/
  prove_literal('Isa'(_d,_c)),                            /** and d is equal to c or a subclass **/
  id2name(_c,_cn),
  id2name(_qc,_qcn),
  'WriteTrace'(veryhigh,'SemanticOptimizer',['In'(_x,_cn),' guaranteed by call of call of query ',_qcn,' [R26]']),
  !.

/** CASE 3b: In(_x,_c) guaranteed by In(_x,_qc) with (qc isA _c) **/
/** R27 **/
showAlreadyGuaranteed('In'(_x,_c),_rangelits) :-
  oLevel(1),
  'VarTabConstant'(_c),
  'IntegerOrReal'(_c),
  show('In'(_x,_qc),_rangelits),                           /** similar as above but just an In predicate **/
  'VarTabConstant'(_qc),
  isGenericQueryClass(_qc),
  retrieve_proposition('P'(_,_qc,'*isa',_d)),             /** and has _d as result type **/
  prove_literal('Isa'(_d,_c)),                            /** and d is equal to c or a subclass **/
  id2name(_c,_cn),
  id2name(_qc,_qcn),
  'WriteTrace'(veryhigh,'SemanticOptimizer',['In'(_x,_cn),' guaranteed by query predicate ','In'(_x,_qcn),' [R27]']),
  !.



/** new cases from 'From'/'To' literals:*/
/**
 * If From(_a,_x) is part of a conjuntion and also In(_a,_ca) and P(_ca,_c,_m,_d)
 * is true is the object base, then the predicate In(_x,_c) is a logical consequence.
 * Hence, it can be omitted from the conjunction.
 * Analogous case holds for the To(_a,_y) literal.
**/

/** R28 **/
showAlreadyGuaranteed('In'(_x,_c),_rangelits) :-
  oLevel(1),
  'VarTabConstant'(_c),
  show('From'(_a,_x),_rangelits),
  show('In'(_a,_ca),_rangelits),
  is_id(_ca),
  retrieve_proposition('P'(_ca,_c,_m,_d)),
  'WriteTrace'(veryhigh,'SemanticOptimizer',['In'(_x,_c),' guaranteed by ','From'(_a,_x),' [R28]']),
  !.

/** R29 **/
showAlreadyGuaranteed('In'(_y,_d),_rangelits) :-
  oLevel(1),
  'VarTabConstant'(_d),
  show('To'(_a,_y),_rangelits),
  show('In'(_a,_ca),_rangelits),
  is_id(_ca),
  retrieve_proposition('P'(_ca,_c,_m,_d)),
  'WriteTrace'(veryhigh,'SemanticOptimizer',['In'(_y,_d),' guaranteed by ','To'(_a,_y),' [R29]']),
  !.







/** 11-May-2006/M.Jeusfeld: transaction times are (temporarily) instantiated to **/
/** String by the implementation of Known in Literals.pro. Thus we can remove   **/
/** The predicate In(t,String) from a conjunction [Known(x,t),In(t,String)].    **/

/** R30 **/
showAlreadyGuaranteed('In'(_t,_S),_rangelits) :-
  oLevel(1),
  is_id(_S),
  id2name(_S,'String'),
  show('Known'(_x,_t),_rangelits),
  'WriteTrace'(veryhigh,'SemanticOptimizer',[idterm('In'(_t,_S)),' guaranteed by ',idterm('Known'(_x,_t)),' [R30]']),
  !.

/** R31 **/
showAlreadyGuaranteed('TRUE',_rangelits) :- !.


/** R32: certain ground predicates can be removed if they are true **/
showAlreadyGuaranteed('From'(_a,_x),_rangelits) :- 
  is_id(_a),
  is_id(_x),
  prove_literal('From'(_a,_x)),
  'WriteTrace'(veryhigh,'SemanticOptimizer',[idterm('From'(_a,_x)),' is redundant in the formula [R32]']),
  !.

showAlreadyGuaranteed('To'(_a,_x),_rangelits) :- 
  is_id(_a),
  is_id(_x),
  prove_literal('To'(_a,_x)),
  'WriteTrace'(veryhigh,'SemanticOptimizer',[idterm('To'(_a,_x)),' is redundant in the formula [R32]']),
  !.

showAlreadyGuaranteed('Label'(_a,_l),_rangelits) :- 
  is_id(_a),
  'VarTabConstant'(_l),
  prove_literal('Label'(_a,_l)),
  'WriteTrace'(veryhigh,'SemanticOptimizer',[idterm('Label'(_a,_l)),' is redundant in the formula [R32]']),
  !.

showAlreadyGuaranteed('P'(_a,_x,_l,_y),_rangelits) :- 
  is_id(_a),
  is_id(_x),
  'VarTabConstant'(_l),
  is_id(_y),
  prove_literal('P'(_a,_x,_l,_y)),
  'WriteTrace'(veryhigh,'SemanticOptimizer',[idterm('P'(_a,_x,_l,_y)),' is redundant in the formula [R32]']),
  !.

/** R33: if (x=y) and In(y,c) is true, then also In(x,c) **/

showAlreadyGuaranteed('In'(_x,_c),_rangelits) :-
  oLevel(1),
  is_id(_c),
  (show('EQ'(_x,_y),_rangelits);  show('EQ'(_y,_x),_rangelits)),
  show('In'(_y,_c),_rangelits),
  'WriteTrace'(veryhigh,'SemanticOptimizer',[idterm('In'(_x,_c)),' guaranteed by ',idterm('EQ'(_x,_y)),' [R33]']),
  !.

/** R34: if (x=val) and val has domain D, then In(x,D) is redundant **/

showAlreadyGuaranteed('In'(_x,_D),_rangelits) :-
  oLevel(1),
  is_id(_D),
  'VarTabVariable'(_x),
  (show('EQ'(_x,_val),_rangelits);show('EQ'(_val,_x),_rangelits)),
  isInDomain(_val,_D),
  'WriteTrace'(veryhigh,'SemanticOptimizer',[idterm('In'(_x,_D)),' guaranteed by ',idterm('EQ'(_x,_val)),' [R34]']),
  !.


isFunctionOrBuiltinQueryClass(_qc) :-
  is_id(_qc),
  name2id('BuiltinQueryClass',_QCid),
  prove_edb_literal('In_e'(_qc,_QCid)),    /** qc is an instance of BuiltinQueryClass **/
  !.

isFunctionOrBuiltinQueryClass(_qc) :-
  is_id(_qc),
  name2id('Function',_QCid),
  prove_edb_literal('In_e'(_qc,_QCid)),    /** qc is an instance of Function **/
  !.

isGenericQueryClass(_qc) :-
  is_id(_qc),
  name2id('GenericQueryClass',_QCid),
  prove_edb_literal('In_e'(_qc,_QCid)),    /** qc is an instance of Function **/
  !.

'IntegerOrReal'(_c) :-
   is_id(_c),
   id2name(_c,_cn),
   (_cn == 'Real'; _cn == 'Integer'),
   !.


/** 21c **/
/** sharpestResultType computes the sharpest result type of a function call **/
/** If the function call is MIN[c/class],MAX[c/class], then the sharpest    **/
/** result type is c.                                                       **/
/** If the function call is SUM[c/class], the sharpest result type is       **/
/** Integer, if c is a subclass of Integer, else it is the range of SUM,    **/
/** i.e. Real.                                                              **/
/** The cases for SUM_Attribute,MIM_Attribute,MAX_Attribute are analogous.  **/


sharpestResultType(_funcall,_T) :-
  _funcall =.. [_fid,_|_args],   /** note that the first arg of a function call is for the result **/
  name2id('Function',_funcid),
  prove_literal('In'(_fid,_funcid)),
  id2name(_fid,_funname),
  checkSharpestResultType(_fid,_funname,_args,_T).


checkSharpestResultType(_fid,'SUM',[_class,_],_IntegerId) :-
  name2id('Integer',_IntegerId),
  prove_literal('Isa'(_class,_IntegerId)),
  !.

checkSharpestResultType(_fid,'SUM_Attribute',[_cat,_,_obj,_],_IntegerId) :-
  name2id('Integer',_IntegerId),
  prove_literal('To'(_cat,_T)),
  prove_literal('Isa'(_T,_IntegerId)),
  !.

checkSharpestResultType(_fid,_FUN,[_class,_],_class) :-
  memberchk(_FUN,['MIN','MAX']),
  !.

checkSharpestResultType(_fid,_FUN,[_cat,_,_obj,_],_T) :-
  memberchk(_FUN,['MIN_Attribute','MAX_Attribute']),
  prove_literal('To'(_cat,_T)),
  !.

/** else: the sharpest result type is the range of the function fid **/
checkSharpestResultType(_fid,_,_,_T) :-
  prove_literal('Isa_e'(_fid,_T)),
  !.




  



/** show(_lit,_rangelits)
 * Show that _lit occurs in _rangelits
 **/

show(_toshow,[_given|_rest_given]) :-
  _toshow = _given.

show(_toshow,[_|_rest_given]) :-
  show(_toshow,_rest_given).




/*************************************************************/
/** optimizeByTrueAndFalse(_oldterm,_result)                **/
/**                                                         **/
/** Es hat sich gezeigt, dass bei der korrekten Behandlung  **/
/** von TRUE und FALSE folgende Spezialfaelle behandelt     **/
/** werden muessen:                                         **/
/** - eine And/Or-Liste wird nullelementig                  **/
/** - eine And/Or-Liste wird einelementig                   **/
/** - ein Unterterm einer And/Or-Liste wird TRUE            **/
/** - ein Unterterm einer And/Or-Liste wird FALSE           **/
/** - ein exists-Range wird zu [FALSE] und bestimmt damit   **/
/**   den Wert des gesamten Ausdrucks zu FALSE              **/
/** - ein forall-Range wird zu [FALSE] und bestimmt damit   **/
/**   den Wert des gesamten Ausdrucks zu TRUE               **/
/** - der Term, ueber den exists quantifiziert wird, wird   **/
/**   FALSE und bestimmt damit den Wert des gesamten        **/
/**   Ausdrucks zu FALSE                                    **/
/** - der Term, ueber den forall quantifiziert wird, wird   **/
/**   TRUE und bestimmt damit den Wert des gesamten         **/
/**   Ausdrucks zu TRUE                                     **/
/*************************************************************/

/** forall **/
optimizeByTrueAndFalse(forall(_,_,'TRUE'),'TRUE') :- !.

optimizeByTrueAndFalse(forall(_v,_range,_F),'TRUE') :-
	pc_member('FALSE',_range),
	!.

optimizeByTrueAndFalse(forall(_v,_range,_F),forall(_v,_range,_optF)) :-
	optimizeByTrueAndFalse(_F,_optF).

/** exists **/
optimizeByTrueAndFalse(exists(_,['FALSE'],_),'FALSE') :- !.

optimizeByTrueAndFalse(exists(_,_,'FALSE'),'FALSE') :- !.

optimizeByTrueAndFalse(exists(_v,_range,_F),'FALSE') :-
	pc_member('FALSE',_range).

optimizeByTrueAndFalse(exists(_v,_range,_F),exists(_v,_range,_optF)) :-
	optimizeByTrueAndFalse(_F,_optF).

/** TRUE Terme werden bereits bei optimizeAndlist beseitigt **/
optimizeByTrueAndFalse(and([]),'TRUE') :- !.

optimizeByTrueAndFalse(and([_t]),_t) :- !.


optimizeByTrueAndFalse(and(_andlist),'FALSE') :-
	pc_member('FALSE',_andlist),
	!.

/** FALSE Terme werden bereits bei optimizeOrlist beseitigt **/
optimizeByTrueAndFalse(or([]),'FALSE') :- !.

optimizeByTrueAndFalse(or([_t]),_t) :- !.

optimizeByTrueAndFalse(or(_orlist),'TRUE') :-
	pc_member('TRUE',_orlist),
	!.

optimizeByTrueAndFalse(_term,_term).


/** expanded_ePreds takes the ePredsTillNow and augments them by some
   direct consequences. This enables further optimizations like 
   eliminating (Domain in Proposition) from the formula generated
   by
      EntityType in Class with
        single
          key: Domain
      end
      Domain end
      Integer in Domain end
   using the meta formula
      $ forall c,d/Proposition p/Proposition!single x,m/VAR
               P(p,c,m,d) and (x in c) ==>
                (
                  forall a1,a2/VAR
                    (a1 in p) and (a2 in p) and Ai(x,m,a1) and Ai(x,m,a2) ==>
                   (a1=a2)
                ) 
       $
   Here, the variable d matches Domain. The E-predicate is just In(EntityType!key,Proposition!single).
   By augmenting this E-predicate by its direct consequence A(EntityType,single,Domain), we
   can conclude that In(Domain,Proposition) is indeed guaranteed by In(EntityType!key,Proposition!single).
**/

expanded_ePreds(_epreds) :-
  ePredsTillNow(_epreds0),
  expandThem(_epreds0,_epreds).

expandThem([],[]) :- !.

expandThem(['In'(_a,_p)|_rest],['In'(_a,_p),'A'(_c,_m,_d)|_nrest]) :-
  retrieve_proposition('P'(_a,_c,_n,_d)),
  attribute('P'(_a,_c,_n,_d)),
  retrieve_proposition('P'(_p,_mc,_m,_md)),
  attribute('P'(_p,_mc,_m,_md)),
  expandThem(_rest,_nrest).


expandThem([_lit|_rest],[_lit|_nrest]) :-
  expandThem(_rest,_nrest).
  


/** referencedByArgs(_x,_args) is used by rule R15 to check whether the object is _x **/
/** is referenced by some argument in _args. This is true if _x occurs in _args.     **/
/** It is also true if some arge _arg in _args is another object id that refers to   **/
/** _x in its P-fact P(_arg,_x1,_l,_x2).                                             **/
/** This definitions allows us to eliminate more occurences of In(x,Proposition).    **/
  
referencedByArgs(_x,_args) :-
  pc_member(_x,_args),
  !.

referencedByArgs(_x,[_arg|_restargs]) :-
  is_id(_arg),
  retrieve_proposition('P'(_arg,_x1,_l,_x2)),
  (_x=_x1;_x=_x2),
  !.

referencedByArgs(_x,[_|_restargs]) :-
  referencedByArgs(_x,_restargs).





/** evaluate the literals that have functional dependencies (FDs), i.e. where **/
/** a bound argument forces a unique solution for the remaining variables     **/
/** of the literals. For example:                                             **/
/**   Label(id_123,v) with variable v is replaced by                          **/
/**   Label(id_123,id_val) where id_val is the only solution                  **/
/** Tickets #276, #283                                                        **/


exploitFunctionalDependencies(_mvars,rangeconstr(_f),rangeconstr(_newf)) :-
  exploitFunctionalDependencies(_mvars,_f,_newf).


/** The subsequent clause optimizes some cases of rangerules, not all.       **/
/** We artificially glue the conclusion literal to the condition literals to **/
/** force that substitutions are applied on all literals.                    **/

exploitFunctionalDependencies(_mvars,rangerule(_vars,_f,_clit),rangerule(_new_vars,_new_f,_new_clit)) :-
  _f = forall(_vars,_lits,'FALSE'),
  _f1 = forall(_vars,[_clit|_lits],'FALSE'),
  _f2 = forall(_new_vars,[_new_clit|_new_lits],'FALSE'),
  _new_f= forall(_new_vars,_new_lits,'FALSE'),
  exploitFunctionalDependencies(_mvars,_f1,_f2).


exploitFunctionalDependencies(_mvars,forall(_vars,_lits,_f),forall(_newvars,_newlits,_newf)) :-
  processLits(_mvars,_lits,_vars,_newvars,_newlits),
  exploitFunctionalDependencies(_mvars,_f,_newf).

exploitFunctionalDependencies(_mvars,exists(_vars,_lits,_f),exists(_newvars,_newlits,_newf)) :-
  processLits(_mvars,_lits,_vars,_newvars,_newlits),
  exploitFunctionalDependencies(_mvars,_f,_newf).

exploitFunctionalDependencies(_mvars,and(_f1,_f2),and(_nf1,_nf2)) :-
  exploitFunctionalDependencies(_mvars,_f1,_nf1),
  exploitFunctionalDependencies(_mvars,_f2,_nf2).

exploitFunctionalDependencies(_mvars,or(_f1,_f2),or(_nf1,_nf2)) :-
  exploitFunctionalDependencies(_mvars,_f1,_nf1),
  exploitFunctionalDependencies(_mvars,_f2,_nf2).

exploitFunctionalDependencies(_mvars,not(_f),not(_nf)) :-
  exploitFunctionalDependencies(_mvars,_f,_nf).

exploitFunctionalDependencies(_mvars,_f,_f).


exploitFunctionalDependencies(_f,_newf) :-
  exploitFunctionalDependencies([],_f,_newf).



processLits(_mvars,_lits,_vars,_newvars,_newlits) :- 
  eliminateInLabel(_mvars,_lits,_vars,_lits1),            /** step 1 **/
  scanFDs(_mvars,_lits1,_vars,_newvars,_newlits).         /** step 2 **/



/** Step 1: eliminate In(_m,Label) when possible **/

eliminateInLabel(_mvars,[],_vars,[]) :- !.

eliminateInLabel(_mvars,['In'(_m,id_120)|_restlits],_vars,_restnewlits) :-    /** id_120=Label **/
  pc_member('Label'(_x,_m),_restlits),
  is_id(_x),
  pc_member(_m,_vars),
  \+ pc_member(_m,_mvars),
  'WriteTrace'(high,'SemanticOptimizer',[idterm('In'(_m,id_120)),' redundant due to ', idterm('Label'(_x,_m)),' in conjunction.']),
  !,
  eliminateInLabel(_mvars,_restlits,_vars,_restnewlits).

eliminateInLabel(_mvars,[_lit|_restlits],_vars,[_lit|_restnewlits]) :- 
  eliminateInLabel(_mvars,_restlits,_vars,_restnewlits).



/** Step 2: apply functional dependencies in literals **/
scanFDs(_mvars,[],_vars,_vars,[]) :- !.

scanFDs(_mvars,_lits,_vars,_newvars,_newlits) :-
  computeSubstitutions(_mvars,_lits,_vars,_subst),          /** substitions implicated by FDs **/
  applySubstitutions(_subst,_vars,_lits,_newvars,_newlits), 
  !.





applySubstitutions(_subst,_vars,_lits,_newvars,_newlits) :-
  computeNewVars(_subst,_vars,_newvars),   /** effect on variable list **/
  computeNewLits(_subst,_lits,_newlits).   /** effect on lits **/


computeNewVars([],_vars,_vars) :- !.
computeNewVars(_subst,[],[]) :- !.

computeNewVars(_subst,[_v|_vars],_newvars) :-
  pc_member( _val/_v, _subst),        /** this variable is substituted **/
  'WriteTrace'(high,'SemanticOptimizer',['Variable ', _v, ' is substituted by value ',idterm(_val),' via a functional dependency.']),
  computeNewVars(_subst,_vars,_newvars).

/** variable was not substituted **/
computeNewVars(_subst,[_v|_vars],[_v|_newvars]) :-
  computeNewVars(_subst,_vars,_newvars).




computeNewLits([],_lits,_lits) :- !.
computeNewLits(_subst,[],[]) :- !.

computeNewLits(_subst,[_lit|_restlits],[_newlit|_restnewlits]) :-
  applySubstOnLit(_subst,_lit,_newlit),
  computeNewLits(_subst,_restlits,_restnewlits).

applySubstOnLit(_subst,_lit,_newlit) :-
  _lit =.. [_f|_args],
  applySubstOnArgs(_subst,_args,_newargs),
  _newlit =.. [_f|_newargs].

/** catchall **/
applySubstOnLit(_subst,_lit,_lit).



applySubstOnArgs(_subst,[],[]) :- !.

/** arg _a to be substituted by _v **/
applySubstOnArgs(_subst,[_a|_args],[_v|_newargs]) :-
  pc_member(_v/_a,_subst),  /** read v/a as "value v substitutes variable v" **/
  applySubstOnArgs(_subst,_args,_newargs).

/** arg _a not substituted **/
applySubstOnArgs(_subst,[_a|_args],[_a|_newargs]) :-
  applySubstOnArgs(_subst,_args,_newargs).




computeSubstitutions(_mvars,[_lit|_restlits],_vars,_substs) :-
  isFDLit(_mvars,_lit,_vars,_newsubst),
  computeSubstitutions(_mvars,_restlits,_vars,_restsubsts),
  append(_newsubst,_restsubsts,_substs).


computeSubstitutions(_mvars,[_lit|_restlits],_vars,_substs) :-
  computeSubstitutions(_mvars,_restlits,_vars,_substs).

computeSubstitutions(_mvars,[],_vars,[]) :- !.




/** Return the substitution implicated by a certain literal. **/
/** The variable may not be a meta variable since they are   **/
/** being replaced via the update operation (tell/untell)    **/

isFDLit(_mvars,'From'(_x,_v),_vars,[_val/_v]) :-
  pc_member(_v,_vars),
  \+ pc_member(_v,_mvars),
  is_id(_x),
  prove_literal('From'(_x,_val)),   
  !.

isFDLit(_mvars,'Label'(_x,_v),_vars,[_val/_v]) :-
  pc_member(_v,_vars),
  \+ pc_member(_v,_mvars),
  is_id(_x),
  prove_literal('Label'(_x,_val)),   
  !.

isFDLit(_mvars,'To'(_x,_v),_vars,[_val/_v]) :-
  pc_member(_v,_vars),
  \+ pc_member(_v,_mvars),
  is_id(_x),
  prove_literal('To'(_x,_val)),   /** only one solution possible **/
  !.

isFDLit(_mvars,'P'(_id,_x,_m,_y),_vars,[_xval/_x,_mval/_m,_yval/_y]) :-
  is_id(_id),
  pc_member(_x,_vars), \+ pc_member(_x,_mvars),
  pc_member(_m,_vars), \+ pc_member(_m,_mvars),
  pc_member(_y,_vars), \+ pc_member(_y,_mvars),
  prove_literal('P'(_id,_xval,_mval,_yval)),   
  !.

/** Pa is the attribution P-predicate; see also Literals.pro **/
isFDLit(_mvars,'Pa'(_id,_x,_m,_y),_vars,[_xval/_x,_mval/_m,_yval/_y]) :-
  is_id(_id),
  pc_member(_x,_vars), \+ pc_member(_x,_mvars),
  pc_member(_m,_vars), \+ pc_member(_m,_mvars),
  pc_member(_y,_vars), \+ pc_member(_y,_mvars),
  prove_literal('Pa'(_id,_xval,_mval,_yval)),   
  !.



/** special optimization patterns for rangeforms **/

/** pattern 1: a function F has a domain predicate In('~this',D) which is
              guaranteed by all cases EQ('~this',v) where ~this is bound to 
              a value from D
  Example: Definition of Fibonacci numbers as recursive function
      fib in Function isA Integer with
        parameter
          n: Integer
        constraint
          cfib: $ (n=0) and (this=0) or
                  (n=1) and (this=1) or
                  (n>1) and (this=fib(n-1)+fib(n-2)) 
              $
      end
  Here, the domain predicate In(this,Integer) is implied by the superclass Integer.
  The three cases are all assigning integer number to 'this'. Hence, we do not
  have to check In(this,Integer).
**/

eliminateDomainByEQ( forall(_vars,_rangelits,_caseFormula),
                     forall(_vars,_rangelits1,_caseFormula)) :-
  pc_member('~this',_vars),
  delete('In'('~this',_D),_rangelits,_rangelits1),  /** tentatively remove the literal **/
  checkOnDomain('~this',_D,_caseFormula),
  'WriteTrace'(veryhigh,'SemanticOptimizer',[idterm('In'('~this',_D)),' guaranteed by ',idterm(_caseFormula),' [P1]']).

  
/** do nothing if not applicable **/
eliminateDomainByEQ(_f,_f).

checkOnDomain(_var,_D,and(_OrList)) :-
  _OrList \== [],
  checkOnDomainPerCase(_var,_D,_OrList).

checkOnDomainPerCase(_var,_D,[]).

checkOnDomainPerCase(_var,_D,[or(_lits)|_rest]) :-
  pc_member(not('EQ'(_var,_val)),_lits),
  isInDomain(_val,_D),
  checkOnDomainPerCase(_var,_D,_rest).


/** isInDomain(expr,D) checks whether expr is an element of domain D **/

isInDomain(_val,_D) :-
  is_id(_val),
  is_id(_D),
  prove_edb_literal('In_e'(_val,_D)).

isInDomain(_expr,_D) :-
  isFunctionLit(_expr,_fun),
  is_id(_fun),
  is_id(_D),
  prove_literal('Isa_e'(_fun,_D)).








  





