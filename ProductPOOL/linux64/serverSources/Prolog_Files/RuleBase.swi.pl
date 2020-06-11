/**
The ConceptBase.cc Copyright

Copyright 1987-2020 The ConceptBase Team. All rights reserved.

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
**/


:- module('RuleBase',[
'allBound'/1
,'findRecRules'/2
,'genPrologCodeFromInfos'/0
,'getHeadFromRuleInfo'/2
,'getHeadLiterals'/2
,'getOptParFromRuleInfo'/2
,'getTailFromRuleInfo'/2
,'getVartabFromRuleInfo'/2
,'initDatalogRulesInfo'/5
,'initDatalogRulesInfo'/7
,'isAux'/1
,'makeTmpRuleInfosPerm'/0
,'orderLocalRules'/3
,'remove_tmpRuleInfos'/0
,'store_ruleinfos'/1
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').


:- use_module('CodeCompiler.swi.pl').
:- use_module('CodeStorage.swi.pl').
:- use_module('QO_costBase.swi.pl').
:- use_module('QO_literals.swi.pl').




:- use_module('QO_optimize.swi.pl').
:- use_module('GeneralUtilities.swi.pl').
:- use_module('QO_utils.swi.pl').








:- use_module('Literals.swi.pl').



:- use_module('ModelConfiguration.swi.pl').

:- use_module('PrologCompatibility.swi.pl').













:- use_module('MetaUtilities.swi.pl').




:- style_check(-singleton).




/**=========================================================**/
/**                                                         **/
/** Das Modul ruleBase verwaltet Informationen zur Erzeugung**/
/** der Prolog-Regeln einer Applikation                     **/
/** Die Prolog-Regeln werden aus Datalog-Regeln erzeugt.    **/
/** Grundlage fuer die Erzeugung des Prolog-Codes sind die  **/
/** ruleInfo-Eintraege der entsprechenden Datalog-Regeln    **/
/**                                                         **/
/** Folgende Information wird in den ruleInfo-EIntraegen    **/
/** verwaltet:                                              **/
/**                                                         **/
/** ruleId:  eindeutiger systemgenerierter Identifikator    **/
/**                                                         **/
/** ruleCat: Kategorie der Regel:                           **/
/**          Moegliche Werte                                **/
/**          * view:  Regel zur Sichtenwartung              **/
/**          * query: Code einer Query                      **/
/**          * rule:  Code einer deduktiven Regel           **/
/**          * system: Regel ist nicht benutzerdefiniert    **/
/**                                                         **/
/** objId:   id des Objekts, dessen Gueltigkeit notwendig   **/
/**          fuer die Gueltigkeit der Regel ist             **/
/**                                                         **/
/** ids:     ID-Struct fuer Query oder Regel, Parameter     **/
/**          z.B. bei handleCode$CodeStorage                **/
/**          (kann vielleicht weg, wenn handleCode ersetzt) **/
/**                                                         **/
/** head:    Kopfliteral der Regel                          **/
/**                                                         **/
/** body:    Menge der Literale im Regelrumpf               **/
/**                                                         **/
/** depsOn:  Menge der ruleIds, von der die aktuelle        **/
/**          Regel abhaengt                                 **/
/**                                                         **/
/** vartab:  Variablentabelle aus der Rangeform             **/
/**          Uebersetzung                                   **/
/**                                                         **/
/** optPar:  Optimierungsparameter                          **/
/**                                                         **/
/** relAlgExp: relationaler Algebra-Ausdruck                **/
/**                                                         **/
/**                                                         **/
/** Waehrend einer Transaktion wird fuer jede neu generierte**/
/** Datalog-Regel ein temporaerer ruleInfo-Eintrag erzeugt, **/
/** welcher den Funktor 'tmpRuleInfo' besitzt. Dieser wird  **/
/** sukzessive gefuellt und bei Beendigung der Transaktion  **/
/** als 'ruleInfo'-Fakt persistent gespeichert.             **/
/**                                                         **/
/** Bei der Erzeugung der Datalog-Regeln werden "normale"   **/
/** Regeln und Hilfsregeln unterschieden. Hilfsregeln sind  **/
/** immer lokal zu einer Regel oder Anfrage, ihre           **/
/** Kopfliterale koennen daher nur in den Datalog-Regeln    **/
/** auftreten, die zu einer bestimmten Regel/Anfrage        **/
/** gehoeren. Die Komponenten des Abhaengigkeitsgraphen     **/
/** in denen diese Regeln auftreten, sind daher statisch,   **/
/** d.h. durch eine nachfolgende Transaktion koennen keine  **/
/** neuen "dependsOn"-Eintraege entstehen, in denen die     **/
/** Ids dieser Hilfsregeln auftreten. Daher macht es Sinn,  **/
/** globale und lokale Abhaengigkeiten zu unterscheiden:    **/
/**                                                         **/
/**  * Regeln mit Kopfliteralen, die an beliebiger          **/
/**    Stelle auftreten koennen, also z.B. In- oder         **/
/**    Adot-Literalen, muessen in einem globalen            **/
/**    Abhaengigkeitsgraphen verwaltet werden.              **/
/**                                                         **/
/**  * Hilfsregeln werden nur "lokal" betrachtet, d.h.      **/
/**    waehrend der Transaktion, in der sie definiert       **/
/**    werden.                                              **/
/**                                                         **/
/**=========================================================**/


/**---------------------------------------------------------**/
/** Initialisierung der Rule-Infos                          **/
/**                                                         **/
/** Nach der Erzeugung der Datalog-Regeln zu einer          **/
/** Query, ded.Regel, etc. wird fuer jede der erzeugten     **/
/** Regeln ein ruleInfo-Term angelegt. Einige Felder        **/
/** sind dabei noch undefiniert.                            **/
/**                                                         **/
/**---------------------------------------------------------**/


initDatalogRulesInfo([],_cat,_id,_ids,_vartab).
initDatalogRulesInfo([(_head :- _tail)|_rules],_cat,_id,_ids,_vartab) :-
	initDatalogRuleInfo(_head,_tail,_cat,_id,_ids,_vartab),
	initDatalogRulesInfo(_rules,_cat,_id,_ids,_vartab).




initDatalogRuleInfo(_head,_tail,_cat,_id,_ids,_vartab) :-
	buildNewRuleId(_ruleId),
	findDepObjId(_cat,_id,_objId),
	buildNewRuleInfo(_head,_tail,_cat,_objId,_ids,_ruleId,_vartab,_ruleInfo),
	assert(_ruleInfo),!.



/*Ausnahmesfall fuer VMruleGenerator,bei dem benoetigt ruleId zurueckzuliefern.*/



initDatalogRulesInfo(_head,_tail,_cat,_id,_ids,_vartab,_ruleId) :-
	buildNewRuleId(_ruleId),
	findDepObjId(_cat,_id,_objId),
	buildNewRuleInfo(_head,_tail,_cat,_objId,_ids,_ruleId,_vartab,_ruleInfo),
	assert(_ruleInfo),!.

/**--------------------------------**/
/**                                **/
/** buildNewRuleInfo               **/
/** Initialisierung der Eintraege, **/
/**                                **/
/**--------------------------------**/


buildNewRuleInfo(_head,_tailConjunct,_cat,_objId,_ids,_ruleId,_vartab,_ruleInfo) :-
	'Conjunct2List'(_tailConjunct,_tail),
	undefined(_depsOn),
	undefined(_optPar),
	undefined(_relAlgExp),
	_ruleInfo = tmpRuleInfo(_ruleId,
							_cat,
							_objId,
							_ids,
							_head,
							_tail,
							_depsOn,
							_vartab,
							_optPar,
							_relAlgExp).

/**--------------------------------**/
/**                                **/
/** buildNewRuleId                 **/
/** Generierung eines eindeutigen  **/
/** Id's fuer eine Datalog-Regel   **/
/**                                **/
/**--------------------------------**/


buildNewRuleId(_ruleId) :-
	getFlag('Session_counter',_sc),
	getFlag('ID_counter',_idc),
	_newIdc is _idc + 1,
	setFlag('ID_counter',_newIdc),
	pc_inttoatom(_sc,_sca),
	pc_inttoatom(_idc,_idca),
	pc_atomconcat(['Rule_',_sca,'_',_idca],_ruleId),!.


/**-------------------------------------------------**/
/**                                                 **/
/** findDepObjId                                    **/
/** Bestimmung des Objekts, dessen Gueltigkeit      **/
/** Voraussetzung fuer die Gueltigleit der Datalog  **/
/** Regel ist.                                      **/
/**                                                 **/
/** Bei einer deduktiven Regel ist die Instanzen -  **/
/** beziehung des entsprechenden Attributlinks zu   **/
/** Class!rule Voraussetzung fuer die Gueltigkeit   **/
/** Dieser wird hier berechnet.                     **/
/**                                                 **/
/**-------------------------------------------------**/



/** Fall 1: Datalog-Code gehoert zu einer
           deduktiven Regel ->
           In ruleId ist der ObjektID
           des Assertion-Textes gespeichert. **/
/** 1: MSFOL-Regel **/
findDepObjId(rule,_ruleId,_objId) :-
	!,
	select2id('Class!rule',_ruleClass),
	prove_literal('To'(_objId,_ruleId)),
	prove_literal('In'(_objId,_ruleClass)),!.

/** Fall 2: sonst **/
findDepObjId(_cat,_objId,_objId) :-
	prove_literal('In'(_objId,_qClass)),!.


/** Invers zu findDepObjId fuer eine deduktive Regel (MSFOL) **/


getRuleIdFromDepObjId(_depObjId,_ruleId) :-
	prove_literal('To'(_depObjId,_ruleId)),!.



/**=======  ruleInfo -  lokaler Abhaengigkeitsgraph ========**/
/**                                                         **/
/** buildLocalDependencyGraph                               **/
/**                                                         **/
/**                                                         **/
/**                                                         **/
/**                                                         **/
/**                                                         **/
/**=========================================================**/
buildLocalDependencyGraph :-
	getLocalRuleCodeIdsWithCat(_ruleIds),
	buildLocalDependenciesForRuleIds(_ruleIds).




buildLocalDependenciesForRuleIds([]) :- !.
buildLocalDependenciesForRuleIds([_ruleCodeId|_ruleCodeIds]) :-
	buildLocalDependenciesForRuleId(_ruleCodeId),
	buildLocalDependenciesForRuleIds(_ruleCodeIds).




buildLocalDependenciesForRuleId([_ruleId,_cat]) :-
	tmpRuleInfo(_ruleId,_cat,_objId,_ids,
				_head,_tail,_depsOn,
				_vartab,_optPar,_relAlgExp),
	removeSecondaryFunctors(_tail,_tailClean),
	findLocalRuleReferencesInTail(_tail,_referenced),
	retract(tmpRuleInfo(_ruleId,_cat,_objId,_ids,
						_head,_tail,_depsOn,
						_vartab,_optPar,_relAlgExp)),
	assert(tmpRuleInfo(_ruleId,_cat,_objId,_ids,
						_head,_tail,_referenced,
						_vartab,_optPar,_relAlgExp)),!.



/**---------------------------------------------------------**/
/** checkSpecialBindings                                    **/
/**   tritt der Aufruf einer Hilfsregel nur in negierter    **/
/**   Form auf, dann kann bei der Optimierung dieser        **/
/** Regel davon ausgegangen werden, das alle Variablen im   **/
/** Kopf gebunden sind.                                     **/
/**---------------------------------------------------------**/


checkSpecialBindings :-
	getLocalRuleCodeIdsWithUndefOptPar(_ruleIds),
	checkSpecialBindings(_ruleIds).

checkSpecialBindings([]).
checkSpecialBindings([_ruleId|_ruleIds]) :-
	tmpRuleInfo(_ruleId,_cat,_objId,_ids,
				_head,_tail,_depsOn,
				_vartab,_optPar,_relAlgExp),
	filterNotsWithAux(_tail),
	checkSpecialBindings(_ruleIds).


filterNotsWithAux([]).
filterNotsWithAux([not(_lit)|_lits]) :-
	isAux(_lit),
	_lit =.. [_functor|_],
	(
		(pc_is_a_key('QO_notLit',_functor),pc_recorded('QO_notLit',_functor,0));
		 pc_rerecord('QO_notLit',_functor,0)
	),!,
	filterNotsWithAux(_lits).
filterNotsWithAux([_lit|_lits]) :-
	isAux(_lit),
	_lit =.. [_functor|_],
	(
		(pc_is_a_key('QO_notLit',_functor),pc_rerecord('QO_notLit',_functor,1));
		true
	),!,
	filterNotsWithAux(_lits).
filterNotsWithAux([_|_lits]) :-
	filterNotsWithAux(_lits).



allBound(_head) :-
	_head =.. [_functor|_],
	pc_is_a_key('QO_notLit',_functor),
	pc_recorded('QO_notLit',_functor,0),!.

/**---------------------------------------------------------**/
/** findLocalRuleReferencesInTail                           **/
/** Eingabe: Liste von Literalen                            **/
/** Ausgabe: Liste von Ids der Regeln, die im Rumpf der     **/
/**          aktuellen Regel referenziert werden            **/
/**          Dabei werden nur die in der aktuellen          **/
/**          Transaktion hinzugefuegten Regeln betrachtet.  **/
/**                                                         **/
/**                                                         **/
/**---------------------------------------------------------**/



findLocalRuleReferencesInTail(_lits,_allRulesReferenced) :-
	findLocalRuleReferencesInTail(_lits,[],_allRulesReferenced1),!,
	makeflat(_allRulesReferenced1,_allRulesReferenced).

findLocalRuleReferencesInTail([],_allRulesReferenced,_allRulesReferenced).

findLocalRuleReferencesInTail([not(_lit)|_lits],_rulesPrev,_ruleIds) :-
	!,
	findLocalRuleReferencesInTail([_lit|_lits],_rulesPrev,_ruleIds).

findLocalRuleReferencesInTail(['In'(_x,_class)|_lits],_rulesPrev,_allRules) :-
	findall(_ruleId,
		tmpRuleInfo(_ruleId,_,_,_,
					'In'(_,_class),_,_,
					_,undef,_),
		_rulesReferenced),
	_rulesReferenced \==[],!,
	findLocalRuleReferencesInTail(_lits,[_rulesReferenced|_rulesPrev],_allRules).

findLocalRuleReferencesInTail(['Adot'(_p,_,_)|_lits],_rulesPrev,_allRules) :-
	findall(_ruleId,
		tmpRuleInfo(_ruleId,_,_,_,
					'Adot'(_p,_,_),_,_,
					_,undef,_),
		_rulesReferenced),
	_rulesReferenced \==[],!,
	findLocalRuleReferencesInTail(_lits,[_rulesReferenced|_rulesPrev],_allRules).


findLocalRuleReferencesInTail([_lit|_lits],_rulesPrev,_allRules) :-
     _lit =.. [_functor|_],
     ( is_id(_functor);
       pc_atomconcat('ID_',_,_functor)
      ),
	findall(_ruleId,
			(
		 	 tmpRuleInfo(_ruleId,_,_,_,_head,_,_,_,undef,_relAlgExp),
			 _head =.. [_functor|_]
			),
		_rulesReferenced),
	_rulesReferenced \==[],!,
	findLocalRuleReferencesInTail(_lits,[_rulesReferenced|_rulesPrev],_allRules).


findLocalRuleReferencesInTail([_lit|_lits],_rulesPrev,_ruleIds) :-
	findLocalRuleReferencesInTail(_lits,_rulesPrev,_ruleIds).

/** scheint doppelt zu sein -> nicht umgestellt
 findLocalRuleReferencesInTail([_lit|_lits],_allRulesReferenced) :-
	findall(_ruleId,
			(
			 _lit =.. [_functor|_],
                         ( is_id(_functor);
                           pc_atomconcat('ID_',_,_functor)
                          ),
		 	 tmpRuleInfo(_ruleId,_,_,_,_head,_,_,_,undef,_relAlgExp),
			 _head =.. [_functor|_]
			),
		_rulesReferenced),
	_rulesReferenced \==[],!,
	findLocalRuleReferencesInTail(_lits,_ruleIds),
	append(_rulesReferenced,_ruleIds,_allRulesReferenced).
**/




/**---------------------------------------------------------**/
/** orderLocalRules                                         **/
/** Die waehrend der aktuellen Transaktion erzeugten        **/
/** Datalog-Regeln werden fuer die Optimierung angeordnet:  **/
/**---------------------------------------------------------**/


orderLocalRules(_ruleIds,_recCycles,_ruleIdsOrdered) :-
	makeflat(_recCycles,_recRules1),!,
	remDups(_recRules1,_recRules),
	storeRecRuleIds(_recRules),
	orderLocalRules(_ruleIds,[],_recRules,_ruleIdsOrdered).




/** Fall 1: Alle Regeln angeordnet **/
orderLocalRules([],_rulesOrdered,_,_rulesOrdered) :- !.

/** Fall 2: Es gibt Regeln, bei denen alle Refrenzen im Rumpf
           angeordnet sind **/

orderLocalRules(_rulesNotHandled,_rulesHandled,_recRules,_rulesOrdered) :-
	findall(_ruleId,
		(member(_ruleId,_rulesNotHandled),
		 tmpRuleInfo(_ruleId,_cat,_objId,_ids,_head,_tail,_depIds,_vartab,_optPar,_relAlgExp),
		 subtract(_depIds,_rulesHandled,_rem),
		 _rem == []),
		_rulesReady),
	_rulesReady \== [],!,
	append(_rulesHandled,_rulesReady,_newRulesHandled),
	subtract(_rulesNotHandled,_rulesReady,_newRulesNotHandled),
	orderLocalRules(_newRulesNotHandled,_newRulesHandled,_recRules,_rulesOrdered).

/** Fall 3: Behandlung zyklischer Abhaengigkeiten: Tritt ein Zyklus auf,
           so wird versucht, eine Regel zu finden, bei der alle Referenzen
           bis auf die zyklischen Abhaengigkeiten im Rumpf behandelt sind, **/

orderLocalRules(_rulesNotHandled,_rulesHandled,_recRules,_rulesOrdered) :-
	findall(_ruleId,
		(member(_ruleId,_rulesNotHandled),
		 tmpRuleInfo(_ruleId,_cat,_objId,_ids,_head,_tail,_depIds,_vartab,_optPar,_relAlgExp),
		 subtract(_depIds,_rulesHandled,_rem),
		 subset(_rem,_recRules)),
		_rulesReady),
	_rulesReady \== [],!,
	append(_rulesHandled,_rulesReady,_newRulesHandled),
	subtract(_rulesNotHandled,_rulesReady,_newRulesNotHandled),
	orderLocalRules(_newRulesNotHandled,_newRulesHandled,_recRules,_rulesOrdered).


/** Fall 4: Gelingt Fall 3 nicht, so werden alle zyklischen Abhaengigkeiten
           brutal aufgeloest, d.h auf "behandelt" gesetzt**/
orderLocalRules(_rulesNotHandled,_rulesHandled,_recRules,_rulesOrdered) :-
	append(_rulesHandled,_recRules,_newRulesHandled),
	subtract(_rulesNotHandled,_recRules,_newRulesNotHandled),
	orderLocalRules(_newRulesNotHandled,_newRulesHandled,_recRules,_rulesOrdered).




/**---------------------------------------------------------**/
/** findRecRules                                            **/
/** Eingabe: Liste von ruleIds                              **/
/** Ausgabe: Liste von Listen von ruleIds                   **/
/**                                                         **/
/** Wird eine Datalog-Regel optimiert, so ist zur Berech-   **/
/** nung der Kostenfunktion erforderlich, dass die Regeln,  **/
/** die im Rumpf der aktuellen Regel referenziert werden,   **/
/** bereits optimiert sind. Probleme treten auf, wenn       **/
/** Regeln zyklisch voneinander abhaengen (direkte oder     **/
/** indirekte Rekursion).                                   **/
/**                                                         **/
/** Fuer jeden Regel werden die Zykel bestimmt, an denen    **/
/** sie teilnimmt, d.h. es werden alle Pfade im Abhaengig-  **/
/** keitsgraphen gesucht, die bei der Regel beginnen und    **/
/** bei ihr auch wieder enden.                              **/
/**                                                         **/
/** Nachteil: Die Ausgabeliste enthaelt Duplikate von       **/
/**           Zykeln. Besteht ein Zyklus aus n Knoten, so   **/
/**           wird er n-mal aufgefuehrt.                    **/
/**                                                         **/
/** Bei dieser Suche werden die bisher besuchten Knoten     **/
/** ebenfalls protokolliert. Wird ein bereits besuchter     **/
/** Knoten ein zweites mal besucht, so wird die Suche       **/
/** abgebrochen, da ansonsten die Suche nicht terminiert.   **/
/**---------------------------------------------------------**/


findRecRules([],[]) :- !.
findRecRules([_recRuleCand|_recRuleCands],_recRules) :-
	findCompleteCyclesWithRule(_recRuleCand,_cycles),
/** write('cycles='),write(_cycles),nl,nl, **/
	findRecRules(_recRuleCands,_recRules1),
	append(_cycles,_recRules1,_recRules),!.

/**---------------------------------------------------------**/
/** findCompleteCyclesWithRule/2                            **/
/** Eingabe: ruleId r                                       **/
/** Ausgabe: Liste von Listen von ruleIds                   **/
/**          Jeder Eintrag beschreibt einen Zyklus, der     **/
/**          mit der Regel r beginnt und endet              **/
/**---------------------------------------------------------**/


/** old method: find all cycles for _recRuleCand **/
/**
findCompleteCyclesWithRule(_recRuleCand,_resultList) :-
	tmpRuleInfo(_recRuleCand,_cat,_objId,_ids,_head,_tail,_depIds,_vartab,_optPar,_relAlgExp),
	findall(_result,
		findCycleWithRule(_recRuleCand,_recRuleCand,[],_depIds,_result),
		_resultList).
**/

/** Issue #22; new method: find only the first cycle for _recRuleCand **/
findCompleteCyclesWithRule(_recRuleCand,[_result]) :-
	tmpRuleInfo(_recRuleCand,_cat,_objId,_ids,_head,_tail,_depIds,_vartab,_optPar,_relAlgExp),
	findCycleWithRule(_recRuleCand,_recRuleCand,[],_depIds,_result),
	!.
findCompleteCyclesWithRule(_recRuleCand,[]).





/** Fall 1: Startregel ist Bestandteil eines Zyklus **/
findCycleWithRule(_recRuleCand,_,_rulesVisited,_dependsOn,[_recRuleCand|_rulesVisited]) :-
	memberchk(_recRuleCand,_dependsOn),!.

/** Fall 2: Es liegt ein Zyklus vor, die Startregel ist aber nicht Bestandteil, sondern
	   die zuletzt betrachtete Regel ist Start- und Zielpunkt
	   -> Fehlschlag der Suche **/
findCycleWithRule(_recRuleCand,_lastRule,[_lastRule|_rulesVisited],_dependsOn,_) :-
	memberchk(_lastRule,_rulesVisited),!,fail.

/** Fall 3: Es wurde noch kein Zyklus entdeckt **/
findCycleWithRule(_recRuleCand,_lastRule,_rulesVisited,_dependsOn,_cycle) :-
	member(_ruleId,_dependsOn),
	tmpRuleInfo(_ruleId,_cat,_objId,_ids,_head,_tail,_depIds,_vartab,_optPar,_relAlgExp),
	findCycleWithRule(_recRuleCand,_ruleId,[_ruleId|_rulesVisited],_depIds,_cycle).





/**=======  ruleInfo -  Regeluebersetzung ==================**/
/**                                                         **/
/** Fuer die Fakten mit dem Funktor 'tmpRuleInfo' wird      **/
/** hier Prolog-Code erzeugt.(hier wird nur die Infos,      **/
/** die noch nicht optimiert werden, gesammelt.)		   **/
/** Dieses Praedikat dient der Entkopplung der Erzeugung    **/
/** von Datalog-Code und ausfuehrbarem Prolog-Code          **/
/**                                                         **/
/**                                                         **/
/** Der Datalog-Code wird in tmpRuleInfo-Fakten zwischen-   **/
/** gespeichert. Die waehrend einer Transaktion erzeugten   **/
/** Fakten werden hier gesammelt und aus ihnen wird         **/
/** Prolog-Code erzeugt.                                    **/
/**                                                         **/
/** Dieses Pr?dikat geh?rt nicht hierhin,sondern in   **/
/** ein ?bergeordnetes Modul                             **/
/**=========================================================**/

genPrologCodeFromInfos :-
	buildLocalDependencyGraph,
	getLocalRuleCodeIdsWithUndefOptPar(_ruleIds),
	checkSpecialBindings(_ruleIds),
	!,
	optimizeDatalogRules(_ruleIds,_optDataOut),
	prepareGenerationOfExecCode(_optDataOut,_codeToCompile),
	sortExecCode(_codeToCompile,_codeSorted),
	generateCodeForClusters(_codeSorted),
	merken_Saved_ruleIds.



/**---------------------------------------------------------**/
/** merken_Saved_ruleIds 				   **/
/** Alle schon gespeicherten RegelCode-Ids werden gemerkt   **/
/**---------------------------------------------------------**/
merken_Saved_ruleIds:-
	getLocalRuleCodeIds(_ruleIds1),
	(pc_recorded(ruleIdslist,_ruleIds2);_ruleIds2=[]),
	append(_ruleIds1,_ruleIds2,_ruleIds),
	pc_rerecord(ruleIdslist,_ruleIds).


/**---------------------------------------------------------**/
/** getLocalRuleCodeIds                                     **/
/** Sammle die RegelCode-Ids aller Datalog-Regeln auf,      **/
/** die in der aktuellen Transaktion erzeugt wurden ,       **/
/** inclusive alle schon optimiert oder nicht optimiert;    **/
/** alle schon gespeicherten Regeln oder nicht gespeicherte.**/
/**---------------------------------------------------------**/


getLocalRuleCodeIds(_ruleIds) :-
	save_setof(_ruleId,
		(_cat,_objId,_ids,_head,_tail,_depsOn,_vartab,_optPar,_relAlgExp)^tmpRuleInfo(_ruleId,_cat,_objId,_ids,_head,_tail,_depsOn,_vartab,_optPar,_relAlgExp),
		_ruleIds).

/**---------------------------------------------------------**/
/** getRuleCodeIdsToSave                                    **/
/** Sammle die RegelCode-Ids aller Datalog-Regeln auf,      **/
/** die in der aktuellen Transaktion erzeugt und optimiert  **/
/** wurden, aber noch nicht gespeichert als PrologCode.	   **/
/**---------------------------------------------------------**/

getRuleCodeIdsToSave(_ruleIds):-
	(pc_recorded(ruleIdslist,_ruleIds2);_ruleIds2=[]),
	save_setof(_ruleId,
		(_cat,_objId,_ids,_head,_tail,_depsOn,_vartab,_optPar,_relAlgExp)^(
		tmpRuleInfo(_ruleId,_cat,_objId,_ids,_head,_tail,_depsOn,_vartab,_optPar,_relAlgExp),
		\+(member(_ruleId,_ruleIds2))),
	_ruleIds).

/**---------------------------------------------------------**/
/** getLocalRuleCodeIdsWithCat:                             **/
/** Sammle die RegelCode-Ids aller Datalog-Regeln auf,      **/
/** die in der aktuellen Transaktion erzeugt wurden         **/
/**---------------------------------------------------------**/


getLocalRuleCodeIdsWithCat(_ruleIds) :-
	save_setof([_ruleId,_cat],
		(_objId,_ids,_head,_tail,_depsOn,_vartab,_optPar,_relAlgExp)^tmpRuleInfo(_ruleId,_cat,_objId,_ids,_head,_tail,_depsOn,_vartab,undef,_relAlgExp),
		_ruleIds).


/**---------------------------------------------------------**/
/** getLocalRuleCodeIdsWithUndefOptPar                      **/
/** Sammle die RegelCode-Ids aller Datalog-Regeln auf,      **/
/** die in der aktuellen Transaktion erzeugt wurden         **/
/** und deren OptPar undef ist, d.h. noch nicht optimiert   **/
/**---------------------------------------------------------**/


getLocalRuleCodeIdsWithUndefOptPar(_ruleIds) :-
	assert(vmrule(nix,nix)), /* damit vmrule im setof bekannt ist */
	save_setof(_ruleId,
		(_cat,_objId,_ids,_head,_tail,_depsOn,_vartab,_relAlgExp)^(tmpRuleInfo(_ruleId,_cat,_objId,_ids,_head,_tail,_depsOn,_vartab,undef,_relAlgExp),\+(vmrule(_ruleId,_))),
		_ruleIds),
	retract(vmrule(nix,nix)).



prepareGenerationOfExecCode([],[]).
prepareGenerationOfExecCode([_ruleId-_codeList|_optRules],
                            [ruleData(query,_ruleId,_objId,_codeList)|_rulesCode]) :-
	tmpRuleInfo(_ruleId,query,_objId,_,_,_,_,_,_,_),
	prepareGenerationOfExecCode(_optRules,_rulesCode).

prepareGenerationOfExecCode([_ruleId-_codeList|_optRules],
                            [ruleData(mquery,_ruleId,_objId,_objId,_codeList)|_rulesCode]) :-
	tmpRuleInfo(_ruleId,mquery,_objId,_,_,_,_,_,_,_),
	prepareGenerationOfExecCode(_optRules,_rulesCode).


prepareGenerationOfExecCode([_ruleId-_codeList|_optRules],
                            [ruleData(rule,_ruleId,_ids,_codeList)|_rulesCode]) :-
	tmpRuleInfo(_ruleId,rule,_,_ids,_,_,_,_,_,_),
	prepareGenerationOfExecCode(_optRules,_rulesCode).

prepareGenerationOfExecCode([_ruleId-_codeList|_optRules],
                            [ruleData(vmrule,_ruleId,_ids,_codeList)|_rulesCode]) :-
	tmpRuleInfo(_ruleId,vmrule,_,_ids,_,_,_,_,_,_),
	prepareGenerationOfExecCode(_optRules,_rulesCode).



/**
	1. Hauptregel
	2. Hilfsregeln
		2.1 nichtrekursive Regeln nach Kosten
		2.2 rekursuve Regeln
**/




sortExecCode([],[]) :- !.
sortExecCode(_ruleData,_ruleDataOut) :-
	getRuleCodeIdsToSave(_ruleIds),
	getRulesByDepObj(_ruleIds,_ruleGroupList),
	getRecRuleIds(_recRules),
	buildRuleClusters(_ruleGroupList,_recRules,_ruleCluster),
	sortRuleData(_ruleCluster,_ruleData,_ruleDataOut).







getRulesByDepObj(_ruleIds,_ruleGroupListByDepObj) :-
	prepareSorting(_ruleIds,_ruleListUnsorted),
	keysort(_ruleListUnsorted,_ruleList),
	groupKeyList(_ruleList,_ruleGroupList),
	keysort(_ruleGroupList,_ruleGroupListByDepObj1),
	mergeKeyList(_ruleGroupListByDepObj1,_ruleGroupListByDepObj).




prepareSorting([],[]).
prepareSorting([_ruleId|_ruleIds],[_headKey-_ruleId|_rulePairs]) :-
	buildHeadKey(_ruleId,_headKey),
	prepareSorting(_ruleIds,_rulePairs).




buildHeadKey(_ruleId,_adotKey) :-
	tmpRuleInfo(_ruleId,_cat,_objId,_ids,'Adot'(_cc,_x,_y),_tail,_depsOn,_vartab,_optPar,_relAlgExp),!,
	pc_atomconcat('Adot',_cc,_adotKey),!.

buildHeadKey(_ruleId,_inKey) :-
	tmpRuleInfo(_ruleId,_cat,_objId,_ids,'In'(_x,_c),_tail,_depsOn,_vartab,_optPar,_relAlgExp),!,
	pc_atomconcat('In',_c,_inKey),!.

buildHeadKey(_ruleId,_ltKey) :-
	tmpRuleInfo(_ruleId,_cat,_objId,_ids,'LTevalQuery'(_depObj,_),_tail,_depsOn,_vartab,_optPar,_relAlgExp),!,
	pc_atomconcat('LTevalQuery',_depObj,_ltKey),!.

/*fuer zB del(id_3232(_)) buildet key als delid_3232, nicht wie vorher als del,uneindeutig!*/

buildHeadKey(_ruleId,_Key) :-
	tmpRuleInfo(_ruleId,_cat,_objId,_ids,_head,_tail,_depsOn,_vartab,_optPar,_relAlgExp),
	_head =.. [_functor1|[_term]],
	member(_functor1,[plus,minus,new,red,del,ins]),
	!,
	_term =.. [_functor2|_args],
	pc_atomconcat(_functor1,_functor2,_Key).


buildHeadKey(_ruleId,_functor) :-
	tmpRuleInfo(_ruleId,_cat,_objId,_ids,_head,_tail,_depsOn,_vartab,_optPar,_relAlgExp),!,
	_head =.. [_functor|_args].




/*sortRuleData wird _ruleData nach die angegebene ruleId-Order(aus ruleCluster) sortiert!*/

sortRuleData([],_,[]).
sortRuleData([_ruleCluster|_ruleClusters],_ruleData,_ruleDatasorted) :-
	sortRuleDataForCluster(_ruleCluster,_ruleData,_ruleDatasorted1),
	sortRuleData(_ruleClusters,_ruleData,_ruleDatasorted2),
	append(_ruleDatasorted1,_ruleDatasorted2,_ruleDatasorted).


sortRuleDataForCluster([],_,[]).
sortRuleDataForCluster([_ruleId|_ruleIdrest],_ruleData,[ruleData(_mode,_ruleId,_idPar,_rule)|_rest]) :-
	member(ruleData(_mode,_ruleId,_idPar,_rule),_ruleData),!,
	sortRuleDataForCluster(_ruleIdrest,_ruleData,_rest).


sortRuleDataForCluster([_ruleId|_ruleIdrest],_ruleData,[ruleData(_mode,_ruleId,_idPar1,_idPar2,_rule)|_rest]) :-
	member(ruleData(_mode,_ruleId,_idPar1,_idPar2,_rule),_ruleData),!,
	sortRuleDataForCluster(_ruleIdrest,_ruleData,_rest).





/** Gruppiere die Regeln nach ihrem Headkey ->
   Regln mit gleichem Kopf werden zusammengefasst
   Ihre Sortierung nach Depending-Object wird vorbereitet.

   Das gleiche depending Object impliziert die logische Zusammengehoerigkeit
   der Regeln.
**/


groupKeyList([],[]).
groupKeyList([_key-_ruleId|_keyList],[_objId-[_ruleId|_listOfElems]|_remainder]) :-
	tmpRuleInfo(_ruleId,_cat,_objId,_ids,_head,_tail,_depsOn,_vartab,_optPar,_relAlgExp),
	find_keys(_key,_keyList,_listOfElems,_newKeyList),
	groupKeyList(_newKeyList,_remainder).


find_keys(_key,[],[],[]) :-
	!.

find_keys(_key,[_key-_x|_xs],[_x|_ys],_zs) :-
	!,
	find_keys(_key,_xs,_ys,_zs).

find_keys(_key,[_x|_xs],_ys,[_x|_zs]) :-
	find_keys(_key,_xs,_ys,_zs).




mergeKeyList([],[]).
mergeKeyList([_objId-_ruleIds|_keyList],_keyListMerged) :-
	mergeKeyList(_keyList,[_objId-_ruleIds],_keyListMerged).



mergeKeyList([],_keyList,_keyList).
mergeKeyList([_objId-_newRules|_others],[_objId-_ruleIds|_merged],_keyListMerged) :-
	!,
	append(_ruleIds,_newRules,_rulesMerged),
	mergeKeyList(_others,[_objId-_rulesMerged|_merged],_keyListMerged).
mergeKeyList([_objId-_newRules|_others],[_otherObjId-_ruleIds|_merged],_keyListMerged) :-
	_objId \== _otherObjId,
	mergeKeyList(_others,[_objId-_newRules|[_otherObjId-_ruleIds|_merged]],_keyListMerged).




buildRuleClusters([],_,[]).
buildRuleClusters([_objId-_ruleGroup|_ruleGroupList],_recRules,[_ruleCluster|_ruleClusters]) :-
	buildRuleCluster(_ruleGroup,_recRules,_ruleCluster),
	buildRuleClusters(_ruleGroupList,_recRules,_ruleClusters).


buildRuleCluster(_ruleGroup,_recRules,_ruleCluster) :-
	getLTEvalRules(_ruleGroup,_newRuleGroup,_ltEvalRules),
	intersect_plus(_newRuleGroup,_recRules,_recRulesInGroup,_nonRecRulesInGroup),
	getCostsForRuleIds(_nonRecRulesInGroup,_nrWithCosts1),
	keysort(_nrWithCosts1,_nrWithCosts),
	dropKeys(_nrWithCosts,_nr),
	getCostsForRuleIds(_recRulesInGroup,_rWithCosts1),
	keysort(_rWithCosts1,_rWithCosts),
	dropKeys(_rWithCosts,_r),
	append(_r,_ltEvalRules,_rules1),
	append(_nr,_rules1,_ruleCluster).

/* arg3 = arg1 und arg2, arg4 arg1 - arg2 */
intersect_plus([],_xs,[],[]) :- !.

intersect_plus([_x|_xs],_ys,[_x|_zs],_ws) :-
	member(_x,_ys),
	!,
	intersect_plus(_xs,_ys,_zs,_ws).

intersect_plus([_x|_xs],_ys,_zs,[_x|_ws]) :-
	intersect_plus(_xs,_ys,_zs,_ws).


getLTEvalRules([],[],[]).
getLTEvalRules([_ruleId|_ruleIds],_otherRules,[_ruleId|_ltEvals]) :-
	tmpRuleInfo(_ruleId,_cat,_objId,_ids,_head,_tail,_depsOn,_vartab,_optPar,_relAlgExp),
	_head =.. ['LTevalQuery'|_],!,
	getLTEvalRules(_ruleIds,_otherRules,_ltEvals).
getLTEvalRules([_ruleId|_ruleIds],[_ruleId|_otherRules],_ltEvals) :-
	getLTEvalRules(_ruleIds,_otherRules,_ltEvals).



getCostsForRuleIds([],[]).
getCostsForRuleIds([_ruleId|_ruleIds],[_cost-_ruleId|_cAndRuleIds]) :-
	tmpRuleInfo(_ruleId,_cat,_objId,_ids,_head,_tail,_depsOn,_vartab,_optPar,_relAlgExp),
	getArgs(_head,_args),
	buildAdAllFreeForArgs(_args,_ad),
	getCostsSum(_head,_ad,_cost),
	getCostsForRuleIds(_ruleIds,_cAndRuleIds).



generateCodeForClusters([]) .

generateCodeForClusters([ruleData(_mode,_ruleId,_idPar,_ruleList)|_rdList]) :-
	((_mode == rule);(_mode == query)),!,
	generatePROLOGCode(_ruleList,_prologCode),
	handleCode(_mode,_idPar,_prologCode),
	generateCodeForClusters(_rdList).

generateCodeForClusters([ruleData(_mode,_ruleId,_idPar,_ruleList)|_rdList]) :-
	_mode == vmrule,
	!,
	generatePROLOGCode(_ruleList,_prologCode),
	handleCode(_mode,_ruleId,_prologCode),
	generateCodeForClusters(_rdList).


/** nur fuer debug-Zwecke **/
generateCodeForCluster([_ruleInfo|_triList]) :-
		writeq(_ruleInfo),nl,
		write('*** no code generated ***'),nl,
		generateCodeForCluster(_triList).



store_ruleinfos([]):-!.

store_ruleinfos([_first|_rest]):-
	assert(_first),
	!,
	store_ruleinfos(_rest).


/**---------------------------------------------------------**/
/** storeRuleInfosToFile                                    **/
/**---------------------------------------------------------**/
storeRuleInfosToFile(_ruleidlist) :-
	get_application(_appname),
	appFilename('ruleinfo',_appname,_fullFileName),
    pc_fopen(ruleinfofile,_fullFileName,a),
	writeRuleIds(_ruleidlist).

writeRuleIds([]) :-
	pc_fclose(ruleinfofile).

writeRuleIds([_ruleid|_rest]) :-
	ruleInfo(_ruleid,_cat,_oid,_ids,_head,_body,_depsOn,_vartab,_optPar,_relAlgExp),
	writeFacts(ruleinfofile,[ruleInfo(_ruleid,_cat,_oid,_ids,_head,_body,_depsOn,_vartab,_optPar,_relAlgExp)]),
	writeRuleIds(_rest).

/**---------------------------------------------------------**/
/** makeTmpRuleInfosPerm/0.                                 **/
/**                                                         **/
/** die waehrend einer Transaktion angelegten ruleInfos     **/
/** werden den permamenten hinzugefuegt. Dazu wird der      **/
/** Funktor von 'tmpRuleInfo' nach 'ruleInfo' geandert.     **/
/**                                                         **/
/**---------------------------------------------------------**/
'TmpRuleInfosToRuleInfos'([_ruleId|_rest]) :-
	retract(tmpRuleInfo(_ruleId,_cat,_objId,_ids,_head,_tail,_depsOn,_vartab,_optPar,_relAlgExp)),
	assert(ruleInfo(_ruleId,_cat,_objId,_ids,_head,_tail,_depsOn,_vartab,_optPar,_relAlgExp)),
	'TmpRuleInfosToRuleInfos'(_rest).

'TmpRuleInfosToRuleInfos'([]).

makeTmpRuleInfosPerm :-
	'TmpRuleInfosToRuleInfos'(_ruleidlist),
	pc_erase(ruleIdslist),
 	storeRuleInfosToFile(_ruleidlist).

/**---------------------------------------------------------**/
/** remove_tmpRuleInfos/0                                   **/
/**                                                         **/
/** die waehrend einer Transaktion angelegten ruleInfos     **/
/** werden geloescht. Dies ist erforderlich, wenn die       **/
/** Transaktion fehlgeschlagen ist oder ein ASK war.        **/
/**                                                         **/
/**---------------------------------------------------------**/
remove_tmpRuleInfos :-
	retractall(tmpRuleInfo(_ruleId,_cat,_objId,_ids,_head,_tail,_depsOn,_vartab,_optPar,_relAlgExp)).



getVartabFromRuleInfo(_ruleId,_vartab) :-
	tmpRuleInfo(_ruleId,_cat,_objId,_ids,_head,_tail,_depsOn,_vartab,_optPar,_relAlgExp),!.
getVartabFromRuleInfo(_ruleId,_vartab) :-
	ruleInfo(_ruleId,_cat,_objId,_ids,_head,_tail,_depsOn,_vartab,_optPar,_relAlgExp),!.

getHeadFromRuleInfo(_ruleId,_head) :-
	tmpRuleInfo(_ruleId,_cat,_objId,_ids,_head,_tail,_depsOn,_vartab,_optPar,_relAlgExp),!.
getHeadFromRuleInfo(_ruleId,_head) :-
	ruleInfo(_ruleId,_cat,_objId,_ids,_head,_tail,_depsOn,_vartab,_optPar,_relAlgExp),!.

getTailFromRuleInfo(_ruleId,_tail) :-
	tmpRuleInfo(_ruleId,_cat,_objId,_ids,_head,_tail,_depsOn,_vartab,_optPar,_relAlgExp),!.
getTailFromRuleInfo(_ruleId,_tail) :-
	ruleInfo(_ruleId,_cat,_objId,_ids,_head,_tail,_depsOn,_vartab,_optPar,_relAlgExp),!.


getAlgExpFromRuleInfo(_ruleId,_algExp) :-
	tmpRuleInfo(_ruleId,_cat,_objId,_ids,_head,_tail,_depsOn,_vartab,_optPar,_algExp),!.
getAlgExpFromRuleInfo(_ruleId,_algExp) :-
	ruleInfo(_ruleId,_cat,_objId,_ids,_head,_tail,_depsOn,_vartab,_optPar,_algExp),!.

getOptParFromRuleInfo(_ruleId,_optPar) :-
	tmpRuleInfo(_ruleId,_cat,_objId,_ids,_head,_tail,_depsOn,_vartab,_optPar,_algExp),!.
getOptParFromRuleInfo(_ruleId,_optPar) :-
	ruleInfo(_ruleId,_cat,_objId,_ids,_head,_tail,_depsOn,_vartab,_optPar,_algExp),!.

getDepsOnFromRuleInfo(_ruleId,_optPar) :-
	tmpRuleInfo(_ruleId,_cat,_objId,_ids,_head,_tail,_depsOn,_vartab,_optPar,_algExp),!.
getDepsOnFromRuleInfo(_ruleId,_optPar) :-
	ruleInfo(_ruleId,_cat,_objId,_ids,_head,_tail,_depsOn,_vartab,_optPar,_algExp),!.



/**--------------------------------**/
/**                                **/
/** isAux                          **/
/** Testen, ob der uebergebene     **/
/** Datalog-Regelkopf zu einer     **/
/** Hilfsregel gehoert, d.h        **/
/** einen Funktor besitzt,  der    **/
/** mit 'ID_' beginnt              **/
/**                                **/
/**--------------------------------**/


isAux(_head) :-
	_head =.. [_functor|_],
	pc_atomconcat('ID_',_,_functor),!.






setAlgExpInRuleInfo(_ruleId,_algExp) :-
	retract(tmpRuleInfo(_ruleId,_cat,_objId,_ids,_head,_tail,_depsOn,_vartab,_optPar,_oldAlgExp)),
	assert(tmpRuleInfo(_ruleId,_cat,_objId,_ids,_head,_tail,_depsOn,_vartab,_optPar,_algExp)),!.
setAlgExpInRuleInfo(_ruleId,_algExp) :-
	retract(ruleInfo(_ruleId,_cat,_objId,_ids,_head,_tail,_depsOn,_vartab,_optPar,_oldAlgExp)),
	assert(ruleInfo(_ruleId,_cat,_objId,_ids,_head,_tail,_depsOn,_vartab,_optPar,_algExp)),!.



getHeadLiterals([],[]).
getHeadLiterals([_ruleId|_ruleIds],[_ruleId-_head|_headLits]) :-
	(
	tmpRuleInfo(_ruleId,_cat,_objId,_ids,_head,_tail,_depIds,_vartab,_optPar,_relAlgExp);
	ruleInfo(_ruleId,_cat,_objId,_ids,_head,_tail,_depIds,_vartab,_optPar,_relAlgExp)
	),
	getHeadLiterals(_ruleIds,_headLits).

storeRecRuleIds(_recRules) :-
	pc_rerecord('QO_ruleBase',recRules,_recRules).
getRecRuleIds(_recRules) :-
	(pc_recorded('QO_ruleBase',recRules,_recRules);
	 _recRules = []),!.
