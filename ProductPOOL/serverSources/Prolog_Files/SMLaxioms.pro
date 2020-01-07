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
* File:         SMLaxioms.pro
* Version:      10.1
* Creation:    21-Oct-1987, Manfred Jeusfeld (UPA)
* Last Change: 01-Jul-1996, Manfred Jeusfeld (RWTH)
* Date released : 96/04/15  (YY/MM/DD)
*
* SCCS-Source-Pool : /home/CBase/CB_NewStruct/ProductPOOL/serverSources/Prolog_Files/SCCS/s.SMLaxioms.pro
* Date retrieved : 96/04/25 (YY/MM/DD)
* -----------------------------------------------------------------------------
*
* This Prolog module is part of the ConceptBase system which is a run-time
* system for the System Modelling Language (SML).
* The SMLaxioms module contains predicates that implement the basic
* axioms of predefined links (such as '*isa', '*instanceof') in the
* SML language (cf. [CML 87]). Those predicates which contain the string
* "axiom" are intended to be capable to generate an argument which fulfills
* the underlying axiom. Predicates which contain "constraint" are only
* capable of testing a properly instantiated argument.
*
* References:
*  [CML 87] N.N.: "Conceptual Modelling Language: An Informal Description",
*           Institute of Computer Science, Research Center Of Crete,
*           January 1987
*
*
* Exported predicates:
* --------------------
*
*   + InstanceOf_constraint_1/1
*      Succeeds if arg1 satisfies "InstanceOf" contraint 1 (see below).
*   + IsA_axiom_1/1
*   + IsA_constraint_1/1
*   + SMLvalid/1
*      Arg1 is a proposition in the KB which fulfills the integrity con-
*      straints of SML.
*   + SMLvalid_untell/1
*       Arg1 is a proposition in the KB which is going to be untelled, if
*       untelling does not violate the integrity constraints of SML.
*   + is_specialization_of/2
*
*  20-Dec-1989\TW: Big change, axioms and constraints adapted to valid time;
*                  also integrity checks for UNTELL added.
*
*  17-May-1990/CMa: reduced scope of IndividualConstraint.
*
* 04-May-1992/MSt small change networkconstraint1
*
*  01-Sep-1992/DG: Timecomponents are deleted, see CBNEWS[142]
*
* 29.09.92 RG	eliminated relicts of 'LiteralProcessor'
*
* 30.09.92 RG eliminated usage of 'WeakDeduction'
*
* 27-Oct-92/MJf: IsA_axiom_2 (inheritance of attributes to subclasses) is
*                now removed (see CBNEWS[144])
*
* 4-Nov-1992/MSt: call of IC checker for user defined ICs moved to SemanticIntegrity.pro
* some imports fo TC predicates deleted which are not used here
*
* 9-Dez-1996/LWEB: retrieve_temp_proposition$Rep_temp/1 durch retrieve_temp$PropositionProcessor/1 ersetzt.
}

{:- setdebug.}


#MODULE(SMLaxioms)
#EXPORT(IsA_axiom_1/1)
#EXPORT(SMLvalid/1)
#EXPORT(SMLvalid_untell/1)
#EXPORT(is_specialization_of/2)
#ENDMODDECL()


#IMPORT(retrieve_proposition/1,PropositionProcessor)
#IMPORT(report_error/3,ErrorMessages)
#IMPORT(member/2,GeneralUtilities)
#IMPORT(attribute/1,validProposition)
#IMPORT(individual/1,validProposition)
#IMPORT(systemLabel/1,validProposition)
#IMPORT(ordinaryLabel/1,validProposition)
#IMPORT(systemOmegaClass/1,validProposition)
#IMPORT(prove_literal/1,Literals)
#IMPORT(prove_edb_literal/1,Literals)
#IMPORT(not_prove_literal/1,Literals)
#IMPORT(retrieve_temp_ins/1,PropositionProcessor)
#IMPORT(retrieve_temp_del/1,PropositionProcessor)
#IMPORT(id2name/2,GeneralUtilities)
#IMPORT(name2id/2,GeneralUtilities)
#IMPORT(check_implicit/1,BIM2C)
#IMPORT(pc_update/1,PrologCompatibility)

#IF(SWI)
:- style_check(-singleton).
#ENDIF(SWI)



#DYNAMIC('integrity@errors'/1)
'integrity@errors'(0).





{ =================== }
{ Exported predicates }
{ =================== }


{ ********************* I s A _ a x i o m _ 1 ****************** }
{                                                                }
{ IsA_axiom_1(_propdescr)                                        }
{   _propdescr: any: ground                                      }
{                                                                }
{ 'IsA_axiom_1' is the implementation of the "IsA" axiom (A1)    }
{ adapted from [CML 87] p. 13:                                   }
{                                                                }
{  (A1) If P is an instance of Q during t and Q is a speciali-   }
{       zation of R during t, then P is also an instance of R    }
{       during t.                                                }
{                                                                }
{ Note that '*isa' propositions are assumed to have duration     }
{ "Always" (cf. [CML 87] p. 23). The proposition stating that    }
{ P is an instance of Q may NOT be inherited. Otherwise an in-   }
{ finite loop could occur.                                       }
{                                                                }
{ 12-Apr-88: The execution order of the premises of 'IsA_axiom_1'}
{ now depends on the instantiation degree of _propdescr (see     }
{ also notes.log)                                                }
{                                                                }
{ ************************************************************** }

IsA_axiom_1(In_i(_P,_R)) :-
  atom(_P),
  !,
  retrieve_proposition(P(_ID1,_P,'*instanceof',_Q)),
  is_proper_specialization_of(_Q,_R).

IsA_axiom_1(In_i(_P,_R)) :-
  is_proper_specialization_of(_Q,_R),
  retrieve_proposition(P(_ID1,_P,'*instanceof',_Q)).


{ ********* I n s t a n c e O f _ c o n s t r a i n t _ 1 ****** }
{                                                                }
{ InstanceOf_constraint_1(_propdescr)                            }
{   _propdescr: any                                              }
{                                                                }
{ This predicate checks wether a given _propdescr fulfills the   }
{ constraint listed below (cf. [CML 87] p. 8):                   }
{                                                                }
{  (C1) For every proposition P which is instance of a proposi-  }
{       tion Q: from(P) must be an instance of from(Q), to(P)    }
{       must be an instance of to(Q).                            }
{                                                                }
{ 'InstanceOf_constraint_1' adapts the following strategy to en- }
{ sure satisfaction of (C1):                                     }
{   TRY to prove that _propdescr doesn't satisfy the constraint. }
{   If so, it runs in the cut-fail and therefore fails itself.   }
{   Otherwise - after ckecking all possible _Q's - it runs in    }
{   second ("catch-all") clause and it succeeds.                 }
{                                                                }
{ ************************************************************** }

{* preliminary check for existence of referenced objects: }

InstanceOf_constraint_1(P(_P,_X,_l,_Y)) :-
  \+(individual(P(_P,_X,_l,_Y))),
  \+(retrieve_proposition(P(_Y,_V,_l1,_W))),
  !,
  report_error(NOOBJECT, TelosAxioms,[telosStatement(_P),objectName(_Y)]),
  fail.

InstanceOf_constraint_1(P(_P,_X,_l,_Y)) :-
  \+(individual(P(_P,_X,_l,_Y))),
  check_implicit(_Y),
  !,
  report_error(NOOBJECT, TelosAxioms,[telosStatement(_P),objectName(_Y)]),
  fail.


{ main check: the instantiation to a class _C triggers this IC.          }
{ We assume that _X exists as an object. This is made sure by an earlier }
{ step (e.g., in the translation from object names to OIDs).             }

InstanceOf_constraint_1(P(_P,_X,_in,_C)) :-
  _in == '*instanceof',
  retrieve_proposition(P(_X,_S,_L,_D)),   {assuming that _X exists!}
  violatesIOC1(P(_X,_S,_L,_D),_C),
  !,
  fail.


{* no violation: }

InstanceOf_constraint_1(_).


{* do the work:}
{* violatesIOC1:                                                            *}
{* 12-Jan-2005/M. Jeusfeld: we now use the general In-predicate to test     *}
{* the axiom. The advantage is that we can now also use attribute categories*}
{* of deduced classes of _X. A negative side effect is that the truth of    *}
{* In(_X,_W) (or In(_Y,_W) may change depending on the deductive rules and  *}
{* the database state. Then, we would have to re-check SAIOC1 but we        *}
{* currently don't do that.                                                 *}
{* See also find_attributeclasses in FragmentToPropositions.pro             *}

violatesIOC1(P(_P,_X,_l,_Y),_Q) :-
   retrieve_proposition(P(_Q,_V,_l1,_W)),
   (_X \== _P; _V \== _Q), !,       { if _P and _Q are individuals then      }
                                    { everything is OK since In(_P,_Q) holds }
   (
     not_prove_literal(In(_X,_V));
     not_prove_literal(In(_Y,_W))
   ),
{*
   \+ (
         prove_edb_literal(In_e(_X,_V)),
         prove_edb_literal(In_e(_Y,_W))
       ),
*}

  report_error(SAIOC1, TelosAxioms, [objectName(_P),
                                   objectName(_X),
                                   objectName(_Y),
                                   objectName(_Q),
                                   objectName(_V),
                                   objectName(_W)]).



{ **************** I s A _ c o n s t r a i n t _ 1 ************* }
{                                                                }
{ IsA_constraint_1(_propdescr)                                   }
{   _propdescr: any                                              }
{                                                                }
{ This predicate checks wether a given _propdescr fulfills the   }
{ constraint listed below (cf. [CML 87] p. 13):                  }
{                                                                }
{  (C2) If P is a specialization of Q and there exists an attri- }
{       bute class A=<Q,l,R,t> then for all attribute classes    }
{       A1=<P,l,R1,t1> R1 must be a specialization of R.         }
{                                                                }
{ The remarks on 'InstanceOf_constraint_1' apply analogously.    }
{ Note that only proper generalizations Q of P have to be        }
{ examined. In the case "Q = P" there won't be a matching        }
{ attribute class A \= A1 due to (C3)! Right?                    }
{                                                                }
{ ************************************************************** }

IsA_constraint_1(P(_A1,_P,_l,_R1)) :-
  attribute(P(_A1,_P,_l,_R1)),
   is_proper_specialization_of(_P, _Q),
  name2id(QueryClass,_QueryClass),
  \+(prove_literal( In(_P,_QueryClass))),  {id_65=QueryClass; QueryClasses do not need to specialize  }
  retrieve_proposition(P(_A,_Q,_l,_R)),    {their attributes since the instances of }
  ( (\+(is_specialization_of(_R1,_R)),     {their attributes are derived.           }
     _error = ATTRIBUTE_MISMATCH);
    (\+(is_specialization_of(_A1,_A)),
     _error = ATTRIBUTE_UNSPECIALIZED)
  ),
  !,
  report_error( _error, TelosAxioms,[objectName(_P),
                                     objectName(_Q),
                                     objectName(_A),
                                     objectName(_A1),
                                     objectName(_R),
                                     objectName(_R1)]),
  fail.

{ 	IsA_constraint_1 needs to be checked in the other direction as well:
	is P!l a correct generalisation of Q!l  ?
	25-01-96 LWEB }

IsA_constraint_1(P(_A1,_P,_l,_R1)) :-
  attribute(P(_A1,_P,_l,_R1)),
   is_proper_specialization_of(_Q, _P),
  name2id(QueryClass,_QueryClass),
  \+(prove_literal( In(_Q,_QueryClass))),  {id_65=QueryClass; QueryClasses do not need to specialize  }
  retrieve_proposition(P(_A,_Q,_l,_R)),   	 {their attributes since the instances of }
  ( (\+(is_specialization_of(_R,_R1)),    	 {their attributes are derived.           }
     _error = ATTRIBUTE_MISMATCH);
    (\+(is_specialization_of(_A,_A1)),
     _error = ATTRIBUTE_UNSPECIALIZED)
  ),
  !,
  report_error( _error, TelosAxioms,[objectName(_Q),
                                     objectName(_P),
                                     objectName(_A1),
                                     objectName(_A),
                                     objectName(_R),
                                     objectName(_R1)]),
  fail.

IsA_constraint_1(_).



{ **************** I s A _ c o n s t r a i n t _ 2 ************* }
{                                                                }
{ IsA_constraint_2(_propdescr)                                   }
{   _propdescr: any                                              }
{                                                                }
{ This predicate checks wether a given _propdescr fulfills the   }
{ constraint listed below (see also Diss. of M. Jeusfeld):       }
{                                                                }
{  (C3) If C is a subclass of D then the source of C must be a   }
{       subclass of the source of D, and the destination of C    }
{       must be a subclass of the destination of D.              }
{                                                                }
{ ************************************************************** }

IsA_constraint_2(P(_A1,_C,_isa,_D)) :-
  _isa == '*isa',
  retrieve_proposition(P(_C,_C1,_l1,_D1)),
  _C1 \== _C,     {_C is not an individual}
  retrieve_proposition(P(_D,_C2,_l2,_D2)),
  (
     \+(is_specialization_of(_C1,_C2));
     \+(is_specialization_of(_D1,_D2))
  ),
  !,
  report_error(WRONGSUBCLASS, TelosAxioms, [objectName(_C),
                                   objectName(_C1),
                                   objectName(_D1),
                                   objectName(_D),
                                   objectName(_C2),
                                   objectName(_D2)]),
  fail.

IsA_constraint_2(_).

{ **************** I s A _ c o n s t r a i n t _ 3 ************* }
{                                                                }
{ IsA_constraint_3(_propdescr)                                   }
{   _propdescr: any                                              }
{                                                                }
{ This predicate checks axiom 12 of the telos axioms:            }
{                                                                }
{   forall c,d Isa(c,d) and Isa(d,c) ==> (c=d)                   }
{   (no cyclic Isa-relations)                                    }
{ ************************************************************** }

IsA_constraint_3(P(_A1,_C,'*isa',_D)) :-
	_C \== _D,
	is_specialization_of(_C1,_C),
	is_specialization_of(_D,_D1),
	is_specialization_of(_D1,_C1),
	!,
	report_error(ISA_AXIOM, TelosAxioms, [objectName(_C),
                                   objectName(_D),
                                   objectName(_C1),
                                   objectName(_D1)]),
	fail.

IsA_constraint_3(_).


{ *************** I s A _ c o n s t r a i n t _ 4 ************** }
{                                                25-Jun-1996/MJf }
{ IsA_constraint_4(_propdescr)                                   }
{   _propdescr: any                                              }
{                                                                }
{ This predicate checks wether a given _propdescr fulfills the   }
{ a subcase of axiom A16 [cf. Jeusfeld92]:                       }
{                                                                }
{    If C is subclass of D, D has an attribute labelled 'a' and  }
{    another superclass E of C (not of D) defines another        }
{    attribute with the same label, then C must also define an   }
{    attribute with label 'a'.                                   }
{                                                01-Jul-1996/MJf }
{ ************************************************************** }

IsA_constraint_4(P(_,_C,'*isa',_D)) :-
  name2id(QueryClass,_QueryClass),
                                      {id_65=QueryClass QueryClasses may violate this axiom since they }
  \+(prove_literal( In(_C,_QueryClass))),   {have no explicit instances(only derived).      }
  is_specialization_of(_D,_D1),			{Hier besteht Gefahr von endloser Schleife,wenn isA Beziehung eine Zykel bildet!}
  retrieve_proposition(P(_a1,_D1,_a,_TD1)),	{Durch Backtracking wird is_specialization_of immer wieder aufgerufen und immer}
  attribute(P(_a1,_D1,_a,_TD1)),		{liefert was aus, wegen Zykel. Deshalb wird IsA_3 vorausgezetzt fuer IsA_4.}
  \+(retrieve_proposition(P(_,_C,_a,_TC))),
  is_proper_specialization_of(_C,_E),
  retrieve_proposition(P(_a2,_E,_a,_TE)),
  attribute(P(_a2,_E,_a,_TE)),
  \+(is_specialization_of(_E,_D)),
  \+(is_specialization_of(_D,_E)),
  !,
  report_error( NON_UNIQUE_ATTRIBUTE, TelosAxioms, [objectName(_C),
                                         objectName(_D1),
                                         objectName(_E),
                                         _a]),
  fail.

IsA_constraint_4(_).



{ *********** N e t w o r k _ c o n s t r a i n t _ 1 ********** }
{                                                                }
{ Network_constraint_1(_propdescr)                               }
{   _propdescr: any                                              }
{                                                                }
{ This predicate checks wether a given _propdescr fulfills the   }
{ constraint listed below (cf. [CML 87] p. 8):                   }
{                                                                }
{  (C3) No two propositions can have the same source, label and  }
{       destination during overlapping time intervals.           }
{                                                                }
{ You should regard that this constraint is LESS restrictive     }
{ than in [CML 87]. We allow links with identical labels and     }
{ source if the destination is different.                        }
{ Please regard _propdescr as a candidate to be inserted in the  }
{ knowledge base.                                                }
{                                                                }
{ 07-Jun-1988: Now the restrictive version of (C3) is chosen ex- }
{ cept for the system labels '*instanceof' and '*isa'. ---MJf    }
{                                                                }
{ ************************************************************** }


Network_constraint_1(P(_id1,_x,_sl,_y)) :-
  systemLabel(_sl),
  retrieve_proposition(P(_id2,_x,_sl,_y)),
  _id1 \== _id2,
  !,
  report_error( SANC1, TelosAxioms, [objectName(_id1),
					objectName(_x),_sl,
					objectName(_y),
					objectName(_id2)]),
  fail.

Network_constraint_1(P(_id1,_x,_l,_y)) :-
  attribute(P(_id1,_x,_l,_y)),
  retrieve_proposition(P(_id2,_x,_l,_z)),
  _id1 \== _id2,
  !,
  report_error( NAMECONFLICT, TelosAxioms, [objectName(_x),_l]),
  fail.

Network_constraint_1(_).


{ ************************ S M L v a l i d ********************* }
{                                                                }
{ SMLvalid(_propdescr)                                           }
{   _propdescr: partial                                          }
{                                                                }
{ There are several strong restrictions which have to be ful-    }
{ filled by propositions in the KB.                              }
{ They reflect constraints on predefined labels of the SML       }
{ language: '*instanceof', '*isa' ...                            }
{                                                                }
{ 08-Jun-1988: Now, 'SMLvalid' checks all semantic integrity     }
{              constraints in order to generate all possible     }
{              error messages.                                   }
{               --- MJf                                          }
{                                                                }
{ 19-Dec-1989\TW: Individual_constraint is also tested           }
{                                                                }
{ ************************************************************** }


SMLvalid(_propdescr) :-
  pc_update('integrity@errors'(0)),

  CheckIntegrity(Network_constraint_1, _propdescr),
  CheckIntegrity(InstanceOf_constraint_1, _propdescr),
  CheckIntegrity(IsA_constraint_1, _propdescr),
  CheckIntegrity(IsA_constraint_2, _propdescr),
 'integrity@errors'(_x), { number of errors in Isa1 and 2}
  CheckIntegrity(IsA_constraint_3, _propdescr),
 'integrity@errors'(_x),  { evaluate Isa4 nur wenn no errors in Isa3, sonst endlose schleife.  HW/Nov-1997}
  CheckIntegrity(IsA_constraint_4, _propdescr),
  !,
  'integrity@errors'(0).   {no errors found --> success, otherwise:  fail}



{ *************** S M L v a l i d _ u n t e l l **************** }
{                                                                }
{                                             19-Dec-1988\TW     }
{ SMLvalid_untell(_propdescr)                                    }
{   _propdescr: partial                                          }
{                                                                }
{ There are several strong restrictions which have to be ful-    }
{ filled by propositions in the KB.                              }
{ They reflect constraints on predefined labels of the SML       }
{ language: '*instanceof', '*isa' ...                            }
{ This predicates tests, wether this restrictions are fullfilled }
{ after _propdescr  is untelled.                                 }
{ Propositions with transaction time in the fifth component are  }
{ not considered.                                                }
{                                                                }
{ ************************************************************** }


SMLvalid_untell(_propdescr) :-
  pc_update('integrity@errors'(0)),
  CheckIntegrity(InstanceOf_constraint_1_untell_1, _propdescr),
  CheckIntegrity(InstanceOf_constraint_1_untell_2, _propdescr),
  CheckIntegrity(InstanceOf_constraint_1_untell_3, _propdescr),
  CheckIntegrity(InstanceOf_constraint_1_untell_4, _propdescr),
  CheckIntegrity(InstanceOf_constraint_1_untell_5, _propdescr),
  CheckIntegrity(InstanceOf_constraint_1_untell_6, _propdescr),
  CheckIntegrity(IsA_constraint_1_untell_1, _propdescr),
   !,
  'integrity@errors'(0).



{ ================== }
{ Private predicates }
{ ================== }



{ **** i s _ p r o p e r _ s p e c i a l i z a t i o n _ o f *** }
{                                                                }
{ is_proper_specialization_of(_P,_Q)                             }
{   _P: any: ground:                                             }
{   _Q: any: ground:                                             }
{                                                                }
{ Succeeds if there is a chain of '*isa' propositions which      }
{ connects _P with _Q. So it implements the transitive           }
{ irreflexive closure of the '*isa' relation.                    }
{ Only explicit and derived '*isa' links are considered. Dealing }
{ with inherited '*isa' links would lead to infinite loops of    }
{ 'is_proper_specialization_of'.                                 }
{ Note that the duration of '*isa' links is assumed to be        }
{ "Always" for every such link (cf. [CML 87] p. 23).             }
{                                                                }
{ ************************************************************** }

is_proper_specialization_of(_P, _Q) :-
  retrieve_proposition(P(_id,_P,'*isa',_Q)),
  _P \== _Q
 {RS, 9.1. 1996: Wenn P == Q, dann Endlosschleife,
	    z.B. fuer Proposition isA Proposition}
 .

is_proper_specialization_of(_P, _Q) :-
  atom(_P),
  !,
  retrieve_proposition(P(_id,_P,'*isa',_P1)),
  _P1 \== _P,
  is_proper_specialization_of(_P1,_Q).

is_proper_specialization_of(_P, _Q) :-
  retrieve_proposition(P(_id,_Q1,'*isa',_Q)),
  _Q1 \== _Q, {RS, 9.1. 1996}
  is_proper_specialization_of(_P,_Q1).





{ *********** i s _ s p e c i a l i z a t i o n _ o f ********** }
{                                                                }
{ is_specialization_of(_P,_Q)                                    }
{   _P: any: ground:                                             }
{   _Q: any: ground:                                             }
{                                                                }
{ Succeeds if _P is a specialization of _Q, that is either       }
{ proper specialization or _P equals _Q. So it implements        }
{ the transitive reflexive closure of the '*isa' relation.       }
{                                                                }
{ ************************************************************** }

is_specialization_of(_P, _P):-
	ground(_P).

is_specialization_of(_P,id_0).  {* id_0=Proposition; 29-Oct-2002/M.Jeusfeld: anything is specialization of Proposition *}

is_specialization_of(_P, _Q) :-
  is_proper_specialization_of(_P,_Q).


{ ***************** C h e c k I n t e g r i t y **************** }
{                                                                }
{ CheckIntegrity(_constraint, _propdescr)                        }
{   _constraint: atom                                            }
{   _propdescr: ground                                           }
{                                                                }
{ CheckIntegrity just calls the goal "_constraint(_propdescr)".  }
{ If it succeeds, CheckIntegrity will also succeed. If it fails, }
{ the counter 'integrity@errors'(_i) is incremented and Check-   }
{ Integrity succeeds.                                            }
{ CheckIntegrity is used in 'SMLvalid' (see above).              }
{                                                                }
{ ************************************************************** }

CheckIntegrity(_constraint,_propdescr) :-
  atom(_constraint),

  ground(_propdescr),

  ( call_IC(_constraint,_propdescr);
    (
     'integrity@errors'(_i),
     _i1 is _i+1,
     pc_update('integrity@errors'(_i1)))
  ),

  !.


call_IC(Network_constraint_1, _x) :-
  Network_constraint_1(_x).

call_IC(IsA_constraint_1, _x) :-
  IsA_constraint_1(_x).

call_IC(IsA_constraint_2, _x) :-
  IsA_constraint_2(_x).

call_IC(IsA_constraint_3, _x) :-
  IsA_constraint_3(_x).

call_IC(IsA_constraint_4, _x) :-
  IsA_constraint_4(_x).

call_IC(InstanceOf_constraint_1, _x) :-
  InstanceOf_constraint_1(_x).

call_IC(InstanceOf_constraint_1_untell_1, _x) :-
  InstanceOf_constraint_1_untell_1(_x).

call_IC(InstanceOf_constraint_1_untell_2, _x) :-
  InstanceOf_constraint_1_untell_2(_x).

call_IC(InstanceOf_constraint_1_untell_3, _x) :-
  InstanceOf_constraint_1_untell_3(_x).

call_IC(InstanceOf_constraint_1_untell_4, _x) :-
  InstanceOf_constraint_1_untell_4(_x).

call_IC(InstanceOf_constraint_1_untell_5, _x) :-
  InstanceOf_constraint_1_untell_5(_x).

call_IC(InstanceOf_constraint_1_untell_6, _x) :-
  InstanceOf_constraint_1_untell_6(_x).

call_IC(IsA_constraint_1_untell_1, _x) :-
  IsA_constraint_1_untell_1(_x).



{ In folgenden Ueberpruefungen fuer Untell wird ein zusaetzliche Bedingung     }
{ eingesetzt wegen Retell-Operation. Denn es kann bei dem Retell folgende      }
{ passieren: man untell was P(*) und gleichzeitig P(*) wird nach untell        }
{ wieder getellt. Deswegen bevor man fuer ein P(*) die Pruefungen durchfuehren }
{ muss noch check ob diese fact ist nach wieder getellt.		       }
{ mit not retrieve_proposition(P(*))					       }


{ ****  I n s t a n c e _ o f _ c o n s t r ai n t _ 1 _ u n t e l l _ 1  *****}
{                                                                              }
{                                                             19-Dec-1988\TW   }
{  InstanceOf_constraint_1_untell_1(_propdescr)                                }
{     _propdescr: partial:ground                                               }
{                                                                              }
{                                                                              }
{ If _Q appears in an another Proposition, which is not also untelled, as      }
{ destination, _Q is not untelled. Untell would cause a violation of           }
{  'InstanceOf_constraint_1'.                                                  }
{                                                                              }
{ **************************************************************************** }

InstanceOf_constraint_1_untell_1(P(_Q,_x,_l,_y)) :-
\+(retrieve_proposition(P(_Q,_,_,_))), 		{ neue Bedingung}
 retrieve_proposition(P(_id2,_P,_label,_Q)),
 \+(retrieve_temp_del(P(_,_P,_label,_Q))),
 !,
 report_error(UNTELL3, TelosAxioms, [objectName(_Q),
				objectName(_id2),_label,
				objectName(_P)]),
 fail.

InstanceOf_constraint_1_untell_1(_).


{ ****  I n s t a n c e _ o f _ c o n s t r ai n t _ 1 _ u n t e l l _ 2  *****}
{                                                                              }
{                                                             19-Dec-1988\TW   }
{  InstanceOf_constraint_1_untell_2(_propdescr)                                }
{     _propdescr: partial:ground                                               }
{                                                                              }
{                                                                              }
{ If _P appears in an another Proposition, which is not also untelled, as      }
{ source, _P is not untelled. Untell would cause a violation of                }
{ 'InstanceOf_constraint_1'.                                                   }
{                                                                              }
{ **************************************************************************** }


InstanceOf_constraint_1_untell_2(P(_P,_x,_l,_y)) :-
\+(retrieve_proposition(P(_P,_,_,_))),	{ neue Bedingung}
 retrieve_proposition(P(_id2,_P,_label,_Q)),  {TL/9.3.94}
 { The method id2name(_Q,_Qname) , ... , _Qname == Individual, .... }
 { does not work, because Individual is a node, Attribute is a link and id2name }
 { returns the label-entry of the object, that is, in case of Attribute, attribute! }
 _IDofIndividual=id_7,
 _IDofInstanceOf=id_1,
 _IDofAttribute=id_6,
 _IDofIsA=id_15,
 (not(_Q == _IDofIndividual);not(_label == '*instanceof')),
 (not(_Q == _IDofInstanceOf);not(_label == '*instanceof')),
 (not(_Q == _IDofAttribute);not(_label == '*instanceof')),
 (not(_Q == _IDofIsA);not(_label == '*instanceof')),
  \+(retrieve_temp_del(P(_,_P,_label,_Q))),
 !,
 	write(error),nl,
  report_error(UNTELL4, TelosAxioms, [objectName(_P),
				objectName(_id2),_label,
				objectName(_Q)]),
  fail.

InstanceOf_constraint_1_untell_2(_).


{ ****  I n s t a n c e _ o f _ c o n s t r ai n t _ 1 _ u n t e l l _ 3  *****}
{                                                                              }
{                                                             19-Dec-1988\TW   }
{  InstanceOf_constraint_1_untell_3(_propdescr)                                }
{     _propdescr: partial:ground                                               }
{                                                                              }
{                                                                              }
{ If the source of an instanceof-proposition is source of a proposition _P,     }
{ and the destination is source of _Q , and _P is instance of _Q, then the     }
{ proposition is not untelled. Untell would cause a violation of               }
{ 'InstanceOf_constraint_1'.                                                   }
{                                                                              }
{ **************************************************************************** }


InstanceOf_constraint_1_untell_3(P(_id1,_fromP,'*instanceof',_fromQ)) :-
 \+(retrieve_proposition(P(_,_fromP,'*instanceof',_fromQ))),	{ neue Bedingung}
 retrieve_proposition(P(_Q,_fromQ,_l,_d)),
 not(_Q == _d),
 retrieve_proposition(P(_P,_fromP,_l1,_d1)),
 retrieve_proposition(P(_id4,_P,'*instanceof',_Q)),
 \+(retrieve_temp_del(P(_,_P,'*instanceof',_Q))),!,
 report_error(UNTELL5, TelosAxioms, [objectName(_id1),
				objectName(_fromP),
				objectName(_P),
				objectName(_fromQ),
				objectName(_Q)]),
 fail.


InstanceOf_constraint_1_untell_3(_).


{ ****  I n s t a n c e _ o f _ c o n s t r ai n t _ 1 _ u n t e l l _ 4  *****}
{                                                                              }
{                                                             19-Dec-1988\TW   }
{  InstanceOf_constraint_1_untell_4(_propdescr)                                }
{     _propdescr: partial:ground                                               }
{                                                                              }
{ If the source of an instanceof-proposition is destination of a proposition _P }
{ and the destination is destination of _Q and _P is instance of _Q, then the  }
{ proposition is not untelled. Untell would cause a violation of               }
{ 'InstanceOf_constraint_1'.                                                   }
{                                                                              }
{ **************************************************************************** }

InstanceOf_constraint_1_untell_4(P(_id1,_toP,'*instanceof',_toQ)) :-
 \+(retrieve_proposition(P(_,_toP,'*instanceof',_toQ))), 	{ neue Bedingung}
 retrieve_proposition(P(_Q,_s,_l,_toQ)),
 not(_Q == _s),
 retrieve_proposition(P(_P,_s1,_l1,_toP)),
 retrieve_proposition(P(_id4,_P,'*instanceof',_Q)),
 \+(retrieve_temp_ins(P(_,_P,'*instanceof',_Q))),!,
 report_error(UNTELL8, TelosAxioms, [objectName(_id1),
				objectName(_toP),
				objectName(_P),
				objectName(_toQ),
				objectName(_Q)]),
 fail.

InstanceOf_constraint_1_untell_4(_).


{ ****  I n s t a n c e _ o f _ c o n s t r ai n t _ 1 _ u n t e l l _ 5  *****}
{                                                                              }
{                                                             19-Dec-1988\TW   }
{  InstanceOf_constraint_1_untell_5(_propdescr)                                }
{     _propdescr: partial:ground                                               }
{                                                                              }
{                                                                              }
{ The untelling of an isa-relation between _V and _W may violate               }
{ InstanceOf_constraint_1, if:                                                 }
{ (1) The untelling causes, that _Q is no longe superclass of _P               }
{ (2) _P has an instance _P1 with attribute _A1                                }
{ (3) _A1 is instance of _A, which is attribute of _Q                          }
{ InstanceOf_constraint_1 would be violated, because from(_A1) == _P1 would    }
{ no longer be instance of from(_A) == _Q                                      }
{                                                                              }
{ **************************************************************************** }

{ 25.4. CQ,RS:
  Umordung der Literale im Rumpf}
InstanceOf_constraint_1_untell_5(P(_id1,_V,'*isa',_W)) :-

\+(retrieve_proposition(P(_,_V,'*isa',_W))), 	{ neue Bedingung}
 {Q ist Oberklasse von W}
 is_specialization_of(_W,_Q),

 {und hat ein Attribut id2}
 retrieve_proposition(P(_id2,_Q,_l,_d)),
 attribute(P(_id2,_Q,_l,_d)),

 {P ist Subklasse von V,
  aber nach der Loeschung von
  V isA W keine Subklasse mehr von Q}
 is_specialization_of(_P,_V),
 \+ is_specialization_of(_P,_Q),

 {Und hat eine Instanz P1}
 retrieve_proposition(P(_id3,_P1,'*instanceof',_P)),

 {mit einem Attribut der Kategorie _id2, welches nicht
  geloescht wurde}

 retrieve_proposition(P(_A1,_P1,_l1,_d1)),
 retrieve_proposition(P(_id5,_A1,'*instanceof',_id2)),
  \+(retrieve_temp_del(P(_,_P1,_l1,_d1))),

 !,
 report_error(UNTELL10, TelosAxioms, [objectName(_id1),
				objectName(_P),
				objectName(_P1),
				objectName(_A1),
				objectName(_id2),
				objectName(_Q)]),
 fail.

{ Wie vorher, nur gespiegelt 31.1.96/CQ}

InstanceOf_constraint_1_untell_5(P(_id1,_V,'*isa',_W)) :-
\+(retrieve_proposition(P(_,_V,'*isa',_W))), 	{ neue Bedingung}
 is_specialization_of(_W,_Q),
 retrieve_proposition(P(_id2,_d,_l,_Q)),
 attribute(P(_id2,_d,_l,_Q)),

 is_specialization_of(_P,_V),
 \+ is_specialization_of(_P,_Q),

 retrieve_proposition(P(_id3,_P1,'*instanceof',_P)),


 retrieve_proposition(P(_A1,_d1,_l1,_P1)),
 retrieve_proposition(P(_id5,_A1,'*instanceof',_id2)),
  \+(retrieve_temp_del(P(_,_d1,_l1,_P1))),

 !,
 report_error(UNTELL10b, TelosAxioms, [objectName(_id1),
				objectName(_P),
				objectName(_P1),
				objectName(_A1),
				objectName(_id2),
				objectName(_Q),
				objectName(_d),
				objectName(_d1)]),
 fail.

InstanceOf_constraint_1_untell_5(_).

{ ****  I n s t a n c e _ o f _ c o n s t r ai n t _ 1 _ u n t e l l _ 6  *****}
{                                                                              }
{                                                             19-Dec-1988\TW   }
{  InstanceOf_constraint_1_untell_6(_propdescr)                                }
{     _propdescr: partial:ground                                               }
{                                                                              }
{                                                                              }
{ The untelling of an instanceof-relation between P1 and P may violate         }
{ InstanceOf_constraint_1, if:                                                 }
{ (1) The untelling causes, that  P1 is no longe instance of Q  (P isa Q)      }
{ (2) P1 has attribute A1                                                      }
{ (3) A1 is instance of A, which is attribute of Q                             }
{ InstanceOf_constraint_1 would be violated, because from(_A1) == _P1 would    }
{ no longer be instance of from(_A) == _Q                                      }
{                                                                              }
{ +++/19-Jan-1989: The instantiation link to _Q may be given through another   }
{ path, different from _P !!!                           .-- Manfred Jeusfeld   }
{                                                                              }
{ **************************************************************************** }


InstanceOf_constraint_1_untell_6(P(_id1,_P1,'*instanceof',_P)) :-
\+(retrieve_proposition(P(_,_P1,'*instanceof',_P))), 	{ neue Bedingung}
 retrieve_proposition(P(_A1,_P1,_l1,_d1)),
 attribute(P(_A1,_P1,_l1,_d1)),
 retrieve_proposition(P(_id2,_A1,'*instanceof',_A)),
 retrieve_proposition(P(_A,_Q,_l,_d)),
 is_specialization_of(_P,_Q),
  \+ (retrieve_temp_del(P(_A1,_P1,_l1,_d1));
      prove_edb_literal(In_e(_P1,_Q))),  { +++ }
 !,
 report_error(UNTELL10, TelosAxioms, [objectName(_id1),
				objectName(_P),
				objectName(_P1),
				objectName(_A1),
				objectName(_A),
				objectName(_Q)]),
 fail.

InstanceOf_constraint_1_untell_6(_).

{ ************* I s A _ c o n s t r ai n t _ 1 _ u n t e l l _ 1  *************}
{                                                                              }
{                                                             19-Dec-1988\TW   }
{  IsA_constraint_1_untell_1(_propdescr)                                       }
{     _propdescr: partial:ground                                               }
{                                                                              }
{                                                                              }
{ The untelling of an isa-relation between O1 and O may violate                }
{ IsA_constraint_1, if:                                                        }
{ (1) The untelling causes, that  R is no longer superclass of R1              }
{ (2) There exists a proposition < A,Q,l,R,t> and < A1,P,l,R1,t1>              }
{ (3) P is specialization of Q                                                 }
{                                                                              }
{ **************************************************************************** }

IsA_constraint_1_untell_1(P(_id1,_O1,'*isa',_O)) :-
\+(retrieve_proposition(P(_,_O1,'*isa',_O))),  	{ neue Bedingung}
 is_specialization_of(_O,_R),
 is_specialization_of(_R1,_O1),
 retrieve_proposition(P(_A,_Q,_l,_R)),
 attribute(P(_A,_Q,_l,_R)),
 retrieve_proposition(P(_A1,_P,_l,_R1)),
 attribute(P(_A1,_P,_l,_R1)),
 is_specialization_of(_P,_Q),!,
 report_error(UNTELL9, TelosAxioms, [objectName(_id1),
				objectName(_R1),
				objectName(_A1),
				objectName(_R),
				objectName(_A),
				objectName(_P),
				objectName(_Q)]),
 fail.

IsA_constraint_1_untell_1(_).


