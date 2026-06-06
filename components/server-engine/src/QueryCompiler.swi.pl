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
% File:         QueryCompiler.pro
% Version:      11.5
% Creation:    24-July-1990, Martin Staudt (UPA)
% Last Change   : 97/02/07, Christoph Quix (RWTH)
%
% SCCS-Source-Pool : /home/CBase/CB_NewStruct/ProductPOOL/SCCS/serverSources/Prolog_Files/s.QueryCompiler.pro
% Date retrieved : 97/06/26 (YY/MM/DD)
% ----------------------------------------------------------------------------
%
% Exported predicates:
% ---------------------
% compile_query/1
% get_QueryStruct/2
% QueryArgNum/2
% untell_query/1
% store_perm_QueryRules/1
% store_perm_QueryRules/2
% remove_tmp_QueryRules/0
% restore_QueryRules/0
% delete_perm_QueryRules/1
% delete_perm_QueryRules/2
% replace_derive_expression3
%
%
% Changes :
% ---------
% completely rewritten by kvt
%
% Jul-97/Wang tmpQueryRule_ins and tmpQueryRule_del are additionally used.
% They are responsible for retell_Operation, because the set of told rules and
% from un-told rules shall be stored separately. For this, a flag is still
% set from TellAndAsk.
%
% Apr-98/Wang handleCode,generate_exec_code, generatePROLOGCode are completely removed here.
% Processing of Prolog code generation in RuleBase is done only after optimization.
% instead initDatalogRulesInfo is done here after Datalog code generation.
%
%

:- module('QueryCompiler',[
'GenericQuery'/1
,'QCsubquery'/4
,'Query'/1
,'QueryArgNum'/2
,'SubQuery'/1
,'SubQuery'/2
,'SubQuery'/3
,'View'/1
,'View'/2
,'buildQueryArgExp'/3
,'buildQueryHead'/3
,'compileDatalogRule'/1
,'compile_query'/1
,'createNewVarname'/1
,'create_IDS'/2
,'delete_perm_QueryRules'/1
,'delete_perm_QueryRules'/2
,'factor_query'/1
,'generate_GenQueryArgs'/5
,'get_QueryStruct'/2
,'get_components'/3
,'get_pattern'/3
,'get_tmp_QueryStruct'/1
,'remove_tmp_QueryRules'/0
,'replace_derive_expression'/3
,'restore_QueryRules'/0
,'store_perm_QueryRules'/1
,'store_perm_QueryRules'/2
,'store_tmp_QueryStruct'/1
,'untell_query'/1
,'QCisa'/2
,'QCparam'/3
,'tmpQueryRule'/1
,'tmpQueryRule_ins'/1
,'tmpQueryRule_del'/1
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').
:- use_module('PROLOGruleProcessor.swi.pl').
:- use_module('PropositionProcessor.swi.pl').
:- use_module('Literals.swi.pl').
:- use_module('AssertionTransformer.swi.pl').
:- use_module('LTcompiler.swi.pl').
:- use_module('ErrorMessages.swi.pl').
:- use_module('GeneralUtilities.swi.pl').
:- use_module('PrologCompatibility.swi.pl').
:- use_module('VarTabHandling.swi.pl').
:- use_module('FragmentToPropositions.swi.pl').
:- use_module('SubQueryCompiler.swi.pl').
:- use_module('ViewCompiler.swi.pl').
:- use_module('TellAndAsk.swi.pl').
:- use_module('RuleBase.swi.pl').
:- use_module('ViewMonitor.swi.pl').
:- use_module('SelectExpressions.swi.pl').
:- use_module('CodeCompiler.swi.pl').
:- use_module('CodeStorage.swi.pl').
:- use_module('BDMIntegrityChecker.swi.pl').
:- use_module('MetaUtilities.swi.pl').
:- use_module('MetaFormulas.swi.pl').
:- use_module('validProposition.swi.pl').
:- use_module('cbserver.swi.pl').
:- dynamic 'QCsubquery'/4 .
:- dynamic 'factor_query'/1 .
:- dynamic 'QCisa'/2 .
:- dynamic 'QCparam'/3 .
:- dynamic 'tmpQueryRule'/1 .
:- dynamic 'tmpQueryRule_ins'/1 .
:- dynamic 'tmpQueryRule_del'/1 .
:- style_check(-singleton).
%  ******************* c o m p i l e _ q u e r i e s ***********************
%
%  *************************************************************************

compile_queries([]).
compile_queries([_query|_queries]) :-
	compileQuery(_query),
	compile_queries(_queries).
%  BuiltinQueries are not compiled/CQ 13/2/96

compile_query(_query) :-
	name2id('BuiltinQueryClass',_bqid),
	prove_literal('In'(_query,_bqid)),
	!.
%  Functions have to be compiled, although the compiled code
%   is not really used. But QueryArgExp and ViewArgExp are necessary,
%   so that Functions can be used in other queries.
%  compile_query(_query) :-
% 	name2id(Function,_fid),
% 	prove_literal(In(_query,_fid)),
% 	!.
%

compile_query(_query) :-
	compileQuery(_query).
compile_query(_q) :-
	!,
	nl,
	write('failed to compile query '),
	id2name(_q,_qNAME),
	writeq(_qNAME),
	nl,!,
	fail.

compileQuery(_qid) :-
    name2id('DatalogQueryClass',_dqid),
    prove_literal('In'(_qid,_dqid)),
	!,
	compileDatalogQuery(_qid).
compileQuery(_qID) :-
	setQueryFlag('Q'),
	getQueryMode(_qID,_mode),
	create_IDS(_qID,_qIDS),
	id2name(_qID,_q),
	'WriteTrace'(high,'QueryCompiler',['Start compiling ',_mode,': ', _q]),
	get_all_infos(_qID,_querySTR,_queryconstrA,_qQAE,_subqueryinfo),  % 12-09-95/MSt
        checkMinimumStructure(_querySTR),  % ticket #163: queries without superclass or constraint are forbidden
	'WriteTrace'(high,'QueryCompiler',['Gathered structural information: ', _querySTR]),
	store_tmp_QueryStruct(_qQAE),
	'WriteTrace'(high,'QueryCompiler','Now compiling to rangeform'),
	generateRangeform(_querySTR, _queryconstrA, _queryRF, _vartab),
        !,
        checkNoErrors,  % check that parsing was successful,; ticket #189
	!,
        generateBDMRule(_queryRF,_vartab,_qID),  % .. to let query calls In(x,q) occur in rules/constraints
	!,
	%  Compile the rangeform of the query to Datalog-neg
	%

	generateDatalog(_qID,_qIDS,_queryRF,_vartab,_ruleDLs),
	initDatalogRulesInfo(_ruleDLs,_mode,_qID,_qIDS,_vartab),
	!,
	%  generate additional rules to handle the dichotomy query versus class
	%

	generate_In_Rule(_qID,_inruleDLs),
	initDatalogRulesInfo(_inruleDLs,_mode,_qID,_qIDS,_vartab),
	!,
	compile_subqueries(_mode,_qID,_subqueryinfo),
	buildNF2exp(_qID,_algexp,_argexp),
	retractall('QCsubquery'(_,_,_,_)).
compileQuery(_q) :-
	!,
	nl,
	write('There is a problem in query '),
	id2name(_q,_qNAME),
	writeq(_qNAME),
	nl,!,
	fail.
%  a query like "Function F end" would have not enough info to create a membership constraint different from FALSE
%  ticket #163

checkMinimumStructure('QS'(lit(_id),[],[])) :-
   atom(_id),
   increment('error_number@F2P'),
   report_error('QLERR14','QueryCompiler',[objectName(_id)]),
   !,
   fail.
%  otherwise: go on with the compilation

checkMinimumStructure(_).

checkNoErrors :-
	'error_number@F2P'(0),
	!.
checkNoErrors :-
        'error_number@F2P'(_n),
	_n > 0,
	write('Errors found in query definition: '), write(_n), nl,
	!,
	fail.
%  2-Jun-2004/M.Jeusfeld: generate code that allows to compile query rules for
%  the integrity checker;  see also CBNEWS.doc, item 213
%  first, check whether a query with a meta variable is also defined as instance
%  of MSFOLrule (i.e. being integrated into the constraint checker). This is
%  not supported by ConceptBase since the partial evaluator for meta formulas
%  does not support queries. Instead, the meta literals stay as is in queries.
%  It would be nice to lift this restriction but one can always use a deductive
%  rule like   $ forall x/VAR c/MC (x in c) and ... ==> (x in MyClass) $ to
%  simulate a query class. There are no restrictions on deductive rules.
%  Related to ticket #159.

generateBDMRule(_queryRF,_vartab,_qID) :-
  name2id('MSFOLrule',_MSFOLruleId),
  prove_literal('In'(_qID,_MSFOLruleId)),  % check whether QueryClass can store triggers
  _queryRF = rangerule([_this],_formula,_qlit),
  metaFormula(_formula),
  !,
  report_error('METAQUERY_ERROR','QueryCompiler',[objectName(_qID)]),
  fail.
generateBDMRule(_queryRF,_vartab,_qID) :-
  name2id('MSFOLrule',_MSFOLruleId),
  prove_literal('In'(_qID,_MSFOLruleId)),  % check whether QueryClass can store triggers
  _queryRF = rangerule([_this],_formula,_qlit),
   thisVariable(_this),
  _qlit =.. [_qID,_this],
  _queryRF1 = rangerule([_this],_formula,'In'(_this,_qID)),
  !,
  tell_BDMRule(_queryRF1,_vartab,_qID).
generateBDMRule(_,_,_qID) :-  % if unsuccessful, we still continue to compile the query
   id2name(_qID,_qName),
   'WriteTrace'(high,'QueryCompiler',['Query ', _qName, ' was not compiled for being used for integrity checking']),
   !.
generateBDMRule(_,_,_).

thisVariable('this').
thisVariable('~this').
% ******************** g e t _ c o m p o n e n t s ***********************
%
%  ************************************************************************

get_components(_,[],[]).
get_components(_n,[_t|_r],[_a|_ar]) :-
	arg(_n,_t,_a),
	get_components(_n,_r,_ar).
%  ****************** g e t _ Q u e r y S t r u c t ************************
%
%  *************************************************************************

get_QueryStruct(_q,_s) :-
	pc_has_a_definition('QueryArgExp'(_,_)),
	'QueryArgExp'(_q,_s).
get_QueryStruct(_q,_s) :-
	get_tmp_QueryStruct('QueryArgExp'(_q,_s)).
%  *************** s t o r e _ t m p _ Q u e r y S t r u c t ***************
%
%  *************************************************************************
%  case 1: there was a forward declaration for query q

store_tmp_QueryStruct('QueryArgExp'(_q,_s)) :-
	get_QueryStruct(_q,_s),  % there was a forward declaration of this query
	removeOldCode(_q),  % remove the old datalog code generated for it
	'WriteTrace'(high,'QueryCompiler',['Code of forward-declared query ', idterm(_q), ' clear for update.']),
	!.
%  case 2: there was a forward-declaration but it has a different signature

store_tmp_QueryStruct('QueryArgExp'(_q,_s)) :-
        get_QueryStruct(_q,_s1),
	_s1 \= _s,
	!,
	write('Error in QueryCompiler:  '),write('QueryArgExp'(_q,_s)),write(' is not equal to '),write('QueryArgExp'(_q,_s1)),nl, 
        fail.
%  case 3: no forward declaration, q is a new query

store_tmp_QueryStruct(_QS) :-
	store_tmp_PROLOGrules([_QS]).
%  removeOldCode removes the tmpRuleInfo clauses generated in the current transaction for the query
%  class q. This is required if there is a so-called forward-declaration of a query class. See
%  ticket #177. The second frame for query q will then provide the right code for the query.

removeOldCode(_q) :-
   retract(tmpRuleInfo(_ruleid,query,_q,_ids,_lit,_body,_depsOn,_vartab,_new_optPar,_relAlgExp)),
   fail.
removeOldCode(_q).
%  *************** g e t _ t m p _ Q u e r y S t r u c t *******************
%
%  *************************************************************************

get_tmp_QueryStruct(_QS) :-
	get_tmp_PROLOGrules([_QS]).
%  ******************** s t o r e _ t m p _ M R u l e s ********************
%
%  *************************************************************************

store_perm_QueryRules(_rules) :-
	pc_has_a_definition(tmpQueryRule(_)),
	findall(_r,tmpQueryRule(_r),_multirules),
	remove_multiple_elements(_multirules,_rules),
	retractall(tmpQueryRule(_)),
	!.
store_perm_QueryRules([]).
store_perm_QueryRules(_rules,retell_tell) :-
	pc_has_a_definition(tmpQueryRule_ins(_)),
	findall(_r,tmpQueryRule_ins(_r),_multirules),
	remove_multiple_elements(_multirules,_rules),
	abolish(tmpQueryRule_ins,1),!.
store_perm_QueryRules([],_).

remove_tmp_QueryRules :-  % in ObjPro during tell,retell
	(
	retract(tmpQueryRule(_r));
	retract(tmpQueryRule_ins(_r))
	),
	remove_PROLOGrules([_r]),
	remove_tmp_QueryRules.
remove_tmp_QueryRules.

delete_perm_QueryRules([_qr|_qrr]) :-
	retract(tmpQueryRule(_qr)),
    delete_perm_QueryRules(_qrr),!.
delete_perm_QueryRules([]).
delete_perm_QueryRules([_qr|_qrr],retell_untell) :-
	retract(tmpQueryRule_del(_qr)),
    delete_perm_QueryRules(_qrr),!.
delete_perm_QueryRules([],_).

restore_QueryRules :-
	(
	retract(tmpQueryRule(_qr));
	retract(tmpQueryRule_del(_qr))
	),
	assert(_qr),
	fail.
restore_QueryRules.
%  ************************ g e t _ t m p _ M R u l e s ********************
%
%  *************************************************************************

get_tmp_MRule(_QS) :-
	get_tmp_PROLOGrules([rule(_QS)]).
%  ************* g e n e r a t e _ I n _ R u l e ************
%
%  **************************************************************************
%  for generic queries only
%

generate_In_Rule(_qID,[('LTevalQuery'(_qID,'In'('_at_this',_qID))
                             :- _Q)]) :-
	get_QueryStruct(_qID,[this|_s]),
	'GenericQuery'(_qID),
	!,
	generate_GenQueryArgs('_at_this',[this|_s],[],_arglist,_),
	_Q =..[_qID|_arglist].
%  for ordinary queries only
%

generate_In_Rule(_qID,[('LTevalQuery'(_qID,'In'('_at_this',_qID))
                             :- _Q)]) :-
	get_QueryStruct(_qID,[this|_s]),
	!,
	'QueryArgNum'(_s,_l),
	pc_atomconstruct('_',_l,_ls),
	pc_atomtolist(_ls,_fa),
	_Q =..[_qID,'_at_this'|_fa].
generate_In_Rule(_,[]).
%  *********************** Q u e r y A r g N u m ****************************
%
%  **************************************************************************

'QueryArgNum'([],0).
'QueryArgNum'([rp(_,_)|_r],_i) :-
	'QueryArgNum'(_r,_j),
	_i is _j + 3 .
'QueryArgNum'([cp(_,_)|_r],_i) :-
	'QueryArgNum'(_r,_j),
	_i is _j + 2 .
'QueryArgNum'([p(_,_)|_r],_i) :-
	'QueryArgNum'(_r,_j),
	_i is _j + 2 .
'QueryArgNum'([r(_)|_r],_i) :-
	'QueryArgNum'(_r,_j),
	_i is _j + 2 .
'QueryArgNum'([c(_)|_r],_i) :-
	'QueryArgNum'(_r,_j),
	_i is _j + 1 .
'QueryArgNum'([this|_r],_i) :-
	'QueryArgNum'(_r,_j),
	_i is _j + 1 .

get_ID(_id):-
   assign_ID('P'(_id,_s,_d,_f)).
%  **************** u n t e l l _ q u e r y ***********************
%
%  *******************************************************

untell_query(_q) :-
	(
		(if_exist_view,  % check whether a view exists
		findall(('LTevalQuery'(_q,_t):- _body),clause('LTevalQuery'(_q,_t), _body),_listofclauses),  % for ViewMonitor, before untell, the queries
		findall_deduced_factor_query(_listofclauses,_listoffactors),  % will be evaluated
		assert(factor_query(_listoffactors)),
		!
		);
		true  % if no view exists, do nothing
	),
	(
        (retellflag(untell),
        findall(('LTevalQuery'(_q,_t):- _body), (retract(('LTevalQuery'(_q,_t):- _body)),assert(tmpQueryRule_del(('LTevalQuery'(_q,_t):- _body)))),_s),
        findall('Trigger'(_q,_trig),(retract('Trigger'(_q,_trig)),assert(tmpQueryRule_del('Trigger'(_q,_trig)))),_s1),
        retract('QueryArgExp'(_q,_args)),
        assert(tmpQueryRule_del('QueryArgExp'(_q,_args)))
		);
		(not(retellflag(_)),
		findall(('LTevalQuery'(_q,_t):- _body), (retract(('LTevalQuery'(_q,_t):- _body)),assert(tmpQueryRule(('LTevalQuery'(_q,_t):- _body)))),_s),
        findall('Trigger'(_q,_trig),(retract('Trigger'(_q,_trig)),assert(tmpQueryRule('Trigger'(_q,_trig)))),_s1),
        retract('QueryArgExp'(_q,_args)),
        assert(tmpQueryRule('QueryArgExp'(_q,_args)))
		)
	),!.
% ***************************************************

findall_deduced_factor_query([],[]):-!.  % LTevalQuerys (LTevalQuery(_id,_id(_parameter)) or LTevalQuery(_id,In(_x,_id))
									%  are the queries to untell; take all LTevalQuerys(_id,_id(_parameter)) and
									%  evaluate them, then we first get factors _id(_l,_), and from _id(_l,_)

findall_deduced_factor_query([(_a)|_b],_c):-  % In(_l,_id) is additionally generated
	arg(1,_a,'LTevalQuery'(_id,_body)),
	_body =.. [_id|_arglist],
	save_setof(_body,'LTevalQuery'(_id,_body),_sol1),
	'In_clauses'(_id,_sol1,_sol2),
	append(_sol1,_sol2,_sol),
	findall_deduced_factor_query(_b,_cc),
	append(_sol,_cc,_c).
findall_deduced_factor_query([(_a)|_b],_c):-
	findall_deduced_factor_query(_b,_c).

'In_clauses'(_i,[],[]):- !.
'In_clauses'(_i,[_a|_b],['In'(_l,_i)|_c]):-
	arg(1,_a,_l),
	'In_clauses'(_i,_b,_c).
% ***************************************************

get_all_infos(_qcID,'QS'(_queryHead,_vts,_lits),_constrA ,_qQAE,_s) :-
% Arg _s, 12-09-95/MSt
	%  mark(_CUT),  SWI/SICSTUS conversion

	buildIDS(_qcID,_qcIDS),
	get_constraint_info(_qcIDS,_constrA),
	get_isa_infos(_qcIDS,_vts1,_queryargs1),
	get_rattr_infos(_qcIDS,_constrA,_lits2,_vts2,_queryargs2),
	((_vts1 = [],
	  _vts2 \== [],
	  report_error('QLERR11','QueryCompiler',[objectName(_qcID)]),
	  !,
	  fail);
	 true
	),
	get_cattr_infos(_qcIDS,_constrA,_lits3,_vts3,_queryargs3),
	get_param_infos(_qcIDS,_lits4,_vts4,_queryargs4),
        get_required_parameter_infos(_qcIDS,_lits5),  % ticket #147
	append([_lits5,_lits2,_lits3,_lits4],_lits),
	append([_vts1,_vts2,_vts3,_vts4],_vts),
	append([_queryargs1,_queryargs2,_queryargs3,_queryargs4],_queryargs),
	buildQueryHead(_qcID,_vts,_queryHead),
	buildQueryArgExp(_qcID,_queryargs,_qQAE),
	get_subquery_infos(_qcID,_s),  % 12-09-95/MSt
	%  cut(_CUT).  SWI/SICSTUS conversion

	!.
%  get_required_parameter_infos determines the parameters of the generic
%  query class _qcID (if any) and produces the 'bound' literals to be
%  added to the code compiled for the query.  See also ticket #147.

get_required_parameter_infos(_qcIDS,_lits_to_be_added) :-
  _qcIDS = (_qcID, _, _,_pID, _),
   setof(_param,requiredParameter(_param,_qcID,_pID),_params),
   generateBoundLits(_params,_lits_to_be_added),
   !.
get_required_parameter_infos(_,[]).

requiredParameter(_param,_qcID,_pID) :-
  retrieve_proposition('P'(_id,_qcID,_param,_d)),  % _id is an attribute of the query
  prove_literal('In'(_id,_pID)),  % _id is actually specifying a parameter
  (prove_literal('A_label'(_qcID,required,_d,_param));  % this parameter is defined as 'required
   isFunction(_qcID)  % or the query class is a Function
  ).
%  The 'bound' lit is moved later by QO_preproc to the begin of the condition
%  The literal is defined in Literals.pro and generated in CodeCompiler.pro

generateBoundLits([],[]) :- !.
generateBoundLits([_param|_restparams],[lit(bound(_pvar))|_restlits]) :-
  atom(_param),
  pc_atomconcat('~',_param,_pvar),
  generateBoundLits(_restparams,_restlits).
%  collect all isa links of the query class
%

get_isa_infos(_qcIDS,[('~this',_isalist)],[this]) :-
	_qcIDS = (_qcID, _, _,_, _),
	setof(_i,
	      [_id]^retrieve_proposition('P'(_id,_qcID,'*isa',_i)),
	      _isalist),
	%  CQ - ~this can also be used for parameters

	pc_member(_class,_isalist),
	%  assert(QCparam(_qcID,'~this',_class)),
	%  MSt - disable for subqueries

	assert('QCisa'(_qcID,_isalist)).
get_isa_infos(_,[],[]).
%  get the query constraint

get_constraint_info(_qcIDS,_constrA) :-
	_qcIDS = (_qcID, _, _,_, _qconsID),
	id2name(_qcID,_name),
	prove_literal( 'Adot'(_qconsID,_qcID,_constrID)),
	prove_literal('Label'(_constrID,_constrA)).
get_constraint_info(_,'$ TRUE $').
%  get all retrieved_attributes

get_rattr_infos(_qcIDS,_constr,_lit2s,_vt2s,_queryargs):-
	_qcIDS = (_qcID, _raID, _caID,_pID, _qconsID),
	setof(t(_lits,_vts,_queryarg),
			get_rattr_info(_qcID,_raID,_pID,_constr,_lits,_vts,_queryarg),
			_ts),
	get_components(1,_ts,_litss),
	get_components(2,_ts,_vtss),
	get_components(3,_ts,_queryargs),
	makeflat(_litss,_lit2s),
	makeflat(_vtss,_vt2s).
get_rattr_infos(_,_,[],[],[]).
%  Case 1: retrieved attribute + parameter

get_rattr_info(_qcID,_raID,_pID,_constr,_lits,_vts,_queryarg):-
	retrieve_proposition( 'P'(_linkID,_qcID,_l,_destID)),
	retrieve_proposition('P'(_,_linkID,'*instanceof',_pID)),
	prove_literal('In_s'(_linkID,_raID)),
	createNewVarname(_pl),
	createNewVarname(_label),
	createNewVarname(_pC),
	%  The name of the variable is the label of the parameter!

	pc_atomconcat('~',_l,_atl),
	_lits = [ lit('A_label'('~this',_l,_atl,_label)), lit('In'(_atl,_pC))],
	name2id('Proposition',_propid),
	name2id('Label',_labid),
	_vts = [(_label,_labid),(_atl,_destID),(_pC,_propid)],
	_queryarg = rp(_l,_destID).
%  Case 2: retrieved attribute
%  case 2a: attribute is necessary or qcID is not a View

get_rattr_info(_qcID,_raID,_pID,_constr,_lits,_vts,_queryarg):-
	retrieve_proposition( 'P'(_linkID,_qcID,_l,_destID)),
	not(retrieve_proposition('P'(_,_linkID,'*instanceof',_pID))),
	prove_literal('In_s'(_linkID,_raID)),
	createNewVarname(_pl),
	createNewVarname(_label),
	_lits = [lit('A_label'('~this',_l,_pl,_label))],
	name2id('Proposition',_propid),
	name2id('Label',_labid),
	_vts = [(_label,_labid),(_pl,_destID)],
	_queryarg = r(_l).
%  case 2b: remember _l and retrieved for subquery when qcID is a View and attr is not necessary
%  inherited_attribute only for Views, optional retrieved_attribute

get_rattr_info(_qcID,_raID,_pID,_constr,_lits,_vts,_queryarg):-
	retrieve_proposition( 'P'(_linkID,_qcID,_l,_destID)),
	'View'(_qcID),
	name2id('View',_vid),
	retrieve_proposition('P'(_inhid,_vid,'inherited_attribute',_)),
	prove_literal('In_s'(_linkID,_inhid)),
    assert('QCsubquery'(_qcID,_l,_destID,r)),
    fail.

get_cattr_infos(_qcIDS,_constr,_lit2s,_vt2s,_queryargs):-
	_qcIDS = (_qcID, _raID, _caID,_pID, _qconsID),
	setof(t(_lits,_vts,_queryarg),
            get_cattr_info(_qcID,_caID,_pID,_constr,_lits,_vts,_queryarg),
			_ts),
	get_components(1,_ts,_litss),
	get_components(2,_ts,_vtss),
	get_components(3,_ts,_queryargs),
	makeflat(_litss,_lit2s),
	makeflat(_vtss,_vt2s).
get_cattr_infos(_,_,[],[],[]).

get_cattr_info(_qcID,_caID,_pID,_constr,_lits,_vts,_queryarg):-
	retrieve_proposition( 'P'(_linkID,_qcID,_l,_destID)),
	prove_literal('In_s'(_linkID,_caID)),
	createNewVarname(_pl),
	(
	 (  % Case 1: computed attribute + parameter
	  retrieve_proposition('P'(_,_linkID,'*instanceof',_pID)),
	  createNewVarname(_pC),
	  pc_atomconcat('~',_l,_atl),
	  _lits = [lit('In'(_atl,_pC))],
	  name2id('Proposition',_propid),
	  _vts = [(_atl,_destID),(_pC,_propid)],
	  _queryarg = cp(_l,_destID)
	 );
	 (  % Case 2: computed attribute
	  not(retrieve_proposition('P'(_,_linkID,'*instanceof',_pID))),
	  _lits = [],
	    pc_atomconcat('~',_l,_atl),
	    _vts = [(_atl,_destID)],
	    _queryarg = c(_l)
    )).

get_param_infos(_qcIDS,_lit2s,_vt2s,_queryargs):-
	_qcIDS = (_qcID, _raID, _caID,_pID, _qconsID),
	setof(t(_lits,_vts,_queryarg),
			get_param_info(_qcID,_raID,_caID,_pID,_lits,_vts,_queryarg),
			_ts),
	get_components(1,_ts,_litss),
	get_components(2,_ts,_vtss),
	get_components(3,_ts,_queryargs),
	makeflat(_litss,_lit2s),
	makeflat(_vtss,_vt2s).
get_param_infos(_,[],[],[]).

get_param_info(_qcID,_raID,_caID,_pID,_lits,_vts,_queryarg):-
	retrieve_proposition( 'P'(_linkID,_qcID,_l,_destID)),
	prove_literal('In_s'(_linkID,_pID)),
	not(prove_literal('In_s'(_linkID,_raID))),
	not(prove_literal('In_s'(_linkID,_caID))),
	createNewVarname(_pC),
	pc_atomconcat('~',_l,_atl),
	_lits = [lit('In'(_atl,_pC))],
	_vts = [(_atl,_destID),(_pC,id_0)],  % id_0 = Proposition
	_queryarg = p(_l,_destID),
    assert('QCparam'(_qcID,_atl,_destID)).

buildIDS(_qcID,(_qcID, _raID, _caID,_pID, _qconsID)) :-
	%  get IDs of SystemClases

        _QuClassId=id_65,  % id_65=QueryClass
        _GeQuClassId=id_72,  % id_72=GenericQueryClass
	%  get ID of retrieved_attribute

	retrieve_proposition('P'(_raID, _QuClassId, retrieved_attribute, _)),
	%  get ID of computed_attribute

	retrieve_proposition('P'(_caID,_QuClassId,computed_attribute,_)),
	%  get ID of parameter

	retrieve_proposition('P'(_pID,_GeQuClassId,parameter,_)),
	%  get ID of constraint

	retrieve_proposition('P'(_qconsID,_QuClassId,constraint,_)).

createNewVarname(_newvarA):-
	uniqueAtom(_numA),
	pc_atomconcat('var_',_numA,_newvarA).

buildQueryArgExp(_qID,[this|_rs],'QueryArgExp'(_qID,[this|_nrs])) :-
	!,
	skip(this,_rs,_nrs).
buildQueryArgExp(_qID,_rs,'QueryArgExp'(_qID,_rs)).

buildQueryHead(_qID, _vars,lit(_head)) :-
	get_components(1,_vars,_vs),
	_head =.. [_qID|_vs].
% *******************
% _info = _key(_queryarg,_lits,_vars)
% _key : key for subsequent sorting.
%
%
% _infos
%  skip all _a that appear first in the list
%

skip(_a,[_a|_as],_bs) :-
	!,
	skip(_a,_as,_bs).
skip(_a,_as,_as).
%  THIS WAS INSERTED FROM ASSERTION COMPILER
%  build the IDS (ID struct)
%

create_IDS(_rID,id(_rID,_nID)) :-
	newOID(_nID).
% *******************************************************
%  newOID(_nID)
%
%  _nID : (output) : OID
%
%  self-explaining, isn't it ?
%  would be nice to have this as a test too
% *******************************************************

newOID(_nID) :-
	assign_ID('P'(_nID,_,_,_)).
%  useful auxiliary predicate
%

getQueryMode(_q,query).
% *********************************************************
%  GenericQuery(_qID)
%
%  Test whether a query class is a generic query.
% *********************************************************

'GenericQuery'(_qID) :-
	name2id('GenericQueryClass',_GeQuClassId),
	prove_literal( 'In_i'(_qID,_GeQuClassId) ).
% *********************************************************
%  Query(_qID)
%
%  Test whether a query class is a query.
% *********************************************************

'Query'(_qID) :-
	name2id('QueryClass',_QuClassId),
	prove_literal( 'In_e'(_qID,_QuClassId) ).
% ***************************************************************
%
%  SubQuery(_q,_name)
%
%  Description of arguments:
%        q : ID of a query with subquery-attribute label appended
%     name : name of the query with subquery-attribute label appended
%
%  Description of predicate:
%    Tests whether q is a subquery and returns names
% ***************************************************************
%  1-argument version does not return name with attached subquery-attribute label

'SubQuery'(_q) :-
        %  get_QueryStruct(_q,_),
  %  There are subqueries with vm prefix for which there is no corresponding rule without prefix

        pc_atomconcat('id_',_r1,_q),
        split_atom(_r1,'_',_num,_attr),
        \+(pc_atompart(_num,'_',_,_)),
        pc_atomconcat(['id_',_num],_qID),
        'Query'(_qID).
'SubQuery'(_q,_name) :-
	%  get_QueryStruct(_q,_),
  %  There are subqueries with vm prefix for which there is no corresponding rule without prefix

	pc_atomconcat('id_',_r1,_q),
	split_atom(_r1,'_',_num,_attr),
	\+(pc_atompart(_num,'_',_,_)),
	pc_atomconcat(['id_',_num],_qID),
	'Query'(_qID),
	id2name(_qID,_qname),
	pc_atomconcat([_qname,'_',_attr],_name).
'SubQuery'(_q,_qname,_attr) :-
	%  get_QueryStruct(_q,_),
  %  There are subqueries with vm prefix for which there is no corresponding rule without prefix

	pc_atomconcat('id_',_r1,_q),
	split_atom(_r1,'_',_num,_attr),
	\+(pc_atompart(_num,'_',_,_)),
	pc_atomconcat(['id_',_num],_qID),
	'Query'(_qID),
	id2name(_qID,_qname).
% ***************************************************************
%
%  View(_q,_name)
%
%  Description of arguments:
%        q : ID of a view
%     name : name of the view
%
%  Description of predicate:
%    Tests whether q is a view and returns the name
% ***************************************************************

'View'(_q,_name) :-
	\+('SubQuery'(_q)),
	name2id('View',_vid),
	prove_edb_literal('In_e'(_q,_vid)),
	id2name(_q,_name).
%  1-argument version does not return the name of the view

'View'(_q) :-
        \+('SubQuery'(_q)),
        name2id('View',_vid),
        prove_edb_literal('In_e'(_q,_vid)).
% ***************************************************************
%
%  replace_derive_expression(_i,_d,_t)
%
%  Description of arguments:
%        i : variable in question (usually _this)
%        d : term of form derive(_q,_slist) where
%             _q is the GenericQueryClass name and
%             _slist is the parameter list
%        t : output: term of form id_1234(_this,_p1,_c1,....)
%
%  Description of predicate:
%    Generates from derive expression d a term t matching the query
%    head and usable to call the query.
%    i is the Prolog variable substituted for this in t.
%    Arguments in t are atoms; pc_atom_to_term turns them into variables.
% ***************************************************************
%  Use toId instead makeId. MakeId can also return variables
%  In that case, all queries are checked, which is both wrong
%  and highly inefficient, since there is only one _qID to be
%  considered in replace_derive_expression.

replace_derive_expression(_i,derive(_q,_slist),_term) :-
	toId(_q,_qID),
	get_QueryStruct(_qID,_s),
	generate_GenQueryArgs(_i,_s,_slist,_args,_rest),
	_rest == [],
	_term =..[_qID|_args],
        !.
replace_derive_expression(_,derive(_qID,_slist),_) :-
	(id2name(_qID,_q) ; atom(_qID),_q = _qID),
% 	pc_atom_to_term(_af,derive(_q,_slist)),

	report_error('QLERR6','QueryCompiler',[objectName(derive(_q,_slist))]),
	increment('error_number@F2P'),
	!,fail.
% ***************************************************************
%
%  generate_GenQueryArgs(_i,_qs,_slist,_arglist,_rest)
%
%  Description of arguments:
%        i : variable for this (as atom with prefix _)
%       qs : QueryStruct of the query
%    slist : list of substitution(_v,_p) and specialize(_p,_c)
%  arglist : Output: list of the arguments
%  rest: remainder of the S list that could not be inserted
%  (should be empty)
%  Description of predicate:
%    Generates the argument list for a generic query (see replace_..)
% ***************************************************************

generate_GenQueryArgs(_i,[],_slist,[],_slist) :- !.
generate_GenQueryArgs(_i,[this|_r],_slist,[_i|_nr],_rest) :-
	!,
	generate_GenQueryArgs(_i,_r,_slist,_nr,_rest).
generate_GenQueryArgs(_i,[c(_x)|_r],_s,['_'|_rargs],_rest) :-
	!,
	generate_GenQueryArgs(_i,_r,_s,_rargs,_rest).
generate_GenQueryArgs(_i,[r(_x)|_r],_s,['_','_'|_rargs],_rest) :-  % '_' for label 21-05-96/CQ
	generate_GenQueryArgs(_i,_r,_s,_rargs,_rest).
generate_GenQueryArgs(_i,[rp(_x,_c)|_r],_s,['_','_',_cs|_rargs],_rest) :-  % '_' for label 21-05-96/CQ
	pc_member(specialize(_x,_cs),_s),!,
	prove_literal('Isa'(_cs,_c)),
	delete(specialize(_x,_cs),_s,_re),
	generate_GenQueryArgs(_i,_r,_re,_rargs,_rest).
generate_GenQueryArgs(_i,[cp(_x,_c)|_r],_s,['_',_cs|_rargs],_rest) :-
	pc_member(specialize(_x,_cs),_s),!,
	prove_literal('Isa'(_cs,_c)),
	delete(specialize(_x,_cs),_s,_re),
	generate_GenQueryArgs(_i,_r,_re,_rargs,_rest).
generate_GenQueryArgs(_i,[p(_x,_c)|_r],_s,['_',_cs|_rargs],_rest) :-
	pc_member(specialize(_x,_cs),_s),!,
	prove_literal('Isa'(_cs,_c)),
	delete(specialize(_x,_cs),_s,_re),
	generate_GenQueryArgs(_i,_r,_re,_rargs,_rest).
generate_GenQueryArgs(_i,[rp(_x,_c)|_r],_s,['_',_xnID,_c|_rargs],_rest) :-  % '_' for label 21-05-96/CQ
	pc_member(substitute(_xn,_x),_s),!,
	delete(substitute(_xn,_x),_s,_re),
	valid_substitution(_xn,_xnID,_c),
	generate_GenQueryArgs(_i,_r,_re,_rargs,_rest).
generate_GenQueryArgs(_i,[cp(_x,_c)|_r],_s,[_xnID,_c|_rargs],_rest) :-
	pc_member(substitute(_xn,_x),_s),!,
	delete(substitute(_xn,_x),_s,_re),
	valid_substitution(_xn,_xnID,_c),
	generate_GenQueryArgs(_i,_r,_re,_rargs,_rest).
generate_GenQueryArgs(_i,[p(_x,_c)|_r],_s,[_xnID,_c|_rargs],_rest) :-
	pc_member(substitute(_xn,_x),_s),!,
	delete(substitute(_xn,_x),_s,_re),
	valid_substitution(_xn,_xnID,_c),
	generate_GenQueryArgs(_i,_r,_re,_rargs,_rest).
%  if retrieved attr. with non-substituted parameter 06-06-96/CQ

generate_GenQueryArgs(_i,[_f|_r],_s,['_','_',_c|_args],_rest) :-
	_f =.. [rp,_,_c],!,
	generate_GenQueryArgs(_i,_r,_s,_args,_rest).
generate_GenQueryArgs(_i,[_f|_r],_s,['_',_c|_args],_rest) :-
	_f =.. [_,_,_c],!,
	generate_GenQueryArgs(_i,_r,_s,_args,_rest).
generate_GenQueryArgs(_i,[_f|_r],_s,['_'|_args],_rest) :-
	generate_GenQueryArgs(_i,_r,_s,_args,_rest).
%  *************************************************
%    ATTENTION   ATTENTION   ATTENTION
%  Yes! A temporary tell happens here even though
%  we are presumably in the middle of an ask. This is necessary
%  so that instances of builtin types not yet explicitly told
%  receive an ID. Therefore at the end of the ask operation
%  (in QueryProcessor.pro) there is also
%  remove_temporary_information
%  ****************  Extension: *******************
%  Specializations of builtin types are also
%  considered, e.g. INTEGER, CHAR, VARCHAR imported from
%  external data sources.
%  30-Jun-2004/M.Jeusfeld
%  Allow nested parameterized query calls Q[x/p], i.e. x can be Q1[y/a].
%  See also CBNEWS.doc, item 215.
%  Ticket 194: parameter can be a derive expression encoded in an atom

valid_substitution(_parameter,_term,_c):-
	atom(_parameter),
	pc_atom_to_term(_parameter,derive(_q,_slist)),
	replace_derive_expression('_',derive(_q,_slist),_term),  % '_' is anonymous variable; stands for this
       _term =.. [_qid|_args],
	!.
valid_substitution(_parameter,_term,_c):-
       _parameter = derive(_q,_slist),
       replace_derive_expression('_',derive(_q,_slist),_term),  % '_' is anonymous variable; stands for this
       _term =.. [_qid|_args],
%   write('Complex parameter inserted: '), write(_term),nl,

       !.
valid_substitution(_parameter,_parameterID,_c):-
	name2id('Real',_realID),
	prove_literal('Isa'(_c,_realID)),
        makeAtomArg(_parameter,_aparameter),
	create_if_builtin_object(_aparameter),
	name2id(_aparameter,_parameterID),
	!.
valid_substitution(_parameter,_parameterID,_c):-
	name2id('String',_stringID),
	prove_literal('Isa'(_c,_stringID)),
        makeAtomArg(_parameter,_aparameter),
	create_if_builtin_object(_aparameter),
	name2id(_aparameter,_parameterID),
	!.
valid_substitution(_parameter,_parameterID,_c):-
	name2id('Integer',_integerID),
	prove_literal('Isa'(_c,_integerID)),
        makeAtomArg(_parameter,_aparameter),
	create_if_builtin_object(_aparameter),
	name2id(_aparameter,_parameterID),
	!.
valid_substitution(_parameter,_parameterID,_c):-
	eval(_parameter,replaceSelectExpression,_parameterID),
        is_id(_parameterID),  % pc_atomconcat('id_',_,_parameterID),
	prove_literal('In'(_parameterID,_c)),
	!.
%  What is this for? Removed for now. 9-8-96/CQ
% valid_substitution(_parameter,_parameter,_c):-
% 	prove_literal(P(_id,_,_parameter,_c)),
% 	!.
%  Variables can also be used as parameters 09-08-96/CQ

valid_substitution(_parameter,_parameter,_c) :-
	'VarTabVariable'(_parameter).
%  Integers and reals inside complex query calls might be parsed as Prolog integers/reals
%  and need to be converted to atoms since create_if_builtin_object expects it.

makeAtomArg(_x,_a) :-
  integer(_x),
  pc_inttoatom(_x,_a),
  !.
makeAtomArg(_x,_a) :-
  float(_x),
  pc_floattoatom(_x,_a),
  !.
makeAtomArg(_x,_a) :-
  bimstring(_x),
  stringToQuotedAtom(_x,_a),
  !.
makeAtomArg(_a,_a).
% ===========================================================
%  get_pattern/3
%  Creates the binding info. for a rule head.
%  If the rule is for a query, then the
%  parameter classes are bound. Variables of these classes
%  are also returned in a list.
%  Otherwise all variables are free.
%  Required by the Datalog optimizer.
% ===========================================================

get_pattern(_head,_newpattern,_parclasslist) :-
	functor(_head,_qID,_arity),
	get_QueryStruct(_qID,_structlist),
	!,
	'QueryStructToPattern'(_structlist,_patlist),
	_head =.. [_|_args],
	!,
	get_vars_for_parclass(_patlist,_args,_parclasslist,_newpatlist),
	pc_atomconcat(_newpatlist,_newpattern).
get_pattern(_head,_pattern,[]) :-
	functor(_head,_,_arity),
	pc_atomconstruct(f,_arity,_pattern).
% ===========================================================
%  QueryStructToPattern/2
%  Returns variable bindings in the head of the corresponding query
%  for a QueryStruct. (cf. generate_GenQueryArgs in QueryCompiler)
% ===========================================================

'QueryStructToPattern'([],[]).
'QueryStructToPattern'([this|_t],[f|_p]) :-
	'QueryStructToPattern'(_t,_p).
'QueryStructToPattern'([c(_a)|_t],[f|_p]) :-
	'QueryStructToPattern'(_t,_p).
'QueryStructToPattern'([r(_a)|_t],[ff|_p]) :-
	'QueryStructToPattern'(_t,_p).
'QueryStructToPattern'([rp(_a,_b)|_t],[ffb|_p]) :-
	'QueryStructToPattern'(_t,_p).
'QueryStructToPattern'([cp(_a,_b)|_t],[fb|_p]) :-
	'QueryStructToPattern'(_t,_p).
'QueryStructToPattern'([p(_a,_b)|_t],[fb|_p]) :-
	'QueryStructToPattern'(_t,_p).
'QueryStructToPattern'([_f|_t],[ff|_p]) :-
	_f =.. [_,_,_],
	'QueryStructToPattern'(_t,_p).
'QueryStructToPattern'([_u|_t],[f|_p]) :-
	'QueryStructToPattern'(_t,_p).
% ===========================================================
%  get_vars_for_parclass(_inpat,_invars,_outvars,_outpat)
%  Returns the variable designation of the classes of the parameters
%  in the list _outvars. _inpat is the assignment
%  the variables of the query head, _invars are all
%  variables occurring therein. Classes are exactly
%  the second variable of binding pair 'fb'. The
%  binding pattern is changed to 'bb' because
%  the corresponding In literal is moved forward later.
% ===========================================================

get_vars_for_parclass([],[],[],[]).
get_vars_for_parclass([fb|_fbs],[_v1,_v2|_vs],[_v2|_pcs],[bb|_newfbs]) :-
	get_vars_for_parclass(_fbs,_vs,_pcs,_newfbs).
get_vars_for_parclass([f|_fbs],[_v1|_vs],_pcs,[f|_newfbs]) :-
	get_vars_for_parclass(_fbs,_vs,_pcs,_newfbs).
% ===========================================================
%  compileDatalogQuery(_q)            CQ/Oct-2003
%   Datalog queries are query classes where code can be given
%   directly. This gives full control over code generation
%   without depending on the optimizer.
%   Code is defined as string attribute "code".
%   The attribute may be multi-valued, then several rules are generated.
% ===========================================================

compileDatalogQuery(_qid) :-
	setQueryFlag('Q'),
	create_IDS(_qid,_qIDS),
	id2name(_qid,_q),
	'WriteTrace'(high,'QueryCompiler',['Start compiling DatalogQuery: ', _q]),
	buildIDS(_qid,_qcIDS),
	get_isa_infos(_qcIDS,_vts1,_queryargs1),
	get_cattr_infos(_qcIDS,_constrA,_lits3,_vts3,_queryargs3),
	get_param_infos(_qcIDS,_lits4,_vts4,_queryargs4),
	append([_vts1,_vts3,_vts4],_vts),
    append([_queryargs1,_queryargs3,_queryargs4],_queryargs),
	get_components(1,_vts,_headVars),
	!,
	buildQueryHead(_qid,_vts,_queryHead),
	buildQueryArgExp(_qid,_queryargs,_qQAE),
	store_tmp_QueryStruct(_qQAE),
	!,
	getCodeInfos(_headVars,_qid,_bodylist),
	!,
	_queryHead = lit(_queryHeadWoLit),
	generateCodeForDatalogQuery('LTevalQuery'(_qid,_queryHeadWoLit),_headVars,_bodylist),
	!,
	%  generate additional rules to handle the dichotomy query versus class

	generate_In_Rule(_qid,_inruleDLs),
	initDatalogRulesInfo(_inruleDLs,query,_qid,_qIDS,_vartab),
	!.

compileDatalogRule(_rid) :-
	id2name(_rid,_r),
	'WriteTrace'(high,'QueryCompiler',['Start compiling DatalogRule: ', _r]),
	getHeadForDatalogRule(_rid,_headVars,_head),
	!,
	getCodeInfos(_headVars,_rid,_bodylist),
	!,
	generateCodeForDatalogRule(_rid,_head,_headVars,_bodylist),
	!.

getHeadForDatalogRule(_rid,['~this'],'In'('~this',_class)) :-
    name2id('DatalogInRule',_dir),
    prove_literal('In'(_rid,_dir)),
    !,
    prove_literal('A'(_rid,concernedClass,_class)).
getHeadForDatalogRule(_rid,['~src','~dst'],'Adot'(_class,'~src','~dst')) :-
    name2id('DatalogAttrRule',_dar),
    prove_literal('In'(_rid,_dar)),
    !,
    prove_literal('A_e'(_rid,'DatalogRule',concernedClass,_class)).
%  Get code attributes for qid and generate
%  the rule bodies from them.

getCodeInfos(_headVars,_qid,_codelist) :-
    setof(_cid,prove_literal('A'(_qid,code,_cid)),_cids),
    getCodeInfos2(_headVars,_cids,_codelist).

getCodeInfos2(_,[],[]).
getCodeInfos2(_headVars,[_cid|_cids],[body(_allvars,_body)|_bodies]) :-
    id2name(_cid,_codestr1),
    pc_atomconcat('"',_codestr2,_codestr1),
    pc_atomconcat(_code,'"',_codestr2),
    pc_atom_to_term(_code,_body1),
    ( _body1 = (vars(_varlist),_body2);
     (_body1 = _body2, _varlist = [])
    ),
    !,
	'VarTabInit',
    name2id('Proposition',_propid),
	'VarTabInsert'(_headVars,[_propid]),
    'VarTabInsert'(_varlist,[_propid]),
    transformLitsInBody(_body2,_body),
    'VarTabLookup_vars'(_allvars),
    !,
    getCodeInfos2(_headVars,_cids,_bodies).

transformLitsInBody((_lit,_rlits),(_newlit,_newrlits)) :-
    !,
    transformLit(_lit,_newlit),
    !,
    transformLitsInBody(_rlits,_newrlits).
transformLitsInBody(_lit,_newlit) :-
    !,
    transformLit(_lit,_newlit).

transformLit(query(_qexp),_qlit) :-
    !,
    pc_stringtoatom(_pointer,_qexp),
	'ObjNameStringToList'(_pointer,_list),
	_list = [class(_queryterm)],
    createNewVarname(_this),
    name2id('Proposition',_propid),
    'VarTabInsert'(_this,[_propid]),
	buildQueryLit(_this,_queryterm,_qlit).
transformLit('Mod'(_lit),'Mod'(_newlit)) :-
    !,
    transformLit(_lit,_newlit).
transformLit(not(_lit),not(_newlit)) :-
    !,
    transformLit(_lit,_newlit).
transformLit('Adot'(_cc,_x,_y),'Adot'(_ccid,_xid,_yid)) :-
    !,
    replaceObjnames([_cc,_x,_y],[_ccid,_xid,_yid]).
transformLit('Adot_label'(_cc,_x,_ml,_y,_l),'Adot_label'(_ccid,_xid,_ml,_yid,_l)) :-
    !,
    replaceObjnames([_cc,_x,_y],[_ccid,_xid,_yid]).
transformLit(_lit,_newlit) :-
    _lit =..[_func,_x,_l,_y],
    pc_member(_func,['A','A_e','A_d','Ai']),
    !,
    replaceObjnames([_x,_y],[_xid,_yid]),
    _newlit =.. [_func,_xid,_l,_yid].
transformLit('A_label'(_x,_ml,_y,_l),'A_label'(_xid,_ml,_yid,_l)) :-
    !,
    replaceObjnames([_x,_y],[_xid,_yid]).
transformLit('Aidot'(_cc,_x,_l,_y),'Aidot'(_ccid,_xid,_l,_yid)) :-
    !,
    replaceObjnames([_cc,_x,_y],[_ccid,_xid,_yid]).
transformLit('In'(_x,query(_qexp)),_qlit) :-
    !,
    replaceObjnames([_x],[_xid]),
    pc_stringtoatom(_pointer,_qexp),
	'ObjNameStringToList'(_pointer,_list),
	_list = [class(_queryterm)],
    buildQueryLit(_xid,_queryterm,_qlit).
transformLit(_lit,_newlit) :-
    _lit =..[_func,_x,_y],
    pc_member(_func,['In','In_e','In_s','In_o','In_i','In_eh','From','To','Known','Isa','Isa_e','IDENTICAL','UNIFIES','LT','GT','LE','GE','EQ','NE']),
    !,
    replaceObjnames([_x,_y],[_xid,_yid]),
    _newlit =.. [_func,_xid,_yid].
transformLit(_lit,_lit) :-
    pc_has_a_definition(_lit).

replaceObjnames([],[]).
replaceObjnames([_objname|_rest],[_objname|_restids]) :-
    'VarTabVariable'(_objname),
    !,
    replaceObjnames(_rest,_restids).
replaceObjnames([_objname|_rest],[_oid|_restids]) :-
    atom(_objname),
    !,
    pc_stringtoatom(_pointer,_objname),
	'ObjNameStringToList'(_pointer,_list),
	_list = [class(_objexp)],
	eval(_objexp,replaceSelectExpression,_oid),
	(_objexp \= _oid ; id2name(_oid,_)),
	!,
    replaceObjnames(_rest,_restids).
replaceObjnames([_objname|_rest],_ids) :-
    atomic(_objname),
    !,
    pc_atom_to_term(_objatom,_objname),
    create_if_builtin_object(_objatom),
    replaceObjnames([_objatom|_rest],_ids).
replaceObjnames([_objname|_],_) :-
    report_error('PFNFE','QueryCompiler',[_objname]),
    !,
    fail.

buildQueryLit(_this,derive(_q,_slist),_exp) :-
    !,
    name2id(_q,_qid),
	get_QueryStruct(_qid,_s),
	generate_GenQueryArgs(_this,_s,_slist,_args,_rest),
	_rest == [],
	_exp =..[_qid|_args].
buildQueryLit(_this,_q,_exp) :-
    name2id(_q,_qid),
	get_QueryStruct(_qid,_s),
	generate_GenQueryArgs(_this,_s,[],_args,_rest),
	_rest == [],
	_exp =..[_qid|_args].

generateCodeForDatalogQuery(_queryHead,_headVars, []).
generateCodeForDatalogQuery(_queryHead,_headVars,[body(_bodyVars,_body)|_bodies]) :-
    append(_headVars,_bodyVars,_vars),
    fakeRanges(_vars,_ranges),
    _rule1 = ( _queryHead :- _body ),
    insert_underscores(_rule1,_ranges,_rule),
    generatePROLOGCode([_rule],_prologrule),
    store_tmp_PROLOGrules(_prologrule),
    !,
    generateCodeForDatalogQuery(_queryHead,_headVars,_bodies).

generateCodeForDatalogRule(_rid,_head,_headVars, []).
generateCodeForDatalogRule(_rid,_head,_headVars,[body(_bodyVars,_body)|_bodies]) :-
    append(_headVars,_bodyVars,_vars),
    fakeRanges(_vars,_ranges),
    _rule1 = ( _head :- _body ),
    insert_underscores(_rule1,_ranges,_rule),
    generatePROLOGCode([_rule],_prologrule),
    uniqueAtom(_newid),
    handleCode(rule,id(_rid,_newid),_prologrule),
    !,
    generateCodeForDatalogRule(_rid,_head,_headVars,_bodies).

fakeRanges([],[]).
fakeRanges([_var|_vs],[range(_var,_)|_rs]) :-
    fakeRanges(_vs,_rs).
