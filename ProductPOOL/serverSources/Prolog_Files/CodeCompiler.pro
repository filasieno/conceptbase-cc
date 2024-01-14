{*
The ConceptBase.cc Copyright

Copyright 1987-2024 The ConceptBase Team. All rights reserved.

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
* File :        CodeCompiler.pro
* Version :     1.5
* Creation:     28-Mar-94, Kai v. Thadden (RWTH)
* Last change : 09-Jan-2003, Manfred Jeusfeld (Uni Tilburg)
* Release:      1
*
*
*------------------------------------------------------------
* Dieses Modul transformiert Datalog-Regeln in ausfuehrbaren Code fuer (Meta-)Auswerter.
Im Moment stehen zwei Auswerter zur Verfuegung:
- normaler PROLOG-Code (mit 'magic cache; siehe Literals.pro)
spaeter kann vielleicht der AlgebraCompiler hier eingebaut werden.
*
*}
{* Konvention fuer Variablennamen:
 DL : DATALOG-neg (beachte: alle Variablen sind durch Underscore gekennzeichne Atome (Bsp: _x)
 PL : PROLOG
*}
#MODULE(CodeCompiler)
#EXPORT(generatePROLOGCode/2)
#EXPORT(specialFunctor/2)
#ENDMODDECL()



{===========================================================}
{=                  IMPORTED PREDICATES                    =}
{===========================================================}
#IMPORT(insertPROLOGVars/2,GeneralUtilities)
#IMPORT(append/3,GeneralUtilities)
#IMPORT(storeRuleId/1,LTstubs)
#IMPORT(getRuleId/1,LTstubs)
#IMPORT(deleteRuleId/1,LTstubs)
#IMPORT(specialize_rule/2,RuleSpecializer)
#IMPORT(rewrite_rule/3,RuleOptimizer)
#IMPORT(pc_has_a_definition/1,PrologCompatibility)
#IMPORT(pc_atomconcat/2,PrologCompatibility)
#IMPORT(pc_atomconcat/3,PrologCompatibility)
#IMPORT(prove_literal/1,Literals)
#IMPORT(name2id/2,GeneralUtilities)
#IMPORT(is_id/1,MetaUtilities)
#IMPORT(isDeducable/1,Literals)


{===========================================================}
{=              LOCAL PREDICATE DECLARATION                =}
{===========================================================}
#LOCAL(insertProveLiteral/2)
#LOCAL(generate_specialized_rules/2)
#LOCAL(generate_optimized_rules/2)
#LOCAL(specialFunctor/1)
#LOCAL(specialFunctor/2)


#IF(SWI)
:- style_check(-singleton).
#ENDIF(SWI)


{===========================================================}
{=             EXPORTED PREDICATES DEFINITION              =}
{===========================================================}

{***********************************************************}
{* generatePROLOGCode leistet folgendes
- der Regelkopf sieht aus wie bisher: LTevalRule(_id,
- vor den einzelnen Literalen steht ein prove_literal$Literals
- die Atome mit Underscores weden durch richtige PROLOG-Variablen ersetzt.
- es wird das Zeitliteral eingebaut, um Rollback-Anfragen richtig behandeln zu koennen.(Dieses sollte erst zu einem spaeteren Zeitpunkt getan werden.)
Wichtig dabei ist:
- die erste Regel der Liste ist die Hauptaufrufsregel
*}
{***********************************************************}

generatePROLOGCode([],[]).

generatePROLOGCode([_clauseDL|_clauseDLs],[_clausePL|_clausePLs]) :-
	generatePROLOGCode(_clauseDL,_clausePL),
	!,
	generatePROLOGCode(_clauseDLs,_clausePLs).

generatePROLOGCode(_clauseDL,_clausePL) :-
	_clauseDL =.. [':-',_clauseHead,_clauseBody],
	insertProveLiteral(_clauseBody,_nclauseBody),
	_nclauseDL =.. [':-',_clauseHead,_nclauseBody],
	insertPROLOGVars(_nclauseDL,_clausePL).


{===========================================================}
{=                LOCAL PREDICATES DEFINITION              =}
{===========================================================}
generate_specialized_rules([],[]).

generate_specialized_rules([_first|_rest],_rs) :-
	specialize_rule(_first,_sf),
	generate_specialized_rules(_rest,_sr),
	append(_sf,_sr,_rs).

generate_optimized_rules([],[]).

generate_optimized_rules([_first|_rest],_rs) :-
	getRuleId(_id),
	(pc_atomconcat('#',_ido,_id);_ido = _id),
	rewrite_rule(_ido,_first,_flist),
	generate_optimized_rules(_rest,_rlist),
	append(_flist,_rlist,_rs).


{* Ticket #147 *}
insertProveLiteral((bound(_x),_rest),(_blit,_nrest)) :-
        !,
        produceBoundCall(bound(_x),_blit),
        insertProveLiteral(_rest,_nrest).


{* Fall 1: Aufruf eines zu einer Regel gehoerenden Codeteils hat einen Funktor der Form ID_123_4. Darum darf kein prove_literal geschriben werden, da auf die Regel nicht ueber die Propositionenschnittstelle zugegriffen werden darf.
*}
insertProveLiteral((_lit,_rest),(_lit,_nrest)) :-
	specialFunctor(_lit),
	!,
	insertProveLiteral(_rest,_nrest).


{** 14-Nov-2005/M. Jeusfeld: replace calls In(x,qc) where qc is a query class **}
{** by qc(x). This reduces the call depth for answering queries since a call  **}
{** In(x,qc) will always be computed by a call qc(x).                         **}
{** Note: this transformation can only be done for queries that have neither  **}
{** parameters, nor retrieved attributes, nor computed attributes. Otherwise, **}
{** the query literal would have a form like qc(x,a,b,...).                   **}

insertProveLiteral((In(_x,_qc),_rest),(_qlit1,_nrest)) :-
        is_id(_qc),
        prove_literal(In_s(_qc,id_65)),    {* id_65=QueryClass *}
        \+ hasAdditionalArgs(_qc), {* ticket #213 *}
        _qlit =.. [_qc,_x],  {* may not have further args like parameters, computed/retrieved attribute *}
        {isDeducable(_qlit), }   {* ticket #213: isDeducable not yet precomputed here *}
        insertProveLiteral(_qlit,_qlit1),     
        !,
        insertProveLiteral(_rest,_nrest).


{* Fall 2: Wenn das Literal negiert ist, setze ein not_prove_literal ein *}
insertProveLiteral((not(_lit),_rest),(_nlit,_nrest)) :-
	!,
	insertNotProveLiteral(_lit,_nlit),
	insertProveLiteral(_rest,_nrest).

{* Fall 3: In allen anderen Faellen prove_literal drumschreiben
*}
#IF(BIM)
insertProveLiteral((_lit,_rest),('prove_literal$Literals'(_lit),_nrest)) :-
#ELSE()
#PLAIN(insertProveLiteral((_lit,_rest),('\'Literals\':prove_literal'(_lit),_nrest)) :-)
#ENDIF(BIM)
	!,
	insertProveLiteral(_rest,_nrest).

{* Fall 3/4/5 wie oben. Abbruch der Schleife
*}
insertProveLiteral(_lit,_lit) :-
	specialFunctor(_lit),
	!.

insertProveLiteral(not(_lit),_nlit) :-
	!,
	insertNotProveLiteral(_lit,_nlit).

#IF(BIM)
insertProveLiteral(_lit,'prove_literal$Literals'(_lit)).
#ELSE()
#PLAIN(insertProveLiteral(_lit,'\'Literals\':prove_literal'(_lit)).)
#ENDIF(BIM)


{* insertNotProveLiteral sorgt dafuer, dass fuer ein Literal 'not P(x)' *}
{* als Prolog-Code not_prove_literal$Literals(P(x)) generiert wird.     *}
{* Frueher wurde einfach 'not prove_literal$Literals(P(x))' generiert.  *}
{* Die neue Version erlaubt eine expliziete Behandlung von Negation in  *}
{* Literals.pro.   9-Jan-2003/M.Jeusfeld                                *}

insertNotProveLiteral(_lit,not(_lit)) :- specialFunctor(_lit).

#IF(BIM)
insertNotProveLiteral(_lit,'not_prove_literal$Literals'(_lit)).
#ELSE()
#PLAIN(insertNotProveLiteral(_lit,'\'Literals\':not_prove_literal'(_lit)).)
#ENDIF(BIM)


{* Ticket #147 *}
#IF(BIM)
produceBoundCall(bound(_x),'bound$Literals'(_x)).
#ELSE()
#PLAIN(produceBoundCall(bound(_x),'\'Literals\':bound'(_x)).)
#ENDIF(BIM)

{* specialFunctor/1 fuegt kein prove_literal ein, wenn _lit einen besonderen Funktor hat
*}
specialFunctor(_lit) :-
	functor(_lit,_fun,_ar),
	specialFunctor(_fun,_ar),
	!.

{ Notwendig, da not ein Builtin-Praedikat ist und somit bei }
{ der naechsten Regel als specialFunctor erkannt werden wuerde. }
specialFunctor(not(_)) :-
    !,
    fail.

{ Notwendig fuer Datalog-Queries, damit alle Builtin-Praedikate nicht }
{ mit prove_literal eingefasst werden }
specialFunctor(_lit) :-
    pc_has_a_definition(_lit).

{* Regelkopf, der vom LTcompiler erzeugt wurde
*}
specialFunctor(_fun,_) :-
	pc_atomconcat('ID_',_,_fun).

{* prove_literal steht schon davor
*}
#IF(BIM)
specialFunctor(prove_literal$Literals,1).
#ELSE()
#PLAIN(specialFunctor('Literals':prove_literal,1).)
#ENDIF(BIM)

{* ist der Kopf einer Anfrage
*}
specialFunctor(_fun,2) :-
	pc_atomconcat('LTevalQuery',_,_fun).

{* ==/2 und ground/1 werden u.U. vom QueryCompiler in eine Regel geschrieben.
*}
specialFunctor('==',2).
specialFunctor('ground',1).

specialFunctor(del,1).
specialFunctor(ins,1).
specialFunctor(red,1).
specialFunctor(new,1).
specialFunctor(plus,1).
specialFunctor(minus,1).


{* ticket #213: test whether _qc has some additional arguments, i.e. *}
{* retrieved/computed attributes or parameters.                      *}
hasAdditionalArgs(_qc) :-
   prove_literal(A(_qc,QueryClass,retrieved_attribute,_));
   prove_literal(A(_qc,QueryClass,computed_attribute,_));
   prove_literal(A(_qc,GenericQueryClass,parameter_attribute,_)).

