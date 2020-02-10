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
* File:        Calendar.pro
* Version:     4.2
* Creation:    5-Apr-1988, Thomas Wenig, Reinhard Muehlbauer (UPA)
* Last change: 11/30/92, Manfred Jeusfeld (RWTH)
* Release:     4
* ----------------------------------------------------------
*
* Calendar is used for the implementation of a time calculus and
* declares the predicate'time_relation',
* which computes the relationship between two predefined intervals.
*
* Exported predicate:
* --------------------
*
*   + time_relation/3
*       Retrieves in arg3 the relation between the predefined intervals
*       described by arg1 and arg2.
*   + isYear/1,isMonth/1,isDay/1,isHour/1,isMinute/1,isSecond/1,isMilliSecond/1,
*     isClosedTimelineInterval/1,isRightOpenTimelineInterval/1,
*     isLeftOpenTimelineInterval/1
*       Succeed if arg1 belongs to the  the corresponding time interval class
*   + time_consistency/1
*       Arg1 is a correct predefined time interval.
*   + ctime/1
*       Arg1 is the actual system time retrieved by the C-function
*       'sysclock'
*
*
* 3-Jul-1990/MJf: Three new kinds of predefined time intervals introduced:
* ClosedTimelineInterval,RightOpenTimelineInterval,LeftOpenTimelineInterval.
* Predicates isYear,...,isLeftOpenTimelineInterval classify predefined
* time intervals.
*
*/

:- module('Calendar',[
'ctime'/1
,'startPoint'/2
,'time_relation'/3
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').

:- use_module('prologToUnixSUN4.swi.pl').
:- use_module('TransactionTime.swi.pl').


:- style_check(-singleton).



/* =================== */
/* Exported predicates */
/* =================== */



/**************************** T I M E _ R E L A T I O N *************************/
/*                                                                              */
/* time_relation(_time1,_time2,_rel)                                            */
/*     _time1: ground :term                                                     */
/*     _time2: ground: term                                                     */
/*     _rel  : term   (timepoint-representation)                                */
/*                                                                              */
/* Retrieves the relationship (arg3) between two predefined intervals           */
/* described by arg1 and arg2.                                                  */
/*                                                                              */
/* 3-Jul1990/MJf: drastic reimplementation; time relation now computes the      */
/* start and end points of time1 and time2 and then compares them to get the    */
/* relationship for the time point algebra (see also tp_Algebra).               */
/*                                                            29-Jun-1990/MJf   */
/********************************************************************************/

time_relation(_t1,_t2,tp(_bb,_be,_eb,_ee)) :-
  startPoint(_t1,_t1b),
  endPoint(_t1,_t1e),
  startPoint(_t2,_t2b),
  endPoint(_t2,_t2e),
  compareTimepoints(_t1b,_t2b,_bb),
  compareTimepoints(_t1b,_t2e,_be),
  compareTimepoints(_t1e,_t2b,_eb),
  compareTimepoints(_t1e,_t2e,_ee),
  !.



/* ************************** S T A R T P O I N T *************************** */
/*                                                            29-Jun-1990/MJf */
/* startPoint(_t,_pt)                                                         */
/*   _t: ground (i)                                                           */
/*   _pt: any: ground                                                         */
/*                                                                            */
/* StartPoint computes the starting time point of predefined time interval _t.*/
/* We take the unit of milliseconds to represent time points though it may    */
/* turn out to be insufficiently small for some applications.                 */
/* For left or right open time intervals there are the two additional time    */
/* points '-infinite' and '+infinite'.                                        */
/*                                                                            */
/* ************************************************************************** */

startPoint(year(_y),millisecond(_y,1,1,0,0,0,0)).

startPoint(month(_y,_m),millisecond(_y,_m,1,0,0,0,0)).

startPoint(day(_y,_m,_d),millisecond(_y,_m,_d,0,0,0,0)).

startPoint(hour(_y,_m,_d,_h),millisecond(_y,_m,_d,_h,0,0,0)).

startPoint(minute(_y,_m,_d,_h,_mi),millisecond(_y,_m,_d,_h,_mi,0,0)).

startPoint(second(_y,_m,_d,_h,_mi,_s),millisecond(_y,_m,_d,_h,_mi,_s,0)).

startPoint(millisecond(_y,_m,_d,_h,_mi,_s,_ms),
           millisecond(_y,_m,_d,_h,_mi,_s,_ms)).


startPoint('Always','-infinite').

startPoint(ltt(_t),'-infinite').

startPoint(tt(_t),_pt) :- startPoint(_t,_pt).

startPoint(tt(_t1,_t2),_pt) :- startPoint(_t1,_pt).

startPoint('Now',_pt) :- get_transaction_time(_c),!,startPoint(_c,_pt). /* 14.2.96/TL */

startPoint('Now',_pt) :- currenttime(_c),startPoint(_c,_pt).


/* **************************** E N D P O I N T ***************************** */
/*                                                            29-Jun-1990/MJf */
/* endPoint(_t,_pt)                                                           */
/*   _t: ground (i)                                                           */
/*   _pt: any: ground                                                         */
/*                                                                            */
/* StartPoint computes the ending time point of predefined time interval _t.  */
/*                                                                            */
/* ************************************************************************** */

endPoint(year(_y),millisecond(_y,12,31,11,59,59,999)).

endPoint(month(_y,_m),millisecond(_y,_m,_ld,11,59,59,999)) :-
  lastday(_y,_m,_ld).

endPoint(day(_y,_m,_d),millisecond(_y,_m,_d,11,59,59,999)).

endPoint(hour(_y,_m,_d,_h),millisecond(_y,_m,_d,_h,59,59,999)).

endPoint(minute(_y,_m,_d,_h,_mi),millisecond(_y,_m,_d,_h,_mi,59,999)).

endPoint(second(_y,_m,_d,_h,_mi,_s),millisecond(_y,_m,_d,_h,_mi,_s,999)).

endPoint(millisecond(_y,_m,_d,_h,_mi,_s,_ms),
         millisecond(_y,_m,_d,_h,_mi,_s,_ms)).


endPoint('Always','+infinite').

endPoint(ltt(_t),_pt) :- endPoint(_t,_pt).

endPoint(tt(_t),'+infinite').

endPoint(tt(_t1,_t2),_pt) :- endPoint(_t2,_pt).

endPoint('Now',_pt) :- get_transaction_time(_c),!,endPoint(_c,_pt). /* 14.2.96/TL */

endPoint('Now',_pt) :- currenttime(_c),endPoint(_c,_pt).


/* ******************* C O M P A R E T I M E P O I N T S ******************** */
/*                                                            29-Jun-1990/MJf */
/* compareTimepoints(_pt1,_pt2,_res)                                          */
/*   _pt1,_pt2: ground (i)                                                    */
/*   _res: ground (o)                                                         */
/*                                                                            */
/* The input are two "time points" given by a very small time interval unit,  */
/* e.g. milliseconds. The components are compared until one is smaller or     */
/* bigger than the other:                                                     */
/*                pt1:          y1 m1 d1 h1 mi1 s1 ms1 ...                    */
/*                pt2:          y2 m2 d2 h2 mi2 s2 ms2 ...                    */
/* Possible results are                                                       */
/*                's' -  pt1,pt2 are the same                                 */
/*                'p' -  pt1 precedes pt2                                     */
/*                'f' -  pt1 follows pt2                                      */
/* Other values (see tp_Algebra.pro) are not possible since time points have  */
/* always a deterministic relation.                                           */
/* Two special cases '-infinite', '+infinite' are treated to capture left and */
/* right opened tim intervals.                                                */
/*                                                                            */
/* ************************************************************************** */

compareTimepoints(_pt,_pt,'s') :- !.      /* pt is the same as pt             */

compareTimepoints('-infinite',_t,'p').    /* '-infinite' precedes everything  */
compareTimepoints(_t,'-infinite','f').    /* everything follows '-infinite'   */
compareTimepoints('+infinite',_t,'f').    /* '+infinite' follows everything   */
compareTimepoints(_t,'+infinite','p').    /* everything precedes '+infinite'  */

compareTimepoints(_pt1,_pt2,_r) :-
  _pt1 =.. [_|_list1],              /* first list element is the functor      */
  _pt2 =.. [_|_list2],              /* of the time point, e.g. millisecond    */
  compareArgs(_list1,_list2,_r),
  !.


/* componentwise comparison, significance decreases from left to right: */

compareArgs([],[],'s').                /* ==> pt1,pt2 are the same */

compareArgs([_n|_rest1],[_n|_rest2],_r) :-
  compareArgs(_rest1,_rest2,_r).

compareArgs([_n1|_],[_n2|_],'p') :-    /* ==> pt1 precedes pt2 */
  _n1 < _n2.

compareArgs([_n1|_],[_n2|_],'f') :-    /* ==> pt1 follows pt2  */
  _n1 > _n2.




/* ***************************** L A S T D A Y ****************************** */
/*                                                            29-Jun-1990/MJf */
/* lastday(_y,_m,_dmax)                                                       */
/*   _y,_m: integer (i)                                                       */
/*   _dmax: integer (o)                                                       */
/*                                                                            */
/* Lastday determines _dmax to be the last day of the month _m in year _y.    */
/* Leap years (e.g. 1980) are taken into account for the February month.      */
/*                                                                            */
/* ************************************************************************** */

lastday(_,1,31).
lastday(_y,2,29) :-  leap(_y), !.
lastday(_,2,28).
lastday(_,3,31).
lastday(_,4,30).
lastday(_,5,31).
lastday(_,6,30).
lastday(_,7,31).
lastday(_,8,31).
lastday(_,9,30).
lastday(_,10,31).
lastday(_,11,30).
lastday(_,12,31).



/********************************** L E A P *************************************/
/*                                                                              */
/* leap(_y)                                                                     */
/*    _y : integer                                                              */
/*                                                                              */
/* Succeeds, if _y is a leap-year ("Schaltjahr").                               */
/*                                                                              */
/********************************************************************************/

leap(_y) :-
  0 is (_y mod 4),
  \+(0 is (_y mod 400)).


/*************************** T I M E _ C O N S I S T E N C Y ********************/
/*                                                                              */
/* time_consistency(_predef)                                                    */
/*     _predef : term                                                           */
/*                                                                              */
/* Succeeds, if _predef is correct description of a predefined timeinterval     */
/*                                                                              */
/********************************************************************************/


time_consistency(_t) :-
  (isTimelineUnitInterval(_t);
   isClosedTimelineInterval(_t);
   isRightOpenTimelineInterval(_t);
   isLeftOpenTimelineInterval(_t)),
  !.


isTimelineUnitInterval(_t) :-
  (isYear(_t); isMonth(_t); isDay(_t); isHour(_t);
   isMinute(_t); isSecond(_t); isMilliSecond(_t)),
  !.


isYear(year(_y)) :- integer(_y) .

isMonth(month(_y,_m))  :-
  _m < 13, _m > 0,
  isYear(year(_y)).

isDay(day(_y,_m,_d)) :-
   lastday(_y,_m,_dmax), _d =< _dmax , _d > 0,
   isMonth(month(_y,_m)) .

isHour(hour(_y,_m,_d,_h)) :-
   _h < 24, _h >= 0,
   isDay(day(_y,_m,_d)).

isMinute(minute(_y,_m,_d,_h,_mi)) :-
   _mi < 60, _mi >= 0,
   isHour(hour(_y,_m,_d,_h)).

isSecond(second(_y,_m,_d,_h,_mi,_s)) :-
   _s < 60, _s >= 0,
   isMinute(minute(_y,_m,_d,_h,_mi)).

isMilliSecond(millisecond(_y,_m,_d,_h,_mi,_s,_u)) :-
   _u < 1000, _u >= 0,
   isSecond(second(_y,_m,_d,_h,_mi,_s)).


/** ClosedTimelineIntervals tt(_t1,_t2) begin with the start point of _t1 **/
/** and end with the end point of _t2. Example:                           **/
/**    tt(day(1980,2,13),second(1985,10,17,4,39,59))                      **/
/** =  [13-Feb-1980,17-Oct-1985/4:39:59]                                  **/

isClosedTimelineInterval(tt(_t1,_t2)) :-
  isTimelineUnitInterval(_t1),
  isTimelineUnitInterval(_t2),
  endPoint(_t1,_pt1),
  startPoint(_t2,_pt2),
  compareTimepoints(_pt1,_pt2,'p').   /*end of t1 must precede begin of t2*/


/** Time interval that begins at the same time as _t but never ends **/

isRightOpenTimelineInterval(tt(_t)) :-
  isTimelineUnitInterval(_t).

/** Time interval that ends together with _t but that existed all the time **/
/** before. <Don't say that's impossible, please>                          **/

isLeftOpenTimelineInterval(ltt(_t)) :-
  isTimelineUnitInterval(_t).




/************************* C T I M E ********************************************/
/*                                                                              */
/* gets systime with the help of predicate 'currenttime'                        */
/*                                                                              */
/* **************************************************************************** */

ctime(millisecond(_y,_mo,_d,_h,_mi,_s,_us)) :-
  currenttime(millisecond(_y,_mo,_d,_h,_mi,_s,_us)).




