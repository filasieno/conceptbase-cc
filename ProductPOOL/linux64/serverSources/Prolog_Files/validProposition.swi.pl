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
* File:        %M%
* Version:     %I%
* Creation:    12-Oct-1987, Manfred Jeusfeld (UPA)
* Last Change: %G%, Martin Staudt (RWTH)
* Release:     %R%
* -----------------------------------------------------------------------------
*
* This Prolog module is part of the ConceptBase system which is a run-time
* system for the System Modelling Language (SML).
* The predicates in validProposition.pro are concerned with the intermediate
* description of propositions in the ObjectProcessor and in the Proposition-
* Processor. Clearly, all things in SML are objects and all objects can be
* described by a collection of propositions. So propositions are crucial in
* ConceptBase. By now, we have chosen the propval notation for propositions:
*   A proposition description is a structure with functor 'propval' and five
*   components: id, object, proposition, value, time.
* So 'propval(_id,_x,_l,_y,_t)' has the interpretation:
*   The object _x has value _y for property (label) _l at time _t and this
*   proposition has the identifier _id.
*
*
*
* Exported predicates:
* --------------------
*
*   + whatID/2
*      If arg1 is a proposition description then arg2 is the ID component
*   + whatSource/2
*      Gives the source component (implements the "from" function of CML).
*   + whatLabel/2
*      Gives the label component ("label" function).
*   + whatDestination/2
*      Gives the destination component ("to" function).
*   + individual/1
*      Checks wether arg1 is an individual proposition.
*   + constant/1
*      Checks wether arg1 is a constant proposition.
*   + time_interval_constant/1
*      Checks wether arg1 is a time interval constant.
*   + assign_ID/1
*   + newIdentifier/1
*   + systemLabel/1
*   + system_generated/1
*   + ordinaryLabel/1
*   + attribute/1
*   + systemOmegaClass/1
*   + assertion_string/1
*   + PropositionType/2
*   + system_class/2
*	arg2 is one of the four system-classes for the arg1
*
*/



:- module('validProposition',[
'PropositionType'/2
,'assertion_string'/1
,'assign_ID'/1
,'attribute'/1
,'individual'/1
,'newIdentifier'/1
,'ordinaryLabel'/1
,'systemLabel'/1
,'systemOmegaClass'/1
,'systemOmegaClassName'/1
,'system_generated'/1
,'varID'/1
,'whatID'/2
,'isVisible'/1
,'isFunction'/1
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').


:- use_module('GeneralUtilities.swi.pl').
:- use_module('PropositionProcessor.swi.pl').


:- use_module('PrologCompatibility.swi.pl').


:- use_module('MetaUtilities.swi.pl').
:- use_module('Literals.swi.pl').


:- style_check(-singleton).




/* ************************* w h a t I D ************************ */
/*                                                                */
/* whatID(_propdescr, _id)                                        */
/*   _propdescr: any: partial                                     */
/*   _id: any                                                     */
/*                                                                */
/* Succeeds if _id is the ID component of _propdescr.             */
/*								 */
/* ************************************************************** */

whatID('P'(_id,_x,_l,_y), _id).


/* varID(_p) succeeds if the first argument of _p is a variable: */

varID('P'(_id,_x,_l,_y)) :- var(_id).

/* ********************* w h a t S o u r c e ******************** */
/*                                                                */
/* whatSource(_propdescr, _c)                                     */
/*   _propdescr: any: partial                                     */
/*   _x: any                                                      */
/*                                                                */
/* Succeeds if _x is the source component of _propdescr.          */
/*								 */
/* Adapted to the new proposition/6 form.	25.07.1990 RG	 */
/*                                                                */
/* ************************************************************** */

whatSource('P'(_id,_x,_l,_y), _x).

/* ********************* w h a t L a b e l  ********************* */
/*                                                                */
/* whatLabel(_propdescr, _l)                                      */
/*   _propdescr: any: partial                                     */
/*   _l: any                                                      */
/*                                                                */
/* Succeeds if _l is the label component of _propdescr.           */
/*								 */
/* Adapted to the new proposition/6 form.	25.07.1990 RG	 */
/*                                                                */
/* ************************************************************** */

whatLabel('P'(_id,_x,_l,_v), _l).

/* **************** w h a t D e s t i n a t i o n *************** */
/*                                                                */
/* whatDestination(_propdescr, _y)                                */
/*   _propdescr: any: partial                                     */
/*   _y: any                                                      */
/*                                                                */
/* Succeeds if _y is the destination component of _propdescr.     */
/*								 */
/* Adapted to the new proposition/6 form.	25.07.1990 RG	 */
/*                                                                */
/* ************************************************************** */

whatDestination('P'(_id,_x,_l,_y), _y).



/* ******************* i n d i v i d u a l ********************** */
/*                                                                */
/* individual(_propdescr)                                         */
/*   _propdescr: any: partial                                     */
/*                                                                */
/* Succeeds if _propdescr is an individual proposition. See also  */
/* [CML 87] p. 7.                                                 */
/*                                                                */
/* ************************************************************** */

individual('P'(_o,_o,_l,_o)).


/* ********************* c o n s t a n t ************************ */
/*                                                                */
/* constant(_propdescr)                                           */
/*   _propdescr: any: partial                                     */
/*                                                                */
/* Succeeds if _propdescr is a constant proposition. See also     */
/* [CML 87] p. 7.                                                 */
/*                                                                */
/* ************************************************************** */

constant('P'(_p,_p,_p,_p)).




/* ********************** a t t r i b u t e ********************* */
/*                                                                */
/* attribute(_propdescr)                                          */
/*   _propdescr: partial                                          */
/*                                                                */
/* 'attribute/1' checks wether the given _propdescr is an         */
/* attribute. The exact definition for this is like this:         */
/*   Each instance of the class ATTRIBUTE is an attribute.        */
/* Fornatunately, we must not ask the KB about this information   */
/* since it is given by the structure of _propdescr.              */
/* We define 'attribute/1' by enumerating all those propositions  */
/* which are not attributes:                                      */
/*     1. all instantiation propositions (label '*instanceof')    */
/*     2. all specialization prop's (label '*isa')                */
/*     3. all individuals                                         */
/* Naturally, this list has to be updated if new (system) propo-  */
/* sitions are defined which don't fall in this list but also may */
/* not be regarded as attributes.                                 */
/*                                                                */
/* ************************************************************** */

attribute('P'(_id,_x,_l,_y)) :-
  \+ (individual('P'(_id,_x,_l,_y))),
  _l \== '*instanceof',
  _l \== '*isa'.


/* **************** P r o p o s i t i o n T y p e I D *************** */
/*                                                */
/* PropositionTypeID(_p,_cID)                                         */
/*   _p: propval                                                  */
/*   _cID: any: atom                                                */
/*                                                                */
/* Argument _cID is the oid of the system omega class which _p belongs to.     */
/*                                                                */
/* ************************************************************** */

'PropositionTypeID'(_prop,_cID):-
  'PropositionType'(_prop,_c),name2id(_c,_cID).

'PropositionTypeID'(_prop,id_0).  /** id_0=Proposition **/


/* **************** P r o p o s i t i o n T y p e *************** */
/*                                               29-Jul-1988/MJf  */
/* PropositionType(_p,_c)                                         */
/*   _p: propval                                                  */
/*   _c: any: atom                                                */
/*                                                                */
/* Argument _c is the system omega class which _p belongs to.     */
/*                                                                */
/* ************************************************************** */


'PropositionType'('P'(_id,_x,'*instanceof',_c), id_1) :- !.   /** id_1=InstanceOf **/

'PropositionType'('P'(_id,_x,'*isa',_c), id_15) :- !.         /** id_15=IsA **/

'PropositionType'(_p,id_7) :-                               /** id_7=Individual **/
  individual(_p),
  !.


/*else:*/
'PropositionType'(_p, id_6) :-           /** id_6=Attribute **/
  attribute(_p),
  !.




/* *************** s y s t e m O m e g a C l a s s ************** */
/*                                               29-Jul-1988/MJf  */
/* systemOmegaClass(_x)                                           */
/*   _x: any: atom                                                */
/*                                                                */
/* Each object is automatically classified to a so-called system  */
/* omega class. The corresponding instantiation link holds the    */
/* belief time of that object.                                    */
/* Our frame formatter (PropositionsToFragment) puts the system   */
/* omega classes just before the object name, e.g.                */
/*     Individual bill in Person ...                              */
/* Don't be confused by the different spelling. It's an alias     */
/* defined in SML_Aliases.pro.                                    */
/* 21-Sep-1988/MJf: renamed 'omegaclass' to 'systemOmegaClass'    */
/* 13-Jun-1989/MJf: changed due to introduction of ATTRIBUTE      */
/* 9-Jan-1990/MJf: systemOmegaClass able to backtrack             */
/*                                               15-Jun-1989/MJf  */
/* ************************************************************** */


systemOmegaClass(_ID):-
	pc_member(_ID,[id_7,id_6,id_1,id_15,id_0]).  /** Individual,Attribute,InstanceOf,IsA,Proposition **/

systemOmegaClassName(_name) :-
  pc_member(_name,['Individual','Attribute','InstanceOf','IsA','Proposition',
                   select('Proposition',!,attribute),
                   select('Proposition', '->', 'Proposition'),
                   select('Proposition', '=>', 'Proposition')]).


/* ******************* s y s t e m L a b e l ******************** */
/*                                                                */
/* systemLabel(_l)                                                */
/*   _l: ground                                                   */
/*                                                                */
/* For now, there are two "system labels": '*instanceof' and      */
/* '*isa'. They are different from the other labels because       */
/* ConceptBase treats links with these labels always as instant-  */
/* iation or specialization links, respectively. It must not look */
/* at the classes of these links in order to get their semantics. */
/* A consequence of this is, that the network constraint 1 (see   */
/* SMLaxioms) for links with system labels is checked only in a   */
/* weak version.                                                  */
/*                                                                */
/* ************************************************************** */

systemLabel(_l) :-
   (_l == '*instanceof';
   _l == '*isa'),!.



/* *************** s y s t e m _ g e n e r a t e d ************** */
/*                                                7-Jun-1989/MJf  */
/* system_generated(_id)                                          */
/*   _id: atom                                                    */
/*                                                                */
/* Succeeds id _id is a system generated identifier.              */
/*                                                                */
/* ************************************************************** */

system_generated(_id) :-
  atom(_id),
  pc_atomconcat('#',_,_id),
  !.


/* ****************** o r d i n a r y L a b e l ***************** */
/*                                                                */
/* ordinaryLabel(_l)                                              */
/*   _l: ground                                                   */
/*                                                                */
/* All labels which are not system labels are "ordinary" labels.  */
/*                                                                */
/* ************************************************************** */

ordinaryLabel(_l) :-
  _l \== '*instanceof',
  _l \== '*isa'.



/* *************** a s s e r t i o n _ s t r i n g ************** */
/*                                                                                   */
/* assertion_string(_a)                                           */
/*   _a: ground,string                                            */
/*                                                                */
/* Assertions are atoms surrounded by '$'    */

/* ************************************************************** */

assertion_string(_x) :-
         atom(_x),pc_atomconcat('$',_r,_x),pc_atomconcat(_f,'$',_r).






/* ******************** a s s i g n _ I D *********************** */
/*                                                                */
/* assign_ID(_propdescr)                                          */
/*   _propdescr: partial:                                         */
/*                                                                */
/* Instantiates the ID component of _propdescr if necessary (cf.  */
/* [CML 87] p. 7). 'assign_ID' is mainly used in the represen-    */
/* tation modules (Rep_simp,Rep_temp,...).                        */
/* 28-Jun-1988/MJf: system generated ID's have the form '#'<i>    */
/*                                                                */
/* ************************************************************** */

assign_ID(_propdescr) :-
  whatID(_propdescr,_ID),
  atom(_ID),
  !.

assign_ID(_propdescr) :-
  whatID(_propdescr,_ID),
  newIdentifier(_ID),
  !.

/* **************** n e w I d e n t i f i e r ******************* */
/*                                                3-Jul-1989/MJf  */
/* newIdentifier(_ID)                                             */
/*   _ID: free: atom                                              */
/*                                                                */
/* Instantiates _ID with a new identifier.                        */
/*                                                                */
/* ************************************************************** */

newIdentifier(_ID) :-
   uniqueAtom(_ID).


/* ******************** i s V i s i b l e *********************** */
/*                                         4-May-2005/M.Jeusfeld  */
/* isVisible(_ID)                                                 */
/*   _ID: atom                                                    */
/*                                                                */
/* Checks whether the object identifed by _ID is visible in the   */
/* current module context.                                        */
/* This check is related to ticket #64.                           */
/*                                                                */
/* ************************************************************** */

isVisible(_ID) :-
  is_id(_ID),                     /** _ID is an identifier **/
  prove_literal('P'(_ID,_,_,_)),    /** and we can see it    **/
  !.




isFunction(_f) :-
  prove_literal('In_e'(_f,id_106)).    /** id_106 = Function **/





