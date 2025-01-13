{*
The ConceptBase.cc Copyright

Copyright 1987-2025 The ConceptBase Team. All rights reserved.

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
*}
{
*
*		DIESE MODUL WIRD IN DER AKTUELLEN VERSION VON CONCEPTBASE
*		NICHT MEHR GELADEN.	 9-Dez-1996 LWEB
*
* File:        Rep_h.pro
* Version:     7.1
* Creation:    27-Jun-1989, Thomas Wenig (UPA)
* Last change: 5/4/94, Manfred Jeusfeld (RWTH)
* Release:     7
* -----------------------------------------------------------------------------
*
* This Prolog module is part of the ConceptBase system which is a run-time
* system for the System Modelling Language (SML).
*
*
* This module supports a fast storing of history-propvals
* by the following method ( the same as in Rep_fast):
*
* Each propval(_id,_x,_l,_y,_t) is stored twice:
*   hfastform1:
*      a predicate with _x as functor and _l, _y, _id and _t as arguments.
*   hfastform2:
*      a predicate with a predefined functor depending on the label _l
*      (analogous to Rep_simp).
*
* The retrieval functions as follows:
* if _x is instantiated then seek the predicates with _x as functor,
* otherwise look at the second representation (depending of the label).
*
* There exists one problem:
* If a propval has a _x equal to an already existing predicate name
* and this predicate has four arguments then a retrieval for the propval
* will invide a wrong result.
* The solution of appending a suffix (i.e. @) to each _x before storing
* or retrieving the predicate with _x as functor will cost too much time.
* Perhaps a better solution: Appending of such a suffix at a higher level
* before *_h_proposition is called.
*
* 26.07.1990 RG:	Now storing proposition/6 facts.
*			The old propval form is also retrievable for
*			compatibility reasons.
*
* 30-Nov-1992/MJf: changed propval(id,x,l,y,t) and proposition(id,x,l,y,t,tt) to
* P(id,x,l,y) and hP(id,x,l,y,tt), i.e. the valid time component t is now
* eliminated (details in CBNEWS[147]).
*
*
* Exported predicates:
* --------------------
*
*   + retrieve_h_proposition/1
*      Retrieve the proposition described by arg1.
*   + create_h_proposition/1
*      Create the proposition described by arg1.
*   + delete_h_proposition/1
*      Delete the proposition described by arg1.
*
}



#MODULE(Rep_h)
#ENDMODDECL()


#IMPORT(pcall/1,GeneralUtilities)

#IMPORT(name2id/2,GeneralUtilities)
	{30-Jul-93/HP}
#IMPORT(retrieve_fast_proposition/1,Rep_fast)
#IMPORT(pc_atomconcat/2,PrologCompatibility)
#IMPORT(pc_atomconcat/3,PrologCompatibility)

#IMPORT(id2name/2,GeneralUtilities)
	{30-Jul-93/HP}


{ =================== }
{ Exported predicates }
{ =================== }





{ ********* r e t r i e v e _ h _ p r o p o s i t i o n ******** }
{                                                                }
{ retrieve_h_proposition(_propdescr)                             }
{   _propdescr: partial: ground                                  }
{                                                                }
{ This predicate retrieves propositions stored in the 'h'        }
{ representation. If the _id component of the proposition is     }
{ ground (=completely instantiated), 'retrieve_h_proposition'    }
{ searches 'hfastform1' facts. Otherwise, the ordinary           }
{'hfastform2' representation is looked up. Backtracking is       }
{ possible.                                                      }
{                                                                }
{ Changed from propval/5 to proposition/6.			 }
{						26.07.1990 RG	 }
{ ************************************************************** }

retrieve_h_proposition(hP(_id,_s,_l,_d,_tt)):-
{ set_act_hist$BIM2C,}
    { The C-Proposition-Base can search with search-time, 6.4.1994/TL }
 retrieve_C_proposition(P(_id,_s,_l,_d)).

retrieve_h_proposition(hP(_m,_id,_s,_l,_d,_tt)):-
{ set_act_hist$BIM2C,}
    { The C-Proposition-Base can search with search-time, 6.4.1994/TL }
 retrieve_C_proposition(P(_id,_s,_l,_d,_m)).



{
retrieve_h_proposition(P(_id,_s,_l,_d)) :-
	retrieve_h_proposition(hP(_id,_s,_l,_d,_)).

retrieve_h_proposition(hP(_id,_x,_l,_y,_tt)) :-
	M_SearchSpace( _m ),
	retrieve_h_proposition(hP(_m,_id,_x,_l,_y,_tt)).

retrieve_h_proposition(hP(_m,_id,_x,_l,_y,_tt)) :-
	atom(_x),
	id2name(_y,_y1),
	_y1 \= 'Individual',
	_y1 \= 'InstanceOf',
	_y1 \= 'IsA',
	_y1 \= 'Attribute',
	!,
        hfastform1(hP(_m,_id,_x,_l,_y,_tt),_ff1),
	pcall(_ff1).

retrieve_h_proposition(hP(_m,_id,_x,_l,_y,_tt)) :-
	hfastform2(hP(_m,_id,_x,_l,_y,_tt),_ff2),
 	pcall(_ff2).


}

{ *********** c r e a t e _ h _ p r o p o s i t i o n ********** }
{                                                                }
{ create_h_proposition(_propdescr)                               }
{   _propdescr: partial: ground                                  }
{                                                                }
{ This predicate just stores the proposition _propdescr with two }
{ Prolog facts both stating the same assertion. The first uses   }
{ the source component of _propdescr as functor, the second uses }
{ a predefined functor.                                          }
{                                                                }
{ ************************************************************** }

create_h_proposition(hP([_m,_id],_x,_l,_y,_tt)) :-	{ for System startup }
{	write('create_h startup '),write(hP([_m,_id],_x,_l,_y,_tt)),nl, 	}
 	hfastform1(hP(_m,_id,_x,_l,_y,_tt),_ff1),
  	assert(_ff1),
  	hfastform2(hP(_m,_id,_x,_l,_y,_tt),_ff2),
  	assert(_ff2),
  	!.

create_h_proposition(hP(_id,_x,_l,_y,_tt)) :-
{	write('create_h   '),write(hP(_id,_x,_l,_y,_tt)),nl,	}
	M_SearchSpace( _m ),
  	hfastform1(hP(_m,_id,_x,_l,_y,_tt),_ff1),
  	assert(_ff1),
  	hfastform2(hP(_m,_id,_x,_l,_y,_tt),_ff2),
  	assert(_ff2),
  	!.



{ ********** d e l e t e _ h _ p r o p o s i t i o n *********** }
{                                                                }
{ delete_h_proposition(_propdescr)                               }
{   _propdescr: partial: ground                                  }
{                                                                }
{ Try to delete the proposition given by _propdescr in both re-  }
{ presentations of Rep_h. 'delete_h_proposition' will NOT        }
{ backtrack.                                                     }
{                                                                }
{ ************************************************************** }


delete_h_proposition(hP(_id,_x,_l,_y,_tt)) :-
	M_SearchSpace( _m ),
  	hfastform1(hP(_m,_id,_x,_l,_y,_tt),_ff1),
  	retract(_ff1),
  	hfastform2(hP(_m,_id,_x,_l,_y,_tt),_ff2),
  	retract(_ff2),
	!.



{ ================== }
{ Private predicates }
{ ================== }


{ ********************* h f a s t f o r m 1 ******************** }
{                                                                }
{ hfastform1(_propdescr,_ff1)                                    }
{   _propdescr: partial                                          }
{   _ff1: partial                                                }
{                                                                }
{ 'hfastform1' transforms a given _propdescr into _ff1 where the }
{ source argument of _propdescr becomes the functor of _ff1 and  }
{ the other arguments of _propdescr become its arguments:        }
{      propval(_id,_x,_l,_y,_t) ---> _x(_l,_y,_id,_t)            }
{ Naturally, _x must be an atom.                                 }
{                                                                }
{ ************************************************************** }

#MODE(( hfastform1(?,o) ))


hfastform1(hP(_m,_id,_x,_l,_y,_tt), _ff1) :-
  atom(_x),
  pc_atomconcat('*history',_x,_x1),
  _ff1 =.. [_x1,_m,_l,_y,_id,_tt].		{ m may not be used as functor 5-Jul-1995 LWEB }


{ ********************* h f a s t f o r m 2 ******************** }
{                                                                }
{ hfastform2(_propdescr,_ff1)                                    }
{   _propdescr: partial                                          }
{   _ff2: partial                                                }
{                                                                }
{ Opposed to hfastform2, hfastform1 only uses terms with know    }
{ functors ('inst@h','isa@h','indiv@h' and                       }
{ 'others@h') to represent _propdescr.                           }
{ Note that one may NOT define hfastform2 by including cuts ('!')}
{ in its clauses since the label component of _propdescr can be  }
{ a variable. In this case, backtracking on all four possible    }
{ representations of hfastform2 must be allowed.                 }
{                                                                }
{ ************************************************************** }

#MODE(( hfastform2(?,o) ))

:- 'inst@h'/5 index (2,3,4).
:- 'isa@h'/5 index (4,3,4).
:- 'indiv@h'/3 index (2,3).
:- 'others@h'/6 index (2,4,5).

hfastform2(hP(_m,_id,_x,'*instanceof',_y,_tt),'inst@h'(_m,_x,_y,_id,_tt)).

hfastform2(hP(_m,_id,_x,'*isa',_y,_tt), 'isa@h'(_m,_x,_y,_id,_tt)).

hfastform2(hP(_m,_id,_id,'-',_id,_tt), 'indiv@h'(_m,_id,_tt)).

hfastform2(hP(_m,_id,_x,_l,_y,_tt), 'others@h'(_m,_x,_l,_y,_id,_tt)) :-
  _l \== '*instanceof',
  _l \== '*isa',
  \+ ( _l == '-',
       _x == _id,
       _y == _id ).


