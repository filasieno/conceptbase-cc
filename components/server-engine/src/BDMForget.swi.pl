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
% **********************************************************************
%
% File:         BDMForget.pro
% Version:      11.3
%
%
% Date released : 97/02/12  (YY/MM/DD)
%
% SCCS-Source-Pool : /home/CBase/CB_NewStruct/ProductPOOL/serverSources/Prolog_Files/SCCS/s.BDMForget.pro
% Date retrieved : 97/04/30 (YY/MM/DD)
% *************************************************************************
%
% -----------------------------------------------------------------------------
%
% This module is part of the BDMIntegrityChecker and is responsible for the
% right treatment of untelled integrity constraints and rules concerning their
% compilation.
%
%
%
% Exported predicates:
% --------------------
%
%   + ForgetIntegrityConstraint/1
%       When an integrity constraint is deleted in the system (UNTELL), then
%       here all objects linked to this integrity constraint are deleted;
%       these are exactly those generated in NewIntegrityConstraint@BDMCompile.
%
%   + ForgetRule/1
%       When a rule is deleted from the system (UNTELL), all are initialized here
%       objects deleted that hang off this rule; these are exactly those
%       generated in NewRule@BDMCompile.
%
%
% 7-Mar-1990/MJf:
%   . Use dedicated variables _tt1,_tt2,... for transaction time intervals
%     instead of tt(_TellTime) for all transaction times. Reason: Different
%     information may have different transaction time though in the case
%     of BDM rules&constraints the corresponding triggers, specialized
%     assertions etc. normally has been told during the same transaction.
%     But: It may be the case that some weird trigger (or so) is told later.
%
% 12-Mar-1990/MJf:
%    . The "generate-test-fail" combination used in ForgetSimplified-
%      Constraints, ForgetSimplifiedRules and RuleConcernsThisClass is now
%      replaced by the "findall" paradigm. The reason for this is the
%      following: BDMForget backtracks on the objects in the KB which have
%      to be "untelled". The untelled ones are temporarily created in
%      Rep_temp. Thus, the procedure retrieve_proposition may *not* con-
%      sider Rep_temp. Otherwise, infinite backtracking would occur.
%      On the other hand, it would be nice to have Rep_temp visible during
%      the UNTELL phase when the concerned objects are identified.
%      Reason: We want to have the UNTELL to non-sensitive to the ordering
%      of the untelled information. Example: Up to now, it's impossible to
%      untell the attributes and the class (defining the corresponding
%      categories) in the same transaction. The untelled instantiation link
%      is in Rep_temp. Therefore, the translator FragmentToHistoryPropositions
%      cannot find the attribute categories of the untelled attributes.
%      <Please remember that BDMForget is used in this translator>
%
% 4-Jul-1990/MJf:
%   . triggers applyConstraintIfInsert, applyConstraintIfDelete,
%     applyRuleIfInsert, applyRuleIfDelete and deducedBy are now attributes
%     of PROPOSITION instead of CLASS
%
% 21-Jan-1993/DG: AttrValue is changed into A by deleting the
% time component (see CBNEWS[154])
%
% 1-Sep-93/Tl: retrieve_proposition calls with constant objects at Src or Dst entry
% are changed into a name2id(...,_id),retr_prop(..,_id,..) combination. The old
% construction didn't work with an extern retrieve_proposition
%
% Meta formula change (10.1.96)
% new predicate ForgetProcTrigger(_oid) that deletes all generated procedure
% triggers for a metaformula.
%
% 9-Dec-96 LWEB: retrieve_temp_proposition$Rep_temo replaced by
% retrieve_temp$PropositionProcessor.
%

:- module('BDMForget',[
'ForgetIntegrityConstraint'/1
,'ForgetProcTrigger'/1
,'ForgetRule'/1
,'RetrieveProposition'/1
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').
:- use_module('PropositionProcessor.swi.pl').
:- use_module('FragmentToHistoryPropositions.swi.pl').
:- use_module('Literals.swi.pl').
:- use_module('BDMKBMS.swi.pl').
:- use_module('GeneralUtilities.swi.pl').
:- style_check(-singleton).
%  ====================
%  Exported predicates:
%  ====================
%  ***************************************************************************
%
%  ForgetIntegrityConstraint( _IcId)
%
%  If the UNTELL operation is applied to an integrity constraint, then
%  UNTELL must automatically be applied to all objects created during the
%  compilation phase (tell_BDMIntegrityConstraint@BDMIntegrityChecker).
%  Since this integrity constraint is then no longer taken into account by the
%  integrity test (check_BDMIntegrity@BDMIntegrityChecker), the dependencies
%  between affected classes and incoming rules of the integrity constraint
%  change. Finally, all internal BDM predicates associated with this
%  integrity constraint are deleted or updated.
%  It is assumed that the object representing the integrity condition
%  (with the identifier _IcId) has already been untelled.
%
%  _IcId      : the identifier of the object that represents the integrity
%               condition. (i)
%
%  ***************************************************************************

'ForgetIntegrityConstraint'( _IcId) :-
                %  1. the complete integrity constraint:

        delete_origConstraint( _IcId),
                %  2. process the individual simplified instances of this
                %     integrity constraint:

        'ForgetSimplifiedConstraints'( _IcId),
        !.
%  ***************************************************************************
%
%  ForgetRule( _RuleId)
%
%  When the UNTELL operation is applied to a rule, then
%  UNTELL must automatically be applied to all objects created during the
%  compilation phase (tell_BDMIntegrityConstraint@BDMIntegrityChecker).
%  Since this rule is then no longer taken into account by the integrity test
%  (check_BDMIntegrity@BDMIntegrityChecker), change
%  the dependencies between affected classes and incoming rules and
%  the rule. Finally all internal BDM predicates,
%  that are related to this rule, deleted resp. updated.
%  Assumes that the object representing the rule
%  (with identifier _RuleId), has already been untold.
%
%  _RuleId : identifier of the object that represents the rule (i).
%
%  ***************************************************************************

'ForgetRule'( _RuleId) :-
        delete_origRule( _RuleId),
                %  2. Process the individual simplified instances of this
                %     integrity constraint:

        'ForgetSimplifiedRules'( _RuleId),
        !.

'ForgetProcTrigger'(_oid) :-
	findall('applyPredicateIfInsert@BDMCompile'(_literal,_oid,_ePredList,_proc),
	retrieve_BDMFormula('applyPredicateIfInsert@BDMCompile'(_literal,_oid,_ePredList,_proc)),
	_procTriggerList1),
	% write(_procTriggerList1),nl,nl,

	deleteProcTriggerList(_procTriggerList1),
	findall('applyPredicateIfDelete@BDMCompile'(_literal,_oid,_proc),
	retrieve_BDMFormula('applyPredicateIfDelete@BDMCompile'(_literal,_oid,_proc)),
	_procTriggerList2),
	% write(_procTriggerList2),nl,nl,

	deleteProcTriggerList(_procTriggerList2)
	.

deleteProcTriggerList([]).
deleteProcTriggerList([_pt|_pts]) :-
	delete_BDMFormula_once(_pt),
	deleteProcTriggerList(_pts).
%  ===================
%  Private predicates:
%  ===================
%  ***************************************************************************
%
%  ForgetSimplifiedConstraints( _IcId)
%
%  In turn, all simplified instances of the integrity
%  constraint are searched for.
%  A certain simplified instance of an integrity condition is
%  treated according to the UNTELL operation: unassigning their objects,
%  Deleting their BDM predicates, changing the dependencies by
%  propagating subset of the rules entering the integrity constraint.
%
%  _IcId      : the identifier of the object representing the integrity condition
%               (i)
%
%  12-Mar-1990/MJf: Use findall and the recursive procedure delete-
%  SimplifiedConstraints instead of the "backtracking" solution. See also note-
%  at the beginning of this file.
%
%  ***************************************************************************

'ForgetSimplifiedConstraints'( _IcId) :-
                %  1. Find all simplified instances:
        %  1-Sep-93/Tl

	name2id('MSFOLconstraint',_MSFOLconId),
	name2id('BDMConstraintCheck',_BDMconChId),
        retrieve_proposition( 'P'( _AttrCatId,
           _MSFOLconId, specialConstraint,_BDMconChId )),
        findall(_SimpIcId,
                isSimplifiedAssertion(_IcId, _AttrCatId, _SimpIcId),
                _solutions),
                %  2. Delete them

        deleteSimplifiedConstraints(_IcId,_solutions),
        !.
% * Process all found simplified integrity constraints:

deleteSimplifiedConstraints(_IcId,[]) :- !.
deleteSimplifiedConstraints(_IcId, [_SimpIcId|_rest]) :-
          %  1. Forget the simplified instance

   delete_applyConstraint( _IcId, _SimpIcId, _ClassId, _InsDel),
          %  2. Considering rules whose inference literal goes into the
          %     simplified instance is involved

   'RuleConcernsThisClass'( _ClassId, untoldIC(_SimpIcId), _InsDel),
   deleteSimplifiedConstraints(_IcId,_rest).
% * _SimpAssId is a simplification of _AssId under category _AttrCatId

isSimplifiedAssertion(_AssId, _AttrCatId, _SimpAssId) :-
   retrieve_proposition('P'(_ConId,_AssId,_l2,_SimpAssId)),
   retrieve_proposition('P'(_IoId, _ConId,'*instanceof',_AttrCatId)).
%  ***************************************************************************
%
%  ForgetSimplifiedRules( _RuleId)
%
%  In turn, all simplified forms of the rule are searched for.
%  A certain simplified form of the rule is
%  treated according to the UNTELL operation: unassigning their objects,
%  deleting its BDM predicates, changing dependencies by
%  propagating portion of the rules incoming into the rule.
%
%  _RuleId    : the identifier of the object representing the rule. (i)
%
%  12-Mar-1990/MJf: Changes analogous to ForgetSimplifiedConstraints
%
%  ***************************************************************************

'ForgetSimplifiedRules'( _RuleId) :-
                %  1. Searching for all simplified instances:
        % 1-Sep-93/Tl

        name2id('MSFOLrule',_MSFOLruleId),
        name2id('BDMRuleCheck',_BDMruleChId),
        retrieve_proposition(
                    'P'(_AttrCatId,_MSFOLruleId,specialRule,_BDMruleChId)),
        findall(_SimpRuleId,
                isSimplifiedAssertion(_RuleId, _AttrCatId, _SimpRuleId),
                _solutions),
                %  2. Delete them

        deleteSimplifiedRules(_RuleId,_solutions),
        !.

deleteSimplifiedRules(_RuleId,[]) :- !.
deleteSimplifiedRules(_RuleId, [_SimpRuleId|_rest]) :-
          %  1. Forget the simplified instance

   delete_SimpRule( _SimpRuleId, _ClassId, _InsDel),
          %  2. Consider rules whose inference literal is entered into the
          %     simplified instance is entered

   'RuleConcernsThisClass'( _ClassId, untoldRule(_SimpRuleId), _InsDel),
   deleteSimplifiedRules(_RuleId,_rest).
%  ***************************************************************************
%
%  RuleConcernsThisClass( _ClassId, _untold, _InsDel)
%
%  If instances of the specified class are derived from a rule,
%  then the compilation of this rule must also be updated.
%
%  _ClassId   : the identifier of the class whose instances enter an
%               integrity constraint that was untelled, or appear in a rule
%               that itself (possibly via further rules) enters an untelled
%               integrity constraint (i),
%  _untold    : contains identifier of the deleted simplified formula (i)
%  _InsDel    : whether delete or insert check is omitted (i).
%
%  12-Mar-1990/MJf: Here too the "fail" construction is replaced by "findall".
%  However, isSpecializedRuleDeducingClass is a somewhat stricter condition.
%  visitSimpRules simply treats all solutions as before.
%
%  ***************************************************************************
%  _InsDel indicates whether the deleted simplified form is for Insert or
%  delete of the condition literal (concerning _ClassId) was responsible

'RuleConcernsThisClass'(_ClassId, _untold,_InsDel):-
   findall(_SimpRuleId,
           isSpecializedRuleDeducingClass(_ClassId,_SimpRuleId),
           _solutions),
   visitSimpRules(_solutions,_untold,_InsDel),
   'WriteTrace'(veryhigh,'BDMForget',['The deletion ',_untold,
              ' affects the specialized rules ',_solutions,
              ' which are triggers for "',_InsDel,'" at class ',_ClassId]),
   !.

visitSimpRules([],_,_) :- !.
visitSimpRules([_SimpRuleId|_rest],_untold,_InsDel) :-
	_goahead = goAhead(_InsDel, _ListOfSimpIcIds, _ListOfSimpRuleIds),
	(
	  retrieve_BDMFormula('applyRuleIfInsert@BDMCompile'( _RuleId, _, _SimpRuleId, _, _, _,_goahead))
	;
	  retrieve_BDMFormula('applyRuleIfDelete@BDMCompile'( _RuleId, _, _SimpRuleId, _, _, _,_goahead))
	),
	_goahead = goAhead(_InsDel, _ListOfSimpIcIds, _ListOfSimpRuleIds),
	!,
     % * Processing this simplified rule:

   treatSimpRule(_SimpRuleId,_untold,_ListOfSimpRuleIds,_ListOfSimpIcIds),
   visitSimpRules(_rest,_untold,_InsDel).
%  ... when the goAhead trigger does not have the desired _InsDel:
%  ---> this simplified form is not included in _untold

visitSimpRules([_|_rest],_untold,_InsDel) :-
   visitSimpRules(_rest,_untold,_InsDel).
% * _RuleId derives instances of _ClassId. Note that the route goes via the
% * internal representation _OrigRuleId of the rule.      12-Mar-1990/MJf
%  _RuleTime removed                                    25-Jan-1993/DG

isDeducingRule(_ClassId, _RuleId) :-
      % *  _OrigRuleId is the internal form of a rule of _ClassId

   prove_literal(  'A'(_ClassId,deducedBy,_OrigRuleId)  ),
      % * _RuleId is the Id of the text form of the rule

   prove_literal(  'A'(_RuleId,originalRule,_OrigRuleId)  ).
% * _SimpRuleId is a specialization of _RuleId

isSpecializedRule(_RuleId, _SimpRuleId) :-
   prove_literal(  'A'(_RuleId,specialRule,_SimpRuleId)  ).
% * _SimpRuleId is a simplified instance of a rule whose instances
% * derives from _ClassId.                                12-Mar-1990/MJf

isSpecializedRuleDeducingClass(_ClassId, _SimpRuleId) :-
   isDeducingRule(_ClassId, _RuleId),
   isSpecializedRule(_RuleId, _SimpRuleId).
%  ***************************************************************************
%
%  treatSimpRule( _SimpRuleId, _untold, _ListOfSimpRuleIds, _ListOfSimpIcIds)
%
%  The given simplified form of a rule generates objects that feed into the
%  simplified instance of an integrity condition to be deleted (or into
%  the simplified rule form to be deleted). Therefore the references
%  between them must be deleted, and if the simplified rule form feeds into nothing
%  else, then the references to this simplified rule form
%  and to delete them themselves.
%
%  _SimpRuleId        : the identifier of the simplified form of a rule,
%                       generated objects that may enter an integrity constraint
%                       that was untelled, or enter a rule that itself
%                       (possibly via further rules) enters an untelled
%                       integrity constraint (i),
%  _untold            : contains the identifier of the deleted simplified
%                       form (i),
%  _ListOfSimpRuleIds : list of simplified rule forms to apply after the
%                       simplified form of the rule to be processed
%                       would apply (i),
%  _ListOfSimpIcIds   : list of the simplified rule forms that after the
%                       simplified form of a rule to be processed are to be applied
%                       would be (i),
%
%  ***************************************************************************
%  The found simplified rule refers ONLY to the Ic to be untold:

treatSimpRule( _SimpRuleId, untoldIC(_untell_SimpIcId), [], [_untell_SimpIcId]) :-
        'WriteTrace'(high,'BDMForget',[_SimpRuleId,' is now unnecessary']),
        delete_SimpRule( _SimpRuleId, _ClassId, _InsDel),
        'RuleConcernsThisClass'( _ClassId, untoldRule(_SimpRuleId), _InsDel),
        !.
%  the found simplified rule involves more than the Ic to be untold:

treatSimpRule( _SimpRuleId, untoldIC(_untell_SimpIcId), _, _) :-
        (_name = 'applyRuleIfInsert@BDMCompile';
         _name = 'applyRuleIfDelete@BDMCompile'),
        _trigger =.. [_name,_RuleId,_ClassId,_SimpRuleId,_Literal,_RuleConcl,_RuleCondMerged,
                      goAhead(_InsDel,_ListOfSimpIcIdsOld,_ListOfSimpRuleIds)],
        retrieve_BDMFormula_once(_trigger),
        !,
        deleteListMember( _ListOfSimpIcIdsOld, _untell_SimpIcId,
                          _ListOfSimpIcIdsNew),
        _newtrigger =.. [_name,_RuleId,_ClassId,_SimpRuleId,_Literal,
                      _RuleConcl,_RuleCondMerged,
                      goAhead(_InsDel,_ListOfSimpIcIdsNew,_ListOfSimpRuleIds)],
        change_BDMFormula(_trigger,_newtrigger),
        !.
%  The found simplified rule points ONLY to the simplified rule to be untelled
%  simplified rule:

treatSimpRule( _SimpRuleId, untoldRule(_untell_SimpRuleId),
               [_untell_SimpRuleId], []) :-
        'WriteTrace'(high,'BDMForget',[_SimpRuleId,' is now unnecessary']),
        delete_SimpRule( _SimpRuleId, _ClassId, _InsDel),
        'RuleConcernsThisClass'( _ClassId, untoldRule(_SimpRuleId), _InsDel),
        !.
%  The found simplified rule is involved in more than the simplified rule
%  to be untold:

treatSimpRule( _SimpRuleId, untoldRule(_untell_SimpRuleId), _, _) :-
        (_name = 'applyRuleIfInsert@BDMCompile';
         _name = 'applyRuleIfDelete@BDMCompile'),
        _trigger =.. [_name,_RuleId,_ClassId,_SimpRuleId,_Literal,_RuleConcl,_RuleCondMerged,
                      goAhead(_InsDel,_ListOfSimpIcIds,_ListOfSimpRuleIdsOld)],
        retrieve_BDMFormula_once(_trigger),
        !,
        deleteListMember( _ListOfSimpRuleIdsOld, _untell_SimpRuleId,
                          _ListOfSimpRuleIdsNew),
        _newtrigger =.. [_name,_RuleId,_ClassId,_SimpRuleId,_Literal,
                      _RuleConcl,_RuleCondMerged,
                      goAhead(_InsDel,_ListOfSimpIcIds,_ListOfSimpRuleIdsNew)],
        change_BDMFormula(_trigger,_newtrigger),
        !.
%  ===========================================================================
%  ***************************************************************************
%  ***************************************************************************
%
%  *************      S   U   B   M   O   D   U   L   E      *****************
%
%
%               DDDD    EEEEE   L       EEEEE  TTTTT  EEEEE
%               D   D   E       L       E        T    E
%               D   D   EEEE    L       EEEE     T    EEEE
%               D   D   E       L       E        T    E
%               DDDD    EEEEE   LLLLL   EEEEE    T    EEEEE
%
%
%  This section contains only the predicates that deal with
%  invalidating and deleting Prolog predicates.
%  Note: all these predicates are fully analogous to those in the
%  STORE@BDMCompile submodule, i.e. if something changes in storage,
%  it must be changed correspondingly here and vice versa!
%
%  This can be done with the following predicates:
%       delete_origConstraint( _IcId)
%       delete_origRule( _RuleId)
%       delete_applyConstraint( _IcId, _SimpIcId, _ClassId, _InsDel)
%       delete_SimpRule( _SimpRuleId, _ClassId, _InsDel)
%
%  ***************************************************************************
%  ***************************************************************************
%  ***************************************************************************
%
%  delete_origConstraint( _IcId)
%
%  untells the objects and deletes the BDM predicate for a complete
%  integrity constraint.
%
%  _IcId      : the identifier of the object representing the original integri-
%               ty condition (instance of MSFOLconstraint) (i).
%
%  ***************************************************************************

delete_origConstraint( _IcId) :-
                %  1. Invalidating the objects:
                %  1a. Reference from the integrity constraint to its internal,
                %      complete representation:
        % 1-Sep-93/Tl

        name2id('MSFOLconstraint',_MSFOLconId),
        name2id('BDMConstraintCheck',_BDMconChId),
        retrieve_proposition( 'P'( _AttrCatId1,
           _MSFOLconId, originalConstraint, _BDMconChId)),
        retrieve_proposition(
            'P'( _ConId, _IcId, _Label, _OrigIcId)),
        retrieve_proposition(
            'P'( _IoId1a, _ConId, '*instanceof', _AttrCatId1)),
        'DELETE'( 'P'( _ConId, _IcId, _Label, _OrigIcId)),
        'DELETE'( 'P'( _IoId1a, _ConId, '*instanceof', _AttrCatId1)),
                %  1b. The object that contains the integrity constraint in its
                %      contains internal, complete representation:

        retrieve_proposition(
            'P'( _OrigIcId, _OrigIcId, _IcFormula_list, _OrigIcId)),
        retrieve_proposition(
           'P'( _IoId2b, _OrigIcId, '*instanceof', _BDMconChId)),
        'DELETE'( 'P'( _OrigIcId, _OrigIcId, _IcFormula_list, _OrigIcId)),
        'DELETE'( 'P'( _IoId2b, _OrigIcId, '*instanceof', _BDMconChId)),
                %  2. Delete of the BDM predicate:

        delete_BDMFormula_once('origConstraint@BDMCompile'( _, _OrigIcId, _)),  % 26-May-1995 LWEB
         !.
%  ***************************************************************************
%
%  delete_origRule( _RuleId)
%
%  untells the objects and deletes the BDM predicate for a complete
% rule.
%
%  _RuleId      : the identifier of the object that represents the original rule
%                 (instance of MSFOLrule) (i).
%
%  ***************************************************************************

delete_origRule( _RuleId) :-
                %  1a. The reference from the rule to its internal,
                %      complete representation:
        % 1-Sep-93/Tl

        name2id('MSFOLrule',_MSFOLruleId),
        name2id('BDMRuleCheck',_BDMruleChId),
        retrieve_proposition(
           'P'( _AttrCatId1, _MSFOLruleId, originalRule, _BDMruleChId)),
        retrieve_proposition(
           'P'( _ConId1, _RuleId, _Label1, _OrigRuleId)),
        retrieve_proposition(
           'P'( _IoId1b, _ConId1, '*instanceof', _AttrCatId1)),
        'DELETE'( 'P'( _ConId1, _RuleId, _Label1, _OrigRuleId)),
        'DELETE'( 'P'( _IoId1b, _ConId1, '*instanceof', _AttrCatId1)),
                %  1a. The object that contains the rule in its internal,
                %      represents in complete format:

        retrieve_proposition(
           'P'( _OrigRuleId, _OrigRuleId, _Rule_list, _OrigRuleId)),
        retrieve_proposition(
           'P'( _IoId2b, _OrigRuleId, '*instanceof', _BDMruleChId)),
        'DELETE'( 'P'( _OrigRuleId, _OrigRuleId, _Rule_list, _OrigRuleId)),
        'DELETE'( 'P'( _IoId2b, _OrigRuleId, '*instanceof', _BDMruleChId)),
                %  1c. The reference from the class affected by the
                %      inference literal of the rule to the internal
                %      complete rule:
        % 1-Sep-93/Tl

        name2id('Proposition',_PropId),
        retrieve_proposition(
           'P'( _AttrCatId3, _PropId, deducedBy, _BDMruleChId)),
        retrieve_proposition(
           'P'( _ConId3, _ClassId, _Label3, _OrigRuleId)),
        retrieve_proposition(
           'P'( _IoId3a, _ConId3, '*instanceof', _AttrCatId3)),
        'DELETE'( 'P'( _ConId3, _ClassId, _Label3, _OrigRuleId)),
        'DELETE'( 'P'( _IoId3a, _ConId3, '*instanceof', _AttrCatId3)),
                %  2. Delete of the BDM predicate:

        delete_BDMFormula_once('origRule@BDMCompile'( _RuleId, _, _, _)),
        !.
%  ***************************************************************************
%
%  delete_applyConstraint( _IcId, _SimpIcId, _ClassId, _InsDel)
%
%  untells the objects and deletes the BDM predicate for a specialized
%  integrity constraint and its references.
%
%  _IcId      : identifier of the object representing the original integri-
%               ty condition (instance of MSFOLconstraint) (i),
%  _SimpIcId  : id of the object representing the simplified Ic (i),
%  _ClassId   : id of the class whose instances may enter the IC (o),
%  _InsDel    : = Insert, if Ic was to be tested during an insert operation,
%               = Delete, "     "  "   "     delete-"          "  "      " (o).
%
%  ***************************************************************************

delete_applyConstraint( _IcId, _SimpIcId, _ClassId, _InsDel) :-
                %  1. Invalidating the objects:
                %  1a. The reference from the integrity constraint
                %      to its simplified instance:

        name2id('MSFOLconstraint',_MSFOLconId),
        name2id('BDMConstraintCheck',_BDMconChId),
        retrieve_proposition( 'P'( _AttrCatId,
           _MSFOLconId, specialConstraint, _BDMconChId)),
        retrieve_proposition(
           'P'( _ConId1, _IcId, _Label1, _SimpIcId)),
        retrieve_proposition(
           'P'( _IoId1b, _ConId1, '*instanceof', _AttrCatId)),
        'DELETE'( 'P'( _ConId1, _IcId, _Label1, _SimpIcId)),
        'DELETE'( 'P'( _IoId1b, _ConId1, '*instanceof', _AttrCatId)),
                %  1b. The reference from the affected class to
                %      the simplified instance:

        retrieve_proposition('P'( _ConId2, _ClassId, _Label2, _SimpIcId)),
        ((
          % 1-Sep-93/Tl

          name2id('Proposition',_PropId),
          retrieve_proposition( 'P'( _AttrCatId2,
            _PropId, applyConstraintIfInsert, _BDMconChId)),
          retrieve_proposition(
            'P'( _IoId2a, _ConId2, '*instanceof', _AttrCatId2)),
          _InsDel = 'Insert'
         );
         (
          retrieve_proposition( 'P'( _AttrCatId2,
            _PropId, applyConstraintIfDelete, _BDMconChId)),
          retrieve_proposition(
            'P'( _IoId2a, _ConId2, '*instanceof', _AttrCatId2)),
          _InsDel = 'Delete'
        )),
        'DELETE'( 'P'( _ConId2, _ClassId, _Label2, _SimpIcId)),
        'DELETE'( 'P'( _IoId2a, _ConId2, '*instanceof', _AttrCatId2)),
                %  1c. The object representing the simplified instance
                %      of the integrity condition:

        retrieve_proposition(
           'P'( _SimpIcId, _SimpIcId, _IcFormula_list, _SimpIcId)),
        retrieve_proposition(
           'P'( _IoId3b, _SimpIcId, '*instanceof', _BDMconChId)),
        'DELETE'( 'P'( _SimpIcId, _SimpIcId, _IcFormula_list, _SimpIcId)),
        'DELETE'( 'P'( _IoId3b, _SimpIcId, '*instanceof', _BDMconChId)),
                %  2. Delete of the BDM predicate:

        ((_InsDel = 'Insert',
          delete_BDMFormula_once( 'applyConstraintIfInsert@BDMCompile'(_, _ClassId, _SimpIcId, _Literal, _IcFormula))
         );
         delete_BDMFormula_once( 'applyConstraintIfDelete@BDMCompile'( _, _ClassId, _SimpIcId, _Literal, _IcFormula))
        ),
        !.
%  ***************************************************************************
%
%  delete_SimpRule( _SimpRuleId, _ClassId, _InsDel)
%
%  untells the objects and deletes the BDM predicate for a specialized
%  Rule and all its references.
%
%  _SimpRuleId: id of the object representing the simplified rule (i),
%  _ClassId   : Id of the class whose instances may be in rule apply (o),
%  _InsDel    : = Insert, if rule is to be tested during an insert operation,
%               = Delete, "     "  "   "     delete-"       "  "      " (o).
%
%  ***************************************************************************

delete_SimpRule( _SimpRuleId, _ClassId, 'Insert') :-
                %  1. Delete the BDM predicate:

        delete_BDMFormula_once( 'applyRuleIfInsert@BDMCompile'( _RuleId, _ClassId, _SimpRuleId, _, _, _,
                 goAhead(_,_ListOfSimpIcIds,_ListOfSimpRuleIds))),
                %  2. Invalidating the objects:
                %      The reference from the class to the simplified rule,
                %      from the complete rule to this simplified
                %      Form and the rule itself:

        delete_SimpRuleObjects( _ClassId, _SimpRuleId),
        !.
delete_SimpRule( _SimpRuleId, _ClassId, 'Delete') :-
                %  1. Delete of the BDM predicate:

        delete_BDMFormula_once( 'applyRuleIfDelete@BDMCompile'( _RuleId, _ClassId, _SimpRuleId, _, _, _,
                 goAhead(_,_ListOfSimpIcIds,_ListOfSimpRuleIds))),
                %  2. Invalidate the objects:
                %     The reference from the class to the simplified rule,
                %      from the complete rule to this simplified
                %      form and the rule itself:

        delete_SimpRuleObjects( _ClassId, _SimpRuleId),
        !.

delete_SimpRuleObjects( _ClassId, _SimpRuleId) :-
                %  1b. The reference from the rule to its simplified form:

	name2id('MSFOLrule',_MSFOLruleId),
	name2id('BDMRuleCheck',_BDMruleChId),
        retrieve_proposition(
           'P'( _AttrCatId2, _MSFOLruleId, specialRule, _BDMruleChId)),
        retrieve_proposition(
           'P'( _ConId2, _RuleId, _Label2, _SimpRuleId)),
        retrieve_proposition(
           'P'( _IoId2a, _ConId2, '*instanceof', _AttrCatId2)),
        'DELETE'( 'P'( _ConId2, _RuleId, _Label2, _SimpRuleId)),
        'DELETE'( 'P'( _IoId2a, _ConId2, '*instanceof', _AttrCatId2)),
                %  1c. The object representing the simplified form of the
                %      rule:

        retrieve_proposition(
           'P'( _SimpRuleId, _SimpRuleId, _Rule_list, _SimpRuleId)),
        retrieve_proposition(
           'P'( _IoId3b, _SimpRuleId, '*instanceof', _BDMruleChId)),
        'DELETE'( 'P'( _SimpRuleId, _SimpRuleId, _Rule_list, _SimpRuleId)),
        'DELETE'( 'P'( _IoId3b, _SimpRuleId, '*instanceof', _BDMruleChId)),
        !.
delete_SimpRuleObjects( _ClassId, _SimpRuleId).

'PassThruList'( [], _) :-
        !.
'PassThruList'( [ _el | _rest], _Predicate) :-
        _Predicate =.. [ _functor, _arg],
        _callPredicate =.. [ _functor, _arg, _el],
        call( _callPredicate),
        'PassThruList'( _rest, _Predicate),
        !.

'RetrieveProposition'( _object) :-
        retrieve_proposition( _object)
	;
        retrieve_temp_del( _object).
%  20-Nov-96 LWEB : retrieve_proposition covers both persistent and temporary objects
%  ***************************************************************************
%
%  deleteListMember( _ListOld, _Member, _ListNew)
%
%  Remove the specified element from the old list (it must be
%  contained in it!).
%
%  ***************************************************************************

deleteListMember( [ _Member | _ListOld_rest], _Member, _ListOld_rest) :-
        !.
deleteListMember( [ _NotMember | _ListOld_rest], _Member,
                  [ _NotMember | _ListNew_rest]) :-
        deleteListMember( _ListOld_rest, _Member, _ListNew_rest),
        !.
