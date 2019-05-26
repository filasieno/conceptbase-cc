{*
The ConceptBase.cc Copyright

Copyright 1987-2019 The ConceptBase Team. All rights reserved.

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
*}
{*
*
* File 		: ViewEvaluator.pro
* Version	: 11.1
* Creation	: 23-May-95,  Christoph Quix (RWTH)
* Last change : 10/11/96, Christoph Quix (RWTH)
* Release	: 11
*
*-----------------------------------------------
*
* NF2-like algebra to transform the query answer relations
* into nested frames
*}

#MODULE(ViewEvaluator)
#EXPORT(evaluate_view/3)
#EXPORT(evaluate_view_wo_mat/3)
#EXPORT(evaluate_views/3)
#ENDMODDECL()


#IMPORT(member/2,GeneralUtilities)
#IMPORT(append/3,GeneralUtilities)
#IMPORT(nth1/4,GeneralUtilities)
#IMPORT(is_list/1,GeneralUtilities)
#IMPORT(setUnion/3,GeneralUtilities)
#IMPORT(length/2,GeneralUtilities)
#IMPORT(nmembers/3,GeneralUtilities)
#IMPORT(makeset/2,GeneralUtilities)
#IMPORT(subst/3,GeneralUtilities)
#IMPORT(evaluate_queries/4,QueryEvaluator)
#IMPORT(get_QueryStruct/2,QueryCompiler)
#IMPORT(get_ViewArgExp/3,ViewCompiler)
#IMPORT(name2id/2,GeneralUtilities)
#IMPORT(appendBuffer/2,ExternalCodeLoader)
#IMPORT(transform_view_answer/4,AnswerTransformator)
#IMPORT(WriteListOnTrace/2,GeneralUtilities)
#IMPORT(pc_atomconcat/2,PrologCompatibility)
#IMPORT(pc_atomconcat/3,PrologCompatibility)
#IMPORT(pc_recorded/2,PrologCompatibility)
#IMPORT(pc_recorded/3,PrologCompatibility)
#IMPORT(pc_atom_to_term/2,PrologCompatibility)
#IMPORT(pc_time/2,PrologCompatibility)

#IF(SWI)
:- style_check(-singleton).
#ENDIF(SWI)


{===========================================================}
{=              LOCAL PREDICATE DECLARATION                =}
{===========================================================}


{===========================================================}
{=             EXPORTED PREDICATES DEFINITION              =}
{===========================================================}

evaluate_views([],_ansrep,_ans).

evaluate_views([_v|_r],_ansrep,_ans) :-
	evaluate_view(_v,_ansrep,_ans),
	evaluate_views(_r,_ansrep,_ans).

{evaluate_views([_v|_r],_ansrep,_ans2) :-
	evaluate_view(_v,_ansrep,_ans),
	evaluate_views(_r,_ansrep,_rans),
	pc_atomconcat([_ans,'\n',_rans],_ans2).}

evaluate_view(_dexp,_ansrep,_ans) :-
	evaluate_view_mat(_dexp,_ansrep,_ans),
	!.

evaluate_view(_dexp,_ansrep,_ans) :-
	evaluate_view_wo_mat(_dexp,_ansrep,_ans),
	!.

evaluate_view_mat(_dexp,VIEW,_ans) :-
	pc_atom_to_term(_atomdexp,_dexp),
	pc_recorded(_atomdexp,ViewMonitor,view(_qid,_dexp,_qgoals,_ruleids,_vmtype,_ans)),
	!.

evaluate_view_wo_mat(derive(_v,_slist),_ansrep,_ans) :-
	!,
	name2id(_v,_vid),
	get_ViewArgExp(_vid,_argexp,_nfexp),
	subst((_vid=derive(_vid,_slist)),_nfexp,_nfexpWithDerive),
	pc_time((do_algebra(_nfexpWithDerive,_sol),
    transform_view_answer(_sol,_argexp,_ansrep,_ans)),_t),
    WriteListOnTrace(low,['   ... ',_t, ' sec used to evaluate view']).


evaluate_view_wo_mat(_v,_ansrep,_ans) :-
	name2id(_v,_vid),
	get_ViewArgExp(_vid,_argexp,_nfexp),
	pc_time((do_algebra(_nfexp,_sol),
    transform_view_answer(_sol,_argexp,_ansrep,_ans)),_t),
    WriteListOnTrace(low,['   ... ',_t, ' sec used to evaluate view']).


do_algebra(join(_cond,_rel1,_rel2), _newrel) :-
	!,
	do_algebra(_rel1,_newrel1),
	do_algebra(_rel2,_newrel2),
	do_join(_cond,_newrel1,_newrel2,_newrel).

do_algebra(xjoin(_cond,_pos,_rel1,_rel2), _newrel) :-
	!,
	do_algebra(_rel1,_newrel1),
	do_algebra(_rel2,_newrel2),
	do_xjoin(_cond,_pos,_newrel1,_newrel2,_newrel).

do_algebra(leftouterjoin(_cond,_args,_rel1,_rel2), _newrel) :-
	!,
	do_algebra(_rel1,_newrel1),
	do_algebra(_rel2,_newrel2),
	do_leftouterjoin(_cond,_args,_newrel1,_newrel2,_newrel).

do_algebra(proj(_ns,_rel),_newrel) :-
	!,
	do_algebra(_rel,_rel2),
	do_projection(_ns,_rel2,_newrel).

do_algebra(fill(_ns,_rel),_newrel) :-
	!,
	do_algebra(_rel,_rel2),
	do_fill(_ns,_rel2,_newrel).

do_algebra(nest(_ns,_rel),_newrel) :-
	!,
	do_algebra(_rel,_rel2),
	do_nest(_ns,_rel2,_newrel).

do_algebra(xnest(_ns,_rel),_newrel) :-
	!,
	do_algebra(_rel,_rel2),
	do_xnest(_ns,_rel2,_newrel).

do_algebra(union(_rel1,_rel2),_newrel) :-
	!,
	do_algebra(_rel1,_newrel1),
	do_algebra(_rel2,_newrel2),
	do_union(_newrel1,_newrel2,_newrel).

do_algebra(_rel,_rel) :-
	is_list(_rel),!.

do_algebra(derive(_q,_slist),_qans) :-
	atom(_q),
	get_QueryStruct(_q,_qs),
	!,
	evaluate_queries([derive(_q,_slist)],[solution(_,_qans)],Now,newOB).

do_algebra(_q,_qans) :-
	atom(_q),
	get_QueryStruct(_q,_qs),
	!,
	evaluate_queries([_q],[solution(_q,_qans)],Now,newOB).


{===========================================================}
{=                LOCAL PREDICATES DEFINITION              =}
{===========================================================}

{***********************************************************}
{ do_join(_cond,_rel1,_rel2,_newrel)                        }
{                                                           }
{   Natuerlicher Join zwischen _rel1 und _rel2, d.h.        }
{   Join-Attribut faellt bei zweiter Relation weg, und      }
{   Attribute von _rel2 werden hinten angehaengt.           }
{                                                           }
{***********************************************************}

do_join(_cond, [],_rel2, [] ):-!.

do_join(_cond, [_h|_t], _rel2 , _outrel ) :-
	setof(_y,(member(_y,_rel2),check_cond(_cond,_h,_y)),_ys),
	do_join2(_cond,_h,_ys,_newhs),
	!,
	do_join(_cond,_t,_rel2,_newrel),
	append(_newhs,_newrel,_outrel).

{ Zu _h wurde kein passendes Tupel gefunden -> weg damit }
do_join(_cond, [_h|_t], _rel2, _newrel) :-
	do_join(_cond,_t,_rel2,_newrel),!.


do_join2(_cond,_h,[],[]):-!.
do_join2(_cond,_h,[_y|_ys],[_newh|_newhs]) :-
	_h =.. _hlist,
	_y =.. [_op|_ylist],
	functor(_y,_,_ar),
	get_all_args(2,_cond,_ns),
	invert_int_list(_ns,_ar,_invns),
	nmembers(_invns,_ylist,_newylist),
	append(_hlist,_newylist,_newhlist),
	_newh =.. _newhlist,
	do_join2(_cond,_h,_ys,_newhs).


check_cond([],_,_).
check_cond([equal(_n1,_n2)|_conds],_t1,_t2):-
	arg(_n1,_t1,_arg),
	arg(_n2,_t2,_arg),
	check_cond(_conds,_t1,_t2).


get_all_args(_n,[],[]).
get_all_args(_n,[_h|_list],[_arg|_arglist]) :-
	arg(_n,_h,_arg),
	get_all_args(_n,_list,_arglist).

{***********************************************************}
{ do_xjoin(_cond,_pos,_rel1,_rel2,_newrel)                  }
{                                                           }
{   Erweiterter Join zwischen _rel1 und _rel2, d.h.         }
{   Attribut _pos in _rel1 wird durch Tupel aus _rel2       }
{   ersetzt, wenn Join-Bedingung erfuellt ist.              }
{                                                           }
{***********************************************************}

do_xjoin(_cond,_pos, [],_rel2, [] ):-!.

do_xjoin(_cond,_pos, [_h|_t], _rel2 , _outrel ) :-
	setof(_y,(member(_y,_rel2),check_cond(_cond,_h,_y)),_ys),
	do_xjoin2(_pos,_h,_ys,_newhs),
	!,
	do_xjoin(_cond,_pos,_t,_rel2,_newrel),
	append(_newhs,_newrel,_outrel).

{ Zu _h wurde kein passendes Tupel gefunden -> weg damit }
do_xjoin(_cond,_pos, [_h|_t], _rel2, _newrel) :-
	do_xjoin(_cond,_pos,_t,_rel2,_newrel),!.


do_xjoin2(_pos,_h,[],[]):-!.
do_xjoin2([_pos],_h,[_y|_ys],[_newh|_newhs]) :-
	functor(_h,_op,_ar),
	invert_int_list([_pos],_ar,_invns),
	make_nest_term(_invns,_h,_newh),
	arg(_pos,_newh,_y),
	do_xjoin2([_pos],_h,_ys,_newhs).

{ xjoin mit zwei Positionsargumenten, um retr.attributes,
* die SubViews sind, mit Labeln zu joinen }
do_xjoin2([_pos,_pos2],_h,[_y|_ys],[_newh|_newhs]) :-
	functor(_h,_op,_ar),
	invert_int_list([_pos,_pos2],_ar,_invns),
	make_xjoin_term(_invns,_pos2,_h,_newh),
	_y =.. [_func|_arglist],
	arg(_pos2,_h,_addarg),
	_newy =.. [_func,_addarg|_arglist],
	((_pos < _pos2,
	  _pos1 = _pos
	 );
	 (_pos > _pos2,
	  _pos1 is _pos - 1
	 )
	),
	arg(_pos1,_newh,_newy),
	do_xjoin2([_pos,_pos2],_h,_ys,_newhs).


make_xjoin_term(_ns,_pos2,_h,_newh) :-
	functor(_h,_op,_ar),
	_ar1 is _ar - 1 ,
	functor(_newh,_op,_ar1),
	make_xjoin_term2(_ns,_pos2,_h,_newh).

make_xjoin_term2([],_pos2,_h,_newh).
make_xjoin_term2([_n|_ns],_pos2,_h,_newh) :-
	((_n < _pos2,
	  _n1 = _n
	 );
	 (_n > _pos2,
	  _n1 is _n - 1
	 )
	),
	arg(_n,_h,_arg),
	arg(_n1,_newh,_arg),
	make_xjoin_term2(_ns,_pos2,_h,_newh).


{***********************************************************}
{ do_leftouterjoin(_condlist,_args,_rel1,_rel2,_newrel)     }
{                                                           }
{   LeftOuter-Join zwischen _rel1 und _rel2, d.h.           }
{   Join-Attribut faellt bei zweiter Relation weg, und      }
{   Attribute von _rel2 werden hinten angehaengt.           }
{   Falls Elemente aus _rel1 gibt, fuer die                 }
{   die Join-Bedingung nicht  erfuellt ist, werden diese    }
{   trotzdem in _newrel aufgenommen, mit [] als Element     }
{   in den Attributen der anderen Relation.                 }
{   _args ist eine Integer-Liste mit zwei Elementen, die    }
{   die Stelligkeit der beiden Relationen angeben.          }
{                                                           }
{***********************************************************}

do_leftouterjoin(_cond, _args, [],_rel2,[]):-!.

do_leftouterjoin(_cond, _args, [_h|_t], _rel2 , _outrel ) :-
	setof(_y,(member(_y,_rel2),check_cond(_cond,_h,_y)),_ys),
	do_join2(_cond,_h,_ys,_newhs), { wenn etwas gefunden wurde, joine genauso wie bei normalen Join }
	!,
	do_leftouterjoin(_cond,_args,_t,_rel2,_newrel),
	append(_newhs,_newrel,_outrel).

{ Zu _h wurde kein passendes Tupel gefunden -> auffuellen mit [] }
do_leftouterjoin(_cond, [_num1,_num2],[_h|_t], _rel2, [_newh|_newrel]) :-
	_min is _num1 + 1 ,
	length(_cond,_n),
	_max is _num2 + _num1 - _n,
	make_int_list(_min,_max,_intlist),
	do_fill(_intlist,[_h],[_newh]),
	do_leftouterjoin(_cond,[_num1,_num2],_t,_rel2,_newrel),
	!.


{***********************************************************}
{ do_projection(_elemlist,_rel,_newrel)                     }
{                                                           }
{   Projektion von _rel auf die Attribute aus _elemlist     }
{   Wichtig: Wenn in elemlist Werte vorkommen, die groesser }
{    als die Stelligkeit von _rel sind, scheitert die Proj. }
{                                                           }
{***********************************************************}

do_projection(_ns,[_h|_rel],[_newh|_newrel]) :-
	_h =.. [_op|_hlist],
	nmembers(_ns,_hlist,_rest),
	_newh =.. [_op|_rest],
	do_projection(_ns,_rel,_newrel).

do_projection(_ns,[],[]):-!.

{***********************************************************}
{ do_fill(_ns,_rel,_newrel)                                 }
{                                                           }
{   Fuellt die Attribute _ns mit [] auf. Reihenfolge bei    }
{   den _ns ist zu beachten!                                }
{                                                           }
{***********************************************************}

do_fill(_ns,[_h|_rel],[_newh|_newrel]) :-
	_h =.. [_op|_hlist],
	do_fill2(_ns,_hlist,_newhlist),
	_newh =.. [_op|_newhlist],
	!,
	do_fill(_ns,_rel,_newrel).

do_fill(_ns,[],[]):-!.

do_fill2([_n1|_ns], _hlist, _newhlist) :-
	ninsert(_n1,[],_hlist,_hl2),
	do_fill2(_ns,_hl2,_newhlist).

do_fill2([],_l,_l):-!.


{***********************************************************}
{ do_nest(_ns,_rel,_newrel)                                 }
{                                                           }
{   Nested eine Relation _rel ueber die Attribute _ns.      }
{   Wenn ueber mehrere Attribute genested wird, so werden   }
{   diese zu einer Relation op(a1,a2,...) zusammengefasst.  }
{   (Wird ueber nur ein Attribut genested, dann ist das Er-  }  { Stimmt nicht mehr }
{   gebnis eine einfache Liste.)                             }
{   Das resultierende Nest-Attribut wird immer am Ende der  }
{   Relation eingefuegt. Die Attribute ueber die genested   }
{   wird, werden geloescht.                                 }
{                                                           }
{   _ns sind die Attribute, ueber die NICHT genestet wird!!!}
{                                                           }
{***********************************************************}

do_nest(_ns,[],[]):-!.

do_nest(_ns,[_h|_rel],[_nestelem|_newrel]) :-
	functor(_h,_op,_arity),
	invert_int_list(_ns,_arity,_invns),
	make_nest_term(_ns,_h,_newh),
	setof(_newh,member(_newh,[_h|_rel]),_hlist),
	list_diff([_h|_rel],_hlist,_restrel),
	!,
	do_nest2(_invns,_hlist,_nestelem),
	do_nest(_ns,_restrel,_newrel),
	!.


do_nest2([],_list,_elem) :-
	member(_elem,_list),!.

{ Nesten ueber mehrere Attribute => Sub-Attribute werden mit einem Funktor zusammengefasst }
do_nest2(_ns,_list,_nestelem) :-
	_ns = [_|_],
	do_projection(_ns,_list,_newlist),
	member(_x,_list),
	!,
	functor(_x,_op,_arity),
    invert_int_list(_ns,_arity,_invns),
	do_projection(_invns,[_x],[_newx]),
	_newx =.. _xlist,
	append(_xlist,[_newlist],_newxlist),
	_nestelem =.. _newxlist,
	!.

{ Nesten ueber ein Attribut ==> packe Ergebnisse in eine Liste ohne Funktor}
{do_nest2(_ns,_list,_nestelem) :-
	_ns = [_n],
	setof(_arg,(member(_y,_list),
				arg(_n,_y,_arg)
			   ),
		  _arglist),
	member(_x,_list),
	functor(_x,_op,_arity),
    invert_int_list(_ns,_arity,_invns),
	do_projection(_invns,[_x],[_newx]),	_newx =.. _xlist,
	append(_xlist,[_arglist],_newxlist),
	_nestelem =.. _newxlist.}


make_nest_term(_ns,_h,_newh) :-
	functor(_h,_op,_arity),
	functor(_newh,_op,_arity),
	make_nest_term2(_ns,_h,_newh).

make_nest_term2([],_h,_newh):-!.

make_nest_term2([_n1|_ns],_h,_newh) :-
	arg(_n1,_h,_arg1),
	arg(_n1,_newh,_arg1),
	make_nest_term2(_ns,_h,_newh).

{***********************************************************}
{ do_xnest(_ns,_rel,_newrel)                                }
{                                                           }
{   Alle Attribute, die nicht in  _ns sind, werden zu Mengen zusammen-        }
{   gefasst. Im Gegensatz zu normalen nest werden mehrere   }
{   Attribute nicht zu einem Tupel zusammengefasst.         }
{   Sind die Attribute schon Mengen, dann werden die Mengen }
{   vereinigt.                                              }
{                                                           }
{***********************************************************}

do_xnest(_ns,[],[]).

do_xnest(_ns,[_h|_rel],[_newh|_newrel]) :-
	functor(_h,_op,_ar),
	invert_int_list(_ns,_ar,_ins),
	make_nest_term(_ns,_h,_newh),
	setof(_newh,member(_newh,[_h|_rel]),_hlist),
	list_diff([_h|_rel],_hlist,_restrel),
	!,
	do_xnest2(_ins,_hlist,_newh),
	do_xnest(_ns,_restrel,_newrel).

do_xnest2([],_list,_nestelm).

do_xnest2([_n|_ns],_list,_nestelem) :-
	setof(_arg,[_h]^(member(_h,_list),arg(_n,_h,_arg)),_arglist),
	multi_union(_arglist,_arglist2),
	arg(_n,_nestelem,_arglist2),
	do_xnest2(_ns,_list,_nestelem).


multi_union(_in,_out) :-
	multi_union2(_in,_out1),
	!,
	makeset(_out1,_out).

multi_union2([],[]).
multi_union2([_h|_t],_out) :-
	is_list(_h),
	!,
	multi_union2(_t,_nt),
	append(_h,_nt,_out).

multi_union2([_h|_t],_out) :-
	multi_union2(_t,_nt),
	append([_h],_nt,_out).

{***********************************************************}
{ do_union(_ns,_rel,_newrel)                                }
{                                                           }
{   Vereinigung ueber geschachtelte Relationen. Wenn ein    }
{   Attribut eine Menge ist, werden die Mengen der Tupel,   }
{   wo der Rest gleich ist, vereinigt.                      }
{                                                           }
{***********************************************************}

do_union([],[],[]):-!.

do_union(_rel1,_rel2,[_newterm|_newrel]) :-
	setUnion(_rel1,_rel2,[_h|_rel3]),
	get_list_args(_h,1,_ns),
	functor(_h,_op,_arity),
	invert_int_list(_ns,_arity,_invns),
	make_nest_term(_invns,_h,_newh),
	copy_term(_newh,_newterm),
	findall(_newh,member(_newh,[_h|_rel3]),_newhlist),
	list_diff([_h|_rel3],_newhlist,_restrel),
	!,
	do_union2(_ns,_newhlist,_newterm),
	do_union(_restrel,[],_newrel).

do_union2([],_rel,_newterm):-!.

do_union2([_n|_ns],_rel,_newterm) :-
	get_arglist_n(_n,_rel,_arglist),
	arg(_n,_newterm,_arglist),
	do_union2(_ns,_rel,_newterm).

get_list_args(_f,_n,[_n|_ns]) :-
	arg(_n,_f,_l),
	is_list(_l),
	_n1 is _n + 1,
	get_list_args(_f,_n1,_ns).

get_list_args(_f,_n,_ns) :-
	arg(_n,_f,_l),
	not(is_list(_l)),
	_n1 is _n + 1,
	get_list_args(_f,_n1,_ns).

get_list_args(_f,_n,[]) :-
	functor(_f,_op,_arity),
	_arity =< _n.


get_arglist_n(_n,[],[]).

get_arglist_n(_n,[_h|_t],_arglist) :-
	arg(_n,_h,_arglist1),
	get_arglist_n(_n,_t,_arglist2),
	setUnion(_arglist1,_arglist2,_arglist).

{***********************************************************}
{ ninsert(_n,_elem,_list1,_list2)                           }
{                                                           }
{   Fuege an _n-ter Stelle in Liste _list1 das Element      }
{   _elem ein. Ergebnis: _list2.                            }
{   Wenn _n > len(_list1), dann wird _elem am Ende der      }
{   Liste eingefuegt.                                       }
{                                                           }
{***********************************************************}

ninsert(1,_elem,_list,[_elem|_list]) .

ninsert(_n,_elem,[_h|_t],[_h|_newt]) :-
	_n > 1,
	_n1 is _n - 1,
	ninsert(_n1,_elem,_t,_newt).

ninsert(_n,_elem,[],[_elem]).





invert_int_list(_ns,_max,_invns) :-
	make_int_list(_max,_maxlist),
	list_diff(_maxlist,_ns,_invns).


list_diff([_x|_l],_d,_r) :-
	member(_x,_d),
	list_diff(_l,_d,_r).

list_diff([_x|_l],_d,[_x|_r]) :-
	not(member(_x,_d)),
	list_diff(_l,_d,_r).

list_diff([],_d,[]) :- !.


make_int_list(_max,_list) :-
	make_int_list(1,_max,_list).

make_int_list(_max,_max,[_max]).

make_int_list(_min,_max,_intlist) :-
	_max > _min,
	_max1 is _max - 1,
	make_int_list(_min,_max1,_t),
	append(_t,[_max],_intlist).




{ ?- lib(lists),lib(listut). }


{ Zum testen
do_algebra([q(a,b,c)],_rel).
do_algebra(join([equal(1,2)],[q(a,b,c),q(b,c,d)],[q(b,a),q(x,b)]),_newrel).
do_algebra(xjoin([equal(2,1)],2,[q(a,b,c),q(b,x,d)],[q(b,a),q(x,b)]),_newrel).
do_algebra(leftouterjoin([equal(1,2)],[q(a,b,c),q(b,c,d)],[q(b,a),q(x,b)]),_newrel).
do_algebra(leftouterjoin([equal(1,2)],[q(a,b,c),q(b,c,d),q(f,g,h)],[q(b,a),q(x,b)]),_newrel).
do_algebra(proj([1,2],[q(a,b,c),q(b,c,d),q(b,a),q(x,b)]),_newrel).
do_algebra(fill([2,5],[q(a,b,c),q(b,c,d),q(b,a),q(x,b)]),_newrel).
do_algebra(nest([2,3],[q(a,b,c),q(b,c,d),q(b,a,c),q(x,b,c)]),_newrel).
do_algebra(nest([2],[q(a,b,c),q(b,c,d),q(b,a,c),q(x,b,c)]),_newrel).
do_algebra(xnest([2],[q(a,b,c),q(b,c,d),q(b,a,c),q(x,b,c)]),_newrel).
do_algebra(xnest([1],[q(a,[b],c),q(b,c,d),q(b,[a],c),q(x,b,c)]),_newrel).
do_algebra(union([q(a,b,[c]),q(b,c,[d]),q(b,a,[c,qx]),q(x,b,[c])],[q(a,b,[d])]),_newrel).
do_algebra(union([q(a,b,[c]),q(b,c,[d]),q(b,c,[d,qx]),q(x,b,[c])],[q(a,b,[d])]),_newrel).
do_algebra(union(fill([3],[q(a,x),q(d,c)]),union([q(a,b,[c]),q(b,c,[d]),q(b,c,[d,qx]),q(x,b,[c])],[q(a,b,[d])])),_newrel).
}
