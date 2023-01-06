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
Matthias Jarke, RWTH Aachen, Informatik 5, Ahornstr. 55, 52056 Aachen, Germany
Christoph Quix, RWTH Aachen, Informatik 5, Ahornstr. 55, 52056 Aachen, Germany


This license is a FreeBSD-style copyright license.
Legal home of the FreeBSD copyright license: http://www.freebsd.org/copyright/freebsd-license.html
**/
/*
*
* File:         %M%
* Version:      %I%
* Creation:     6-Dec-93, Kai v. Thadden (RWTH)
* Last Change   : %E%, Christoph Quix (RWTH)
*
* SCCS-Source-Pool : %P%
* Date retrieved : %D% (YY/MM/DD)
*
*------------------------------------------------------------
*
*/

:- module('MSFOLpreProcessor',[
'preProcess'/3
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').

:- use_module('tokens_dcg.swi.pl').
:- use_module('VarTabHandling.swi.pl').
:- use_module('PrologCompatibility.swi.pl').




/*===========================================================*/
/*=              LOCAL PREDICATE DECLARATION                =*/
/*===========================================================*/




:- style_check(-singleton).




/*===========================================================*/
/*=             EXPORTED PREDICATES DEFINITION              =*/
/*===========================================================*/




preProcess('QS'(_,_vars,_),_textA,_tokens) :-
	!,
	initializeVarTab(_vars),
	preProcess(constraint,_textA,_tokens).

preProcess(_mode,_textA,_tokens) :-
	(_mode == rule; _mode == constraint),
	removeAssDelimiters(_textA,_text2A),
	!,
	pc_atomtolist(_text2A,_textCs),
	buildTokens(_tokens,_textCs,[]).


/*===========================================================*/
/*=                LOCAL PREDICATES DEFINITION              =*/
/*===========================================================*/

/*************************************************************/
/** removeAssDelimiters ( _assertionString , _result )      **/
/**                                                         **/
/** _assertionString : ground :  list of char               **/
/**                   _result : free                        **/
/**                                                         **/
/** _result is _assertionString without surrounding '$'     **/
/** chars which originally indicated _assertionString as an **/
/** assertion string                                        **/
/*************************************************************/



removeAssDelimiters(_dollar_assertion,_assertion) :-

	pc_atomconcat('$',_help1,_dollar_assertion),
	!,
	pc_atomconcat(_assertion,'$',_help1).

/** Default: do nothing **/
removeAssDelimiters(_,_).





initializeVarTab([]).

initializeVarTab([(_n,_c)|_vts]) :-
	saveVarTabInsert([_n],_c),
	initializeVarTab(_vts).
