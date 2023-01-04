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
* File:        BDMTransFormula.pro
* Version:     7.4
* Creation:    2-Aug-1990, Manfred Jeusfeld (UPA)
* Last Change: 28 Jun 1994, Manfred Jeusfeld (RWTH)
* Release:     7
*
*------------------------------------------------------------
*
* This module is part of the BDMIntegrityChecker. It performs transformation of a rangeform into a form that can be evaluated by BDMEvaluation
*
}


#MODULE(BDMTransFormula)
#EXPORT(GetEntry/3)
#EXPORT(RangeToEvaForm/6)
#EXPORT(VarsOfRangeform/2)
#EXPORT(avoidDoubleQuantifications/2)
#EXPORT(negateRangeForm/2)
#ENDMODDECL()


{===========================================================}
{=                  IMPORTED PREDICATES                    =}
{===========================================================}

#IMPORT(append/3,GeneralUtilities)
#IMPORT(member/2,GeneralUtilities)
#IMPORT(delete/3,GeneralUtilities)
#IMPORT(save_setof/3,GeneralUtilities)
#IMPORT(WriteTrace/3,GeneralUtilities)
#IMPORT(memberchk/2,GeneralUtilities)

#IMPORT(ConcernedClass/4,BDMLiteralDeps)
#IMPORT(RetrieveProposition/1,BDMForget)
#IMPORT(retrieve_BDMFormula/1,BDMKBMS)
#IMPORT(isQlit/1,QO_preproc)

{===========================================================}
{=              LOCAL PREDICATE DECLARATION                =}
{===========================================================}
#LOCAL(noDoubleQuantifications/2 )
#LOCAL(InsertPrologVars/6 )
#LOCAL(buildVarTab/2 )
#LOCAL(applyVarTab/5 )
#LOCAL(MakePrologLiteral/6 )
#LOCAL(ReplaceArgs/5 )
#LOCAL(GetVar/5 )
#LOCAL(negateRangeForm/2 )
#LOCAL(saveEvaForm/3 )
#LOCAL(makeSaveEvaForm/4 )
#LOCAL(splitLits/4 )
#LOCAL(recursive/2 )
#LOCAL(sameLit/2 )
#LOCAL(dependsOn/2 )
#LOCAL(dependsOnDirect/2 )
#LOCAL(completeRanges/5 )
#LOCAL(getFreeVars/3 )
#LOCAL(getAllVars/2 )
#LOCAL(missingRanges/4 )
#LOCAL(boundIn/2 )
#LOCAL(memberVar/2 )
#LOCAL(findRange/3 )
#LOCAL(ElimOuterNots/2 )
#LOCAL(findVars/3 )
#LOCAL(closure/2 )
#LOCAL(warshall/2 )
#LOCAL(warshall/3 )
#LOCAL(ord_union/3 )

#IF(SWI)
:- style_check(-singleton).
#ENDIF(SWI)

{===========================================================}
{=             EXPORTED PREDICATES DEFINITION              =}
{===========================================================}


{*** avoidDoubleQuantifications undoes some of the pushing-in of **}
{*** quantors into conjunctions/disjunctions performed in the    **}
{*** miniscope transformation, e.g. the original formala         **}
{***    forall x/C (A(x) and B(x)) reads in miniscope as         **}
{***    (forall x/C A(x)) and (forall x/C B(x))                  **}
{*** This representation is a disadvantage the purpose of        **}
{*** integrity checking since it introduces double triggers for  **}
{*** (x in C).                                                   **}
{*** I think the miniscope form in AssertionSimplifier should be **}
{*** redesigned. Then, this little piece of code (used in        **}
{*** BDMCompile) would become superfluous.                       **}
{*** 27-Jul-1993/MJf                                             **}

avoidDoubleQuantifications(_f,_ff) :-
  noDoubleQuantifications(_f,_ff),
  !.

avoidDoubleQuantifications(_f,_f).

{ ******************* R a n g e T o E v a F o r m ******************** }
{                                                                      }
{ RangeToEvaForm(_vars,_ranges,_rangeF,_rangeLit,_evaF,_evaLit)        }
{   _vars: term (i)                                                    }
{   _ranges: list (i)                                                  }
{   _rangeF: term (i)                                                  }
{   _rangeLit: literal (i)                                             }
{   _evaF: term (o)                                                    }
{   _evaLit: literal (o)                                               }
{                                                                      }
{ The CML/Telos variables are replaced by Prolog variables and the     }
{ first argument of the quantified (sub-) formulas is eliminated.      }
{ Note that _evaF is evaluable thru BDMEvaluation.                     }
{                                                                      }
{ 18-Dec-1990/MJf: additional parameter _rangeLit for InsertPrologVars }
{ in order to do a better optimization in guardA, see also             }
{ CBNEWS[108].                                                         }
{                                                                      }
{ 8-Jun-1993/MJf: a new procedure saveEvaForm rewrites deductive       }
{ rules (evarule format) in a way that makes terminating evaluation    }
{ strategies (BDMEvaluation) possible. See also CBNEWS[156].           }
{ ******************************************************************** }


RangeToEvaForm(vars(_a,_b),_ranges,_rangeF,_rangeLit,_evaFS,_evaLit) :-

	buildVarTab(_a,_VarTab),
	InsertPrologVars(vars(_a,_b),_ranges,_rangeLit,_rangeF,_evaF,_VarTab),
	MakePrologLiteral(vars(_a,_b),_ranges,_VarTab,OUTSIDE,_rangeLit,_evaLit),
	saveEvaForm(_evaF,_evaLit,_evaFS),
	WriteTrace(veryhigh,BDMTransFormula,[RangeToEvaForm,'--->',idterm(_evaF),' BY ',idterm(_evaLit)]),

  !.

{ ****************** V a r s O f R a n g e f o r m ******************* }
{                                                                      }
{ VarsOfRangeform(_rangeF,_vars)                                       }
{   _rangeF: term (i)                                                  }
{   _vars: term (o)                                                    }
{                                                                      }
{ The output parameter _vars has the form vars(_allvars,_goodvars).    }
{ The component _allvars is unified with the list of all variables     }
{ occuring within _rangeF. The second component _goodvars becomes the  }
{ list of all 'forall' quantified variables which are not in the scope }
{ of an 'exists' quantor.                                              }
{ This procedure is the successor of the original 'AllquVarsWoExqu'    }
{ procedure.                                                           }
{                                                                      }
{ ******************************************************************** }

VarsOfRangeform(_rangeform, vars(_allvars,_goodvars) ) :-
   findVars(_rangeform, _allvars, _goodvars),
   !.

{ **************************   G e t E n t r y   ************************** }
{                                                                           }
{ GetEntry( _Tab, _old, _new)                                               }
{                                                                           }
{ Eintrage in _Tab haben die Form f(_old,_new), wobei f irgendein Funktor   }
{ ist. GetVar sucht nun nach einem Eintrag mit erstem Argument _old und     }
{ liefert _new zurueck. Falls kein Eintrag gefunden wurde, wird _old unver- }
{ aendert zurueckgegeben.                                                   }
{                                                                           }
{ Bem.: GetEntry ging aus dem alten GetVar hervor, ist jetzt jedoch allge-  }
{ meiner zu verwenden (s.a. BDMCompile).                                    }
{                                                                           }
{ ************************************************************************* }


GetEntry( [], _old, _old) :- !.

GetEntry( [_entry|_],_old,_new) :-
  _entry =.. [_,_old,_new],
  !.

GetEntry( [_|_restTab], _old, _new) :-
  GetEntry(_restTab,_old,_new).


{===========================================================}
{=                LOCAL PREDICATES DEFINITION              =}
{===========================================================}

noDoubleQuantifications(and(forall(_v,_lits,_f1),forall(_v,_lits,_f2)),
                        forall(_v,_lits,and(_f1,_f2))).

noDoubleQuantifications(or(exists(_v,_lits,_f1),exists(_v,_lits,_f2)),
                        exists(_v,_lits,or(_f1,_f2))).


{ treatment of deductive rules within the same framework as constraints: }


InsertPrologVars(_v,_r,_rlit,rangerule(_cond,_concl),
                 evarule(_econd,_econcl),_VarTab) :-
  !,
  negateRangeForm(_cond,_negatedcond),      {have it exists-quantified}
  InsertPrologVars(_v,_r,_rlit,_concl,_econcl,_VarTab),
  InsertPrologVars(_v,_r,_rlit,_negatedcond,_econd,_VarTab),
  !.


{ eliminate empty universal quantifications (introduced by specialization }
{ within BDMCompile)                                                      }

{ a) even no range literals:                        }

InsertPrologVars(_v,_r,_rlit,forall([],[],_rangeF),
                 _evaF,
                 _VarTab) :-
  InsertPrologVars(_v,_r,_rlit,_rangeF,_evaF,_VarTab).

{ b) some range literals, but all variables bound:  }

InsertPrologVars(_v,_r,_rlit,forall([],_lits,_rest_rangeF),
                 implies(_plits,_prest_rangeF),
                 _VarTab) :-
  !,
  applyVarTab(_v,_r,_VarTab,_lits,_plits),
  InsertPrologVars(_v,_r,_rlit,_rest_rangeF,_prest_rangeF,_VarTab).


{28-Jun-1994/MJf:}
{Treat "forall vars1 lits1 ==> (forall vars2 lits2 ==> F)" like }
{      "forall vars1+vars2 lits1+lits2 ==> F"                   }
{ Advantage is more efficient Prolog code to be processed by    }
{ BDMevaluation.                                                }

InsertPrologVars(_v,_r,_rlit,forall(_vars1,_lits1,forall(_vars2,_lits2,_rest_rangeF)),
                 forall(_plits,_prest_rangeF),
                 _VarTab) :-
  !,
  append(_vars1,_vars2,_vars),
  append(_lits1,_lits2,_lits),
  applyVarTab(_v,_r,_VarTab,_lits,_plits),
  InsertPrologVars(_v,_r,_rlit,_rest_rangeF,_prest_rangeF,_VarTab).


InsertPrologVars(_v,_r,_rlit,forall(_vars,_lits,_rest_rangeF),
                 forall(_plits,_prest_rangeF),
                 _VarTab) :-
  !,
  applyVarTab(_v,_r,_VarTab,_lits,_plits),
  InsertPrologVars(_v,_r,_rlit,_rest_rangeF,_prest_rangeF,_VarTab).


InsertPrologVars(_v,_r,_rlit,exists(_ranges,_lits,_rest_rangeF),
                 exists(_plits,_prest_rangeF),
                 _VarTab) :-
  !,
  applyVarTab(_v,_r,_VarTab,_lits,_plits),
  InsertPrologVars(_v,_r,_rlit,_rest_rangeF,_prest_rangeF,_VarTab).

InsertPrologVars(_v,_r,_rlit,or(_rF1,_rF2),or(_prF1,_prF2),_VarTab) :-
  !,
  InsertPrologVars(_v,_r,_rlit,_rF1,_prF1,_VarTab),
  InsertPrologVars(_v,_r,_rlit,_rF2,_prF2,_VarTab).

InsertPrologVars(_v,_r,_rlit,and(_rF1,_rF2),and(_prF1,_prF2),_VarTab) :-
  !,
  InsertPrologVars(_v,_r,_rlit,_rF1,_prF1,_VarTab),
  InsertPrologVars(_v,_r,_rlit,_rF2,_prF2,_VarTab).

InsertPrologVars(_v,_r,_rlit,not(_L),not(_pL),_VarTab) :-
  !,
  applyVarTab(_v,_r,_VarTab,[_L],[_pL]).

InsertPrologVars(_v,_r,_rlit,_L,_pL,_VarTab) :-
  applyVarTab(_v,_r,_VarTab,[_L],[_pL]).




buildVarTab([],[]) :- !.

buildVarTab([_x|_rest],[var(_x,_px)|_restVarTab]) :-
  buildVarTab(_rest,_restVarTab).



applyVarTab(_v,_r,_VarTab,[],[]) :- !.

applyVarTab(_v,_r,_VarTab,[_lit|_rest],[_plit|_prest]) :-
  MakePrologLiteral(_v,_r,_VarTab,INSIDE,_lit,_plit),
  applyVarTab(_v,_r,_VarTab,_rest,_prest).



{ . Replace the arguments by the Prolog correspondences }

{ optimized A as Adot(cc,x,y), see CBNEWS[152]: }

MakePrologLiteral(_vars,_ranges,_VarTab,_mode,A(_x,_l,_y),_evaLit) :-
  ConcernedClass(_vars,_ranges,A(_x,_l,_y),_cc),
  ReplaceArgs(_mode,_vars,_VarTab,[_x,_y],[_x1,_y1]),
  _evaLit =.. [Adot,_cc,_x1,_y1],
  !.

{ analogously for Ai: }

MakePrologLiteral(_vars,_ranges,_VarTab,_mode,Ai(_x,_l,_id),_evaLit) :-
  ConcernedClass(_vars,_ranges,Ai(_x,_l,_id),_cc),
  ReplaceArgs(_mode,_vars,_VarTab,[_x,_id],[_x1,_id1]),
  _evaLit =.. [Aidot,_cc,_x1,_id1],
  !.

{ analogously for In
: }

MakePrologLiteral(_vars,_ranges,_VarTab,_mode,In(_x,_c),In(_x1,_c1)) :-
  ReplaceArgs(_mode,_vars,_VarTab,[_x,_c],[_x1,_c1]),
  !.

{ other literals: }

MakePrologLiteral(_vars,_ranges,_VarTab,_mode,_rangeLit,_evaLit) :-
  _rangeLit =.. [_name|_args],
  ReplaceArgs(_mode,_vars,_VarTab,_args,_prologArgs),
  _evaLit =.. [_name|_prologArgs],
  !.



ReplaceArgs(_mode,_vars,_VarTab,[],[]) :- !.

{* ticket #158: an argument may be the anonymous variable introduced by *}
{* a functional expression. Then, we need to use a new variable _newvar *}
{* to hold the result of the functional expression.                     *}

ReplaceArgs(_mode,_vars,_VarTab,['_'|_restArgs],[_newvar|_restPrologArgs]) :-
  ReplaceArgs(_mode,_vars,_VarTab,_restArgs,_restPrologArgs).

{* ticket #158: arguments of a literal can be query literals (in particular *}
{* funtional expressions). Example COUNT_Attribute(a1/attrcat,_x/objname)   *}
{* would be mapped internally to id_1234(_,_a1,_c1,_x,_c2). In this case,   *}
{* the anonymous result variable is at the first argument.                  *}

ReplaceArgs(_mode,_vars,_VarTab,[_lit|_restArgs],[_prologLit|_restPrologArgs]) :-
  isQlit(_lit),!,
  _lit =.. [_id|['_'|_restargs]], 
  MakePrologLiteral(_vars,_ranges,_VarTab,_mode,_lit,_prologLit),
  ReplaceArgs(_mode,_vars,_VarTab,_restArgs,_restPrologArgs).

ReplaceArgs(_mode,_vars,_VarTab,[_arg|_restArgs],[_prologArg|_restPrologArgs]) :-
  GetVar(_mode,_vars,_VarTab,_arg,_prologArg),
  ReplaceArgs(_mode,_vars,_VarTab,_restArgs,_restPrologArgs).


GetVar(INSIDE,_vars,_VarTab,_arg,_prologArg) :-
  GetEntry(_VarTab,_arg,_prologArg),
  !.


{ arg is all-quantified and not within the scope of an 'exists' }
{ or arg is a constant:                                         }

GetVar(OUTSIDE,vars(_a,_b),_VarTab,_arg,_prologArg) :-
  (member(_arg,_b); \+(member(_arg,_a))),
  !,
  GetEntry(_VarTab,_arg,_prologArg).


{ arg is a variable in the scope of an 'exists':                }

GetVar(OUTSIDE,_vars,_VarTab,_arg,_newprologVar).





{ produce the negation of a range formula: }

negateRangeForm(TRUE,FALSE) :- !.
negateRangeForm(FALSE,TRUE) :- !.

negateRangeForm(forall(_v,_r,_F),exists(_v,_r,_nF)) :-
  negateRangeForm(_F,_nF),
  !.

negateRangeForm(exists(_v,_r,_F),forall(_v,_r,_nF)) :-
  negateRangeForm(_F,_nF),
  !.

negateRangeForm(and([]),or([])).

negateRangeForm(and([_a|_as]),or([_na|_nas])) :-
	negateRangeForm(_a,_na),
	!,
	negateRangeForm(and(_as),or(_nas)).

negateRangeForm(or([]),and([])).

negateRangeForm(or([_o|_os]),and([_no|_nos])) :-
	negateRangeForm(_o,_no),
	!,
	negateRangeForm(and(_os),or(_nos)).

negateRangeForm(and(_F1,_F2),or(_nF1,_nF2)) :-
  negateRangeForm(_F1,_nF1),
  negateRangeForm(_F2,_nF2),
  !.

negateRangeForm(or(_F1,_F2),and(_nF1,_nF2)) :-
  negateRangeForm(_F1,_nF1),
  negateRangeForm(_F2,_nF2),
  !.

negateRangeForm(not(_lit), _lit) :- !.

negateRangeForm(_lit, not(_lit)) :- !.




saveEvaForm(evarule(_econd,_econcl),_instLit,evarule(_econdS,_econcl)) :-
  _instLit =.. [_f|_args],
  getAllVars(_args,_boundvars),
  makeSaveEvaForm(_boundvars,_econcl,_econd,_econdS),
        {_econdS is the "safe" format}
  !.

saveEvaForm(_evaF,_instLit,_evaF).


{*** makeSaveEvaForm(_conclLit,_f,_fS) takes a formula _f (evarule format }
{*** and produces a variant _fS (also evarule format) which discriminates }
{*** non-recursive and recursive predicates. The latter ones are shifted  }
{*** inside the formula (without changing the semantics). Thereby, the    }
{*** forward-chaining rule evaluator in BDMEvaluation can impose a cut    }
{*** after the recursive part of _fS. This cures many cases of non-       }
{*** termination of recursive rules (BUT NOT ALL, unfortunately).         }
{*** The parameter _conclLit is the conclusion literal of the deductive   }
{*** rule. Note that all literal are in internal form (Adot instead A) and}
{*** that their variables are Prolog variables!                           }


{*** 1. treat all or cases of a deductive rule (this would be different   }
{*** different clauses with the same conclusion literal in DATALOG)       }

makeSaveEvaForm(_boundvars,_conclLit,or(_f1,_f2),or(_sf1,_sf2)) :-
  makeSaveEvaForm(_boundvars,_conclLit,_f1,_sf1),
  makeSaveEvaForm(_boundvars,_conclLit,_f2,_sf2),
  !.

{*** 2. Do the main work,i.e., discriminate the "safe" (non-recursive)    }
{*** predicates. Note that the rewritten formula is equivalent to the     }
{*** original one.                                                        }
{*** The steps are as follows: first, _lits is divided in to safe and     }
{*** unsafe predicates. If the is at least one unsafe literal then we can }
{*** rewrite the formula. Since some literals have left the range of the  }
{*** outer exists some variables of _conclLit may not be bound by         }
{*** _safelits. Therefore, auxiliary predicates are added to complete the }
{*** range. As the result, all variables of _conclLit are bound by        }
{*** _savelitsPlus.                                                       }

makeSaveEvaForm(_boundvars,_conclLit,exists(_lits,_f),
                exists(_savelitsPlus,exists(_unsavelits,_f))) :-
  splitLits(_conclLit,_lits,_savelits,_unsavelits),
  _unsavelits \= [],
  completeRanges(_boundvars,_conclLit,_savelits,_unsavelits,_savelitsPlus).

makeSaveEvaForm(_,_,_f,_f).


{*** splitLits(_conclLit,_lits,_savelits,_unsavelits) does the work as    }
{*** mentioned before. The first parameter is necessary for detecting     }
{*** recursion inside the rule itself.                                    }
{*** One has to be very careful for not unifying Prolog variables in      }
{*** literals.                                                            }

splitLits(_conclLit,[],[],[]) :- !.

splitLits(_conclLit,[_lit|_restlits],[_lit|_restsave],_unsave) :-
  \+ recursive(_conclLit,_lit),  {avoid variable bindings by succeeding recursive/1}
  !,
  splitLits(_conclLit,_restlits,_restsave,_unsave).


splitLits(_conclLit,[_lit|_restlits],_save,[_lit|_restunsave]) :-
  splitLits(_conclLit,_restlits,_save,_restunsave).


{*** The literal _lit is recursive if it matches the conclusion literal   }
{*** or it "depends" on itsself.                                          }

recursive(_conclLit,_lit) :-
  sameLit(_conclLit,_lit);
  dependsOn(_lit,_lit),
  !.

{*** For sameLit we only like at this three literals. The others are not  }
{*** allowed as conclusions of deductive rules.                           }

sameLit(Adot(_cc,_,_),Adot(_cc,_,_)).
sameLit(Aidot(_cc,_,_),Aidot(_cc,_,_)).
sameLit(In(_,_c),In(_,_c)).


{*** allowed as conclusions of deductive rules.                           }
{*** dependsOn(_lit1,_lit2) states that _lit1 depends on _lit2, i.e.,     }
{*** _lit1 is directly or indirectly derived by a rule that contains _lit2}
{*** in its condition. Fortunately, BDMCompile has already set up the     }
{*** dependency network.                                                  }

{* the depends on problem maps 1:1 to the closure problem described in the book "The Craft of Prolog" by Richard A O'Keefe. The code for the warshall algorithm, ord_union/3 is taken from the BIM-Libraries, the code for closure/2 from the book mentioned above.
*}

dependsOn(_lit1,_lit2) :-
	closure(_lit1,_lit2).


{* dependsOnDirect/2 succeeds if (_lit1,_lit2) is an edge of the dependency graph *}

dependsOnDirect(_lit1,_lit2) :-
	retrieve_BDMFormula('applyRuleIfInsert@BDMCompile'(_RuleId, _,_,_lit2c,_lit1c,_f,_goAhead)),
	sameLit(_lit1,_lit1c), sameLit(_lit2,_lit2c).

{*** dependency network.                                                  }
{*** completeRanges(_conclLit,_savelits,_unsavelits,_savelitsPlus) in-    }
{*** vestigates the free variables of _conclLit wether they are bound by  }
{*** a safe literal. If not, then we have to add an auxiliary bound       }
{*** literal. Here, we take the class membership of the variable.         }
{*** Though In(x,Proposition) would work for any case it is by far to     }
{*** inefficient. We do not use it here.                                  }

completeRanges(_boundvars,_conclLit,_savelits,_unsavelits,_savelitsPlus) :-
  _conclLit =.. [_f|_args],
  getFreeVars(_boundvars,_args,_freevars),
  missingRanges(_freevars,_savelits,_unsavelits,_plus),
  append(_savelits,_plus,_savelitsPlus),
  !.


getFreeVars(_boundvars,[],[]) :- !.

getFreeVars(_boundvars,[_arg1|_restargs],[_arg1|_restfree]) :-
  var(_arg1),
  \+ memberVar(_arg1,_boundvars),
  !,
  getFreeVars(_boundvars,_restargs,_restfree).

getFreeVars(_boundvars,[_arg1|_restargs],_restfree) :-
  getFreeVars(_boundvars,_restargs,_restfree).



getAllVars([],[]) :- !.

getAllVars([_arg1|_restargs],[_arg1|_restvars]) :-
  var(_arg1),
  !,
  getAllVars(_restargs,_restvars).

getAllVars([_arg1|_restargs],_restvars) :-
  getAllVars(_restargs,_restvars).



{*** missingRanges(_vars,_savelits,_unsavelits,_plus) computes the aux-   }
{*** iliary range literals for _savelits.                                 }

missingRanges([],_savelits,_unsavelits,[]) :- !.

missingRanges([_var|_restvars],_savelits,_unsavelits,[In(_var,_c)|_restplus]) :-
  \+ boundIn(_var,_savelits),  {we have a free variable that has to be bound}
  !,
  findRange(_var,_unsavelits,_c),
  missingRanges(_restvars,_savelits,_unsavelits,_restplus).

{*** otherwise: the variable _var is already bound by some literal in     }
{*** _safelits.                                                           }

missingRanges([_var|_restvars],_savelits,_unsavelits,_restplus) :-
  missingRanges(_restvars,_savelits,_unsavelits,_restplus).


{*** boundIn(_var,_lits) is true if the variable _var occurs in a         }
{*** literal of _lits. Note that _lits contains only positive literals by }
{*** definition  of evarules.                                             }

boundIn(_var,[_lit|_]) :-
  _lit =.. [_f|_args],
  memberVar(_var,_args),
  !.

boundIn(_var,[_|_rest]) :-
  boundIn(_var,_rest).

memberVar(_v,[_x|_rest]) :- var(_x),_v == _x,!.
memberVar(_v,[_|_rest]) :- memberVar(_v,_rest).



{*** findRange(_var,_lits,_c) takes a free variable _var and looks in     }
{*** which unsafe literal it occurs. That literal is used to determine the}
{*** class _c of the variable.                                            }

findRange(_var,[Adot(_cc,_x,_y)|_rest],_c) :-
  _var == _x,
  RetrieveProposition(P(_cc,_c,_m,_d)),
  !.

findRange(_var,[Adot(_cc,_x,_y)|_rest],_d) :-
  _var == _y,
  RetrieveProposition(P(_cc,_c,_m,_d)),
  !.

findRange(_var,[Aidot(_cc,_x,_id)|_rest],_c) :-
  _var == _x,
  RetrieveProposition(P(_cc,_c,_m,_d)),
  !.

findRange(_var,[Aidot(_cc,_x,_id)|_rest],_cc) :-
  _var == _id,
  !.

findRange(_var,[_lit|_rest],_c) :-
  findRange(_var,_rest,_c).



{ *************************************************************************** }
{                                                                   1989/EK   }
{ ElimOuterNots( _miniscopeform_withOuterNots, _miniscopeform)                }
{                                                                             }
{ In der Miniscope-Form der Formel (Integritaetsbedingung oder Bedingungsteil }
{ einer Regel) tauchen eventuell not's auf, diese werden nach ganz innen      }
{ gezogen, d.h. genau vor Literale.                                           }
{                                                                             }
{ _BIMstring : die Zeichenkette, die die Regel darstellt (so, wie sie der     }
{              Benutzer eingegeben hat) (i),                                  }
{ _id        : der Identifikator des Objekts, das die Regel enthaelt (i).     }
{                                                                             }
{ *************************************************************************** }



ElimOuterNots(not(not(_t)),_r) :-

	ElimOuterNots(_t,_r).


ElimOuterNots(not(and(_t1,_t2)),or(_r1,_r2)) :-

	ElimOuterNots(not(_t1),_r1),
	ElimOuterNots(not(_t2),_r2).


ElimOuterNots(not(or(_t1,_t2)),and(_r1,_r2)) :-

	ElimOuterNots(not(_t1),_r1),
	ElimOuterNots(not(_t2),_r2).


ElimOuterNots(not(lit(_l)),not(lit(_l))) :- !.


ElimOuterNots(not(exists(_var,_type,_t)),forall(_var,_type,_r)) :-

	ElimOuterNots(not(_t),_r).


ElimOuterNots(lit(_l),lit(_l)) :- !.


ElimOuterNots(or(_t1,_t2),or(_r1,_r2)) :-

	ElimOuterNots(_t1,_r1),
	ElimOuterNots(_t2,_r2).


ElimOuterNots(and(_t1,_t2),and(_r1,_r2)) :-

	ElimOuterNots(_t1,_r1),
	ElimOuterNots(_t2,_r2).


ElimOuterNots(exists(_var,_type,_t),exists(_var,_type,_r)) :-

	ElimOuterNots(_t,_r).


ElimOuterNots(forall(_var,_type,_t),forall(_var,_type,_r)) :-

	ElimOuterNots(_t,_r).






{ ... getVars does the work for VarsOfRangeform }

findVars( forall(_vars, _, _rangeF), _allvars, _goodvars) :-
	append(_vars,_restallvars,_allvars),
	append(_vars,_restgoodvars,_goodvars),
	findVars( _rangeF, _restallvars, _restgoodvars),
	!.

findVars( exists(_vars, _, _rangeF), _allvars, []) :-
	append(_vars,_restallvars,_allvars),
	findVars( _rangeF, _restallvars, _),
	!.

findVars(and([]),[],[]).

findVars( and([_f|_fs]), _allvars, _goodvars) :-
	findVars(_f,_allvars_f,_goodvars_f),
	append(_allvars_f,_allvars_fs,_allvars),
	append(_goodvars_f,_goodvars_fs,_goodvars),
	findVars(and(_fs), _allvars_fs, _goodvars_fs),
	!.

findVars(or([]),[],[]).

findVars( or([_f|_fs]), _allvars,_goodvars) :-
	findVars(_f,_allvars_f,_goodvars_f),
	append(_allvars_f,_allvars_fs,_allvars),
	append(_goodvars_f,_goodvars_fs,_goodvars),
	findVars(or(_fs), _allvars_fs, _goodvars_fs),
	!.

{ alle anderen Subformeln (exists,TRUE,FALSE,pos/neg Literale): }

findVars(_,[],[]) :- !.


{***********************************************************}
{* closure(_lit1,_lit2)                                    *}
{*                                                         *}
{* succeeds if there is a path in the dependency graph from*}
{* _lit1 to _lit2                                          *}
{* cf. "The Craft of Prolog" von Richard A O'Keefe (pp 167)*}
{***********************************************************}
closure(_ancestor,_descendant) :-

	{* first build a neighbor structure representation of the dependency graph *}
	setof(_from-_tos,
		setof(_to,dependsOnDirect(_from,_to),_tos),
		_graph),

	{* then build the transitive closure *}
	warshall(_graph,_closure),

	{* check if the asked for edge has been computed by the warshall algorithm *}
	member(_ancestor-_descendants,_closure),
	member(_descendant,_descendants).


{* The warshall algorithm *}

warshall(_Graph, _Closure) :-
	warshall(_Graph, _Graph, _Closure).

warshall([], _Closure, _Closure) :- !.
warshall([_V-_|_G], _E, _Closure) :-
	memberchk(_V-_Y, _E),	{*  _Y := _E(v) *}
	warshall(_E, _V, _Y, _NewE),
	warshall(_G, _NewE, _Closure).


warshall([_X-_Neibs|_G], _V, _Y, [_X-_NewNeibs|_NewG]) :-
	memberchk(_V, _Neibs),
	!,
	ord_union(_Neibs, _Y, _NewNeibs),
	warshall(_G, _V, _Y, _NewG).
warshall([_X-_Neibs|_G], _V, _Y, [_X-_Neibs|_NewG]) :- !,
	warshall(_G, _V, _Y, _NewG).
warshall([], _, _, []).

{* ord_union/3 is just a help predicate for the warshall algorithm *}

ord_union([],_B,_B) :- !.

ord_union(_A,[],_A) :- !.

ord_union([_H|_T1], [_H|_T2], [_H|_T3]) :-
	!,
	ord_union(_T1, _T2, _T3).

ord_union([_H1|_T1],[_H2|_T2],[_H1|_T]) :-
	_H1 @< _H2,
	!,
	ord_union(_T1,[_H2|_T2],_T).

ord_union(_A,[_H2|_T2],[_H2|_T]) :-
	ord_union(_A,_T2,_T).
