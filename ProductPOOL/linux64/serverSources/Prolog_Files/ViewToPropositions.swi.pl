/**
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
**/
/**
*
* File 		: %M%
* Version	: %I%
* Creation	: 14-Mar-95,  Christoph Quix (RWTH)
* Last change : %G%, Christoph Quix (RWTH)
* Release	: %R%
*
*-----------------------------------------------
*
* Transformation of special parts of a SMLfragment
* (enumeration, selectExpB, complexRef, ..) to Propositions.
**/

:- module('ViewToPropositions',[
'qclist'/2
,'store_complexRef'/3
,'store_enumeration'/3
,'store_selectExpB'/3
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').


:- use_module('VarTabHandling.swi.pl').
:- use_module('MSFOLassertionParserUtilities.swi.pl').

:- use_module('FragmentToPropositions.swi.pl').







:- use_module('validProposition.swi.pl').
:- use_module('Literals.swi.pl').
:- use_module('GeneralUtilities.swi.pl').





:- use_module('ScanFormatUtilities.swi.pl').
:- use_module('SelectExpressions.swi.pl').
:- use_module('MSFOLpreProcessor.swi.pl').




:- use_module('PrologCompatibility.swi.pl').




/*===========================================================*/
/*=              LOCAL PREDICATE DECLARATION                =*/
/*===========================================================*/







:- dynamic 'qclist'/2 .


:- style_check(-singleton).



/*===========================================================*/
/*=             EXPORTED PREDICATES DEFINITION              =*/
/*===========================================================*/

/*************************************************************/
/* store_selectExpB(_x,_AClist,_prop)                        */
/*                                                           */
/*   Fuer eine SelectExpB wird eine QC angelegt, die als     */
/*   Constraint                                              */
/*   "this in <SelectExpB>" enthaelt.                        */
/*                                                           */
/*************************************************************/

/* Fall 1: this|. ...  (SelectExpressions mit this als erstes Objekt => Parameter fuer QC benoetigt) */
store_selectExpB(_xid,_AClist,property(_l,selectExpB(_this,_op,_right))) :-
	(_this == 'this' ; _this == '~this'),
	!,
	id2name(_xid,_x),
	create_subview_name(_x,_l,_qc),
	_par = '~this_par',
	saveVarTabInsert(['~this'],[_xid]),    /* Implizite Variable this in VarTab eintragen */
	replaceSelectExpB(selectExpB('~this',_op,_right),'~this',_destid,_newterm),  /* nur _dest ermitteln */
    pc_atomconcat('constr_',_l,_cprop),
    rebuildSelectExpB(selectExpB(_par,_op,_right),_selectAtom),
	pc_atomconcat(['$ ~this in ',_selectAtom,' $'],_constr),
	_attrdecl2=attrdecl([constraint],[property(_cprop,_constr)]),
	pc_atomconcat('~',_par_ohne_at,_par),
	(qclist(_,_qclist);
	 _qclist = [q(_qc,[p(_par_ohne_at,_x)])]
	),
	name2id('View',_vid),
    store_Sub_Object(what(_qc),in(_vid),isa([class(_destid)]),with([_attrdecl2]),_qclist),
    store_property(_xid,_AClist,property(_l,derive(_qc,[substitute('~this',_par_ohne_at)]))).

/* Fall 2: obj|. ... (SelectExpressions mit beliebigem Objekt)
* (hier werden auch SelectAusdruecke mit Scope-Resolution-Operator behandelt, der vorher schon ersetzt
*  wurde) */
store_selectExpB(_xid,_AClist,property(_l,selectExpB(_obj1,_op,_right))) :-
	_obj1 \== '~this',
	_obj1 \== this,
	id2name(_xid,_x),
	eval(_obj1,replaceSelectExpression,_obj),
	create_subview_name(_x,_l,_qc),
	'VarTabLookup_ranges'(_r),
	replaceSelectExpB(selectExpB(_obj,_op,_right),'~this',_destid,_newterm),  /* nur _dest ermitteln */
	!,
	pc_atomconcat('constr_',_l,_cprop),
	rebuildSelectExpB(selectExpB(_obj,_op,_right),_selectAtom),
	pc_atomconcat(['$ ~this in ',_selectAtom,' $'],_constr),
	_attrdecl1=attrdecl([constraint],[property(_cprop,_constr)]),
	(qclist(_,_qclist);
	 _qclist = []
	),
	!,
	name2id('View',_vid),
	store_Sub_Object(what(_qc),in(_vid),isa([class(_destid)]),with([_attrdecl1]),_qclist),
	store_complex_property(_xid,_AClist,property(_l,_qc),_qclist).

/*************************************************************/
/* store_complexRef(_x,_AClist,property(_l,_smlfrag))        */
/*                                                           */
/*   Fuer einen geschachtelten Frame wird eine neue QC       */
/*   angelegt, die wieder komplexe Ausdruecke enthalten kann */
/*   wofuer weitere QCs angelegt werden muessen              */
/*                                                           */
/*   Bevor die neuen QC abgespeichert wird, werden zuerst die*/
/*   Parameter fuer die tiefer-geschachtelten QCs ermittelt  */
/*   (werden in qclist/2 abgespeichert)                      */
/*   und ScopeResolution-Ausdruecke (this::... ) werden durch*/
/*   eindeutige Bezeichner (Parameter oder this) ersetzt     */
/*                                                           */
/*************************************************************/

store_complexRef(_xid,_AClist,property(_l,['SMLfragment'(what([]),in_omega([]),in([]),isa(_classlist),with(_attrdecllist))])) :-
	id2name(_xid,_x),
	create_subview_name(_x,_l,_xhelp),
	((qclist(_,_outqclist),
	  _outadlist = _attrdecllist
	 );
	 (attrdecl_parameter(_xhelp,[a('~this',_x),a(_l,_xhelp)],_attrdecllist,_outadlist, [], _outqclist),
	  pc_update(qclist(_x,_outqclist))
	 )
	),
	!,
	name2id('SubView',_svid),
    store_Sub_Object(what(_xhelp),in(_svid),isa(_classlist),with(_outadlist),_outqclist),
    store_complex_property(_xid,_AClist,property(_l,_xhelp),_outqclist),
	(retract(qclist(_x,_outqclist));
	 true
	).

/*************************************************************/
/* store_enumeration(_x,_AClist,property(_l,_enum))          */
/*                                                           */
/*  Fuer eine Enumeration wird eine neue QC angelegt, die    */
/*  als Constraint $ (this == e1) or ... (this == en) $ ent- */
/*  haelt, wobei die ei's die Elemente der Aufzaehlung sind. */
/*  Um die Oberklasse der neuen QC zu finden, wird bei den   */
/*  Oberklassen von _x nach dem Attribut _l gesucht.         */
/*                                                           */
/*************************************************************/

store_enumeration(_xid,_AClist,property(_l,enumeration(_list))) :-
	id2name(_xid,_x),
	create_subview_name(_x,_l,_qc),
	!,
	prove_literal('Isa'(_xid,_classid1)),
    _xid \== _classid1,
	prove_literal('P'(_,_classid1,_l,_classid)),
	pc_atomconcat('constr_',_l,_cprop),
	enumerationToConstraint(_list,_constr),
	_attrdecl1=attrdecl([constraint],[property(_cprop,_constr)]),
	name2id('View',_vid),
    store_Sub_Object(what(_qc),in(_vid),isa([class(_classid)]),with([_attrdecl1]),[]),
	name2id(_qc,_qcid),
	store_property(_xid,_AClist,property(_l,_qcid)).



/*===========================================================*/
/*=                LOCAL PREDICATES DEFINITION              =*/
/*===========================================================*/

/*************************************************************/
/* store_complex_property(_x,_AClist,property(_l,_c),_qclist)*/
/*                                                           */
/*  In _qclist ist eine Liste aller zu speichernden QCs mit  */
/*  ihren Parametern abgelegt. Falls _c nicht in _qclist ist */
/*  braucht _c keine Parameter, und kann direkt abgespeichert*/
/*  werden. Sonst wird mit Hilfe der Parameterliste eine     */
/*  Derive-Expression gebaut.                                */
/*                                                           */
/*************************************************************/

store_complex_property(_xid,_AClist,property(_l,_c),_qclist) :-
	member(q(_c,_plist),_qclist),
	!,
	id2name(_xid,_x),
	make_derive_exp(_x,_c,_plist,_dexp),
	store_property(_xid,_AClist,property(_l,_dexp)).

store_complex_property(_xid,_AClist,property(_l,_c),_qclist) :-
	name2id(_c,_cid),
	store_property(_xid,_AClist,property(_l,_cid)).


/*************************************************************/
/* make_derive_exp(_x,_c,_plist,_deriveexp)                  */
/*   (Hilfspraedikat fuer store_complex_property/4)          */
/*                                                           */
/*  Bildet zu einer QC _c mit einer Parameterliste _plist    */
/*  eine Derive-Expression, die bei einem Attribut der Klasse*/
/*  _x benutzt werden soll. Die Parameternamen sind bei allen*/
/*  ineinander geschachtelten QCs gleich und eindeutig, d.h. */
/*  substitute(_p1,_p1) heisst Parameter _p1 von _c wird     */
/*  durch den Parameter _p1 von _x ersetzt. Nur wenn der     */
/*  Parameter _p1 ein Element von _x sein soll, wird _p1     */
/*  durch 'this' ersetzt.                                    */
/*                                                           */
/*************************************************************/

make_derive_exp(_x,_c,_plist,derive(_c,_slist)) :-
	make_derive_exp2(_x,_plist,_slist).

make_derive_exp2(_x,[p(_p1,_x)],[substitute('~this',_p1)]):-!.
make_derive_exp2(_x,[p(_p1,_c)],[substitute(_par,_p1)]):-
	pc_atomconcat('~',_p1,_par),
	_x\==_c,!.

make_derive_exp2(_x,[p(_p1,_x)|_t],[substitute('~this',_p1)|_slist]) :-
	make_derive_exp2(_x,_t,_slist).

make_derive_exp2(_x,[p(_p1,_c)|_t],[substitute(_par,_p1)|_slist]) :-
	pc_atomconcat('~',_p1,_par),
	_x \== _c,
	make_derive_exp2(_x,_t,_slist1).



/*************************************************************/
/* store_Sub_Object(what(_qc),_isa,_with,_qclist)            */
/*                                                           */
/*  Speichert ein Sub-QC, die aus einer SelectExpB,          */
/*  ComplexRef bzw. Enumeration gebildet wurde. Hier muessen */
/*  keine Parameter mehr ermittelt und keine ScopeResolution-*/
/*  Ausdruecke mehr ersetzt werden. Wenn _qc nicht in _qclist*/
/*  enthalten braucht _qc keine Parameter. Sonst muessen die */
/*  Parameter noch zur AttributDeclarationList hinzugefuegt  */
/*  werden. 	 												*/
/*                                                           */
/*************************************************************/

store_Sub_Object(what(_what),in(_gqcid),isa(_isa),with(_attrdecllist),_qclist) :-
	member(q(_what,_plist),_qclist),
   	_plist \== [],
	!,
	add_plist_to_attrdecllist(_plist,_attrdecllist,_adlist2),
	changeIdentifierExp('SMLfragment'(what(_what),
	                                in_omega([class(_gqcid)]),
									in([]),
									isa(_isa),
									with(_adlist2)),
						replaceSelectExpression,
						'SMLfragment'(what(_nwhat),
						            in_omega([class(_ngqcid)]),
									in([]),
									isa(_nisa),
								    with(_nadlist2))),
	store_what(what(_nwhat)),
	store_in_omega(what(_nwhat),in_omega([class(_ngqcid)])),
	store_isa(what(_nwhat),isa(_nisa)),
	store_with(what(_nwhat),with(_nadlist2)),
	store_query(what(_nwhat)).


store_Sub_Object(what(_what),in(_qcid),isa(_isa),with(_attrdecllist),_qclist) :-
	!,
	changeIdentifierExp('SMLfragment'(what(_what),
	                                in_omega([class(_qcid)]),
									in([]),
									isa(_isa),
									with(_attrdecllist)),
						replaceSelectExpression,
						'SMLfragment'(what(_nwhat),
						            in_omega([class(_nqcid)]),
									in([]),
									isa(_nisa),
								    with(_nadlist))),
	store_what(what(_nwhat)),
	store_in_omega(what(_nwhat),in_omega([class(_nqcid)])),
    store_isa(what(_what),isa(_nisa)),
	store_with(what(_nwhat),with(_nadlist)),
	store_query(what(_nwhat)).

/*************************************************************/
/* add_plist_to_attrdecllist([p(_p1,_c1)|_plistrest],        */
/* 							_oldadlist,_newadlist)          */
/*   (Hilfspraedikat fuer store_Sub_Object/4)                */
/*                                                           */
/*  Fuegt zu einer AttributeDeclarationList die Parameter-   */
/*  deklarationen hinzu. Die Klassen der Parameter sind      */
/*  nicht die _ci's (die QCs sind), sondern deren Oberklassen*/
/*  um Rekursion zu vermeiden.                               */
/*                                                           */
/*************************************************************/

add_plist_to_attrdecllist([],_adlist,_adlist) :- ! .

/* Speichere nicht die QueryClassen, sondern deren Oberklassen um Rekursion zu vermeiden */
add_plist_to_attrdecllist([p(_p1,_c1)|_t],_adlist,[attrdecl([parameter],[property(_par,_class)])|_adlist2]) :-
	(pc_atomconcat('~',_par,_p1);_par = _p1),
	name2id(_c1,_cid),
	setof(_x,(prove_literal('Isa'(_cid,_x)),_cid\==_x),_classlist),
	get_parameter_class(_classlist,_class),
	add_plist_to_attrdecllist(_t,_adlist,_adlist2).

/* Es wurde keine Oberklasse fuer die QC _c1 gefunden ==> nimm _c1 als Parameterklasse (--> Rekursion) */
add_plist_to_attrdecllist([p(_p1,_c1)|_t],_adlist,[attrdecl([parameter],[property(_p1,_c1)])|_adlist2]) :-
	add_plist_to_attrdecllist(_t,_adlist,_adlist2).

/*************************************************************/
/* get_parameter_class(_list,_parclass)                      */
/*     (Hilfspraed. fuer add_plist_to_attrdecllist/3)        */
/*                                                           */
/*  Wenn die Parameterliste zur AttrDeclList hinzugefuegt    */
/*  wird, wird nach Oberklassen von QCs gesucht. Hat eine    */
/*  QC mehrere Oberklassen, so muss dafuer eine neue QC er-  */
/*  zeugt werden, die diese Oberklassen als Oberklassen hat. */
/*  Gibt es nur eine Oberklasse, so ist das die Parameter-   */
/*  klasse.                                                  */
/*                                                           */
/*************************************************************/

get_parameter_class([_x],_x) :- !.

get_parameter_class(_l,_newqc) :-
	length(_l,_n),
	_n > 1,
	pc_atomconcat(['SV_'|_l],_newqc),
	list2classlist(_l,_l2),
	name2id('View',_vid),
	store_Sub_Object(what(_newqc),in(_vid),isa(_l2),with([]),[]).


/*************************************************************/
/* list2classlist(_l,_cl)                                    */
/*   (Hilfspraedikat fuer get_parameter_class/2)             */
/*                                                           */
/*  Wandelt eine Liste von Atomen [a1,...,an] in             */
/*  eine Liste von Termen der Form [class(a1),...,class(an)] */
/*  um.                                                      */
/*                                                           */
/*************************************************************/

list2classlist([],[]) .
list2classlist([_h|_t],[class(_h)|_t2]) :-
	list2classlist(_t,_t2).

/********************************************************************************/
/* attrdecl_parameter(_what,_inattr,_inadlist,_outadlist,_inqclist, _outqclist) */
/*   (wird von store_complexRef aufgerufen)                                     */
/*                                                                              */
/* Idee: Suche alle Attributdefinitionen nach benoetigten Parametern ab:        */
/*       merke alle vorkommenden Attributlabels in _inattr                      */
/*          [a(a1,c1),a(a2,c2),....] ai bezeichnet das Attributlabel, ci ist    */
/*          die Klasse auf die sich ai bezieht, d.h. this::...::ai soll ein     */
/*		   Element von ci sein.                                                */
/*                                                                              */
/*       ersetze scope_res-Ausdruecke in _inadlist durch die erzeugten          */
/*          eindeutigen Parameter (neue Terme in _outadlist)                    */
/*                                                                              */
/*       gib eine Liste von (Generic-)QC mit ihren Parametern zurueck           */
/*          (d.h. _inqclist wird durch weiter QCs                               */
/*          [q(qc1,[p(p11,c11),p(p12,c12),...],q(qc2,...),...]                  */
/*             qci ist der Name der QueryClass                                  */
/*             pij ist ein Parameter der QueryClass qci                         */
/*             cij ist die Query-Klasse, in die pij gehoert                     */
/*				(cij wird beim Abspeichern durch eine Oberklasse ersetzt um    */
/*				 Rekursion zu verhindern)                                      */
/*                                                                              */
/********************************************************************************/


/* Fall 1: keine Attribute -> nichts zu tun */
attrdecl_parameter(_what,_inattr, [], [], _inqclist, _inqclist) :- !.

/* Fall 2: Suche zunaechst die Parameter der Property und dann die der restlichen Attribute */
attrdecl_parameter(_what,_inattr, [attrdecl(_AClist,_inproplist)|_intail], [attrdecl(_AClist,_outproplist)|_outtail], _inqclist,_outqclist) :-
	proplist_parameter(_what,_inattr,_inproplist,_outproplist,_inqclist, _outqclist1),
	attrdecl_parameter(_what,_inattr,_intail,_outtail,_inqclist,_outqclist2),
	union_qc_list(_outqclist1,_outqclist2,_outqclist).



/********************************************************************************/
/* proplist_parameter(_what,_inattr,_inadlist,_outadlist,_inqclist, _outqclist) */
/*   (Hilfspraedikat fuer  attrdecl_parameter/6)                                */
/*                                                                              */
/*  Analog zu attrdecl_parameter, hier jedoch nur fuer eine Propertylist.       */
/*                                                                              */
/********************************************************************************/

/* Fall 1: Keine Property -> nichts zu tun */
proplist_parameter(_what,_inattr, [],[], _inqclist,_inqclist) :- !.

/* Fall 2: DeriveExpression -> keine Parameter */
proplist_parameter(_what,_inattr, [property(_l2,derive(_,_))|_intail], [property(_l2,derive(_,_))|_outtail],_inqclist,_outqclist) :-
	proplist_parameter(_what,_inattr,_intail,_outtail,_inqclist,_outqclist).

/* Fall 3: SelectExpB, die mit 'this' beginnt -> this_par ist Parameter aller QC oberhalb von _what*/
proplist_parameter(_what,[_h|_t], [property(_l,selectExpB(_this,_op,_right))|_intail], [property(_l,selectExpB('~this_par',_op,_right))|_outtail], _inqclist, _outqclist) :-
	(_this == this; _this == '~this'),
	create_subview_name(_what,_l,_newqc),
	a('~this',_thisclass) = _h,
   	add_qc_parameter([_h|_t],_inqclist,_newqc,p('this_par',_thisclass),_outqclist1),
	!,
	proplist_parameter(_what,[_h|_t],_intail,_outtail,_inqclist,_outqclist2),
	union_qc_list(_outqclist1,_outqclist2,_outqclist).

/* Fall 4: SelectExpB mit scope_res-Operator '::' -> scope_res-Ausdruck ersetzen,
*		  Parameter hinzufuegen falls 'this' nicht gemeint war */
proplist_parameter(_what,[_h|_t], [property(_l,selectExpB(scope_res(_this,_sc),_op,_right))|_intail], [property(_l,selectExpB(_par,_op,_right))|_outtail], _inqclist, _outqclist) :-
	(_this == this; _this == '~this'),
	create_subview_name(_what,_l,_newqc),
	append(_t,[a(_l,_newqc)],_t2),
	replace_scope_res([_h|_t2],scope_res('~this',_sc),_par,_class),
	((_par == '~this',_outqclist1 = _inqclist);
	 (pc_atomconcat('~',_par_ohne_at,_par),
   	  add_qc_parameter([_h|_t],_inqclist,_newqc,p(_par_ohne_at,_class),_outqclist1)
	 )
	),
	!,
	proplist_parameter(_what,[_h|_t],_intail,_outtail,_inqclist,_outqclist2),
	union_qc_list(_outqclist1,_outqclist2,_outqclist).

/* Fall 5: SelectExpB mit einem bestimmten Objekt -> restliche Prop.-List absuchen */
proplist_parameter(_what, _inattr, [property(_l,selectExpB(_obj,_op,_right))|_intail], [property(_l,selectExpB(_obj,_op,_right))|_outtail], _inqclist, _outqclist) :-
	_obj \== '~this',
	_obj \== this,
	_obj \== scope_res(_,_),
	proplist_parameter(_what, _inattr, _intail, _outtail, _inqclist, _outqclist).

/* Fall 6: Geschachtelter Frame -> untersuche Attrdecl-List des Subframes und restliche Prop.-List */
proplist_parameter(_wh, _inattr, [property(_l,['SMLfragment'(_what,_in_omega,_in,_isa,with(_inadlist))])|_intail], [property(_l,['SMLfragment'(_what,_in_omega,_in,_isa,with(_outadlist))])| _outtail], _inqclist, _outqclist) :-
	create_subview_name(_wh,_l,_newqc),
	append(_inattr,[a(_l,_newqc)],_inattr2),
	attrdecl_parameter(_newqc,_inattr2,_inadlist,_outadlist,_inqclist,_outqclist1),
	proplist_parameter(_wh,_inattr,_intail,_outtail,_inqclist,_outqclist2),
	union_qc_list(_outqclist1,_outqclist2,_outqclist).

/* Fall 7: Assertion String -> suche diesen nach scope_res-Variablen ab, und dann restliche Prop.-List */
proplist_parameter(_what,_inattr, [property(_l,_v)|_intail],[property(_l,_new)|_outtail], _inqclist, _outqclist) :-
	assertion_string(_v),
	!,
    replace_scope_res_in_assertion(_what,_inattr,_v,_new,_inqclist,_outqclist1),
	proplist_parameter(_what,_inattr, _intail, _outtail, _inqclist, _outqclist2),
	union_qc_list(_outqclist1,_outqclist2,_outqclist).

/* Fall 8: Irgendwas anderes -> untersuche restliche Prop.-List */
proplist_parameter(_what,_inattr, [property(_l2,_v)|_intail], [property(_l2,_v)|_outtail], _inqclist, _outqclist) :-
	not(assertion_string(_v)),
	proplist_parameter( _what, _inattr, _intail, _outtail, _inqclist, _outqclist).


/********************************************************************************/
/* replace_scope_res(_attrlist,_scoperesexp,_newpar,_class)                     */
/*   (wird von proplist_parameter aufgerufen)                                   */
/*                                                                              */
/*   Ersetzt einen ScopeResolution-Ausdruck durch einen neuen Parameter oder    */
/*   durch 'this'. Dabei wird auch die Klasse des neuen Parameters bzw. von this*/
/*   zurueckgegeben.                                                            */
/*                                                                              */
/********************************************************************************/

/* Fall 1: ScopeResolution-Ausdruck geht ueber die ganze Parameterliste,
* d.h this ist gemeint */
replace_scope_res([a('~this',_thisclass)|_t],scope_res('~this',_sc),'~this',_class) :-
	scope_res2list(_sc,_l),
	_l = _t,
	last(a(_a,_class),_t).

/* Fall 2: ScopeResolution-Ausdruck referenziert ein Element eines uebergeordneten
* Frames => ersetze Ausdruck durch this_..._par und gib Klasse davon zurueck */
replace_scope_res([a('~this',_c)|_t],scope_res('~this',_sc),_out,_class) :-
	scope_res2list(_sc,_l),
	append(_l,_x,_t),
	last(a(_a,_class),_l),
	_x = [_|_],
	concat_attr_list_with_blank(_l,_out1),
	pc_atomconcat(['~this_',_out1,'_par'],_out).

/* Fall 3: Irgendein Fehler */
/* TODO: vernuenftige Fehlerbehandlung */
replace_scope_res(_a,_sc,_,_) :-
	write('Fehler in replace_scope_res'),nl,
	write('Inattr: '),write(_a),nl,
	write('Scope: '),write(_sc),nl,
	!,fail.



/********************************************************************************/
/* scope_res2list(_scoperesexp,_attrlist)                                       */
/*     (Hilfspraedikat fuer replace_scope_res/4)                                */
/*                                                                              */
/*  Ersetzt einen ScopeResolution-Ausdruck durch eine Attributeliste a(..).     */
/*                                                                              */
/********************************************************************************/

scope_res2list(scope_res(_x,_y),[a(_x,_c)|_l]) :-
	scope_res2list(_y,_l),!.

scope_res2list(_x,[a(_x,_c)]) :-
	atom(_x).



/********************************************************************************/
/* concat_attr_list_with_blank(_attrlist,_atom)                                 */
/*     (Hilfspraedikat fuer replace_scope_res/4)                                */
/*                                                                              */
/*    Aus [a(a1,_),...,a(an,_)] wird 'a1_..._an'                                */
/*                                                                              */
/********************************************************************************/

concat_attr_list_with_blank([a(_a,_c)],_a) :- !.

concat_attr_list_with_blank([a(_a,_c)|_t],_out) :-
	concat_attr_list_with_blank(_t,_out1),
	pc_atomconcat([_a,'_',_out1],_out).


/********************************************************************************/
/* add_qc_parameter(_attrlist,_inqclist,_newqc,p(_p,_c),_outqclist)             */
/*   (wird von proplist_parameter und replace_scope_res_in_assertion benutzt)   */
/*                                                                              */
/*  Fuege den Parameter _p zu allen QueryClassen zwischen _c und _newqc hinzu   */
/*  (_c und _newqc sind Elemente von _attrlist)                                 */
/*                                                                              */
/********************************************************************************/

/* Fall 1: Anfangsklasse _c in AttrList gefunden => fuege die Parameter mit
* von add_qc_parameter2 in _inqclist ein */
add_qc_parameter([a(_,_c)|_t],_inqclist,_newqc,p(_p,_c),_outqclist) :-
	add_qc_parameter2(_t,_inqclist,_newqc,p(_p,_c),_outqclist),!.

/* Fall 2: Anfangsklasse noch nicht gefunden => weitersuchen */
add_qc_parameter([_h|_t],_inqclist,_newqc,p(_p,_c),_outqclist) :-
	_h \== a(_,_c),
	add_qc_parameter(_t,_inqclist,_newqc,p(_p,_c),_outqclist).


/********************************************************************************/
/* add_qc_parameter2(_attrlist,_inqclist,_newqc,p(_p,_c),_outqclist)            */
/*                                                                              */
/*  Fuege den Parameter _p zu allen QueryClassen bis _newqc hinzu               */
/*  (_newqc ist Element von _attrlist bzw. ist eine neue QC, die noch in        */
/*   _inqclist eingetragen werden muss)                                         */
/*  Damit SelectAusdruecke richtig ausgewertet koennen, wird der Parameter      */
/*  in die VariablenTabelle eingetragen                                         */
/*                                                                              */
/********************************************************************************/
add_qc_parameter2([],_inqclist,_newqc,p(_p,_c),_outqclist) :-
	append(_inqclist,[q(_newqc,[p(_p,_c)])],_outqclist),
	name2id(_c,_cid),
	pc_atomconcat('~',_p,_atp),
	saveVarTabInsert([_atp],[_cid]).

add_qc_parameter2([a(_,_newqc)|_t],_inqclist,_newqc,_par,_outqclist) :-
   	add_par(_newqc,_inqclist,_par,_outqclist),!.

add_qc_parameter2([a(_,_c)|_t],_inqclist,_newqc,_par,_outqclist) :-
	_c \== _newqc,
	add_par(_c,_inqclist,_par,_outqclist1),
	add_qc_parameter2(_t,_outqclist1,_newqc,_par,_outqclist).

/********************************************************************************/
/* add_par(_qc,_inqclist,p(_p,_c),_outqclist)                                   */
/*                                                                              */
/*  Fuegt den Parameter _p zur QC _qc hinzu                                     */
/*                                                                              */
/********************************************************************************/

add_par(_qc,[q(_qc,_plist)|_t],p(_p,_c),[q(_qc,_plist2)|_t]) :-
	append(_plist,[p(_p,_c)],_plist2),
	name2id(_c,_cid),
	pc_atomconcat('~',_p,_atp),
	saveVarTabInsert([_atp],[_cid]).

add_par(_qc,[q(_qc2,_plist)|_t],_par,[q(_qc2,_plist)|_t2]) :-
	_qc \== _qc2,
	add_par(_qc,_t,_par,_t2).

add_par(_qc,[],p(_p,_c),[q(_qc,[p(_p,_c)])]) :-
	name2id(_c,_cid),
	pc_atomconcat('~',_p,_atp),
	saveVarTabInsert([_atp],[_cid]).

/********************************************************************************/
/* union_qc_list(_qclist1, _qclist2, _qclist3)                                  */
/*                                                                              */
/*  Zwei Listen von QC mit Parametern (Format wie bei proplist_parameter)       */
/*  werden zusammengemergt                                                      */
/*                                                                              */
/********************************************************************************/

/*Fall 1: Liste 1 ist leer */
union_qc_list([],_qc,_qc) :- !.

/*Fall 2: Kopfelement der ersten Liste ist in Liste 2 enthalten -> vereinige Parameterlisten und dann den Rest*/
union_qc_list([q(_qc,_plist)|_t],_qclist,[q(_qc,_newplist)|_newqclist]) :-
	member(q(_qc,_plist2),_qclist),
	union(_plist,_plist2,_newplist),
	union_qc_list(_t,_qclist,_newqclist).

/*Fall 3: Kopfelement der ersten Liste ist in Liste 2 nicht enthalten -> hinzufuegen und dann den Rest vereinigen*/
union_qc_list([q(_qc,_plist)|_t],_qclist,[q(_qc,_plist)|_newqclist]) :-
	not(member(q(_qc,_plist2),_qclist)),
	union_qc_list(_t,_qclist,_newqclist).




/********************************************************************************/
/* replace_scope_res_in_assertion(_what,_inattr,_assertion,_newassertion,       */
/*                                _inqclist,_outqclist)                         */
/*                                                                              */
/*   Sucht in einem Assertion-String nach Variablen, die mit                    */
/*   scope_res-Operator benutzt werden (z.B. this::dept) oder nach this         */
/*   und ersetzt diese Ausdruecke durch die entsprechenden Parameter.           */
/*   Dabei wird die Liste der QCs mit Parametern aktualisiert.                  */
/*                                                                              */
/********************************************************************************/

replace_scope_res_in_assertion(_what,_inattr,_ass,_newass,_inqclist,_outqclist) :-
	pc_atomtolist(_ass,_asslist),
	replace_scope_res_in_assertion2(_what,_inattr,_asslist,_newasslist,_inqclist,_outqclist),
	pc_atomtolist(_newass,_newasslist).

/* Fall 1: Assertion-String vollstaendig bearbeitet */
replace_scope_res_in_assertion2(_what,_inattr,[],[],_inqclist,_inqclist) :- !.

/* Fall 2a: Anfang eines ScopeResolution-Ausdrucks gefunden =>
*   parse bis zum Ende des Ausdrucks, ersetze diesen Ausdruck und
*   aktualisiere die QC-Liste */
replace_scope_res_in_assertion2(_what,_inattr,[_x,'~',t,h,i,s,':',':'|_tail],_new,_inqclist,_outqclist) :-
    not(ident_char(_x)),
	parse_scope_res(_tail,_sc,_tail2),
	replace_scope_res(_inattr,scope_res('~this',_sc),_par,_class),
	pc_atomconcat('~',_par_ohne_at,_par),
	!,
	((_par == '~this',_outqclist1 = _inqclist);
   	 add_qc_parameter(_inattr,_inqclist,_what,p(_par_ohne_at,_class),_outqclist1)
	),
	replace_scope_res_in_assertion2(_what,_inattr,_tail2,_newtail2,_outqclist1,_outqclist),
	pc_atomtolist(_par,_parlist),
	append([_x|_parlist],_newtail2,_new).

/*Fall 2b: this -> ~this */
replace_scope_res_in_assertion2(_what,_inattr,[_x,t,h,i,s,':',':'|_tail],_new,_inqclist,_outqclist) :-
    not(ident_char(_x)),
	_x \== '~',
	parse_scope_res(_tail,_sc,_tail2),
	replace_scope_res(_inattr,scope_res('~this',_sc),_par,_class),
	pc_atomconcat('~',_par_ohne_at,_par),
	!,
	((_par == '~this',_outqclist1 = _inqclist);
   	 add_qc_parameter(_inattr,_inqclist,_what,p(_par_ohne_at,_class),_outqclist1)
	),
	replace_scope_res_in_assertion2(_what,_inattr,_tail2,_newtail2,_outqclist1,_outqclist),
	pc_atomtolist(_par,_parlist),
	append([_x|_parlist],_newtail2,_new).

/* Fall 3a: '~this' gefunden => ersetze durch '~this_par' und aktualisiere QC-Liste*/
replace_scope_res_in_assertion2(_what,_inattr,[_x,'~',t,h,i,s,_y|_tail],[_x,'~',t,h,i,s,'_',p,a,r|_newtail],_inqclist,_outqclist) :-
    not(ident_char(_x)),
	not(ident_char(_y)),
	[_y|_tail] \= [':',':'|_l],
	member(a('~this',_class),_inattr),
	!,
   	add_qc_parameter(_inattr,_inqclist,_what,p('this_par',_class),_outqclist1),
	replace_scope_res_in_assertion2(_what,_inattr,[_y|_tail],_newtail,_outqclist1,_outqclist).

/* Fall 3b: 'this' gefunden => ersetze durch '~this_par' und aktualisiere QC-Liste*/
replace_scope_res_in_assertion2(_what,_inattr,[_x,t,h,i,s,_y|_tail],[_x,'~',t,h,i,s,'_',p,a,r|_newtail],_inqclist,_outqclist) :-
    not(ident_char(_x)),
	not(ident_char(_y)),
	[_y|_tail] \= [':',':'|_l],
	member(a('~this',_class),_inattr),
	!,
   	add_qc_parameter(_inattr,_inqclist,_what,p('this_par',_class),_outqclist1),
	replace_scope_res_in_assertion2(_what,_inattr,[_y|_tail],_newtail,_outqclist1,_outqclist).

/* Fall 4: Irgendetwas anderes */
replace_scope_res_in_assertion2(_what,_inattr,[_h|_tail],[_h|_newtail],_inqclist,_outqclist) :-
	replace_scope_res_in_assertion2(_what,_inattr,_tail,_newtail,_inqclist,_outqclist).


/********************************************************************************/
/* parse_scope_res(_atomlist, _term, _restatomlist)                             */
/*                                                                              */
/*  Parse die atomlist bis zum Ende des ScopeRes-Ausdrucks,                     */
/*  "Parse-Baum" wird in _term zurueckgegeben, der restliche Teil von _atomlist,*/
/*  der nicht zu diesem Ausdruck gehoert, wird in _restatomlist zurueckgegeben. */
/*                                                                              */
/********************************************************************************/

parse_scope_res(_atomlist,_y,_r) :-
	parse_scope_res2(_atomlist,'',_y,_r),!.

/* Fall 1: Ein Teil eines Identifiers => erweitere Identifier und parse weiter */
parse_scope_res2([_x|_tail],_ident,_term,_rest) :-
	ident_char(_x),
	pc_atomconcat(_ident,_x,_newident),
	parse_scope_res2(_tail,_newident,_term,_rest).

/* Fall 2: Ein neuer Sub-Term beginnt */
parse_scope_res2([':',':'|_tail],_ident,scope_res(_ident,_term),_rest) :-
	_ident \== '',
	parse_scope_res2(_tail,'',_term,_rest).

/* Fall 3: Zeichen gefunden, das nicht zu einem Identifier gehoert => Abbruch */
parse_scope_res2([_x|_tail],_ident,_ident,[_x|_tail]) :-
	not(ident_char(_x)),
	_x \== ':',
	_ident \== '',!.



/********************************************************************************/
/* rebuildSelectExpB(_selexp,_atom)                                             */
/*                                                                              */
/* ersetzt den Syntax-Baum einer SelectExpr.B durch entsprechendes Atom         */
/* (um aus einer Property mit SelectExpB eine Constraint zu machen)             */
/*                                                                              */
/********************************************************************************/

rebuildSelectExpB(_ain,_atom) :-
	atom(_ain),
	name2id(_ain,_id),
	!,
   	eval(_id,insertSelectExpression,_sel),
	outSelectIdent(_sel,_atom).

rebuildSelectExpB(select(_l,_op,_r),_atom) :-
	!,
	outSelectIdent(select(_l,_op,_r),_atom).

rebuildSelectExpB(selectExpB(_l,_op,_r),_atom) :-
	rebuildSelectExpB(_l,_al),
	((_op == 'dot', _aop ='.');
	 (_op == 'bar', _aop ='|')),
	 !,
	rebuildSelectExpB(_r,_ar),
	pc_atomconcat([_al,_aop,_ar],_atom).

rebuildSelectExpB(restriction(_l,_r),_atom) :-
	atom(_l),
	!,
	rebuildSelectExpB(_r,_ar),
	pc_atomconcat(['(',_l,':',_ar,')'],_atom).

rebuildSelectExpB(enumeration(_list),_atom) :-
	rebuildSelectExpB(_list,_alist),
	!,
	pc_atomconcat(['[',_alist,']'],_atom).

rebuildSelectExpB([_head],_atom) :-
	!,
	rebuildSelectExpB(_head,_atom).

rebuildSelectExpB([_head|_tail],_atom) :-
	rebuildSelectExpB(_head,_ahead),
	!,
	rebuildSelectExpB(_tail,_atail),
	pc_atomconcat([_ahead,',',_atail],_atom).

rebuildSelectExpB(class(_x),_x) :- !.

/* Fehler ? */
rebuildSelectExpB(_atom,_atom) :- !.


/********************************************************************************/
/* enumerationToConstraint(_list,_label,_constr)                                */
/*    (wird von store_Enumeration aufgerufen)                                   */
/*                                                                              */
/*   Wandelt eine Liste von Labels bzw. SelectAusdruecken in einen              */
/*   Constraintstring um,                                                       */
/*       z.B. [a,b,c] => (this label a) or (this label b) or ...                */
/*                                                                              */
/********************************************************************************/

enumerationToConstraint(_list,_constr) :-
	enumerationToConstraint2(_list,_constr2),
	!,
	pc_atomconcat(['$ ',_constr2,' $'],_constr).

enumerationToConstraint2([class(_obj)], _constr) :-
	outSelectIdent(_obj,_obj2),
	pc_atomconcat([' (~this == ',_obj2,')'],_constr).

enumerationToConstraint2([class(_obj)|_tail], _constr) :-
	outSelectIdent(_obj,_obj2),
	enumerationToConstraint2(_tail, _constr2),
	pc_atomconcat([' (~this == ',_obj2,') or ',_constr2],_constr).



create_subview_name(_main,_label,_subview) :-
	pc_atomconcat(['SV_',_main,'_',_label],_subview).

