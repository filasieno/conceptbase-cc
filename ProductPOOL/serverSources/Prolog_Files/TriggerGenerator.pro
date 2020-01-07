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
* File :        TriggerGenerator.pro
* Version :     7.2
* Creation:     Martin Staudt (UPA)
* Last change : 12 Jul 1995, Lutz Bauer (RWTH)
* Release:      7
* ----------------------------------------------------------------------------
*
* Exported predicates:
* --------------------
*
* 21-Jan-1993/DG: AttrValue is changed into A and InstanceOf into In by deleting the
* time component (see CBNEWS[154])
*
* 1-Sep-93/Tl: retrieve_proposition calls with constant objects at Src or Dst entry
* are changed into a name2id(...,_id),retr_prop(..,_id,..) combination. The old
* construction didn't work with an extern retrieve_proposition
*
* 30-May-2006/M.Jeusfeld: This module is obsolete and no longer used in ConceptBase
*
*
}

#MODULE(TriggerGenerator)
#EXPORT(check_QueryTriggers/0)
#ENDMODDECL()

#IMPORT(retrieve_proposition/1,PropositionProcessor)
#IMPORT(get_PROLOGrule/2,PROLOGruleProcessor)
#IMPORT(retrieve_temp_ins/1,PropositionProcessor)
#IMPORT(invalidate/1,QAmanager)

#IF(SWI)
:- style_check(-singleton).
#ENDIF(SWI)




{ =================== }
{ Exported predicates }
{ =================== }

{ ******************** c h e c k _ Q u e r y T r i g g e r s **************** }
{                                                                             }
{ *************************************************************************** }



check_QueryTriggers :-
	retrieve_temp_ins(P(_id,_s,_l,_d)),		{ 12-Jul-1995 LWEB }
	check_triggers(P(_id,_s,_l,_d)).

check_QueryTriggers.

check_triggers(P(_id,_s,'*instanceof',_d)) :-
	check(_d).

check_triggers(P(_id,_s,'*instanceof',_d)) :-
	check(_s,_d).

check_triggers(P(_id,_s,'*instanceof',_d)) :-
	retrieve_proposition(P(_,_d,'*isa',_d2)),
	check(_d2).

check(_id) :-
	get_PROLOGrule(Trigger(_q,_id),true),
	invalidate(_q),
	check(_q).

check(_s,_id) :-
	get_PROLOGrule(Trigger(_q,s(_id,_o)),true),
	retrieve_proposition(P(_s,_o,_,_)),
	invalidate(_q),
	check(_q).













