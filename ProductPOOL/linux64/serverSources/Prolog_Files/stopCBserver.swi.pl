/**
The ConceptBase.cc Copyright

Derived from ConceptBase.cc, originally created by the ConceptBase Team under a FreeBSD-style license.

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
*
* File:         %M%
* Version:      %I%
*
*
* Date released    : %E%  (YY/MM/DD)
*
* SCCS-Source-Pool : %P%
* Date retrieved   : %D% (YY/MM/DD)
-----------------------------------------------------------------------------
*
* This Prolog module is part of the ConceptBase system which is a run-time
* system for the System Modelling Language (SML).
* The module stopCB provides the procedures to leave ConceptBase in a
* consistent way.
*
* Exported predicates:
* --------------------
*
*   + getoutofConceptBase/0
*      Prepares termination of ConceptBase.
*
* 30-May-1990/MJf: Server disconnects itself from the set of available tools
* before terminating.
*
*/

:- module('stopCBserver',[
'getoutofConceptBase'/0
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').


:- use_module('GeneralUtilities.swi.pl').
:- use_module('CBserverInterface.swi.pl').

:- use_module('ModelConfiguration.swi.pl').
:- use_module('BIM2C.swi.pl').
:- use_module('ECAutilities.swi.pl').

:- use_module('Literals.swi.pl').


:- style_check(-singleton).



/* =================== */
/* Exported predicates */
/* =================== */


/* ************ g e t o u t o f C o n c e p t B a s e *********** */
/*                                                                */
/* getoutofConceptBase                                            */
/*                                                                */
/* ************************************************************** */

getoutofConceptBase :-
  printCacheStatistics('stopCBserver'),
  'ClearECArules',
  thisToolId(_tid),
  handle_message(ipcmessage(_tid,_,'CANCEL_ME',[]),ipcanswer(_,_ok,_rt)),
  done_bim2c,
  'ClearAndClean',
  sayGoodbye.            /* termination done in IpcChannel! */



/* ********************** s a y G o o b y e ********************* */
/*                                                                */
/* sayGoodBye                                                     */
/*                                                                */
/* Print out a "goodbye" message from ConceptBase on the users    */
/* terminal.                                                      */
/*                                                                */
/* ************************************************************** */

sayGoodbye :-
  'WriteListOnTrace'(minimal,['>>> Goodbye from ConceptBase.cc (CBserver)   ...            ..             .']),
  'WriteListOnTrace'(minimal,['----------------------------------------------------------------------------']),
  'WriteListOnTrace'(minimal,[' ']),
  !.



