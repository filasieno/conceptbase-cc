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
Matthias Jarke, RWTH Aachen, Informatik 5, Ahornstr. 55, 52056 Aachen, Germany
Christoph Quix, RWTH Aachen, Informatik 5, Ahornstr. 55, 52056 Aachen, Germany


This license is a FreeBSD-style copyright license.
Legal home of the FreeBSD copyright license: http://www.freebsd.org/copyright/freebsd-license.html
**/
/*
*
* File:         LTcompiler.pro
* Version:      11.3
* Creation:     2-Nov-93, Kai v. Thadden (RWTH)
* Last Change   : 98/01/25, Christoph Quix (RWTH)
*
* SCCS-Source-Pool : /home/CBase/CB_NewStruct/ProductPOOL/SCCS/serverSources/Prolog_Files/s.LTcompiler.pro
* Date retrieved : 98/03/18 (YY/MM/DD)
*
*----------------------------------------------------------------------------
*
* Neufassung der LT-Transformation, die direkt auf der
* Rangeform arbeitet
*
**/
/** Konvention fuer Variablennamen:
 DL : DATALOG-neg (beachte: alle Variablen sind durch Underscore gekennzeichne Atome (Bsp: _x)
 RF : Formel in Rangeform
_fv : free variable
_a  : member of an and-list
_o  : member of an or-list
_ruleIDS: Variable die Struktur id(_xID,_yID) enthaelt
**/

:- module('LTcompiler',[
'generateDatalog'/5
,'insert_underscores'/3
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').


/*===========================================================*/
/*=                  IMPORTED PREDICATES                    =*/
/*===========================================================*/
:- use_module('GeneralUtilities.swi.pl').

:- use_module('PrologCompatibility.swi.pl').




:- use_module('BDMTransFormula.swi.pl').
:- use_module('QO_preproc.swi.pl').
:- use_module('VMruleGenerator.swi.pl').







/*===========================================================*/
/*=              LOCAL PREDICATE DECLARATION                =*/
/*===========================================================*/










:- style_check(-singleton).




/*===========================================================*/
/*=                    LOCAL VARIABLES                      =*/
/*===========================================================*/

:- dynamic 'fun'/2 .

fun(pred,0).

/*===========================================================*/
/*=             EXPORTED PREDICATES DEFINITION              =*/
/*===========================================================*/

/******************************************************************/
/** generateDatalog(_OID,_ruleIDS,_rangerule,_ranges,_clauseDLs) **/
/** _OID	:Objekt_Id    zB Query_Id oder RuleId                   **/
/** _ruleIDS  : zur Initialisierung                              **/
/** _rangerule: Regel in Rangeform                               **/
/** _ranges:    Variablentabelle fuer die Rangerule              **/
/** _clauseDLs: Liste der erzeugten DATALOG-neg Regeln           **/
/**                                                              **/
/** Wandelt eine PL1 Regel in eine DATALOG-Regel um.             **/
/******************************************************************/

generateDatalog(_OID,_ruleIDS,_ruleRF,_ranges,_optClauseDLs) :-

	/** Initialisiere Mechanismus der neue Funktoren fuer Datalog-Regeln erzeugt
	**/
	initUniqueFunctor(_ruleIDS),
	!,
	/** markiere Variablen mit einem Underscore **/
	insert_underscores(_ruleRF,_ranges,_nrangerule),
	!,
	/** Bedingung ist in der Rangeform negiert
	**/
	_nrangerule = rangerule(_vars,_negcond,_concl),
	negateRangeForm(_negcond,_cond),
	!,
	/** eigentlicher Aufruf des LT-Algorithmus
	**/
	'LT'(rule(_cond,_concl),_vars,_clauseDLs),
	preOptimize(_clauseDLs,_ranges,_optClauseDLs),
	store_vm_rules(view(_OID,_ruleIDS,_ranges),_optClauseDLs).

/* store_vm_rules(view(_OID,_ruleIDS,_ranges),_optClauseDLs) Generierung der Sichtenwartungsregeln fuer alle Regeln in CB!*/
/*Denn aus den in VMruleGenerator.pro erzeugten Vmrules werden noch die zugehoerigen Ruleinfos generiert, benoetigt hier noch*/
/*_OID,_ruleIDS, und Vartab zuruecklierfern zu VMruleGenerator.pro .*/



/*===========================================================*/
/*=                LOCAL PREDICATES DEFINITION              =*/
/*===========================================================*/

/*************************************************************/
/** LT(_ruleStruct,_fvs,_resultDLs)                         **/
/**                                                         **/
/** _ruleStruct:im wesentlichen die Rangeform der Formel    **/
/** _fvs:       "freie Variablen der Regel" d.h. die        **/
/**             Variablen die im Kopf der Regel vorkommen   **/
/** _resultDLs: das Ergebnis: eine Liste von Datalog Regeln **/
/**                                                         **/
/** Umwandlung einer PL1 Regel in eine DATALOG-Regel. Die   **/
/** formale Grundlage der Transformation findet sich im     **/
/** Artikel "Making PROLOG more expressive" von Lloyd/Topor **/
/** (deshalb heisst hier auch alles LT)                     **/
/*************************************************************/




'LT'(rule(_cond,_concl),_fvs,[_clauseDL| _clauseDLs]) :-

	/** mache aus der Bedingung DATALOG-Code
	**/
	'LT'(_cond, _fvs, _LTcond, _clauseDLs),
	!,

	/** Klammern nur fuer Operatorpraezedenz
	**/
	_clauseDL = (_concl :- _LTcond) .

/** double not **/
'LT'(not(not(_t)),_fvs,_r,_clauseDLs ) :-
	'LT'(_t,_fvs,_r,_clauseDLs ).

/** exists **/
/** Das Anhaengen des Restterms an den Range bewirkt die korrekte (linksassoziative) Klammerung der DATALOG-Terme
**/
'LT'(exists(_vars,_ranges,'TRUE'),_fvs,_r,_clauseDLs) :-
	set_union(_vars,_fvs,_newfvs),
	!,
	'LT'(and(_ranges),_newfvs,_r,_clauseDLs).

'LT'(exists(_vars,_ranges,and(_as)),_fvs,_res,_clauseDLs) :-
	set_union(_vars,_fvs,_newfvs),
	append(_ranges,_as,_nas),
	!,
	'LT'(and(_nas),_newfvs,_res,_clauseDLs).

'LT'(exists(_vars,_ranges,_rest),_fvs,_res,_clauseDLs) :-
	set_union(_vars,_fvs,_newfvs),
	append(_ranges,[_rest],_as),
	!,
	'LT'(and(_as),_newfvs,_res,_clauseDLs).

/** not exists **/

'LT'(not(exists(_vars,_ranges,_rest)),_fvs,not(_newClauseHead), _newClauseDLs) :-
	needed_free_vars(exists(_vars,_ranges,_rest),_fvs,_needfvs),
	generateNewClauseHead(_needfvs,_newClauseHead),
	'LT'(rule(exists(_vars,_ranges,_rest),_newClauseHead),_needfvs,_newClauseDLs).

/** forall **/

'LT'(forall(_var,_ranges,_rest),_fvs,_r,_clauseDLs) :-
	!,
	'LT'(not(exists(_var,_ranges,not(_rest))),_fvs,_r,_clauseDLs).

/** not forall **/

'LT'(not(forall(_vars,_ranges,_rest)),_fvs,_r,_clauseDLs) :-
	!,
	'LT'(exists(_vars,_ranges,not(_rest)),_fvs,_r,_clauseDLs).

/** and **/

'LT'(and([_a]),_fvs,_r,_clauseDLs) :-
	'LT'(_a,_fvs,_r,_clauseDLs).

/** Sonderfall: exists-Unterbaum in einer and-Liste. Hier muss aufgepasst werden, dass die Klammerung stimmt. Im allgemeinen liefert naemlich LT(exists ...) einen komplexen bereits geklammerten Ausdruck.
**/
'LT'(and([_a|_as]),_fvs,_res,_clauseDLs) :-
	functor(_a,exists,_),
	!,
	'LT'(_a,_fvs,_r,_clauseDLs1),
	'LT'(and(_as),_fvs,_rs,_clauseDLs2),
	!,
	append(_clauseDLs1,_clauseDLs2,_clauseDLs),
	conjunct(_r,_rs,_res).


'LT'(and([_a|_as]),_fvs,_res,_clauseDLs) :-
	'LT'(_a,_fvs,_r,_clauseDLs1),
	'LT'(and(_as),_fvs,_rs,_clauseDLs2),
	!,
	append(_clauseDLs1,_clauseDLs2,_clauseDLs),
	conjunct(_r,_rs,_res).

/** or **/
/** Ich schreibe das 'oder' direkt in den DATALOG Code und erspare mir damit teuere Neuberechnungen beziehungsweise das Merken von Variablen. Leider findet Martin das Generieren von neuen Klauseln besser also habe ich fuer or (und not-and) weitere Faelle implementiert.

LT(or([_o]),_fvs,_r,_clauseDLs) :-
	LT(_o,_fvs,_r,_clauseDLs).

LT(or([_o|_os]),_fvs,(_r;_rs),_clauseDLs) :-
	LT(_o,_fvs,_r,_clauseDLs1),
	LT(or(_os),_fvs,_rs,_clauseDLs2),
	!,
	append(_clauseDLs1,_clauseDLs2,_clauseDLs).
**/

'LT'(or(_os),_fvs,_newClauseHead,_flatDLs) :-
	needed_free_vars(or(_os),_fvs,_needfvs),
	generateNewClauseHead(_needfvs,_newClauseHead),
	save_setof(_clauseDLs,
		[_x]^(
		  pc_member(_x,_os),
		  'LT'(rule(_x,_newClauseHead),_needfvs,_clauseDLs)
		),
		_clauseDLss),
	!,
	makeflat(_clauseDLss,_flatDLs).


/** not and **/

'LT'(not(and(_as)),_fvs,_r,_clauseDLs) :-
	negateTermlist(_as,_os),
	'LT'(or(_os),_fvs,_r,_clauseDLs).


/** not or **/

'LT'(not(or(_as)),_fvs,_r,_clauseDLs) :-
	negateTermlist(_as,_os),
	'LT'(and(_os),_fvs,_r,_clauseDLs).
/*8-Aug-95/MSt: Fehler berichtigt _os und _as vertauscht*/

/** einfaches Literale
**/
'LT'(not('TRUE'),_,'FALSE',[]).

'LT'(not('FALSE'),_,'TRUE',[]).

/** fuer negierte oder positive Literale **/
'LT'(_lit,_,_lit,[]).


/** Erzeugt einen neuen Anfragekopf **/
generateNewClauseHead(_fvs,_newClauseHead) :-
	generateUniqueFunctor(_predname),
	_newClauseHead =.. [_predname|_fvs],
        !.


initUniqueFunctor(id(_,_id2)) :-
	!,
	initUniqueFunctor(_id2).

initUniqueFunctor(_id2) :-
	pc_atomconcat(['ID_',_id2,'_'],_nrulename),
	pc_update(fun(_nrulename,1)).

generateUniqueFunctor(_fun) :-
	!,
	fun(_rulename,_x),
	pc_inttoatom(_x,_xA),
	pc_atomconcat(_rulename,_xA,_fun),
	_nx is _x + 1,
	pc_update(fun(_rulename,_nx)).

/** sucht alle Variablen aus _fvs die in _t wirklich vorkommen.
**/
needed_free_vars(_t,_fvs,_needfvs) :-
	_needfvs = _fvs.

/** Abbruch, falls alle Variablen benoetigt werden
**/
needed_free_vars(_,[],[]).

needed_free_vars(not(_t),_fvs,_needfvs) :-
	needed_free_vars(_t,_fvs,_needfvs).

needed_free_vars(exists(_,_ranges,_t),_fvs,_needfvs) :-
	needed_free_vars(_ranges,_fvs,_needfvs1),
	delete(_needfvs1,_fvs,_fvs1),
	needed_free_vars(_t,_fvs1,_needfvs2),
	append(_needfvs1,_needfvs2,_needfvs).

needed_free_vars(and(_as),_fvs,_needfvs) :-
	needed_free_vars(_as,_fvs,_needfvs).

needed_free_vars(and(_os),_fvs,_needfvs) :-
	needed_free_vars(_os,_fvs,_needfvs).

needed_free_vars([],_,[]) :- !.

needed_free_vars([_t|_ts],_fvs,_needfvs) :-
	needed_free_vars(_t,_fvs,_needfvs1),
	delete(_needfvs,_fvs,_fvs2),
	needed_free_vars(_ts,_fvs2,_needfvs).

needed_free_vars(lit(_l),_fvs,_needfvs) :-
	_l =.. [_|_args],
	findall(_x,
		(
		  pc_member(_x,_args),
		  pc_member(_x,_fvs)
		),
		_needfvs).

/** negateTermlist negiert jedes Listenelement **/
negateTermlist([],[]).

negateTermlist([_t|_ts],[not(_t)|_nts]) :-
	negateTermlist(_ts,_nts).

insert_underscores(_term,[],_term)  :- !.

insert_underscores(_term,[range(_x,_)|_ranges],_nterm) :-
       pc_atomconcat('~',_rest,_x),
	convert_label(_rest,_rest1),
       pc_atomconcat('_at_',_rest1,_ux),
       !,
       substitute(_x,_ux,_term,_nterm1),
/*In _term wo _x vorkommt, wird durch _ux ersetzt, daraus bekommen wir nterm.*/
       !,
       insert_underscores(_nterm1,_ranges,_nterm).

insert_underscores(_term,[range(_x,_)|_ranges],_nterm) :-
	convert_label(_x,_x1),
	pc_atomconcat('_',_x1,_ux),
	!,
	substitute(_x,_ux,_term,_nterm1),
	!,
	insert_underscores(_nterm1,_ranges,_nterm).

substitute(_x,_nx,[],[]).

substitute(_x,_nx,[_t|_ts],[_nt|_nts]) :-
	substitute(_x,_nx,_t,_nt),
	substitute(_x,_nx,_ts,_nts).

/** Term ist nur zu ersetzendes Atom
**/
substitute(_x,_nx,_x,_nx) :- !.


/** Term ist komplex
**/
substitute(_x,_nx,_t,_nt) :-
	_t =.. [_f|_args],
	substitute(_x,_nx,_args,_nargs),
	_nt =.. [_f|_nargs],
        !.

/** Term ist uninteressantes Atom
**/
substitute(_x,_nx,_t,_t) :-
	atom(_t).




/** setUtilities (from BIM libraries) **/



set_union([], _Set2, _Set2).
set_union([_Element|_Residue], _Set, _Union) :-
	memberchk(_Element, _Set),
        !,
	set_union(_Residue, _Set, _Union).
set_union([_Element|_Residue], _Set, [_Element|_Union]) :-
	set_union(_Residue, _Set, _Union).

/** "Konjunktion" zweier Klammerterme
**/
conjunct((_r1,_r1s),_rs,(_r1,_r2s)) :-
	!,
	conjunct(_r1s,_rs,_r2s).

conjunct(_r,_rs,(_r,_rs)).
