/**
The ConceptBase.cc Copyright

Copyright 1987-2021 The ConceptBase Team. All rights reserved.

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
* File:        %M%
* Version:     %I%
*
*
* Date released : %E%  (YY/MM/DD)
*
* SCCS-Source-Pool : %P%
* Date retrieved : %D% (YY/MM/DD)
***************************************************************************
*
* This module defines a simple programming interface for the CBserver.
* It can be used by experienced ConceptBase users to extend the
* capabilities of the CBserver by LPI plug-ins (see user manual).
*
*
*/



:- module('cbserver',[
'concat'/2
,'ask'/3
,'ask'/1
,'askAll'/3
,'tellFrames'/1
,'makeName'/2
,'makeId'/2
,'toId'/2
,'arg2val'/2
,'val2arg'/2
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').


:- use_module('ObjectProcessor.swi.pl').
:- use_module('GeneralUtilities.swi.pl').


:- use_module('ExternalCodeLoader.swi.pl').

:- use_module('PrologCompatibility.swi.pl').

:- use_module('MetaUtilities.swi.pl').
:- use_module('Literals.swi.pl').
:- use_module('TellAndAsk.swi.pl').








:- use_module('FragmentToPropositions.swi.pl').


:- style_check(-singleton).





/* =================== */
/* Exported predicates */
/* =================== */

/**
  -------------
  concat(_x,_y)
  -------------

  Concatenate the strings in the input list _x and produce a single string _y.
  Example: 
    concat([a,bc,d],_y)
    ==> _y = abcd
**/

concat(_x,_y) :- pc_atomconcat(_x,_y).


/** 
  -----------------------
  ask(_q,_params,_answer)
  -----------------------

  Ask the query _q with parameters _params. Result will be in _answer.
  Example:
    ask('PLUS',[1/r1,2.5/r2],_answer)
    ==> _answer=3.5
**/

ask(_q,_params,_answer) :-
  createBuffer(_ret),  /** allocate some memory for the query answer **/
  !,
  params2Substitution(_params,_substlist),    /** convert parameters to their internal data structure **/
  makeName(_q,_qname),                        /** convert query id to query name, if necessary **/
  ask_objproc(ask([derive(_qname,_substlist)],'FRAME'),_ret),   /** ask the query **/
  getStringFromBuffer(_answer,_ret),                            /** retrieve the answer from the buffer **/
  disposeBuffer(_ret),      /** free the memory pointed to by _ret **/
  !.

ask(_q,_params,'no') :-
  write('>>> cbserver:ask '),write(_q),write(_params),write(' failed'),nl,
  !.




/** 
  ----------
  ask(_lits)
  ----------

  Evaluate the list _lits of literals against the current database.
  Example:
    ask([In(produceMailText, 'QueryClass'), A(_x, forQuery, produceMailText)])
  will bind the variable _x to possible fillers. We currently only support
  a subset of literals (see compileLit/2 below).
**/


ask(_lits) :-
  compileLits(_lits,_executablelits),
  !,
  prove_literals(_executablelits).



/**
  ---------------------
  askAll(_x,_lits,_set)
  ---------------------

  ask for all solution to variable _x for which ask(_lits) is true and return them as a set
  without duplicates.
**/

askAll(_x,_lits,_set) :-
  findall(_x,ask(_lits),_bag),
  makeset(_bag,_set).



/**
  ----------
  tellFrames(_frames)
  ----------

  Try to tell the frames in the Prolog string _frames. If successful, the tell operation
  succeeds, otherwise it fails.

**/

tellFrames(_frames) :-
  makeAtom(_frames,_aframes),
  pc_stringtoatom(_framepointer,_aframes),
  'TELL'(_framepointer,_completion),
  !,
  checkUpdate(_err),
  _completion == 'noerror',
  _err == 'noerror',
  !.



/**
makeName replaces object identifiers by object names
**/

makeName(_x,_xname) :-
  is_id(_x),
  id2name(_x,_xname),
  !.
makeName(_x,_x).



/** 
makeId replaces object names by object identifiers; deals with variables as well
**/

makeId(_x,_x) :- var(_x),!.
makeId(_x,_x) :- is_id(_x),!.

makeId(_x,_xid) :-
  atom(_x),
  name2id(_x,_xid).

makeId(_x,_x).


/**
toId demands that the first argument is bound, either it is already an 
identifier, or it is converted to an identifier via name2id
**/

toId(_q,_q) :- is_id(_q),!.

toId(_q,_qid) :-
  atom(_q),
  name2id(_q,_qid).



/** 
arg2val converts an object identifier or functional expression to a Prolog value (number, string), 
if possible
**/

arg2val(_arg,_num) :-
  evalFunctionArg(_arg,_r1id),
  ground(_r1id),
  id2name(_r1id,_r1atom),
  pc_atom_to_term(_r1atom,_num),
  !.


/** 
val2arg converts a Prolog value to an object identifier; possibly by 
creating the object for this value
**/

val2arg(_num,_arg) :-
  pc_atom_to_term(_resatom,_num),
  determineValClass(_num,_class),
  create_if_builtin_object(_resatom,_class,_arg),
  !.





/* ================== */
/* Private predicates */
/* ================== */

determineValClass(_num,'Integer') :-
  integer(_num),
  !.

determineValClass(_num,'Real') :-
  float(_num),
  !.

determineValClass(_s,'String') :-
  quotedAtom(_s),
  !.




params2Substitution([],[]) :- !.

params2Substitution([_x/_c|_rest],[substitute(_xname,_cname)|_restsubst]) :-
  makeName(_x,_xname),
  makeName(_c,_cname),
  params2Substitution(_rest,_restsubst).


/** compileLits replaces object names in input literals by object identifiers. **/

compileLits([],[]) :- !.

compileLits([_lit|_rest],[_executable|_restexec]) :-
  compileLit(_lit,_executable),
  compileLits(_rest,_restexec).


compileLit('In'(_x,_c),'In'(_xid,_cid)) :-
  makeId(_x,_xid),
  makeId(_c,_cid),
  !.

compileLit('Isa'(_c,_d),'In'(_cid,_did)) :-
  makeId(_c,_cid),
  makeId(_d,_did),
  !.

compileLit('A'(_x,_m,_y),'A'(_xid,_m,_yid)) :-
  makeId(_x,_xid),
  makeId(_y,_yid),
  !.

compileLit('AL'(_x,_m,_n,_y),'A_label'(_xid,_m,_yid,_n)) :-
  makeId(_x,_xid),
  makeId(_y,_yid),
  !.

compileLit('Adot_label'(_cat,_x,_y,_l),'Adot_label'(_catid,_x,_y,_l)) :-
  makeId(_cat,_catid),
  makeId(_x,_xid),
  makeId(_y,_yid),
  !.

compileLit(_lit,_) :-
  write('>>> cbserver:ask failed to compile '), write(_lit),nl,
  !,
  fail.








