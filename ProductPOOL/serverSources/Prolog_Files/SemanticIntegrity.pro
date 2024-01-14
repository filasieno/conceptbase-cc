{*
The ConceptBase.cc Copyright

Copyright 1987-2024 The ConceptBase Team. All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted
provided that the following conditions are met:

   1. Redistributions of source code must retain the above copyright notice, this list of
      conditions and the following disclaimer.
   2. Redistributions in binary form must reproduce the above copyright notice, this list of
      conditions and the following disclaimer in the documentation and/or other materials
      provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE CONCEPTBASE TEAM ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE CONCEPTBASE TEAM OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

The views and conclusions contained in the software and documentation are those of the authors
and should not be interpreted as representing official policies, either expressed or implied,
of the ConceptBase Team.


The ConceptBase Team is represented by

Manfred Jeusfeld, University of Skovde, 54128 Skovde, Sweden


This license is a FreeBSD-style copyright license.
Legal home of the FreeBSD copyright license: http://www.freebsd.org/copyright/freebsd-license.html
*}
{
*
* File:        SemanticIntegrity.pro
* Version:     11.4
*
*
* Date released : 97/03/20  (YY/MM/DD)
*
* SCCS-Source-Pool : /home/CBase/CB_NewStruct/ProductPOOL/serverSources/Prolog_Files/SCCS/s.SemanticIntegrity.pro
* Date retrieved : 97/04/29 (YY/MM/DD)
**************************************************************************
*
* This Prolog module is part of the ConceptBase system which is a run-timer the System Modelling Language (SML).
* SemanticIntegrity provides procedures to check the semantic integrity
* of sets of propositions. It is based on the predicates of SMLaxioms.pro.
*
* 19-Dec-1989/TW: Now this module checks semantic integrity
*                 also for UNTELL
*
* 27.07.1990 RG: Modified check_them to only retrieve the old
*	         propval/5 form.
*
* 12-Jul-1995 LWEB : 	in check_untell_axioms/0 und check_untell_ICs wurde retrieve_temp_proposition(_p)
*			durch retrieve_temp_proposition(P(_id,_s,_l,_d)) ersetzt, um unnoetiges backtracking
*			zu vermeiden.
* 07-10-1996 LWEB:	auf Objektspeicherstand gebracht.
*
* 09-Dez-1996/LWEB:	checkIntegrity/2 wurde so erweitert, dass fuer jedes Modul welches von der aktuellen
			Transaktion betroffen ist, auf semantische Integritaet ueberprueft wird.
			Hierbei sind insbesondere getellte/geuntellte Import- bzw. Export Beziehungen zu beachten.
			Das allgemeine Vorgehen ist im Internen Bericht i5-9505 dokumentiert.

* Jun-97 checkIntegrity wird fuer Retell erweitert.
}


#MODULE(SemanticIntegrity)
#EXPORT(checkIntegrity/2)
#ENDMODDECL()


#IMPORT(retrieve_proposition/1,PropositionProcessor)
#IMPORT(retrieve_proposition/2,PropositionProcessor)
#IMPORT(retrieve_proposition_noimport/2,PropositionProcessor)
#IMPORT(retrieve_temp_ins/1,PropositionProcessor)
#IMPORT(retrieve_temp_ins/2,PropositionProcessor)
#IMPORT(retrieve_temp_del/1,PropositionProcessor)
#IMPORT(retrieve_temp_del/2,PropositionProcessor)
#IMPORT(WriteTrace/3,GeneralUtilities)
#IMPORT(SMLvalid/1,SMLaxioms)
#IMPORT(SMLvalid_untell/1,SMLaxioms)
#IMPORT(name2id/2,GeneralUtilities)
#IMPORT(id2name_list/2,GeneralUtilities)
#IMPORT(id2name/2,GeneralUtilities)
#IMPORT(save_setof/3,GeneralUtilities)
#IMPORT(increment/1,GeneralUtilities)
#IMPORT(append/3,GeneralUtilities)
#IMPORT(setModule/1,ModelConfiguration)
#IMPORT(getModule/1,ModelConfiguration)
#IMPORT(systemOmegaClass/1,validProposition)
#IMPORT(tellCheck_BDMIntegrity/1,BDMIntegrityChecker)
#IMPORT(untellCheck_BDMIntegrity/1,BDMIntegrityChecker)
#IMPORT(pc_update/1,PrologCompatibility)
#IMPORT(reset_counter_if_undefined/1,GeneralUtilities)

#IF(SWI)
:- style_check(-singleton).
#ENDIF(SWI)




{ ************** c h e c k I n t e g r i t y **************** }
{                                                             }
{ checkIntegrity(_operation,_errno)                           }
{   _operation: ground : atom                                 }
{   _errno: any: integer                                      }
{                                                             }
{ Semantic integrity is checked for the operations 'tell' or  }
{ 'untell'. _errno contains after execution the number of     }
{ errors.                                                     }
{                                                             }
{ *********************************************************** }

checkIntegrity(tell,_errno) :-
 	checkSemanticIntegrity(_errno),!.

checkIntegrity(untell,_errno) :-
 	check_for_untell(_errno),!.


checkIntegrity(retell,_errno) :-
 	check_for_retell(_errno),!.


{ ******* c h e c k S e m a n t i c I n t e g r i t y ******* }
{                                                             }
{ checkSemanticIntegrity(_errno)                              }
{   _errno: any: integer                                      }
{                                                             }
{ All propositions in the 'temp' representation, i.e. retriev-}
{ able by 'retrieve_temp_proposition', are checked for sem-   }
{ antic integrity. After execution, _errno contains the num-  }
{ ber of errors encountered.                                  }
{                                                             }
{ *********************************************************** }

{ Hier ist die Ueberpruefung der IC-Konsistentz bei import/export und normalen Faellen implementiert }
{ Eine Erlaeuterung hierzu befindet sich im Internen Bericht I5-9505 } { LWEB }

{ checkSemanticIntegrity-Fall fuer Transaktionen in denen  export attribute  neu getellt werden }
checkSemanticIntegrity(_errno) :-
  	temp_ins_export_attributes,!,			{ kamen neue exp attribute vor ? }
 	getModule(_m),
  	save_setof( _imod, importing_module(_imod), _imodlist),		{ kontrolliere alle importierenden Module und alle (rekursiv!) geschachtelten Module}
										{ in importierenden Modulen }
	id2name_list(_imodlist,_inames),
	WriteTrace(veryhigh,SemanticIntegrity,[' Importing Modules that are concerned by this transaction: ',_inames]),

	append([_m],_imodlist,_mimodlist),					{ _m selbst muss natuerlich auch ueberprueft werden }

  	get_nested_modules(_mimodlist,_modules_to_be_checked), 	{ alle geschachtelteten Module, die in den zu ueberpruefenden existieren, }
										{ muessen ebenfalls ueberprueft werden }

	id2name_list(_modules_to_be_checked,_mtbc),
	WriteTrace(veryhigh,SemanticIntegrity,[' Modules to be checked for Integrity violations are: ',_mtbc]),
  	reset_counter_if_undefined('error_number@SI'),
 	 check_axioms(_modules_to_be_checked,_m),
  	 ((  'error_number@SI'(0),!,check_ICs(_modules_to_be_checked,_m));true),
 	 'error_number@SI'(_errno),
!.


{ checkSemanticIntegrity-Fall fuer neue "gewoehnliche" Objekte und neu getellte import attribute }
checkSemanticIntegrity(_errno) :-			{ sonst }
  	not(temp_ins_export_attributes),!,
  	getModule(_m),
  	get_nested_modules([_m],_modules_to_be_checked),
	id2name_list(_modules_to_be_checked,_mtbc),
	WriteTrace(veryhigh,SemanticIntegrity,[' Modules to be checked for Integrity violations are: ',_mtbc]),
  	reset_counter_if_undefined('error_number@SI'),
  	check_axioms(_modules_to_be_checked,_m),
   	((  'error_number@SI'(0),!,check_ICs(_modules_to_be_checked,_m));true),
  	'error_number@SI'(_errno),
!.


{ importing_module(_imid) liefert die id eines Moduls zurueck, welches das aktuelle Modul }
{ importiert. (backtrackingfaehig!) 		}
importing_module(_imid) :-
  	getModule(_msp),
	System(_sid),
        Module(_mid),
	retrieve_proposition_noimport(_sid,P(_iid,_mid,imports,_mid)),
	retrieve_proposition_noimport(_,P(_,_x,'*instanceof',_iid)),
	retrieve_proposition_noimport(_imid,P(_x,_imid,_,_msp)).

{ get_nested_module(_modlist,_result) }
{ gebe alle geschachtelten Module fuer jedes einzelne Modul aus der Liste _modlist zurueck.
 _modlist ist eine Teilliste von _result }
get_nested_modules([],[]).
get_nested_modules([_h|_t],[_h|_tn])	:-
	save_setof( _mod, nested_module(_h,_mod), _tl),
	get_nested_modules(_t,_tl2),
	append(_tl,_tl2,_tn).


nested_module(_father,_child)	:-		{ _child ist in _father REKURSIV geschachtelt }
  	nested(_father,_child).
nested_module(_father,_child)	:-
  	nested(_father,_c),				{ teuer !!! }
 	nested_module(_c,_child).

nested(_father,_child)		:-
        Module(_mid),
	retrieve_proposition_noimport(_father,P(_,_child,'*instanceof',_mid)),
	_child \= _father.		{ damit System keinen unendlichen loop erzeugt. }


temp_ins_export_attributes 		:-		{ ueberpruefe ob temporaere export attribute existieren }
  	getModule(_m),
 	Module(_mid),
  	System(_sid),
  	retrieve_proposition(_sid, P( _id10,  _mid, exports, _)),
  	retrieve_temp_ins(_m,P(_, _id12, '*instanceof', _id10)).


temp_del_export_attributes 		:-		{ ueberpruefe fuer untell ob temporaere export attribute existieren }
  	getModule(_m),
 	Module(_mid),
  	System(_sid),
  	retrieve_proposition(_sid, P(_id10,  _mid, exports, _)),
  	retrieve_temp_del(_m,P(_, _id12, '*instanceof', _id10)).

{ ************** c h e c k _ f o r _ u n t e l l  *********** }
{                                                             }
{ check_for_untell(_errno)                                    }
{   _errno: any: integer                                      }
{                                                             }
{ All propositions in the 'temp' representation, i.e. retriev-}
{ able by 'retrieve_temp_proposition', are checked for sem-   }
{ antic integrity for the 'untell'-operation. After exe-      }
{ cution, _errno contains the number of errors encountered.   }
{                                                             }
{ *********************************************************** }

{ Falls export attribute geUNTELLt werden, werden die entsprechenden CB_export Fakten geloescht, dann wird der }
{ ICcheck und Axiomcheck fuer alle importierenden Module ausgefuehrt, danach werden die CB_export Fakten aus }
{ Konsistenzgruenden wieder erzeugt (um spaeter im ObjectProcessor wieder geloescht zu werden  4-8-1995 LWEB }

check_for_untell(_errno) :-
  	temp_del_export_attributes,!,									{temperory Aenderung}
  	getModule(_m),
  	save_setof( _imod, importing_module(_imod), _imodlist),		{ kontrolliere alle importierenden Module und alle geschachtelten Module}
										{ in importierenden Modulen }
	id2name_list(_imodlist,_inames),
	WriteTrace(veryhigh,SemanticIntegrity,[' Importing Modules that are affected by this transaction: ',_inames]),

	append([_m],_imodlist,_mimodlist),
   	get_nested_modules(_mimodlist,_modules_to_be_checked),

	id2name_list(_modules_to_be_checked,_mtbc),
	WriteTrace(veryhigh,SemanticIntegrity,[' Modules to be checked for Integrity violations are: ',_mtbc]),

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
	WriteTrace(veryhigh,SemanticIntegrity,[' Modules to be checked for Integrity violations are: ',_mtbc]),
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


{*********************************************retell*********************************************}




check_for_retell(_errno) :-
	temp_ins_export_attributes,!,
  	temp_del_export_attributes,!,
	getModule(_m),
  	save_setof( _imod, importing_module(_imod), _imodlist),		{ kontrolliere alle importierenden Module und alle geschachtelten Module}
										{ in importierenden Modulen }
	id2name_list(_imodlist,_inames),
	WriteTrace(veryhigh,SemanticIntegrity,[' Importing Modules that are affected by this transaction: ',_inames]),

	append([_m],_imodlist,_mimodlist),
   	get_nested_modules(_mimodlist,_modules_to_be_checked),

	id2name_list(_modules_to_be_checked,_mtbc),
	WriteTrace(veryhigh,SemanticIntegrity,[' Modules to be checked for Integrity violations are: ',_mtbc]),

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
        {* error count might be incremented by check_retell_ICs; ticket #318 *}
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
	WriteTrace(veryhigh,SemanticIntegrity,[' Modules to be checked for Integrity violations are: ',_mtbc]),
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
 	'error_number@UI'(_e1),   {* ticket #318 *}
	'error_number@SI'(_e2),
	_errno is _e1 + _e2,
	!.




{ ================== }
{ Private predicates }
{ ================== }

check_axioms([],_omod) :- setModule(_omod).  		{ 1-Aug-1995 LWEB }

check_axioms([_h|_t],_omod):-
	setModule(_h),	{ fuehre Axiomueberpruefung nach und nach fuer jedes Modul durch }
	check_axioms,
	check_axioms(_t,_omod).

check_axioms :-								{ 27.07.1990 RG }
	retrieve_temp_ins(P(_id,_s,_l,_d)),		{ 31-Jul-1995 LWEB }
  	check_proposition(P(_id,_s,_l,_d)),
  fail.

check_axioms.	{final success for module }


check_ICs([],_omod) :- setModule(_omod).  			{ 1-Aug-1995 LWEB }

check_ICs([_h|_t],_omod):-
	setModule(_h),
		check_ICs,
	check_ICs(_t,_omod).

check_ICs:-								{ 3-Nov-1992 MSt }
  	retrieve_temp_ins(P(_id,_s,_l,_d)),			{ 31-Jul-1995 LWEB }
  	check_proposition_forICs(P(_id,_s,_l,_d)),
  fail.

check_ICs.  {final success}

{ ************ c h e c k _ u n t e l l _ a x i o m s / I C s **************** }
{                                                             }
{ check_untell_axioms/ICs                                                                                         }
{                                                             }
{                                                             }
{ Checks for each 'temp'-propval the integrity for untelling  }
{                                                             }
{ *********************************************************** }

check_untell_axioms([],_omod) :- setModule(_omod).  		{ 1-Aug-1995 LWEB }

check_untell_axioms([_h|_t],_omod):-
	setModule(_h),
	check_untell_axioms,
	check_untell_axioms(_t,_omod).

check_untell_axioms:-
  retrieve_temp_del(P(_id,_s,_l,_d)),		{ 12-Jul-1995 LWEB }
  check_untell_proposition(P(_id,_s,_l,_d)),
  fail.

check_untell_axioms.  {final success}

check_untell_ICs([],_omod) :- setModule(_omod).  			{ 1-Aug-1995 LWEB }

check_untell_ICs([_h|_t],_omod):-
	setModule(_h),
	check_untell_ICs,
	check_untell_ICs(_t,_omod).

check_untell_ICs:-                     { 3-Nov-1992 MSt }
  retrieve_temp_del(P(_id,_s,_l,_d)),			{ 12-Jul-1995 LWEB }
  check_untell_proposition_forICs(P(_id,_s,_l,_d)),
  fail.

check_untell_ICs.  {final success}



{******************************* check retell axioms/ICs ***************************************}
{ Hier werden check_retell_axioms und ckeck_retell_ICs gebaut, Check fuer Untell und Tell wird  }
{ hintereinander ausgefuehrt									}

check_retell_axioms([],_omod) :- setModule(_omod).

check_retell_axioms([_h|_t],_omod):-
	setModule(_h),
	check_retell_axioms,
	check_retell_axioms(_t,_omod).

check_retell_axioms:- 							{check for untell und tell hintereinander}
  retrieve_temp_del(P(_id0,_s0,_l0,_d0)),
  check_untell_proposition(P(_id0,_s0,_l0,_d0)),
  retrieve_temp_ins(P(_id,_s,_l,_d)),
  check_proposition(P(_id,_s,_l,_d)),
  fail.

check_retell_axioms.  {final success}



check_retell_ICs([],_omod) :- setModule(_omod).


check_retell_ICs([_h|_t],_omod):-
	setModule(_h),
	check_retell_ICs,
	check_retell_ICs(_t,_omod).

check_retell_ICs:-
  retrieve_temp_del(P(_id0,_s0,_l0,_d0)),					{check for untell und tell hintereinander}
  check_untell_proposition_forICs(P(_id0,_s0,_l0,_d0)),
  retrieve_temp_ins(P(_id,_s,_l,_d)),
  check_proposition_forICs(P(_id,_s,_l,_d)),
  fail.

check_retell_ICs.  {final success}





{ ************ c h e c k _ p r o p o s i t i o n ( f o r I C s)************ }
{                                                             }
{ check_proposition(forICs)(_propdescr)                       }
{   _propdescr: partial                                       }
{                                                             }
{ Checks _propdescr for semantic integrity. If inconsistent,  }
{ the error number ('error_number@SI') is incremented.        }
{                                                             }
{ *********************************************************** }

check_proposition(_propdescr) :-
  SMLvalid(_propdescr),
  !.

{ if error detected: }
check_proposition(_p) :-
  increment('error_number@SI'),
  !.

check_proposition_forICs(_propdescr) :-                     { 3-Nov-1992 MSt }
  tellCheck_BDMIntegrity(_propdescr),
  !.

{ if error detected: }
check_proposition_forICs(_p) :-
   increment('error_number@SI'),
  !.

{ ****** c h e c k _ u n t e l l _ p r o p o s i t i o n ( f o r I C s) *********** }
{                                                             }
{ check_untell_proposition(forICs)(_propdescr)                        }
{   _propdescr: partial                                       }
{                                                             }
{ Checks _propdescr for semantic integrity for untelling. If  }
{ inconsistent, the error number ('error_number@SU') is       }
{ incremented.                                                }
{                                                             }
{ *********************************************************** }

check_untell_proposition(_propdescr) :-
  SMLvalid_untell(_propdescr),
  !.

{ if error detected: }
check_untell_proposition(_p) :-
  increment('error_number@UI'),
  !.

check_untell_proposition_forICs(_propdescr) :-                      { 3-Nov-1992 MSt }
  untellCheck_BDMIntegrity(_propdescr),
  !.

{ if error detected: }
check_untell_proposition_forICs(_p) :-
  increment('error_number@UI'),
  !.



