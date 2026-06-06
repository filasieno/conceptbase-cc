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

:- module('QO_heur',[
'cleanLiterals'/2
,'earlyRedNegPost'/2
,'earlyRedNegPre'/2
,'recHeuristic'/1
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').
:- use_module('QO_costBase.swi.pl').
:- use_module('QO_literals.swi.pl').
:- use_module('QO_vartab.swi.pl').
:- use_module('GeneralUtilities.swi.pl').
:- use_module('RuleBase.swi.pl').
:- use_module('PrologCompatibility.swi.pl').
:- style_check(-singleton).
% ================  simple optimizations ============================
% --------------------------------------------------------------------
%
%  The input literal list represents a conjunction.
%  Therefore the following optimizations are possible:
%
%  1. TRUE literals are removed from the conjunction
%  2. if FALSE occurs, there can be no solution
%  3. duplicates are removed
%
%  Note on 3.
%  Replacing the parameter literal In(_x,_var_XYZ)
%  with In(_x,<class of x>) in module QO_preproc can cause
%  duplicate In-literals in parameter queries.
%  If In(_x,<class of x>)
%  appears twice after replacing _var_XYZ with <class of x>,
%  one of the occurrences can be removed, even if the optimization
%  later undoes the replacement again.
%  Reason: at query invocation _var_XYZ is always bound to a
%  subclass of <class of x>.
%
% --------------------------------------------------------------------

cleanLiterals(_litsIn,['FALSE']) :-
	memberchk('FALSE',_litsIn),!.
cleanLiterals(_litsIn,_lits) :-
	cleanLiterals1(_litsIn,_lits).

cleanLiterals1([],[]).
cleanLiterals1(['TRUE'|_litsIn],_lits) :-
	!,
	cleanLiterals1(_litsIn,_lits).
cleanLiterals1([_l|_litsIn],_lits) :-
	memberchk(_l,_litsIn),!,
	cleanLiterals1(_litsIn,_lits).
cleanLiterals1([_l|_litsIn],[_l|_lits]) :-
	cleanLiterals1(_litsIn,_lits).
% ================= early reduction for negated literals ============
% --------------------------------------------------------------------
%  Handling of negated literals:
%  1. negated literals may only be evaluated when
%     both arguments are bound
%  2. often the cost of negated literals according to the cost model
%     is close to 1, although they express much better selection
%     conditions
%
%  The heuristic is based on the assumption that certain negated
%  literals should be evaluated as early as possible
%
%  They are removed from the literal set before determining a
%  literal arrangement and then inserted as far to the left as
%  possible.
% --------------------------------------------------------------------

testNeg :-
	_lits = [
                'Adot'('_nid1','_t','_n1'),
                'Adot'('_nid2','_this','_n'),
                'Adot'('_tid','_f','_mftId'),
                'In'(id_3925,'_mfClass'),
                'Adot'('_nid3',id_3925,'_n1'),
%                 Adot('_tid1','_t','_mftId'),

               	'Adot'('_did','_f','_d'),
                'Adot'('_tid2','_this','_mftId'),
% 		not(IDENTICAL('_f','_this')),

                'Adot'('_nid4','_f','_n')
		],
	earlyRedNegPre(_lits,_newLits),
	earlyRedNegPost(_newLits,_litsOut),
	!.
% --------------------------------------------------------------------
%
%  earlyNegPre: preprocessing
%  remove selected negated literals from the literal set
%
% --------------------------------------------------------------------

earlyRedNegPre(_lits,_newLits) :-
	earlyRedNegPre1(_lits,_newLits,_litsRemoved),
	pc_rerecord('QOTransTemp',earlyRedNegLits,_litsRemoved).

earlyRedNegPre1([],[],[]).
earlyRedNegPre1([_lit|_lits],_newLits,[_lit|_litsRemoved]) :-
	earlyRedNegLiteral(_lit),!,
	earlyRedNegPre1(_lits,_newLits,_litsRemoved).
earlyRedNegPre1([_lit|_lits],[_lit|_newLits],_litsRemoved) :-
	earlyRedNegPre1(_lits,_newLits,_litsRemoved).
% --------------------------------------------------------------------
%
%  earlyRedNegPost: post-processing
%  insert the negated literals as far to the front as possible
%
% --------------------------------------------------------------------

earlyRedNegPost(_lits,_newLits) :-
	pc_recorded('QOTransTemp',earlyRedNegLits,_litsRemoved),
	getVarsBoundExtern(_varsBound),
	insertNegLits(_litsRemoved,_varsBound,_lits,_newLits).

insertNegLits([],_,_lits,_lits).
insertNegLits([_negLit|_negLits],_varsBound,_oldLits,_lits) :-
	getVars(_negLit,_varsLit),
	(insertNegLit(_negLit,_varsLit,_varsBound,_oldLits,_newLits);
	 append(_oldLits,[_negLit],_newLits)),!,
%  if insertion fails, append
% 							    at the end of the sequence

	insertNegLits(_negLits,_varsBound,_newLits,_lits).

insertNegLit(_negLit,_varsLit,_varsBound,_oldLits,[_negLit|_oldLits]) :-
	subtract(_varsLit,_varsBound,_remVars),
	_remVars == [],!.
insertNegLit(_negLit,_varsLit,_varsBound,[_actLit|_oldLits],[_actLit|_lits]) :-
	subtract(_varsLit,_varsBound,_remVars),
	_remVars \== [],
	getVars(_actLit,_varsBoundNow),
	insertNegLit(_negLit,_remVars,_varsBoundNow,_oldLits,_lits).
%  this predicate determines which negated literals are subjected
%  to the re-ordering heuristic ("put ngated predicates at the
%  first place where all their variables are bound.
%  20-Oct-2003/M.Jeusfeld: Apply this to virtuall ALL negated
%  literals. Otherwise, we will generate under some circumstances
%  some rules whose conditions starts with not(lit) where lit is
%  containing variables.
%  See also CBNEWS.doc, point 207

earlyRedNegLiteral(not(_lit)) :-
	_lit =.. [_func|_],
        !.
%  old restriction disabled now:
% 	memberchk(_func,[IDENTICAL,UNIFIES,EQ,From,To,Label,P]),!.
%

earlyRedNegLiteral('NE'(_x,_y)).
% ================  recursive rules ==================================

recHeuristic([]).
recHeuristic([_recCycle|_recCycles]) :-
	getHeadLiterals(_recCycle,_headLiterals),
	storeRecCostEstimates(_headLiterals),
	recHeuristic(_recCycles).

storeRecCostEstimates([]) :-
	storeRecCostInfos.
storeRecCostEstimates([_ruleId-_head|_ruleInfos]) :-
	pc_current_key('QO_recRules',_ruleId),!,
	storeRecCostEstimates(_ruleInfos).
storeRecCostEstimates([_ruleId-_head|_ruleInfos]) :-
	getVartabFromRuleInfo(_ruleId,_vartab),
	countMaximalExtension(_head,_vartab,_costInfos),
	pc_rerecord('QO_recRules',_ruleId,_costInfos),
	storeRecCostEstimates(_ruleInfos).

storeRecCostInfos :-
	findall(_head,
		(
			pc_current_key('QO_recRules',_ruleId),
		 	pc_recorded('QO_recRules',_ruleId,cost(_head,_costInfos)),
		 	storeRecCostInfosForHead(_head,_costInfos),
		 	pc_erase('QO_recRules',_ruleId)),
		_).

storeRecCostInfosForHead(_,[]).
storeRecCostInfosForHead(_head,[_ad-_cost|_costInfos]) :-
	storeCost(_head,_ad,_cost,_cost),
	storeRecCostInfosForHead(_head,_costInfos).

countMaximalExtension(_head,_vartab,cost(_head,_costInfos)) :-
	buildAllAds(_head,_args,_ads),
	countMaximalExtensionWithAds(_args,_ads,_vartab,_costInfos).
%  Here, the maximum extension of the recursive literal should actually be computed.
%  This causes problems if the extension is very small. Then left-recursive
%  rules occur that thus with small extensions cannot be computed.
%  Therefore infinity is used here, so that the recursive literals stand as far right as possible.
%  30.3.98/CQ

countMaximalExtensionWithAds(_,[],_vartab,[]).
countMaximalExtensionWithAds(_args,[_ad|_ads],_vartab,[_ad-infinity|_counts]) :-
	%  countMaximalExtensionWithAd(_args,_ad,_vartab,1,_count),

	countMaximalExtensionWithAds(_args,_ads,_vartab,_counts).

countMaximalExtensionWithAd([],[],_,_count,_count).
countMaximalExtensionWithAd([_arg|_args],[f|_ads],_vartab,_oldCount,_count) :-
	!,
	countInstancesRFVartab(_arg,_vartab,_inst),
	_newCount is _oldCount * _inst,
	countMaximalExtensionWithAd(_args,_ads,_vartab,_newCount,_count).
countMaximalExtensionWithAd([_arg|_args],[_|_ads],_vartab,_oldCount,_count) :-
	countMaximalExtensionWithAd(_args,_ads,_vartab,_oldCount,_count).
