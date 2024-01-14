{*
The ConceptBase.cc Copyright

Copyright 1987-2024 The ConceptBase Team. All rights reserved.

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

{ DIESES MODUL WIRD NICHT MEHR BENOETIGT. EVENT-ERKENNUNG IST ECAeventManager.pro }
{ Jan-98/CQ }



{
::::::::::::::
SML2Events.pro
:::::::::::::

*
* File : SML2Events
* Version : 1
* Creation: 1-Feb-1995, Farshad Lashgari
*-----------------------------------------------
* Modul berechnet alle Erreignispraedikate aus der Liste der SMLfragments

* Exported predicates
* -------------------
*
* + fraglist2eventlist/3
*
}

#MODULE(ECA_SML2Events)
#ENDMODDECL()

#IMPORT(id2name/2,GeneralUtilities)
#IMPORT(name2id/2,GeneralUtilities)
#IMPORT(append/3,GeneralUtilities)
#IMPORT(append/2,GeneralUtilities)
#IMPORT(makeset/2,GeneralUtilities)
#IMPORT(save_setof/3,GeneralUtilities)
#IMPORT(retrieve_proposition/1,PropositionProcessor)
#IMPORT(set_KBsearchSpace/2,SearchSpace)
#IMPORT(prove_literal/1,Literals)
#IMPORT(prove_edb_literal/1,Literals)
#IMPORT(aToAdot/2,AToAdot)

#IF(SWI)
:- style_check(-singleton).
#ENDIF(SWI)


{*******************************************************************}
{                                                                   }
{ fraglist2eventlist(_eventtype,_smlfraglist,_eventlist)            }
{                                                                   }
{ Description of arguments:                                         }
{eventtype   : Event type (Tell/Untell)                             }
{smlfraglist : List of Smlfragments [SMLfragment(what(...),...)]    }
{eventlist   : Result list of events [Tell(In(x,C)),Untell(...),...]}
{                                                                   }
{ Description of predicate:                                         }
{  Finds the events out of an fragment list                         }
{*******************************************************************}

#MODE((fraglist2eventlist(i,i,o)))


fraglist2eventlist(_,[],[]).
fraglist2eventlist(_etype,[_smlfrag|_fraglist],_elist):-
	frag2eventlist(_etype,_smlfrag,_elist1),
	fraglist2eventlist(_etype,_fraglist,_elist2),
	append(_elist1,_elist2,_elist),!.

frag2eventlist(_etype,'SMLfragment'(what(_object),in_omega(_oclasslist),in(_classlist),isa(_isalist),with(_withlist)),_elist):-
	Expand_of_superClass(_oclasslist,_newoclasslist),
	Expand_of_superClass(_classlist,_newclasslist),
	Expand_of_superClass(_isalist,_newisalist),
	append(_newoclasslist,_newclasslist,_newinlist),
	!,
	build_in_events(_etype,_object,_newinlist,_inevents),
	build_isa_events(_etype,_object,_newisalist,_isAevents),
	build_attr_events(_etype,_object,_withlist,_Aevents),
	append(_inevents,_isAevents,_elist1),
	append(_elist1,_Aevents,_elist).



{*******************************************************************}
{                                                                   }
{ build_in_events(_event,_object,_classlist,_eventlist)             }
{                                                                   }
{ Description of arguments:                                         }
{   event  : Type of Event (Tell/Untell)                            }
{  object  : main object of fragment                                }
{classlist : list of In-Classes (including Omega- and super classes)}
{eventlist : Result list of events                                  }
{                                                                   }
{ Description of predicate:                                         }
{   Checks if object is really inserted/deleted as instance of a    }
{   class.                                                          }
{*******************************************************************}

#MODE((build_in_events(i,i,i,o)))


build_in_events(_,_,[],[]).

{ In Beziehung existiert schon }
build_in_events(Tell,_o,[_c|_r],_rest) :-
	set_KBsearchSpace(currentOB,Now),
	name2id(_o,_oid),
	name2id(_c,_cid),
	prove_edb_literal(In_e(_oid,_cid)),
	!,
	build_in_events(Tell,_o,_r,_rest).

build_in_events(_ev,_o,[_c|_r],[_event|_rest]) :-
	name2id(_o,_oid),
	name2id(_c,_cid),
	_event =.. [_ev,In(_oid,_cid)],
	!,
	build_in_events(_ev,_o,_r,_rest).

{*******************************************************************}
{                                                                   }
{ build_isa_events(_event,_object,_classlist,_eventlist)            }
{                                                                   }
{ Description of arguments:                                         }
{   event  : Type of Event (Tell/Untell)                            }
{  object  : main object of fragment                                }
{classlist : list of IsaClasses (including Omega- and super classes)}
{eventlist : Result list of events                                  }
{                                                                   }
{ Description of predicate:                                         }
{   Checks if object is really inserted/deleted as subclass of a    }
{   class.                                                          }
{*******************************************************************}

#MODE((build_isa_events(i,i,i,o)))


build_isa_events(_,_,[],[]).

{ Isa Beziehung existiert schon }
build_isa_events(Tell,_o,[_c|_r],_rest) :-
	set_KBsearchSpace(currentOB,Now),
	name2id(_o,_oid),
	name2id(_c,_cid),
	prove_literal(Isa(_oid,_cid)),
	!,
	build_isa_events(Tell,_o,_r,_rest).

build_isa_events(_ev,_o,[_c|_r],[_event|_rest]) :-
	name2id(_o,_oid),
	name2id(_c,_cid),
	_event =.. [_ev,Isa(_oid,_cid)],
	!,
	build_isa_events(_ev,_o,_r,_rest).




{*******************************************************************}
{                                                                   }
{ build_attr_events(_event,_object,_classlist,_eventlist)           }
{                                                                   }
{ Description of arguments:                                         }
{   event  : Type of Event (Tell/Untell)                            }
{  object  : main object of fragment                                }
{ withlist : list of with specifications                            }
{eventlist : Result list of events                                  }
{                                                                   }
{ Description of predicate:                                         }
{   generates the event list for attribute definitions. For each    }
{   attribute declaration, each attribute category and each property}
{   an event must be generated. The event has the form              }
{   Tell(Adot(cc,object,value))                                     }
{*******************************************************************}

#MODE((build_attr_events(i,i,i,o)))


build_attr_events(_ev,_o,[],[]).

build_attr_events(_ev,_o,[attrdecl(_aclist,_proplist)|_rest],_attrevents) :-
	build_attr_events2(_ev,_o,_aclist,_proplist,_attrevents1),
	build_attr_events(_ev,_o,_rest,_attrevents2),
	append(_attrevents1,_attrevents2,_attrevents).

#MODE((build_attr_events2(i,i,i,i,o)))


build_attr_events2(_ev,_o,[],_,[]).

build_attr_events2(_ev,_o,[_ac|_rest],_proplist,_attrevents) :-
	build_prop_events(_ev,_o,_ac,_proplist,_attrevents1),
	build_attr_events2(_ev,_o,_rest,_proplist,_attrevents2),
	append(_attrevents1,_attrevents2,_attrevents).


#MODE((build_prop_events(i,i,i,i,o)))


build_prop_events(_ev,_o,_ac,[],[]).

{ Attribut existiert schon }
build_prop_events(Tell,_o,_ac,[property(_label,_value)|_rest],_evrest) :-
	set_KBsearchSpace(newOB,Now),
	name2id(_o,_oid),
	name2id(_value,_vid),
	aToAdot([A(_oid,_ac,_vid)],[_adot]),
	set_KBsearchSpace(currentOB,Now),
	prove_literal(_adot),
	!,
	build_prop_events(Tell,_o,_ac,_rest,_evrest).

build_prop_events(_ev,_o,_ac,[property(_label,_value)|_rest],[_event|_evrest]) :-
	((_ev=Tell,set_KBsearchSpace(newOB,Now));
     (_ev=Untell,set_KBsearchSpace(oldOB,Now))
	),
	name2id(_o,_oid),
	name2id(_value,_vid),
	aToAdot([A(_oid,_ac,_vid)],[_adot]),
	!,
	_event =.. [_ev,_adot],
	build_prop_events(_ev,_o,_ac,_rest,_evrest).




{*******************************************************************}
{                                                                   }
{ Expand_of_superClass(_classes,_oclasses)                          }
{                                                                   }
{ Description of arguments:                                         }
{ classes : input                                                   }
{oclasses : output                                                  }
{                                                                   }
{ Description of predicate:                                         }
{ 	Suche die Superclasses zu einer Klasse _c.  Ist _c in der DB    }
{   noch nicht enthalten, liefere keine Superclasses zurueck        }
{                                                                   }
{*******************************************************************}

#MODE((Expand_of_superClass(i,o)))


Expand_of_superClass([],[]).

Expand_of_superClass([_t|_r],_rest) :- { sonst Endlosschleife, da Proposition=>Proposition }
	(_t = class(_p); (_t\= class(_),_t = _p)),
	id2name(_p,_pn),
	_pn == 'Proposition',
	!,
	Expand_of_superClass(_r,_rest).

Expand_of_superClass([_t|_clist],_slist):-
	(_t = class(_c); (_t\= class(_),_t = _c)),
	name2id(_c,_cid),
	findall(_s,retrieve_proposition(P(_,_cid,'*isa',_s)),_slist1),!,
	!,
	Expand_of_superClass(_clist,_slist2),
	Expand_of_superClass(_slist1,_slist3),
	append([_slist1,_slist2,_slist3],_slist4),
	makeset([_c|_slist4],_slist),!.

Expand_of_superClass([_t|_clist],_slist):-
	Expand_of_superClass(_clist,_slist),!.


