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
* This file contains predicates for storing and retrieving
* PROLOGclauses from the PROLOG database
*
*
* 07-Jul-93/kvt: habe sortClauseList/2 geloescht, was nach
*    Martin nicht mehr benoetigt wurde.
*
* 1-Sep-93/Tl: retrieve_proposition calls with constant objects at Src or Dst entry
* are changed into a name2id(...,_id),retr_prop(..,_id,..) combination. The old
* construction didn't work with an extern retrieve_proposition
*
* Metaformel Aenderung (10.1.96) RS
* Auch temporaer erzeugte Regeln muessen schon feuern koennen.
* Deswegen wird store_PROLOGrules schon bei store_tmp_PROLOGrules
* aufgerufen und nicht erst bei store_perm_PROLOGrules
*
* 9-Dez-96/LWEB : delete_Builtinrules/1 entfaellt, da es nirgendwo benutzt wird.
* In delete_all_BDMFormulas/1 wurde beruecksichtigt, dass 'origConstraint@BDMCompile'
* und die beiden zugehoerigen Trigger jetzt eine Stelle mehr haben.
*
* Jul-97 tmp_rules_ins und tmp_rules_del werden zusaetzlich eingesetzt.
* Die sind fuer retell_Operation zustandig, denn die Menge von getellten rules und
* von geuntellten rules sollen seperate gespeichert werden. Dazu wird noch ein Flag
* aus TellAndAsk gesetzt.
*

* Exported predicates:
*---------------------
*
*   + store_tmp_PROLOGrules/1
*   + get_tmp_PROLOGrules/1
*   + store_perm_PROLOGrules/1
*   + store_perm_PROLOGrules/2
*   + get_PROLOGrule/1
*   + remove_tmp_PROLOGrules/0
*   + remove_tmp_PROLOGrules/1
*   + remove_PROLOGrules/1
*   + delete_PROLOGrules/0
*   + store_PROLOGrules/1
*   + store_PROLOGrulesAndTriggers/1
*   + store_toFile_PROLOGrules/2
*   + delete_fromFile_PROLOGrules/2
*   + remove_closed_RuleTTime/0
*
}


#MODULE(PROLOGruleProcessor)
#EXPORT(delete_fromFile_PROLOGrules/2)
#EXPORT(get_PROLOGrule/2)
#EXPORT(get_tmp_PROLOGrules/1)
#EXPORT(remove_PROLOGrules/1)
#EXPORT(remove_closed_RuleTTime/0)
#EXPORT(remove_tmp_PROLOGrules/0)
#EXPORT(store_PROLOGrules/1)
#EXPORT(store_PROLOGrulesAndTriggers/1)
#EXPORT(store_perm_PROLOGrules/1)
#EXPORT(store_perm_PROLOGrules/2)
#EXPORT(store_tmp_PROLOGrules/1)
#EXPORT(store_toFile_PROLOGrules/2)
#EXPORT(tmp_rules/1)
#EXPORT(tmp_rules_ins/1)
#EXPORT(tmp_rules_del/1)
#EXPORT(tellDelayedFrames/0)
#ENDMODDECL()


#IMPORT(member/2,GeneralUtilities)
#IMPORT(append/3,GeneralUtilities)
#IMPORT(WriteTrace/3,GeneralUtilities)
#IMPORT(prove_literal/1,Literals)
#IMPORT(delete_all_BDMFormulas/1,BDMKBMS)
#IMPORT(load_BDMFormula/1,BDMKBMS)
#IMPORT(retrieve_proposition/1,PropositionProcessor)
#IMPORT(get_KBsearchSpace/2,SearchSpace)
#IMPORT(set_KBsearchSpace/2,SearchSpace)
#IMPORT(name2id/2,GeneralUtilities)
#IMPORT(makeflat/2,GeneralUtilities)
#IMPORT(load_vmrule/1,VMruleGenerator)
#IMPORT(retellflag/1,TellAndAsk)
#IMPORT(pc_has_a_definition/1,PrologCompatibility)
#IMPORT(pc_fopen/3,PrologCompatibility)
#IMPORT(pc_fclose/1,PrologCompatibility)
#IMPORT(pc_swriteQuotesAndModule/2,PrologCompatibility)
#IMPORT(checkToAddIsDeducable/1,Literals)
#IMPORT(tellFrames/1,cbserver)
#IMPORT(getFlag/2,GeneralUtilities)
#IMPORT(get_cb_feature/2,GlobalParameters)
#IMPORT(set_cb_feature/2,GlobalParameters)



#DYNAMIC(tmp_rules/1).
#DYNAMIC(tmp_rules_ins/1).
#DYNAMIC(tmp_rules_del/1).

#IF(SWI)
:- style_check(-singleton).
#ENDIF(SWI)



{************** s t o r e _ t m p _ P R O L O G r u l e s *********************}
{                                                                              }
{ store_tmp_PROLOGrules (_clauselist)                                          }
{            _clauselist : ground : list                                       }
{                                                                              }
{ store_tmp_PROLOGrules stores list of PROLOGclauses in PROLOG database        }
{ as tmp_rule(_clauselist) for later permanent assertion or possibly           }
{ deletion. So it is a 'temporary' form of direct assertion.                   }
{                                                                              }
{******************************************************************************}

{* Metaformel Aenderung
   Auch temporaer erzeugte Regeln muessen schon feuern koennen.
   Deswegen wird hier schon
   store_PROLOGrules aufgerufen und nicht erst bei
   store_perm_PROLOGrules
*}

#IF(SWI)
:- module_transparent store_tmp_PROLOGrules/1 .
#ENDIF(SWI)

store_tmp_PROLOGrules([]) :-!.

store_tmp_PROLOGrules(_clauseList) :-
   WriteTrace(veryhigh,PROLOGruleProcessor, ['store_tmp_PROLOGrules ----> ',
                                              _clauseList]),
(
  (retellflag(untell), assert(tmp_rules_del(_clauseList)));
  (retellflag(tell), assert(tmp_rules_ins(_clauseList)));
  ( assert(tmp_rules(_clauseList)))
),
   !,
   store_PROLOGrules(_clauseList).



{ ************* g e t _ all t m p _ P R O L O G r u l e s *************************}
{                                                                              }
{ get_all_tmp_PROLOGrules (_clauselist)                                            }
{            _clauselist : any  : list                                         }
{                                                                              }
{ get_all_tmp_PROLOGrules retrieves all temporary PROLOGclauses in PROLOG database       }
{ stored as tmp_rule(_clauselist).                                             }
{                                                                              }
{ **************************************************************************** }

#IF(SWI)
:- module_transparent get_all_tmp_PROLOGrules/1 .
#ENDIF(SWI)

get_all_tmp_PROLOGrules(_clauselist) :-
	findall(_clauses,get_tmp_PROLOGrules(_clauses),_clauselist1),
	makeflat(_clauselist1,_clauselist).


{ ************* g e t _ t m p _ P R O L O G r u l e s *************************}
{                                                                              }
{ get_tmp_PROLOGrules (_clauselist)                                            }
{            _clauselist : any  : list                                         }
{                                                                              }
{ get_tmp_PROLOGrules retrieves list of PROLOGclauses in PROLOG database       }
{ stored as tmp_rule(_clauselist).                                             }
{                                                                              }
{ **************************************************************************** }

#IF(SWI)
:- module_transparent get_tmp_PROLOGrules/1 .
#ENDIF(SWI)

get_tmp_PROLOGrules(_clauselist) :-			{ich glaube mit untell nicht zu tun}
	(
         tmp_rules(_clauselist);
	 tmp_rules_ins(_clauselist)
	).

{************** s t o r e _ p e r m _ P R O L O G r u l e s *******************}
{                                                                              }
{ store_perm_PROLOGrules(_list)                                                }
{          _list : free :list                                                  }
{                                                                              }
{ store_perm_PROLOGrules collects all PROLOGrule lists stored in above         }
{ produced tmp-form in one list _list and asserts each clause directly.        }
{                                                                              }
{******************************************************************************}


#IF(SWI)
:- module_transparent store_perm_PROLOGrules/1 .
:- module_transparent store_perm_PROLOGrules/2 .
#ENDIF(SWI)

{* store_perm_PROLOGrules/1 *}
store_perm_PROLOGrules(_list) :-
           retract(tmp_rules(_clauseList)),
           store_perm_PROLOGrules(_rest),
           append(_clauseList,_rest,_list).

store_perm_PROLOGrules([]) :- !.


{* store_perm_PROLOGrules/2 *}
store_perm_PROLOGrules(_list,retell_untell) :-
           retract(tmp_rules_del(_clauseList)),
           store_perm_PROLOGrules(_rest,retell_untell),
           append(_clauseList,_rest,_list).

store_perm_PROLOGrules(_list,retell_tell) :-
           retract(tmp_rules_ins(_clauseList)),
           store_perm_PROLOGrules(_rest,retell_tell),
           append(_clauseList,_rest,_list).

store_perm_PROLOGrules([],_) :- !.


{ ********************** g e t _ P R O L O G r u l e ************************* }
{                                                                              }
{ get_PROLOGrule(_head,_body)                                                  }
{       _head : partial (at least functor)                                     }
{       _body : any                                                            }
{                                                                              }
{ provides access to all PROLOGrules which were stored by store_PROLOGrules    }
{                                                                              }
{ **************************************************************************** }

#IF(SWI)
:- module_transparent get_PROLOGrule/2 .
#ENDIF(SWI)

get_PROLOGrule(_head,_body) :-
        clause(_head,_body).


{************ r e m o v e _ t m p _ P R O L O G r u l e s *********************}
{                                                                              }
{ remove_tmp_PROLOGrules/0 retracts all facts of the form tmp_rules(*) repre-  }
{ senting temporary stored list of PROLOGclauses.                              }
{                                                                              }
{ remove_tmp_PROLOGrules/1 retracts all facts of the form tmp_rules(_arg1)  re-}
{ presenting a temporary stored list of PROLOGclauses.                         }
{                                      26-Jul-1991, Andre Klemann (UPA)        }
{                                                                              }
{ Jun-97 remove_tmp_PROLOGrules retracts noch all the facts in form            }
{tmp_rules_del,tmp_rules_ins.						       }
{******************************************************************************}


remove_tmp_PROLOGrules :-

           (retract(tmp_rules(_c));retract(tmp_rules_ins(_c));retract(tmp_rules_del(_c))),
	   remove_PROLOGrules(_c),
           fail.

remove_tmp_PROLOGrules :- ! .





{************ r e m o v e _ c l o s e d _ R u l e T T i m e *******************}
{                                                                              }
{ remove_closed_RuleTTime retracts (in case of a failed UNTELL attempt,	       }
{ or retell_untell attempt) all						       }
{ facts of the form tmp_rules([RuleTTime(..)]) representing temporary stored   }
{ closed transaction times of rules and restores its previous form.            }
{                                                                              }
{******************************************************************************}

remove_closed_RuleTTime :-
      (
	(retract(tmp_rules([RuleTTime(id(_id,_id2),tt(_t1,_t2))])));
	(retract(tmp_rules_del([RuleTTime(id(_id,_id2),tt(_t1,_t2))])))
      ),
      assert(RuleTTime(id(_id,_id2),tt(_t1))),
      fail.

remove_closed_RuleTTime.





{************ s t o r e _ P R O L O G r u l e s *******************************}
{                                                                              }
{ store_PROLOGrules(_clauselist)                                               }
{          _clauselist : ground : list                                         }
{                                                                              }
{ store_PROLOGrules asserts list of PROLOGclauses directly in the PROLOGbase.  }
{                                                                              }
{******************************************************************************}

#IF(SWI)
:- module_transparent store_PROLOGrules/1 .
#ENDIF(SWI)

store_PROLOGrules([]):- !.

store_PROLOGrules([_first|_rest]) :-
#IF(SWI)
    getContextModule(_first,_mod),
	_mod:assert(_first),
#ELSE()
    assert(_first),
#ENDIF(SWI)
    updateIsDeducable(_first),
    store_PROLOGrules(_rest).

{* 13-Jan-2005/M.Jeusfeld: maintain the facts IS_DEDUCABLE up-to-date. *}
{* See also Ticket #45                                                 *}
updateIsDeducable( (_head :- _tail) ) :-
  checkToAddIsDeducable(_head).   {* will update the IS_DEDUCABLE facts for Literals.pro *}
updateIsDeducable(_).             {* never fail *}



#IF(SWI)
:- module_transparent store_PROLOGrulesAndTriggers/1 .
#ENDIF(SWI)

store_PROLOGrulesAndTriggers([]):- !.


{* tell:frames is actually a Prolog expression with operator ':' *}
{* and arguments 'tell' a_frames. We use it to specify Telos     *}
{* frames within an LPI file.                                    *}
store_PROLOGrulesAndTriggers([tell:_frames|_rest]) :-
   delayTellFrames(_frames),
   !,
   store_PROLOGrulesAndTriggers(_rest).

{* This is a hack and i don't like it. Triggers and Rules should either not be stored together in the same file or should be store in the ObjectBase itself
*}
{* case 1: _first is a Trigger *}
store_PROLOGrulesAndTriggers([_first|_rest]) :-
	load_BDMFormula(_first),
	!,
	store_PROLOGrulesAndTriggers(_rest).

store_PROLOGrulesAndTriggers([vmrule(_id,_r)|_rest]) :-
	load_vmrule(vmrule(_id,_r)),
	!,
	store_PROLOGrulesAndTriggers(_rest).

{* case 2: _first is a rule *}
store_PROLOGrulesAndTriggers([_first|_rest]) :-
#IF(SWI)
    getContextModule(_first,_mod),
	_mod:assert(_first),
#ELSE()
    assert(_first),
#ENDIF(SWI)
	!,
	store_PROLOGrulesAndTriggers(_rest).


{* Memorize tell operations that are coded in some LPI file loaded as system start-up *}
{* They may not be told directly when the LPI file is loaded because the system       *}
{* is not yet up and running then.                                                    *}
{* Instead, they are told just before the IPC channel is started.                     *}
{* The syntax for a tell operation in an LPI file is                                  *}
{*    ?- tell('bill in Employee end').                                                  *}
{* See startCBserver.pro                                                              *}

delayTellFrames(_frames) :-
  assert(tobeTold(_frames)),
   WriteTrace(veryhigh,PROLOGruleProcessor, ['Delaying tell frames from an LPI file: ', name(_frames)]),
  !.
delayTellFrames(_).


delayedTell(_frames) :-
  retract(tobeTold(_frames)).

tellDelayedFrames :-
  retract(tobeTold(_frames)),
  checkTellFrames(_frames),
  fail.

tellDelayedFrames.
  

checkTellFrames(_frames) :-
   getFlag(devOption,'nolpi'),
   WriteTrace(veryhigh,PROLOGruleProcessor, ['Skipping delayed frames: ', name(_frames)]),
   !.

checkTellFrames(_frames) :-
  WriteTrace(veryhigh,PROLOGruleProcessor, ['Telling delayed frames: ', name(_frames)]),
  get_cb_feature(TraceMode,_tm),
  setTraceMinimal(_tm),
  saveTellFrames(_tm,_frames),
  !.

saveTellFrames(_tm,_frames) :-
  tellFrames(_frames),
  set_cb_feature(TraceMode,_tm),
  !.

saveTellFrames(_tm,_frames) :-
  WriteTrace(minimal,PROLOGruleProcessor, ['Failed to tell Telos frames fom plugin file: ', name(_frames)]),
  set_cb_feature(TraceMode,_tm),
  !.


setTraceMinimal(low) :-
    set_cb_feature(TraceMode,minimal),
    !.
setTraceMinimal(_).



#IF(SWI)
getContextModule((_head :- _body),_mod) :-
    !,
    getContextModule(_head,_mod).

getContextModule(_head,'GlobalPredicates') :-
    current_predicate(_,_head),
    predicate_property(_head,imported_from('GlobalPredicates')).

getContextModule(_head,user). { :-
    write('**** Warning: Unknown predicate:'), write(_head), nl. }
#ENDIF(SWI)

{************ r e m o v e _ P R O L O G r u l e s *****************************}
{                                                                              }
{ remove_PROLOGrules(_clauselist)                                              }
{          _clauselist : ground : list                                         }
{                                                                              }
{ removePROLOGrules retracts each PROLOGclause in _clauselist from the PROLOG  }
{ database. It fails if one of the tried retracts fails.                       }
{                                                                              }
{******************************************************************************}

#IF(SWI)
:- module_transparent remove_PROLOGrules/1 .
#ENDIF(SWI)

remove_PROLOGrules([]):- !.

remove_PROLOGrules([_fact|_rest]) :-
           retract(_fact),
           remove_PROLOGrules(_rest).

{ *************** d e l e t e _ P R O L O G r u l e s ************************ }
{                                                                              }
{ delete_PROLOGrules abolishes all clauses with                                }
{       functor LTevalRule arity 2                                             }
{       functor LTevalQuery arity 2                                            }
{       functor aux_rule arity 2                                               }
{       functor aux_rule arity 1                                               }
{       functor RuleTTime/2                                                    }
{       the functors of the Integrity Checker and                              }
{       the some more functors of the Query Compiler                           }
{                                                                              }
{ **************************************************************************** }

delete_PROLOGrules :-

           abolish(LTevalQuery,2),
           abolish(LTevalRule,2),
           abolish(aux_rule,2),
           abolish(aux_rule,3),
           abolish(RuleTTime,2),

	delete_all_BDMFormulas('origConstraint@BDMCompile'(_,_,_)),		{ 26-May-1995 LWEB }
	delete_all_BDMFormulas('applyConstraintIfInsert@BDMCompile'(_,_,_,_,_)),{ 26-May-1995 LWEB }
	delete_all_BDMFormulas('applyConstraintIfDelete@BDMCompile'(_,_,_,_,_)),{ 26-May-1995 LWEB }
	delete_all_BDMFormulas('origRule@BDMCompile'(_,_,_,_)),
	delete_all_BDMFormulas('applyRuleIfInsert@BDMCompile'(_,_,_,_,_,_,_)),
	delete_all_BDMFormulas('applyRuleIfDelete@BDMCompile'(_,_,_,_,_,_,_)),

           abolish(QueryArgExp,2),
           abolish(Trigger,2),

           get_KBsearchSpace(_sp,_rb),
           set_KBsearchSpace(_sp,_rb),
           !.



{***********************************************************}
{* store_toFile_PROLOGrules (_filename,_clauselist)        *}
{*                                                         *}
{* _filename : ground : atom                               *}
{* _clauselist : ground : list                             *}
{*                                                         *}
{* store_toFile_PROLOGrules opens file '_filename.pro' and *}
{* writes PROLOGrules in _clauselist to it.                *}
{***********************************************************}

#IF(SWI)
:- module_transparent store_toFile_PROLOGrules/2 .
#ENDIF(SWI)

store_toFile_PROLOGrules(_file,_clauselist) :-

           pc_fopen(clause_file,_file,a),          {AM}
           writeToFile(clause_file,_clauselist),
           pc_fclose(clause_file).


{******************************************************************************}

#IF(SWI)
:- module_transparent delete_fromFile_PROLOGrules/2 .
#ENDIF(SWI)

delete_fromFile_PROLOGrules(_file,_clauselist) :-       {AM}

           pc_fopen(clause_file,_file,a),
           writeToFileDeletes(clause_file,_clauselist),
           pc_fclose(clause_file).






{ ================== }
{ Private predicates }
{ ================== }



{**************** w r i t e T o F i l e ***************************************}
{                                                                              }
{ writeToFile(_logicalfile,_clauselist)                                        }
{             _logicalfile : ground : atom                                     }
{             _clauselist : ground : list                                      }
{                                                                              }
{ writeToFile performs writing list of PROLOGclauses _clauselist to file with  }
{ logical name _logicalfile.                                                   }
{                                                                              }
{ **************************************************************************** }
#IF(SWI)
:- module_transparent writeToFile/2 .
#ENDIF(SWI)

{* ticket #319: only write to file if updatemode is persistent *}
writeToFile(_,_) :-
  get_cb_feature('UpdateMode',nonpersistent),
  !.

writeToFile(_,[]) :- ! .

writeToFile(_file,[(_first)|_rest]) :-
        pc_swriteQuotesAndModule(_atom,_first),
        write(_file,_atom),
        write(_file,'.'),
        write(_file,'\n\n'),
        writeToFile(_file,_rest).


{ **************************************************************************** }
#IF(SWI)
:- module_transparent writeToFileDeletes/2 .
#ENDIF(SWI)


writeToFileDeletes(_,_) :-
  get_cb_feature('UpdateMode',nonpersistent),
  !.

writeToFileDeletes(_,[]) :- ! . {AM}

writeToFileDeletes(_file,[(_first)|_rest]) :-
        pc_swriteQuotesAndModule(_atom,_first),
        write(_file,ToBeDeleted(_atom)),
        write(_file,'.'),
        write(_file,'\n'),
        writeToFileDeletes(_file,_rest).


{ **************************************************************************** }
