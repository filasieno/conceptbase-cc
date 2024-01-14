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
{
*
* File:         QAmanager.pro
* Version:      11.5
* Creation:     19-Mar-1990, Martin Staudt (UPA)
* Last Change   : 96/12/09, Christoph Quix (RWTH)
*
* SCCS-Source-Pool : /home/CBase/CB_NewStruct/ProductPOOL/serverSources/Prolog_Files/SCCS/s.QAmanager.pro
* Date retrieved : 97/05/13 (YY/MM/DD)
* ----------------------------------------------------------------------------
*
* Exported predicates:
* ---------------------
*
*   + handle_queries/5
*
*
* 27-Apr-1993 MSt: retrieve_proposition replaced by prove_literal
*
* 1-Sep-93/Tl: retrieve_proposition calls with constant objects at Src or Dst entry
* are changed into a name2id(...,_id),retr_prop(..,_id,..) combination. The old
* construction didn't work with an extern retrieve_proposition
*
* 30-May-2006/M.Jeusfeld: remove all the stuff related to 'evaluation table'. This
* feature is no longer used in ConceptBase. It was a kind of a cache that memorizes
* answers to queries in files (!). Go to earlier versions of QAmanager.pro, i.e. before
* May 2006 to see the removed code. As a side effect, the procedure invalidate is no
* longer exported. The module TriggerGenerator.pro that has imported invalidate/1 is
* removed as a whole. It's procedure check_QueryTriggers was used by ObjectProcessor.pro
* but now it is obsolete.
*
*
}

#MODULE(QAmanager)
#EXPORT(handle_queries/5)
#EXPORT(adaptAnswerRep/3)
#ENDMODDECL()


#IMPORT(evaluate_queries/4,QueryEvaluator)
#IMPORT(transform_answer/3,AnswerTransformator)
#IMPORT(appendBuffer/2,ExternalCodeLoader)
#IMPORT(active_sender/1,CBserverInterface)
#IMPORT(thisToolId/1,CBserverInterface)
#IMPORT(queue_message/3,CBserverInterface)
#IMPORT(prove_literal/1,Literals)
#IMPORT(append/3,GeneralUtilities)
#IMPORT(member/2,GeneralUtilities)
#IMPORT(retrieve_proposition/1,PropositionProcessor)
#IMPORT(get_KBsearchSpace/2,SearchSpace)
#IMPORT(get_KBsearchSpace/2,SearchSpace)
#IMPORT(Query/1,QueryCompiler)
#IMPORT(GenericQuery/1,QueryCompiler)
#IMPORT(View/1,QueryCompiler)
#IMPORT(newIdentifier/1,validProposition)
#IMPORT(eval/3,SelectExpressions)
#IMPORT(report_error/3,ErrorMessages)
#IMPORT(WriteTrace/3,GeneralUtilities)
#IMPORT(name2id/2,GeneralUtilities)
#IMPORT(atom2list/2,GeneralUtilities)
#IMPORT(evaluate_views/3,ViewEvaluator)
#IMPORT(get_ViewArgExp/3,ViewCompiler)
#IMPORT(pc_atomconcat/2,PrologCompatibility)
#IMPORT(pc_atomconcat/3,PrologCompatibility)
#IMPORT(pc_atom_to_term/2,PrologCompatibility)
#IMPORT(pc_fopen/3,PrologCompatibility)
#IMPORT(pc_fclose/1,PrologCompatibility)
#IMPORT(pc_record/3,PrologCompatibility)
#IMPORT(addAnswerParameters/2,AnswerTransform)
#IMPORT(create_if_builtin_object/1,FragmentToPropositions)
#IMPORT(is_id/1,MetaUtilities)
#IMPORT(mergeAnswersForBulkQueries/2,AnswerTransformator)
#IMPORT(getFlag/2,GeneralUtilities)
#IMPORT(setFlag/2,GeneralUtilities)
#IMPORT(setGlobalVar/3,GeneralUtilities)
#IMPORT(currentClient/3,CBserverInterface)

#DYNAMIC(QueryObject/4)
#DYNAMIC(EvalDecision/3)

#IF(SWI)
:- style_check(-singleton).
#ENDIF(SWI)





{ ==================== }
{ Exported predicates: }
{ ==================== }


{ ********************** h a n d l e _ q u e r i e s ************************ }
{                                                                             }
{	handle_queries ( _qlist, _RBtime, _ansrep, _m , _answer )             }
{			_qlist : ground                                       }
{			_RBtime : ground                                      }
{			_m : ground                                           }
{			_answer : ground                                      }
{                                                                             }
{	handle_queries activates evaluation of specified queries in _qlist    }
{	with Rollback time _RBtime in KB-part _m (at the moment only 'wholeKB'}
{	or 'persistentKB' allowed). The answer _answer consists of a list of  }
{	the answer objects with format _ansrep (e.g. FRAME or FRAGMENT)       }
{	                                                                      }
{	For queries with RBtime 'FromNowOn' the answers are stored in files.  }
{	The dependency between queries, answers and asking tools is stored in }
{	a table. Whenever a query shall be evaluated it is checked wether     }
{	a stored answer for this query already exists or not.                 }
{                                                                             }
{	The administration table consists of three part tables :              }
{		1.) QueryObject table: QueryObject (_qid,_q,_RBtime,_aid)     }
{		    _qid is the identifier for a stored query with query      }
{		    class _q as description and Rollback time _RBtime         }
{		    _aid is the identifier for an answer object which results }
{		    from an evaluation of _qid. If the query has not been     }
{		    evaluated _aid has value unknown.                         }
{		2.) AnswerObject table: AnswerObject(_aid,_aifile)            }
{		    _aid is the identifier of an answer object which results  }
{		    from an evaluation of a query object. _aifile is the name }
{		    of a file where the answers are explicitly stored in form }
{		    of instantiated query literals.                           }
{		3.) EvalDecision table : EvalDecision(_decId,_qid,_toolid)    }
{		    each evaluation of a query _qid is a decision with        }
{		    identifier _decId. This decision is executed for an extern}
{		    tool _toolid. Whenever two query objects are described by }
{		    the same query class and Rollback time they have the same }
{		    identifier but different entries for eval decision and    }
{		    toolid in the evaluation table.                           }
{                                                                             }
{ *************************************************************************** }

{ 31-Mar-95 LWEB  	process_qlist ist ein Hilfsrule dass alle namen in der _qlist 	}
{ 			in TOID's umwandelt 						}

process_qlist([],[]) :- !.

process_qlist([derive(_h,_temp)|_t],[derive(_nh,_temp)|_nt]) :-
        !,  { otherwise crash in garbage collection! 12.10.1998 CR }
        hooksForQueryCall(derive(_h,_temp)),
	name2id(_h,_nh),
	process_qlist(_t,_nt).

process_qlist([_h|_t],[_nh|_nt]) :-
        hooksForQueryCall(derive(_h,_temp)),
	name2id(_h,_nh),
	process_qlist(_t,_nt).


{* issue #53: memorize the currentPalette of the current client *}
hooksForQueryCall(derive(GetJavaGraphicalPalette, [substitute(_palette, pal)])) :-
       currentClient(_toolid,_toolclass,_user),
       setGlobalVar(_toolid,'currentPalette',_palette),
       !.
hooksForQueryCall(_).





handle_queries(_q,_RBtime,_ansrep,_m,_a) :-
        _q \= [],
	_q \= [_|_],!,
	handle_queries([_q],_RBtime,_ansrep,_m,_a).


handle_queries(_qlist_name,_RBtime,_ansrep,_m,_sol1) :-
	_qlist_name \== [],
	process_qlist(_qlist_name,_qlist),
	check_views(_qlist,_vlist),
	_vlist \== [],
	setFlag(currentAnswerFormat,_ansrep),   {*  for JSONIC, ticket #422  *}  
	evaluate_views(_vlist,_ansrep,_sol1).

handle_queries(_qlist_name,_RBtime,_ansrep,_m,_solution) :-
	_qlist_name \== [],
	process_qlist(_qlist_name,_qlist),!,			{ 31-Mar-95 LWEB }
	check_queries(_qlist,_dqlist),
        adaptAnswerRep(_dqlist,_ansrep,_ansrep_new),
	setFlag(currentAnswerFormat,_ansrep_new),  {*  for JSONIC, ticket #422  *}   
	evaluate_queries(_dqlist,_answers,_RBtime,_m),
        mergeAnswersForBulkQueries(_answers,_manswers),  {* treat answers to a bulk query as a single answer *}
	transform_answer(_manswers,_ansrep_new,_solution).


{* for empty query lists; can occur for bulk queries that have only unknown arguments *}
handle_queries([],_RBtime,_ansrep,_m,_solution) :-
        xmlAnswerRep(_ansrep),
        getFlag(bulkQuery,on),
        appendBuffer(_solution,'<result></result>'),
        !.
handle_queries([],_RBtime,_ansrep,_m,_solution) :-
        !.


{* guess whether _ar is expecting ans XML type of answer *}
xmlAnswerRep(_ar) :-
  _ar \= 'FRAME',
  _ar \= 'LABEL',
  _ar \= 'default',
  _ar \= 'VIEW',
  _ar \= 'FRAGMENT',
  _ar \= 'JSONIC',
  _ar \= 'NONE',
  !.






{ =================== }
{ Private predicates: }
{ =================== }




{ ************************ c h e c k _ q u e r i e s ************************** }
{                                                                               }
{	check_queries ( _queries, _nqueries )                                   }
{			_queries : ground : list                                }
{			_nqueries : free                                        }
{	 	                 					        }
{	checks wether queries in _queries are known instances of QueryClass     }
{	or GenericQueryClass resp. correct derive-expressions. In the third     }
{	case _nqueries contains the term representation of the derive-epression }
{	otherwise the original (generic) query from _queries.                   }
{										}
{ ***************************************************************************** }


check_queries([],[]).
check_queries([_f|_r],[_nf|_nr]) :-
	_f =..[derive,_gq,_sl],
	name2id(_gq,_gqID),
	GenericQuery(_gqID),  { 25.08.94 CR }
	build_derive_list(_sl,_dl),  {kann demnaechst wegfallen s.u.}
	_nf =..[derive,_gqID,_dl],!,
	check_queries(_r,_nr).

check_queries([_f|_r],_) :-
	_f =..[_gq,_sl],
	!,
	pc_atom_to_term(_af,_f),
	report_error(QLERR2 , QAmanager,[objectName(_gq),_af]),fail.

check_queries([_f|_r],[_fID|_nr]) :-
	name2id(_f,_fID),
	Query(_fID),
	!,
	check_queries(_r,_nr).

{* one can also ask ordinary classes; that is interpreted as asking for the instances of that class *}
{* Ticket #231                                                                                      *}
check_queries([_f|_r],[_nf|_nr]) :-
	name2id(_f,_fID),
	isClass(_fID),
        _nf =.. [derive,id_448,[substitute(_fID,class)]],    {* id_448=find_instances *}
	!,
	check_queries(_r,_nr).


check_queries([_f|_r],_) :-
	!,
	report_error(QLERR3 , QAmanager,[objectName(_f)]),fail.


isClass(_c) :-
	name2id('Class',_Class),
        prove_literal(In_s(_c,_Class)),  {* an explicit/not inherited instance of Class *}
        !.


{* Function calls will use the LABEL answer format instead *}
{* 'default'. This makes answers shorter.                  *}

adaptAnswerRep([derive(_f,_args)],'default','LABEL') :-
  is_id(_f),
  prove_edb_literal(In_s(_f,id_106)),     {* id_106 = Function *}
  !.

{* ticket #431: replace default format by der first forQuery format if existent *}
adaptAnswerRep([derive(_q,_args)],'default',_formatid) :-
  is_id(_q),
  prove_literal(A(_formatid,AnswerFormat,forQuery,_q)),
  !.
adaptAnswerRep([_q],'default',_formatid) :-
  is_id(_q),
  prove_literal(A(_formatid,AnswerFormat,forQuery,_q)),
  !.

adaptAnswerRep(_,'default','FRAME') :- !.
adaptAnswerRep(_,_a,_a).






check_views([],[]).

check_views([derive(_v,_slist)|_r],[derive(_v,_slistID)|_nr]) :-
	atom(_v),
	name2id(_v,_vID),
	View(_vID),
	build_derive_list(_slist,_slistID),
	!,
	check_views(_r,_nr).


check_views([_v|_r],[_v|_nr]) :-
	atom(_v),
	name2id(_v,_vID),
	View(_vID),
	!,
	check_views(_r,_nr).

check_views([_|_r],_nr) :-
	check_views(_r,_nr).



{ ******************* b u i l d _ d e r i v e _ l i s t ********************** }
{									       }
{	build_derive_list ( _sourcerep, _termrep )                             }
{			_sourcerep : ground                                    }
{			_termrep : free                                        }
{									       }
{	generates term representation _termrep for a derive-expression in      }
{	source representation _sourcerep.                                      }
{	Note: Occurences of object names must be replaced by their correspond- }
{	ing object identifiers.                                                }
{									       }
{ **************************************************************************** }


build_derive_list([],[]).
{MART}{Das gesamt Praed. ersetzt jetzt nur noch ggfs. nicht
umgesetzte Select-Ausdr?cke....kann also wegfallen, sobald auch die einzelnen
Anfragen durch den Telos-Parser laufen}

{*** Case 1: parameter substitution, e.g. Q([1000/salary]) }

build_derive_list([substitute(_oname,_label)|_r],[substitute(_oid,_label)|_nr]) :-
   {* make parameter visible in AnswerFormat.pro *}
   addAnswerParameters('AuxAnswerParameter',[_oname/_label]),
   create_if_builtin_object(_oname),   {* if a value like 1 or "name" is supplied, it will be created as object *}
   eval(_oname,replaceSelectExpression,_oid),
                                            { oname is an external object name,}
   !,                                       { it must be transformed into  }
   build_derive_list(_r,_nr).               { an internal oid              }

{*** Case 2: parameter specialization, e.g. Q([salary:TopSalary]) }

build_derive_list([specialize(_label,_cname)|_r],[specialize(_label,_cid)|_nr]) :-
eval(_cname,replaceSelectExpression,_cid),
        !,
	build_derive_list(_r,_nr).





{ ********************* c h e c k _ p e r m _ q u e r i e s ******************* }
{                                                                               }
{	check_perm_queries ( _queries, _nqueries )                              }
{			_queries : ground : list                                }
{			_nqueries : free                                        }
{	 	                 					        }
{	same as check_queries but _queries must contain only permanently stored }
{	queries resp. derive-expressions which depend on such a query.          }
{                                                                               }
{ ***************************************************************************** }


check_perm_queries([],[]).

check_perm_queries([_f|_r],[_nf|_nr]) :-
	_f =..[_gq,_sl],
	name2id(_gq,_gqID),
	get_KBsearchSpace(_ss,_tt),
	set_KBsearchSpace(currentOB,Now),
	GenericQuery(_gqID),
	set_KBsearchSpace(_ss,_tt),
	build_derive_list(_sl,_dl),
	_nf =..[derive,_gqID,_dl],!,
	check_perm_queries(_r,_nr).

check_perm_queries([_f|_r],_) :-
	_f =..[_gq,_sl],
	!,
	pc_atom_to_term(_af,_f),
	report_error(QLERR4 , QAmanager,[objectName(_gq),_af]),fail.

check_perm_queries([_f|_r],[_fID|_nr]) :-
	name2id(_f,_fID),
	get_KBsearchSpace(_ss,_tt),
	set_KBsearchSpace(currentOB,Now),
	Query(_fID),
	set_KBsearchSpace(_ss,_tt),
	!,
	check_perm_queries(_r,_nr).

check_perm_queries([_f|_r],_) :-
	!,
	report_error(QLERR5 , QAmanager,[objectName(_f)]),fail.






