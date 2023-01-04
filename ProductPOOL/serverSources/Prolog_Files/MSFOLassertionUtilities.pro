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
{
*
* File:        MSFOLassertionUtilities.pro
* Version:     7.3
* Creation:    08-Feb-1993, Kai v. Thadden (RWTH-Aachen)
* Last Change: 22 Jan 1995 , Kai v. Thadden (RWTH-Aachen)
* Release:     7
* -----------------------------------------------------------------------------
*
This file contains predicates for general manipulation of MSFOL-formulas.
*
*
}

#MODULE(MSFOLassertionUtilities)
#EXPORT(convert/2)
#EXPORT(pushNegationInvards/2)
#EXPORT(substituteVar/4)
#ENDMODDECL()

#IF(SWI)
:- style_check(-singleton).
#ENDIF(SWI)



{***********************************************************}
{* pushNegationInvards( _f,_nf )                           *}
{*                                                         *}
{* not exists quantifiers are transformed back to forall   *}
{* quantifiers                                             *}
{***********************************************************}

{* double not *}
pushNegationInvards(not(not(_t)),_r) :-
	pushNegationInvards(_t,_r).

{* Literals *}
pushNegationInvards(not(lit(TRUE)),lit(FALSE)) :- !.

pushNegationInvards(not(lit(FALSE)),lit(TRUE)) :- !.

pushNegationInvards(not(lit(_l)),not(lit(_l))) :- !.

pushNegationInvards(lit(_l),lit(_l)) :- !.

{* and *}
pushNegationInvards(and([]),and([])).

pushNegationInvards(and([_t|_ts]),and([_r|_rs])) :-
	pushNegationInvards(_t,_r),
	pushNegationInvards(and(_ts),and(_rs)).

{* or *}
pushNegationInvards(or([]),or([])).

pushNegationInvards(or([_t|_ts]),or([_r|_rs])) :-
	pushNegationInvards(_t,_r),
	pushNegationInvards(or(_ts),or(_rs)).

{* not and *}
pushNegationInvards(not(and([])),or([])).

pushNegationInvards(not(and([_t|_ts])),or([_r|_rs])) :-
	pushNegationInvards(not(_t),_r),
	pushNegationInvards(not(and(_ts)),or(_rs)).

{* nor or *}
pushNegationInvards(not(or([])),and([])).

pushNegationInvards(not(or([_t|_ts])),and([_r|_rs])) :-
	pushNegationInvards(not(_t),_r),
	pushNegationInvards(not(or(_ts)) ,and(_rs) ).

{* exists *}
pushNegationInvards(exists(_var,_type,_t),exists(_var,_type,_r)) :-

	pushNegationInvards(_t,_r).

{* not exists *}
pushNegationInvards(not(exists(_var,_type,_t)),forall(_var,_type,_r)) :-
	pushNegationInvards(not(_t),_r).

{* The next two clauses are not necessary in the context   *}
{* the predicate is used. But they make the intension of   *}
{* pushNegationInvards complete, so that the predicate     *}
{* might be reused in another context.                     *}

{* forall *}
pushNegationInvards(forall(_var,_type,_t),forall(_var,_type,_r)) :-
	pushNegationInvards(_t,_r).

{* not forall *}
pushNegationInvards(not(forall(_var,_type,_t)),exists(_var,_type,_r)) :-
	pushNegationInvards(not(_t),_r).


{***********************************************************}
{* substituteVar(_oldvar,_newvar,_oldformula,_newformula)  *}
{*                                                         *}
{* substitutes all occurances of _oldvar by _newvar in     *}
{* _oldformula                                             *}
{*                                                         *}
{***********************************************************}

{* change variable in quantifier
*}
substituteVar(_ov,_nv,exists(_ov,_type,_t), exists(_nv,_type,_nt)) :-

	!,
	substituteVar(_ov,_nv,_t,_nt).

substituteVar(_ov,_nv,forall(_ov,_type,_t), forall(_nv,_type,_nt)) :-

	!,
	substituteVar(_ov,_nv,_t,_nt).

{* else leave the variable unchanged
*}
substituteVar(_ov,_nv,exists(_v,_type,_t), exists(_v,_type,_nt)) :-

	!,
	substituteVar(_ov,_nv,_t,_nt).

substituteVar(_ov,_nv,forall(_ov,_type,_t), forall(_nv,_type,_nt)) :-

	!,
	substituteVar(_ov,_nv,_t,_nt).

substituteVar(_ov,_nv,not(_t),not(_nt)) :-
	!,
	substituteVar(_ov,_nv,_t,_nt).

substituteVar(_ov,_nv,and([]),and([])) :-
	!.

substituteVar(_ov,_nv,and([_t|_ts]),and([_nt|_nts])) :-
	!,
	substituteVar(_ov,_nv,_t,_nt),
	substituteVar(_ov,_nv,and(_ts),and(_nts)).


substituteVar(_ov,_nv,or([]),or([])) :-
	!.

substituteVar(_ov,_nv,or([_t|_ts]),or([_nt|_nts])) :-
	!,
	substituteVar(_ov,_nv,_t,_nt),
	substituteVar(_ov,_nv,or(_ts),or(_nts)).

substituteVar(_ov,_nv,lit(_l),lit(_nl)) :-
	!,
	_l =.. [_fun|_args],
	substituteVar(_ov,_nv,Args(_args),Args(_nargs)),
	_nl =.. [_fun|_nargs].

substituteVar(_ov,_nv,Args([]),Args([])) :- !.

substituteVar(_ov,_nv,Args([_ov|_args]),Args([_nv|_nargs])) :-
	!,
	substituteVar(_ov,_nv,Args(_args),Args(_nargs)).

substituteVar(_ov,_nv,Args([_var|_args]),Args([_var|_nargs])) :-
	!,
	substituteVar(_ov,_nv,Args(_args),Args(_nargs)).

{***********************************************************}
{* convert(_listform,_nestedform)                          *}
{* Konvertiert and- und or-Listen zur alten Schachteldar-  *}
{* stellung                                                *}
{***********************************************************}

convert( MSFOLassertion(_f), MSFOLassertion(_nf)) :-
	convert(_f,_nf).

convert( forall(_v,_t,_f), forall(_v,_t,_nf) ) :-
	convert(_f,_nf).

convert( exists(_v,_t,_f), exists(_v,_t,_nf) ) :-
	convert(_f,_nf).

convert( impl(_t1,_t2), impl(_nt1,_nt2) ) :-
	convert(_t1,_nt1),
	convert(_t2,_nt2).

convert( not(_f), not(_nf) ) :-
	convert(_f,_nf).

convert( and([_t1,_t2]), and(_nt1,_nt2) ) :-
	!,
	convert(_t1,_nt1),
	convert(_t2,_nt2).

convert( and([_t|_ts]), and(_nt,_nts) ) :-
	convert(_t,_nt),
	convert(and(_ts),_nts).

convert( or([_t1,_t2]), or(_nt1,_nt2) ) :-
	!,
	convert(_t1,_nt1),
	convert(_t2,_nt2).

convert( or([_t|_ts]), or(_nt,_nts) ) :-
	convert(_t,_nt),
	convert(or(_ts),_nts).

convert( lit(_l), lit(_l) ).

convert(_l,_l).
