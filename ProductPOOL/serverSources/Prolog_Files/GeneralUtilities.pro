{*
The ConceptBase.cc Copyright

Copyright 1987-2022 The ConceptBase Team. All rights reserved.

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
*
*
* Date released : %E%  (YY/MM/DD)
*
* SCCS-Source-Pool : %P%
* Date retrieved : %D% (YY/MM/DD)
***************************************************************************
*
*
* 12-Mar-1990 HWN   a string is now a list of characters
* 16-Mar-1990 MSt    new preds delete/3, delete_all/3
*		     remove_multiple_elements/2
* 05-Apr-1990 MSt    new pred replace/4
* 18-Jul-1991 AK   write_info/1 adapted for handling a list of bimstrings;
*                  seemed to be important for tracing multiple answer insances
*                  of a query
* 7-Jul-1992 kvt  a faster method for opListtoTerm/2
*
* 31.10.92 RG new atom2list now as replacement of pc_atomtolist
*
* 26-Jan-1993/DG: InstanceOf is changed into In
* (by deleting the time component, see CBNEWS[154])
*
* 05-Oct-95 HWN: intersect/3 von library sets uebernommen
* 		und subtract/3
*
* 9-Dez-1996 LWEB: *  + name2id_list/2
*  + id2name_list/2  + id2uniquename/2

*
* Exported predicates:
* --------------------
*
*   + read_term/2
*      Read a term in arg2 from file arg1 with EOF detection.
*   + append/3, append/2
*      List concatenation.
*   + member/2
*   + memberchk/2
*   + length/2
*   + delete/3
*   + delete_all/3
*   + remove_multiple_elements/2
*   + append_atom/3
*      Concatenation of atoms.
*   + pcall/1
*      Calls arg1 as a goal after verifying that arg1 is indeed a defined
*      predicate
*   + increment/1
*      Increments the counter arg1 by 1
*   + save_bagof/3
*      Same as builtin bagof/3 but gives arg3=[] if no solutions for
*      the predicate arg2 exist
*   + save_setof/3
*      Similar to builtin setof/3, see save_bagof above.
*   + bimstring/1             			 (12-Mar-1990 HWN)
*      Succeeds if arg1 is a BIMPrologstring (= list of ASCII numbers)
*   + BimstringToString/2
*   + makeflat/2
*      Produces a "flat" list arg2 out of a nested list arg1
*   + opListtoTerm/2
*   + printCBdevelopers/0
*       Writes the names of all ConceptBase developers on standard output
*   + copyright_notice/1
*       Write the copyright notice on the terminal
*   + writeListLn/1
*       prints the list of strings arg1 with the built-in write/1 and termi-
*       nates with the built-in nl/0.
*   + metaIn/4
*	tests, whether an object is a member of the instanciation hirarchy
*	tree of depth _depth
*   + metaIn_first_fit/5
*	similar to metaIn/4, but the instanciation relationship is tes-
*	ted for a list of classes and the first fitting one of them is given
*	back
*   + rewrite_term/2
*   + WriteTrace/3
*   + WriteUpdate/3
*   + atom2list/2
*   + split_list/5 (earlier in ListUtilities)  15-Nov-1992/MSt
*   + map_list/4 (earlier in ListUtilities)  19-Nov-1992/MSt
*   + atom2term/2 30-Jun-93
*
*   + get_label/2 30-Jul-93/HP
*	arg1 is unified with the label of a Proposition with arg2 as
*	its oid. Later this predicate is replaced by an external
*	predicate.
*
*  - get_label/2
*  + name2id_list/2  LWEB
*  + id2name_list/2  LWEB
* + id2uniquename/2 LWEB
*  + name2id/2
*  + id2name/2 2-Sep-93/Tl
*           same as get_label
*  + insertPROLOGVars/2 8-Nov-93/kvt
*       substitute atoms beginning with an underscore
*       by a real PROLOG Variable
*
*  + select2id/2 19-Mai-95/TL
*           same as name2id, only for select-expressions given in a string
*           (not a select(..,...) - prolog structure)
*
*  + intersect/3 05-Oct-95, HWN und
*  + subtract/3
*		aus der BIM Library sets uebernommen
*
}



#MODULE(GeneralUtilities)
#EXPORT(BimstringToString/2)
#EXPORT(WriteListOnTrace/2)
#EXPORT(WriteNewlineOnTrace/1)
#EXPORT(WriteOnTrace/2)
#EXPORT(WriteTrace/3)
#EXPORT(WriteUpdate/3)
#EXPORT(append/2)
#EXPORT(atom2list/2)
#EXPORT(atom2term/2)
#EXPORT(bimstring/1)
#EXPORT(cm_findall/3)
#EXPORT(cm_setof/3)
#EXPORT(conforms/2)
#EXPORT(convert_label/2)
#EXPORT(convert_label/3)
#EXPORT(copyright_notice/1)
#EXPORT(reportCBserverAsReady/1)
#EXPORT(delete/3)
#EXPORT(delete_all/3)
#EXPORT(isSubsetOf/2)
#EXPORT(id2name/2)
#EXPORT(id2name_list/2)
#EXPORT(id2uniquename/2)
#EXPORT(ident_char/1)
#EXPORT(ident_in_atom/2)
#EXPORT(increment/1)
#EXPORT(initializeCBstate/0)
#EXPORT(insertPROLOGVars/2)
#EXPORT(intersect/3)
#EXPORT(last/2)
#EXPORT(makeflat/2)
#EXPORT(makeset/2)
#EXPORT(memberHeadlist/3)
#EXPORT(metaIn_first_fit/5)
#EXPORT(name2allid/2)
#EXPORT(name2id/2)
#EXPORT(t_name2id/3)
#EXPORT(name2id_list/2)
#EXPORT(nmembers/3)
#EXPORT(nth1/3)
#EXPORT(nth1/4)
#EXPORT(opListtoTerm/2)
#EXPORT(operatingSystemIsWindows/0)
#EXPORT(pcall/1)
#EXPORT(printCBdevelopers/0)
#EXPORT(read_term_eof/2)
#EXPORT(remove_multiple_elements/2)
#EXPORT(replace/4)
#EXPORT(replaceCString/2)
#EXPORT(reset_counter/1)
#EXPORT(set_counter/2)
#EXPORT(get_counter/2)
#EXPORT(reset_counter_if_undefined/1)
#EXPORT(reverse/2)
#EXPORT(rewrite_term/2)
#EXPORT(save_bagof/3)
#EXPORT(save_setof/3)
#EXPORT(save_stringtoatom/2)
#EXPORT(select2id/2)
#EXPORT(setDifference/3)
#EXPORT(setUnion/3)
#EXPORT(setUnionAndDifference/4)
#EXPORT(setUserName/0)
#EXPORT(split_atom/4)
#EXPORT(quotedAtom/1)
#EXPORT(unquoteAtom/2)
#EXPORT(subst/3)
#EXPORT(subtract/3)
#EXPORT(uniqueAtom/1)
#EXPORT(user_name/1)
#EXPORT(variable/1)
#EXPORT(writeListLn/1)
#EXPORT(getGraphType/3)   {* originally defined in OB.builtin *}
#EXPORT(timetoatom/2)
#EXPORT(timetoatom/3)
#EXPORT(makeSaveAtom/2)
#EXPORT(saveDIV/3)
#EXPORT(saveIDIV/3)
#EXPORT(increment_counter/2)
#EXPORT(setFlag/2)
#EXPORT(getFlag/2)
#EXPORT(resetFlag/1)
#EXPORT(quicksortLabels/2)
#EXPORT(quicksortLabels/3)
#EXPORT(makeAtom/2)
#EXPORT(stringToQuotedAtom/2)
#EXPORT(writeConceptBaseVersionMessage/0)
#EXPORT(cleanCachedSpeedyFacts/0)
#EXPORT(speedy/1)
#EXPORT(star_name2id/2)
#EXPORT(find_max/2)
#EXPORT(find_min/2)
#EXPORT(createBuffer/1)
#EXPORT(createBuffer/2)
#EXPORT(disposeBuffer/1)
#EXPORT(deleteIpcMessage/1)
#EXPORT(is_allIds/1)
#EXPORT(isAlphanumeric/1)
#EXPORT(makeAlphanumeric/2)
#EXPORT(append/3)
#EXPORT(member/2)
#EXPORT(is_allNumbers/1)
#EXPORT(appendGproperties/2)



#IF(SWI)
#ELSE(SWI)
#EXPORT(is_list/1)
#EXPORT(length/2)
#EXPORT(memberchk/2)
#ENDIF(SWI)
#ENDMODDECL()


#IMPORT(CBdeveloper/1,GlobalParameters)
#IMPORT(cb_version/1,GlobalParameters)
#IMPORT(cb_date_of_release/1,GlobalParameters)
#IMPORT(cb_location/1,GlobalParameters)
#IMPORT(cb_copyright_time/1,GlobalParameters)
#IMPORT(cb_installation/1,GlobalParameters)
#IMPORT(get_cb_feature/2,GlobalParameters)
#IMPORT(default_cb_feature/2,GlobalParameters)
#IMPORT(cb_feature_longname/2,GlobalParameters)
#IMPORT(featureValueName/3,GlobalParameters)
#IMPORT(get_application/1,ModelConfiguration)
#IMPORT(eval/3,SelectExpressions)
#IMPORT(getStringFromBuffer/2,ExternalCodeLoader)
#IMPORT(displayAnswerOnTrace/2,ExternalCodeLoader)
#IMPORT(retrieve_proposition/1,PropositionProcessor)
#IMPORT(retrieve_proposition/2,PropositionProcessor)
#IMPORT(retrieve_proposition_noimport/2,PropositionProcessor)
#IMPORT(get_module_name/2,PropositionProcessor)
#IMPORT(user/1,prologToUnixSUN4)
#IMPORT(host/1,prologToUnixSUN4)
#IMPORT(prove_literal/1,Literals)
#IMPORT(dir_list/2,ConfigurationUtilities)
#IMPORT(currenttime/1,prologToUnixSUN4)
#IMPORT(name2idF2P/2,FragmentToPropositions)
#IMPORT(callExactlyOnce/1,PrologCompatibility)
#IMPORT(id2name_bim2c/2,BIM2C)
#IMPORT(star_name2id_bim2c/2,BIM2C)
#IMPORT(name2id_bim2c/2,BIM2C)
#IMPORT(select2id_bim2c/2,BIM2C)
#IMPORT(portnr/1,GlobalParameters)
#IMPORT(pc_has_a_definition/1,PrologCompatibility)
#IMPORT(pc_atomprefix/3,PrologCompatibility)
#IMPORT(pc_atomconcat/2,PrologCompatibility)
#IMPORT(pc_atomconcat/3,PrologCompatibility)
#IMPORT(pc_erase/2,PrologCompatibility)
#IMPORT(pc_record/2,PrologCompatibility)
#IMPORT(pc_record/3,PrologCompatibility)
#IMPORT(pc_recorded/2,PrologCompatibility)
#IMPORT(pc_recorded/3,PrologCompatibility)
#IMPORT(pc_update/1,PrologCompatibility)
#IMPORT(pc_inttoatom/2,PrologCompatibility)
#IMPORT(pc_floattoatom/2,PrologCompatibility)
#IMPORT(pc_atom_to_term/2,PrologCompatibility)
#IMPORT(pc_atomtolist/2,PrologCompatibility)
#IMPORT(pc_stringtoatom/2,PrologCompatibility)
#IMPORT(pc_ascii/2,PrologCompatibility)
#IMPORT(pc_atompart/4,PrologCompatibility)
#IMPORT(pc_atompartsall/3,PrologCompatibility)
#IMPORT(pc_pointer/1,PrologCompatibility)
#IMPORT(pc_error_message/2,PrologCompatibility)
#IMPORT(pc_swriteQuotes/2,PrologCompatibility)
#IMPORT(appendBuffer/2,ExternalCodeLoader)
#IMPORT(is_id/1,MetaUtilities)
#IMPORT(addAnswerParameters/2,AnswerTransform)
#IMPORT(report_error/3,ErrorMessages)
#IMPORT(raiseStratificationError/0,Literals)
#IMPORT(setCacheSize/1,Literals)
#IMPORT(outObjectName/2,ScanFormatUtilities)
#IMPORT(convertLit/2,ScanFormatUtilities)
#IMPORT(outIdentifier/2,ScanFormatUtilities)
#IMPORT(deleteBuffer/1,ExternalCodeLoader)
#IMPORT(initBuffer/2,ExternalCodeLoader)
#IMPORT(DeleteIpcMessage/1,ExternalCodeLoader)
#IMPORT(classifyPredicate/2,ECAqueryEvaluator)
#IMPORT(loadedLPI/1,ConfigurationUtilities)
#IMPORT(alphanumeric/3,tokens_dcg)
#IMPORT(buildTokens/3,tokens_dcg)
#IMPORT(convertSelectExpression/3,parseAss_dcg)
#IMPORT(getCC/3,Literals)



#DYNAMIC(user_name/1)

#IF(SWI)
:- style_check(-singleton).
#ENDIF(SWI)


{ =================== }
{ Exported predicates }
{ =================== }

{**************************** m a p _ l i s t ******************************}
{                                                                           }
{                                                     06-Nov-1990 / AK (UPA)}
{                                                                           }
{ map_list(_functor,_functor_args,_in_list,_out_list)                       }
{	_functor : ground : atom                                            }
{	_functor_args : partial : a list of arguments [_arg1,...,_argn]     }
{                                 possibly an empty list                    }
{	_in_list : ground : list [...,_x,...]                               }
{	_out_list : any : a list [...,_y,...]                               }
{                                                                           }
{ The predicate _functor(_x,_y,_arg1,...,_argn) is applied to  each  element}
{ _x of the input list _in_list. The resulting list _out_list is constructed}
{ with the resulting arguments _y. The  predicate  _functor(_x,_y,_arg1,...,}
{ _argn) must always succeed. If it is defined in a module, which  uses  the}
{ module directive,the functor must be qualified with the module name or the}
{ predicate must be declared global.                                        }
{                                                                           }
{***************************************************************************}

map_list(_functor,_functor_args,_in_list,_out_list):-
	atom(_functor),
	is_list(_functor_args),
	_pred =.. [_functor,_,_|_functor_args],
	pc_has_a_definition(_pred),
	map_list1(_functor,_functor_args,_in_list,_out_list).


map_list1(_functor,_functor_args,[_head|_tail],[_new_head|_new_tail]):-
	_predicate =.. [_functor,_head,_new_head|_functor_args],
	_predicate,
	map_list1(_functor,_functor_args,_tail,_new_tail).

map_list1(_,_,[],[]).


{********************************* is_list *********************************}
{                                                                           }
{                                                     06-Nov-1990 / AK (UPA)}
{                                                                           }
{ is_list(_l)                                                               }
{                                                                           }
{ is_list/1 succeeds, if _l is a list                                       }
{                                                                           }
{***************************************************************************}

#IF(SWI)
#ELSE(SWI)
is_list(_l) :-
	nonvar(_l),
	is_list1(_l).

is_list1([_|_]).
is_list1([]).
#ENDIF(SWI)

{ ********************** r e a d _ t e r m ********************* }
{                                                                }
{ read_term_eof(_inputfile, _x)                                      }
{   _inputfile: atom                                             }
{   _x: any                                                      }
{                                                                }
{ Just like the builtin read/2 but end-of-file is detected and   }
{ reported in the second argument.                               }
{                                                                }
{ ************************************************************** }

read_term_eof(_inputfile, _x) :-
   read(_inputfile, _x),
   !.

{ SWI and SICStus return end_of_file directly from read if EOF is reached }
#IF(BIM)
read_term_eof(_inputfile, end_of_file) :-
   eof(_inputfile),
   !.
#ENDIF(BIM)

{ ************************* a p p e n d ************************ }
{                                                                }
{ append(_l1,_l2,_l3)                                            }
{   _l1: any                                                     }
{   _l2: any                                                     }
{   _l3 any                                                      }
{                                                                }
{ Just the old list append.                                      }
{                                                                }
{ ************************************************************** }


append([], _l, _l).
append([_x|_l], _r, [_x|_e]) :- append(_l, _r, _e).


{* list version of append *}
append([],[]).
append([_l|_ls],_cl) :-
	append(_ls,_hs),
	append(_l,_hs,_cl).



{ ************************* m e m b e r ************************ }
{                                                                }
{ member(_x,_l)                                                  }
{   _x: any                                                      }
{   _l: any: list                                                }
{                                                                }
{ Succeeds if _x is in the list _l.                              }
{                                                14-Mar-1990/MJf }
{ ************************************************************** }



member(_x,[_x|_]).
member(_x,[_|_r]) :- member(_x,_r).    {'\==' not necessary }
 { member(_x,[_y|_r]) :- _x \== _y,member(_x,_r). }   {'\==' instead '\='}




{***********************************************************}
{* memberchk/2 from the BIM libraries                      *}
{*                                                         *}
{* is faster than member/2 when both parameters are        *}
{* instanciated. (At least BIM says so.)                   *}
{***********************************************************}

#IF(SWI)
#ELSE(SWI)
#MODE( memberchk(i, i) )

memberchk(_Element, [_Head|_Tail]) :-
	memberchk(_Element, _Head, _Tail).

memberchk(_Element, _Element, _) :-
	!.
memberchk(_Element, _, [_Head|_Rest]) :-
	memberchk(_Element, _Head, _Rest).
#ENDIF(SWI)

{* memberHeadlist(_x,_list,_headlist) checks whether _x occurs in _list. *}
{* If yes, then it succeeds and unifies _headlist with the list of       *}
{* elements preceding the first occurrence of _x in _list.               *}
{* Example: memberHeadlist(a3,[a1,a2,a3,a4,a5],[a1,a2]).                 *}

memberHeadlist(_x,_list,_headlist) :-
  do_memberHeadlist(_x,_list,[],_headlist).

do_memberHeadlist(_x,[_x|_rest],_sofar,_sofar) :- !.

do_memberHeadlist(_x,[_y|_rest],_sofar,_headlist) :- 
  append(_sofar,[_y],_new_sofar),
  do_memberHeadlist(_x,_rest,_new_sofar,_headlist).


{ ******************* l e n g t h ****************************** }
{                                                                }
{ length ( _x , _l )                                             }
{    _x : ground : list                                          }
{    _l : free : integer                                         }
{                                                                }
{ ************************************************************** }

#IF(SWI)
#ELSE(SWI)
length([],0).
length([_f|_r],_l) :- length(_r,_l1), _l is _l1 + 1 .
#ENDIF(SWI)


{ ******************** d e l e t e ***************************** }
{                                                 15-Mar-90 MSt  }
{	delete ( _x , _l , _nl )                                 }
{		_x : ground                                      }
{		_l : ground : list                               }
{		_nl : free : list                                }
{                                                                }
{	The first occurence of _x in list _l is deleted,         }
{	result is _nl.                                           }
{                                                                }
{ ************************************************************** }

delete(_x,[],[]).
delete(_x,[_x|_r],_r) :- !.
delete(_x,[_y|_r],[_y|_dr]) :-
	delete(_x,_r,_dr).


{ ******* r e m o v e _ m u l t i p l e _ e l e m e n t s ****** }
{                                                 16-Mar-90 MSt  }
{                                                                }
{ 	remove_multiple_elements ( _l , _sl )                    }
{		_l : ground : list                               }
{		_sl : free : list                                }
{                                                                }
{	Multiple occurences of any element in list _l are        }
{	deleted, result is _sl.                                  }
{ ************************************************************** }

remove_multiple_elements([],[]).

remove_multiple_elements([_x|_r],[_x|_nr]) :-
	delete_all(_x,_r,_r1),
	remove_multiple_elements(_r1,_nr).

{ **************** d e l e t e _ a l l ************************* }
{                                                  16-Mar-90 MSt }
{	delete_all ( _el , _l , _nl )                            }
{		_el : ground                                     }
{		_l : ground : list                               }
{		_sl : free : list                                }
{                                                                }
{	All occurences of element _el in list _l are deleted,    }
{	result is _nl.                                           }
{                                                                }
{ ************************************************************** }

delete_all(_,[],[]) :- !.
delete_all(_x,[_y|_r],_nr) :-
	_x == _y,  { Aug-97/CQ, Element muessen identisch sein, sonst unerwuenschte Unifikation! }
	!,
	delete_all(_x,_r,_nr).

delete_all(_x,[_y|_r],[_y|_nr]) :-
	_x \== _y,
	delete_all(_x,_r,_nr).


{ ************************** r e p l a c e ********************* }
{                                                05-Apr-90 MSt   }
{	replace ( _x , _l , _y , _nl )                           }
{		_x : ground                                      }
{		_l : ground : list                               }
{		_y : ground                                      }
{		_nl : free                                       }
{	                                                         }
{	replace all occurences of element _x in list _l by ele-  }
{	ment _y. Result is _nl.                                  }
{                                                                }
{ ************************************************************** }

replace(_x,[],_y,[]).

replace(_x,[_x|_r],_y,[_y|_nr]) :-
	!,replace(_x,_r,_y,_nr).

replace(_x,[_f|_r],_y,[_f|_nr]) :-
	replace(_x,_r,_y,_nr).




{ ******************** a p p e n d _ a t o m ******************* }
{                                                                }
{ append_atom(_a1,_a2,_a3)                                       }
{   _a1: atom                                                    }
{   _a2: atom                                                    }
{   _a3: any: atom                                               }
{                                                                }
{ Concat a1 and a2: a3 <-- a1 # a2                               }
{                                                                }
{ ************************************************************** }

append_atom(_a1,_a2,_a3) :-
  pc_atomconcat([_a1,'#',_a2],_a3).




{ ************************** p c a l l ************************* }
{                                                                }
{ pcall(_goal)                                                   }
{   _goal: any                                                   }
{                                                                }
{ 'pcall' calls _goal if it has a definition (there is a corres- }
{ ponding clause in the Prolog database.                         }
{ 'pcall' is especially useful to avoid error message in the     }
{ case of undefined predicates.                                  }
{                                                                }
{ ************************************************************** }
#IF(SWI)
:- module_transparent pcall/1 .
#ENDIF(SWI)

pcall(_goal) :-
  pc_has_a_definition(_goal),
  call(_goal).



{ ********************** i n c r e m e n t ********************* }
{                                                                }
{ increment(_counter)                                            }
{   _counter: atom                                               }
{                                                                }
{ This procedures treats _counter as unary Prolog facts whose    }
{ argument is incremented by 1.                                  }
{                                                                }
{ ************************************************************** }
#IF(SWI)
:- module_transparent increment/1 .
#ENDIF(SWI)


increment(_counter) :-
  increment_counter(_counter,_current).

increment_counter(_counter,_i) :-
  atom(_counter),
  _call =.. [_counter, _i],
  pcall(_call),
  integer(_i),
  _i1 is _i+1,
  _newfact =.. [_counter, _i1],
  pc_update(_newfact),
{* write('New value for '),write(_counter),write(': '),write(_i1),nl, *}
  !.

increment_counter(_counter,_) :-
  writeListLn(['% ERROR in GeneralUtilities: ',
	_counter,' is not a proper counter']),
  !.

set_counter(_counter,_n) :- 
  atom(_counter),
  _counter_fact =.. [_counter, _n],
  pc_update(_counter_fact),
  !.

get_counter(_counter,_n) :-
  atom(_counter),
  _counter_fact =.. [_counter, _n],
  pcall(_counter_fact),
  !.

reset_counter(_counter) :-
  set_counter(_counter,0).

reset_counter_if_undefined(_counter) :-
  atom(_counter),
  _call =.. [_counter, _i],
  pc_has_a_definition(_call),
  pcall(_call),
  !.

reset_counter_if_undefined(_counter) :-
  reset_counter(_counter).




{* manage label/value pairs *}

setFlag(_label,_value) :-
  atom(_label),
  pc_recorded(_label,'labelValuePair',_oldvalue),
  pc_rerecord(_label,'labelValuePair',_value),
  !.

setFlag(_label,_value) :-
  atom(_label),
  pc_record(_label,'labelValuePair',_value),
  !.

getFlag(_label,_value) :-  
  atom(_label),
  pc_recorded(_label,'labelValuePair',_value),
  !.

resetFlag(_label) :-
  atom(_label),
  pc_erase(_label,'labelValuePair'),
  !.





{ ********************* s a v e _ b a g o f ******************** }
{                                                                }
{ save_bagof(_x,_pred,_listofresults)                            }
{   _x: any                                                      }
{   _pred: partial                                               }
{   _listofresults: any: list                                    }
{                                                                }
{ 'save_bagof' collects in _listofresults all elements like _x   }
{ which satisfy _pred. Opposed to the builtin predicate 'bagof'  }
{ 'save_bagof' will return the empty list if there is no single  }
{ solution for _pred.                                            }
{                                                                }
{ ************************************************************** }

#IF(SWI)
:- module_transparent save_bagof/3 .
#ENDIF(SWI)

save_bagof(_x,_pred,_listofresults) :-
  bagof(_x,_pred,_listofresults),
  !.

save_bagof(_,_,[]).


{ ********************* s a v e _ s e t o f ******************** }
{                                                                }
{ save_setof(_x,_pred,_listofresults)                            }
{   _x: any                                                      }
{   _pred: partial                                               }
{   _listofresults: any: list                                    }
{                                                                }
{ see 'save_bagof'...                                            }
{                                                                }
{ ************************************************************** }

#IF(SWI)
:- module_transparent save_setof/3 .
#ENDIF(SWI)

save_setof(_x,_pred,_listofresults) :-
  setof(_x,_pred,_listofresults),
  !.

save_setof(_,_,[]).



{ ******************** c m _ f i n d a l l ********************* }
{                                                                }
{ cm_findall(_x,_g,_l)                                           }
{  _x: any                                                       }
{  _g: partial                                                   }
{  _l: any: list                                                 }
{                                                                }
{ Find all _x satisfying goal _g and put them in the list _l.    }
{ The code is taken from Clocksin&Mellish 1981, p. 152.          }
{ Duplicates are not removed.                                    }
{                                                                }
{ ************************************************************** }
#IF(SWI)
:- module_transparent cm_findall/3 .
#ENDIF(SWI)

cm_findall(_x,_g,_) :-
  asserta('found@GU'('%mark')),
  call(_g),
  asserta('found@GU'(_x)),
  fail.

cm_findall(_,_,_m) :-
  cm_collect_found([],_m).

cm_collect_found(_s,_l) :-
  cm_get_next(_x),
  !,
  cm_collect_found([_x|_s],_l).

cm_collect_found(_l,_l).

cm_get_next(_x) :-
  retract('found@GU'(_x)),
  !,
  _x \== '%mark'.


cm_setof(_x,_g,_) :-
  asserta('found@GU'('%mark')),
  call(_g),
  asserta_if_new('found@GU'(_x)),
  fail.

cm_setof(_,_,_m) :-
  cm_collect_found([],_m).

asserta_if_new('found@GU'(_x)) :-
  'found@GU'(_x),
  !.

asserta_if_new('found@GU'(_x)) :-
   asserta('found@GU'(_x)).


{ ************************ m a k e s e t *********************** }
{                                                                }
{ makeset(_bag,_set)                                             }
{   _bag: partial: list                                          }
{   _set: list                                                   }
{                                                                }
{ Produces _set by removing all duplicates from _bag.            }
{ _bag must be instantiated.                                     }
{                                                                }
{ ************************************************************** }

makeset(_x,_) :-
  var(_x),
  !,
  fail.

makeset([],[]) :- !.

makeset([_x|_bagrest],_set) :-
  member(_x,_bagrest),
  !,
  makeset(_bagrest,_set).

makeset([_x|_bagrest],[_x|_setrest]) :-
  makeset(_bagrest,_setrest).



{ *********************** s e t U n i o n ********************** }
{                                                                }
{ setUnion(_s1,_s2,_set)                                         }
{   _s1,_s2: list (i)                                            }
{   _set: list  (o)                                              }
{                                                                }
{ _Set is the union of lists _s1,_s2 (without duplicates).       }
{                                                                }
{ ************************************************************** }

setUnion(_s1,_s2,_Set) :-
  append(_s1,_s2,_List),
  makeset(_List,_Set),
  !.


{ ****************** s e t D i f f e r e n c e ***************** }
{                                                                }
{ setDifference(_s1,_s2,_set)                                    }
{   _s1,_s2: list (i)                                            }
{   _set: list  (o)                                              }
{                                                                }
{ _Set is the set of elements of _s1 that are not in _s2, i.e.   }
{ ( _s1 \ _s2 )                                                  }
{                                                                }
{ ************************************************************** }

setDifference([],_,[]) :- !.

setDifference([_x|_rest],_s2,_set) :-
  member(_x,_s2),
  !,
  setDifference(_rest,_s2,_set).

setDifference([_x|_rest],_s2,[_x|_set]) :-
  setDifference(_rest,_s2,_set).


{ ********** s e t U n i o n A n d D i f f e r e n c e ********* }
{                                                                }
{ setUnionAndDifference(_s1,_s2,_u,_d)                           }
{   _s1,_s2: list (i)                                            }
{   _u,_d: list  (o)                                             }
{                                                                }
{ The parameter_ u is the (set) union of s1, s2; _d is the set   }
{ difference.                                                    }
{                                                                }
{ ************************************************************** }

setUnionAndDifference([],_s2,_s2,[]) :- !.

setUnionAndDifference([_x|_rest],_s2,_union,_difference) :-
  (member(_x,_s2); member(_x,_rest)),
  !,
  setUnionAndDifference(_rest,_s2,_union,_difference).

setUnionAndDifference([_x|_rest],_s2,[_x|_ru],[_x|_rd]) :-
  setUnionAndDifference(_rest,_s2,_ru,_rd).



{ ************************* quotedAtom  ************************ }
{                                                                }
{ quotedAtom(_x)                                                 }
{   _x: ground                                                   }
{                                                                }
{ 'quotedAtom' succeeds if _x is a atom enclosed in double quotes}
{                                                                }
{ ************************************************************** }

quotedAtom(_x) :-
    var(_x),
    !,
    fail.

quotedAtom(_x) :-
    atom(_x),
    pc_atomconcat('"',_r,_x),
    pc_atomconcat(_f,'"',_r).


{* quote an atom if necessary *}

quoteAtom(_a,_a) :-
   atom(_a),
   quotedAtom(_a),
   !.

quoteAtom(_a,_qa) :-
   atom(_a),
   pc_atomconcat(['"',_a,'"'],_qa),
   !.

quoteAtom(_a,_a).


{* remove double quotes around an atom if possible *}

unquoteAtom(_x,_xstripped) :-
    atom(_x),
    pc_atomconcat('"',_r,_x),
    pc_atomconcat(_xstripped,'"',_r),
    !.

unquoteAtom(_x,_x).


{* convert a Prolog string like [77, 97, 114, 105, 104] to a quoted atom like "Marih" *}
stringToQuotedAtom(_s,_qa) :-
  makeAtom(_s,_a),
  quoteAtom(_a,_qa).
  

{ ************************* b i m s t r i n g ****************** }
{                                                                }
{ bimstring(_x)                                                  }
{   _x: ground                                                   }
{                                                                }
{ 'bimstring' succeeds if _x is a list of ASCII numbers (here:   }
{ integer).                                                      }
{                                                                }
{ ************************************************************** }


bimstring(_x) :- var(_x), !, fail.
bimstring([_i]) :- integer(_i),!.			{12-Mar-1990 HWN}
bimstring([_i|_t]) :- integer(_i), bimstring(_t).


{* BimstringToString is selfexplanatory.                11-Apr-1990/MJf }
{* ... works in both directions                                         }

BimstringToString([],[]) :- !.
BimstringToString([_x|_numberlist],[_c|_charlist]) :-
  pc_ascii(_c,_x),
  BimstringToString(_numberlist,_charlist).



{ *********************** m a k e f l a t ********************** }
{                                                                }
{ makeflat(_list,_flatlist)                                      }
{   _list: list                                                  }
{   _flatlist: any: list                                         }
{                                                                }
{ 'makeflat' takes _list as input parameter and produces _flat-  }
{ list, which is a "flat" list of all non-list elements of _list }
{ or its elements.                                               }
{ Example:                                                       }
{   ?- makeflat([a,[b,c],[[[c]]],d],_r).                         }
{      _r = [a,b,c,d]                                            }
{   Yes                                                          }
{                                                                }
{ ************************************************************** }

makeflat(_x,_) :-                       {first parameter must be input}
  var(_x),
  !,
  fail.

makeflat([],[]) :- !.


makeflat([_x|_rest],[_x|_frest]) :-     {variables are elements, too}
  var(_x),
  !,
  makeflat(_rest,_frest).

makeflat([[]|_rest],_flatlist) :-
  !,
  makeflat(_rest,_flatlist).

makeflat([[_h|_t]|_rest],_flatlist) :-   {main clause}
  !,
  makeflat([_h,_t|_rest],_flatlist).

makeflat([_a|_rest],[_a|_frest]) :-      {copying non-list elements}
  makeflat(_rest,_frest).


{***********************************************************}
{* isSubsetOf(_A,_S)                                       *}
{*                                                         *}
{* succeeds if all elements of list A also occur in list S *}
{***********************************************************}

isSubsetOf([],_S).

isSubsetOf([_a|_restA],_S) :-
  member(_a,_S),
  isSubsetOf(_restA,_S).
  


{ ************** p r i n t C B d e v e l o p e r s ************* }
{                                                 5-Mar-1990/MJf }
{ printCBdevelopers                                              }
{                                                                }
{ Write them on standard output.                                 }
{                                                                }
{ ************************************************************** }

#DYNAMIC(bufferedCBdeveloper/1)

printCBdevelopers :-
   CBdeveloper(_name),
   outputCBdeveloper(_name),
{*   WriteListOnTrace(minimal,['                                     | ',_name]), *}
   fail.

printCBdevelopers :-
  retract(bufferedCBdeveloper(_name1)),
  WriteListOnTrace(low,['   ',_name1]),
  !.

printCBdevelopers.

outputCBdeveloper(_name2) :-
  retract(bufferedCBdeveloper(_name1)),
  WriteListOnTrace(low,['   ',_name1,' | ',_name2]),
  !.

outputCBdeveloper(_name) :-
  assert(bufferedCBdeveloper(_name)),
  !.



{ ************** i n i t i a l i z e C B s t a t e ************* }
{                                                17-Mar-1990/MJf }
{ initializeCBstate                                              }
{                                                                }
{ Initialize various counters of ConceptBase. The most important one is     }
{ 'Session_counter' since it enables unique object identifiers.  }
{                                                                }
{ Counters are declared in module 'GlobalParameters.pro'         }
{ RS, 20.1.1997                                                  }
{                                                                }
{ ************************************************************** }

initializeCBstate :-
   getFlag(Session_counter,_c),
   pc_inttoatom(_c,_IDc),
   pc_atomconcat('s',_IDc,_IDs),
   setFlag(Session_id,_IDs),
   setFlag(Transaction_counter,0),         {used in CBserverInterface.pro}
   setFlag(QueuedMessage_counter,0),       {used in CBserverInterface.pro}
   setFlag(ID_counter,0),                  {used in validProposition.pro}
   setCacheSize(0),                        {used in Literals.pro}
   setCurrentCacheMode,
   reset_counter(ruleTriggerCount),
   reset_counter(constraintTriggerCount),
   setErrorQueueSlots,
   !.

setErrorQueueSlots :-
   get_cb_feature(maximalErrors,_maxe),
   setFlag(remainingErrorQueueSlots,_maxe),
   !.
setErrorQueueSlots. {* never fail *}

setCurrentCacheMode :-
  get_cb_feature(defaultCacheMode,_dm),
  setFlag(currentCacheMode,_dm),
  !.
setCurrentCacheMode :-
  setFlag(currentCacheMode,'off').     {to have at least a starting value *}



{ setUserName takes the login name user() and the hostname host() }
{ and stores the fact user_name(<user>@host). This is used for    }
{ specifying the user connecting a tool to the CBserver. See      }
{ method ENROLL_ME of the CBserverInterface.    14-Feb-1991/MJf   }

setUserName :-
   user(_user),
   host(_host),
   pc_atomconcat([_user,'@',_host],_full_username),
   pc_update(user_name(_full_username)),
   !.




{* for startCBserver, option -version *}
writeConceptBaseVersionMessage :-
   cb_version(_v),
   cb_date_of_release(_d),
   cb_location(_loc),
   getenv(CB_VARIANT,_variant),
   getPROLOG_VARIANT(_pvariant),
   cb_copyright_time(_copyyears),
   write('ConceptBase.cc Server '),
   write(_v),
   write(' ('),write(_variant),
   write(','),write(_pvariant),write('), '),
   write(_loc),write(', '),
   write(_d),nl,
   write( _copyyears), write(' by The ConceptBase Team. All rights reserved.'),nl,
   write('Original software by Manfred Jeusfeld, Martin Staudt, Christoph Quix and others.'),nl,
   write('This is free software. '),
   write('See http://conceptbase.cc for details.'),nl,
   write('No warranty, not even for MERCHANTABILITY or '),
   write('FITNESS FOR A PARTICULAR PURPOSE.'),nl, 
   !.



{ copyright_notice/1 does the work for copyright_notice/0 of }
{ startCB,startCBenv and startCBserver.       9-Mar-1990/MJf }

copyright_notice(_tool) :-
   cb_version(_v),
   cb_date_of_release(_d),
   cb_location(_loc),
   cb_copyright_time(_copyyears),
   getenv(CB_VARIANT,_variant),
   getPROLOG_VARIANT(_pvariant),
   printImportantParameters,
   {* these parameters are also accessible to answer formats: *}
   addAnswerParameters('PersistentAnswerParameter',
                         [_v/cb_version,_d/cb_date_of_release,_variant/CB_VARIANT,
                          _pvariant/PROLOG_VARIANT]),
   WriteListOnTrace(minimal,['> This is ConceptBase.cc (',_tool,') ',_v,', ',_loc,', ',_d]),
   WriteListOnTrace(minimal,['> ', _copyyears, ' by The ConceptBase Team. All rights reserved.']),
   WriteListOnTrace(minimal,['> Distributed under a BSD-style license. Call "cbserver -license" for details.']),
   WriteNewlineOnTrace(minimal),
   WriteListOnTrace(minimal,['>    Contact: M.Jeusfeld,University of Skovde,54128 Skovde/Sweden']),
{*   WriteListOnTrace(minimal,['>    M.Jarke,C.Quix,RWTH Aachen,Ahornstr.55,52056 Aachen/Germany']), *}
   WriteListOnTrace(minimal,['>    http://conceptbase.cc']),
   WriteNewlineOnTrace(minimal),
   (
    (cb_installation(runtime),!);
     (getenv('CB_WORK',_cbwork),
      writeListLn(['>>> Interactive version build from ProductPOOL at ',_cbwork]),
      nl
     )
    ),
   !.

copyright_notice(_).   {never fail}


reportCBserverAsReady(_module) :-
   portnr(_nr),
   host(_host),
   WriteListOnTrace(no,['> CBserver ready on host \'',_host, '\' serving port number ',_nr]),
   WriteNewlineOnTrace(minimal),
   !.


getPROLOG_VARIANT(_pvariant) :-
  getenv(PROLOG_VARIANT,_pvariant1),
  getPROLOG_VERSION(_version),
  pc_atomconcat(_pvariant1,_version,_pvariant).

#IF(SWI)
getPROLOG_VERSION(_version) :-
  current_prolog_flag(version,_v),
  _major is _v // 10000,
  _v1 is _v - _major * 10000,
  _minor is _v1 // 100,
  _patch is _v1 - _minor * 100,
  pc_inttoatom(_major,_at1),
  pc_inttoatom(_minor,_at2),
  pc_inttoatom(_patch,_at3),
  pc_atomconcat([' ',_at1,'.',_at2,'.',_at3],_version).
#ELSE(SWI)
#ENDIF(SWI)

getPROLOG_VERSION('').


printImportantParameters :-
   get_application(_app),
   !,
   printCBFeatures,
   printCharacterEncoding,
   WriteListOnTrace(minimal,['> Loaded database: ',_app]),
   writeLoadedLPI,
   WriteNewlineOnTrace(minimal).


printImportantParameters.


writeLoadedLPI :-
  findall(_lpi,loadedLPI(_lpi),_lpiList),
  insertCommas(_lpiList,_printableLpiList),
  WriteListOnTrace(minimal,['> Includes plugins: '|_printableLpiList]),
  !.
writeLoadedLPI.

insertCommas([],[]) :- !.

insertCommas([_lpi],[_lpi]) :- !.

insertCommas([_lpi|_rest],[_lpi,', '|_restplist]) :- 
  insertCommas(_rest,_restplist).






printCBFeatures :-
  cb_feature_longname(_f,_n),
  get_cb_feature(_f,_val),
  default_cb_feature(_f,_defval),
  _defval \= _val,
  addAnswerParameters('PersistentAnswerParameter',[_val/_f]),   {* make that value accessible for answer formatting as well *}
  printOnTrace(_f,_n,_val),
  fail.
printCBFeatures.


printOnTrace(_f,_n,_val) :-
  featureValueName(_f,_val,_printname),
  WriteListOnTrace(minimal,['> ',_n,': ',_val, ' (',_printname,')']),
  !.
printOnTrace(_f,_n,_val) :-
  WriteListOnTrace(minimal,['> ',_n,': ',_val]),
  !.



#IF(SWI)
printCharacterEncoding :-
   current_prolog_flag(encoding,_encoding),
   WriteListOnTrace(high,['> Character encoding: ',_encoding]),
   !.
#ELSE(SWI)
#ENDIF(SWI)

printCharacterEncoding.



{ ********************* W r i t e T r a c e ******************** }
{                                                 3-May-1990/MJf }
{ WriteTrace(_prio,_module,_x)                                   }
{                                                                }
{ Write _x on standard output if _prio conforms with TraceMode.  }
{ See also fact TraceMode in GlobalParameters.                   }
{                                                                }
{ ************************************************************** }

WriteTrace(_prio,_module,[_h|_t]) :-
  get_cb_feature(TraceMode,_m),
  conforms(_prio,_m),
  numberforName(_prio,_number),
  write('>>> '),writeCurrentTime,write(' - '),
  write(_module),write(': '),
  write_info([_h|_t],_number),nl,
  !.

{ If x is a pointer, then it is a pointer to a StringBuffer,
  use displayAnswerOnTrace to write answer }
WriteTrace(_prio,_module,_x) :-
  pc_pointer(_x),
  get_cb_feature(TraceMode,_m),
  conforms(_prio,_m),
  numberforName(_prio,_number),
  write('>>> '),writeCurrentTime,write(' - '),
  write(_module),write(': '),
#IF(SWI)
    flush_output,
#ENDIF(SWI)
  displayAnswerOnTrace(_x,_number),nl,
  !.

WriteTrace(_prio,_module,_x) :-
  atom(_x),
  get_cb_feature(TraceMode,_m),
  conforms(_prio,_m),
  numberforName(_prio,_number),
  write('>>> '),writeCurrentTime,write(' - '),
  write(_module),write(': '),
  write(_x),nl,
  !.

WriteTrace(_,_,_).


{* 22-Feb-2001/MJf: output in each WriteTrace the current time *}
writeCurrentTime :-
  currenttime(_time),
  writeTime(_time),
  !.


writeTime(_time) :-
  timetoatom(noniso,_time,_a),
  write(_a).

timetoatom(_t,_a) :-
  timetoatom(iso,_t,_a).


timetoatom(_isomode,tt(millisecond(_y,_mo,_d,_h,_mi,_s,_milli)),_a) :-
  timetoatom(_isomode,millisecond(_y,_mo,_d,_h,_mi,_s,_milli),_a),
  !.


{* display date in format YYYY-MM-DD, time as hh:mm:ss *}
timetoatom(noniso,millisecond(_y,_mo,_d,_h,_mi,_s,_ms),_a) :-
  write4(_y,_ya),
  write2(_mo,_moa),
  write2(_d,_da),
  write2(_h,_ha),
  write2(_mi,_mia),
  write2(_s,_sa),
  write3(_ms,_msa),
  pc_atomconcat([_ya,'-',_moa,'-',_da,',',_ha,':',_mia,':',_sa,'.',_msa],_a),
  !.

{* display date in ISO 8601/EN 28601 format like 2007-12-24T18:21,318Z *}
timetoatom(iso,millisecond(_y,_mo,_d,_h,_mi,_s,_ms),_a) :-
  write4(_y,_ya),
  write2(_mo,_moa),
  write2(_d,_da),
  write2(_h,_ha),
  write2(_mi,_mia),
  write2(_s,_sa),
  write3(_ms,_msa),
  pc_atomconcat([_ya,'-',_moa,'-',_da,'T',_ha,':',_mia,':',_sa,',',_msa,'Z'],_a),
  !.

{* display date as a list of numbers like 2007,12,24,18,21,318 *}
timetoatom(list,millisecond(_y,_mo,_d,_h,_mi,_s,_ms),_a) :-
  write4(_y,_ya),
  write2(_mo,_moa),
  write2(_d,_da),
  write2(_h,_ha),
  write2(_mi,_mia),
  write2(_s,_sa),
  write3(_ms,_msa),
  pc_atomconcat([_ya,',',_moa,',',_da,',',_ha,',',_mia,',',_sa,',',_msa],_a),
  !.


write2(_n) :-
  integer(_n), _n =< 9, _n >= 0,
  write(0),write(_n),
  !.

write2(_n) :- write(_n).

{* write<n> outputs an integer with n digits to an atom (using leading 0) *}
write4(_n,_a) :-
  integer(_n),
  _n < 10,_n >= 0,
  pc_inttoatom(_n,_a1),
  pc_atomconcat('000',_a1,_a),
  !.

write4(_n,_a) :-
  integer(_n),
  _n < 100,_n >= 10,
  pc_inttoatom(_n,_a1),
  pc_atomconcat('00',_a1,_a),
  !.

write4(_n,_a) :-
  integer(_n),
  _n < 1000,_n >= 100,
  pc_inttoatom(_n,_a1),
  pc_atomconcat('0',_a1,_a),
  !.

write4(_n,_a) :-
  integer(_n),
  pc_inttoatom(_n,_a),
  !.


write3(_n,_a) :-
  integer(_n),
  _n < 10,_n >= 0,
  pc_inttoatom(_n,_a1),
  pc_atomconcat('00',_a1,_a),
  !.

write3(_n,_a) :-
  integer(_n),
  _n < 100,_n >= 10,
  pc_inttoatom(_n,_a1),
  pc_atomconcat('0',_a1,_a),
  !.

write3(_n,_a) :-
  integer(_n),
  pc_inttoatom(_n,_a),
  !.




write2(_n,_a) :-
  integer(_n),
  _n < 10,_n >= 0,
  pc_inttoatom(_n,_a1),
  pc_atomconcat('0',_a1,_a),
  !.

write2(_n,_a) :-
  integer(_n),
  pc_inttoatom(_n,_a),
  !.


  




{* Trace an pc_update on KB (see ObjectProcessor.pro) *}

WriteUpdate(_prio,_prefix,_prop) :-
  get_cb_feature(TraceMode,_m),
  conforms(_prio,_m),
  checkForIDs(_prop,_outprop),
  writeListLn([_prefix,_outprop]),
  !.

WriteUpdate(_,_,_).


{* This one is for writing anything on the trace without the headers *}
{* that WriteTrace imposes.                                          *}

WriteOnTrace(_prio,_term) :-
  get_cb_feature(TraceMode,_m),
  conforms(_prio,_m),
  write(_term),
  !.

WriteOnTrace(_,_).


{* write a list of terms (atoms) on the trace *}

WriteListOnTrace(_prio,_) :-
  get_cb_feature(TraceMode,_m),
  \+ conforms(_prio,_m),
  !.  {* do nothing *}


WriteListOnTrace(_prio,[]) :-
  nl,
  !.

WriteListOnTrace(_prio,[_x|_rest]) :-
  writeX(_x),
  WriteListOnTrace(_prio,_rest).

WriteListOnTrace(_,_).  {* never fail *}

writeX(_r) :-
  float(_r),
#IF(BIM)
  printf(stdout, '%.6f',_r),
#ELSE(BIM)
  format('~6f',[_r]),
{*  write(_r), *}
#ENDIF(BIM)
  !.

writeX(_x) :- write(_x).



{* make sure that we writes propositions on the trace where source s and *}
{* destination d are consistently either all names or all ids            *}

checkForIDs(P(_id,_s,_l,_d),P(_id,_sid,_l,_did)) :-
  name2idF2P(_s,_sid),
  name2idF2P(_d,_did),
  !.

checkForIDs(_prop,_prop).



{* Just write a newline if _prio is accordingly *}
WriteNewlineOnTrace(_prio) :-
  get_cb_feature(TraceMode,_m),
  conforms(_prio,_m),
  nl,
  !.

WriteNewlineOnTrace(_).



conforms(_messageprio,_filter) :-
   numberforName(_messageprio,_n1),
   numberforName(_filter,_n2),
   _n1 =< _n2,
   !.

numberforName(silent,-1).
numberforName(no,0).
numberforName(minimal,1).
numberforName(low,2).
numberforName(high,3).
numberforName(veryhigh,4).




write_info([],_) :- nl.
write_info([_h|_t],_tl) :- writeItem(_h,_tl),!,write_info(_t,_tl).
write_info(_x,_tl) :- writeItem(_x,_tl).

writeItem(nl,_) :- nl,!.
writeItem([],_) :-
  write('[]'),
  !.

writeItem(stringBuffer(_p),_m) :-
#IF(SWI)
    flush_output,
#ENDIF(SWI)
    displayAnswerOnTrace(_p,_m),
    !.

writeItem(name(_x),_) :-
        makeAtom(_x,_n),
        !,
        write(_n).

writeItem(idterm(_x),_) :-
	writeidterm(_x),
	!.

writeItem(_x,_) :- write(_x).

writeidterm(_x) :-
	var(_x),
	!,
	write(_x).

writeidterm(_x) :-
	is_id(_x),
	id2name(_x,_),
	outObjectName(_x,_n),
	!,
	write(_n).

writeidterm(_action) :-
        _action =.. [_a,_lit],
        member(_a,['Tell','Untell','Retell','Ask']),
        convertLit(_lit,_nicelit),
	!,
	write(_a), write(' '), write(_nicelit).

writeidterm(_action) :-
        _action =.. ['Raise',_dexp],
        outIdentifier(_dexp,_nicedexp),
	!,
	write('Raise'), write(' '), write(_nicedexp).

writeidterm(_x) :-
	(atomic(_x);var(_x)),
	!,
	write(_x).

writeidterm(_x) :-
	is_list(_x),
	!,
	write('['),
	writeidlist(_x),
	write(']'),
	!.

writeidterm(_x) :-
        compound(_x),
	_x =.. [_f|_args],
	!,
	writeidterm(_f),
	write('('),
	writeidlist(_args),
	write(')'),
	!.

writeidterm(_x) :-
	write(_x),
	!.

writeidlist([]).
writeidlist([_id|_ids]) :-
	writeidterm(_id),
	(_ids ==[];write(',')),
	!,
	writeidlist(_ids).

writeString([]) :-
  !.

writeString([_i|_s]) :-
  put(_i),
  writeString(_s).



{************************** s p l i t  _ l i s t ***************************}
{                                                                           }
{                                                     06-Nov-1990 / AK (UPA)}
{                                                                           }
{ split_list(_functor,_functor_args,_in_list,_list1,_list2)                 }
{	_functor : ground : atom                                            }
{	_functor_args : partial : a list of arguments [_arg1,...,_argn]     }
{                                 possibly an empty list                    }
{	_in_list : ground : list [...,_x,...]                               }
{	_list1 : any : a list                                               }
{	_list2 : any : a list                                               }
{                                                                           }
{ The predicate _functor(_x,_arg1,...,_argn) is applied to each  element  _x}
{ of the input list _in_list. If the predicate succeeds,_x is placeed in the}
{ list _list1, otherwise in the list _list2.If the predicate is defined in a}
{ module, which uses the module directive,the functor must be qualified with}
{ the module name or the predicate must be declared global.                 }
{                                                                           }
{***************************************************************************}

split_list(_functor,_functor_args,_in_list,_list1,_list2):-
	atom(_functor),
	is_list(_functor_args),
	_pred =.. [_functor,_|_functor_args],
	pc_has_a_definition(_pred),
	split_list1(_functor,_functor_args,_in_list,_list1,_list2).


split_list1(_functor,_functor_args,[_head|_tail],[_head|_tail1],_list2):-
	_predicate =.. [_functor,_head|_functor_args],
	_predicate,
	!,
	split_list1(_functor,_functor_args,_tail,_tail1,_list2).

split_list1(_functor,_functor_args,[_head|_tail],_list1,[_head|_tail2]):-
	split_list1(_functor,_functor_args,_tail,_list1,_tail2).

split_list1(_,_,[],[],[]).


{********************************* id2name *******************************}
{ id2name/2								    }
{									    }
{	arg1 : any							    }
{	arg2 : ground : atom						    }
{									    }
{***************************************************************************}

id2name_list([],[]).
id2name_list([_id|_t],[_name|_nt])  :- id2name(_id,_name),!, id2name_list(_t,_nt).

id2name(_id,_name) :-
              id2name_bim2c(_id,_name),!.

{********************************* id2uniquename ***************************}
{ id2uniquename/2						            }
{									    }
{	arg1 : ground :any							    }
{	arg2 : var : any						    }
{									}
{ Returns unique name  for a given id.	    }
{ In case an id has a name which is'nt unique in the current module context, id2uniquename }
{ returns  name@module  as a unique name }
{***************************************************************************}

id2uniquename([],[]).

id2uniquename([_h|_t],[_nh|_nt]) :-
	id2uniquename(_h,_nh),
	id2uniquename(_t,_nt).

id2uniquename(_id,_l) :-
	id2uniquename_wbt(_id,_l),!.

id2uniquename_wbt(_id,'*instanceof') :-		{ 10-May-1995 LWEB just return '*instanceof' cause this label is NOT unique }
	id2name(_id,_l),
	_l = '*instanceof'.

id2uniquename_wbt(_id,'*isa') :-			{ 10-May-1995 LWEB just return '*isa' cause this label is NOT unique }
	id2name(_id,_l),
	_l = '*isa'.

id2uniquename_wbt(_id,_l) :-			{ 26-May-1995 LWEB attribute names needn't be unique }
	retrieve_proposition(P(_id,_s,_l,_d)),
	_s \== _id,
        _d \== _id.

id2uniquename_wbt(_id,_uniquename) :-		{ name is unique if name2allid returns just one id }
	id2name(_id,_uniquename),
	name2allid(_uniquename,[_]).

id2uniquename_wbt(_id,_uniquename) :-
	id2name(_id,_name),
	_name \== '*instanceof',
	_name \== '*isa',
	get_module_name(_id,_modname),
	pc_atomconcat([_name,'@',_modname], _uniquename).

{********************************** name2id ********************************}
{ star_name2id/2							    }
{									    }
{	arg1 : ground : atom						    }
{	arg2 : any							    }
{									    }
{***************************************************************************}

star_name2id(_name,_id) :-
        star_name2id_bim2c(_name,_id).

{********************************* name2id *******************************}
{ name2id/2  								    }
{									    }
{	arg1 : any							    }
{	arg2 : ground : atom						    }
{									    }
{  	t_name2id/3  ist ein name2id mit vorgegebenen Modulkontext (muss ground sein)   }
{***************************************************************************}



name2id(_l,_l) :- 	var(_l),!.

name2id(select(_l,'@',_mod),_id)	:-	{ write('name2id_select'),nl, }
			M_SearchSpace(_m),t_name2id('silent',_m,select(_l,'@',_mod),_id),!.

name2id(_l,_id)	:-	name2id_bim2c(_l,_id),!.




{* t_name2id(_m,_n,_id) is called in parseAss.dcg. By default, it produces no error message when n is not *}
{* a known object name (use 'silent').  You can also use t_name2id('errorreport',_m,_name,_id) to force   *}
{* an error report when n does not exist. Issue #32.                                                      *}


t_name2id(_m,_name,_id) :-
  t_name2id('silent',_m,_name,_id).  {* also used in parseAss *}




t_name2id(_,_,_l,_l) :- 	var(_l),!.			{ _l   is not unified at all }


t_name2id(_,_,Attribute,id_6) :- !.  {* id_6=Proposition!attribute *}

t_name2id(_,_,InstanceOf,id_1) :- !.  {* id_1=InstanceOf *}

t_name2id(_,_,IsA,id_15) :- !.        {* id_15=IsA *}

t_name2id(_,_,Single,_id):-
   select2id('Proposition!single',_id),!.

t_name2id(_,_,Necessary,_id):-
   select2id('Proposition!necessary',_id),!.

t_name2id(_,_,select(_l,'@',_mod),_id):-
	name2id(_mod,_modid),
	retrieve_proposition(_modid,P(_id,_,_l,_)),!.

t_name2id(_,_,_id,_id):- 			{ 25-Apr-1996 LWEB }
	atom(_id),
        is_id(_id), {* pc_atomconcat('id_',_,_id), *}
 	!.	{ _l  is a TOID already }

t_name2id(_,_m,_l,_id):-				{ search for the TOID of label _l }
		var(_id),
		atom(_m),
		retrieve_proposition(_m,P(_id,_id,_l,_id)),!.

t_name2id(_,_m,_l,_id):-
		atom(_id),
                callExactlyOnce(is_id(_id)),
{*		callExactlyOnce((pc_atomconcat('id_',_,_id))), *}
		retrieve_proposition_noimport(_m,P(_id,_id,_l,_id)),!.

{* parameterized query calls can occur as arguments of other parameterized query calls *}
t_name2id(_,_m,_l,_call):-
                compound(_call),
                _call =.. [_id|_args],
                callExactlyOnce(is_id(_id)),
{*		callExactlyOnce((pc_atomconcat('id_',_,_id))), *}
		retrieve_proposition_noimport(_m,P(_id,_id,_l,_id)),!.


{* mode 'errorreport': report error when object with name _l does not exist *}
t_name2id('errorreport',_m,_l,_id) :-
  atom(_l),
  var(_id),
  \+ is_id(_l),
  \+ pc_atomconcat('$',_,_l),
  report_error(PFNFE,GeneralUtilities,[_l]),
  !,
  fail.


{********************************* name2allid *******************************}
{ name2allid/2								    }
{									    }
{	arg1 : any							    }
{	arg2 : ground : list						    }
{									    }
{	liefert alle id's der P-Tupel zurueck, die im Sichtbarkeitsbereich des }
{	aktuellen Moduls arg1 in der Label-Komponente haben }
{***************************************************************************}

name2allid(_l,_idlist) :-					{ 5-Jul-1995 LWEB }
	M_SearchSpace(_m),
	save_setof(_id,  t_name2id('silent',_m,_l,_id)  , _idlist).

{********************************* name2allid *******************************}
{ name2id_list/2								    }
{									    }
{	arg1 : list							    }
{	arg2 : list						    }
{									    }
{***************************************************************************}

name2id_list([],[]).
name2id_list([_name|_nt],[_id|_t])  :- name2id(_name,_id),!, name2id_list(_nt,_t).

{********************************* select2id *******************************}
{ select2id/2								    }
{									    }
{	arg1 : any							    }
{	arg2 : ground : atom						    }
{									    }
{***************************************************************************}

{* ticket #281: save Prolog method for evaluation select expressions like bill!bname *}
select2id(_name,_id) :-
   atom(_name),
   pc_atomtolist(_name,_charlist),
   buildTokens(_tokens,_charlist,[]),
   convertSelectExpression(_id,_tokens,[]),
   !.

{* if the Prolog method fails, we try the C-method though this case should never occur *}
select2id(_name,_id) :-
   select2id_bim2c(_name,_id),  {* select2id_bim2c is not module-aware; ticket #281 *}
   write('!!! GeneralUtilities: Unexpected call of ' ),write(select2id_bim2c(_name,_id)),nl,
   !.


{ ================== }
{ Private predicates }
{ ================== }


{*****************************************************************************}
{  opListtoTerm (_list,_term)
   _list  ground,list of atoms
   _term   free
   creates from the inputlist _list = [identifier,select_symbol,identifier,...]
   a term of the form :
   select(select(...select(identifier,select_symbol,identifier)select_symbol...)
   This predicate is used by the file LanguageUtilities.pro.
    7-Jul-1992: made it faster by using an accumulator
}

 opListtoTerm([_x,_selectop,_y|_rest],_term) :-
	opListtoTerm(_rest,_term,select(_x,_selectop,_y)).

opListtoTerm([],_akku,_akku).
opListtoTerm([_selectop,_y |_ys],_term ,_akku) :-
	opListtoTerm(_ys, _term , select(_akku,_selectop,_y)).


{***************************************************************************}
{  reverseListtoTerm (_list,_term)
   _list  ground,list of atoms
   _term  free,atom
   creates a term described in opListtoTerm, but the inputlist _list
   is the reverselist of the list in opListtoTerm.
****************************************************************************}

reverseListtoTerm([_ident1,_selectSymbol,_ident2],
                              select(_ident2,_selectSymbol,_ident1)) :-!.



reverseListtoTerm([_identifier,_selectSymbol|_tail],
                             select(_rest,_selectSymbol,_identifier)) :-
                  reverseListtoTerm(_tail,_rest).


{*  29-Jun-1992 kvt faster Version of reverse with Akkumulator *}
reverse(_xs,_ys) :- reverse(_xs,_ys,[]).
reverse([],_akku,_akku).
reverse([_x|_xs],_ys,_akku) :- reverse(_xs,_ys,[_x|_akku]).


{****************************** w r i t e l n *********************************}
{									       }
{						14-Aug-1990 / AK (UPA)         }
{      writeListLn(_list)                                                          }
{        _list : ground                                                        }
{									       }
{ writeListLn/1 prints all the elements of _list with write/1 to the current output}
{ stream. The output will be terminated with nl/0.                             }
{									       }
{******************************************************************************}

writeListLn([]) :- !, nl.

writeListLn(_atom) :-
  atom(_atom),
  write(_atom),
  nl,
  !.

writeListLn([_string|_rest]):-
	write(_string),
	writeListLn(_rest).

{ ****************** m e t a I n s t a n c e O f ****************** }
{                                                   9-Feb-1990/MJf  }
{ metaIn(_x,_c,_dir,_depth)                                 }
{   _x: any: ground                                                 }
{   _c: any: ground                                                 }
{   _dir: atom (going_into or coming_out_of)                        }
{   _depth: integer                                                 }
{                                                                   }
{ Succeeds if _x is _depth instantiation relationships below (above }
{ in the case of _dir=going_into) the object _c.                    }
{                                                                   }
{   x ---> c1 ---> ... ---> c                                       }
{             (depth times)                                         }
{                                                                   }
{                                                                   }
{ Changes :							    }
{                                                                   }
{ metaIn/4 was originally placed in BuiltinQueries.pro .    }
{ The cut in the 5th clause was set in comment brackets, because the}
{ execution could not terminate, if var(_c) and ground(_x) hold.Fur-}
{ thermore, the 3rd clause tests now, whether _c is ground and _x is}
{ free. Thus, at least one of the arguments _x or _c must be instan-}
{ ciated. The 2nd, 3rd, and 4th clauses are added for efficiency im-}
{ provements.							    }
{ --1900 / AK (UPA)						    }
{                                                                   }
{ ***************************************************************** }

metaIn(_x,_x,_,0) :- !.

metaIn(_x,_c,coming_out_of,1) :-
  ground(_x),
  prove_literal(In(_x,_c)).

metaIn(_x,_c,coming_out_of,2) :-
  ground(_x),
  prove_literal(In(_x,_c1)),
  prove_literal(In(_c1,_c)).

metaIn(_x,_c,coming_out_of,3) :-
  ground(_x),
  prove_literal(In(_x,_c1)),
  prove_literal(In(_c1,_c2)),
  prove_literal(In(_c2,_c)).

metaIn(_x,_c,coming_out_of,_depth) :-
  _depth>3,
  ground(_x),
  {!,}
  prove_literal(In(_x,_c1)),
  _depth1 is _depth-1,
  metaIn(_c1,_c,coming_out_of,_depth1).

metaIn(_x,_c,coming_out_of,_depth) :-
  _depth>0,
  ground(_c),
  var(_x),
  _depth1 is _depth-1,
  metaIn(_c1,_c,coming_out_of,_depth1),
  prove_literal(In(_x,_c1)).

metaIn(_c,_x,going_into,_depth) :-
  metaIn(_x,_c,coming_out_of,_depth).


{******************* m e t a I n _ f i r s t _ f i t *****************}
{									       }
{						--1990 / AK (UPA)         }
{									       }
{ metaIn_first_fit(_x,_classes,_dir,_depth,_c)                         }
{	_x : ground : ConceptBase object				       }
{	_classes : ground : a list of ConceptBase classes [...,_c,...]         }
{	_dir : ground : a member of [going_into,coming_out_of]		       }
{	_depth : ground : integer					       }
{	_c : ground : a ConceptBase class				       }
{									       }
{ _c is the first element in the list of classes _classes for  witch  the  call}
{ metaIn(_x,_c,_dir,_depth) succeeds. If this is not the case  for  any}
{ class in the list _classes, _c will be instanciated with  the  default  value}
{ 'Proposition'.							       }
{									       }
{******************************************************************************}



metaIn_first_fit(_x,[],_dir,_depth,Proposition).

metaIn_first_fit(_x,[_c|_],_dir,_depth,_c):-
	metaIn(_x,_c,_dir,_depth),
	!.

metaIn_first_fit(_x,[_|_classes],_dir,_depth,_c):-
	metaIn_first_fit(_x,_classes,_dir,_depth,_c).



{ ************************** r e w r i t e _ t e r m ************************* }
{                                                              06-Nov-90 MSt   }
{	rewrite_term ( _term , _rterm )                                        }
{		_term : ground                                                 }
{		_rterm : free                                                  }
{									       }
{	any PROLOG term _term is rewritten to _rterm where each atom in        }
{	_term preceded by an underscore '_' is replaced by an unique           }
{	uninstantiated PROLOG variable.                                        }
{	Example:   d('_a',t('_b','_a')) is transformed to                      }
{		   d(_23,t(_24,_23))                                           }
{									       }
{ **************************************************************************** }


rewrite_term(_t,_nt) :-
        compound(_t),
	_t =..[_f|_args],
	rewrite_args(_args,_nargs,[],_),
	_nt =..[_f|_nargs].

rewrite_args([],[],_t,_t).

rewrite_args([_f|_r],[_nf|_nr],_vartab,_nnvartab) :-
	replace_arg(_f,_nf,_vartab,_nvartab),
	rewrite_args(_r,_nr,_nvartab,_nnvartab).


replace_arg(_f,_v,_tab,_tab) :-
	_f \== '_',
	member(v(_f,_v),_tab),!.

replace_arg(_f,_nf,_tab,_ntab) :-
        compound(_f),
	_f =..[_functor|_args],
	_args \== [],
	rewrite_args(_args,_nargs,_tab,_ntab),
	_nf =..[_functor|_nargs],!.

replace_arg(_f,_v,_tab,[v(_f,_v)|_tab]) :-
	variable(_f),!.

replace_arg(_f,_f,_tab,_tab) :-
	atom(_f),!.

replace_arg(_f,_f,_tab,_tab) :-
	integer(_f),!.

variable(_f) :-
        atom(_f),
	pc_atomprefix('_',1,_f).




{ **************************    atom2list    ************************* }
{							31.10.92 RG      }
{									       }
{ Just like pc_atomtolist of BIMprolog but without the bug of producing non atoms }
{									       }
{ **************************************************************************** }

atom2list( _a, _l ) :-
	var( _a ),
	!,
	a2l( _a, _l ).

atom2list( _a, _l ) :-
        atom(_a),
	pc_atomtolist( _a, _l ).


a2l('',[]) :- !.

a2l(_a,[_f|_r]) :-
        a2l(_b,_r),
        atom(_f),
        pc_atomconcat(_f,_b,_a).


{***********************************************************}
{* atom2term(_atom,_term)                                  *}
{*                                                         *}
{* type conversion between atoms and terms under           *}
{* consideration of single quotes. This predicate works in *}
{* both directions.                                        *}
{***********************************************************}

atom2term(_atom,_term) :-
	atom(_atom),
	!,
	pc_atom_to_term(_atom,_term).


atom2term(_atom,_term) :-
	pc_swriteQuotes(_atom,_term).


{***********************************************************}
{* insertPROLOGVars(_t1,_t2)                               *}
{* takes a clause and replaces atoms of the form '_x' by a *}
{* ProLog-variable. It is presently implemented with a     *}
{* dirty pc_atom_to_term/pc_atom_to_term combination                          *}
{***********************************************************}

insertPROLOGVars(_nterm,_nterm2) :-
	DIRTY_DATATYPE_WORKAROUND(_nterm,_DIRTYterm),
	pc_atom_to_term(_at,_DIRTYterm),
	pc_atom_to_term(_at,_nterm2).

{* local predicates for insertPROLOGVars *}

DIRTY_DATATYPE_WORKAROUND(_term,_nterm) :-
        compound(_term),
	_term =.. [_fun|_args],
	DDW_REPLACE_ARGS(_args,_nargs),
	_nterm =.. [_fun|_nargs].

{* map DDW_RELACE_ARG to each element of the list
*}

DDW_REPLACE_ARGS([],[]).

DDW_REPLACE_ARGS([_arg|_args],[_narg|_nargs]) :-
	DDW_REPLACE_ARG(_arg,_narg),
	DDW_REPLACE_ARGS(_args,_nargs).

{* If the arg is a BIMstring (i.e. a list of ascii numbers) it is converted to the double quoted atom ''"String"''
*}
DDW_REPLACE_ARG(_arg,_narg) :-
	bimstring(_arg),
	!,
	BimstringToString(_arg,_charlist),
	atom2list(_atom,_charlist),
	pc_atomconcat(['\'','"',_atom,'"','\''],_narg).

{* If arg is an Integer it is converted to a double quoted atom ''integer''
*}
DDW_REPLACE_ARG(_arg,_narg) :-
	integer(_arg),
	!,
	pc_inttoatom(_arg,_atom),
	DDW_REPLACE_ARG(_atom,_narg).

{* do the same with reals
*}
DDW_REPLACE_ARG(_arg,_narg) :-
	float(_arg),
	!,
	pc_floattoatom(_arg,_atom),
	DDW_REPLACE_ARG(_atom,_narg).

DDW_REPLACE_ARG(_arg,_arg) :-
	atom(_arg),
	pc_atomprefix('_',1,_arg),
	!.

{* if arg is already an atom add additional quotes if necessary. This is the case if the atom contains e.g. blanks *}

DDW_REPLACE_ARG(_arg,_narg) :-
	atom(_arg),
	!,
	atom2term(_narg,_arg).


DDW_REPLACE_ARG(_arg,_narg) :-
	functor(_arg,_,_arity),
	_arity > 0,
	DIRTY_DATATYPE_WORKAROUND(_arg,_narg).

DDW_REPLACE_ARG(_arg,_arg).



{***********************************************************}
{* uniqueAtom(_xA)                                       *}
{*                                                         *}
{* liefert eine einzigartiges Atom zurueck                 *}
{* entspricht assign_ID$validProposition.pro nur mit under *}
{* score als Trennzeichen                                  *}
{***********************************************************}

uniqueAtom(_ID) :-
	getFlag(Session_id,_prefix),
	getFlag(ID_counter,_i),
	pc_atomconcat([_prefix,'_',_i],_ID),
	_i1 is _i+1,
	setFlag(ID_counter,_i1),
	!.


{***********************************************************}
{* replaceCString(_list,_atomlist)			   *}
{*                                                         *}
{* Ersetzt in _list alle C-Strings (Pointer) durch die     *}
{* entsprechenden Atome	/CQ 11-1-95			   *}
{*                                                         *}
{***********************************************************}

replaceCString([],[]):-!.

replaceCString([_p|_rest],[_a|_newrest]) :-
	pc_pointer(_p),
	pc_stringtoatom(_p,_a),
	!,
	replaceCString(_rest,_newrest).

replaceCString([_a|_rest],[_a|_newrest]) :-
	replaceCString(_rest,_newrest).




{***********************************************************}
{* ident_in_atom(_ident,_atom)                             *}
{*                                                         *}
{* Erfolgreich, _ident als separater Identifier in _atom   *}
{* enthalten ist. Zur Definition eines Identifiers         *}
{* s. tokens.dcg                                           *}
{*                                                         *}
{***********************************************************}

ident_in_atom(_ident,_atom) :-
	pc_atomtolist(_ident,_l1),
	pc_atomtolist(_atom,_l2),
	subseq0(_l2,_l1),
	ident_in_atom2(_l1,[' '|_l2]),
	!.

ident_in_atom2(_identlist,[_x|_xs]) :-
	\+(ident_char(_x)),
	(append(_identlist,[],_xs);
	 (append(_identlist,[_y|_ys],_xs),
	  \+(ident_char(_y))
	 )
	).

ident_in_atom2(_identlist,[_x|_xs]) :-
	ident_in_atom2(_identlist,_xs).




{******************************************************************************}
{   ident_char(_c)                                                             }
{      (wird von replace_scope_res_in_assertion benutzt)                       }
{                                                                              }
{   Wahr, wenn _c ein Zeichen ist, das in einem Identifier vorkommen kann.     }
{   (vgl. tokens.dcg)                                                          }
{                                                                              }
{******************************************************************************}

ident_char(_c) :-
	 'a' @=< _c, _c @=< 'z'.

ident_char(_c) :-
	 'A' @=< _c, _c @=< 'Z'.

ident_char(_c) :-
	 '0' @=< _c, _c @=< '9'.

ident_char('_').




{*******************************************************************}
{* split_atom(_atom,_splitatom,_part1,_part2)                      *}
{*                                                                 *}
{* Spaltet ein Atom in zwei Teile (part1, part2), die in atom durch*}
{* splitatom getrennt waren. splitatom ist *nicht* Suffix von      *}
{* part1 oder Prefix von part2.                                    *}
{* es gilt also: pc_atomconcat([_part1,_splitatom,_part2],_atom)      *}
{*                                                                 *}
{*******************************************************************}

split_atom(_atom,_split,_part1,_part2) :-
	pc_atompartsall(_atom,_split,_pos),
	atom_length(_atom,_atomlen),
	atom_length(_split,_splitlen),
	_rlen is _atomlen + _splitlen - _pos - 1 ,
	_pos1 is _pos + _splitlen,
	pc_atompart(_atom,_part2,_pos1,_rlen),
	pc_atomconcat(_a,_part2,_atom),
	pc_atomconcat(_part1,_split,_a).


        {******************************************************}
        {* intersect(i_Set1, i_Set2, ?_Intersection)          *}
	{* urspruenglich definiert in BIM Library sets		*}
        {* is true when Intersection is the intersection      *}
        {* of Set1 and Set2, *taken in a particular order*.   *}
        {* In fact it is precisely the elements of Set1       *}
        {* taken in that order, with elements not in Set2     *}
        {* deleted.  If Set1 contains duplicates, so may      *}
        {* Intersection. This routine is due to Peter Ross    *}
        {* and avoids the problem that in the (otherwise)     *}
        {* obvious definition,                                *}
        {* ?- intersection([a,b,c],[a,b,c],[c]) will succeed. *}
        {******************************************************}

intersect([], _, []).
intersect([_Element|_Residue], _Set, _Result) :-
	member(_Element, _Set),
	!,
	_Result = [_Element|_Intersection],
	intersect(_Residue, _Set, _Intersection).
intersect([_|_Rest], _Set, _Intersection) :-
	intersect(_Rest, _Set, _Intersection).


        {**********************************************}
        {* subtract(i_Set1, i_Set2, ?_Difference)     *}
        {* is like intersect, but this time it is the *}
        {* elements of Set1 which *are* in Set2 that  *}
        {* are deleted.                               *}
        {**********************************************}

subtract([], _, []).
subtract([_Element|_Residue], _Set, _Difference) :-
	memberchk(_Element, _Set),
        !,
	subtract(_Residue, _Set, _Difference).
subtract([_Element|_Residue], _Set, [_Element|_Difference]) :-
	subtract(_Residue, _Set, _Difference).


        {********************************************************}
        {* subseq0(_Sequence, _SubSequence)                     *}
        {* is true when _SubSequence is a subsequence           *}
        {* of _Sequence, but may be _Sequence itself.           *}
        {* Thus subseq0([a,b], [a,b]) is true as well           *}
        {* as subseq0([a,b], [a]).                              *}
        {*                                                      *}
        {* subseq1(_Sequence, _SubSequence)                     *}
        {* is true when _SubSequence is a proper                *}
        {* subsequence of _Sequence, that is it                 *}
        {* contains at least one element less.                  *}
        {*                                                      *}
        {* ?- setof(_X, subseq0([a,b,c],_X), _Xs).              *}
        {* _Xs = [[],[a],[a,b],[a,b,c],[a,c],[b],[b,c],[c]]     *}
        {* ?- bagof(_X, subseq0([a,b,c,d],_X), _Xs).            *}
        {* _Xs = [[a,b,c,d],[b,c,d],[c,d],[d],[],[c],           *}
        {*        [b,d],[b],[b,c],[a,c,d],                      *}
        {*        [a,d],[a],[a,c],[a,b,d],[a,b],[a,b,c]]        *}
        {********************************************************}

subseq0(_List, _List).
subseq0(_List, _Rest) :-
	subseq1(_List, _Rest).

subseq1([_|_Tail], _Rest) :-
	subseq0(_Tail, _Rest).
subseq1([_Head|_Tail], [_Head|_Rest]) :-
	subseq1(_Tail, _Rest).


        {*******************************************************}
        {* last(_Last, _List)                                  *}
        {* is true when _List is a _List and _Last is its last *}
        {* element.  This could be defined as                  *}
        {* last(_X,_L) :- append(_, [_X], _L).                 *}
        {*******************************************************}

last(_Last, [_Last]) :-
        !.
last(_Last, [_|_List]) :-
	last(_Last, _List).





{*******************************************}
{* save_stringtoatom/2          19-01-96/CQ*}
{*                                         *}
{* Konvertiert Pointer auf C-String in ein *}
{* Prolog-Atom ohne Warnmeldung bei zu     *}
{* grossen Atomen auszugeben.              *}
{* (nur noetig, wo auch grosse Atome vor-  *}
{* kommen koennen)                         *}
{*                                         *}
{*******************************************}

save_stringtoatom(_cstr,_atom) :-
	pc_error_message(540,off),
	pc_stringtoatom(_cstr,_atom),
	pc_error_message(540,on),
	!.

save_stringtoatom(_cstr,'(String too long)') :- !.


        {************************************************************}
        {* nth0(i_N, i_List, ?_Elem) is true when _Elem is the      *}
        {* _Nth member of _List, counting the first as element 0.   *}
        {* (That is, throw away the first _N elements and unify     *}
        {* _Elem with the next.)  It can only be used to select     *}
        {* a particular element given the list and index. For that  *}
        {* task it is more efficient than nmember.                  *}
        {* nth1(i_N, i_List, ?_Elem) is the same as nth0,           *}
        {* except that it counts from 1, that is nth(1,[_H|_],_H).  *}
        {************************************************************}

nth0(0, [_Head|_], _Head) :- !.
nth0(_N, [_|_Tail], _Elem) :-
	nonvar(_N),
	_M is _N - 1 ,
	nth0(_M, _Tail, _Elem).

nth1(1, [_Head|_], _Head) :- !.
nth1(_N, [_|_Tail], _Elem) :-
	nonvar(_N),
	_M is _N - 1,
	nth1(_M, _Tail, _Elem).

        {************************************************************}
        {* nth0(i_N, ?_List, ?_Elem, ?_Rest) unifies _Elem with     *}
        {* the _Nth element of _List, counting from 0, and _Rest    *}
        {* with the other elements.  It can be used to select       *}
        {* the _Nth element of _List (yielding _Elem and _Rest),    *}
        {* or to insert _Elem before the _Nth (counting from 1)     *}
        {* element of _Rest, when it yields _List,                  *}
        {* e.g. nth0(2, _List, c, [a,b,d,e])                        *}
        {* unifies _List with [a,b,c,d,e].  nth1 is the same        *}
        {* except that it counts from 1. nth1 can be used to        *}
        {* insert _Elem after the _Nth element of _Rest.            *}
        {************************************************************}

nth0(0, [_Head|_Tail], _Head, _Tail) :- !.
nth0(_N, [_Head|_Tail], _Elem, [_Head|_Rest]) :-
	nonvar(_N),
	_M is _N - 1,
	nth0(_M, _Tail, _Elem, _Rest).

nth1(1, [_Head|_Tail], _Head, _Tail) :-
        !.
nth1(_N, [_Head|_Tail], _Elem, [_Head|_Rest]) :-
	nonvar(_N),
	_M is _N - 1,
	nth1(_M, _Tail, _Elem, _Rest).


        {************************************************************}
        {* nmember(_Elem, _List, _Index) Possible Calling Sequences *}
        {* nmember(i,i,-) or nmember(-,i,i) or nmember(o,i,-).      *}
        {* True when _Elem is the _Indexth member of _List.         *}
        {* It may be used to select a particular element, or to     *}
        {* find where some given element occurs, or to enumerate    *}
        {* the elements and indices togther.                        *}
        {************************************************************}

nmember(_Elem, [_Head|_Tail], _Count) :-
        nmember(_Elem, _Head, _Tail, 1, _Count).

#MODE( nmember(?, ?, i, i, ?))


nmember(_Elem, _Elem, _, _Count, _Count).
nmember(_Elem, _, [_Head|_Tail], _CSoFar, _Count):-
        _sofar is _CSoFar + 1,
        nmember(_Elem, _Head, _Tail, _sofar , _Count).

        {**************************************************************}
        {* nmembers(i_Indices, i_Answers, -_Ans) or                   *}
        {* nmembers(-_Indices, i_Answers, i_Ans) (But not             *}
        {* nmembers(-,+,-), it loops.) Like nmember/3                 *}
        {* except that it looks for a list of arguments in            *}
        {* a list of positions.                                       *}
        {* eg. nmembers([3,5,1], [a,b,c,d,e,f,g,h], [c,e,a]) is true  *}
        {**************************************************************}

nmembers([], _, []) .
nmembers([_N|_Rest], _Answers, [_Ans|_RestAns]) :-
        nmember(_Ans, _Answers, _N),
        nmembers(_Rest, _Answers, _RestAns).



{ aus BIM_PROLOG_DIR/src/prolog/terms/struct.pro }
{**********************************************************************}
{* subst(Substitution, Term, Result) applies a substitution, where    *}
{* <substitution> ::= <OldTerm> = <NewTerm>                           *}
{*          |  <Substitution> & <Substitution>                        *}
{*          |  <Substitution> # <Substitution>                        *}
{* The last two possibilities only make sense when the input Term is  *}
{* an equation, and the substitution is a set of solutions.  The      *}
{* "conjunction" of substitutions really refers to back-substitution, *}
{* and the order in which the substitutions are done may be crucial.  *}
{* If the substitution is ill-formed, and only then, subst will fail. *}
{**********************************************************************}
:- op(950,xfy,'#').                     {* Used for disjunction *}
:- op(920,xfy,'&').                     {* Used for conjunction *}

subst((_Subst1 & _Subst2), _Old, _New) :-
        subst(_Subst1, _Old, _Mid), !,
        subst(_Subst2, _Mid, _New).
subst((_Subst1 # _Subst2), _Old, (_New1 # _New2)) :-
        subst(_Subst1, _Old, _New1), !,
        subst(_Subst2, _Old, _New2).
subst((_Lhs = _Rhs), _Old, _New) :- !,
        subst(_Lhs, _Rhs, _Old, _New).
subst(true, _Old, _Old).


subst(_Lhs, _Rhs, _Old, _Rhs) :-
	_Old == _Lhs,
	!.
subst(_, _, _Old, _Old) :-
    var(_Old),
    !.
subst(_Lhs, _Rhs, _Old, _New) :-
    functor(_Old, _Functor, _Arity),
    functor(_New, _Functor, _Arity),
    subst(_Arity, _Lhs, _Rhs, _Old, _New).


subst(0, _, _, _, _) :- !.
subst(_N, _Lhs, _Rhs, _Old, _New) :-
    arg(_N, _Old, _OldArg),
    subst(_Lhs, _Rhs, _OldArg, _NewArg),
    arg(_N, _New, _NewArg),
    _M is _N-1,
    !,
    subst(_M, _Lhs, _Rhs, _Old, _New).



{*******************************************************************}
{                                                                   }
{ find_max(_ids,_maxid)                                             }
{                                                                   }
{ Description of arguments:                                         }
{     ids : Liste von IDs (ground)                                  }
{   maxid : groesstes Objekt                                        }
{                                                                   }
{ Description of predicate:                                         }
{  Sucht in einer Liste von OIDs das groesste Objekt heraus.        }
{*******************************************************************}

#MODE((find_max(i,o)))


find_max([_id1|_ids],_maxid) :-
	find_max(_id1,_ids,_maxid).

find_max(_id,[],_id).

find_max(_id1,[_id2|_ids],_maxid) :-
	prove_literal(GE(_id1,_id2)),
	!,
	find_max(_id1,_ids,_maxid).

find_max(_id1,[_id2|_ids],_maxid) :-
	find_max(_id2,_ids,_maxid).




{*******************************************************************}
{                                                                   }
{ find_min(_ids,_minid)                                             }
{                                                                   }
{ Description of arguments:                                         }
{     ids : Liste von IDs (ground)                                  }
{   minid : groesstes Objekt                                        }
{                                                                   }
{ Description of predicate:                                         }
{  Sucht in einer Liste von OIDs das groesste Objekt heraus.        }
{*******************************************************************}

#MODE((find_min(i,o)))


find_min([_id1|_ids],_minid) :-
	find_min(_id1,_ids,_minid).

find_min(_id,[],_id).

find_min(_id1,[_id2|_ids],_minid) :-
	prove_literal(LE(_id1,_id2)),
	!,
	find_min(_id1,_ids,_minid).

find_min(_id1,[_id2|_ids],_minid) :-
	find_min(_id2,_ids,_minid).




{ Die externen Quellen konnten ein anderes Syntax haben, z.B. in CB ist es nicht erlaubt Attribute-Namen als 'ID Nr' einzugeben, oder
wenn einige Sonderzeichenen in 'Label' vorkommen, dann werden Probleme auftreten, wenn wir die Attribute-Namen aus extetrn, wie 'Wang@rwth'
in CB uebernehmen.
Eine Abhilfe ist:
Alle Attribute-Namen werden aus externen Quellen mit Hochkomma geklammert, d.h. 'ID Nr'==>"ID Nr",
denn CB erlaubt Attribute-Namen in Stringformat zu definieren.
Aber trotzdem haben wir  noch Problem:
Bei Generieren der Regeln oder Ruleinfos werden Atom wie vm_id_2222_Label,_qvar_Label,_at_Label...konstruiert,
dann wenn diese Labels ein Atom mit Hochkomma sind, wie "ID Nr", werden pc_atom_to_term() und pc_atom_to_term()   mit solche konstruierten Ids und Variabeln
failschlagen, z.B. vm_id_2222_"ID Nr". Also Hochkomma erzeugt Problem bei Generierung der Rules,Ruleinfos!

Deswegen werden alle Labels bei solche Kombination mit einer eindeutigen id_???? ersetzen.
Hier unterscheiden wir zwei Faelle:
1) wenn das Label in Kombinationen wie: id_2222_Label, oder vm_id_2222_Label steht, dann wird das Label durch seine Id in CB ersetzt.
2) wenn das Label in Kombinationen wie: _qvar_Label_label,_qvar_Label oder _at_Label steht, dann wird eine neue Id dafuer erzeugt,
denn die Quelle des Labels nicht bekannt ist, und wieterhin wird es bei dieser Kombination  nur Variablen generiert,
ist es egal was die Labels ersetzt wird.}

{ Fuer die Faelle, dass die Kombinationen Ids sind.}
convert_label(_quelleID,_label,_convert_label):-
!,
id2name(_quelleID,_quelle),
eval(select(_quelle,'!',_label),replaceSelectExpression,_convert_label).

{ID fuer diese Label schon generiert!}
convert_label(_label,_convert_label):-
pc_recorded(_label,'Label_conversion',_convert_label),
!.

{Zuerstmal generieren eine ID fuer diese Label!}
convert_label(_label,_new_label):-
uniqueAtom(_new_label),
!,
pc_record(_label,'Label_conversion',_new_label).



{*****************************************************}
{ Praedikate zur Bestimmung des Betriebssystems	      }
{*****************************************************}

getCBVariant(_var) :-
    getenv('CB_VARIANT',_var),
    !.

operatingSystemIsWindows :-
	getCBVariant(windows),
	!.


operatingSystemIsLinux :-
	getCBVariant(linux),
	!.


operatingSystemIsSolaris :-
	getCBVariant(_val),
	(_val = sun4;_val = i86pc),
	!.


{* 29-Oct-2004/M.Jeusfeld: define getGraphType as static Prolog procedure *}

getGraphType([_result],_oid,_palid) :-
    getGraphTypeCandidates(_gtlist,_palid),
    lastMatchGT(_gtlist,_oid,_gtid1),
    !,
    id2name(_gtid1,_r),
    appendBuffer(_result,'    <graphtype>'),
    appendBuffer(_result,_r),
    appendBuffer(_result,'</graphtype>\n'),
    !.

getGraphType([''],_oid,_palid).

getGraphTypeCandidates(_gtlist,_palid) :-
  pc_recorded(_palid,GRAPHTYPECANDIDATES,_gtlist),
  !.
getGraphTypeCandidates(_gtlist,_palid) :-
  setof((_pr,_gtid),
        [_pra,_prid]^(
         prove_literal(Adot(id_879,_palid,_gtid)),     {* id_879=GraphicalPalette!contains *}
         prove_literal(Adot(id_886,_gtid,_prid)),     {* id_886=JavaGraphicalType!priority *}
         id2name(_prid,_pra),
         pc_inttoatom(_pr,_pra)
        ),_gtlist),
   pc_record(_palid,GRAPHTYPECANDIDATES,_gtlist),
  !.


lastMatchGT([(_prio,_gtid)],_oid,_gtid) :-
  prove_literal(Adot(id_876,_oid,_gtid)),   {* id_876=Proposition!graphtype *}
  !.
lastMatchGT([_x|_rest],_oid,_gtid) :-
  lastMatchGT(_rest,_oid,_gtid).
lastMatchGT([(_prio,_gtid)|_rest],_oid,_gtid) :-
  prove_literal(Adot(id_876,_oid,_gtid)),   {* id_876=Proposition!graphtype *}
  !.


{* for gproperties, ticket #397 *}
appendGproperties(_buf,_oid) :-
   findall((_name,_value), gProperty(_oid,_name,_value),_propertylist),
   addPropertyList(_buf,_propertylist),
   !.
appendGproperties('',_oid).


addPropertyList(_buf,[]) :- !.
addPropertyList(_buf,[(_n,_v)|_rest]) :-
    appendBuffer(_buf,'    <gproperty>\n'),
    appendBuffer(_buf,'      <name>'),
    appendBuffer(_buf,_n),
    appendBuffer(_buf,'</name>\n'),
    appendBuffer(_buf,'      <value>'),
    quoteAtom(_v,_vq),
    appendBuffer(_buf,_vq),
    appendBuffer(_buf,'</value>\n'),
    appendBuffer(_buf,'    </gproperty>\n'),
    addPropertyList(_buf,_rest).
addPropertyList(_buf,_).


gProperty(_x,_label,_val) :-
  getCC(Proposition,gproperty,_cc),
  prove_literal(Adot_label(_cc,_x,_v,_label)),
  id2name(_v,_val).




{* makeSaveAtom(_a,_saveatom) replaces in _a all blanks and '- by '_'.    *}

makeSaveAtom(_a,_saveatom) :-
  atom(_a),
  name(_a,_name),
  scanChars(_name,_savename),
  name(_saveatom,_savename),
  !.
makeSaveAtom(_a,_a).

scanChars([],[]) :- !.

scanChars([_c|_rest],[_sc|_srest]) :-
  saveChar(_c,_sc),
  scanChars(_rest,_srest).

saveChar(32,95) :- !.  {* ' ' --> '_' *}
saveChar(45,95) :- !.  {* '-' --> '_' *}
saveChar(46,95) :- !.  {* '.' --> '_' *}

saveChar(_c,_c).


isAlphanumeric(_atom) :-
   atom(_atom),
   atom2list(_atom, _charList),
   alphanumeric(_, _charList, []).
   {* checkAlphanumeric(_charList). *}

{* alternative to alphanumeric/3 
checkAlphanumeric([_first]) :-
  name(_first,[_firstcode]),
  (isAlpha(_firstcode);isNum(_firstcode)),
  !.
checkAlphanumeric([_first|_rest]) :-
  name(_first,[_firstcode]),
  (isAlpha(_firstcode);isNum(_firstcode)),
  checkAlphanumeric(_rest).
*}



{* transform an atom to a strictly alphanumerical atom *}
makeAlphanumeric(_atom,_atom) :-
  isAlphanumeric(_atom),
  !.

makeAlphanumeric(_atom,_alphanum) :-
  name(_atom,_ascii1),
  makeAlphanumAscii(_ascii1,_ascii2),
  name(_alphanum,_ascii2),
  !.

makeAlphanumAscii([_first|_rest],[_first|_newrest]) :-
  isAlpha(_first),
  !,
  do_makeAlphanumAscii(_rest,_newrest).


makeAlphanumAscii([_first|_rest],_new) :-
  specToAlphaNum(_first,_spec),
  name('_',_u),
  !,
  do_makeAlphanumAscii(_rest,_newrest),
  append(_spec,_u,_specu),
  append(_specu,_newrest,_new).

do_makeAlphanumAscii([],[]) :- !.

do_makeAlphanumAscii([_x|_rest],[_x|_newrest]) :-
  (isAlpha(_x);isNum(_x);name('_',_x)),
  !,
  do_makeAlphanumAscii(_rest,_newrest).

do_makeAlphanumAscii([_x|_rest],_new) :-
  specToAlphaNum(_x,_spec),
  name('_',_u),
  !,
  do_makeAlphanumAscii(_rest,_newrest),
  append(_u,_spec,_uspec),
  append(_uspec,_u,_specu),
  append(_specu,_newrest,_new).


isAlpha(_first) :-
  name('A',_A),
  name('Z',_Z),
  name('a',_a),
  name('z',_z),
  (
   _first >= _A, _first =< _Z
   ;
   _first >= _a, _first =< _z
  ),
  !.

isNum(_first) :-
  name('0',_0),
  name('9',_9),
  _first >= _0, _first =< _9,
  !.


specToAlphaNum(_first,_spec) :-
  pc_inttoatom(_first,_at),
  pc_atomconcat('C',_at,_cspec),
  name(_cspec,_spec).



{* saveDIV(_result,_r1,_r2) is a save way to perferm division of two real numbers *}
{* If _r2 is zero, then saveDIV will fail and generate an error message.          *}

saveDIV(_result,_r1,_r2) :-
   saveToDivideBy(_r2),
  _result is _r1 / _r2.

{* saveIDIV(_I1,_i2) behaves analogously to saveDIV *}

saveIDIV(_result,_i1,_i2) :-
   saveToDivideBy(_i2),
  _result is _i1 // _i2.


{* check whether it is safe to divide by _z, i.e. whether _x <> 0 *}

saveToDivideBy(_x) :-
  (_x is 0; _x is 0.0),
  report_error(DIVBYZERO,GeneralUtilities,[]),
  raiseStratificationError,  {* just make sure that the ASK returns 'error' *}
  !,
  fail.

saveToDivideBy(_).



quicksortLabels(_listunsorted,_listsorted):-
  quicksortLabels(ascending,_listunsorted,_listsorted).


quicksortLabels(_order,[_pilot|_res],_listsorted):-
    partitionLabels(_order,_res,_pilot,_less,_bigger),
    quicksortLabels(_order,_less,_ls),
    quicksortLabels(_order,_bigger,_bs),
    append(_ls,[_pilot|_bs],_listsorted).
quicksortLabels(_order,[],[]):-!.

partitionLabels(ascending,[_x|_xs],_y,_ls,[_x|_bs]):-
    _x @> _y,
    partitionLabels(ascending,_xs,_y,_ls,_bs).
partitionLabels(descending,[_x|_xs],_y,_ls,[_x|_bs]):-
    _x @< _y,
    partitionLabels(descending,_xs,_y,_ls,_bs).

partitionLabels(_order,[_x|_xs],_y,[_x|_ls],_bs):-
    partitionLabels(_order,_xs,_y,_ls,_bs).
partitionLabels(_order,[],_,[],[]):-!.



{*
makeAtom converts a Prolog string to a Prolog atom if necessary
*}

makeAtom(_x,_x) :-
  atom(_x),
  !.
makeAtom(_s,_x) :-
  bimstring(_s),  {* _s is list of character codes *}
  name(_x,_s).







#DYNAMIC(cachedSpeedyFact/1)

{* speedy calls the goal and memorizes the result to speed up the computation *}
{* Use with great care since the goal could have many solution.               *}

speedy(_goal) :-
  cachedSpeedyFact(_goal),
  !.

speedy(_goal) :-
  call(_goal),
  assert(cachedSpeedyFact(_goal)).


{* the stored facts become invalid, usually due to database updates *}
cleanCachedSpeedyFacts :-
    retractall(cachedSpeedyFact(_)),
    !.
cleanCachedSpeedyFacts.





{* interface to C-Buffers; used to efficiently manipulate C-Strings *}
{* Used as wrapper for the corresponding functions exported from    *}
{* libGeneral/ExternalCodeLoader                                    *}


createBuffer(_buf) :-
  createBuffer(_buf,medium),   {* take a 'medium' as default buffer size  *}
  !.


{* see also ticket #263 and call of createBuffer/2 in               *}
{* CBserverInterface.pro                                            *}
{* The following buffer sizes led to a crash with the PDD example   *}
{* on Linux64:                                                      *}
{*    125, 499, 500, 993-1000                                       *}
{* Other buffer sizes appears fine but there is no proof.           *}


{* symbolic buffer sizes *}
createBuffer(_buf,mini) :-
  initBuffer(_buf,29),
  !.

createBuffer(_buf,medium) :-
  initBuffer(_buf,1151),
  !.

createBuffer(_buf,large) :-
  initBuffer(_buf,2053),
  !.


{* explicit buffer size *}
createBuffer(_buf,_len) :-
  integer(_len),
  initBuffer(_buf,_len),
  !.

disposeBuffer(_buf) :-
  deleteBuffer(_buf), 
   !.

deleteIpcMessage(_m) :-
   DeleteIpcMessage(_m),
   !.



{* is_allIds(_list): check whether all elements of _list are identifiers  *}

is_allIds([]) :- !.

is_allIds([_x|_rest]) :-
  is_id(_x),
  is_allIds(_rest).


{* is_allNumbers(_list): check whether all elements of _list are numbers  *}

is_allNumbers([]) :- !.

is_allNumbers([_x|_rest]) :-
  number(_x),
  is_allNumbers(_rest).




