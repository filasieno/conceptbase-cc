/**
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
**/
/*************************************************************************
*
* File:         BDMEvaluation.pro
* Version:      11.4
*
*
* Date released : 97/05/26  (YY/MM/DD)
*
* SCCS-Source-Pool : /home/CBase/CB_NewStruct/ProductPOOL/SCCS/serverSources/Prolog_Files/s.BDMEvaluation.pro
* Date retrieved : 97/07/09 (YY/MM/DD)
**************************************************************************
*---------*
* This module is part of the BDMIntegrityChecker and
* is responsible for the translation of BDM-formulas in an
* evaluable form and to evaluate them.
*
*
* Exported predicates:
* --------------------
*
*
*   + tellRuleOrIntegrityConstraint/1
*
*   + untellRule/1
*
*   + tellObjectConcerningIntegrityConstraintsOrRules/1
*
*   + untellObjectConcerningIntegrityConstraintsOrRules/1
*
*
* 4-Jul-1990/MJf:
*   . triggers applyConstraintIfInsert, applyConstraintIfDelete,
*     applyRuleIfInsert, applyRuleIfDelete and deducedBy are now attributes
*     of PROPOSITION instead of CLASS
*
* 24-Jan-1993/DG: AttrValue is changed into A; IsA into Isa
* (by deleting the time component, see CBNEWS[154])
*
*
* Metaformel Aenderung (10.1.96):
* tellRuleOrIntergityConstraint:
* neuer Fall, falls die Regel oder Intergitaetsbedingung eine
* Metaformel ist.
*
*
*  05-Dez-1996  LWEB:
*  bei der Auswertung von Constraints wird jeweils ueberprueft, ob eine Constraint im aktuellen
* Modulkontext sichtbar ist.
*/




:- module('BDMEvaluation',[
'tellObjectConcerningIntegrityConstraintsOrRules'/1
,'tellRuleOrIntegrityConstraint'/1
,'untellObjectConcerningIntegrityConstraintsOrRules'/1
,'untellRule'/1
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').

:- use_module('PropositionProcessor.swi.pl').

:- use_module('ErrorMessages.swi.pl').
:- use_module('Literals.swi.pl').





:- use_module('GeneralUtilities.swi.pl').




:- use_module('SearchSpace.swi.pl').

:- use_module('BDMKBMS.swi.pl').


:- use_module('BDMForget.swi.pl').
:- use_module('CBserverInterface.swi.pl').




:- use_module('ScanFormatUtilities.swi.pl').
:- use_module('PrologCompatibility.swi.pl').


:- use_module('validProposition.swi.pl').








:- style_check(-singleton).





/* ==================== */
/* Exported predicates: */
/* ==================== */




/* *************************************************************************** */
/*                                                                             */
/* tellRuleOrIntegrityConstraint( _propdescr)                                  */
/*                                                                             */
/* Handelt es sich bei dem neuen Objekt um eine Instanziierung in die          */
/* spezielle Klasse 'MSFOLconstraint', das heisst es soll eine neue            */
/* Integritaetsbedingung nach Bry, Decker, Manthey eingegeben werden, so wird  */
/* diese neue Formel vollstaendig ausgewertet.                                 */
/* Handelt es sich dagegen bei dem neuen Objekt um eine Instanziierung in die  */
/* spezielle Klasse 'MSFOLrule', das heisst es soll eine neue Regel nach Bry,  */
/* Decker, Manthey eingegeben werden, so wird ueberprueft, ob mit dieser Regel */
/* neu herleitbare Objekte direkt oder indirekt in einen Integritaetstest      */
/* eingehen. In diesem Fall werden alle diese Objekte erzeugt und wie          */
/* Neueintraege dem Integritaetstest unterzogen.                               */
/*                                                                             */
/* Anpassung fuer Metaformeln                                                  */
/* Ist das neue Objekt eine Metaformel, so wird der Test fuer die              */
/* Instanzen dieser Formel, aber nicht fuer die Formel selbst durchgefuehrt    */
/* *************************************************************************** */


tellRuleOrIntegrityConstraint( 'P'(_id, _IcId, '*instanceof', _constraintid)) :-
  id2name(_constraintid,_constraintname),
  _constraintname == 'MSFOLconstraint',
		/* A new integrity constraint! */
		/* So, fetch the formula: */
   	get_module(_IcId,_mod),
   prove_literal('Mod'( 'A_e'(_IcId,'MSFOLconstraint',originalConstraint,_OrigIcId),_mod) ),		/* 26-May-1997 LWEB */
   retrieve_BDMFormula(
          'origConstraint@BDMCompile'( _, _OrigIcId, _IcFormulaMerged)),	/* 26-May-1995 LWEB */
	!,
		/* And evaluate it: */
   (proveEvaFormula_once( _IcFormulaMerged);
    (getIClabel(_mod,_IcId,_iclabel),
     report_error( 'WRONG_IC', 'BDMEvaluation', [ _iclabel, objectName(_IcId), objectName(_mod)]),
     !,
     fail
    )
   ).

/* neuer Fall fuer MetaFormel:
 ist eine Formel eine MetaFormel, so haengen an ihr keine Trigger
 der Form origConstraint@BDMCompile*/
tellRuleOrIntegrityConstraint( 'P'(_id, _IcId, '*instanceof', _constraintid)) :-
	  id2name(_constraintid,_constraintname),
  	  _constraintname == 'MSFOLconstraint',
	  prove_edb_literal( 'A_e'(_IcId,'MSFOLconstraint',originalConstraint,_OrigIcId) ),
	name2id(metaMSFOLconstraint,_mid),
	  prove_edb_literal( 'In_e'(_OrigIcId,_mid)),!.

tellRuleOrIntegrityConstraint('P'( _id, _RuleId, '*instanceof', _ruleid)) :-
   id2name(_ruleid,_rulename),
  _rulename == 'MSFOLrule',
   /*!,*/
		/* Es soll eine neue Regel eingetragen werden!                 */

		/* Suchen der Klasse, die durch die neue Regel neue Instanzen  */
		/* erhaelt:                                                    */
   prove_edb_literal( 'A_e'(_RuleId,'MSFOLrule',originalRule,_OrigRuleId) ),   /** checks module context as well (ticket #64) **/
   prove_edb_literal( 'A_e'(_ClassId,'Proposition',deducedBy,_OrigRuleId) ),

		/* Ueberpruefen, ob Instanzen der Klasse (in-)direkt in        */
		/* Integritaetstest eingehen:                                  */
   findall( _SimpIcId,
		(
            		retrieve_BDMFormula( 'applyConstraintIfInsert@BDMCompile'( _IcId, _ClassId, _SimpIcId, _, _)),
					/* 26-May-1995 LWEB nur im Modulkontext sichtbare ICs auswerten*/
			isVisible(_IcId)
		),
	                         _ListOfSimpIcIds),
   findall( _SimpRuleId,
		(
   		         retrieve_BDMFormula( 'applyRuleIfInsert@BDMCompile'( _RuleId, _ClassId, _SimpRuleId, _, _, _, _)),
			 isVisible(_SimpRuleId)
		),
            _ListOfSimpRuleIds),
   !,

	(
	 (_ListOfSimpIcIds == [],
	  _ListOfSimpRuleIds == [],
	 !
		/* Es ist nichts zu ueberpruefen.                              */
         );

	 (
	  (
		/* Die Klasse ist durch mindestens eine Integritaetsbedingung  */
		/* oder Regel betroffen, also Holen der neuen Regel:           */
	  retrieve_BDMFormula( 'origRule@BDMCompile'( _RuleId, _RuleConcl, _RuleCondFormMerged, _)),


		/* Erzeugen aller neuherleitbaren Objekte:                     */
	  findall( _RuleConcl,
	           proveEvaRule( _RuleCondFormMerged),
		   _SetOfNewLiterals),


 /**         WriteTrace(veryhigh,BDMEvaluation, ['SetOfNewLiterals = ', _SetOfNewLiterals]), **/


		/* Auswerten der betroffenen Integritaetsbedingungen:          */
	  'TestIntegrityConstraints'( _ListOfSimpIcIds, _SetOfNewLiterals,'Insert'),

		/* Auswerten der betroffenen Regeln:                           */
	  'TestRules'( _ListOfSimpRuleIds, _SetOfNewLiterals, 'Insert'),
	  !
		/* Jetzt ist der Integritaetstest erfolgreich abgeschlossen.   */

	  );
	  (
		/* Fehler!!!                                                   */

	   report_error( 'WRONG_RULE', 'BDMEvaluation', [ objectName(_RuleId)]),
	   !,
	   fail
	  )

	 )
	).

/* neuer Fall fuer MetaFormel:
ist eine Formel eine MetaFormel, so haengen an ihr keine Trigger
 der Form origConstraint@BDMCompile*/
tellRuleOrIntegrityConstraint( 'P'(_id, _IcId, '*instanceof', _constraintid)) :-
	  id2name(_constraintid,_constraintname),
  	  _constraintname == 'MSFOLrule',
	  prove_edb_literal( 'A_e'(_IcId,'MSFOLconstraint',originalConstraint,_OrigIcId) ),
	  name2id(metaMSFOLrule,_mid),
	  prove_edb_literal( 'In_e'(_OrigIcId,_mid)),!.





tellRuleOrIntegrityConstraint( _) :-

		/* Keine neue Regel und keine neue Integritaetsbedingung!       */
	!.






getIClabel(_mod,_IcId,_iclabel) :-
  prove_literal('Mod'( 'A_label'(_c,constraint,_IcId,_iclabel),_mod) ),
  !.

getIClabel(_mod,_IcId,'?lab'). /** never fail **/




/* *************************************************************************** */
/*                                                                             */
/* untellRule( _propdescr)                                                     */
/*                                                                             */
/* Handelt es sich bei dem zu loeschenden Objekt um eine Instanziierung in     */
/* die spezielle Klasse 'MSFOLrule', so wird ueberprueft, ob mit dieser Regel  */
/* herleitbare Objekte direkt oder indirekt in einen Integritaetstest          */
/* eingehen, und zwar in eine Loeschueberpruefung. In diesem Fall werden alle  */
/* diese Objekte erzeugt und wie Loeschungen dem Integritaetstest unterzogen.  */
/*                                                                             */
/* *************************************************************************** */




untellRule( 'P'( _id, _RuleId, '*instanceof', _ruleid)) :-
	id2name(_ruleid,_rulename),
	_rulename == 'MSFOLrule',

		/* War die zu loeschende Regel fuer Loeschueberpruefungen      */
		/* uebersetzt?                                                 */

	'DependingOnDeletionOfThisRule'(_RuleId,_ListOfSimpIcIds,_ListOfSimpRuleIds),

        (_ListOfSimpIcIds \== [] ; _ListOfSimpRuleIds \== []),

/**
       WriteTrace(low,BDMEvaluation,
                   ['Deletion of rule ',_RuleId, ' affects constraints "',
                    idterm(_ListOfSimpIcIds), '" and rules "',idterm(_ListOfSimpRuleIds),'"']),
**/

	!,
		/* Ja!                                                         */

	((
		/* Holen der vollstaendigen Regel:                             */

	  retrieve_backup_BDMFormula('origRule@BDMCompile'( _RuleId, _RuleConcl, _RuleCondFormMerged, _)),

		/* Erzeugen aller nach Annahme der Transaktion nicht mehr      */
		/* herleitbaren Objekte:                                       */
	  findall( _RuleConcl,
	           proveEvaRule( _RuleCondFormMerged),
		   _SetOfRemovedLiterals),

/**
          WriteTrace(veryhigh,BDMEvaluation, ['SetOfRemovedLiterals = ',
                                               _SetOfRemovedLiterals]),
**/

		/* Auswerten der betroffenen Integritaetsbedingungen:          */
	  'TestIntegrityConstraints'( _ListOfSimpIcIds, _SetOfRemovedLiterals,
                                    'Delete'),

		/* Auswerten der betroffenen Regeln:                           */
	  'TestRules'( _ListOfSimpRuleIds, _SetOfRemovedLiterals, 'Delete'),
	  !
		/* Jetzt ist der Integritaetstest erfolgreich abgeschlossen.   */

	  );
	  (
		/* Fehler!!!                                                   */

	   report_error( 'RULE_NEEDED', 'BDMEvaluation', [ objectName(_RuleId)]),
	   !,
	   fail
	  )

	 ).


/* Keine zu loeschende Regel:                                                  */
untellRule( _) :-

	!.



/** Bestimme alle SimpIcIds und SimpRuleIds, die von der Loeschung **/
/** dieser Regel, d.h. von der Loeschung ihres Folgerungsliterals  **/
/** abhaengen:                                                     **/


'DependingOnDeletionOfThisRule'(_RuleId,_allICs,_allRules) :-
   findall( _BDMPredicateDel, retrieve_backup_BDMFormula( _BDMPredicateDel), _deletedTriggers)	,
   accumulateDeps(_deletedTriggers, _RuleId,_allICs,_allRules),
   !.

accumulateDeps(_deletedTriggers, _RuleId,_allICs,_allRules) :-
  accumulateDeps(_deletedTriggers, _RuleId,[],[],_allICs,_allRules).


accumulateDeps([], _RuleId,_soFarICs,_soFarRules,_soFarICs,_soFarRules) :- !.

accumulateDeps([_trigger|_restTriggers], _RuleId,_soFarICs,_soFarRules,_allICs,_allRules) :- 
  (
   _trigger = 'applyRuleIfInsert@BDMCompile'(_RuleId, _0,_SimpRuleId,_1,_2,_3,goAhead('Delete',_IClist,_Rulelist));
   _trigger = 'applyRuleIfDelete@BDMCompile'(_RuleId, _0,_SimpRuleId,_1,_2,_3,goAhead('Delete',_IClist,_Rulelist))
  ),
  append(_soFarICs,_IClist,_newSoFarICs),
  append(_soFarRules,_Rulelist,_newSoFarRules),
  accumulateDeps(_restTriggers, _RuleId,_newSoFarICs,_newSoFarRules,_allICs,_allRules).

accumulateDeps([_trigger|_restTriggers], _RuleId,_soFarICs,_soFarRules,_allICs,_allRules) :-
  accumulateDeps(_restTriggers, _RuleId,_soFarICs,_soFarRules,_allICs,_allRules).
  











/* *************************************************************************** */
/*                                                                             */
/* tellObjectConcerningIntegrityConstraintsOrRules(_propdescr)                 */
/*                                                                             */
/* Handelt es sich bei dem neuen Objekt um eine Instanziierung in eine         */
/* Klasse, so wird der Integritaetstest aktiviert: Betrachtet werden alle      */
/* Regeln und Integritaetsbedingungen, die von dieser Klasse ausgehen. Die     */
/* Integritaetsbedingungen werden mit dem Objekt, das instanziiert werden      */
/* soll, ausgewertet. Die Regeln werden auf dieses Objekt angewendet, dann     */
/* wird mit den dann betroffenen Integritaetsbedingungen und noch weiter       */
/* anzuwenden Regeln bezogen auf die hergeleiteten neuen Objekte genauso       */
/* verfahren. Bei keiner der Auswertungen darf ein Fehler anfallen, sonst      */
/* kommt es zu einer Fehlerausgabe und das Praedikat endet erfolglos (fail).   */
/*                                                                             */
/* *************************************************************************** */



tellObjectConcerningIntegrityConstraintsOrRules(
	'P'( _id, _Object, '*instanceof', _ClassId)) :-
		/* Sammeln aller Integritaetsbedingungen und Regeln, die von   */
		/* dieser Klasse (oder ihren Oberklassen) ausgehen:            */
	findall( _SimpIcId,
                    (prove_edb_literal('Isa'(_ClassId,_super1)),
			(
		    		retrieve_BDMFormula( 'applyConstraintIfInsert@BDMCompile'( _IcId, _super1, _SimpIcId, _, _))),
				isVisible(_IcId)
			),
	            _ListOfSimpIcIds),
	findall( _SimpRuleId,
                    (prove_edb_literal('Isa'(_ClassId,_super2)),
			(
		    		retrieve_BDMFormula( 'applyRuleIfInsert@BDMCompile'( _RuleId, _super2, _SimpRuleId, _, _, _, _))),
				isVisible(_SimpRuleId)  /** check due to ticket #64 **/
			),
	            _ListOfSimpRuleIds),


	( _ListOfSimpIcIds \== []; _ListOfSimpRuleIds \== []),

		/* _ClassId ist durch mindestens eine Integritaetsbedingung    */
		/* oder Regel betroffen.                                       */

		/* Holen des zu instanziierenden Objekts:                      */
	  retrieve_proposition( 'P'( _Object, _s, _l, _d)),

		/* Zur Schnittstellenbedienung:                                */
	  'InstLiterals'( 'P'(_id,_Object,'*instanceof',_ClassId),
                        'P'(_Object,_s,_l,_d), _lits),

	((
		/* Auswerten der betroffenen Integritaetsbedingungen:          */
	  'TestIntegrityConstraints'( _ListOfSimpIcIds, _lits, 'Insert'),

		/* Anwenden der betroffenen Regeln und Fortfahren:             */
	  'TestRules'( _ListOfSimpRuleIds, _lits, 'Insert'),
	  !
	 );
	 (
		/* Jetzt liegt ein Fehler vor:                                 */
	  !,
	  report_error( 'OBJECT_INCONSISTENT', 'BDMEvaluation',
                       [ objectName(_Object), objectName(_ClassId)]),
          !,
	  fail
	)).




tellObjectConcerningIntegrityConstraintsOrRules(
	'P'( _id, _Object, '*isa', _ClassId)) :-
		/* Sammeln aller Integritaetsbedingungen und Regeln, die von   */
		/* dieser Klasse (oder ihren Oberklassen) ausgehen:            */
	name2id('IsA',_isaid),  /*Concerned Class fuer IsA Links */
	findall( _SimpIcId,
			(retrieve_BDMFormula( 'applyConstraintIfInsert@BDMCompile'( _IcId, _isaid, _SimpIcId, _, _)),
			 isVisible(_IcId)
			),
	            _ListOfSimpIcIds),
	findall( _SimpRuleId,
			(
		    	  retrieve_BDMFormula( 'applyRuleIfInsert@BDMCompile'( _RuleId, _isaid, _SimpRuleId, _, _, _, _)),
			  isVisible(_SimpRuleId)  /** check due to ticket #64 **/
			),
	            _ListOfSimpRuleIds),

	( _ListOfSimpIcIds \== []; _ListOfSimpRuleIds \== []),
	((
		/* Auswerten der betroffenen Integritaetsbedingungen:          */
	  'TestIntegrityConstraints'( _ListOfSimpIcIds, ['Isa'(_Object,_ClassId)], 'Insert'),

		/* Anwenden der betroffenen Regeln und Fortfahren:             */
	  'TestRules'( _ListOfSimpRuleIds, ['Isa'(_Object,_ClassId)], 'Insert'),
	  !
	 );
	 (
		/* Jetzt liegt ein Fehler vor:                                 */
	  !,
	  report_error( 'OBJECT_INCONSISTENT', 'BDMEvaluation',
                       [ objectName(_Object), objectName(_ClassId)]),
          !,
	  fail
	)).




tellObjectConcerningIntegrityConstraintsOrRules( _) :-

		/* Das neue Objekt geht weder direkt noch indirekt             */
		/* in einen Integritaetstest ein.                              */
	!.










/* *************************************************************************** */
/*                                                                             */
/* untellObjectConcerningIntegrityConstraintsOrRules( _propdescr)              */
/*                                                                             */
/* Geht die Klasse, zu der das Objekt nach der Transaktion nicht mehr gehoeren */
/* soll, in eine Integritaetsbedingung (in-)direkt ein, so wird der            */
/* Integritaetstest aktiviert: Betrachtet werden alle Regeln und Integritaets- */
/* bedingungen bzgl. delete, die von dieser Klasse ausgehen. Die               */
/* Integritaetsbedingungen werden mit dem Objekt, das instanziiert werden      */
/* soll, ausgewertet. Die Regeln werden auf dieses Objekt angewendet, dann     */
/* wird mit den dann betroffenen Integritaetsbedingungen und noch weiter       */
/* anzuwenden Regeln bezogen auf die hergeleiteten Objekte genauso             */
/* verfahren. Bei keiner der Auswertungen darf ein Fehler anfallen, sonst      */
/* kommt es zu einer Fehlerausgabe und das Praedikat endet erfolglos (fail).   */
/*                                                                             */
/* *************************************************************************** */



untellObjectConcerningIntegrityConstraintsOrRules(
	'P'( _id, _Object, '*instanceof', _ClassId)) :-

		/* Sammeln aller Integritaetsbedingungen und Regeln, die von   */
		/* dieser Klasse (oder ihren Oberklassen) ausgehen:            */
	findall( _SimpIcId,
                    (prove_edb_literal('Isa'(_ClassId,_super1)),
		    retrieve_BDMFormula( 'applyConstraintIfDelete@BDMCompile'( _IcId, _super1, _SimpIcId, _, _)),
											/* 26-May-1995 LWEB */
	    	    isVisible(_IcId)
		     ),
	            _ListOfSimpIcIds),
	findall( _SimpRuleId,
                    (prove_edb_literal('Isa'(_ClassId,_super2)),
		    retrieve_BDMFormula( 'applyRuleIfDelete@BDMCompile'( _RuleId, _super2, _SimpRuleId, _, _, _, _)),
		    isVisible(_SimpRuleId)  /** check due to ticket #64 **/
                    ),
	            _ListOfSimpRuleIds),

	( _ListOfSimpIcIds \== []; _ListOfSimpRuleIds \== []),


		/* _ClassId ist durch mindestens eine Integritaetsbedingung    */
		/* oder Regel betroffen.                                       */

		/* Holen des zu instanziierenden Objekts:                      */
	  'RetrieveProposition'( 'P'( _Object, _s, _l, _d)),

		/* Zur Schnittstellenbedienung:                                */
	  'InstLiterals'( 'P'(_id,_Object,'*instanceof',_ClassId),
                        'P'(_Object,_s,_l,_d), _lits),

	((
		/* Auswerten der betroffenen Integritaetsbedingungen:          */
	  'TestIntegrityConstraints'( _ListOfSimpIcIds, _lits, 'Delete'),

		/* Anwenden der betroffenen Regeln und Fortfahren:             */
	  'TestRules'( _ListOfSimpRuleIds, _lits, 'Delete'),
	  !
	 );
	 (
		/* Jetzt liegt ein Fehler vor:                                 */
	  !,
	  report_error( 'OBJECT_NEEDED', 'BDMEvaluation',
                       [ objectName(_Object), objectName(_ClassId)]),
          !,
	  fail
	)).





untellObjectConcerningIntegrityConstraintsOrRules(
	'P'( _id, _Object, '*isa', _ClassId)) :-
		/* Sammeln aller Integritaetsbedingungen und Regeln, die von   */
		/* dieser Klasse (oder ihren Oberklassen) ausgehen:            */
	name2id('IsA',_isaid),  /*Concerned Class fuer IsA Links */
	findall( _SimpIcId,
			(retrieve_BDMFormula( 'applyConstraintIfInsert@BDMCompile'( _IcId, _isaid, _SimpIcId, _, _)),
	    	         isVisible(_IcId)
			),
	            _ListOfSimpIcIds),
	findall( _SimpRuleId,
                    (
		    retrieve_BDMFormula( 'applyRuleIfInsert@BDMCompile'( _RuleId, _isaid, _SimpRuleId, _, _, _, _)),
		    isVisible(_SimpRuleId)  /** check due to ticket #64 **/
                    ),
	            _ListOfSimpRuleIds),

	( _ListOfSimpIcIds \== []; _ListOfSimpRuleIds \== []),
	((
		/* Auswerten der betroffenen Integritaetsbedingungen:          */
	  'TestIntegrityConstraints'( _ListOfSimpIcIds, ['Isa'(_Object,_ClassId)], 'Delete'),

		/* Anwenden der betroffenen Regeln und Fortfahren:             */
	  'TestRules'( _ListOfSimpRuleIds, ['Isa'(_Object,_ClassId)], 'Delete'),
	  !
	 );
	 (
		/* Jetzt liegt ein Fehler vor:                                 */
	  !,
	  report_error( 'OBJECT_INCONSISTENT', 'BDMEvaluation',
                       [ objectName(_Object), objectName(_ClassId)]),
          !,
	  fail
	)).




untellObjectConcerningIntegrityConstraintsOrRules( _) :-

		/* Das zu loeschende Objekt geht weder direkt noch indirekt    */
		/* in einen Integritaetstest ein.                              */
	!.




















/* ================== */
/* Private predicate: */
/* ================== */







/* ****************************   T e s t R u l e s ************************** */
/*                                                                             */
/* TestRules( _ListOfSimpRuleIds, _SetOfLiterals, _InsDel)                     */
/*                                                                             */
/* Die Elemente in der Liste (2. Arg.) sind alle Instanzen einer Klasse, die   */
/* von den Regeln (1.Arg.) betroffen sind.                                     */
/* Die Regeln werden mit allen Elementen ausgewertet, dann wird mit weiteren   */
/* Regeln und Integritaetsbedingungen fortgefahren.                            */
/* Kommt es dabei zu einem Fehler, wird dieser ausgegeben.                     */
/*                                                                             */
/* *************************************************************************** */


'TestRules'( [], _, _) :-

		/* Es sind keine Regeln anzuwenden.                            */
	!.


'TestRules'( _ListOfSimpRuleIds, [], _) :-

		/* Es sind keine Objekte mehr zu ueberpruefen.                 */
	!.




'TestRules'( _ListOfSimpRuleIds, _SetOfLiterals, _InsDel) :-
		/* Mit jeder betroffenen Regel:                                */
	member( _SimpRuleId, _ListOfSimpRuleIds),

	(( _InsDel == 'Insert',
	   retrieve_BDMFormula_once( 'applyRuleIfInsert@BDMCompile'( _RuleId, _, _SimpRuleId, _Literal, _RuleConcl, _RuleCondMerged,
		  goAhead(_nowInsDel,_ListOfSimpIcIdsNew,_ListOfSimpRuleIdsNew))),
           isVisible(_SimpRuleId)  /** check due to ticket #64 **/
	 );
	 ( _InsDel == 'Delete',
	   retrieve_BDMFormula_once( 'applyRuleIfDelete@BDMCompile'( _RuleId, _, _SimpRuleId, _Literal, _RuleConcl, _RuleCondMerged,
		  goAhead(_nowInsDel,_ListOfSimpIcIdsNew,_ListOfSimpRuleIdsNew))),
           isVisible(_SimpRuleId)  /** check due to ticket #64 **/
	)),

increment('ruleTriggerCalls'),

        deltaRuleConclusions(_InsDel,_SetOfLiterals,_Literal,
                             _nowInsDel,_RuleConcl,_RuleCondMerged,
                             _SetOfNewLiterals),


		/* Auswerten der betroffenen Integritaetsbedingungen mit jedem */
		/* der neu herleitbaren Literale:                              */
	\+(('TestIntegrityConstraints'( _ListOfSimpIcIdsNew, _SetOfNewLiterals,
	                             _nowInsDel),

		/* Auswerten der betroffenen Regeln:                           */
	   'TestRules'( _ListOfSimpRuleIdsNew, _SetOfNewLiterals, _nowInsDel)
	  )),
		/* Und weiter mit den anderen neuen Objekten, bzw. ICs!        */


		/* Jetzt liegt ein Fehler vor:                                 */
	!,
        'WriteTrace'(high,'BDMEvaluation',
                   ['The application ', 'of the rule ', idterm(_RuleId),
		  ' leads to an ', 'integrity error.']),
/**	report_error( DUEtoRULE, BDMEvaluation, [ objectName(_RuleId)]), **/
        !,
	fail.



'TestRules'( _, _, _) :-

		/* Alle betroffene Regeln wurden angewendet.                   */
	!.



'TestRules_help'( _SetOfLiterals, _Literal, _RuleCondMerged, _RuleConcl) :-

	member( _Literal, _SetOfLiterals),
	proveEvaRule(_RuleCondMerged).
               /**** note: var's of _RuleConcl occur in _RuleCondMerged */



/* ************* d e l t a R u l e C o n c l u s i o n s ************* */
/*                                                                     */
/* deltaRuleConclusions(_InsDelOnCondition,_SetOfLiterals,_Literal,    */
/*                    _InsDelOnConcl,_RuleConcl,_RuleCondMerged,       */
/*                    _DeltaLiterals)                                  */
/*                                                                     */
/*   _InsDelOnCondition: Insert/Delete (i)                             */
/*   _SetOfLiterals: list (i)                                          */
/*   _Literal: term (i)                                                */
/*   _InsDelOnConcl: Insert/Delete (i)                                 */
/*   _RuleConcl: term (i)                                              */
/*   _RuleCondMerged: term (i)                                         */
/*   _DeltaLiterals: list (o)                                          */
/*                                                                     */
/* Die Operation _InsDelOnCondition auf den Literalen _SetOfLiterals   */
/* wird in die vereinfachte Form _RuleCondMerged mit Folgerungsliteral */
/* _RuleConcl und Instanzierungsliteral _Literal eingespeist.          */
/* _DeltaLiterals ist die Menge der geaenderten Loesungen fuer das     */
/* Folgerungsliteral, wobei _InsDelOnConcl angibt, ob sie eingefuegt   */
/* neu herleitbar) oder geloescht (nicht mehr herleitbar) sind.        */
/*                                                                     */
/* Falls _InsDelOnCondition=_InsDelOnConcl, so braucht _RuleCondMerged */
/* lediglich auf dem vollen KB-Zustand (d.h. mit temporaeren Objekten) */
/* getestet zu werden.                                                 */
/*                                                                     */
/* Ansonsten wird durch zweifaches Ableiten die Differenz der aus      */
/* _RuleCondMerged ableitbaren Folgerungsliterale auf dem alten und    */
/* neuen KB-Zustand ermittelt.                                         */
/*                                                                     */
/* ******************************************************************* */


deltaRuleConclusions(_InsDelOnCondition,_SetOfLiterals,_Literal,
                     _InsDelOnConcl,_RuleConcl,_RuleCondMerged,
                     _DeltaLiterals) :-

   _InsDelOnCondition == _InsDelOnConcl,
   !,
   get_KBsearchSpace(_kb,_rbt),
    ( (_InsDelOnCondition == 'Insert',set_KBsearchSpace(newOB,'Now'));
	(_InsDelOnCondition == 'Delete',set_KBsearchSpace(oldOB,'Now')) ),

   /** ticket #303: need findall instead cm_findall here??? **/
   findall( _RuleConcl,
            'TestRules_help'( _SetOfLiterals,
                             _Literal, _RuleCondMerged, _RuleConcl),
            _pDeltaLiterals),


   removeAlreadyProcessed(_InsDelOnConcl,_pDeltaLiterals,_DeltaLiterals),
   set_KBsearchSpace(_kb,_rbt),   /*alte Setzungen*/

   !.


deltaRuleConclusions(_InsDelOnCondition,_SetOfLiterals,_Literal,
                     _InsDelOnConcl,_RuleConcl,_RuleCondMerged,
                     _DeltaLiterals) :-

   _InsDelOnCondition \== _InsDelOnConcl,

   get_KBsearchSpace(_kb,_rbt),

   /* ... Loesungen in der ganzen Wissensbank: */

  ( (_InsDelOnCondition == 'Insert',set_KBsearchSpace(newOB,'Now'));
	(_InsDelOnCondition == 'Delete',set_KBsearchSpace(oldOB,'Now')) ),

   cm_findall( _RuleConcl,
            'TestRules_help'( _SetOfLiterals,
                             _Literal, _RuleCondMerged, _RuleConcl),
            _wholeKB_Solutions),


   /* ... Loesungen in der Wissensbank ohne die temporaeren Objekte: */

   set_KBsearchSpace(currentOB,'Now'),
   /** ticket #303: need findall instead cm_findall here??? **/
   findall( _RuleConcl,
            'TestRules_help'( _SetOfLiterals,
                             _Literal, _RuleCondMerged, _RuleConcl),
            _persistentKB_Solutions),

   setDifference(_persistentKB_Solutions,_wholeKB_Solutions,_pDeltaLiterals),
   removeAlreadyProcessed(_InsDelOnConcl,_pDeltaLiterals,_DeltaLiterals),

   set_KBsearchSpace(_kb,_rbt),   /*alte Setzungen*/

   !.


removeAlreadyProcessed(_InsDel,_alllits,_newlits) :-
  scanAllLits(_InsDel,_alllits,_newlits),
  !.

scanAllLits(_InsDel,[],[]) :- !.

scanAllLits(_InsDel,[_lit|_rest],_newlits) :-
  alreadyProcessed(_InsDel,_lit),
/** write('alreadyProcessed: '),write_lcall(_lit),nl, **/
  !,
  scanAllLits(_InsDel,_rest,_newlits).

scanAllLits(_InsDel,[_lit|_rest],[_lit|_newlits]) :-
  storeLit(_InsDel,_lit),
  scanAllLits(_InsDel,_rest,_newlits).


alreadyProcessed('Insert',_lit) :- 'Inserted'(_lit).
alreadyProcessed('Delete',_lit) :- 'Deleted'(_lit).

storeLit('Insert',_lit) :- assert('Inserted'(_lit)).
storeLit('Delete',_lit) :- assert('Deleted'(_lit)).




/* ************   T e s t I n t e g r i t y C o n s t r a i n t s ************ */
/*                                                                             */
/* TestIntegrityConstraints( _ListOfSimpIcIds, _SetOfLiterals, _InsDel)        */
/*                                                                             */
/* Die Elemente in der Liste (2. Arg.) sind alle Instanzen einer Klasse, die   */
/* von den Integritaetsbedingungen (1.Arg.) betroffen sind.                    */
/* Die Integritaetsbedingungen werden mit allen Elementen ausgewertet.         */
/* Kommt es dabei zu einem Fehler, wird dieser ausgegeben.                     */
/*                                                                             */
/* *************************************************************************** */


'TestIntegrityConstraints'( [], _, _) :-

		/* Es sind keine Integritaetsbedingungen zu ueberpruefen.      */
	!.


'TestIntegrityConstraints'( _ListOfSimpIcIds, [], _) :-

		/* Es sind keine Objekte mehr zu ueberpruefen.                 */
	!.



'TestIntegrityConstraints'( _ListOfSimpIcIds, _SetOfLiterals, _InsDel) :-

/**       WriteTrace(veryhigh,BDMEvaluation,['Test integrity constraints ',
                  _ListOfSimpIcIds, ' on literals ',_SetOfLiterals,
                  ' for operation ',_InsDel]), **/

		/* Mit jeder betroffenen Integritaetsbedingung:                */
	member( _SimpIcId, _ListOfSimpIcIds),

	(( _InsDel == 'Insert',
	   	retrieve_BDMFormula_once( 'applyConstraintIfInsert@BDMCompile'( _IcId, _, _SimpIcId, _Literal, _IcFormSimplMerged)),
												/* 26-May-1995 LWEB */
	        isVisible(_IcId)
	 );
	 ( _InsDel == 'Delete',
	   	retrieve_BDMFormula_once( 'applyConstraintIfDelete@BDMCompile'( _IcId, _, _SimpIcId, _Literal, _IcFormSimplMerged)),		/* 26-May-1995 LWEB */
	        isVisible(_IcId)
	)),

increment('constraintTriggerCalls'),

		/* Fuer jedes der neu hergeleiteten Literale:                  */
                /* (gleichzeitig werden die freien Variablen in                */
                /* _IcFormSimplMerged belegt!)                                 */

	member( _Literal, _SetOfLiterals),

		/* Auswerten der Integritaetsbedingung mit diesem Literal:     */
        \+proveEvaFormula_once(_IcFormSimplMerged),
		/* Und weiter mit den anderen neuen Objekten, bzw. ICs!        */


		/* Jetzt liegt ein Fehler vor:                                 */
	!,
	get_module(_IcId,_modic),
        checkOnHint(_IcId,_explanationtext,_c,_IClabel),
	report_error( 'IC_VIOLATION', 'BDMEvaluation', [_InsDel,formula([_Literal]),_explanationtext,objectName(_c),_IClabel]),
        !,
	fail.





'TestIntegrityConstraints'( _, _, _) :-

		/* Alle zu testenden ICs sind mit allen zu ueberpruefenden     */
		/* Elementen getestet.                                         */
	!.



/** 3-Mar-2005/M.Jeusfeld: solve ticket #58, i.e. output a user-definable text **/
/** when an integrity constraint is violatated.                                **/


/** case 1: constraint has a hint **/
checkOnHint(_IcId,_hinttext,_class,_label) :-
  traceOriginalIc(_IcId,_class,_label),
  prove_literal('P'(_id,_c,_hasIC,_IcId)),
  attribute('P'(_id,_c,_hasIC,_IcId)),
  prove_literal('A_label'(_id,comment,_textid,hint)),
  outObjectName(_textid,_text),
  unquoteAtom(_text,_hinttext),
  !.

/** case 2: display the source of _IcId **/
checkOnHint(_IcId,_hinttext,_class,_label) :-
  traceOriginalIc(_IcId,_class,_label),
  prove_literal('P'(_id,_c,_hasIC,_IcId)),
  attribute('P'(_id,_c,_hasIC,_IcId)),
  outObjectName(_IcId,_ictext),
  pc_atomconcat(['The concerned integrity constraint is ',_ictext,'. '],_hinttext1),
  checkOnMetaFormula(_IcId,_hinttext2),
  pc_atomconcat(_hinttext1,_hinttext2,_hinttext),
  !.

/** case 3: display some default text **/

checkOnHint(_IcId,'This should never occur. Inform the ConceptBase team!',noclass,nolabel).


/** checkOnMetaFormula: if _IcId is an integrity constraint generated from a meta formula, **/
/** then there should be some explanation why _IcId was generated. The reason is that      **/
/** some fact was inserted to the object base, which triggered the meta formula compiler.  **/
/** This fact (matching the so-called E-predicate) happens to be maintained by ConceptBase **/
/** in the applyPredicateIfDelete@BDMCompile facts. So we can just use these facts to      **/
/** produce more explanation for the IC_VIOLATION error message.                           **/
/** The applyPredicateIfDelete fact contains the generated _IcId in the _procedure         **/
/** argument. Note that we should only print those _lit which are responsible for the      **/
/** generation of _IcId.                                                                   **/

checkOnMetaFormula(_IcId,_whymetatext) :-
  prove_edb_literal('In_e'(_IcId,_metaIcId)),  /** IcId is generated from metaIcId **/
  findall(_lit,
           (
           retrieve_BDMFormula('applyPredicateIfDelete@BDMCompile'(_lit,_metaIcId,_procedure)),
           createModTerm(deleteGeneratedFormula,'AssertionTransformer',[_IcId,_number,_metaIcId,_mode],_procedure)
           ),
           _litlist),
  _litlist \= [],
  outFormula(_litlist,_littext),
  pc_atomconcat(['The integrity constraint was activated by an earlier update which made ',
                 _littext, ' true in the object base.'],_whymetatext),
  !.

checkOnMetaFormula(_,'').
  
  


/** traceOriginalIc finds the class where the integrity constraint was originally defined **/
/** It follows ISA links between instances of MSFOLconstraint. This tracing is  **/
/** necessary when a formula has been generated from a meta formula.                      **/

traceOriginalIc(_IcId,_class,_label) :-
  prove_edb_literal('Isa'(_IcId,_otherIc)),
  _otherIc \= _IcId,
  prove_edb_literal('In_e'(_otherIc,id_52)),  /** id_52=MSFOLconstraint **/
  !,
  traceOriginalIc(_otherIc,_class,_label).

traceOriginalIc(_IcId,_class,_label) :-
  prove_literal('P'(_id,_class,_label,_IcId)),
  attribute('P'(_id,_class,_label,_IcId)),
  !.
  




/* ************************   I n s t L i t e r a l s  ************************ */
/*                                                                              */
/* InstLiterals(_p1,_p2,_lits) gives the induced solutions to the base literals */
/* Adot, Aidot and In dependent on the two new (or deleted) objects             */
/* _p1,_p2. No deductive rules except Isa hierachies are taken into account.    */
/* p1 is the instantiation and p2 is the object mentioned in the source of p1.  */
/* See also CBNEWS[153]                                                         */
/*                                                                              */
/* **************************************************************************** */

'InstLiterals'( 'P'(_id,_Object,'*instanceof',_Class),
              _propdescr,
              _lits) :-
  findall(_c,prove_edb_literal('Isa'(_Class,_c)),_classes),  /* at least _Class is */
  foldInstLiterals(_classes,_propdescr,_lits),       /* a solution         */
  !.

/** case 1 **/
foldInstLiterals([],_,[]) :- !.


/** old variant for case 2: */
foldInstLiterals([_c|_rest],'P'(_Object,_Object,_l,_Object),
                 ['In'(_Object,_c)|_restlits]) :-
  !,
  foldInstLiterals(_rest,'P'(_Object,_Object,_l,_Object),_restlits).

/** new variant for case 2: */
/** ticket #314: we should also generate the In_e fact but since it does not
   have a concerned class in the formula of ticket 314, we leave it as is
foldInstLiterals([_c|_rest],P(_Object,_Object,_l,_Object),
                 [In(_Object,_c),In_e(_Object,_c)|_restlits]) :-
  !,
  foldInstLiterals(_rest,P(_Object,_Object,_l,_Object),_restlits).
**/


/** case 3 **/
foldInstLiterals([_c|_rest],'P'(_id,_x,_l,_y),
                 ['Adot'(_c,_x,_y),'Aedot'(_c,_x,_y),'Aidot'(_c,_x,_id),'Adot_label'(_c,_x,_y,_l),
                  'In'(_id,_c)|_restlits]) :-
  attribute('P'(_id,_x,_l,_y)),
  !,
  foldInstLiterals(_rest,'P'(_id,_x,_l,_y),_restlits).

/** case 4: skip instantiations and specializations **/
foldInstLiterals([_c|_rest],'P'(_id,_x,_l,_y),_restlits) :-
  foldInstLiterals(_rest,'P'(_id,_x,_l,_y),_restlits).




/* *************************************************************************** */
/*                                                                             */
/*                      F O R M E L A U S W E R T E R                          */
/*                                                                             */
/*                                                                             */
/* *************************************************************************** */


/* ********************** p r o v e E v a F o r m u l a ********************** */
/*                                                                             */
/* proveEvaFormula(_Formula)                                                   */
/*   _Formula: term (i/o)                                                      */
/*                                                                             */
/* Die auszuwertende Formel muss das folgende Format haben:                    */
/*    <Formula>      ::=  forall( <LiteralList>, <Formula>)  |                 */
/*                        exists( <LiteralList>, <Formula>)  |                 */
/*                        and(<Formula>,<Formula>) |                           */
/*                        or(<Formula>,<Formula>) |                            */
/*                        implies(<LiteralList>,<Formula>) |                   */
/*                        <Literal> | not(<Literal>)                           */
/*                        FALSE  |                                             */
/*                        TRUE                                                 */
/*    <LiteralList>  ::=  [ <Literals> ] |                                     */
/*                        []                                                   */
/*    <Literals>     ::=  <Literal>, <Literals>  |                             */
/*                        <Literal>                                            */
/*    <Literal>      ::=  siehe Literals.pro                                   */
/*                                                                             */
/*                                                                             */
/*    forall([ a1, ..., an], InnerFormula)                                     */
/* entspricht                                                                  */
/*    forall eingeordnete Variablen (not a1 or ... or not an or InnerFormula)  */
/* und                                                                         */
/*    exists([ a1, ..., an], InnerFormula)                                     */
/* entspricht                                                                  */
/*    exists eingeordnete Variable (a1 and ... and an and InnerFormula).       */
/*                                                                             */
/* Zur Semantik dieser Formeln: sie entsprechen dem Vorschlag fuer Formeln aus */
/* [BrDeMa 88]. Dort taucht allerdings noch ein zusaetzliches Argument auf,    */
/* das gewisse Variablen auffuehrt. Dieses ist hier nicht mehr notwendig, da   */
/* die Variablen hier quantifiziert sind; die Quantoren muessen vor dem Aufruf */
/* dieses Formelauswerters in Literale umgewandelt werden und in die restlichen*/
/* Literale der Formel an geeigneter Stelle eingeordnet werden (vgl. BDMTrans- */
/* Formula). Der Formelauswerter ermoeglicht den Gebrauch der in der obigen    */
/* Syntax aufgefuehrten Literale.                                              */
/*                                                                             */
/* 26-Oct-1990/MJf: Konjunktionen (and) und Disjunktionen (or) sowie positive  */
/* und negative Literale sind jetzt als auswertbare Formeln zugelassen.        */
/*                                                             29-Oct-1990/MJf */
/* *************************************************************************** */


proveEvaFormula( forall(_lits,_F) ) :-
  prove_literals(_lits),
  \+ proveEvaFormula(_F),
  !,
  fail.


proveEvaFormula( forall(_lits,_F) ) :- !.


/* implies is like forall but all variables in _lits are ground, hence */
/* there no need to backtrack over _lits as done for 'forall'          */


proveEvaFormula( implies(_lits,_F) ) :-
  prove_literals(_lits),
  !,
  proveEvaFormula(_F),
  !.

proveEvaFormula( implies(_lits,_F) ) :- !.


proveEvaFormula( exists(_lits,_F) ) :-
  prove_literals(_lits),
  proveEvaFormula(_F).


proveEvaFormula( and(_F1,_F2) ) :-
  proveEvaFormula(_F1),
  proveEvaFormula(_F2).


proveEvaFormula( or(_F1,_F2) ) :-
  proveEvaFormula(_F1);
  proveEvaFormula(_F2).


proveEvaFormula( 'TRUE' ) :- !.

proveEvaFormula( 'FALSE' ) :- !,fail.


proveEvaFormula( not(_lit) ) :-
  not_prove_literal(_lit).

proveEvaFormula( _lit ) :-
  prove_literal(_lit).




/** simplifyEva(_F,_Fs) takes an eva-formula as input and applies the following **/
/** simplifications:                                                            **/
/**  a) Literals like From(_id,_x), To(_id,_y), P(_id,_x,_l,_y) with bound id   **/
/**     are evaluated yielding values for the other arguments. This is ok       **/
/**     since _id is uniquely determining the other arguments.                  **/
/**  b) quantification expressions like exists,forall are removed when there is **/
/**     no variable in the subexpression.                                       **/
/**  c) All _lit in a list _lits which are true in the database are removed.    **/
/**     These do not need to be reported to the user                            **/
/**  d) Spurious occurences of 'and TRUE' are eliminated.                       **/
/** As a result, we have a more readable formula _Fs, that we report in the     **/
/** error message to the user.                                                  **/
/**                                                                             **/
/** Note that simplifyEva is only evaluated for formulas _F that are not        **/
/** true in the current object base. Hence, when we eliminate true literals in  **/
/** step c), we are sure that some un-true literals remain. These are those     **/
/** should be true and thus should be reported to the user.                     **/


simplifyEva(_F,_Fs) :-
  replaceDependentVars(_F,_F1),
  removeQuants(_F1,_F2),
  elimAndTrue(_F2,_Fs),
  !.

simplifyEva(_F,_F).


/** elimAndTrue does task d) mentioned above **/

elimAndTrue(and([],'TRUE'),'TRUE').

elimAndTrue(and(_F,'TRUE'),_F1) :-
  elimAndTrue(_F,_F1).

elimAndTrue(and('TRUE',_F),_F1) :-
  elimAndTrue(_F,_F1).

elimAndTrue(and(_F,_G),_H) :-
  elimAndTrue(_F,_F1),
  elimAndTrue(_G,_G1),
  (_F \== _F1; _G \== _G1),
  elimAndTrue(and(_F1,_G1),_H).

elimAndTrue(and(_F,[]),_F1) :-
  elimAndTrue(_F,_F1).

elimAndTrue(and([],_F),_F1) :-
  elimAndTrue(_F,_F1).

/** "or FALSE" is like "and TRUE" **/
elimAndTrue(or(_F,'FALSE'),_F1) :-
  elimAndTrue(_F,_F1).

elimAndTrue(or('FALSE',_F),_F1) :-
  elimAndTrue(_F,_F1).

elimAndTrue(_F,_F).



/** removeQuants does tasks b) and c) mentioned above **/

removeQuants(exists(_lits,_F),and(_lits1,_F)) :-
  ground(_lits),
  removeTrueLits(_lits,_lits1),
  !.

removeQuants(forall(_lits,_F),implies(_lits1,_F)) :-
  ground(_lits),
  removeTrueLits(_lits,_lits1),
  !.

removeQuants(exists(_lits,_F),exists(_lits1,_F)) :-
  removeTrueLits(_lits,_lits1),
  !.

removeQuants(forall(_lits,_F),forall(_lits1,_F)) :-
  removeTrueLits(_lits,_lits1),
  !.

removeQuants(and(_F,_G),and(_F1,_G1)) :-
  removeQuants(_F,_F1),
  removeQuants(_G,_G1).

removeQuants(or(_F,_G),or(_F1,_G1)) :-
  removeQuants(_F,_F1),
  removeQuants(_G,_G1).

removeQuants(_F,_F).

removeTrueLits([],[]) :- !.

removeTrueLits([_lit|_rest],_rest1) :- 
  ground(_lit),
  prove_literal(_lit),
  !,
  removeTrueLits(_rest,_rest1).

removeTrueLits([_lit|_rest],[_lit|_rest1]) :-
  removeTrueLits(_rest,_rest1).




/** replaceDependentVars does task a) mentioned above **/

replaceDependentVars(exists(_lits,_F),exists(_lits1,_F1)) :-
  replaceDependentVars(_lits,_lits1),
  replaceDependentVars(_F,_F1).

replaceDependentVars(forall(_lits,_F),forall(_lits1,_F1)) :-
  replaceDependentVars(_lits,_lits1),
  replaceDependentVars(_F,_F1).

replaceDependentVars(and(_F,_G),and(_F1,_G1)) :-
  replaceDependentVars(_F,_F1),
  replaceDependentVars(_G,_G1).

replaceDependentVars(or(_F,_G),or(_F1,_G1)) :-
  replaceDependentVars(_F,_F1),
  replaceDependentVars(_G,_G1).

replaceDependentVars(implies(_F,_G),implies(_F1,_G1)) :-
  replaceDependentVars(_F,_F1),
  replaceDependentVars(_G,_G1).

replaceDependentVars(not(_lit),not(_lit1)) :-
  replaceDependentVarsInLit(_lit,_lit1).

replaceDependentVars([],[]) :- !.

replaceDependentVars([_lit|_rest],[_lit1|_rest1]) :-
  replaceDependentVarsInLit(_lit,_lit1),
  replaceDependentVars(_rest,_rest1).

replaceDependentVars(_F,_F).

replaceDependentVarsInLit('From'(_id,_x),'From'(_id,_x)) :-
  atom(_id),
  var(_x),
  prove_literal('From'(_id,_x)),
  !.

replaceDependentVarsInLit('To'(_id,_y),'To'(_id,_y)) :-
  atom(_id),
  var(_y),
  prove_literal('To'(_id,_y)),
  !.

replaceDependentVarsInLit('P'(_id,_x,_l,_y), 'P'(_id,_x,_l,_y)) :-
  atom(_id),
  (var(_x);var(_l);var(_y)),
  prove_literal('P'(_id,_x,_l,_y)),
  !.

/** when x,m,l are bound in a literal A_label(x,ml,y,l), then there can **/
/** be at most one solution for y due to the uniqueness of attribute    **/
/** labels within an object x.                                          **/
replaceDependentVarsInLit('A_label'(_x,_ml,_y,_l),'A_label'(_x,_ml,_y,_l)) :-
  atom(_x),
  atom(_ml),
  atom(_l),
  var(_y),
  prove_literal('A_label'(_x,_ml,_y,_l)),
  !.

/** same for Adot_label variant                                         **/
replaceDependentVarsInLit('Adot_label'(_cc,_x,_y,_l),'Adot_label'(_cc,_x,_y,_l)) :-
  atom(_cc),
  atom(_x),
  atom(_l),
  var(_y),
  prove_literal('Adot_label'(_cc,_x,_y,_l)),
  !.


replaceDependentVarsInLit(_lit,_lit).




  


/**** proveEvaRule(_F) evaluates the condition _f of a deductive rule.     */
/**** We could take proveEvaFormula for this task but that would loop      */
/**** endlessly for certain recursive rules (see also BDMTransFormula and  */
/**** CBNEWS[156]. Therefore, we take advantage of the transformations     */
/**** done in BDMTransFormula which produces so-called "safe" forms of the */
/**** rule condition: the recursive literals are pushed inside the formula.*/
/**** First, proveEvaRule decomposes _f into the or-subformulas (the cases */
/**** of the formula). Each subformula is treated as follows: the range    */
/**** literals _savelits are evaluated in the normal way. Since the are    */
/**** non-recursive, evaluation will terminate even with backtracking. The */
/**** inner formula _innerF may contain recursive predicates. It is evalu- */
/**** ated in a non-backtracking way. This is ok since all free variables  */
/**** of the conclusion literal are already bound by _savelits. Thus, we   */
/**** only have to test the variable bindings generated by the evaluation  */
/**** of _safelits.                                                        */
/**** This strategy, cures some of the non-terminations of recursive rules.*/
/**** However, there are certainly cases where this simple method fails.   */

proveEvaRule( or(_F1,_F2) ) :-
  !,
  (proveEvaRule(_F1);proveEvaRule(_F2)).

proveEvaRule( exists(_savelits,_innerF) ) :-
  !,
  prove_literals(_savelits),
  proveEvaFormulaForRule_once(_innerF).

proveEvaRule(_F) :-
  proveEvaFormula(_F).


/** same as proveEvaFormula_once but will not generate error messages **/
proveEvaFormulaForRule_once(_F) :-
  proveEvaFormula(_F),
  !.



/** 23-Oct-2003: this call of proveEvaFormula is now utilizing the default cache  **/
/** mode (usually 'transient') instead of 'off'. The mode is set to 'off' at TELL **/
/** and UNTELL transactions because the extension of literals changes during      **/
/** insertion of new objects.                                                     **/
/** When the cache mode is 'off' any evaluation of a recursive literal can crash  **/
/** the server via an infinite loop. To cure this, we set the cache mode to its   **/
/** default before we evaluate the formuala. This might have to be extended to    **/
/** proveEvaRule as well. But we keep that for the time when it is really needed. **/
/** After formula evaluation, we erase the cached facts since they are only valid **/
/** for the time point where they were evaluated. Note that the TELL operation    **/
/** might insert new objects.                                                     **/
/** See also Ticket #13 (23-Oct-2003). M. Jeusfeld                                **/

/** success case: if _F can be proven once then _F is true and the concerned      **/
/** integrity constraint is not violated in this case.                            **/

proveEvaFormula_once(_F) :-
  proveEvaFormula(_F),
  !.

/** failure cases:                                                                **/
/** 25-Apr-2005/M.Jeusfeld: error messages IC_NOTSAT used to be attached to the   **/
/** forall and implies cases of proveEvaFormula. This caused some wrong error     **/
/** messages to be generated (see ticket #63). To avoid this, we only generate    **/
/** error messages for proveEvaFormula_once. This should solve ticket #63.        **/

proveEvaFormula_once( forall(_lits,_F) ) :-
  prove_literals(_lits),  /** to bind violator variables in _F **/
  \+ proveEvaFormula(_F),
  simplifyEva(_F,_Fs),   
  report_error( 'IC_NOTSAT', 'BDMEvaluation', [formula(_lits),formula(_Fs)]),
  !,
  fail.

proveEvaFormula_once( implies(_lits,_F) ) :-
  prove_literals(_lits),  /** to bind violator variables in _F **/
  simplifyEva(_F,_Fs),
  report_error( 'IC_NOTSAT', 'BDMEvaluation', [formula(_lits),formula(_Fs)]),
  !,
  fail.

/** catchall for error message except the trivial FALSE formula **/
proveEvaFormula_once(_F) :-
  _F \== 'FALSE',
  simplifyEva(_F,_Fs),
  report_error( 'IC_NOTSAT1', 'BDMEvaluation', [formula(_Fs)]),
  !,
  fail.


 

