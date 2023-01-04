/**
The ConceptBase.cc Copyright

Copyright 1987-2022 The ConceptBase Team. All rights reserved.

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
Matthias Jarke, RWTH Aachen, Informatik 5, Ahornstr. 55, 52056 Aachen, Germany
Christoph Quix, RWTH Aachen, Informatik 5, Ahornstr. 55, 52056 Aachen, Germany


This license is a FreeBSD-style copyright license.
Legal home of the FreeBSD copyright license: http://www.freebsd.org/copyright/freebsd-license.html
**/
/*
*
* File:         %M%
* Version:      %I%
* Creation:    01.01.1993 Thomas List (RWTH)
* Last Change   : %E%, Thomas List (RWTH)
*
* SCCS-Source-Pool : %P%
* Date retrieved : %D% (YY/MM/DD)
-----------------------------------------------------------------------------
*
*
*
*
*/
:- module('BIM2C',[
'check_implicit'/1
,'create'/1
,'delete_export'/1
,'delete_import'/1
,'done_bim2c'/0
,'id2select'/2
,'id2starttime'/2
,'id2endtime'/2
,'init'/1
,'new_export'/1
,'new_import'/1
,'prove_C_A'/3
,'prove_C_Adot'/4
,'prove_C_Aidot'/4
,'prove_C_In_i'/2
,'prove_C_Attr_s'/2
,'prove_C_In_s'/2
,'prove_C_Isa'/2
,'prove_C_sys_class'/2
,'retrieve_C_proposition'/1
,'retrieve_C_proposition_set'/2
,'retrieve_C_proposition_module'/1
,'set_act_hist_bim2c'/0
,'set_current_OB_bim2c'/0
,'set_cbmodule'/1
,'set_new_OB_bim2c'/0
,'set_old_OB_bim2c'/0
,'set_overrule_act_bim2c'/0
,'set_overrule_module'/1
,'set_overrule_temp_bim2c'/0
,'set_overrule_temp_tell_bim2c'/0
,'set_overrule_temp_untell_bim2c'/0
,'set_search_point_bim2c'/7
,'set_persistency_level_bim2c'/1
,'set_time_point_bim2c'/7
,'sysIdOfProposition'/1
,'sysclass'/2
,'update_zaehler'/3
,'update_zaehler_ohne_huelle'/3
,'id2name_bim2c'/2
,'star_name2id_bim2c'/2
,'name2id_bim2c'/2
,'rename_object'/2
,'select2id_bim2c'/2
,'insert_commit_bim2c'/0
,'insert_abort_bim2c'/0
,'remove_abort_bim2c'/0
,'remove_end_bim2c'/0
,'set_act_bim2c'/0
,'set_temp_bim2c'/0
,'remove'/1
,'removetmp'/1
,'changeAttributeValue'/2
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').

:- use_module('ExternalCodeLoader.swi.pl').


















































:- use_module('PropositionProcessor.swi.pl').
:- use_module('startCBserver.swi.pl').
:- use_module('PrologCompatibility.swi.pl').

:- use_module('GeneralUtilities.swi.pl').








:- use_module('ModelConfiguration.swi.pl').








:- use_module('CBserverInterface.swi.pl').



:- use_module('ErrorMessages.swi.pl').
:- use_module('GlobalParameters.swi.pl').
:- use_module('MetaUtilities.swi.pl').


:- style_check(-singleton).




init(_app):-
	init(_succ,_app),
	_succ==1 .

init(_app):-
	'ClearAndClean',
	reportOptionErrorAndStop('Application file does not match current version.').

done_bim2c:-done.
test_bim2c:-test.

insert_commit_bim2c :- insert_commit.
insert_abort_bim2c :- insert_abort.
remove_abort_bim2c :- remove_abort.
remove_end_bim2c :- remove_end.

/*******************************************************************************************/

set_act_bim2c:-
	/*write(akt),nl,*/
	set_act.

set_temp_bim2c :-
	/*write(temp),nl,*/
	set_temp.

set_overrule_temp_bim2c:-
	/*write(overrule_temp),nl,*/
	set_overrule_temp.

set_overrule_temp_tell_bim2c:-
	set_overrule_temp_tell.

set_overrule_temp_untell_bim2c:-
	set_overrule_temp_untell.

set_overrule_act_bim2c:-
	/*write(overrule_act),nl,*/
	set_overrule_act.

set_hist_bim2c:-
	/*write(hist),nl,*/
	set_hist.

set_act_temp_bim2c:-
	/*write(act_temp),nl,*/
	set_act_temp.

set_act_hist_bim2c:-
	/*write(act_hist),nl,*/
	set_act_hist.

set_new_OB_bim2c:-
	set_new_OB.

set_old_OB_bim2c:-
	set_old_OB.

set_current_OB_bim2c:-
	set_current_OB.

set_persistency_level_bim2c(_newlevel) :-
	set_persistency_level(_newlevel).

/********************************************************************************************/

set_time_point_bim2c(_milsec,_sec,_min,_hour,_mday,_mon,_year):-
/*	write(set_time_point(_milsec,_sec,_min,_hour,_mday,_mon,_year)),nl, */
	set_time_point(_milsec,_sec,_min,_hour,_mday,_mon,_year).

set_search_point_bim2c(_milsec,_sec,_min,_hour,_mday,_mon,_year):-
/*	write(set_search_point(_milsec,_sec,_min,_hour,_mday,_mon,_year)),nl, */
	set_search_point(_milsec,_sec,_min,_hour,_mday,_mon,_year).

delete_history_db_bim2c(_ms,_s,_mi,_h,_d,_m,_y):-
	delete_history_db(_ms,_s,_mi,_h,_d,_m,_y).


retrieve_C_proposition(_M):-
    retrieve_prop_query(_M,_result),
    !,
    member(_M,_result).

retrieve_C_proposition_set(_M,_propset):-
    retrieve_prop_query(_M,_propset),
    !.



retrieve_C_proposition_module(_M):-
    retrieve_prop_module_query(_M,_result),
    !,
    member(_M,_result).


/** y is an explicit attribute value of x **/
prove_C_Attr_s(_x,_y) :-
    'Attr_s_query'('M'(_x,_y),_result),
    !,
    member('M'(_x,_y),_result).

prove_C_In_s(_x,_y) :-
    'In_s_query'('M'(_x,_y),_result),
    !,
    member('M'(_x,_y),_result).

prove_C_In_i(_x,_y) :-
    'In_i_query'('M'(_x,_y),_result),
    !,
    member('M'(_x,_y),_result).

prove_C_Isa(_x,_y) :-
    'Isa_query'('M'(_x,_y),_result),
    !,
    member('M'(_x,_y),_result).

prove_C_sys_class(_x,_y) :-
    sys_class_query('M'(_x,_y),_result),
    !,
    member('M'(_x,_y),_result).

prove_C_Adot(_cc,_x,_l,_y) :-    
    'Adot_query'('M'(_cc,_x,_l,_y),_result),   /** _l is the label of an explicit attribute between x,y; ticket #187 **/
    !,
    member('M'(_cc,_x,_l,_y),_result).


/** ticket #211 **/
prove_C_Aidot(_cc,_x,_l,_id) :-
    'Aidot_query'('M'(_cc,_x,_l,_id),_result),  /** _l is the label of an explicit attribute between x,y **/
    !,
    member('M'(_cc,_x,_l,_id),_result).

prove_C_A(_x,_ml,_y) :-
    'A_query'('M'(_x,_ml,_y),_result),
    !,
    member('M'(_x,_ml,_y),_result).

star_name2id_bim2c(_name,_id):-
    star_query(_name,_result),
    !,
    member(_id,_result).


/*name2id_bim2c(_x,_x):-var(_x),write('name2id-Aufruf mit Variablen!!!!'),nl,!.*/


/* name2id_bim2c(_x,_y):-write(NAME2ID(_x,_y)),nl,fail.		*/

name2id_bim2c(_id,_id):-
        is_id(_id), /** pc_atomconcat('id_',_,_id), **/
 	!.

 /** id_6 = Proposition!attribute = Attribute; see also checkCorrectIDs in Literals **/
name2id_bim2c('Attribute',id_6):-
   !.

name2id_bim2c('InstanceOf',id_1):-
   !.

name2id_bim2c('IsA',id_15):-
   !.

name2id_bim2c('Single',_id):-
   select2id_bim2c('Proposition!single',_id),
   !.

name2id_bim2c('Necessary',_id):-
   select2id_bim2c('Proposition!necessary',_id),
   !.

name2id_bim2c(_name,_id):-
    atom(_name),
    name2id(_succ,_name,_idout),
    _idout = _id,
    _succ ==1,
    !.


cname2id(_name,_id):-
	atom(_name),
 	name2id(_succ,_name,_id),
 	_succ==1,
 	!.

cname2id(_name,_id):-
/*	write(create_implicit_node(p(_id,_,_name,_))),nl,		*/
	atom(_name),
	create_implicit_node(_r,_name,_id),
	_r == 1,
	!.

nname2id(_name,_id):-
/*	write(NNAME2ID(_name,_id)),nl,	*/
	atom(_name),
	create_name2id(_succ,_name,_id),
	_succ==1,
	!.

nname2id(_name,_id):-
/*	write(create_node(_name,_id)),nl,*/
	atom(_name),
	create_node(_r,_name,_id),
	_r == 1,
	!.


/* erzeugt aus einer Namen-Liste eine ID-Liste */
liste_name2id([_name|_rests],[_id|_restids]):-
	name2id_bim2c(_name,_id),
	liste_name2id(_rests,_restids).

liste_name2id([],[]).

liste_id2name([_id|_rests],[_name|_restnames]):-
	id2name_bim2c(_id,_name),
	liste_id2name(_rests,_restnames).

liste_id2name([],[]).


id2name_bim2c(_id,_name):-
/*	write(id2name_bim2c(_id,_name)),nl,*/
    atom(_id),
    is_id(_id),  /** pc_atomconcat('id_',_,_id), **/
    !,
    id2name(_succ,_id,_name),
    _succ==1,
    !.



/** select2id_bim2c is deprecated; ticket #281 *)
 {* id_6 = Proposition!attribute = Attribute; see also checkCorrectIDs in Literals **/
select2id_bim2c('Attribute',id_6):-
/**	select2id_bim2c('Proposition!attribute',_id), **/
	!.


select2id_bim2c(_name,_id):-
	select2id(_succ,_name,_idout),
	_succ==1,
	_idout = _id,
	!.

/** select2id/3 sometimes fails when called for an object name which **/
/** represents a $formula$. Then, we try name2id_bim2c since this    **/
/** appears more robust.                                             **/

select2id_bim2c(_name,_id):-
	atom(_name),
	name2id_bim2c(_name,_id),
	!.

id2select(_id,_name):-
/*	write(id2select(_id,_name)),nl,*/
	atom(_id),
        is_id(_id),  /** pc_atomconcat('id_',_,_id), **/
 	!,
	id2select(_succ,_id,_name),
        !.

/** id2starttime returns the start time of an object _id **/
id2starttime(_id,tt(_starttime)) :-
/*	write(id2starttime(_id,_milsec,_sec,_min,_hour,_mday,_mon,_year)),nl,*/
	id2starttime(_succ,_id,_milsec,_sec,_min,_hour,_mday,_mon,_year),
	_succ==1,
	formTimeTuple(_milsec,_sec,_min,_hour,_mday,_mon,_year,_starttime),
	!.

/** id2endtime returns the end time of an object _id **/
id2endtime(_id,tt(_endtime)) :-
        id2endtime(_succ,_id,_milsec,_sec,_min,_hour,_mday,_mon,_year),
        _succ==1,
	formTimeTuple(_milsec,_sec,_min,_hour,_mday,_mon,_year,_endtime),
        !.

/** this is the 'infinity' time point in the object store libCos3 **/
formTimeTuple(0,59,59,23,31,12,1969,'infinity') :- !. 

formTimeTuple(_milsec,_sec,_min,_hour,_mday,_mon,_year,
              millisecond(_year,_mon,_mday,_hour,_min,_sec,_milsec)).

check_implicit(_id):-
	ground(_id),
	check_implicit(_succ,_id),
	_succ==1,
	!.

create('P'(_id1,_id,_lab,_id)):-
/*	write(create(P(_id1,_id,_lab,_id))),nl,	*/
/* warum so? - falls _id1 frei ist und _id ist belegt soll man einen Link
  von _id nach _id erzeigen und keinen neuen Knoten (reflexiver Link)
*/
     _id1 == _id,
     !,
     nname2id(_lab,_id),
     _id1=_id.

create('P'(_id,_src,_lab,_dst)):-
   cname2id(_src,_srcid),
   cname2id(_dst,_dstid),
   create_link(_succ,_id,_srcid,_lab,_dstid),
   _succ == 1,!.

remove(_id):-remove(_succ,_id),_succ==1,!.

/** to remove an object _id that has been told in the current transaction **/
/** If successful, the object _id won't exist anymore afterwards, i.e.    **/
/** it will not be visible even to rollback queries.  See ticket #92      **/
removetmp(_id):-
  removetmp(_succ,_id),
 _succ==1,!.

rename_object(_newname,_oldname):-
	name2id_bim2c(_oldname,_oldID),
        may_be_renamed(_oldID),              /** rename is access-restricted (CBNEWS.doc[209] **/
	sysclass(_oldID,id_7),      /* id_7=Individual */
	rename(_succ,_newname,_oldname),
	_succ==1,!.

rename_object(_newname,_oldname):-
  \+ name2id_bim2c(_oldname,_oldID),
  report_error('PFNFE','BIM2C',[_oldname]),   /** not found error **/
  !,
  fail.



/** An object may get a new name if              **/
/**  a) the security level is 0 (disabled)       **/
/** or                                           **/
/**  b1) objid is defined in the current module  **/
/**      context, and                            **/
/**  b2) the current user has write permission   **/
/**      to the current module                   **/

/* case a: */
may_be_renamed(_objid) :-
  get_cb_feature(securityLevel,'0'),       /** access control disabled,  CBserver option -s **/
  !.

/* case b: */
may_be_renamed(_objid) :-
   active_sender(_s),  /** this tool has requested the rename **/
   knownTool(_s,_,_user,_,_module),   /** this is the user behind the tool and the name of the module **/
   name2id_bim2c(_module,_m1),
   retrieve_proposition_noimport(_m2,'P'(_objid,_x,_l,_y)),  /** objid is defined in module m2 **/
   check_rename_permission(_objid,_user,_module,_m1,_m2),
   !.

check_rename_permission(_objid,_user,_module,_m1,_m2) :-
  _m1 \== _m2,
  report_error('WRONG_MODULE', 'BIM2C', ['rename',objectName(_objid),objectName(_m1),objectName(_m2)]),
  !,
  fail.

check_rename_permission(_objid,_user,_module,_m1,_m2) :-
  \+ checkPermission(_user,'TELL',_module),
  report_error( 'NO_RENAME', 'BIM2C', [_user,_module,objectName(_objid)]),
  !,
  fail.

check_rename_permission(_objid,_user,_module,_m1,_m2).



changeAttributeValue(_aid,_oid):-
	changeAttrValue(_aid,_oid).

sysclass(_id,_class):-
	atom(_id),
	!,
	(
		get_sys_class(_succ,_id,_nclass),_succ==1 ;
		_class=id_0     /** id_0= Proposition **/
	),
	_nclass = _class.

sysclass(_id,_class):-
	atom(_class),
	!,
	prove_C_sys_class(_id,_class).

sys_class(_id,_class):-
	get_all_instances_of_systemOmegaClass(_id,_class).

get_all_instances_of_systemOmegaClass(_id,_c):-
	member(_c,[id_6,id_15,id_1,id_7,id_0]),  /** Attribute,IsA,InstanceOf,Individual,Proposition **/
	prove_C_sys_class(_id,_c).



sysIdOfProposition(_id):-
     get_prop_id(_succ,_nid),!,
    _succ==1,
    _id = _nid,!.

update_zaehler(_id,_box,_count) :-
    	!,
	update_zaehler(_succ,_id,_box,_count),
	_succ==1 .

update_zaehler_ohne_huelle(_id,_box,_count) :-
    	!,
	update_zaehler_ohne_huelle(_succ,_id,_box,_count),
	_succ==1 .

get_zaehler(_id,_box,_count) :-
    	!,
	get_zaehler(_succ,_id,_box,_count),
	_succ==1 .


update_histogramm(_id,_dir) :-
    	!,
	pc_time(
	update_histogramm(_succ,_id,_dir),
	_t),

    write('Time: '),write(_t),nl,

	_succ==1 .

update_histogramm(_id,_dir,_src,_dst) :-
    	!,
	pc_time(
	update_histogramm(_succ,_id,_dir,_src,_dst),
	_t),

    write('Time: '),write(_t),nl,

	_succ==1 .

get_histogramm(_id,_dir,_list):-
	start_get_histogramm(_succ1,_id,_dir),
	_succ1 == 1,
	findall(_count-_id2,(repeat,get_one_histogramm(_succ,_id2,_count),(_succ\=1,!,fail ; true)),_list).




/* Module : */

set_cbmodule(_id):-
	set_module(_succ,_id),!,
	_succ==1 .

/* nur fuer retrieve_proposition */
set_overrule_module(_id):-
	set_overrule_module(_succ,_id),!,
	_succ==1 .

initialize_module(_id):-
	initialize_module(_succ,_id),!,
	_succ==1 .

system_module(_id):-
	system_module(_succ,_id),!,
	_succ==1 .

new_export(_id):-
	new_export(_succ,_id),!,
	_succ==1 .
/*		write(new_export(_id)),nl .	*/

delete_export(_id):-
	delete_export(_succ,_id),!,
	_succ==1 .
/*		write(delete_export(_id)),nl .	*/

new_import(_id):-
	new_import(_succ,_id),!,
	_succ==1 .
/*		write(new_import(_id)),nl .	*/

delete_import(_id):-
	delete_import(_succ,_id),!,
	_succ==1 .
/*		write(delete_export(_id)),nl .	*/




