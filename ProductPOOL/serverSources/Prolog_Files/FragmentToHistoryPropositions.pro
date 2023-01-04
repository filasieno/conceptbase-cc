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
*
* File:         FragmentToHistoryPropositions.pro
* Version:      11.5
*
*
* Date released : 97/02/12  (YY/MM/DD)
*
* SCCS-Source-Pool : /home/CBase/CB_NewStruct/ProductPOOL/serverSources/Prolog_Files/SCCS/s.FragmentToHistoryPropositions.pro
* Date retrieved : 97/04/29 (YY/MM/DD)
* ----------------------------------------------------------
*
* This Prolog module is part of the ConceptBase system which is a
* run-time system for the System Modelling Language (SML).
* This module contains the predicates necessary for transforming a
* SMLfragment into a set of propvals and then to store them as
* history propvals.
*
* 22-Dec-1989/MJf: untell_property reimplemented (new name untell_attrdecl)
*
* 13-Mar-90/MSt : untell of derive expressions
* 19-Jun-1990/MJf: replace INDIVIDUALCLASS by CLASS
*
* 25.07.1990 RG:        Modified DELETE to use the new proposition/6 format.
* 25-Jul-1991/MJf: more natural UNTELLing of omega classes, see CBNEWS[133]
*13-Jan-1992/MSt : UNTELLING of single(!) objects without any connection to others
*                       simplified (e.g. 'UNTELL o'  instead of 'UNTELL Individual o'
*
* 7-Dec-1992/kvt: Format of smlfragment changed (cf. CBNEWS[148])
*
* 1-Sep-93/Tl: retrieve_proposition calls with constant objects at Src or Dst entry
* are changed into a name2id(...,_id),retr_prop(..,_id,..) combination. The old
* construction didn't work with an extern retrieve_proposition
*
* 9-Dez-1996/LWEB: retrieve_temp_proposition$Rep_temp/1 Aufrufe wurden durch
* retrieve_temp$PropositionProcessor/1 ersetzt.
*
* Exported predicates:
* --------------------
*
*   + do_untell_Object/1
*      the UNTELL-operation is made on the SML-fragment arg1.
*
* Metaformel-Aenderungen (10.1.96):
* untell_Assertion wird in zwei Praedikate aufgespaltet:
*  untell_MetaAssertion
*  loescht eine Metaformel,
*  alle aus ihr generierten Formel und alle zu ihr
*  gehoerenden Trigger
*
*  untell_SimpleAssertion
*  altes untell_Assertion
*
*  neues Praedikat untell_generatedAssertions zum Loeschen
*  von aus Metaformeln generierten Formeln
*
*
}

{:- setdebug.}

#MODULE(FragmentToHistoryPropositions)
#EXPORT(DELETE/1)
#EXPORT(do_untell_Object/2)
#EXPORT(untell_generatedAssertions/3)
#EXPORT(untell_in/2)
#EXPORT(untell_isa/2)
#EXPORT(untell_with/2)
#ENDMODDECL()

#IMPORT(find_attributeclasses/3,FragmentToPropositions)
#IMPORT(getAssertionClass/2,FragmentToPropositions)
#IMPORT(generateMetaFormulaClassName/2,FragmentToPropositions)
#IMPORT(retrieve_proposition/1,PropositionProcessor)
#IMPORT(retrieve_proposition_noimport/2,PropositionProcessor)
#IMPORT(retrieve_temp_del/1,PropositionProcessor)
#IMPORT(systemOmegaClass/1,validProposition)
#IMPORT(report_error/3,ErrorMessages)
#IMPORT(increment/1,GeneralUtilities)
#IMPORT(member/2,GeneralUtilities)
#IMPORT(save_setof/3,GeneralUtilities)
#IMPORT(assertion_string/1,validProposition)
#IMPORT(untell_BDMIntegrityConstraint/1,BDMIntegrityChecker)
#IMPORT(untell_BDMRule/1,BDMIntegrityChecker)
#IMPORT(untell_BDMProcTrigger/1,BDMIntegrityChecker)
#IMPORT(untell_Rule/1,LTstubs)
#IMPORT(prove_literal/1,Literals)
#IMPORT(prove_edb_literal/1,Literals)
#IMPORT(checkToEmptyCacheOnUpdate/0,Literals)
#IMPORT(untell_query/1,QueryCompiler)
#IMPORT(get_QueryStruct/2,QueryCompiler)
#IMPORT(untell_ecarule/1,ECAruleCompiler)
#IMPORT(update_ecarule_del/1,ECAruleCompiler)
#IMPORT(eval/3,SelectExpressions)
#IMPORT(id2name/2,GeneralUtilities)
#IMPORT(name2id/2,GeneralUtilities)
#IMPORT(select2id/2,GeneralUtilities)
#IMPORT(set_overrule_act_bim2c/0,BIM2C)
#IMPORT(WriteUpdate/3,GeneralUtilities)
#IMPORT(remove/1,BIM2C)
#IMPORT(removetmp/1,BIM2C)
#IMPORT(pc_update/1,PrologCompatibility)
#IMPORT(pc_atomconcat/2,PrologCompatibility)
#IMPORT(pc_atomconcat/3,PrologCompatibility)
#IMPORT(pc_inttoatom/2,PrologCompatibility)
#IMPORT(pc_atom_to_term/2,PrologCompatibility)
#IMPORT(reset_counter_if_undefined/1,GeneralUtilities)
#IMPORT(retrieve_temp_ins/1,PropositionProcessor)
#IMPORT(get_cb_feature/2,GlobalParameters)
#IMPORT(set_prolog_KBsearchSpace/2,SearchSpace)
#IMPORT(get_prolog_KBsearchSpace/2,SearchSpace)
#IMPORT(setCheckUpdateModeIfCacheKept/0,FragmentToPropositions)
#IMPORT(makeId/1,cbserver)
#IMPORT(is_id/1,MetaUtilities)

#IF(SWI)
:- style_check(-singleton).
#ENDIF(SWI)



{ =================== }
{ Exported predicates }
{ =================== }



{ *************** d o _ u n t e l l _ O b j e c t **************** }
{                                                                  }
{ do_untell_Object(_SMLfragment)                                   }
{   _SMLfragment: ground                                           }
{                                                                  }
{ the SML-fragment _SMLfragment is untelled. First it is transla-  }
{ ted into 'temp' propvals. Then several untell-constraints are    }
{ prooved. At last, the corresponding propvals are deleted and     }
{ stored as history-propvals. Also the 'temp'-propvals are removed.}
{                                                                  }
{ **************************************************************** }


do_untell_Object(_x,_y) :-
   reset_counter_if_undefined('error_number@F2HP'),
   checkToEmptyCacheOnUpdate,    {* will empty the cache in Literals.pro *}
   fail.

do_untell_Object(SMLfragment(what(_objdescr),               {13-Jan-92/MSt}
                 in_omega([class(_omegaclass)]),
                 in([]),isa([]),
                 with([])),0) :-
  name2id(_objdescr,_objID),
  systemOmegaClass(_omegaclass),
  prove_edb_literal(In_e(_objID,_omegaclass)),
  DELETE(P(_objID,_a1,_a2,_a3)),
  !.

do_untell_Object(SMLfragment(what(_objdescr),
                 in_omega([]),
                 in([]),isa([]),
                 with([])),0) :-
  name2id(_objdescr,_objID),
  DELETE(P(_objID,_a1,_a2,_a3)),
  !.

do_untell_Object(SMLfragment(what(_objdescr),               {13-Jan-92/MSt}
                 in_omega(_),
                 in([]),isa([]),
                 with([])),_errno) :-
  report_error( FPNTE, FragmentToHistoryPropositions, [objectName(_objdescr)]),
  increment('error_number@F2HP'),
  'error_number@F2HP'(_errno),
  !.

do_untell_Object(SMLfragment(what(_objdescr),
                 in_omega(_OmegaList),
                 in(_InstanceList),isa(_IsAList),
                 with(_AttributeList)),0) :-
     name2id(_objdescr,_objID),
     identify_object(_objID),
     untell_in_omega(_objID,_OmegaList),
     untell_in(_objID,_InstanceList),
     untell_isa(_objID,_IsAList),
     untell_with(_objID,_AttributeList),
     untell_if_query(what(_objID)),
     untell_if_ecarule(what(_objID)),
     untell_inSysClass_if_cleanup(_objID),
     !.

do_untell_Object(SMLfragment(what(_e),_,_,_,_), _errno) :-
  report_error( FPNTE, FragmentToHistoryPropositions, [objectName(_e)]),
  increment('error_number@F2HP'),
  'error_number@F2HP'(_errno),
  !.


do_untell_Object(_e, 1) :-
  report_error( FPWSF, FragmentToHistoryPropositions, [_e]),
  !.



{ =================== }
{ Private predicates: }
{ =================== }





{ *************** u n t e l l _ i f _ q u e r y ********************}
{                                                                   }
{ ******************************************************}
{22-07-1993/MSt}

untell_if_query(what(_q)) :-
     {1-Sep-93/Tl}
     { Query soll komplett untelled werden --> ok }
     (retrieve_temp_del(P(_,_q,'*instanceof',id_65));    {* id_65=QueryClass *}
     retrieve_temp_del(P(_,_q,'*instanceof',id_72))      {* id_72=GenericQueryClass *}
    ),
	untell_queryattr_isa(_q),
    untell_query(_q).

untell_if_query(what(_q)) :-
	retrieve_temp_del(P(_,_q,'*instanceof',id_80)),    {* id_80=View *}
	untell_query(_q). { sollte vielleicht mal spezielles untell_view sein, dass auch SubViews, etc. loescht }

untell_if_query(what(_q)) :-
    { (Teil einer) BuiltinQuery untellen --> ok (nichts tun) }
    prove_edb_literal(In_s(_q,id_77)).  {* id_77=BuiltinQueryClass *}

untell_if_query(what(_q)) :-
    { Teil einer 'normalen' Query untellen --> nicht erlaubt }
     prove_edb_literal(In_e(_q,id_65)),    {* id_65=QueryClass *}
     retrieve_temp_del(P(_,_q,_,_)),
     !,report_error(QLERR10,FragmentToHistoryPropositions,[objectName(_q)]),
      increment('error_number@F2HP'),
     fail.

untell_if_query(_).
    { keine Query }


{Hier fuer den fall:
zB
QueryClass test1 isA Employee with retrieved_attribute salary:Integer end
QueryClass test2 isA test2 with retrieved_attribute salary:Integer end
dann wenn man test2 untell will, muss auch alle attribute_isa_link
zur superClass test1geloscht werden, wie zB test2!salary==>test1!salary
 entspricht auch fuer computed attribute,parameter...}

untell_queryattr_isa(_q):-
(get_QueryStruct(_q,[this|_s]);get_QueryStruct(_q,[_s])),
get_all_attr_labels(_s,_labellist),
	id2name(_q,_qname),
remove_all_isa_link(_qname,_labellist).


get_all_attr_labels([],[]):-!.
get_all_attr_labels([r(_l)|_r],[_l|_rlabellist]):-
	get_all_attr_labels(_r,_rlabellist).
get_all_attr_labels([rp(_l,_)|_r],[_l|_rlabellist]):-
	get_all_attr_labels(_r,_rlabellist).
get_all_attr_labels([c(_l)|_r],[_l|_rlabellist]):-
	get_all_attr_labels(_r,_rlabellist).
get_all_attr_labels([cp(_l,_)|_r],[_l|_rlabellist]):-
	get_all_attr_labels(_r,_rlabellist).
get_all_attr_labels([p(_l,_)|_r],[_l|_rlabellist]):-
	get_all_attr_labels(_r,_rlabellist).

remove_all_isa_link(_qname,[]).
remove_all_isa_link(_qname,[_label|_rlabellist]):-
	eval(select(_qname,'!',_label),replaceSelectExpression,_lid),
	retrieve_proposition(P(_id,_lid,'*isa',_sid)),
	DELETE(P(_id,_lid,'*isa',_sid)),
	remove_all_isa_link(_qname,_rlabellist).
remove_all_isa_link(_qname,[_label|_rlabellist]):-			{Hier fuer den fall, fuer qname!label keine isa Beziehung gibt.}
	remove_all_isa_link(_qname,_rlabellist).
{*******************************************************************}
{                                                                   }
{ untell_if_ecarule(_what)                                          }
{                                                                   }
{ Description of arguments:                                         }
{    what : what(_oid)                                              }
{                                                                   }
{ Description of predicate:                                         }
{   Deletes the ecarule oid.                                        }
{*******************************************************************}

#MODE((untell_if_ecarule(i)))


{ Ganze Regel loeschen }
untell_if_ecarule(what(_id)) :-
	retrieve_temp_del(P(_,_id,'*instanceof',id_1403)),   {* id_1403=ECArule *}
	!,
	untell_ecarule(_id).

{ Irgendwas von Regel loeschen }
untell_if_ecarule(what(_id)) :-
	retrieve_proposition(P(_,_id,'*instanceof',id_1403)),  {* id_1403=ECArule *}
	!,
	update_ecarule_del(_id).

{ ecarule!active loeschen }
untell_if_ecarule(what(_lid)) :-
	retrieve_temp_del(P(_,_lid,'*instanceof',id_1411)),   {* id_1411=ECArule!active *}
	!,
	retrieve_proposition(P(_,_ecaid,'*instanceof',id_1403)),   {* id_1403=ECArule *}
	(retrieve_temp_del(P(_lid,_ecaid,_,_));
	 retrieve_proposition(P(_lid,_ecaid,_,_))
	),
	!,
	update_ecarule_del(_ecaid).


untell_if_ecarule(_).

{ *************** u n t e l l _ i n _ o m e g a ****************** }
{                                                                  }
{  untell_in_omega(_objdescr,_classlist)                           }
{     _objdescr: ground                                            }
{     _classlist : ground                                          }
{                                                                  }
{ removes the instantiation-links to omega-classes from the current}
{ propositions and transforms them to the history propositions     }
{                                                                  }
{ **************************************************************** }

untell_in_omega(_objdescr,_classlist) :-
  untell_in(_objdescr,_classlist).        {25-Jul-1991/MJf: no difference}




{ ******************* u n t e l l _i n  **************************** }
{                                                                    }
{ untell_in(_objdescr,_in)                                           }
{   _objdescr: ground                                                }
{   _in: ground                                                      }
{                                                                    }
{                                                                    }
{ removes the instantiation-links from the current propositions      }
{ and transforms them to history propositions.                       }
{                                                                    }
{ ****************************************************************** }


untell_in(_objdescr,[]) :- !.

{ ... if _class is a systemOmegaClass (Individual,Attribute,InstanceOf,IsA) }
{ then the _objdescr itself is going to be deleted:                         }

untell_in(_objdescr,[class(_classID)|_classList]) :-
  systemOmegaClass(_classID),
  prove_edb_literal(In_e(_objdescr,_classID)),
  DELETE(P(_objdescr,_x,_l,_y)),
  !,
  untell_in(_objdescr,_classList).


untell_in(_objdescr,[class(_class)|_classList]) :-

 name2id(_class,_classID),
 DELETE(P(_id1,_objdescr,'*instanceof',_classID)),
 !,
 untell_in(_objdescr,_classList).



untell_in(_objdescr,[class(_class)|_classList]) :-
 report_error(UNTELL1, FragmentToHistoryPropositions,
              [objectName(_objdescr),'instance',objectName(_class)]),
  increment('error_number@F2HP'),
  !,
  fail.




{ untell_inSysClass_if_cleanup(_x)                                   }
{                                                                    }
{ removes the instantiation-links from the current propositions      }
{ to its system omega class if                                       }
{   a) the untell mode is 'cleanup' and                              }
{   b) x has no properties (attributes, classes, superclasses) after }
{      the current transaction                                       }
{   c) no other object uses x (as class, superclass or attribute)    }


untell_inSysClass_if_cleanup(_x) :-
  get_cb_feature(UntellMode,cleanup),
  get_KBsearchSpace(_OB,_RBT),
  set_KBsearchSpace(currentOB,Now),
  do_untell_inSysClass(_x),
  set_KBsearchSpace(_OB,_RBT),
  !.

{* else: do nothing *}
untell_inSysClass_if_cleanup(_x).


do_untell_inSysClass(_x) :-
  hasNoOutgoingLink(_x),
  hasNoIncomingLink(_x),
  DELETE(P(_x,_x1,_m,_y1)),
  !.
do_untell_inSysClass(_).

hasNoOutgoingLink(_x) :-
  retrieve_proposition(P(_id,_x,_n,_y)),
  _id \== _x,  {* individuals are not links of themselves *}
  !,
  fail.
hasNoOutgoingLink(_x).

hasNoIncomingLink(_x) :-
  retrieve_proposition(P(_id,_y,_n,_x)),
  _id \== _x,  {* individuals are not links of themselves *}
  !,
  fail.
hasNoIncomingLink(_x).






{ ******************* u n t e l l _ i s a  ************************* }
{                                                                    }
{ untell_isa(_objdescr,_isa)                                         }
{   _objdescr: ground                                                }
{   _isa: ground                                                     }
{                                                                    }
{ removes the isa-links from the current propositions                }
{ and transforms them to history propositions.                       }
{                                                                    }
{ ****************************************************************** }

untell_isa(_objdescr,[]) :- !.


untell_isa(_objdescr,[class(derive(_q,_sl))|_classList]) :-
 retrieve_proposition(P(_id,_objdescr,'*isa',_dq)),
 retrieve_proposition(P(_dq,_dq,_l,_dq)),
 atom(_l),
 _l \=='-',
 pc_atom_to_term(_l,_lt),
 _lt = derive(_q,_sl),
 !,
 DELETE(P(_id,_objdescr,'*isa',_dq)),
 untell_if_derivedQuery(_class),
 untell_isa(_objdescr,_classList).


untell_isa(_objdescr,[class(_class)|_classList]) :-
 _class \= derive(_,_),
 makeId(_class,_cid),    {* make sure that _cid is an object id; ticket #150          *}
 is_id(_cid),            {* makeId returns _class if there is no such id; ticket #225 *}
 DELETE(P(_id1,_objdescr,'*isa',_cid)),
 !,
 untell_isa(_objdescr,_classList).


untell_isa(_objdescr,[class(_class)|_classList]) :-
  report_error(UNTELL1, FragmentToHistoryPropositions,
               [objectName(_objdescr),'specialization',objectName(_class)]),
  increment('error_number@F2HP'),
  !,
  fail.




{ ******************* u n t e l l _ wi t h   *********************** }
{                                                                    }
{ untell_with(_objdescr,_with)                                       }
{   _objdescr: ground                                                }
{   _with: ground                                                    }
{                                                                    }
{                                                                    }
{ removes the attribute-links of the list in arg 2 from the          }
{ current propositions and transforms them to history propositions.  }
{                                                                    }
{ 20-Dec-1989/MJf: untell for more than one attribute category       }
{                                                                    }
{ ****************************************************************** }

untell_with(_objdescr,[]) :- !.

untell_with(_objdescr,
            [attrdecl(_attrcategorylist,_propertyList)|_attributeList]) :-
 untell_attrdecl(_objdescr,attrdecl(_attrcategorylist,_propertyList)),!,
 untell_with(_objdescr,_attributeList).





{ **************** u n t e l l _ a t t r d e c l ******************* }
{                                                                    }
{ untell_attrdecl(_objdescr,_attrdecl)                               }
{   _objdescr: ground                                                }
{   _attrdecl: ground                                                }
{                                                                    }
{ Removes the information given by _attrdecl for object _objdescr.   }
{ This procedure was previously named 'untell_property'.             }
{                                                                    }
{                                                    22-Dec-1989/MJf }
{ ****************************************************************** }

untell_attrdecl(_objdescr, attrdecl(_attrcategorylist,_propertyList)) :-
 find_attributeclasses(_objdescr,_attrcategorylist,_AClist),
 untell_properties(_objdescr,_AClist,_propertyList).



{ *************** u n t e l l _ p r o p e r t i e s **************** }
{                                                                    }
{ untell_properties(_objdescr,_AClist,_propertyList)                 }
{                                                                    }
{ Untell the instantiation of all attributes given by _propertyList  }
{ to the attribute classes in _AClist.                               }
{ ****************************************************************** }

untell_properties(_objdescr,_AClist,[]) :- !.

untell_properties(_objdescr,_AClist,[property(_label,_dest)|_rest]) :-
  name2id(_dest,_d),
  getAttributeId(_id1,_objdescr,_label,_d),
  !,
  untell_instanceOfAttrClass(_id1,_d,_AClist),
  untell_attr_isa(_id1,_label),
  untell_inSysClass_if_cleanup(_id1),  {* see ticket #98 *}
  untell_properties(_objdescr,_AClist,_rest).

untell_properties(_objdescr,_,[property(_label,_dest)|_]) :-
  report_error(UNTELL2, FragmentToHistoryPropositions,
              [objectName(_objdescr),_label,objectName(_dest),Now]),
  increment('error_number@F2HP'),
  !,fail.


{* we already know the attribute id *}
getAttributeId(_id,_objdescr,id(_id),_d) :- !.

{* we only know the label *}
getAttributeId(_id,_objdescr,_label,_d) :-
  retrieve_proposition(P(_id,_objdescr,_label,_d)).



{loschen attribute link zur superclass, siehe auch oben bei untell_if_Query.}
untell_attr_isa(_attrid,_label):-
	retrieve_proposition(P(_id,_attrid,'*isa',_sid)),
	DELETE(P(_id,_attrid,'*isa',_sid)).

untell_attr_isa(_objdescr,_label).

{ ****** u n t e l l _ i n s t a n c e O f A t t r C l a s s ******* }
{                                                                    }
{ untell_instanceOfAttrClass(_id1,_dest,_AClist)                     }
{                                                                    }
{ Untell the instantiation of the attribute with name _id1 to the    }
{ classes in _AClist. If ATTRIBUTE is in _AClist then _id1 itself is }
{ removed from the current KB.                                       }
{                                                    22-Dec-1989/MJf }
{                                                    14-Feb-1989/MSt }
{ ****************************************************************** }

untell_instanceOfAttrClass(_id1,_dest,[]) :- !.

{*** untelling the attribute itself: }

untell_instanceOfAttrClass(_id1,_d,[id_6|_rest]) :-   {* id_6=Attribute *}
  DELETE(P(_id1,_objdescr,_label,_d)),
  !,
  untell_if_derivedQuery(_d),
  untell_assertion(_d),
  untell_instanceOfAttrClass(_id1,_d,_rest).

{*** untelling a class of the attribute: }

untell_instanceOfAttrClass(_id1,_d,[_ac1|_rest]) :-  
  _ac1 \= id_6,    {* id_6=Attribute *}
  !,
  DELETE(P(_id2,_id1,'*instanceof',_ac1)),
  untell_if_assertion(_d,_ac1),
  untell_instanceOfAttrClass(_id1,_d,_rest).

{*** else }

untell_instanceOfAttrClass(_id1,_dest,[_ac1|_rest]) :-
  report_error(UNTELL14, FragmentToHistoryPropositions,
              [objectName(_id1),objectName(_ac1)]),
  !,
  fail.


{ ****************** u n t e l l _ a s s e r t i o n *************** }
{                                                                    }
{ untell_assertion(_id)                                              }
{                  _id : ground                                      }
{                                                                    }
{ assertion with identifier _id is removed together with its         }
{ instantiation links to INDIVIDUAL and CLASS.                       }
{                                                                    }
{ 19-Jun-1990/MJf: CLASS instead INDIVIDUALCLASS, see also procedure }
{ store_assertionproperty of module FragmentToPropositions.          }
{                                                                    }
{ 30-Nov-1990/MJf: Now, assertions are no longer declared as         }
{ instances of CLASS, see also CBNEWS[110].                          }
{                                                                    }
{                                                      14-Feb-1989   }
{ ****************************************************************** }


untell_assertion(_assID) :-
	(untell_MetaAssertion(_assID),!);
	(untell_SimpleAssertion(_assID)).
untell_assertion(_).

{* neuer Fall fuer Metaformeln:
	ist die zu loeschende Formel eine Metaformel, dann muessen folgende Objekte
	geloescht werden:
	1. Die Metaformel selbst
	2. Alle Instanzen dieser Formel (generierte Formeln)
	3. Alle Einfuege- und Loeschtrigger, die zu der Metaformel gehoeren
*}
untell_MetaAssertion(_metaFormulaId) :-
	{*test, ob Formel Metaformel:}
	getAssertionClass(_,_possibleClass),
	generateMetaFormulaClassName(_possibleClass,_metaFormulaCategory),
	name2id(_metaFormulaCategory,_mfCatId),
	prove_edb_literal(In(_metaFormulaId,_mfCatId)),!,

	{* finden und loeschen aller Instanzen der Metaformel *}
	save_setof(_assId,prove_edb_literal(In(_assId,_metaFormulaId)),_assertionsToDelete),
	getAssertionClass(_mode,_possibleClass),
	untell_generatedAssertions(_assertionsToDelete,_metaFormulaId,_mode),
	untell_in(_metaFormulaId,[class(_mfCatId)]),

	{* loeschen der Metaformel und der zugehoerigen Trigger *}
	untell_BDMProcTrigger([_metaFormulaId]),
	untell_SimpleAssertion(_metaFormulaId).



untell_generatedAssertions([],_,_).
untell_generatedAssertions([_as|_assertions],_metaFormulaId,_mode) :-
	{* test, ob generierte Formel *}
	retrieve_proposition(P(_id,_class,_label,_as)),
        _id \== _class,                                  {* id is an attribute, not an individual *}
	pc_atomconcat(_genIDPart1,'generated',_label),   {* label is generated by ConceptBase *}

	{* loeschen der isa-Beziehung zur Metaformel (ticket #152) *}
	DELETE(P(_id1,_as,'*isa',_metaFormulaId)),!,

        {* ggf. generierten Hint bei _id loeschen *}
        untellHint(_id),

	{* loeschen des rule/constraint Attributes, das auf den Formletext zeigt *}
	retrieve_proposition(P(_as,_as,_formulatext,_as)),
	untell_with(_class,[attrdecl([_mode,attribute],[property(_label,_formulatext)])]),!,
	untell_generatedAssertions(_assertions,_metaFormulaId,_mode).

{ dieser Fall duerfte eigentlich nicht mehr auftreten
untell_generatedAssertions([_as|_assertions],_metaFormulaId,_mode) :-
	retrieve_temp_del(P(_id1,_as,'*instanceof',_metaFormulaId)),
	fail.
}

{* untell a generated hint (if existing *}
untellHint(_attrid) :-
  prove_edb_literal(A_label(_attrid,comment,_hintid,hint)),
  retrieve_proposition(P(_commentid,_attrid,hint,_hintid)),
  retrieve_proposition(P(_instid,_commentid,'*instanceof',_comclassid)),
  retrieve_proposition(P(_hintid,_hintid,_hinttext,_hintid)),
  retrieve_proposition(P(_instid1,_hintid,'*instanceof',_hintclassid)),
  DELETE(P(_instid,_commentid,'*instanceof',_comclassid)),
  DELETE(P(_commentid,_attrid,hint,_hintid)),
  DELETE(P(_hintid,_hintid,_hinttext,_hintid)),
  DELETE(P(_instid1,_hintid,'*instanceof',_hintclassid)),
  !.
untellHint(_attrid).



untell_SimpleAssertion(_id) :-
  set_overrule_act_bim2c,

{* Nur Verweise auf das Objekt, aber nicht das Individualobjekt selber werden hier
   gesucht. (9.1. 1996, RS)
   Gibt es Verweise auf den Assertiontext, so darf dieser nicht geloescht werden
*}
  retrieve_proposition(P(_id2,_b,_c,_id)),
  _id \== _id2,

  !.


untell_SimpleAssertion(_id) :-
	retrieve_proposition(P(_id,_id1,_label,_id2)),
	assertion_string(_label),!,
	DELETE(P(_id,_id1,_label,_id2)).





{ ************* u n t e l l _ i f _ a s s e r t i o n ***************}
{                                                                    }
{ untell_if_assertion(_dest,_assattrclass)                           }
{                                                                    }
{                                                                    }
{ Check for two or more assertions with the same text                }
{                                                     5-Dez-1995/TLi }
{ ****************************************************************** }

untell_if_assertion(_d,_assattrclass) :-
  set_overrule_act_bim2c,
  retrieve_proposition(P(_id,_,_,_d)),
  set_overrule_act_bim2c,
  retrieve_proposition(P(_,_id,'*instanceof',_assattrclass)),
  !.

untell_if_assertion(_d,_assattrclass) :-
  do_untell_if_assertion(_d,_assattrclass).

{ *********** d o _ u n t e l l _ i f _ a s s e r t i o n ***********}
{                                                                    }
{ do_untell_if_assertion(_dest,_assattrclass)                        }
{                                                                    }
{ If the attribute class is labelled 'constraint' or 'rule'          }
{ then we also have to remove the internal code of the assertions.   }
{ In addition the instantiation of the assertion to its assertion    }
{ class (i.e. MSFOLconstraint, MSFOLrule) is deleted                 }
{                                                                    }
{                                                    14-Feb-1989/MSt }
{ ****************************************************************** }

do_untell_if_assertion(_d,_assattrclass) :-
  name2id(Class,_ClassId),
  retrieve_proposition(P(_assattrclass,_ClassId,_asslabel,_A)),
  remove_assertion_code(_asslabel,_d),
  !.

{20-7-93 MSt}
do_untell_if_assertion(_d,_assattrclass) :-
  retrieve_proposition(P(_assattrclass,id_65,constraint,_A)),   {* id_65=QueryClass *}
  remove_assertion_code(query,_d),
  !.

{ ECArules }
do_untell_if_assertion(_d,_assattrclass) :-
	retrieve_proposition(P(_assattrclass,id_1403,ecarule,_)),   {* id_1403=ECArule *}
	remove_assertion_code(ecarule,_d),
	!.


do_untell_if_assertion(_,_).  {catchall}


remove_assertion_code(constraint,_d) :-
  name2id(MSFOLconstraint,_MSFOLconId),
  DELETE( P( _IoId, _d, '*instanceof', _MSFOLconId)),
  untell_BDMIntegrityConstraint(_d),
  !.

remove_assertion_code(rule,_d) :-
  name2id(MSFOLrule,_MSFOLruleId),
  DELETE( P( _IoId1, _d, '*instanceof', _MSFOLruleId)),
  untell_Rule(_d),
  untell_BDMRule(_d),
  !.

{20-7-93 MSt}
remove_assertion_code(query,_d) :-
  name2id(MSFOLquery,_MSFOLquId),
  DELETE( P( _IoId, _d, '*instanceof', _MSFOLquId)),
  !.

{ ECA rules }
remove_assertion_code(ecarule,_d) :-
	name2id(ECAassertion,_ecaassid),
	DELETE(P(_ioid,_d,'*instanceof',_ecaassid)),
	!.

remove_assertion_code(_,_d).


{ *********** u n t e l l _ i f _ d e r i v e d Q u e r y ********** }
{                                                  13-Mar-90/MSt     }
{ untell_if_derivedQuery(_id)                                        }
{       _id : ground                                                 }
{                                                                    }
{ If _id represents a derived query it must be 'untold' together     }
{ with its specialization relation to the generic query from which   }
{ it is derived.                                                     }
{                                                                    }
{ ****************************************************************** }

untell_if_derivedQuery(_id) :-
  retrieve_proposition(P(_id,_id,_l,_id)),
  atom(_l),
  pc_atomconcat('derive(',_,_l),
  pc_atom_to_term(_l,_term),
  _term = derive(_,_),
  DELETE(P(_id,_id,_l,_id)),
  DELETE(P(_id2,_id,'*isa',_GQ)).

untell_if_derivedQuery(_).



{ **************** i d e n t i f y _ o b j e c t ******************* }
{                                                                    }
{ identify_object(_objdescr)                                         }
{    _objdescr : ground                                              }
{                                                                    }
{ proves, wether the argument is an object of the knowledge-base     }
{                                                                    }
{ ****************************************************************** }

identify_object(_id) :-
  retrieve_proposition(P(_id,_x,_l,_y)),
  !.



{ **************** m i n u s _ r e l a t i o n  *************** }
{                                                               }
{  minus_relation(_l1,_l2,_l3)                                  }
{              _l1: list: ground                                }
{              _l2: list: ground                                }
{              _l3: any                                         }
{                                                               }
{ removes all elements of _l2 out of _l1. _l3 is the result     }
{                                                               }
{ ************************************************************* }

minus_relation(_rel_old,[],_rel_old).

minus_relation(_list1,[_y|_list2],_rel) :-
  minus_simple_relation(_list1,_y,_list3),
  minus_relation(_list3,_list2,_rel),!.

{ **************** m i n u s _ r e l a t i o n  *************** }
{                                                               }
{  minus_simple_relation(_l1,_a,_l3)                            }
{              _l1: list: ground                                }
{              _a:  ground                                      }
{              _l3: any                                         }
{                                                               }
{ removes  _a out of _l1. _l3 is the result                     }
{                                                               }
{ ************************************************************* }

minus_simple_relation([_x|_list],_x,_list).

minus_simple_relation([_x|_list1],_y,[_x|_list2])   :-
  _x \== _y,
  minus_simple_relation(_list1,_y,_list2).


{ ************************ D E L E T E ************************ }
{                                                2-Jan-1990/MJf }
{ DELETE(_p)                                                    }
{   _p: ground object                                           }
{                                                               }
{ Mark the object _p as deleted.                                }
{ is an ordinary object (individual,attribute, instanceOf or    }
{ isA) and the second contains the belief (=transaction) time   }
{ of the first one.                                             }
{                                                               }
{ Remark: The ordering of delete_proposition is important. We}
{ to delete _p in its normal representation and then            }
{ create them in Rep_temp. If we would create it first in Rep_  }
{ temp and then delete them, then we may just delete it in      }
{ Rep_temp once again!              4-Jan-1990/MJf              }
{                                                               }
{ ************************************************************* }

DELETE(P(_id,_x,_l,_y)) :-
  set_overrule_act_bim2c,
  retrieve_proposition_noimport(_m,P(_id,_x,_l,_y)),   {* 26-Feb-2004/M.Jeusfeld           *}
  (
    get_cb_feature(securityLevel,'0');         {* no access control enabled: DELETE is always allowed *}
    M_SearchSpace(_m)
  ),            {* otherwise: deletion only in current module! *}
{*  WriteUpdate(low,'-',P(_id,_x,_l,_y)), *}  
  setCheckUpdateModeIfCacheKept,  {* ticket #123 *}
  remove(_id),
  !.

{* this clause takes care of deleting a P-tuple that had been inserted *}
{* in the same transaction, see also ticket #92                        *}
DELETE(P(_id,_x,_l,_y)) :-
  retrieve_temp_ins(P(_id,_x,_l,_y)), 
  removetmp(_id),
{*  WriteUpdate(low,'#',P(_id,_x,_l,_y)),  *} 
  setCheckUpdateModeIfCacheKept,  {* ticket #123 *}
  !.

{* this clause shortcuts an attempt to delete an object that is already deleted *}
DELETE(P(_id,_x,_l,_y)) :-
  retrieve_temp_del(P(_id,_x,_l,_y)),
{*  write(_id),write(' was already marked deleted. '),nl, *}
  setCheckUpdateModeIfCacheKept,  {* ticket #123 *}
  !.



DELETE(P(_id,_x,_l,_y)) :-
  retrieve_proposition_noimport(_m,P(_id,_x,_l,_y)),
  id2name(_m,_mname),
  report_error(UNTELL13, FragmentToHistoryPropositions,
              [_id,_x,_l,_y,_mname]),
  increment('error_number@F2HP'),
  !,
  fail.




