/**
The ConceptBase.cc Copyright

Copyright 1987-2019 The ConceptBase Team. All rights reserved.

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
* File:         PropositionsToFragment.pro
* Version:      11.2
* Creation:    18-Mar-1988, Manfred Jeusfeld (UPA)
* Last Change   : 96/12/09, Christoph Quix (RWTH)
*
* SCCS-Source-Pool : /home/CBase/CB_NewStruct/ProductPOOL/serverSources/Prolog_Files/SCCS/s.PropositionsToFragment.pro
* Date retrieved : 97/05/16 (YY/MM/DD)
* ----------------------------------------------------------------------------
*
* The module topdownOT.pro has been divided into two parts:
* this is the one part of it, only containing the predicates necessary
* for collecting all propvals of a wished object and to generate a
* SMLfragment from them. (July-1988/EK)
*
*       02-Mar-1990/MSt : Most changes for the integration of the time
*                         calculus are not necessary any longer since
*                         now retrieve_proposition suceeds for historical
*                         propositions too if a corresponding search space
*                         was specified
*
* 7-Dec-1992/kvt: Format of smlfragment changed (cf. CBNEWS[148])
*
* Exported predicates:
* --------------------
*
*   + do_compose_storedObject/2
*       Generates a SMLfragment (arg2) from an object description (arg1).
*
*/


:- module('PropositionsToFragment',[
'do_compose_storedObject'/2
,'compose_attrdecllist'/2
,'hideOmegaClasses'/2
,'labelIsGenerated'/2
,'ded_get_object'/1
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').


:- use_module('PropositionProcessor.swi.pl').
:- use_module('ErrorMessages.swi.pl').
:- use_module('validProposition.swi.pl').

:- use_module('GeneralUtilities.swi.pl').



:- use_module('ScanFormatUtilities.swi.pl').
:- use_module('Literals.swi.pl').
:- use_module('AnswerTransformator.swi.pl').

:- use_module('PrologCompatibility.swi.pl').

:- use_module('GlobalParameters.swi.pl').




/* Flag, ob implizite Beziehungen auch beruecksichtigt werden sollen 
* arg: f(_in,_isa,_with)  Variablen muessen TRUE sein, wenn implizite
* Beziehungen beruecksichtigt werden sollen. Sonst FALSE. 7-6-95/CQ */

:- dynamic 'ded_get_object'/1 .


:- style_check(-singleton).



/* ==================== */
/* Exported predicates: */
/* ==================== */


/* ********* d o - c o m p o s e _ s t o r e d O b j e c t ********** */
/*                                                                    */
/* do_compose_storedObject(_object_spec, _SMLfragment)                */
/*   _object_spec: ground                                             */
/*   _SMLfragment: any: ground                                        */
/*                                                                    */
/* 'do_compose_storedObject' builds an object description _SMLfragment*/
/* for the object specified by _object_spec.                          */
/* To perform this task it only considers stored propositions (see    */
/* PropositionBase). Currently, _object_spec's are given by the ID    */
/* (=name) of the requested object. _SMLfragment has the structure of */
/* SML fragments, of course.                                          */
/*                                                                    */
/* ****************************************************************** */

do_compose_storedObject(_ID, 'SMLfragment'(_what,
                                         _in_omega,
                                         _in,
                                         _isa,
                                         _with)) :-
  ground(_ID),
  compose_what(_ID, _what),
  compose_in_s(_ID, _in_omega, _in),
  compose_isa(_ID,_isa),
  compose_with(_ID,_with),
  !.



/*  ****************************************************************  */
/*                                                                    */
/* hideOmegaClasses(_SMLfragment1, _SMLfragment2)                     */
/*                                                                    */
/* The omega classes Individual, Attribute, InstanceOf, IsA,          */
/* Proposition and the attribute category 'attribute' are removed     */
/* from _SMLfragment1 if the UntellMode is set to 'cleanup'. Result   */
/* is in _SMLfragment2. See ticket #154.                              */ 
/*                                                                    */
/*  ****************************************************************  */

hideOmegaClasses(_SMLfragment,_SMLfragment) :-
  get_cb_feature('UntellMode',verbatim),
  !.

hideOmegaClasses(_SMLfragment,_nakedSMLfragment) :-
  hideClasses(_SMLfragment,_SMLfragment1),
  hideAttributeCategories(_SMLfragment1,_nakedSMLfragment),
  !.

hideOmegaClasses(_SMLfragment,_SMLfragment).  /** never fail **/



/* =================== */
/* Private predicates: */
/* =================== */


/* ******************** c o m p o s e _ w h a t ********************* */
/*                                                                    */
/* compose_what(_x,_what)                                             */
/*   _x: any: ground                                                  */
/*   _what: any: ground                                               */
/*                                                                    */
/* The procedure 'compose_what' tries to find a proposition named _x  */
/* and - if existent - builds a "what" component (first argument of   */
/* a SML fragment).                                                   */
/* 'compose_what' will not backtrack.                                 */
/*                                                  01-Aug-1988/MJf   */
/* ****************************************************************** */

compose_what(_x, what(_x)) :-
  retrieve_proposition('P'(_x,_,_,_)),
  !.

compose_what(_e,_) :-
  outIdentifier(_e,_a),
  report_error( 'PFNFE', 'PropositionsToFragment', [ _a]),
  !,
  fail.


/* ******************** c o m p o s e _ i n _ s ********************* */
/*                                                                    */
/* compose_in_s(_x,_in_omega,_in)                                     */
/*   _x: any: ground                                                  */
/*   _in_omega: any: ground                                           */
/*   _in: any: ground                                                 */
/*                                                                    */
/* 'compose_in_s' searches all classes, which have _x explicitely as  */
/* an instance (no inheritance/deduction regarded). The omega classes */
/* are collected in _in_omega, all others in _in. The arguments       */
/* _in_omega and _in conform to the data structure of the second and  */
/* third argument of a SML fragment.                                  */
/* No backtracking.                                                   */
/*                                                                    */
/* ****************************************************************** */

compose_in_s(_x, in_omega(_classlist1), in(_classlist2)) :-
  ded_get_object(f('TRUE',_,_)),   /* user wants deductive In-Relations*/
  save_setof(class(_c),
             is_class_ded(_x,_c),
             _classlist),
  distribute_classes(_classlist, _classlist1, _classlist2),
  !.

compose_in_s(_x, in_omega(_classlist1), in(_classlist2)) :-
  save_setof(class(_c),
             is_class(_x,_c),
             _classlist),
  distribute_classes(_classlist, _classlist1, _classlist2),
  !.


/* ************************ i s _ c l a s s ************************* */
/*                                                                    */
/* is_class(_x,_c)                                                    */
/*   _x: any: ground                                                  */
/*   _c: any: ground                                                  */
/*   _t: any: ground                                                  */
/*   _timerellist: any: ground                                        */
/*                                                                    */
/* This predicate succeeds if _x is an explicit instance of class _c  */
/* at time _t and with _timerellist containing all explicit temporal  */
/* relations of _t.                                                   */
/* The argument _timerellist conforms after instantiation to the      */
/* syntax of <timerellist> for SML fragments.                         */
/* 'is_class' backtracks on all possible solutions.                   */
/*                                                                    */
/* 7-Dec-1992/kvt:validity time and timerelations no longer supported */
/* ****************************************************************** */

is_class(_x,_c) :-
  (prove_literal('In_s'(_x,_c));    /*stored instanceof rel's*/
   prove_literal('In_o'(_x,_c))),    /*instantiation to system classes*/
  _c \== id_0.                     /** id_0 = Proposition **/

/* Applied, if user wants deductive relationships*/
is_class_ded(_x,_c) :-
  (prove_literal('In'(_x,_c));
  prove_literal('In_s'(_x,_c));
  prove_literal('In_o'(_x,_c))),
  _c \== id_0.                   /** id_0 = Proposition **/



/* ********************* c o m p o s e _ i s a ********************** */
/*                                                                    */
/* compose_isa(_x,_isa)                                               */
/*   _x: any: ground                                                  */
/*   _isa: any: ground                                                */
/*                                                                    */
/* 'compose_isa' finds all objects which are explicit generalizations */
/* of _x and collects them in _isa (which conforms to the standards   */
/* the fourth element of SML fragments).                              */
/* No backtracking.                                                   */
/*                                                                    */
/* ****************************************************************** */

compose_isa(_x, isa(_classlist)) :-
  ded_get_object(f(_,'TRUE',_)), /* user wants deductive Isa-Relations*/
  save_setof(class(_c),
             is_generalization_ded(_x,_c),
             _classlist),
  !.

compose_isa(_x, isa(_classlist)) :-
  save_setof(class(_c),
             is_generalization(_x,_c),
             _classlist),
  !.


/* *************** i s _ g e n e r a l i z a t i o n **************** */
/*                                                                    */
/* is_generalization(_x,_c,_t,_timerellist)                           */
/*   _x: any: ground                                                  */
/*   _c: any: ground                                                  */
/*                                                                    */
/* 'is_generalization' succeeds if _c is an explicit generalization   */
/* of _x                                                              */
/* Backtracking is possible.                                          */
/*                                                                    */
/* ****************************************************************** */

is_generalization(_x,_c) :-
  retrieve_proposition('P'(_,_x,'*isa',_c)).

/* Applied, if deductive Isa-Relations are wanted */
is_generalization_ded(_x,_c) :-
	prove_literal('Isa'(_x,_c)),
	_x \== _c.

/* ******************** c o m p o s e _ w i t h ********************* */
/*                                                                    */
/* compose_with(_x,_with)                                             */
/*   _x: any: ground                                                  */
/*   _with: any: ground                                               */
/*                                                                    */
/* The procedure 'compose_with' builds a <with> data structure (see   */
/* syntax of SML fragments) for the object named _x. Only explicit    */
/* properties (=attributes) of _x are regarded.                       */
/* First, it collects all explicit properties of _x in _proplist      */
/* (elements are propvals). Then it determines the attribute          */
/* categories of each propval in _proplist. The result, _propcatlist, */
/* consists of elements propcat(_catlist,_p) where _p is a attribute  */
/* propval for _x and _catlist is a list of the labels of all attri-  */
/* bute catergories which have _p as an instance.                     */
/* Finally, the _attrdecllist is composed according to the syntax of  */
/* SML fragments.                                                     */
/* No backtracking.                                                   */
/*                                                                    */
/* ****************************************************************** */

compose_with(_xID, with(_attrdecllist)) :-
  save_setof(_property,
             is_property(_xID,_property),
             _proplist),
  get_categories(_proplist,_propcatlist),
  ((ded_get_object(f(_,_,'TRUE')),   /* Look for derive properties */
    save_setof(_attrdecl,
  			 get_derive_property(_xID,_attrdecl),
			 _attrdecllist1)
   );
   _attrdecllist1 = []
  ),
  compose_attrdecllist(_propcatlist,_attrdecllist2),
  purgeDuplicateAttributes(_attrdecllist1,_attrdecllist2,_attrdecllist1a),   /** eliminate derived attributes that are also explicit **/
  append(_attrdecllist1a,_attrdecllist2,_attrdecllist),
  !.


get_derive_property(_xID, attrdecl([_l],[property(_catom,_y)])) :-
	prove_literal('A_d'(_xID,_l,_y)),
	get_computed_atom(_l,_y,_catom).

/** 19-Feb-2010: do not include inherited attributes anymore
get_derive_property(_xID, _attrdecl) :-
	prove_literal(Isa(_xID,_c)),
	_c \== _xID,
	compose_with(_c,with(_attrdecllist)),
	member(_attrdecl,_attrdecllist).
**/




/** If the parameter dedWith of get_object is set to TRUE, then derived/inherited attributes are included **/
/** into the answer frame. However, if a subclass refines an attribute of a superclass, then the          **/
/** attribute of the superclass may NOT be included in the answer frame. Ticket #229, 2009-10-30/MJf      **/


purgeDuplicateAttributes(_derived_attrdecls,_explicit_attrdecls,_new_derived_attrdecls) :-
  forbiddenLabels(_explicit_attrdecls,_forbidden),
  cleanDerivedAttrDecls(_forbidden,_derived_attrdecls,_new_derived_attrdecls).

forbiddenLabels(_attrdecls,_labels) :-
  forbiddenLabels(_attrdecls,[],_labels).

forbiddenLabels([],_soFar,_soFar) :- !.

forbiddenLabels([attrdecl(_cats,[])|_restattrdecls],_soFar,_labels) :-
  forbiddenLabels(_restattrdecls,_soFar,_labels).

forbiddenLabels([attrdecl(_cats,[property(_lab,_)|_restprops])|_restattrdecls],_soFar,_labels) :-
  forbiddenLabels([attrdecl(_cats,_restprops)|_restattrdecls],[_lab|_soFar],_labels).


cleanDerivedAttrDecls(_forbidden,[],[]) :- !.

cleanDerivedAttrDecls(_forbidden,[_attrdecl|_restattrdecls],[_clean_attrdecl|_new_derived_attrdecls]) :-
  cleanAttrDecl(_forbidden,_attrdecl,_clean_attrdecl),
  _clean_attrdecl \= attrdecl(_cats,[]),   /** attrdecl is not void **/
  !,
  cleanDerivedAttrDecls(_forbidden,_restattrdecls,_new_derived_attrdecls).

/** attrdecl is void **/
cleanDerivedAttrDecls(_forbidden,[_attrdecl|_restattrdecls],_new_derived_attrdecls) :-
  cleanDerivedAttrDecls(_forbidden,_restattrdecls,_new_derived_attrdecls).


cleanAttrDecl(_forbidden,attrdecl(_cats,_propertylist),attrdecl(_cats,_newpropertylist)) :-
  cleanPropertyList(_forbidden,_propertylist,_newpropertylist).

cleanPropertyList(_forbidden,[],[]) :- !.

cleanPropertyList(_forbidden,[property(_lab,_)|_restprops],_newpropertylist) :-
  member(_lab,_forbidden),
  !,
  cleanPropertyList(_forbidden,_restprops,_newpropertylist).


cleanPropertyList(_forbidden,[property(_lab,_val)|_restprops],[property(_lab,_val)|_newpropertylist]) :-
  cleanPropertyList(_forbidden,_restprops,_newpropertylist).



/* ********************* i s _ p r o p e r t y ********************** */
/*                                                                    */
/* is_property(_x,_propdescr)                                         */
/*   _x: any: ground                                                  */
/*   _propdescr: any: ground                                          */
/*                                                                    */
/* This predicate succeeds if _propdescr is a legal attribute for _x. */
/* Only explicit propvals are regarded.                               */
/* Backtracking possible.                                             */
/*                                                                    */
/* ****************************************************************** */

is_property(_xID, 'P'(_id,_xID,_l,_y)) :-
  retrieve_proposition('P'(_id,_xID,_l,_y)),
  attribute('P'(_id,_xID,_l,_y)),
  \+ labelIsGenerated(_l,_y).   /** the property is not generated/compiled, e.g. generated rule triggers **/


/** All generated attributes (should) get a label '*generated' in ConceptBase **/
/** Those attributes should not be shown with get_object.                     **/
labelIsGenerated(_lab,_y) :-
  atom(_lab),
  pc_atomconcat(_prefix,'generated',_lab),
  \+ 'InAssertionClass'(_y).

'InAssertionClass'(_a) :-
  name2id('MSFOLrule',_MSFOLrule),
  name2id('MSFOLconstraint',_MSFOLconstraint),
  (
   prove_literal('In_e'(_a,_MSFOLrule));
   prove_literal('In_e'(_a,_MSFOLconstraint))
  ),
  !.

/* ****************** g e t _ c a t e g o r i e s ******************* */
/*                                                                    */
/* get_categories(_proplist,_propcatlist)                             */
/*   _proplist: any: list                                             */
/*   _propcatlist: any: list                                          */
/*                                                                    */
/* The procedure 'get_categories' searches for each propval in        */
/* _proplist the list of categories it belongs to. More exactly:      */
/* Let                                                                */
/*   propval(_id,_x,_l,_y,_t)                                         */
/* be an element of _proplist.                                        */
/* Then, _propcatlist will have an element                            */
/*   propcat([_l1,_l2,..._ln],propval(_id,_x,_l,_y,_t)),              */
/* where _l1,..._ln are the labels of the (attribute) propositions of */
/* whose _id is an instance.                                          */
/* Only explicit propvals are regarded.                               */
/*                                                                    */
/* ****************************************************************** */


get_categories([],[]) :- !.

get_categories([_p|_restproplist],
               [propcat(_catlist,_p)|_restpropcatlist]) :-
  categories_of(_p,_catlist),
  get_categories(_restproplist,_restpropcatlist).


/* ******************* c a t e g o r i e s _ o f ******************** */
/*                                                                    */
/* categories_of(_propdescr,_catlist)                                 */
/*   _propdescr: any: partial                                         */
/*   _catlist: any: lsit                                              */
/*                                                                    */
/* 'categories_of' determines the labels of all explicit attribute    */
/* categories of _propdescr. No backtracking.                         */
/* 13-Jun-1989/MJf: The category 'property' (which comes from the     */
/* omega class ATTRIBUTE is not included in the SML-fragment. Ex-     */
/* ception: there is no other category to be found.                   */
/* 24-Jul-1990/MJf: 'property' is no longer a hidden category since   */
/* it no longer exists! See also CBNEWS[99].                          */
/*                                                   24-Jul-1990/MJf  */
/* 16-Mar-95 kvt : there are no hidden categories any more            */
/* ****************************************************************** */

categories_of('P'(_id,_x,_l,_y),_catlist) :-
  save_setof(_label,
             is_category(_id,_label),
             _catlist),
 	!.

/* ********************* i s _ c a t e g o r y ********************** */
/*                                                                    */
/* is_category(_id,_label)                                            */
/*   _id: any: ground                                                 */
/*   _label: any: ground                                              */
/*                                                                    */
/* 'is_category' succeeds if there is an explicit attribute category  */
/* _ac with label _label for the attribute named _id. Note that the   */
/* temporal information in _t1 and _tac currently has no influence    */
/* on 'is_category'. Thus, if 'is_category(<id>,<label>)' succeeds we */
/* will not know WHEN that assertion was true.                        */
/* Backtracking possible.                                             */
/*                                                                    */
/* ****************************************************************** */

is_category(_id,_label) :-
  (prove_literal('In_s'(_id,_ac));    /*stored instantiations*/
   prove_literal('In_o'(_id,_ac))),   /*instantiations to system classes (Attribute)*/
  retrieve_proposition('P'(_ac,_c,_label,_c1)),
  attribute('P'(_ac,_c,_label,_c1)).


/* ************ c o m p o s e _ a t t r d e c l l i s t ************* */
/*                                                                    */
/* compose_attrdecllist(_propcatlist,_attrdecllist)                   */
/*   _propcatlist: any: list (ip)                                     */
/*   _attrdecllist: any: list (op)                                    */
/*                                                                    */
/* The procedure 'compose_attrdecllist' builds a valid <attrdecllist> */
/* (see syntax of SML fragments) using the information of             */
/* _propcatlist (compare 'get_categories').                           */
/* This is done by the following algorithm:                           */
/*   (1) Take the first propcat of _propcatlist, say _pc.             */
/*   (2) Determine all propcats in _propcatlist with the same catlist */
/*       (first argument of _pc)                                      */
/*   (3) Build the corresponding <attrdecl> of those propcats and in- */
/*       sert it into _attrdecllist                                   */
/*   (4) Remove the propcats of step (2) from _propcatlist            */
/*   (5) Continue with (1) until list is empty                        */
/*                                                                    */
/* ****************************************************************** */

compose_attrdecllist([],[]) :- !.

compose_attrdecllist([_pc|_pcrest],[_attrdecl|_attrdecl_rest]) :-
  compose_attrdecl(_pc,[_pc|_pcrest],_attrdecl,_pcrest1),
  compose_attrdecllist(_pcrest1,_attrdecl_rest).


/* **************** c o m p o s e _ a t t r d e c l ***************** */
/*                                                                    */
/* compose_attrdecl(_propcat,_propcatlist,_attrdecl,_newpropcatlist)  */
/*   _propcat: any: partial (ip)                                      */
/*   _propcatlist: any: list (ip)                                     */
/*   _attrdecllist: any: list (op)                                    */
/*   _newpropcatlist: any: list (op)                                  */
/*                                                                    */
/* 'compose_attrdecl' builds an _attrdecl (see syntax of SML          */
/* fragments) for the propcats in _propcatlist with the same catego-  */
/* ries (first arg of propcat) as _propcat. Additionally, _newprop-   */
/* catlist consists of thoses elements of _propcatlist which didn't   */
/* match.                                                             */
/* No backtracking.                                                   */
/*                                                                    */
/* ****************************************************************** */

compose_attrdecl(propcat(_catlist,_),
                 _propcatlist,
                attrdecl(_catlist,_propertylist),
                 _newpropcatlist) :-
  compose_propertylist(_catlist,_propcatlist,_propertylist,_newpropcatlist),
  !.


/* ************ c o m p o s e _ p r o p e r t y l i s t ************* */
/*                                                                    */
/* compose_propertylist(_catlist,_propcatlist,_propertylist,          */
/*                      _newpropcatlist)                              */
/*   _catlist: any: list (ip)                                         */
/*   _propcatlist: any: list (ip)                                     */
/*   _propertylist: any: list (op)                                    */
/*   _newpropcatlist: any: list (op)                                  */
/*                                                                    */
/* This procedure does the work for 'compose_attrdecl' by scanning    */
/* through _propcatlist and inserting a <property> term in _property- */
/* list for each propcat in _propcatlist with first argument _catlist.*/
/* Concurrently, _newpropcatlist is built of those propcats of _prop- */
/* catlist with a different first argument.                           */
/*                                                                    */
/* ****************************************************************** */

compose_propertylist(_,[],[],[]) :- !.

compose_propertylist(_catlist,
                  [propcat(_catlist,'P'(_id,_x,_l,_y))|_pcrest],
                  [property(_l,_y)|_prest],
                  _newpropcatlist) :-
  !,
  compose_propertylist(_catlist,_pcrest,_prest,_newpropcatlist).

compose_propertylist(_catlist,
                  [_pc|_pcrest],
                  _propertylist,
                  [_pc|_newpcrest]) :-
  compose_propertylist(_catlist,_pcrest,_propertylist,_newpcrest).




/* ************** d i s t r i b u t e _ c l a s s e s *************** */
/*                                                                    */
/* distribute_classes(_classlist,_classlist1,_classlist2)             */
/*   _classlist: any: list                                            */
/*   _classlist1: any: list                                           */
/*   _classlist2: any: list                                           */
/*                                                                    */
/* The procedure 'distribute_classes' seperates _classlist into       */
/* _classlist1 containing the omega classes and into _classlist2 for  */
/* the rest. All elements must match the <class> non-terminal (see    */
/* syntax of SML fragments).                                          */
/*                                                                    */
/* 2-Aug-1988/MJf: Now, distribute_classes makes sure that _classlist1*/
/* is not empty (SML grammar does not like empty in_omega's!).        */
/*                                                   15-Jun-1989/MJf  */
/* ****************************************************************** */

distribute_classes(_classlist,_classlist1,_classlist2) :-
  distribute_them(_classlist,_l1,_l2),
  first_list_non_empty(_l1,_l2,_classlist1,_classlist2),
  !.


/**** ... put the omega classes into arg2 and the rest into arg3: */

distribute_them([],[],[]) :- !.

distribute_them([class(_c)|_rest],
                   [class(_c)|_rest_in_omega],
                   _in) :-
  systemOmegaClass(_c),
  !,
  distribute_them(_rest, _rest_in_omega, _in).

distribute_them([class(_c)|_rest],
                   _in_omega,
                   [class(_c)|_rest_in]) :-
  distribute_them(_rest, _in_omega, _rest_in).



/**** ... (try to) make sure that the list of "omega" classes is non-empty: */

first_list_non_empty([_x|_rest],_l2,[_x|_rest],_l2) :- !.  /*everything ok*/

first_list_non_empty([], [_x|_rest], [_x], _rest) :- !.  /*steal one entry of*/
                                                         /*the second list   */

first_list_non_empty(_l1,_l2,_l1,_l2).                   /*this case should  */
                                                         /*should never occur*/



/** for hideOmegaClasses: **/

hideClasses('SMLfragment'(_what,in_omega(_classes1),_in,_isa,_with),
            'SMLfragment'(_what,in_omega(_classes2),_in,_isa,_with)) :-
  doHideClasses(_classes1,_classes2),
  !.

doHideClasses([],[]) :- !.

doHideClasses([class(_omegaclass)|_rest],_newrest) :-
  systemOmegaClassName(_omegaclass),
  doHideClasses(_rest,_newrest).

doHideClasses([class(_class)|_rest],[class(_class)|_newrest]) :-
  doHideClasses(_rest,_newrest).


hideAttributeCategories('SMLfragment'(_what,_in_omega,_in,_isa,with(_attrdecllist1)),
                        'SMLfragment'(_what,_in_omega,_in,_isa,with(_attrdecllist2))) :-
  doHideAttributeCategories(_attrdecllist1,_attrdecllist2).


doHideAttributeCategories([],[]) :- !.

doHideAttributeCategories([attrdecl(_catlist1,_propertylist)|_rest],
                          [attrdecl(_catlist2,_propertylist)|_newrest]) :-
  removeAttributeFromCategories(_catlist1,_catlist2),
  doHideAttributeCategories(_rest,_newrest).

removeAttributeFromCategories([attribute],[attribute]) :- !.

removeAttributeFromCategories(_catlist1,_catlist2) :-
  doRemoveAttributeFromCategories(_catlist1,_catlist2).

doRemoveAttributeFromCategories([],[]) :- !.

doRemoveAttributeFromCategories([attribute|_rest],_newrest) :-
  !,
  doRemoveAttributeFromCategories(_rest,_newrest).

doRemoveAttributeFromCategories([_cat|_rest],[_cat|_newrest]) :-
  doRemoveAttributeFromCategories(_rest,_newrest).

