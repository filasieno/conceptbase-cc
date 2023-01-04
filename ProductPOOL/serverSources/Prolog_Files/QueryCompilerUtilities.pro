{*
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
*}
{*
* File:         %M%
* Version:      %I%
* Creation:     31-Jan-1996, Christoph Quix (RWTH)
* Last Change   : %E%, Christoph Quix (RWTH)
*
* SCCS-Source-Pool : %P%
* Date retrieved : %D% (YY/MM/DD)

* --------------------------------------------------------------------------
*
* Dieses Modul enthaelt einige Hilfspraedikate fuer QueryCompiler,
* SubQueryCompiler und ViewCompiler.
*}

#MODULE(QueryCompilerUtilities)
#EXPORT(build_leftouterjoins/5)
#EXPORT(build_nest/4)
#EXPORT(build_nest_rattr/4)
#EXPORT(build_param/4)
#EXPORT(build_xjoin/6)
#EXPORT(build_xjoin_argexp/4)
#EXPORT(build_xnest/4)
#EXPORT(check_if_param/4)
#EXPORT(get_QCjoincond/1)
#EXPORT(get_arg_pos/3)
#EXPORT(insert_this_par_join/3)
#EXPORT(partofQuery/3)
#EXPORT(project_out_parclasses/5)
#EXPORT(store_QCjoincond/1)
#EXPORT(subquery/3)
#ENDMODDECL()


#IMPORT(prove_literal/1,Literals)
#IMPORT(retrieve_proposition/1,PropositionProcessor)
#IMPORT(pc_member/2,PrologCompatibility)
#IMPORT(replace/4,GeneralUtilities)
#IMPORT(append/3,GeneralUtilities)
#IMPORT(name2id/2,GeneralUtilities)
#IMPORT(store_tmp_PROLOGrules/1,PROLOGruleProcessor)
#IMPORT(get_tmp_PROLOGrules/1,PROLOGruleProcessor)
#IMPORT(QCsubquery/4,QueryCompiler)
#IMPORT(QCparam/3,QueryCompiler)
#IMPORT(createNewVarname/1,QueryCompiler)
#IMPORT(pc_has_a_definition/1,PrologCompatibility)
#IMPORT(pc_atomconcat/2,PrologCompatibility)
#IMPORT(pc_atomconcat/3,PrologCompatibility)
#IMPORT(pc_atom_to_term/2,PrologCompatibility)

#IF(SWI)
:- style_check(-singleton).
#ENDIF(SWI)




{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
{Hilfspraedikate fuer SubQueryCompiler                    }
{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

#MODE((build_param(i,o,o,o)))

build_param([],[],[],[]).

build_param([p(_p,_C)|_rest],
		[lit(In(_atp,_C))|_rlits],
		[(_atp,_C),(_pc,_propid)|_rvt],
		[p(_p,_C)|_rargs]) :-
	pc_atomconcat('~',_p,_atp),
	createNewVarname(_pc),
	name2id(Proposition,_propid),
	build_param(_rest,_rlits,_rvt,_rargs).


#MODE((check_if_param(i,i,o,o)))

check_if_param(_dl,_q,_l1,_l2) :-
	findall(res(p(_p,_C),equal(_p,_for)),
			(QCparam(_q,_atp,_C),pc_atomconcat('~',_p,_atp),pc_member(substitute(_atp,_for),_dl)),
			_h1),
	split_res(_h1,_l1,_l2).

#MODE((split_res(i,o,o)))

split_res([],[],[]).
split_res([res(_e1,_e2)|_rest],[_e1|_r1],[_e2|_r2]) :-
	split_res(_rest,_r1,_r2).

#MODE((insert_this_par_join(i,i,o)))

insert_this_par_join([],_js,_js).
insert_this_par_join([substitute('~this',_for)|_r],_js,[equal(this,_for)|_njs]) :-
	!,
	insert_this_par_join(_r,_js,_njs).

insert_this_par_join([_h|_r],_js,_njs) :-
	insert_this_par_join(_r,_js,_njs).



{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
{Hilfspraedikate fuer ViewCompiler                        }
{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

#MODE((project_out_parclasses(i,i,i,o,o)))

project_out_parclasses(_argexp,_nfexp,_joincond,_newargexp,proj(_projlist,_nfexp)) :-
	project_out_parclasses2(0,_argexp,_joincond,_newargexp,_projlist).

#MODE((project_out_parclasses2(i,i,i,o,o)))

project_out_parclasses2(_n,[],_joincond,[],[]).

project_out_parclasses2(_n,[this|_r],_joincond,[this|_nr],[_n1|_projlist]) :-
	_n1 is _n + 1 ,
	project_out_parclasses2(_n1,_r,_joincond,_nr,_projlist).

project_out_parclasses2(_n,[p(_p,_c)|_r],_joincond,[ps(_p)|_nr],[_n1|_projlist]) :-
	pc_member(_t,_joincond),
	arg(2,_t,_p),
	!,
	_n1 is _n + 1 ,
	_n2 is _n + 2 ,
	project_out_parclasses2(_n2,_r,_joincond,_nr,_projlist).

project_out_parclasses2(_n,[p(_p,_c)|_r],_joincond,[p(_p,_c)|_nr],[_n1,_n2|_projlist]) :-
	_n1 is _n + 1 ,
	_n2 is _n + 2 ,
	project_out_parclasses2(_n2,_r,_joincond,_nr,_projlist).

project_out_parclasses2(_n,[cp(_p,_c)|_r],_joincond,[cps(_p)|_nr],[_n1|_projlist]) :-
	pc_member(_t,_joincond),
	arg(2,_t,_p),
	!,
	_n1 is _n + 1 ,
	_n2 is _n + 2 ,
	project_out_parclasses2(_n2,_r,_joincond,_nr,_projlist).

project_out_parclasses2(_n,[cp(_p,_c)|_r],_joincond,[cp(_p,_c)|_nr],[_n1,_n2|_projlist]) :-
	_n1 is _n + 1 ,
	_n2 is _n + 2 ,
	project_out_parclasses2(_n2,_r,_joincond,_nr,_projlist).

project_out_parclasses2(_n,[rp(_p,_c)|_r],_joincond,[rps(_p)|_nr],[_n1,_n2|_projlist]) :-
	pc_member(_t,_joincond),
	arg(2,_t,_p),
	!,
	_n1 is _n + 1 ,
	_n2 is _n + 2 ,
	_n3 is _n + 3 ,
	project_out_parclasses2(_n3,_r,_joincond,_nr,_projlist).

project_out_parclasses2(_n,[rp(_p,_c)|_r],_joincond,[rp(_p,_c)|_nr],[_n1,_n2,_n3|_projlist]) :-
	_n1 is _n + 1 ,
	_n2 is _n + 2 ,
	_n3 is _n + 3 ,
	project_out_parclasses2(_n3,_r,_joincond,_nr,_projlist).

project_out_parclasses2(_n,[r(_x)|_r],_joincond,[r(_x)|_nr],[_n1,_n2|_projlist]) :-
	_n1 is _n + 1 ,
	_n2 is _n + 2 ,
	project_out_parclasses2(_n2,_r,_joincond,_nr,_projlist).

project_out_parclasses2(_n,[c(_x)|_r],_joincond,[c(_x)|_nr],[_n1|_projlist]) :-
	_n1 is _n + 1 ,
	project_out_parclasses2(_n1,_r,_joincond,_nr,_projlist).

project_out_parclasses2(_n,[set(_x)|_r],_joincond,[set(_x)|_nr],[_n1|_projlist]) :-
	_n1 is _n + 1 ,
	project_out_parclasses2(_n1,_r,_joincond,_nr,_projlist).


{** PROJEKTION **}
#MODE((build_proj(i,i,i,o)))

build_proj(_arglist,_subv,_argexp,proj(_narglist,_subv)) :-
	replace_proj_args(_arglist,_argexp,_narglist).

#MODE((replace_proj_args(i,i,o)))

replace_proj_args([],_,[]).
replace_proj_args([_arg|_rarg],_argexp,[_i|_is]) :-
	get_arg_pos(_arg,_argexp,_i),
	replace_proj_args(_rarg,_argexp,_is).


{** JOIN **}
#MODE((build_join(i,i,i,i,i,o)))

build_join(_q1,_qae1,_q2,_qae2,_condlist,join(_ncondlist,_q1,_q2)) :-
	replace_join_args(_qae1,_qae2,_condlist,_ncondlist).


{** XJOIN **}
#MODE((build_xjoin(i,i,i,i,i,o)))

build_xjoin(_q1,_qae1,_q2,_qae2,_condlist,xjoin(_ncondlist,[_pos,_pos1],_q1,_q2)) :-
	replace_join_args(_qae1,_qae2,_condlist,_ncondlist),
	pc_member(equal(_attr,this),_condlist),
	pc_member(r(_attr),_qae1),
	!,
	get_arg_pos(_attr,_qae1,_pos),
	_pos1 is _pos - 1 .


build_xjoin(_q1,_qae1,_q2,_qae2,_condlist,xjoin(_ncondlist,[_pos],_q1,_q2)) :-
	replace_join_args(_qae1,_qae2,_condlist,_ncondlist),
	pc_member(equal(_attr,this),_condlist),
	!,
	get_arg_pos(_attr,_qae1,_pos).


#MODE((replace_join_args(i,i,i,o)))

replace_join_args(_,_,[],[]).

replace_join_args(_qae1,_qae2,[equal(_arg1,_arg2)|_rest],[equal(_i1,_i2)|_nrest]) :-
	get_arg_pos(_arg1,_qae1,_i1),
	get_arg_pos(_arg2,_qae2,_i2),
	replace_join_args(_qae1,_qae2,_rest,_nrest).


#MODE((get_arg_pos(i,i,o)))

{ Hole die Position eines Argument in einem Query-Kopf }
get_arg_pos(WANT_NUMBER_OF_ARGUMENTS,[],0). { Ein Hack, damit auch die Anzahl der Argumente erhalten kann }

get_arg_pos(_arg,[_arg|_rest],1) :- !.
get_arg_pos(_arg,[r(_arg)|_rest],2):- !.
get_arg_pos(_arg,[rp(_arg,_c)|_rest],2):- !.
get_arg_pos(_arg,[c(_arg)|_rest],1):- !.
get_arg_pos(_arg,[cp(_arg,_c)|_rest],1):- !.
get_arg_pos(_arg,[p(_arg,_c)|_rest],1):- !.
get_arg_pos(_arg,[rps(_arg)|_rest],2):- !.
get_arg_pos(_arg,[cps(_arg)|_rest],1):- !.
get_arg_pos(_arg,[ps(_arg)|_rest],1):- !.
{get_arg_pos(_arg,[set(_s)|_rest],1):- !.} { Keine Vergleiche von Menge-Attributen }

get_arg_pos(_arg,[_x|_rest],_n) :-
	(_x = c(_y);
	 _x = ps(_y);
	 _x = cps(_y);
	 _x = set(_y);
	 _x = this
	),
	_y \== _arg,
	!,
	get_arg_pos(_arg,_rest,_n2),
	_n is _n2 + 1 .

get_arg_pos(_arg,[_x|_rest],_n) :-
	(_x = r(_y);
	 _x = rps(_y);
	 _x = cp(_y,_c);
	 _x = p(_y,_c)
	),
	_y \== _arg,
	!,
	get_arg_pos(_arg,_rest,_n2),
	_n is _n2 + 2 .

get_arg_pos(_arg,[_x|_rest],_n) :-
    _x = rp(_y,_c),
	_y \== _arg,
	!,
	get_arg_pos(_arg,_rest,_n2),
	_n is _n2 + 3 .

{** ArgExp fuer Join bauen **}
#MODE((build_join_argexp(i,i,i,o)))

build_join_argexp(_qae1,[],_joincond,_qae1).
build_join_argexp(_qae1,[this|_r],_joincond,_joinargexp) :-
	pc_member(equal(_x,this),_joincond),
	!,
	build_join_argexp(_qae1,_r,_joincond,_joinargexp).

build_join_argexp(_qae1,[_t|_r],_joincond,_joinargexp) :-
	functor(_t,_op,_ar),
	pc_member(_op,[p,r,c,rp,cp,ps,rps,cps]),
	arg(1,_t,_arg),
	pc_member(equal(_x,_arg),_joincond),
	!,
	build_join_argexp(_qae1,_r,_joincond,_joinargexp).

build_join_argexp(_qae1,[_t|_r],_joincond,_joinargexp) :-
	_t \== this,
	build_join_argexp(_qae1,_r,_joincond,_joinargexp1),
	append(_joinargexp1,[_t],_joinargexp).

{** ArgExp fuer XJoin bauen **}
#MODE((build_xjoin_argexp(i,i,i,o)))

build_xjoin_argexp(_qae1,_qae2,_joins,_joinargexp) :-
	pc_member(equal(_arg,this),_joins),
	pc_member(_attr,_qae1),
	functor(_attr,_func,_ar),
	pc_member(_func,[r,c]),
	arg(1,_attr,_arg),
	!,
	replace(this,_qae2,_attr,_newqae2),
	build_xjoin_exp(_attr,_newqae2,_xjoinexp),
	replace(_attr,_qae1,_xjoinexp,_joinargexp).

#MODE((build_xjoin_exp(i,i,o)))

build_xjoin_exp(r(_a),_qae,set(_qae)) :- !.
build_xjoin_exp(c(_a),_qae,set(_qae)) :- !.
build_xjoin_exp(_x,_qae,_x).

{** Left-Outerjoins **}
#MODE((build_leftouterjoins(i,i,i,o,o)))

build_leftouterjoins([],[_nfexp],[_argexp],_nfexp,_argexp).

build_leftouterjoins([_joincond],
					[_nfexp,_nfexp2],
					[_argexp,_argexp2],
					leftouterjoin(_condlist,[_argnum1,_argnum2],_nfexp,_nfexp2),
					_newargexp) :-
	!,
	replace_join_args(_argexp,_argexp2,_joincond,_condlist),
	build_join_argexp(_argexp,_argexp2,_joincond,_newargexp),
	get_arg_pos(WANT_NUMBER_OF_ARGUMENTS,_argexp,_argnum1),
	get_arg_pos(WANT_NUMBER_OF_ARGUMENTS,_argexp2,_argnum2).


build_leftouterjoins([_firstjoin|_rjoin],
					[_nfexp,_nfexp2|_rnf],
					[_argexp,_argexp2|_rae],
				    _newnfexp,
					_newargexp) :-
	build_leftouterjoins([_firstjoin],[_nfexp,_nfexp2],[_argexp,_argexp2],_nfexp3,_argexp3),
	build_leftouterjoins(_rjoin,[_nfexp3|_rnf],[_argexp3|_rae],_newnfexp,_newargexp).


{** NEST **}
#MODE((build_nest(i,i,o,o)))

build_nest(_view,_argexp,nest(_is,_view),_outexp) :-
	get_nest_attrs(_argexp,_nestattrs,_nestargexp,_setexp),
	replace_proj_args(_nestattrs,_argexp,_is),
	append(_nestargexp,[set(_setexp)],_outexp).


{** XNEST **}
#MODE((build_xnest(i,i,o,o)))

{ Hier brauchen wir mit der setexp nichts zu machen, da die schon }
{ von build_xjoin eingesetzt worden ist }
build_xnest(_nfexp,_argexp,xnest(_is,_nfexp),_xnestargexp) :-
	get_nest_attrs(_argexp,_nestattrs,_nestargexp,_setexp),
	build_xnest_argexp(_nestattrs,_argexp,_xnestargexp),
	replace_proj_args(_nestattrs,_argexp,_is).


{** XNest ArgExp **}
#MODE((build_xnest_argexp(i,i,o)))

{ xjoin wird nicht immer vor einem xnest gemacht, deshalb baue noch }
{ die set-Ausdruecke fuer alle ArgExp ausser this,p und set ein. }
build_xnest_argexp([],[],[]).

build_xnest_argexp([this|_t],[this|_rargexp],[this|_newargexp]) :-
	!,
	build_xnest_argexp(_t,_rargexp,_newargexp).

build_xnest_argexp([_h|_t],[p(_h,_c)|_rargexp],[p(_h,_c)|_newargexp]) :-
	!,
	build_xnest_argexp(_t,_rargexp,_newargexp).

build_xnest_argexp(_t,[set(_l)|_rargexp],[set(_l)|_newargexp]) :-
	!,
	build_xnest_argexp(_t,_rargexp,_newargexp).

build_xnest_argexp(_t,[_exp|_rargexp],[set([_exp])|_newargexp]) :-
	!,
	build_xnest_argexp(_t,_rargexp,_newargexp).


{** Nest fuer retrieved_attributes **}
#MODE((build_nest_rattr(i,i,o,o)))

{ Mache Nest-Operationen um retrieved_attributes und ihre Label zusammen zufassen }
{ und zwar schrittweise fuer jedes retrieved_attribute }
build_nest_rattr(_nfexp,_argexp,_newnfexp,_newargexp) :-
	pc_member(r(_x),_argexp),
	!,
	get_not_rattr_list(0,r(_x),_argexp,_argexp2,_notrattrlist),
	build_nest_rattr(nest(_notrattrlist,_nfexp),_argexp2,_newnfexp,_newargexp).

build_nest_rattr(_nfexp,_argexp,_nfexp,_argexp).


#MODE((get_not_rattr_list(i,i,i,o,o)))

get_not_rattr_list(_n,r(_x),[],[],[]).

get_not_rattr_list(_n,r(_x),[this|_rarg],[this|_narg],[_n1|_rlist]) :-
	_n1 is _n + 1 ,
	get_not_rattr_list(_n1,r(_x),_rarg,_narg,_rlist).

get_not_rattr_list(_n,r(_x),[c(_a)|_rarg],[c(_a)|_narg],[_n1|_rlist]) :-
	_n1 is _n + 1 ,
	get_not_rattr_list(_n1,r(_x),_rarg,_narg,_rlist).

get_not_rattr_list(_n,r(_x),[set(_a)|_rarg],[set(_a)|_narg],[_n1|_rlist]) :-
	_n1 is _n + 1 ,
	get_not_rattr_list(_n1,r(_x),_rarg,_narg,_rlist).

get_not_rattr_list(_n,r(_x),[ps(_a)|_rarg],[ps(_a)|_narg],[_n1|_rlist]) :-
	_n1 is _n + 1 ,
	get_not_rattr_list(_n1,r(_x),_rarg,_narg,_rlist).

get_not_rattr_list(_n,r(_x),[r(_a)|_rarg],[r(_a)|_narg],[_n1,_n2|_rlist]) :-
	_a \== _x,
	_n1 is _n + 1 ,
	_n2 is _n + 2 ,
	get_not_rattr_list(_n2,r(_x),_rarg,_narg,_rlist).

get_not_rattr_list(_n,r(_x),[p(_p,_c)|_rarg],[p(_p,_c)|_narg],[_n1,_n2|_rlist]) :-
	_n1 is _n + 1 ,
	_n2 is _n + 2 ,
	get_not_rattr_list(_n2,r(_x),_rarg,_narg,_rlist).

get_not_rattr_list(_n,r(_x),[r(_x)|_rarg],_narg,_rlist) :-
	_n2 is _n + 2 ,
	get_not_rattr_list(_n2,r(_x),_rarg,_narg1,_rlist),
	append(_narg1,[set([r(_x)])],_narg).


#MODE((get_nest_attrs(i,o,o,o)))

get_nest_attrs([],[],[],[]).

get_nest_attrs([_arg|_rarg],[_attr|_rattr],[_arg|_restexp],_setexp) :-
	((_arg = this, _attr = this);
	 _arg = p(_attr,_)
	{ _arg = rp(_attr,_);
	 _arg = cp(_attr,_);
	 _arg = ps(_attr,_);
	 _arg = rps(_attr,_);
	 _arg = cps(_attr,_) }
	),
	!,
	get_nest_attrs(_rarg,_rattr,_restexp,_setexp).

get_nest_attrs([_arg|_rarg],_rattr,_restexp,[_arg|_setexp]) :-
	_arg \== this,
	get_nest_attrs(_rarg,_rattr,_restexp,_setexp).


{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
{ Andere Hilfspraedikate                                  }
{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

#MODE((subquery(i,?,?)))

subquery(_q,_sv,_l) :-
	QCsubquery(_q,_l,_dest,_),
	deriveExp2name(_dest,_sv).


#MODE((partOfQuery(i,?,?)))

partofQuery(_q,_sv,_l) :-
	prove_literal(A_label(_q,partof,_dest,_l)),
	deriveExp2name(_dest,_sv).


#MODE((deriveExp2name(i,?)))

deriveExp2name(_dest,_sv) :-
	retrieve_proposition(P(_dest,_,_label,_)),
#IF(SWI)
    pc_atomconcat('derive(',_,_label),
#ENDIF(SWI)
	pc_atom_to_term(_label,_term),
	_term = derive(_sv,_dl),
	!.

deriveExp2name(_d,_d) :- !.


#MODE((store_QCjoincond(i)))

store_QCjoincond(QCjoincond(_q1,_q2,_cond)) :-
   	store_tmp_PROLOGrules([QCjoincond(_q1,_q2,_cond)]).

#MODE((get_QCjoincond(?)))

get_QCjoincond(QCjoincond(_q1,_q2,_cond)) :-
	get_tmp_PROLOGrules(QCjoincond(_q1,_q2,_cond)),
	!.


get_QCjoincond(QCjoincond(_q1,_q2,_cond)) :-
	pc_has_a_definition(QCjoincond(_,_,_)),
	QCjoincond(_q1,_q2,_cond).

