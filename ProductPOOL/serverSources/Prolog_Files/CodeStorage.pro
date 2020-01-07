{*
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
*}
{
*
*
* File:         CodeStorage.pro
* Version:      11.2
* Creation:     28-Mar-94, Kai v. Thadden (RWTH)
* Last Change   : 96/10/11, Christoph Quix (RWTH)
*
* SCCS-Source-Pool : /home/CBase/CB_NewStruct/ProductPOOL/SCCS/serverSources/Prolog_Files/s.CodeStorage.pro
* Date retrieved : 97/07/02 (YY/MM/DD)
*
*------------------------------------------------------------
* This module handles the code created from a rule. I'm sure that this module won't be needed in the long run. At the moment it is just mean't as a black box where I stuff in all the code created from DATALOG-rules.
*
}
#MODULE(CodeStorage)
#EXPORT(handleCode/3)
#ENDMODDECL()

{===========================================================}
{=                  IMPORTED PREDICATES                    =}
{===========================================================}
#IMPORT(store_tmp_PROLOGrules/1,PROLOGruleProcessor)
#IMPORT(store_PROLOGrules/1,PROLOGruleProcessor)
#IMPORT(get_transaction_time/1,TransactionTime)
#IMPORT(append/3,GeneralUtilities)
#IMPORT(rewrite_term/2,GeneralUtilities)
#IMPORT(retellflag/1,TellAndAsk)
#IMPORT(isAux/1,RuleBase)
#IMPORT(tmpQueryRule/1,QueryCompiler)
#IMPORT(tmpQueryRule_ins/1,QueryCompiler)
#IMPORT(tmpQueryRule_del/1,QueryCompiler)

{===========================================================}
{=              LOCAL PREDICATE DECLARATION                =}
{===========================================================}
#LOCAL(insertTTinfo/3)


#IF(SWI)
:- style_check(-singleton).
#ENDIF(SWI)


{===========================================================}
{=             EXPORTED PREDICATES DEFINITION              =}
{===========================================================}
#IF(TODO)
:- module_transparent handleCode/3 .
#ENDIF(TODO)

handleCode(rule, _id, _clausePLs) :-
	!,
	insertTTinfo(_clausePLs, _id, _nclausePLs),
	store_tmp_PROLOGrules(_nclausePLs).

handleCode(query, _id, _clausePLs) :-
	!,
	insertLTevalQuery(_clausePLs,_id,_clause2PLs),
	store_tmp_QueryRules(_clause2PLs).

handleCode(mquery, _id, _clauseMLs) :-
	!,
	store_tmp_MRules(_clauseMLs).

handleCode(vmrule,_id,_vmrules) :-
	!,
	store_tmp_VMRules(_id,_vmrules).

{===========================================================}
{=                LOCAL PREDICATES DEFINITION              =}
{===========================================================}



{* Schreibt die erste Klausel in ein LTevalRule(_id,_head) um.
*}
#IF(TODO)
:- module_transparent insertTTinfo/3 .
#ENDIF(TODO)

insertTTinfo(_ruleList,_ident,_newRuleList) :-
	get_transaction_time(_ttime),
	insertTTinfo1(_ruleList,_ident,_ttime,_newRuleList1),
	_newRuleList = [RuleTTime(_ident,tt(_ttime))|_newRuleList1].

#IF(TODO)
:- module_transparent insertTTinfo1/4 .
#ENDIF(TODO)

insertTTinfo1([],_,_,[]).


{* 14-Nov-2007/M. Jeusfeld: also support Adot_label for deductive rules; see ticket #164 *}

#IF(BIM)
insertTTinfo1([(Adot(_cc,_x,_y) :- _body)|_rests],_ident,_ttime,
		[(LTevalRule(_cc,Adot(_cc,_x,_y)) :- (RBTimeRelevantRule$LTstubs(_ident),_body))|_nrests]) :-
	!,insertTTinfo1(_rests,_ident,_ttime,_nrests).

insertTTinfo1([(Adot_label(_cc,_x,_y,_n) :- _body)|_rests],_ident,_ttime,
                [(LTevalRule(_cc,Adot_label(_cc,_x,_y,_n)) :- (RBTimeRelevantRule$LTstubs(_ident),_body))|_nrests]) :-
        !,insertTTinfo1(_rests,_ident,_ttime,_nrests).

insertTTinfo1([(In(_x,_y) :- _body)|_rests],_ident,_ttime,
		[(LTevalRule(_y,In(_x,_y)) :- (RBTimeRelevantRule$LTstubs(_ident),_body))|_nrests]) :-
	ground(_y),
	!,insertTTinfo1(_rests,_ident,_ttime,_nrests).
#ELSE()
insertTTinfo1([(Adot(_cc,_x,_y) :- _body)|_rests],_ident,_ttime,
		[(LTevalRule(_cc,Adot(_cc,_x,_y)) :- ('LTstubs':'RBTimeRelevantRule'(_ident),_body))|_nrests]) :-
	!,insertTTinfo1(_rests,_ident,_ttime,_nrests).

insertTTinfo1([(Adot_label(_cc,_x,_y,_n) :- _body)|_rests],_ident,_ttime,
                [(LTevalRule(_cc,Adot_label(_cc,_x,_y,_n)) :- ('LTstubs':'RBTimeRelevantRule'(_ident),_body))|_nrests]) :-
        !,insertTTinfo1(_rests,_ident,_ttime,_nrests).

insertTTinfo1([(In(_x,_y) :- _body)|_rests],_ident,_ttime,
		[(LTevalRule(_y,In(_x,_y)) :- ('LTstubs':'RBTimeRelevantRule'(_ident),_body))|_nrests]) :-
	ground(_y),
	!,insertTTinfo1(_rests,_ident,_ttime,_nrests).
#ENDIF(BIM)


insertTTinfo1([(_oldHead :- _body)|_rests], _ident,_ttime, [(_oldHead :- _body)|_nrests]) :-
	!,insertTTinfo1(_rests,_ident,_ttime,_nrests).

#IF(TODO)
:- module_transparent insertLTevalQuery/3 .
#ENDIF(TODO)

{* Schreibt um bestimmte Klauseln ein LTevalQuery *}
insertLTevalQuery([],_,[]).
insertLTevalQuery([(_oldHead :- _body)|_rests],_ident, [(_oldHead :- _body)|_newRests]) :-
	isAux(_oldHead),
	!,
	insertLTevalQuery(_rests,_ident,_newRests).
insertLTevalQuery([(_oldHead :- _body)|_rests],_ident, [(_oldHead :- _body)|_newRests]) :-
	_oldHead = LTevalQuery(_,_),
	!,
	insertLTevalQuery(_rests,_ident,_newRests).

insertLTevalQuery([(_oldHead :- _body)|_rests],_, [(LTevalQuery(_ident,_oldHead) :- _body)|_newRests]) :-
	_oldHead =..[_ident|_],
	_ident \== 'In',
	insertLTevalQuery(_rests,_,_newRests).

insertLTevalQuery([(_oldHead :- _body)|_rests],_, [(LTevalQuery(_ident,_oldHead) :- _body)|_newRests]) :-
	_oldHead = In(_,_ident),
	insertLTevalQuery(_rests,_,_newRests).


{ ******************** s t o r e _ t m p _ M R u l e s ******************** }
{                                                                           }
{ ************************************************************************* }
#IF(TODO)
:- module_transparent store_tmp_VMRules/1 .
:- module_transparent store_tmp_QueryRules/1 .
#ENDIF(TODO)

store_tmp_VMRules(_,[]).
store_tmp_VMRules(_id,[_r|_rs]) :-
	store_tmp_PROLOGrules([vmrule(_id,_r)]),
	store_tmp_VMRules(_id,_rs).

store_tmp_QueryRules([]) :- !.

store_tmp_QueryRules([_first|_rlist]) :-
	(
	(retellflag(untell),assert(tmpQueryRule_del(_first)));
	(retellflag(tell),assert(tmpQueryRule_ins(_first)));
	assert(tmpQueryRule(_first))
	),
	store_PROLOGrules([_first]),
	store_tmp_QueryRules(_rlist).

