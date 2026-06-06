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
% File:         ViewCompiler.pro
% Version:      12.1
% Creation:     31-Jan-1996, Christoph Quix (RWTH)
% Last Change   : 98/04/03, Christoph Quix (RWTH)
%
% SCCS-Source-Pool : /home/CBase/CB_NewStruct/ProductPOOL/SCCS/serverSources/Prolog_Files/s.ViewCompiler.pro
% Date retrieved : 98/04/22 (YY/MM/DD)
%
% --------------------------------------------------------------------------
%
% This module generates from a view definition the NF2 expression. (Part 1)
% This expression is stored together with information about the arguments
% (cf. QueryStruct) as ViewArgExp. (Part 2)
% In the third section, the Datalog rules required for view maintenance
% are generated. These are not (!) the rules with del/ins literals,
% but pure Datalog rules that represent the join conditions between
% the individual sub-queries, as they are computed in buildNF2Exp.
%

:- module('ViewCompiler',[
'buildNF2exp'/3
,'generate_additional_vm_rules'/0
,'get_ViewArgExp'/3
,'get_main_query'/2
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').
%  Part 1

:- use_module('QueryCompilerUtilities.swi.pl').
:- use_module('QueryCompiler.swi.pl').
:- use_module('GeneralUtilities.swi.pl').
:- use_module('PropositionProcessor.swi.pl').
%  Part 2

:- use_module('PROLOGruleProcessor.swi.pl').
%  Part 3

:- use_module('Literals.swi.pl').
:- use_module('VMruleGenerator.swi.pl').
:- use_module('CodeCompiler.swi.pl').
:- use_module('CodeStorage.swi.pl').
:- use_module('RuleBase.swi.pl').
:- use_module('GlobalParameters.swi.pl').
:- use_module('PrologCompatibility.swi.pl').
:- style_check(-singleton).
% ***************************************************************
% ***************************************************************
%  Part 1
%  Construction of NF2 expressions
% ***************************************************************
% ***************************************************************
% ***************************************************************
%
%  buildNF2exp(_q,_argexp,_nfexp)
%
%  Description of arguments:
%        q : ID of the view
%   argexp : expression describing the arguments of an answer term
%             (cf. QueryStruct)
%    nfexp : expression with NF2-algebra-like operations that
%            assemble a complex term from the Datalog rules.
%
%  Description of predicate:
%    First the NF2 expressions for the sub-queries must be computed,
%    then connected into one large overall expression with
%    left-outer joins.
%
% ***************************************************************
%  1. Expression is already stored

buildNF2exp(_q,_argexp,_nfexp) :-
	get_ViewArgExp(_q,_argexp,_nfexp),
	!.
%  2. Expression must be computed

buildNF2exp(_q,_finalargexp,_finalnfexp) :-
	%  first find all subviews that appear in subqueries

	findall(sub_vq(_q,_dest,_label),
			(partofQuery(_q,_dest,_label),subquery(_q,_dest,_label)),
			_l1),
	%  and generate both NF2 and ArgExp's for them,
	%  * already including the associated subquery

	buildNF2_vq(_l1,_explist1,_argexplist1,_joincondlist1),
	%  then consider all subqueries that are NOT also directed at subviews

	findall(sub_q(_q,_dest,_label),
			(subquery(_q,_dest,_label),not(partofQuery(_q,_dest,_label))),
			_l2),
	%  and build NF2 expression and ArgExp for these as well

	buildNF2_q(_l2,_explist2,_argexplist2,_joincondlist2),
	%  merge both lists of NF2 expressions and ArgExp's

	append(_explist1,_explist2,_explist),
	append(_argexplist1,_argexplist2,_argexplist),
	append(_joincondlist1,_joincondlist2,_joincondlist),
	%  now find all subviews that hang directly on the main query

	findall(sub_v(_q,_dest,_label),
			(partofQuery(_q,_dest,_label),not(subquery(_q,_dest,_label))),
			_l3),
	buildNF2_v(_q,_l3,_nfexp31,_argexp31),
	%  here the retrieved_attributes must first be nested together with their labels,
	%  just as already done in the subqueries

	build_nest_rattr(_nfexp31,_argexp31,_nfexp3,_argexp3),
	%  then nest around the result over all arguments except parameters and
	%  this

	build_xnest(_nfexp3,_argexp3,_nfexp4,_argexp4),
	% The join of main query and subqueries proceeds from left to right,
	%  join conditions (equalities) are only identical identifiers in the ArgExp's,
	%  no additional conditions

	build_leftouterjoins(_joincondlist,[_nfexp4|_explist],[_argexp4|_argexplist],_finalnfexp,_finalargexp),
	store_tmp_ViewArgExp(_q,_finalargexp,_finalnfexp).
%  The newly obtained structure is thus reflected in the argexp again!!,
%  meaning this receives additional arguments from the joined-in
%  columns. Join columns are kept at their position in the left join partner.
% ***************************************************************
%
%  buildNF2_vq(_subvqlist,_nfexplist,_argexplist,_joincondlist)
%  buildNF2_vq_Exp(_subvq,_nfexp,_argexp,_joincond)
%
%  Description of arguments:
%  subvqlist : list of sub_vq terms with main query, subview, label
%  nfexplist : list of NF2 expressions for the above sub_vqs
% argexplist : list of ArgExpression for the above sub_vqs
% joincondlist : list of join conditions between main query and subquery
%
%  Description of predicate:
%  Build the NF2 expression for a subview that appears in a subquery
%  and join it with that subquery.
%  First the parameter classes in the subview must be projected away,
%  since they already appear in the subquery.
%  Then join the reduced subview with the subquery and create
%  a ViewArgExp for it
%
% ***************************************************************

buildNF2_vq([],[],[],[]).
buildNF2_vq([_first|_rest],[_firstexp|_restexp],[_firstargexp|_restargexp],[_firstjoin|_rjoin]):-
	buildNF2_vq_Exp(_first,_firstexp,_firstargexp,_firstjoin),
	buildNF2_vq(_rest,_restexp,_restargexp,_rjoin).

buildNF2_vq_Exp(sub_vq(_q,_subv,_label),_nestexp,_nestjoinargexp,_mainjoincond) :-
	%  first build join expression and ArgExp for the subview independently

	buildNF2exp(_subv,_subvargexp,_subvnfexp),
	%  subquery is main query + label

	convert_label(_q,_label,_label1),
	pc_atomconcat([_q,'_',_label1],_subq),
	%  the subquery must then be joined with the subview:
	%  since the subview appears in a subquery, there is therefore a
    %  QueryArgExp for it

	get_QueryStruct(_subq,_subqargexp),
	%  get_QueryStruct(_subv,_subvargexp),
	%  get the information for the join between subquery and subview

	((get_QCjoincond('QCjoincond'(_subq,_subv,_joincond)),
	  !
	 );
	 _joincond=[]
	),
	((get_QCjoincond('QCjoincond'(_q,_subq,_mainjoincond)),
	  !
	 );
	 _mainjoincond=[]
	),
	%  process join condition and suffix first, i.e.
	% 	  labels in joincond must be replaced by integers,
	% 	  build ViewArgExp for the subquery (QueryArgExp of the subquery
	% 	  should already exist), and store everything together.
	%  We no longer need the parameter classes of the SubView,
	%  they would after the join appear as useless attributes
	%  Therefore they are projected away here!

	project_out_parclasses(_subvargexp,_subvnfexp,_joincond,_redsubvargexp,_projexp),
	%  join reduced subview with the subquery

	build_xjoin(_subq,_subqargexp,_projexp,_redsubvargexp,_joincond,_joinexp),
	build_xjoin_argexp(_subqargexp,_redsubvargexp,_joincond,_joinargexp),
	%  nest the result over the parameters and this

	build_xnest(_joinexp,_joinargexp,_nestexp,_nestjoinargexp),
	store_tmp_ViewArgExp(_subq,_nestjoinargexp,_nestexp).
% ***************************************************************
%
%  buildNF2_q(_subqlist,_nfexplist,_argexplist,_joincondlist)
%  buildNF2_q_Exp(_subq,_nfexp,_argexp,_joincond)
%
%  Description of arguments:
%     subq : subq term with main query, target class, and attribute label
%    nfexp : corresponding NF2 expression
%   argexp : argument expression
% joincond : join conditions between main query and subquery
%
%  Description of predicate:
%    Handling of subqueries that do not lead to subview
%  Here one must perform a nest operation for the subquery,
%    in which attribute values are nested together, and obtain the
%    join conditions for the left-outer join with the main query
% ***************************************************************

buildNF2_q([],[],[],[]).
buildNF2_q([_first|_rest],[_firstexp|_restexp],[_firstargexp|_restargexp],[_firstjoin|_rjoin]):-
	buildNF2_q_Exp(_first,_firstexp,_firstargexp,_firstjoin),
	buildNF2_q(_rest,_restexp,_restargexp,_rjoin).

buildNF2_q_Exp(sub_q(_q,_dest,_label),_nestexp,_argexp,_joincond) :-
	convert_label(_q,_label,_label1),
	pc_atomconcat([_q,'_',_label1],_sq),
    	get_QueryStruct(_sq,_oldargexp),
	((get_QCjoincond('QCjoincond'(_q,_sq,_joincond))
	 );
	 _joincond=[]
	),
	!,
	build_nest(_sq,_oldargexp,_nestexp,_argexp),
	%  over all arguments that are not this or parameters

	store_tmp_ViewArgExp(_sq,_argexp,_nestexp).
% ***************************************************************
%
%  buildNF2_v(_query,_subv,_nfexp,_argexp)
%
%  Description of arguments:
%    query : ID of the main query
%     subv : list of subv terms with main query, subview, label
%    nfexp : corresponding NF2 expression
%   argexp : corresponding ArgExpression
%
%  Description of predicate:
%    Handling of SubViews that hang directly on a main query
%    i.e. whose attributes are necessary.
%  Here several cases must be distinguished, e.g. whether there
%    such SubViews exist at all, whether the SubViews have parameters
%    that must be taken into account in the join between main query
%    and subview.
% ***************************************************************
%  1. case: there are no sub_v's, then return the values of the main query
%           as the result!

buildNF2_v(_q,[],_q,_qae) :-
	get_QueryStruct(_q,_qae).
%  2. case: there are some, so build the NF2 expression and ArgExp
%           for the first and use the result for the
%           following subviews.

buildNF2_v(_q,[sub_v(_q,_sv,_label)|_rest],_nfexp,_argexp) :-
	get_QueryStruct(_q,_qae),
	buildNF2_v_Exp(sub_v(_q,_sv,_label),_q,_qae,_nfexp1,_argexp1),
	buildNF2_v(_rest,_nfexp1,_argexp1,_nfexp,_argexp).
%  no further subviews -> in=out

buildNF2_v([],_nfexp,_argexp,_nfexp,_argexp).
%  there are still subviews: compute result for one and
%  use it for the computation of the next subview.

buildNF2_v([_h|_t],_nfexp1,_argexp1,_nfexp,_argexp) :-
	buildNF2_v_Exp(_h,_nfexp1,_argexp1,_nfexp2,_argexp2),
	buildNF2_v(_t,_nfexp2,_argexp2,_nfexp,_argexp).
%  1. case: build the NF2 expression and ArgExp when the subview
%           has parameters that must be taken into account in the
%           join condition.

buildNF2_v_Exp(sub_v(_q,_sv,_label),_oldnfexp,_qae,_xjoinexp,_joinargexp) :-
	'View'(_sv,_),
	retrieve_proposition('P'(_id,_q,_label,_deriveID)),
	retrieve_proposition('P'(_deriveID,_,_deriveatom,_)),
    pc_atomconcat('derive(',_,_deriveatom),
	pc_atom_to_term(_deriveatom,_deriveterm),
	_deriveterm = derive(_sv,_dl),
	!,
	%  build the join condition from the parameter specifications

	check_if_param(_dl,_q,_res,_parjoins1),
	insert_this_par_join(_dl,_parjoins1,_parjoins),
	_joins=[equal(_label,this)|_parjoins],
	%  and store the whole thing

	store_QCjoincond('QCjoincond'(_q,_sv,_joins)),
	%  get the ViewArgExp of the subview

	get_ViewArgExp(_sv,_svae1,_svnfexp1),
	%  project away the parameter classes (not needed and only a nuisance)

	project_out_parclasses(_svae1,_svnfexp1,_joins,_svae,_svnfexp),
	%  build the xJoin between the result so far and the reduced subview

	build_xjoin(_oldnfexp,_qae,_svnfexp,_svae,_joins,_xjoinexp),
	build_xjoin_argexp(_qae,_svae,_joins,_joinargexp).
%  2. case: subview has no parameters

buildNF2_v_Exp(sub_v(_q,_sv,_label),_oldnfexp,_qae,_xjoinexp,_joinargexp) :-
	'View'(_sv,_),
	!,
	%  join condition only for this

	_joins=[equal(_label,this)],
	store_QCjoincond('QCjoincond'(_q,_sv,_joins)),
	get_ViewArgExp(_sv,_svae,_svnfexp),
	%  build the xjoin between the result so far and the subview as above

	build_xjoin(_oldnfexp,_qae,_svnfexp,_svae,_joins,_xjoinexp),
	build_xjoin_argexp(_qae,_svae,_joins,_joinargexp).
% ***************************************************************
% ***************************************************************
%  Part 2
%  Storing the ViewArgExpressions calculated above
% ***************************************************************
% ***************************************************************
% ***************************************************************
%
%  store_tmp_ViewArgExp(_q,_s,_nf)
%  get_ViewArgExp(_q,_s,_nf)
%  get_tmp_ViewArgExp(_q,_s,_nf)
%
%  Description of arguments:
%        q : ID of the view
%        s : QueryStruct
%       nf : NF2 expression for computing the view
%
% ***************************************************************

store_tmp_ViewArgExp(_q,_s,_nf) :-
	store_tmp_PROLOGrules(['ViewArgExp'(_q,_s,_nf)]).

get_ViewArgExp(_q,_s,_nf) :-
	pc_has_a_definition('ViewArgExp'(_,_,_)),
	'ViewArgExp'(_q,_s,_nf),
	!.
get_ViewArgExp(_q,_s,_nf) :-
	get_tmp_ViewArgExp(_q,_s,_nf).

get_tmp_ViewArgExp(_q,_s,_nf) :-
	get_tmp_PROLOGrules(['ViewArgExp'(_q,_s,_nf)]).
% ***************************************************************
% ***************************************************************
%  Part 3
%  Generating the additional rules for view maintenance
% ***************************************************************
% ***************************************************************
% ***************************************************************
%
%  generate_additional_vm_rules/0
%
%  Description of predicate:
%    Generates the rules that specify the join conditions between the
%    sub-queries. Normal evaluation does not use these rules,
%    but only the NF2 expression. For view maintenance,
%    the complex NF2 terms are only a hindrance, which is why the
%    joins are already performed here at the Datalog level.
%
%
%  Change: ruleInfos regarding the rules are also generated here,
%  HW/6.98, and storage of the rule is taken over by
% 	  genPrologCodeFromInfos. Therefore generatePROLOGCode and
% 	  handleCode are dropped in all submodules.
% 	  For this, genPrologCodeFromInfos is called in the main module
% 	  generate_additional_vm_rules.
%   Note:   normally genPrologCodeFromInfos is called in
% 	  ObjectTransformator, and that handles
% 	  Prolog code generation for all generated rules.
% 	  But here the additional VM rules are generated much later
% 	  (after the integrity check), so for all VM rules additionally
% 	  generated here, separate
% 	  rule infos must still be generated, optimized, and Prolog code generated.

generate_additional_vm_rules :-
	get_cb_feature('ViewMaintenanceRules',off),!.
generate_additional_vm_rules :-
	get_cb_feature('ViewMaintenanceRules',on),
	save_setof('QueryArgExp'(_q,_s),get_tmp_QueryStruct('QueryArgExp'(_q,_s)),_qaelist),
	generate_additional_vm_rules(_qaelist),
	genPrologCodeFromInfos.
generate_additional_vm_rules([]).
%  a rule was already generated for _q

generate_additional_vm_rules(['QueryArgExp'(_q,_qs)|_rqaes]) :-
	get_vm_query_name(_q,_vmq),
	get_QueryStruct(_vmq,_vmqs),
	!,
	generate_additional_vm_rules(_rqaes).
%  _q is a DatalogQueryClass

generate_additional_vm_rules(['QueryArgExp'(_q,_qs)|_rqaes]) :-
    name2id('DatalogQueryClass',_dqid),
    prove_literal('In'(_q,_dqid)),
	!,
	generate_additional_vm_rules(_rqaes).
%  Subquery

generate_additional_vm_rules(['QueryArgExp'(_sq,_sqs)|_rqaes]) :-
	'SubQuery'(_sq,_),
	!,
	get_main_query(_sq,_mq),
	get_QueryStruct(_mq,_mqs),
	% Ensure that there is a VM rule for mq

	generate_additional_vm_rules(['QueryArgExp'(_mq,_mqs)]),
	get_vm_query_name(_mq,_vmq),
	get_QueryStruct(_vmq,_vmqs),
	get_QCjoincond('QCjoincond'(_mq,_sq,_joincond)),
	generate_additional_subquery_rule(_sq,_sqs,_vmq,_vmqs,_joincond),
	generate_additional_vm_rules(_rqaes).
generate_additional_vm_rules(['QueryArgExp'(_sv,_svs)|_rqaes]) :-
	name2id('SubView',_svid),
	prove_literal('In_s'(_sv,_svid)),
	!,
	%  mq can also be a subquery, but is treated the same as a query

	get_QCjoincond('QCjoincond'(_mq,_sv,_joincond)),
	get_QueryStruct(_mq,_mqs),
	% Ensure that there is a VM rule for mq

	generate_additional_vm_rules(['QueryArgExp'(_mq,_mqs)]),
	get_vm_query_name(_mq,_vmq),
	get_QueryStruct(_vmq,_vmqs),
	generate_additional_subview_rule(_sv,_svs,_vmq,_vmqs,_joincond),
	generate_additional_vm_rules(_rqaes).
%  everything except subview

generate_additional_vm_rules(['QueryArgExp'(_v,_vs)|_rqaes]) :-
	!,
	%  a proper View/Query does not stand on the right in a Join -> no conditions

	generate_additional_view_rule(_v,_vs),
	generate_additional_vm_rules(_rqaes).
% ***************************************************************
%
%  generate_additional_subquery_rule(_sq,_sqae,_mq,_mqae,_joincond)
%
%  Description of arguments:
%       sq : designation of the subquery
%     sqae : QueryArgExp of the subquery
%       mq : main query
%     mqae : QueryArgExp of the main query
% joincond : join condition for the join between the two queries
%
%  Description of predicate:
%  here one must now enter all parameters of the main query in the
%    subquery head, and in the body enter once the normal subquery and
%    the main-query literal. Take join conditions between arguments of
%    the main query and subquery into account!
%
% ***************************************************************

generate_additional_subquery_rule(_sq,_sqae,_mq,_mqae,_joincond) :-
	get_vm_query_name(_sq,_vmsq),
	buildQueryHead_with_QueryStruct(_sq,_sqae,_sqhead),
	replace_joinargs_in_QueryStruct(_mqae,_joincond,_newmqae),
	buildQueryHead_with_QueryStruct(_mq,_newmqae,_mqhead),
	add_parameter_to_SubQueryStruct(_newmqae,_sqae,_vmsqae),  % newmqae is already altered by the join args
	add_parameter_to_SubQueryStruct(_mqae,_sqae,_goodqae),  % therefore add parameters to the old QAE and ...
	buildQueryHead_with_QueryStruct(_vmsq,_vmsqae,_vmhead),
	_rule = (( _vmhead :- _sqhead , _mqhead)),
	current_view(_OID,_IDS,_Vartab),
	store_vm_rules(view(_OID,_IDS,_Vartab),[_rule]),  % note: vm rules are stored here and
								%  rule infos with Cat: vmrule are generated in VMruleGenerator.

	initDatalogRulesInfo([_rule],query,_OID,_IDS,_Vartab),  % here rule infos for the view rules with
								%  Cat: query are generated.

	store_tmp_QueryStruct('QueryArgExp'(_vmsq,_goodqae)).  % ... store here
% ***************************************************************
%
%  generate_additional_subview_rule(_sv,_svae,_mq,_mqae,_joincond)
%
%  Description of arguments:
%       sv : SubView
%     svae : QueryArgExp of the subview
%       mq : query joined with sv (query or subquery)
%     mqae : corresponding QueryArgExp
% joincond : the join conditions
%
%  Description of predicate:
%    here one need only enter once in the body the normal subview and
%    the main-query literal. Take join conditions between arguments
%    of the main query and subquery into account! The head needs no
%    parameters added; they are already all present on the subview!
%
% ***************************************************************

generate_additional_subview_rule(_sv,_svae,_mq,_mqae,_joincond) :-
	get_vm_query_name(_sv,_vmsv),
	get_necessary_attributes(_svae,_necattrs,_mainsvae),
	generate_additional_necessary_attribute_rule(_sv,_svae,_mainsvae,_necattrs),
	buildQueryHead_with_QueryStruct(_sv,_svae,_svhead),
	replace_joinargs_in_QueryStruct(_mqae,_joincond,_newmqae),
	buildQueryHead_with_QueryStruct(_mq,_newmqae,_mqhead),
	buildQueryHead_with_QueryStruct(_vmsv,_mainsvae,_vmhead),
	_rule = (( _vmhead :- _svhead , _mqhead)),
	current_view(_OID,_IDS,_Vartab),
	store_vm_rules(view(_OID,_IDS,_Vartab),[_rule]),
	initDatalogRulesInfo([_rule],query,_OID,_IDS,_Vartab),
	store_tmp_QueryStruct('QueryArgExp'(_vmsv,_mainsvae)).
% ***************************************************************
%
%  generate_additional_view_rule(_v,_vae)
%
%  Description of arguments:
%        v : View
%      vae : QueryArgExp of the view
%
%  Description of predicate:
%   here one need do almost nothing; main views are not used on the
%   right-hand side of any joins. Therefore only build head
%   literal and body literal as stated in the ArgExp.
%
% ***************************************************************

generate_additional_view_rule(_v,_vae) :-
	get_vm_query_name(_v,_vm),
	get_necessary_attributes(_vae,_necattrs,_mainvae),
	generate_additional_necessary_attribute_rule(_v,_vae,_mainvae,_necattrs),
	buildQueryHead_with_QueryStruct(_v,_vae,_vhead),
	buildQueryHead_with_QueryStruct(_vm,_mainvae,_vmhead),
	_rule = (( _vmhead :-  _vhead )),
	current_view(_OID,_IDS,_Vartab),
	store_vm_rules(view(_OID,_IDS,_Vartab),[_rule]),
	initDatalogRulesInfo([_rule],query,_OID,_IDS,_Vartab),
	store_tmp_QueryStruct('QueryArgExp'(_vm,_mainvae)).
% ***************************************************************
%
%  generate_additional_necessary_attribute_rule(_q,_qae,_mqae,_attrs)
%
%  Description of arguments:
%        q : query of the attributes
%      qae : corresponding ArgExp
%     mqae : ArgExp for the main object (this and parameters)
%     attr : list of attributes in ArgExp form (r,c,cp,rp terms)
%
%  Description of predicate:
%    Generates additional rules for the necessary attributes of a
%    query. The necessary attributes are normally contained in the head
%    of the main query. When an attribute is deleted, one cannot
%    tell at the head of the main query which attribute was deleted
%    (if there are several) and whether the main element should
%    therefore also be deleted. The additional rules therefore form
%    a projection onto the object (with parameters) and one
%    attribute. In generate_(sub)view_rule an analogous rule for the
%    projection onto the main object only is formed. When deleting
%    an attribute there should therefore be a minus term for the
%    given attribute, and for the other rules there may possibly be
%    alternative derivations (rederive).
% ***************************************************************

generate_additional_necessary_attribute_rule(_q,_qae,_mqae,[]).
generate_additional_necessary_attribute_rule(_q,_qae,_mqae,[_attr|_rest]) :-
	buildQueryHead_with_QueryStruct(_q,_qae,_qhead),
	append(_mqae,[_attr],_vmqae),
	arg(1,_attr,_attrlabel),
        convert_label(_q,_attrlabel,_attrlabel1),
	pc_atomconcat(['vm_',_q,'_',_attrlabel1],_vmq),
	buildQueryHead_with_QueryStruct(_vmq,_vmqae,_vmhead),
	_rule = (( _vmhead :-  _qhead )),
	current_view(_OID,_IDS,_Vartab),
	store_vm_rules(view(_OID,_IDS,_Vartab),[_rule]),
	initDatalogRulesInfo([_rule],query,_OID,_IDS,_Vartab),
	store_tmp_QueryStruct('QueryArgExp'(_vmq,_vmqae)),
	generate_additional_necessary_attribute_rule(_q,_qae,_mqae,_rest).
% ***************************************************************
%
%  buildQueryHead_with_QueryStruct(_q,_qs,_head)
%
%  Description of arguments:
%        q : Query
%       qs : QueryStruct
%     head : head of the query
%
%  Description of predicate:
%    Builds from a QueryStruct a rule head that can be used in
%    Datalog.
% ***************************************************************

buildQueryHead_with_QueryStruct(_q,_qs,_head) :-
	get_args_from_QueryStruct(_qs,_arglist),
	_head =.. [_q|_arglist].
% ***************************************************************
%
%  get_args_from_QueryStruct(_qs,_arglist)
%
%  Description of arguments:
%       qs : QueryStruct
%  arglist : argument list with variables as atoms starting with _
%
%  Description of predicate:
%    Returns the argument list for a QueryStruct
% ***************************************************************

get_args_from_QueryStruct([],[]) :- !.
get_args_from_QueryStruct([_atom|_r],[_atomvar|_rarg]) :-
	atom(_atom),
	convert_label(_atom,_atom1),  % "..." is replaced by HK...HK
	!,
	pc_atomconcat('_qvar_',_atom1,_atomvar),
	get_args_from_QueryStruct(_r,_rarg).
get_args_from_QueryStruct([p(_p,_c)|_r],[_pvar,_c|_rarg]) :-
	!,
	convert_label(_p,_p1),
	pc_atomconcat('_qvar_',_p1,_pvar),
	get_args_from_QueryStruct(_r,_rarg).
get_args_from_QueryStruct([cp(_p,_c)|_r],[_pvar,_c|_rarg]) :-
	!,
	convert_label(_p,_p1),
	pc_atomconcat('_qvar_',_p1,_pvar),
	get_args_from_QueryStruct(_r,_rarg).
get_args_from_QueryStruct([rp(_p,_c)|_r],[_plabel,_pvar,_c|_rarg]) :-
	!,
	convert_label(_p,_p1),
	pc_atomconcat('_qvar_',_p1,_pvar),
	pc_atomconcat(['_qvar_',_p1,'_label'],_plabel),
	get_args_from_QueryStruct(_r,_rarg).
get_args_from_QueryStruct([c(_c)|_r],[_cvar|_rarg]) :-
	!,
	convert_label(_c,_c1),
	pc_atomconcat('_qvar_',_c1,_cvar),
	get_args_from_QueryStruct(_r,_rarg).
get_args_from_QueryStruct([r(_c)|_r],[_clabel,_cvar|_rarg]) :-
	!,
	convert_label(_c,_c1),
	pc_atomconcat('_qvar_',_c1,_cvar),
	pc_atomconcat(['_qvar_',_c1,'_label'],_clabel),
	get_args_from_QueryStruct(_r,_rarg).
% ***************************************************************
%
%  replace_joinargs_in_QueryStruct(_qs,_joincond,_newqs)
%
%  Description of arguments:
%       qs : QueryStruct
% joincond : join condition (list of equal terms)
%    newqs : new QueryStruct with replaced argument names
%
%  Description of predicate:
%    When generating the additional rule, first
%    for the two queries from a QueryStruct a rule head is
%    generated. So that common variables are used in the rule heads,
%    in one QS the identifiers of the arguments must be replaced
%    by the corresponding identifiers of the other QS.
%    The matching identifier is found in the join condition.
% ***************************************************************

replace_joinargs_in_QueryStruct([],_,[]) :- !.
replace_joinargs_in_QueryStruct([this|_r],_joincond,[_np|_nr]) :-
	member(equal(this,_np),_joincond),  % _np should actually always be this
	!,
	replace_joinargs_in_QueryStruct(_r,_joincond,_nr).
replace_joinargs_in_QueryStruct([p(_p,_c)|_r],_joincond,[p(_np,_c)|_nr]) :-
	member(equal(_p,_np),_joincond),
	!,
	replace_joinargs_in_QueryStruct(_r,_joincond,_nr).
replace_joinargs_in_QueryStruct([cp(_p,_c)|_r],_joincond,[cp(_np,_c)|_nr]) :-
	member(equal(_p,_np),_joincond),
	!,
	replace_joinargs_in_QueryStruct(_r,_joincond,_nr).
replace_joinargs_in_QueryStruct([rp(_p,_c)|_r],_joincond,[rp(_np,_c)|_nr]) :-
	member(equal(_p,_np),_joincond),
	!,
	replace_joinargs_in_QueryStruct(_r,_joincond,_nr).
replace_joinargs_in_QueryStruct([c(_p)|_r],_joincond,[c(_np)|_nr]) :-
	member(equal(_p,_np),_joincond),
	!,
	replace_joinargs_in_QueryStruct(_r,_joincond,_nr).
replace_joinargs_in_QueryStruct([r(_p)|_r],_joincond,[r(_np)|_nr]) :-
	member(equal(_p,_np),_joincond),
	!,
	replace_joinargs_in_QueryStruct(_r,_joincond,_nr).
replace_joinargs_in_QueryStruct([this|_r],_joincond,[non_relevant_this|_nr]) :-
	!,
	replace_joinargs_in_QueryStruct(_r,_joincond,_nr).
replace_joinargs_in_QueryStruct([_t|_r],_joincond,[_nt|_nr]) :-
	functor(_t,_op,2),
	!,
	functor(_nt,_op,2),
	arg(1,_t,_arg),
	pc_atomconcat('non_relevant_',_arg,_narg),
	arg(1,_nt,_narg),
	arg(2,_t,_arg2),
	arg(2,_nt,_arg2),
	replace_joinargs_in_QueryStruct(_r,_joincond,_nr).
replace_joinargs_in_QueryStruct([_t|_r],_joincond,[_nt|_nr]) :-
	functor(_t,_op,1),
	!,
	functor(_nt,_op,1),
	arg(1,_t,_arg),
	pc_atomconcat('non_relevant_',_arg,_narg),
	arg(1,_nt,_narg),
	replace_joinargs_in_QueryStruct(_r,_joincond,_nr).
% ***************************************************************
%
%  add_parameter_to_SubQueryStruct(_qs,_subqs,_newsubqs)
%
%  Description of arguments:
%       qs : QueryStruct of the main query
%    subqs : QueryStruct of a subquery
% newsubqs : result
%
%  Description of predicate:
%    Inserts the parameters of the main query into the subquery.
%    Thus the parameters of the main query also appear in the newly
%    generated head of the subquery. This is necessary because a change
%    to the subquery must also have the "full" object name to which
%    the parameters of a query belong.
%
% ***************************************************************

add_parameter_to_SubQueryStruct([],_sq,_sq) :-!.
add_parameter_to_SubQueryStruct([p(_p,_c)|_r],_sq,_nsq) :-
	\+(member(p(_p,_c),_sq)),
	!,
	add_parameter_to_SubQueryStruct(_r,_sq,_nsq1),
	append(_nsq1,[p(_p,_c)],_nsq).
add_parameter_to_SubQueryStruct([cp(_p,_c)|_r],_sq,_nsq) :-
	\+(member(cp(_p,_c),_sq)),
	!,
	add_parameter_to_SubQueryStruct(_r,_sq,_nsq1),
	append(_nsq1,[cp(_p,_c)],_nsq).
add_parameter_to_SubQueryStruct([rp(_p,_c)|_r],_sq,_nsq) :-
	\+(member(rp(_p,_c),_sq)),
	!,
	add_parameter_to_SubQueryStruct(_r,_sq,_nsq1),
	append(_nsq1,[rp(_p,_c)],_nsq).
add_parameter_to_SubQueryStruct([_x|_r],_sq,_nsq) :-
	!,
	add_parameter_to_SubQueryStruct(_r,_sq,_nsq).
%  generate a name for the generated additional queries

get_vm_query_name(_q,_vmq) :-
	pc_atomconcat('vm_',_q,_vmq).
%  get the ID of the main query for a subquery

get_main_query(_id,_qID) :-
	pc_atomconcat('id_',_r1,_id),
	split_atom(_r1,'_',_num,_attr),
	\+(pc_atompart(_num,'_',_,_)),
	pc_atomconcat(['id_',_num],_qID),
	'Query'(_qID).
% ***************************************************************
%
%  get_necessary_attributes(_qae,_necattr,_mainqae)
%
%  Description of arguments:
%      qae : QueryArgExp
%  necattr : ArgExp for attributes
%  mainqae : ArgExp without attributes (only this and Parameter)
%
%  Description of predicate:
%    Filters the attributes out of an ArgExp; these are the
%    attributes that are necessary for the query.
%    If an attribute is a parameter and retrieved/computed (cp+rp),
%    then it appears in both necattr and mainqae.
%
% ***************************************************************

get_necessary_attributes([],[],[]).
get_necessary_attributes([this|_rqae],_necattr,[this|_mainqae]) :-
	get_necessary_attributes(_rqae,_necattr,_mainqae).
get_necessary_attributes([p(_p,_c)|_rqae],_necattr,[p(_p,_c)|_mainqae]) :-
	get_necessary_attributes(_rqae,_necattr,_mainqae).
get_necessary_attributes([cp(_p,_c)|_rqae],_necattr,[cp(_p,_c)|_mainqae]) :-
	get_necessary_attributes(_rqae,_necattr,_mainqae).
get_necessary_attributes([rp(_p,_c)|_rqae],_necattr,[rp(_p,_c)|_mainqae]) :-
	get_necessary_attributes(_rqae,_necattr,_mainqae).
get_necessary_attributes([c(_c)|_rqae],[c(_c)|_necattr],_mainqae) :-
	get_necessary_attributes(_rqae,_necattr,_mainqae).
get_necessary_attributes([r(_c)|_rqae],[r(_c)|_necattr],_mainqae) :-
	get_necessary_attributes(_rqae,_necattr,_mainqae).
