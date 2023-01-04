{*
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
*}
{
*
* File:        %M%
* Version:     %I%
* Creation:    9-Aug-1990, Manfred Jeusfeld (UPA)
* Last Change: %G%, Manfred Jeusfeld (UNITILB)
* Release:     %R%
* -----------------------------------------------------------------------------
*
* This module is part of the BDMIntegrityChecker. It provides procedures
* for relating literals to classes of the KB.
*
* 25-Jan-1993/DG: AttrValue is changed into A; AttrId into Ai;
* Prop into P; IsA into Isa; InstanceOf into In
* (by deleting the time component, see CBNEWS[154])
*
* 7-Jun-93/kvt: Adot is treated, too (for safety reasons)
*               minor bugfix in AdmissableConclusionClass/1
*
* 7-Sep-94/CQ: VarTabLookup returns only lists CB[176]
*
* 11-Jan-95/CQ: getConcernedClass: look also for attributes
*	of Proposition
*
* 23-Jun-95/CQ: Fehlermeldung NOCONCERNEDCLASS wird bei schwachen Literalen
*               (GT,LT,From,To,....) weggelassen.
* 2-Oct-03/M.Jeusfeld: ConcernedClass von A(x,l,y) bei variablen l ist
* Attribute
}




#MODULE(BDMLiteralDeps)
#EXPORT(AdmissableConclusionClass/1)
#EXPORT(ConcernedClass/2)
#EXPORT(ConcernedClass/4)
#EXPORT(WeakLiteral/1)
#EXPORT(noTriggerLiteral/2)
#ENDMODDECL()

#IMPORT(prove_literal/1,Literals)
#IMPORT(prove_upd_literal/1,Literals)
#IMPORT(retrieve_proposition/1,PropositionProcessor)
#IMPORT(getCC/3,Literals)
#IMPORT(GetEntry/3,BDMTransFormula)
#IMPORT(member/2,GeneralUtilities)
#IMPORT(WriteTrace/3,GeneralUtilities)
#IMPORT(length/2,GeneralUtilities)
#IMPORT(VarTabLookup/2,VarTabHandling)
#IMPORT(VarTabVariable/1,VarTabHandling)
#IMPORT(VarTabConstant/1,VarTabHandling)
#IMPORT(name2id/2,GeneralUtilities)
#IMPORT(id2name/2,GeneralUtilities)
#IMPORT(is_list/1,GeneralUtilities)
#IMPORT(report_error/3,ErrorMessages )
#IMPORT(pc_atomconcat/2,PrologCompatibility)
#IMPORT(pc_atomconcat/3,PrologCompatibility)
#IMPORT(is_id/1,MetaUtilities)
#IMPORT(getFlag/2,GeneralUtilities)
#IMPORT(checkArgLabel/1,MSFOLassertionTransformer)
#IMPORT(save_setof/3,GeneralUtilities)
#IMPORT(get_cb_feature/2,GlobalParameters)

#IF(SWI)
:- style_check(-singleton).
#ENDIF(SWI)


{***********************************************************}
{* ConcernedClass(_lit,_class)                             *}
{*  _lit: term (i)                                         *}
{*  _class: atom (o)                                       *}
{*                                                         *}
{* The literal _lit related to a class _class of the       *}
{* (current!) knowledge base with the following property:  *}
{* Instantiation of that class may affect the set of       *}
{* solutions of _lit.                                      *}
{*                                                         *}
{* All necessary information about variables is drawn out  *}
{* of the current variable table.                          *}
{***********************************************************}


ConcernedClass(_lit,_class) :-
  getConcernedClass(_lit,_class),
  WriteTrace(veryhigh,BDMLiteralDeps,
             [idterm(ConcernedClass(_lit)),'--->',idterm(_class)]),
  !.


ConcernedClass(_lit,_class) :-
  \+(WeakLiteral(_lit)),        { Keine Fehlermeldung fuer schwache Literale }
  getFlag(optimizeLevel,_ol),_ol > 0,   { Keine Fehlermeldung wenn optimizeRangeForm aus MetaRFormToAssText aufgerufen }
  WriteTrace(veryhigh,BDMLiteralDeps,['No class found concerning ',idterm(_lit)]),
  trigger_NOCONCERNEDCLASS(_lit),
  !,
  fail.


trigger_NOCONCERNEDCLASS(_lit) :-
  _lit = A(_x,_m,_y),
  report_error(NOCONCERNEDCLASS,BDMLiteralDeps,[_x,_m,formula(_lit)]),  {3-arg variant of error message}
  !.

trigger_NOCONCERNEDCLASS(_lit) :-
  report_error(NOCONCERNEDCLASS,BDMLiteralDeps,[formula(_lit)]),
  !.



{
               Dep's for A,Ai
               ==========================

                   R -----l------> Cy
                            ^
                            |
                            | __t
                            |
                   x -----j------> y
}

{ (a) Label quantified: not allowed since it makes it impossible to find }
{     a concerned class                                                  }

getConcernedClass(Adot(_cc,_,_),_cc) :- !.  { #195 }
getConcernedClass(Adot(_cc,_,_,_),_cc) :- !.
getConcernedClass(Adot_label(_cc,_,_,_),_cc) :- !. { #195 }
getConcernedClass(Aedot_label(_cc,_,_,_),_cc) :- !. { #330 }
getConcernedClass(Aedot(_cc,_,_),_cc) :- !.   {* ticket #207 *} { #195 }

getConcernedClass(A_label(_x,_ml,_y,_l),_cc) :-
	!,
	getConcernedClass(A(_x,_ml,_y),_cc).



getConcernedClass(A(_x,_l,_y), _class) :-
  VarTabVariable(_l),
  !,
  fail.


{ (b) Component _x is quantified: Range of _x is used to find the class }

{* _type kann auch eine Liste sein.Ich haette an dieser Stelle gerne eine sauberere Loesung.
*}

getConcernedClass(A(_x,_l,_y), _class) :-
  VarTabLookup(_x,_type),
	is_list(_type),
        getTypeMember(_R1,_type),
	checkArgLabel(_R1),   {* may not be tagged as 'UNKNOWN' *}
	prove_literal(Isa(_R1,_R)),
	\+(prove_literal(In(_R,id_65))),    {* id_65=QueryClass *}
  prove_literal(P(_class,_R,_l,_)),
  atom(_class),!.


{ (b1) Look in subclasses of type of x as well; see ticket #242 }

getConcernedClass(A(_x,_l,_y), _class) :-
  get_cb_feature(forceConcernedClass,'extended'),
  VarTabLookup(_x,_type),
  is_list(_type),
  getTypeMember(_R1,_type),
  checkArgLabel(_R1),   {* may not be tagged as 'UNKNOWN' *}
  save_setof(_c,isDefiningAttribute(_R1,_l,_c),_classes),  
  _classes = [_class],                                      {* result is unique *}
  !.

{ (b2) Look in subclasses of derived by DeepTelos as well; see issue #4 }

getConcernedClass(A(_x,_l,_y), _class) :-
  getCC('Proposition','ISA',_ISA),   {* DeepTelos ISA is defined *}
  VarTabLookup(_x,_type),
	is_list(_type),
        getTypeMember(_R1,_type),
	checkArgLabel(_R1),   {* may not be tagged as 'UNKNOWN' *}
        prove_upd_literal(Adot(_ISA,_Rx,_R)),
	\+(prove_literal(In(_R,id_65))),    {* id_65=QueryClass *}
  prove_literal(P(_class,_R,_l,_)),
  atom(_class),!.

{ (b3) Look in subclasses of derived by MLT-Telos as well; see issue #4 }

getConcernedClass(A(_x,_l,_y), _class) :-
  getCC('TYPE',specializes,_ISA),   {* MLT-Telos "specializes" is defined *}
  VarTabLookup(_x,_type),
	is_list(_type),
        getTypeMember(_R1,_type),
	checkArgLabel(_R1),   {* may not be tagged as 'UNKNOWN' *}
        prove_upd_literal(Adot(_ISA,_Rx,_R)),
	\+(prove_literal(In(_R,id_65))),    {* id_65=QueryClass *}
  prove_literal(P(_class,_R,_l,_)),
  atom(_class),!.


  

{ (c) _x is a constant, use it's classes to find concerned class }

getConcernedClass(A(_x,_l,_y), _class) :-
  VarTabConstant(_x),name2id(_x,_xID),
  prove_literal(In_eh(_xID,_R)), {* Find the most special class first 1-3-96/CQ *}
  prove_literal(P(_class,_R,_l,_)).


{ (d) Else: Look for _l in Proposition }

getConcernedClass(A(_x,_l,_y),_class) :-
	prove_literal(P(_class,id_0,_l,_)).   {* id_0=Proposition *}



{30-Nov-1990/MJf: concerned class of Ai,A_e is the same as for A }

getConcernedClass(Aidot(_cc,_,_),_cc) :- !.

getConcernedClass(Ai(_x,_l,_id),_class) :-
  getConcernedClass(A(_x,_l,_y), _class),
  !.

getConcernedClass(A_e(_x,_l,_id),_class) :-
  getConcernedClass(A(_x,_l,_y), _class),
  !.







{
               Dep's for In
               ====================

                 InstanceOf
                     ^
                     |
                     |
                     |
                x -------> c
                       \
                        t
}

{ (a) c is quantified: _class is InstanceOf                          }

getConcernedClass(In(_x,_c), _IDofInstanceOf) :-
  VarTabVariable(_c),
  name2id(InstanceOf,_IDofInstanceOf),
  !.

{ (b) c is a constant: c is the concerned class                     }

getConcernedClass(In(_x,_c), _c).

{* In_e and In_s have the same concerned class as In *}

getConcernedClass(In_s(_x,_c),_cc):-
  getConcernedClass(In(_x,_c),_cc).

getConcernedClass(In_e(_x,_c),_cc):-
  getConcernedClass(In(_x,_c),_cc).




{
               Dep's for IsA
               =============

                    IsA
                     ^
                     |
                     |
                     |
                c1 ====> c2
                      \
                        t
}


getConcernedClass(Isa(_c1,_c2), _IDofIsA):-
  name2id(IsA,_IDofIsA).

getConcernedClass(Isa_e(_c1,_c2), _IDofIsA):-
  name2id(IsA,_IDofIsA).



{* 28-May-2004: allow parameterized queries as well *}
getConcernedClass(_qlit,_qid) :-
   _qlit =.. [_qid|_],
   is_id(_qid),   {*   pc_atomconcat('id_',_,_qid),  *}
   id2name(_qid,_).


{* ticket #272: use Proposition as range of a variable if the *}
{* variable was declared like x/VAR in the formula.           *}
getTypeMember(id_0,['VAR']) :- !.   {* id_0=Proposition *}

getTypeMember(_R1,_types) :- 
    member(_R1,_types),
    _R1 \== 'VAR'.



{* find subclasses _class of _R1 that define an attribute with label _l *}

isDefiningAttribute(_R1,_l,_class) :-
  prove_literal(Isa(_R,_R1)),      {* look in subclasses of R1 *}
  prove_literal(P(_class,_R,_l,_)),
  \+(prove_literal(In(_R,id_65))).                     {* id_65=QueryClass *}




              { Fuer Regeln sind als "concerned class" InstanceOf und    }
              { IsA z.Zt. nicht zugelassen, da von ihnen zu viele andere }
              { Regeln und ICs abhaengen koennen.                        }

AdmissableConclusionClass(_class) :-
  _class \== In,
  _class \== Isa,
  !.

AdmissableConclusionClass(_class) :-
  WriteTrace(veryhigh,BDMLiteralDeps,[idterm(_class),
             ' not admitted as concerned class of the conclusion']),
  !,
  fail.




{ Schwache Literale sind solche, fuer die es keine "Concerned Class" }
{ gibt. Siehe auch BDMCompile und User Manual.                       }

WeakLiteral(_lit) :-
  member(_lit,[LT(_,_),
               GT(_,_),
               LE(_,_),
               GE(_,_),
               EQ(_,_),
               UNIFIES(_,_),
               NE(_,_),
               IDENTICAL(_,_),
               From(_,_),
               Label(_,_),
               To(_,_),
               When(_,_),
               Known(_,_),
               In2(_,_),
               A2(_,_,_)]),
  !.

{ Einfache Funktionen sind auch "weak", da ihr Ergebnis sich nur }
{ dann aendert, wenn sich die Eingabe aendert. }
WeakLiteral(_lit) :-
	_lit =.. [_id|_args],
	id2name(_id,_name),
	prove_literal(In(_id,_id_106)),   {* id_106 = Function *}
	!.


{* The literal _lit with concerned class _cc is not considered for *}
{* generating triggers.                                            *}
{* Reason 1: the concerned class is an immutable attribute; such   *}
{*           attributes are declared once for when their source    *}
{*           objects are declared; afterwards they never change;   *}
{*           hence, the trigger generated for the source object    *}
{*           is sufficient. (Ticket #358)                          *}
noTriggerLiteral(_cc,_lit) :-
  get_cb_feature(RangeFormOptimizing,_a),  {* only prune the trigger when optimizing mode is 4 or higher *}
  pc_inttoatom(_i,_a),
  _i > 3,
  getCC(Proposition,immutable,_immutable),
  prove_literal(In(_cc,_immutable)),
  !.





{ ******************* C o n c e r n e d C l a s s ******************** }
{                                                                      }
{ ConcernedClass(_vars,_ranges,_lit,_class)                            }
{   _vars: term (i)                                                    }
{   _ranges: list (i)                                                  }
{   _lit: term (i)                                                     }
{   _class: atom (o)                                                   }
{                                                                      }
{ The literal _lit with its variable bindings given by _ranges is      }
{ related to a class _class of the (current!) knowledge base with the  }
{ following property:                                                  }
{  Instantiation of that class may affect the set of solutions of _lit }
{ The parameter _vars has the form vars(_a,_b) where _a is the list    }
{ of all variables of the formula containing _lit and _b is the subset }
{ of variables that are allquantified and not within the scope of an   }
{ existential quantor.                                                 }
{                                                                      }
{ ******************************************************************** }


ConcernedClass(_vars,_ranges,_lit,_class) :-
  getConcernedClass(_vars,_ranges,_lit,_class),
  WriteTrace(veryhigh,BDMLiteralDeps,
             [idterm(ConcernedClass(_vars, _ranges, _lit)),'--->',idterm(_class)]),
  !.


ConcernedClass(_vars,_ranges,_lit,_class) :-
  \+(WeakLiteral(_lit)),            { Keine Fehlermeldung fuer schwache Literale }
  WriteTrace(veryhigh,BDMLiteralDeps,['No class found concerning ',idterm(_lit)]),
  trigger_NOCONCERNEDCLASS(_lit),
  !,
  fail.


{
               Dep's for A,Ai
               ==========================

                   R -----l------> Cy
                            ^
                            |
                            | __t
                            |
                   x -----j------> y
}



{ (a) Label quantified: not allowed since it makes it impossible to find }
{     a concerned class                                                  }

getConcernedClass(_v,_r,A_label(_x,_l,_y,_),_cc) :-
	!,
	getConcernedClass(_v,_r,A(_x,_l,_y),_cc).

getConcernedClass(vars(_a,_b),_ranges, A(_x,_l,_y), _class) :-
  member(_l,_a),   {Label is quantified!}
  !,
  fail.


{ (b) Component _x is quantified: Range of _x is used to find the class }

getConcernedClass(vars(_a,_b),_ranges,A(_x,_l,_y), _class) :-
  member(_x,_a),
  GetEntry(_ranges,_x,_Rx1),
  ((is_list(_Rx1),
	getTypeMember(_Rx,_Rx1)
   );
    \+(is_list(_Rx1)),
	_Rx = _Rx1
  ),
  prove_literal(Isa(_Rx,_R)),
  \+(prove_literal(In(_R,id_65))),  {* id_65=QueryClass *}
  prove_literal(P(_class,_R,_l,_)),
  atom(_class),!.


{ (b1) Look in subclasses of type of x as well; see ticket #242 }

getConcernedClass(vars(_a,_b),_ranges,A(_x,_l,_y), _class) :-
  get_cb_feature(forceConcernedClass,'extended'),
  member(_x,_a),
  GetEntry(_ranges,_x,_Rx1),
  ((is_list(_Rx1),
	getTypeMember(_Rx,_Rx1)
   );
    \+(is_list(_Rx1)),
	_Rx = _Rx1
  ),
  save_setof(_c,isDefiningAttribute(_Rx,_l,_c),_classes),  
  _classes = [_class],                                      {* result is unique *}
  !.


{ (b2) Look in subclasses of derived by DeepTelos as well; see issue #4 }

getConcernedClass(vars(_a,_b),_ranges,A(_x,_l,_y), _class) :-
  retrieve_proposition(P(_ISA,id_0,ISA,id_0)),  {* DeepTelos ISA is defined *}
  member(_x,_a),
  GetEntry(_ranges,_x,_Rx1),
  ((is_list(_Rx1),
	getTypeMember(_Rx,_Rx1)
   );
    \+(is_list(_Rx1)),
	_Rx = _Rx1
  ),
  prove_upd_literal(Adot(_ISA,_Rx,_R)),
  \+(prove_literal(In(_R,id_65))),  {* id_65=QueryClass *}
  prove_literal(P(_class,_R,_l,_)),
  atom(_class),!.


{ (c) Else: _x is a constant, use it's classes to find concerned class }

getConcernedClass(_vars,_ranges,A(_x,_l,_y), _class) :-
  id2name(_x,_),              { check, if _x really is an id TL/24.1.96 }
  prove_literal(In_eh(_x,_R)), {* Find the most special class first 1-3-96/CQ *}
  prove_literal(P(_class,_R,_l,_)).


{ (d) Else: Look for _l in Proposition }

getConcernedClass(_vars,_ranges,A(_x,_l,_y),_class) :-
	prove_literal(P(_class,id_0,_l,_)).   {* id_0=Proposition *}


{30-Nov-1990/MJf: concerned class of Ai,A_e is the same as for A }

getConcernedClass(_vars,_ranges,Ai(_x,_l,_id),_class) :-
  getConcernedClass(_vars,_ranges,A(_x,_l,_y), _class),
  !.

getConcernedClass(_vars,_ranges,A_e(_x,_l,_id),_class) :-
  getConcernedClass(_vars,_ranges,A(_x,_l,_y), _class),
  !.



{* 7-Jun-1993/kvt: for safety reasons: ConcernedClass of an Adot and Aidot Literal *}

getConcernedClass(_,_,Adot(_cc,_,_),_cc) :- !.  { #195 }
getConcernedClass(_,_,Adot(_cc,_,_,_),_cc) :- !.
getConcernedClass(_,_,Adot_label(_cc,_,_,_),_cc) :- !. { #195 }
getConcernedClass(_,_,Aedot_label(_cc,_,_,_),_cc) :- !. { #330 }

getConcernedClass(_,_,Aidot(_cc,_,_),_cc) :- !.

getConcernedClass(_,_,Aedot(_cc,_,_),_cc) :- !.   {* ticket #207 *} { #195 }



{
               Dep's for In
               ====================

                 InstanceOf
                     ^
                     |
                     |
                     |
                x -------> c
                       \
                        t
}

{ (a) c is quantified: _class is InstanceOf                          }

getConcernedClass(vars(_a,_b),_ranges,In(_x,_c), _InstanceOfID) :-
  member(_c,_a),
  name2id(InstanceOf,_InstanceOfID),
  !.

{ (b) c is a constant: c is the concerned class                     }

getConcernedClass(_vars,_ranges,In(_x,_c), _c).

{* In_e and In_s have the same concerned class as In *}

getConcernedClass(vars(_a,_b),_ranges,In_s(_x,_c),_cc):-
  getConcernedClass(vars(_a,_b),_ranges,In(_x,_c),_cc).

getConcernedClass(vars(_a,_b),_ranges,In_e(_x,_c),_cc):-
  getConcernedClass(vars(_a,_b),_ranges,In(_x,_c),_cc).




{
               Dep's for IsA
               =============

                    IsA
                     ^
                     |
                     |
                     |
                c1 ====> c2
                      \
                        t
}


getConcernedClass(_vars,_ranges,Isa(_c1,_c2), _IsAID):-
	name2id(IsA,_IsAID).

getConcernedClass(_vars,_ranges,Isa_e(_c1,_c2), _IsAID):-
        name2id(IsA,_IsAID).




              { Fuer Regeln sind als "concerned class" InstanceOf und    }
              { IsA z.Zt. nicht zugelassen, da von ihnen zu viele andere }
              { Regeln und ICs abhaengen koennen.                        }

{* 28-May-2004: allow parameterized queries as well *}
getConcernedClass(_,_,_qlit,_qid) :-
   _qlit =.. [_qid|_],
   is_id(_qid),   {* pc_atomconcat('id_',_,_qid), *}
   id2name(_qid,_).



