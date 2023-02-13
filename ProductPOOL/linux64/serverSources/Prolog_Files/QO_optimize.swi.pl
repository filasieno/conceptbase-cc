/**
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
**/

:- module('QO_optimize',[
'bestFirst'/0
,'optimizeDatalogRules'/2
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').



:- use_module('QO_preproc.swi.pl').



:- use_module('QO_costBase.swi.pl').



:- use_module('QO_costs.swi.pl').

:- use_module('QO_heur.swi.pl').
:- use_module('QO_literals.swi.pl').







:- use_module('QO_vartab.swi.pl').
:- use_module('QO_search.swi.pl').
:- use_module('QO_utils.swi.pl').
:- use_module('RuleBase.swi.pl').






:- use_module('QueryCompiler.swi.pl').




:- use_module('GeneralUtilities.swi.pl').


:- use_module('GlobalParameters.swi.pl').
:- use_module('PrologCompatibility.swi.pl').







:- use_module('MetaUtilities.swi.pl').


:- style_check(-singleton).





/**--------------------------------------------------------------------**/
/**								      **/
/** Hauptmodul des Anfrageoptimierers 				      **/
/**								      **/
/**								      **/
/**								      **/
/**								      **/
/**--------------------------------------------------------------------**/
optimizeDatalogRules([],[]) :-!.
optimizeDatalogRules(_ruleIds,_optDataOut) :-

	/** 1. Vorbehandlung zur Entdeckung und
	      Aufloesung rekursiver Abhaengigkeiten **/
	findRecRules(_ruleIds,_recRules),
	recHeuristic(_recRules),

	/** 2. Bestimmung der OptimierungSreihenfolge **/
	orderLocalRules(_ruleIds,_recRules,_rulesOrdered),
	'WriteTrace'(veryhigh,'QO_optimize',['Start optimization ...']),
	pc_time(optimizeRules(_rulesOrdered,_optDataOut),_t),
        'WriteListOnTrace'(veryhigh,[_t, ' sec used for optimization']).


optimizeRules([],[]).

optimizeRules([_ruleId|_ruleIds],[_ruleId-[(_head :- _tail)]|_optDatas]) :-
    get_cb_feature('RangeFormOptimizing',_a),
    pc_inttoatom(_i,_a),
    _i < 2,
    !,
    getHeadFromRuleInfo(_ruleId,_head),
	getTailFromRuleInfo(_ruleId,_tail1),
	'List2Conjunct'(_tail1,_tail),
	optimizeRules(_ruleIds,_optDatas).

optimizeRules([_ruleId|_ruleIds],[_ruleId-[(_head :- _tail)]|_optDatas]) :-
	getHeadFromRuleInfo(_ruleId,_head),
	_head =.. [_functor|_args],
	(member(_functor,['LTevalQuery',ins,del,red,new,plus,minus]);
	pc_atomconcat('vm_',_,_functor)),
	!,
	getTailFromRuleInfo(_ruleId,_tail1),
	'List2Conjunct'(_tail1,_tail),
	optimizeRules(_ruleIds,_optDatas).


optimizeRules([_ruleId|_ruleIds],[_ruleId-_rulesOpt|_optDatas]) :-
	getHeadFromRuleInfo(_ruleId,_head),
	getTailFromRuleInfo(_ruleId,_tail1),
	'List2Conjunct'(_tail1,_tail),
	getOptParFromRuleInfo(_ruleId,_optPar),
	setOptParameters(_optPar),
	getVartabFromRuleInfo(_ruleId,_vartab),
	initOptStructures(_vartab),
	checkAllBound(_head),
	optimizeRule(_ruleId,(_head :- _tail),_rulesOpt),
	optimizeRules(_ruleIds,_optDatas).


/** Fall 1:	Regeln, die hier den Funktor LTevalQuery haben,
		dienen der Behandlung von Literalen der Form
		In(_x,_qc), wobei _qc eine Query-Class ist. Die
		Anordnung der Literale im Rumpf ist schematisch
		vorgegeben und soll nicht geandert werden.
**/



/** Fall 2:	Regeln die optimiert werden **/
optimizeRule(_ruleId,_rule,_ruleOpt) :-
	preprocRule(_rule,_head,_literalsPre),
	optimizeLiteralSequence(_ruleId,_literalsPre,_head,_ruleOpt).




optimizeLiteralSequence(_ruleid,_literals,_head,[_ruleOpt]) :-
	optParAllFree,
	bestFirstSearch(_head,_literals,_literalsOpt1),
	postprocRule(_literalsOpt1,_head,_ruleOpt),
	removeSecondaryFunctors([_head],[_head_ohne_functor]),
	buildAllAdsForHead(_head_ohne_functor,_ads),
	getArgs(_head_ohne_functor,_args),
	storeCostsAllAds(_ruleid,_ruleOpt,_ads,[],_args),
	!.




storeCostsAllAds(_ruleid,(_head :- _opttail),[],_costs,_) :-
	'Conjunct2List'(_opttail,_opttaillist),
	storeAllOptPars(_ruleid,_opttaillist,_costs).

storeCostsAllAds(_ruleid,(_head :- _tail),[_ad|_ads],_costs,_args) :-
	'Conjunct2List'(_tail,_literals),
	getVarsBoundFromArgs(_args,_ad,_varsBound),
	setExternBound(_varsBound),
	calcComputationCost(_literals,_fanOut,_costEval),
	'WriteTrace'(veryhigh,'QO_optimize',['Rule optimized: ', _head,' :- ',_tail,' \n Adornment: ',_ad,'\n Fan-Out: ',_fanOut,'\n Costs: ',_costEval]),
	storeCost(_head,_ad,_fanOut,_costEval),
	buildKey(_head,_ad,_key),
	store_optPar_for_LTevalQuery(_head,_ad,_fanOut,_costEval),
	storeCostsAllAds(_ruleid,(_head :- _tail),_ads,[cost(_key,_fanOut,_costEval)|_costs],_args).


checkAllBound(_head) :-
	allBound(_head),!,
	getVars(_head,_vars),
	setExternBound(_vars).
checkAllBound(_).



buildAllAdsForHead(_head,_ads) :-
	_head =.. [_func|[_term]],
	member(_func,[plus,minus,new,ins,del,red]),
	!,
	buildAllAdsForHead(_term,_ads).

buildAllAdsForHead(_head,[_ad]) :-
	allBound(_head),!,
	bindAllVarsInAd(_head,_ad).


buildAllAdsForHead(_head,_ads) :-
	_head =.. [_id|_args],
        is_id(_id),  /** pc_atomconcat('id_',_,_id), **/
	('SubQuery'(_id,_);'Query'(_id)),
	!,
	get_QueryStruct(_id,_qstr),
	findall(_ad,buildAdWithQS(_args,_qstr,_ad),_ads).

/*Sonder Fall fuer Hilfsregel
Wenn parameter mehr als 4, dann so es nur 2 Belegungsmuster liefern, sonst verschwendet zu viel zeit!*/

buildAllAdsForHead(_head,[_ad1,_ad2]) :-
	_head =.. [_id|_args],
	pc_atomconcat('ID_',_,_id),
	length(_args,_l),
	_l > 4,
    !,
	buildAd1(_args,_ad1,_ad2).

buildAllAdsForHead(_head,_ads) :-
	_head =.. [_id|_args],
	pc_atomconcat('vm_',_,_id),
	!,
	get_QueryStruct(_id,_qstr),
	findall(_ad,buildAdWithQS(_args,_qstr,_ad),_ads).

buildAllAdsForHead(_head,_ads) :-
	buildAllAds(_head,_ads).



buildAd1([],[],[]):-!.
buildAd1([_|_r],[f|_fr],[b|_br]):-
	buildAd1(_r,_fr,_br).



buildAdWithQS([],[],[]).

buildAdWithQS([_,_|_rargs],[r(_)|_rest],[f,f|_rad]) :-
	buildAdWithQS(_rargs,_rest,_rad).
buildAdWithQS([_|_rargs],[c(_)|_rest],[f|_rad]) :-
	buildAdWithQS(_rargs,_rest,_rad).
buildAdWithQS([_|_rargs],[this|_rest],[f|_rad]) :-
	buildAdWithQS(_rargs,_rest,_rad).
buildAdWithQS([_|_rargs],[this|_rest],[b|_rad]) :-
	buildAdWithQS(_rargs,_rest,_rad).

buildAdWithQS([_,_,_class|_rargs],[rp(_,_)|_rest],[f,f,_bclass|_rad]) :-
	((isConst(_class),_bclass=c);					 /**Change: der Fall "c" wird auch beruecksichtigt . **/
	 (isVar(_class),_bclass=b)
    ),
	buildAdWithQS(_rargs,_rest,_rad).

buildAdWithQS([_,_,_class|_rargs],[rp(_,_)|_rest],[b,f,_bclass|_rad]) :-
	((isConst(_class),_bclass=c);
	 (isVar(_class),_bclass=b)
    ),
	buildAdWithQS(_rargs,_rest,_rad).

buildAdWithQS([_,_class|_rargs],[cp(_,_)|_rest],[f,_bclass|_rad]) :-
	((isConst(_class),_bclass=c);
	 (isVar(_class),_bclass=b)
    ),
	buildAdWithQS(_rargs,_rest,_rad).

buildAdWithQS([_,_class|_rargs],[cp(_,_)|_rest],[b,_bclass|_rad]) :-
	((isConst(_class),_bclass=c);
	 (isVar(_class),_bclass=b)
    ),
	buildAdWithQS(_rargs,_rest,_rad).

buildAdWithQS([_,_class|_rargs],[p(_,_)|_rest],[f,_bclass|_rad]) :-
	((isConst(_class),_bclass=c);
	 (isVar(_class),_bclass=b)
    ),
	buildAdWithQS(_rargs,_rest,_rad).
buildAdWithQS([_,_class|_rargs],[p(_,_)|_rest],[b,_bclass|_rad]) :-
	((isConst(_class),_bclass=c);
	 (isVar(_class),_bclass=b)
    ),
	buildAdWithQS(_rargs,_rest,_rad).



naiveSearch(_literals,_cheapest) :-
	findall(_costs-_litsPerm,
		(perm(_literals,_litsPerm),
		 testCosts(_litsPerm,_costs),
		 _costs \== infinity),
	_litList),
	keysort(_litList,_ls),
	_ls = [_cost-_cheapest|_].






setOptParameters(_) :-
	setDefault(ads),
	setDefault(search).




setDefault(ads) :-
	pc_rerecord('QO_optPar',ads,allFree).

setDefault(search) :-
	pc_rerecord('QO_optPar',search,bestFirst).

optParAllFree :-
	pc_recorded('QO_optPar',ads,allFree).

bestFirst :-
	pc_recorded('QO_optPar',search,bestFirst).

cheapestFirst :-
	pc_recorded('QO_optPar',search,cheapestFirst).
