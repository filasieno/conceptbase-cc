/**
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
**/
/*************************************************************************
*
*
* File:         %M%
* Version:      %I%
* Last Change: %G%, Rene Soiron (RWTH)
* Date released : %E%  (YY/MM/DD)
*
* SCCS-Source-Pool : %P%
* Date retrieved : %D% (YY/MM/DD)
**************************************************************************
*------------------------------------------------------------
*
* interface to the creation of an optimized rangeform
*
* Changes:
*
* 7-Sep-1994/CQ: VarTabLookup(ranges,_) -> VarTabLookup_ranges(_)    CB[176]
*
* Metaformel-Aenderungen (10.1.96):
* generateRangeform/5:
* der ID des $$-Formeltexts wird zusaetzlich uebergeben, um fuer
* Metaformeln die generierten Formeln als Instanzen eintragen zu
* koennen
* neue lokale Praedikate:
* handleSimpleFormula, handleMetaFormula,
* tellGenFormulas, deleteGeneratedFormula
*
*/

:- module('AssertionTransformer',[
'ePredsTillNow'/1
,'generateRangeform'/4
,'generateRangeform'/5
,'isQuery'/0
,'setQueryFlag'/1
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').

:- use_module('GeneralUtilities.swi.pl').
:- use_module('MetaUtilities.swi.pl').
:- use_module('MSFOLassertionParser.swi.pl').
:- use_module('MSFOLassertionTransformer.swi.pl').
:- use_module('MSFOLassertionSimplifier.swi.pl').
:- use_module('SemanticOptimizer.swi.pl').
:- use_module('VarTabHandling.swi.pl').




:- use_module('MetaSimplifier.swi.pl').

:- use_module('MetaTriggerGen.swi.pl').
:- use_module('AToAdot.swi.pl').
:- use_module('MetaRFormulas.swi.pl').
:- use_module('ErrorMessages.swi.pl').
:- use_module('FragmentToPropositions.swi.pl').

:- use_module('FragmentToHistoryPropositions.swi.pl').
:- use_module('PrologCompatibility.swi.pl').
:- use_module('ScanFormatUtilities.swi.pl').
:- use_module('Literals.swi.pl').

:- use_module('validProposition.swi.pl').
:- use_module('PropositionProcessor.swi.pl').






:- dynamic 'query'/1 .
   /** Flagge, ob constraint eine Query-Constraint oder eine Integritaetsbedingung ist **/
:- dynamic 'ePredsTillNow'/1 .
   /** for SemanticOptimizer.pro **/


:- style_check(-singleton).



/*===========================================================*/
/*=             EXPORTED PREDICATES DEFINITION              =*/
/*===========================================================*/

/*************************************************************/
/** generateRangeform(_mode, _asstext,_rangeform,_vartab)   **/
/**                                                         **/
/**  _asstext:    (i) list of chars                         **/
/**  _rangeform:  (o)                                       **/
/**  _ranges:     (o)                                       **/
/**                                                         **/
/** generateRangeform first parses the text of an assertion.
Then the scopes of the quantifiers are minimized; the formula
is now in the so called miniscope form.
The miniscope form is then compiled to the range form and
optimized afterwards.

Metaformulas:
generateRangeform/4 is only imported by the QueryCompiler,
the AssertionCompiler imports generateRangeform/5, which
supports Metaformulas.
This mechanism ensures, that query constraints can't be
"meta"
**/
/*************************************************************/
/** remark: The VarTabHandling should be implemented in C: In the beginning of generateRangeform VarTabInit(_handle) is called and delivers a pointer to the VarTabStructure. The pointer is passed to all clauses of generateRangeform. In the end the VarTab is destroyed by VarTabDestroy(_handle). (At present we have no handles. The VarTab is a static data structure of module VarTabHandling.
**/



/*SWI/SICStus conversion: replaced mark/1,cut/1 combination */
generateRangeform(_mode,_assertionAS,_rangeform_optRF,_ranges) :-
    generateRangeform2(_mode,_assertionAS,_rangeform_optRF,_ranges).

generateRangeform(_,_string,_,_) :-
	report_error('FORMULA_UNPARSABLE', 'AssertionTransformer', [_string]),
	!,
	fail.

generateRangeform2(_mode,_assertionAS,_rangeform_optRF,_ranges) :-
	'VarTabInit', /**initialise VarTab **/

	parseMSFOLassertion(_mode,_assertionAS, _assertionMSFOL),!,
	'WriteTrace'(veryhigh,'AssertionTransformer',[parseMSFOLassertion,'--->',idterm(_assertionMSFOL)]),

	generateMiniScopeForm( _assertionMSFOL, _miniscopeMSFOL),!,
	'WriteTrace'(veryhigh,'AssertionTransformer',	['MiniScope','--->',idterm(_miniscopeMSFOL)]),

	miniscopeToRangeform(  _miniscopeMSFOL, _rangeformRF1),!,
	'WriteTrace'(veryhigh,'AssertionTransformer',[miniscopeToRangeform,'--->',idterm(_rangeformRF1)]),

/*
	Die Variablentabelle darf erst dann inkrementell geaendert
	werden, wenn getRangesFromRangeForm nur die In-Literale
	beruecksichigt, die beruecksichtigt werden sollen.
	(RS,24.1.1996)
	alternativ: AToAdot-Runde auf Datalog-Ebene
	15-Oct-2007/M.Jeusfeld: need a corerct VarTab for solving ticket #159
*/

        getRangesFromRangeForm(_rangeformRF1,_toInsert),!,
        'VarTabInsertRanges'(_toInsert),!,

        replaceAsWithAdots(_rangeformRF1,_rangeformRF),!,

	optimizeRangeform(  _rangeformRF, _rangeform_optRF),
        !,
	'WriteTrace'(veryhigh,'AssertionTransformer',['optimized Rangeform to --->',idterm(_rangeform_optRF)]),

	'VarTabLookup_ranges'(_ranges),!,
	'VarTabDestroy', /** throw away VarTab **/
    !.



/********************************************************************/
/** generateRangeform(_mode, _rfID, _asstext,_rangeform,_vartab)   **/
/**                                                                **/
/**  _mode:       (i) rule or constraint                           **/
/**  _rfID:       (i) oid of original formulatext                  **/
/**  _asstext:    (i) list of chars                                **/
/**  _rangeform:  (o) rangeform of formula (if simple)             **/
/**                   'metaFormula' if formula is meta             **/
/**  _ranges:     (o)                                              **/
/**                                                                **/
/** generateRangeform first parses the text of an assertion.
Then the scopes of the quantifiers are minimized; the formula
is now in the so called miniscope form.
The miniscope form is then compiled to the range form and
optimized afterwards.

**/
/*************************************************************/

generateRangeform(_mode,_rfID,_assertionAS,_rangeform_optRF,_ranges) :-
	/*mark(_mark),*/
	'VarTabInit', /**initialise VarTab **/
	'WriteTrace'(veryhigh,'AssertionTransformer',['generating code for: ',_assertionAS]),

	parseMSFOLassertion(_mode,_assertionAS, _assertionMSFOL),!,
	'WriteTrace'(veryhigh,'AssertionTransformer',[parseMSFOLassertion,'--->',idterm(_assertionMSFOL)]),

	'VarTabLookup_ranges'(_ranges0),


	generateMiniScopeForm( _assertionMSFOL, _miniscopeMSFOL),!,
	'WriteTrace'(veryhigh,'AssertionTransformer',	['MiniScope','--->',idterm(_miniscopeMSFOL)]),

	miniscopeToRangeform(  _miniscopeMSFOL, _rangeformRF),!,
	'WriteTrace'(veryhigh,'AssertionTransformer',[miniscopeToRangeform,'--->',idterm(_rangeformRF)]),

	testIfMetaFormula(_mode,_rangeformRF,_flag),!,
	/*cut(_mark),*/
	((_flag == 'simple', handleSimpleFormula(_rangeformRF,_rangeform_optRF,_ranges));
	 (_flag == 'meta', handleMetaFormula(_rangeformRF,[],_mode,_rfID),_rangeform_optRF = 'metaFormula',_ranges = []);
	 (_flag == 'redundant',_rangeform_optRF = 'redundant',_ranges = [],
             'WriteTrace'(veryhigh,'AssertionTransformer',[idterm(_rangeformRF), ' is marked as redundant. No Datalog code generated.']))
        ),

	!.



generateRangeform(_mode,_formulaID,_string,_,_) :-
	report_error('FORMULA_UNPARSABLE', 'AssertionTransformer', [_string]),
	!,
	fail.





setQueryFlag('Q') :-
	pc_update(query(1)).
setQueryFlag('RC') :-
	pc_update(query(0)).

isQuery :-
	query(1).

/*===========================================================*/
/*=                LOCAL PREDICATES DEFINITION              =*/
/*===========================================================*/

/*************************************************************/
/** convertCondition(_conclvars,_condition,_bdmcondition)   **/
/**                                                         **/
/** konvertiert eine Formel in das fuer die BDM-Behandlung  **/
/** noetige Format.                                         **/
/** Beispiel:                                               **/
/** convertCondition([a,b],F,_bdm) liefert in _bdm den Term **/
/** forall(a,c1,forall(b,c2,not(F)))                        **/
/** wobei c1 bzw. c2 die zu a bzw. b zugehoerigen Klassen   **/
/** sind                                                    **/
/** Diese merkwuerdig erscheinende Transformation braucht   **/
/** man, um die _condition ein eine Rangeform bringen zu    **/
/** koennen.                                                **/
/*************************************************************/

convertCondition([],_condition,not(_condition)).

convertCondition([_v|_vs],_condition,forall(_v,_t,_bdmcondition)) :-
	'VarTabLookup'(_v,_t),
	convertCondition(_vs,_condition,_bdmcondition).

/*************************************************************/
/** handleSimpleFormula(_rangeform,_rangeform_optRF,_ranges)**/
/**                                                         **/
/** Dieses Praedikat fasst die Behandlung einer einfachen   **/
/** (nicht-Meta) Formel zusammen.                           **/
/** _rangeform: Eingabeformel                               **/
/** _rangeform_optRF: optimierte Formel                     **/
/** _ranges: Klassenlisten fuer die Variablen der Formel    **/
/**                                                         **/
/** 1. Variablentabelle aus Rangeform fuellen               **/
/** 2. A --> Adot                                           **/
/** 3. semantische Optimierung                              **/
/**                                                         **/
/*************************************************************/
handleSimpleFormula(_rangeform,_rangeform_optRF,_ranges) :-

/*
	Die Variablentabelle darf erst dann inkrementell geaendert
	werden, wenn getRangesFromRangeForm nur die In-Literale
	beruecksichigt, die beruecksichtigt werden sollen.
	(RS,24.1.1996)

	getRangesFromRangeForm(_rangeform,_toInsert),!,
	VarTabInsertRanges(_toInsert),!,
*/
	replaceAsWithAdots(_rangeform,_rangeform1),!,
        exploitFunctionalDependencies(_rangeform1,_rangeform2),
	optimizeRangeform(_rangeform2, _rangeform_optRF),
        !,
	'WriteTrace'(veryhigh,'AssertionTransformer',['optimized Rangeform to --->',idterm(_rangeform_optRF)]),
	'VarTabLookup_ranges'(_ranges),!,
	'VarTabDestroy'.

/*************************************************************/
/** handleMetaFormula(_rangeform,_ePredsTillNow,_mode,_rfID)**/
/**                                                         **/
/** _rangeform : Metaformel in Rangeform                    **/
/** _ePredsTillNow : Literale, die bisher partiell          **/
/**                  ausgewertet wurden                     **/
/** _mode : rule, constraint                                **/
/** _rfID : oid der Metaformel                              **/
/**                                                         **/
/*************************************************************/


handleMetaFormula(_rangeform,_ePredsTillNow,_mode,_rfID) :-

/**
	die alte Variablentabelle der Metaformel wird nicht mehr benoetigt,
	fuer die vereinfachten Formeln wird jeweils eine eigene aufgebaut
**/
	'VarTabDestroy',!,

        correctRangeform(_rangeform,_rangeform_c),

	'WriteTrace'(veryhigh,'AssertionTransformer',['partially evaluating ... ',nl,idterm(_rangeform_c)]),
        pc_update(ePredsTillNow(_ePredsTillNow)),     /** 30-Oct-2001/MJf, to be used in SemanticOptimizer **/
	metaSimplifier(_rangeform_c,_ePredsTillNow,_genFormulas,_genInsertTriggers,_genDeleteTriggers,_substitutions,_formulaClasses),!,

	'WriteTrace'(high,'AssertionTransformer',['generated Formulas: -->',idterm(_genFormulas)]),
	/* Store Metaformula as instance of metaMSFOLconstraint or metaMSFOLrule*/
	do_store_metaFormClass(_mode,_rfID),!,
	getAttributeLabels(_rfID,_genFormulas,_genDeleteTriggers,_attrLabels),   /** generated readable attribute labels **/
	/* Tell generated formulas */
	tellGenFormulas(_substitutions,_genFormulas,_formulaClasses,_mode,_rfID,_genFormulaIDs,_attrLabels),!,
        pc_update(ePredsTillNow([])),
	/* Tell procedure trigger */
	store_procedureTrigger(_rfID,_mode,_genInsertTriggers,_genDeleteTriggers,_genFormulaIDs),!.


handleMetaFormula(_rangeform,_,_,_) :-
	report_error('HMF1','AssertionTransformer',[_rangeform]),!,fail.



/**
  Meta formulas like  
     forall x/VAR (x [in] NodeOrLink) and not (x in String) ==> (x in ModelElement)
  are suffering from the Miniscope form created by ConceptBase. They are mapped to
  a representation that includes a subformula like
    forall c In(x,c) and In(c,NodeOrLink ==>  'FALSE' or In(x,String)
  This means that the negated predicate is moved out of the conjunction.
  The procedure correctRangeform is an incomplete attempt to repair the situation.
  In particular, we only consider the 'or' terms that have two subformulas.
  In general, the 'or' has a list of subformulas.
  See ticket #230
**/

correctRangeform(rangerule(_vars,_f1,_lit),rangerule(_vars,_f2,_lit)) :-
        correctRangeform(_f1,_f2),
        !.

correctRangeform(rangeconstraint(_f1),rangeconstraint(_f2)) :-
        correctRangeform(_f1,_f2),
        !.

correctRangeform(forall(_vars,_lits,_f1),forall(_vars,_lits,_f2)) :-
        correctRangeform(_f1,_f2),
        !.

correctRangeform(exists(_vars,_lits,_f1),exists(_vars,_lits,_f2)) :-
        correctRangeform(_f1,_f2),
        !.

/** This is the patterns that is replaced **/
correctRangeform( or([forall(_vars,_lits,'FALSE'),_f1]), forall(_vars,_lits,_f2) ) :-
        correctRangeform(_f1,_f2),
        !.
correctRangeform( or([forall(_vars,_lits,'FALSE')|_restF1]), forall(_vars,_lits,or(_restF2)) ) :-
        _restF1 = [_f1,_f2|_],  /** at least two subformulas **/
        correctRangeform(_restF1,_restF2),
        !.


/** This one is the dual case for exists  **/
correctRangeform( and([exists(_vars,_lits,'TRUE'),_f1]), exists(_vars,_lits,_f2) ) :-
        correctRangeform(_f1,_f2),
        !.
correctRangeform( and([exists(_vars,_lits,'TRUE')|_restF1]), exists(_vars,_lits,and(_restF2)) ) :-
        _restF1 = [_f1,_f2|_],  /** at least two subformulas **/
        correctRangeform(_restF1,_restF2),
        !.

correctRangeform([],[]) :- !.

correctRangeform([_f1|_rest1],[_f2|_rest2]) :-
        correctRangeform(_f1,_f2),
        correctRangeform(_rest1,_rest2),
        !.


/** catchall **/
correctRangeform(_f,_f).

  


/** make an intelligent guess for the attribute labels assigned to the **/
/** generated assertions. Basically, if there id a delete trigger for  **/
/** the literal In(attr,cat), e.g. In(Employee!name,Proposition!single)**/
/** then we take the combination name_single as proposed label for     **/
/** the generated assertion.                                           **/

getAttributeLabels(_mfId,[],[],[]) :- !.
getAttributeLabels(_mfId,[_f|_rest],[],['none'|_restlabels]) :- 
	getAttributeLabels(_mfId,_rest,[],_restlabels).

/** guess via the affected attribute labels **/
getAttributeLabels(_mfId,[_f|_rest],
                   [_firsttriggers|_resttriggers],
                   [_attrlabel|_restlabels]) :-
	member('applyPredicateIfDelete@BDMCompile'('In'(_attr,_cat),_),_firsttriggers),
	retrieve_proposition('P'(_attr,_x,_l1,_y)),
	retrieve_proposition('P'(_cat,_c,_l2,_d)),
	attribute('P'(_attr,_x,_l1,_y)),
	attribute('P'(_cat,_c,_l2,_d)),
	prove_literal('Label'(_attr,_l1)),
	prove_literal('Label'(_cat,_l2)),
        pc_atomconcat([_l1,'_',_l2],_attrlabel),
	!,
	getAttributeLabels(_mfId,_rest,_resttriggers,_restlabels).


/** if the previous guess via attribute labels fails, we try the label that the original meta formula has **/
getAttributeLabels(_mfId,[_f|_rest],[_|_resttriggers], [_attrlabel|_restlabels]) :-
        (
        prove_literal('A_label'(_c,rule,_mfId,_attrlabel))
          ;
        prove_literal('A_label'(_c,constraint,_mfId,_attrlabel))
        ),
        getAttributeLabels(_mfId,_rest,_resttriggers,_restlabels).

/** otherwise, we indicate that we did not find a good guess **/
getAttributeLabels(_mfId,[_f|_rest], [_|_resttriggers], ['none'|_restlabels]) :-
        getAttributeLabels(_mfId,_rest,_resttriggers,_restlabels).





/*************************************************************/
/** tellGenFormulas(_fs,_cs,_mode,_mfID,_fids)              **/
/**                                                         **/
/** _substs : Metavariablensubstititionen                   **/
/** _fs (i) : generierte Formeln                            **/
/** _cs (i) : Klassen, an die die Formeln gehaengt werden   **/
/** _mode (i) : rule, constraint                            **/
/** _mfID (i): iod der Metaformel                           **/
/** _fids (o) : oidsder generierten Formeln                 **/
/*************************************************************/
tellGenFormulas(_substs,[],[],_,_,[],_).
tellGenFormulas([_subst|_restsubsts],[_gf|_genFormulas],[_class|_genformulasClasses],_mode,_mfID,[_gfID|_gfIDs],
                [_attrlabel|_attrlabelRest]) :-
	do_store_generatedAssertion(_subst,_gf,_class,_mode,_mfID,_gfID,_attrlabel),!,
	tellGenFormulas(_restsubsts,_genFormulas,_genformulasClasses,_mode,_mfID,_gfIDs,_attrlabelRest).
tellGenFormulas([_subst|_restsubsts],[_gf|_genFormulas],[_class|_genformulasClasses],_mode,_mfID,[_gfID|_gfIDs],
                []) :-
        do_store_generatedAssertion(_subst,_gf,_class,_mode,_mfID,_gfID,'none'),!,
        tellGenFormulas(_restsubsts,_genFormulas,_genformulasClasses,_mode,_mfID,_gfIDs,_attrlabelRest).
tellGenFormulas(_,[_gf|_],[_class|_],_mode,_mfID,[_gfID|_]) :-
	report_error('TGF1','AssertionTransformer',[_gf]),!,
	fail.

deleteGeneratedFormula(_assertionID,_nr,_mfID,_mode) :- _nr > 0,!.
deleteGeneratedFormula(_assertionID,0,_mfID,_mode) :-
	untell_generatedAssertions([_assertionID],_mfID,_mode),!.
deleteGeneratedFormula(_assertionID,0,_mfID,_mode) :- !.

