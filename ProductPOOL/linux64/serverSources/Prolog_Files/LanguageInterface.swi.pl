/**
The ConceptBase.cc Copyright

Copyright 1987-2023 The ConceptBase Team. All rights reserved.

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
**/
/*
*
* File:        	LanguageInterface.pro
* Version:     	7.4
* Creation:    01-Dec-1988, Hans Nissen (UPA)
* Last Change: 	03 Nov 1994, Kai v. Thadden (RWTH)
* Release:     	7
* -----------------------------------------------------------------------------
*
*
*  Exported predicates:
*  --------------------
*     + build_fragments/2
*     + build_fragments_from_cstring/2
*
*
*  Change history:
*  ---------------
*	2-Jan-1989/MJf: adding error messages to parseSML and formatSML
*      31-Aug-1989/MJf: correcting an error in parseSML ('Identifier' is
*                       used by some tools instead of 'identifier').
*      09-Nov-1989/MSt: parseSML/4 can now also be used to parse a charlist
*                       containing more than one CMLobjects
*                       new pred parseSMLtexts/2.
*      Many,many Schrott removed, MSt, 19-8-92
*
*  9-Dez-1996/LWEB : in build_fragments_from_cstring / 2  wird ueberprueft, ob
* der Telosparser ein  $set module=MODULE  gefunden hat. Falls ja, wird M_Searchspace/1 umgesetzt.
*
*/


:- module('LanguageInterface',[
'build_fragments_from_cstring'/2
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').

:- use_module('GeneralUtilities.swi.pl').
:- use_module('ErrorMessages.swi.pl').
:- use_module('ExternalCodeLoader.swi.pl').











:- use_module('CBserverInterface.swi.pl').



:- use_module('PrologCompatibility.swi.pl').







:- style_check(-singleton).




/* **************************************************************************** */


build_fragments(_charlist,_fraglist) :-
	_charlist = [_|_], var(_fraglist),
	length(_charlist,_len),
	'CharListToCString'(_cstring,_charlist,_len),
	build_fragments_from_cstring(_cstring, _fraglist),
	memfree(_cstring),
	!.


/**** =================================================
	build_fragments_from_cstring( _cstring, _fraglist )

		_cstring : pointer (C-String)
		_fraglist : free

	calls the Telos parser and returns a list of SMLfragments.
	The _cstring has to be deallocated by the caller.
===============================================  ****/

build_fragments_from_cstring(_cstring, _fraglist) :-
	pc_pointer(_cstring), var(_fraglist),
	te_frame_parser(_C_ParseOutput,_cstring),
	get_mod_context(_modcon),					/* 2-10-1996 LWEB */
/*	write('geparster modkonext: '),write(_modcon),nl,	*/
	(
		_modcon = 'DEFAULT'
	;
		(
			current_sender(_s),
        		knownTool(_s,_toolclass,_user,_fd,_old_module),
			checkPermission(_user,'TELL',_modcon),  /** enough rights to do a TELL **/
			enactModuleContext(_modcon,ok),       /** must be successful **/
			!
		)
	),
	getFrameParseErrNo(_errno,_C_ParseOutput),
	!,
	build_fragments2(_C_ParseOutput,_errno,_fraglist).

/**  Fehler beim Parsen der Modulcontext Direktive **/
build_fragments_from_cstring(_, _) :-
	get_mod_context('ERROR'),
	report_error( 'MOD2', 'CBserverInterface', ['ERROR']),
	!.

/**  Fehler: geparster Modulkontext existiert nicht **/
build_fragments_from_cstring(_, _) :-
	get_mod_context(_modcon),
	report_error( 'MOD1', 'CBserverInterface', [_modcon]),
	!.

build_fragments2(_C_ParseOutput,0,_fraglist) :-
	getFragmentListFromFrameParseOutput(_C_fraglist,_C_ParseOutput),
	'GC_ifNotEnoughHeapSpace'(_C_fraglist),
	'FragmentListCToProlog'(_C_fraglist,_fraglist),
	'DestroySMLfrag'(_C_fraglist), 
	memfree(_C_ParseOutput),
	!.

build_fragments2(_C_ParseOutput,_errno,_fraglist) :-
        _errno \== 0,  /*error*/
        getFrameParseErrLine(_errline,_C_ParseOutput),
        getFrameParseErrToken(_errtoken,_C_ParseOutput),
        ((_errtoken = 'SET_MODULE_ERROR',
          report_error('SET_MODULE_ERROR','TelosParser',[_errline]),
          !
         );
         report_error('TELOSPARSEERR','TelosParser',[_errno,_errline,_errtoken])
        ),
        getFragmentListFromFrameParseOutput(_C_fraglist,_C_ParseOutput),
        'DestroySMLfrag'(_C_fraglist), 
        memfree(_C_ParseOutput),
        increment('error_number@F2P'), 
        !,
        fail.



/* GC_ifNotEnoughHeapSpace: Garbage collection may be executed before the Heap is totally exhausted, esp. when it is exhausted by aboutt 90%. A secure way is to use get_term_space.
*/

'GC_ifNotEnoughHeapSpace'(_C_fraglist) :-
	getFragmentListSpace( _cells_needed1, _C_fraglist ),
	_cells_needed2 is _cells_needed1 + 100,  /* to go sure */
	get_term_space( _ok, _cells_needed2 ),  /* GC, if needed */
	!, _ok \== 0 .
