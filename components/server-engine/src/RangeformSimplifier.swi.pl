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
%
% File:         %M%
% Version:      %I%
%
%
% Date released : %E%  (YY/MM/DD)
%
% SCCS-Source-Pool : %P%
% Date retrieved : %D% (YY/MM/DD)
% ----------------------------------------------------------
%
% In the RangeformSimplifier module, it is investigated whether a formula
% is redundant. This means that the formula contains In or A literals
% that can have no solution.
%
%
% Example constraint
% forall c,x In(c,Integer) and In(x,c) ==> ....
%
% This formula is a meta formula. As a simplified formula,
% e.g.
% forall x In(x,4) ==> ....
% is generated.
% The object "4" cannot have instances, however. Therefore the
% formula is always true, since the condition part is false.
%
% For rules, it is to be noted that these are syntactically implications,
% but the implication means:
%
% Insert the conclusion when the condition part is true.
% Redundant rules are those that cannot fire, because
% the condition part is false.
%
% In the range form this condition part is negated ->
% redundant are the rules whose negated condition part is true ->
% rules whose condition part has the above form, i.e.
%
% forall <false>
%
% are redundant.
%
% Furthermore rules of the form forall x/c ==> In(x,c) are redundant and
% lead to infinite loops when computing the instances of c. A
% simple case is currently caught.
%

:- module('RangeformSimplifier',[
'isRedundant'/2
,'isTokenAsClass'/1
,'simpleClass'/1
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').
:- use_module('BDMLiteralDeps.swi.pl').
:- use_module('MetaRFormulas.swi.pl').
:- use_module('GeneralUtilities.swi.pl').
:- use_module('BIM2C.swi.pl').
:- use_module('Literals.swi.pl').
:- use_module('MetaUtilities.swi.pl').
:- use_module('SemanticOptimizer.swi.pl').
:- style_check(-singleton).
%  ***************** i s R e d u n d a n t **************************
%
%  Parameter
%  _mode: 'rule' or 'constraint'
%  _f: formula in range form
%
%  currently only calls ClassIsToken; perhaps there are still more
%  redundant formulas and someone has an idea how to
%  detect them.
%
%  ******************************************************************

isRedundant(_mode,_f) :-
	'ClassIsToken'(_mode,_f),!.
isRedundant(rule,rangerule(_vars,_f,_lit)) :-
   'ConclusionInCondition'(rule,rangerule(_vars,_f,_lit)),
   'WriteTrace'(veryhigh,'RangeformSimplifier',['The conclusion predicate ',idterm(_lit), ' occurs in the condition ',
              idterm(_f), ' of the rule.']),
   !.
%  ticket #301: the condition of a rangerule is represented as
%  forall(_vars, _cond, FALSE); the whole rule can be ignored
%  if the condition is always false.

isRedundant(rule,forall(_vars, _cond, 'FALSE')) :-
   alwaysFalse(_cond),
   'WriteTrace'(veryhigh,'RangeformSimplifier',['The rule condition ',idterm(_cond), ' is always false.']),
   !.
%  Ticket #266: remove also tautologies

isRedundant(constraint,_f) :-
	alwaysTrue(_f),
        !.
%  ***************** C o n c l u s i o n I n C o n d i t i o n*******
%
%  Parameter
%  _mode: rule or constraint
%  _f: formula in rangeform
%
%  finds rules of the form  $forall In(x,c) and ... ==> In(x,c)$
%
%
%  ******************************************************************

'ConclusionInCondition'(rule,rangerule(_vars,_f,_lit)) :-
	rFormulaParts(_f,forall,_,_,_sf),_sf == 'FALSE',!,
	getAllLitsForallQuant(_f,_lits),!,
	memberchk(_lit,_lits).
%  ***************** C l a s s I s T o k e n ************************
%
%  Parameter
%  _mode: rule or constraint
%  _f: formula in rangeform
%
%  collects the In and A literals that appear in a universal quantifier
%
%
%  ******************************************************************

'ClassIsToken'(constraint,rangeconstr(forall(_v,_l,_s))) :-
	!,
	getInsAndAsForallQuant(rangeconstr(forall(_v,_l,_s)),_inLits,_aLits),!,
	isTokenAsClass(_inLits,_aLits),!.
'ClassIsToken'(rule,rangerule(_vars,forall(_v,_l,_s),_lit)) :-
	!,
        getInsAndAsForallQuant(forall(_v,_l,_s),_inLits,_aLits),!,
        isTokenAsClass(_inLits,_aLits),!.
%  This pattern appears only in MetaSimplifier when the
%    rangerule or rangeconstr functor was temporarily
%    deleted.
%    isRedundant is also called from there to determine whether
%    a formula is redundant. However, the check applies
%    only to In literals, because the variable table for concernedClass
%    computation is filled only after back-translation of the generated
%    formulas into the $$ format.
%

'ClassIsToken'(constraint,_f) :-
	rFormulaParts(_f,forall,_,_,_),!,
	getInsForallQuant(_f,_inLits),!,
	isTokenAsClass(_inLits),!.
'ClassIsToken'(rule,_f) :-
        rFormulaParts(_f,forall,_,_,_),!,
        getInsForallQuant(_f,_inLits),!,
        isTokenAsClass(_inLits),!.
%  ***************** g e t I n s ( A n d A s ) F o r a l l Q u a n t
%
%  Parameter
%  _f: formula in rangeform
%  _inLits: In -literals
%  _aLits: A-literals
%
%  collects the In and A literals that appear in a universal quantifier
%
%
%  ******************************************************************

getInsAndAsForallQuant(_f,_inLits,_aLits) :-
	rFormulaParts(_f,forall,_,_range,_sf),!,
	filterInPreds(_range,_inLits1),!,
	filterAPreds(_range,_aLits1),!,
	getInsAndAsForallQuant(_sf,_inLits2,_aLits2),!,
	append(_inLits1,_inLits2,_inLits),!,
	append(_aLits1,_aLits2,_aLits),!.
getInsAndAsForallQuant(_,[],[]).

getInsForallQuant(_f,_inLits) :-
	rFormulaParts(_f,forall,_,_range,_sf),!,
	filterInPreds(_range,_inLits1),!,
	getInsForallQuant(_sf,_inLits2),!,
	append(_inLits1,_inLits2,_inLits),!.
getInsForallQuant(_,[]).

getAllLitsForallQuant(_f,_lits) :-
	rFormulaParts(_f,forall,_,_range,_sf),!,
	getAllLitsForallQuant(_sf,_otherLits),!,
	append(_range,_otherLits,_lits),!.
getAllLitsForallQuant(_f,[]).

isTokenAsClass(_inLits,_) :-
	isTokenAsClass(_inLits),!.
isTokenAsClass(_,_aLits) :-
	isTokenAsClass(_aLits),!.
isTokenAsClass(['In'(_x,_c)|_]) :-
	is_id(_c),!,
	noToken(_c),!,fail.
isTokenAsClass(['In'(_x,_c)|_]) :-
	is_id(_c),!,
	simpleClass(_id),
	prove_literal('In'(_c,_id)),!.
isTokenAsClass(['In'(_x,_c)|_ins]) :-
	isTokenAsClass(_ins).
isTokenAsClass(['A'(_x,_m,_y)|_]) :-
	is_id(_x),
	select2id(_m,_id),
	!,
	'ConcernedClass'('A'(_x,_m,_y),_cc),
	prove_literal('P'(_cc,_c,_m,_d)),
	((simpleClass(_idc),prove_literal('In'(_c,_idc)));(simpleClass(_idd),prove_literal('In'(_d,_idd)))),!.
isTokenAsClass(['A'(_x,_m,_y)|_]) :-
	select2id(_m,_id),
	!,
	'ConcernedClass'('A'(_x,_m,_y),_cc),
	prove_literal('P'(_cc,_c,_m,_d)),
	((simpleClass(_idc),prove_literal('In'(_c,_idc)));(simpleClass(_idd),prove_literal('In'(_d,_idd)))),!.
isTokenAsClass(['A'(_x,_m,_y)|_as]) :-
	isTokenAsClass(_as).

simpleClassGround(_id) :-
	id2name(_id,_name),
	memberchk(_name,['Boolean','Integer','Real','String','TransactionTime',
	'MSFOLassertion','MSFOLrule','MSFOLconstraint',
	metaMSFOLconstraint,metaMSFOLrule,
	'BDMConstraintCheck','BDMRuleCheck',
	'LTruleEvaluator','ExternalReference',
	'BuiltinQueryClass','AnswerRepresentation',
	'GraphicalType','X11_Color','ATK_TextAlign',
	'ATK_Fonts','ATK_LineCap','ATK_ShapeStyle']),!.

simpleClass(_id) :-
	member(_name,['Boolean','Integer','Real','String','TransactionTime',
	'MSFOLassertion','MSFOLrule','MSFOLconstraint',
	metaMSFOLconstraint,metaMSFOLrule,
	'BDMConstraintCheck','BDMRuleCheck',
	'LTruleEvaluator','ExternalReference',
	'BuiltinQueryClass','AnswerRepresentation',
	'GraphicalType','X11_Color','ATK_TextAlign',
	'ATK_Fonts','ATK_LineCap','ATK_ShapeStyle']),
	name2id(_name,_id).

noToken(_id) :-
	id2name(_id,_name),
	memberchk(_name,['Class','Individual','Proposition','Attribute','InstanceOf','Isa']),!.
