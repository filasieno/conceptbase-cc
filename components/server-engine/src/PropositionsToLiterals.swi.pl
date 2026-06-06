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
% Creation:
% Last Change   : %E%, Christoph Quix (RWTH)
%
% SCCS-Source-Pool : %P%
% Date retrieved : %D% (YY/MM/DD)
%
% -----------------------------------------------------------------------------
%
% In this Prolog module, predicates are implemented that
% eine list of Propositionen in literals (In,Isa,A,Adot,...) umwandeln.
% This is needed, among other things, for view maintenance and ECA rules.
%
%
%

:- module('PropositionsToLiterals',[
'prop2lit'/3
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').
:- use_module('SearchSpace.swi.pl').
:- use_module('Literals.swi.pl').
:- use_module('PropositionProcessor.swi.pl').
:- use_module('validProposition.swi.pl').
:- use_module('GeneralUtilities.swi.pl').
:- use_module('PrologCompatibility.swi.pl').
:- use_module('GlobalParameters.swi.pl').
:- style_check(-singleton).
% ***************************************************************
%
%  prop2lit(_mode,_props,_lits)
%
%  Description of arguments:
%     mode : Tell/Untell
%    props : List of propositions (input)
%     lits : List of literals (output)
%
%  Description of predicate:
%    Converts Propositions to Literals
% ***************************************************************

prop2lit('Tell',_props,_lits) :-
	init_prop2lit,
	set_KBsearchSpace(newOB,'Now'),
	prop2lit('Tell',_props),
	get_lits(_lits).
prop2lit('Untell',_props,_lits) :-
	init_prop2lit,
	set_KBsearchSpace(oldOB,'Now'),
	prop2lit('Untell',_props),
	get_lits(_lits).

init_prop2lit :-
	pc_rerecord(prop2lit,[]).

get_lits(_lits) :-
	pc_recorded(prop2lit,_lits).

store_lits(_oldlits,[]) :- !.
store_lits(_oldlits,_to_be_added) :-
  append(_oldlits,_to_be_added,_newlits),
  pc_rerecord(prop2lit,_newlits).
%  the first parameter _mode is either 'Tell' or 'Untell'. It helps to limit
%  the search space for isEventLit.

add_lits(_mode,_origlits) :-
  pc_recorded(prop2lit,_oldlits),
  filterMatches(_mode,_oldlits,_origlits,_filteredlits),
  store_lits(_oldlits,_filteredlits),
  !.
add_lits(_mode,_).

filterMatches(_mode,_oldlits,[],[]) :- !.
filterMatches(_mode,_oldlits,[_lit|_rest],_newrest) :-
  redundantLit(_mode,_oldlits,_lit),
  !,
  filterMatches(_mode,_oldlits,_rest,_newrest).
filterMatches(_mode,_oldlits,[_lit|_rest],[_lit|_newrest]) :-
  filterMatches(_mode,_oldlits,_rest,_newrest).

redundantLit(_mode,_oldlits,_lit) :-
  ((get_cb_feature('ViewMaintenanceRules',off),  \+ isEventLit(_mode,_lit));
  member(_lit,_oldlits)),
  !.
%  isEventLit(_mode,_eventlit) is true when _mode(_eventlit) is the
%  event of an ECA rule. The parameter _mode is either 'Tell' or
%  'Untell'.

isEventLit('Tell',_eventlit) :-
  'r@ECAruleManager'(_r,'Tell'(_eventlit),_a,_do,_else,_d,_queue).
isEventLit('Untell',_eventlit) :-
  'r@ECAruleManager'(_r,'Untell'(_eventlit),_a,_do,_else,_d,_queue).
%  Process list first

prop2lit(_mode,[]) :-
	!.
%  frequent case deserves special handling for speeding up computation.
%  Makes ECA computation about 5-8% faster.

prop2lit(_mode,['P'(_id,_x,_l,_y),'P'(_oid,_id,'*instanceof',_cc)|_r]) :-
	attribute('P'(_id,_x,_l,_y)),
	add_lits(_mode,['Adot'(_cc,_x,_y),
	        'Adot_label'(_cc,_x,_y,_l),'In'(_id,_cc),
	        'Aidot'(_cc,_x,_id),'From'(_id,_x),'To'(_id,_y)]),
	!,
	prop2lit(_mode,_r).
prop2lit(_mode,['P'(_id,_x,_l,_y)|_r]) :-
	do_prop2lit(_mode,'P'(_id,_x,_l,_y)),
	!,
	prop2lit(_mode,_r).
%  Ab here for the einzelnen Propositions
%  In_s and In_i

do_prop2lit(_mode,'P'(_oid,_x,'*instanceof',_b)) :-
	prove_literal('Isa'(_b,_c)), 
	add_lits(_mode,['In'(_x,_c)]),
	fail.
%  In_e
%  --- uncomment to support In_e also for ECA rules ---
% do_prop2lit(_mode,P(_oid,_x,'*instanceof',_c)) :-
% 	add_lits(_mode,[In_e(_x,_c)]),
% 	fail.
%
%  detect insertion/deletion of Individuals

do_prop2lit(_mode,'P'(_x,_x,_m,_x)) :-
	add_lits(_mode,['In'(_x,id_7)]),  % id_7=Individual
	fail.
% Isa

do_prop2lit(_mode,'P'(_oid,_a,'*isa',_b)) :-
	prove_literal('Isa'(_x,_a)),
	prove_literal('Isa'(_b,_y)),
	add_lits(_mode,['Isa'(_x,_y)]),
	fail.
%  Adot etc.: new attribute

do_prop2lit(_mode,'P'(_id,_x,_l,_y)) :-
	attribute('P'(_id,_x,_l,_y)),
	prove_edb_literal('In_e'(_id,_cc)),
	retrieve_proposition('P'(_cc,_a,_ml,_b)),
	attribute('P'(_cc,_a,_ml,_b)),
	add_lits(_mode,['Adot'(_cc,_x,_y),
	        'Adot_label'(_cc,_x,_y,_l),
                'In'(_id,id_6),  % id_6=Attribute    
%
% 	        A(_x,_ml,_y),
% 	        A_label(_x,_ml,_y,_l),
% 	        Ai(_x,_ml,_id),
%

	        'Aidot'(_cc,_x,_id)]),
	fail.
%  Adot etc.: new attribute category for an existing attribute

do_prop2lit(_mode,'P'(_oid,_id,'*instanceof',_cc)) :-
	retrieve_proposition('P'(_cc,_a,_ml,_b)),
	attribute('P'(_cc,_a,_ml,_b)),
	retrieve_proposition('P'(_id,_x,_l,_y)),
	attribute('P'(_id,_x,_l,_y)),
	add_lits(_mode,['Adot'(_cc,_x,_y),
	        'Adot_label'(_cc,_x,_y,_l),
%
% 	        A(_x,_ml,_y),
% 	        A_label(_x,_ml,_y,_l),
% 	        Ai(_x,_ml,_oid),
%

	        'Aidot'(_cc,_x,_oid)]),
	fail.
%  simple literals: From,To
%  Known/Label are not generated, can also also not appear in the ON-part of an ECA-rule

do_prop2lit(_mode,'P'(_id,_x,_l,_y)) :-
        attribute('P'(_id,_x,_l,_y)),
	add_lits(_mode,['From'(_id,_x),'To'(_id,_y)]),
         !.
do_prop2lit(_mode,'P'(_id,_x,_l,_y)).
