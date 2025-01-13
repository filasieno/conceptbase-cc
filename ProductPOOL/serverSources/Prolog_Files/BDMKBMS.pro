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
*
* Date released : %E%  (YY/MM/DD)
*
* SCCS-Source-Pool : %P%
* Date retrieved : %D% (YY/MM/DD)
* -----------------------------------------------------------------------------
*
* This module is part of the BDMIntegrityChecker and
* is responsible for the management of those prolog-predicates
* that contain evaluable formulas (wellknown as BDMFormulaPredicates).
*
*
*
* Exported predicates:
* --------------------
*
*   + store_BDMFormula/1
*
*   + retrieve_BDMFormula/1
*
*   + retrieve_BDMFormula_once/1
*
*   + mk_permanent_BDMFormula/2
*
*   + rm_temp_BDMFormula/0
*
*   + change_BDMFormula/2
*
*   + delete_BDMFormula/1
*
* Metaformel-Aenderungen(10.1.96):
*
* geaendert: change_BDMFormula
* Ein Trigger kann innerhalb einer Transaktion erzeugt und danach
* geaendert werden.
*
* mk_permanent_BDMFormula:
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
* is_trigger
* neue Trigger mit aufgenommen
*
*
* 05-Dez-1996 LWEB
*  Die Trigger 'applyConstraintIfInsert@BDMCompile'   und  'applyConstraintIfDelete@BDMCompile'
*  'origConstraint@BDMCompile'
*  wurden um eine Stelle erweitert. Diese Stelle enthaelt die _id des Telos-Constraint Objekts. Sie dient
*  zur Ueberpruefung, ob die zum Trigger gehoerige Constraint im aktuellen Modulkontext sichtbar ist.
}


#MODULE(BDMKBMS).
#EXPORT(change_BDMFormula/2)
#EXPORT(delete_BDMFormula_once/1)
#EXPORT(delete_BDMFormulas/1)
#EXPORT(delete_all_BDMFormulas/1)
#EXPORT(load_BDMFormula/1)
#EXPORT(mk_permanent_BDMFormula/3)
#EXPORT(retrieve_BDMFormula/1)
#EXPORT(retrieve_BDMFormula_once/1)
#EXPORT(retrieve_backup_BDMFormula/1)
#EXPORT(rm_temp_BDMFormula/0)
#EXPORT(store_BDMFormula/1)
#ENDMODDECL()

#IMPORT(member/2,GeneralUtilities)
#IMPORT(append/3,GeneralUtilities)
#IMPORT(WriteTrace/3,GeneralUtilities)

{* declare the trigger-predicates as dynamic encapsulated in this module
*}

#DYNAMIC(perm_trigger/1)
#DYNAMIC(temp_trigger/1)
#DYNAMIC(backup_trigger/1)

#IF(SWI)
:- style_check(-singleton).
#ENDIF(SWI)



{***************************************************************************}
{                                                                           }
{**************      S   U   B   M   O   D   U   L   E      ****************}
{                                                                           }
{                                                                           }
{   BBBB   DDDD   M   M   FFFFF   OOO   RRRR   M   M  U   U   L        A      }
{   B   B  D   D  MM MM   F      O   O  R   R  MM MM  U   U   L       A A     }
{   BBBB   D   D  M M M   FFFF   O   O  RRRR   M M M  U   U   L      AAAAA    }
{   B   B  D   D  M   M   F      O   O  R  R   M   M  U   U   L      A   A    }
{   BBBB   DDDD   M   M   F       OOO   R   R  M   M   UUU    LLLLL  A   A    }
{                                                                             }
{                                                                             }
{ Es gibt verschiedene Praedikate zur Abspeicherung von BDM-Formeln.          }
{ Die zeitkritischen Praedikate:                                              }
{   'applyConstraintIfInsert@BDMCompile'                                      }
{     ( _icId, _ClassId, _SimpIcId, _Literal, _IcFormSimplMerged),            }
{   'applyConstraintIfDelete@BDMCompile'                                      }
{     ( _icId, _ClassId, _SimpIcId, _Literal, _IcFormSimplMerged),            }
{   'applyRuleIfInsert@BDMCompile'                                            }
{     ( _RuleId, _ClassId, _SimpRuleId, _Literal, _RuleConcl,_RuleCondMerged, }
{       _ListOfSimpRuleIds, _ListOfSimpIcIds),                                }
{   'applyRuleIfDelete@BDMCompile'                                            }
{     (_RuleId,  _ClassId, _SimpRuleId, _Literal, _RuleConcl,_RuleCondMerged, }
{       _ListOfSimpRuleIds, _ListOfSimpIcIds).                                }
{ Und die restlichen Praedikate:                                              }
{   'origConstraint@BDMCompile'( _idIc, _OrigIcId, _IcFormulaMerged),         }
{   'origRule@BDMCompile'( _RuleId, _RuleConcl,                               }
{                          _RuleCondFormMerged, _ruleinfo).                   }
{                                                                             }
{                                                                             }
{ Mit folgenden Praedikaten kann man darauf zugreifen:                        }
{      store_BDMFormula( _BDMFormulaPredicate)                                }
{      retrieve_BDMFormula( _BDMFormulaPredicate)                             }
{      retrieve_BDMFormula_once( _BDMFormulaPredicate)                        }
{      change_BDMFormula( _BDMFormulaPredicate_old, _BDMFormulaPredicate_new) }
{      mk_permanent_BDMFormula( _ListOfBDMFormulaPredicates, _mode)           }
{      rm_temp_BDMFormula                                                     }
{      delete_BDMFormula( _BDMFormulaPredicate)                               }
{                                                                             }
{ Intern werden die Hilfspraedikate                                           }
{	'temp_trigger'                                                        }
{	'backup_trigger'                                                      }
{       'perm_trigger'                                                        }
{ verwendet, auf die von aussen kein Zugriff ist.                             }
{                                                                             }
{                                                                             }
{***************************************************************************}






{***************************************************************************}
{                                                                             }
{ store_BDMFormula( _BDMFormulaPredicate)                                     }
{                                                                             }
{ Wird eine neues Praedikat abgespeichert, das eine BDM-Formel enthaelt, so   }
{ darf dies zuerst nur temporaer geschehen. Es muss sich wieder loeschen      }
{ lassen, falls die Transaktion, auf Grund derer die neue BDM-Formel angelegt }
{ wurde, nicht angenommen wird.                                               }
{                                                                             }
{***************************************************************************}


store_BDMFormula(_BDMFormulaPredicate) :-
	assert(temp_trigger( _BDMFormulaPredicate)),
	WriteTrace(veryhigh,BDMKBMS,[store_BDMFormula,' :: ',idterm(_BDMFormulaPredicate)]),
	!.

{***********************************************************}
{* load_BDMFormula( _BDMFormulaPredicate)                  *}
{*                                                         *}
{* Die Trigger werden im Moment in OB.rule gespeichert.    *}
{* load_BDMFormula/1 merkt sich den Trigger in der PROLOG  *}
{* Datenbank.                                              *}
{***********************************************************}

load_BDMFormula(_BDMFormulaPredicate) :-
	is_trigger(_BDMFormulaPredicate),
	assert(perm_trigger( _BDMFormulaPredicate)),
	!.
load_BDMFormula(_BDMFormulaPredicate) :-
	is_legacy_trigger(_BDMFormulaPredicate,_BDMFormulaPredicateNew),  {* ticket #303 *}
	assert(perm_trigger( _BDMFormulaPredicateNew)),
	WriteTrace(low,BDMKBMS,['Legacy trigger trigger detected, ',
                                'consider recompiling the database from its sources. ']),
	!.


{***************************************************************************}
{                                                                             }
{ retrieve_BDMFormula( _BDMFormulaPredicate)                                  }
{                                                                             }
{ Dieses ist die Zugriffsschnittstelle zu den intern abgespeicherten Praedi-  }
{ katen, die die BDM-Formeln enthalten. Entweder ist ein solches Praedikat    }
{ noch temporaer abgespeichert, oder schon permanent.                         }
{                                                                             }
{***************************************************************************}


retrieve_BDMFormula(_BDMFormulaPredicate) :-

	perm_trigger(_BDMFormulaPredicate)
	;
	temp_trigger( _BDMFormulaPredicate).


{***********************************************************}
{                                                           }
{ retrieve_backup_BDMFormula( _BDMFormulaPredicate)         }
{                                                           }
{ greift auf die backup-Kopie eines Triggers zu. Das wird in}
{ BDMEvaluation benoetigt.                                  }
{                                                           }
{***********************************************************}

retrieve_backup_BDMFormula(_BDMFormulaPredicate) :-

	backup_trigger(_BDMFormulaPredicate).


{***************************************************************************}
{                                                                             }
{ retrieve_BDMFormula_once( _BDMFormulaPredicate)                             }
{                                                                             }
{ Dieses ist die Zugriffsschnittstelle zu den intern abgespeicherten Praedi-  }
{ katen, die die BDM-Formeln enthalten. Entweder ist ein solches Praedikat    }
{ noch temporaer abgespeichert, oder schon permanent.                         }
{ Hier wird nur nach der ersten Loesung gesucht, sinnvoll bei instanziiertem  }
{ Formelidentifikator, so dass es nur eine Loesung geben kann.                }
{                                                                             }
{***************************************************************************}


retrieve_BDMFormula_once(_BDMFormulaPredicate) :-

	retrieve_BDMFormula(_BDMFormulaPredicate),
	!.






{***************************************************************************}
{                                                                             }
{ change_BDMFormula( _BDMFormulaPredicate_old, _BDMFormulaPredicate_new)      }
{                                                                             }
{ Wird ein BDM-Praedikat geaendert, so darf dies erst nur temporaer geschehen.}
{                                                                             }
{***************************************************************************}


change_BDMFormula(_old,_new) :-
	assert( temp_trigger(_new)),
	do_change_BDMFormula(_old,_new),
	WriteTrace(veryhigh,BDMKBMS,[change_BDMFormula,' :: ',idterm(_old),' -> ', idterm(_new)]),
	!.



do_change_BDMFormula( _BDMFormulaPredicate_old, _BDMFormulaPredicate_new) :-

	{ War der Trigger vor der Transaktion schon in ConceptBase: }
	perm_trigger( _BDMFormulaPredicate_old),
	!,
	{ Ja, deshalb muss es geloescht u. gemerkt werden:            }
{	write(assert(backup_trigger(_BDMFormulaPredicate_old))),nl,}
	assert(backup_trigger(_BDMFormulaPredicate_old)),
{	write(retract(perm_trigger(_BDMFormulaPredicate_old))),nl,nl,}
	retract(perm_trigger(_BDMFormulaPredicate_old))
{	,write(retract(perm_trigger(_BDMFormulaPredicate_old))),nl,nl}.


do_change_BDMFormula( _BDMFormulaPredicate_old, _BDMFormulaPredicate_new) :-

	{* ist das Praedikat temporaer erzeugt worden, dann darf kein Backup-Trigger
	   angelegt werden, denn nur Trigger, die vor der Transaktion in ConceptBase
	   waren, duerfen wiederhergestellt werden *}
	retract(temp_trigger( _BDMFormulaPredicate_old)),
{	write(retract(temp_trigger( _BDMFormulaPredicate_old))),nl,nl,}
	!.

{***************************************************************************}
{                                                                             }
{ mk_permanent_BDMFormula( _ListOfBDMPredicates1,_ListOfBDMPredicates2,_mode) }
{                                                                             }
{ Wird eine Transaktion angenommen, so muessen alle durch sie temporaer       }
{ angelegten Objekte nun permanent gemacht werden und alle temporaer          }
{ geloeschten Objekte permanent geloescht werden.                             }
{                                                                             }
{                                                                             }
{***************************************************************************}


mk_permanent_BDMFormula( _ListOfBDMPredicatesInserted, _ListOfBDMPredicatesDeleted,tell) :-
	findall( _BDMPredicateIns, temp_trigger( _BDMPredicateIns), _ListOfBDMPredicatesInserted),
{	write('inserted: '),write(_ListOfBDMPredicatesInserted),nl,nl,}
	mk_permanent_BDMFormula_i(_ListOfBDMPredicatesInserted),
	findall( _BDMPredicateDel, backup_trigger( _BDMPredicateDel), _ListOfBDMPredicatesDeleted)	,
{	write('deleted: '),write(_ListOfBDMPredicatesDeleted),nl,nl,}
	mk_permanent_BDMFormula_d(_ListOfBDMPredicatesDeleted).


mk_permanent_BDMFormula( _ListOfBDMPredicatesDeleted, _ListOfBDMPredicatesInserted,untell) :-
	mk_permanent_BDMFormula( _ListOfBDMPredicatesInserted, _ListOfBDMPredicatesDeleted,tell).




mk_permanent_BDMFormula_i([]).
mk_permanent_BDMFormula_i([_trigger|_triggers]):-
	retract(temp_trigger( _trigger)),
{	write(assert(perm_trigger(_trigger))),nl,nl,}
	assert(perm_trigger(_trigger)),
	mk_permanent_BDMFormula_i(_triggers).


mk_permanent_BDMFormula_d([]).
mk_permanent_BDMFormula_d([_trigger|_triggers]):-
	retract(backup_trigger(_trigger)),
	mk_permanent_BDMFormula_d(_triggers).






{***************************************************************************}
{                                                                             }
{ rm_temp_BDMFormula                                                          }
{                                                                             }
{ Wird eine Transaktion abgelehnt, so muessen alle durch sie temporaer        }
{ angelegten Objekte nun geloescht werden. Hier geschieht dies mit            }
{ den Praedikaten, die die BDM-Formeln enthalten.                             }
{                                                                             }
{***************************************************************************}

{* Rollback einer Transaktion:             *}
{* Loesche zuerst alle temporaeren Trigger *}
rm_temp_BDMFormula :-

	temp_trigger( _BDMFormulaPredicate),
	retract( temp_trigger( _BDMFormulaPredicate)),
	fail.


{* Mache alle alten Trigger wieder gueltig  *}
rm_temp_BDMFormula :-

	backup_trigger( _BDMFormulaPredicate),
	retract(backup_trigger( _BDMFormulaPredicate)),
	assert(perm_trigger(_BDMFormulaPredicate)),
	fail.


{* ... und Ende *}
rm_temp_BDMFormula :-

	!.

{***************************************************************************}
{                                                                             }
{ delete_BDMFormula( _BDMFormulaPredicate)                                    }
{                                                                             }
{ Beim UNTELL einer Integritaetsbedingung oder Regel werden einige dazuge-    }
{ hoerige BDMFormelPraedikate geloescht.                                      }
{                                                                             }
{***************************************************************************}

delete_BDMFormulas([]).
delete_BDMFormulas([_t|_ts]) :-
	delete_BDMFormula(_t),
	delete_BDMFormulas(_ts).

delete_BDMFormula_once(_BDMFormulaPredicate) :-
	delete_BDMFormula(_BDMFormulaPredicate),
	!.

delete_BDMFormula( _BDMFormulaPredicate) :-
		{ Zur vollstaendigen Instanziierung: }
	perm_trigger(_BDMFormulaPredicate),!,
		{ Loeschen des Praedikats }
	retract( perm_trigger(_BDMFormulaPredicate)),

		{ ... und Zwischenspeichern bis zum Ende des UNTELLs:         }
	assert( backup_trigger( _BDMFormulaPredicate)),
        WriteTrace(veryhigh,BDMKBMS,[delete_BDMFormula,' :: ',
                                     idterm(_BDMFormulaPredicate)]).

delete_BDMFormula( _BDMFormulaPredicate) :-
		{ Zur vollstaendigen Instanziierung: }
	is_ProcedureTrigger(_BDMFormulaPredicate),
	temp_trigger(_BDMFormulaPredicate),
	{* ist das Praedikat temporaer erzeugt worden, dann darf kein Backup-Trigger
	   angelegt werden, denn nur Prozedur Trigger, die vor der Transaktion in ConceptBase
	   waren, duerfen wiederhergestellt werden *}
	retract( temp_trigger(_BDMFormulaPredicate)),
        WriteTrace(veryhigh,BDMKBMS,[delete_BDMFormula,' :: ',
                                     idterm(_BDMFormulaPredicate)]).





delete_all_BDMFormulas(_BDMFormulaPredicate) :-

	(delete_BDMFormula(_BDMFormulaPredicate),fail)
	;
	true.


is_trigger(_BDMFormula) :-				{ 26-May-1995 LWEB }
	functor(_BDMFormula,_x,_arity),
	member((_x,_arity),[
					('applyConstraintIfInsert@BDMCompile',5),
					('applyConstraintIfDelete@BDMCompile',5),
					('applyRuleIfInsert@BDMCompile',7),
					('applyRuleIfDelete@BDMCompile',7),
					('origConstraint@BDMCompile',3),
					('origRule@BDMCompile',4),
					('applyPredicateIfInsert@BDMCompile',4),
	   				('applyPredicateIfDelete@BDMCompile',3)]).


{* deal with old OB.rule files that have old trigger formats *}
{* ticket #303                                               *}
is_legacy_trigger('applyRuleIfInsert@BDMCompile'(_1,_2,_3,_4,_5,_6),
                  'applyRuleIfInsert@BDMCompile'(_,_1,_2,_3,_4,_5,_6)).	
is_legacy_trigger('applyRuleIfDelete@BDMCompile'(_1,_2,_3,_4,_5,_6),
                  'applyRuleIfDelete@BDMCompile'(_,_1,_2,_3,_4,_5,_6)).				
	

is_ProcedureTrigger(_BDMFormula) :-
	functor(_BDMFormula,_x,_arity),
	member((_x,_arity),[
           	('applyPredicateIfInsert@BDMCompile',4),
	   	('applyPredicateIfDelete@BDMCompile',3)]).
