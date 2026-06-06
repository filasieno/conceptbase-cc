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
% File:        SemanticIntegrity.pro
% Version:     11.4
%
%
% Date released : 97/03/20  (YY/MM/DD)
%
% SCCS-Source-Pool : /home/CBase/CB_NewStruct/ProductPOOL/serverSources/Prolog_Files/SCCS/s.SemanticIntegrity.pro
% Date retrieved : 97/04/29 (YY/MM/DD)
% *************************************************************************
%
% This Prolog module is part of the ConceptBase system which is a run-timer the System Modelling Language (SML).
% SemanticIntegrity provides procedures to check the semantic integrity
% of sets of propositions. It is based on the predicates of SMLaxioms.pro.
%
% 19-Dec-1989/TW: Now this module checks semantic integrity
%                 also for UNTELL
%
% 27.07.1990 RG: Modified check_them to only retrieve the old
% 	         propval/5 form.
%
% 12-Jul-1995 LWEB : 	in check_untell_axioms/0 and check_untell_ICs, retrieve_temp_proposition(_p)
% 			was replaced by retrieve_temp_proposition(P(_id,_s,_l,_d)) to avoid unnecessary
% 			backtracking.
% 07-10-1996 LWEB:	Adapted to object store.
%
% 09-Dez-1996/LWEB:	checkIntegrity/2 was extended so that for each module affected by the current
% 			transaction, semantic integrity is checked.
% 			In particular, told/untold import and export relationships must be taken into account.
% 			The general approach is documented in internal report i5-9505.
%
% Jun-97 checkIntegrity is used for Retell extended.
%

:- module('SemanticIntegrity',[
'checkIntegrity'/2
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').
:- use_module('PropositionProcessor.swi.pl').
:- use_module('GeneralUtilities.swi.pl').
:- use_module('SMLaxioms.swi.pl').
:- use_module('ModelConfiguration.swi.pl').
:- use_module('validProposition.swi.pl').
:- use_module('BDMIntegrityChecker.swi.pl').
:- use_module('PrologCompatibility.swi.pl').
:- style_check(-singleton).
%  ************** c h e c k I n t e g r i t y ****************
%
%  checkIntegrity(_operation,_errno)
%    _operation: ground : atom
%    _errno: any: integer
%
%  Semantic integrity is checked for the operations 'tell' or
%  'untell'. _errno contains after execution the number of
%  errors.
%
%  ***********************************************************

checkIntegrity(tell,_errno) :-
 	checkSemanticIntegrity(_errno),!.
checkIntegrity(untell,_errno) :-
 	check_for_untell(_errno),!.
checkIntegrity(retell,_errno) :-
 	check_for_retell(_errno),!.
%  ******* c h e c k S e m a n t i c I n t e g r i t y *******
%
%  checkSemanticIntegrity(_errno)
%    _errno: any: integer
%
%  All propositions in the 'temp' representation, i.e. retriev-
%  able by 'retrieve_temp_proposition', are checked for sem-
%  antic integrity. After execution, _errno contains the num-
%  ber of errors encountered.
%
%  ***********************************************************
%  Here the IC consistency check is implemented for import/export and normal cases
%  An explanation is in internal report I5-9505
 %  LWEB
%  checkSemanticIntegrity case for transactions in which export attributes are newly told

checkSemanticIntegrity(_errno) :-
  	temp_ins_export_attributes,!,  % Did new export attributes appear?
 	getModule(_m),
  	save_setof( _imod, importing_module(_imod), _imodlist),  % Check all importing modules and all (recursively) nested modules
										%  within importing modules

	id2name_list(_imodlist,_inames),
	'WriteTrace'(veryhigh,'SemanticIntegrity',[' Importing Modules that are concerned by this transaction: ',_inames]),
	append([_m],_imodlist,_mimodlist),  % _m itself must of course also be checked
  	get_nested_modules(_mimodlist,_modules_to_be_checked),  % All nested modules that exist within the modules to be checked
										%  must also be checked

	id2name_list(_modules_to_be_checked,_mtbc),
	'WriteTrace'(veryhigh,'SemanticIntegrity',[' Modules to be checked for Integrity violations are: ',_mtbc]),
  	reset_counter_if_undefined('error_number@SI'),
 	 check_axioms(_modules_to_be_checked,_m),
  	 ((  'error_number@SI'(0),!,check_ICs(_modules_to_be_checked,_m));true),
 	 'error_number@SI'(_errno),
!.
%  checkSemanticIntegrity case for new "ordinary" objects and newly told import attributes

checkSemanticIntegrity(_errno) :-  % otherwise
  	not(temp_ins_export_attributes),!,
  	getModule(_m),
  	get_nested_modules([_m],_modules_to_be_checked),
	id2name_list(_modules_to_be_checked,_mtbc),
	'WriteTrace'(veryhigh,'SemanticIntegrity',[' Modules to be checked for Integrity violations are: ',_mtbc]),
  	reset_counter_if_undefined('error_number@SI'),
  	check_axioms(_modules_to_be_checked,_m),
   	((  'error_number@SI'(0),!,check_ICs(_modules_to_be_checked,_m));true),
  	'error_number@SI'(_errno),
!.
%  importing_module(_imid) returns the id of a module that imports the current module
%  (backtrackable!)

importing_module(_imid) :-
  	getModule(_msp),
	'System'(_sid),
        'Module'(_mid),
	retrieve_proposition_noimport(_sid,'P'(_iid,_mid,imports,_mid)),
	retrieve_proposition_noimport(_,'P'(_,_x,'*instanceof',_iid)),
	retrieve_proposition_noimport(_imid,'P'(_x,_imid,_,_msp)).
%  get_nested_module(_modlist,_result)
%  return all nested modules for each individual module from the list _modlist.
%  _modlist is a sublist of _result

get_nested_modules([],[]).
get_nested_modules([_h|_t],[_h|_tn])	:-
	save_setof( _mod, nested_module(_h,_mod), _tl),
	get_nested_modules(_t,_tl2),
	append(_tl,_tl2,_tn).

nested_module(_father,_child)	:-  % _child is nested recursively within _father
  	nested(_father,_child).
nested_module(_father,_child)	:-
  	nested(_father,_c),  % expensive !!!
 	nested_module(_c,_child).

nested(_father,_child)		:-
        'Module'(_mid),
	retrieve_proposition_noimport(_father,'P'(_,_child,'*instanceof',_mid)),
	_child \= _father.  % So that System does not cause an infinite loop.

temp_ins_export_attributes 		:-  % Check whether temporary export attributes exist
  	getModule(_m),
 	'Module'(_mid),
  	'System'(_sid),
  	retrieve_proposition(_sid, 'P'( _id10,  _mid, exports, _)),
  	retrieve_temp_ins(_m,'P'(_, _id12, '*instanceof', _id10)).

temp_del_export_attributes 		:-  % For untell, check whether temporary export attributes exist
  	getModule(_m),
 	'Module'(_mid),
  	'System'(_sid),
  	retrieve_proposition(_sid, 'P'(_id10,  _mid, exports, _)),
  	retrieve_temp_del(_m,'P'(_, _id12, '*instanceof', _id10)).
%  ************** c h e c k _ f o r _ u n t e l l  ***********
%
%  check_for_untell(_errno)
%    _errno: any: integer
%
%  All propositions in the 'temp' representation, i.e. retriev-
%  able by 'retrieve_temp_proposition', are checked for sem-
%  antic integrity for the 'untell'-operation. After exe-
%  cution, _errno contains the number of errors encountered.
%
%  ***********************************************************
%  If export attributes are untold, the corresponding CB_export facts are deleted, then
%  IC check and axiom check are run for all importing modules; afterward the CB_export facts are
%  regenerated for consistency reasons (to be deleted again in ObjectProcessor later)  4-8-1995 LWEB

check_for_untell(_errno) :-
  	temp_del_export_attributes,!,  % temporary change
  	getModule(_m),
  	save_setof( _imod, importing_module(_imod), _imodlist),  % Check all importing modules and all nested modules
										%  within importing modules

	id2name_list(_imodlist,_inames),
	'WriteTrace'(veryhigh,'SemanticIntegrity',[' Importing Modules that are affected by this transaction: ',_inames]),
	append([_m],_imodlist,_mimodlist),
   	get_nested_modules(_mimodlist,_modules_to_be_checked),
	id2name_list(_modules_to_be_checked,_mtbc),
	'WriteTrace'(veryhigh,'SemanticIntegrity',[' Modules to be checked for Integrity violations are: ',_mtbc]),
 		 reset_counter_if_undefined('error_number@UI'),
		 check_untell_axioms(_modules_to_be_checked,_m),
  		 ((  'error_number@UI'(0),!,check_untell_ICs(_modules_to_be_checked,_m));true),
		 'error_number@UI'(_errno),
!.
check_for_untell(_errno) :-
  	not(temp_del_export_attributes),!,
  	getModule(_m),
  	get_nested_modules([_m],_modules_to_be_checked),
	id2name_list(_modules_to_be_checked,_mtbc),
	'WriteTrace'(veryhigh,'SemanticIntegrity',[' Modules to be checked for Integrity violations are: ',_mtbc]),
    reset_counter_if_undefined('error_number@UI'),
  	check_untell_axioms(_modules_to_be_checked,_m),
   	((
		'error_number@UI'(0),
		!,
		check_untell_ICs(_modules_to_be_checked,_m)
	 );
	 true
	),
 	'error_number@UI'(_errno),
	!.
% *******************************************retell*******************************************

check_for_retell(_errno) :-
	temp_ins_export_attributes,!,
  	temp_del_export_attributes,!,
	getModule(_m),
  	save_setof( _imod, importing_module(_imod), _imodlist),  % Check all importing modules and all nested modules
										%  within importing modules

	id2name_list(_imodlist,_inames),
	'WriteTrace'(veryhigh,'SemanticIntegrity',[' Importing Modules that are affected by this transaction: ',_inames]),
	append([_m],_imodlist,_mimodlist),
   	get_nested_modules(_mimodlist,_modules_to_be_checked),
	id2name_list(_modules_to_be_checked,_mtbc),
	'WriteTrace'(veryhigh,'SemanticIntegrity',[' Modules to be checked for Integrity violations are: ',_mtbc]),
 	reset_counter_if_undefined('error_number@UI'),
	reset_counter_if_undefined('error_number@SI'),
	check_retell_axioms(_modules_to_be_checked,_m),
 	'error_number@UI'(_errno_untell),
	'error_number@SI'(_errno_tell),
   	((
		_errno_untell == 0,
		_errno_tell == 0,
		!,
		check_retell_ICs(_modules_to_be_checked,_m)
   	 );
	 true
	),
        %  error count might be incremented by check_retell_ICs; ticket #318

 	'error_number@UI'(_e1),
	'error_number@SI'(_e2),
	_errno is _e1 + _e2,
	!.
check_for_retell(_errno) :-
  	not(temp_ins_export_attributes),!,
	not(temp_del_export_attributes),!,
 	getModule(_m),
  	get_nested_modules([_m],_modules_to_be_checked),
	id2name_list(_modules_to_be_checked,_mtbc),
	'WriteTrace'(veryhigh,'SemanticIntegrity',[' Modules to be checked for Integrity violations are: ',_mtbc]),
        reset_counter_if_undefined('error_number@UI'),
   	reset_counter_if_undefined('error_number@SI'),
   	check_retell_axioms(_modules_to_be_checked,_m),
 	'error_number@UI'(_errno_untell),
	'error_number@SI'(_errno_tell),
   	((
		_errno_untell == 0,
		_errno_tell == 0,
		!,
		check_retell_ICs(_modules_to_be_checked,_m)
   	 );
	 true
	),
 	'error_number@UI'(_e1),  % ticket #318
	'error_number@SI'(_e2),
	_errno is _e1 + _e2,
	!.
%  ==================
%  Private predicates
%  ==================

check_axioms([],_omod) :- setModule(_omod).  % 1-Aug-1995 LWEB
check_axioms([_h|_t],_omod):-
	setModule(_h),  % Perform axiom checking one module at a time
	check_axioms,
	check_axioms(_t,_omod).
check_axioms :-  % 27.07.1990 RG
	retrieve_temp_ins('P'(_id,_s,_l,_d)),  % 31-Jul-1995 LWEB
  	check_proposition('P'(_id,_s,_l,_d)),
  fail.
check_axioms.  % final success for module
check_ICs([],_omod) :- setModule(_omod).  % 1-Aug-1995 LWEB
check_ICs([_h|_t],_omod):-
	setModule(_h),
		check_ICs,
	check_ICs(_t,_omod).
check_ICs:-  % 3-Nov-1992 MSt
  	retrieve_temp_ins('P'(_id,_s,_l,_d)),  % 31-Jul-1995 LWEB
  	check_proposition_forICs('P'(_id,_s,_l,_d)),
  fail.
check_ICs.  % final success
%  ************ c h e c k _ u n t e l l _ a x i o m s / I C s ****************
%
%  check_untell_axioms/ICs
%
%
%  Checks for each 'temp'-propval the integrity for untelling
%
%  ***********************************************************

check_untell_axioms([],_omod) :- setModule(_omod).  % 1-Aug-1995 LWEB
check_untell_axioms([_h|_t],_omod):-
	setModule(_h),
	check_untell_axioms,
	check_untell_axioms(_t,_omod).
check_untell_axioms:-
  retrieve_temp_del('P'(_id,_s,_l,_d)),  % 12-Jul-1995 LWEB
  check_untell_proposition('P'(_id,_s,_l,_d)),
  fail.
check_untell_axioms.  % final success
check_untell_ICs([],_omod) :- setModule(_omod).  % 1-Aug-1995 LWEB
check_untell_ICs([_h|_t],_omod):-
	setModule(_h),
	check_untell_ICs,
	check_untell_ICs(_t,_omod).
check_untell_ICs:-  % 3-Nov-1992 MSt
  retrieve_temp_del('P'(_id,_s,_l,_d)),  % 12-Jul-1995 LWEB
  check_untell_proposition_forICs('P'(_id,_s,_l,_d)),
  fail.
check_untell_ICs.  % final success
% ***************************** check retell axioms/ICs *************************************
%  Here check_retell_axioms and check_retell_ICs are built; untell and tell checks are
%  executed sequentially

check_retell_axioms([],_omod) :- setModule(_omod).
check_retell_axioms([_h|_t],_omod):-
	setModule(_h),
	check_retell_axioms,
	check_retell_axioms(_t,_omod).
check_retell_axioms:-  % check untell and tell sequentially
  retrieve_temp_del('P'(_id0,_s0,_l0,_d0)),
  check_untell_proposition('P'(_id0,_s0,_l0,_d0)),
  retrieve_temp_ins('P'(_id,_s,_l,_d)),
  check_proposition('P'(_id,_s,_l,_d)),
  fail.
check_retell_axioms.  % final success
check_retell_ICs([],_omod) :- setModule(_omod).
check_retell_ICs([_h|_t],_omod):-
	setModule(_h),
	check_retell_ICs,
	check_retell_ICs(_t,_omod).
check_retell_ICs:-
  retrieve_temp_del('P'(_id0,_s0,_l0,_d0)),  % check untell and tell sequentially
  check_untell_proposition_forICs('P'(_id0,_s0,_l0,_d0)),
  retrieve_temp_ins('P'(_id,_s,_l,_d)),
  check_proposition_forICs('P'(_id,_s,_l,_d)),
  fail.
check_retell_ICs.  % final success
%  ************ c h e c k _ p r o p o s i t i o n ( f o r I C s)************
%
%  check_proposition(forICs)(_propdescr)
%    _propdescr: partial
%
%  Checks _propdescr for semantic integrity. If inconsistent,
%  the error number ('error_number@SI') is incremented.
%
%  ***********************************************************

check_proposition(_propdescr) :-
  'SMLvalid'(_propdescr),
  !.
%  if error detected:

check_proposition(_p) :-
  increment('error_number@SI'),
  !.

check_proposition_forICs(_propdescr) :-  % 3-Nov-1992 MSt
  tellCheck_BDMIntegrity(_propdescr),
  !.
%  if error detected:

check_proposition_forICs(_p) :-
   increment('error_number@SI'),
  !.
%  ****** c h e c k _ u n t e l l _ p r o p o s i t i o n ( f o r I C s) ***********
%
%  check_untell_proposition(forICs)(_propdescr)
%    _propdescr: partial
%
%  Checks _propdescr for semantic integrity for untelling. If
%  inconsistent, the error number ('error_number@SU') is
%  incremented.
%
%  ***********************************************************

check_untell_proposition(_propdescr) :-
  'SMLvalid_untell'(_propdescr),
  !.
%  if error detected:

check_untell_proposition(_p) :-
  increment('error_number@UI'),
  !.

check_untell_proposition_forICs(_propdescr) :-  % 3-Nov-1992 MSt
  untellCheck_BDMIntegrity(_propdescr),
  !.
%  if error detected:

check_untell_proposition_forICs(_p) :-
  increment('error_number@UI'),
  !.
