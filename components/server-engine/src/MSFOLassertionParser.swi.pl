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
% Creation:     2-Dec-1988, Martin Staudt (UPA)
% Last Change   : %E%, Christoph Quix (RWTH)
%
% SCCS-Source-Pool : %P%
% Date retrieved : %D% (YY/MM/DD)
%
% ----------------------------------------------------------------------------
%
% Exported predicates:
% ---------------------
%
%   + parseMSFOLassertion/3
%
%
%   12-Mar-1990/MSt : deriveExpressions are allowed as literal arguments
%   8-Feb-1991/MJf : deriveExpressions Q[...] allowed, Q([...]) still valid
%   26-Mai-1992/kvt : infix abbreviation for AttrValue and InstanceOf
%   7-Jul-1992/kvt : interprets select-expressions
%   24-Jan-1993/DG: IsA changed into Isa; InstanceOf into In;
%   AttrValue into A (by deleting the time component, see CB[154])
%   7-Sep-1994/CQ: Queries and constraints are tested by validMSFOLassertion CB[177]
% Konventionen
% A : Atom
% s : list
% C : Buchstabe (character)
%

:- module('MSFOLassertionParser',[
'parseMSFOLassertion'/3
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').
% ===========================================================
% =                  IMPORTED PREDICATES                    =
% ===========================================================

:- use_module('GeneralUtilities.swi.pl').
:- use_module('parseAss_dcg.swi.pl').
:- use_module('QueryCompiler.swi.pl').
:- use_module('ErrorMessages.swi.pl').
:- use_module('MSFOLpreProcessor.swi.pl').
:- use_module('MSFOLassertionParserUtilities.swi.pl').
:- use_module('AssertionCompiler.swi.pl').
:- use_module('Literals.swi.pl').
:- use_module('VarTabHandling.swi.pl').
:- use_module('PrologCompatibility.swi.pl').
:- use_module('MetaLiterals.swi.pl').
% ===========================================================
% =              LOCAL PREDICATE DECLARATION                =
% ===========================================================

:- style_check(-singleton).
% ===========================================================
% =             EXPORTED PREDICATES DEFINITION              =
% ===========================================================

parseMSFOLassertion(_mode,_stringA,_syntaxtree) :-
	preProcess(_mode,_stringA,_tokens),
	parseMSFOLassertion1(_mode,_tokens,_syntaxtree_1),
	expandMacroPredicates(_syntaxtree_1,_syntaxtree).  % see ticket #124
parseMSFOLassertion(_,_,_) :-
        pc_update('LTerror'(1)),
        !,
        fail.

parseMSFOLassertion1(_mode,_tokens,_syntaxtree) :-
	(_mode == constraint;
	 _mode == rule
	),
    member(ident('~this'),_tokens),
	!,
   	currentCompiledRule(_ruleId),
    (prove_literal('A_e'(_class,'Class',rule,_ruleId));
	 prove_literal('A_e'(_class,'Class',constraint,_ruleId))
	),
   	saveVarTabInsert(['~this'],[_class]),
	parseMSFOLassertion2(_mode,_tokens,_msfolexp),
	insert_this(_msfolexp,_class,_syntaxtree).
parseMSFOLassertion1(_mode,_tokens,_syntaxtree) :-
	parseMSFOLassertion2(_mode,_tokens,_syntaxtree).
% ===========================================================
% =                LOCAL PREDICATES DEFINITION              =
% ===========================================================
%  parseMSFOLassertion2/3 schmeisste den DCG-Parser an
%

parseMSFOLassertion2('QS'(_head,_vars,_lits),_queryconstrtokens, 'MSFOLrule'(_varnames,_cond,_head)) :-
	!,
	%  first parse the tokens of the query constraint like if it was an ordinary constraint
	%

	buildMSFOLconstraint('MSFOLconstraint'(_syntaxtree), _queryconstrtokens,[]),
	!,
	insert_vars(_vars),
	buildDottedOrDeriveLiterals(_lits,_dotlits),
	!,
	%  if the syntaxtree starts with an "and" then push the _dotlits into the and-list
	%

	get_components(1,_vars,_varnames),
	(
	_syntaxtree = and(_fs)->
		append(_dotlits,_fs,_nfs), _cond = and(_nfs);
		append(_dotlits,[_syntaxtree],_condlits), _cond = and(_condlits)
	),
	validMSFOLassertion('MSFOLrule'(_varnames,_cond,_head)).
parseMSFOLassertion2(constraint,_tokens,_syntaxtree) :-
	buildMSFOLconstraint(_syntaxtree,_tokens,[]),
	validMSFOLassertion(_syntaxtree).
parseMSFOLassertion2(rule,_tokens,'MSFOLrule'(_v,_cond,_concl)) :-
        buildAssertionRule(_syntaxtree,_tokens,[]),
	validMSFOLassertion(_syntaxtree),
	_syntaxtree = 'MSFOLrule'(_v,_cond,_concl),
        !.

insert_this('MSFOLconstraint'(_t),_c,'MSFOLconstraint'(forall('~this',_c,and([_t])))).
insert_this('MSFOLrule'(_v,_cond,_concl),_c,'MSFOLrule'(_v,_cond,_concl)).

insert_vars([]).
insert_vars([(_v,_c)|_r]) :-
	saveVarTabInsert([_v],_c),
	insert_vars(_r).
