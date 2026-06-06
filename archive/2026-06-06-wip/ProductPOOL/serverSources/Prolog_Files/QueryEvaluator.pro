{*
The ConceptBase.cc Copyright

Copyright 1987-2026 The ConceptBase Team. All rights reserved.

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
*}
{
*
* File :        QueryEvaluator.pro
* Version :     12.3
* Creation:     29-Jul-1989, Martin Staudt (UPA)
* Last change : 05/01/98, Kai v. Thadden (RWTH)
* Release:      12
* ----------------------------------------------------------------------------
*
* Exported predicates:
* ---------------------
*
*   + evaluate_queries/23
*
*
*
}


#MODULE(QueryEvaluator)
#EXPORT(LoadExternalDataForQueryEvaluating/1)
#EXPORT(evaluate_queries/4)
#ENDMODDECL()


#IMPORT(bimstring/1,GeneralUtilities)
#IMPORT(BimstringToString/2,GeneralUtilities)
#IMPORT(atom2list/2,GeneralUtilities)
#IMPORT(insertPROLOGVars/2,GeneralUtilities)
#IMPORT(retrieve_proposition/1,PropositionProcessor)
#IMPORT(report_error/3,ErrorMessages)
#IMPORT(GenericQuery/1,QueryCompiler)
#IMPORT(SubQuery/2,QueryCompiler)
#IMPORT(get_QueryStruct/2,QueryCompiler)
#IMPORT(QueryArgNum/2,QueryCompiler)
#IMPORT(replace_derive_expression/3,QueryCompiler)
#IMPORT(specialize_goal/4,RuleSpecializer)
#IMPORT(set_KBsearchSpace/2,SearchSpace)
#IMPORT(member/2,GeneralUtilities)
#IMPORT(append/3,GeneralUtilities)
#IMPORT(name2id/2,GeneralUtilities)
#IMPORT(id2name/2,GeneralUtilities)
#IMPORT(prove_literal/1,Literals)
#IMPORT(prove_edb_literal/1,Literals)
#IMPORT(prove_explicit/1,Literals)
#IMPORT(SubQuery/2,QueryCompiler)
#IMPORT(checkIntegrity/2,SemanticIntegrity)
#IMPORT(ObjectLoadedflag/1,ExternalConnection)
#IMPORT(ifcheck/1,ExternalConnection)
#IMPORT(testIfExistsExternalDataSource/0,ExternalConnection)
#IMPORT(isComplexQlit/1,QO_preproc)
#IMPORT(pc_has_a_definition/1,PrologCompatibility)
#IMPORT(pc_atomconcat/2,PrologCompatibility)
#IMPORT(pc_atomconcat/3,PrologCompatibility)
#IMPORT(pc_atom_to_term/2,PrologCompatibility)
#IMPORT(pc_atomtolist/2,PrologCompatibility)
#IMPORT(pc_time/2,PrologCompatibility)
#IMPORT(pc_member/2,PrologCompatibility)
#IMPORT(pc_atomconstruct/3,PrologCompatibility)
#IMPORT(is_id/1,MetaUtilities)
#IMPORT(makeset/2,GeneralUtilities)
#IMPORT(computeFunction/3,SystemBuiltin)


#DYNAMIC(LoadExternalDataForQueryEvaluating/1)

#IF(SWI)
:- style_check(-singleton).
#ENDIF(SWI)



{ =================== }
{ Exported predicates }
{ =================== }


evaluate_queries([],[],_,_):-!.

evaluate_queries(_qlist,_answers,_RBtime,_m) :-
	checkQueryEvaluatingFlag,
	generate_query_goals(_qlist,_fwqgoals,_bwqgoals),
	set_KBsearchSpace(_m,_RBtime),
	evaluate_backward(_bwqgoals,_solutions),
	combine_solution_with_goals(_qlist,_solutions,_answers),
	retractall(LoadExternalDataForQueryEvaluating(_)),
	retractall(ObjectLoadedflag(_)),
	ICforLoadedExObjs.

checkQueryEvaluatingFlag :-
	testIfExistsExternalDataSource,
	assert(LoadExternalDataForQueryEvaluating(yes)),
	!.

checkQueryEvaluatingFlag.

{Bei Laden von externen OBjekten (tell_temp_ExObj) wrid ueberprueft, ob IC dabei noetig ist.
Wenn es fuer ein der geladene Objekte der Fall ist, wird das Flag ifcheck als TRUE gesetzt. IC wird fuer
alle in dieser Transaktion geladene Daten durchgefuehrt.}

ICforLoadedExObjs:-
	(
	  (not(ifcheck(yes)),
 	   !);
	  (retractall(ifcheck(_)),
  	   !,
	   checkIntegrity(tell,_e),
	   _e == 0,
	   write('   ... semantic integrity checked.\n\n'))
	).


evaluate_backward([],[]) :- !.

evaluate_backward([_fq|_rq],_answers) :-
	evaluate(_fq,_fanswer),
	evaluate_backward(_rq,_ranswers),
	append(_fanswer,_ranswers,_answers).


evaluate(_f,[_res]) :-
  atom(_f),    {* query calls without an argument for the answer variable are wrong *}
  !,
  fail.


evaluate(_f,[_res]) :-
	_f =.. [_fid,_answer|_args],
	not(SubQuery(_fid,_)),
	prove_literal(In(_fid,id_106)),  {* id_106=Function *}
        \+ prove_edb_literal(A_e(_fid,QueryClass,constraint,_someconstraint)),  {* ticket #78: this is not a user-defined function *}
	!,
	id2name(_fid,_fname),
        computeFunction(_fname,_answer,_args),
	_res =.. [_fid,_answer|_args].



{* In this clause, the answers to a query are evaluated        *}
{* The setof is available in two versions:                     *}
{*   a) with LTevalQuery(_,_q) as member predicate             *}
{*      This option is preferred hacause it will use           *}
{*      the cache feature of Literals.pro only when the        *}
{*      evaluation of the body of a rule for LTevalQuery(_,_q) *}
{*      contains a derived predicate	                       *}
{*   b) prove_literal(_q)                                      *}
{*      This answers the same query but via the proper         *}
{*      prove_literals call. As _q is a derivable predicate    *}
{*      the magic cache evaluator will always use the cache    *}
{*      facility. This is unnecessary for many (builtin)       *}
{*      queries.                                               *}
{* 23-Aug-2002/MJF: continue to use option a)                  *}

{* 8-Jul-2004/M.Jeusfeld *}
{* complex query calls are answered by prove_explicit since the*}
{* magic cache evaluation can't produce a proper AbstractCall  *}
{* for them. This implementation restriction can potentially   *}
{* cause endless loops!                                        *}

evaluate(_q,_answers) :-
 isComplexQlit(_q),
 setof(_q,prove_explicit(_q),_answers),
 !.

evaluate(_q,_answers) :-
	{ Dieses setof ist wichtig, da sich der AnswerTransformator auf sortierte Antworte verlaesst. }
{* a)        setof(_q,LTevalQuery(_,_q),_answers), *}
{* b)}       setof(_q,prove_literal(_q),_answers), 
	!.

evaluate(_,[]).



generate_query_goals([],[],[]).


generate_query_goals([derive(_gq,_dexp)|_r],_forw,[_bwgoal|_backw]) :-
	clause(LTevalQuery(_gq,_),_),!,
	generate_backward_query_goal(derive(_gq,_dexp),_bwgoal),
	generate_query_goals(_r,_forw,_backw).

generate_query_goals([derive(_gq,_dexp)|_r],[_fwgoal|_forw],_backw) :-
	generate_forward_query_goal(derive(_gq,_dexp),_fwgoal),
	generate_query_goals(_r,_forw,_backw).

generate_query_goals([_fq|_r],_forw,[_bwgoal|_backw]) :-
	clause(LTevalQuery(_fq,_),_),!,
	generate_backward_query_goal(_fq,_bwgoal),
	generate_query_goals(_r,_forw,_backw).

{* Diese Klausel wurde eingefuegt, um Probleme mit den OIDs vs. name zu umgehen
*}
{
generate_query_goals([_fq|_r],_forw,[_bwgoal|_backw]) :-
	name2id(_fq,_fqID),
	clause(LTevalQuery(_fqID,_),_),!,
	generate_backward_query_goal(_fq,_bwgoal),
	generate_query_goals(_r,_forw,_backw).
}

generate_query_goals([_fq|_r],[_fwgoal|_forw],_backw) :-
	generate_forward_query_goal(_fq,_fwgoal),
	generate_query_goals(_r,_forw,_backw).


{ _fq sollte ID sein, bringt aber Probleme beim Erzeugen von Prolog-Termen TL/7.94}
{ hat sich duch Aenderung des ID-Bezeichners geaendert! }

generate_forward_query_goal(derive(_gq,_dexp),_fq) :-
	!,
	replace_derive_expression('_',derive(_gq,_dexp),_term),
	specialize_goal(_term,[],_nterm,_),
	insertPROLOGVars(_nterm,_nterm2),
	_nterm2 =.. [_f|_args],
	assert(goal(derive(_gq,_dexp),_nterm2)),
	remove_free_vars(_args,_nargs),
	pc_atomconcat('query_',_f,_nf),
	_fq =..[_nf|_nargs].


generate_forward_query_goal(_fq,_f) :-
	name2id(_fq,_fqID),
	GenericQuery(_fqID),
	get_QueryStruct(_fqID,_s),
	gen_binding_exp(_s,_be,_bv),
	remove_free_vars(_bv,_nbv),
	pc_atomconcat(_fq,'_',_h1),
	pc_atomconcat(_h1,_be,_h2),
	_g =..[_h2|_bv],
	assert(goal(_fq,_g)),
	pc_atomconcat('query_',_h2,_ff),
	_f =..[_ff|_nbv].

generate_forward_query_goal(_fq,_f) :-
	name2id(_fq,_fqID),
	get_QueryStruct(_fqID,_s),
	QueryArgNum(_s,_l),
	pc_atomconstruct(f,_l,_p),
	pc_atomconstruct('_',_l,_a),
	pc_atomtolist(_a,_al),
	pc_atom_to_term(_na,_al),
	pc_atom_to_term(_na,_args),
	pc_atomconcat(_fq,'_',_h1),
	pc_atomconcat(_h1,_p,_h2),
	_g =..[_h2|_args],
	assert(goal(_fq,_g)),
	pc_atomconcat('query_',_h2,_f).


generate_backward_query_goal(derive(_gq,_dexp),_fq) :-
	!,
	replace_derive_expression('_',derive(_gq,_dexp),_term),
	insertPROLOGVars(_term,_fq),
	assert(goal(derive(_gq,_dexp),_fq)).

generate_backward_query_goal(_fq,_f) :-
	SubQuery(_fq,_),
	!,
	get_QueryStruct(_fq,_s),
	gen_binding_exp(_s,_be,_bv),
	_f =..[_fq|_bv],
	assert(goal(_fq,_f)).

generate_backward_query_goal(_fq,_f) :-
	name2id(_fq,_fqID),
	GenericQuery(_fqID),
	!,
	get_QueryStruct(_fqID,_s),
	gen_binding_exp(_s,_be,_bv),
	_f =..[_fq|_bv],
	assert(goal(_fq,_f)).

generate_backward_query_goal(_fq,_f) :-
	name2id(_fq,_fqID),
	get_QueryStruct(_fqID,_s),
	QueryArgNum(_s,_l),
	pc_atomconstruct('_',_l,_a),
	pc_atomtolist(_a,_al),
	pc_atom_to_term(_na,_al),
	pc_atom_to_term(_na,_args),
	_f =..[_fq|_args],
	assert(goal(_fq,_f)).

remove_free_vars([],[]).
remove_free_vars([_f|_r],_nr) :-
	var(_f),!,
	remove_free_vars(_r,_nr).

remove_free_vars([_f|_r],[_f|_nr]) :-
	remove_free_vars(_r,_nr).

gen_binding_exp([],'',[]).

gen_binding_exp([this|_r],_be,[_|_bv]) :-
	!,
	gen_binding_exp(_r,_ber,_bv),
	pc_atomconcat(f,_ber,_be).

gen_binding_exp([_t|_r],_be,[_,_,_c|_bv]) :-
	_t =..[rp,_,_c],!,
	gen_binding_exp(_r,_ber,_bv),
	pc_atomconcat(fb,_ber,_be).

gen_binding_exp([_t|_r],_be,[_,_|_bv]) :-
	_t =..[r,_],!,
	gen_binding_exp(_r,_ber,_bv),
	pc_atomconcat(fb,_ber,_be).

gen_binding_exp([_t|_r],_be,[_,_c|_bv]) :-
	_t =..[_,_,_c],!,
	gen_binding_exp(_r,_ber,_bv),
	pc_atomconcat(fb,_ber,_be).

gen_binding_exp([_t|_r],_be,[_|_bv]) :-
	_t =..[_,_],!,
	gen_binding_exp(_r,_ber,_bv),
	pc_atomconcat(f,_ber,_be).


{* 10-Apr-2008/M.Jeusfeld
   For an unknown reason, the call setof in combine_solution_with_goals can cause
   duplicates of the same entry if it is evaluated without a database or with
   a fresh database created by the current CBserver process.
   The call of makeset cures this bug. The bug van be tested with the script
   minreal.cbs. See also check-in [8091].
*}

{* make sure that solutions are collected in the same sequence as the original queries *}
combine_solution_with_goals(_calls,_sol,_solutions) :-
    getGoalList(_calls,_goallist),
    get_relevant_answers(_goallist,_sol,_solutions),
    retractall(goal(_,_)).


getGoalList([],[]) :- !.

getGoalList([_q|_restq],[g(_q,_g)|_restg]) :-
    goal(_q,_g),!,
    getGoalList(_restq,_restg).

{* issue #39: sometimes the goal(q,g) facts are incomplete *}
getGoalList([_q|_restq],[g(_q,_g)|_restg]) :-
    generate_backward_query_goal(_q,_g),
    getGoalList(_restq,_restg).

getGoalList([_|_restq],_restg) :-
    getGoalList(_restq,_restg).


{* old version of combine_solution_with_goals; no longer needed *}
combine_solution_with_goals(_sol,_solutions) :-
	setof(g(_q,_g),goal(_q,_g),_goallist1),
	makeset(_goallist1,_goallist),
	get_relevant_answers(_goallist,_sol,_solutions),
	retractall(goal(_,_)).

get_relevant_answers(_,[],[]) :- !.
get_relevant_answers([],_,[]).

get_relevant_answers([g(_q,_g)|_rg],_sol,[solution(_q,_solution)|_rs]) :-
	(
	 (setof(_g,pc_member(_g,_sol),_solution),!);
	 _solution = []
	),
	get_relevant_answers(_rg,_sol,_rs).












