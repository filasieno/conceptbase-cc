{*
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
*}
{
*
*		DIESE MODUL WIRD IN DER AKTUELLEN VERSION VON CONCEPTBASE
*		NICHT MEHR GELADEN.	 9-Dez-1996 LWEB
*
* File:        %M%
* Version:     %I%
* Creation:    30-Oct-1987, Manfred Jeusfeld (UPA)
* Last Change: %G%, Manfred Jeusfeld (RWTH)
* Release:     %R%
* -----------------------------------------------------------------------------
*
* This Prolog module is part of the ConceptBase system which is a run-time
* system for the System Modelling Language (SML).
* This representation module serves for the temporal storage of
* propositions.
*
* 26-Jul-1988/MJf: Use 'prop@temp'/5 facts for representing propositions
*
* 24.07.1990 RG:	Now storing 'prop@temp'/6 facts.
*			The old propval form is also retrievable for
*			compatibility reasons.
* 24.07.1990 AM:	Bug corrections only.
*
* 17-Jul-1991/MJf: Use a representation similar to fastform2 in Rep_fast.
* This speeeds up translation of a frame by 2-10%.
*
* 30-Nov-1992/MJf: changed propval(id,x,l,y,t) and proposition(id,x,l,y,t,tt) to
* P(id,x,l,y) and hP(id,x,l,y,tt), i.e. the valid time component t is now
* eliminated (details in CBNEWS[147]).
*
*
* Exported predicates:
* --------------------
*
*   + retrieve_temp_proposition/1
*      Retrieve the proposition described by arg1 in the representation 'temp'.
*   + create_temp_proposition/1
*      Create the proposition described by arg1 in the representation 'temp'.
*   + delete_temp_proposition/1
*      Delete the proposition described by arg1 in the representation 'temp'.
*
}

{:- setdebug.}


#MODULE(Rep_temp)
#ENDMODDECL()


#IMPORT(assign_ID/1,validProposition)

#IMPORT(pcall/1,GeneralUtilities)

#IMPORT(get_transaction_time/1,TransactionTime)

#IMPORT(name2id/2,GeneralUtilities)
     	  { 17-Jul-1995 LWEB }
#IMPORT(system_generated/1,validProposition)
    { 17-Jul-1995 LWEB }
#IMPORT(newIdentifier/1,validProposition)
         { 17-Jul-1995 LWEB }
#IMPORT(retrieve_C_proposition/1,BIM2C)

#IMPORT(retrieve_C_proposition_module/1,BIM2C)

#IMPORT(set_overrule_temp_bim2c/0,BIM2C)


#GLOBAL(temporary_attr/2)
		{ 17-Jul-1995 LWEB }
#DYNAMIC(temporary_attr/2)



{ =================== }
{ Exported predicates }
{ =================== }


{ ****** r e t r i e v e _ t e m p _ p r o p o s i t i o n ***** }
{                                                                }
{ retrieve_temp_proposition(_propdescr)                          }
{   _propdescr: partial: ground                                  }
{                                                                }
{ Succeeds if there is a propval with matching ID, object,       }
{ proposition,value and time components in the 'temp'            }
{ representation.                                                }
{                                                26-Jul-1988/MJf }
{								 }
{ Changed from propval/5 to proposition/6.			 }
{						24.07.1990 RG	 }
{ ************************************************************** }
{ !@! 14-03-96 Die Verteilung vom temporaeren Speicher in 2 Teilen fuer Tell und Untell }

{
retrieve_temp_proposition(P(_id,_x,_l,_y)) :-
	retrieve_temp_proposition(hP(_id,_x,_l,_y,_)).

retrieve_temp_proposition(hP(_id,_x,_l,_y,_tt)) :-
	M_SearchSpace( _m ),
	retrieve_temp_proposition(hP(_m,_id,_x,_l,_y,_tt)).

retrieve_temp_proposition(hP(_m,_id,_x,_l,_y,_tt)) :-
	tempform(hP(_m,_id,_x,_l,_y,_tt),_ff2),
 	pcall(_ff2),
	pcall(OP(_id,_op)).
	{write('RETRIEVE>>>'),write(OP(_id,_op)),write('   '),write(_ff2),nl.}

}
retrieve_temp_proposition(P(_id,_x,_l,_y)):-
 	set_overrule_temp_bim2c,
  	retrieve_C_proposition(P(_id,_x,_l,_y)).


retrieve_temp_proposition(hP(_id,_x,_l,_y,_tt)):-
	set_overrule_temp_bim2c,
	retrieve_C_proposition(P(_id,_x,_l,_y)).

retrieve_temp_proposition(hP(_m,_id,_x,_l,_y,_tt)):-
	set_overrule_temp_bim2c,
	retrieve_C_proposition_module(P(_id,_x,_l,_y,_m)).




{ ******** c r e a t e _ t e m p _ p r o p o s i t i o n ******* }
{                                                                }
{ create_temp_proposition( _propdescr)                           }
{   _propdescr: ground                                           }
{                                                                }
{ Store _propdescr as a 'temp' Prolog fact.                      }
{								 }
{ ************************************************************** }

create_temp_proposition(P(_id,_x,_l,_y)):-
	write('create_temp_proposition FEHLER'),nl,!,fail.
{
create_temp_proposition(P(_id,_x,_l,_y)):-
              !,
           write(create_temp(P(_id,_x,_l,_y))),nl,
              create(P(_id,_x,_l,_y)).

create_temp_proposition(hP(_id,_x,_l,_y,_tt)):-
              !,
              write(create_temp(hP(_id,_x,_l,_y,_tt))),nl,
              create(P(_id,_x,_l,_y)).
}
{
create_temp_proposition(P(_id,_x,_l,_y)) :-
	get_transaction_time(_ttime),
	_tt = tt(_ttime),
        	create_temp_proposition(hP(_id,_x,_l,_y,_tt)),
  	!.
}
{
create_temp_proposition(hP(_id,_id,_l,_id,_tt)) :-
	not(call(temporary_attr(_l,_))),
	M_SearchSpace( _m ),
  	assign_ID(P(_id,_x,_l,_y)),
  	tempform(hP(_m,_id,_x,_l,_y,_tt),_ff2),
  	assert(_ff2),
  	!,
	{!@! 14-03-96 Die Verteilung vom temporaeren Speicher in 2 Teilen fuer Tell und Untell }
	CURRENT_OPERATION$Rep_temp(_op),
	assert(OP(_id,_op)),
	{write('CREATE>>>'),write(OP(_id,_op)),write('   '),write(_ff2),nl,}
  	!.
}

{ *********** d e l e t e _ t e m p _ p r o p e r t y ********** }
{                                                                }
{ delete_temp_proposition(_propdescr)                            }
{   _propdescr: partial                                          }
{                                                                }
{ Delete a matching Prolog fact _propdescr.                      }
{								 }
{ ************************************************************** }

delete_temp_proposition(P(_id,_x,_l,_y)) :-
   delete_temp_proposition(hP(_id,_x,_l,_y,_)).

{
delete_temp_proposition(P(_id,_x,_l,_y)) :-
   	delete_temp_proposition(hP(_id,_x,_l,_y,_)).

delete_temp_proposition(hP(_id,_x,_l,_y,_tt)) :-
	M_SearchSpace( _m ),
  	tempform(hP(_m,_id,_x,_l,_y,_tt),_ff2),
  	CURRENT_OPERATION$Rep_temp(_op),
	retract(OP(_id,_op)),
  	retract(_ff2),
{write('DELETE>>>'),write(OP(_id,_op)),write('   '),write(_ff2),nl,}
	!.
}

{ ================== }
{ Private predicates }
{ ================== }

#MODE(( tempform(?,o) ))


tempform(hP(_m,_id,_x,'*instanceof',_y,_tt), 'inst@temp'(_m,_x,_y,_id,_tt)).

tempform(hP(_m,_id,_x,'*isa',_y,_tt), 'isa@temp'(_m,_y,_x,_id,_tt)).

tempform(hP(_m,_id,_id,_l,_id,_tt), 'indiv@temp'(_m,_id,_l,_tt)).

tempform(hP(_m,_id,_x,_l,_y,_tt), 'others@temp'(_m,_x,_y,_id,_l,_tt)) :-
  _l \== '*instanceof',
  _l \== '*isa',
  _x \== _id.

