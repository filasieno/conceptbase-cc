{*
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
*}

{******      DIESES MODUL WIRD NICHT MEHR GENUTZT !!! *********}
{******      DURCH QO_* ersetzt                       *********}

{*
*
* File:         %M%
* Version:      %I%
* Creation      : 28-Aug-95,  Christoph Quix (RWTH)
* Last Change   : %E%, Christoph Quix (RWTH)
*
* SCCS-Source-Pool : %P%
* Date retrieved : %D% (YY/MM/DD)
*
*-----------------------------------------------
* Beurteilung der Komplexitaet von Literalen.
* Dieses Modul sollte nur von DatalogOptimizer benutzt werden.
*
* Changes:
*
* 8-Feb-1996: Integer,Real und String sind Huge,
*	Vergleichsliterale mit freien Variablen sind verboten,
*	und Vergleichsliterale nur mit gebundenen Variablen sind
*	very_easy.
*}

#MODULE(CostModel)
#EXPORT(big_lit/1)
#EXPORT(smaller_lit/2)
#ENDMODDECL()



{* Diese Praedikate sind dynamisch deklariert damit man in OB.builtin
 * zusaetzliche Fakten fuer seine Applikation einfuegen kann.
 *}
#LOCAL(smaller/2)
#DYNAMIC(smaller/2)
#LOCAL(smaller_id/2)
#DYNAMIC(smaller_id/2)
#LOCAL(huge/1)
#DYNAMIC(huge/1)
#LOCAL(huge_id/1)
#DYNAMIC(huge_id/1)



{===========================================================}
{=                  EXPORTED PREDICATES                    =}
{===========================================================}
{*
:- exports smaller_lit/2 to Datalog_Optimizer .
:- exports big_lit/1 to Datalog_Optimizer .
*}
{===========================================================}
{=                  IMPORTED PREDICATES                    =}
{===========================================================}

#IMPORT(name2id/2,GeneralUtilities)
#IMPORT(id2name/2,GeneralUtilities)
#IMPORT(get_free_args/2,DatalogOptimizer)


#IF(SWI)
:- style_check(-singleton).
#ENDIF(SWI)



{===========================================================}
{=             EXPORTED PREDICATES DEFINITION              =}
{===========================================================}


{===========================================================}
{* big_lit/1                                               *}
{* Wahr, wenn arg1 ein kritisches oder verbotenes Literal  *}
{* ist, oder wenn alle Argumente des Literals nicht        *}
{* gebunden sind.                                          *}
{===========================================================}

big_lit(_lit) :-
	critical(_lit).

big_lit(_lit) :-
	forbidden(_lit).

big_lit(_lit) :-
	_lit =.. [_f|_args],
	get_free_args(_lit,_args).


{===========================================================}
{* smaller_lit(arg1,arg2)                                  *}
{*                                                         *}
{* Dies ist das wichtigste Praedikat um die Reihenfolge in *}
{* Datalog-Regeln zu aendern.                              *}
{===========================================================}


{* Literale die very_easy (z.B. To,From,...) sind, sollen nach
 * vorne, und gelten deshalb als kleiner als alle anderen Literale
 *}
smaller_lit(_lit1,_lit2) :-
	very_easy(_lit1).


{* Adot_bbf,Adot_bfb ist besser als Adot_bff, wenn
 * die Concerned_Class nicht huge ist *}
smaller_lit(Adot_bbf(_cc,_,_),Adot_bff(_,_,_)) :-
	not huge_id(_cc).

smaller_lit(Adot_bfb(_cc,_,_),Adot_bff(_,_,_)) :-
	not huge_id(_cc).

smaller_lit(Adot_label_bbff(_cc,_,_,_),Adot_label_bfff(_,_,_,_)) :-
	not huge_id(_cc).

smaller_lit(Adot_label_bfbf(_cc,_,_,_),Adot_label_bfff(_,_,_,_)) :-
	not huge_id(_cc).


{* Ein In-Literal ist besser als ein anderes In-Literal, wenn
 * die zugehoerige Klasse kleiner ist.
 *}
smaller_lit(In_fb(_x,_b),In_fb(_y,_c)) :-
    smaller_than(_b,_c).


{* Ausserdem sind small_lit < medium_lit < big_lit *}
smaller_lit(_lit1,_lit2) :-
	small_lit(_lit1),
	big_lit(_lit2).

smaller_lit(_lit1,_lit2) :-
	small_lit(_lit1),
    medium_lit(_lit2).

smaller_lit(_lit1,_lit2) :-
	medium_lit(_lit1),
	big_lit(_lit2).


{===========================================================}
{=             LOCAL PREDICATES DEFINITION                 =}
{===========================================================}


{===========================================================}
{* small_lit(arg1)                                         *}
{* Alle Literale, die in O(1) ausgewertet werden koennen.  *}
{===========================================================}

small_lit(_lit) :-
	easy(_lit).

small_lit(not(_lit)).

small_lit(_lit) :-
	get_free_args(_lit,[]).




{===========================================================}
{* medium_lit(arg1)                                        *}
{* Alle Literale, die weder big noch small sind.           *}
{===========================================================}

medium_lit(_lit) :-
	not small_lit(_lit),
	not big_lit(_lit).



{===========================================================}
{* critical(arg1)                                          *}
{* Alle Literale, die viel Zeit kosten, aber nicht unbe-   *}
{* dingt boesartig sind.                                   *}
{===========================================================}
critical(In_fb(_x,_b)) :-
     huge_id(_b).

critical(Adot_bff(_cc,_x,_y)) :-
     huge_id(_cc).

critical(Adot_bfb(_cc,_x,_y)):-
    huge_id(_cc).

critical(Adot_bbf(_cc,_x,_y)):-
    huge_id(_cc).

critical(Adot_label_bfff(_cc,_x,_y,_)) :-
     huge_id(_cc).

critical(Adot_label_bfbf(_cc,_x,_y,_)):-
    huge_id(_cc).

critical(Adot_label_bbff(_cc,_x,_y,_)):-
    huge_id(_cc).

critical(A2_fff(_,_,_).
critical(A2_fbf(_,_,_).
critical(A2_fbf(_,_,_).
critical(A2_fbb(_,_,_).

critical(In2_ff(_,_).
critical(In2_fb(_,_).


{===========================================================}
{* forbidden(arg1)                                         *}
{* Alle Literale, die wirklich schlimm sind.               *}
{===========================================================}

forbidden(Adot_bff(_,_,_)).
forbidden(Adot_label_bfff(_,_,_,_)).
forbidden(From_ff(_,_)).
forbidden(To_ff(_,_)).
forbidden(In_ff(_,_)).

{ Diese Literale koennen mit freien Variablen nicht ausgewertet werden. }
forbidden(LT_bf(_,_)).
forbidden(GT_bf(_,_)).
forbidden(LE_bf(_,_)).
forbidden(GE_bf(_,_)).
forbidden(EQ_bf(_,_)).
forbidden(NE_bf(_,_)).
forbidden(LT_fb(_,_)).
forbidden(GT_fb(_,_)).
forbidden(LE_fb(_,_)).
forbidden(GE_fb(_,_)).
forbidden(EQ_fb(_,_)).
forbidden(NE_fb(_,_)).
forbidden(LT_ff(_,_)).
forbidden(GT_ff(_,_)).
forbidden(LE_ff(_,_)).
forbidden(GE_ff(_,_)).
forbidden(EQ_ff(_,_)).
forbidden(NE_ff(_,_)).

forbidden(IDENTICAL_ff(_,_)).
forbidden(IDENTICAL_bf(_,_)).
forbidden(IDENTICAL_fb(_,_)).
forbidden(UNIFIES_ff(_,_)).

{===========================================================}
{* Es folgen die Default-Definitionen von huge, smaller,   *}
{* easy und very_easy.                                     *}
{===========================================================}

huge_id(_id)  :- ground(_id),id2name(_id,_name),huge(_name).
huge(Class).
huge(Proposition).
huge(Attribute).
huge(attribute).
huge(InstanceOf).
huge('*instanceof').
huge(IsA).
huge('*isa').
huge(Individual).
huge(String).
huge(Integer).
huge(Real).

smaller(InstanceOf,Proposition).
smaller(Attribute,InstanceOf).
smaller(Class,Attribute).

smaller_id(_id1,_id2) :- ground(_id1),ground(_id2),id2name(_id1,_name1), id2name(_id2,_name2),smaller(_name1,_name2).

smaller_than(_x,_y) :- smaller_id(_x,_y).
smaller_than(_x,_y) :- smaller_id(_x,_z),smaller_than(_z,_y).
smaller_than(_x,_y) :- huge_id(_y), not huge_id(_x).


{Literale, die ganz nach vorne kommen sollen, da einfach auszuwerten und
* Variablen vorne binden sollen}
very_easy(From_fb(_,_)).
very_easy(From_bf(_,_)).
very_easy(From_bb(_,_)).
very_easy(To_fb(_,_)).
very_easy(To_bf(_,_)).
very_easy(To_bb(_,_)).
very_easy(Adot_bbb(_,_,_)).
very_easy(Adot_label_bbbb(_,_,_,_)).
very_easy(LT_bb(_,_)).
very_easy(GT_bb(_,_)).
very_easy(LE_bb(_,_)).
very_easy(GE_bb(_,_)).
very_easy(EQ_bb(_,_)).
very_easy(NE_bb(_,_)).
very_easy(IDENTICAL_bb(_,_)).
very_easy(UNIFIES_bf(_,_)).
very_easy(UNIFIES_fb(_,_)).
very_easy(UNIFIES_bb(_,_)).

easy(_lit) :- very_easy(_lit).
easy(In_fb(_,_id)) :- id2name(_id,_x),_x=='Boolean'.



{===========================================================}

{* Ein Beispiel, wie die Fakten in OB.builtin an die eigene
 * Applikation angepasst werden koennen. *}

{* Wichtig: Vergleich der Rueckgabe von eval und des Arguments
 * erst nachher durch IDENTICAL-Literal, da sonst der Objektspeicher
 * eine Warning meldet. Gleiches gilt fuer id2name und name2id.}

{*
huge$CostModel(RELATION).
huge_id$CostModel(_id) :-
	eval$SelectExpressions(select(RELATION,!,PRIMAERSCHLUESSEL),replaceSelectExpression,_id1),
	_id1 == _id.

huge_id$CostModel(_id) :-
	eval$SelectExpressions(select(select(RELATION,!,ATTRIBUT),!,FREMDSCHLUESSEL_ZU),replaceSelectExpression,_id1),
	_id1 ==_id.

smaller_id$CostModel(_id1,_id2) :-
	id2name$GeneralUtilities(_id2,_x),
	_x == RELATION,
	eval$SelectExpressions(select(RELATION,!,PRIMAERSCHLUESSEL),replaceSelectExpression,_id),
	_id1 == _id.

huge$CostModel(Aufgabe).
huge$CostModel(Methode).
huge$CostModel(Objekt).
*}
{===========================================================}

