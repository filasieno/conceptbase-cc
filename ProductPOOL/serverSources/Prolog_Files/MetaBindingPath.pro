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
{************************************************************************
*
* File:         %M%
* Version:      %I%
*
*
* Date released : %E%  (YY/MM/DD)
*
* SCCS-Source-Pool : %P%
* Date retrieved : %D% (YY/MM/DD)
**************************************************************************
* Das Modul MetaBindingPath bestimmt fuer eine gegebene Metaformel einen
* Folge von Literalen, die ausgewertet werden sollen.
*
*
* Beispiel
* Metaformel necessary:
* Class with
*  constraint
*         necConstraint:
*         $ forall p,x,m/VAR c,d/VAR In(p,Class!necessary) and P(p,c,m,d)
*		and In(x,c) ==> exists y/VAR  In(y,d) and A(x,m,y) $
* end
*
* Klassenvariablen: c und d
* c und d muessen instantiiert werden, damit sich eine vereinfachte
* Formel ueberhaupt speichern laesst.
*
* Moegliche Literale fuer die Auswertung sind:
* In(p,Class!necessary), P(p,c,m,d), In(x,c)
*
* Verfahren:
* um c und d zu binden kann man nur P(p,c,m,d) verwenden
* P-Literale werden fuer die partielle Auswertung nur in
* der Form P(b,f,f,f) zugelassen (b fuer bound,f fuer free)
* Um P(p,c,m,d) in diese Form zu bringen, muss
* In(p,Class!necessary) ausgwertet werden
* In(f,b) ist zulaessig
* -->
* BindingPath: In(p,Class!necessary), P(p,c,m,d)
*
* Die Information, welche Instantiierungmuster zulaessig sind und
* welche nicht wird aus MetaLiterals.pro gewonnen
*
}
#MODULE(MetaBindingPath)
#EXPORT(findBindingPathsForVars/6)
#EXPORT(selectCheapestPath/6)
#EXPORT(substituteBP/4)
#ENDMODDECL()


#IMPORT(determines/4,MetaLiterals)
#IMPORT(determines2/2,MetaLiterals)
#IMPORT(determines3/3,MetaLiterals)
#IMPORT(litParts/3,MetaLiterals)
#IMPORT(substituteLits/4,MetaLiterals)
#IMPORT(append/3,GeneralUtilities)
#IMPORT(empty/1,MetaUtilities)
#IMPORT(giveNthMember/3,MetaUtilities)
#IMPORT(listDifference/3,MetaUtilities)
#IMPORT(listIntersection/3,MetaUtilities)
#IMPORT(pc_member/2,PrologCompatibility)
#IMPORT(memberchk/2,GeneralUtilities)
#IMPORT(nonmember/2,MetaUtilities)
#IMPORT(not_empty/1,MetaUtilities)
#IMPORT(position/3,MetaUtilities)
#IMPORT(removeMultiEntries/2,MetaUtilities)
#IMPORT(removePosElem/3,MetaUtilities)
#IMPORT(saveSetof/3,MetaUtilities)
#IMPORT(subSetList/2,MetaUtilities)
#IMPORT(substElemsInList/4,MetaUtilities)
#IMPORT(WriteTrace/3,GeneralUtilities)
#IMPORT(get_cb_feature/2,GlobalParameters)
#IMPORT(retrieve_proposition/1,PropositionProcessor)
#IMPORT(is_id/1,MetaUtilities)
#IMPORT(prove_literal/1,Literals)

#IF(SWI)
:- style_check(-singleton).
#ENDIF(SWI)



{ test predicate }
testBP(_metaVs,_cons,_vars,_lits,_clevel,_bPs,_cList) :-
	findBindingPathsForVars(_metaVs,_cons,_vars,_lits,_clevel,_bPs),
	computeAllCosts(_metaVs,_cons,_bPs,_cList).
 testBP1(_metaVs,_cons,_vars,_lits,_clevel,_bP) :-
	findBindingPathsForVars(_metaVs,_cons,_vars,_lits,_clevel,_bPs),
	selectCheapestPath(_metaVs,_cons,_bPs,_bP,_bcost,0).
{
testBP([c,d],[Nec],[p,c,x,m,d,y],[In(p,Nec),In(x,c),P(p,c,m,d)],10,_bps,_cost).
testBP([c,d],[RevSingle],[p,c,m,d,y,x1,x2],[In(p,RevSingle),In(y,d),P(p,c,m,d),In(x1,c),In(x2,c),A(x1,m,y),A(x2,m,y)],10,_bps,_cost).
testBP([x1,x2,y],[RevSingle],[p,c,m,d,y,x1,x2],[In(p,RevSingle),In(y,d),P(p,c,m,d),In(x1,c),In(x2,c),A(x1,m,y),A(x2,m,y)],10,_bps,_cost).

}


{--------------EXPORT PART -------------------------}
{--------------------------------------------------}
{--------------------------------------------------}

{
 findBindingPathsForVars(mVs,cons,vars,lits,clevel,pBaths)
"mVs" contains the variables that have to be bound evaluating
some of the literals in "lits" with an evaluation pattern with max.
cost clevel
"vars" and "cons" are the variables and constants occuring
"bPaths" contains the paths found
}
findBindingPathsForVars(_mVs,_cons,_vars,_lits,_clevel,_bPathList) :-
	fillDeterminerStructure(_mVs,_cons,_vars,_lits,_clevel,_varDetList),
	findBindingPathsForVariables(_mVs,_cons,_vars,_clevel,_varDetList,_bPathList),
        !.



{-------------------------------------
selectCheapestPath(mVars,cons,bPaths,bPath,status)
Find that element bPath in bPaths with cost function is minimal
_mVars: meta variables to be bound
_cons: constants in the formula
_bList: vandidate binding paths
_b: cheapest binding path
_bcost: cost of the selected cheapest path 
_status: -1: no binding path, 0 success
}
selectCheapestPath(_mVars,_,[],_,_,-1) :- !.
selectCheapestPath(_mVars,_cons,_bList,_b,_bcost,0) :-
	not_empty(_bList),
        optimizeBindingList(_bList,_optbList),   {* new by M.Jeusfeld, 25-Oct-2001, CBNEWS[202] *}
 	selectCheapestPath1(_mVars,_cons,_optbList,_b,_bcost),
        WriteTrace(high,MetaBindingPath,['Cheapest binding path is ',idterm(_b),' (cost=',_bcost,')']),
	!.




{* optimizeBindingList(_inlist,_outlist)
* remove literals from paths in _inlist that are
* redundant (much like in SemanticOptimizer), e.g.
* [In(c,SomeClass),A(c,attr,d)] --> [A(c,attr,d)]
* M. Jeusfeld, 3-Oct-2001
*}

optimizeBindingList(_bList,_optbList) :-
  optimizeBindingList(_bList,_bList,_optbList).   {* 2nd argument holds all bindings *}



optimizeBindingList([],_allBinds,[]) :-!.  {* all done *}

{* Ticket #273: also eliminate dependent Binds *}
optimizeBindingList([_b1|_brest],_allBinds,_newbrest) :-
   isDependentBinding(_b1,_allBinds),
   optimizeBindingList(_brest,_allBinds,_newbrest).

optimizeBindingList([_b1|_brest],_allBinds,[_newb1|_newbrest]) :-
  optimizeBinding(_b1,_newb1),
  optimizeBindingList(_brest,_allBinds,_newbrest).

{* The Binds data structure has to be read as follows     *}
{* Binds(_c,_v,_lits,_len)                                *}
{*  _c = list of variables that shall be eliminated by    *}
{*       partial evaluation.                              *}
{*  _v = list of variables  that are instances of         *}
{*       members of _c                                    *}
{*  _lits = ordered list of literals that can be used to  *}
{*          get bindings for _c variables (partial eval.) *}
{*  _len = length of the list _lits                       *}
{*                                                        *}
{* For example, $ forall x/Individual E,D/Class           *}
{*                (x in E) and (E isA D)  ==> (x in D)    *}
{* has _c =[E,D] and _v=[x] and _lits =[(E isA D)] as one *}
{* candidate binding.                                     *}

optimizeBinding(Binds(_c,_v,_lits,_len),Binds(_c,_v,_newlits,_newlen)) :-
  optimizeLits(_c, _lits,_len,[],_newlits1,_newlen),  {_newlits is reversed in order}
  rereverseOrder(_newlits1,[],_newlits).



{* Ticket #273: Eliminate so-called dependent bindings from the set *}
{* of all binding candidates.                                       *}
{* The pattern is as follows:                                       *}
{* a) There is a Binds b1 that just has the path [In(_E,_RANGE)]    *}
{* b) There is another Binds b2 that has a path that contains       *}
{*          [In(_X,_DOMAIN),A(_X,_M,_E)]                            *}
{*    which logically implies In(_E,_RANGE), then we can remove b1  *}
{*    from the candidate Binds.                                     *}
{* The logical implication goes via attribute typing: _DOMAIN or    *}
{* one of its superclasses has an attribute category                *}
{*    P(_,SUPER,_M,_RANGE). Them, the variable _E in A(_X,_M,_E)    *}
{* must fulfill In(_E,_RANGE). So, if the path of b2 is true, then  *}
{* the path -f b1 must also be true. The Binds bz binds more        *}
{* variables. Hence we skip the candidate Binds b1.                 *}
{* The two Binds b1,b2 are necessarily different. Hence we only     *}
{* eliminate b1 if there are at least two candidate Binds. Hence,   *}
{* we do not create an empty binding list via this elimination step.*}


isDependentBinding(_b1,[_b2|_rest]) :-
  isDependentBinds(_b1,_b2),
  !.

isDependentBinding(_b1,[_b2|_rest]) :-
  isDependentBinding(_b1,_rest).


isDependentBinds(_b1,_b2) :-
  _b1 = Binds(_c1,_v1,[In(_E,_RANGE)],1),
  _b2 = Binds(_c2,_v2,_path2,_len2),
  _len2 > 1,
  pc_member(In(_X,_DOMAIN),_path2),
  pc_member(A(_X,_M,_E),_path2),
  pc_member(_E,_c1),
  pc_member(_E,_c2),
  pc_member(_X,_c2),
  is_id(_DOMAIN),
  is_id(_RANGE),
  prove_literal(Isa(_DOMAIN,_SUPER)),
  retrieve_proposition(P(_,_SUPER,_M,_RANGE)),
  !.




{* optimizeLits unfortunately reverses the original order of *}
{* literals in Binds(...). Thus, we have to rereverse it.    *}

rereverseOrder([],_sofar,_sofar) :- !.

rereverseOrder([_x|_r],_sofar,_res) :-
  rereverseOrder(_r,[_x|_sofar],_res).


{* all lits checked for redundancy: *}
optimizeLits(_BoundVars,[],_len,_sofar,_sofar,_len) :-!.

{* case 1: we don't need _lit. Note that we have to check *}
{* with _restlits of the list and also with the already   *}
{* processed lits in _sofar!                              *}
optimizeLits(_BoundVars,[_lit|_restlits],_len,_sofar,_newlits,_newlen) :-
  (redundantLit(_BoundVars,_lit,_restlits); redundantLit(_BoundVars,_lit,_sofar)),
  !,
  _len1 is _len - 1,                             {* shall have one literal less *}
  optimizeLits(_BoundVars,_restlits,_len1,_sofar,_newlits,_newlen).

{* else: we need _lit *}
optimizeLits(_BoundVars,[_lit|_restlits],_len,_sofar,_newlits,_newlen) :-
  optimizeLits(_BoundVars,_restlits,_len,[_lit|_sofar],_newlits,_newlen).



{* redundantLit just gets rid of In(x,c) predicates that         *}
{* are covered by A(x,m,y) or similar. We make sure that x is a  *}
{* variable that is bound to a constant during partial evaluation*}

redundantLit(_BoundVars,In(_x,_c),[A(_x,_m,_y)|_]) :-
  pc_member(_x,_BoundVars),
  WriteTrace(veryhigh,MetaBindingPath,[In(_x,_c),' covered by ',A(_x,_m,_y)]),
  !.
redundantLit(_BoundVars,In(_y,_c),[A(_x,_m,_y)|_]) :-
  pc_member(_x,_BoundVars),
  WriteTrace(veryhigh,MetaBindingPath,[In(_y,_c),' covered by ',A(_x,_m,_y)]),
  !.
redundantLit(_BoundVars,In(_x,_c),[Ai(_x,_m,_y)|_]) :-
  pc_member(_x,_BoundVars),
  WriteTrace(veryhigh,MetaBindingPath,[In(_x,_c),' covered by ',Ai(_x,_m,_y)]),
  !.
redundantLit(_BoundVars,In(_y,_c),[Ai(_x,_m,_y)|_]) :-
  pc_member(_x,_BoundVars),
  WriteTrace(veryhigh,MetaBindingPath,[In(_y,_c),' covered by ',Ai(_x,_m,_y)]),
  !.
{* ticket #162, #330 *}
redundantLit(_BoundVars,In(_x,_c),[_lit|_]) :-
  (_lit = A_label(_x,_m,_y,_n);_lit = Ae_label(_x,_m,_y,_n)),
  pc_member(_x,_BoundVars),
  WriteTrace(veryhigh,MetaBindingPath,[In(_x,_c),' covered by ',_lit]),
  !.
redundantLit(_BoundVars,In(_y,_c),[_lit|_]) :-
  (_lit = A_label(_x,_m,_y,_n);_lit = Ae_label(_x,_m,_y,_n)),
  pc_member(_y,_BoundVars),
  WriteTrace(veryhigh,MetaBindingPath,[In(_y,_c),' covered by ',_lit]),
  !.


{* ticket #207: improve support for A_e *}
redundantLit(_BoundVars,In(_y,_c),[A_e(_x,_m,_y)|_]) :-
  pc_member(_x,_BoundVars),
  WriteTrace(veryhigh,MetaBindingPath,[In(_x,_c),' covered by ',A_e(_x,_m,_y)]),
  !.
redundantLit(_BoundVars,In(_y,_c),[A_e(_x,_m,_y)|_]) :-
  pc_member(_y,_BoundVars),
  WriteTrace(veryhigh,MetaBindingPath,[In(_y,_c),' covered by ',A_e(_x,_m,_y)]),
  !.





redundantLit(_BoundVars,_lit,[_|_rest]) :-
  redundantLit(_BoundVars,_lit,_rest).

{* end optimizeBindingList by M. Jeusfeld *}




{-------------------------------------
substituteBP:
In the input-binding structure the arguments in the first list
are replaced by the corresponding of the second list.
}

substituteBP(Binds(_c,_v,_lits,_cost),_vcs,_newVcs,Binds(_newC,_newV,_newLits,_cost)) :-
	substElemsInList(_c,_vcs,_newVcs,_newC),
	substElemsInList(_v,_vcs,_newVcs,_newV),
 	substituteLits(_lits,_vcs,_newVcs,_newLits).


{-----------------------------LOCAL PART ----------------}

{
cleanDetInfoList(_lit,_vBound,_detInfo,_newDetInfo)
_lit is the literal evaluated
_vBound are the Variables bound by this evaluation
_detInfo is a list of determiner infos for a variable
_newDetInfo is this list after deleting some entries:
	All entries describing the effects of the evaluation of _lit are deleted, because
	_lit has been evaluated once and can'y be evaluated twice (2nd case)
	All entries which would add at least one of the variables bound when evaluating
	_lit to the list of variables to bind (2nd argument of DI-Structure), when a certain literal
	is evaluated (4rth case)


}
cleanDetInfoList(_,_,[],[]) .
cleanDetInfoList(_det,_vBound,[DI(_det,_,_,_)|_dIs],_newDIs) :- !,
	cleanDetInfoList(_det,_vBound,_dIs,_newDIs).
cleanDetInfoList(_det1,_vBound,[DI(_det2,_c,_v,_cost)|_dIs],[DI(_det2,_c,_v,_cost)|_newDIs]) :-
 	_det1 \=_det2,
	listIntersection(_c,_vBound,[]),!,
 	cleanDetInfoList(_det1,_vBound,_dIs,_newDIs).
cleanDetInfoList(_det1,_vBound,[DI(_det2,_c,_,_)|_dIs],_newDIs) :-
 	_det1 \= _det2,
	listIntersection(_c,_vBound,_l),
	not_empty(_l),
 	cleanDetInfoList(_det1,_vBound,_dIs,_newDIs).


{
cleanDetInfoLists(_det,_vBound,_vInds,_detInfos,_remInd,_newDetInfos)
cleanDetInfoList is envoked for all Determiner info lists of those variables not
bound by evaluating _lit. For those bound, the hole list is deleted, because varaibles
are bound only once in a path
}
cleanDetInfoLists(_,_,[],[],[],[]) .
cleanDetInfoLists(_det,_vBound,[_vInd|_vInds],[_detInfo|_detInfos],[_vInd|_remInd],[_newDetInfo|_newDetInfos]) :-
	nonmember(_vInd,_vBound),!,
 	cleanDetInfoList(_det,_vBound,_detInfo,_newDetInfo),
 	cleanDetInfoLists(_det,_vBound,_vInds,_detInfos,_remInd,_newDetInfos).
cleanDetInfoLists(_det,_vBound,[_vInd|_vInds],[_|_detInfos],_remInd,_newDetInfos) :-
	memberchk(_vInd,_vBound),!,
 	cleanDetInfoLists(_det,_vBound,_vInds,_detInfos,_remInd,_newDetInfos).

{
computeAllCosts(_mVars,_cons,_bList,_cList)
_cons are the constants
_bList contains a list of Binds - predicates, each predicate represents a BindingPath
_cList contains for each Binds- predicate the value of the cost function
}
computeAllCosts(_mVars,_,[],[]) .
computeAllCosts(_mVars,_cons,[Binds(_,_,_path,_length)|_bPs],[_c|_costList]) :-
	computeCost(_mVars,_cons,_path,_length,_c),
	computeAllCosts(_mVars,_cons,_bPs,_costList).

{
computeCost(_cons,_path,_length,_c):
_cons is the list of constants
_path is a list of Literals, which are evaluated according to their appearance in this list
_ length is the length of this list
_c is the value of cost-function of the _path
}
computeCost(_mVars,_cons,_path,_length,_cost) :-
	computeCostAcc(_mVars,_cons,_path,1,_cost1),
 	_cost is _cost1 * _length.

{
computeCostAcc(_mVars,_cons,_path,_cost till now,_cost):
_cons is the list of constants
_path is a list of Literals, which are evaluated according to their appearance in this list
_cost till now is the _cost of the previous evaluations
_c is the value of the cost-function after evluating the whole path
}
computeCostAcc(_mVars,_,[],_cost,_cost) :- !.
computeCostAcc(_mVars,_cons,[_lit|_lits],_costUntilNow,_cost) :-
	litParts(_lit,_,_args),
	listIntersection(_args,_cons,_instYet),
 	determines(_lit,_instYet,_instNew,_costOfStep),
        joinCorrection(_mVars,_lit,_lits,_corr),
	_newCost is _costUntilNow * _costOfStep // _corr + 1, 
	append(_instNew,_cons,_newCons),
 	computeCostAcc(_mVars,_newCons,_lits,_newCost,_cost).

{* ticket #264: if cost computation fails for one path, we set its costs as maxcost+1 *}
{* so that the costs of the other paths still are calculated.                         *}
computeCostAcc(_mVars,_,_,_,_cost) :-
       get_cb_feature(maxCostLevel,_mcost),
       _cost is _mcost+1. 


joinCorrection(_mVars,A(_j,_m,_x),_lits,10) :-
  pc_member(A(_j,_m,_y),_lits),
  pc_member(_x,_mVars),pc_member(_y,_mVars),
  !.


joinCorrection(_mVars,_lit,_lits,1).




{
 cutDIList(_diList1,_diList,_clevel):
_diList1 is a list of determiner infos sorted by cost
_diList contains those elements with cost <= _clevel
}
cutDIList([],[],_) .
cutDIList([DI(_l,_c,_v,_cost)|_],[],_clevel) :-
	_cost > _clevel.
cutDIList([DI(_l,_c,_v,_cost)|_diList],[DI(_l,_c,_v,_cost)|_diListNew],_clevel) :-
	 _cost =< _clevel,
 	cutDIList(_diList,_diListNew,_clevel).

 {
fillDeterminerList(_args,_vars,_cons,_diList,_varDetList1,_varDetList2)
_args contains the arguments of the actual literal
_vars are the variables
_cons are the constants
_diList is a list of determiner infos with cost < _cost
_ varDetList1 contains for each variable a list of possible determining Literals with
maximal cost _cost found till now.
_ varDetList2 is a list of Lists:
for each variable this structure contains a list of possible determining Literals with
maximal cost _cost.
}
fillDeterminerList(_,[],_,_,[],[]) .
fillDeterminerList(_args,[_v|_vars],_cons,_diList,[_vDetList1|_varsDetList1],[_vDetList|_varsDetList]) :-
	listIntersection([_v],_args,[_v]),
 	testDetCondition(_v,_cons,_diList,_vDetList2),
 	append(_vDetList1,_vDetList2,_vDetList),
 	fillDeterminerList(_args,_vars,_cons,_diList,_varsDetList1,_varsDetList).
fillDeterminerList(_args,[_v|_vars],_cons,_diList,[_vDetList|_varsDetList1],[_vDetList|_varsDetList]) :-
	listIntersection([_v],_args,[]),
 	fillDeterminerList(_args,_vars,_cons,_diList,_varsDetList1,_varsDetList).

{
fillDeterminerStructure(_mVs,_cons,_vars,_lits,_cost,_varDetList):
_mVs are the meta-Variables
_cons are the constants appearing in the Literals
_vars  are the variables, this list is used as index to the _varDetList components
_lits are the Literals
_cost is the maximal cost allowed
_ varDetList is a list of Lists:
for each variable this structure contains a list of possible determining Literals with
maximal cost _cost.
}
fillDeterminerStructure(_mVs,_cons,_vars,_lits,_cost,_varDetList) :-
	initVarDetList(_vars,_varDetList1),
 	findPossDeterminersOfVars(_mVs,_lits,_cons,_vars,_cost,_varDetList1,_varDetList).


{
findBindingPathsForVariables(_mVs,_cons,_vars,_clevel,_varDetList,_bPs)
_mVs is the list of variables to bind
_cons is the list of constants
_vars is the list of variables
_clevel is the maximal cost level
_varDetList is the dteerminer structure:
for each variable this structure contains a list of possible determining Literals with
maximal cost _clevel.
}
findBindingPathsForVariables(_mVs,_cons,_vars,_clevel,_varDetList,_bPs) :-
	saveSetof(_bPaths,tryToFindPath(_mVs,_cons,_vars,_varDetList,_clevel,_bPaths),_bPs)
{,	write(saveSetof(_bPaths,tryToFindPath(_mVs,_cons,_vars,_varDetList,_clevel,_bPaths),_bPs)),nl,nl}.

 {
findCheaperBinding(_b,_c,_bList,_cList,_binding,_bcost).
_b is the cheapest binding path found till now
_c is the cost of this path
_bList are the binding paths to compare b with
_clist are the corresponding values of the cost function
_binding is the cheapest path wrt. the value of the cost function found in [_b|_bList]
_bcost is the cost of the selected path _binding
}
findCheaperBinding(_b,_c,[],[],_b,_c) .
findCheaperBinding(_b,_c,[_|_bList],[_cGreaterEq|_cList],_binding,_bcost) :-
	_cGreaterEq >= _c,!,
	findCheaperBinding(_b,_c,_bList,_cList,_binding,_bcost).
 findCheaperBinding(_,_c,[_bCheaper|_bList],[_cCheaper|_cList],_binding,_bcost) :-
	_cCheaper < _c,!,
	findCheaperBinding(_bCheaper,_cCheaper,_bList,_cList,_binding,_bcost).

{
findPossDeterminersOfVars(_mVs,_lits,_cons,_vars,_cost,_varDetList1,_varDetList).
_cons are the constants appearing in the Literals
_vars  are the variables
_lits are the Literals
_cost is the maximal cost allowed
_ varDetList1 contains for each variable this structure contains a list of possible determining Literals with
maximal cost _cost found till now.
_ varDetList is a list of Lists:
for each variable this structure contains a list of possible determining Literals with
maximal cost _cost.
}

findPossDeterminersOfVars(_,[],_,_,_,_v,_v) .

findPossDeterminersOfVars(_mVs,[_lit|_lits],_cons,_vars,_cost,_varDetList1,_varDetList) :-
 	determines3(_cons,_lit,_diList0),
	cutDIList(_diList0,_diList,_cost),
	litParts(_lit,_,_args),
	fillDeterminerList(_args,_vars,_cons,_diList,_varDetList1,_varDetList2),
 	findPossDeterminersOfVars(_mVs,_lits,_cons,_vars,_cost,_varDetList2,_varDetList).



 {
initVarDetList(_vars,_varDetList)
_vars
_varDetList
for each element of _vars an empty list is added to _varDetList
}
initVarDetList([],[]) .
initVarDetList([_|_vars],[[]|_detList]) :-
	initVarDetList(_vars,_detList).
{
removeDetInfoList
}
removeDetInfoList(_v,_vars,_listOfDetInfoList,_detInfoList,_remVars,_remListOfDetInfoList) :-
	position(_v,_vars,_pos),
 	giveNthMember(_listOfDetInfoList,_pos,_detInfoList),
 	removePosElem(_pos,_listOfDetInfoList,_remListOfDetInfoList),
 	removePosElem(_pos,_vars,_remVars).

{
selectCheapestPath1(mVars,cons,bPaths,bPath,bcost)
Find that element bPath in bPaths with cost function is minimal; minimal cost is returned in bcost
}
selectCheapestPath1(_mVars,_cons,[_b],_b,_bcost) :-
        computeAllCosts(_mVars,_cons,[_b],[_bcost]),
        !.
selectCheapestPath1(_mVars,_cons,[_b|_bList],_binding,_bcost) :-
	not_empty(_bList),
 	computeAllCosts(_mVars,_cons,[_b|_bList],[_c|_cList]),
{* writeCostsBinds([_b|_bList],[_c|_cList]),nl, *}
 	findCheaperBinding(_b,_c,_bList,_cList,_binding,_bcost).


writeCostsBinds([],[]) :- !.

writeCostsBinds([_b|_bList],[_c|_cList]) :-
  write(_c),write(' : '),write(_b),nl,
  writeCostsBinds(_bList,_cList).


testAllmVarDet([],_,[]).
testAllmVarDet([DI(_lit,_c,_v,_evCost)|_diList],_mVs,[DI(_lit,_c,_v,_evCost)|_erg]) :-
	listDifference(_mVs,_v,_res),
	_res == [],!,
	testAllmVarDet(_diList,_mVs,_erg).
testAllmVarDet([DI(_lit,_c,_v,_evCost)|_diList],_mVs,_erg) :-
	listDifference(_mVs,_v,_res),
	_res \== [],!,
	testAllmVarDet(_diList,_mVs,_erg).
{
testDetCondition
}
testDetCondition(_,_,[],[]) .
testDetCondition(_var,_cons,[DI(_l,_c,_v,_cost)|_dis],[DI(_l,_c,_v,_cost)|_goodDis]) :-
	memberchk(_var,_v),
 	nonmember(_var,_c),
 	listIntersection(_v,_cons,[]),!,
 	testDetCondition(_var,_cons,_dis,_goodDis).
testDetCondition(_var,_cons,[DI(_,_c,_v,_)|_dis],_goodDis) :-
	testDetCondition(_var,_cons,_dis,_goodDis).


{
tryToFindPath(_mVs,_cons,_vars,_varsDetList,_clevel,_bPath)
_mVs is the list of variables to bind
_cons is the list of constants
_vars is the list of variables
_varsDetList is the determiner structure:
for each variable this structure contains a list of possible determining Literals with
maximal cost _clevel.
_clevel is the maximal cost level
_bPath contains a BindingPath
}
tryToFindPath(_mVs,_cons,_vars,_varsDetList,_clevel,_bPath) :-
	pc_member(_mV,_mVs),
 	removeDetInfoList(_mV,_vars,_varsDetList,_detInfoList,_newVars,_newVarsDetList),
	pc_member(DI(_det,_c,_v,_cost),_detInfoList),
 	tryToFindPathWithLit(_mVs,DI(_det,_c,_v,_cost),_newVarsDetList,_cons,_newVars,_clevel,_bPath).

{
tryToFindPathWithLit(_mVars,_detInfo,_varsDetList,_cons,_vars,_clevel,_bPath)
_mVars: List of variables to bind
_detInfo: Starting literal infos
_varsDetList: Infos for remaining variables
_cons: constants
_vars: index to _varsDetList
_clevel: costlevel
_bPath: one possible BindingPath, starting with starting literal
}
tryToFindPathWithLit(_mVars,_detInfo,_varsDetList,_cons,_vars,_clevel,_bPath) :-
   tryToFindPathWithLitAcc(_mVars,_detInfo,_vars,_varsDetList,_cons,_clevel,Binds([],_vars,[],0),_bPath).


tryToFindPathWithLitAcc(_mVars,DI(_det,_c,_v,_),_,_,_cons,_,Binds(_varsBound,_vars,_detList,_anz),Binds(_varsBoundNow,_remVars,[_det|_detList],_newAnz)) :-
	_newAnz is _anz + 1,
        get_cb_feature(bindingPathLen,_maxblen),
        _newAnz =< _maxblen,
	subSetList(_c,_cons),
	subSetList(_mVars,_v),!,
 	listDifference(_vars,_v,_remVars),
 	append(_v,_varsBound,_v1),
	 removeMultiEntries(_v1,_varsBoundNow).


tryToFindPathWithLitAcc(_mVs,DI(_det,_c,_v,_),_rVars,_rVarsDetList,_cons,_clevel,Binds(_varsBound,_vars,_detList,_anz),_bPath) :-
 	_newAnz is _anz + 1,
        get_cb_feature(bindingPathLen,_maxblen),
        _newAnz =< _maxblen,
	listDifference(_mVs,_v,_mVarsNeedInst),
 	listDifference(_c,_cons,_newVarsNeedInst),
	append(_mVarsNeedInst,_newVarsNeedInst,_needInst1),
 	removeMultiEntries(_needInst1,_needInst),
 	listDifference(_vars,_v,_remVars),
 	append(_v,_varsBound,_v1),
 	removeMultiEntries(_v1,_varsBoundNow),
 	cleanDetInfoLists(_det,_v,_rVars,_rVarsDetList,_rVars1,_rVarsDetList1),
 	pc_member(_nextVar,_needInst),
 	removeDetInfoList(_nextVar,_rVars1,_rVarsDetList1,_detInfoList,_newVars,_newVarDetList),
	pc_member(DI(_newDet,_newC,_newV,_newCost),_detInfoList),
	tryToFindPathWithLitAcc(	_needInst,
					DI(_newDet,_newC,_newV,_newCost),
					_newVars,_newVarDetList,
					_cons,
					_clevel,
					Binds(_varsBoundNow,_remVars,[_det|_detList],_newAnz),
					_bPath).


 {----------------------------PREDICATES not needed----------}
{
bListToStringList([],[],[]) .
bListToStringList([Binds(_varsBound,_varsFree,_lits,_w)|_bps],[_bpString|_bpsString],[_w|_ws]) :- 	 bToString(Binds(_varsBound,_varsFree,_lits,_w),_bpString),
 bListToStringList(_bps,_bpsString,_ws).


bToString(Binds(_varsBound,_varsFree,_lits,_),"Binds("++_vbs++" ,"++_vfs++" ,"++_litsStr++") ,") :- 	 unitListToString(_varsBound,_vbs),
 unitListToString(_varsFree,_vfs),
 literalListToString(_lits,_litsStr).

testBP1(_cs,_vs,_ls,_clevel) :- 	 stringListToUnitList(_cs,_cons),
 stringListToUnitList(_vs,_vars),
 stringListToLiteralList(_ls,_lits),
 findPossDeterminersOfVars(_cons,_vars,_lits,_clevel,_varsDetList),
 writeVarDetList(_vars,_varsDetList,StdOut).

writeVarDetList([],_,_) .

writeVarDetList([_v|_vars],[_detInfo|_detInfos],_streamOut) :- 	 writeString(_streamOut,"
  "),
 unitToString(_v,_u),
 writeString(_streamOut,_u),
 writeString(_streamOut,"	  "),
 detInfoListToString(_detInfo,_ds),
 writeString(_streamOut,_ds),
 writeVarDetList(_vars,_detInfos,_streamOut).
 }

