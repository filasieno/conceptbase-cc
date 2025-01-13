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

#MODULE(QO_heur)
#EXPORT(cleanLiterals/2)
#EXPORT(earlyRedNegPost/2)
#EXPORT(earlyRedNegPre/2)
#EXPORT(recHeuristic/1)
#ENDMODDECL()



#IMPORT(storeCost/4,QO_costBase)
#IMPORT(buildAllAds/3,QO_literals)
#IMPORT(getVars/2,QO_literals)
#IMPORT(countInstancesRFVartab/3,QO_vartab)
#IMPORT(getVarsBoundExtern/1,QO_vartab)
#IMPORT(memberchk/2,GeneralUtilities)
#IMPORT(subtract/3,GeneralUtilities)
#IMPORT(append/3,GeneralUtilities)
#IMPORT(getHeadLiterals/2,RuleBase)
#IMPORT(getVartabFromRuleInfo/2,RuleBase)
#IMPORT(pc_rerecord/2,PrologCompatibility)
#IMPORT(pc_rerecord/3,PrologCompatibility)
#IMPORT(pc_recorded/2,PrologCompatibility)
#IMPORT(pc_recorded/3,PrologCompatibility)
#IMPORT(pc_erase/1,PrologCompatibility)
#IMPORT(pc_erase/2,PrologCompatibility)
#IMPORT(pc_current_key/1,PrologCompatibility)
#IMPORT(pc_current_key/2,PrologCompatibility)

#IF(SWI)
:- style_check(-singleton).
#ENDIF(SWI)



{================  einfache Optimierungen ============================*}

{*--------------------------------------------------------------------*}
{*                                                                    *}
{* Die eingegebe Literalliste stellt eine Konjunktion dar.            *}
{* Dadurch sind folgende Optmierungen moeglich:                       *}
{*                                                                    *}
{* 1. TRUE - Literale werden aus der Konjunktion entfernt 	      *}
{* 2. tritt ein FALSE auf, so kann es keine Loesung geben             *}
{* 3. Duplikate werden entfernt					      *}
{*                                                                    *}
{* Anmerkung zu 3.                                                    *}
{* Durch die Ersetzung des Parameter-Literals In(_x,_var_XYZ)         *}
{* durch In(_x,<Klasse von x>) im Modul QO_preproc koennen bei        *}
{* Parameter-Queries doppelte In-Literale auftreten.                  *}
{* Tritt In(_x,<Klasse von x>)                                        *}
{* nach der Ersetzung von _var_XYZ durch <Klasse von x> doppelt auf,  *}
{* so kann eines der Vorkommen entfernt werden, auch wenn nach der    *}
{* Optimierung die Ersetzung wieder rueckgaengig gemacht wird.        *}
{* Grund: _var_XYZ ist beim Aufruf der Query immer  an eine Subklasse *}
{* der <Klasse von x> gebunden.					      *}
{*                                                                    *}
{*--------------------------------------------------------------------*}

#MODE( cleanLiterals(i,o))

cleanLiterals(_litsIn,[FALSE]) :-
	memberchk(FALSE,_litsIn),!.
cleanLiterals(_litsIn,_lits) :-
	cleanLiterals1(_litsIn,_lits).

#MODE( cleanLiterals1(i,o))

cleanLiterals1([],[]).
cleanLiterals1([TRUE|_litsIn],_lits) :-
	!,
	cleanLiterals1(_litsIn,_lits).
cleanLiterals1([_l|_litsIn],_lits) :-
	memberchk(_l,_litsIn),!,
	cleanLiterals1(_litsIn,_lits).
cleanLiterals1([_l|_litsIn],[_l|_lits]) :-
	cleanLiterals1(_litsIn,_lits).


{================= early reduction fuer negierte Literale ============*}

{*--------------------------------------------------------------------*}
{* Behandlung negierter Literale:                                     *}
{* 1. negierte Literale duerfen erst dann ausgewertet werden, wenn    *}
{* beide Argumente gebunden sind                                      *}
{* 2. oft liegen die Kosten negierter Literale nach dem Kostenmodell  *}
{* nahe bei 1, obwohl sie deutlich bessere Selektionsbedingungen      *}
{* ausdruecken                                                        *}
{*                                                                    *}
{* Die Heuristik beruht auf der Annahme, das bestimmte negierte       *}
{* Literale so frueh wie moeglich ausgewertet werden sollen           *}
{*                                                                    *}
{* Sie werden vor der Bestimmung einer Literalanordnung aus der       *}
{* Literalmenge entfernt und nacher so weit links wie moeglich        *}
{* eingefuegt.                                                        *}
{*--------------------------------------------------------------------*}



testNeg :-
	_lits = [
                Adot('_nid1','_t','_n1'),
                Adot('_nid2','_this','_n'),
                Adot('_tid','_f','_mftId'),
                In(id_3925,'_mfClass'),
                Adot('_nid3',id_3925,'_n1'),
{                Adot('_tid1','_t','_mftId'),}
               	Adot('_did','_f','_d'),
                Adot('_tid2','_this','_mftId'),
{		not(IDENTICAL('_f','_this')),}
                Adot('_nid4','_f','_n')
		],
	earlyRedNegPre(_lits,_newLits),
	earlyRedNegPost(_newLits,_litsOut),
	!.




{*--------------------------------------------------------------------*}
{*                                                                    *}
{* earlyNegPre: Vorbehandlung                                         *}
{* entfernen bestimmter negierter Literale aus der Literalmenge       *}
{*                                                                    *}
{*--------------------------------------------------------------------*}
#MODE( earlyRedNegPre(i,o))

earlyRedNegPre(_lits,_newLits) :-
	earlyRedNegPre1(_lits,_newLits,_litsRemoved),
	pc_rerecord(QOTransTemp,earlyRedNegLits,_litsRemoved).

#MODE( earlyRedNegPre1(i,o,o))

earlyRedNegPre1([],[],[]).
earlyRedNegPre1([_lit|_lits],_newLits,[_lit|_litsRemoved]) :-
	earlyRedNegLiteral(_lit),!,
	earlyRedNegPre1(_lits,_newLits,_litsRemoved).
earlyRedNegPre1([_lit|_lits],[_lit|_newLits],_litsRemoved) :-
	earlyRedNegPre1(_lits,_newLits,_litsRemoved).

{*--------------------------------------------------------------------*}
{*                                                                    *}
{* earlyRedNegPost: Nachbehandlung                                    *}
{* einfuegen der negierten Literale so weit vorne wie moeglich        *}
{*                                                                    *}
{*--------------------------------------------------------------------*}
#MODE( earlyRedNegPost(i,o))

earlyRedNegPost(_lits,_newLits) :-
	pc_recorded(QOTransTemp,earlyRedNegLits,_litsRemoved),
	getVarsBoundExtern(_varsBound),
	insertNegLits(_litsRemoved,_varsBound,_lits,_newLits).

#MODE( insertNegLits(i,i,i,o))

insertNegLits([],_,_lits,_lits).
insertNegLits([_negLit|_negLits],_varsBound,_oldLits,_lits) :-
	getVars(_negLit,_varsLit),
	(insertNegLit(_negLit,_varsLit,_varsBound,_oldLits,_newLits);
	 append(_oldLits,[_negLit],_newLits)),!,        {* gelingt keine Einfuegung, dann
							    ganz nach hinten in der Sequenz *}
	insertNegLits(_negLits,_varsBound,_newLits,_lits).

#MODE( insertNegLit(i,i,i,i,o))

insertNegLit(_negLit,_varsLit,_varsBound,_oldLits,[_negLit|_oldLits]) :-
	subtract(_varsLit,_varsBound,_remVars),
	_remVars == [],!.
insertNegLit(_negLit,_varsLit,_varsBound,[_actLit|_oldLits],[_actLit|_lits]) :-
	subtract(_varsLit,_varsBound,_remVars),
	_remVars \== [],
	getVars(_actLit,_varsBoundNow),
	insertNegLit(_negLit,_remVars,_varsBoundNow,_oldLits,_lits).



{* this predicate determines which negated literals are subjected *}
{* to the re-ordering heuristic ("put ngated predicates at the    *}
{* first place where all their variables are bound.               *}
{* 20-Oct-2003/M.Jeusfeld: Apply this to virtuall ALL negated     *}
{* literals. Otherwise, we will generate under some circumstances *}
{* some rules whose conditions starts with not(lit) where lit is  *}
{* containing variables.                                          *}
{* See also CBNEWS.doc, point 207                                 *}

#MODE( earlyRedNegLiteral(i))

earlyRedNegLiteral(not(_lit)) :-
	_lit =.. [_func|_],
        !.
{* old restriction disabled now:
	memberchk(_func,[IDENTICAL,UNIFIES,EQ,From,To,Label,P]),!.
*}

earlyRedNegLiteral(NE(_x,_y)).



{================  rekursive Regeln ==================================*}

#MODE( recHeuristic(i))

recHeuristic([]).
recHeuristic([_recCycle|_recCycles]) :-
	getHeadLiterals(_recCycle,_headLiterals),
	storeRecCostEstimates(_headLiterals),
	recHeuristic(_recCycles).



#MODE( storeRecCostEstimates(i))

storeRecCostEstimates([]) :-
	storeRecCostInfos.
storeRecCostEstimates([_ruleId-_head|_ruleInfos]) :-
	pc_current_key(QO_recRules,_ruleId),!,
	storeRecCostEstimates(_ruleInfos).
storeRecCostEstimates([_ruleId-_head|_ruleInfos]) :-
	getVartabFromRuleInfo(_ruleId,_vartab),
	countMaximalExtension(_head,_vartab,_costInfos),
	pc_rerecord(QO_recRules,_ruleId,_costInfos),
	storeRecCostEstimates(_ruleInfos).


storeRecCostInfos :-
	findall(_head,
		(
			pc_current_key(QO_recRules,_ruleId),
		 	pc_recorded(QO_recRules,_ruleId,cost(_head,_costInfos)),
		 	storeRecCostInfosForHead(_head,_costInfos),
		 	pc_erase(QO_recRules,_ruleId)),
		_).


#MODE( storeRecCostInfosForHead(i,i))

storeRecCostInfosForHead(_,[]).
storeRecCostInfosForHead(_head,[_ad-_cost|_costInfos]) :-
	storeCost(_head,_ad,_cost,_cost),
	storeRecCostInfosForHead(_head,_costInfos).


#MODE( countMaximalExtension(i,i,o))

countMaximalExtension(_head,_vartab,cost(_head,_costInfos)) :-
	buildAllAds(_head,_args,_ads),
	countMaximalExtensionWithAds(_args,_ads,_vartab,_costInfos).


#MODE( countMaximalExtensionWithAds(i,i,i,o))

{ Hier sollte eigentlich, die maximale Extension des rekursiven Literals berechnet werden. }
{ Das gibt aber Probleme, falls die Extension sehr klein ist. Dann treten naemlich links rekursive }
{ Regeln auf, die auch mit kleinen Extensionen nicht berechnet werden koennen. }
{ Daher wird hier infinity eingesetzt, damit die rekursiven Literale moeglichst weit rechts stehen. }
{ 30.3.98/CQ }
countMaximalExtensionWithAds(_,[],_vartab,[]).
countMaximalExtensionWithAds(_args,[_ad|_ads],_vartab,[_ad-infinity|_counts]) :-
	{ countMaximalExtensionWithAd(_args,_ad,_vartab,1,_count), }
	countMaximalExtensionWithAds(_args,_ads,_vartab,_counts).


#MODE( countMaximalExtensionWithAd(i,i,i,i,o))

countMaximalExtensionWithAd([],[],_,_count,_count).
countMaximalExtensionWithAd([_arg|_args],[f|_ads],_vartab,_oldCount,_count) :-
	!,
	countInstancesRFVartab(_arg,_vartab,_inst),
	_newCount is _oldCount * _inst,
	countMaximalExtensionWithAd(_args,_ads,_vartab,_newCount,_count).
countMaximalExtensionWithAd([_arg|_args],[_|_ads],_vartab,_oldCount,_count) :-
	countMaximalExtensionWithAd(_args,_ads,_vartab,_oldCount,_count).



