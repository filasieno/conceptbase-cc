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
% File:        PropositionProcessor.pro
% Version:     11.5
%
%
% Date released : 97/05/28  (YY/MM/DD)
%
% SCCS-Source-Pool : /home/CBase/CB_NewStruct/ProductPOOL/serverSources/Prolog_Files/SCCS/s.PropositionProcessor.pro
% Date retrieved : 97/07/09 (YY/MM/DD)
% **************************************************************************
%
% This Prolog module is part of the ConceptBase system which is a run-time
% system for the System Modelling Language (SML).
% The PropositionProcessor provides an interface to the propval relation
% which is used to define the semantics of single propositions in our
% SML implementation. The interface consists of the few exported predicates
% listed below.
%
%
%  9-Dec-96/LWEB: the entire PropositionBase.pro module was dissolved and its
% functionality was moved into PropositionProcessor.pro.
%  PropositionProcessor is now the sole proposition interface to the object store (via BIM2C).
%
% 5-Mar-97/LWEB: retrieve_temp/1 extended for correct integrity checking of
% UNTELL/TELL on import/export attributes.
%
%  Jun-97: retrieve_temp/1 was replaced by retrieve_temp_ins and retrieve_temp_del.
%  Temporary storage is split for new information and old information (temp_ins and temp_del),
%  allowing separate access.
%
%
% :- setdebug.

:- module('PropositionProcessor',[
'get_module'/2
,'get_module_name'/2
,'retrieve_proposition'/1
,'retrieve_proposition'/2
,'retrieve_proposition_noimport'/2
,'retrieve_temp_del'/1
,'retrieve_temp_del'/2
,'retrieve_temp_ins'/1
,'retrieve_temp_ins'/2
,'retrieve_temp_module_tell'/2
,'retrieve_temp_module_untell'/2
,'retrieve_temp_ins_set'/2
,'retrieve_temp_del_set'/2
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').
:- use_module('SearchSpace.swi.pl').
:- use_module('GeneralUtilities.swi.pl').
:- use_module('BIM2C.swi.pl').
:- use_module('validProposition.swi.pl').
:- use_module('ObjectProcessor.swi.pl').
:- use_module('PrologCompatibility.swi.pl').
:- style_check(-singleton).
%  ===================
%  Exported predicates
%  ===================
%  ********** r e t r i e v e _ p r o p o s i t i o n  **********
%
%  retrieve_proposition(_propdescr)
%    _propdescr: any: ground
%
%   returns a proposition according to the set KBsearchSpace,
%  the corresponding M_SearchSpace taking import/export attributes into account
%  **************************************************************

retrieve_proposition('P'(_id,_x,_l,_y)) :-
   retrieve_C_proposition('P'(_id,_x,_l,_y)).
%  ********* r e t r i e v e _ p r o p o s i t i o n/2  *********
%
%  retrieve_proposition(_m,_propdescr)
%    _m: ground
%    _propdescr: any: ground
%
%  Searches for _propdescr in Module _m including import/export
%  relations.
%
%  **************************************************************

retrieve_proposition(_m, 'P'(_id,_x,_l,_y)) :-
	ground(_m),
	set_overrule_module(_m),
	retrieve_C_proposition('P'(_id,_x,_l,_y)).
%  **************************************************************
% 	 retrieve_proposition_noimport / 1
%  	_m : any : term
%
% 	Searches for a predicate defined in module _m.
% 	(import/export relationships are not considered)
%
% 	_m may be a variable.
%
%  **************************************************************

retrieve_proposition_noimport(_m,'P'(_id,_x,_l,_y))	:-
	retrieve_C_proposition_module('P'( _id, _x, _l, _y, _m)).
%  **************************************************************
% 	 retrieve_temp_module_tell(untell) / 2
					%  retrieve ONLY temporary props within a module
%  **************************************************************

retrieve_temp_module_tell(_m,'P'(_id,_x,_l,_y))	:-
	set_overrule_temp_tell_bim2c,
	retrieve_C_proposition_module('P'( _id, _x, _l, _y, _m)).

retrieve_temp_module_untell(_m,'P'(_id,_x,_l,_y))	:-
	set_overrule_temp_untell_bim2c,
	retrieve_C_proposition_module('P'( _id, _x, _l, _y, _m)).
%  **************************************************************
% 	 retrieve_temp_ins(del) / 1
				  			%  retrieve ONLY temporary props
%  **************************************************************

retrieve_temp_ins(_m,'P'(_id,_x,_l,_y))	:-
	ground(_m),
	set_overrule_module(_m),
	set_overrule_temp_tell_bim2c,
	retrieve_C_proposition('P'(_id,_x,_l,_y)).
retrieve_temp_ins('P'(_id,_x,_l,_y))	:-
	set_overrule_temp_tell_bim2c,
	retrieve_C_proposition('P'(_id,_x,_l,_y)).
%  the following version of retrieve_temp/1 provides objects that from the export interface of
%  modules imported by the current module, as temporary objects for the current
%  objects available
%  see module server technical documentation

retrieve_temp_ins('P'(_id,_x,_l,_y))	:-
	(i_import(_iid) ; d_import(_iid)),
	callExactlyOnce((
		set_overrule_temp_tell_bim2c,
		retrieve_C_proposition('P'(_iid,_m,_,_im)),
		'M_SearchSpace'(_m),
		'System'(_sid),
		'Module'(_mid),
		retrieve_proposition_noimport(_sid,'P'(_eip,_mid,exports,_))
	)),
	retrieve_proposition_noimport(_im,'P'(_,_ei2,'*instanceof',_eip)),
	retrieve_proposition_noimport(_im,'P'(_ei2,_im,_,_id)),
	retrieve_proposition_noimport(_,'P'(_id,_x,_l,_y)).
%  the following version of retrieve_temp/1 makes objects temporarily exported
%  from the current transaction module (whether because they were just inserted or
%  deleted by the current transaction) available in modules that import the current
%  module (as temporary objects).
%  see module server technical documentation
%  _m contains the current module of the transaction
%  _am is the module currently being checked (in the semantic integrity check)

retrieve_temp_ins('P'(_id,_x,_l,_y))	:-
	(i_export(_eid) ; d_export(_eid)),
	callExactlyOnce((
		set_overrule_temp_tell_bim2c,
		retrieve_C_proposition_module('P'(_eid,_m,_,_id,_m)),
		'M_SearchSpace'(_am),
		'System'(_sid),
		'Module'(_mid),
		retrieve_proposition_noimport(_sid,'P'(_eip,_mid,imports,_)),
		retrieve_proposition_noimport(_am,'P'(_,_ei2,'*instanceof',_eip)),
		retrieve_proposition_noimport(_am,'P'(_ei2,_am,_,_m)),
		retrieve_proposition_noimport(_,'P'(_id,_x,_l,_y))
	)).

retrieve_temp_del(_m,'P'(_id,_x,_l,_y))	:-
	ground(_m),
	set_overrule_module(_m),
	set_overrule_temp_untell_bim2c,
	retrieve_C_proposition('P'(_id,_x,_l,_y)).
retrieve_temp_del('P'(_id,_x,_l,_y))	:-
        set_overrule_temp_untell_bim2c,
        retrieve_C_proposition('P'(_id,_x,_l,_y)).
retrieve_temp_del('P'(_id,_x,_l,_y))	:-
	(i_import(_iid) ; d_import(_iid)),
	callExactlyOnce((
		set_overrule_temp_untell_bim2c,
		retrieve_C_proposition('P'(_iid,_m,_,_im)),
		'M_SearchSpace'(_m),
		'Module'(_mid),
		'System'(_sid),
		retrieve_proposition_noimport(_sid,'P'(_eip,_mid,exports,_))
	)),
	retrieve_proposition_noimport(_im,'P'(_,_ei2,'*instanceof',_eip)),
	retrieve_proposition_noimport(_im,'P'(_ei2,_im,_,_id)),
	retrieve_proposition_noimport(_,'P'(_id,_x,_l,_y)).
retrieve_temp_del('P'(_id,_x,_l,_y))	:-
	(i_export(_eid) ; d_export(_eid)),
	callExactlyOnce((
		set_overrule_temp_untell_bim2c,
		retrieve_C_proposition_module('P'(_eid,_m,_,_id,_m)),
		'M_SearchSpace'(_am),
		'System'(_sid),
		'Module'(_mid),
		retrieve_proposition_noimport(_sid,'P'(_eip,_mid,imports,_)),
		retrieve_proposition_noimport(_am,'P'(_,_ei2,'*instanceof',_eip)),
		retrieve_proposition_noimport(_am,'P'(_ei2,_am,_,_m)),
		retrieve_proposition_noimport(_,'P'(_id,_x,_l,_y))
	)).
%  these variants  of retrieve_temp_ins,retrieve_temp_del return directly the
%  set of propositions matching (P(_id,_x,_l,_y).

retrieve_temp_ins_set('P'(_id,_x,_l,_y),_propset) :-
	set_overrule_temp_tell_bim2c,
	retrieve_C_proposition_set('P'(_id,_x,_l,_y),_propset).

retrieve_temp_del_set('P'(_id,_x,_l,_y),_propset)	:-
        set_overrule_temp_untell_bim2c,
        retrieve_C_proposition_set('P'(_id,_x,_l,_y),_propset).
%  **************************************************************
% 	 get_module_name / 2
%  **************************************************************

get_module_name(_id,_inmod) :-
	retrieve_C_proposition_module('P'( _id, _, _, _, _idinmod)),
	!,
	id2name(_idinmod,_inmod).

get_module(_id,_inmod) :-
	retrieve_C_proposition_module('P'( _id, _, _, _, _inmod)),
	!.
