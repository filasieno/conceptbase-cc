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
% File:         SubQueryCompiler.pro
% Version:      11.3
% Creation:     31-Jan-1996, Christoph Quix (RWTH)
% Last Change   : 96/10/28, Christoph Quix (RWTH)
%
% SCCS-Source-Pool : /home/CBase/CB_NewStruct/ProductPOOL/serverSources/Prolog_Files/SCCS/s.SubQueryCompiler.pro
% Date retrieved : 97/01/21 (YY/MM/DD)
%
% --------------------------------------------------------------------------
%
% This module translates the subqueries of a query class or views.
% compile_subqueries in Part 1 creates the Datalog code.
% get_subquery_info in Part 2 generates the information needed
% for the Datalog rules. The core is handle_subquery, which
% also stores the join conditions for the NF2 expression.
%
% Changes: Prolog code generation is done after optimization in RuleBase; here after compilation only
% the initialization of the rule infos. (See QueryCompiler.)
%

:- module('SubQueryCompiler',[
'compile_subqueries'/3
,'get_subquery_infos'/2
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').
:- use_module('PropositionProcessor.swi.pl').
:- use_module('QueryCompiler.swi.pl').
:- use_module('AssertionTransformer.swi.pl').
:- use_module('LTcompiler.swi.pl').
:- use_module('GeneralUtilities.swi.pl').
:- use_module('FragmentToPropositions.swi.pl').
:- use_module('QueryCompilerUtilities.swi.pl').
:- use_module('ViewCompiler.swi.pl').
:- use_module('RuleBase.swi.pl').
:- use_module('PrologCompatibility.swi.pl').
:- style_check(-singleton).
%  PART 1
% ***************************************************************
%
%  compile_subqueries(_mode,_query,_subqueries)
%
%  Description of arguments:
%     mode : query or mquery (here presumably always query)
%    query : ID of the query
% subqueries : list of the SubQueries
%
%  Description of predicate:
%  compile_subqueries already assumes that all relevant
%  information has been collected for generating the Datalog code;
%  it matches exactly the translation of the main query
%
% ***************************************************************

compile_subqueries(_,_,[]).
compile_subqueries(_mode,_q,[_subquery|_rest]) :-
	compile_subquery(_mode,_subquery),
	compile_subqueries(_mode,_q,_rest).
% ***************************************************************
%
%  compile_subquery(_mode,_querystruct)
%
%  Description of arguments:
%     mode : as above, query or mquery
% querystruct : a term containing the subquery information
%
%  Description of predicate:
%   SubQueries are translated in a similar way to main queries;
%   QueryStructs are stored
% ***************************************************************

compile_subquery(_mode,subquery(_subqname,'QS'(_queryHead,_vts,_lits),_subQAE)) :-
	create_IDS(_subqname,_qIDS),
	store_tmp_QueryStruct(_subQAE),
	generateRangeform('QS'(_queryHead,_vts,_lits), '$ TRUE $', _queryRF, _vartab),
	get_main_query(_subqname,_qID),
	generateDatalog(_qID,_qIDS,_queryRF,_vartab,_ruleDLs),
	initDatalogRulesInfo(_ruleDLs,_mode,_qID,_qIDS,_vartab).
%  PART 2
% ***************************************************************
%
%  get_subquery_infos(_query,_info)
%
%  Description of arguments:
%    query : ID of the main query
%     info : list of SubQuery terms
%
%  Description of predicate:
%  collects the information for the subqueries and
%  as a side effect generates (join) information for the
%  NF2 expressions
%  (called by get_all_infos of the main query;
%    the subviews are already compiled at this point
%    and the NF2 expression is available.)
% ***************************************************************

get_subquery_infos(_q,_info) :-
	findall(subquery(_subqname,_subQS,_subQAE),
			get_sub_info(_q,_subqname,_subQS,_subQAE),
			_info),
	%  remove no longer needed info

	retractall('QCisa'(_q,_)),
	retractall('QCparam'(_q,_p,_C)).
% ***************************************************************
%
%  get_sub_info(_query,_subquery,_subQS,_subQAE)
%
%  Description of arguments:
%    query : ID of the main query
% subquery : designation of the subquery (id_1234_label)
%    subQS : QueryStruct of the subquery
%   subQAE : QueryArgExp of the subquery
%
%  Description of predicate:
%   Retrieves the information for a subquery of a given main query.
% ***************************************************************

get_sub_info(_q,_subqname,_subQS,_subQAE):-
	'QCsubquery'(_q,_l,_destID,_type),
	handle_subquery(_q,_l,_destID,_type,_subQS,_subQAE),
	pc_atomconcat(_q,'_',_h1),
	convert_label(_q,_l,_l1),
	pc_atomconcat(_h1,_l1,_subqname).
% ***************************************************************
%
%  handle_subquery(_q,_l,_dest,_type,_qs,_qae)
%
%  Description of arguments:
%        q : ID of the main query
%        l : label of the subquery attribute
%     dest : ID of the target class of the SQ attribute
%     type : 'c' or 'r' for computed/retrieved-attribute
%       qs : QueryStruct of the subquery
%      qae : QueryArgExp of the subquery
%
%  Description of predicate:
%  Depending on whether the target component of the attribute is a
%  derivation expression, one must pay attention to parameters of
%  the main query that can occur. In each case, for derivation
%  expressions one must remember the join condition
%  'attributelabel'='this' for the join between subquery and
%  subview. This applies however only when the derivation expression
%  actually applies to a subview and not to an ordinary generic
%  query class.
%
% ***************************************************************
% **
% CASE 1
% **
% Case 1: _destID is derive-exp, i.e. also consider parameters if applicable
%  only required when derive expression is for a Subview !!
%  If a parameter of the main query is passed to a parameter of the subview
%  (e.g. S(p/q), first the parameter p is thus
%  an argument of the subquery and when later joining with the subview
%  the join condition eq(p,q) is needed.

handle_subquery(_q,_l,_destID,_type,'QS'(_queryHead,[('~this',_isalist)|_vts],_lits),_subQAE) :-
	retrieve_proposition('P'(_destID,_ ,_label,_)),
    sub_atom(_label,_,_,_,'derive('),
	pc_atom_to_term(_label,_term),
	_term = derive(_s,_dl),
	!,
	% If no parameter of the main query appears in the derive expression (target component
	%  of the attribute), no join condition is needed either, i.e. _joins=[]

	check_if_param(_dl,_q,_res,_parjoins1),
	insert_this_par_join(_dl,_parjoins1,_parjoins),
	% _res contains the parameter description for the affected
	%  parameters of the main query that also appear in the subquery
	%  These parameters must therefore also appear in the head of the subquery

	build_subquery_info(_q,_l,_destID,_type,_res,_lits,_vts,_args),
	'QCisa'(_q,_isalist),
	convert_label(_q,_l,_l1),
	pc_atomconcat([_q,'_',_l1],_subqueryID),
	% Besides the join condition for parameters, in every case one needs
	%  the condition that 'this' in the subview corresponds to 'l' in the subquery; therefore
	%  store it as well; NOT when _destID or the derive expression
	%  refers only to an ordinary generic query class
	%  For the join with the subview:
	%   if _s is a view, additionally join label and this

	(('IsView'(_s),
	  _njoins=[equal(_l,this)|_parjoins],
	  store_QCjoincond('QCjoincond'(_subqueryID,_s,_njoins)),
	  !
	 );
	 %  otherwise joining the parameters suffices; that
	 %  is handled however by the Prolog code (it is not a subview!)

	 (_njoins = _parjoins
	 )
	),
	%  for the join between main query and subquery, one must
	%  compare the parameters and this

	store_QCjoincond('QCjoincond'(_q,_subqueryID,[equal(this,this)|_parjoins1])),
	buildQueryHead(_subqueryID,[('~this',_isalist)|_vts],_queryHead),
	buildQueryArgExp(_subqueryID,[this|_args],_subQAE).
% **
% CASE 2
% **
%  Case 2: Normal case; parameters of the original query are irrelevant,
%  i.e. destID is not a derive expression; then one only needs to join
%  the this of the main query and the this of the subquery!

handle_subquery(_q,_l,_destID,_type,'QS'(_queryHead,[('~this',_isalist)|_vts],_lits),_subQAE) :-
	build_subquery_info(_q,_l,_destID,_type,[],_lits,_vts,_args),
	% 5th argument (_res) empty, since no parameters of the main query are relevant

	'QCisa'(_q,_isalist),
	convert_label(_q,_l,_l1),
	pc_atomconcat([_q,'_',_l1],_subqueryID),
	%  The join condition for main and subquery

	store_QCjoincond('QCjoincond'(_q,_subqueryID,[equal(this,this)])),
	%  If destID is a view, additionally remember the join between
	%  subquery and subview destID

	(('IsView'(_destID),
	  store_QCjoincond('QCjoincond'(_subqueryID,_destID,[equal(_l,this)]))
	 );
	 true
	),
	!,
	buildQueryHead(_subqueryID,[('~this',_isalist)|_vts],_queryHead),
	buildQueryArgExp(_subqueryID,[this|_args],_subQAE).
% ***************************************************************
%
%  build_subquery_info(_q,_l,_dest,_type,_p,_lits,_vts,_args)
%
%  Description of arguments:
%        q : ID of the main query
%        l : label of the SQ attribute
%     dest : ID of the target class of the SQ attribute
%     type : c or r, for computed/retrieved attribute
%        p : list of p(_p,_C) terms for parameters
%     lits : literals for Param.-Var., this, and attribute
%      vts : VarTabRange: list of terms (_var,_type)
%     args : list for the QueryArgExp (c(_),r(_),p(_)-terms)
%
%  Description of predicate:
%   generates the necessary specifications for the subquery:
%      a) argument for the attribute value and
%      b) if applicable, for parameters of the main query
%
% ***************************************************************

build_subquery_info(_q,_l,_destID,c,_p,
		[lit('In'(_pl,_destID))|_lits],
		[(_pl,_destID)|_pvt],
		[c(_l)|_args]) :-
	% for computed attributes that are not necessary, they also do not appear in the constraint
	% here a new var is still created, since no references are possible anyway

	createNewVarname(_pl),
	build_param(_p,_lits,_pvt,_args).
build_subquery_info(_q,_l,_destID,r,_p,
		[lit('A_label'('~this',_l,_pl,_label)),lit('In'(_pl,_destID))],
		[(_label,_labid),(_pl,_destID)|_pvt],
		[r(_l)|_args]):-
	% for retrieved attributes

	createNewVarname(_pl),
	createNewVarname(_label),
	name2id('Proposition',_propid),
	name2id('Label',_labid),
	build_param(_p,_lits,_pvt,_args).
