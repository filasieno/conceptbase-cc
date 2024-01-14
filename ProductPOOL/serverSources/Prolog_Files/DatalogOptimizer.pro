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

{******      DIESES MODUL WIRD NICHT MEHR GENUTZT !!! *********}
{******      DURCH QO_* ersetzt                       *********}

{*
*
* File 		: DatalogOptimizer.pro
* Version	: 1.4
* Creation	: 28-Aug-95,  Christoph Quix (RWTH)
* Last change 	: 05 Oct 1995, Hans W. Nissen (RWTH)
* Release	: 1
*
*-----------------------------------------------
*
*  optimze/2 wird von QueryCompiler nach generateDatalog aufgerufen,
*  und soll die Reihenfolge der Literale in der Datalog-Regel optimieren.
*
*  HWN, 05-Oct-1995: intersect/3 benutzt, aber nicht aus GeneralUtilities importiert worden.
* HWN, 05-Oct-1995: delete/3 und subtract/3 benutzt, aber nicht aus GeneralUtilities importiert.
*
*}

#MODULE(DatalogOptimizer)
#EXPORT(get_free_args/2)
#ENDMODDECL()


#IMPORT(get_pattern/3,QueryCompiler)
#IMPORT(specialize_rule/3,RuleSpecializer)
#IMPORT(member/2,GeneralUtilities)
#IMPORT(append/3,GeneralUtilities)
#IMPORT(name2id/2,GeneralUtilities)
#IMPORT(split_atom/4,GeneralUtilities)
#IMPORT(intersect/3,GeneralUtilities)
#IMPORT(big_lit/1,CostModel)
#IMPORT(smaller_lit/2,CostModel)
#IMPORT(delete/3,GeneralUtilities)
#IMPORT(subtract/3,GeneralUtilities)
#IMPORT(preprocRuleList/3,QO_preproc)
#IMPORT(pc_atomconcat/2,PrologCompatibility)
#IMPORT(pc_atomconcat/3,PrologCompatibility)
#IMPORT(pc_atomtolist/2,PrologCompatibility)
#IMPORT(pc_atompart/4,PrologCompatibility)


#IF(SWI)
:- style_check(-singleton).
#ENDIF(SWI)


{===========================================================}
{=             EXPORTED PREDICATES DEFINITION              =}
{===========================================================}

{===========================================================}
{* optimizeRuleList/2                                      *}
{* Optimiere eine Liste von Datalog-Regeln.                *}
{===========================================================}

optimizeRuleList([],_,[]).

optimizeRuleList([_rule|_t],_ranges,[_newrule|_newt]) :-
	preprocRuleList(_rule,_ranges,_literals),
	optimize(_rule,_newrule),
	optimizeRuleList(_t,_ranges,_newt).


{===========================================================}
{* optimize/2                                              *}
{* Optimiere die Reihenfolge einer Datalog-Regel.          *}
{* 1. Hole mit get_pattern die Belegung der Variablen im   *}
{*    Kopf des Literals. Bei GQCs sind naemlich einige Var.*}
{*    immer belegt. Bei Regeln sind alle Variablen frei.   *}
{* 2. Ziehe die In-Literale mit den Variablen aus dem Kopf *}
{*    aus dem Datalog-Body raus, und fuege sie spaeter am  *}
{*    Anfang des Body ein. Diese In-Literale sind meistens *}
{*    naemlich In_bb-Literale, da man die Parameter meist  *}
{*    substituiert. Wenn man die Parameter spezialisiert   *}
{*    ist auch nicht schlimm, da dies i.d.R. eine Klasse   *}
{*    ist. Dadurch hat man die Variablen der Parameter     *}
{*    direkt am Anfang gebunden => bessere Optimierung     *}
{* 3. Fuege zu den Literalen in Kopf und Rumpf der Regel   *}
{*    die Belegungsinfo. hinzu. (spepcialize_rule)         *}
{* 4. Versuche die Reihenfolge zu aendern, (reorder_lit.)  *}
{*    verwerfe die Belegungsinfo. wieder (remove_pattern)  *}
{*    und fuege die In-Literale fuer die Parameter wieder  *}
{*    ein. (add_lits)                                      *}
{===========================================================}

optimize((_head :- _body),(_head:-_newbody2)):-
        get_pattern(_head,_pattern,_parclasslist),
		get_in_with_parclass(_parclasslist,_body,_inlist,_restbody),
        specialize_rule(_pattern,(_head :- _restbody),_specialrule),
        _specialrule=(_shead :- _sbody),
        reorder_literals(_sbody,_rebody,0),
		!,
        remove_pattern(_rebody,_newbody),
		add_lits(_inlist,_newbody,_newbody2).

{===========================================================}
{=                LOCAL PREDICATES DEFINITION              =}
{===========================================================}

{===========================================================}
{* reorder_literals(_lit,_newlit,_n)                       *}
{* Versuche die Reihenfolge der Literale zu optimieren,    *}
{* und zwar solange bis im letzten Schritt keine Veraen-   *}
{* derung erreicht wurde bzw. 100 Iterationen gemacht      *}
{* worden sind. Letzteres ist nur zur Sicherheit und sollte*}
{* eigentlich nicht auftreten.                             *}
{===========================================================}

reorder_literals(_literals,_literals,100).

reorder_literals(_literals,_newliterals,_n) :-
	reorder(_literals,_literals2),
	((_literals == _literals2,
	  _newliterals = _literals
	 );
	 (_n1 is _n + 1,
	  reorder_literals(_literals2,_newliterals,_n1)
	 )
	).


{===========================================================}
{* remove_pattern/2                                        *}
{* Entfernt von einer Literalkonjunktion bzw. von einem    *}
{* Literal die Belegungsinfo.                              *}
{===========================================================}

remove_pattern((_f,_t),(_newf,_newt)) :-
	remove_pattern(_f,_newf),
	remove_pattern(_t,_newt).

remove_pattern(not(_f),not(_newf)) :-
	remove_pattern(_f,_newf).

remove_pattern(_f,_newf) :-
	_f \== (_,_),
	_f =.. [_h |_args],
	split_atom(_h,'_',_newh,_pat),
	not pc_atompart(_pat,'_',_,_),
	_newf =.. [_newh|_args].



{===========================================================}
{* get_in_with_parclass(_vars,_lits,_inlits,_restlits)     *}
{* Nimmt die In-Literale aus lits heraus, die als zweites  *}
{* Argument ein Element aus _vars haben. Diese In-Literale *}
{* werden in _inlits zurueckgegeben, der Rest in _restlits.*}
{===========================================================}

get_in_with_parclass([],_body,[],_body).

get_in_with_parclass(_list,(In(_x,_c),_body),[In(_x,_c)|_rins],_newbody) :-
	member(_c,_list),
	delete(_c,_list,_rlist),
	get_in_with_parclass(_rlist,_body,_rins,_newbody).

get_in_with_parclass(_list,In(_x,_c),[In(_x,_c)],true) :-
	member(_c,_list).

get_in_with_parclass(_list,(_lit,_rlits),_ins,_newlits) :-
	get_in_with_parclass(_list,_rlits,_ins,_new),
  	((_new == true,
	  _newlits = _lit
	 );
	 (_new \== true,
	  _newlits = (_lit,_new)
	 )
	).

get_in_with_parclass(_list,_lit,[],_lit) :-
	_lit \= (_,_).


{===========================================================}
{* add_lits(_lits,_body,_newbody)	  					   *}
{* Fuegt die Literale aus _lits am Anfang des Regelrumpfes *}
{* body ein, d.h. body ist eine Konjunktion von Literalen. *}
{===========================================================}

add_lits([],_body,_body).

add_lits([_lit|_t],_body,(_lit,_newbody)) :-
	add_lits(_t,_body,_newbody).


{===========================================================}
{* reorder(_in,_out)                                       *}
{* Dieses Praedikat macht die ganze Arbeit hier.           *}
{* _in ist ein Regelrumpf, der von links nach rechts durch-*}
{* gegangen wird. Trifft man dabei auf ein Literal, das    *}
{* "groesser" als das naechste Literal ist, so werden diese*}
{* beiden vertauscht. "Grosse" Literale werden also zuerst *}
{* nach rechts geschoben. "Einfache" Literale werden je    *}
{* Durchgang um max. eine Stelle nach links geschoben.     *}
{* Deshalb ist es noetig, dass dieses Praedikat von        *}
{* reorder_literals mehrmals aufgerufen wird bis sich      *}
{* nichts mehr aendert.                                    *}
{===========================================================}

{* Es ist nur ein Literal da, keine Konjunktion mehr *}
reorder(_lit,_lit) :-
	_lit \= (_,_).

reorder((_h1,(_h2,_t)),(_newh1,_newt)) :-
	reorder((_h1,_h2),(_newh1,_newh2)),
	reorder((_newh2,_t),_newt).


{* Bei negierten Literalen sind alle Variablen gebunden,
 * und das soll auch so bleiben, falls man die vertauscht.
 * Negierte Literale werden nur vor "grossen" Literalen geschoben,
 * um sich evtl. die Auswertung der "grossen" Literale zu sparen. *}
reorder((_h1,not(_h2)),(not(_h2),_h1)) :-
	_h1 \= (not(_)),
	big_lit(_h1),
	_h2 =.. [_f|_args],
	get_free_args(_h1,_freeargs1),
	get_free_args(_h2,_freeargs2),
	subtract(_args,_freeargs2,_bargs),
	intersect(_freeargs1,_bargs,[]).

{* Schiebe not-Literale nach hinten, falls sie vor einem
 * Literal stehen, dass nicht "big" ist. *}
reorder((not(_h1),_h2),(_h2,not(_h1))) :-
	_h2 \= (not(_)),
    not big_lit(_h2).

{* Ein IDENTICAL mit zwei belegten Variablen kann bei Vertauschung in ein
 * UNIFIES mit einer belegten Variablen umgewandelt werden. *}
reorder((_h1,_h2),(_newh2,_newh1)) :-
	_h2 = IDENTICAL_bb(_x,_y),
	_h1 \= (not(_)),
	get_free_args(_h1,_freeargs1),
	((intersect(_freeargs1,[_x,_y],[_x]),
	  set_args(b,_h1,[_x],_newh1),
	  _newh2 = UNIFIES_fb(_x,_y)
	 );
	 (intersect(_freeargs1,[_x,_y],[_y]),
	  set_args(b,_h1,[_y],_newh1),
	  _newh2 = UNIFIES_bf(_x,_y)
	 )
	).

{* Der Standardfall: h2 ist einfacher als h1 auszuwerten,
 * deshalb werden die beiden vertauscht, wenn nicht durch die
 * Vertauschung das neue Literal newh2 schlechter wird als h1. *}
reorder((_h1,_h2),(_newh2,_newh1)) :-
	_h2 \= (_,_),
	_h1 \= (not(_)),
	_h2 \= (not(_)),
	smaller_lit(_h2,_h1),
	_h2 =.. [_f2|_args2],
	get_free_args(_h1,_freeargs1),
	intersect(_freeargs1,_args2,_args),
	set_args(b,_h1,_args,_newh1),
	set_args(f,_h2,_args,_newh2),
	smaller_lit(_newh2,_h1).

{* Keine Vertauschung moeglich *}
reorder((_h1,_h2),(_h1,_h2)).


{===========================================================}
{* get_free_args(_lit,_args)                               *}
{* Gibt die freien Argumente eines Literals zurueck.       *}
{* (Literal hat bereits Belegungspattern, z.B. In_fb       *}
{===========================================================}

get_free_args(not(_lit),_freeargs) :-
	get_free_args(_lit,_freeargs).

get_free_args(_lit,_freeargs) :-
	_lit \= (not(_)),
	_lit =.. [_f|_allargs],
	split_atom(_f,'_',_truelit,_pat),
	not pc_atompart(_pat,'_',_,_),
	pc_atomtolist(_pat,_patlist),
	get_free_args_list(_allargs,_patlist,_freeargs).


get_free_args_list([],[],[]).

get_free_args_list([_arg|_restargs],[f|_restpats],[_arg|_restfreeargs]) :-
	get_free_args_list(_restargs,_restpats,_restfreeargs).

get_free_args_list([_arg|_restargs],[b|_restpats],_restfreeargs) :-
	get_free_args_list(_restargs,_restpats,_restfreeargs).


{===========================================================}
{* set_args(_mode,_lit,_args,_newlit)					   *}
{* Setzt die Argumente eines Literals auf _mode (f oder b) *}
{* d.h. der Belegungspattern wird angepasst.               *}
{===========================================================}

set_args(_mode,_lit,[],_lit).

set_args(_mode,not(_lit),_setargs,not(_newlit)) :-
	set_args(_mode,_lit,_setargs,_newlit).

set_args(_mode,_lit,_setargs,_newlit) :-
	_lit \= (not(_)),
	_lit =.. [_f|_args],
	split_atom(_f,'_',_truelit,_pattern),
	not pc_atompart(_pattern,'_',_,_),
	pc_atomtolist(_pattern,_patlist),
	set_args2(_mode,_args,_setargs,_patlist,_newpatlist),
	pc_atomtolist(_newpattern,_newpatlist),
	pc_atomconcat([_truelit,'_',_newpattern],_newfunc),
	_newlit =.. [_newfunc|_args].

set_args2(_mode,_args,[],_patlist,_patlist).

set_args2(_mode,[_arg|_restargs],[_arg|_restsetargs],[_pat|_restpatlist],[_mode|_newpatlist]) :-
	!,
	set_args2(_mode,_restargs,_restsetargs,_restpatlist,_newpatlist).

set_args2(_mode,[_arg|_restargs],[_arg2|_restsetargs],[_pat|_restpatlist],[_pat|_newpatlist]) :-
	_arg \== _arg2,
	set_args2(_mode,_restargs,[_arg2|_restsetargs],_restpatlist,_newpatlist).



