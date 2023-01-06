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
:::::::::::::
ECAqueryEvaluator.pro
:::::::::::::

*/
:- module('ECAqueryEvaluator',[
'evalECAquery'/2
,'evaluate_ecaformula'/1
,'classifyPredicate'/2
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').


:- use_module('GeneralUtilities.swi.pl').



:- use_module('Literals.swi.pl').

:- use_module('ObjectProcessor.swi.pl').
:- use_module('SearchSpace.swi.pl').

:- use_module('PrologCompatibility.swi.pl').









:- use_module('GlobalParameters.swi.pl').



:- use_module('SystemBuiltin.swi.pl').
:- use_module('ECAruleManager.swi.pl').
:- use_module('QO_preproc.swi.pl').



:- style_check(-singleton).



/*********************************************************************/
/**			evalECAquery/2				   **/
/*********************************************************************/

evalECAquery('Ask'(_,true),true) :- !.

evalECAquery('Ask'(_,false),false) :-!.


/** this case is for allnew queries with no free variables **/
evalECAquery('Ask'([],allnew(_lits)),allnew(_lits)) :-
   get_KBsearchSpace(_sp,_tt),
   set_KBsearchSpace(newOB,'Now'),
   ground(_lits),
   useCacheIfNeededList(_lits,_need), 
   prove_literals(_lits),   /** only prove once **/
   set_KBsearchSpace(_sp,_tt),
   !.

/** else case needs to return empty list **/
evalECAquery('Ask'([],allnew(_lits)),[]) :-
   set_KBsearchSpace(oldOB,'Now'),
   !.

/** analogous case is for allold queries with no free variables **/
evalECAquery('Ask'([],allold(_lits)),allold(_lits)) :-
   get_KBsearchSpace(_sp,_tt),
   set_KBsearchSpace(oldOB,'Now'),
   ground(_lits),
   prove_literals(_lits),     /** only prove once **/
   set_KBsearchSpace(_sp,_tt),
   !.

/** else case needs to return empty list **/
evalECAquery('Ask'([],allold(_lits)),[]) :-
   !.

evalECAquery('Ask'(_v,_q),_answers):-
	get_KBsearchSpace(_sp,_tt),
	set_KBsearchSpace(oldOB,'Now'),
        evaluate_ecaqueries('Ask'(_v,_q),_answers),
	set_KBsearchSpace(_sp,_tt),
	!.


/** This variant of evalECAquery will return as answer all instantiated terms **/
/** marching _q that are true in the database. It works independent of the    **/
/** number of free variables in _q. Hence, this should now solve ticket #83.  **/
/** This variant is being called in ECAruleManager.pro, more precisely in     **/
/** the procedure fire_ecarule.                                               **/
/** Note that the variable _v is missing in this variant of evalECAquery. This**/
/** makes sure that the old variant and the new variant do not interfer.      **/
/** We use findall instead of save_setof since we do not know the number of   **/
/** free variable in _q. The procedure findall is indifferent to this.        **/

evalECAquery('Ask'(true),[true]) :- !.

evalECAquery('Ask'(false),[]) :- !.


/** the query is a conjunction of literals, all to be evaluated against the   **/
/** newest database state.                                                    **/
evalECAquery('Ask'(allnew(_lits)),_answers) :-
	get_KBsearchSpace(_sp,_tt),
	set_KBsearchSpace(newOB,'Now'),
        useCacheIfNeededList(_lits,_need), 
        cm_setof(allnew(_lits),'Literals':prove_literals(_lits),_answers), 
	set_KBsearchSpace(_sp,_tt),
	!.

/** the query is a conjunction of literals, all to be avaluated against the   **/
/** old database state.                                                       **/
evalECAquery('Ask'(allold(_lits)),_answers) :-
	get_KBsearchSpace(_sp,_tt),
	set_KBsearchSpace(oldOB,'Now'),
        cm_setof(allold(_lits),'Literals':prove_literals(_lits),_answers), 
	set_KBsearchSpace(_sp,_tt),
	!.

/** else: a mixed formula that is either no conjunction, or has literals that **/
/** need to be evaluated against different database states.                   **/
evalECAquery('Ask'(_q),_answers) :-
	get_KBsearchSpace(_sp,_tt),
	set_KBsearchSpace(oldOB,'Now'),
        findall(_q,evaluate_ecaformula(_q),_answers), 
	set_KBsearchSpace(_sp,_tt).



/*********************************************************************/
/**		evaluate_ecaqueries				   **/
/*********************************************************************/

/* Query auf neuer OB auswerten */
/* evaluate_ecaqueries(Ask(_var,new(_q)),_answers) :-
	!,
	set_KBsearchSpace(newOB,Now),
	evaluate_ecaqueries(Ask(_var,_q),_answers),
	set_KBsearchSpace(oldOB,Now).
*/ /* Macht irgendwie keinen Sinn, new wird weiter unten behandelt. */

evaluate_ecaqueries('Ask'(_var,_query),_answers):-
	var(_var),
	!,
	save_setof(_var,evaluate_ecaformula(_query),_answers).

evaluate_ecaqueries('Ask'(_var,_query),[_query]):-
	_var == [],
	evaluate_ecaformula(_query),
	!.

evaluate_ecaqueries('Ask'([],_q),[]).


evaluate_ecaformula(and(_f1,_f2)) :-
	!,
	evaluate_ecaformula(_f1),
	evaluate_ecaformula(_f2).

evaluate_ecaformula(or(_f1,_f2)) :-
	!,
	(evaluate_ecaformula(_f1);
	evaluate_ecaformula(_f2)).

evaluate_ecaformula([_lit]) :-
	!,
	evaluate_ecaformula(_lit).

evaluate_ecaformula([_lit|_rest]) :-
        _rest \= [],
	!,
	evaluate_ecaformula(_lit),
	evaluate_ecaformula(_rest).

evaluate_ecaformula(not(_f)) :-
	!,
	\+(evaluate_ecaformula(_f)).

evaluate_ecaformula(new(_lit)) :-
	get_KBsearchSpace(_oldsp,_oldtt),
	set_KBsearchSpace(newOB,'Now'),
        useCacheIfNeeded(_lit,_need),  /** ticket #253 **/
                /** need to compute all solutions, and then deliver them via member; ticket #248 **/
        cm_setof(_lit,'ECAqueryEvaluator':prove_eca_literal(_lit),_lits),   
	set_KBsearchSpace(_oldsp,_oldtt),
        pc_member(_lit,_lits).


evaluate_ecaformula(new(_lit)) :-
	set_KBsearchSpace(oldOB,'Now'),    
        !,
	fail.


evaluate_ecaformula(_lit) :-
   _lit \= new(_),    /** the 'new' qualifier is processed in the previous clauses **/
   prove_eca_literal(_lit).





prove_eca_literal(true) :- !.

prove_eca_literal(false) :- !, fail.

/** this case may never be called when _c is a variable **/
/** I believe such espressions are anyway not supported by the parser **/
prove_eca_literal('In'(_x,_c)) :-
        nonvar(_c),
        _c=derive(_bq,_slist),
	name2id(_bq,_bqid),
	prove_literal('In'(_bqid,id_77)),       /** id_77 = BuiltinQueryClass **/
	!,
	id2name(_bqid,_bqname),
write(processBuiltin(_bqname,_x,_slist)),nl,
        processBuiltin(_bqname,_x,_slist).


prove_eca_literal(_lit) :-
	prove_literal(_lit).



/** The IF-part of an ECArule can contain calls to recursive predicate that  **/
/** are evaluated on the newest database state, i.e. during the update phase **/
/** of a transaction. Normally, the predicate cache is set to 'off' since    **/
/** cached facts can be invalid due to updates. Unfortunately, the call of   **/
/** a recursive predicate in cachemode=off can loop forever because          **/
/** because ConceptBase then employs Prolog's SLDNF rather than the safe     **/
/** cache-based evaluation.                                                  **/
/** To cope with the problem, we re-activate the cache whenever we encounter **/
/** the call of recursive predicate on the newest database state. After      **/
/** evaluation of the recursive predicate, we empty the cache and set        **/
/** cachemode=off again.   (Ticket #253)                                     **/


useCacheIfNeeded(_lit,needed) :-
  get_cb_feature(ecaControl, safe),  /** only needed in 'safe' mode **/
  needsCache(_lit),
  checkToEnableCacheAfterUpdate,
  checkToEmptyCacheOnSearchSpaceChange,  /** cache ready for use **/
  !.
useCacheIfNeeded(_lit,not_needed). /** cache not needed in this case **/


/** ticket #306: better use the cache if there is a complex query call **/
needsCache(_lit) :-
  isComplexQlit(_lit);
  isComplexComparisonLit(_lit).

needsCache(_lit) :-
  isDeducable(_lit),  /** lit is possibly recursive, hence we need to use the cache **/
  recursivePredicate(_lit).



useCacheIfNeededList(_lits,not_needed) :-
  get_cb_feature(ecaControl, unsafe),  /** cache not needed in mode -eca unsafe **/
  !.

useCacheIfNeededList(_lits,needed) :-
   pc_member(_lit,_lits),
   useCacheIfNeeded(_lit,needed),
   !.
useCacheIfNeededList(_lits,not_needed).



recursivePredicate(_lit) :-
  speedy(classifyPredicate(_lit,_class)),   /** speedy speeds up the computation **/
  !,
  _class=recursive.



classifyPredicate(_lit,nonrecursive) :-
  noCycle(_lit,[]),
  !.

classifyPredicate(_lit,recursive).


noCycle(_lit,_sofar) :-
  findCycle(_lit,_sofar),
  !,
  fail.
noCycle(_lit,_sofar).

findCycle(_lit1,_sofar) :-
  directDepOn(_lit1,_lit2),
  (_lit1=_lit2;
   pc_member(_lit2,_sofar);
   findCycle(_lit2,[_lit1|_sofar])
  ),
  !.

directDepOn(_lit1,_lit2) :-
  interestingLit(_lit1),
  ruleBody(_lit1,_body),
  plainLitInBody(_lit2,_body).

ruleBody(_conclLit,_body) :-
  clause('LTevalQuery'(_id,_conclLit),_body);
  clause('LTevalRule'(_id,_conclLit),_body);
  clause(_conclLit,_body).


plainLitInBody(_lit,_lit) :- _lit \= true,_lit \= (_a,_b).
plainLitInBody(_lit, 'Literals':prove_literal(_lit)).
plainLitInBody(_lit, 'Literals':not_prove_literal(_lit)).
plainLitInBody(_lit, not(_lit)).

plainLitInBody(_lit,(_lit,_)) :- _lit \= (_a,_b).
plainLitInBody(_lit, ('Literals':prove_literal(_lit),_) ).
plainLitInBody(_lit, ('Literals':not_prove_literal(_lit),_) ).
plainLitInBody(_lit, (not(_lit),_) ).

/** the Prolog OR ';' is not used in clauses generated by ConceptBase **/

plainLitInBody(_lit, (_,_rest) ) :- plainLitInBody(_lit,_rest).



/** we only follow clauses that are generated for rules/queries **/
/** Clauses with head ID_* are auxiliary clauses generated for  **/
/** rules and queries.                                          **/

interestingLit('Adot'(_,_,_)).
interestingLit('Adot_label'(_,_,_,_)).
interestingLit('In'(_,_)).
interestingLit(_lit) :-
  _lit =.. [_f|_],
  (pc_atomprefix('id_',3,_f);
   pc_atomprefix('ID_',3,_f)
  ).






