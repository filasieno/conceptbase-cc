{*
The ConceptBase.cc Copyright

Copyright 1987-2026 The ConceptBase Team. All rights reserved.

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
* File:         VMruleGenerator.pro
* Version:      11.3
* Creation:    1996, Christoph Quix (RWTH)
* Last Change: 01/19/98, Christoph Quix (RWTH)
* Date released : 98/01/19  (YY/MM/DD)
*
* SCCS-Source-Pool : /home/CBase/CB_NewStruct/ProductPOOL/SCCS/serverSources/Prolog_Files/s.VMruleGenerator.pro
* Date retrieved : 98/03/18 (YY/MM/DD)
*
*----------------------------------------------------------------------------
*
* In diesem Modul werden die aus normalen Datalog-Regeln, die Regeln
* fuer ViewMaintenance erzeugt und ueber CodeCompiler+CodeStorage abgespeichert.
*
* Exported predicates:
*---------------------
*    store_vm_rules/2  (LTcompiler und ViewCompiler)
*		speichert zu einer Liste von Regeln die VM-Regeln
*    get_relevant_rule/2  (cfixpoint)
*       holt zu einem gegeb. Literal die relevanten Regeln
*    load_vmrule/1   (PROLOGruleProcessor)
*       baut die Record-Database zu der Regel auf
*}


#MODULE(VMruleGenerator)
#EXPORT(conjunction/3)
#EXPORT(current_view/3)
#EXPORT(del_rec_db/3)
#EXPORT(get_rec_db/3)
#EXPORT(get_relevant_rule/2)
#EXPORT(is_delta/1)
#EXPORT(load_vmrule/1)
#EXPORT(store_rec_db/3)
#EXPORT(store_vm_rules/2)
#ENDMODDECL()


#IMPORT(generatePROLOGCode/2,CodeCompiler)
#IMPORT(handleCode/3,CodeStorage)
#IMPORT(uniqueAtom/1,GeneralUtilities)
#IMPORT(variable/1,GeneralUtilities)
#IMPORT(member/2,GeneralUtilities)
#IMPORT(delete/3,GeneralUtilities)
#IMPORT(get_cb_feature/2,GlobalParameters)
#IMPORT(initDatalogRulesInfo/7,RuleBase)
#IMPORT(pc_atomconcat/2,PrologCompatibility)
#IMPORT(pc_atomconcat/3,PrologCompatibility)
#IMPORT(pc_record/2,PrologCompatibility)
#IMPORT(pc_record/3,PrologCompatibility)
#IMPORT(pc_rerecord/2,PrologCompatibility)
#IMPORT(pc_rerecord/3,PrologCompatibility)
#IMPORT(pc_recorded/2,PrologCompatibility)
#IMPORT(pc_recorded/3,PrologCompatibility)
#IMPORT(pc_erase/1,PrologCompatibility)
#IMPORT(pc_erase/2,PrologCompatibility)
#IMPORT(pc_current_key/1,PrologCompatibility)
#IMPORT(pc_current_key/2,PrologCompatibility)
#IMPORT(pc_update/1,PrologCompatibility)

#DYNAMIC(current_view/3)

#IF(SWI)
:- style_check(-singleton).
#ENDIF(SWI)





{*******************************************************************}
{*******************************************************************}
{** Teil 1                                                        **}
{** Generieren der Sichtenwartungsregeln aus Datalog-Regeln       **}
{*******************************************************************}
{*******************************************************************}

{===================================================}
{* store_vm_rules(_id,_list)                       *}
{*                                                 *}
{* Transformiert die Datalog-Regeln aus list in    *}
{* VM-Regeln. _id ist der Oid des View/der Rule/...*}
{* Algorithmus aus Staudt/Jarke 1995 (AIB 13)      *}
{*    Incremental maintenance of externally        *}
{*    materialized Views.                          *}
{*                                                 *}
{===================================================}
#MODE(store_vm_rules(i,i))

store_vm_rules(view(_OID,_IDS,_Vartab),_rlist) :-
	get_cb_feature(ViewMaintenanceRules,on),
	pc_update(current_view(_OID,_IDS,_Vartab)),
	process_rules(_rlist).

store_vm_rules(_,_) :-
	get_cb_feature(ViewMaintenanceRules,off).


{===================================================}
{* process_rules(_list)                            *}
{*                                                 *}
{===================================================}
#MODE(process_rules(i))

process_rules([]).
process_rules([_r|_t]) :-
	store_delta_rules(_r),
	process_rules(_t).


{===================================================}
{* store_delta_rules(_rule)                        *}
{*                                                 *}
{===================================================}

#MODE(store_delta_rules(i))

store_delta_rules((_head :- _body )) :-
	store_dis(_head,_body),
	store_nis(_head,_body),
	store_r(_head,_body),
	store_iis(_head,_body),
	store_eis(_head,_body).

store_delta_rules(_fact) :-
	_fact \= (_h :- _b).


{===================================================}
{* store_dis(_head,_body)                          *}
{*                                                 *}
{===================================================}
#MODE(store_dis(i,i))

store_dis(_head,_body) :-
	get_delta_bodies(_body,_delbodies,del),
	store_rules(del(_head),_delbodies).


{===================================================}
{* store_nis(_head,_body)                          *}
{*                                                 *}
{===================================================}
#MODE(store_nis(i,i))

 { N1-Regel nicht erzeugen, werden mit prove_literal bewiesen}
 { N1-Regeln wurden sonst bei cfixpoint nicht als relevant erkannt. }
store_nis(_head,_body) :-
{    store_rule((new(_head) :- _head , not del(_head))),} { N1 }
	store_rule((new(_head) :- red(_head))),             { N2 }
	store_rule((new(_head) :- ins(_head))).             { N3 }
{	store_base_nis(_body).}  { Sind schon in cfixpoint gespeichert}


{===================================================}
{* store_base_nis(_head,_body)                     *}
{*                                                 *}
{===================================================}
#MODE(store_base_nis(i))

 { N1-Regel nicht erzeugen, werden mit prove_literal bewiesen}
 { N1-Regeln wurden sonst bei cfixpoint nicht als relevant erkannt. }

 { Hier auch N2 erzeugen, da es in ConceptBase keine eindeutige }
 { Unterscheidung zwichen Basispraedikaten (In, Adot, ...) und  }
 { aus Regeln gefolgerten Praedikaten gibt.                     }
store_base_nis(_lit) :-
	_lit \= (_,_),
	base_literal(_lit),
{	store_rule((new(_lit) :- _lit, not del(_lit))),}  { N1 }
	store_rule((new(_lit) :- red(_lit))),             { N2 }
	store_rule((new(_lit) :- ins(_lit))).             { N3 }

store_base_nis(_lit) :-
	_lit \= (_,_),
	\+ base_literal(_lit).

store_base_nis((_lit,_lits)) :-
	store_base_nis(_lit),
	store_base_nis(_lits).


#MODE(base_literal(i))

base_literal(Adot(_,_,_,_)).
base_literal(A(_,_,_)).
base_literal(Ai(_,_,_,_)).
base_literal(In(_,_)).
base_literal(Isa(_,_)).
base_literal(From(_,_)).
base_literal(To(_,_)).
base_literal(UNIFIES(_,_)).
base_literal(IDENTICAL(_,_)).
base_literal(GE(_,_)).
base_literal(LE(_,_)).
base_literal(LT(_,_)).
base_literal(GT(_,_)).
base_literal(EQ(_,_)).
base_literal(NE(_,_)).
base_literal(TRUE).
base_literal(Known(_,_)).


{===================================================}
{* store_r(_head,_body)                            *}
{*                                                 *}
{===================================================}
#MODE(store_r(i,i))

store_r(_head,_body) :-
	add_body_functor(_body,new,_newbody),
	store_rule((red(_head) :- del(_head), _newbody)).


{===================================================}
{* store_iis(_head,_body)                          *}
{*                                                 *}
{===================================================}
#MODE(store_iis(i,i))

store_iis(_head,_body) :-
	get_delta_bodies(_body,_insbodies,ins),
	add_new_to_bodies(_insbodies,_newbodies),
	store_rules(ins(_head),_newbodies).


{===================================================}
{* store_eis(_head,_body)                          *}
{*                                                 *}
{===================================================}
#MODE(store_eis(i,i))

store_eis(_head,_body) :-
	store_rule((plus(_head) :- ins(_head), not(_head))),
	store_rule((minus(_head) :- del(_head), not(ins(_head)), not(red(_head)))).


{===================================================}
{* store_rules(_head,_bodylist)                    *}
{*                                                 *}
{===================================================}
#MODE(store_rules(i,i))

store_rules(_head,[]).
store_rules(_head,[_body1|_rbodies]) :-
	store_rule((_head :- _body1)),
	store_rules(_head,_rbodies).

{Die PrologCode von generierten Regel fuer sichtwartung wird erst nach der Optimierung }
{erzeugt,und dann entsprenchend gespeichert, hier macht nur einfach Initialisierung der}
{Ruleinfos fuer die Vmrules.}

#MODE(store_rule(i))

store_rule((_head :-_tail)) :-
	current_view(_OID,_IDS,_Vartab),
{* Hier wird aus RuleInfo Initialisierung ein eindeutige ruleId als viewId zurueckliefern. *}
	initDatalogRulesInfo(_head,_tail,vmrule,_OID,_IDS,_Vartab,_viewid),
	store_rule_info(_viewid,(_head :-_tail)).



{===================================================}
{* get_delta_bodies(_lits,_deltas,_head)           *}
{*                                                 *}
{* _lits ist ein Regelrumpf, _head ist der Funktor *}
{* fuer das Deltaliteral, und _deltas ist ein Liste*}
{* von Regelruempfen mit den eingefuegten Deltas   *}
{*                                                 *}
{===================================================}
#MODE(get_delta_bodies(i,o,i))

get_delta_bodies(_lits,_deltas,_head) :-
	get_delta_bodies(true,_lits,_deltas,_head).

#MODE(get_delta_bodies(i,i,o,i))

get_delta_bodies(true,(_first,_rest),[(_deltafirst,_rest)|_deltas],_head) :-
	!,
	create_delta(_first,_head,_deltafirst),
	get_delta_bodies(_first,_rest,_deltas,_head).

get_delta_bodies(true,_lit,[_deltalit],_head) :-
	_lit \= (_,_),
	!,
	create_delta(_lit,_head,_deltalit).

get_delta_bodies(_lits,(_first,_rest),[_body|_deltas],_head) :-
	_lits \= true,
	!,
	create_delta(_first,_head,_deltafirst),
	conjunction((_deltafirst,_lits),_rest,_body),
	conjunction(_lits,_first,_flits),
	get_delta_bodies(_flits,_rest,_deltas,_head).

get_delta_bodies(_lits,_first,[(_deltafirst,_lits)],_head) :-
	_lits \= true,
	_first \= (_,_),
	create_delta(_first,_head,_deltafirst).



{===================================================}
{* conjunction(_r1,_r2,_r3)                        *}
{*                                                 *}
{* Verknuepft zwei Regelruempfe so, dass auch die  *}
{* Klammerung stimmt (d.h. keine Klammerung)       *}
{*                                                 *}
{===================================================}
#MODE(conjunction(i,i,o))

conjunction(_lit,_rest,(_lit,_rest)) :-
	_lit \= (_,_).

conjunction((_first,_lits),_rest,(_first,_restlits)) :-
	conjunction(_lits,_rest,_restlits).


{===================================================}
{* add_body_functor(_lits,_func._flits)            *}
{*                                                 *}
{* Gibt jedem Literal des Regelrumpfes lits den    *}
{* Funktor _func zusaetzlich.                      *}
{*                                                 *}
{===================================================}
#MODE(add_body_functor(i,i,o))

add_body_functor(_lit,_f,_flit) :-
	_lit \= (_,_),
	create_delta(_lit,_f,_flit).

add_body_functor((_lit,_rlits),_f,(_flit,_frlits)) :-
	add_body_functor(_lit,_f,_flit),
	add_body_functor(_rlits,_f,_frlits).


{===================================================}
{* add_new_to_bodies(_bodylist,_newbodylist)       *}
{*                                                 *}
{* Alle Literale der bodylist erhalten zusaetzlich *}
{* den Funktor new(_l), wenn sie nicht die Form    *}
{* ins(_) haben.                                   *}
{*                                                 *}
{===================================================}
#MODE(add_new_to_bodies(i,o))

add_new_to_bodies([],[]).
add_new_to_bodies([_h|_t],[_newh|_newt]) :-
	add_new_to_bodies2(_h,_newh),
	add_new_to_bodies(_t,_newt).

#MODE(add_new_to_bodies2(i,o))

add_new_to_bodies2(_lit,_newlit) :-
	_lit \= (_,_),
	((_lit \= ins(_), _lit \= del(_), _lit \= minus(_), _lit \= plus(_),
	   create_delta(_lit,new,_newlit)
	 );
	 ( is_delta(_lit), _lit \= red(_),lit \= new(_),
	  _newlit = _lit
	)).


add_new_to_bodies2((_lit,_rlits),(_newlit,_newrlits)) :-
	add_new_to_bodies2(_lit,_newlit),
	add_new_to_bodies2(_rlits,_newrlits).


{===================================================}
{* create_delta(_lit,_functor,_deltalit)           *}
{*                                                 *}
{===================================================}
#MODE(create_delta(i,i,o))

create_delta(not(_l),del,plus(_l)).
create_delta(not(_l),ins,minus(_l)).
create_delta(not(_l),new,not(new(_l))).
create_delta(_l,del,del(_l)) :- _l \= (not(_)).
create_delta(_l,ins,ins(_l)) :- _l \= (not(_)).
create_delta(_l,new,new(_l)) :- _l \= (not(_)).


#MODE(is_delta(?))

is_delta(ins(_)).
is_delta(del(_)).
is_delta(red(_)).
{is_delta(new(_)).}
is_delta(plus(_)).
is_delta(minus(_)).


{*******************************************************************}
{*******************************************************************}
{** Teil 2                                                        **}
{** Laden, Speichern und Loeschen von Regeln                      **}
{*******************************************************************}
{*******************************************************************}

{*******************************************************************}
{                                                                   }
{ load_vmrule(_vmrule)                                              }
{                                                                   }
{ Description of arguments:                                         }
{  vmrule : Term der Form vmrule(id,rule)                           }
{                                                                   }
{ Description of predicate:                                         }
{  Der PROLOGruleProcessor laedt die Regeln aus OB.rule. Fuer die   }
{  VM-Regeln wird mit store_rule_info ein Index fuer effizienten    }
{  Zugriff angelegt.                                                }
{*******************************************************************}

#MODE(load_vmrule(?))

load_vmrule(vmrule(_id,_r)) :-
	store_rule_info(_id,_r),
	assert(vmrule(_id,_r)).



{*******************************************************************}
{                                                                   }
{ store_rule_info(_id,_rule)                                        }
{                                                                   }
{ Description of arguments:                                         }
{      id : ID der Regel (kein ID des Objektspeichers!)             }
{    rule : Regel                                                   }
{                                                                   }
{ Description of predicate:                                         }
{   Zu jedem Delta-Praedikat werden die Regeln abgespeichert, in    }
{   denen es vorkommt. Dadurch kann man in cfixpoint schneller auf  }
{   auf die relevanten Regeln zugreifen, d.h. die Regeln, in denen  }
{   sich was geaendert hat.                                         }
{*******************************************************************}

#MODE(store_rule_info(i,?))

store_rule_info(_id,_r) :-
	get_delta(_r,_delta),
	store_info(_id,_delta),
	fail.

store_rule_info(_id,_r).


#MODE(store_info(i,?))

store_info(_id,_delta) :-
	_delta =..[_f,_lit],
	compute_key(_lit,_f,_key,_domain),
	store_rec_db(_key,_domain,_id),
	!.


#MODE(get_delta(?,?))

get_delta((_head :- _body),_delta) :-
	get_delta(_body,_delta).

get_delta((_delta,_rest),_delta) :-
	is_delta(_delta).

get_delta((_,_rest),_delta) :-
	get_delta(_rest,_delta).

get_delta(_delta,_delta) :-
	_delta \= (_,_),
	is_delta(_delta).



{*******************************************************************}
{                                                                   }
{ compute_key(_lit,_delta,_key,_domain)                             }
{                                                                   }
{ Description of arguments:                                         }
{     lit : Literal (ohne Delta) fuer das Key berechnet werden soll }
{   delta : Delta-Functor als Atom                                  }
{     key : Schluessel         fuer                                 }
{  domain : Domain         Record-Database                          }
{                                                                   }
{ Description of predicate:                                         }
{   Fuer das Literal delta(lit), wird ein Schluessel berechnet.     }
{   Der Schluessel setzt aus dem Wort 'key' und den belegten Var.   }
{   des Literals zusammen (Fuer In(_x,id) ist Schluessel 'keyid').  }
{   domain hat das Prefix 'VM_' mit delta, dem Funktor des Literals }
{   und dem Belegungspattern als Suffixe (Fuer In(_x,id) mit Delta  }
{   ins ist die Domain: 'VM_insInfb').                              }
{*******************************************************************}

#MODE(compute_key(?,i,o,o))

compute_key(_lit,_delta,_key,_domain) :-
	_lit =.. [_f|_args],
	compute_key2(_args,_pat,'key',_key),
	pc_atomconcat(['VM_',_delta,_f,_pat],_domain).

#MODE(compute_key2(?,o,i,o))

compute_key2([],'',_k,_k).

compute_key2([_h|_r],_pat,_k,_k2) :-
	(var(_h);variable(_h)),
	compute_key2(_r,_pat2,_k,_k2),
	pc_atomconcat(f,_pat2,_pat).

compute_key2([_h|_r],_pat,_k,_k3) :-
        getArgSave(_h,_hatom),                   {* 9-Jul2004/M.Jeusfeld *}
	pc_atomconcat(_k,_hatom,_k2),
	compute_key2(_r,_pat2,_k2,_k3),
	pc_atomconcat(b,_pat2,_pat).



{*******************************************************************}
{                                                                   }
{ get_relevant_rule(_lit,_rule)                                     }
{                                                                   }
{ Description of arguments:                                         }
{     lit : ein Delta-Literal                                       }
{    rule : eine Regel, in der lit vorkommt                         }
{                                                                   }
{ Description of predicate:                                         }
{   Holt zu Delta-Literal lit die entsprechenden Regeln (Backtrack).}
{*******************************************************************}

#MODE(get_relevant_rule(i,o))

get_relevant_rule(_lit,_r) :-
	generate_keys(_lit,_key,_domain),
	pc_current_key(_key,_domain),
	get_rec_db(_key,_domain,_id),
	pc_recorded(vmrules,VMruleGenerator,_ruleids),
	member(_id,_ruleids),
	vmrule(_id,_r),
	bind_vars(_lit,_r).




{*******************************************************************}
{                                                                   }
{ bind_vars(_lit,_rule)                                             }
{                                                                   }
{ Description of arguments:                                         }
{     lit : Literal, mit den Variablenbindungen                     }
{    rule : Regel, deren Variablen gebunden werden sollen           }
{                                                                   }
{ Description of predicate:                                         }
{   Ein Delta-Literal enthaelt in der Regel auch Variablen. Bei der }
{   der Auswertung werden diese Variablen gebunden. Die Variablen   }
{   kommen in der Regel mehrmals vor und muessen deshalb gebunden   }
{   werden.                                                         }
{*******************************************************************}

#MODE(bind_vars(i,?))

bind_vars(_lit,_lit) :-!.
bind_vars(_lit,(_r:-_b)) :-
	bind_vars(_lit,_b),
	!.

bind_vars(_lit,(_lit,_r)) :-!.
bind_vars(_lit,(_,_r)) :-
	bind_vars(_lit,_r),
	!.

bind_vars(_lit,_):-!.



{*******************************************************************}
{                                                                   }
{ generate_keys(_lit,_key,_domain)                                  }
{                                                                   }
{ Description of predicate:                                         }
{   Fuer das Delta-Literal muessen alle moeglichen Schluessel       }
{   generiert werden. In lit selbst sind alle Argumente gebunden,   }
{   aber das Literal kann mit freien Variablen in einem Regelrumpf  }
{   benutzt werden. Daher muessen alle moeglichen Belegungsmuster   }
{   per Backtracking generiert werden. (vgl. compute_key )          }
{                                                                   }
{*******************************************************************}

#MODE(generate_keys(i,o,o))

generate_keys(_lit,_key,_domain) :-
	_lit =.. [_delta,_lit2],
	_lit2 =.. [_f|_args],
	generate_keys2(_args,_pat,'key',_key),
	pc_atomconcat(['VM_',_delta,_f,_pat],_domain).

#MODE(generate_keys2(i,o,i,o))

generate_keys2([],'',_k,_k).
generate_keys2([_h|_r],_pat,_k,_k2) :-
	generate_keys2(_r,_pat2,_k,_k2),
	pc_atomconcat(f,_pat2,_pat).

generate_keys2([_h|_r],_pat,_k,_k3) :-
        getArgSave(_h,_hatom),                   {* 9-Jul2004/M.Jeusfeld *}
	pc_atomconcat(_k,_hatom,_k2),
	generate_keys2(_r,_pat2,_k2,_k3),
	pc_atomconcat(b,_pat2,_pat).


{* Since the introduction of complex query calls (CBNEWS[215] *}
{* arguments of query litarals can be other query literals.   *}
{* Hence, thye old assumption that an argument is either an   *}
{* atom or a variable ('_*'). is no longer true. getArgAtom   *}
{* returns fir query literals their functor which is always   *}
{* an atom. This solves the problem of wrong calls of         *}
{* pc_atomconcat.                                                *}

getArgSave(_a,_a) :- atom(_a),!.
getArgSave(_x,_x) :- var(_x),!.

getArgSave(_qlit,_qid) :-
  compound(_qlit),
  _qlit =.. [_qid|_].



{*** RECORD-DATABASE ***}
{** Speichern **}
#MODE(store_rec_db(i,i))

store_rec_db(_key,_value) :-
	store_rec_db(_key,0,_value).

#MODE(store_rec_db(i,i,i))

{ Fall 1: Schluessel wird schon benutzt, daher Wertliste erweitern }
store_rec_db(_key,_domain,_value) :-
	pc_recorded(_key,_domain,_old),
	pc_rerecord(_key,_domain,[_value|_old]),
	!.

{ Fall 2: Schluessel unbenutzt, daher Wert als Liste speichern }
store_rec_db(_key,_domain,_value) :-
	pc_record(_key,_domain,[_value]),
	!.


{** Zugriff **}
#MODE(get_rec_db(i,o))

get_rec_db(_key,_value) :-
	get_rec_db(_key,0,_value).

#MODE(get_rec_db(i,i,o))

get_rec_db(_key,_domain,_value) :-
	pc_recorded(_key,_domain,_list),
	{ Alle Element sukzessive via Backtracking aus Liste holen }
	member(_value,_list).


{** Loeschen eines Elements **}
#MODE(del_rec_db(i,i,i))

del_rec_db(_key,_domain,_value) :-
	pc_recorded(_key,_domain,_old),
	delete(_value,_old,_new),
	((_new \= [],pc_rerecord(_key,_domain,_new));
	 (_new =[],pc_erase(_key,_domain))
	),
	!.

