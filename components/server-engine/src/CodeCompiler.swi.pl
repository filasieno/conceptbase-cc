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
% File :        CodeCompiler.pro
% Version :     1.5
% Creation:     28-Mar-94, Kai v. Thadden (RWTH)
% Last change : 09-Jan-2003, Manfred Jeusfeld (Uni Tilburg)
% Release:      1
%
%
% ------------------------------------------------------------
% This module transforms Datalog rules into executable code for (meta-)evaluators.
% Two evaluators are currently available:
% - normal Prolog code (with magic cache; see Literals.pro)
% - later, the AlgebraCompiler may be integrated here as well.
%
%
%  Naming convention for variables:
%  DL : DATALOG notation (note: all variables are atoms marked by underscore, e.g. _x)
%  PL : PROLOG variables
%

:- module('CodeCompiler',[
'generatePROLOGCode'/2
,'specialFunctor'/2
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').
% ===========================================================
% =                  IMPORTED PREDICATES                    =
% ===========================================================

:- use_module('GeneralUtilities.swi.pl').
:- use_module('LTstubs.swi.pl').
:- use_module('RuleSpecializer.swi.pl').
:- use_module('RuleOptimizer.swi.pl').
:- use_module('PrologCompatibility.swi.pl').
:- use_module('Literals.swi.pl').
:- use_module('MetaUtilities.swi.pl').
% ===========================================================
% =              LOCAL PREDICATE DECLARATION                =
% ===========================================================

:- style_check(-singleton).
% ===========================================================
% =             EXPORTED PREDICATES DEFINITION              =
% ===========================================================
% *******************************************************
%  generatePROLOGCode does the following:
% - the rule head looks as before: LTevalRule(_id,
% - before each individual literal there is a prove_literal$Literals
% - atoms with underscores are replaced by proper Prolog variables.
% - a time literal is built in to handle rollback requests correctly.
%   (This should be done at a later point in time.)
% Important:
% - the first rule of the list is the main invocation rule
%
% *******************************************************

generatePROLOGCode([],[]).
generatePROLOGCode([_clauseDL|_clauseDLs],[_clausePL|_clausePLs]) :-
	generatePROLOGCode(_clauseDL,_clausePL),
	!,
	generatePROLOGCode(_clauseDLs,_clausePLs).
generatePROLOGCode(_clauseDL,_clausePL) :-
	_clauseDL =.. [':-',_clauseHead,_clauseBody],
	insertProveLiteral(_clauseBody,_nclauseBody),
	_nclauseDL =.. [':-',_clauseHead,_nclauseBody],
	insertPROLOGVars(_nclauseDL,_clausePL).
% ===========================================================
% =                LOCAL PREDICATES DEFINITION              =
% ===========================================================

generate_specialized_rules([],[]).
generate_specialized_rules([_first|_rest],_rs) :-
	specialize_rule(_first,_sf),
	generate_specialized_rules(_rest,_sr),
	append(_sf,_sr,_rs).

generate_optimized_rules([],[]).
generate_optimized_rules([_first|_rest],_rs) :-
	getRuleId(_id),
	(pc_atomconcat('#',_ido,_id);_ido = _id),
	rewrite_rule(_ido,_first,_flist),
	generate_optimized_rules(_rest,_rlist),
	append(_flist,_rlist,_rs).
%  Ticket #147

insertProveLiteral((bound(_x),_rest),(_blit,_nrest)) :-
        !,
        produceBoundCall(bound(_x),_blit),
        insertProveLiteral(_rest,_nrest).
%  case 1: Call of a code part belonging to a rule has a functor of the form ID_123_4. Therefore no prove_literal may be written, since the rule must not be accessed via the proposition interface.
%

insertProveLiteral((_lit,_rest),(_lit,_nrest)) :-
	specialFunctor(_lit),
	!,
	insertProveLiteral(_rest,_nrest).
%  14-Nov-2005/M. Jeusfeld: replace calls In(x,qc) where qc is a query class
%  by qc(x). This reduces the call depth for answering queries since a call
%  In(x,qc) will always be computed by a call qc(x).
%  Note: this transformation can only be done for queries that have neither
%  parameters, nor retrieved attributes, nor computed attributes. Otherwise,
%  the query literal would have a form like qc(x,a,b,...).

insertProveLiteral(('In'(_x,_qc),_rest),(_qlit1,_nrest)) :-
        is_id(_qc),
        prove_literal('In_s'(_qc,id_65)),  % id_65=QueryClass
        \+ hasAdditionalArgs(_qc),  % ticket #213
        _qlit =.. [_qc,_x],  % may not have further args like parameters, computed/retrieved attribute
        % isDeducable(_qlit),
   %  ticket #213: isDeducable not yet precomputed here

        insertProveLiteral(_qlit,_qlit1),     
        !,
        insertProveLiteral(_rest,_nrest).
%  case 2: if the literal is negated, insert not_prove_literal

insertProveLiteral((not(_lit),_rest),(_nlit,_nrest)) :-
	!,
	insertNotProveLiteral(_lit,_nlit),
	insertProveLiteral(_rest,_nrest).
%  case 3: in all other cases, wrap prove_literal around the literal
%

insertProveLiteral((_lit,_rest),('\'Literals\':prove_literal'(_lit),_nrest)) :-
	!,
	insertProveLiteral(_rest,_nrest).
%  cases 3/4/5 as above. End of the loop.
%

insertProveLiteral(_lit,_lit) :-
	specialFunctor(_lit),
	!.
insertProveLiteral(not(_lit),_nlit) :-
	!,
	insertNotProveLiteral(_lit,_nlit).
insertProveLiteral(_lit,'\'Literals\':prove_literal'(_lit)).
%  insertNotProveLiteral ensures that for a literal 'not P(x)'
%  the Prolog code not_prove_literal$Literals(P(x)) is generated.
%  Previously, 'not prove_literal$Literals(P(x))' was generated instead.
%  The new version allows explicit treatment of negation in
%  Literals.pro.   9-Jan-2003/M.Jeusfeld

insertNotProveLiteral(_lit,not(_lit)) :- specialFunctor(_lit).
insertNotProveLiteral(_lit,'\'Literals\':not_prove_literal'(_lit)).
%  Ticket #147

produceBoundCall(bound(_x),'\'Literals\':bound'(_x)).
%  specialFunctor/1 does not insert prove_literal when _lit has a special functor
%

specialFunctor(_lit) :-
	functor(_lit,_fun,_ar),
	specialFunctor(_fun,_ar),
	!.
%  Necessary because not is a built-in predicate and therefore
%  the next rule would otherwise be recognized as specialFunctor.

specialFunctor(not(_)) :-
    !,
    fail.
%  Necessary for Datalog queries so that built-in predicates are not
%  wrapped with prove_literal

specialFunctor(_lit) :-
    pc_has_a_definition(_lit).
%  rule head that was generated by the LT compiler
%

specialFunctor(_fun,_) :-
	pc_atomconcat('ID_',_,_fun).
%  prove_literal is already before it
%

specialFunctor('Literals':prove_literal,1).
%  is the head of a query
%

specialFunctor(_fun,2) :-
	pc_atomconcat('LTevalQuery',_,_fun).
%  ==/2 and ground/1 are possibly written into a rule by the QueryCompiler.
%

specialFunctor('==',2).
specialFunctor('ground',1).
specialFunctor(del,1).
specialFunctor(ins,1).
specialFunctor(red,1).
specialFunctor(new,1).
specialFunctor(plus,1).
specialFunctor(minus,1).
%  ticket #213: test whether _qc has some additional arguments, i.e.
%  retrieved/computed attributes or parameters.

hasAdditionalArgs(_qc) :-
   prove_literal('A'(_qc,'QueryClass',retrieved_attribute,_));
   prove_literal('A'(_qc,'QueryClass',computed_attribute,_));
   prove_literal('A'(_qc,'GenericQueryClass',parameter_attribute,_)).
