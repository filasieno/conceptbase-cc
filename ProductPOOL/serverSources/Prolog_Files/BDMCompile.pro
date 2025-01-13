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
* File:         %M%
* Version:      %I%
*
* Last Change:  05-Dec-1996 LWEB  (RWTH)
*
* Date released : %E%  (YY/MM/DD)
*
* SCCS-Source-Pool : %P%
* Date retrieved : %D% (YY/MM/DD)
**************************************************************************
*
* This module is part of the BDMIntegrityChecker and
* is responsible for the compilation of new integrity constraints and rules.
*
*
*
* Exported predicates:
* --------------------
*
*   + NewIntegrityConstraint/3
*       Wird in das System eine neue Integritaetsbedingung eingefuegt (TELL), so
*       wird sie hier uebersetzt. Dazu gehoeren
*         - das Erkennen der Klassen, deren Instanzen durch die Integritaets-
*           bedingung betroffenen sein koennen,
*         - das Erstellen vereinfachter Formeln und auswertbare Formen davon,
*         - das Betrachten und eventuelle Uebersetzen von Regeln, die
*           Objekte erzeugen, die von der Integritaetsbedingung direkt oder
*           indirekt betroffen sein koennen,
*         - das Abspeichern der erstellten Formeln in internen Praedikaten,
*         - das Erstellen der Struktur entsprechend des Modells
*           (vgl. CompleteBDMRuleConstraintModel.sml).
*
*   + NewRule/4
*       Wird in das System eine neue Regel eingefuegt, so wird sie hier
*       uebersetzt, analog zu oben. Dazu gehoeren
*         - das Erkennen der Klassen, deren Instanzen durch die Regel
*           betroffenen sein koennen,
*       Falls Objekte, die von dieser Regeln erzeugt werden, in eine Inte-
*       gritaetsbedingung eingehen (direkt oder indirekt):
*         - das Erstellen vereinfachter Formeln und auswertbare Formen davon,
*         - das Betrachten und eventuelle Uebersetzen von Regeln, die
*           Objekte erzeugen, die ueber diese Regel von der Integritaets-
*           bedingung direkt oder indirekt betroffen sein koennen,
*       Und:
*         - das Abspeichern der erstellten Formeln in internen Praedikaten,
*         - das Erstellen der Struktur entsprechend des Modells
*           (vgl. CompleteBDMRuleConstraintModel.sml).
*
*
* 4-Jul-1990/MJf:
*   . triggers applyConstraintIfInsert, applyConstraintIfDelete,
*     applyRuleIfInsert, applyRuleIfDelete and deducedBy are now attributes
*     of PROPOSITION instead of CLASS
*
* 25.07.1990 RG:	Replaced STORE(propval...) by STORE(proposition...).
*
* 10-Aug-1992 MSt:     specialized forms in props represented by atoms(!)
*			     surrounded by $
*
* 08-Jun-93/kvt bugfix cf. ErrorsCorrected[11]
* 06-Jul-93/kvt Kapselung der Trigger in BDMKBMS.pro
* 26-May-95/LWEB Integrity Constraints werden um eine Stelle erweitert, die ID der Proposition Darstellung wird
		abgespeichert, um bei der Auswerung auf Modulsichtbarkeit der IC zu pruefen
*
* Metaformel-Aenderung(10.1.96)
* neues Praedikat NewProcTrigger

}


#MODULE(BDMCompile)
#EXPORT(NewIntegrityConstraint/3)
#EXPORT(NewProcTrigger/1)
#EXPORT(NewRule/3)
#ENDMODDECL()

#IMPORT(STORE/1,FragmentToPropositions)
#IMPORT(retrieve_proposition/1,PropositionProcessor)
#IMPORT(newIdentifier/1,validProposition)
#IMPORT(append/3,GeneralUtilities)
#IMPORT(member/2,GeneralUtilities)
#IMPORT(WriteTrace/3,GeneralUtilities)
#IMPORT(delete/3,GeneralUtilities)
#IMPORT(increment/1,GeneralUtilities)
#IMPORT(report_error/3,ErrorMessages)
#IMPORT(prove_literal/1,Literals)
#IMPORT(prove_edb_literal/1,Literals)
#IMPORT(not_prove_literal/1,Literals)
#IMPORT(RangeToEvaForm/6,BDMTransFormula)
#IMPORT(VarsOfRangeform/2,BDMTransFormula)
#IMPORT(avoidDoubleQuantifications/2,BDMTransFormula)
#IMPORT(ConcernedClass/4,BDMLiteralDeps)
#IMPORT(AdmissableConclusionClass/1,BDMLiteralDeps)
#IMPORT(WeakLiteral/1,BDMLiteralDeps)
#IMPORT(noTriggerLiteral/3,BDMLiteralDeps)
#IMPORT(store_BDMFormula/1,BDMKBMS)
#IMPORT(retrieve_BDMFormula_once/1,BDMKBMS)
#IMPORT(retrieve_BDMFormula/1,BDMKBMS)
#IMPORT(change_BDMFormula/2,BDMKBMS)
#IMPORT(convert/2,MSFOLassertionUtilities)
#IMPORT(name2id/2,GeneralUtilities)
#IMPORT(pc_atomconcat/2,PrologCompatibility)
#IMPORT(pc_atomconcat/3,PrologCompatibility)
#IMPORT(pc_atom_to_term/2,PrologCompatibility)
#IMPORT(get_cb_feature/2,GlobalParameters)
#IMPORT(id2name/2,GeneralUtilities)

#GLOBAL(ExamIcLiterals/6 )
#GLOBAL(ExamCondLitsForRuleOrIc/10 )

#IF(SWI)
:- style_check(-singleton).
#ENDIF(SWI)


{ ==================== }
{ Exported predicates: }
{ ==================== }



{ *************************************************************************** }
{                                                                             }
{ NewIntegrityConstraint( _ranges, _rangeform, _IcId)                         }
{                                                                             }
{ Dieses Praedikat verarbeitet eine neue Integritaetsbedingung. Vorausgesetzt }
{ ist, dass bereits ein Objekt (mit dem Identifikator _IcId) geschaffen ist,  }
{ das die Integritaetsbedingung darstellt.                                    }
{ Vorgehen:                                                                   }
{       - Abspeichern der gesamten Integritaetsbedingung.                     }
{	- Verarbeiten der Formel: mit jedem Literal der Formel                }
{	  (soweit dieses den Datenbestand beruehrt):                          }
{	  - Erkennen der Klassen, deren Instanzen durch dieses Literal        }
{	    betroffen sein koennen und                                        }
{	  - Erstellen der sogenannten vereinfachten Instanz der Integritaets- }
{	    bedingung bzgl. dieses Literals.                                  }
{	  - Suchen und Verarbeiten einer Regel, die Objekte erzeugt, die von  }
{           diesem Literal betroffen sein koennten.                           }
{	  - Abspeichern der gefundenen Informationen.                         }
{                                                                             }
{ _ranges    : Angaben ueber die vorkommenden Variablen                       }
{ _rangeform : die Formel der neuen Integritaetsbedingung, wegen des exakten  }
{	       Formats siehe anderwo, (i)                                     }
{ _IcId      : der Identifikator des Objekts, das die Integritaetsbedingung   }
{              darstellt. (i)                                                 }
{                                                                             }
{ *************************************************************************** }



NewIntegrityConstraint( _ranges, _rangeform, _IcId) :-

	VarsOfRangeform(_rangeform,_vars),
	convert(_rangeform,_rangeformO), {kvt}
	RangeToEvaForm(_vars,_ranges,_rangeformO, TRUE,_evaform, _),
	store_origConstraint(_evaform, _IcId),
	generateSpecializations(_vars,_ranges,_rangeformO,_IcId),
	!,
	'error_number@F2P'(0).   {Compilation must have been successful! }




generateSpecializations(_vars,_ranges, _rangeform, _IcId) :-
  PassThruRangeform(_rangeform,
	  ExamIcLiterals(_ranges, _rangeform, _IcId, _vars)),
  !.





{ *************************************************************************** }
{                                                                             }
{ NewRule(_ranges, _rangeform, _RuleId)                                       }
{                                                                             }
{ Wird eine neue Regel eingefuehrt, so wird sie mit diesem Praedikat verarbei-}
{ tet. Dabei wird vorausgesetzt, dass sie selber bereits als ein Objekt abge- }
{ legt ist. In Abhaengigkeit von der Art der Literale und deren Instanziie-   }
{ rungsgrads werden die Klassen bestimmt, deren Instanzen durch diese Litera- }
{ le betroffen sein koennen, sowie weitere Einschraenkungstest (analog zu dem }
{ Vorgehen bei einer neuen Integritaetsbedingung).                            }
{ Gehen die durch diese Regel erzeugten Objekte in einen Integritaetstest ein,}
{ so werden zusaetzliche Verweise an den durch die Bedingungsliterale betrof- }
{ fenen Objekte (bzw. deren Klassen) angelegt.                                }
{                                                                             }
{ _rangeform : Die deduktive Regel in der Form rangerule(_cond,_concl) (i)    }
{ _concl_lit : der Folgerungsteil der Regel, es handelt sich dabei um         }
{              ein einziges Literal, (i)                                      }
{ _RuleId     : der Identifikator des Objekts, das die Regel darstellt (i)    }
{                                                                             }
{ *************************************************************************** }


NewRule(_ranges, rangerule(_rangecond,_rangeconcl), _RuleId) :-

	VarsOfRangeform(_rangecond,_vars),

	{* 1. Abspeichern der vollstaendigen Regel:
	*}


	{* 1a. Dazu muss festgestellt werden, von welcher Klasse die Regel Instanzen herleiten kann:
	*}

	ConcernedClass(_vars,_ranges,_rangeconcl,_class),
	AdmissableConclusionClass(_class),
	convert(_rangecond,_rangecondO),

	RangeToEvaForm(_vars,_ranges, rangerule(_rangecondO,_rangeconcl),TRUE, evarule(_evaform_cond,_evaform_concl),_),


	{* 1c. Und nun werden die vollstaendige Regel, in internen Formaten, und die betroffene Klasse abgespeichert:
	*}
	  store_origRule(_evaform_cond, _evaform_concl, _RuleId, _class, ruleinfo(_rangecondO,_rangeconcl,_ranges,_vars)),

	{* 2. Compilieren der Regel:
	*}


	{* 2a. Compilieren der Regel bzgl. Einfuegeoperationen:
	*}

	{* Nachschauen, ob von der Klasse, deren Instanzen  durch das Regelkopfliteral betroffen sein koennten, Verweise bzgl. Integritaetsbedingungen oder Regeln ausgehen, die bei einer Einfuegeoperation zu testen waeren:
	*}

	findall( _SimpIcIdIns,
		   (
			retrieve_BDMFormula( 'applyConstraintIfInsert@BDMCompile'( _icID, _class, _SimpIcIdIns, _, _)),
			retrieve_proposition(P(_icID,_,_,_))	{ 26-May-1995 LWEB }
		   ),
		_ListOfSimpIcIdsInsert),

 	findall( _SimpRuleIdIns,
		retrieve_BDMFormula('applyRuleIfInsert@BDMCompile'( _RuleId, _class, _SimpRuleIdIns, _, _, _, _)),
		_ListOfSimpRuleIdsInsert),


	{* Und compilieren der gefundenen Formeln:
	*}
	((_ListOfSimpIcIdsInsert = [],
	  _ListOfSimpRuleIdsInsert = []
	 );
	 PassThruRangeform( _rangecondO, ExamCondLitsForRuleOrIc(Insert, _ranges, _rangecondO, _rangeconcl, _RuleId, _ListOfSimpIcIdsInsert, _ListOfSimpRuleIdsInsert, _vars))),


	{* 2b. Bzgl. Loeschoperationen:
	*}

	{* Nachschauen, ob von der Klasse, deren Instanzen durch das Regelkopfliteral betroffen sein koennten, Verweise bzgl Integritaetsbedingungen oder Regeln ausgehen, die bei einer Loeschoperation zu testen waeren:
	*}
	findall( _SimpIcIdDel,
		(
			retrieve_BDMFormula('applyConstraintIfDelete@BDMCompile'( _IcId, _class, _SimpIcIdDel, _, _)),
			retrieve_proposition(P(_IcId, _, _, _))		{ 26-May-1995 LWEB }
		),
		_ListOfSimpIcIdsDelete),
	findall( _SimpRuleIdDel,
		retrieve_BDMFormula('applyRuleIfDelete@BDMCompile'( _RuleId, _class, _SimpRuleIdDel, _, _, _, _)),
		_ListOfSimpRuleIdsDelete),

	{* Und compilieren der gefundenen Formeln:
	*}

 	((_ListOfSimpIcIdsDelete = [],
	  _ListOfSimpRuleIdsDelete = []
	 );
	 PassThruRangeform( _rangecondO, ExamCondLitsForRuleOrIc( Delete, _ranges, _rangecondO, _rangeconcl, _RuleId, _ListOfSimpIcIdsDelete, _ListOfSimpRuleIdsDelete, _vars))),
	!,
	{* Compilation must have been successful!
	*}
	'error_number@F2P'(0).


{* 16-Jul-1991/MJf: error handling
*}

NewRule(_ranges, rangerule(_rangecond,_rangeconcl), _RuleId) :-
	increment('error_number@F2P'),
	report_error(NORULE, BDMCompile, [objectName(_RuleId)]),
	!,
	fail.

{*****************************************************************************}
{                                                                             }
{ NewProcTrigger(_trig)                                                       }
{                                                                             }
{ der Trigger _trig hat den Funktor                                           }
{ applyPredicateIfInsert, bzw applyPredicateIfDelete und dient der Wartung    }
{ der aus Metaformeln erzeugten vereinfachten Formeln                         }
{ dieser wird direkt nach BDMKBMS durchgereicht                               }
{*****************************************************************************}

NewProcTrigger(_trig) :-
	store_BDMFormula(_trig).

{ =================== }
{ Private predicates: }
{ =================== }


{ =========================================================================== }
{ *************** Praedikate, die nur fuer neue ICs dienen: ***************** }
{ ========================================================================= }





{ ************************************************************************** }
{                                                                            }
{ ExamIcLiterals(_sign,_lit,_ranges,_rangeform,_IcId,_vars)                  }
{                                                                            }
{ Hier wird nun die Formel der Integritaetsbedingung bzgl. eines bestimmten  }
{ ihrer Literale verarbeitet, d.h.                                           }
{	1. Erkennen der betroffenen Klasse                                   }
{	2. Erstellen der vereinfachten Instanz der Integritaetsbedingung     }
{	3. Ueberpruefen, ob Regeln zu beachten sind                          }
{	4. Abspeichern der gefundenen Informationen.                         }
{                                                                            }
{ _sign      : Vorzeichen des Literals (i)                                   }
{ _lit       : Das Literal, bzgl. der die Integritaetsbedingung verarbeitet  }
{              werden soll, (i)                                              }
{ _ranges    : Tabelle, die Variablen ihre "Ranges" (Klassen) zuordnet (i)   }
{ _rangeform : die Formel der Integritaetsbedingung, die bzgl. des Literals  }
{              verarbeitet werden soll, (i)                                  }
{ _IcId      : der Identifikator des Objekts, das die Integritaetsbedingung  }
{              darstellt, (i)                                                }
{ _vars      : Information ueber die Variablen der Formel: vars(_a,_b)  (i)  }
{               _a = alle Variablen                                          }
{               _b = alle all-quantifizierten Variablen, die nicht im Gel-   }
{                    tungsbereich eines Existenzquantors liegen.             }
{                                                                            }
{ ************************************************************************** }

{* Wenn _lit ein 'weak literal' ist (Vergleichsoperatoren, Instanzen von    *}
{* Function wie COUNT), dann werden keine 'simplified rangeforms'           *}
{* generiert, da sich die Aenderung der Extension dieser Literale nicht     *}
{* (so einfach) inkrementell bestimmen laesst.                              *}

ExamIcLiterals(_sign, _lit, _ranges, _rangeform, _IcId, _vars) :-
  WeakLiteral(_lit),
  !.


ExamIcLiterals(_sign, _lit, _ranges, _rangeform, _IcId, _vars) :-
  ConcernedClass(_vars, _ranges, _lit, _class),
  ExamIcLiteralsCC(_sign, _lit, _class, _ranges, _rangeform, _IcId, _vars),
  !.


{* Issue #28: another case that an integrity constraint cannot be compiled correctly *}
ExamIcLiterals(_sign, _lit, _ranges, _rangeform, _IcId, _vars) :-
   get_cb_feature(forceConcernedClass,_ccmode),
   _ccmode \= 'off',
   increment('error_number@F2P'),
   report_error(NOSPEC, BDMCompile, [objectName(_IcId),formula(_lit)]),
   !,
   fail.




ExamIcLiteralsCC(_sign, _lit, _class, _ranges, _rangeform, _IcId, _vars) :-
  noTriggerLiteral(_class,_lit),
  !.


{3-Jun-2004/M.Jeusfeld: check for forbidden orccurences of query classes    *}
{* Only when a query class _class is also an instance of MSFOLrule, it can  *}
{* be referred to in a constraint (or rule). Reason: a query class needs to *}
{* be an instance of MSFOLrule to instruct ConceptBase to generate the      *}
{* triggers necessary for integrity checking.                               *}

ExamIcLiteralsCC(_sign, _lit, _class, _ranges, _rangeform, _IcId, _vars) :-
  prove_edb_literal(In_e(_class,id_65)),    {* id_65=QueryClass *}
  not_prove_literal(In(_class,id_46)),      {* id_46=MSFOLrule *}
  !,
  increment('error_number@F2P'),
  report_error(QUERYCLASS_NOT_IN_IC, BDMCompile, [objectName(_class),constraint,objectName(_IcId)]),
  !,
  fail.


{* 29-Nov-2005/M.Jeusfeld: generic query classes may not occur in constraints (or rules) *}
{* since the incremental constraint evaluator cannot handle them correctly. See also     *}
{* ticket #16 and #90.                                                                   *}
{* 31-Aug-2006/M.Jeusfeld: this is only enforced when CBserver parameter -cc             *}
{* (forceConcernedClass) is not set to off. Novice users are encouraged to use strict    *}
{* as it guarantees a more correct and stable behavior at the expense of flexibility.    *}

ExamIcLiteralsCC(_sign, _lit, _class, _ranges, _rangeform, _IcId, _vars) :-
  get_cb_feature(forceConcernedClass,_ccmode),
  _ccmode \= off,
  prove_literal(In(_class,id_72)),    {* id_72=GenericQueryClass *}
  !,
  increment('error_number@F2P'),
  report_error(GENERIC_QUERYCLASS_NOT_IN_IC, BDMCompile, [objectName(_class),constraint,objectName(_IcId)]),
  !,
  fail.





ExamIcLiteralsCC(_sign, _lit, _class, _ranges, _rangeform,
               _IcId, _vars) :-

  effectiveInsDel(_sign,Insert,_InsDel),

  SimplifyRangeform(_ranges,_rangeform,_InsDel,_lit,_vars,
                    _simplifiedrangeform),

  RangeToEvaForm(_vars,_ranges,_simplifiedrangeform,_lit,
                 _simplifiedevaform,_InstLiteral),
  constructStoredForm(_simplifiedrangeform,_ranges,_InsDel,_lit,_InstLiteral,_StoredForm),

  store_applyConstraint(_InsDel,_simplifiedevaform,_IcId,
                        _InstLiteral,_class,_SimpIcId,_StoredForm),

        { Untersuchen, ob eine Regel Objekte erzeugt, die von dem      }
	{ Literal betroffen sein koennten. Falls ja, muessen alle      }
	{ Klassen, deren Instanzen in Bedingungsliteralen dieser Regel }
	{ eingehen koennen, einen speziellen Verweis bekommen.         }
  RuleConcernsThisClass(_class, toldIC(_SimpIcId), _InsDel),
  !.



{ 16-Jul-1991/MJf: Fehlerbehandlung }

ExamIcLiteralsCC(_sign, _lit, _class, _ranges, _rangeform, _IcId, _vars) :-
   increment('error_number@F2P'),
   report_error(NOSPEC, BDMCompile, [objectName(_IcId),formula(_lit)]),
   !,
   fail.




{ ************************************************************************** }
{                                                                            }
{ SimplifyRangeform( _ranges, _rangeform, _InsDel,_lit, _vars,               }
{                    _simplifiedrangeform)                                   }
{                                                                            }
{ _ranges      : Tabelle der vorkommenden Variablen mit ihren "Ranges" (i)   }
{ _rangeform   : die zu vereinfachende Integritaetsbedingung (i),            }
{ _InsDel      : Indikator, ob die vereinfachte Ic bei Einfuege- oder Loesch-}
{                operation zu testen ist (i).                                }
{ _lit         : bzgl. dem die Ic vereinfacht werden soll (i),               }
{ _vars        : Variablen der Formel, vgl ExamIcLiterals (i),               }
{ _simplifiedrangeform : die vereinfachte Integritaetsbedingung (o),         }
{                                                                            }
{ Hier wird die angegebene Integritaetsbedingung bezueglich eines bestimmten }
{ ihrer Literale vereinfacht.                                                }
{                                                                            }
{ ************************************************************************** }


SimplifyRangeform(_ranges, _rangeform, _InsDel, _lit, _vars,
                  _simplifiedrangeform) :-

	_lit =.. [ _LiteralName | _LiteralArgs],

		{ 1. Eliminieren solcher Variablen, die als Argumente des Li- }
		{    terals auftauchen, und die allquantifiziert sind, aber   }
		{    nicht im Geltungsbereich eines Existenzquantors liegen:  }
	ElimQuantsInRangeform(_ranges,_LiteralArgs,_vars,_rangeform,
		              _rangeform_woquants,_all_elimed),

		{ 2. Unter bestimmten Umstaenden Weglassen des Literals in    }
		{    der Formel und diese vereinfachen:                       }
        InsertOrDelete(_all_elimed, _InsDel, _lit, _rangeform_woquants,
                       _simplifiedrangeform),

WriteTrace(veryhigh,BDMCompile,
           [idterm(SimplifyRangeform(_InsDel,_lit)),'--->',idterm(_simplifiedrangeform)]),


	!.






{ ************************************************************************** }
{                                                                            }
{ ElimQuantsInRangeform( _ranges,_LiteralArgs,_vars,_rangeform,   }
{                        _rangeform_woquants, _all_elimed)                   }
{                                                                            }
{ Loeschen der Quantifizierungen von solchen Variablen, die in den Argumenten}
{ eines Literals vorkommen, und die allquantifiziert sind, aber nicht unter  }
{ dem Geltungsbereich eines Existenzquantors stehen.                         }
{                                                                            }
{ _ranges      : Tabelle der vorkommenden Variablen mit ihren "Ranges" (i)   }
{ _LiteralArgs       : die Argumente eines Literals (i),                     }
{ _vars         : vgl. ExamIcLiterals (i),                                   }
{ _rangeform         : zu durchsuchende Formel, (i)                          }
{ _rangeform_woquants: dieselbe Formel nur ohne die Quantifizierung der      }
{                      Variablen, die ein Argument des Literals sind und     }
{                      ausserdem in vars(_,_b) aufgefuehrt sind, (o)         }
{ _all_elimed        : gibt an, ob alle Quantifizierungen der Variablen      }
{                      aus den Argumenten des Literals geloescht werden      }
{                      konnten (yes) oder nicht (no). (o)                    }
{                                                                            }
{ ************************************************************************** }



{ Fertig, nichts mehr zu tun.                                                }

ElimQuantsInRangeform(_ranges, [], _, _rangeform, _rangeform, yes) :- !.



{ Das erste (aktuelle) Argument ist eines Variable, die zudem auch noch in   }
{ der Liste _AllquVars aufgefuehrt ist (d.h. die Variable ist in der Formel  }
{ allquantifiziert und vor ihr taucht kein Existenzquantor auf). Deshalb wird}
{ die Quantifizierung der Variablen aus der Formel gestrichen.               }

ElimQuantsInRangeform(_ranges, [ _arg | _args_rest], vars(_a,_b),
                      _rangeform, _rangeform_woquants, _all_elimed) :-

	member( _arg, _b),
	!,
	ElimQuant( _arg, _rangeform, _rangeform_woquant),
	ElimQuantsInRangeform(_ranges,_args_rest, vars(_a,_b),
                              _rangeform_woquant,
	                      _rangeform_woquants, _all_elimed).




{ Das aktuelle Argument ist zwar eine Variable, aber sie taucht nicht }
{ in vars(_,_b) auf, d.h. hier ist nichts zu tun, weiter.             }
{ Insbesondere ist hiermit _all_elimed = no!                          }

ElimQuantsInRangeform(_ranges, [ _arg | _args_rest], vars(_a,_b),
                      _rangeform, _rangeform_woquants, no) :-

	member(_arg,_a),
	!,
	ElimQuantsInRangeform(_ranges, _args_rest, vars(_a,_b), _rangeform,
                              _rangeform_woquants, _).




{ Das erste (aktuelle) Argument ist eine Konstante,                  }
{ d.h. hier ist nichts zu tun, weiter.                               }

ElimQuantsInRangeform(_ranges, [_arg|_args_rest], _vars,
                      _rangeform, _rangeform_woquants, _all_elimed) :-

	!,
	ElimQuantsInRangeform(_ranges, _args_rest, _vars, _rangeform,
                              _rangeform_woquants, _all_elimed).





{ ************************************************************************** }
{                                                                            }
{ InsertOrDelete( _all_elimed, _InsDel, _lit, _rangeformWoQuants,            }
{                            _rangeformWoLit)                                }
{                                                                            }
{ Hier wird endgueltig die sogenannte vereinfachte Instanz einer Ic          }
{ bezueglich eines ihrer Literale erstellt. Die Quantifizierungen            }
{ von Variablen, die in diesem Literal vorkommen, wurden, soweit erlaubt,    }
{ bereits zuvor geloescht.                                                   }
{                                                                            }
{ _all_elimed        : gibt an, ob die Quantifizierungen aller Variablen,    }
{                      die in dem Literal vorkommen, geloescht wurden (yes)  }
{                      oder nicht (no), (i)                                  }
{ _InsDel            : gibt an, ob _rangeformWoQuants bezueglich der Ein-    }
{                      fuegung ('Insert') oder der Loeschung ('Delete')      }
{                      von _lit zu spezialisieren ist, (i)                   }
{ _lit               : das Literal aus der Formel, bzgl. dem die sogenann-   }
{                      te vereinfachte Instanz der Formel gebildet wird,(i)  }
{ _rangeformWoQuants : die Formel, wobei bereits die erforderlichen Loe-     }
{                      schungen von Quantifizierungen durchgefuehrt wurden,  }
{                      (i)                                                   }
{ _rangeformWoLit    : falls _all_elimed=yes und _InsDel=Insert, so werden   }
{                      negierte Vorkommen von _lit in _rangeformWoQuants     }
{                      durch FALSE ersetzt bzw. eliminiert (o)               }
{                                                                            }
{ ************************************************************************** }


{ falls nicht alle Variablen des angeschauten Literals _lit     }
{ eliminiert wurden, so kann _rangeform nicht weiter verein-    }
{ facht werden:                                                 }

InsertOrDelete(no, Delete, _lit, _rangeform, _rangeform) :- !.
InsertOrDelete(no, Insert, _lit, _rangeform, _rangeform) :- !.


{ Bei 'Delete' kann kein Literal verschwinden:                  }

InsertOrDelete(yes, Delete, _lit, _rangeform, _rangeform) :- !.


{ negatives _lit kommt in den (implizit negativen) Literalen    }
{ hinter einem 'forall' vor: Ersetze es durch FALSE, d.h.       }
{ loesche es einfach aus der Liste                              }
{ ### Annahme: _lit kommt hoechstens einmal in _lits vor; dies  }
{ ist sinnvoll, da  x and x = x or x = x                        }

InsertOrDelete(yes, Insert, _lit,
               forall(_vars,_lits,_rangeF),
               forall(_vars,_newlits,_rangeF)) :-
   member(_lit,_lits),
   delete(_lit,_lits,_newlits),
   !.

{ in einem inneren 'forall' suchen:                             }

InsertOrDelete(yes, Insert, _lit,
               forall(_vars,_lits,_rangeF),
               forall(_vars,_lits,_rangeFwoLit)) :-
  !,
  InsertOrDelete(yes, Insert,_lit,_rangeF,_rangeFwoLit).


{ Suchen in Konjunktionen und Disjunktionen:                    }

InsertOrDelete(yes, Insert, _lit,
               and(_rF1,_rF2),
               and(_newrF1,_newrF2)) :-
   InsertOrDelete(yes, Insert, _lit, _rF1, _newrF1),
   InsertOrDelete(yes, Insert, _lit, _rF2, _newrF2),
   !.

InsertOrDelete(yes, Insert, _lit,
               or(_rF1,_rF2),
               or(_newrF1,_newrF2)) :-
   InsertOrDelete(yes, Insert, _lit, _rF1, _newrF1),
   InsertOrDelete(yes, Insert, _lit, _rF2, _newrF2),
   !.


{ einzeln vorkommendes negatives Literal                       }
{ es wird bei 'Insert' durch FALSE ersetzt                     }

InsertOrDelete(yes, Insert, _lit,
               not(_lit),
               FALSE) :- !.


{ irgendein positives Literal (auch TRUE, FALSE)               }
{ es kann bei 'Insert' nicht ersetzt werden                    }

InsertOrDelete(yes, Insert, _lit, _somelit, _somelit) :- !.







{ ============================================================================ }
{ ***************** Praedikate, die Regeln verarbeiten: ********************** }
{ ============================================================================ }







{ *************************************************************************** }
{                                                                             }
{ ExamCondLitsForRuleOrIc( _sign,_Literal, _InsDelConcl ,                     }
{                          _RuleCondFormula, _RuleConcl, _RuleId,             }
{                      _ListOfSimpIcIds, _ListOfSimpRuleIds, _InsDel,_vars)   }
{                                                                             }
{ Hier wird jedes einzelne Literal einer Bedingungsformel einer Regel verar-  }
{ beitet: Erstellen der vereinfachten Form der Regel, Verweise zu anderen     }
{ Integritaetsbedingungen oder Regeln erstellen, ...                          }
{ Es wird die betroffene Klasse und die vereinfachte Form der Regel bestimmt  }
{ und abgespeichert, schliesslich werden von dieser vereinfachten Form die    }
{ Verweise zu anderen vereinfachten Regeln oder Integritaetsbedingungen       }
{ angelegt, die die Instanzen von der durch das Folgerungsliteral der         }
{ aktuellen Regeln betroffenen Klasse betreffen. Zuletzt muss untersucht      }
{ werden, ob Instanzen der durch das aktuelle Literal der aktuellen Formel    }
{ betroffenen Klasse selber durch eine Regel hergeleitet werden  koennen,     }
{ eine solche Regel muss dann nach dem selben Verfahren verarbeitet werden.   }
{                                                                             }
{ _sign              : Vorzeichen des Literals (i).                           }
{ _lit               : Das aktuelle Literal der Bedingungsformel der aktuellen}
{                      Regel, das nun verarbeitet werden soll, (i)            }
{ _RuleCondFormula   : die Bedingungsformel der aktuellen Regel, (i)          }
{ _RuleConcl         : das Folgerungsliteral der aktuellen Regel, (i)         }
{ _RuleId            : der Identifikator des Objekts, das die aktuelle Regel  }
{                      darstellt, (i)                                         }
{ _ListOfSimpIcIds   : eine Liste der Identifikatoren von vereinfachten Formen}
{                      von Integritaetsbedingungen, in die Instanzen der Klas-}
{                      se eingehen, die durch das Folgerungsliteral der aktu- }
{                      ellen Regeln betroffen ist, (i)                        }
{ _ListOfSimpRuleIds : dasselbe mit vereinfachten Regeln, (i)                 }
{                                                                             }
{ *************************************************************************** }

{* similar to ExamIcLiterals *}

{ Weak litarals are for example comparison literals  }

ExamCondLitsForRuleOrIc( _sign,_lit,_InsDelConcl, _ranges,
                         _rangecond, _rangeconcl, _RuleId,
                         _ListOfSimpIcIds, _ListOfSimpRuleIds,_vars) :-
  WeakLiteral(_lit),
  !.


ExamCondLitsForRuleOrIc( _sign,_lit,_InsDelConcl, _ranges,
                         _rangecond, _rangeconcl, _RuleId,
                         _ListOfSimpIcIds, _ListOfSimpRuleIds,_vars) :-
  ConcernedClass(_vars, _ranges, _lit, _class), {* only compute the concerned class once *}
  ExamCondLitsForRuleOrIcCC( _sign,_lit,_InsDelConcl, _class, _ranges,
                         _rangecond, _rangeconcl, _RuleId,
                         _ListOfSimpIcIds, _ListOfSimpRuleIds,_vars).


ExamCondLitsForRuleOrIcCC( _sign,_lit,_InsDelConcl, _class, _ranges,
                         _rangecond, _rangeconcl, _RuleId,
                         _ListOfSimpIcIds, _ListOfSimpRuleIds,_vars) :-
  prove_edb_literal(In_e(_class,id_65)),  {* id_65=QueryClass *}
  not_prove_literal(In(_class,id_46)),    {* id_46=MSFOLrule *}
  !,
  increment('error_number@F2P'),
  report_error(QUERYCLASS_NOT_IN_IC, BDMCompile, [objectName(_class),rule,objectName(_RuleId)]),
  !,
  fail.


{* same exclusion of GenericQueryClass as for ExamIcLiterals: *}

ExamCondLitsForRuleOrIcCC( _sign,_lit,_InsDelConcl, _class, _ranges,
                         _rangecond, _rangeconcl, _RuleId,
                         _ListOfSimpIcIds, _ListOfSimpRuleIds,_vars) :-
  prove_literal(In(_class,id_72)),   {* id_72=GenericQueryClass *}
  !,
  increment('error_number@F2P'),
  report_error(GENERIC_QUERYCLASS_NOT_IN_IC, BDMCompile, [objectName(_class),constraint,objectName(_IcId)]),
  !,
  fail.





{ the literal _lit with concerned class _class is a no trigger literal, e.g. }
{ because _class is an immutable attribute                                   }
ExamCondLitsForRuleOrIcCC( _sign,_lit,_InsDelConcl, _class, _ranges,
                         _rangecond, _rangeconcl, _RuleId,
                         _ListOfSimpIcIds, _ListOfSimpRuleIds,_vars) :-
  noTriggerLiteral(_class,_lit),
  !.


ExamCondLitsForRuleOrIcCC( _sign,_lit,_InsDelConcl, _class, _ranges,
                         _rangecond, _rangeconcl, _RuleId,
                         _ListOfSimpIcIds, _ListOfSimpRuleIds,_vars) :-

   effectiveInsDel(_sign,_InsDelConcl,_effInsDel),

		{ Erstellen der vereinfachten Form der Regel:                 }
   SimplifyRangeform(_ranges, _rangecond, _effInsDel, _lit, _vars,
                  _simplifiedrangecond),

   RangeToEvaForm(_vars,_ranges,rangerule(_simplifiedrangecond,_rangeconcl),
                  _lit, evarule(_evacond,_evaconcl),_InstLiteral),

		{ Abspeichern der gefundenen Informationen:                   }
   store_applyRule( _effInsDel,
                 _evacond, _evaconcl, _RuleId,
	         _InstLiteral, _class, _InsDelConcl,
	         _ListOfSimpIcIds, _ListOfSimpRuleIds, _SimpRuleId),


		{ Werden Instanzen der betroffenen Klasse von einer Regel     }
		{ hergeleitet?                                                }
   RuleConcernsThisClass( _class, toldRule(_SimpRuleId), _effInsDel),

   !.







{ 16-Jul-1991/MJf: Fehlerbehandlung }

ExamCondLitsForRuleOrIcCC( _sign,_lit,_InsDelConcl, _class, _ranges,
                         _rangecond, _rangeconcl, _RuleId,
                         _ListOfSimpIcIds, _ListOfSimpRuleIds,_vars) :-
   increment('error_number@F2P'),
   report_error(NOSPEC, BDMCompile, [objectName(_RuleId),formula(_lit)]),
   !,
   fail.


{ *************************************************************************** }
{                                                            5-Nov-1990/MJf   }
{ effectiveInsDel( _sign, _InsDelOfConcl, _effInsDel)                         }
{                                                                             }
{ Dieses Praedikat berechnet aus dem Vorzeichen des Literalvorkommens (ge-    }
{ geben durch _sign) und der benoetigte Operation des Folgerungs-             }
{ literals (_InsDelOfConcl) die resultierende Operation auf dem Literalvor-   }
{ kommen:                                                                     }
{                                                                             }
{    _sign=negative (neg. Literalvorkommen)                                   }
{    _InsDelOfConcl=Insert (Insert des Folg.literals soll ueberwacht werden)  }
{    ===>                                                                     }
{    _effInsDel=Insert (ueberwache Insert des Literalvorkommens!)             }
{                                                                             }
{    _sign=positive (pos. Literalvorkommen)                                   }
{    _InsDelOfConcl=Insert (Insert des Folg.literals soll ueberwacht werden)  }
{    ===>                                                                     }
{    _effInsDel=Delete (ueberwache Delete des Literalvorkommens!)             }
{                                                                             }
{    _sign=negative (neg. Literalvorkommen)                                   }
{    _InsDelOfConcl=Delete (Delete des Folg.literals soll ueberwacht werden)  }
{    ===>                                                                     }
{    _effInsDel=Delete (ueberwache Delete des Literalvorkommens!)             }
{                                                                             }
{    _sign=positive (pos. Literalvorkommen)                                   }
{    _InsDelOfConcl=Delete (Delete des Folg.literals soll ueberwacht werden)  }
{    ===>                                                                     }
{    _effInsDel=Insert (ueberwache Insert des Literalvorkommens!)             }
{                                                                             }
{ Beachte: Integritaetsbedingungen koennen als Regeln angesehen werden, die   }
{ TRUE als Folgerungsliteral haben. Es ist also _InsDelOfConcl=Insert anzu-   }
{ setzen!                                                                     }
{                                                                             }
{                                                                             }
{ *************************************************************************** }

effectiveInsDel(negative,Insert,Insert) :- !.
effectiveInsDel(positive,Insert,Delete) :- !.
effectiveInsDel(negative,Delete,Delete) :- !.
effectiveInsDel(positive,Delete,Insert) :- !.








{ *************************************************************************** }
{                                                                             }
{ RuleConcernsThisClass( _ClassId, _told, _InsDel)                            }
{                                                                             }
{ Die Instanzen der ang. Klasse gehen (in-)direkt in Integritaetstest ein.    }
{ Falls die Instanzen der angegebenen Klasse durch eine Regel hergeleitet     }
{ werden, so muessen die Klassen, deren Instanzen in diese Regel eingehen,    }
{ einen speziellen Verweis auf eine vereinfachte Form dieser Regel bekommen,  }
{ von dieser vereinfachten Form muss ein Verweis auf die Regel oder Integri-  }
{ taetsbedingung angelegt werden, in die die Instanzen der angegebenen Klasse }
{ eingehen.                                                                   }
{                                                                             }
{ _ClassId : Identifikator der Klasse, die auf Regelabhaengigkeit untersucht  }
{            werden soll, (i)                                                 }
{ _told    : enthaelt den Identifikator der fuer die Operation _InsDel ver-   }
{            einfachten Form (i)                                              }
{               toldIC(_SimpIcId) - _SimpIcId wurde neu generiert fuer die    }
{                                   Operation _InsDel auf _ClassId            }
{               toldIC(_SimpRuleId) - analog, allerdings wurde eine Regel ge- }
{                                   neriert                                   }
{ _InsDel  : Indikator, ob _told fuer Einfuege- oder Loeschoperation verant-  }
{            wortlich ist (i)                                                 }
{                                                                             }
{ *************************************************************************** }



RuleConcernsThisClass( _ClassId, _told, _InsDel):-


		{ 1. Werden Instanzen der betroffenen Klasse von einer Regel  }
		{ hergeleitet?                                                }
        prove_edb_literal(  A_e(_ClassId,Proposition,deducedBy,_OrigRuleId) ),

        prove_edb_literal(  A_e(_RuleId,MSFOLrule,originalRule,_OrigRuleId) ),


		{ Ja, und zwar durch die Regel mit dem Identifikator _RuleId. }


		{ 2. Verarbeiten dieser Regel:                                }

	RuleConcernsThisClass_help( _OrigRuleId, _RuleId, _told, _InsDel),




		{ Damit alle Regeln betrachtet werden, die Instanzen der an-  }
		{ gegebenen Klasse herleiten:                                 }
	fail.



RuleConcernsThisClass( _, _, _):-

	!.






RuleConcernsThisClass_help( _OrigRuleId, _RuleId, _told, _InsDel) :-

        { 1. Bestimme alle vereinfachten Formen von _RuleId }

        findall(_simprule,
                prove_edb_literal(A_e(_RuleId,MSFOLrule,specialRule,_simprule)),
                _allsimprules),

        updateGoAheads(_allsimprules,_RuleId,_told,_InsDel,
                       _InsDel,_unsupported),

        recompileRule(_OrigRuleId,_RuleId,_told,_unsupported),

        !.




{*  Die Regel war schon fuer den gewuenschten Fall compiliert: }

recompileRule(_OrigRuleId,_RuleId,_told, nil) :-  !.


{* sonst:   }

recompileRule(_OrigRuleId,_RuleId,_told,_InsDel) :-

		{ Holen der Formel der Regel:                                 }
	retrieve_BDMFormula(
              'origRule@BDMCompile'( _RuleId, _, _body,
                           ruleinfo(_rangecond,_rangeconcl,_ranges,_vars)) ),

		{ Verarbeiten der Formel, d.h. die Informationen fuer jedes   }
		{ einzelne Literal der Formel erstellen:                      }

        WriteTrace(high,BDMCompile, ['Original rule with body ',idterm(_body),
                   ' has to be re-compiled for the case "', _InsDel,
                   '" of its conclusion literal ',idterm(_rangeconcl)]),

        newGoAheads(_told,_ListOfSimpIcIds,_ListOfSimpRuleIds),

        !,

	PassThruRangeform( _rangecond,
	   ExamCondLitsForRuleOrIc(_InsDel,_ranges,_rangecond,_rangeconcl,_RuleId,
	             _ListOfSimpIcIds,_ListOfSimpRuleIds,_vars)),
	!.



newGoAheads(  toldIC(_SimpIcId),      [_SimpIcId],  []             ).
newGoAheads(  toldRule(_SimpRuleId),  [],           [_SimpRuleId]  ).






{ Wenn die Regel (_RuleId), die Instanzen der Klasse herleitet, die in eine   }
{ neue Integritaetsbedingung oder Regel eingeht, schon uebersetzt ist, so     }
{ braucht nur noch die neue zusaetzliche Information abgespeichert zu werden, }
{ was nach Anwendung dieser Regel neues zu tun ist.                           }

{ _unsupported zeigt an, ob noch eine Re-Compilation der Regel noetig ist.    }
{ Dieser Fall tritt ein, wenn die Regel noch nicht fuer den die Operation     }
{ _InsDel des Folgerungsliterals vereinfacht worden ist.                      }

updateGoAheads([],_RuleId,_told,_InsDel,
               _unsupported,_unsupported) :- !.

updateGoAheads([_SimpRuleId|_rest],_RuleId,_told,_InsDel,
               _tillNow,_unsupported) :-
        newGoAheads(_told,_ListOfSimpIcIds,_ListOfSimpRuleIds),

	store_more_applyConsRule(_InsDel,_SimpRuleId,_ListOfSimpIcIds,
		_ListOfSimpRuleIds),

        !,

        updateGoAheads(_rest,_RuleId,_told,_InsDel,
                       nil,_unsupported).


{ Beachte: store_more_applyConsRule fuehrt zu einem fail, falls _SimpRuleId   }
{ in seinem goAhead nicht _InsDel unterstuetzt.                               }

updateGoAheads([_|_rest],_RuleId,_told,_InsDel,
               _tillNow,_unsupported) :-
       updateGoAheads(_rest,_RuleId,_told,_InsDel,_tillNow,_unsupported).








{ =========================================================================== }
{ ****** Praedikate, die sowohl fuer neue ICs als auch Regeln dienen: ******* }
{ =========================================================================== }


{* 20-Nov-2002/M.Jeusfeld: excludeDoublettes cares for the exclusion of double *}
{* occurrences of matchable literals _lit1,_lit2 in _lits in order not to      *}
{* generate simplified forms for both _lit1 and _lit2.                         *}
{*   Example:                                                                  *}
{*       forall([x1,x2,z],[P1(x1,m,x2),P2(x1,z),P1(x2,m,x1)],_f)               *}
{* Heres, the two literals P1(x1,m,x2) and P1(x2,m,x1) are matching. We only   *}
{* have to feed incremental updates (delete,insert) into one of the two        *}
{* occurrences. Note: the second occurrence is excluded from having simplified *}
{* forms (triggers) gerenarted for it. It does not mean that it is eliminated  *}
{* from the formula as such.                                                   *}
{* Note: The directly quantified variables of _lit1 must the the same as those *}
{* of _lit2. Then, any trigger to the one literal fully instantiates the other *}
{* and vice versa.                                                             *}


excludeDoublettes(_vars,_lits,_newlits) :-
  removeDoublettes(_vars,_lits,_newlits),
  !.

removeDoublettes(_vars,[_lit|_restlits],_restnewlits) :-
  occursDoublette(_vars,_lit,_restlits),
  !,
  removeDoublettes(_vars,_restlits,_restnewlits).

removeDoublettes(_vars,[_lit|_restlits],[_lit|_restnewlits]) :-
  removeDoublettes(_vars,_restlits,_restnewlits).

removeDoublettes(_vars,[],[]).


occursDoublette(_vars,_lit1,[_lit2|_]) :-
  matchableLit(_vars,_lit1,_lit2),
  WriteTrace(veryhigh,BDMCompile,
           ['The literal occurs ',idterm(_lit1), ' has doublette ',idterm(_lit2),' and does not require trigger generation']),
  !.

occursDoublette(_vars,_lit,[_|_rest]) :-
  occursDoublette(_vars,_lit,_rest).

matchableLit(_vars,_lit1,_lit2) :-
  _lit1 =.. [_pred|_args1],
  _lit2 =.. [_pred|_args2],
  sameSignature(_vars,_args1,_args2),
  !.

sameSignature(_allvars,_args1,_args2) :-
  checkSameSignature(_allvars,_args1,_args2,_args1,_args2).

checkSameSignature(_,_args1,_args2,[],[]).

checkSameSignature(_allvars,_args1,_args2,[_x|_rest1],[_y|_rest2]) :-
  matchingArgs(_allvars,_args1,_args2,_x,_y),
  checkSameSignature(_allvars,_args1,_args2,_rest1,_rest2).

matchingArgs(_allvars,_args1,_args2,_x,_x) :- !.

matchingArgs(_allvars,_args1,_args2,_x,_y) :-
  member(_x,_allvars),
  member(_y,_allvars),
  member(_x,_args2),    {* this makes sure that _lit1 and _lit2 have *}
  member(_y,_args1),    {* exactly the same vars                     *}
  !.




{ *************************************************************************** }
{                                                                             }
{ PassThruRangeform( _rangeform, _Predicate)                                  }
{                                                                             }
{ Dieses Praedikat durchlaeuft lediglich die Formel, um dann die einzelnen    }
{ Literale an die Verarbeitung weiterzugeben. Die spezielle Weiterverarbeitung}
{ wird durch das angegebene Praedikat bestimmt.                               }
{ Das aktuelle zu verarbeitende Literal wird den Argumenten dieses Praedikats }
{ vorangestellt.                                                              }
{                                                                             }
{ _rangeform : Die Formel, wird durchlaufen, (i)                              }
{ _Predicate : das auszufuehrende Praedikat fuer jedes einzelne Literal der   }
{              Formel. (i)                                                    }
{                                                                             }
{ *************************************************************************** }


PassThruRangeform(forall(_vars,_lits,_rangeF),_GenericPred) :-
  excludeDoublettes(_vars,_lits,_newlits),
  PassThruLits(negative,_newlits,_GenericPred),
  PassThruRangeform(_rangeF,_GenericPred),
  !.

PassThruRangeform(exists(_vars,_lits,_rangeF),_GenericPred) :-
  excludeDoublettes(_vars,_lits,_newlits),
  PassThruLits(positive,_newlits,_GenericPred),
  PassThruRangeform(_rangeF,_GenericPred),
  !.

PassThruRangeform(and(_rF1,_rF2),_GenericPred) :-
  PassThruRangeform(_rF1,_GenericPred),
  PassThruRangeform(_rF2,_GenericPred),
  !.

PassThruRangeform(or(_rF1,_rF2),_GenericPred) :-
  PassThruRangeform(_rF1,_GenericPred),
  PassThruRangeform(_rF2,_GenericPred),
  !.

PassThruRangeform(not(_lit),_GenericPred) :-
  PassThruLits(negative,[_lit],_GenericPred),
  !.

PassThruRangeform(TRUE, _GenericPred) :- !.
PassThruRangeform(FALSE, _GenericPred) :- !.

PassThruRangeform(_lit, _GenericPred) :-
  _lit =.. [_f|_args],
  \+(member(_f,['forall','exists','and','or','not','TRUE','FALSE'])),
  PassThruLits(positive,[_lit],_GenericPred),
  !.


{ Wenn nichts zutrifft: sofortiger Erfolg}

PassThruRangeform(_anyLit, _anyPred) :- !.


{ Abarbeiten der Aufrufe fuer eine Liste von CML/Telos-Literalen :  }
{   _sign: Vorzeichen des Literals ('positive' oder 'negative') (i) }

PassThruLits(_sign,[],_GenericPred) :- !.

PassThruLits(_sign,[_lit|_rest],_GenericPred) :-
  _GenericPred =.. [_P|_args],
  _callPred =.. [_P,_sign,_lit|_args],
  call(_callPred),
  !,
  PassThruLits(_sign,_rest,_GenericPred).





{ *************************************************************************** }
{                                                                             }
{ ElimQuant( _Variable, _Formula, _FormulaWithoutQuant)                       }
{                                                                             }
{ Die Quantifizierung der angegebenen Variablen wird in der Formel geloescht. }
{                                                                             }
{ _Variable               : Variable, deren Quantifizierung in der Formel     }
{                           geloescht werden soll, (i)                        }
{ _Formula                : Formel, (i)                                       }
{ _FormulaWithoutQuant    : dieselbe Formel nur ohne die Quantifizierung der  }
{                           Variablen. (o)                                    }
{                                                                             }
{ 9-Aug-1990/MJf: Adaption an allgemeinere "range form"                       }
{                                                                             }
{ *************************************************************************** }



ElimQuant(_var, forall(_vars,_lits,_rangeF),
          forall(_newvars,_lits,_rangeF)) :-
  member(_var,_vars),
  delete(_var,_vars,_newvars),
  !.

ElimQuant(_var, forall(_vars,_lits,_rangeF),
          forall(_vars,_lits,_newrangeF)) :-
  ElimQuant(_var, _rangeF, _newrangeF),
  !.

{ ... in exists-Teilformeln wird kein Quantor mehr eliminiert, da man bei    }
{ Loeschungen von Literalen nicht sicherstellenkann, dass es nicht trotzdem  }
{ weiter ableitbar ist!                                 9-Aug-1990/MJf       }

ElimQuant(_var, and(_rf1,_rf2), and(_newrf1,_newrf2)) :-
  ElimQuant(_var, _rf1, _newrf1),
  ElimQuant(_var, _rf2, _newrf2),
  !.

ElimQuant(_var, or(_rf1,_rf2), or(_newrf1,_newrf2)) :-
  ElimQuant(_var, _rf1, _newrf1),
  ElimQuant(_var, _rf2, _newrf2),
  !.

{  .. sonst (exists, pos/neg Literale, TRUE, FALSE) : mache nichts }

ElimQuant(_var,_rangeF,_rangeF).






{ *************************************************************************** }
{                                                                             }
{ assign_Component( _comp)                                                    }
{                                                                             }
{ Hilfspraedikat: Entsprechend assign_ID@validProposition.                    }
{                                                                             }
{ _comp : bekommt einen systemdefinierten Identifikator zugeordnet (o).       }
{                                                                             }
{ *************************************************************************** }



assign_Component(_comp) :-
  newIdentifier(_idNew),
  pc_atomconcat(_idNew,'generated',_comp).  {* mark the label with the word 'generated' *}






{ =========================================================================== }
{ *************************************************************************** }
{ *************************************************************************** }
{                                                                             }
{ *************      S   U   B   M   O   D   U   L   E      ***************** }
{                                                                             }
{                                                                             }
{                     SSSS  TTTTT   OOO   RRRR   EEEEE                        }
{                    S        T    O   O  R   R  E                            }
{                     SSS     T    O   O  RRRR   EEEE                         }
{                        S    T    O   O  R  R   E                            }
{                    SSSS     T     OOO   R   R  EEEEE                        }
{                                                                             }
{                                                                             }
{ Hier befinden sich ausschliesslich die Praedikate, die sich mit der         }
{ Erzeugung von Prolog-Praedikaten beschaeftigen.                             }
{ Achtung: alle diese Praedikate sind voellig analog zu denen aus dem         }
{ Submodule STORE@BDMForget, d.h. aendert sich etwas an der Abspeicherung,    }
{ so muss es entsprechend dort geaendert werden und umgekehrt!                }
{                                                                             }
{ Mit folgenden Praedikaten laesst sich abspeichern:                          }
{      store_origConstraint( _IcFormulaMerged, _IcId)                         }
{      store_origRule( _RuleCondFormula, _RuleCondFormulaMerged, _RuleConcl,  }
{                      _RuleId,_ClassId,_ruleinfo)                            }
{      store_applyConstraint( _InsDel, _IcFormulaMerged, _IcId,               }
{                             _Literal, _ClassId, _SimpIcId)                  }
{      store_applyRule( _InsDel,                                              }
{                       _RuleCondMerged, _RuleConcl, _RuleId,                 }
{                       _Literal, _ClassId, _InsDelOfConcl,                   }
{                       _ListOfSimpIcIds, _ListOfSimpRuleIds, _SimpRuleId)    }
{      store_more_applyConsRule( _InsDel, _SimpRuleId, _ListOfSimpIcIds,      }
{                                _ListOfSimpRuleIds)                          }
{                                                                             }
{ *************************************************************************** }
{ *************************************************************************** }





{ *************************************************************************** }
{                                                                             }
{ store_origConstraint( _IcFormula, _IcId)                                    }
{                                                                             }
{ erzeugt die propvals und das BDMPraedikat fuer die vollstaendige            }
{ Integritaetsbedingung, wie sie eingegeben wurde, aber bereits umgeformt in  }
{ das BDMFormat und mit untergemischten Quantoren (d.h. sie wird Instanz von  }
{ BDMConstraintCheck).                                                        }
{                                                                             }
{ _IcFormula : die vollstaendige Integritaetsbedingung, im BDMFormat mit      }
{              untergemischten Quantoren (i),                                 }
{ _IcId      : der Identifikator des Objekts, das die vollstaendige Integri-  }
{              taetsbedingung darstellt (also Instanz von BDMConstraint) (i), }
{                                                                             }
{ *************************************************************************** }


store_origConstraint( _IcFormula, _IcId) :-


		{ 1. Abspeichern der propvals:                                }

		{ 1a. Erstellen eines Objekts, das die Integritaetsbedingung  }
		{     in ihrer internen, vollstaendigen Darstellung enthaelt: }
	pc_atom_to_term( _IcFormula_flat, _IcFormula),
	disambiguateCodeLabel(_IcFormula_flat,_IcFormula_flat_dollar),
{	assign_Component( _OrigIcId),      }
	STORE(P(_OrigIcId,_OrigIcId,_IcFormula_flat_dollar,_OrigIcId)),
	name2id(BDMConstraintCheck,_BDMconChId),
	STORE(P(_IoId1,_OrigIcId,'*instanceof',_BDMconChId)),
		{ 1b. Erstellen eines Verweises von der Integritaetsbedingung }
		{ zu ihrer internen, vollstaendigen Darstellung:              }
	assign_Component( _Label),
	STORE(P( _ConId, _IcId, _Label, _OrigIcId)),
	retrieve_proposition(
              P(_AttrCatId,id_52, originalConstraint, _BDMconChId)),   {* id_52=MSFOLconstraint *}
	STORE(P(_IoId2,_ConId,'*instanceof',_AttrCatId)),


		{ 2. Abspeichern des BDMPraedikats:                           }

	store_BDMFormula('origConstraint@BDMCompile'( _IcId, _OrigIcId, _IcFormula)),	{ 26-May-1995 LWEB }
	!.








{ *************************************************************************** }
{                                                                             }
{ store_origRule( _RuleCondFormulaMerged,                                     }
{                 _RuleConcl, _RuleId, _ClassId, _ruleinfo)                   }
{                                                                             }
{ erzeugt die propvals und das BDMPraedikat fuer die vollstaendige            }
{ Regel, wie sie eingegeben wurde, bereits umgeformt in das BDMFormat         }
{ (gemischt und und ungemischt) (d.h. sie wird Instanz von BDMRuleCheck).     }
{                                                                             }
{ _RuleCondFormula : die vollstaendige Regelfolgerung (i),                    }
{ _RuleCondFormulaMerged : die vollstaendige Regelfolgerung, gemischt (i),    }
{ _RuleConcl : das Folgerungsliteral der Regel (i),                           }
{ _RuleId    : der Identifikator des Objekts, das die vollstaendige Regel     }
{              darstellt (also Instanz von BDMRule) (i),                      }
{ _ClassId   : der Identifikator der Klasse, von der Instanzen durch die      }
{              Regel hergeleitet werden koennen (i).                          }
{ _ruleinfo  : range form der ganzen Regel mit ranges und Variablen (i)       }
{                                                                             }
{ *************************************************************************** }

store_origRule(_RuleCondFormulaMerged, _RuleConcl,
                _RuleId, _ClassId, _ruleinfo) :-


		{ 1. Abspeichern der propvals:                                }

		{ 1a. Erstellen eines Objekts, das die Regel in ihrem         }
		{ internen, vollstaendigem Format darstellt:                  }
	pc_atom_to_term( _Rule_flat,
	    Rule( Condition( _RuleCondFormulaMerged), Conclusion( _RuleConcl))),
	disambiguateCodeLabel(_Rule_flat,_Rule_flat_dollar),
	{assign_Component( _OrigRuleId),}
	STORE(P(_OrigRuleId,_OrigRuleId,_Rule_flat_dollar,_OrigRuleId)),
	name2id(BDMRuleCheck,_BDMruleChId),
	STORE(P(_IoId1,_OrigRuleId,'*instanceof',_BDMruleChId)),
		{ 1b. Erstellen eines Verweises von der Regel zu ihrer        }
		{ internen, vollstaendigen Darstellung:                       }
	assign_Component( _Label2),
	STORE(P(_ConId2,_RuleId,_Label2,_OrigRuleId)),
	retrieve_proposition(
           P( _AttrCatId2, id_46, originalRule, _BDMruleChId)),    {* id_46=MSFOLrule *}
	STORE(P(_IoId2,_ConId2,'*instanceof',_AttrCatId2)),

  		{ 1c. Erstellen eines Verweises von der Klasse, die durch das }
		{ Folgerungsliteral der Regel betroffen ist, zu der internen  }
		{ vollstaendigen Regel:                                       }
	assign_Component( _Label3),
	STORE(P(_ConId3,_ClassId,_Label3,_OrigRuleId)),


	retrieve_proposition(
                      P( _AttrCatId3, id_0, deducedBy, _BDMruleChId)),     {* id_0=Proposition *}
	STORE(P(_IoId3,_ConId3,'*instanceof',_AttrCatId3)),


		{ 2. Abspeichern des BDMPraedikats: }
	store_BDMFormula( 'origRule@BDMCompile'( _RuleId, _RuleConcl,_RuleCondFormulaMerged, _ruleinfo)),

	!.







{ *************************************************************************** }
{                                                                             }
{ store_applyConstraint( _InsDel,                                             }
{                        _IcFormula, _IcId,                                   }
{                        _Literal, _ClassId, _SimpIcId,                       }
{                        _StoredForm)                                         }
{                                                                             }
{ erzeugt die propvals und das BDMPraedikat fuer eine spezialisierte Integri- }
{ taetsbedingung.                                                             }
{                                                                             }
{ _InsDel    : = Insert, falls Ic bei einer Einfuegeoperation zu testen ist,  }
{              = Delete, "     "  "   "     Loesch-"          "  "      " (i).}
{ _IcFormula : die spezialisierte Integritaetsbedingung, im gemischten        }
{              BDMFormat (i),                                                 }
{ _IcId      : der Identifikator des Objekts, das die urspruengliche Integri- }
{              taetsbedingung (Instanz von MSFOLconstraint) darstellt (i),    }
{ _Literal   : bzgl. dem die Ic zu _IcFormula vereinfacht wurde (i),          }
{ _ClassId   : Id der Klasse, deren Instanzen das Literal matchen koennen (i),}
{ _SimpIcId  : Id des Objekts, das die vereinfachte Ic darstellt (o).         }
{ _StoredForm: Format aus constructStoredForm, die als Prop. ans entspr.      }
{              Attribut gehaengt wird(i).                                     }
{                                                                             }
{ *************************************************************************** }


store_applyConstraint( _InsDel,
                       _IcFormula, _IcId,
                       _Literal, _ClassId, _SimpIcId,
                       _StoredForm) :-


		{ 1. Abspeichern der propvals:                                }

		{ 1a. Erstellen eines Objekts, das die vereinfachte Instanz   }
		{ der Integritaetsbedingung darstellt:                        }
	pc_atom_to_term( _IcFormula_flat, _StoredForm),
	disambiguateCodeLabel(_IcFormula_flat,_IcFormula_flat_dollar),
{	assign_Component( _SimpIcId),}
	STORE(P(_SimpIcId,_SimpIcId,_IcFormula_flat_dollar,_SimpIcId)),
	name2id(BDMConstraintCheck,_BDMconChId),
	STORE(P(_IoId1,_SimpIcId,'*instanceof',_BDMconChId)),

		{ 1b. Erstellen eines Verweises von der Integritaetsbedingung }
		{ zu ihrer vereinfachten Instanz:                             }
	assign_Component( _Label2),
	STORE(P(_ConId2,_IcId,_Label2,_SimpIcId)),
	retrieve_proposition(
             P(_AttrCatId2,id_52, specialConstraint, _BDMconChId)),    {* id_52=MSFOLconstraint *}
	STORE(P(_IoId2,_ConId2,'*instanceof',_AttrCatId2)),

		{ 1c. Erstellen eines Verweises von der betroffenen Klasse zu }
		{ der vereinfachten Instanz :                                 }
	assign_Component( _Label3),
	STORE(P(_ConId3,_ClassId,_Label3,_SimpIcId)),


	((_InsDel = Insert,
	  retrieve_proposition( P( _AttrCatId3,
            id_0, applyConstraintIfInsert,_BDMconChId))       {* id_0=Proposition *}
	 );
	 retrieve_proposition( P( _AttrCatId3,
              id_0, applyConstraintIfDelete, _BDMconChId))    {* id_0=Proposition *}
	),
	STORE(P(_IoId3,_ConId3,'*instanceof',_AttrCatId3)),



		{ 2. Abspeichern des BDMPraedikats: }

	((_InsDel = Insert,
	  store_BDMFormula( 'applyConstraintIfInsert@BDMCompile'( _IcId, _ClassId, _SimpIcId, _Literal, _IcFormula))		{ 26-May-1995 LWEB }
	 );
	 store_BDMFormula( 'applyConstraintIfDelete@BDMCompile'( _IcId, _ClassId, _SimpIcId, _Literal, _IcFormula))
	),
	!.









{ *************************************************************************** }
{                                                                             }
{ store_applyRule( _InsDel,                                                   }
{                  _RuleCondMerged, _RuleConcl, _RuleId,                      }
{                  _Literal, _ClassId, _InsDelOfConcl,                        }
{                  _ListOfSimpIcIds, _ListOfSimpRuleIds, _SimpRuleId)         }
{                                                                             }
{ erzeugt die propvals und das BDMPraedikat fuer eine spezialisierte Regel.   }
{ _InsDel    : = Insert, falls Regel bei  Einfuegeoperation auszufuehren ist, }
{              = Delete, "     "     "    Loesch-"          "           " (i).}
{ _RuleCondMerged : der spezialisierte Regelbedingungsteil, im gemischten     }
{                   BDMFormat (i),                                            }
{ _RuleConcl : das Folgerungsliteral (i),                                     }
{ _RuleId    : der Identifikator des Objekts, das die urspruengliche Regel    }
{              taetsbedingung (Instanz von MSFOLrule) darstellt (i),          }
{ _Literal   : bzgl. dem die Regel zu vereinfacht wurde (i),                  }
{ _ClassId   : Id der Klasse, deren Instanzen das Literal matchen koennen (i),}
{ _InsDelOfConcl    : zeigt die Operation an, die aus _InsDel fuer das Fol-   }
{                     gerungsliteral resultiert (i)                           }
{ _ListOfSimpIcIds : Liste der Identifikatoren von vereinfachten Formen von   }
{                    Integritaetsbedingungen, in die Instanzen der Klasse     }
{                    eingehen koennen, die durch das Folgerungsliteral der    }
{                    aktuellen Regel hergeleitet werden koennen (i),          }
{ _ListOfSimpRuleIds : dasselbe mit vereinfachten Regeln (i).                 }
{ _SimpRuleId        : Id des Objekts, das die vereinf. Regel darstellt (o).  }
{                                                                             }
{ *************************************************************************** }


store_applyRule( _InsDel,
                 _RuleCondMerged, _RuleConcl, _RuleId,
	         _Literal, _ClassId, _InsDelOfConcl,
	         _ListOfSimpIcIds, _ListOfSimpRuleIds, _SimpRuleId) :-


		{ 1. Abspeichern der propvals:                                }

		{ 1a. Erstellen eines Objekts, das die vereinfachte Form      }
		{ der Regel darstellt:                                        }
	pc_atom_to_term( _Rule_flat,
                Rule( Condition( _RuleCondMerged), Conclusion( _RuleConcl))),
	disambiguateCodeLabel(_Rule_flat,_Rule_flat_dollar),
{	assign_Component( _SimpRuleId),}
	STORE(P(_SimpRuleId,_SimpRuleId,_Rule_flat_dollar,_SimpRuleId)),
	name2id(BDMRuleCheck,_BDMruleChId),
	STORE(P(_IoId1,_SimpRuleId,'*instanceof',_BDMruleChId)),

		{ 1b. Erstellen eines Verweises von der Regel zu ihrer        }
		{ vereinfachten Form:                                         }
	assign_Component( _Label2),
	STORE(P(_ConId2,_RuleId,_Label2,_SimpRuleId)),
	retrieve_proposition(
           P(_AttrCatId2, id_46, specialRule, _BDMruleChId)),   {* id_46=MSFOLrule *}
	STORE(P(_IoId2,_ConId2,'*instanceof',_AttrCatId2)),


		{ 2. Abspeichern des BDMPraedikats: }

	((_InsDel = Insert,
	  store_BDMFormula( 'applyRuleIfInsert@BDMCompile'(_RuleId, _ClassId, _SimpRuleId, _Literal, _RuleConcl, _RuleCondMerged,
              goAhead(_InsDelOfConcl,_ListOfSimpIcIds,_ListOfSimpRuleIds)))
	 );
	 store_BDMFormula( 'applyRuleIfDelete@BDMCompile'(_RuleId, _ClassId, _SimpRuleId, _Literal, _RuleConcl, _RuleCondMerged,
              goAhead(_InsDelOfConcl,_ListOfSimpIcIds,_ListOfSimpRuleIds)))

	),
	!.






{ *************************************************************************** }
{                                                                             }
{ store_more_applyConsRule( _InsDel, _SimpRuleId,                             }
{                           _ListOfSimpIcIds, _ListOfSimpRuleIds)             }
{                                                                             }
{ erzeugt die propvals und das geaenderte BDMPraedikat fuer eine speziali-    }
{ sierte Regel, die nun in weiteren Integritaetstest (in-)direkt eingeht.     }
{                                                                             }
{ _InsDel    : = Insert, falls Regel bei  Einfuegeoperation auszufuehren ist, }
{              = Delete, "     "     "    Loesch-"          "           " (i),}
{ _SimpRuleId : Id des Objekts, das die vereinf. Regel darstellt (i),         }
{ _ListOfSimpIcIds : Liste der Identifikatoren von weiteren vereinf. Formen v.}
{                    Integritaetsbedingungen, in die Instanzen der Klasse     }
{                    eingehen koennen, die durch das Folgerungsliteral der    }
{                    aktuellen Regel hergeleitet werden koennen (i),          }
{ _ListOfSimpRuleIds : dasselbe mit vereinfachten Regeln (i).                 }
{                                                                             }
{ *************************************************************************** }


store_more_applyConsRule( _InsDel, _SimpRuleId, _ListOfSimpIcIds,
	                  _ListOfSimpRuleIds) :-


		{ 1. Abspeichern der propvals:                                }


		{ 2. Abspeichern des BDMPraedikats:                           }

        (_triggername = 'applyRuleIfInsert@BDMCompile';
         _triggername = 'applyRuleIfDelete@BDMCompile'),

	_trigger =.. [_triggername,_RuleId,_ClassId,_SimpRuleId,_Literal,_RuleConcl,
                      _RuleCondMerged,goAhead(_InsDel,_IClist,_Rulelist)],

	retrieve_BDMFormula_once(_trigger),

        append(_IClist,_ListOfSimpIcIds,_newIClist),
        append(_Rulelist,_ListOfSimpRuleIds,_newRulelist),

	_newtrigger =.. [_triggername,_RuleId, _ClassId,_SimpRuleId,_Literal,_RuleConcl,
                      _RuleCondMerged, goAhead(_InsDel,_newIClist,_newRulelist)],

         WriteTrace(veryhigh,BDMCompile, ['Simplified rule ',idterm(_SimpRuleId),
                   ' gets new go-ahead triggers to simplified constraints "',
                   idterm(_ListOfSimpIcIds), '" and rules "',idterm(_ListOfSimpRuleIds),'"']),

       change_BDMFormula(_trigger,_newtrigger),

	!.



{AM : Storing the simplified rangeform instead}

constructStoredForm(_simplifiedrangeform,_ranges,_InsDel,_lit,_InstLiteral,_StoredForm) :-

  create_replaceList(_lit,_InstLiteral,_rpl),
  listreplace(_simplifiedrangeform,_rpl,_sfr_new),
  ((_InsDel == Insert,
    _StoredForm = Insert(_InstLiteral,_sfr_new,_ranges));
   (_InsDel == Delete,
    _StoredForm = Delete(_InstLiteral,_sfr_new,_ranges))
  ).



{* for the next two clauses cf. ErrorsCorrected[11] *}
create_replaceList(_lit,Adot(_cc,_s,_d),_rpl) :-
	!,
	id2name(_cc,_l),
	create_replaceList(_lit,A(_s,_l,_d),_rpl).

create_replaceList(_lit,Aidot(_,_s,_d),_rpl) :-
	!,
	create_replaceList(_lit,Ai(_s,_l,_d),_rpl).

{* sonst mache weiter wie bisher *}
create_replaceList(_lit,_InstLiteral,_rpl) :-
  _lit =.. [_|_args1],
  _InstLiteral =.. [_|_args2],
  scan_for_vars(_args2,_args1,_rpl).


scan_for_vars(_,[],[]) :- !.
scan_for_vars([],_,[]) :- !.

scan_for_vars([_top_arg2|_rest_args2],[_top_arg1|_rest_args1],[by(_top_arg1,_top_arg2)|_rpl_rest]) :-
  var(_top_arg2),!,
  scan_for_vars(_rest_args2,_rest_args1,_rpl_rest).



scan_for_vars([_top_arg2|_rest_args2],[_top_arg1|_rest_args1],_rpl_rest) :-
  ground(_top_arg2),!,
  scan_for_vars(_rest_args2,_rest_args1,_rpl_rest).






listreplace(_simplifiedrangeform,[_top_rpl|_rest_rpl],_sfr_new) :-
  !,
  replace(_simplifiedrangeform,_top_rpl,_sfr_new1),
  listreplace(_sfr_new1,_rest_rpl,_sfr_new).

listreplace(_simplifiedrangeform,[],_simplifiedrangeform) :- !.


replace(_simplifiedrangeform,by(_a,_b),_sfr_new) :-

  (atom(_simplifiedrangeform);
   var(_simplifiedrangeform)),
  ((_simplifiedrangeform == _a,
    _sfr_new = _b);
   (_sfr_new = _simplifiedrangeform)),
  !.

replace(_simplifiedrangeform,by(_a,_b),_sfr_new) :-
  _simplifiedrangeform =.. [_f|_args],
  replaceTermList(_args,by(_a,_b),_args_new),
  _sfr_new =.. [_f|_args_new] .


replaceTermList([],by(_a,_b),[]) :- !.

replaceTermList([_top_arg|_args],by(_a,_b),[_top_arg_new|_args_new]) :-
  !,
  replace(_top_arg,by(_a,_b),_top_arg_new),
  replaceTermList(_args,by(_a,_b),_args_new).


{* Ticket #161: create a save object name for _rawtext: if such an object already *}
{* exists, then we append a comment text with the identifier _idX to make it      *}
{* unique. This ensures that triggers like applyRuleIfInsert will get a unique    *}
{* identifier being the object identifier of the Telos proposition generated for  *}
{* _savetext_dollar.                                                              *}
disambiguateCodeLabel(_rawtext,_savetext_dollar) :-
  atom(_rawtext),
  pc_atomconcat(['$',_rawtext,'$'], _rawtext_dollar),
  do_disambiguateCodeLabel(_rawtext_dollar,_savetext_dollar).

do_disambiguateCodeLabel(_rawtext_dollar,_savetext_dollar) :-
  retrieve_proposition(P(_id,_id,_rawtext_dollar,_id)),  {* object with rawtext_dollar already exists *}
  !,
  newIdentifier(_idX),    {* see ticket #161 }
  pc_atomconcat([_rawtext_dollar,' /* disambiguated ',_idX,' */'],_savetext_dollar).

{* else: the original code label can be used *}
do_disambiguateCodeLabel(_text_dollar,_text_dollar).
  

