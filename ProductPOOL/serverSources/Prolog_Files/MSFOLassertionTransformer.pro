{*
The ConceptBase.cc Copyright

Copyright 1987-2025 The ConceptBase Team. All rights reserved.

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
* File :        MSFOLassertionTransformer.pro
* Version :     7.4     
* Creation:     2-Nov-93, Kai v. Thadden (RWTH)
* Last change : 31 Aug 1994, 2-Nov-93, Kai v. Thadden (RWTH)
* Release:      7
*
*
*----------------------------------------------------------------------------
*
* Transformation der Miniscopeform in die Rangeform
*
}

#MODULE(MSFOLassertionTransformer)
#EXPORT(miniscopeToRangeform/2)
#EXPORT(checkArgLabel/1)
#ENDMODDECL()


#IMPORT(resolveDeriveExpression/2,MSFOLassertionParserUtilities)
#IMPORT(pc_atomconcat/3,PrologCompatibility)
#IMPORT(increment/1,GeneralUtilities)
#IMPORT(is_id/1,MetaUtilities)



{===========================================================}
{=              LOCAL PREDICATE DECLARATION                =}
{===========================================================}
#LOCAL(miniscopeToRangeform2/2)
#LOCAL(buildRanges/5)
#LOCAL(getRangeFromOrlist/3)
#LOCAL(getRangeFromAndlist/3)

#IF(SWI)
:- style_check(-singleton).
#ENDIF(SWI)



{===========================================================}
{=             EXPORTED PREDICATES DEFINITION              =}
{===========================================================}
{***********************************************************}
{* miniscopeToRangeform(_formulaMSFOL,_formulaRF)          *}
{* _formulaMSFOL : term (i)                                *}
{* _formulaRF    : term (o)                                *}
{*                                                         *}
{* Take a minscope formula _formulaMSFOL and produce the   *}
{* rangeform _formulaRF                                    *}
{***********************************************************}

miniscopeToRangeform( MSFOLconstraint(_formulaMSFOL),rangeconstr(_formulaRF)) :-
	miniscopeToRangeform2(_formulaMSFOL,_formulaRF).

miniscopeToRangeform(MSFOLrule(_vars,_conditionMSFOL,_conclusionMSFOL),rangerule(_vars,_conditionRF,_conclusionRF)) :-

	miniscopeToRangeform2(_conditionMSFOL,_conditionRF),
	miniscopeToRangeform2(_conclusionMSFOL,_conclusionRF).
	
{===========================================================}
{=                LOCAL PREDICATES DEFINITION              =}
{===========================================================}

{***********************************************************}
{* miniscopeToRangeform2(_miniF,_rangeF)                   *}
{* _miniF : term (i)                                       *}
{* _rangeF: term (o)                                       *}
{*                                                         *}
{* Take the minscope formula _miniF and produce the range  *}
{* form.                                                   *}
{***********************************************************}


{* Case 1: forall *}

miniscopeToRangeform2(forall(_var,_type,_term),forall(_vars,_ranges,_rangeterm)) :-
	checkArgLabel(_type),
	buildRanges(forall,forall(_var,_type,_term),_vars,_ranges,_restterm),
	miniscopeToRangeform2(_restterm,_rangeterm).

{* Case 2: exists *}

miniscopeToRangeform2(exists(_var,_type,_term),exists(_vars,_ranges,_rangeterm)) :-
	checkArgLabel(_type),
	buildRanges(exists,exists(_var,_type,_term),_vars,_ranges,_restterm),
	miniscopeToRangeform2(_restterm,_rangeterm).

{* Case 3: or *}
miniscopeToRangeform2(or([]),or([])) :- !.

miniscopeToRangeform2(or([_t|_ts]),or([_rt|_rts])) :-
	miniscopeToRangeform2(_t,_rt),
	miniscopeToRangeform2(or(_ts),or(_rts)).

{* Case 4: and *}
miniscopeToRangeform2(and([]),and([])) :- !.

miniscopeToRangeform2(and([_t|_ts]),and([_rt|_rts])) :-
	miniscopeToRangeform2(_t,_rt),
	miniscopeToRangeform2(and(_ts),and(_rts)).

{* Case 5: Literals *}
miniscopeToRangeform2(not(lit(_l)),not(_l)) :- !.

miniscopeToRangeform2(lit(_l),_l) :- 
   _l =.. [_f|_args],
   checkArgLabel(_args), !.  {* no unknown object name in _args *}


{* check whether label is tagged as unknown by parseAss.dcg; see also ticket #189 *}
checkArgLabel(_label) :-
   atom(_label),
   pc_atomconcat('%%UNKNOWN--',_,_label),
   increment('error_number@F2P'),
   !,
   fail.

checkArgLabel([]) :- !.
checkArgLabel([_t|_rest]) :-
  checkArgLabel(_t),
  checkArgLabel(_rest).

checkArgLabel(_).  {* we except anything that is no matching %%UNKNOWN--* *}





{***********************************************************}
{* buildRanges bastelt fuer einen _quantifier-Ausdruck den *}
{* passenden Range zusammen                                *}
{* buildRanges(_mode,_term,_vars,_range,_rest)             *}
{* _mode: (i) forall/exists, Quantortyp, fuer den der Range*}
{*        erzeugt werden soll                              *}
{* _term: (i) miniscope, aus der die Range-Literale gezogen*}
{*        werden                                           *}
{* _vars: (o) Variablen, fuer die der Range gilt (Es       *}
{*        koennen z.B. 2 Quantoren gleichen Typs zusammen- *}
{*        gefasst werden                                   *}
{* _range:(o) Der Range fuer den aktuellen Quantor         *}
{* _rest: (o) der Teil der Formel, der nicht in den Range  *}
{*        kommt                                            *}
{***********************************************************}

{* Fall 1: forall *}

{* Fall 1a) forall-Quantor, mit einer Klasse *}
buildRanges(forall,forall(_v,[_c],_t),[_v|_vs],[_inlit|_rs],_restterm) :-
	!,
	createInLit(_v,_c,_inlit),
	buildRanges(forall,_t,_vs,_rs,_restterm),
	!.

{* Fall 1b) forall-Quantor wobei _v in mehreren Klassen ist
 *}
buildRanges(forall,forall(_v,[_c|_cs],_t),_vs,[_inlit|_rs],_restterm) :-
	!,
	createInLit(_v,_c,_inlit),
	buildRanges(forall,forall(_v,_cs,_t),_vs,_rs,_restterm),
	!.

{* Fall 1c) forall-Quantor, mit einer Klasse, ohne Klassenliste. Sollte man u.U. mit Fall 1a) verbinden.
*}
buildRanges(forall,forall(_v,_c,_t),[_v|_vs],[_inlit|_rs],_restterm) :-
	createInLit(_v,_c,_inlit),
	buildRanges(forall,_t,_vs,_rs,_restterm),
	!.

buildRanges(forall,or(_ts),[],_ranges,_restterm) :-
	getRangeFromOrlist(_ts,_ranges,_noranges),
	((_noranges == [],!, _restterm = lit(FALSE))	{case1:all elements of the or-list could be drawn into the range}
	;(_noranges = [_restterm])		{case2:all elements of the or-list exept one could be drawn into the range}
	;(_restterm = or(_noranges))		{case3:_rs contains at least two elements}
	).

buildRanges(forall,not(lit(_l)),[],[_l],lit(FALSE)) :- !.

buildRanges(forall,_t,[],[],_t) :- !. {* Restterm *}


{* Fall 2: exists *}

{* Fall 1a) exists-Quantor, mit einer Klasse *}
buildRanges(exists,exists(_v,[_c],_t),[_v|_vs],[_inlit|_rs],_restterm) :-
	createInLit(_v,_c,_inlit),
	buildRanges(exists,_t,_vs,_rs,_restterm),
	!.

{* Fall 1b) exists-Quantor wobei _v in mehreren Klassen ist
 *}
buildRanges(exists,exists(_v,[_c|_cs],_t),_vs,[_inlit|_rs],_restterm) :-
	createInLit(_v,_c,_inlit),
	buildRanges(exists,exists(_v,_cs,_t),_vs,_rs,_restterm),
	!.

{* Fall 1c) forall-Quantor, mit einer Klasse, ohne Klassenliste. Sollte man u.U. mit Fall 1a) verbinden.
*}
buildRanges(exists,exists(_v,_c,_t),[_v|_vs],[_inlit|_rs],_restterm) :-
	createInLit(_v,_c,_inlit),
	buildRanges(exists,_t,_vs,_rs,_restterm),
	!.

buildRanges(exists,and(_ts),[],_ranges,_restterm) :-
	getRangeFromAndlist(_ts,_ranges,_noranges),
	((_noranges == [],!, _restterm = lit(TRUE))	{case1:all elements of the or-list could be drawn into the range}
	;(_noranges = [_restterm])		{case2:all elements of the or-list exept one could be drawn into the range}
	;(_restterm = and(_noranges))		{case3:_rs contains at least two elements}
	).

{* avoids creation of unnecessary TRUE literals an         *}
{* equivalent construction in the forall-case is not       *}
{* necessary, because pushNegationInvards converts         *}
{* not(lit(TRUE)) to lit(FALSE), which cannot be unified   *}
{* with the general not(lit)-case                          *}

buildRanges(exists,lit(TRUE),[],[],lit(TRUE)) :- !.

buildRanges(exists,lit(_l),[],[_l],lit(TRUE)) :- !.

buildRanges(exists,_t,[],[],_t) :- !. {* Restterm *}


{***********************************************************}
{* getRangeFromOrlist splittet eine _orlist in Elemente,   *}
{* die in den Range eingehen und Elemente, die nicht in den*}
{* Range eingehen (fuer forall)                            *}
{***********************************************************}

getRangeFromOrlist([],[],[]) :- !.

getRangeFromOrlist([not(lit(_l))|_orlist],[_l|_rs],_rest) :-
	!,
	getRangeFromOrlist(_orlist,_rs,_rest).

getRangeFromOrlist([_t|_orlist],_rs,[_t|_rest]) :-
	!,
	getRangeFromOrlist(_orlist,_rs,_rest).


{***********************************************************}
{* getRangeFromAndlist splittet eine _orlist in Elemente,  *}
{* die in den Range eingehen und Elemente, die nicht in den*}
{* Range eingehen (fuer exists)                            *}
{***********************************************************}

getRangeFromAndlist([],[],[]) :- !.

getRangeFromAndlist([lit(_l)|_andlist],[_l|_rs],_rest) :-
	!,
	getRangeFromAndlist(_andlist,_rs,_rest).

getRangeFromAndlist([_t|_andlist],_rs,[_t|_rest]) :-
	!,
	getRangeFromAndlist(_andlist,_rs,_rest).


{***********************************************************}
{* createInLit(_v,_c,_inlit)                               *}
{* erstellt fuer eine Variable _v und eine Klasse _c ein   *}
{* Literal In(_v,_c). Ist _c jedoch ein Ableitungsausdruck *}
{* (d.h. eine generische Anfrageklasse u.U. mit Parametern)*}
{* so wird der passende Anfrageaufruf eingesetzt.          *}
{***********************************************************}

createInLit(_v,_c,_inlit) :-
        checkArgLabel(_c),   {* ticket #272 *}
	_inlit1 = In(_v,_c),
	resolveDeriveExpression(_inlit1,_inlit).



