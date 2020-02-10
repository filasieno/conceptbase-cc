/**
The ConceptBase.cc Copyright

Copyright 1987-2020 The ConceptBase Team. All rights reserved.

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
**/
/*Change: An einigen Stellen wird wegen zusaetzlichen Vmrules etwas geaendert, man muss denn zusaetzlich beachten,
Fuer die Faelle: literal mit aussen_Schachtlung new,red,ins,...			HW/jun.98*/


:- module('QO_literals',[
'Conjunct2List'/2
,'List2Conjunct'/2
,'bindAllVarsInAd'/2
,'buildAdAllFreeForArgs'/2
,'buildAdForLit'/4
,'buildAllAds'/2
,'buildAllAds'/3
,'filterSuperClassesWithSize'/3
,'findMostSpecialAttrCat'/3
,'getArgs'/2
,'getConstAndVarsList'/3
,'getConstList'/2
,'getDest'/2
,'getSource'/2
,'getVars'/2
,'getVarsBoundFromArgs'/3
,'getVarsList'/2
,'isConst'/1
,'isVar'/1
,'listContainsRealSubClass'/2
,'listContainsRealSuperClass'/2
,'listContainsSubClass'/2
,'qo_inSysClass'/2
,'qo_prove_literal'/1
,'removeSecondaryFunctors'/2
,'sysForbidden'/1
,'testAllGround'/1
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').


:- use_module('QO_profile.swi.pl').
:- use_module('GeneralUtilities.swi.pl').



:- use_module('QO_utils.swi.pl').


:- use_module('Literals.swi.pl').


:- use_module('PrologCompatibility.swi.pl').

:- use_module('MetaUtilities.swi.pl').


:- style_check(-singleton).





/** ---------------------------------------------- **/
/**						  **/
/** Arbeiten mit Belegungsmustern		  **/
/**						  **/
/** ---------------------------------------------- **/

/** ---------------------------------------------- **/
/**						  **/
/** Berechnung aller Belegungsmuster, die durch    **/
/** das System verboten sind			  **/
/**						  **/
/** ---------------------------------------------- **/

:- dynamic 'sysForbidden'/1 .

sysForbidden(lit('Mod'(_lit),_ad)) :-
	!,
	sysForbidden(lit(_lit,_ad)).


sysForbidden(lit(ins(_lit),_ad)) :-
	!,
	sysForbidden(lit(_lit,_ad)).
sysForbidden(lit(del(_lit),_ad)) :-
	!,
	sysForbidden(lit(_lit,_ad)).
sysForbidden(lit(new(_lit),_ad)) :-
	!,
	sysForbidden(lit(_lit,_ad)).
sysForbidden(lit(red(_lit),_ad)) :-
	!,
	sysForbidden(lit(_lit,_ad)).
sysForbidden(lit(plus(_lit),_ad)) :-
	!,
	sysForbidden(lit(_lit,_ad)).
sysForbidden(lit(minus(_lit),_ad)) :-
	!,
	sysForbidden(lit(_lit,_ad)).

sysForbidden(lit('In'(_x,_y),[_,f])).

sysForbidden(lit('Adot'(_cc,_x,_y),[f,_,_])).

sysForbidden(lit('A'(_x,_l,_y),[_,f,_])).


/** 19-Jul-2007/M.Jeusfeld: EQ,UNIFIES are allowed even if both **/
/** variables are free (f). This is because they now have the   **/
/** power to bind variables. See also ticket #142.              **/

/** this code is now obsolete!
sysForbidden(lit(UNIFIES(_x,_y),[f,f])).

sysForbidden(lit(_lit,_ad)) :-
	functor(_lit,_f,_),
	member(_f,[IDENTICAL,LT,GE,GT,LE,EQ,NE]),
	member(f,_ad).
**/

sysForbidden(lit(_lit,_ad)) :-
        functor(_lit,_f,_),
        member(_f,['IDENTICAL','LT','GE','GT','LE','NE']),
        member(f,_ad).

sysForbidden(lit(not(_lit),_ad)) :-
	member(f,_ad).

sysForbidden(lit(_q,[b|_args])) :-
	_q =.. [_fid|_],
        is_id(_fid),   /** pc_atomconcat('id_',_,_fid), **/
	name2id('Function',_fctid),
	prove_literal('In'(_fid2,_fctid)),
	_fid2 = _fid.

sysForbidden(lit(_q,[f|_args])) :-
	_q =.. [_fid|_],
        is_id(_fid),   /** pc_atomconcat('id_',_,_fid), **/
	name2id('Function',_fctid),
	prove_literal('In'(_fid2,_fctid)),
	_fid2 = _fid,
	member(f,_args).


/** ---------------------------------------------- **/
/**						  **/
/** Operationen auf Adornments, also Listen mit    **/
/** Elementen mit Wert f,b, oder c		  **/
/**						  **/
/** ---------------------------------------------- **/


testAllGround([]).
testAllGround([b|_bs]) :-
	testAllGround(_bs).
testAllGround([c|_bs]) :-
	testAllGround(_bs).




buildAllAds(_lit,_ads) :-
	getArgs(_lit,_args),
	buildAllAdsForArgs(_args,_ads).

buildAllAds(_lit,_args,_ads) :-
	getArgs(_lit,_args),
	buildAllAdsForArgs(_args,_ads).





buildAllAdsForArgs(_args,_ads) :-
	findall(_ad,
		buildAdForArgs(_args,_ad),
		_ads),!.



buildAdForArgs([],[]).
buildAdForArgs([_var|_vars],[_ad|_ads]) :-
	buildAdForArg(_var,_ad),
	buildAdForArgs(_vars,_ads).



buildAdForArg(_const,c) :-
	isConst(_const),!.
buildAdForArg(_var,b).
buildAdForArg(_var,f).

buildAdAllFreeForArgs([],[]).
buildAdAllFreeForArgs([_const|_vars],[c|_ads]) :-
	isConst(_const),!,
	buildAdAllFreeForArgs(_vars,_ads).
buildAdAllFreeForArgs([_var|_vars],[f|_ads]) :-
	buildAdAllFreeForArgs(_vars,_ads).




bindAllVarsInAd(_lit,_ad) :-
	_lit =.. [_f|_args],
	bindAllVarsInAd1(_args,_ad),!.

bindAllVarsInAd1([],[]).
bindAllVarsInAd1([_c|_args],[c|_ad]) :-
	isConst(_c),!,
	bindAllVarsInAd1(_args,_ad).
bindAllVarsInAd1([_|_args],[b|_ad]) :-
	bindAllVarsInAd1(_args,_ad).



/** ---------------------------------------------- **/
/**						  **/
/** buildAdList(_litList,_cons,_boundVars,_adLits) **/
/**						  **/
/** _litList: Liste von Literalen		  **/
/** _cons: Konstanten				  **/
/** _boundVars: gebundene Variablen		  **/
/**						  **/
/** _adLits: Literale mit Bindungsmustern	  **/
/**                				  **/
/** Aufgrund der Konstanten und geb. Variablen     **/
/** wird fuer jedes Literal das Belegungsmuster	  **/
/** bestimmt       				  **/
/**						  **/
/** ---------------------------------------------- **/


buildAdList([],_,_,[]).

buildAdList([_lit|_lits],_cons,_boundVars,[lit(_lit,_ad)|_adLits]) :-
	getArgs(_lit,_args),
	buildAdFromArgs(_args,_cons,_boundVars,_ad),
	buildAdList(_lits,_cons,_boundVars,_adLits).


/** ---------------------------------------------- **/
/**						  **/
/** buildAdSeq(_litList,_cons,_boundVars,_adLits)  **/
/**						  **/
/** _litList: Liste von Literalen		  **/
/** _cons: Konstanten				  **/
/** _boundVars: gebundene Variablen		  **/
/**						  **/
/** _adLits: Literale mit Bindungsmustern	  **/
/**                				  **/
/** Die Literale in litList werden als Sequenz     **/
/** aufgefasst, d.h. nach Berechnung des           **/
/** Belegungsmusters werden die gebundenen         **/
/** aktualisiert.				  **/
/**						  **/
/** ---------------------------------------------- **/


buildAdSeq([],_,_,[]).

buildAdSeq([_lit|_lits],_const,_oldVarsBound,[lit(_lit,_ad)|_adLits]) :-
	getArgs(_lit,_args),
	buildAdFromArgs(_args,_const,_oldVarsBound,_ad),
	getVars(_lit,_vars),
	union(_oldVarsBound,_vars,_newVarsBound),
	buildAdSeq(_lits,_const,_newVarsBound,_adLits).




buildAdFromArgs([],_,_,[]).
buildAdFromArgs([_x|_args],_const,_boundVars,[c|_ad]) :-
	memberchk(_x,_const),!,
	buildAdFromArgs(_args,_const,_boundVars,_ad).
buildAdFromArgs([_x|_args],_const,_boundVars,[b|_ad]) :-
	memberchk(_x,_boundVars),!,
	buildAdFromArgs(_args,_const,_boundVars,_ad).
buildAdFromArgs([_x|_args],_const,_boundVars,[f|_ad]) :-
	buildAdFromArgs(_args,_const,_boundVars,_ad).





buildAdForLit(_lit,_const,_boundVars,lit(_lit,_ad)) :-
	getArgs(_lit,_args),
	buildAdFromArgs(_args,_const,_boundVars,_ad).




/** ---------------------------------------------- **/
/**						  **/
/** Arbeiten mit Literalen       		  **/
/**						  **/
/** ---------------------------------------------- **/



/** ----------------------------------------------

   List2Conjunct/2:
   Eingabe: Liste von Literalen
   Ausgabe: Konjunktion von Literalen
   ---------------------------------------------- **/



'List2Conjunct'([],'TRUE') :- !.
'List2Conjunct'([_lit],_lit) :- !.
'List2Conjunct'([_lit|_lits],(_lit,_newTail)) :-
	'List2Conjunct'(_lits,_newTail).



'Conjunct2List'(_lit,[_lit]) :-
        _lit \= (_,_).
'Conjunct2List'((_lit,_rest),[_lit|_lits]) :-
        'Conjunct2List'(_rest,_lits).





clearTrues([],[]).
clearTrues(['TRUE'|_lits],_newLits) :-
	!,clearTrues(_lits,_newLits).
clearTrues([_l|_lits],[_l|_newLits]) :-
	clearTrues(_lits,_newLits).


/**
#MODE( intersectLiterals(i,i,o))

intersectLiterals([],_,[]).
intersectLiterals([In(_x,_class)|_lits],_otherLits,[In(_x,_class)|_intersect]) :-
	member(In(_y,_class),_otherLits),!,
	intersectLiterals(_lits,_otherLits,_intersect).
intersectLiterals([Adot(_p,_x,_y)|_lits],_otherLits,[Adot(_p,_x,_y)|_intersect]) :-
	member(Adot(_p,_c,_d),_otherLits),
	!,
	intersectLiterals(_lits,_otherLits,_intersect).
intersectLiterals([_lit|_lits],_otherLits,[_lit|_intersect]) :-
	_lit =.. [_functor|_],
	(_functor \== In,_functor \== Adot),
	member(_lit2,_otherLits),
	_lit2 =.. [_functor|_],!,
	intersectLiterals(_lits,_otherLits,_intersect).
intersectLiterals([_lit|_lits],_otherLits,_intersect) :-
	intersectLiterals(_lits,_otherLits,_intersect).
**/


removeSecondaryFunctors([],[]).
removeSecondaryFunctors(['Mod'(_lit)|_lits],[_lit|_litsOut]) :-
	!,removeSecondaryFunctors(_lits,_litsOut).
removeSecondaryFunctors([not(_lit)|_lits],[_lit|_litsOut]) :-
	!,removeSecondaryFunctors(_lits,_litsOut).
removeSecondaryFunctors([ins(_lit)|_lits],[_lit|_litsOut]) :-
	!,removeSecondaryFunctors(_lits,_litsOut).
removeSecondaryFunctors([del(_lit)|_lits],[_lit|_litsOut]) :-
	!,removeSecondaryFunctors(_lits,_litsOut).
removeSecondaryFunctors([new(_lit)|_lits],[_lit|_litsOut]) :-
	!,removeSecondaryFunctors(_lits,_litsOut).
removeSecondaryFunctors([red(_lit)|_lits],[_lit|_litsOut]) :-
	!,removeSecondaryFunctors(_lits,_litsOut).
removeSecondaryFunctors([plus(_lit)|_lits],[_lit|_litsOut]) :-
	!,removeSecondaryFunctors(_lits,_litsOut).
removeSecondaryFunctors([minus(_lit)|_lits],[_lit|_litsOut]) :-
	!,removeSecondaryFunctors(_lits,_litsOut).
removeSecondaryFunctors([_lit|_lits],[_lit|_litsOut]) :-
	removeSecondaryFunctors(_lits,_litsOut).


/**---------------------------------------

   getConst:
	Eingabe: 	Literal
	Ausgabe: 	Liste der Konstanten im Literal

   getVars:
	Eingabe: 	Literal
	Ausgabe: 	Liste der Variablen im Literal

   getConstAndVars:
	Eingabe: 	Literal
	Ausgabe: 	Liste der Variablen im Literal
			Liste der Konstanten im Literal

-----------------------------------------**/


getConstList(_litList,_constList) :-
	getConstAndVarsList(_litList,_constList,_).



getVarsList(_litList,_varsList) :-
	getConstAndVarsList(_litList,_,_varsList).



getArgsList(_litList,_argsList) :-
	getArgsList(_litList,[],_args).


	getArgsList([],_args,_args).
	getArgsList([_lit|_lits],_oldArgs,_args) :-
		getArgs(_lit,_actArgs),
		union(_actArgs,_oldArgs,_newArgs),
		getArgsList(_lits,_newArgs,_args).



getConst(_lit,_constList) :-
	getConstAndVars(_lit,_constList,_).



getVars(_lit,_varsList) :-
	getConstAndVars(_lit,_,_varsList).







getArgs('Mod'(_lit),_args) :-
	!,
	getArgs(_lit,_args).

getArgs(not(_lit),_args) :-
	!,
	getArgs(_lit,_args).

getArgs(_lit,_args):-
	_lit =.. [_functor|[_term]],
	member(_functor,[plus,minus,new,red,del,ins]),
	!,
	getArgs(_term,_args).

getArgs(_lit,_args) :-
	_lit =.. [_|_args].

/**--------------------------------------

  getConstAndVars/3:
  Eingabe: Literal
  Ausgabe: Konstanten im Literal
	   Variablen im Literal

----------------------------------------**/



getConstAndVarsList([],[],[]).
getConstAndVarsList([_lit|_lits],_constList,_varList) :-
        getConstAndVars(_lit,_c,_v),
        getConstAndVarsList(_lits,_const,_vars),
        union(_c,_const,_constList),
	union(_v,_vars,_varList).




getConstAndVars(_lit,_const,_vars) :-
        getArgs(_lit,_args),
        filterConstAndVars(_args,_const,_vars).






getVarsBoundFromArgs([],[],[]).
getVarsBoundFromArgs([_arg|_args],[b|_ads],[_arg|_vb]) :-
	!,
	getVarsBoundFromArgs(_args,_ads,_vb).
getVarsBoundFromArgs([_arg|_args],[_|_ads],_vb) :-
	getVarsBoundFromArgs(_args,_ads,_vb).



/** --------------------------------------

  filterConstAndVars/3:
  Eingabe: Argumentliste
  Ausgabe: Konstanten in der Liste
 	   Variablen in der List
  Konstanten sind die Werte, die
  nicht mit einem '_' beginnen.

   ---------------------------------------- **/
/** Alles, was keine Variable ist, ist eine
   Konstante. Konstanten koennen oid's oder
   label sein.
   Variablen im Prolog-Code beginnen mit einem '_'
**/




filterConstAndVars([],[],[]).
filterConstAndVars([_var|_rest],_const,_allvars) :-
        isVarX(_var,_varsX),!,
        filterConstAndVars(_rest,_const,_vars),
        setUnion(_varsX,_vars,_allvars).
filterConstAndVars([_c|_rest],[_c|_const],_vars) :-
        filterConstAndVars(_rest,_const,_vars).







isVar(_var) :-
	atom(_var),  /** args of query literals can be wuery literals! see CBNEWS[215] **/
	pc_atomconcat('_',_,_var).


/** 24-Feb-2005/M. Jeusfeld: use isVarX instead isVar in filterConstAndVars     **/
/** This solves ticket #52 (not all variables passed as arguments to sub-rules  **/
/** The change is necessary because literals can contain other literals as      **/
/** arguments (CBNEWS.doc[215]. By this, a literal can have the structure       **/
/** Q1(a1,Q2(a2,a3),a4). We need to make sure that also a3 and a4 are checked   **/
/** for being recognized as variables. Otherwise, the Datalog-code that is      **/
/** generated fails to pass necessary arguments from a super-clause to a        **/
/** sub-clause (see LTcompiler.pro).                                            **/



isVarX(_var,[_var]) :-
        atom(_var),  /** args of query literals can be wuery literals! see CBNEWS[215] **/
        pc_atomconcat('_',_,_var).

isVarX(_lit,_vars) :-
  compound(_lit),
  getVars(_lit,_vars).
  




isConst(_arg) :-
	atom(_arg),
        is_id(_arg),  /** pc_atomconcat('id_',_,_arg), **/
        !.
isConst(_arg) :-
	not(isVar(_arg)).




/** -------------------------------------------- **/
/** 					        **/
/** listContains(Real)Sub/SuperClass:            **/
/** Eingabe: Klasse 				**/
/**	    Liste von oids			**/
/** 					        **/
/** Test, ob in der Liste der oids eine		**/
/** (echte) Generalisierung bzw. Spezialisierung **/
/** enthalten ist.			        **/
/** 					        **/
/** -------------------------------------------- **/



listContainsSuperClass(_c,[_class|_]) :-
	is_id(_c),is_id(_class),
	qo_prove_literal('Isa'(_c,_class)),!.
listContainsSuperClass(_c,[_|_classes]) :-
	listContainsSuperClass(_c,_classes).



listContainsRealSuperClass(_c,[_class|_]) :-
	_c \== _class,
	is_id(_c),is_id(_class),
	qo_prove_literal('Isa'(_c,_class)),!.
listContainsRealSuperClass(_c,[_|_list]) :-
	listContainsRealSuperClass(_c,_list).



listContainsSubClass(_c,[_class|_]) :-
	is_id(_c),is_id(_class),
	qo_prove_literal('Isa'(_class,_c)),!.
listContainsSubClass(_c,[_|_classes]) :-
	listContainsSubClass(_c,_classes).




listContainsRealSubClass(_c,[_class|_]) :-
	is_id(_c),is_id(_class),
	_c \== _class,
	qo_prove_literal('Isa'(_class,_c)),!.
listContainsRealSubClass(_c,[_|_list]) :-
	listContainsRealSubClass(_c,_list).





filterSuperClassesWithSize(_c,_classes,_superClasses) :-
	findSuperClassesWithSize(_c,[_c|_classes],_scList1),
	keysort(_scList1,_superClasses),!.




findSuperClassesWithSize(_,[],[]).
findSuperClassesWithSize(_c,[_class|_classes],[_size-_class|_superClasses]) :-
	is_id(_c),is_id(_class),
	qo_prove_literal('Isa'(_c,_class)),!,
	countInstances(_class,_size),
	findSuperClassesWithSize(_c,_classes,_superClasses).
findSuperClassesWithSize(_c,[_class|_classes],_superClasses) :-
	findSuperClassesWithSize(_c,_classes,_superClasses).





/** -------------------------------------------- **/
/** 					        **/
/** findMostSpecialAttrCat                       **/
/** Eingabe: Liste von Attributkategorien	**/
/**	    bisher speziellste			**/
/** 					        **/
/** Bestimme die speziellste Attributkategorie	**/
/** 					        **/
/** Eine solche Attributkategorie muss nach      **/
/** nach Axiom A16 (Manfreds Diss) existieren    **/
/** Einen Test hat er eingebaut	                **/
/** (mail 25.6.96, CBNEWS 188)		        **/
/** -------------------------------------------- **/


findMostSpecialAttrCat([],_subc,_subc).
findMostSpecialAttrCat([_subcCand|_subcList],_oldSubc,_subc) :-
        prove_literal('Isa'(_subcCand,_oldSubc)),!,
        findMostSpecialAttrCat(_subcList,_subcCand,_subc).
findMostSpecialAttrCat([_subcCand|_subcList],_oldSubc,_subc) :-
        findMostSpecialAttrCat(_subcList,_oldSubc,_subc).



/** -------------------------------------------- **/
/** 					        **/
/** Literalschnittstelle des Query-Compilers	**/
/**						**/
/** -------------------------------------------- **/



getSource(_oid,_source) :-
	prove_literal('From'(_oid,_source)).



getDest(_oid,_dest) :-
	prove_literal('To'(_oid,_dest)).




qo_inSysClass(_x,_c) :-
	sys_In(_x,_c).



qo_prove_literal(_l) :-
	prove_literal(_l).
