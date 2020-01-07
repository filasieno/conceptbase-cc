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
{************************************************************************
*
* File:         BDMForget.pro
* Version:      11.3
*
*
* Date released : 97/02/12  (YY/MM/DD)
*
* SCCS-Source-Pool : /home/CBase/CB_NewStruct/ProductPOOL/serverSources/Prolog_Files/SCCS/s.BDMForget.pro
* Date retrieved : 97/04/30 (YY/MM/DD)
**************************************************************************
*
* -----------------------------------------------------------------------------
*
* This module is part of the BDMIntegrityChecker and is responsible for the
* right treatment of untelled integrity constraints and rules concerning their
* compilation.
*
*
*
* Exported predicates:
* --------------------
*
*   + ForgetIntegrityConstraint/1
*       Wird im System eine Integritaetsbedingung geloescht (UNTELL), so
*       werden hier alle Objekte geloescht, die an dieser Integritaetsbedingung
*       haengen, es sind genau diese, die in NewIntegrityConstraint@BDMCompile
*       erzeugt wurden.
*
*   + ForgetRule/1
*       Wird im System eine Regel geloescht (UNTELL), so werden hier alle
*       Objekte geloescht, die an dieser Regel haengen, es sind genau diese,
*       die in NewRule@BDMCompile erzeugt wurden.
*
*
* 7-Mar-1990/MJf:
*   . Use dedicated variables _tt1,_tt2,... for transaction time intervals
*     instead of tt(_TellTime) for all transaction times. Reason: Different
*     information may have different transaction time though in the case
*     of BDM rules&constraints the corresponding triggers, specialized
*     assertions etc. normally has been told during the same transaction.
*     But: It may be the case that some weird trigger (or so) is told later.
*
* 12-Mar-1990/MJf:
*    . The "generate-test-fail" combination used in ForgetSimplified-
*      Constraints, ForgetSimplifiedRules and RuleConcernsThisClass is now
*      replaced by the "findall" paradigm. The reason for this is the
*      following: BDMForget backtracks on the objects in the KB which have
*      to be "untelled". The untelled ones are temporarily created in
*      Rep_temp. Thus, the procedure retrieve_proposition may *not* con-
*      sider Rep_temp. Otherwise, infinite backtracking would occur.
*      On the other hand, it would be nice to have Rep_temp visible during
*      the phase of UNTELL when the concerned objects are identified.
*      Reason: We want to have the UNTELL to non-sensitive to the ordering
*      of the untelled information. Example: Up to now, it's impossible to
*      untell the attributes and the class (defining the corresponding
*      categories) in the same transaction. The untelled instantiation link
*      is in Rep_temp. Therefore, the translator FragmentToHistoryPropositions
*      cannot find the attribute categories of the untelled attributes.
*      <Please remember that BDMForget is used in this translator>
*
* 4-Jul-1990/MJf:
*   . triggers applyConstraintIfInsert, applyConstraintIfDelete,
*     applyRuleIfInsert, applyRuleIfDelete and deducedBy are now attributes
*     of PROPOSITION instead of CLASS
*
* 21-Jan-1993/DG: AttrValue is changed into A by deleting the
* time component (see CBNEWS[154])
*
* 1-Sep-93/Tl: retrieve_proposition calls with constant objects at Src or Dst entry
* are changed into a name2id(...,_id),retr_prop(..,_id,..) combination. The old
* construction didn't work with an extern retrieve_proposition
*
* Metaformel Aenderung (10.1.96)
* neues Praedikat ForgetProcTrigger(_oid), dass zu einer
* Metaformel alle erzeugten Prozedurtrigger loescht.
*
* 9-Dez-96 LWEB: retrieve_temp_proposition$Rep_temo durch retrieve_temp$PropositionProcessor
* ersetzt.
}


#MODULE(BDMForget)
#EXPORT(ForgetIntegrityConstraint/1)
#EXPORT(ForgetProcTrigger/1)
#EXPORT(ForgetRule/1)
#EXPORT(RetrieveProposition/1)
#ENDMODDECL()

#IMPORT(retrieve_proposition/1,PropositionProcessor)
#IMPORT(retrieve_temp_del/1,PropositionProcessor)
#IMPORT(DELETE/1,FragmentToHistoryPropositions)
#IMPORT(prove_literal/1,Literals)
#IMPORT(retrieve_BDMFormula_once/1,BDMKBMS)
#IMPORT(change_BDMFormula/2,BDMKBMS)
#IMPORT(delete_BDMFormula_once/1,BDMKBMS)
#IMPORT(retrieve_BDMFormula/1,BDMKBMS)
#IMPORT(WriteTrace/3,GeneralUtilities)
#IMPORT(name2id/2,GeneralUtilities)

#IF(SWI)
:- style_check(-singleton).
#ENDIF(SWI)


{ ==================== }
{ Exported predicates: }
{ ==================== }


{ *************************************************************************** }
{                                                                             }
{ ForgetIntegrityConstraint( _IcId)                                           }
{                                                                             }
{ Wird auf eine Integritaetsbedingung die Operation UNTELL angewendet, so     }
{ muss automatisch auf alle in der Compilierphase (tell_BDMIntegrityConstraint}
{ @BDMIntegrityChecker) erstellten Objekte auch UNTELL angewendet werden.     }
{ Da diese Integritaetsbedingung dann nicht mehr von Integritaetstest         }
{ (check_BDMIntegrity@BDMIntegrityChecker) beruecksichtigt wird, aendern sich }
{ die Abhaengigkeiten zwischen betroffenen Klassen und eingehenden Regeln und }
{ der Integritaetsbedingung. Schliesslich werden alle internen BDMPraedikate, }
{ die mit dieser Integritaetsbedingung zusammenhaengen, geloescht bzw.        }
{ aktualisiert.                                                               }
{ Vorausgesetzt ist, dass das Objekt, das die Integritaetsbedingung darstellt }
{ (mit dem Identifikator _IcId), bereits untelled wurde.                      }
{                                                                             }
{ _IcId      : der Identifikator des Objekts, das die Integritaetsbedingung   }
{              darstellt. (i)                                                 }
{                                                                             }
{ *************************************************************************** }


ForgetIntegrityConstraint( _IcId) :-


                { 1. die vollstaendige Integritaetsbedingung:                 }

        delete_origConstraint( _IcId),

                { 2. Verarbeiten der einzelnen vereinfachten Instanzen dieser }
                {    Integritaetsbedingung:                                   }

        ForgetSimplifiedConstraints( _IcId),
        !.






{ *************************************************************************** }
{                                                                             }
{ ForgetRule( _RuleId)                                                        }
{                                                                             }
{ Wird auf eine Regel die Operation UNTELL angewendet, so                     }
{ muss automatisch auf alle in der Compilierphase (tell_BDMIntegrityConstraint}
{ @BDMIntegrityChecker) erstellten Objekte auch UNTELL angewendet werden.     }
{ Da diese Regel dann nicht mehr von Integritaetstest                         }
{ (check_BDMIntegrity@BDMIntegrityChecker) beruecksichtigt wird, aendern sich }
{ die Abhaengigkeiten zwischen betroffenen Klassen und eingehenden Regeln und }
{ der Regel. Schliesslich werden alle internen BDMPraedikate,                 }
{ die mit dieser Regel zusammenhaengen, geloescht bzw. aktualisiert.          }
{ Vorausgesetzt ist, dass das Objekt, das die Regel darstellt                 }
{ (mit dem Identifikator _RuleId), bereits untelled wurde.                    }
{                                                                             }
{ _RuleId : der Identifikator des Objekts, das die Regel darstellt (i).       }
{                                                                             }
{ *************************************************************************** }



ForgetRule( _RuleId) :-



        delete_origRule( _RuleId),

                { 2. Verarbeiten der einzelnen vereinfachten Instanzen dieser }
                {    Integritaetsbedingung:                                   }

        ForgetSimplifiedRules( _RuleId),

        !.


ForgetProcTrigger(_oid) :-
	findall('applyPredicateIfInsert@BDMCompile'(_literal,_oid,_ePredList,_proc),
	retrieve_BDMFormula('applyPredicateIfInsert@BDMCompile'(_literal,_oid,_ePredList,_proc)),
	_procTriggerList1),
	{write(_procTriggerList1),nl,nl,}
	deleteProcTriggerList(_procTriggerList1),
	findall('applyPredicateIfDelete@BDMCompile'(_literal,_oid,_proc),
	retrieve_BDMFormula('applyPredicateIfDelete@BDMCompile'(_literal,_oid,_proc)),
	_procTriggerList2),
	{write(_procTriggerList2),nl,nl,}
	deleteProcTriggerList(_procTriggerList2)
	.

deleteProcTriggerList([]).
deleteProcTriggerList([_pt|_pts]) :-
	delete_BDMFormula_once(_pt),
	deleteProcTriggerList(_pts).


{ =================== }
{ Private predicates: }
{ =================== }



{ *************************************************************************** }
{                                                                             }
{ ForgetSimplifiedConstraints( _IcId)                                         }
{                                                                             }
{ Der Reihe nach werden alle vereinfachten Instanzen der Integritaetsbe-      }
{ dingung gesucht.                                                            }
{ Eine bestimmte vereinfachte Instanz einer Integritaetsbedingung wird        }
{ entsprechend der UNTELL-Operation behandelt: Untellen ihrer Objekte,        }
{ Loeschen ihrer BDMPraedikate, Aendern der Abhaengigkeiten durch             }
{ propagierendes Untell der in die Integritaetsbedingung eingehenden Regeln.  }
{                                                                             }
{ _IcId      : der Identifikator des Objekts, das die Integritaetsbedingung   }
{              darstellt. (i)                                                 }
{                                                                             }
{ 12-Mar-1990/MJf: Benutze findall und die rekursive Prozedur delete-         }
{ SimplifiedConstraints anstatt der "Backtracking" Loesung. Siehe auch Anmer- }
{ kung am Anfang dieser Datei.                                                }
{                                                                             }
{ *************************************************************************** }


ForgetSimplifiedConstraints( _IcId) :-

                { 1. Suchen aller vereinfachten Instanzen:                     }
        { 1-Sep-93/Tl }
	name2id(MSFOLconstraint,_MSFOLconId),
	name2id(BDMConstraintCheck,_BDMconChId),
        retrieve_proposition( P( _AttrCatId,
           _MSFOLconId, specialConstraint,_BDMconChId )),
        findall(_SimpIcId,
                isSimplifiedAssertion(_IcId, _AttrCatId, _SimpIcId),
                _solutions),

                {2. Loesche sie                                                }
        deleteSimplifiedConstraints(_IcId,_solutions),
        !.



{*** Behandle alle gefundenen vereinfachten IC's:   }

deleteSimplifiedConstraints(_IcId,[]) :- !.

deleteSimplifiedConstraints(_IcId, [_SimpIcId|_rest]) :-
          { 1. Vergessen der vereinfachten Instanz                      }
   delete_applyConstraint( _IcId, _SimpIcId, _ClassId, _InsDel),
          { 2. Betrachten von Regeln, deren Folgerungsliteral in die    }
          {    vereinfachte Instanz eingeht                             }
   RuleConcernsThisClass( _ClassId, untoldIC(_SimpIcId), _InsDel),
   deleteSimplifiedConstraints(_IcId,_rest).


{*** _SimpAssId ist Vereinfachung von _AssId unter der Kategorie _AttrCatId }

isSimplifiedAssertion(_AssId, _AttrCatId, _SimpAssId) :-
   retrieve_proposition(P(_ConId,_AssId,_l2,_SimpAssId)),
   retrieve_proposition(P(_IoId, _ConId,'*instanceof',_AttrCatId)).





{ *************************************************************************** }
{                                                                             }
{ ForgetSimplifiedRules( _RuleId)                                             }
{                                                                             }
{ Der Reihe nach werden alle vereinfachten Formen der Regel gesucht.          }
{ Eine bestimmte vereinfachte Form der Regel wird                             }
{ entsprechend der UNTELL-Operation behandelt: Untellen ihrer Objekte,        }
{ Loeschen ihrer BDMPraedikate, Aendern der Abhaengigkeiten durch             }
{ propagierendes Untell der in die Regel eingehenden Regeln.                  }
{                                                                             }
{ _RuleId    : der Identifikator des Objekts, das die Regel darstellt. (i)    }
{                                                                             }
{ 12-Mar-1990/MJf: Aenderungen analog zu ForgetSimplifiedConstraints          }
{                                                                             }
{ *************************************************************************** }


ForgetSimplifiedRules( _RuleId) :-

                { 1. Suchen aller vereinfachten Instanzen:                      }
        {1-Sep-93/Tl}
        name2id(MSFOLrule,_MSFOLruleId),
        name2id(BDMRuleCheck,_BDMruleChId),
        retrieve_proposition(
                    P(_AttrCatId,_MSFOLruleId,specialRule,_BDMruleChId)),
        findall(_SimpRuleId,
                isSimplifiedAssertion(_RuleId, _AttrCatId, _SimpRuleId),
                _solutions),

                {2. Loesche sie                                                }
        deleteSimplifiedRules(_RuleId,_solutions),
        !.


deleteSimplifiedRules(_RuleId,[]) :- !.

deleteSimplifiedRules(_RuleId, [_SimpRuleId|_rest]) :-
          { 1. Vergessen der vereinfachten Instanz                      }
   delete_SimpRule( _SimpRuleId, _ClassId, _InsDel),
          { 2. Betrachten von Regeln, deren Folgerungsliteral in die    }
          {    vereinfachte Instanz eingeht                             }
   RuleConcernsThisClass( _ClassId, untoldRule(_SimpRuleId), _InsDel),
   deleteSimplifiedRules(_RuleId,_rest).





{ *************************************************************************** }
{                                                                             }
{ RuleConcernsThisClass( _ClassId, _untold, _InsDel)                          }
{                                                                             }
{ Wenn Instanzen der angegebenen Klasse von einer Regel hergeleitet werden,   }
{ so muss auch die Compilierung dieser Regel aktualisiert werden.             }
{                                                                             }
{ _ClassId   : der Identifikator der Klasse, deren Instanzen in eine          }
{              Integritaetsbedingung eingehen, die untelled wurde, oder die   }
{              in eine Regel eingehen, die selber (evtl. ueber weitere Regeln)}
{              in eine untelled Integritaetsbedingung eingeht (i),            }
{ _untold    : enthaelt Identifikator der geloeschten vereinfachten Formel (i)}
{ _InsDel    : ob Loesch- oder Einfuegeueberpruefung wegfaellt (i).           }
{                                                                             }
{ 12-Mar-1990/MJf: Auch hier ist die "fail"-Konstruktion durch ein "findall"  }
{ ersetzt. Allerdings ist isSpecializedRuleDeducingClass eine etwas kompli-   }
{ ziertere Bedingung. VisitSimpRules behandelt einfach alle Loesungen wie     }
{ bisher.                                                                     }
{                                                                             }
{ *************************************************************************** }


{* _InsDel gibt an, ob die geloeschte vereinfachte Form fuer Insert bzw.  *}
{* Delete des Bedingungsliterals (concerning _ClassId) verantwortlich war *}

RuleConcernsThisClass(_ClassId, _untold,_InsDel):-

   findall(_SimpRuleId,
           isSpecializedRuleDeducingClass(_ClassId,_SimpRuleId),
           _solutions),

   visitSimpRules(_solutions,_untold,_InsDel),

   WriteTrace(veryhigh,BDMForget,['The deletion ',_untold,
              ' affects the specialized rules ',_solutions,
              ' which are triggers for "',_InsDel,'" at class ',_ClassId]),
   !.



visitSimpRules([],_,_) :- !.

visitSimpRules([_SimpRuleId|_rest],_untold,_InsDel) :-

	_goahead = goAhead(_InsDel, _ListOfSimpIcIds, _ListOfSimpRuleIds),
	(
	  retrieve_BDMFormula('applyRuleIfInsert@BDMCompile'( _RuleId, _, _SimpRuleId, _, _, _,_goahead))
	;
	  retrieve_BDMFormula('applyRuleIfDelete@BDMCompile'( _RuleId, _, _SimpRuleId, _, _, _,_goahead))
	),
	_goahead = goAhead(_InsDel, _ListOfSimpIcIds, _ListOfSimpRuleIds),
	!,


     {*** Verarbeiten dieser vereinfachten Regel:               }
   treatSimpRule(_SimpRuleId,_untold,_ListOfSimpRuleIds,_ListOfSimpIcIds),

   visitSimpRules(_rest,_untold,_InsDel).



{* ... wenn der goAhead-Trigger nicht das gewuenschte _InsDel hat : }
{* ---> diese vereinfachte Form geht nicht in _untold ein           }

visitSimpRules([_|_rest],_untold,_InsDel) :-
   visitSimpRules(_rest,_untold,_InsDel).






{*** _RuleId leitet Instanzen von _ClassId zur Zeit _RuleTime ab. Man be-  *}
{*** achte, dass der Weg ueber die interne Darstellung _OrigRuleId der     *}
{*** Regel fuehrt.                                         12-Mar-1990/MJf *}
{* _RuleTime entfernt                                    25-Jan-1993/DG*}

isDeducingRule(_ClassId, _RuleId) :-

      {***  _OrigRuleId ist die interne Form einer Regel von _ClassId      *}
   prove_literal(  A(_ClassId,deducedBy,_OrigRuleId)  ),

      {*** _RuleId ist der Id der Textform der Regel                       *}
   prove_literal(  A(_RuleId,originalRule,_OrigRuleId)  ).



{*** _SimpRuleId ist zur Zeit _RuleTime eine Spezialisierung von _RuleId   *}

isSpecializedRule(_RuleId, _SimpRuleId) :-
   prove_literal(  A(_RuleId,specialRule,_SimpRuleId)  ).



{*** _SimpRuleId ist eine vereinfachte Instanz einer Regel, die Instanzen  *}
{*** von _ClassId herleitet.                               12-Mar-1990/MJf *}

isSpecializedRuleDeducingClass(_ClassId, _SimpRuleId) :-
   isDeducingRule(_ClassId, _RuleId),
   isSpecializedRule(_RuleId, _SimpRuleId).





{ *************************************************************************** }
{                                                                             }
{ treatSimpRule( _SimpRuleId, _untold, _ListOfSimpRuleIds, _ListOfSimpIcIds)  }
{                                                                             }
{ Die angegebene vereinfachte Form einer Regel erzeugt Objekte, die in die zu }
{ loeschende vereinfachte Instanz einer Integritaetsbedingung eingeht (xor in }
{ die zu loeschende vereinfachte Regelform). Also muessen die Verweise        }
{ dazwischen geloescht werden, und falls die vereinfachte Regelform in nichts }
{ anderes eingeht, so sind auch die Verweise auf diese vereinfachte Regelform }
{ und sie selber zu loeschen.                                                 }
{                                                                             }
{ _SimpRuleId        : der Identifikator der vereinfachten Form einer Regel,  }
{                      die Objekte erzeugt, die in eine Integritaetsbedingung }
{                      eingehen koennen, die untelled wurde, oder die in eine }
{                      Regel eingehen, die selber (evtl. ueber weitere Regeln)}
{                      in eine untelled Integritaetsbedingung eingeht (i),    }
{ _untold            : enthaelt den Identifikator der geloeschten vereinfach- }
{                      ten Form (i),                                          }
{ _ListOfSimpRuleIds : Liste der vereinfachten Regelformen, die nach der zu   }
{                      behandelnden vereinfachten Form einer Regel anzuwenden }
{                      waeren (i),                                            }
{ _ListOfSimpIcIds   : Liste der vereinfachten Regelformen, die nach der zu   }
{                      behandelnden vereinfachten Form einer Regel anzuwenden }
{                      waeren (i),                                            }
{                                                                             }
{ *************************************************************************** }



{ Die gefundene vereinfachte Regel zeigt NUR auf die zu untellende Ic:        }

treatSimpRule( _SimpRuleId, untoldIC(_untell_SimpIcId), [], [_untell_SimpIcId]) :-

        WriteTrace(high,BDMForget,[_SimpRuleId,' is now unnecessary']),
        delete_SimpRule( _SimpRuleId, _ClassId, _InsDel),
        RuleConcernsThisClass( _ClassId, untoldRule(_SimpRuleId), _InsDel),
        !.




{ Die gefundene vereinfachte Regel geht in mehr als die zu untellende Ic ein: }

treatSimpRule( _SimpRuleId, untoldIC(_untell_SimpIcId), _, _) :-

        (_name = 'applyRuleIfInsert@BDMCompile';
         _name = 'applyRuleIfDelete@BDMCompile'),

        _trigger =.. [_name,_RuleId,_ClassId,_SimpRuleId,_Literal,_RuleConcl,_RuleCondMerged,
                      goAhead(_InsDel,_ListOfSimpIcIdsOld,_ListOfSimpRuleIds)],

        retrieve_BDMFormula_once(_trigger),

        !,

        deleteListMember( _ListOfSimpIcIdsOld, _untell_SimpIcId,
                          _ListOfSimpIcIdsNew),

        _newtrigger =.. [_name,_RuleId,_ClassId,_SimpRuleId,_Literal,
                      _RuleConcl,_RuleCondMerged,
                      goAhead(_InsDel,_ListOfSimpIcIdsNew,_ListOfSimpRuleIds)],

        change_BDMFormula(_trigger,_newtrigger),
        !.




{ Die gefundene vereinfachte Regel zeigt NUR auf die zu untellende            }
{ vereinfachte Regel:                                                         }

treatSimpRule( _SimpRuleId, untoldRule(_untell_SimpRuleId),
               [_untell_SimpRuleId], []) :-

        WriteTrace(high,BDMForget,[_SimpRuleId,' is now unnecessary']),
        delete_SimpRule( _SimpRuleId, _ClassId, _InsDel),
        RuleConcernsThisClass( _ClassId, untoldRule(_SimpRuleId), _InsDel),
        !.




{ Die gefundene vereinfachte Regel geht in mehr als die zu untellende         }
{ vereinfachte Regel ein:                                                     }

treatSimpRule( _SimpRuleId, untoldRule(_untell_SimpRuleId), _, _) :-

        (_name = 'applyRuleIfInsert@BDMCompile';
         _name = 'applyRuleIfDelete@BDMCompile'),

        _trigger =.. [_name,_RuleId,_ClassId,_SimpRuleId,_Literal,_RuleConcl,_RuleCondMerged,
                      goAhead(_InsDel,_ListOfSimpIcIds,_ListOfSimpRuleIdsOld)],

        retrieve_BDMFormula_once(_trigger),

        !,


        deleteListMember( _ListOfSimpRuleIdsOld, _untell_SimpRuleId,
                          _ListOfSimpRuleIdsNew),

        _newtrigger =.. [_name,_RuleId,_ClassId,_SimpRuleId,_Literal,
                      _RuleConcl,_RuleCondMerged,
                      goAhead(_InsDel,_ListOfSimpIcIds,_ListOfSimpRuleIdsNew)],

        change_BDMFormula(_trigger,_newtrigger),
        !.











{ =========================================================================== }
{ *************************************************************************** }
{ *************************************************************************** }
{                                                                             }
{ *************      S   U   B   M   O   D   U   L   E      ***************** }
{                                                                             }
{                                                                             }
{              DDDD    EEEEE   L       EEEEE  TTTTT  EEEEE                    }
{              D   D   E       L       E        T    E                        }
{              D   D   EEEE    L       EEEE     T    EEEE                     }
{              D   D   E       L       E        T    E                        }
{              DDDD    EEEEE   LLLLL   EEEEE    T    EEEEE                    }
{                                                                             }
{                                                                             }
{ Hier befinden sich ausschliesslich die Praedikate, die sich mit dem         }
{ Ungueltigmachen und Loeschen von Prolog-Praedikaten beschaeftigen.          }
{ Achtung: alle diese Praedikate sind voellig analog zu denen aus dem         }
{ Submodule STORE@BDMCompile, d.h. aendert sich etwas an der Abspeicherung,   }
{ so muss es entsprechend hier geaendert werden und umgekehrt!                }
{                                                                             }
{ Mit folgenden Praedikaten laesst sich dies tun:                             }
{      delete_origConstraint( _IcId)                                          }
{      delete_origRule( _RuleId)                                              }
{      delete_applyConstraint( _IcId, _SimpIcId, _ClassId, _InsDel)           }
{      delete_SimpRule( _SimpRuleId, _ClassId, _InsDel)                       }
{                                                                             }
{ *************************************************************************** }
{ *************************************************************************** }







{ *************************************************************************** }
{                                                                             }
{ delete_origConstraint( _IcId)                                               }
{                                                                             }
{ untelled die Objekte und loescht das BDMPraedikat fuer eine vollstaendige   }
{ Integritaetsbedingung.                                                      }
{                                                                             }
{ _IcId      : der Identifikator des Objekts, das die urspruengliche Integri- }
{              taetsbedingung (Instanz von MSFOLconstraint) darstellt (i).    }
{                                                                             }
{ *************************************************************************** }


delete_origConstraint( _IcId) :-

                { 1. Ungueltigmachen der Objekte:                            }

                { 1a. Verweis von der Integritaetsbedingung zu ihrer internen,}
                {     vollstaendigen Darstellung:                             }
        {1-Sep-93/Tl}
        name2id(MSFOLconstraint,_MSFOLconId),
        name2id(BDMConstraintCheck,_BDMconChId),
        retrieve_proposition( P( _AttrCatId1,
           _MSFOLconId, originalConstraint, _BDMconChId)),
        retrieve_proposition(
            P( _ConId, _IcId, _Label, _OrigIcId)),
        retrieve_proposition(
            P( _IoId1a, _ConId, '*instanceof', _AttrCatId1)),

        DELETE( P( _ConId, _IcId, _Label, _OrigIcId)),
        DELETE( P( _IoId1a, _ConId, '*instanceof', _AttrCatId1)),


                { 1b. Das Objekts, das die Integritaetsbedingung in ihrer     }
                {     internen, vollstaendigen Darstellung enthaelt:          }

        retrieve_proposition(
            P( _OrigIcId, _OrigIcId, _IcFormula_list, _OrigIcId)),
        retrieve_proposition(
           P( _IoId2b, _OrigIcId, '*instanceof', _BDMconChId)),

        DELETE( P( _OrigIcId, _OrigIcId, _IcFormula_list, _OrigIcId)),
        DELETE( P( _IoId2b, _OrigIcId, '*instanceof', _BDMconChId)),

                { 2. Loeschen des BDMPraedikats:                              }

        delete_BDMFormula_once('origConstraint@BDMCompile'( _, _OrigIcId, _)),		{ 26-May-1995 LWEB }
         !.











{ *************************************************************************** }
{                                                                             }
{ delete_origRule( _RuleId)                                                   }
{                                                                             }
{ untelled die Objekte und loescht das BDMPraedikat fuer eine vollstaendige   }
{ Regel.                                                                      }
{                                                                             }
{ _RuleId      : der Identifikator des Objekts, das die urspruengliche Regel  }
{                (Instanz von MSFOLrule) darstellt (i).                       }
{                                                                             }
{ *************************************************************************** }



delete_origRule( _RuleId) :-

                { 1a. Der Verweis von der Regel zu ihrer internen,            }
                {     vollstaendigen Darstellung:                             }
        {1-Sep-93/Tl}
        name2id(MSFOLrule,_MSFOLruleId),
        name2id(BDMRuleCheck,_BDMruleChId),
        retrieve_proposition(
           P( _AttrCatId1, _MSFOLruleId, originalRule, _BDMruleChId)),
        retrieve_proposition(
           P( _ConId1, _RuleId, _Label1, _OrigRuleId)),
        retrieve_proposition(
           P( _IoId1b, _ConId1, '*instanceof', _AttrCatId1)),


        DELETE( P( _ConId1, _RuleId, _Label1, _OrigRuleId)),
        DELETE( P( _IoId1b, _ConId1, '*instanceof', _AttrCatId1)),


                { 1a. Das Objekt, das die Regel in ihrer internen,            }
                {     vollstaendigem Format darstellt:                        }

        retrieve_proposition(
           P( _OrigRuleId, _OrigRuleId, _Rule_list, _OrigRuleId)),
        retrieve_proposition(
           P( _IoId2b, _OrigRuleId, '*instanceof', _BDMruleChId)),

        DELETE( P( _OrigRuleId, _OrigRuleId, _Rule_list, _OrigRuleId)),
        DELETE( P( _IoId2b, _OrigRuleId, '*instanceof', _BDMruleChId)),


                { 1c. Der Verweis von der Klasse, die durch das               }
                {     Folgerungsliteral der Regel betroffen ist, zu der       }
                {     internen vollstaendigen Regel:                          }

        {1-Sep-93/Tl}
        name2id(Proposition,_PropId),
        retrieve_proposition(
           P( _AttrCatId3, _PropId, deducedBy, _BDMruleChId)),
        retrieve_proposition(
           P( _ConId3, _ClassId, _Label3, _OrigRuleId)),
        retrieve_proposition(
           P( _IoId3a, _ConId3, '*instanceof', _AttrCatId3)),

        DELETE( P( _ConId3, _ClassId, _Label3, _OrigRuleId)),
        DELETE( P( _IoId3a, _ConId3, '*instanceof', _AttrCatId3)),


                { 2. Loeschen des BDMPraedikats:                              }

        delete_BDMFormula_once('origRule@BDMCompile'( _RuleId, _, _, _)),
        !.










{ *************************************************************************** }
{                                                                             }
{ delete_applyConstraint( _IcId, _SimpIcId, _ClassId, _InsDel)                }
{                                                                             }
{ untelled die Objekte und loescht das BDMPraedikat fuer eine spezialisierte  }
{ Integritaetsbedingung und deren Verweise.                                   }
{                                                                             }
{ _IcId      : der Identifikator des Objekts, das die urspruengliche Integri- }
{              taetsbedingung (Instanz von MSFOLconstraint) darstellt (i),    }
{ _SimpIcId  : Id des Objekts, das die vereinfachte Ic darstellt (i),         }
{ _ClassId   : Id der Klasse, deren Instanzen u.U. in Ic eingehen (o),        }
{ _InsDel    : = Insert, falls Ic bei einer Einfuegeoperation zu testen war,  }
{              = Delete, "     "  "   "     Loesch-"          "  "      " (o).}
{                                                                             }
{ *************************************************************************** }


delete_applyConstraint( _IcId, _SimpIcId, _ClassId, _InsDel) :-

                { 1. Ungueltigmachen der Objekte:                            }


                { 1a. Der Verweis von der Integritaetsbedingung               }
                {     zu ihrer vereinfachten Instanz:                         }
        name2id(MSFOLconstraint,_MSFOLconId),
        name2id(BDMConstraintCheck,_BDMconChId),
        retrieve_proposition( P( _AttrCatId,
           _MSFOLconId, specialConstraint, _BDMconChId)),
        retrieve_proposition(
           P( _ConId1, _IcId, _Label1, _SimpIcId)),
        retrieve_proposition(
           P( _IoId1b, _ConId1, '*instanceof', _AttrCatId)),

        DELETE( P( _ConId1, _IcId, _Label1, _SimpIcId)),
        DELETE( P( _IoId1b, _ConId1, '*instanceof', _AttrCatId)),


                { 1b. Der Verweis von der betroffenen Klasse zu               }
                {     der vereinfachten Instanz :                             }
        retrieve_proposition(P( _ConId2, _ClassId, _Label2, _SimpIcId)),

        ((
          {1-Sep-93/Tl}
          name2id(Proposition,_PropId),
          retrieve_proposition( P( _AttrCatId2,
            _PropId, applyConstraintIfInsert, _BDMconChId)),
          retrieve_proposition(
            P( _IoId2a, _ConId2, '*instanceof', _AttrCatId2)),
          _InsDel = Insert
         );
         (
          retrieve_proposition( P( _AttrCatId2,
            _PropId, applyConstraintIfDelete, _BDMconChId)),
          retrieve_proposition(
            P( _IoId2a, _ConId2, '*instanceof', _AttrCatId2)),
          _InsDel = Delete
        )),

        DELETE( P( _ConId2, _ClassId, _Label2, _SimpIcId)),
        DELETE( P( _IoId2a, _ConId2, '*instanceof', _AttrCatId2)),


                { 1c. Das Objekt, das die vereinfachte Instanz                }
                {     der Integritaetsbedingung darstellt:                    }

        retrieve_proposition(
           P( _SimpIcId, _SimpIcId, _IcFormula_list, _SimpIcId)),
        retrieve_proposition(
           P( _IoId3b, _SimpIcId, '*instanceof', _BDMconChId)),

        DELETE( P( _SimpIcId, _SimpIcId, _IcFormula_list, _SimpIcId)),
        DELETE( P( _IoId3b, _SimpIcId, '*instanceof', _BDMconChId)),


                { 2. Loeschen des BDMPraedikats:                              }

        ((_InsDel = Insert,
          delete_BDMFormula_once( 'applyConstraintIfInsert@BDMCompile'(_, _ClassId, _SimpIcId, _Literal, _IcFormula))
         );
         delete_BDMFormula_once( 'applyConstraintIfDelete@BDMCompile'( _, _ClassId, _SimpIcId, _Literal, _IcFormula))
        ),
        !.









{ *************************************************************************** }
{                                                                             }
{ delete_SimpRule( _SimpRuleId, _ClassId, _InsDel)                            }
{                                                                             }
{ untelled die Objekte und loescht das BDMPraedikat fuer eine spezialisierte  }
{ Regel und alle deren Verweise.                                              }
{                                                                             }
{ _SimpRuleId: Id des Objekts, das die vereinfachte Regel darstellt (i),      }
{ _ClassId   : Id der Klasse, deren Instanzen u.U. in Regel eingehen (o),     }
{ _InsDel    : = Insert, falls Regel bei einer Einfuegeoperation zu testen,   }
{              = Delete, "     "  "   "     Loesch-"          "  "      " (o).}
{                                                                             }
{ *************************************************************************** }



delete_SimpRule( _SimpRuleId, _ClassId, Insert) :-
                { 1. Loeschen des BDMPraedikats:                              }
        delete_BDMFormula_once( 'applyRuleIfInsert@BDMCompile'( _RuleId, _ClassId, _SimpRuleId, _, _, _,
                 goAhead(_,_ListOfSimpIcIds,_ListOfSimpRuleIds))),

                { 2. Ungueltigmachen der Objekte:                             }
                {     Der Verweis von der Klasse auf die vereinfachte Regel,  }
                {     von der vollstaendigen Regel auf diese vereinfachte     }
                {     Form und die Regel selber:                              }
        delete_SimpRuleObjects( _ClassId, _SimpRuleId),
        !.






delete_SimpRule( _SimpRuleId, _ClassId, Delete) :-
                { 1. Loeschen des BDMPraedikats:                              }

        delete_BDMFormula_once( 'applyRuleIfDelete@BDMCompile'( _RuleId, _ClassId, _SimpRuleId, _, _, _,
                 goAhead(_,_ListOfSimpIcIds,_ListOfSimpRuleIds))),

                { 2. Ungueltigmachen der Objekte:                             }
                {    Der Verweis von der Klasse auf die vereinfachte Regel,   }
                {     von der vollstaendigen Regel auf diese vereinfachte     }
                {     Form und die Regel selber:                              }
        delete_SimpRuleObjects( _ClassId, _SimpRuleId),
        !.





delete_SimpRuleObjects( _ClassId, _SimpRuleId) :-

                { 1b. Der Verweis von der Regel zu ihrer vereinfachten Form:  }

	name2id(MSFOLrule,_MSFOLruleId),
	name2id(BDMRuleCheck,_BDMruleChId),
        retrieve_proposition(
           P( _AttrCatId2, _MSFOLruleId, specialRule, _BDMruleChId)),
        retrieve_proposition(
           P( _ConId2, _RuleId, _Label2, _SimpRuleId)),
        retrieve_proposition(
           P( _IoId2a, _ConId2, '*instanceof', _AttrCatId2)),

        DELETE( P( _ConId2, _RuleId, _Label2, _SimpRuleId)),
        DELETE( P( _IoId2a, _ConId2, '*instanceof', _AttrCatId2)),


                { 1c. Das Objekts, das die vereinfachte Form der Regel        }
                {     darstellt:                                              }

        retrieve_proposition(
           P( _SimpRuleId, _SimpRuleId, _Rule_list, _SimpRuleId)),
        retrieve_proposition(
           P( _IoId3b, _SimpRuleId, '*instanceof', _BDMruleChId)),

        DELETE( P( _SimpRuleId, _SimpRuleId, _Rule_list, _SimpRuleId)),
        DELETE( P( _IoId3b, _SimpRuleId, '*instanceof', _BDMruleChId)),
        !.

delete_SimpRuleObjects( _ClassId, _SimpRuleId).











PassThruList( [], _) :-

        !.


PassThruList( [ _el | _rest], _Predicate) :-

        _Predicate =.. [ _functor, _arg],
        _callPredicate =.. [ _functor, _arg, _el],
        call( _callPredicate),
        PassThruList( _rest, _Predicate),
        !.







RetrieveProposition( _object) :-

        retrieve_proposition( _object)
	;

        retrieve_temp_del( _object).


{ 20-Nov-96 LWEB : retrieve_proposition deckt sowohl persistente als auch temporaere Objekte ab }







{ *************************************************************************** }
{                                                                             }
{ deleteListMember( _ListOld, _Member, _ListNew)                              }
{                                                                             }
{ Aus der alten Liste wird das angegebene Element herausgeloescht (es muss in }
{ ihr enthalten sein!).                                                       }
{                                                                             }
{ *************************************************************************** }


deleteListMember( [ _Member | _ListOld_rest], _Member, _ListOld_rest) :-

        !.



deleteListMember( [ _NotMember | _ListOld_rest], _Member,
                  [ _NotMember | _ListNew_rest]) :-

        deleteListMember( _ListOld_rest, _Member, _ListNew_rest),
        !.
