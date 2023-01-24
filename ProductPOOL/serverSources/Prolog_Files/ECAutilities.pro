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


This license is a FreeBSD-style copyright license.
Legal home of the FreeBSD copyright license: http://www.freebsd.org/copyright/freebsd-license.html
*}
{
*
* File:         %M%
* Version:      %I%
* Creation:     1997, F. Lashgari
* Last Change   : %E%, Christoph Quix (RWTH)
*
* SCCS-Source-Pool : %P%
* Date retrieved : %D% (YY/MM/DD)
*

}


#MODULE(ECAutilities)
#EXPORT(ClearECArules/0)
#EXPORT(build_ask_events/2)
#EXPORT(difference/3)
#EXPORT(difference_var/3)
#EXPORT(high_modus/2)
#EXPORT(no_intersection/2)
#ENDMODDECL()

#IMPORT(member/2,GeneralUtilities)
#IMPORT(get_application/1,ModelConfiguration)
#IMPORT(appFilename/3,ModelConfiguration)
#IMPORT(replace_derive_expression/3,QueryCompiler)
#IMPORT(name2id/2,GeneralUtilities)
#IMPORT(pc_atomconcat/2,PrologCompatibility)
#IMPORT(pc_atomconcat/3,PrologCompatibility)
#IMPORT(pc_atom_to_term/2,PrologCompatibility)
#IMPORT(pc_fopen/3,PrologCompatibility)
#IMPORT(pc_fclose/1,PrologCompatibility)
#IMPORT(reverse/2,GeneralUtilities)
#IMPORT(pc_time/2,PrologCompatibility)

#IF(SWI)
:- style_check(-singleton).
#ENDIF(SWI)


{****************************************************************}
{ substitute_answer/2						 }
{****************************************************************}

substitute_answer(_answer, _action, _execaction) :-
	pc_atomconcat(_action,'@ECAactionManager', _head),
	clause( _head , _body),
	substitute( _answer, _body, _execaction).


{****************************************************************}
{ substitute/2	 						 }
{****************************************************************}


substitute( _answer, (_a,_b),(_anew,_bnew)):-
	_b =.. [_functor|_args],
	subs(_answer,_args,_newargs),
	_bnew =.. [_functor|_newargs],
	substitute( _answer, _a, _anew).

substitute( _answer, _a,_anew):-
	_a =.. [_functor|_args],
	subs(_answer,_args,_newargs),
	_anew =.. [_functor|_newargs].

subs(_,[],[]).

subs(_a,[this|_rest],[_a|_newrest]) :-
	subs(_a, _rest, _newrest),!.

subs(_a,[_b|_rest],[_b|_newrest]) :-
	subs(_a, _rest, _newrest).


{****************************************************************}
{ build_ask_events/2						 }
{****************************************************************}

build_ask_events([],[]).
build_ask_events([derive(_q,_slist)|_r1],[Ask(_query),Ask(In(_,_qid))|_r2]) :-
	!,
	name2id(_q,_qid),
	replace_derive_expression(_,derive(_qid,_slist),_query),   {* _ is for the result parameter in the query call *}
	build_ask_events(_r1,_r2).

build_ask_events([_q|_r1],[Ask(In(_,_qid))|_r2]):-
	!,
	name2id(_q,_qid),
	build_ask_events(_r1,_r2).

{****************************************************************}
{ initializeECAstat/0						 }
{****************************************************************}


initializeECAstat :-
	assert('eca_activate@ECAruleManager'(off)).





{****************************************************************}
{ no_intersection/2					 	 }
{****************************************************************}
no_intersection(_,[]):-!.
no_intersection([],_):-!.
no_intersection([_a|_r1],_r2):-
	!,
	\+ member(_a,_r2),
	no_intersection(_r1,_r2).


{****************************************************************}
{ get_list_range/4					 	 }
{****************************************************************}

get_list_range(_l,1,0,[]).
get_list_range([_a|_l],1,_j,[_a|_new]):-
	_j1 is _j-1,!,
	get_list_range(_l,1,_j1,_new).

get_list_range([_a|_l],_i,_j,_new):-
	_i > 1,
	_j > _i ,
	_i1 is _i-1,
	_j1 is _j-1,
	get_list_range(_l,_i1,_j1,_new).


length_of_list(_l,_n):-
	length_of_list(_l,0,_n).

length_of_list([],_n,_n).
length_of_list([_a|_r],_n1,_n):-
	_n2 is _n1+1,
	length_of_list(_r,_n2,_n).

{****************************************************************}
{ get_last/2						 	 }
{****************************************************************}
get_last([_a],_a).
get_last([_a|_r],_b):-
	get_last(_r,_b).




{****************************************************************}
{ high_modus/2						 	 }
{****************************************************************}

high_modus(immediate,imm_def).
high_modus(immediate,deferred).
high_modus(imm_def,deferred).

exists_ecarule(_r) :-
	'eca@ECAruleManager'(_r,_,_,_,_,_,_,_,_,_,_,Now).



{****************************************************************}
{ ClearECArules/0					 	 }
{****************************************************************}

ClearECArules :-
	get_application(_app),
        appFilename('ecarule',_app,_file),
        pc_fopen(ecafile,_file,w),
	save_ecarules(ecafile),
	pc_fclose(ecafile).

save_ecarules(_file) :-
	retract('eca@ECAruleManager'(_n,_e,_a,_do,_else,_p,_m,_ac,_d,_queue,_t1,_t2)),
	write(_file,eca(_n,_e,_a,_do,_else,_p,_m,_ac,_d,_queue,t1,_t2)),
	write(_file,'.\n'),
	fail.

save_ecarules(_file) :-
	retract('priority@ECAruleManager'(_r,_af,_be)),
	write(_file,priority(_r,_af,_be)),
	write(_file,'.\n'),
	fail.

save_ecarules(_file) :-
	retract('e@ECAevent'(_e,_imm,_imm_def,_def)),
	write(_file,e(_e,_imm,_imm_def,_def)),
	write(_file,'.\n'),
	fail.

save_ecarules(_file) :-
	retract('r@ECAruleManager'(_n,_e,_a,_do,_else,_d,_queue)),
	write(_file,r(_n,_e,_a,_do,_else,_d,_queue)),
	write(_file,'.\n'),
	fail.

save_ecarules(_file) :-
	retract('nest@ECAruleManager'(_n1,_n2,_n3)),
	write(_file,nest(_n1,_n2,_n3)),
	write(_file,'.\n'),
	fail.

save_ecarules(_file).




{*******************************************************************}
{difference/3							    }
{*******************************************************************}
difference(_list,[],_list).
difference([],_list,[]).
difference([_a|_rest],_b,_c):-
	member(_a,_b),!,
	difference(_rest,_b,_c).
difference([_a|_rest],_b,[_a|_c]):-
	difference(_rest,_b,_c).



{*******************************************************************}
{difference_var/3							    }
{*******************************************************************}
difference_var(_list,[],_list).
difference_var([],_list,[]).
difference_var([_a|_rest],_b,_c):-
	member_var(_a,_b),!,
	difference_var(_rest,_b,_c).
difference_var([_a|_rest],_b,[_a|_c]):-
	difference_var(_rest,_b,_c).

member_var(_a,[_b|_rest]):-
	_a == _b ,!.

member_var(_a,[_b|_rest]):-
	member_var(_a,_rest).
