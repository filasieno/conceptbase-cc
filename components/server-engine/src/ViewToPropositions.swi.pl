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
% File 		: %M%
% Version	: %I%
% Creation	: 14-Mar-95,  Christoph Quix (RWTH)
% Last change : %G%, Christoph Quix (RWTH)
% Release	: %R%
%
% -----------------------------------------------
%
% Transformation of special parts of a SMLfragment
% (enumeration, selectExpB, complexRef, ..) to Propositions.
%

:- module('ViewToPropositions',[
'qclist'/2
,'store_complexRef'/3
,'store_enumeration'/3
,'store_selectExpB'/3
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').
:- use_module('VarTabHandling.swi.pl').
:- use_module('MSFOLassertionParserUtilities.swi.pl').
:- use_module('FragmentToPropositions.swi.pl').
:- use_module('validProposition.swi.pl').
:- use_module('Literals.swi.pl').
:- use_module('GeneralUtilities.swi.pl').
:- use_module('ScanFormatUtilities.swi.pl').
:- use_module('SelectExpressions.swi.pl').
:- use_module('MSFOLpreProcessor.swi.pl').
:- use_module('PrologCompatibility.swi.pl').
% ===========================================================
% =              LOCAL PREDICATE DECLARATION                =
% ===========================================================

:- dynamic 'qclist'/2 .
:- style_check(-singleton).
% ===========================================================
% =             EXPORTED PREDICATES DEFINITION              =
% ===========================================================
% *******************************************************
%  store_selectExpB(_x,_AClist,_prop)
%
%    For a SelectExpB a ... new QC is created, which as
%    constraint
%    contains "this in <SelectExpB>".
%
% *******************************************************
%  case 1: this|. ...  (SelectExpressions with this as first object => parameter for QC needed)

store_selectExpB(_xid,_AClist,property(_l,selectExpB(_this,_op,_right))) :-
	(_this == 'this' ; _this == '~this'),
	!,
	id2name(_xid,_x),
	create_subview_name(_x,_l,_qc),
	_par = '~this_par',
	saveVarTabInsert(['~this'],[_xid]),  % register implicit variable this in VarTab
	replaceSelectExpB(selectExpB('~this',_op,_right),'~this',_destid,_newterm),  % determine _dest only
    pc_atomconcat('constr_',_l,_cprop),
    rebuildSelectExpB(selectExpB(_par,_op,_right),_selectAtom),
	pc_atomconcat(['$ ~this in ',_selectAtom,' $'],_constr),
	_attrdecl2=attrdecl([constraint],[property(_cprop,_constr)]),
	pc_atomconcat('~',_par_ohne_at,_par),
	(qclist(_,_qclist);
	 _qclist = [q(_qc,[p(_par_ohne_at,_x)])]
	),
	name2id('View',_vid),
    store_Sub_Object(what(_qc),in(_vid),isa([class(_destid)]),with([_attrdecl2]),_qclist),
    store_property(_xid,_AClist,property(_l,derive(_qc,[substitute('~this',_par_ohne_at)]))).
%  case 2: obj|. ... (SelectExpressions with arbitrary object)
% (here SelectExpressions with scope-resolution operator are also handled, which was already
%  replaced earlier)

store_selectExpB(_xid,_AClist,property(_l,selectExpB(_obj1,_op,_right))) :-
	_obj1 \== '~this',
	_obj1 \== this,
	id2name(_xid,_x),
	eval(_obj1,replaceSelectExpression,_obj),
	create_subview_name(_x,_l,_qc),
	'VarTabLookup_ranges'(_r),
	replaceSelectExpB(selectExpB(_obj,_op,_right),'~this',_destid,_newterm),  % determine _dest only
	!,
	pc_atomconcat('constr_',_l,_cprop),
	rebuildSelectExpB(selectExpB(_obj,_op,_right),_selectAtom),
	pc_atomconcat(['$ ~this in ',_selectAtom,' $'],_constr),
	_attrdecl1=attrdecl([constraint],[property(_cprop,_constr)]),
	(qclist(_,_qclist);
	 _qclist = []
	),
	!,
	name2id('View',_vid),
	store_Sub_Object(what(_qc),in(_vid),isa([class(_destid)]),with([_attrdecl1]),_qclist),
	store_complex_property(_xid,_AClist,property(_l,_qc),_qclist).
% *******************************************************
%  store_complexRef(_x,_AClist,property(_l,_smlfrag))
%
%    For a nested frame a ... new QC is created, which
%    may again contain complex expressions for which
%    further QCs must be created
%
%    Before the new QCs are stored, the parameters for the
%    more deeply nested QCs are determined first
%    (stored in qclist/2)
%    and scope-resolution expressions (this::... ) are replaced
%    by unique identifiers (parameters or this)
%
% *******************************************************

store_complexRef(_xid,_AClist,property(_l,['SMLfragment'(what([]),in_omega([]),in([]),isa(_classlist),with(_attrdecllist))])) :-
	id2name(_xid,_x),
	create_subview_name(_x,_l,_xhelp),
	((qclist(_,_outqclist),
	  _outadlist = _attrdecllist
	 );
	 (attrdecl_parameter(_xhelp,[a('~this',_x),a(_l,_xhelp)],_attrdecllist,_outadlist, [], _outqclist),
	  pc_update(qclist(_x,_outqclist))
	 )
	),
	!,
	name2id('SubView',_svid),
    store_Sub_Object(what(_xhelp),in(_svid),isa(_classlist),with(_outadlist),_outqclist),
    store_complex_property(_xid,_AClist,property(_l,_xhelp),_outqclist),
	(retract(qclist(_x,_outqclist));
	 true
	).
% *******************************************************
%  store_enumeration(_x,_AClist,property(_l,_enum))
%
%   For an enumeration a ... new QC is created, which
%   as constraint contains $ (this == e1) or ... (this == en) $,
%   where the ei's are the elements of the enumeration.
%   To find the superclass of the new QC, the superclasses
%   of _x for attribute _l are searched.
%
% *******************************************************

store_enumeration(_xid,_AClist,property(_l,enumeration(_list))) :-
	id2name(_xid,_x),
	create_subview_name(_x,_l,_qc),
	!,
	prove_literal('Isa'(_xid,_classid1)),
    _xid \== _classid1,
	prove_literal('P'(_,_classid1,_l,_classid)),
	pc_atomconcat('constr_',_l,_cprop),
	enumerationToConstraint(_list,_constr),
	_attrdecl1=attrdecl([constraint],[property(_cprop,_constr)]),
	name2id('View',_vid),
    store_Sub_Object(what(_qc),in(_vid),isa([class(_classid)]),with([_attrdecl1]),[]),
	name2id(_qc,_qcid),
	store_property(_xid,_AClist,property(_l,_qcid)).
% ===========================================================
% =                LOCAL PREDICATES DEFINITION              =
% ===========================================================
% *******************************************************
%  store_complex_property(_x,_AClist,property(_l,_c),_qclist)
%
%   In _qclist a list of all QCs to be stored with
%   their parameters is kept. If _c is not in _qclist,
%   _c needs no parameters and can be stored directly.
%   Otherwise a derive expression is built using the
%   parameter list.
%
% *******************************************************

store_complex_property(_xid,_AClist,property(_l,_c),_qclist) :-
	member(q(_c,_plist),_qclist),
	!,
	id2name(_xid,_x),
	make_derive_exp(_x,_c,_plist,_dexp),
	store_property(_xid,_AClist,property(_l,_dexp)).
store_complex_property(_xid,_AClist,property(_l,_c),_qclist) :-
	name2id(_c,_cid),
	store_property(_xid,_AClist,property(_l,_cid)).
% *******************************************************
%  make_derive_exp(_x,_c,_plist,_deriveexp)
%    (helper predicate for store_complex_property/4)
%
%   Builds a derive expression for a QC _c with parameter
%   list _plist that is to be used at an attribute of class
%   _x. Parameter names are the same and unique across all
%   nested QCs, i.e. substitute(_p1,_p1) means parameter
%   _p1 of _c is replaced by parameter _p1 of _x. Only when
%   parameter _p1 is to be an element of _x is _p1
%   replaced by 'this'.
%
% *******************************************************

make_derive_exp(_x,_c,_plist,derive(_c,_slist)) :-
	make_derive_exp2(_x,_plist,_slist).

make_derive_exp2(_x,[p(_p1,_x)],[substitute('~this',_p1)]):-!.
make_derive_exp2(_x,[p(_p1,_c)],[substitute(_par,_p1)]):-
	pc_atomconcat('~',_p1,_par),
	_x\==_c,!.
make_derive_exp2(_x,[p(_p1,_x)|_t],[substitute('~this',_p1)|_slist]) :-
	make_derive_exp2(_x,_t,_slist).
make_derive_exp2(_x,[p(_p1,_c)|_t],[substitute(_par,_p1)|_slist]) :-
	pc_atomconcat('~',_p1,_par),
	_x \== _c,
	make_derive_exp2(_x,_t,_slist1).
% *******************************************************
%  store_Sub_Object(what(_qc),_isa,_with,_qclist)
%
%   Stores a sub-QC formed from a SelectExpB,
%  complexRef or enumeration. Here no more parameters need
%   to be determined and no more scope-resolution
%   expressions need to be replaced. If _qc is not in
%   _qclist, _qc needs no parameters. Otherwise the
%   parameters must still be added to the attribute
%   declaration list.
%
% *******************************************************

store_Sub_Object(what(_what),in(_gqcid),isa(_isa),with(_attrdecllist),_qclist) :-
	member(q(_what,_plist),_qclist),
   	_plist \== [],
	!,
	add_plist_to_attrdecllist(_plist,_attrdecllist,_adlist2),
	changeIdentifierExp('SMLfragment'(what(_what),
	                                in_omega([class(_gqcid)]),
									in([]),
									isa(_isa),
									with(_adlist2)),
						replaceSelectExpression,
						'SMLfragment'(what(_nwhat),
						            in_omega([class(_ngqcid)]),
									in([]),
									isa(_nisa),
								    with(_nadlist2))),
	store_what(what(_nwhat)),
	store_in_omega(what(_nwhat),in_omega([class(_ngqcid)])),
	store_isa(what(_nwhat),isa(_nisa)),
	store_with(what(_nwhat),with(_nadlist2)),
	store_query(what(_nwhat)).
store_Sub_Object(what(_what),in(_qcid),isa(_isa),with(_attrdecllist),_qclist) :-
	!,
	changeIdentifierExp('SMLfragment'(what(_what),
	                                in_omega([class(_qcid)]),
									in([]),
									isa(_isa),
									with(_attrdecllist)),
						replaceSelectExpression,
						'SMLfragment'(what(_nwhat),
						            in_omega([class(_nqcid)]),
									in([]),
									isa(_nisa),
								    with(_nadlist))),
	store_what(what(_nwhat)),
	store_in_omega(what(_nwhat),in_omega([class(_nqcid)])),
    store_isa(what(_what),isa(_nisa)),
	store_with(what(_nwhat),with(_nadlist)),
	store_query(what(_nwhat)).
% *******************************************************
%  add_plist_to_attrdecllist([p(_p1,_c1)|_plistrest],
%  							_oldadlist,_newadlist)
%    (helper predicate for store_Sub_Object/4)
%
%   Adds parameter declarations to an attribute declaration
%   list. The classes of the parameters are not the _ci's
%   (the QCs themselves), but their superclasses, to avoid
%   recursion.
%
% *******************************************************

add_plist_to_attrdecllist([],_adlist,_adlist) :- ! .
%  Do not store the query classes, but their superclasses, to avoid recursion

add_plist_to_attrdecllist([p(_p1,_c1)|_t],_adlist,[attrdecl([parameter],[property(_par,_class)])|_adlist2]) :-
	(pc_atomconcat('~',_par,_p1);_par = _p1),
	name2id(_c1,_cid),
	setof(_x,(prove_literal('Isa'(_cid,_x)),_cid\==_x),_classlist),
	get_parameter_class(_classlist,_class),
	add_plist_to_attrdecllist(_t,_adlist,_adlist2).
%  No superclass was found for the QC _c1 ==> use _c1 as parameter class (--> recursion)

add_plist_to_attrdecllist([p(_p1,_c1)|_t],_adlist,[attrdecl([parameter],[property(_p1,_c1)])|_adlist2]) :-
	add_plist_to_attrdecllist(_t,_adlist,_adlist2).
% *******************************************************
%  get_parameter_class(_list,_parclass)
%      (helper predicate for add_plist_to_attrdecllist/3)
%
%   When the parameter list is added to the attrdecl list,
%   superclasses of QCs are searched. If a QC has multiple
%   superclasses, a new QC must be created that has these
%   superclasses as its superclasses. If there is only one
%   superclass, that is the parameter class.
%
% *******************************************************

get_parameter_class([_x],_x) :- !.
get_parameter_class(_l,_newqc) :-
	length(_l,_n),
	_n > 1,
	pc_atomconcat(['SV_'|_l],_newqc),
	list2classlist(_l,_l2),
	name2id('View',_vid),
	store_Sub_Object(what(_newqc),in(_vid),isa(_l2),with([]),[]).
% *******************************************************
%  list2classlist(_l,_cl)
%    (helper predicate for get_parameter_class/2)
%
%   Converts a list of atoms [a1,...,an] into
%   a list of terms of the form [class(a1),...,class(an)].
%
%
% *******************************************************

list2classlist([],[]) .
list2classlist([_h|_t],[class(_h)|_t2]) :-
	list2classlist(_t,_t2).
% **************************************************************************
%  attrdecl_parameter(_what,_inattr,_inadlist,_outadlist,_inqclist, _outqclist)
%    (called by store_complexRef)
%
%  Idea: search all attribute definitions for required parameters:
%        record all occurring attribute labels in _inattr
%           [a(a1,c1),a(a2,c2),....] ai denotes the attribute label, ci is
%           the class to which ai refers, i.e. this::...::ai shall be an
% 		   element of ci.
%
%        replace scope_res expressions in _inadlist with the generated
%           unique parameters (new terms in _outadlist)
%
%        return a list of (generic) QCs with their parameters
%           (i.e. _inqclist is extended by further QCs
%           [q(qc1,[p(p11,c11),p(p12,c12),...],q(qc2,...),...]
%              qci is the name of the query class
%              pij is a parameter of query class qci
%              cij is the query class to which pij belongs
% 				(cij is replaced by a superclass when storing in order to
% 				 prevent recursion)
%
% **************************************************************************
%  Case 1: no attributes -> nothing to do

attrdecl_parameter(_what,_inattr, [], [], _inqclist, _inqclist) :- !.
%  case 2: first search for parameters of the property and then those of the remaining attributes

attrdecl_parameter(_what,_inattr, [attrdecl(_AClist,_inproplist)|_intail], [attrdecl(_AClist,_outproplist)|_outtail], _inqclist,_outqclist) :-
	proplist_parameter(_what,_inattr,_inproplist,_outproplist,_inqclist, _outqclist1),
	attrdecl_parameter(_what,_inattr,_intail,_outtail,_inqclist,_outqclist2),
	union_qc_list(_outqclist1,_outqclist2,_outqclist).
% **************************************************************************
%  proplist_parameter(_what,_inattr,_inadlist,_outadlist,_inqclist, _outqclist)
%    (helper predicate for attrdecl_parameter/6)
%
%   Analogous to attrdecl_parameter, but here only for a property list.
%
% **************************************************************************
%  Case 1: no property -> nothing to do

proplist_parameter(_what,_inattr, [],[], _inqclist,_inqclist) :- !.
%  Case 2: derive expression -> no parameters

proplist_parameter(_what,_inattr, [property(_l2,derive(_,_))|_intail], [property(_l2,derive(_,_))|_outtail],_inqclist,_outqclist) :-
	proplist_parameter(_what,_inattr,_intail,_outtail,_inqclist,_outqclist).
%  Case 3: SelectExpB starting with 'this' -> this_par is parameter of all QCs above _what

proplist_parameter(_what,[_h|_t], [property(_l,selectExpB(_this,_op,_right))|_intail], [property(_l,selectExpB('~this_par',_op,_right))|_outtail], _inqclist, _outqclist) :-
	(_this == this; _this == '~this'),
	create_subview_name(_what,_l,_newqc),
	a('~this',_thisclass) = _h,
   	add_qc_parameter([_h|_t],_inqclist,_newqc,p('this_par',_thisclass),_outqclist1),
	!,
	proplist_parameter(_what,[_h|_t],_intail,_outtail,_inqclist,_outqclist2),
	union_qc_list(_outqclist1,_outqclist2,_outqclist).
%  Case 4: SelectExpB with scope_res operator '::' -> replace scope_res expression,
%          add parameter if 'this' was not meant

proplist_parameter(_what,[_h|_t], [property(_l,selectExpB(scope_res(_this,_sc),_op,_right))|_intail], [property(_l,selectExpB(_par,_op,_right))|_outtail], _inqclist, _outqclist) :-
	(_this == this; _this == '~this'),
	create_subview_name(_what,_l,_newqc),
	append(_t,[a(_l,_newqc)],_t2),
	replace_scope_res([_h|_t2],scope_res('~this',_sc),_par,_class),
	((_par == '~this',_outqclist1 = _inqclist);
	 (pc_atomconcat('~',_par_ohne_at,_par),
   	  add_qc_parameter([_h|_t],_inqclist,_newqc,p(_par_ohne_at,_class),_outqclist1)
	 )
	),
	!,
	proplist_parameter(_what,[_h|_t],_intail,_outtail,_inqclist,_outqclist2),
	union_qc_list(_outqclist1,_outqclist2,_outqclist).
%  case 5: SelectExpB with a specific object -> search remaining prop. list

proplist_parameter(_what, _inattr, [property(_l,selectExpB(_obj,_op,_right))|_intail], [property(_l,selectExpB(_obj,_op,_right))|_outtail], _inqclist, _outqclist) :-
	_obj \== '~this',
	_obj \== this,
	_obj \== scope_res(_,_),
	proplist_parameter(_what, _inattr, _intail, _outtail, _inqclist, _outqclist).
%  case 6: nested frame -> examine attrdecl list of subframe and remaining prop. list

proplist_parameter(_wh, _inattr, [property(_l,['SMLfragment'(_what,_in_omega,_in,_isa,with(_inadlist))])|_intail], [property(_l,['SMLfragment'(_what,_in_omega,_in,_isa,with(_outadlist))])| _outtail], _inqclist, _outqclist) :-
	create_subview_name(_wh,_l,_newqc),
	append(_inattr,[a(_l,_newqc)],_inattr2),
	attrdecl_parameter(_newqc,_inattr2,_inadlist,_outadlist,_inqclist,_outqclist1),
	proplist_parameter(_wh,_inattr,_intail,_outtail,_inqclist,_outqclist2),
	union_qc_list(_outqclist1,_outqclist2,_outqclist).
%  case 7: assertion string -> search for scope_res variables, then remaining prop. list

proplist_parameter(_what,_inattr, [property(_l,_v)|_intail],[property(_l,_new)|_outtail], _inqclist, _outqclist) :-
	assertion_string(_v),
	!,
    replace_scope_res_in_assertion(_what,_inattr,_v,_new,_inqclist,_outqclist1),
	proplist_parameter(_what,_inattr, _intail, _outtail, _inqclist, _outqclist2),
	union_qc_list(_outqclist1,_outqclist2,_outqclist).
%  Case 8: anything else -> examine remaining prop. list

proplist_parameter(_what,_inattr, [property(_l2,_v)|_intail], [property(_l2,_v)|_outtail], _inqclist, _outqclist) :-
	not(assertion_string(_v)),
	proplist_parameter( _what, _inattr, _intail, _outtail, _inqclist, _outqclist).
% **************************************************************************
%  replace_scope_res(_attrlist,_scoperesexp,_newpar,_class)
%    (called by proplist_parameter)
%
%    Replaces a scope-resolution expression with a new parameter or
%    with 'this'. The class of the new parameter or of 'this'
%    is also returned.
%
% **************************************************************************
%  Case 1: scope-resolution expression spans the entire parameter list,
% i.e. 'this' is meant

replace_scope_res([a('~this',_thisclass)|_t],scope_res('~this',_sc),'~this',_class) :-
	scope_res2list(_sc,_l),
	_l = _t,
	last(a(_a,_class),_t).
%  Case 2: scope-resolution expression refers to an element of a parent
% frame => replace expression with this_..._par and return its class

replace_scope_res([a('~this',_c)|_t],scope_res('~this',_sc),_out,_class) :-
	scope_res2list(_sc,_l),
	append(_l,_x,_t),
	last(a(_a,_class),_l),
	_x = [_|_],
	concat_attr_list_with_blank(_l,_out1),
	pc_atomconcat(['~this_',_out1,'_par'],_out).
%  case 3: some error
%  TODO: proper error handling

replace_scope_res(_a,_sc,_,_) :-
	write('Error in replace_scope_res'),nl,
	write('Inattr: '),write(_a),nl,
	write('Scope: '),write(_sc),nl,
	!,fail.
% **************************************************************************
%  scope_res2list(_scoperesexp,_attrlist)
%      (helper predicate for replace_scope_res/4)
%
%   Converts a scope-resolution expression into an attribute list a(..).
%
% **************************************************************************

scope_res2list(scope_res(_x,_y),[a(_x,_c)|_l]) :-
	scope_res2list(_y,_l),!.
scope_res2list(_x,[a(_x,_c)]) :-
	atom(_x).
% **************************************************************************
%  concat_attr_list_with_blank(_attrlist,_atom)
%      (helper predicate for replace_scope_res/4)
%
%     From [a(a1,_),...,a(an,_)] forms 'a1_..._an'
%
% **************************************************************************

concat_attr_list_with_blank([a(_a,_c)],_a) :- !.
concat_attr_list_with_blank([a(_a,_c)|_t],_out) :-
	concat_attr_list_with_blank(_t,_out1),
	pc_atomconcat([_a,'_',_out1],_out).
% **************************************************************************
%  add_qc_parameter(_attrlist,_inqclist,_newqc,p(_p,_c),_outqclist)
%    (used by proplist_parameter and replace_scope_res_in_assertion)
%
%   Add parameter _p to all query classes between _c and _newqc
%   (_c and _newqc are elements of _attrlist)
%
% **************************************************************************
%  Case 1: start class _c found in attr list => insert parameters into
% _inqclist via add_qc_parameter2

add_qc_parameter([a(_,_c)|_t],_inqclist,_newqc,p(_p,_c),_outqclist) :-
	add_qc_parameter2(_t,_inqclist,_newqc,p(_p,_c),_outqclist),!.
%  case 2: initial class still not found => continue searching

add_qc_parameter([_h|_t],_inqclist,_newqc,p(_p,_c),_outqclist) :-
	_h \== a(_,_c),
	add_qc_parameter(_t,_inqclist,_newqc,p(_p,_c),_outqclist).
% **************************************************************************
%  add_qc_parameter2(_attrlist,_inqclist,_newqc,p(_p,_c),_outqclist)
%
%   Add parameter _p to all query classes up to _newqc
%   (_newqc is an element of _attrlist or is a new QC that must still be
%    recorded in _inqclist)
%   So that select expressions can be evaluated correctly, the parameters
%   are entered into the variable table
%
% **************************************************************************

add_qc_parameter2([],_inqclist,_newqc,p(_p,_c),_outqclist) :-
	append(_inqclist,[q(_newqc,[p(_p,_c)])],_outqclist),
	name2id(_c,_cid),
	pc_atomconcat('~',_p,_atp),
	saveVarTabInsert([_atp],[_cid]).
add_qc_parameter2([a(_,_newqc)|_t],_inqclist,_newqc,_par,_outqclist) :-
   	add_par(_newqc,_inqclist,_par,_outqclist),!.
add_qc_parameter2([a(_,_c)|_t],_inqclist,_newqc,_par,_outqclist) :-
	_c \== _newqc,
	add_par(_c,_inqclist,_par,_outqclist1),
	add_qc_parameter2(_t,_outqclist1,_newqc,_par,_outqclist).
% **************************************************************************
%  add_par(_qc,_inqclist,p(_p,_c),_outqclist)
%
%   Adds parameter _p to QC _qc
%
% **************************************************************************

add_par(_qc,[q(_qc,_plist)|_t],p(_p,_c),[q(_qc,_plist2)|_t]) :-
	append(_plist,[p(_p,_c)],_plist2),
	name2id(_c,_cid),
	pc_atomconcat('~',_p,_atp),
	saveVarTabInsert([_atp],[_cid]).
add_par(_qc,[q(_qc2,_plist)|_t],_par,[q(_qc2,_plist)|_t2]) :-
	_qc \== _qc2,
	add_par(_qc,_t,_par,_t2).
add_par(_qc,[],p(_p,_c),[q(_qc,[p(_p,_c)])]) :-
	name2id(_c,_cid),
	pc_atomconcat('~',_p,_atp),
	saveVarTabInsert([_atp],[_cid]).
% **************************************************************************
%  union_qc_list(_qclist1, _qclist2, _qclist3)
%
%   Two lists of QCs with parameters (format as in proplist_parameter)
%   are merged
%
% **************************************************************************
%  case 1: list 1 is empty

union_qc_list([],_qc,_qc) :- !.
%  case 2: head of first list is contained in list 2 -> merge parameter lists and then the rest

union_qc_list([q(_qc,_plist)|_t],_qclist,[q(_qc,_newplist)|_newqclist]) :-
	member(q(_qc,_plist2),_qclist),
	union(_plist,_plist2,_newplist),
	union_qc_list(_t,_qclist,_newqclist).
%  case 3: head of first list not contained in list 2 -> add it and then merge the rest

union_qc_list([q(_qc,_plist)|_t],_qclist,[q(_qc,_plist)|_newqclist]) :-
	not(member(q(_qc,_plist2),_qclist)),
	union_qc_list(_t,_qclist,_newqclist).
% **************************************************************************
%  replace_scope_res_in_assertion(_what,_inattr,_assertion,_newassertion,
%                                 _inqclist,_outqclist)
%
%    Searches an assertion string for variables that use the
%    scope_res operator (e.g. this::dept) or for 'this'
%    and replaces these expressions with the corresponding parameters.
%    The list of QCs with parameters is updated in the process.
%
% **************************************************************************

replace_scope_res_in_assertion(_what,_inattr,_ass,_newass,_inqclist,_outqclist) :-
	pc_atomtolist(_ass,_asslist),
	replace_scope_res_in_assertion2(_what,_inattr,_asslist,_newasslist,_inqclist,_outqclist),
	pc_atomtolist(_newass,_newasslist).
%  Case 1: assertion string fully processed

replace_scope_res_in_assertion2(_what,_inattr,[],[],_inqclist,_inqclist) :- !.
%  Case 2a: start of a scope-resolution expression found =>
%   parse until end of expression, replace the expression and
%   update the QC list

replace_scope_res_in_assertion2(_what,_inattr,[_x,'~',t,h,i,s,':',':'|_tail],_new,_inqclist,_outqclist) :-
    not(ident_char(_x)),
	parse_scope_res(_tail,_sc,_tail2),
	replace_scope_res(_inattr,scope_res('~this',_sc),_par,_class),
	pc_atomconcat('~',_par_ohne_at,_par),
	!,
	((_par == '~this',_outqclist1 = _inqclist);
   	 add_qc_parameter(_inattr,_inqclist,_what,p(_par_ohne_at,_class),_outqclist1)
	),
	replace_scope_res_in_assertion2(_what,_inattr,_tail2,_newtail2,_outqclist1,_outqclist),
	pc_atomtolist(_par,_parlist),
	append([_x|_parlist],_newtail2,_new).
%  Case 2b: this -> ~this

replace_scope_res_in_assertion2(_what,_inattr,[_x,t,h,i,s,':',':'|_tail],_new,_inqclist,_outqclist) :-
    not(ident_char(_x)),
	_x \== '~',
	parse_scope_res(_tail,_sc,_tail2),
	replace_scope_res(_inattr,scope_res('~this',_sc),_par,_class),
	pc_atomconcat('~',_par_ohne_at,_par),
	!,
	((_par == '~this',_outqclist1 = _inqclist);
   	 add_qc_parameter(_inattr,_inqclist,_what,p(_par_ohne_at,_class),_outqclist1)
	),
	replace_scope_res_in_assertion2(_what,_inattr,_tail2,_newtail2,_outqclist1,_outqclist),
	pc_atomtolist(_par,_parlist),
	append([_x|_parlist],_newtail2,_new).
%  case 3a: '~this' found => replace with '~this_par' and update QC list

replace_scope_res_in_assertion2(_what,_inattr,[_x,'~',t,h,i,s,_y|_tail],[_x,'~',t,h,i,s,'_',p,a,r|_newtail],_inqclist,_outqclist) :-
    not(ident_char(_x)),
	not(ident_char(_y)),
	[_y|_tail] \= [':',':'|_l],
	member(a('~this',_class),_inattr),
	!,
   	add_qc_parameter(_inattr,_inqclist,_what,p('this_par',_class),_outqclist1),
	replace_scope_res_in_assertion2(_what,_inattr,[_y|_tail],_newtail,_outqclist1,_outqclist).
%  case 3b: 'this' found => replace with '~this_par' and update QC-list

replace_scope_res_in_assertion2(_what,_inattr,[_x,t,h,i,s,_y|_tail],[_x,'~',t,h,i,s,'_',p,a,r|_newtail],_inqclist,_outqclist) :-
    not(ident_char(_x)),
	not(ident_char(_y)),
	[_y|_tail] \= [':',':'|_l],
	member(a('~this',_class),_inattr),
	!,
   	add_qc_parameter(_inattr,_inqclist,_what,p('this_par',_class),_outqclist1),
	replace_scope_res_in_assertion2(_what,_inattr,[_y|_tail],_newtail,_outqclist1,_outqclist).
%  Case 4: something else

replace_scope_res_in_assertion2(_what,_inattr,[_h|_tail],[_h|_newtail],_inqclist,_outqclist) :-
	replace_scope_res_in_assertion2(_what,_inattr,_tail,_newtail,_inqclist,_outqclist).
% **************************************************************************
%  parse_scope_res(_atomlist, _term, _restatomlist)
%
%   Parse the atom list until the end of the scope_res expression,
%   parse tree is returned in _term, the remaining part of _atomlist
%   that does not belong to this expression is returned in _restatomlist.
%
% **************************************************************************

parse_scope_res(_atomlist,_y,_r) :-
	parse_scope_res2(_atomlist,'',_y,_r),!.
%  case 1: part of an identifier => extend identifier and continue parsing

parse_scope_res2([_x|_tail],_ident,_term,_rest) :-
	ident_char(_x),
	pc_atomconcat(_ident,_x,_newident),
	parse_scope_res2(_tail,_newident,_term,_rest).
%  Case 2: a new sub-term begins

parse_scope_res2([':',':'|_tail],_ident,scope_res(_ident,_term),_rest) :-
	_ident \== '',
	parse_scope_res2(_tail,'',_term,_rest).
%  case 3: character found that does not belong to an identifier => abort

parse_scope_res2([_x|_tail],_ident,_ident,[_x|_tail]) :-
	not(ident_char(_x)),
	_x \== ':',
	_ident \== '',!.
% **************************************************************************
%  rebuildSelectExpB(_selexp,_atom)
%
%  Replaces the syntax tree of a SelectExpB with the corresponding atom
%  (to turn a property with SelectExpB into a constraint)
%
% **************************************************************************

rebuildSelectExpB(_ain,_atom) :-
	atom(_ain),
	name2id(_ain,_id),
	!,
   	eval(_id,insertSelectExpression,_sel),
	outSelectIdent(_sel,_atom).
rebuildSelectExpB(select(_l,_op,_r),_atom) :-
	!,
	outSelectIdent(select(_l,_op,_r),_atom).
rebuildSelectExpB(selectExpB(_l,_op,_r),_atom) :-
	rebuildSelectExpB(_l,_al),
	((_op == 'dot', _aop ='.');
	 (_op == 'bar', _aop ='|')),
	 !,
	rebuildSelectExpB(_r,_ar),
	pc_atomconcat([_al,_aop,_ar],_atom).
rebuildSelectExpB(restriction(_l,_r),_atom) :-
	atom(_l),
	!,
	rebuildSelectExpB(_r,_ar),
	pc_atomconcat(['(',_l,':',_ar,')'],_atom).
rebuildSelectExpB(enumeration(_list),_atom) :-
	rebuildSelectExpB(_list,_alist),
	!,
	pc_atomconcat(['[',_alist,']'],_atom).
rebuildSelectExpB([_head],_atom) :-
	!,
	rebuildSelectExpB(_head,_atom).
rebuildSelectExpB([_head|_tail],_atom) :-
	rebuildSelectExpB(_head,_ahead),
	!,
	rebuildSelectExpB(_tail,_atail),
	pc_atomconcat([_ahead,',',_atail],_atom).
rebuildSelectExpB(class(_x),_x) :- !.
%  error ?

rebuildSelectExpB(_atom,_atom) :- !.
% **************************************************************************
%  enumerationToConstraint(_list,_label,_constr)
%     (called by store_enumeration)
%
%    Converts a list of labels or select expressions into a
%    constraint string,
%        e.g. [a,b,c] => (~this == a) or (~this == b) or ...
%
% **************************************************************************

enumerationToConstraint(_list,_constr) :-
	enumerationToConstraint2(_list,_constr2),
	!,
	pc_atomconcat(['$ ',_constr2,' $'],_constr).

enumerationToConstraint2([class(_obj)], _constr) :-
	outSelectIdent(_obj,_obj2),
	pc_atomconcat([' (~this == ',_obj2,')'],_constr).
enumerationToConstraint2([class(_obj)|_tail], _constr) :-
	outSelectIdent(_obj,_obj2),
	enumerationToConstraint2(_tail, _constr2),
	pc_atomconcat([' (~this == ',_obj2,') or ',_constr2],_constr).

create_subview_name(_main,_label,_subview) :-
	pc_atomconcat(['SV_',_main,'_',_label],_subview).
