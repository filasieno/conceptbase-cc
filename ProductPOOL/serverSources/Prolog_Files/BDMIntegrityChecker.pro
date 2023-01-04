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
* File:         BDMIntegrityChecker.pro
* Version:      11.2
*
*
* Date released : 96/12/09  (YY/MM/DD)
*
* SCCS-Source-Pool : /home/CBase/CB_NewStruct/ProductPOOL/SCCS/serverSources/Prolog_Files/s.BDMIntegrityChecker.pro
* Date retrieved : 97/07/08 (YY/MM/DD)
*
* -----------------------------------------------------------------------------
*
* This module is part of the BDMIntegrityChecker and
* is responsible for the adaption of all modules concerning the integrity
* checker to ConceptBase.
*
*
*
* Exported predicates:
* --------------------
*
*   + tell_BDMIntegrityConstraint/2
*       Takes the string of a new integrity constraint, transforms it
*       to the internal format and calls the processing of new ICs.
*
*   + tell_BDMRule/2
*       Takes the string of a new rule, transforms it
*       to the internal format and calls the processing of new rules.
*
*
*   + untell_BDMIntegrityConstraint/1
*       All objects depending on the untelled integrity constraint are
*       to untell too or to change.
*
*   + untell_BDMRule/1
*       All objects depending on the untelled rule are also
*       to untell or to change.
*
*
*   + tellCheck_BDMIntegrity/1
*       Each object that has been created during a TELL transaction
*       has to be checked whether it does not violate the
*       integrity of the new database state.
*
*   + untellCheck_BDMIntegrity/1
*       Each object that has been deleted during an UNTELL transaction
*       has to be checked whether it's missing does not violate the
*       integrity of the new database state.
*
*
*   + mk_permanent_BDMFormulas/2
*       Temporary created BDMFormulas (because of an (UN-)TELL)
*       will be permanently stored if the transaction is accepted.
*
*   + rm_temp_BDMFormulas/0
*       Temporary created BDMFormulas (because of an (UN-)TELL)
*       will be delete if the transaction is not accepted.
*
*
* Metaformeln Aenderung:
* neue Praedikate
* tell_BDMProcTrigger
* untell_BDMProcTrigger
* zum Eintragen und Loeschen einer Liste von Prozedurtriggern
*
* mk_permanent_BDMFormulas
* dreistellig, nicht mehr zweistellig
* eine Liste mit zu loeschenden Formeln und eine mit einzutragenden
* Formeln wird uebergeben
* Grund
* Verwendung von change_BDMFormula:
* Das Aendern einer BDM-Formel erfolgt, indem die alte Formel
* geloescht und die neue eingetragen wird.
* Dies war vor Integration der Metaformeln nicht vollstaendig
* implementiert:
* Beim Tell wurden nur Einfuegungen beruecksichtigt, beim
* Untell nur Loeschungen
*
}



#MODULE(BDMIntegrityChecker)
#EXPORT(mk_permanent_BDMFormulas/3)
#EXPORT(rm_temp_BDMFormulas/0)
#EXPORT(tellCheck_BDMIntegrity/1)
#EXPORT(tell_BDMIntegrityConstraint/3)
#EXPORT(tell_BDMProcTrigger/1)
#EXPORT(tell_BDMRule/3)
#EXPORT(untellCheck_BDMIntegrity/1)
#EXPORT(untell_BDMIntegrityConstraint/1)
#EXPORT(untell_BDMProcTrigger/1)
#EXPORT(untell_BDMRule/1)
#ENDMODDECL()

#IMPORT(NewIntegrityConstraint/3,BDMCompile)
#IMPORT(NewRule/3,BDMCompile)
#IMPORT(NewProcTrigger/1,BDMCompile)
#IMPORT(ForgetIntegrityConstraint/1,BDMForget)
#IMPORT(ForgetRule/1,BDMForget)
#IMPORT(ForgetProcTrigger/1,BDMForget)
#IMPORT(tellRuleOrIntegrityConstraint/1,BDMEvaluation)
#IMPORT(tellObjectConcerningIntegrityConstraintsOrRules/1,BDMEvaluation)
#IMPORT(untellRule/1,BDMEvaluation)
#IMPORT(untellObjectConcerningIntegrityConstraintsOrRules/1,BDMEvaluation)
#IMPORT(mk_permanent_BDMFormula/3,BDMKBMS)
#IMPORT(rm_temp_BDMFormula/0,BDMKBMS)

#IF(SWI)
:- style_check(-singleton).
#ENDIF(SWI)

{ ==================== }
{ Exported predicates: }
{ ==================== }



{ ============== (UN-)TELL INTEGRITY CONSTRAINT OR RULE ==================== }





{ ************************************************************************** }
{                                                                            }
{ tell_BDMIntegrityConstraint( _BIMstring, _id)                              }
{                                                                            }
{ Die Integritaetsbedingung in Form einer Zeichenkette wird gescannt,        }
{ geparst, in eine bestimmte Normalform gebracht und schliesslich der        }
{ Verarbeitung neuer Integritaetsbedingungen uebergeben.                     }
{                                                                            }
{ _string : die Zeichenkette, die die Integritaetsbedingung darstellt        }
{           (so, wie sie der Benutzer eingegeben hat) (i),                   }
{ _id        : der Identifikator des Objekts, das die Ic enthaelt (i).       }
{                                                                            }
{ ************************************************************************** }


tell_BDMIntegrityConstraint(rangeconstr(_rangeform), _info, _id ) :-
	{ Auswerten, Untersuchen und Zerlegen der Constraint: }
	NewIntegrityConstraint(_info,_rangeform, _id).





{ *************************************************************************** }
{                                                                             }
{ tell_BDMRule( _rangeform, _infos, _id)                                      }
{                                                                             }
{ _rangeform : Term der Form rangerule(_vars,_cond,_concl)                    }
{ _infos      : Variablentabelle der Form [range(x,C)..]                      }
{ _id        : der Identifikator des Objekts, das die Regel enthaelt (i).     }
{                                                                             }
{ *************************************************************************** }

{* Bem: die Elemente der _info-Liste (d.h. die Variablentabelle) wird bald so aussehen: range(this,[C1,C2]).
*}

tell_BDMRule(_rangef, _info, _id) :-
	{ Auswerten, Untersuchen und Zerlegen der Regel: }
	_rangef =.. [rangerule,_vars,_l1,_l2],
	_rangeform =.. [rangerule,_l1,_l2],
	NewRule(_info,_rangeform,_id).

{
Metaformeln: neue Einfuege und Loeschoperationen fuer Trigger zur Wartung
der generierten Formeln (RS, 9.1.1996)
}
{ *************************************************************************** }
{                                                                             }
{ tell_BDMProcTrigger(_pts)                                                   }
{                                                                             }
{ _pts: Liste von Triggern mit Funktor applyPredicateIfInsert /               }
{                                      applyPredicateIfDelete                 }
{                                                                             }
{ *************************************************************************** }


tell_BDMProcTrigger([]).
tell_BDMProcTrigger([_pT|_pTs]) :-
	NewProcTrigger(_pT),
	tell_BDMProcTrigger(_pTs).



{ *************************************************************************** }
{                                                                             }
{ untell_BDMProcTrigger(_oids)                                                }
{                                                                             }
{ _oids: Liste von Metaformel-OIDs.   				              }
{                                                                             }
{  Jeder Prozedurtrigger kann ueber die OID-Komponente eindeutig einer        }
{  Metaformel zugeordnet werden. Wird diese geloescht, so kann man mittels    }
{  der OID Komponente die zugehoerigen Trigger schnell ausfindig machen und   }
{  loeschen                                                                   }
{                                                                             }
{ *************************************************************************** }

untell_BDMProcTrigger([]).
untell_BDMProcTrigger([_oid|_oids]) :-
	ForgetProcTrigger(_oid),
	untell_BDMProcTrigger(_oids).



{ *************************************************************************** }
{                                                                             }
{ untell_BDMIntegrityConstraint( _id)                                         }
{                                                                             }
{ Wird eine Integritaetsbedingung aus dem System geloescht (UNTELL), so       }
{ muessen auch alle anderen daran haengenden Objekte (vereinfachte Instanzen  }
{ z.B.) geloescht werden. Ausserdem muss deren Compilierung zurueckgenommen   }
{ werden.                                                                     }
{                                                                             }
{ _id : der Identifikator des Objekts, das die Integritaetsbed. enthaelt (i). }
{                                                                             }
{ *************************************************************************** }




untell_BDMIntegrityConstraint( _id) :-

        ForgetIntegrityConstraint( _id),
        !.








{ *************************************************************************** }
{                                                                             }
{ untell_BDMRule( _id)                                                        }
{                                                                             }
{ Wird eine Regel aus dem System geloescht (UNTELL), so muessen auch alle     }
{ anderen daran haengenden Objekte (vereinfachte Formen etc.) geloescht       }
{ werden. Ausserdem muss deren Compilierung zurueckgenommen werden.           }
{                                                                             }
{ _id : der Identifikator des Objekts, das die Regel enthaelt (i).            }
{                                                                             }
{ *************************************************************************** }




untell_BDMRule( _id) :-

        ForgetRule( _id),
        !.






{ ============================== EVALUATION ================================= }



{ *************************************************************************** }
{                                                                             }
{ tellCheck_BDMIntegrity(_propdescr)                                          }
{                                                                             }
{ This predicate checks wether a given _propdescr fulfills the                }
{ integrity constraints that concern this _propdescr.                         }
{                                                                             }
{ _propdescr: ein waehrend der TELL-Operation temporaer erzeugtes Objekt (i). }
{                                                                             }
{ *************************************************************************** }

tellCheck_BDMIntegrity( P( _id, _source, _label, _dest)) :-
	  (_label = '*instanceof'; _label = '*isa'),
        !,
                { Falls es sich um eine neue Integritaetsbedingung oder Regel }
                { handelt, so muss getestet werden, ob durch ihr Einfuegen    }
                { keine Inkonsistenz hervorgerufen wird:                      }
        tellRuleOrIntegrityConstraint(
                P( _id, _source, _label, _dest)),

                { Geht das neue Objekt direkt oder indirekt in Integritaets-  }
                { bedingungen ein, so muessen diese ueberprueft werden, ob    }
                { sie auch weiterhin gelten:                                  }
        tellObjectConcerningIntegrityConstraintsOrRules(
                P( _id, _source, _label, _dest)).



{ Es handelt sich um ein Objekt, das vom Integritaetstest nicht betrachtet   }
{ wird:                                                                      }

tellCheck_BDMIntegrity( _) :-

        !.








{ *************************************************************************** }
{                                                                             }
{ untellCheck_BDMIntegrity(_propdescr)                                        }
{                                                                             }
{ Wird ein Objekt durch die Operation UNTELL aus der aktuellen Datenbank      }
{ geloescht, so muss ueberprueft werden, ob danach deren Integritaet noch     }
{ gewaehrleistet ist, oder ob die Existenz des Objekts gefordert wird. Also:  }
{ Ist das Objekt eine Integritaetsbedingung, so braucht nichts getan werden.  }
{ Ist das Objekt eine Regel, so muss darauf geachtet werden, dass nicht eines }
{ der dann nicht mehr herleitbaren Objekte zu Integritaetsverletzung fuehrt.  }
{ Schliesslich sind solche Integritaetsbedingungen (u.U. nach Regelanwendung) }
{ zu testen, die evtl. die Existenz des Objekts verlangen, sie sind an der    }
{ Klasse zu finden, zu der das Objekt dann nicht mehr gehoert.                }
{                                                                             }
{ _propdescr: ein waehrend der UNTELL-Operation temporaer erzeugtes Objekt.   }
{                                                                             }
{ *************************************************************************** }


untellCheck_BDMIntegrity(
     P( _id, _source, _label, _dest)):-
	  (_label = '*instanceof'; _label = '*isa'),
        !,
                { Falls es sich um Regel handelt, so muss getestet werden, ob }
                { durch ihr Loeschen keine Inkonsistenz hervorgerufen wird:   }
        untellRule( P( _id, _source, _label, _dest)),

                { Geht das zu loeschende Objekt (in-)direkt in Integritaets-  }
                { bedingungen ein, so muessen diese ueberprueft werden, ob    }
                { sie auch weiterhin gelten:                                  }
        untellObjectConcerningIntegrityConstraintsOrRules(
            P( _id, _source, _label, _dest)).




{ Es handelt sich um ein Objekt, das vom Integritaetstest nicht betrachtet   }
{ wird:                                                                      }

untellCheck_BDMIntegrity( _) :-

        !.






{ ======================= (UN-) ACCEPT TRANSACTION ========================== }





{ *************************************************************************** }
{                                                                             }
{ mk_permanent_BDMFormulas( _ListOfBDMPredicates1, _listOfPredicates2, _mode) }
{                                                                             }
{ Wird eine Transaktion angenommen, so muessen die waehrend dessen            }
{ durchgefuehrten Eintragungen, Loeschungen und Aenderungen an BDM-Formel-    }
{ Praedikaten nun permanent abgespeichert werden.                             }
{ Handelte es sich um das Consulten einer SML-Datei, so wird die Liste aller  }
{ dabei erzeugten BDM-Formel-Praedikate zur Abspeicherung benoetigt.          }
{                                                                             }
{ Fuer Prozedurtrigger gilt, dass sowohl fuer den Tell als auch fuer den      }
{ untell Fall Einfuegungen und Loeschungen von Prozedurtriggern erforderlich  }
{ sein koennen. Deswegen werden zwei Listen uebergeben.                       }
{                                                                             }
{                                                                             }
{ *************************************************************************** }


mk_permanent_BDMFormulas( _listOfBDMPredicates1, _listOfPredicates2, _mode) :-

        mk_permanent_BDMFormula( _listOfBDMPredicates1, _listOfPredicates2, _mode),
        !.






{ *************************************************************************** }
{                                                                             }
{ rm_temp_BDMFormulas                                                         }
{                                                                             }
{ Wird eine Transaktion abgelehnt, so duerfen die waehrend dessen             }
{ durchgefuehrten Eintragungen, Loeschungen und Aenderungen an BDM-Formel-    }
{ Praedikaten nicht uebernommen werden, sondern es muss unter ihnen wieder    }
{ der Zustand wie von vor der Transaktion herrschen.                          }
{                                                                             }
{ *************************************************************************** }



rm_temp_BDMFormulas :-

        rm_temp_BDMFormula,
        !.
