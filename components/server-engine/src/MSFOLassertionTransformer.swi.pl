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
% File :        MSFOLassertionTransformer.pro
% Version :     7.4
% Creation:     2-Nov-93, Kai v. Thadden (RWTH)
% Last change : 31 Aug 1994, 2-Nov-93, Kai v. Thadden (RWTH)
% Release:      7
%
%
% ----------------------------------------------------------------------------
%
% Transformation of miniscope form into range form
%
%

:- module('MSFOLassertionTransformer',[
'miniscopeToRangeform'/2
,'checkArgLabel'/1
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').
:- use_module('MSFOLassertionParserUtilities.swi.pl').
:- use_module('PrologCompatibility.swi.pl').
:- use_module('GeneralUtilities.swi.pl').
:- use_module('MetaUtilities.swi.pl').
% ===========================================================
% =              LOCAL PREDICATE DECLARATION                =
% ===========================================================

:- style_check(-singleton).
% ===========================================================
% =             EXPORTED PREDICATES DEFINITION              =
% ===========================================================
% *******************************************************
%  miniscopeToRangeform(_formulaMSFOL,_formulaRF)
%  _formulaMSFOL : term (i)
%  _formulaRF    : term (o)
%
%  Take a minscope formula _formulaMSFOL and produce the
%  rangeform _formulaRF
% *******************************************************

miniscopeToRangeform( 'MSFOLconstraint'(_formulaMSFOL),rangeconstr(_formulaRF)) :-
	miniscopeToRangeform2(_formulaMSFOL,_formulaRF).
miniscopeToRangeform('MSFOLrule'(_vars,_conditionMSFOL,_conclusionMSFOL),rangerule(_vars,_conditionRF,_conclusionRF)) :-
	miniscopeToRangeform2(_conditionMSFOL,_conditionRF),
	miniscopeToRangeform2(_conclusionMSFOL,_conclusionRF).
% ===========================================================
% =                LOCAL PREDICATES DEFINITION              =
% ===========================================================
% *******************************************************
%  miniscopeToRangeform2(_miniF,_rangeF)
%  _miniF : term (i)
%  _rangeF: term (o)
%
%  Take the minscope formula _miniF and produce the range
%  form.
% *******************************************************
%  Case 1: forall

miniscopeToRangeform2(forall(_var,_type,_term),forall(_vars,_ranges,_rangeterm)) :-
	checkArgLabel(_type),
	buildRanges(forall,forall(_var,_type,_term),_vars,_ranges,_restterm),
	miniscopeToRangeform2(_restterm,_rangeterm).
%  Case 2: exists

miniscopeToRangeform2(exists(_var,_type,_term),exists(_vars,_ranges,_rangeterm)) :-
	checkArgLabel(_type),
	buildRanges(exists,exists(_var,_type,_term),_vars,_ranges,_restterm),
	miniscopeToRangeform2(_restterm,_rangeterm).
%  Case 3: or

miniscopeToRangeform2(or([]),or([])) :- !.
miniscopeToRangeform2(or([_t|_ts]),or([_rt|_rts])) :-
	miniscopeToRangeform2(_t,_rt),
	miniscopeToRangeform2(or(_ts),or(_rts)).
%  Case 4: and

miniscopeToRangeform2(and([]),and([])) :- !.
miniscopeToRangeform2(and([_t|_ts]),and([_rt|_rts])) :-
	miniscopeToRangeform2(_t,_rt),
	miniscopeToRangeform2(and(_ts),and(_rts)).
%  Case 5: Literals

miniscopeToRangeform2(not(lit(_l)),not(_l)) :- !.
miniscopeToRangeform2(lit(_l),_l) :- 
   _l =.. [_f|_args],
   checkArgLabel(_args), !.  % no unknown object name in _args
%  check whether label is tagged as unknown by parseAss.dcg; see also ticket #189

checkArgLabel(_label) :-
   atom(_label),
   pc_atomconcat('%%UNKNOWN--',_,_label),
   increment('error_number@F2P'),
   !,
   fail.
checkArgLabel([]) :- !.
checkArgLabel([_t|_rest]) :-
  checkArgLabel(_t),
  checkArgLabel(_rest).
checkArgLabel(_).  % we except anything that is no matching %%UNKNOWN--*
% *******************************************************
%  buildRanges assembles the appropriate range for a quantifier expression
%  buildRanges(_mode,_term,_vars,_range,_rest)
%  _mode: (i) forall/exists, quantifier type for which the range
%         is generated
%  _term: (i) miniscope form from which range literals are taken
%  _vars: (o) variables to which the range applies (e.g. two quantifiers
%         of the same type may be combined)
%  _range:(o) the range for the current quantifier
%  _rest: (o) the part of the formula that is not in the range
% *******************************************************
%  Case 1: forall
%  case 1a) forall quantifier with one class

buildRanges(forall,forall(_v,[_c],_t),[_v|_vs],[_inlit|_rs],_restterm) :-
	!,
	createInLit(_v,_c,_inlit),
	buildRanges(forall,_t,_vs,_rs,_restterm),
	!.
%  Case 1b) forall quantifier where _v is in several classes
%

buildRanges(forall,forall(_v,[_c|_cs],_t),_vs,[_inlit|_rs],_restterm) :-
	!,
	createInLit(_v,_c,_inlit),
	buildRanges(forall,forall(_v,_cs,_t),_vs,_rs,_restterm),
	!.
%  case 1c) forall quantifier with one class, without class list. Could be merged with case 1a).
%

buildRanges(forall,forall(_v,_c,_t),[_v|_vs],[_inlit|_rs],_restterm) :-
	createInLit(_v,_c,_inlit),
	buildRanges(forall,_t,_vs,_rs,_restterm),
	!.
buildRanges(forall,or(_ts),[],_ranges,_restterm) :-
	getRangeFromOrlist(_ts,_ranges,_noranges),
	((_noranges == [],!, _restterm = lit('FALSE'))  % case1:all elements of the or-list could be drawn into the range
	;(_noranges = [_restterm])  % case2:all elements of the or-list except one could be drawn into the range
	;(_restterm = or(_noranges))  % case3:_rs contains at least two elements
	).
buildRanges(forall,not(lit(_l)),[],[_l],lit('FALSE')) :- !.
buildRanges(forall,_t,[],[],_t) :- !.  % rest term
%  Case 2: exists
%  case 1a) exists quantifier with one class

buildRanges(exists,exists(_v,[_c],_t),[_v|_vs],[_inlit|_rs],_restterm) :-
	createInLit(_v,_c,_inlit),
	buildRanges(exists,_t,_vs,_rs,_restterm),
	!.
%  Case 1b) exists quantifier where _v is in multiple classes
%

buildRanges(exists,exists(_v,[_c|_cs],_t),_vs,[_inlit|_rs],_restterm) :-
	createInLit(_v,_c,_inlit),
	buildRanges(exists,exists(_v,_cs,_t),_vs,_rs,_restterm),
	!.
%  case 1c) forall quantifier with one class, without class list. Could be merged with case 1a).
%

buildRanges(exists,exists(_v,_c,_t),[_v|_vs],[_inlit|_rs],_restterm) :-
	createInLit(_v,_c,_inlit),
	buildRanges(exists,_t,_vs,_rs,_restterm),
	!.
buildRanges(exists,and(_ts),[],_ranges,_restterm) :-
	getRangeFromAndlist(_ts,_ranges,_noranges),
	((_noranges == [],!, _restterm = lit('TRUE'))  % case1:all elements of the or-list could be drawn into the range
	;(_noranges = [_restterm])  % case2:all elements of the or-list except one could be drawn into the range
	;(_restterm = and(_noranges))  % case3:_rs contains at least two elements
	).
%  avoids creation of unnecessary TRUE literals; an
%  equivalent construction in the forall case is not
%  necessary, because pushNegationInvards converts
%  not(lit(TRUE)) to lit(FALSE), which cannot be unified
%  with the general not(lit)-case

buildRanges(exists,lit('TRUE'),[],[],lit('TRUE')) :- !.
buildRanges(exists,lit(_l),[],[_l],lit('TRUE')) :- !.
buildRanges(exists,_t,[],[],_t) :- !.  % rest term
% *******************************************************
%  getRangeFromOrlist splits an _orlist into elements that
%  belong in the range and elements that do not (for forall)
% *******************************************************

getRangeFromOrlist([],[],[]) :- !.
getRangeFromOrlist([not(lit(_l))|_orlist],[_l|_rs],_rest) :-
	!,
	getRangeFromOrlist(_orlist,_rs,_rest).
getRangeFromOrlist([_t|_orlist],_rs,[_t|_rest]) :-
	!,
	getRangeFromOrlist(_orlist,_rs,_rest).
% *******************************************************
%  getRangeFromAndlist splits an _andlist into elements that
%  belong in the range and elements that do not (for exists)
% *******************************************************

getRangeFromAndlist([],[],[]) :- !.
getRangeFromAndlist([lit(_l)|_andlist],[_l|_rs],_rest) :-
	!,
	getRangeFromAndlist(_andlist,_rs,_rest).
getRangeFromAndlist([_t|_andlist],_rs,[_t|_rest]) :-
	!,
	getRangeFromAndlist(_andlist,_rs,_rest).
% *******************************************************
%  createInLit(_v,_c,_inlit)
%  creates for variable _v and class _c a literal In(_v,_c).
%  If _c is a derive expression (i.e. a generic query class
%  possibly with parameters), the appropriate query call is used.
% *******************************************************

createInLit(_v,_c,_inlit) :-
        checkArgLabel(_c),  % ticket #272
	_inlit1 = 'In'(_v,_c),
	resolveDeriveExpression(_inlit1,_inlit).
