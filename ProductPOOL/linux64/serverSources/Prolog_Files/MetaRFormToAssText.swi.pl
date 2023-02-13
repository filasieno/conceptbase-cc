/**
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


This license is a FreeBSD-style copyright license.
Legal home of the FreeBSD copyright license: http://www.freebsd.org/copyright/freebsd-license.html
**/
/*************************************************************************
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
* Das Modul MetaRFormToAssText dient der Rueckuebersetzung einer
* generierten Formel in das $$-Format.
*
* Beispiel:
* reCompileRFormula(
* rangeconstr(forall([x],[In(x,Patient)],exists([y],[In(y,Illness),A(x,suffers,y)],TRUE))),
* forall x/Patient   (exists y/Illness   A(x,suffers,y) and (TRUE))
* )
*
*
*/
:- module('MetaRFormToAssText',[
'reCompileRFormulaList'/2
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').

:- use_module('MetaRFormulas.swi.pl').

:- use_module('MetaUtilities.swi.pl').
:- use_module('GeneralUtilities.swi.pl').




:- use_module('PrologCompatibility.swi.pl').

:- use_module('SemanticOptimizer.swi.pl').

:- use_module('VarTabHandling.swi.pl').




:- use_module('Literals.swi.pl').




:- style_check(-singleton).





reCompileRFormulaList([],[]).
reCompileRFormulaList([_rf_0|_rfs],[_assText|_assTexts]) :-
	tryOptimizeRangeForm(_rf_0,_rf_1),
	'IdsToNamesInFormula'(_rf_1,_rf),!,
	reCompileRFormula(_rf,_assText1),!,
	pc_atomconcat(['$ ',_assText1,' $'],_assText),
	reCompileRFormulaList(_rfs,_assTexts),!.

/** try to remove at least some of the resundant literals from the generated formula **/
/** Examples are In(MyClass,Proposition) where MyClass is a constant.                **/
/** We have to be carefull not to remove those In(x,c) where x is a variable since   **/
/** the reCompileRFormula procedure needs them to create the vraiable ranges like    **/
/** x/c.                                                                             **/
/** The flag optimizeLevel controls optimizeRangeform in such a way that it will     **/
/** only do the most simplest optimizations if optimizeLevel=0. See also             **/
/** SemanticOptimizer.pro.                                                           **/

tryOptimizeRangeForm(_rf,_newrf) :-
	'VarTabLookup_ranges'([]),    /** currently, the VarTab is empty, i.e. we do not interfer with other formulas **/
	getRangesFromRangeForm(_rf,_toInsert),   /** these ranges would not to be defined in VarTab **/
	'VarTabInsertRanges'(_toInsert),
	'VarTabLookup_ranges'(_rang),
        evalGroundPredicates(_rf,_rf1),   /** ticket #267 **/
	getFlag(optimizeLevel,_old),
	setFlag(optimizeLevel,0),    /** only do minimal optimizations **/
	optimizeRangeform(_rf1,_newrf),  /** remove redundant lits to provide more readable code */
	setFlag(optimizeLevel,_old),
	'VarTabInit',    /** empty the VarTab again **/
	!.
tryOptimizeRangeForm(_rf,_rf).



/** replace certain ground predicates by TRUE or FALSE **/
/** Ticket #267                                        **/

evalGroundPredicates(_f,_newf) :-
  do_evalGroundPredicates(_f,_newf),
  !.
evalGroundPredicates(_f,_f).  /** catchall **/


do_evalGroundPredicates(rangeconstr(_rf),rangeconstr(_newrf)) :-
  do_evalGroundPredicates(_rf,_newrf).

do_evalGroundPredicates(rangerule(_vars,_rf,_concllit),rangerule(_vars,_newrf,_concllit)) :-
  do_evalGroundPredicates(_rf,_newrf).

/** better do not simplify rangerules via ground predicates
   they can become true/false in future database states
do_evalGroundPredicates(rangerule(_vars,forall(_vars,_lits,'FALSE'),_lit),
                        rangerule(_vars,forall(_vars,_newlits,'FALSE'),_lit)) :-
  
  evalGroundLits(_lits,_newlits1),
  pruneTRUE(_newlits1,_newlits).
**/

do_evalGroundPredicates(forall(_vars,_lits,_subFormula),forall(_vars,_newlits,_subFormula1)) :-
  evalGroundLits(_lits,_newlits1),
  pruneTRUE(_newlits1,_newlits),
  do_evalGroundPredicates(_subFormula,_subFormula1).


do_evalGroundPredicates(exists(_vars,_lits,_subFormula),exists(_vars,_newlits,_subFormula1)) :-
  evalGroundLits(_lits,_newlits1),
  pruneTRUE(_newlits1,_newlits),
  do_evalGroundPredicates(_subFormula,_subFormula1).


do_evalGroundPredicates(and(_f1,_f2),and(_newf1,_newf2)) :-
  do_evalGroundPredicates(_f1,_newf1),
  do_evalGroundPredicates(_f2,_newf2).


do_evalGroundPredicates(or(_f1,_f2),or(_newf1,_newf2)) :-
  do_evalGroundPredicates(_f1,_newf1),
  do_evalGroundPredicates(_f2,_newf2).

do_evalGroundPredicates(not(_f1),not(_newf1)) :-
  do_evalGroundPredicates(_f1,_newf1).

do_evalGroundPredicates(_lit,_newlit) :-
  evalGroundLit(_lit,_newlit).



evalGroundLits([],[]) :- !.

evalGroundLits([_lit|_lits],[_newlit|_newlits]) :- 
  evalGroundLit(_lit,_newlit),
  evalGroundLits(_lits,_newlits).


/** conservative check whether the predicate is TRUE or FALSE **/
evalGroundLit('In'(_x,_c),'TRUE') :-
  is_id(_x),
  is_id(_c),
  prove_edb_literal('In'(_x,_c)),
  !.

evalGroundLit('A'(_x,_m,_y),'TRUE') :-
  is_id(_x),
  is_id(_y),
  prove_edb_literal('A_e'(_x,_m,_y)),
  !.

evalGroundLit('EQ'(_x,_x),'TRUE') :-
  !.

evalGroundLit('EQ'(_x,_y),'FALSE') :-
  is_id(_x),
  is_id(_y),
  _x \== _y,
  !.

evalGroundLit('NE'(_x,_y),'TRUE') :-
  is_id(_x),
  is_id(_y),
  _x \== _y,
  !.

/** ticket 301: plain removal can lead to undesired elimination of ranges for variables 
evalGroundLit(NE(_x,_x),'FALSE') :-
  is_id(_x),
  !.
**/

/** otherwise **/
evalGroundLit(_lit,_lit).


pruneTRUE([],[]) :- !.

pruneTRUE(['TRUE'],['TRUE']) :- !.

pruneTRUE(['TRUE'|_lits],_prunedlits) :- 
  pruneTRUE(_lits,_prunedlits),
  !.

pruneTRUE([_lit|_lits],[_lit|_prunedlits]) :- 
  pruneTRUE(_lits,_prunedlits).






/** Funktoren: and und or **/
reCompileRFormulaListWithFunctor([_rf],_,_assText) :-
	!,reCompileRFormula(_rf,_assText).
reCompileRFormulaListWithFunctor([_rf|_rfs],_funktor,_assText) :-
	_rfs \== [],
	reCompileRFormula(_rf,_assText1),!,
	reCompileRFormulaListWithFunctor(_rfs,_funktor,_assText2),!,
	pc_atomconcat([_assText1,' ',_funktor,' ',_assText2],_assText).


/** Constraint: keine besondere Behandlung **/

reCompileRFormula(rangeconstr(_rf),_assText) :-
	!,reCompileRFormula(_rf,_assText),!.


/** Rule:
   Der Term mit dem rangerule - Funktor ist fuer den Benutzer die
   aussere Implikation.
   - Sie muss einen All-Quantor als Funktor haben
     und die Variablen im Folgerungsliteral muessen mit diesem
     Allquantor an KLassen gebunden werden.
   - die rangeform in _rf ist negiert worden, als die Metaformel
     von der $$-Form in die rangeform gebracht wurde. Diese
     Negation wird hier rueckgaengig gemacht.
**/
reCompileRFormula(rangerule(_vars,_rf,_lit),_assText) :-
	findVarInLitsRule(_vars,_rf,_inLits,_rfNew1),
	_inLits \== [],!,
	inLitsToQuants(_inLits,_quantAtoms),!,
	litToAtom(_lit,_litAtom),!,
/*not wegen "convertCondition" aus MSFOLassertionSimplifier*/
	pushNegationInwardsRF(not(_rfNew1),_rfNew),!,
	reCompileRFormula(_rfNew,_subAtom),!,
        encloseInBrackets(_rfNew,_subAtom,_subAtom1),
        implToAtom(_subAtom1,_litAtom,_implAtom),
	pc_atomconcat(['forall',' ',_quantAtoms,' ',_implAtom],_assText),!.

reCompileRFormula(rangerule(_vars,_rf,_lit),_assText) :-
	findVarInLitsRule(_vars,_rf,_inLits,_rfNew1),
	_inLits == [],!,
	litToAtom(_lit,_litAtom),!,
/*not wegen "convertCondition" aus MSFOLassertionSimplifier*/
	pushNegationInwardsRF(not(_rfNew1),_rfNew),!,
	reCompileRFormula(_rfNew,_subAtom),!,
        encloseInBrackets(_rfNew,_subAtom,_subAtom1),
        implToAtom(_subAtom1,_litAtom,_assText),
        !.

/** forall **/

/** 1. Fall: Allquantor ueberfluessig **/
reCompileRFormula(forall([],[],_subFormula),_assText) :-
	reCompileRFormula(_subFormula,_assText),!.

/** 2. Fall: keine In-Literale: Implikation statt forall **/
reCompileRFormula(forall(_vars,_lits,_subFormula),_assText) :-
	findVarInLits(_vars,forall(_vars,_lits,_subFormula),_inLits,_rfNew),
	_inLits == [],!,
	litsToAtom(_lits,_atom1,and),!,
	reCompileRFormula(_subFormula,_subAtom),!,
        encloseInBrackets(_subFormula,_subAtom,_subAtom1),
	pc_atomconcat([_atom1,' ==> ',_subAtom1],_assText),!.

/** 3. Fall: Alle Literale werden benoetigt, um Variablen zu binden
  -> kein Implikationspfeil
**/
reCompileRFormula(forall(_vars,_lits,_subFormula),_assText) :-
	findVarInLits(_vars,forall(_vars,_lits,_subFormula),_inLits,_rfNew),
	_inLits == _lits,!,
	inLitsToQuants(_inLits,_quantAtoms),!,
	reCompileRFormula(_subFormula,_subAtom),!,
        encloseInBrackets(_subFormula,_subAtom,_subAtom1),
	pc_atomconcat(['forall',' ',_quantAtoms,' ',_subAtom1],_assText),!.

/** case 3a: formula has the form forall X inLits and lit ==> FALSE  **/
/**  generate forall x1/C1 x2/C2 ... not lit                         **/ 
reCompileRFormula(forall(_vars,_lits,'FALSE'),_assText) :-
	findVarInLits(_vars,forall(_vars,_lits,'FALSE'),_inLits,_rfNew),
	append(_inLits,[_lit],_lits),!,
	inLitsToQuants(_inLits,_quantAtoms),!,
        termToAtom(_lit,_litText),
	pc_atomconcat(['forall',' ',_quantAtoms,' not ',_litText],_assText),!.

/** 4. Fall: normal **/
reCompileRFormula(forall(_vars,_lits,_subFormula),_assText) :-
	findVarInLits(_vars,forall(_vars,_lits,_subFormula),_inLits,_rfNew),
	listDifference(_lits,_inLits,_remLits),
	_remLits \== [],!,
	inLitsToQuants(_inLits,_quantAtoms),!,
        balanceLits(_remLits,_subFormula,_remLits1,_subFormula1),  /** see below **/
	litsToAtom(_remLits1,_atom1,and),!,
	reCompileRFormula(_subFormula1,_subAtom),!,
        encloseInBrackets(_subFormula,_subAtom,_subAtom1),
	pc_atomconcat(['forall',' ',_quantAtoms,' ',_atom1,' ==> ',_subAtom1],_assText),!.

/**exists: analog zu forall **/
reCompileRFormula(exists([],[],_subFormula),_assText) :-
	reCompileRFormula(_subFormula,_assText),!.

/** special case: subFormula=TRUE, no inLits **/
reCompileRFormula(exists(_vars,_lits,'TRUE'),_assText) :-
	findVarInLits(_vars,exists(_vars,_lits,'TRUE'),_inLits,_rfNew),
        _lits \== [],
	_inLits == [],!,
	litsToAtom(_lits,_assText,and),!.

reCompileRFormula(exists(_vars,_lits,_subFormula),_assText) :-
        findVarInLits(_vars,exists(_vars,_lits,_subFormula),_inLits,_rfNew),
        _inLits == [],!,
        litsToAtom(_lits,_atom1,and),!,
        reCompileRFormula(_subFormula,_subAtom),!,
        encloseInBrackets(_subFormula,_subAtom,_subAtom1),
        pc_atomconcat([_atom1,' and ',_subAtom1],_assText),!.

reCompileRFormula(exists(_vars,_lits,_subFormula),_assText) :-
	findVarInLits(_vars,exists(_vars,_lits,_subFormula),_inLits,_rfNew),
	_inLits == _lits,!,
	inLitsToQuants(_inLits,_quantAtoms),
	reCompileRFormula(_subFormula,_subAtom),!,
        encloseInBrackets(_subFormula,_subAtom,_subAtom1),
	pc_atomconcat(['exists',' ',_quantAtoms,' ',_subAtom1],_assText),!.

/** special case: subFormula=TRUE, some remLits **/
reCompileRFormula(exists(_vars,_lits,'TRUE'),_assText) :-
	findVarInLits(_vars,exists(_vars,_lits,'TRUE'),_inLits,_rfNew),
	listDifference(_lits,_inLits,_remLits),
	_remLits \== [],!,
	inLitsToQuants(_inLits,_quantAtoms),
	litsToAtom(_remLits,_atom1,and),
	pc_atomconcat(['exists',' ',_quantAtoms,' ',_atom1],_assText),!.

reCompileRFormula(exists(_vars,_lits,_subFormula),_assText) :-
        findVarInLits(_vars,exists(_vars,_lits,_subFormula),_inLits,_rfNew),
        listDifference(_lits,_inLits,_remLits),
        _remLits \== [],!,
        inLitsToQuants(_inLits,_quantAtoms),
        litsToAtom(_remLits,_atom1,and),
        reCompileRFormula(_subFormula,_subAtom),!,
        encloseInBrackets(_subFormula,_subAtom,_subAtom1),
        pc_atomconcat(['exists',' ',_quantAtoms,' ',_atom1,' and ',_subAtom1],_assText),!.


/** and, or: Liste von rangeforms nach $$ uebersetzten **/
reCompileRFormula(_rf,_assText) :-
	rFormulaParts(_rf,_funktor,[],[],_subFormulaList),
	memberchk(_funktor,[and,or]),!,
	reCompileRFormulaListWithFunctor(_subFormulaList,_funktor,_assText),!.

/** not: Formel mit not(..) einschliessen **/
reCompileRFormula(not(_rf),_assText) :-
	reCompileRFormula(_rf,_assText1),!,
	pc_atomconcat(['not',' ','(',_assText1,')'],_assText),!.

/** Literal: einfach in Aotm verwandeln **/
reCompileRFormula(_lit,_assText) :-
	rFormulaParts(_lit,_funktor,[],[],_subFormulaList),
	termToAtom(_lit,_assText),!.


/** some variables in vars may not occur in any In-Lit; then Proposition is takes as range **/
/** Ticket #285 **/

inLitsForOrphans([],_inLits,_inLits) :- !.

inLitsForOrphans([_v|_restvars],_inLits,_newinLits) :-
  member('In'(_v,_c),_inLits),
  inLitsForOrphans(_restvars,_inLits,_newinLits).

inLitsForOrphans([_v|_restvars],_inLits,_newinLits) :-
  inLitsForOrphans(_restvars,['In'(_v,'Proposition')|_inLits],_newinLits). 


implToAtom('TRUE',_rhs,_rhs) :- !.
implToAtom(_lhs,_rhs,_implAtom) :-
  pc_atomconcat([_lhs,' ==> ',_rhs],_implAtom).


/** 30-Mar-2005/M. Jeusfeld: enclose a subformula in brachets only when necessary, i.e. **/
/** when it starts with exists or forall. Literals as subfourmulas are not included in  **/
/** brackets. This avoids generating subexpressions like '(A(x,m,y))' which misleads    **/
/** parseAss.dcg into thinking that the first token after the bracket can be the label  **/
/** of an object.                                                                       **/

encloseInBrackets(_,'TRUE','TRUE') :-!.
encloseInBrackets(_,'FALSE','FALSE') :-!.

encloseInBrackets(_subFormula,_subAtom,_subAtom1) :-
  _subFormula =.. [_f|_],
  memberchk(_f,['exists','forall']),
  !,
  pc_atomconcat(['(',_subAtom,')'],_subAtom1).

encloseInBrackets(_subFormula,_subAtom,_subAtom).


/** 10-Mar-2005/M.Jeusfeld: This is a pure cosmetic change. Formulas of the **/
/** form "forall x/C lit1 and lit2 and ... and litn ==> FALSE"              **/
/** are transformed to                                                      **/
/**      "forall x/C lit1 and lit2 and ... ==> not litn"                    **/
/** This is logically equivalent but more appealing to the user.            **/

balanceLits(_remLits,'FALSE',_remLits1, _splitLit) :-
  splitLast(_remLits,[],_remLits1,_splitLit),
  !.

/** do nothing if the formula has not the format from above                 **/
balanceLits(_remLits,_subFormula,_remLits,_subFormula).


/** ticket #266: avoid  'not (x <> y)' **/
splitLast(['NE'(_x,_y)],_sofar,_sofar,'EQ'(_x,_y)) :-     /**   not (x <> y)  <=> (x=y)  **/
  _sofar \= [], 
  !.

splitLast([_lit],_sofar,_sofar,not(_lit)) :- 
  _sofar \= [], 
  !.

splitLast([_lit|_rest],_sofar,_restLits,_splitLit) :-
  _rest \= [], 
  append(_sofar,[_lit],_sofar1),
  splitLast(_rest,_sofar1,_restLits,_splitLit).



findVarInLits(_vars,_rf,_inLits,_rfNew) :-
        do_findVarInLits(_vars,_rf,_inLits1,_rfNew),
        inLitsForOrphans(_vars,_inLits1,_inLits).


do_findVarInLits(_vars,_rf,_inLits,_rfNew) :-
	rFormulaParts(_rf,_functor,_varsRF,_litsRF,_subFormula),
	filterInLitsForVars(_vars,[],_litsRF,_inLits),
	listDifference(_litsRF,_inLits,_litsRFNew),
	rFormulaParts(_rfNew,_functor,_varsRF,_litsRFNew,_subFormula),!.


findVarInLitsRule(_vars,_rf,_inLits,_rfNew) :-
        do_findVarInLitsRule(_vars,_rf,_inLits1,_rfNew),
        inLitsForOrphans(_vars,_inLits1,_inLits).


do_findVarInLitsRule(_vars,_rf,_inLits,_rfNew) :-
	rFormulaParts(_rf,_functor,_varsRF,_litsRF,_subFormula),
	filterInLitsForVars(_vars,[],_litsRF,_inLits),
	listDifference(_litsRF,_inLits,_litsRFNew),
	listDifference(_varsRF,_vars,_varsRFNew),
	rFormulaParts(_rfNew,_functor,_varsRFNew,_litsRFNew,_subFormula),!.


filterInLitsForVars(_vars,_,[],[]).
filterInLitsForVars(_vars,_varsBound,['In'(_x,_c)|_lits],_InLits) :-
	memberchk(_x,_varsBound),!,
	filterInLitsForVars(_vars,_varsBound,_lits,_InLits).
filterInLitsForVars(_vars,_varsBound,['In'(_x,_c)|_lits],['In'(_x,_c)|_InLits]) :-
	memberchk(_x,_vars),
	noBetterInLit('In'(_x,_c),_lits),
	!,
	filterInLitsForVars(_vars,[_x|_varsBound],_lits,_InLits).
filterInLitsForVars(_vars,_varsBound,[_lit|_lits],_InLits) :-
	filterInLitsForVars(_vars,_varsBound,_lits,_InLits).


/** noBetterInLit checks whether the candidate In(_x,_c) is really a good In-Lit to  **/
/** determine the type of the variable _x. For example, if we have                   **/
/** [In(x,Proposition),In(x,Employee)]  as candidates for building the type of       **/
/** variable x, then In(x,Employee) is preferable over In(x,Proposition). So, we     **/
/** avoid using the builtin classes as types for variables if possible.              **/
/** The selection of a good variable type is essential for the compilation of        **/
/** formulas generated from meta formulas. The type influences the compilation of    **/
/** attribution literals like A(x,m,y). If we would bind variable x to a builtin     **/
/** class like Proposition, then we shall not find the attribute category m.         **/
/** See also ConcernedClass and getConcernedClass in BDMLiteralDeps.                 **/

noBetterInLit('In'(_x,_c),_lits) :-
  \+ betterInLit('In'(_x,_c),_lits).

betterInLit('In'(_x,_c),_lits) :-
  member(_c,['Proposition','Attribute','Individual','InstanceOf','IsA']),
  member('In'(_x,_d),_lits).


'IdsToNamesInFormula'(_rf_0,_rf) :-
	rFormulaAnalysis(_rf_0,_,_constants,_),
	'Ids2NamesInTerm'(_rf_0,_rf,_constants),!.



inLitsToQuants([],' ').
inLitsToQuants(['In'(_x1,_c),'In'(_x2,_c),'In'(_x3,_c)|_inLits],_assText) :-
        termListToAtom([_x1,',',_x2,',',_x3,'/',_c],_atom1),!,
        inLitsToQuants(_inLits,_atom2),!,
        pc_atomconcat([_atom1,' ',_atom2],_assText).
inLitsToQuants(['In'(_x1,_c),'In'(_x2,_c)|_inLits],_assText) :-
        termListToAtom([_x1,',',_x2,'/',_c],_atom1),!,
        inLitsToQuants(_inLits,_atom2),!,
        pc_atomconcat([_atom1,' ',_atom2],_assText).
inLitsToQuants(['In'(_x,_c)|_inLits],_assText) :-
	termListToAtom([_x,'/',_c],_atom1),!,
	inLitsToQuants(_inLits,_atom2),!,
	pc_atomconcat([_atom1,' ',_atom2],_assText).


litToAtom('A_label'(_x,_m,_y,_l),_atom) :-
  termToAtom('AL'(_x,_m,_l,_y),_atom),
  !.

litToAtom(_lit,_atom) :-
	termToAtom(_lit,_atom),!.


litsToAtom([_lit],_atom,_) :-
	litToAtom(_lit,_atom),!.
litsToAtom([_lit|_lits],_atom,_connective) :-
	_lits \== [],!,
	litToAtom(_lit,_atom1),!,
	termToAtom(_connective,_atom2),!,
	litsToAtom(_lits,_atom3,_connective),!,
	pc_atomconcat([_atom1,' ',_atom2,' ',_atom3],_atom).



/*************************************************************/
/** pushNegationInwardsRF( _f,_nf )                           **/
/**                                                         **/
/** not exists quantifiers are transformed back to forall   **/
/** quantifiers                                             **/
/*************************************************************/
/** Ich habe einfach kvt's Code aus MSFOLassertionUtilities.pro
   uebernommen und ihn fuer den Literal-Fall auf die rangeform angepasst
   RS
**/


/** double not **/
pushNegationInwardsRF(not(not(_t)),_r) :-
	pushNegationInwardsRF(_t,_r).

/** and **/
pushNegationInwardsRF(and([]),and([])).

pushNegationInwardsRF(and([_t|_ts]),and([_r|_rs])) :-
	pushNegationInwardsRF(_t,_r),
	pushNegationInwardsRF(and(_ts),and(_rs)).

/** or **/
pushNegationInwardsRF(or([]),or([])).

pushNegationInwardsRF(or([_t|_ts]),or([_r|_rs])) :-
	pushNegationInwardsRF(_t,_r),
	pushNegationInwardsRF(or(_ts),or(_rs)).

/** not and **/
pushNegationInwardsRF(not(and([])),or([])).

pushNegationInwardsRF(not(and([_t|_ts])),or([_r|_rs])) :-
	pushNegationInwardsRF(not(_t),_r),
	pushNegationInwardsRF(not(and(_ts)),or(_rs)).

/** nor or **/
pushNegationInwardsRF(not(or([])),and([])).

pushNegationInwardsRF(not(or([_t|_ts])),and([_r|_rs])) :-
	pushNegationInwardsRF(not(_t),_r),
	pushNegationInwardsRF(not(or(_ts)) ,and(_rs) ).

/** exists **/
pushNegationInwardsRF(exists(_var,_type,_t),exists(_var,_type,_r)) :-

	pushNegationInwardsRF(_t,_r).

/** not exists **/
pushNegationInwardsRF(not(exists(_var,_type,_t)),forall(_var,_type,_r)) :-
	pushNegationInwardsRF(not(_t),_r).

/** The next two clauses are not necessary in the context   **/
/** the predicate is used. But they make the intension of   **/
/** pushNegationInwardsRF complete, so that the predicate     **/
/** might be reused in another context.                     **/

/** forall **/
pushNegationInwardsRF(forall(_var,_type,_t),forall(_var,_type,_r)) :-
	pushNegationInwardsRF(_t,_r).

/** not forall **/
pushNegationInwardsRF(not(forall(_var,_type,_t)),exists(_var,_type,_r)) :-
	pushNegationInwardsRF(not(_t),_r).

/** Literals **/
pushNegationInwardsRF(not('TRUE'),'FALSE') :- !.

pushNegationInwardsRF(not('FALSE'),'TRUE') :- !.

pushNegationInwardsRF(not(_l),not(_l)) :- !.

pushNegationInwardsRF(_lit,_lit) :- !.

