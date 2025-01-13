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
/**
*
* File:        LTstubs.pro
* Version:     11.2
*
*
* Date released : 96/12/09  (YY/MM/DD)
*
* SCCS-Source-Pool : /home/CBase/CB_NewStruct/ProductPOOL/SCCS/serverSources/Prolog_Files/s.LTstubs.pro
* Date retrieved : 97/07/03 (YY/MM/DD)
**************************************************************************
*
* <Description>
*
* 9-Dez-1996/LWEB:  RBTimeRelevantRule/1 wurde derartig erweitert, dass ein Rule nur
* dann als relevant angesehen wird, wenn es im aktuellen Modulkontext sichtbar ist.
**/



:- module('LTstubs',[
'deleteRuleId'/1
,'getRuleId'/1
,'storeRuleId'/1
,'untell_Rule'/1
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').

:- use_module('TransactionTime.swi.pl').

:- use_module('PropositionProcessor.swi.pl').
:- use_module('ObjectProcessor.swi.pl').
:- use_module('TellAndAsk.swi.pl').
:- use_module('GeneralUtilities.swi.pl').
:- use_module('validProposition.swi.pl').
:- use_module('PrologCompatibility.swi.pl').

:- use_module('PROLOGruleProcessor.swi.pl').



:- use_module('BIM2C.swi.pl').



:- style_check(-singleton).




/*************************************************************************/
/*                                                                       */
/*	untell_Rule (_id)                                               */
/*		_id : ground                                            */
/*	                                                                */
/*	performs necessary operations for untelling rule _id            */
/*                                                                       */
/*************************************************************************/

untell_Rule(_id) :-
	closeRuleTTime(_id).

/** from LTassertionTranslator **/



/*************************************************************************/
/*                                                                       */
/*	RBTimeRelevantRule (_id)                                        */
/*		_id : ground                                            */
/*                                                                       */
/* test wether rule with identifier _id is relevant for actual Rollback time.
_id is composed from the original rule identifier (propval with assertion string as label) and
an unique identifier for the compilation. So if a rule with original ID was told,untold and told
again without changing the rule text or deleting the assertion as object, we have RuleTTime(RD(ID,_id1),_t1)
and RuleTTime(RD(ID,_id2),_t2) as facts.
*/
/* 2-Sept-1996 LWEB   Check wether the rule with ID _id is visible in current module scope.  (retrieve_proposition(P(_id,_,_,_))) */
/*************************************************************************/


'RBTimeRelevantRule'(id(_id,_sid)) :-
	flag_deacktive_transactiontime.


'RBTimeRelevantRule'(id(_id,_sid)) :-
/*	getTTime(_id,_t),  not the ID of the rule */
	'RuleTTime'(id(_id,_sid),_t),			/* 2-Sept-1996 LWEB */
	correct_belieftime(_t),
	retrieve_proposition('P'(_id,_,_,_)).		/* 2-Sept-1996 LWEB */


getTTime(_id,_t) :-
	id2endtime(_id,'infinity'),
	!,
	id2starttime(_id,_t).

getTTime(_id,tt(_t1,_t2)) :-
	id2starttime(_id,tt(_t1)),
	id2endtime(_id,tt(_t2)).



/*************************************************************************/
/*                                                                       */
/*	closeRuleTTime (_id)                                            */
/*		_id : ground                                            */
/*                                                                       */
/*	belief time interval of rule with identifier _id is closed.     */
/*                                                                       */
/*************************************************************************/

closeRuleTTime(_id) :-
	retract('RuleTTime'(id(_id,_id2),tt(_t1))),
	get_transaction_time(_t2),
	(
	(retellflag(_),assert(tmp_rules_del(['RuleTTime'(id(_id,_id2),tt(_t1,_t2))])));
	assert(tmp_rules(['RuleTTime'(id(_id,_id2),tt(_t1,_t2))]))
	).


/** LTcodeGenerator **/

/*************************************************************************/
/*                                                                       */
/*          store/deleteRuleId(_id) / getRuleId(_nid)                    */
/*             _id : ground         /    _nid : free                     */
/*                                                                       */
/*  _id is identifier for call clause of produced PROLOGcode. Whenever a new identifier is needed ( call of getRuleId) it is constructed from the original stored _id and an ordinal number which depends on the number of already produced clauses. Stored identifiers can be deleted by deleteRuleId.
*/
/*************************************************************************/



storeRuleId(_id) :-
           assert(ruleId(_id,0)).


getRuleId(_cid) :-
           retract(ruleId(id(_id1,_id2),_oid)),!,
           _nid is _oid + 1 ,
           pc_inttoatom(_nid,_anid),
           pc_atomconcat('_',_anid,_aanid),
           pc_atomconcat(_id2,_aanid,_ccid),
           pc_atomconcat('ID_',_ccid,_cid),
           assert(ruleId(id(_id1,_id2),_nid)).

getRuleId(_cid) :-
          retract(ruleId(_id,_oid)),!,
          _nid is _oid + 1 ,
           pc_inttoatom(_nid,_anid),
           pc_atomconcat('_',_anid,_aanid),
           newIdentifier(_id2),
           pc_atomconcat(_id2,_aanid,_ccid),
           pc_atomconcat(_id,_ccid,_cid),
           assert(ruleId(_id,_nid)).


deleteRuleId(_id) :-
           retract(ruleId(_id,_cid)).


