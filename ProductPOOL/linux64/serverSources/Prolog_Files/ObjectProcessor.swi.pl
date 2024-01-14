/**
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
**/
/*
*
* File:        ObjectProcessor.pro
* Version:     11.6
*
*
* Date released : 97/03/20  (YY/MM/DD)
*
* SCCS-Source-Pool : /home/CBase/CB_NewStruct/ProductPOOL/serverSources/Prolog_Files/SCCS/s.ObjectProcessor.pro
* Date retrieved : 97/04/25 (YY/MM/DD)
*
* -----------------------------------------------------------------------------
*
* This Prolog module is part of the ConceptBase system which is a run-time
* system for the System Modelling Language (SML).
* The ObjectProcessor provides an interface for manipulating frame-like
* representations of objects.
*
* 1-Aug-1988/MJf: Introduction of select expressions for ask_objproc
* 24-Jan-1989/MSt: Extension of tell_obj/2 --> tell_obj/3
* (02-Feb-1989/MSt)Integration of PROLOGruleProcessor
* 7-Aug-1989/AM : Change of make_temp_propositions_permanent for correctness
*                 reasons in presence of literals
* 19-Dec-1989/TW : big change:
*                  Integration of valid time and transaction time.
* 19-Jan-1990/EK+MJf
*   Version 2 of BDM-Integrity-Checker integrated; provides permanent storage
*   of BDM code and checking of UNTELL
* 02-03-90/MSt : new ask_objproc/3 for historical queries
*                searchspace is set for tell,untell,ask by set_KBsearchSpace/2
*
* 07-90/MSt :	 Integration of new query language: activate QueryTriggers,
*		 store/remove code of compiled queries
*
*
* 26.07.1990 RG:	Changes to support the new proposition/6 form.
*
* 21-08-90/MSt :  searchspace persistentKB for all queries with RBtime <> Now
*		  wholeKB for all others
*
* 8-Aug-1991/AM : close_transactiontime adapted for lists of
*                 transaction time intervals.
*
* 10-1-96 (RS):
*  Metaformel- Aenderungen:
*  Es werden zwei Listen von Klauseln verwaltet,
*  eine beinhaltet die Objekte, die hinzugefuegt werden sollen,
*  eine die Objekte, die geloescht werden sollen.
*
*  Hintergrund:
*  Fuer die Prozedurtrigger der Metaformeln gilt, dass
*  bei TELL Trigger hinzugefuegt, aber auch geloescht werden
*  Die alte Version unterstuetzte beim TELL nur das
*  Hinzufuegen, nicht aber das Loeschen von Triggern.
*
*
*  Jun-97 Retell-Operation wird realisiert.
*
*/

/*:- setdebug.*/



:- module('ObjectProcessor',[
'ask_objproc'/2
,'ask_objproc'/3
,'d_export'/1
,'d_import'/1
,'do_tell'/1
,'do_untell'/1
,'flag_deacktive_transactiontime'/0
,'i_export'/1
,'i_import'/1
,'remove_temp_exports_imports'/0
,'remove_temporary_information'/0
,'retell_objproc'/3
,'tell_objproc'/2
,'tell_tmp_objproc'/2
,'untell_objproc'/2
,'check_insert_import_relationship'/1
,'checkUpdate'/1
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').


:- use_module('ObjectTransformer.swi.pl').
:- use_module('SelectExpressions.swi.pl').
:- use_module('QueryProcessor.swi.pl').
:- use_module('GeneralUtilities.swi.pl').



:- use_module('PropositionProcessor.swi.pl').








:- use_module('PROLOGruleProcessor.swi.pl').



:- use_module('QueryCompiler.swi.pl').



:- use_module('BDMIntegrityChecker.swi.pl').


:- use_module('SemanticIntegrity.swi.pl').
:- use_module('TransactionTime.swi.pl').

:- use_module('SearchSpace.swi.pl').

:- use_module('WeakPersistency.swi.pl').
:- use_module('ModelConfiguration.swi.pl').
:- use_module('GlobalParameters.swi.pl').




:- use_module('Literals.swi.pl').

:- use_module('BIM2C.swi.pl').



:- use_module('ViewMonitor.swi.pl').

:- use_module('ViewCompiler.swi.pl').

:- use_module('TellAndAsk.swi.pl').
:- use_module('RuleBase.swi.pl').






:- use_module('PrologCompatibility.swi.pl').



:- use_module('ECAruleManager.swi.pl').

:- use_module('ExternalConnection.swi.pl').








:- dynamic 'i_import'/1 .
:- dynamic 'i_export'/1 .
:- dynamic 'd_import'/1 .
:- dynamic 'd_export'/1 .
:- dynamic 'factor_ins'/1 .
:- dynamic 'factor_del'/1 .
:- dynamic 'flag_deacktive_transactiontime'/0 .


:- style_check(-singleton).



/* =================== */
/* Exported predicates */
/* =================== */


/* ****************** t e l l _ o b j p r o c ******************* */
/*                                             22-Jun-1988/MJf    */
/*                                             24-Jan-1988/MSt    */
/*                                              1-Feb-1989/MSt    */
/* tell_objproc(_listofSMLfragments,_completion)                  */
/*   _listofSMLfragments: ground,list                             */
/*   _gencode : any: OBSOLETE                                     */
/*   _completion : free : error,noerror                           */
/*                                                                */
/* This procedure takes each entry of _listofSMLfragments and     */
/* stores it temporarily in the PropositionProcessor. Then, the   */
/* integrity of the whole new information is checked. If no       */
/* errors are found the created propositions are made permanent.  */
/* Otherwise, they are retracted (as in tell_objproc).            */
/* If any error is encountered, then 'tell_obproc' reports this   */
/* by _completion=error otherwise _completion=noerror.            */
/* After consolidating it tell_objproc/3 should replace           */
/* tell_objproc/1.                                                */
/*                                             03-Aug-1988/MJf    */
/*                                             02-Feb-1989/MSt    */
/* For the check of SML-integrity, now checkintegrity/2 with      */
/* first argument 'tell' is called                                */
/*                                                                */
/* ************************************************************** */



tell_objproc(	_listofSMLfragments,
             	noerror)	:-

	pc_time( do_tell(_listofSMLfragments), _T),
        'WriteListOnTrace'(high,['   ... ',_T, ' sec used for telling']),
	!.

/* Behandlung  des Fehlschlags einer TELL-Operation */
tell_objproc(_,error) :-
	remove_temp_exports_imports,
  	remove_transaction_time,
  	remove_temporary_information,
        'WriteListOnTrace'(low,['   ... [2] temporary information retracted\n']),
	!.





/* ************ do_tell ******************* */
/*                                                                  */
/* **************************************************************** */

do_tell(_listofSMLfragments) :-
	ground(_listofSMLfragments),
 	set_KBsearchSpace(newOB,'Now'),
	/* Speichere aus der TELL-Operation einzufuegende Objekte temporaer ab */
  	do_store_tmp(_listofSMLfragments,_deferredactions,_deferredrules),			/* neu: ohne IC-Check */

	insert_import_relationships,		/* LWEB : warte die Import/Export Mengen der Module */
	insert_export_relationships,
        
        /** add the deferred actions and rules to the ECA execution queue **/
        addlist_ECA_ExecutionQueue(_deferredactions),   /** see also ticket #93 **/
        addlist_ECA_ExecutionQueue(_deferredrules),
	! .


tell_check(noerror) :-
	set_KBsearchSpace(newOB,'Now'),
	pc_time(checkIntegrity(tell,_errno2),_T2),
        'WriteListOnTrace'(low,['   ... semantic integrity for Tell checked (',
                              _errno2, ' error(s), ',
                              _T2, ' sec used)']),

        writeTriggerCalls(tell_check),

  	_errno2 = 0,

	!,

	generate_additional_vm_rules,
	retractall(i_import(_)),
	retractall(i_export(_)),

  	store_perm_PROLOGrules(_listofclausesA),
	(
		(if_exist_view,                  /* pruefe ob ein view existiert*/
		findLTevalRules_ins(_listofclausesA,_listofLTevalRules),
		findall_deduced_factor(_listofLTevalRules,_listofnewfactors),
		!
		);
		true  /* falls kein view existiert, mache nichts*/
	),
  	store_perm_QueryRules(_listofClausesC),
	!,
	start_view_maintenance(tell,_listofnewfactors,[]),

	insert_commit_bim2c,
  	mk_permanent_BDMFormulas( _listofclausesB, _listOfClausesToDelete,tell),
  	append( _listofclausesA, _listofclausesB, _list),
  	append( _list,_listofClausesC,_listofclauses),

	makeTmpRuleInfosPerm,

	remove_transaction_time,
  	!,
	((application_active,
   	  get_cb_feature('UpdateMode',persistent),
      pc_time( 'SAVE'(generatedcode(_listofclauses,_listOfClausesToDelete), tell), _T1),
          'WriteListOnTrace'(high,['   ... ',_T1, ' sec used for persistently storing'])
   	 );
   	 true
 	),
  	!.

tell_check(error).


do_store_tmp(_listofSMLfragments,_defactions,_defrules) :-
  	ground(_listofSMLfragments),
  	set_KBsearchSpace(newOB,'Now'),                  		/*02-03-90 MSt*/
  	pc_time(store_Objects(_listofSMLfragments, _defactions,_defrules, _errno1),_T1),
        'WriteListOnTrace'(low,['   ... stored temporarily (',_errno1,' error(s), ',
                             _T1, ' sec used)']),
  	_errno1 = 0,
  	!.

writeTriggerCalls(_case) :-
        ruleTriggerCalls(_rtrigs),
        constraintTriggerCalls(_ictrigs),
        'WriteListOnTrace'(high,['   ... ',_case,': rule/constraint trigger calls ',_rtrigs, ' / ',_ictrigs]),
        !.



/* ************ t e l l _ t m p _ o b j p r o c ******************* */
/*                                                    08-03-90 MSt  */
/*                                                                  */
/*	tell_tmp_objproc ( _listofSMLfragments _ret )              */
/*		_listofSMLfragments : ground                       */
/*	        _ret : free                                        */
/*	                                                           */
/*	same as tell_objproc : fragments in _listofSMLfragments    */
/*	are told to the KB but not in a permanent representation.  */
/*	_ret is noerror in case of success, error otherwise.       */
/*	This predicate shall only be used for internal purposes    */
/*	not as an extern available procedure.                      */
/*	ATTENTION : Temporary information must(!) be deleted by    */
/*	delete_temporary_information/0 before(!) end of trans-     */
/*	action.                                                    */
/*                                                                  */
/* **************************************************************** */

  /* fuer QueyProcessor bei HypoAsk : keine ECA-Action Generierung ! */

tell_tmp_objproc(_listofSMLs,noerror) :-
	/* ersetze  Select-Expressions in den Fragments bereits hier.  LWEB */
	changeSMLs(_listofSMLs,_listofSMLfragments),
	pc_time( do_tell_tmp(_listofSMLfragments), _T),
        'WriteListOnTrace'(low,['   ... ',_T, ' sec used for telling temporarily']),
  	!.

tell_tmp_objproc(_,error) :-			/* Fail */
  	remove_temporary_information,
	remove_transaction_time,
        'WriteListOnTrace'(low,['   ... [3] temporary information retracted\n']),
  	!.


do_tell_tmp(_listofSMLfragments) :-
  	ground(_listofSMLfragments),
   	set_KBsearchSpace(newOB,'Now'),                  /*02-03-90 MSt*/
  	pc_time(store_Objects(_listofSMLfragments, _,_ ,_errno1),_T1),
        'WriteListOnTrace'(low,['   ... stored temporarily (',
                              _errno1, ' error(s), ',
                              _T1, ' sec used)']),
  	_errno1 = 0,
  	pc_time(checkIntegrity(tell,_errno2),_T2),
        'WriteListOnTrace'(low,['   ... semantic integrity checked (',
                              _errno2, ' error(s), ',
                              _T2, ' sec used)']),

        writeTriggerCalls(do_tell_tmp),

  	_errno2 = 0,

  !.

do_tell_tmp(_listofSMLfragments) :-
	insert_abort_bim2c,
   	remove_temporary_information,
	fail.






/* ******************* a s k _ o b j p r o c ******************** */
/*                                                                */
/*                                                 02-03-90 MSt   */
/* ask_objproc(_question,_answer)                                 */
/*   _question: partial                                           */
/*   _answer: free                                                */
/*                                                                */
/* ask_objproc(_question,_RollBacktime,_answer)                   */
/*   _question: partial                                           */
/*   _answer: free                                                */
/*   _RollBackTime : ground                                       */
/*                                                                */
/* 'ask_objproc' is a very powerful procedure for querying the    */
/* knowledge base (seen as a collection of SML objects). The      */
/* first argument specifies the question and the second the       */
/* answer. If 'ask_objproc' can't find a positive solution, it    */
/* answers 'no'.                                                  */
/* 'ask_objproc' will NOT backtrack.                              */
/* 02-03-90 MSt : searchSpace is limited to persistentKB (i.e.    */
/*                no temp information is visible) and to          */
/*		 specified RollBackTime or 'Now' if there is no  */
/* 21-08-90 MSt : search space persistentKB only for queries with */
/*		 Rollback time unequal to Now. For all others    */
/*	         especially for hypothetical queries temporary   */
/*	         stored information is interesting too.          */
/*                                                                */
/* ************************************************************** */

ask_objproc(_question,_answer) :-
   ask_objproc(_question,'Now',_answer).  /*default rollback time is Now*/

ask_objproc(_question,'Now',_answer) :-
	!,
  	set_KBsearchSpace(newOB,'Now'),
  	pc_time(process_query(_question,_answer), _t1),
        'WriteListOnTrace'(low,['   ... ',_t1,' sec used to find the answer\n']),
	!.

ask_objproc(_question,_RollBacktime,_answer) :-
  	set_KBsearchSpace(currentOB,_RollBacktime),
  	pc_time(process_query(_question,_answer), _t1),
        'WriteListOnTrace'(low,['   ... ',_t1,' sec used to find the answer\n']),
  	!.


/* **************** u n t e l l _ o b j p r o c ***************** */
/*                                             19-Dec-1989/TW     */
/* untell_objproc(_listofSMLfragments,_completion)                */
/*   _listofSMLfragments: ground,list                             */
/*   _completion : free : error,noerror                           */
/*                                                                */
/* untell_objproc takes a list of SML-fragments and stores it     */
/* temporary in the proposition processor. The transaction times  */
/* of theese propositions are finished by the actual systemtime   */
/* then an integrity check for untelling is made, in order to     */
/* test the consistency of the KB after untelling. If no errors   */
/* detected, the temporary and the corresponding 'real' propo-    */
/* sitions are deleted and stored as history propvals. Otherwise  */
/* the 'temp'-propositions are removed.                           */
/*                                                                */
/* ************************************************************** */

untell_objproc(_listofSMLfragments,noerror) :-
	remove_del_exports_imports,

  	pc_time( do_untell(_listofSMLfragments), _T),
        'WriteListOnTrace'(high,['   ... ',_T,' sec used for untelling']),
  	!.

/* Fehlschlag UNTELL-Operation */
untell_objproc(_,error) :-
  	remove_abort_bim2c,
	remove_del_exports_imports,
 	remove_closed_RuleTTime,
 	rm_temp_BDMFormulas,
 	remove_transaction_time,
  	restore_QueryRules,
        'WriteListOnTrace'(low,['   ... [4] temporary information retracted\n']),
  	!.



do_untell(_listofSMLfragments) :-
  	ground(_listofSMLfragments),
 	set_KBsearchSpace(oldOB,'Now'),
	/* Loesche Objekte Temporaer */
 	pc_time(untell_Objects(_listofSMLfragments, _deferredactions, _deferredrules, _errno1),_T1),
        'WriteListOnTrace'(low,['   ... removed temporarily (',
                              _errno1, ' error(s), ',
                              _T1, ' sec used)']),
  	_errno1 = 0,

        /** add the deferred actions and rules to the ECA execution queue **/
        addlist_ECA_ExecutionQueue(_deferredactions),   /** see also ticket #93 **/
        addlist_ECA_ExecutionQueue(_deferredrules),

	/* Warte Menge der geloeschten Import/Export Attribute */
	delete_import_relationships,
	delete_export_relationships,
	!.

untell_check(noerror) :-
	set_KBsearchSpace(newOB,'Now'),
	pc_time(checkIntegrity(untell,_errno2),_T2),
        'WriteListOnTrace'(low,['   ... semantic integrity for Untell checked (',
                              _errno2, ' error(s), ',
                              _T2, ' sec used)']),

        writeTriggerCalls(untell_check),

  	_errno2 = 0,
	!,

	store_perm_PROLOGrules(_listofclausesA),
	(
	   (if_exist_view,							/* pruefe ob ein view existiert*/
		findLTevalRules_del(_listofclausesA,_listofLTevalRules),
		assert(flag_deacktive_transactiontime),					/*Die Rules werden vorher temperory deactiviert durch abgeschlossene */
		findall_deduced_factor(_listofLTevalRules,_listofoldfactorsA), 		/*Transactionszeit. Hier wird das Flag gestezt, dann wird die*/
		retract(flag_deacktive_transactiontime),				/*Transactionszeit nicht geprueft, waehrend der Ruleauswertung.*/
		remove_multiple_elements(_listofoldfactorsA,_listofoldfactors1),
		!
	   );
		true  /* falls kein view existiert, mache nichts*/
	),

	delete_perm_QueryRules(_listofclausesA2),				/*Die Factors aus geuntellten Querys werden in QueryComplier generiert,*/
	findall(_f,retract(factor_query(_f)),_listofoldfactors2),		/*und im Form factor_query(_f) gespeichert, _f ist _id(_l,_) oder In(_l,_id).*/
	append(_listofoldfactors1,_listofoldfactors2,_listofoldfactors),	/*_listofoldfactors ist alle Factors, die bzgl. ein View ausgenommen */
	!,										/*werden sollen.(aus geuntellten Querys und Rules)*/

	start_view_maintenance(untell,[],_listofoldfactors),
	remove_end_bim2c,
  	mk_permanent_BDMFormulas( _listofclausesB,_listOfClausesToInsert, untell),
	append( _listofclausesA, _listofclausesA2, _listofclauses1),
  	append(_listofclauses1,_listofclausesB,_listofclauses),

	get_transaction_time(_tr),
        'WriteListOnTrace'(low,['   ... transactiontime is: ', _tr]),
 	remove_transaction_time,
  	!,
 	(
	   (
		application_active,
   		get_cb_feature('UpdateMode',persistent),
  		pc_time( 'SAVE'(generatedcode(_listOfClausesToInsert,_listofclauses), untell), _T1),
                'WriteListOnTrace'(low,['   ... ',_T1, ' sec used for persistently storing'])
   	   );
   	    true
  	),
  	!.

untell_check(error).



/* ***** r e m o v e _ t e m p o r a r y _ i n f o r m a t i o n ******* */
/*                                                                       */
/*                                                        06-03-90 MSt   */
/* remove_temporary_information                                          */
/* temporary propositions, rules, BDMFormulas and time relations are     */
/* deleted.                                                              */
/*                                                                       */
/* ********************************************************************* */

remove_temporary_information :-
	insert_abort_bim2c,
	remove_tmp_PROLOGrules,
	remove_tmp_QueryRules,
	remove_tmpRuleInfos,
	retractall(factor_query),
	retractall(flag_deacktive_transactiontime),
	rm_temp_BDMFormulas.



/* ************************ RETELL-MAIN ************************** */
/* retell_objproc(_untell_frags,_tell_frags,_compl)                */
/* Untellt das erste Arg. und tellt das zweite Argument            */
/* und fuehrt dann Integrity Check durch.                          */
/* *************************************************************** */

retell_objproc(_fraglist_untell,_fraglist_tell,_compl):-
	pc_update(retellflag(untell)),
	retell_untell_objproc(_fraglist_untell,_),
	pc_update(retellflag(tell)),
	retell_tell_objproc(_fraglist_tell,_),
	retract(retellflag(tell)),
  	!.

retell_objproc(_,_,error) :-
	retract(retellflag(_)).

/* ************************ RETELL-UNTELL ************************ */
/* Aehnlich wie bei untell, aber Integritycheck und alles was      */
/* danach passiert werden in Retellcheck ausgefuehrt.              */
/* Zunaechst werden die Frames geuntellt (vgl. untell_objproc)     */
/* *************************************************************** */

retell_untell_objproc(_listofSMLfragments_untell,_) :-
	remove_del_exports_imports,
	pc_time( do_untell(_listofSMLfragments_untell),_T),
        'WriteListOnTrace'(high,['   ... ',_T,' sec used for untelling']),
	!.


/* Fehler bei retell_untell */
retell_untell_objproc(_,_) :-
  	remove_abort_bim2c,
	remove_del_exports_imports,
 	remove_closed_RuleTTime,
 	rm_temp_BDMFormulas,
 	remove_transaction_time,
  	restore_QueryRules,
	!,
	fail.





/* ************************ RETELL-TELL ************************** */
/* Aehnlich wie bei tell, aber Integritycheck und alles was        */
/* danach passiert werden in Retellcheck ausgefuehrt.              */
/* Zunaechst werden die Frames getellt (vgl. tell_objproc)         */
/* *************************************************************** */

retell_tell_objproc(_listofSMLfragments_tell,_) :-
 	pc_time( do_tell(_listofSMLfragments_tell), _T),
        'WriteListOnTrace'(high,['   ... ',_T,' sec used for telling']),
	!.


/* Fehler bei retell_tell */
retell_tell_objproc(_,_) :-
	remove_temp_exports_imports,
  	remove_transaction_time,
  	remove_temporary_information,
        'WriteListOnTrace'(low,['   ... [5] temporary information retracted\n']),
	!,
	fail.




/* ************************ RETELL-CHECK ************************* */
/* Hier wird Integrity gecheckt, wenn noerror, wird noch eine      */
/* Liste von getellten bzw. geuntellten Rules generiert,           */
/* dann wird alles gespeichert.                                    */
/* *************************************************************** */

retell_check(noerror):-
	set_KBsearchSpace(newOB,'Now'),
	pc_time(checkIntegrity(retell,_errno2),_T2),
        'WriteListOnTrace'(low,['   ... semantic integrity for Retell checked (',
                              _errno2, ' error(s), ',
                              _T2, ' sec used']),

        writeTriggerCalls(retell_check),

  	_errno2 = 0,
	!,
	generate_additional_vm_rules,
	retractall(i_import(_)),
	retractall(i_export(_)),
	remove_transaction_time,
  	store_perm_PROLOGrules(_listofclausesA_untell,retell_untell),
	(
		(if_exist_view,  /*pruef ob view existiert */
		findLTevalRules_del(_listofclausesA_untell,_listofLTevalRules_del),
		assert(flag_deacktive_transactiontime),
		findall_deduced_factor(_listofLTevalRules_del,_listofoldfactorsA),
		retract(flag_deacktive_transactiontime),
		remove_multiple_elements(_listofoldfactorsA,_listofoldfactors1),
		!
		);
		true /* falls kein view existiert, mache nichts*/
	),

  	delete_perm_QueryRules(_listofclausesA2_untell,retell_untell),
	findall(_f,retract(factor_query(_f)),_listofoldfactors2),
	append(_listofoldfactors1,_listofoldfactors2,_listofoldfactors),

  	mk_permanent_BDMFormulas( _listofclausesB_untell,_listOfClauseToInsert_untell, untell),

	append( _listofclausesA_untell, _listofclausesA2_untell, _listofclauses1_untell),
  	append(_listofclauses1_untell,_listofclausesB_untell,_listofclauses_untell),

  	store_perm_PROLOGrules(_listofclausesA_tell,retell_tell),
	findLTevalRules_ins(_listofclausesA_tell,_listofLTevalRules_ins),
	findall_deduced_factor(_listofLTevalRules_ins,_listofnewfactors),

  	store_perm_QueryRules(_listofClausesC_tell,retell_tell),

	!,
	start_view_maintenance(retell,_listofnewfactors,_listofoldfactors),

	remove_end_bim2c,
	insert_commit_bim2c,

  	mk_permanent_BDMFormulas( _listofclausesB_tell, _listOfClausesToDelete_tell,tell),
  	append( _listofclausesA_tell, _listofclausesB_tell, _list_tell),
  	append( _list_tell,_listofClausesC_tell,_listofclauses_tell),

	append(_listofclauses_untell,_listOfClausesToDelete_tell,_listOfClausesToDelete),
	append(_listofclauses_tell,_listOfClausesToInsert_untell,_listOfClausesToInsert),

	(
	   (
		application_active,
   		get_cb_feature('UpdateMode',persistent),
  		pc_time( 'SAVE'(generatedcode(_listOfClausesToInsert,_listOfClausesToDelete), retell), _T1),
                'WriteListOnTrace'(low,['   ... ',_T1,' sec  used for persistently storing'])
   	    );
   	    true
  	),
	!.

retell_check(error).




/*********************** ENDE RETELL ***********************************************/



/* ================== */
/* Private predicates */
/* ================== */


/** 13-May-2005/M.Jeusfeld: no longer used
close_transactiontime(hP(_id,_s,_l,_d,tt(_t1)),
                      hP(_id,_s,_l,_d,tt(_t1,_t2))) :-
  get_transaction_time(_t2),
  !.
close_transactiontime(_p,_p).
**/



/* ************ changeSMLs ******************* */
/*                                                                  */
/* **************************************************************** */

changeSMLs([],[]).						/* LWEB */
changeSMLs([_h|_t],[_ch|_ct])	:-
	changeIdentifierExp(_h,replaceSelectExpression,_ch),
	changeSMLs(_t,_ct).



/******************************************************************/
/*	Prozeduren zur Wartung der Import/Export Mengen 		*/
/******************************************************************/

insert_import_relationships	:-
	systemModuleDefined, /** only do this when the System module is fully defined **/
	callExactlyOnce((
			'M_SearchSpace'(_m),
			'Module'(_mid),
			'System'(_sid),
			retrieve_proposition(_sid,'P'(_id1,  _mid, imports, _mid ))
	)),
	retrieve_temp_ins(_m,'P'(_, _id2, '*instanceof', _id1)),
        \+ i_import(_id2),  /** neue imports-Deklaration **/
	callExactlyOnce((
		retrieve_temp_ins(_m,'P'(_id2, _m, _ , _n));
		retrieve_proposition(_m,'P'(_id2, _m, _ , _n ))
	)),
	id2name(_m,_mname),
        id2name(_n,_nname),
        'WriteTrace'(veryhigh,'ObjectProcessor',[' Asserting new Import Relationship: ',_mname,' imports ',_nname]),
	assert(i_import(_id2)),		/* merke neue import-Beziehung, falls Transaktion zurueckgesetzt wird */
	new_import(_id2),
	fail.

insert_import_relationships.


/** 22-Oct-2004/M.Jeusfeld: The procedure insert_import_relationships is being called after **/
/** all new P-tuples of a TELL-Transactions have been temporarily generated. That prevented **/
/** TELL transactions that imported from certain modules to use these imports during the    **/
/** same transaction. This is an undesired situation though it is possible to split the TELL**/
/** into two separate TELL transactions where the first one just performs the imports and   **/
/** the second one contains the frames that use the imports.                                **/
/** To make the module import more flexible, the imports-declarations are now processed on  **/
/** the fly during temporarily storing the new objects (procedure STORE in FragmentTo-      **/
/** Propositions). The new procedure check_insert_import_relationship(_p) just does this.   **/
/** The old procedure insert_import_relations is still called as before to be on the safe   **/
/** side. It checks the fact i_import to prevent double execution of an import.             **/
/** Note: The logic of check_insert_import_relation is not identical to the general         **/
/** insert_import_relationships. In particular the fact P(_id2,_m,_,_n) is                  **/
/** retrieved here only from the newly generated facts (retrieve_temp_ins). Hence, we do    **/
/** keep insert_import_relationships though it won't do anything in most of the cases since **/
/** check_insert_import_relationship has already done the job.                              **/

check_insert_import_relationship('P'(_,_n2,'*instanceof',_n1)) :-
        'M_SearchSpace'(_m),
        name2id(_n2,_id2),
        name2id(_n1,_id1),
        _id1 = id_1527,  /** id_1527=Module!imports **/
        importRel(_id1,_id2,_m,_n),
        'WriteTrace'(veryhigh,'ObjectProcessor',[' Asserting new Import Relationship: ',idterm(_m),' imports ',idterm(_n)]),
        assert(i_import(_id2)),         /* merke neue import-Beziehung */
        new_import(_id2),
        !.
check_insert_import_relationship(_).

importRel(_id1,_id2,_m,_n) :-
        retrieve_temp_ins(_m,'P'(_, _id2, '*instanceof', _id1)),
        retrieve_temp_ins(_m,'P'(_id2, _m, _ , _n)).




insert_export_relationships	:-
	systemModuleDefined, /** only do this when the System module is fully defined **/
	'M_SearchSpace'(_n),
	_id1 = id_1528, /** id_1528=Module!exports **/

	retrieve_temp_ins(_n,'P'(_, _id2, '*instanceof', _id1)),
	callExactlyOnce((
		retrieve_temp_ins(_n,'P'(_id2, _n, _ , _id));
		retrieve_proposition(_n,'P'( _id2, _n, _ , _id ))
	)),
	callExactlyOnce((
		retrieve_temp_module_tell(_,'P'(_id, _x, _l , _y));	/* 7-Jun-1995 LWEB */
		retrieve_proposition_noimport(_,'P'(_id, _x, _l , _y ))
	)),

	id2name(_n,_nname),
	'WriteTrace'(veryhigh,'ObjectProcessor',['Asserted new Export Relationship: ',_id2]),

	assert(i_export(_id2)),
	new_export(_id2),
	fail.
insert_export_relationships.



/*	Prozeduren um das Einfuegen/Loeschen von Import/Export-Beziehungen rueckgaengig zu machen */

remove_temp_exports_imports	:-		/* mache TELL rueckgaengig */
	retract(i_import(_id)),
	delete_import(_id),
	fail.
remove_temp_exports_imports	:-
	retract(i_export(_id)),
	delete_export(_id),
	fail.
remove_temp_exports_imports.


/*-----------------------------------------------------------*/
/* 5-Mar-1997 LWEB */
/* Die beiden folgenden Prozeduren speichern die ID's der aus dem aktuellen Modul durch ein UNTELL zu loeschenden */
/* import und export Beziehungen in zwei Fakten d_import/1 und d_export/1 ab. */

/* Diese Fakten werden von retrieve_temp/1 im PropositionProcessor.pro benoetigt  -  um geloeschte */
/* import/export Beziehungen in betroffenen Modulen sichtbar zu machen (siehe Technische Doku Modulserver) */

delete_import_relationships	:-
	'M_SearchSpace'(_m),
	_id1 = id_1527, /** id_1527=Module!imports **/

	retrieve_temp_del(_m,'P'(_, _id2, '*instanceof', _id1)),
	callExactlyOnce((
		retrieve_temp_del(_m,'P'(_id2, _m, _ , _n));
		retrieve_proposition(_m, 'P'( _id2, _m, _ , _n ))
	)),
	id2name(_m,_mname),
	'WriteTrace'(veryhigh,'ObjectProcessor',[' Delete Import Relationship: ',_id2]),

	assert(d_import(_id2)),
	fail.
delete_import_relationships.


delete_export_relationships	:-
	'M_SearchSpace'(_n),
	_id1 = id_1528, /** id_1528=Module!exports **/


		retrieve_temp_del(_n,'P'(_, _id2, '*instanceof', _id1)),
	callExactlyOnce((
		retrieve_temp_del(_n,'P'(_id2, _n, _ , _id));
		retrieve_proposition(_n, 'P'( _id2, _n, _ , _id ))
	)),
	callExactlyOnce((
		retrieve_temp_module_untell(_,'P'(_id, _x, _l , _y));	/* 7-Jun-1995 LWEB */
		retrieve_proposition_noimport(_,'P'(_id, _x, _l , _y))
	)),

	id2name(_n,_nname),
	'WriteTrace'(veryhigh,'ObjectProcessor',['Delete Export Relationship: ',_id2]),

	assert(d_export(_id2)),
	fail.

delete_export_relationships.


/* Loesche die nicht mehr benoetigten d_import / d_export Fakten */
remove_del_exports_imports	:-
	retract(d_import(_id)),
	fail.
remove_del_exports_imports	:-
	retract(d_export(_id)),
	fail.
remove_del_exports_imports.

/*-----------------------------------------------------------*/


findLTevalRules_ins([],[]):-!.					/* find all clauses(to be inserted or deleted) which with LTevalRule as first argument.*/

findLTevalRules_ins([_a|_b],[_kopf|_c]):-
	arg(1,_a,'LTevalRule'(_,_)),
	!,
	arg(1,_a,_kopf),
	findLTevalRules_ins(_b,_c).

findLTevalRules_ins([_a|_b],_c) :-
	findLTevalRules_ins(_b,_c).





findLTevalRules_del([],[]):-!.
findLTevalRules_del([_a|_b],['LTevalRule'(_id,'Adot'(_id,_s,_d))|_rest]):-
	_a='RuleTTime'(id(_id1,_),_),
	clause('LTevalRule'(_id,'Adot'(_id,_s,_d)),(_term,_)),			/*finde alle mit geuntellten Rule relevant LTevalRules. */
    createModTerm('RBTimeRelevantRule','LTstubs',id(_id1,_),_term),  /*man achtet, dir Rules werden nicht geloescht, sondern*/
	findLTevalRules_del(_b,_rest).						/*nur die Zeitintervale werden abgeschlossen.*/

findLTevalRules_del([_a|_b],['LTevalRule'(_id,'In'(_x,_id))|_rest]):-
	_a='RuleTTime'(id(_id1,_),_),
	clause('LTevalRule'(_id,'In'(_x,_id)),(_term,_)),
    createModTerm('RBTimeRelevantRule','LTstubs',id(_id1,_),_term),
	findLTevalRules_del(_b,_rest).



findall_deduced_factor([],[]):- !.				/*evaluate all LTevalRules*/

findall_deduced_factor([_a|_b],_c):-
	arg(2,_a,'Adot'(_id,_s,_d)),
	findall('Adot'(_id,_s,_d),'LTevalRule'(_id,'Adot'(_id,_s,_d)),_sol),
	findall_deduced_factor(_b,_cc),
	append(_sol,_cc,_c).

findall_deduced_factor([_a|_b],_c):-
	arg(2,_a,'In'(_x,_id)),
	findall('In'(_x,_id),'LTevalRule'(_id,'In'(_x,_id)),_sol),
	findall_deduced_factor(_b,_cc),
	append(_sol,_cc,_c).




/*********************************************************************/
/*                                                                   */
/* checkUpdate(_errflag)                                             */
/*                                                                   */
/* Description of predicate:                                         */
/*  Fuehrt den IntegrityCheck aus, dabei wird kontrolliert ob        */
/*  ein Tell-, Untell- oder Retell-Check durchgefuehrt werden muss   */
/*  in Abhaengigkeit von dem temporaeren Bereichen.                  */
/*********************************************************************/

checkUpdate('noerror') :-
  currentCheckUpdateMode('NO'),  /** we are sure that the current transaction had NO persistent updates **/
  checkToEnableCacheAfterUpdate,  
  remove_tmp_infos,            /** remove any temporarily told object **/
  !.

checkUpdate(_err) :-
  classifyUpdate(_op),
  setCacheInvalid,
  checkToEnableCacheAfterUpdate,   /** 27-Oct-2003/M.Jeusfeld: re-enable cache as soon as possible **/
  do_checkUpdate(_err,_op),  /** type of update determines check operation **/
  rollbackOnError(_err,_op). /** and rollback procedure as well            **/

checkUpdate('noerror').  /** never fail **/


/** We need to classify the update explicitely. The retell_flag is  **/
/** only set if we have an explicit RETELL-Operation. However, any  **/
/** update (even a query) can trigger ECA rules which can tell and  **/
/** untell objects. Hence, we just look whether there are both      **/
/** inserted and deleted objects to classify an update to be a      **/
/** 'retell'. Pure tell and untell operations are classified        **/
/** accordingly.                                                    **/

classifyUpdate('retell') :-
        retrieve_temp_ins(_),
        retrieve_temp_del(_),
        !.
classifyUpdate('tell') :-
        retrieve_temp_ins(_p),
        !.
classifyUpdate('untell') :-
        retrieve_temp_del(_),
        !.



/** to check a retell, we check if there was an integrity violation due **/
/** to the told objects, or the untold objects, or via the combination  **/
/** To only do a retell_check misses integrity violations when the      **/
/** retell was caused by ECA rules.                                     **/


/** there was an earlier error in the syntax checker or in **/
/** FragmentToPropositions, ticket #204                    **/
do_checkUpdate(error,_op) :-
    'error_number@F2P'(_n),
    _n > 0,
     !.


/** ticket #318: perform the dedicated retell-check for retell **/
do_checkUpdate(_err,'retell') :-
	retell_check(_err),
        !.
do_checkUpdate('error','retell').


/** check in case of 'tell' is pretty much standard **/
do_checkUpdate(_err,'tell') :-
	!,
	tell_check(_err).

/** check in case of 'untell' is pretty much standard **/
do_checkUpdate(_err,'untell') :-
	!,
	untell_check(_err).

do_checkUpdate(noerror,_op).


/* Behandlung  des Fehlschlags einer Update-Operation */
rollbackOnError('error','tell') :-
	remove_temp_exports_imports,
  	remove_transaction_time,
  	remove_temporary_information,
        'WriteListOnTrace'(low,['   ... told information retracted\n']),
	!.
rollbackOnError('error','untell') :-
  	remove_abort_bim2c,
	remove_del_exports_imports,
 	remove_closed_RuleTTime,
 	rm_temp_BDMFormulas,
 	remove_transaction_time,
  	restore_QueryRules,
        'WriteListOnTrace'(low,['   ... untold information recovered\n']),
  	!.

rollbackOnError('error','retell') :-
	(retract(retellflag(_));true),   /** retell_flag not always set! **/
        remove_abort_bim2c,
        remove_del_exports_imports,
        remove_closed_RuleTTime,
        rm_temp_BDMFormulas,
        remove_transaction_time,
        restore_QueryRules,
        remove_temp_exports_imports,
        remove_temporary_information,
        'WriteListOnTrace'(low,['   ... retold information undone\n']),
        !.
rollbackOnError(noerror,_) :-
	getModule(_mid),
        incrementModuleUpdateCount(_mid),
        'WriteListOnTrace'(low,['   ... confirmed in OB']),
        !.
rollbackOnError(_,_).


/** maintain the count of updating transactions to a given module _mid **/
incrementModuleUpdateCount(_mid) :-
  pc_recorded(_mid,'MODULE_UPDATES',_count),
  integer(_count),
  _newcount is _count + 1,
  pc_rerecord(_mid,'MODULE_UPDATES',_newcount),
  !.

incrementModuleUpdateCount(_mid) :-
  pc_record(_mid,'MODULE_UPDATES',1),
  !.


systemModuleDefined :-
  getFlag(missingObjects,'yes'),  /** set in Literals.pro **/
  !,
  fail.
systemModuleDefined.








