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
% File:         BDMIntegrityChecker.pro
% Version:      11.2
%
%
% Date released : 96/12/09  (YY/MM/DD)
%
% SCCS-Source-Pool : /home/CBase/CB_NewStruct/ProductPOOL/SCCS/serverSources/Prolog_Files/s.BDMIntegrityChecker.pro
% Date retrieved : 97/07/08 (YY/MM/DD)
%
% -----------------------------------------------------------------------------
%
% This module is part of the BDMIntegrityChecker and
% is responsible for the adaption of all modules concerning the integrity
% checker to ConceptBase.
%
%
%
% Exported predicates:
% --------------------
%
%   + tell_BDMIntegrityConstraint/2
%       Takes the string of a new integrity constraint, transforms it
%       to the internal format and calls the processing of new ICs.
%
%   + tell_BDMRule/2
%       Takes the string of a new rule, transforms it
%       to the internal format and calls the processing of new rules.
%
%
%   + untell_BDMIntegrityConstraint/1
%       All objects depending on the untelled integrity constraint are
%       to untell too or to change.
%
%   + untell_BDMRule/1
%       All objects depending on the untelled rule are also
%       to untell or to change.
%
%
%   + tellCheck_BDMIntegrity/1
%       Each object that has been created during a TELL transaction
%       has to be checked whether it does not violate the
%       integrity of the new database state.
%
%   + untellCheck_BDMIntegrity/1
%       Each object that has been deleted during an UNTELL transaction
%       has to be checked whether it's missing does not violate the
%       integrity of the new database state.
%
%
%   + mk_permanent_BDMFormulas/2
%       Temporary created BDMFormulas (because of an (UN-)TELL)
%       will be permanently stored if the transaction is accepted.
%
%   + rm_temp_BDMFormulas/0
%       Temporary created BDMFormulas (because of an (UN-)TELL)
%       will be delete if the transaction is not accepted.
%
%
% metaformulas change:
% new predicates
% tell_BDMProcTrigger
% untell_BDMProcTrigger
% for registering and deleting a list of procedure triggers
%
% mk_permanent_BDMFormulas
% ternary, no longer binary
% a list with formulas to be deleted and a list with formulas to be inserted
% are passed
% reason:
% use of change_BDMFormula:
% changing a BDM formula is done by deleting the old formula
% and entering the new one.
% this was not completely implemented before integration of the metaformulas:
% on tell only insertions were considered, on
% untell only deletions
%
%

:- module('BDMIntegrityChecker',[
'mk_permanent_BDMFormulas'/3
,'rm_temp_BDMFormulas'/0
,'tellCheck_BDMIntegrity'/1
,'tell_BDMIntegrityConstraint'/3
,'tell_BDMProcTrigger'/1
,'tell_BDMRule'/3
,'untellCheck_BDMIntegrity'/1
,'untell_BDMIntegrityConstraint'/1
,'untell_BDMProcTrigger'/1
,'untell_BDMRule'/1
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').
:- use_module('BDMCompile.swi.pl').
:- use_module('BDMForget.swi.pl').
:- use_module('BDMEvaluation.swi.pl').
:- use_module('BDMKBMS.swi.pl').
:- style_check(-singleton).
%  ====================
%  Exported predicates:
%  ====================
%  ============== (UN-)TELL INTEGRITY CONSTRAINT OR RULE ====================
%  **************************************************************************
%
%  tell_BDMIntegrityConstraint( _BIMstring, _id)
%
%  The integrity constraint in the form of a string is scanned,
%  parsed, brought into a certain normal form and finally the
%  processing of new integrity constraints handed over.
%
%  _string : the string that represents the integrity condition
%            (as entered by the user) (i),
%  _id        : the identifier of the object containing the IC (i).
%
%  **************************************************************************

tell_BDMIntegrityConstraint(rangeconstr(_rangeform), _info, _id ) :-
	%  Evaluate, examine and decompose the constraint:

	'NewIntegrityConstraint'(_info,_rangeform, _id).
%  ***************************************************************************
%
%  tell_BDMRule( _rangeform, _infos, _id)
%
%  _rangeform : term of the form rangerule(_vars,_cond,_concl)
%  _infos      : variable table of the form [range(x,C)..]
%  _id        : the identifier of the object that contains the rule (i).
%
%  ***************************************************************************
%  note: the elements of the _info list (i.e. the variable table) will soon look like: range(this,[C1,C2]).

tell_BDMRule(_rangef, _info, _id) :-
	%  Evaluating, analyzing and decomposing the rule:

	_rangef =.. [rangerule,_vars,_l1,_l2],
	_rangeform =.. [rangerule,_l1,_l2],
	'NewRule'(_info,_rangeform,_id).
%
% Metaformulas: new insert and delete operations for trigger maintenance
% of the generated formulas (RS, 9.1.1996)
%
%  ***************************************************************************
%
%  tell_BDMProcTrigger(_pts)
%
%  _pts: list of triggers with functor applyPredicateIfInsert /
%                                       applyPredicateIfDelete
%
%  ***************************************************************************

tell_BDMProcTrigger([]).
tell_BDMProcTrigger([_pT|_pTs]) :-
	'NewProcTrigger'(_pT),
	tell_BDMProcTrigger(_pTs).
%  ***************************************************************************
%
%  untell_BDMProcTrigger(_oids)
%
%  _oids: list of metaformula OIDs.
%
%   Each procedure trigger can be uniquely assigned via the OID component to a
%   metaformula. If this is deleted, one can by means of
%   the OID component, quickly find the associated triggers and
%   delete them
%
%  ***************************************************************************

untell_BDMProcTrigger([]).
untell_BDMProcTrigger([_oid|_oids]) :-
	'ForgetProcTrigger'(_oid),
	untell_BDMProcTrigger(_oids).
%  ***************************************************************************
%
%  untell_BDMIntegrityConstraint( _id)
%
%  If an integrity constraint is deleted from the system (UNTELL), then
%  all other objects attached to it (simplified instances
%  e.g.) deleted. Furthermore their compilation must be rolled back
%  are.
%
%  _id : the identifier of the object that contains the integrity condition (i).
%
%  ***************************************************************************

untell_BDMIntegrityConstraint( _id) :-
        'ForgetIntegrityConstraint'( _id),
        !.
%  ***************************************************************************
%
%  untell_BDMRule( _id)
%
%  When a rule is deleted from the system (UNTELL), all
%  other dependent objects (simplified forms etc.) must also be deleted
%  are. Furthermore their compilation must be rolled back.
%
%  _id : identifier of the object containing the rule (i).
%
%  ***************************************************************************

untell_BDMRule( _id) :-
        'ForgetRule'( _id),
        !.
%  ============================== EVALUATION =================================
%  ***************************************************************************
%
%  tellCheck_BDMIntegrity(_propdescr)
%
%  This predicate checks wether a given _propdescr fulfills the
%  integrity constraints that concern this _propdescr.
%
%  _propdescr: an object temporarily created during the TELL operation (i).
%
%  ***************************************************************************

tellCheck_BDMIntegrity( 'P'( _id, _source, _label, _dest)) :-
	  (_label = '*instanceof'; _label = '*isa'),
        !,
                %  If this is a new integrity constraint or rule
                %  it must be tested whether its insertion
                %  causes no inconsistency:

        tellRuleOrIntegrityConstraint(
                'P'( _id, _source, _label, _dest)),
                %  If the new object directly or indirectly appears in integrity
                %  constraints, it must be checked whether
                %  they still hold:

        tellObjectConcerningIntegrityConstraintsOrRules(
                'P'( _id, _source, _label, _dest)).
%  this is an object that is not considered by the integrity test:

tellCheck_BDMIntegrity( _) :-
        !.
%  ***************************************************************************
%
%  untellCheck_BDMIntegrity(_propdescr)
%
%  If an object is deleted from the current database by the UNTELL operation
%  then it must be checked whether integrity is still
%  ensured, or whether the existence of the object is required. That is:
%  If the object is an integrity constraint, nothing needs to be done.
%  If the object is a rule, care must be taken that none of
%  which then leads to an integrity violation for objects that can no longer be derived.
%  Finally, such integrity constraints (possibly after rule application)
%  to test those that may require the existence of the object; they are found at
%  the class to which the object then no longer belongs.
%
%  _propdescr: an object temporarily created during the UNTELL operation.
%
%  ***************************************************************************

untellCheck_BDMIntegrity(
     'P'( _id, _source, _label, _dest)):-
	  (_label = '*instanceof'; _label = '*isa'),
        !,
                %  If it is a rule, it must be tested whether
                %  by deleting them no inconsistency is caused:

        untellRule( 'P'( _id, _source, _label, _dest)),
                %  Does the object to be deleted (in-)directly affect integrity-
                %  constraints, it must be checked whether
                %  they still hold:

        untellObjectConcerningIntegrityConstraintsOrRules(
            'P'( _id, _source, _label, _dest)).
%  this is an object that is not considered by the integrity test:

untellCheck_BDMIntegrity( _) :-
        !.
%  ======================= (UN-) ACCEPT TRANSACTION ==========================
%  ***************************************************************************
%
%  mk_permanent_BDMFormulas( _ListOfBDMPredicates1, _listOfPredicates2, _mode)
%
%  If a transaction is accepted, then the during it
%  performed insertions, deletions and changes to BDM formulas must
%  Predicates must now be stored permanently.
%  if an SML file was consulted, the list of all
%  BDM formula predicates generated in the process are needed for storage.
%
%  for procedure triggers, both for tell and for the
%  untell case insertions and deletions of procedure triggers may be required.
%  therefore two lists are passed.
%
%
%  ***************************************************************************

mk_permanent_BDMFormulas( _listOfBDMPredicates1, _listOfPredicates2, _mode) :-
        mk_permanent_BDMFormula( _listOfBDMPredicates1, _listOfPredicates2, _mode),
        !.
%  ***************************************************************************
%
%  rm_temp_BDMFormulas
%
%  When a transaction is rejected, the
%  insertions, deletions and changes to BDM formula
%  predicates are not adopted, but instead under them again
%  the state as before the transaction applies again.
%
%  ***************************************************************************

rm_temp_BDMFormulas :-
        rm_temp_BDMFormula,
        !.
