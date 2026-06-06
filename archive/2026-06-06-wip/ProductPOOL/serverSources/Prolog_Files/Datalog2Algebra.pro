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
{*
*
* File:         %M%
* Version:      %I%
* Creation:     10-Mar-1997, Christoph Quix (RWTH)
* Last Change   : %E%, Christoph Quix (RWTH)
*
* SCCS-Source-Pool : %P%
* Date retrieved : %D% (YY/MM/DD)
*
*-----------------------------------------------
*
* Uebersetzt eine Datalog-Regel in einen Ausdruck
* der relationalen Algebra, der vom Objektspeicher
* ausgewertet werden kann.
*
*}

#MODULE(Datalog2Algebra)
#EXPORT(getRuleIdsForHead/3)
#EXPORT(getRuleIdsForHeads/3)
#ENDMODDECL()


#IMPORT(append/3,GeneralUtilities)
#IMPORT(member/2,GeneralUtilities)
#IMPORT(memberchk/2,GeneralUtilities)
#IMPORT(delete/3,GeneralUtilities)
#IMPORT(subtract/3,GeneralUtilities)
#IMPORT(reverse/2,GeneralUtilities)
#IMPORT(length/2,GeneralUtilities)
#IMPORT(prove_literal/1,Literals)
#IMPORT(isVar/1,QO_literals)
#IMPORT(isConst/1,QO_literals)
#IMPORT(pc_atomconcat/2,PrologCompatibility)
#IMPORT(pc_atomconcat/3,PrologCompatibility)
#IMPORT(pc_rerecord/2,PrologCompatibility)
#IMPORT(pc_rerecord/3,PrologCompatibility)
#IMPORT(pc_recorded/2,PrologCompatibility)
#IMPORT(pc_recorded/3,PrologCompatibility)

#IF(SWI)
:- style_check(-singleton).
#ENDIF(SWI)


{===========================================================}
{=             EXPORTED PREDICATES DEFINITION              =}
{===========================================================}

evaluate_algebra(_id,_algexp) :-
	getRulesForQuery(_id,_rules),
	removeTRUE(_rules,_rules2),
	{ unrollRules(_rules,_rules2), }  {geht noch nicht }
	stratification(_rules2,_rules3),
    generate_stratified_algebra_expression(_rules3,_algexp).

generate_stratified_algebra_expression([],[]).
generate_stratified_algebra_expression([_rules|_strats],[_algexps|_stratalgexps]) :-
	generate_algebra_expression_list(_rules,_algexps),
	generate_stratified_algebra_expression(_strats,_stratalgexps).


generate_algebra_expression_list([],[]).
generate_algebra_expression_list([_rule|_rules],[_algexp|_algexps]) :-
	generate_algebra_expression(_rule,_algexp),
	generate_algebra_expression_list(_rules,_algexps).

{*******************************************************************}
{                                                                   }
{ generate_algebra_expression(_rule,_algexp)                        }
{                                                                   }
{ Description of arguments:                                         }
{    rule : Prolog-Rule ( h(..) :- b1(..), b2(..), ... .            }
{  algexp : sequence of select, project and join operations         }
{                                                                   }
{ Description of predicate:                                         }
{   Take a Prolog rule as input and outputs a equivalent algebra    }
{   expression.                                                     }
{*******************************************************************}

#MODE(generate_algebra_expression(i,o))


generate_algebra_expression(rule(_head,_body),rule(_head,_bodyexp2,_headexp)) :-
	generate_body_expression(_body,_head,_bodyexp,_resultlit),
	generate_head_expression(_head,_resultlit,_headexp,_constexp),
	insertConstExpInBodyExp(_bodyexp,_constexp,_bodyexp2).

insertConstExpInBodyExp(_bodyexp,const,_bodyexp) :-
	!.

insertConstExpInBodyExp(_bodyexp,_const,simplecross(_bodyexp,_const)).


{===========================================================}
{=                LOCAL PREDICATES DEFINITION              =}
{===========================================================}


{*******************************************************************}
{                                                                   }
{ generate_head_expression(_head,_bodylit,_headexp)                 }
{                                                                   }
{ Description of arguments:                                         }
{    head : Kopfliteral                                             }
{ bodylit : Literal fuer den Rumpf                                  }
{ headexp : Ergebnis                                                }
{                                                                   }
{ Description of predicate:                                         }
{                                                                   }
{*******************************************************************}

#MODE(generate_head_expression(i,i,o,o))


generate_head_expression(_head,_bodylit,_mapexp2,_constexp) :-
	get_args_and_func_of_lit(_head,_f,_args),
	get_args_and_func_of_lit(_bodylit,_f2,_bodyargs),
	generate_head_expression2(_args,_bodyargs,0,_mapexp),
	length(_bodyargs,_bodylen),
	makeConstExp(_mapexp,_bodylen,_mapexp2,_constexp).

#MODE(makeConstExp(i,i,o,o))

makeConstExp([],_,[],const).
makeConstExp([map(_x,_y)|_maps],_bodylen,[map(_x,_y)|_rmaps],_const) :-
	makeConstExp(_maps,_bodylen,_rmaps,_const).
makeConstExp([const(_x,_c)|_maps],_bodylen,[map(_bodylen1,_x)|_rmaps],_const2) :-
	_bodylen1 is _bodylen + 1,
	makeConstExp(_maps,_bodylen1,_rmaps,_const),
	_const =.. _args,
	append(_args,[_c],_newargs),
	_const2 =.. _newargs.


#MODE(generate_head_expression2(i,i,i,o))


generate_head_expression2([],_,_,[]).

generate_head_expression2([_var|_args],_bodyargs,_x,[map(_y,_x1)|_restmap]) :-
	isVar(_var),
	!,
	get_arg_position(_var,_bodyargs,_y,0),
	!,
	_x1 is _x + 1,
	generate_head_expression2(_args,_bodyargs,_x1,_restmap).

generate_head_expression2([_const|_args],_bodyargs,_x,[const(_x1,_const)|_restmap]) :-
	_x1 is _x + 1,
	generate_head_expression2(_args,_bodyargs,_x1,_restmap).


{*******************************************************************}
{                                                                   }
{ generate_body_expression(_body,_head,_algexp,_resultlit)          }
{                                                                   }
{ Description of arguments:                                         }
{    body : Rumpf einer Regel                                       }
{  algexp : zugehoerige Algebra-Ausdruck                            }
{    head : Kopf der Regel (fuer die Variablen)                     }
{  reslit : Ergebnisliteral (Variablenreihenfolge nach Anwendung der}
{            algexp                                                 }
{                                                                   }
{ Description of predicate:                                         }
{   Generiert Algebra-Ausdruck fuer den Rumpf einer Regel.          }
{*******************************************************************}

#MODE(generate_body_expression(i,i,o,o))


{ Nur ein lit im Rumpf }
generate_body_expression([_lit],_,lit(_lit),_lit) :-
	!.

{TODO: Nur ein neglit im Rumpf ?!Darf nicht vorkommen ==> unroll}
generate_body_expression([_lit1|_res],_head,_algexp,_reslit) :-
	!,
	get_vars_of_body([_head],_varlist),
	generate_body_expression([_lit1|_res],_varlist,lit(_lit1),_algexp,_reslit).


#MODE(generate_body_expression(i,i,i,o,o))


generate_body_expression([_lit1,_lit2],_varlist,_preres, join_proj(_joincond,_projlist,_preres,lit(_lit2)),_resultlit) :-
	!,
	get_args_and_func_of_lit(_lit1,_func1,_args1),
	get_args_and_func_of_lit(_lit2,_func2,_args2),
	generate_join_condition(_args1,_args2,_joincond,1,0),
	get_args_for_result(_args1,_args2,_joincond,_resargs),
	{ write('  Join cond:'),write(_joincond),nl, }
	{ write('  Result args:'),write(_resargs),nl, }
	generate_proj_list(0,_resargs,_varlist,_projlist,_resargs2),
	{ write('  Proj List:'),write(_projlist),nl, }
	pc_atomconcat(_func1,_func2,_newfunc),
	_resultlit =.. [_newfunc|_resargs2],
	!.

generate_body_expression([_lit1|_rest], _varlist, _preres,_exp,_resultlit) :-
	_rest = [_lit2|_rest2],
	get_vars_of_body(_rest2,_varlist2),
	append(_varlist,_varlist2,_newvarlist),
	generate_body_expression([_lit1,_lit2],_newvarlist,_preres,_exp1,_resultlit1),
	generate_body_expression([_resultlit1|_rest2],_varlist,_exp1,_exp,_resultlit),
	!.

{*******************************************************************}
{                                                                   }
{ generate_join_condition(_args1,_args2,_joincond,_n1,_n2,_resargs) }
{                                                                   }
{ Description of arguments:                                         }
{   args1 : Liste der Argumente von Lit1                            }
{   args2 : Liste der Argumente von Lit2                            }
{joincond : Join-Bedingung fuer Lit1 x Lit2                         }
{      n1 : Position des ersten Arguments von Lit1                  }
{      n2 : Position des eines Args aus Lit2, falls Arg aus Lit1    }
{           schon passendes Argument in Lit2 hat (mehrfach moegl.)  }
{ resargs : Liste der Argumente des Ergebnisliterals                }
{                                                                   }
{ Description of predicate:                                         }
{   Gibt die Join-Bedingung fuer einen Join zwischen Lit1 und Lit2  }
{   zurueck. Zwei Argumente muessen gleich sein, wenn beides        }
{   Variablen sind und die beiden Variablen identisch sind.         }
{   ==/2 funktioniert bei unbelegten Variablen!                     }
{   (args1 wird dabei durchlaufen).                                 }
{   Dabei ist es moeglich, das ein Argument aus Lit1 oder Lit2 mehr-}
{   fach in der Joinbedingung vorkommt, da die Variablen auch mehr- }
{   fach in den Literalen vorkommen koennen.                        }
{*******************************************************************}

#MODE((generate_join_condition(?,?,o)))

{ Ende der Rekursion }
generate_join_condition([],_args2,[],_n1,_n2) :-
	!.

{ passendes Argument kommt vor }
generate_join_condition([_arg|_rest],_args2,[equal(_n1,_n3)|_joincond],_n1,_n2) :-
	get_arg_position(_arg,_args2,_n3,0),
	_n3 > _n2,
	!,
	generate_join_condition([_arg|_rest],_args2,_joincond,_n1,_n3).

{ kein passendes Argument in args2 gefunden }
generate_join_condition([_arg|_rest],_args2,_joincond,_n1,_n2) :-
	_n11 is _n1 + 1,
	generate_join_condition(_rest,_args2,_joincond,_n11,0).



{*******************************************************************}
{                                                                   }
{ get_arg_position(_arg,_args,_erg,_inp)                            }
{                                                                   }
{ Description of arguments:                                         }
{     arg : Argument                                                }
{    args : Argumentliste                                           }
{     erg : Ergebnis=Position von arg in args                       }
{     inp : Offset (wo Zaehlung beginnt)                            }
{                                                                   }
{ Description of predicate:                                         }
{   Ermittelt die Position eines Arguments in einer Argumentliste   }
{                                                                   }
{*******************************************************************}

#MODE((get_arg_position(?,?,o,i)))

get_arg_position(_arg,[_arg2|_args],_i1,_i) :-
	isVar(_arg),
	_arg == _arg2,
	{ !, Hier kein Cut, da mehrfach Suche moeglich }
	_i1 is _i + 1 .

get_arg_position(_arg,[_|_args],_o,_i) :-
	_i1 is _i + 1,
	get_arg_position(_arg,_args,_o,_i1).


#MODE((get_args_for_result(?,?,i,o)))

get_args_for_result(_args1,_args2,_joincond,_result) :-
	get_args_for_result2(_args2,_joincond,1,_res),
	append(_args1,_res,_result).


#MODE((get_args_for_result2(?,i,i,o)))

get_args_for_result2([],_,_,[]) :-
	!.

get_args_for_result2([_arg|_args],_joincond,_n,_res) :-
	isVar(_arg),
	arg_in_cond(_n,_joincond),
	!,
	_n1 is _n + 1,
	get_args_for_result2(_args,_joincond,_n1,_res).

get_args_for_result2([_arg|_args],_joincond,_n,[_arg|_res]) :-
	_n1 is _n + 1,
	get_args_for_result2(_args,_joincond,_n1,_res).


#MODE((arg_in_cond(i,i)))

arg_in_cond(_n,[equal(_a1,_a2)|_res]) :-
	_n == _a2,
	!.

arg_in_cond(_n,[_|_res]) :-
	arg_in_cond(_n,_res).


#MODE((get_vars_of_body(i,o)))

get_vars_of_body([_lit],_vars) :-
	!,
	get_args_and_func_of_lit(_lit,_f,_args),
	get_vars_of_list(_args,_vars).

get_vars_of_body([_l1|_r],_vars) :-
	get_vars_of_body([_l1],_v1),
	get_vars_of_body(_r,_v2),
	append(_v1,_v2,_vars).


#MODE((get_vars_of_list(i,o)))

get_vars_of_list([],[]).
get_vars_of_list([_v|_vs],[_v|_r]) :-
	isVar(_v),
	!,
	get_vars_of_list(_vs,_r).

get_vars_of_list([_c|_vs],_r2) :-
	get_vars_of_body([_c],_vars),
	get_vars_of_list(_vs,_r),
	append(_vars,_r,_r2).




{*******************************************************************}
{                                                                   }
{ generate_proj_list(_i,_args,_vars,_projlist,_newargs)             }
{                                                                   }
{ Description of arguments:                                         }
{       i : Argumentposition                                        }
{    args : Argumentliste                                           }
{    vars : Variablenliste, die noch gebraucht werden               }
{projlist : Liste von Argumentpos., auf die Projeziert wird (output)}
{ newargs : Liste von Argumenten,    "    "    "          "   "     }
{                                                                   }
{ Description of predicate:                                         }
{   Ermittelt die Liste der Argumente, die nach einem Join noch fuer}
{   weitere Joins oder im Kopfliteral gebraucht werden              }
{*******************************************************************}

#MODE((generate_proj_list(i,i,i,o,o)))

generate_proj_list(_,[],_,[],[]) :-
	!.

generate_proj_list(_i,[_arg|_args],_vars,[_i1|_rpl],[_arg|_newargs]) :-
	isVar(_arg),
	var_in_varlist(_arg,_vars),
	!,
	_i1 is _i + 1,
	generate_proj_list(_i1,_args,_vars,_rpl,_newargs).


generate_proj_list(_i,[_arg|_args],_vars,_rpl,_newargs) :-
	_i1 is _i + 1,
	generate_proj_list(_i1,_args,_vars,_rpl,_newargs).



var_in_varlist(_v1,[_v2|_]) :-
	_v1 == _v2,
	!.

var_in_varlist(_v,[_|_vs]) :-
	var_in_varlist(_v,_vs).




get_args_and_func_of_lit(_lit1,_func,_args) :-
	_lit1=..[_f,_lit],
	member(_f,['not',ins,del,red,new,plus,minus]),
	!,
	get_args_and_func_of_lit(_lit,_func,_args).


get_args_and_func_of_lit(_lit,_func,_args) :-
	_lit=.. [_func|_args].







{*******************************************************************}
{                                                                   }
{ getRulesForQuery(_qid,_rules)                                     }
{                                                                   }
{ Description of arguments:                                         }
{     qid : Query ID                                                }
{   rules : Regeln dazu                                             }
{                                                                   }
{ Description of predicate:                                         }
{  Gibt zu einer Query alle Regeln aus, die zur Auswertung dieser   }
{  Query benoetigt werden.                                          }
{                                                                   }
{*******************************************************************}

{ RECORD - DB: }
{ newRules: Die in der aktuellen Iteration gefundenen Regeln }
{ foundRules: Alle bisher gefundenen Regeln }

#MODE((getRulesForQuery(i,o)))


getRulesForQuery(_id,_rules) :-
	getMainRule(_id,_ruleid,_rule),
	pc_rerecord(newRules,Datalog2Algebra,[_ruleid]),
	pc_rerecord(foundRules,Datalog2Algebra,[_ruleid]),
	pc_rerecord(checkedLits,Datalog2Algebra,[]),
	getDependingRules([_ruleid]),
	pc_recorded(foundRules,Datalog2Algebra,_ruleids),
	getRulesForRuleIds(_ruleids,_rules).

getRulesForHead(_head,_cat,_rules) :-
	getRuleIdsForHead(_head,_cat,_ruleids),
	getRulesForRuleIds(_ruleids,_rules).

getRuleIdsForHeads(_heads,_cat,_allruleids) :-
	pc_rerecord(newRules,Datalog2Algebra,[]),
	pc_rerecord(foundRules,Datalog2Algebra,[]),
	pc_rerecord(checkedLits,Datalog2Algebra,[]),
	getRuleIdsForHeads2(_heads,_cat,_allruleids).


getRuleIdsForHeads2([],_cat,[]).

getRuleIdsForHeads2([_head|_heads],_cat,_allruleids) :-
	getRuleIdsForHead2(_head,_cat,_ruleids1),
	getRuleIdsForHeads2(_heads,_cat,_ruleids2),
	pc_recorded(foundRules,Datalog2Algebra,_allruleids).

getRuleIdsForHead(_head,_cat,_allruleids) :-
	pc_rerecord(newRules,Datalog2Algebra,[]),
	pc_rerecord(foundRules,Datalog2Algebra,[]),
	pc_rerecord(checkedLits,Datalog2Algebra,[]),
	getRuleIdsForHead2(_head,_cat,_allruleids).

getRuleIdsForHead2(_head,_cat,_allruleids) :-
	findall(_ruleid,
		ruleInfo(_ruleid,_cat,_,_,_head,_b,_,_,_,_),
		_ruleids),
	pc_rerecord(newRules,Datalog2Algebra,_ruleids),
	pc_recorded(foundRules,Datalog2Algebra,_ruleids2),
	append(_ruleids,_ruleids2,_ruleids3),
    pc_rerecord(foundRules,Datalog2Algebra,_ruleids3),
	pc_recorded(checkedLits,Datalog2Algebra,_heads),
	pc_rerecord(checkedLits,Datalog2Algebra,[_head|_heads]),
	getDependingRules(_ruleids),
	pc_recorded(foundRules,Datalog2Algebra,_allruleids).


getMainRule(_id,_ruleid,rule(_head,_body)) :-
	ruleInfo(_ruleid,_type,_id,_,_head,_body,_,_,_,_),
	(_type = query; _type = mquery ),
	_head =.. [_id|_args].

{ Hole zu allen im vorherigen Durchgang gefundenen Regeln, alle abhaengigen Regeln }
{ Fixpunktiteration! }
getDependingRules :-
	pc_recorded(newRules,Datalog2Algebra,_newrules),
	pc_rerecord(newRules,Datalog2Algebra,[]),
	getDependingRules(_newrules).

{ Wenn keine neuen Regeln gefunden wurden => Ende der Rekursion }
getDependingRules([]) :-
	pc_recorded(newRules,Datalog2Algebra,_newrules),
	_newrules == [],
	!.

{ Sonst beginne naechste Iteration }
getDependingRules([]) :-
	getDependingRules.

{ Hole zu einer RuleId den Rumpf und suche nach abhaengigen Regeln }
getDependingRules([_ruleid|_ruleids]) :-
	ruleInfo(_ruleid,_cat,_oid,_ids,_head,_body,_deps,_vars,_opt,_alg),
	findRuleReferenceInBody(_body),
	getDependingRules(_ruleids).

{*******************************************************************}
{                                                                   }
{ findRuleReferenceInBody(_lits)                                    }
{                                                                   }
{ Description of arguments:                                         }
{    lits : Liste der Literale, fuer die Regeln gesucht werden      }
{                                                                   }
{ Description of predicate:                                         }
{  Sucht zu einer Liste von Literalen alle Regeln, die diese Literale }
{  folgern koennen.                                                 }
{  Record-DB speichert die Regeln die bisher gefunden wurden        }
{*******************************************************************}

#MODE((findRuleReferenceInBody(i)))


findRuleReferenceInBody([]) :-
	!.

findRuleReferenceInBody([not(_lit)|_lits]) :-
	!,
	findRuleReferenceInBody([_lit|_lits]).

findRuleReferenceInBody([new(_lit)|_lits]) :-
	!,
	findRuleReference(new,_lit),
	findRuleReferenceInBody([_lit|_lits]).

findRuleReferenceInBody([ins(_lit)|_lits]) :-
	!,
	findRuleReference(ins,_lit),
	findRuleReferenceInBody(_lits).

findRuleReferenceInBody([del(_lit)|_lits]) :-
	!,
	findRuleReference(del,_lit),
	findRuleReferenceInBody(_lits).

findRuleReferenceInBody([red(_lit)|_lits]) :-
	!,
	findRuleReference(red,_lit),
	findRuleReferenceInBody(_lits).

findRuleReferenceInBody([plus(_lit)|_lits]) :-
	!,
	findRuleReference(plus,_lit),
	findRuleReferenceInBody(_lits).

findRuleReferenceInBody([minus(_lit)|_lits]) :-
	!,
	findRuleReference(minus,_lit),
	findRuleReferenceInBody(_lits).

findRuleReferenceInBody([_lit|_lits]) :-
	findRuleReference('',_lit),
	findRuleReferenceInBody(_lits).

#IF(BIM)
:- findRuleReference/2 index 2 .
#ENDIF(BIM)
#IF(SWI,SICSTUS)
{* :- index(findRuleReference(0,1)). *}
#ENDIF(SWI,SICSTUS)

findRuleReference(_,To(_,_)).
findRuleReference(_,From(_,_)).
findRuleReference(_,Aidot(_,_,_)).
findRuleReference(_,P(_,_,_,_)).
findRuleReference(_,Label(_,_)).
findRuleReference(_,Isa(_,_)).
findRuleReference(_,LT(_,_)).
findRuleReference(_,GT(_,_)).
findRuleReference(_,LE(_,_)).
findRuleReference(_,GE(_,_)).
findRuleReference(_,UNIFIES(_,_)).
findRuleReference(_,IDENTICAL(_,_)).
findRuleReference(_,EQ(_,_)).
findRuleReference(_,NE(_,_)).

findRuleReference(_functor,In(_x,_class)) :-
	\+(isVar(_class)),
	buildLit(_functor,In(_,_class),_head),
	pc_recorded(checkedLits,Datalog2Algebra,_lits),
	\+(member(_head,_lits)),
	pc_rerecord(checkedLits,Datalog2Algebra,[_head|_lits]),
	!,
	pc_recorded(foundRules,Datalog2Algebra,_ruleids),
	findall(_ruleId,
		({prove_literal(Isa(_class,_class2)),}
		 ruleInfo(_ruleId,_,_,_,
					_head,_,_,
					_,_,_),
		\+(memberchk(_ruleId,_ruleids))),
		_rulesReferenced),
	append(_rulesReferenced,_ruleids,_ruleids2),
	pc_rerecord(foundRules,Datalog2Algebra,_ruleids2),
	pc_recorded(newRules,Datalog2Algebra,_newruleids),
	append(_rulesReferenced,_newruleids,_newruleids2),
	pc_rerecord(newRules,Datalog2Algebra,_newruleids2),
	findRuleReference_LTeval(_functor,In(_x,_class)).


{ In-Literal mit Klasse als Variable, erstes Argument ist konstant }
{ sollte eigentlich nicht vorkommen, da Meta-Formel, }
{ kann aber in Queries auftauchen }
findRuleReference(_functor,In(_x,_class)) :-
	isVar(_class),
	not(isVar(_x)),
	buildLit(_functor,In(_,_),_head),
	pc_recorded(checkedLits,Datalog2Algebra,_lits),
	\+(member(_head,_lits)),
	pc_rerecord(checkedLits,Datalog2Algebra,[_head|_lits]),
	!,
	pc_recorded(foundRules,Datalog2Algebra,_ruleids),
	findall(_ruleId,
		(
		 ruleInfo(_ruleId,_type,_,_,_head,_,_,_,_,_),
		 _type \== mquery, { In-Literale fuer mqueries haben die Form In(_,q) :- q(...) }
		\+(memberchk(_ruleId,_ruleids))),
		_rulesReferenced),
	append(_rulesReferenced,_ruleids,_ruleids2),
	pc_rerecord(foundRules,Datalog2Algebra,_ruleids2),
	pc_recorded(newRules,Datalog2Algebra,_newruleids),
	append(_rulesReferenced,_newruleids,_newruleids2),
	pc_rerecord(newRules,Datalog2Algebra,_newruleids2).

{ Wenn beide Argumente von In Variablen sind, dann mache nichts. }
{ Diese In-Literale kommen eigentlich nur bei GenericQueries zur }
{ Bindung der Parameter vor, alles andere sollten Meta-Formeln sein }
findRuleReference(_functor,In(_x,_class)) :-
	isVar(_class),
	isVar(_x),
	!.

findRuleReference(_functor,Adot_label(_p,_x,_y,_l)) :-
	!,
	findRuleReference(_functor,Adot(_p,_x,_y)).

findRuleReference(_functor,Adot(_p,_,_)) :-
	buildLit(_functor,Adot(_p,_x,_y),_head),
	pc_recorded(checkedLits,Datalog2Algebra,_lits),
	\+(member(_head,_lits)),
	pc_rerecord(checkedLits,Datalog2Algebra,[_head|_lits]),
	!,
	pc_recorded(foundRules,Datalog2Algebra,_ruleids),
	findall(_ruleId,
		(
		 ruleInfo(_ruleId,_,_,_,
					_head,_,_,
					_,_,_),
		\+(memberchk(_ruleId,_ruleids))),
		_rulesReferenced),
	append(_rulesReferenced,_ruleids,_ruleids2),
	pc_rerecord(foundRules,Datalog2Algebra,_ruleids2),
	pc_recorded(newRules,Datalog2Algebra,_newruleids),
	append(_rulesReferenced,_newruleids,_newruleids2),
	pc_rerecord(newRules,Datalog2Algebra,_newruleids2).


findRuleReference(_func,_lit) :-
	functor(_lit,_functor,_n),
	functor(_nlit,_functor,_n),
	buildLit(_func,_nlit,_head),
	pc_recorded(checkedLits,Datalog2Algebra,_lits),
	\+(member(_head,_lits)),
	pc_rerecord(checkedLits,Datalog2Algebra,[_head|_lits]),
	!,
	pc_recorded(foundRules,Datalog2Algebra,_ruleids),
	findall(_ruleId,
			(
		 	 ruleInfo(_ruleId,_,_,_,_head,_,_,_,_,_relAlgExp),
			\+(memberchk(_ruleId,_ruleids))
			),
		_rulesReferenced),
	append(_rulesReferenced,_ruleids,_ruleids2),
	pc_rerecord(foundRules,Datalog2Algebra,_ruleids2),
	pc_recorded(newRules,Datalog2Algebra,_newruleids),
	append(_rulesReferenced,_newruleids,_newruleids2),
	pc_rerecord(newRules,Datalog2Algebra,_newruleids2).


{ catch all }
findRuleReference(_func,_lit).



findRuleReference_LTeval(_functor,In(_x,_class)) :-
	pc_recorded(foundRules,Datalog2Algebra,_ruleids),
	ruleInfo(_ruleId,_,_,_,LTevalQuery(_class,In(_,_)),_body,_,_,_,_),
	\+(memberchk(_ruleId,_ruleids)),
	pc_rerecord(foundRules,Datalog2Algebra,[_ruleId|_ruleids]),
	pc_recorded(newRules,Datalog2Algebra,_newruleids),
	pc_rerecord(newRules,Datalog2Algebra,[_ruleId|_newruleids]).

findRuleReference_LTeval(_functor,In(_x,_class)).



buildLit('',_lit,_lit) :-
	!.

buildLit(_func,_lit,_nlit) :-
	_nlit =.. [_func,_lit],
	!.

{*******************************************************************}
{                                                                   }
{ getRulesForRuleIds(_ruleids,_rules)                               }
{                                                                   }
{ Description of arguments:                                         }
{ ruleids : Liste von Rule IDs                                      }
{   rules : Liste von Regeln in der Form rule(_head,_bodylitliste)  }
{                                                                   }
{ Description of predicate:                                         }
{   Holt zu einer Menge von Ruleids die Regeln                      }
{*******************************************************************}

#MODE((getRulesForRuleIds(i,o)))


getRulesForRuleIds([],[]).

getRulesForRuleIds([_ruleid|_ruleids],[rule(In(_this,_qc),[_qlit])|_rules]) :-
	ruleInfo(_ruleid,_,_,_,LTevalQuery(_qc,In(_this,_)),_body,_,_,_,_),
	!,
	_body = [_ground,_identical,_qlit],
	getRulesForRuleIds(_ruleids,_rules).

getRulesForRuleIds([_ruleid|_ruleids],[rule(_head,_body)|_rules]) :-
	ruleInfo(_ruleid,_,_,_,_head,_body,_,_,_,_),
	getRulesForRuleIds(_ruleids,_rules).




{*******************************************************************}
{                                                                   }
{ stratification(_inrules,_outrules)                                }
{                                                                   }
{ Description of arguments:                                         }
{ inrules : nicht strat. Regeln der Form rule(head,body)            }
{outrules : stratifizierte Regeln als geordnete Multi-Liste         }
{                                                                   }
{ Description of predicate:                                         }
{  Stratifiziert eine Regelmenge                                    }
{  Wieder mit Record-DB implementiert:                              }
{   tobeStratified enthaelt die zu stratifizierenden Regeln         }
{   stratified enthaelt die Regeln die der aktuellen Strata gehoeren}
{   stratMultiList enthaelt die Strata als MultiListe in umgekehrter}
{     Reihenfolge (d.h. oberste Strata zuerst)                      }
{  Idee: Kontrolliere sukzessiv alle Regeln, ob sie auf aktueller   }
{   Strata angeordnet werden koennen, d.h. ob es ein Literal im Body}
{   gibt, das negativ von einem noch nicht stratifizierten Regelkopf}
{   abhaengt.                                                       }
{*******************************************************************}

#MODE((stratification(i,o)))


stratification(_inrules,_outrules) :-
	pc_rerecord(tobeStratified,Datalog2Algebra,_inrules),
	pc_rerecord(stratified,Datalog2Algebra,[]),
	pc_rerecord(stratMultiList,Datalog2Algebra,[]),
	stratification(_inrules),
	pc_recorded(stratMultiList,Datalog2Algebra,_outrules),
	!.

#MODE((stratification(i)))

{ Keine Stratifizierung mehr moeglich -> alles in eine Strata }
stratification([]) :-
	pc_recorded(stratified,Datalog2Algebra,[]),
	!,
	pc_recorded(tobeStratified,Datalog2Algebra,_notstratrules),
	pc_recorded(stratMultiList,Datalog2Algebra,_stratmultilist),
	pc_rerecord(stratMultiList,Datalog2Algebra,[_notstratrules|_stratmultilist]).

stratification([]) :-
	pc_recorded(tobeStratified,Datalog2Algebra,_notstratrules),
	pc_recorded(stratified,Datalog2Algebra,_stratrules),
	subtract(_notstratrules,_stratrules,_restnotstratrules),
	_restnotstratrules == [],
	!,
	pc_recorded(stratMultiList,Datalog2Algebra,_stratmultilist),
	pc_rerecord(stratMultiList,Datalog2Algebra,[_stratrules|_stratmultilist]).

stratification([]) :-
	pc_recorded(stratified,Datalog2Algebra,_stratrules),
	pc_recorded(stratMultiList,Datalog2Algebra,_stratmultilist),
	pc_rerecord(stratMultiList,Datalog2Algebra,[_stratrules|_stratmultilist]),
	pc_recorded(tobeStratified,Datalog2Algebra,_notstratrules),
	subtract(_notstratrules,_stratrules,_restnotstratrules),
	pc_rerecord(tobeStratified,Datalog2Algebra,_restnotstratrules),
	pc_rerecord(stratified,Datalog2Algebra,[]),
	stratification(_restnotstratrules).

stratification([rule(_head,_body)|_rules]) :-
	pc_recorded(tobeStratified,Datalog2Algebra,_notstratrules),
	rulesWithSameHead(_head,_notstratrules,_rulesHead,_rulesWoHead),
	stratumRulesOk(_rulesHead,_rulesWoHead),
	!,
	pc_recorded(stratified,Datalog2Algebra,_stratrules),
	append(_stratrules,_rulesHead,_stratrules2),
	pc_rerecord(stratified,Datalog2Algebra,_stratrules2),
	stratification([]). { Fange direkt mit neuer Stratum an, damit eine Stratum moeglichst klein ist }

stratification([rule(_head,_body)|_rules]) :-
	stratification(_rules).

#MODE((stratumRulesOk(i,i)))



stratumRulesOk([],_rules).

stratumRulesOk([rule(_head,_body)|_rrules],_rules) :-
	stratumOk(_body,_rules),
	stratumRulesOk(_rrules,_rules).


#MODE((stratumOk(i,i)))


stratumOk([],_).

stratumOk([not(_lit)|_lits],_rules) :-
	!,
	checkStratNeg(_lit,_rules),
	!,
	stratumOk(_lits,_rules).

stratumOk([_lit|_lits],_rules) :-
	checkStratPos(_lit,_rules),
	!,
	stratumOk(_lits,_rules).

#MODE((checkStratNeg(i,i)))


checkStratNeg(In(_x,_class),_rules) :-
	!,
	findall(_class,
		({ prove_literal(Isa(_class,_class2)), }
		 member(rule(In(_,_class),_body),_rules)
		),
		_classes),
	_classes == [].


checkStratNeg(Adot_label(_p,_x,_y,_l),_rules) :-
	!,
	checkStratNeg(Adot(_p,_x,_y),_rules).

checkStratNeg(Adot(_p,_,_),_rules) :-
	!,
	\+(member(rule(Adot(_p,_,_),_),_rules)).

checkStratNeg(_lit,_rules) :-
	functor(_lit,_func,_ar),
	functor(_nlit,_func,_ar),
	\+(member(rule(_nlit,_),_rules)).

#MODE((checkStratPos(i,i)))


checkStratPos(In(_x,_class),_rules) :-
	!,
	findall(_body,
		({ prove_literal(Isa(_class,_class2)), }
		 member(rule(In(_,_class),_body),_rules)
		),
		_bodies),
	_bodies = [].

checkStratPos(Adot_label(_p,_x,_y,_l),_rules) :-
	!,
	checkStratPos(Adot(_p,_x,_y),_rules).

checkStratPos(Adot(_p,_,_),_rules) :-
	!,
    findall(_body,
		member(rule(Adot(_p,_,_),_body),_rules),
		_bodies),
	_bodies = [].

checkStratPos(_lit,_rules) :-
	functor(_lit,_func,_ar),
	functor(_nlit,_func,_ar),
	findall(_body,
		member(rule(_nlit,_body),_rules),
		_bodies),
	_bodies = [].



{*******************************************************************}
{                                                                   }
{ unrollRules(_inrules,_outrules)                                   }
{                                                                   }
{ Description of arguments:                                         }
{ inrules : Regeln in der Form rule(head,body)                      }
{outrules : Regeln in der Form rule(head,body)                      }
{                                                                   }
{ Description of predicate:                                         }
{  Rollt Regeln ab, d.h. manche Regeln werden weggelassen und statt-}
{  dessen ihre Ruempfe direkt in den Aufruf gesteckt.               }
{*******************************************************************}

#MODE((unrollRules(i,o)))


unrollRules([_mainrule|_inrules],_outrules) :-
	filterUnrollRules(_inrules,_unrollRules,_restrules),
	insertBodies(_unrollRules,[_mainrule|_restrules],_outrules).




filterUnrollRules([],[],[]).

{ Mur eine Regel mit diesem Kopf }
filterUnrollRules([rule(_head,_body)|_rules],[rule(_head,_body)|_unroll],_rest) :-
	rulesWithSameHead(_head,_rules,_rulesHead,_),
	_rulesHead == [],
	!,
	filterUnrollRules(_rules,_unroll,_rest).

{ Nur ein NegLit im Rumpf }
filterUnrollRules([rule(_head,[not(_lit)])|_rules],_unrollRules2,_rest) :-
	!,
	rulesWithSameHead(_head,_rules,_rulesHead,_restRules),
	!,
	filterUnrollRules(_restRules,_unrollRules,_rest),
	append([rule(_head,[not(_lit)])|_rulesHead],_unrollRules,_unrollRules2).

filterUnrollRules([_rule|_rules],_unroll,[_rule|_rest]) :-
	filterUnrollRules(_rules,_unroll,_rest).

insertBodies(_unroll,[],[]).
insertBodies(_unroll,[rule(_head,_body)|_rules],_newrules2) :-
	unrollBody(_body,_unroll,_newbodies),
	insertBodies(_unroll,_rules,_rest),
	makeRuleWithBodies(_head,_newbodies,_newrules),
	append(_newrules,_rest,_newrules2).

unrollBody([],_,[]).
unrollBody([_lit|_lits],_unroll,_newbodies) :-
	rulesWithSameHead(_lit,_unroll,_rules,_),
	findall(_body,member(rule(_,_body),_rules),_bodies1),
	((_bodies1=[],_bodies=[[_lit]]);
	  _bodies=_bodies1
	),
	unrollBody(_lits,_unroll,_morebodies),
	appendBodies(_bodies,_morebodies,_newbodies).

appendBodies([],_bodies,_bodies).
appendBodies([_body|_bodies],_listOfBodies,_newbodies) :-
	addBodyToBodies(_body,_listOfBodies,_morebodies),
	appendBodies(_bodies,_morebodies,_newbodies).

addBodyToBodies(_body,[],[]).
addBodyToBodies(_body,[_body2|_bodies],[_newbody|_morebodies]) :-
	append(_body,_body2,_newbody),
	addBodyToBodies(_body,_bodies,_morebodies).

makeRuleWithBodies(_head,[],[]).
makeRuleWithBodies(_head,[_body|_bodies],[rule(_head,_body)|_rules]) :-
	makeRuleWithBodies(_head,_bodies,_rules).


{ Findet alle Regeln mit gleichem Kopf (dh. die gleiches Literal folgern koennen) }
rulesWithSameHead(In(_,_class),_rules,_rulesHead,_rulesWoHead) :-
	!,
	findall(rule(In(_x,_class),_body),
		({ prove_literal(Isa(_class,_class2)), }
		 member(rule(In(_x,_class),_body),_rules)
		),
		_rulesHead),
	subtract(_rules,_rulesHead,_rulesWoHead).

rulesWithSameHead(Adot_label(_p,_x,_y,_l),_rules,_rulesHead,_rulesWoHead) :-
	!,
	rulesWithSameHead(Adot(_p,_x,_y),_rules,_rulesHead,_rulesWoHead).

rulesWithSameHead(Adot(_p,_,_),_rules,_rulesHead,_rulesWoHead) :-
	!,
	findall(rule(Adot(_p,_x,_y),_body),
		member(rule(Adot(_p,_x,_y),_body),_rules),
		_rulesHead),
	subtract(_rules,_rulesHead,_rulesWoHead).


rulesWithSameHead(_lit,_rules,_rulesHead,_rulesWoHead) :-
	functor(_lit,_func,_ar),
	functor(_nlit,_func,_ar),
	findall(rule(_nlit,_body),
		member(rule(_nlit,_body),_rules),
		_rulesHead),
	subtract(_rules,_rulesHead,_rulesWoHead).





removeTRUE([],[]).

removeTRUE([rule(_head,_body)|_rules],[rule(_head,_nbody)|_nrules]) :-
	removeTRUEfromBody(_body,_nbody),
	removeTRUE(_rules,_nrules).

removeTRUEfromBody([],[]).
removeTRUEfromBody([TRUE|_lits],_nlits) :-
	!,
	removeTRUEfromBody(_lits,_nlits).

removeTRUEfromBody([_lit|_lits],[_lit|_nlits]) :-
	removeTRUEfromBody(_lits,_nlits).




