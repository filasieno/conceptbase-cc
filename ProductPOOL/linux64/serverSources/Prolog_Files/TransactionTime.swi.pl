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
* File:         %M%
* Version:      %I%
* Creation:     28-Feb-1989, Thomas Wenig (UPA)
* Last Change:  03-Jan-1996, Lutz Bauer (RWTH)
* Date released : %E%  (YY/MM/DD)
*
* SCCS-Source-Pool : %P%
* Date retrieved : %D% (YY/MM/DD)
* ----------------------------------------------------------
*
* This Prolog module is part of the ConceptBase system which is a
* run-time system for the System Modelling Language (SML).
* This representation module serves predicates for the use of transaction-time
*
*
* 16-02-1990 MSt : former set_transaction_time/1 renamed to
*                  set_RollBack_time/1
*                  former set/get/remove_systime renamed to
*                  *_transaction_time
*
* 03-Jan-1996 LWEB: occasionally, the belieftime for set_RollBack_time(_belieftime) is
* atom and not term. In such cases, a conversion is committed.
*
* Exported predicates:
* --------------------
*
*   + set_transaction_time/0
*      Stores actual systemtime as a fact.
*   + get_transaction_time/1
*      Retreives the stored systemtime.
*   + remove_transaction_time/0
*      Deletes the stored systemtime.
*   + set_RollBack_time/1
*      Stores the Rollbacktime of a question as a fact.
*   + get_RollBack_time/1
*      Retrieves the stored Rollbacktime.
*   + correct_belieftime/1
*      Succeeds, if arg is within the stored transactiontime.
*   + correct_belieftime/2
*      Succeeds, if arg1 is within the transactiontime arg2.
*
*
*/

/*:- setdebug.*/

:- module('TransactionTime',[
'correct_belieftime'/1
,'get_RollBack_time'/1
,'get_transaction_time'/1
,'remove_transaction_time'/0
,'set_RollBack_time'/1
,'set_transaction_time'/0
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').


:- use_module('Calendar.swi.pl').


:- use_module('BIM2C.swi.pl').

:- use_module('PrologCompatibility.swi.pl').


:- use_module('GeneralUtilities.swi.pl').



:- dynamic 'belief@time'/1 .
:- dynamic 'sys@time'/1 .


:- style_check(-singleton).




/* =================== */
/* Exported predicates */
/* =================== */

/* **************** s e t _ t r a n s a c t i o n _ t i m e ******* */
/*                                                                  */
/* set_transaction_time                                             */
/*                                                                  */
/* set_transaction_time gets the actual systemtime and stores it    */
/*                                                                  */
/* **************************************************************** */


set_transaction_time :-
  ctime(_actualtime1),
  uniqueActualTime(_actualtime1,_actualtime),
  _actualtime = millisecond(_y,_mo,_d,_h,_mi,_s,_us),
  set_time_point_bim2c(_us,_s,_mi,_h,_d,_mo,_y),
  set_search_point_bim2c(_us,_s,_mi,_h,_d,_mo,_y),
  pc_update('sys@time'(_actualtime)),!.


/** make sure that two subsequent transactions get different transaction times **/
uniqueActualTime(_t1,_t) :-
  'sys@time'(_t1),  /** the previous actual time is the same **/
  _t1 = millisecond(_y,_mo,_d,_h,_mi,_s,_ms),
  _ms1 is _ms + 1,
  _t = millisecond(_y,_mo,_d,_h,_mi,_s,_ms1),
  !.
uniqueActualTime(_t,_t).


/* **************** g e t _ t r a n s a c t i o n _ t i m e ******* */
/*                                                                  */
/* get_transaction_time(_actualtime)                                */
/*                                                                  */
/* get_transaction_time gets the actual stored systemtime stored by */
/* set_transaction_time                                             */
/*                                                                  */
/* **************************************************************** */

get_transaction_time(_actualtime) :-
  'sys@time'(_actualtime),
  !.

/** make sure that get_transaction_time does not fail **/
get_transaction_time(_actualtime) :-
  set_transaction_time,
  'sys@time'(_actualtime),
  !.

/* ********* r e m o v e  _ t r a n s a c t i o n _ t i m e ******* */
/*                                                                  */
/* remove_transaction_time                                          */
/*                                                                  */
/* remove_transaction_time deletes the actual stored systemtime     */
/* set_transaction_time                                             */
/*                                                                  */
/* **************************************************************** */

remove_transaction_time :-
    retract('sys@time'(_actualtime)),!.

remove_transaction_time.


/* **************** s e t _ R o l l B a c k _ t i m e ************* */
/*                                                                  */
/* set_RollBack_time(_belieftime)                                   */
/*    _belieftime: term                                             */
/* stores arg as Rollback-time                                      */
/*                                                   16-02-90 MSt   */
/* **************************************************************** */

/** allow using the starttime of objects as rollback time; issue #16 **/
set_RollBack_time(_objname) :-
  atom(_objname),
  _objname \= 'Now',
  _objname \= 'Always',
  name2id(_objname,_id),
  id2starttime(_id,_tt),
  _tt = tt(millisecond(_y,_mo,_d,_h,_mi,_s,_us)),
  do_set_RollBack_time(millisecond(_y,_mo,_d,_h,_mi,_s,_us)),
  !.

set_RollBack_time(_belieftime) :-
  do_set_RollBack_time(_belieftime).


do_set_RollBack_time(_belieftime) :-
 atom(_belieftime),
 (((_belieftime = 'Now'; _belieftime = 'Always'),_term = _belieftime);
  ( _belieftime \= 'Now', _belieftime \= 'Always',pc_atom_to_term(_belieftime,_term))),
 startPoint(_term,_bt),
 _bt = millisecond(_y,_mo,_d,_h,_mi,_s,_us),
 set_search_point_bim2c(_us,_s,_mi,_h,_d,_mo,_y),	/* ??-??-1995 TL */
 fail.

do_set_RollBack_time(_belieftime) :-
  compound(_belieftime),
  startPoint(_belieftime,_bt), 		/* convert timepoint into millisecond format */
  _bt = millisecond(_y,_mo,_d,_h,_mi,_s,_us),
  set_search_point_bim2c(_us,_s,_mi,_h,_d,_mo,_y),	/* ??-??-1995 TL */
  fail.

do_set_RollBack_time(_belieftime) :-
 atom(_belieftime),
 (((_belieftime = 'Now'; _belieftime = 'Always'),_term = _belieftime);
  ( _belieftime \= 'Now', _belieftime \= 'Always',pc_atom_to_term(_belieftime,_term))),
 retract('belief@time'(_x)),
 assert('belief@time'(_term)),!.

do_set_RollBack_time(_belieftime) :-
 retract('belief@time'(_x)),
 assert('belief@time'(_belieftime)),!.

do_set_RollBack_time(_belieftime) :-
 atom(_belieftime),
 (((_belieftime = 'Now'; _belieftime = 'Always'),_term = _belieftime);
  ( _belieftime \= 'Now', _belieftime \= 'Always',pc_atom_to_term(_belieftime,_term))),
 assert('belief@time'(_term)),!.

do_set_RollBack_time(_belieftime) :-
 assert('belief@time'(_belieftime)),!.



/* ************ g e t _ R o l l B a c k _ t i m e ***************** */
/*                                                                  */
/* get_RollBack_time(_belieftime)                                   */
/*    _belieftime: term                                             */
/*                                                                  */
/* get the Rollback-time  stored by set_RollBack_time               */
/*                                                                  */
/* **************************************************************** */

get_RollBack_time(_belieftime) :-
 'belief@time'(_belieftime).

/* *********** C O R R E C T _ B E L I E F T I M E **************** */
/*                                                                  */
/*  correct_belieftime(_tt)                                         */
/*      _tt: term                                                   */
/*                                                                  */
/* correct_believetime proofs, wether the believetime arg includes  */
/* the rollback-time, which is called by get_RollBack_time          */
/*                                                                  */
/* **************************************************************** */

/*AM891*/

correct_belieftime(ttlist([_tt|_rest])) :-
  (correct_belieftime(_tt);
   correct_belieftime(ttlist(_rest))),
  !.

correct_belieftime('FromNowOn') :- !.
correct_belieftime('Always') :- !.


correct_belieftime(_tt) :-
  _tt \= ttlist(_),
  get_RollBack_time(_rbt),
  time_relation(_tt,_rbt,tp(_a,_,_,_b)),
  (_a='s'; _a='p'),      /*start(tt) same or precedes start(rbt) */
  (_b='s'; _b='f'),      /*end(tt) same or follows end(rbt)      */
  !.


/* *********** C O R R E C T _ B E L I E F T I M E **************** */
/*                                                                  */
/*  correct_belieftime(_tt,_bt)                                     */
/*      _tt: term                                                   */
/*      _bt: term                                                   */
/*                                                                  */
/* if the belieftime is an actual one, it has the represantation    */
/* tt(millisecond(_y,_m,_d,_h,_mi,_s,_u), other wise it looks like  */
/* tt(millisecond(_y1,_m1,_d1,_h1,_mi1,_s1,_u1),                    */
/*    millisecond(_y1,_m1,_d1,_h1,_mi1,_s1,_u1)                     */
/* correct_believetime proofs, wether the believetime arg includes  */
/* the rollback-time                                                */
/*                                                                  */
/* **************************************************************** */

/*AM891*/

correct_belieftime(_rbt,_tt) :-
    var(_rbt),
    _rbt = _tt, !.


correct_belieftime(_rbt,ttlist([_tt|_rest])) :-
  (correct_belieftime(_rbt,_tt);
   correct_belieftime(_rbt,ttlist(_rest))),
  !.

correct_belieftime(_rbt,_tt) :-
  (_tt == 'FromNowOn'; _tt == 'Always'),!.

correct_belieftime(_rbt,tt(_t)) :-
   _rbt == 'Now',!.




correct_belieftime(_rbt,_tt) :-
  time_relation(_tt,_rbt,tp(_a,_,_,_b)),
  (_a='s'; _a='p'),      /*start(tt) same or precedes start(rbt) */
  (_b='s'; _b='f'),      /*end(tt) same or follows end(rbt)      */
  !.

