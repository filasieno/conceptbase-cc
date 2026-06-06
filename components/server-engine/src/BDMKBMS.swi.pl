%
% The ConceptBase.cc Copyright
%
% Copyright 1987-2020 The ConceptBase Team. All rights reserved.
%
% Redistribution and use in source and binary forms, with or without modification, are permitted
% provided that the following conditions are met:
%
%    1. Redistributions of source code must retain the above copyright notice, this list of
%       conditions and the following disclaimer.
%    2. Redistributions in binary form must reproduce the above copyright notice, this list of
%       conditions and the following disclaimer in the documentation and/or other materials
%       provided with the distribution.
%
% THIS SOFTWARE IS PROVIDED BY THE CONCEPTBASE TEAM ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
% INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
% PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE CONCEPTBASE TEAM OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
% (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
% OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
% OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%
% The views and conclusions contained in the software and documentation are those of the authors
% and should not be interpreted as representing official policies, either expressed or implied,
% of the ConceptBase Team.
%
%
% The ConceptBase Team is represented by
%
% Manfred Jeusfeld, University of Skovde, 54128 Skovde, Sweden
% Matthias Jarke, RWTH Aachen, Informatik 5, Ahornstr. 55, 52056 Aachen, Germany
% Christoph Quix, RWTH Aachen, Informatik 5, Ahornstr. 55, 52056 Aachen, Germany
%
%
% This license is a FreeBSD-style copyright license.
% Legal home of the FreeBSD copyright license: http://www.freebsd.org/copyright/freebsd-license.html
%
%
%
% File:         %M%
% Version:      %I%
%
%
% Date released : %E%  (YY/MM/DD)
%
% SCCS-Source-Pool : %P%
% Date retrieved : %D% (YY/MM/DD)
% -----------------------------------------------------------------------------
%
% This module is part of the BDMIntegrityChecker and
% is responsible for the management of those prolog-predicates
% that contain evaluable formulas (wellknown as BDMFormulaPredicates).
%
%
%
% Exported predicates:
% --------------------
%
%   + store_BDMFormula/1
%
%   + retrieve_BDMFormula/1
%
%   + retrieve_BDMFormula_once/1
%
%   + mk_permanent_BDMFormula/2
%
%   + rm_temp_BDMFormula/0
%
%   + change_BDMFormula/2
%
%   + delete_BDMFormula/1
%
% Meta-formula changes (10.1.96):
%
% changed: change_BDMFormula
% A trigger can be generated within a transaction and then changed.
%
% mk_permanent_BDMFormula:
% ternary, no longer binary
% a list of formulas to delete and a list of formulas to insert are passed
% Reason:
% use of change_BDMFormula:
% Changing a BDM formula is done by deleting the old formula
% and entering the new one.
% This was not completely implemented before integration of metaformulas:
% on TELL only insertions were considered, on UNTELL only deletions
%
% is_trigger
% new triggers added
%
%
% 05-Dec-1996 LWEB
%  The triggers 'applyConstraintIfInsert@BDMCompile' and 'applyConstraintIfDelete@BDMCompile'
%  and 'origConstraint@BDMCompile'
%  were extended by one slot. This slot contains the _id of the Telos constraint object. It serves
%  for checking whether the constraint associated with the trigger is visible in the current module context.
%

:- module('BDMKBMS',[
'change_BDMFormula'/2
,'delete_BDMFormula_once'/1
,'delete_BDMFormulas'/1
,'delete_all_BDMFormulas'/1
,'load_BDMFormula'/1
,'mk_permanent_BDMFormula'/3
,'retrieve_BDMFormula'/1
,'retrieve_BDMFormula_once'/1
,'retrieve_backup_BDMFormula'/1
,'rm_temp_BDMFormula'/0
,'store_BDMFormula'/1
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').
:- use_module('GeneralUtilities.swi.pl').
%  declare the trigger-predicates as dynamic encapsulated in this module
%

:- dynamic 'perm_trigger'/1 .
:- dynamic 'temp_trigger'/1 .
:- dynamic 'backup_trigger'/1 .
:- style_check(-singleton).
% ***********************************************************************
%
% ************      S   U   B   M   O   D   U   L   E      **************
%
%
%    BBBB   DDDD   M   M   FFFFF   OOO   RRRR   M   M  U   U   L        A
%    B   B  D   D  MM MM   F      O   O  R   R  MM MM  U   U   L       A A
%    BBBB   D   D  M M M   FFFF   O   O  RRRR   M M M  U   U   L      AAAAA
%    B   B  D   D  M   M   F      O   O  R  R   M   M  U   U   L      A   A
%    BBBB   DDDD   M   M   F       OOO   R   R  M   M   UUU    LLLLL  A   A
%
%
%  There are various predicates for storing BDM formulas.
%  The time-critical predicates:
%    'applyConstraintIfInsert@BDMCompile'
%      ( _icId, _ClassId, _SimpIcId, _Literal, _IcFormSimplMerged),
%    'applyConstraintIfDelete@BDMCompile'
%      ( _icId, _ClassId, _SimpIcId, _Literal, _IcFormSimplMerged),
%    'applyRuleIfInsert@BDMCompile'
%      ( _RuleId, _ClassId, _SimpRuleId, _Literal, _RuleConcl,_RuleCondMerged,
%        _ListOfSimpRuleIds, _ListOfSimpIcIds),
%    'applyRuleIfDelete@BDMCompile'
%      (_RuleId,  _ClassId, _SimpRuleId, _Literal, _RuleConcl,_RuleCondMerged,
%        _ListOfSimpRuleIds, _ListOfSimpIcIds).
%  And the remaining predicates:
%    'origConstraint@BDMCompile'( _idIc, _OrigIcId, _IcFormulaMerged),
%    'origRule@BDMCompile'( _RuleId, _RuleConcl,
%                           _RuleCondFormMerged, _ruleinfo).
%
%
%  The following predicates provide access:
%       store_BDMFormula( _BDMFormulaPredicate)
%       retrieve_BDMFormula( _BDMFormulaPredicate)
%       retrieve_BDMFormula_once( _BDMFormulaPredicate)
%       change_BDMFormula( _BDMFormulaPredicate_old, _BDMFormulaPredicate_new)
%       mk_permanent_BDMFormula( _ListOfBDMFormulaPredicates, _mode)
%       rm_temp_BDMFormula
%       delete_BDMFormula( _BDMFormulaPredicate)
%
%  Internally the helper predicates
% 	'temp_trigger'
% 	'backup_trigger'
%        'perm_trigger'
%  are used; they are not accessible from outside.
%
%
% ***********************************************************************
% ***********************************************************************
%
%  store_BDMFormula( _BDMFormulaPredicate)
%
%  When a new predicate is stored that contains a BDM formula, then
%  this may only happen temporarily at first. It must be deletable again
%  leave it, if the transaction on the basis of which the new BDM formula was created
%  was not accepted.
%
% ***********************************************************************

store_BDMFormula(_BDMFormulaPredicate) :-
	assert(temp_trigger( _BDMFormulaPredicate)),
	'WriteTrace'(veryhigh,'BDMKBMS',[store_BDMFormula,' :: ',idterm(_BDMFormulaPredicate)]),
	!.
% *******************************************************
%  load_BDMFormula( _BDMFormulaPredicate)
%
%  Triggers are currently stored in OB.rule.
%  load_BDMFormula/1 remembers the trigger in the Prolog
%  database.
% *******************************************************

load_BDMFormula(_BDMFormulaPredicate) :-
	is_trigger(_BDMFormulaPredicate),
	assert(perm_trigger( _BDMFormulaPredicate)),
	!.
load_BDMFormula(_BDMFormulaPredicate) :-
	is_legacy_trigger(_BDMFormulaPredicate,_BDMFormulaPredicateNew),  % ticket #303
	assert(perm_trigger( _BDMFormulaPredicateNew)),
	'WriteTrace'(low,'BDMKBMS',['Legacy trigger trigger detected, ',
                                'consider recompiling the database from its sources. ']),
	!.
% ***********************************************************************
%
%  retrieve_BDMFormula( _BDMFormulaPredicate)
%
%  This is the access interface to the internally stored predicates
%  that contain BDM formulas. Either such a predicate is still stored
%  temporarily, or already permanently.
%
% ***********************************************************************

retrieve_BDMFormula(_BDMFormulaPredicate) :-
	perm_trigger(_BDMFormulaPredicate)
	;
	temp_trigger( _BDMFormulaPredicate).
% *******************************************************
%
%  retrieve_backup_BDMFormula( _BDMFormulaPredicate)
%
%  accesses the backup copy of a trigger. It is placed in
%  BDMEvaluation needed.
%
% *******************************************************

retrieve_backup_BDMFormula(_BDMFormulaPredicate) :-
	backup_trigger(_BDMFormulaPredicate).
% ***********************************************************************
%
%  retrieve_BDMFormula_once( _BDMFormulaPredicate)
%
%  This is the access interface to the internally stored predicates
%  that contain BDM formulas. Either such a predicate is still stored
%  temporarily, or already permanently.
%  Here only the first solution is sought, which makes sense with an instantiated
%  formula identifier, since there can only be one solution.
%
% ***********************************************************************

retrieve_BDMFormula_once(_BDMFormulaPredicate) :-
	retrieve_BDMFormula(_BDMFormulaPredicate),
	!.
% ***********************************************************************
%
%  change_BDMFormula( _BDMFormulaPredicate_old, _BDMFormulaPredicate_new)
%
%  If a BDM predicate is changed, this may only happen temporarily.
%
% ***********************************************************************

change_BDMFormula(_old,_new) :-
	assert( temp_trigger(_new)),
	do_change_BDMFormula(_old,_new),
	'WriteTrace'(veryhigh,'BDMKBMS',[change_BDMFormula,' :: ',idterm(_old),' -> ', idterm(_new)]),
	!.

do_change_BDMFormula( _BDMFormulaPredicate_old, _BDMFormulaPredicate_new) :-
	%  Was the trigger already in ConceptBase before the transaction:

	perm_trigger( _BDMFormulaPredicate_old),
	!,
	%  Yes, therefore it must be deleted and remembered:
% 	write(assert(backup_trigger(_BDMFormulaPredicate_old))),nl,

	assert(backup_trigger(_BDMFormulaPredicate_old)),
% 	write(retract(perm_trigger(_BDMFormulaPredicate_old))),nl,nl,

	retract(perm_trigger(_BDMFormulaPredicate_old))
% 	,write(retract(perm_trigger(_BDMFormulaPredicate_old))),nl,nl

.
do_change_BDMFormula( _BDMFormulaPredicate_old, _BDMFormulaPredicate_new) :-
	%  if the predicate was temporarily generated, then no backup trigger may be
	% 	   created, because only triggers that were in ConceptBase before the
	% 	   transaction may be restored

	retract(temp_trigger( _BDMFormulaPredicate_old)),
% 	write(retract(temp_trigger( _BDMFormulaPredicate_old))),nl,nl,

	!.
% ***********************************************************************
%
%  mk_permanent_BDMFormula( _ListOfBDMPredicates1,_ListOfBDMPredicates2,_mode)
%
%  If a transaction is accepted, all temporarily created by it must
%  created objects must now be made permanent and all temporarily
%  deleted objects must be permanently deleted.
%
%
% ***********************************************************************

mk_permanent_BDMFormula( _ListOfBDMPredicatesInserted, _ListOfBDMPredicatesDeleted,tell) :-
	findall( _BDMPredicateIns, temp_trigger( _BDMPredicateIns), _ListOfBDMPredicatesInserted),
% 	write('inserted: '),write(_ListOfBDMPredicatesInserted),nl,nl,

	mk_permanent_BDMFormula_i(_ListOfBDMPredicatesInserted),
	findall( _BDMPredicateDel, backup_trigger( _BDMPredicateDel), _ListOfBDMPredicatesDeleted)	,
% 	write('deleted: '),write(_ListOfBDMPredicatesDeleted),nl,nl,

	mk_permanent_BDMFormula_d(_ListOfBDMPredicatesDeleted).
mk_permanent_BDMFormula( _ListOfBDMPredicatesDeleted, _ListOfBDMPredicatesInserted,untell) :-
	mk_permanent_BDMFormula( _ListOfBDMPredicatesInserted, _ListOfBDMPredicatesDeleted,tell).

mk_permanent_BDMFormula_i([]).
mk_permanent_BDMFormula_i([_trigger|_triggers]):-
	retract(temp_trigger( _trigger)),
% 	write(assert(perm_trigger(_trigger))),nl,nl,

	assert(perm_trigger(_trigger)),
	mk_permanent_BDMFormula_i(_triggers).

mk_permanent_BDMFormula_d([]).
mk_permanent_BDMFormula_d([_trigger|_triggers]):-
	retract(backup_trigger(_trigger)),
	mk_permanent_BDMFormula_d(_triggers).
% ***********************************************************************
%
%  rm_temp_BDMFormula
%
%  If a transaction is rejected, all objects temporarily created by it must
%  created objects are now deleted. This is done here with
%  the predicates that contain BDM formulas.
%
% ***********************************************************************
%  Rollback of a transaction:
%  First delete all temporary triggers

rm_temp_BDMFormula :-
	temp_trigger( _BDMFormulaPredicate),
	retract( temp_trigger( _BDMFormulaPredicate)),
	fail.
%  Make all old triggers valid again

rm_temp_BDMFormula :-
	backup_trigger( _BDMFormulaPredicate),
	retract(backup_trigger( _BDMFormulaPredicate)),
	assert(perm_trigger(_BDMFormulaPredicate)),
	fail.
%  ... and end

rm_temp_BDMFormula :-
	!.
% ***********************************************************************
%
%  delete_BDMFormula( _BDMFormulaPredicate)
%
%  When UNTELLing an integrity constraint or rule, some associated-
%  associated BDM formula predicates deleted.
%
% ***********************************************************************

delete_BDMFormulas([]).
delete_BDMFormulas([_t|_ts]) :-
	delete_BDMFormula(_t),
	delete_BDMFormulas(_ts).

delete_BDMFormula_once(_BDMFormulaPredicate) :-
	delete_BDMFormula(_BDMFormulaPredicate),
	!.

delete_BDMFormula( _BDMFormulaPredicate) :-
		%  For complete instantiation:

	perm_trigger(_BDMFormulaPredicate),!,
		%  Delete the predicate

	retract( perm_trigger(_BDMFormulaPredicate)),
		%  ... and cache until the end of UNTELL:

	assert( backup_trigger( _BDMFormulaPredicate)),
        'WriteTrace'(veryhigh,'BDMKBMS',[delete_BDMFormula,' :: ',
                                     idterm(_BDMFormulaPredicate)]).
delete_BDMFormula( _BDMFormulaPredicate) :-
		%  For complete instantiation:

	is_ProcedureTrigger(_BDMFormulaPredicate),
	temp_trigger(_BDMFormulaPredicate),
	%  if the predicate was temporarily generated, then no backup trigger may be
	% 	   created, because only procedure triggers that were in ConceptBase before
	% 	   the transaction may be restored

	retract( temp_trigger(_BDMFormulaPredicate)),
        'WriteTrace'(veryhigh,'BDMKBMS',[delete_BDMFormula,' :: ',
                                     idterm(_BDMFormulaPredicate)]).

delete_all_BDMFormulas(_BDMFormulaPredicate) :-
	(delete_BDMFormula(_BDMFormulaPredicate),fail)
	;
	true.

is_trigger(_BDMFormula) :-  % 26-May-1995 LWEB
	functor(_BDMFormula,_x,_arity),
	member((_x,_arity),[
					('applyConstraintIfInsert@BDMCompile',5),
					('applyConstraintIfDelete@BDMCompile',5),
					('applyRuleIfInsert@BDMCompile',7),
					('applyRuleIfDelete@BDMCompile',7),
					('origConstraint@BDMCompile',3),
					('origRule@BDMCompile',4),
					('applyPredicateIfInsert@BDMCompile',4),
	   				('applyPredicateIfDelete@BDMCompile',3)]).
%  deal with old OB.rule files that have old trigger formats
%  ticket #303

is_legacy_trigger('applyRuleIfInsert@BDMCompile'(_1,_2,_3,_4,_5,_6),
                  'applyRuleIfInsert@BDMCompile'(_,_1,_2,_3,_4,_5,_6)).	
is_legacy_trigger('applyRuleIfDelete@BDMCompile'(_1,_2,_3,_4,_5,_6),
                  'applyRuleIfDelete@BDMCompile'(_,_1,_2,_3,_4,_5,_6)).				

is_ProcedureTrigger(_BDMFormula) :-
	functor(_BDMFormula,_x,_arity),
	member((_x,_arity),[
           	('applyPredicateIfInsert@BDMCompile',4),
	   	('applyPredicateIfDelete@BDMCompile',3)]).
