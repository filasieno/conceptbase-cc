/**
The ConceptBase.cc Copyright

Copyright 1987-2020 The ConceptBase Team. All rights reserved.

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
* File:        IpcParser.pro
* Version:     11.4
*
*
* Date released : 97/05/21  (YY/MM/DD)
*
* SCCS-Source-Pool : /home/CBase/CB_NewStruct/ProductPOOL/SCCS/serverSources/Prolog_Files/s.IpcParser.pro
* Date retrieved : 97/07/09 (YY/MM/DD)
***************************************************************************
*
* Exported predicates:
* --------------------
*
* - IpcParserTypeDefs/0
*
* - GetIpcMessageFromC/2
*
*
* Changes:
* --------
*
* 07-Dec-94/CQ: Fehler bei HYPO_ASK berichtigt
*
* 09-Dez-96/LWEB: Ipc-Grammatik wurde um eine optionale Modulstelle erweitert.
*/


:- module('IpcParser',[
'GetIpcMessageFromC'/2
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').

:- use_module('PrologCompatibility.swi.pl').


:- use_module('ExternalCodeLoader.swi.pl').


:- style_check(-singleton).





/**** =====================================================
	GetIpcMessageFromC( _tipo, _ipcmessage )

		_tipo : ground : the IpcParser output
		_ipcmessage : free

	constructs the Prolog term ipcmessage(_sender,_receiver,_method,_args)
	from the IpcParser output.

====================================================  ****/

'GetIpcMessageFromC'(_p,_msg) :-
    'GetIpcMessageAsTerm'(_r,_p,_msg1),
    _r == 1,
    fixLPICall(_msg1,_msg).

/*LPI_CALL*/
fixLPICall(ipcmessage(_sender,_receiver,'LPI_CALL', [_atom]),ipcmessage(_sender,_receiver,'LPI_CALL', [['PROLOG_CALL'|_term]])) :-
	!,
	pc_atomconcat('PROLOG_CALL,',_rest,_atom),
	pc_atomconcat(['[',_rest,']'],_newatom),
	((pc_atom_to_term(_newatom,_term),!);
	(write('Error: Unable to read PROLOG term'),!,fail)).

fixLPICall(ipcmessage(_sender,_receiver,'LPI_CALL', [_atom]),ipcmessage(_sender,_receiver,'LPI_CALL', [_term])) :-
	!,
	pc_atomconcat(['[',_atom,']'],_newatom),
	((pc_atom_to_term(_newatom,_term),!);
	(write('Error: Unable to read PROLOG term'),!,fail)).

fixLPICall(_msg,_msg).
