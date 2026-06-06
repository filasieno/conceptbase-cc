{*
The ConceptBase.cc Copyright

Copyright 1987-2026 The ConceptBase Team. All rights reserved.

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
*
* File:        %M%
* Version:     %I%
* Creation:    21-Jan-1988, Eva Krueger (UPA)
* Last Change: %G%, Manfred Jeusfeld (RWTH)
* Release:     %R%
* -----------------------------------------------------------------------------
*
* This Prolog module is part of the ConceptBase system which is a run-time
* system for the System Modelling Language (SML).
*
*
* This module supports a fast storing of propvals by the following method:
* 
* Each propval(_id,_x,_l,_y,_t) is stored twice:
*   fastform1:
*      a predicate with _x as functor and _l, _y, _id and _t as arguments.
*   fastform2:
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
* before *_fast_proposition is called.
*
*
* 24.07.1990 RG:	Now storing proposition/6 facts.
*			The old propval form is also retrievable for 
*			compatibility reasons.
*
* 03.09.1990 AM:	'indiv@fast' extended by Individual's label:
*			now Strings,Assertions,... also belong to Individuals
*
* 30-Nov-1992/MJf: changed propval(id,x,l,y,t) and proposition(id,x,l,y,t,tt) to
* P(id,x,l,y) and hP(id,x,l,y,tt), i.e. the valid time component t is now
* eliminated (details in CBNEWS[147]).
*
* 05.01.1995 L.Bauer: Changed hP(id,x,l,y,tt) to hP(m,id,x,l,y,tt) in order to store module
* information along with the proposition
*
* Exported predicates:
* --------------------
*	
*   + retrieve_fast_proposition/1
*      Retrieve the proposition described by arg1.
*   + create_fast_proposition/1
*      Create the proposition described by arg1.
*   + delete_fast_proposition/1
*      Delete the proposition described by arg1.
*
}



#MODULE(Rep_fast)
#ENDMODDECL()


#IMPORT(WriteTrace/3,GeneralUtilities)

#IMPORT(assign_ID/1,validProposition)

#IMPORT(systemOmegaClass/1,validProposition)

#IMPORT(pcall/1,GeneralUtilities)

#IMPORT(name2id/2,GeneralUtilities)
	{6-Sep-93/Tl}
#IMPORT(retrieve_C_proposition/1,BIM2C)

#IMPORT(retrieve_C_proposition_module/1,BIM2C)

#IMPORT(create/1,BIM2C)

#IMPORT(get_transaction_time/1,TransactionTime)

#IMPORT(retrieve_temp_proposition/1,Rep_temp)

#IMPORT(id2name/2,GeneralUtilities)


:- import new_export/1 from BIM2C .
:- import delete_export/1 from BIM2C .
:- import new_import/1 from BIM2C .
:- import delete_import/1 from BIM2C .



{ =================== }
{ Exported predicates }
{ =================== }


{ ****** r e t r i e v e _ f a s t _ p r o p o s i t i o n ***** }
{                                                                }
{ retrieve_fast_proposition(_propdescr)                          }
{   _propdescr: partial: ground                                  }
{                                                                }
{ This predicate retrieves propositions stored in the 'fast'     }
{ representation. If the _id component of the proposition is     }
{ ground (=completely instantiated), 'retrieve_fast_proposition' }
{ searches 'fastform1' facts. Otherwise, the ordinary 'fastform2'}
{ representation is looked up. Backtracking is possible.         }
{								 }
{ Changed from propval/5 to proposition/6. (24.07.1990 RG)	 }
{                                                                }
{ 21-Dec-1990/MJf: new representation fastform1a for instanti-   }
{ ation propositions.                                            }
{                                                                }
{ 20-Nov-1992/MJf: use P/4 instead of propval/5 and proposition/6}
{ The auxiliary data structure hP/5 augments P/4 with the trans- }
{ action time, see CBNEWS[147].                                  }
{								 }
{ ************************************************************** }

retrieve_fast_proposition(P(_id,_x,_l,_y)) :-		
	{ write('get: '), write(P(_id,_x,_l,_y)),nl, }
 	retrieve_C_proposition(P(_id,_x,_l,_y)).

retrieve_fast_proposition(hP(_id,_x,_l,_y,_tt)) 	:-			{ direct search in module }
	retrieve_C_proposition(P(_id,_x,_l,_y)).

retrieve_fast_proposition(hP(_m,_id,_x,_l,_y,_tt)) 	:-			{ direct search in module }
	retrieve_C_proposition_module(P(_id,_x,_l,_y,_m)).


{ ******** c r e a t e _ f a s t _ p r o p o s i t i o n ******* }
{                                                                }
{ create_fast_proposition(_propdescr)                            }
{   _propdescr: partial: ground                                  }
{                                                                }
{ This predicate just stores the proposition _propdescr with two }
{ Prolog facts both stating the same assertion. The first uses   }
{ the source component of _propdescr as functor, the second uses }
{ a predefined functor.                                          }
{								 }
{ ************************************************************** }

create_fast_proposition(_a) :-
	write('FEHLER!!!'),write(create_fast_proposition(_a)),nl,!,fail.
{
create_fast_proposition(P(_id,_x,_l,_y)) :-
	get_transaction_time(_ttime),
	_tt = tt(_ttime),
        	create_fast_proposition(hP(_id,_x,_l,_y,_tt)),
  	!.
}
{create_fast_proposition(hP([_m,_id],_x,_l,_y,_tt)) :-	{ for System startup }
	assign_ID(P(_id,_x,_l,_y)),
  	fastform1or1a(hP(_m,_id,_x,_l,_y,_tt),_ff1),
  	assert(_ff1),
 	fastform2(hP(_m,_id,_x,_l,_y,_tt),_ff2),
  	assert(_ff2),
	!.
}
{
create_fast_proposition(hP(_id,_x,_l,_y,_tt)) :-
	M_SearchSpace( _m ),
  	assign_ID(P(_id,_x,_l,_y)),
  	fastform1or1a(hP(_m,_id,_x,_l,_y,_tt),_ff1),
  	assert(_ff1),
  	fastform2(hP(_m,_id,_x,_l,_y,_tt),_ff2),
  	assert(_ff2),
  	!.
}

{ ******** d e l e t e _ f a s t _ p r o p o s i t i o n ******* }
{                                                                }
{ delete_fast_proposition(_propdescr)                            }
{   _propdescr: partial: ground                                  }
{                                                                }
{ Try to delete the proposition given by _propdescr in both re-  }
{ presentations of Rep_fast. 'delete_fast_proposition' will NOT  }
{ backtrack.                                                     }
{								 }
{ Changed from propval/5 to proposition/6.			 }
{						24.07.1990 RG	 }
{ ************************************************************** }

delete_fast_proposition(P(_id,_x,_l,_y)) :-
	write('FEHLER !!! '),write(delete_fast_proposition(P(_id,_x,_l,_y))),nl,!,fail.

{
delete_fast_proposition(P(_id,_x,_l,_y)) :-
	delete_fast_proposition(hP(_id,_x,_l,_y,_)).

delete_fast_proposition(hP([_,_id],_x,_l,_y,_tt)) :-
	delete_fast_proposition(hP(_id,_x,_l,_y,_tt)).

delete_fast_proposition(hP(_id,_x,_l,_y,_tt)) :-
	{ write('delete_f_prop'), write( hP(_id,_x,_l,_y,_tt) ), nl,  }
	M_SearchSpace( _m ),
  	fastform1or1a(hP(_m,_id,_x,_l,_y,_tt),_ff1),
  	retract(_ff1),
	fastform2(hP(_m,_id,_x,_l,_y,_tt),_ff2),
  	retract(_ff2),
	!.
}


{ ================== }
{ Private predicates }
{ ================== }


{ ********************* f a s t f o r m 1 ********************** }
{                                                                }
{ fastform1(_propdescr,_ff1)                                     }
{   _propdescr: partial                                          }
{   _ff1: partial                                                }
{                                                                }
{ 'fastform1' transforms a given _propdescr into _ff1 where the  }
{ source argument of _propdescr becomes the functor of _ff1 and  }
{ the other arguments of _propdescr become its arguments:        }
{      propval(_id,_x,_l,_y,_t) ---> _x(_l,_y,_id,_t)            }
{ Naturally, _x must be an atom.                                 }
{								 }
{ Changed from propval/5 to proposition/6. (24.07.1990 RG)	 }
{                                                                }
{ ************************************************************** }

#MODE(( fastform1(?,o) ))


fastform1(hP(_m,_id,_x,_l,_y,_tt), _ff1) :-
  _ff1 =.. [_m,_x,_l,_y,_id,_tt].



{ ******************** f a s t f o r m 1 a ********************* }
{                                              21-Dec-1990/MJf   }
{ fastform1a(_propdescr,_ff1a)                                   }
{   _propdescr: partial                                          }
{   _ff1a: partial                                               }
{                                                                }
{ Like fastform1 but fastform1a is only for instantiation pro-   }
{ positions. In this case the 4th component (the class) becomes  }
{ the functor. See also CBNEWS[111] for benchmark results.       }
{                                                                }
{ ************************************************************** }

#MODE(( fastform1a(?,o) ))


fastform1a(hP(_m,_id,_x,'*instanceof',_c,_tt),_ff1a) :-
  _ff1a =.. [_c,_m,_x,_id,_tt].					{ _m darf nicht in den Funktor ! LWEB 4-Jul-1995 }
	


{ This one takes either fastform1 or fastform1a: }

fastform1or1a(hP(_m,_id,_x,'*instanceof',_c,_tt),_ff1a) :-
  atom(_c),
  fastform1a(hP(_m,_id,_x,'*instanceof',_c,_tt),_ff1a),
  !.

fastform1or1a(hP(_m,_id,_x,_l,_y,_tt), _ff1) :-
  atom(_x),
  fastform1(hP(_m,_id,_x,_l,_y,_tt), _ff1).



{ ********************* f a s t f o r m 2 ********************** }
{                                                                }
{ fastform2(_propdescr,_ff1)                                     }
{   _propdescr: partial                                          }
{   _ff2: partial                                                }
{                                                                }
{ Opposed to fastform1, fastform2 only uses terms with known     }
{ functors ('inst@fast','isa@fast','indiv@fast' and              }
{ 'others@fast') to represent _propdescr.                        }
{ Note that one may NOT define fastform2 by including cuts ('!') }
{ in its clauses since the label component of _propdescr can be  }
{ a variable. In this case, backtracking on all four possible    }
{ representations of fastform2 must be allowed.                  }
{								 }
{ Changed from propval/5 to proposition/6.			 }
{						24.07.1990 RG	 }
{ ************************************************************** }

#MODE(( fastform2(?,o) ))

 
fastform2(hP(_m,_id,_x,'*instanceof',_y,_tt), 'inst@fast'(_m,_x,_y,_id,_tt)). 

fastform2(hP(_m,_id,_x,'*isa',_y,_tt), 'isa@fast'(_m,_y,_x,_id,_tt)).

fastform2(hP(_m,_id,_id,_l,_id,_tt), 'indiv@fast'(_m,_id,_l,_tt)).

fastform2(hP(_m,_id,_x,_l,_y,_tt), 'others@fast'(_m,_x,_y,_id,_l,_tt)) :-
  _l \== '*instanceof',
  _l \== '*isa',
  \+ ( _x == _id,
       _y == _id ).



once(_x)	:-	_x,!.