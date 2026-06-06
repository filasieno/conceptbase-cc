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
% File:         AssertionCompiler.pro
% Version:      2.2
%
%
% Date released : 96/01/10  (YY/MM/DD)
%
% SCCS-Source-Pool : /home/CBase/CB_NewStruct/ProductPOOL/serverSources/Prolog_Files/SCCS/s.AssertionCompiler.pro
% Date retrieved : 96/01/17 (YY/MM/DD)
% *************************************************************************
% ----------------------------------------------------------------------------
%
% Exported predicates:
% ---------------------
%
%   + compileAssertion/3
%
% 	25-Jul-90 MSt: assertions which are instances of MSFOLquery are
% 			no longer compiled
%
%
% Nomenclature
% IDS : structure of the form (_rID,_nID) : _rID is the ID of the object that
% contains the rule text, _nID is a new ID (if you know the purpose, please document it here)
% ID : an OID
% DL : DATALOG-neg
% PL : PROLOG code
%
%
%
% Metaformula changes (10.1.96):
% new predicate
% handleRangeform/4, which consolidates code generation for the formulas
% produced in generate-Rangeform.
% For rule and constraint, handleRangeform remains unchanged.
% If the formula is a meta-formula, no code is generated here for the formula
% itself, but for its instantiations. This is done in the
% AssertionTransformer module.
%
% Apr-98/Wang handleCode,generateMRules, generatePROLOGCode are initialized here (complete block removed).
% Processing of Prolog code generation in RuleBase is done only after optimization.
% instead initDatalogRulesInfo is done here after Datalog code generation.
%

:- module('AssertionCompiler',[
'compileAssertion'/3
,'currentCompiledRule'/1
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').
:- use_module('AssertionTransformer.swi.pl').
:- use_module('BDMIntegrityChecker.swi.pl').
:- use_module('LTcompiler.swi.pl').
:- use_module('PropositionProcessor.swi.pl').
:- use_module('SearchSpace.swi.pl').
:- use_module('validProposition.swi.pl').
:- use_module('GeneralUtilities.swi.pl').
:- use_module('RuleBase.swi.pl').
:- use_module('PrologCompatibility.swi.pl').
:- dynamic 'currentCompiledRule'/1 .
:- style_check(-singleton).
% *******************************************************
%  compileAssertion ( _assID , _text , _superclasslist )
%
%  _assID : ground : propId
%  _text : ground : atom surrounded by $
%  _superclasslist : ground : list
%
%  compileAssertion compiles assertion _id with
%  textrepresentation _text. _superclasslist contains
%  assertionclasses e.g. MSFOLquery or MSFOLrule to which
%  assertion _id belongs.
% *******************************************************

compileAssertion( _, _, []) :-  !.
%  Assertion has been already told
%

compileAssertion(_id,_text,[_fc|_rc]) :-
	    existing_relation(_id,_fc),
            !,
            compileAssertion(_id,_text,_rc).
%  new Rule: to be compiled to PROLOG-Code
%

compileAssertion(_ruleID,_text,['MSFOLrule'| _more]) :-
	%  generate optimized datastructure
	%

	setQueryFlag('RC'),
	pc_update(currentCompiledRule(_ruleID)),
	generateRangeform(rule,_ruleID, _text, _rangerule, _vartab),
	!,
	handleRangeform(rule, _rangerule,_vartab,_ruleID),
	%  check Integrity and generate triggers for integrity-checking
	%

	compileAssertion(_ruleID,_text, _more).
compileAssertion(_queryID,_text,['MSFOLquery'| _more]).
% 9-Mar-1993/MJf: MSFOLconstraint instead of BDMConstraint

compileAssertion( _constrID, _text, ['MSFOLconstraint' | _more]) :-
	%  generate optimized datastructure
	%

	setQueryFlag('RC'),
	pc_update(currentCompiledRule(_constrID)),
	generateRangeform(constraint, _constrID,_text, _rangeform, _vartab),
	handleRangeform(constraint, _rangeform,_vartab,_constrID),
	%  check Integrity and generate triggers for integrity-checking
	%

	compileAssertion(_constrID,_text, _more).
compileAssertion(_,_,_) :-
	'WriteTrace'(low,'AssertionCompiler','Assertion was not compiled'),
	!,
	fail.
% ===========================================================
% =                LOCAL PREDICATES DEFINITION              =
% ===========================================================
% *******************************************************
%  existing_relation ( _id , _assclass )
%
%  _id       : ground
%  _assclass : ground
%
%  checks wether the instantiation link between assertion
%  _id and its assertion class _assclass exists with a not
%   finished transaction time. This means that such a link
%  is already believed and a compilation again is not
%  necessary.
% *******************************************************

existing_relation(_assid,_assclass) :-
	get_KBsearchSpace(_kb,_rbt),
	set_KBsearchSpace(currentOB,'Now'),  % see also CBNEWS[126]/MJf
	((
	    %  either there is a relation ...
	    %

	    name2id(_assclass,_assclassID),
	    retrieve_proposition( 'P'( _id, _assid, '*instanceof', _assclassID))
	);(
	    %  ... or NOT: reinstall old settings of KBsearchSpace
	    %

	    set_KBsearchSpace(_kb,_rbt),
	    !
	    ,fail
	)),
	%  ... reinstall in case of success, too
	%

	set_KBsearchSpace(_kb,_rbt),
	!.
%  structure of the IDS (ID struct)

create_IDS(_rID,id(_rID,_nID)) :-
	newOID(_nID).
% *******************************************************
%  newOID(_nID)
%
%  _nID : (output) : OID
%
%  self-explaining, isn't it ?
%  it would not be bad if there were a test for this as well ??
% *******************************************************

newOID(_nID) :-
	assign_ID('P'(_nID,_,_,_)).
% *******************************************************
%  handleRangeform(_mode,_rangeformula,_vartab,_ID
%
%  _mode: rule or constraint
%  _rangeformula: formula to be processed in
%                 in rangeform format
%                 or the atom 'metaFormula' if the
%                 formula is a meta formula
%  _varTab:       variable table
%  _ID: oid of the formula text
%
%  handleRangeform triggers code generation for simple
%  formulas. If the formula is a metaformula, no code is generated
%  here for the formula itself, but for the partially evaluated
%  formula instances.
% *******************************************************
%  Metaformula adjustment:
%    If the formula is a metaformula, then
%    no code is generated for the formula itself, but
%    for its instances.
%    see AssertionTransformer, predicate tellGenFormulas
%    otherwise as before
%    R.S. 9.1. 1996
%

handleRangeform(_,'metaFormula',_,_) :- !.
%  redundant formulas:
%    formulas that contain statements about instances of objects which
%    cannot have instances are ignored.
%    example:
% 	exists y/Proposition In(y,4) .....
%
%    can be replaced by TRUE because object 4 cannot have instances.
%    whether such a case applies is decided in RangeformSimplifier.
%

handleRangeform(_,'redundant',_,_) :- !.
handleRangeform(rule,_rangerule,_vartab,_ruleID) :-
	%  check Integrity and generate triggers for integrity-checking
	%

	tell_BDMRule(_rangerule,_vartab,_ruleID),
	!,
	create_IDS(_ruleID,_rIDS),
	% compile to Datalog
	%

	generateDatalog(_ruleID,_rIDS,_rangerule,_vartab,_ruleDLs),
	!,
	%  Generate Rule Infos Sep-97/RS,CQ

	initDatalogRulesInfo(_ruleDLs,rule,_ruleID,_rIDS,_vartab).
handleRangeform(constraint,_rangeform,_vartab,_constrID) :-
	%  check Integrity and generate triggers for integrity-checking
	%

	tell_BDMIntegrityConstraint( _rangeform,_vartab,_constrID),
	!.
