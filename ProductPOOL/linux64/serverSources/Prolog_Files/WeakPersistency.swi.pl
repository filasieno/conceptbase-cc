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
* File:         WeakPersistency.pro
* Version:      11.1
*
*
* Date released : 96/08/20  (YY/MM/DD)
*
* SCCS-Source-Pool : /home/CBase/CB_NewStruct/ProductPOOL/serverSources/Prolog_Files/SCCS/s.WeakPersistency.pro
* Date retrieved : 97/05/30 (YY/MM/DD)
* -----------------------------------------------------------------------------
*
*
*
* Metaformel-Aenderungen:
*
* process_list_of_clauses erhaelt zwei Listen, eine mit einzufuegenden
* Klauseln, eine mit zu loeschenden Klauseln
*
* assertOrRetract meldet einen Fehler, wenn es eine zu loeschende Klausel
* nicht findet, anstatt ein 'ToBeDeleted(...)' an das OB.rule file
* anzuhaengen
*/


:- module('WeakPersistency',[
'SAVE'/2
,'cleanup'/0
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').


:- use_module('PROLOGruleProcessor.swi.pl').

:- use_module('ModelConfiguration.swi.pl').
:- use_module('TellAndAsk.swi.pl').
:- use_module('PropositionProcessor.swi.pl').
:- use_module('validProposition.swi.pl').
:- use_module('GeneralUtilities.swi.pl').


:- use_module('PrologCompatibility.swi.pl').







:- style_check(-singleton).





/****************************** S A V E ***************************************/
/* SAVE(generatedcode(_listofclausesToInsert,_listofclausesToDelete), _mode)  */
/*									     */
/*	_mode: ground : tell/untell					     */
/*									     */
/* SAVE persistently stores information created by tell_objproc and 	     */
/* untell_objproc to files belonging to the current application.	 	     */
/******************************************************************************/

'SAVE'(generatedcode(_listofclausesToInsert,_listofclausesToDelete), _mode) :-
	ground(_mode),
  	get_application(_appfile),
	process_list_of_clauses(_appfile,_listofclausesToInsert,_listofclausesToDelete,_mode).






/************************** c l e a n u p *************************************/
/*									     */
/* cleanup cleans files belonging to the current application resulting in     */
/* less storage usage and faster reloading of this application.               */
/******************************************************************************/


cleanup :-
	application_active, !,
	get_application(_app),
        assert('persistency@term'(dummy)),
        retract('persistency@term'(dummy)),
	cleanup(_app,rule).


cleanup :- !.





/*======================*/
/* private predicates   */
/*======================*/





/**************  p r o c e s s _ l i s t _ o f _ c l a u s e s  **************/
/*                                                                           */
/* process_list_of_clauses (_app,_clauselistInsert,_clauselistDelete,_mode)  */
/*               _app : ground : atom                 02-Feb-89 MSt          */
/*               _clauselistInsert : ground : clauses to insert              */
/*               _clauselistInsert : ground : clauses to delete              */
/*               _mode : ground : atom			       		    */
/*                                                                           */
/* process_list_of_clauses sends lists of PROLOGrules  to the                */
/* PROLOGruleProcessor for saving in _rule.pro file.                         */
/*                                                                           */
/*                                                                           */
/*****************************************************************************/

process_list_of_clauses(_,[],[],tell) :- !.

process_list_of_clauses(_app,_clauselistInsert,_clauselistDelete,tell) :-
        appFilename('rule',_app,_pfile),
        store_toFile_PROLOGrules(_pfile,_clauselistInsert),
        delete_fromFile_PROLOGrules(_pfile,_clauselistDelete).


process_list_of_clauses(_,[],[],untell) :- !.

process_list_of_clauses(_app,_clauselistInsert,_clauselistDelete,untell) :-
        appFilename('rule',_app,_pfile),
        store_toFile_PROLOGrules(_pfile,_clauselistInsert),
        delete_fromFile_PROLOGrules(_pfile,_clauselistDelete).

process_list_of_clauses(_,[],[],retell) :- !.

process_list_of_clauses(_app,_clauselistInsert,_clauselistDelete,retell) :-
        appFilename('rule',_app,_pfile),
        store_toFile_PROLOGrules(_pfile,_clauselistInsert),
        delete_fromFile_PROLOGrules(_pfile,_clauselistDelete).





/******************************************************************************/

cleanup(_app, _what) :-
    appFilename(_what,_app,_clfilename),
	pc_fopen(cleanfile,_clfilename,r),
	!,
	repeat,
	read_term_eof(cleanfile,_term),
	assertORretract(_term, _what),
	_term = end_of_file,
	pc_fclose(cleanfile),
	!,
	writeback(_app,_what),
    abolish('persistency@term',1).

cleanup(_filename, _what).


/******************************************************************************/

move(_f1, _f2) :-
  pc_atomconcat('/bin/mv ',_f1,_src),
  pc_atomconcat(_src,' ',_src2),
  pc_atomconcat(_src2,_f2,_shcmd),
  shell(_shcmd).


/******************************************************************************/


writeback(_app, rule) :-
        appFilename(rule,_app,_filename),
	pc_fopen(cleanfile,_filename,w),
	retract('persistency@term'(_term)),
        write_it(cleanfile,_term),
	fail.

writeback(_app, rule) :-
        pc_fclose(cleanfile),
        !.


/******************************************************************************/

write_it(_f,_term) :-
    pc_swriteQuotesAndModule(_atom,_term),
	write(_f, _atom),
	write(_f,' .'),
	nl(_f).


/******************************************************************************/


assertORretract(end_of_file,_):- !.

assertORretract('ToBeDeleted'(_del_clause),rule):-
	retract_clause(_del_clause),!.
assertORretract('ToBeDeleted'(_del_clause),rule):-
	write(_del_clause),write(' not found'),nl,nl,!.
assertORretract(_clause,rule):-
	assert('persistency@term'(_clause)).



/******************************************************************************/

retract_clause(_del_clause) :-
	(_del_clause = 'RuleTTime'(_id, tt(_t1,_t2)),
	  retract( 'persistency@term'( 'RuleTTime'(_id, tt(_t1)) ) ),
	 assert( 'persistency@term'( 'RuleTTime'(_id, tt(_t1, _t2)) ) )
	);
	 retract('persistency@term'(_del_clause)).
