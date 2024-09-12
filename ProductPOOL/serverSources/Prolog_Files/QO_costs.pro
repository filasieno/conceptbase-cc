{*
The ConceptBase.cc Copyright

Derived from ConceptBase.cc, originally created by the ConceptBase Team under a FreeBSD-style license.

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

#MODULE(QO_costs)
#EXPORT(calcComputationCost/3)
#EXPORT(costLitsFromState/3)
#EXPORT(getCostFromState/2)
#EXPORT(getLatestLitFromState/2)
#EXPORT(getOrderFromState/2)
#EXPORT(initState/2)
#EXPORT(testCosts/2)
#EXPORT(updateState/3)
#ENDMODDECL()



#IMPORT(getCost/4,QO_costBase)
#IMPORT(buildAdForLit/4,QO_literals)
#IMPORT(getConstList/2,QO_literals)
#IMPORT(prove_literal/1,Literals)
#IMPORT(qo_inSysClass/2,QO_literals)
#IMPORT(testAllGround/1,QO_literals)
#IMPORT(sysForbidden/1,QO_literals)
#IMPORT(countInstances/2,QO_profile)
#IMPORT(freq/3,QO_profile)
#IMPORT(instSrc/2,QO_profile)
#IMPORT(instDest/2,QO_profile)
#IMPORT(sol/2,QO_profile)
#IMPORT(sol_withClass/3,QO_profile)
#IMPORT(getGlobal/2,QO_profile)
#IMPORT(sumlistReal/2,QO_utils)
#IMPORT(bindVarsInVartab/3,QO_vartab)
#IMPORT(getSmallestSuperClass/4,QO_vartab)
#IMPORT(getVarsBoundFromVartab/2,QO_vartab)
#IMPORT(getVarsBoundExtern/1,QO_vartab)
#IMPORT(cleanVT/0,QO_vartab)
#IMPORT(initVT/2,QO_vartab)
#IMPORT(updateVTFromLit/3,QO_vartab)
#IMPORT(getVarInfo/3,QO_vartab)
#IMPORT(getSmallestClassFromVarInfo/2,QO_vartab)
#IMPORT(perm/2,QO_utils)
#IMPORT(save_plus/3,QO_utils)
#IMPORT(save_mult/3,QO_utils)
#IMPORT(save_minus/3,QO_utils)
#IMPORT(save_div/3,QO_utils)
#IMPORT(undefined/1,QO_utils)
#IMPORT(name2id/2,GeneralUtilities)
#IMPORT(member/2,GeneralUtilities)
#IMPORT(pc_atomconcat/2,PrologCompatibility)
#IMPORT(pc_atomconcat/3,PrologCompatibility)
#IMPORT(isComplexComparisonLit/1,QO_preproc)
#IMPORT(isQLit/1,QO_preproc)
#IMPORT(is_id/1,MetaUtilities)

#IF(SWI)
:- style_check(-singleton).
#ENDIF(SWI)





testCosts(_literals,_costs) :-
	initState(_literals,_initState),
	testUpdate(_literals,_initState,_state),!,
	getCostFromState(_state,_costs).


testUpdate([],_state,_state) :-
	getCostFromState(_state,_cost).

testUpdate([_lit|_lits],_oldState,_state) :-
	updateState(_oldState,_lit,_newState),
	testUpdate(_lits,_newState,_state).



#MODE( calcComputationCost(i,o,o))

calcComputationCost(_literals,_fanOut,_costEval) :-
	initState(_literals,_initState),
	calcSequenceCost(_literals,_initState,_state),
	_state = state(_,_costEval,cost(_fanOut,_),_,_,_,_,_).


#MODE( calcSequenceCost(i,i,o))

calcSequenceCost([],_state,_state).
calcSequenceCost([_lit|_lits],_oldState,_state) :-
	updateState(_oldState,_lit,_newState),
	calcSequenceCost(_lits,_newState,_state).


{*--------------------------------------------------------------------*}
{* 						                      *}
{* Verwaltung der Datenstruktur zur Speicherung des                   *}
{* Berechnungszustands nach Bestimmung der Kosten                     *}
{* fuer das i-te Literal.                                             *}
{*                                                                    *}
{* Funktor: state                                                     *}
{* Komponenten:                                                       *}
{*     order: bisher berechnete Anordnung                             *}
{*     costTotal: Gesamtkosten			                      *}
{*     costTerm(anzSol,costEval):		                      *}
{*	    anzSol: geschaetzte Anzahl Loesungen                      *}
{* 	    costEval: geschaetzte Auswertungskosten                   *}
{*     const: Konstanten in der Sequenz                               *}
{*     varsBound: in order gebundene Variablen                        *}
{*     vartab: Variablentabelle 		                      *}
{*     viewMatch: Status der syntaktischen Subsumtionsbeziehungen     *}
{*     histMatch: Anwendbarkeit von Histogrammen 		      *}
{* 						                      *}
{*--------------------------------------------------------------------*}


#MODE( initState(i,o))

initState(_literals,
          state(_order,_costTotal,cost(_anzSol,_costEval),_const,_varsBound,_vartab,_viewMatch,_histMatch)
	 ) :-
	_order = [],
	_costTotal = 0.0,
	_anzSol = 1.0,
	_costEval = 0.0,
	getConstList(_literals,_const),
	getVarsBoundExtern(_varsBound),
	initVT(_literals,_vartab0),
	bindVarsInVartab(_varsBound,_vartab0,_vartab),
	undefined(_viewMatch),
	undefined(_histMatch),!.
	{*
		initViewMatch(_viewMatch),
		initHistMatch(_histMatch),!.
	*}



#MODE( updateState(i,i,o))

updateState(_oldState,_lit,_newState) :-
	costLitFromState(_lit,_oldState,_costTerm),
	updateCostInState(_oldState,_costTerm,_newState1),
	updateHistMatchInState(_newState1,_lit,_newState2),
	updateViewMatchInState(_newState2,_lit,_newState3),
	updateVartabInState(_newState3,_lit,_newState4),
	updateOrderInState(_newState4,_lit,_newState).


#MODE( updateCostInState(i,i,o))

updateCostInState(state(_order,_costOld,cost(_oldAnzSol,_oldCostEval),_const,_varsBound,_vartab,_viewMatch,_histMatch),
		  cost(_fanOut,_litCostEval),
	          state(_order,_cost,cost(_anzSol,_costEval),_const,_varsBound,_vartab,_viewMatch,_histMatch)) :-
	save_mult(_oldAnzSol,_fanOut,_anzSol),
	save_plus(_oldCostEval,_litCostEval,_costEval),
	save_plus(_costOld,_anzSol,_temp),
	save_plus(_temp,_costEval,_cost),!.

#MODE( updateVartabInState(i,i,o))

updateVartabInState(state(_order,_cost,_costTerm,_const,_,_vartabOld,_viewMatch,_histMatch),
		    _lit,
	            state(_order,_cost,_costTerm,_const,_varsBound,_vartab,_viewMatch,_histMatch)) :-
	updateVTFromLit(_vartabOld,_lit,_vartab),
	getVarsBoundFromVartab(_vartab,_varsBound),!.


#MODE( updateHistMatchInState(i,i,o))

updateHistMatchInState(state(_order,_cost,_costTerm,_const,_varsBound,_vartab,_viewMatch,_histMatchOld),
		       _lit,
	               state(_order,_cost,_costTerm,_const,_varsBound,_vartab,_viewMatch,_histMatch)) :-
	updateHistMatch(_histMatchOld,_lit,_histMatch),!.

updateHistMatch(_m,_,_m).


#MODE( updateViewMatchInState(i,i,o))

updateViewMatchInState(state(_order,_cost,_costTerm,_const,_varsBound,_vartab,_viewMatchOld,_histMatch),
		       _lit,
	               state(_order,_cost,_costTerm,_const,_varsBound,_vartab,_viewMatch,_histMatch)) :-
	updateViewMatch(_viewMatchOld,_lit,_viewMatch),!.

updateViewMatch(_m,_,_m).

#MODE( updateOrderInState(i,i,o))

updateOrderInState(state(_order,_cost,_costTerm,_const,_varsBound,_vartab,_viewMatchOld,_histMatch),
		   _lit,
		   state([_lit|_order],_cost,_costTerm,_const,_varsBound,_vartab,_viewMatchOld,_histMatch)) :- !.

#MODE( getConstFromState(i,o))

getConstFromState(state(_order,_cost,_costTerm,_const,_varsBound,_vartab,_viewMatchOld,_histMatch),_const).

#MODE( getVarsBoundFromState(i,o))

getVarsBoundFromState(state(_order,_cost,_costTerm,_const,_varsBound,_vartab,_viewMatchOld,_histMatch),_varsBound).

#MODE( getCostFromState(i,o))

getCostFromState(state(_order,_cost,_costTerm,_const,_varsBound,_vartab,_viewMatchOld,_histMatch),_cost).

#MODE( getVartabFromState(i,o))

getVartabFromState(state(_order,_cost,_costTerm,_const,_varsBound,_vartab,_viewMatchOld,_histMatch),_vartab).


#MODE( getLatestLitFromState(i,o))

getLatestLitFromState(state([_latest|_],_cost,_costTerm,_const,_varsBound,_vartab,_viewMatchOld,_histMatch),_latest).

#MODE( getOrderFromState(i,o))

getOrderFromState(state(_order,_cost,_costTerm,_const,_varsBound,_vartab,_viewMatchOld,_histMatch),_order).



#MODE( costLitsFromState(i,i,o))

costLitsFromState([],_,[]).
costLitsFromState([_lit|_lits],_state,[_cost-_lit|_costs]) :-
	costLitFromState(_lit,_state,cost(_fanOut,_costEval)),
	save_plus(_fanOut,_costEval,_cost),
	costLitsFromState(_lits,_state,_costs).


#MODE( costLitFromState(i,i,?))

costLitFromState(_lit,_state,_costTerm) :-
		getCostFromState(_state,_cost),
		_cost \== infinity,!,
		getConstFromState(_state,_const),
		getVarsBoundFromState(_state,_varsBound),
		getVartabFromState(_state,_vartab),
		buildAdForLit(_lit,_const,_varsBound,_litAd),
		Cost_lit(_litAd,_vartab,_costTerm).

costLitFromState(_lit,_state,_costTerm) :-
		getCostFromState(_state,_cost),
		_cost == infinity,!,
		_costTerm = cost(0.0,0.0).


{*---------------------------------------------------------------*}
{* 								 *}
{* Cost_lit							 *}
{* 								 *}
{* Hier die Berechnung der Literalcosten wird wegen Vmrules um   *}
{* Faelle wie new(lit),red(lit)... erweitert. Man merkt, new(lit)*}
{* wie lit, und fanOutExt fuer die restliche ist 1.0 .		 *}
{*---------------------------------------------------------------*}
#MODE( Cost_lit(i,i,?))

Cost_lit(lit(Mod(_lit),_ad),_vartab,cost(_fanOut,_costEval)) :-
	!,
	Cost_lit(lit(_lit,_ad),_vartab,cost(_fanOut,_costEval)).

Cost_lit(lit(new(_lit),_ad),_vartab,cost(_fanOut,_costEval)) :-
	!,
	Cost_lit(lit(_lit,_ad),_vartab,cost(_fanOut,_costEval)).



Cost_lit(lit(red(_lit),_ad),_,cost(_fanOut,_costEval)) :-
	Cost_litEval(lit(red(_lit),_ad),_fanOutInt,_costEval),
	save_plus(1.0,_fanOutInt,_fanOut),
	!.
Cost_lit(lit(ins(_lit),_ad),_,cost(_fanOut,_costEval)) :-
	Cost_litEval(lit(ins(_lit),_ad),_fanOutInt,_costEval),
	save_plus(1.0,_fanOutInt,_fanOut),
	!.
Cost_lit(lit(del(_lit),_ad),_,cost(_fanOut,_costEval)) :-
	Cost_litEval(lit(del(_lit),_ad),_fanOutInt,_costEval),
	save_plus(1.0,_fanOutInt,_fanOut),
	!.

Cost_lit(lit(plus(_lit),_ad),_,cost(_fanOut,_costEval)) :-
	Cost_litEval(lit(plus(_lit),_ad),_fanOutInt,_costEval),
	save_plus(1.0,_fanOutInt,_fanOut),
	!.
Cost_lit(lit(minus(_lit),_ad),_,cost(_fanOut,_costEval)) :-
	Cost_litEval(lit(minus(_lit),_ad),_fanOutInt,_costEval),
	save_plus(1.0,_fanOutInt,_fanOut),
	!.



Cost_lit(lit(_lit,_ad),_vartab,cost(_fanOut,_costEval)) :-
	Cost_litExtAdWithVartab(lit(_lit,_ad),_vartab,_fanOutExt),
	!,
	Cost_litEval(lit(_lit,_ad),_fanOutInt,_costEval),
	save_plus(_fanOutExt,_fanOutInt,_fanOut),
	!.



Cost_lit(lit(_lit,_ad),_,cost(_fanOut,_costEval)) :-
	Cost_litExtAd(lit(_lit,_ad),_fanOutExt),
	Cost_litEval(lit(_lit,_ad),_fanOutInt,_costEval),
	save_plus(_fanOutExt,_fanOutInt,_fanOut),
	!.




{*---------------------------------------------------------------*}
{* 								 *}
{* Cost_litExtAdWithVartab(lit-term,vartab,cost):		 *}
{* Eingabe: lit-term: lit(lit,ad) 				 *}
{*	lit: Literal, als ground-Term				 *}
{*	vartab: Variablentabelle				 *}
{* 	ad:  Belegungsmuster: Liste von 'f', 'b' und 'c'	 *}
{* 								 *}
{* Ausgabe: cost						 *}
{*      Kosten: positive Real-Zahl oder Atom 'infinity'          *}
{* 								 *}
{* 								 *}
{* Cost_litExtAd liefert eine Schaetzung des extensionalen       *}
{* Fan-Outs des Literals lit mit Belegungsmuster ad              *}
{* Das dreistellige Literal betrachtet die Faelle, in denen	 *}
{* Informationen aus der Variablentabelle Beruecksichtigung	 *}
{* finden.							 *}
{* So ist bei lit(In(_x,_c),[b,c]) mindestens eine Klasse 	 *}
{* von _x bekannt. Damit kennt man eine Klassenbindung fuer _x   *}
{* Es wird davon ausgegangen, dass, wenn _x gebunden ist         *}
{* _x insbesondere an diese Klassen gebunden ist. Das muss wg.	 *}
{* der wegoptimierten In-Literale aber nicht der Fall sein.	 *}
{* 								 *}
{*---------------------------------------------------------------*}
#MODE( Cost_litExtAdWithVartab(i,i,o))

Cost_litExtAdWithVartab(lit(not(_lit),_ad),_vartab,_cost) :-
	testAllGround(_ad),
	!,
	Cost_litExtAdWithVartab(lit(_lit,_ad),_vartab,_cost1),
	!,
	save_minus(1.0,_cost1,_cost).

Cost_litExtAdWithVartab(lit(In(_x,_c),[b,c]),_vartab,_cost) :-
	getSmallestSuperClass(_x,_c,_vartab,_ssc),
	countInstances(_c,_cInst),
	countInstances(_ssc,_sscInst),
	save_div(_cInst,_sscInst,_cost).

Cost_litExtAdWithVartab(lit(To(_x,_y),[f,b]),_vartab,_cost) :-
	getVarInfo(_y,_vartab,_varInfo),
	getSmallestClassFromVarInfo(_varInfo,_sc),
	countInstances(_sc,_anzY),
	sol_withClass(To(_,_),_sc,_instLinksToY),
	save_div(_instLinksToY,_anzY,_cost).

Cost_litExtAdWithVartab(lit(To(_x,_y),[b,b]),_vartab,_cost) :-
	Cost_litExtAdWithVartab(lit(To(_x,_y),[f,b]),_vartab,_cost1),
	getGlobal(prop,_props),
	save_div(_cost1,_props,_cost).


Cost_litExtAdWithVartab(lit(From(_x,_y),[f,b]),_vartab,_cost) :-
	getVarInfo(_y,_vartab,_varInfo),
	getSmallestClassFromVarInfo(_varInfo,_sc),
	countInstances(_sc,_anzY),
	sol_withClass(From(_,_),_sc,_instLinksToY),
	save_div(_instLinksToY,_anzY,_cost).

Cost_litExtAdWithVartab(lit(From(_x,_y),[b,b]),_vartab,_cost) :-
	Cost_litExtAdWithVartab(lit(From(_x,_y),[f,b]),_vartab,_cost1),
	getGlobal(prop,_props),
	save_div(_cost1,_props,_cost).





{*---------------------------------------------------------------*}
{* 								 *}
{* Cost_litExtAd(lit-term,cost):				 *}
{* Eingabe: lit-term: lit(lit,ad) 				 *}
{*	lit: Literal, als ground-Term				 *}
{* 	ad:  Belegungsmuster: Liste von 'f', 'b' und 'c'	 *}
{* 								 *}
{* Ausgabe: cost						 *}
{*      Kosten: positive Real-Zahl oder Atom 'infinity'          *}
{* 								 *}
{* 								 *}
{* Cost_litExtAd liefert eine Schaetzung des extensionalen       *}
{* Fan-Outs des Literals lit mit Belegungsmuster ad              *}
{* 								 *}
{*---------------------------------------------------------------*}
#MODE( Cost_litExtAd(i,o))

{****************************************************}

Cost_litExtAd(_l,infinity) :-
	sysForbidden(_l),!.

{****************************************************}
{* Meta-Literale
Cost_litExtAd(lit(ground(_),[f]),0.0).
Cost_litExtAd(lit(ground(_),[b]),1.0).
Cost_litExtAd(lit(ground(_),[c]),1.0).


*}

{* ticket #147 *}
Cost_litExtAd(lit(bound(_x),_),0.0).

{****************************************************}
{* not *}
Cost_litExtAd(lit(not(_lit),_ad),_cost) :-
	testAllGround(_ad),!,
	Cost_litExtAd(lit(_lit,_ad),_cost1),!,
	save_minus(1.0,_cost1,_cost).
Cost_litExtAd(lit(not(_lit),_),infinity) :- !.

{****************************************************}
{* arithmetischer Vergleich *}


{* 19-Jul-2007/M.Jeusfeld: complex comparison literals like  *}
{*    EQ(x,COUNT[...]) now get the cost of the arguments.    *}


Cost_litExtAd(lit(_complit,_ad),_cost) :-
  isComplexComparisonLit(_complit),
  _complit =.. [_fun,_arg1,_arg2],
  argCost(_arg1,_ad,_c1),
  argCost(_arg2,_ad,_c2),
  save_plus(_c1,_c2,_cost),
  !.


{* otherwise, comparison literals are very cheap. *}
Cost_litExtAd(lit(LT(_,_),_ad),0.5) :-
	testAllGround(_ad),!.
Cost_litExtAd(lit(LT(_,_),_ad),infinity) :- !.

Cost_litExtAd(lit(LE(_,_),_ad),0.5) :-
	testAllGround(_ad),!.
Cost_litExtAd(lit(LE(_,_),_ad),infinity) :- !.

Cost_litExtAd(lit(GE(_,_),_ad),0.5) :-
	testAllGround(_ad),!.
Cost_litExtAd(lit(GE(_,_),_ad),infinity):- !.

Cost_litExtAd(lit(GT(_,_),_ad),0.5) :-
	testAllGround(_ad),!.
Cost_litExtAd(lit(GT(_,_),_ad),infinity) :- !.


Cost_litExtAd(lit(EQ(_,_),_ad),0.5) :- {* aendern: Minimum von Integer und Real *}
	testAllGround(_ad),!.
Cost_litExtAd(lit(EQ(_,_),_ad),infinity) :- !.

Cost_litExtAd(lit(NE(_x,_y),_ad),_cost) :- {* aendern: 1 - cost(IDENTICAL) *}
	testAllGround(_ad),!,
	Cost_litExtAd(lit(EQ(_x,_y),_ad),_cost1),
	_cost is 1.0 - _cost1,!.
Cost_litExtAd(lit(NE(_,_),_ad),infinity) :- !.

{****************************************************}
{* Vergleichsliterale *}
Cost_litExtAd(lit((_x == _y),_ad),_cost) :-
	Cost_litExtAd(lit(IDENTICAL(_x,_y),_ad),_cost).

Cost_litExtAd(lit(IDENTICAL(_x,_y),_ad),_cost) :-
	testAllGround(_ad),!,
	instSrc(IDENTICAL,_count1),
	instDest(IDENTICAL,_count2),
	_tmp is _count1 * _count2,
	((_tmp > 0.0, _cost is 1.0 / _tmp);
	 (_cost is 0.0)),!.
Cost_litExtAd(lit(IDENTICAL(_,_),_ad),infinity):- !.

Cost_litExtAd(lit((_x = _y),_ad),_cost) :-
	Cost_litExtAd(lit(UNIFIES(_x,_y),_ad),_cost).

{ UNIFIES hat Kosten immer 1.0 unabhaengig von Belegung (auch Variablen
  koennen unifiziert werden) }
Cost_litExtAd(lit(UNIFIES(_x,_y),_ad),1.0) :- !.

{****************************************************}
{* Known *}

Cost_litExtAd(lit(Known(_,_),[b,f]),1.0) :- !.
Cost_litExtAd(lit(Known(_,_),[c,f]),1.0) :- !.
Cost_litExtAd(lit(Known(_,_),[_,_]),infinity) :- !.



{****************************************************}
{* P *}
{*erste Komponente belegt, andere frei
	funktionale Abhaengigkeit: p-> c,m,d *}

Cost_litExtAd(lit(Prop(_p,_c,_m,_d),_ad),_cost) :-
	Cost_litExtAd(lit(P(_p,_c,_m,_d),_ad),_cost).

Cost_litExtAd(lit(P(_p,_c,_m,_d),[b,_,_,_]),1.0) :- !.
Cost_litExtAd(lit(P(_p,_c,_m,_d),[c,_,_,_]),1.0) :- !.

{* erste Komponente frei: nur zulassen, wenn auf
    From, To, Label rueckfuehrbar, d.h. nur die entsprechende
    Komponente ist belegt und erste Komponente frei *}
Cost_litExtAd(lit(P(_p,_c,_m,_d),[f,b,_,_]),_cost) :-
	Cost_litExtAd(lit(From(_p,_c),[f,b]),_cost),!.
Cost_litExtAd(lit(P(_p,_c,_m,_d),[f,c,_,_]),_cost) :-
	Cost_litExtAd(lit(From(_p,_c),[f,c]),_cost),!.

Cost_litExtAd(lit(P(_p,_c,_m,_d),[f,_,b,_]),_cost) :-
	Cost_litExtAd(lit(Label(_p,_m),[f,b]),_cost),!.
Cost_litExtAd(lit(P(_p,_c,_m,_d),[f,_,c,_]),_cost) :-
	Cost_litExtAd(lit(Label(_p,_m),[f,c]),_cost),!.

Cost_litExtAd(lit(P(_p,_c,_m,_d),[f,_,_,b]),_cost) :-
	Cost_litExtAd(lit(To(_p,_d),[f,b]),_cost),!.
Cost_litExtAd(lit(P(_p,_c,_m,_d),[f,_,_,c]),_cost) :-
	Cost_litExtAd(lit(To(_p,_d),[f,c]),_cost),!.


Cost_litExtAd(lit(P(_p,_c,_m,_d),_),infinity).


Cost_litExtAd(lit(Pa(_p,_c,_m,_d),_ad),_cost) :-
	Cost_litExtAd(lit(P(_p,_c,_m,_d),_ad),_cost).


{****************************************************}
{* A *}
{* bestimme alle moeglichen Attribut-Oids und
   zu jedem die durchschnittliche Anzahl von
   Loesungen des Adots *}

{* A_label *}
Cost_litExtAd(lit(A_label(_source,_label,_dest,_instLabel),[_ad1,c,_ad2,c]),1.0). { 1.0 ist etwas optimistisch aber besser als infinity }
Cost_litExtAd(lit(A_label(_source,_label,_dest,_instLabel),[_ad1,c,_ad2,b]),1.0).
Cost_litExtAd(lit(A_label(_source,_label,_dest,_instLabel),[_ad1,c,_ad2,f]),_cost) :-
	Cost_litExtAd(lit(A(_source,_label,_dest),[_ad1,c,_ad2]),_cost).

Cost_litExtAd(lit(A_e(_source,_label,_dest),[_ad1,c,_ad2]),_cost) :-
	Cost_litExtAd(lit(A(_source,_label,_dest),[_ad1,c,_ad2]),_cost).

Cost_litExtAd(lit(A_d(_source,_label,_dest),[_ad1,c,_ad2]),0.0).

Cost_litExtAd(lit(A(_source,_label,_dest),[_ad1,c,_ad2]),_cost) :-
	name2id('Attribute',_attrId),
	findall(_costAdot,
	         (
		  qo_inSysClass(_p,_attrId),
		  Cost_litExtAd(lit(Adot(_p,_source,_dest),[c|[_ad1,_ad2]]),_costAdot)
		 ),
		 _costList),
	sumlistReal(_costList,_cost),!.

{****************************************************}
{* Adot (extensional) *}
Cost_litExtAd(lit(Adot(_p,_x,_y),[c,_ad1,_ad2]),_cost) :-
	 Cost_litExtAd(lit(Adot(_p,_x,_y),[_ad1,_ad2]),_cost),!.

{* Adot_label (extensional) *}
Cost_litExtAd(lit(Adot_label(_p,_x,_y,_l),[c,_ad1,_ad2,c]),1.0). { 1.0 ist etwas optimistisch aber besser als infinity }
Cost_litExtAd(lit(Adot_label(_p,_x,_y,_l),[c,_ad1,_ad2,b]),1.0).
Cost_litExtAd(lit(Adot_label(_p,_x,_y,_l),[c,_ad1,_ad2,f]),_cost) :-
	 Cost_litExtAd(lit(Adot(_p,_x,_y),[_ad1,_ad2]),_cost),!.


{* Aedot is cheaper than its Adot counterpart since it does not involve rules *}
Cost_litExtAd(lit(Aedot(_cc,_x,_y),[_c,_ad1,_ad2]),_cost) :-
	Cost_litExtAd(lit(Adot(_cc,_x,_y),[_c,_ad1,_ad2]),_cost1),
        _cost is _cost1 - 0.1 .

{****************************************************}
{* Ai (extensional) *}
Cost_litExtAd(lit(Ai(_x,_l,_p),[_ad1,c,_ad2]),_cost) :-
    Cost_litExtAd(lit(Ai(_x,_l,_p),[_ad1,_ad2]),_cost),!.

Cost_litExtAd(lit(AttrId(_x,_l,_p),[_ad1,c,_ad2]),_cost) :-
	Cost_litExtAd(lit(Ai(_x,_l,_p),[_ad1,c,_ad2]),_cost).

{****************************************************}
{* Aidot (extensional) *}
Cost_litExtAd(lit(Aidot(_cc,_x,_p),[c,_ad1,c,_ad2]),_cost) :-
	 Cost_litExtAd(lit(Aidot(_cc,_x,_p),[_ad1,_ad2]),_cost),!.


{****************************************************}
{* InstanceOf (extensional) *}
Cost_litExtAd(lit(InstanceOf(_x,_c),[_ad1,_ad2]),_cost) :-
	 Cost_litExtAd(lit(In(_x,_c),[_ad1,_ad2]),_cost),!.

Cost_litExtAd(lit(In_e(_x,_c),[_ad1,_ad2]),_cost) :-
	 Cost_litExtAd(lit(In(_x,_c),[_ad1,_ad2]),_cost),!.

Cost_litExtAd(lit(In_s(_x,_c),[_ad1,_ad2]),_cost) :-
	 Cost_litExtAd(lit(In(_x,_c),[_ad1,_ad2]),_cost),!.

Cost_litExtAd(lit(In_o(_x,_c),[_ad1,_ad2]),_cost) :-
	 Cost_litExtAd(lit(In(_x,_c),[_ad1,_ad2]),_cost),!.

Cost_litExtAd(lit(In_i(_x,_c),[_ad1,_ad2]),_cost) :-
	 Cost_litExtAd(lit(In(_x,_c),[_ad1,_ad2]),_cost),!.

Cost_litExtAd(lit(In_eh(_x,_c),[_ad1,_ad2]),_cost) :-
	 Cost_litExtAd(lit(In(_x,_c),[_ad1,_ad2]),_cost),!.


{****************************************************}
{* IsA (extensional) *}
Cost_litExtAd(lit(IsA(_x,_c),[_ad1,_ad2]),_cost) :-
	 Cost_litExtAd(lit(Isa(_x,_c),[_ad1,_ad2]),_cost),!.

Cost_litExtAd(lit(Isa_e(_x,_c),[_ad1,_ad2]),_cost) :-
	 Cost_litExtAd(lit(Isa(_x,_c),[_ad1,_ad2]),_cost),!.


{****************************************************}
{* Allgemein fuer In, A, Ai, Adot, Aidot, Isa, From, To, Label *}


Cost_litExtAd(lit(_lit,[f,f]),_cost) :-
	sol(_lit,_cost),!.

Cost_litExtAd(lit(_lit,[f,b]),_cost) :-

	sol(_lit,_il),
	instDest(_lit,_id),
	((_id > 0.0,_cost is _il / _id);
	 (_cost = 0.0)),!.

Cost_litExtAd(lit(_lit,[f,c]),_cost) :-
	freq(_lit,d,_cost),!.

Cost_litExtAd(lit(_lit,[b,f]),_cost) :-
	sol(_lit,_il),
	instSrc(_lit,_is),
	((_is > 0.0,_cost is _il / _is);
	 (_cost = 0.0)),!.

Cost_litExtAd(lit(_lit,[b,b]),_cost) :-
	sol(_lit,_il),
	instDest(_lit,_id),
	instSrc(_lit,_is),
	_tmp is _id * _is,
	((_tmp > 0.0, _cost is _il / _tmp);
	 (_cost = 0.0)),!.

Cost_litExtAd(lit(_lit,[b,c]),_cost) :-
	freq(_lit,d,_dh),!,
	instSrc(_lit,_is),
	((_is > 0.0,_cost is _dh / _is);
	 (_cost = 0.0)),!.


Cost_litExtAd(lit(_lit,[c,f]),_cost) :-
	freq(_lit,s,_cost),!.

Cost_litExtAd(lit(_lit,[c,b]),_cost) :-
	freq(_lit,s,_sh),
	instDest(_lit,_id),
	((_id > 0.0,_cost is _sh / _id);
	 (_cost = 0.0)),!.


{* Catchall, beispielsweise fuer Regelkoepfe von
   Teilregeln
Cost_litExtAd(_l,0.0) :- !.
*}

Cost_litExtAd(_l,0.0) :-
	true.




Cost_litEval(lit(_lit,[f|_args]),1.0,1.0) :-
	_lit =.. [_fid|_],
        is_id(_fid),  {* pc_atomconcat('id_',_,_fid), *}
	name2id(Function,_fctid),
	prove_literal(In(_fid2,_fctid)),
	_fid2 = _fid,
	not(member(f,_args)).

Cost_litEval(lit(_lit,_ad),_fanOut,_costEval) :-
	getCost(_lit,_ad,_fanOut,_costEval).


{* 19-Jul-2007/M.Jeusfeld: compute the cost of evaluating the argument of a *}
{* complex query.                                                           *}
argCost(_a,_,0.0) :- atom(_a).

argCost(_query,_ad,_cost) :-
 isQlit(_query),
 Cost_litExtAd(lit(_query,_ad),_cost).

   
