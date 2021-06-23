{*
The ConceptBase.cc Copyright

Copyright 1987-2021 The ConceptBase Team. All rights reserved.

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
*}
{
*
* File:        FragmentToPropositions.pro
* Version:     11.4
*
*
* Date released : 97/01/29  (YY/MM/DD)
*
* SCCS-Source-Pool : /home/CBase/CB_NewStruct/ProductPOOL/serverSources/Prolog_Files/SCCS/s.FragmentToPropositions.pro
* Date retrieved : 97/04/29 (YY/MM/DD)
**************************************************************************
*
* The module topdownOT.pro has been divided into two parts:
* this is the one part of it, only containing the predicates necessary
* for transforming a SMLfragment into a set of propvals and then to store them.
*
* 20-Sep-1988/MJf: Reduction of the number of generated '*instanceof'
* propvals for attribute and specialization links.
*
* 14-Dec-1988/EK: Try to guarantee, that all '*instanceof' and '*isa'
* relations have the right level.
*
* 6-Jan-1989/MJf: Adaption of ConceptBase to the new model of assertions
* (see procedure store_property)
*
* 17-Jan-1989/MSt: new: If text of existing assertion is changed a new
* temporary proposition is produced leading to a semantic error
* 'NetworkConstraint'.
*
* 13-Feb-1989/MJf: Making level computations simplier by using a fact
* called 'x@level'. Additionally, the class InstanceOf is used instead
* of InstanceOf_0,...,InstanceOf_omega and IsA instead of IsA_0,...
* IsA_omega. See also CBNEWS.doc [56].

* 14-Mar-1989/MSt : small change see store_property
*
* 12-Apr-1989/MSt : assertion compilation introduced see
*                   store_assertion_property
*
* 14-Jun-1989/MJf:  transaction (belief) time is stored in the instantiation
* link to one of the classes InstanceOf, IsA, INDIVIDUAL, ATTRIBUTE; see also
* lines marked with *BT*
*
* 19-Dec-1989/TW:  transaction time is no longer FromNowOn. It is now the actual
* systemtime
*
* 19-Feb-1990/MSt : AssertionCompiler is called whenever an assertion occurs
*                   arity of lookforassertion/4 reduced to 3
*
* 08-Mar-1990/MSt : change in STORE/1 concerning inheritance, whenever an
*                   attribute occurs (in a fragment) which was inherited before

*                   from a superclass this attribute is stored explicitly.
*
* 13-Mar-1990/MSt : derive expressions allowed in isalist and as property type
*
* 28-Jun-1990/MSt :  If new object is an instance of QueryClass or GenericQuery-
*                    Class ---> call of QueryCompiler
*                    If object does already exists and is instance of QueryClass*
	      or GenericQueryClass the object description is rejected
*
* 25.07.1990 RG:        Replaced STORE(propval...) by STORE(proposition...).
*                       Changed the predicate STORE.
*
* 08-Aug-90/MSt : level of objects with no explicit relation to Token,SimpleClass,
*                 MetaClass,MetametaClass is inherited from a superclass
*                 The corresponding relation to one of the above classes is
*                 stored permanently
*
* 10.09.1990 AM: find_attributeclasses sets ATTRIBUTE when searching for the
*                category of attribute instead of calling retrieve_proposition
* 10.09.1990 AM: disabled: --"--
*
*  2-Jun-1992 KvT: inserted a cut in store_assertionproperty/3 to prevent backtracking after unsuccessfull compilation
* 2-Sep-1992 kvt : no more SMLaliases
*
* 01.09.1992 RG: Implicite generation of constants as nodes in the semantic
*                network
*                NOW STORING THEM ONLY AS PROLOG-ATOMS !!!
*
* 2-Nov-1992 kvt : assertions are compiled later cf. CBNEWS.doc[147]
*
* 7-Dec-1992/kvt: Format of smlfragment changed (cf. CBNEWS[148])
*
* 1-Sep-93/Tl: retrieve_proposition calls with constant objects at Src or Dst entry
* are changed into a name2id(...,_id),retr_prop(..,_id,..) combination. The old
* construction didn't work with an extern retrieve_proposition
*
* 9-Feb-94/HWN: added one case in store_if_query for telling builtin
* query classes.
*
* 10-Jan-96/RS
* Metaformel-Aenderungen
* neue Praedikate
* getAssertionClass
* generateMetaFormulaClassName
* do_store_metaFormClass
* do_store_generatedAssertion
*
*
* 9-Dez-1996/LWEB: retrieve_temp_proposition$Rep_temp/1 Aufrufe wurden durch
* retrieve_temp$PropositionProcessor/1 ersetzt.
* Ein neuer Fall fuer do_store_Object wurde eingefuehrt.
*
*
* Exported predicates:
* --------------------
*
*   + do_store_Object/2
*       Transforms a SMLfragment (arg1) into a set of propvals which are
*       stored in the Rep_temp module; arg2 reports the number of errors
*       during the transformation
*
*   + do_store_assertions/1
*       Compiles all temporarily told assertions. This is useful for
*       assertions that need information that comes later in the
*       framelist.
}


#MODULE(FragmentToPropositions)
#EXPORT(IsView/1)
#EXPORT(STORE/1)
#EXPORT(change_derive_list/2)
#EXPORT(create_if_builtin_object/1)
#EXPORT(create_if_builtin_object/2)
#EXPORT(create_if_builtin_object/3)
#EXPORT(create_as_individual/2)
#EXPORT(do_store_Object/2)
#EXPORT(do_store_assertions/1)
#EXPORT(do_store_generatedAssertion/7)
#EXPORT(do_store_metaFormClass/2)
#EXPORT(find_attributeclasses/3)
#EXPORT(generateMetaFormulaClassName/2)
#EXPORT(getAssertionClass/2)
#EXPORT(name2idF2P/2)
#EXPORT(store_in/2)
#EXPORT(store_in_omega/2)
#EXPORT(store_isa/2)
#EXPORT(store_property/3)
#EXPORT(store_query/1)
#EXPORT(store_what/1)
#EXPORT(store_with/2)
#EXPORT(setCheckUpdateModeIfCacheKept/0)
#ENDMODDECL()


#IMPORT(Query/1,QueryCompiler)
#IMPORT(retrieve_proposition/1,PropositionProcessor)
#IMPORT(assertion_string/1,validProposition)
#IMPORT(assign_ID/1,validProposition)
#IMPORT(newIdentifier/1,validProposition)
#IMPORT(individual/1,validProposition)
#IMPORT(attribute/1,validProposition)
#IMPORT(systemOmegaClass/1,validProposition)
#IMPORT(PropositionType/2,validProposition)
#IMPORT(retrieve_temp_ins/1,PropositionProcessor)
#IMPORT(report_error/3,ErrorMessages)
#IMPORT(increment/1,GeneralUtilities)
#IMPORT(quotedAtom/1,GeneralUtilities)
#IMPORT(pc_member/2,PrologCompatibility)
#IMPORT(remove_multiple_elements/2,GeneralUtilities)
#IMPORT(prove_literal/1,Literals)
#IMPORT(prove_literals/1,Literals)
#IMPORT(prove_edb_literals/1,Literals)
#IMPORT(prove_edb_literal/1,Literals)
#IMPORT(prove_upd_literal/1,Literals)
#IMPORT(checkToEmptyCacheOnUpdate/0,Literals)
#IMPORT(checkToEnableCacheAfterUpdate/0,Literals)
#IMPORT(create/1,BIM2C)
#IMPORT(compile_query/1,QueryCompiler)
#IMPORT(compileDatalogRule/1,QueryCompiler)
#IMPORT(compileAssertion/3,AssertionCompiler)
#IMPORT(getAttrTargetClass/4,MSFOLassertionParserUtilities)
#IMPORT(name2id/2,GeneralUtilities)
#IMPORT(id2name/2,GeneralUtilities)
#IMPORT(check_implicit/1,BIM2C)
#IMPORT(VarTabInit/0,VarTabHandling)
#IMPORT(saveVarTabInsert/2,VarTabHandling)
#IMPORT(intersect/3,GeneralUtilities)
#IMPORT(store_enumeration/3,ViewToPropositions)
#IMPORT(store_selectExpB/3,ViewToPropositions)
#IMPORT(store_complexRef/3,ViewToPropositions)
#IMPORT(qclist/2,ViewToPropositions)
#IMPORT(compile_ecarule/1,ECAruleCompiler)
#IMPORT(update_ecarule_ins/1,ECAruleCompiler)
#IMPORT(set_KBsearchSpace/2,SearchSpace)
#IMPORT(LoadExQStructure/1,ExternalConnection)
#IMPORT(WriteUpdate/3,GeneralUtilities)
#IMPORT(uniqueAtom/1,GeneralUtilities)
#IMPORT(pc_update/1,PrologCompatibility)
#IMPORT(pc_atomconcat/2,PrologCompatibility)
#IMPORT(pc_atomconcat/3,PrologCompatibility)
#IMPORT(pc_inttoatom/2,PrologCompatibility)
#IMPORT(pc_floattoatom/2,PrologCompatibility)
#IMPORT(pc_atom_to_term/2,PrologCompatibility)
#IMPORT(pc_swriteQuotes/2,PrologCompatibility)
#IMPORT(check_insert_import_relationship/1,ObjectProcessor)
#IMPORT(outObjectName/2,ScanFormatUtilities)
#IMPORT(is_id/1,MetaUtilities)
#IMPORT(append/3,GeneralUtilities)
#IMPORT(WriteTrace/3,GeneralUtilities)
#IMPORT(checkIsDeducableByRule/1,Literals)
#IMPORT(reset_counter_if_undefined/1,GeneralUtilities)
#IMPORT(outIdentifier/2,ScanFormatUtilities)
#IMPORT(setCheckUpdateMode/1,TellAndAsk)
#IMPORT(do_processIfDeriveExpr/2,SelectExpressions)
#IMPORT(delayedReplaceSelectExpression/2,SelectExpressions)
#IMPORT(replace_derive_expression/3,QueryCompiler)
#IMPORT(write_lcall/1,Literals)
#IMPORT(getFlag/2,GeneralUtilities)
#IMPORT(get_cb_feature/2,GlobalParameters)
#IMPORT(getCC/3,Literals)

#DYNAMIC('x@type'/1)

#IF(SWI)
:- style_check(-singleton).
#ENDIF(SWI)



{ ==================== }
{ Exported predicates: }
{ ==================== }


{ ***************** d o _ s t o r e _ O b j e c t ****************** }
{                                                                    }
{ do_store_Object(_SMLfragment, _errno)                              }
{   _SMLfragment: ground                                             }
{   _errno: any: integer                                             }
{                                                                    }
{ 'do_store_Object' takes an SML fragment and stores it by dividing  }
{ it into its components and storing those (top down fashion).       }
{ The procedures 'store_in_omega' etc get the _what component of the }
{ SML fragment as first argument since they need this information    }
{ storing the information of the second argument.                    }
{ All information is stred in the "temp" representation (see module  }
{ Rep_temp). The calling procedure is responsible to perform further }
{ integrity checks.                                                  }
{ 'do_store_Object' will ignore information already contained in the }
{ knowledge base. Only new information is really stored.             }
{ The various possible errors are reported to the user but 'do_store_}
{ Object' itself will always suceed.                                 }
{                                                                    }
{ 3-Aug-1988/MJf: Second parameter for reporting the number of       }
{ errors.                                                            }
{                                                                    }
{                                                   29-Jan-1990/MJf  }
{ ****************************************************************** }


do_store_Object(SMLfragment(_what,_in_omega,_in,_isa,_with), 0) :-
	set_KBsearchSpace(newOB,Now), { SearchSpace hier nochmal setzen, da waehrend ECA Auswertung geaendert }
  reset_counter_if_undefined('error_number@F2P'),
  checkToEmptyCacheOnUpdate,                   {* will empty the cache of Literals.pro *}
  pc_update('x@type'(notype)),
  VarTabInit,                 { 19-5-95/CQ: Notwendig fuer Auswertung SelectExpB }
  retractall(qclist(_a,_b)),
  store_what(_what),
  store_in_omega(_what,_in_omega),
  store_in(_what,_in),
  store_isa(_what,_isa),
  store_with(_what,_with),
  VarTabInit,                { 19-5-95/CQ: Vorher eingetragene Variablen wieder loeschen }
  dealWithQueryCompilation(_what,_in_omega,_in),
  'error_number@F2P'(0).



do_store_Object(SMLfragment(what(_e),_,_,_,_), _errno) :-
  name2idF2P(_e,_eID),
  report_error( FPNTE, FragmentToPropositions, [objectName(_eID)]),
  increment('error_number@F2P'),
  'error_number@F2P'(_errno),
  !.

do_store_Object(_e, 1) :-
  report_error( FPWSF, FragmentToPropositions, [_e]),
  !.

{* no classes declared for _what: this is not an object that requires further compilation *}
dealWithQueryCompilation(_what,[],[]) :- !.

dealWithQueryCompilation(_what,_in_omega,_in) :-
 (isQuery(_what) ->
    store_query(_what);
    !
  ),
  (IsECArule(_what) ->
    store_ecarule(_what);
    !
  ),
  (IsDatalogRule(_what) ->
    store_datalogrule(_what);
    !
  ).


{************ d o _ s t o r e _ a s s e r t i o n s **************}
{*                                                               *}
{* store_assertions retrieves all temporary assertions and calls *}
{* the assertion-compiler                                        *}
{*****************************************************************}

do_store_assertions(_errno) :-
	{* Get the OIDs of all temporary assertions that have to be compiled
	*}
	findall(
   		ac(_AssID,_AssClassNA),
   		(
		  pc_member(_AssClassNA,[MSFOLconstraint,MSFOLrule]),
		  name2idF2P(_AssClassNA,_AssClassID),
		  retrieve_temp_ins( P(_,_AssID,'*instanceof',_AssClassID))
		),
	_acMultiList
	),

	remove_multiple_elements(_acMultiList, _acList),

	{* store_assertions does the rest of the work
	*}
	store_assertions(_acList,_errno).

{************ d o _ s t o r e _ m e t a F o r m C l a s s ********}
{*                                                               *}
{* store InstanceOf Relationship between Metaformulatext and     *}
{* Metaformula-Category                                          *}
{*****************************************************************}


do_store_metaFormClass(_mode,_rfID) :-
	getAssertionClass(_mode,_class),
	generateMetaFormulaClassName(_class,_metaFormulaCategory),
	name2id(_metaFormulaCategory,_mfcat),
	do_store_Object(SMLfragment(what(_rfID),in_omega([]),in([class(_mfcat)]),isa([]),with([])),_errno).

{*****d o _ s t o r e _ g e n e r a t e d A s s e r t i o n ******}
{*                                                               *}
{* store Assertion as instance of Metaformula and like a normal  *}
{* Assertion                                                     *}
{*****************************************************************}

{* a) check on temporary told objects *}
do_store_generatedAssertion(_subst,_gf,_class,_mode,_rfID,_assId,_) :-
{test if formula already exists and is generated}
	retrieve_temp_ins(P(_assId,_assId,_gf,_assId)),
	getAssertionClass(_mode,_className),
	name2idF2P(_className,_classID),
	prove_edb_literal(In_e(_assId,_classID)),
	retrieve_temp_ins(P(_,_,_label,_assId)),
	pc_atomconcat(_genIDPart1,'generated',_label),
        !,
        storeIsAToMetaformula(_assId, _rfID),
	!.

{* b) check on existing objects *}
do_store_generatedAssertion(_subst,_gf,_class,_mode,_rfID,_assId,_) :-
 {test if formula already exists and is generated}
 	retrieve_proposition(P(_assId,_assId,_gf,_assId)),
 	getAssertionClass(_mode,_className),
 	name2idF2P(_className,_classID),
 	prove_edb_literal(In_e(_assId,_classID)),
 	retrieve_proposition(P(_,_,_label,_assId)),
 	pc_atomconcat(_genIDPart1,'generated',_label),
        !,
        storeIsAToMetaformula(_assId, _rfID),
 	!.


{* ticket #155: store _class as instance of Class on the fly to make sure that we can *}
{* use the attribute categories rule/constraint                                       *}
do_store_generatedAssertion(_subst,_gf,_class,_mode,_rfID,_assId,_proposedLabel) :-
        reproposeLabel(_proposedLabel,_rfID,_subst,_newProposedLabel),
	createAssertionLabel(_class,_newProposedLabel,_newLabel),
	name2id(Class,_ClassId),
	do_store_Object(SMLfragment(what(_class),in_omega([class(_ClassId)]),in([]),isa([]),with([attrdecl([_mode],[property(_newLabel,_gf)])])),_errno1),!,
	_errno1 == 0,
	retrieve_temp_ins(P(_idattr,_class,_newLabel,_assId)),
        {* ticket #152 *}
	do_store_Object(SMLfragment(what(_assId),in_omega([]),in([]),isa([class(_rfID)]),with([])),_errno2), 
        !,
	_errno2 == 0,
	getAssertionClass(_mode,_assClass),
	store_assertions([ac(_assId,_assClass)],_errno3),
	_errno3 == 0,
        compileHint(_subst,_idattr,_rfID), 
        !.



{* The generated formula may already be told seperately; then we only make sure that the  *}
{* IsA(assId,rfID) is told as well. This is the dependency between the generated formulas *}
{* and the meta formula. See also ticket #191.                                            *}

storeIsAToMetaformula(_assId, _rfID) :-
        do_store_Object(SMLfragment(what(_assId),in_omega([]),in([]),isa([class(_rfID)]),with([])),_errno2),
        !,
        _errno2 == 0.





{ =================== }
{ Private predicates: }
{ =================== }

{* reproposeLabel tries again to find a suitable label for formula generated from *}
{* a meta formula. This has only to be done if the proposed label from            *}
{* AssertionTransformer.pro is 'none'. In this case, we inspect the substitution  *}
{* list for labels and look up the label _metalab of the meta formula.            *}
{* An example case is the model TransitiveClosure.sml from the CB-Forum.          *}

reproposeLabel('none',_rfID,subst(_vars,_valuelist),_NewProposedLabel) :-
      retrieve_proposition(P(_id,_mc,_metalab,_rfID)),   
      attribute(P(_id,_mc,_metalab,_rfID)),
      labelInSubst(_valuelist,_label),
      pc_atomconcat([_label,'_',_metalab],_NewProposedLabel),
      !.
reproposeLabel(_proposedLabel,_rfId,_subst,_proposedLabel).

labelInSubst([_label|_rest],_label) :-
      atom(_label),
      \+ is_id(_label),
      !.
labelInSubst([_|_rest],_label) :-
      labelInSubst(_rest,_label).



{* this clause produces readable labels but labelIsUnused does not cater for multiple generalization *}
createAssertionLabel(_class,_proposedLabel,_newLabel) :- 
        fail, {* currently disabled *}
        get_cb_feature(readableFormulaLabel,on),  {* see ticket #271 *}
	_proposedLabel \= 'none',
	candidateSuffixLabel(_suf),  {* try all allowed suffixes *}
	pc_atomconcat([_proposedLabel,_suf,'_generated'],_newLabel),
        labelIsUnused(_class,_newLabel),  {* see ticket #271 *}
        !.


createAssertionLabel(_class,_proposedLabel,_newLabel) :-
	uniqueAtom(_formulaID),
	_proposedLabel \= 'none',
        pc_atomconcat([_proposedLabel,'_',_formulaID,'_generated'],_newLabel),
	!.

{* otherwise: only a system-generated unique label *}
createAssertionLabel(_class,_proposedLabel,_newLabel) :-
	uniqueAtom(_formulaID),
        pc_atomconcat(_formulaID,'generated',_newLabel),
	!.

candidateSuffixLabel('').  {* first one has no numbering *}
candidateSuffixLabel('1').
candidateSuffixLabel('2').
candidateSuffixLabel('3').
candidateSuffixLabel('4').


labelIsUnused(_class,_newLabel) :-
   isSpecialization(_class,_class2),   {* check all superclasses of _class including _class itself *}
   retrieve_proposition(P(_id,_class2,_newLabel,_)),   {* if is hase the newLabel, we cannot use it *}
   !,
   fail.

{* we also need to check the subclasses since they might already have an assertion with generated label *}
labelIsUnused(_class,_newLabel) :-
   isSpecialization(_class2,_class),   {* check all superclasses of _class including _class itself *}
   retrieve_proposition(P(_id,_class2,_newLabel,_)),   {* if is has the newLabel, we cannot use it *}
   !,
   fail.

{* otherwise: we use it *}
labelIsUnused(_class,_newLabel).


{***************************************}
{  Behandlung von Queries               }
{***************************************}

{* isQuery(_what): Ist _what eine Instanz von QueryClass? *}
isQuery(what(_q)):-
	name2idF2P(_q,_qID),
	Query(_qID).

{ ********************* s t o r e _ q u e r y ********************** }
{                                                                    }
{       store_query(_what)                                           }
{               _what:ground                                         }
{                                                                    }
{ _what is expected to be a valid what component of an SML fragment. }
{ if so, the specified object name _x is checked if it is just       }
{ before told instance of QueryClass.                                }
{ If the check is successful the QueryCompiler is called.            }
{ If the object is an already existing instance of QueryClass but    }
{ not an instance of BuiltinQueryClass, an error messages is         }
{ generated and the KB entry is rejected.                            }
{ ****
************************************************************** }

store_query(what(_q)) :-
	{* _q wurde gerade erst getellt --> Uebersetzung anstossen *}
	name2idF2P(_q,_qID),
	retrieve_temp_ins(P(_qID,_qID,_,_qID)),
	!,
	compile_query(_qID).



{* Anfrageklasse gab es bereits, es wurden jedoch neue Eigenschaften dazugetellt --> Fehler, da wir kein incrementelles Uebersetzen von Anfrageklassen implementiert haben.
*}
store_query(what(_q)) :-
	{* _q ist schon in der DB vorhanden, und es wurden neue Eigenschaften
	    getellt. Falls _q keine BuiltinQuery bzw. Function ist,
	    ist das ein Fehler, da wir kein inkrementelles Uebersetzen von
	    Anfrageklassen implementiert haben.
	    Instanzen von BuiltinQueryClass duerfen jedoch erweitert werden.
	*}
	name2idF2P(_q,_qID),
        incrementalQueryUpdate(_qID),
	not(prove_edb_literal(In_e(_qID,id_77))),   {* id_77=BuiltinQueryClass *}
	not(prove_edb_literal(In_e(_qID,id_106))),  {* id_106=Function *}
	!,report_error(QLERR9,FragmentToPropositions,[objectName(_q)]),
	increment('error_number@F2P'),
	fail.


store_query(_).
	{* Query ist bereits in der DB vorhanden. *}


incrementalQueryUpdate(_qID) :-
	retrieve_temp_ins(P(_aid,_qID,_l,_y)),
	is_incrementalQueryUpdate(P(_aid,_qID,_l,_y)),
	!.

{* the following properties of query classes may not be changed incrementally *}
is_incrementalQueryUpdate(P(_aid,_qID,'*isa',_y)) :-
	!.
is_incrementalQueryUpdate(P(_aid,_qID,_l,_y)) :-
	getCC(QueryClass,retrieved_attribute,_cc),
        prove_edb_literal(In_e(_aid,_cc)),
	!.
is_incrementalQueryUpdate(P(_aid,_qID,_l,_y)) :-
	getCC(QueryClass,computed_attribute,_cc),
        prove_edb_literal(In_e(_aid,_cc)),
	!.
is_incrementalQueryUpdate(P(_aid,_qID,_l,_y)) :-
	getCC(GenericQueryClass,parameter,_cc),
        prove_edb_literal(In_e(_aid,_cc)),
	!.
is_incrementalQueryUpdate(P(_aid,_qID,_l,_y)) :-
	getCC(QueryClass,constraint,_cc),
        prove_edb_literal(In_e(_aid,_cc)),
	!.


{***************************************}
{  Behandlung von ECArules              }
{***************************************}

IsECArule(what(_q)):-
	name2idF2P(_q,_qID),
	name2id(ECArule,_ECArule),
	prove_edb_literal(In_e(_qID,_ECArule)).  {* id_1403=ECArule *}


{*******************************************************************}
{                                                                   }
{ store_ecarule(_ecaid)                                             }
{                                                                   }
{ Description of arguments:                                         }
{  _ecaid : what(ID of the ECA rule)                                }
{                                                                   }
{ Description of predicate:                                         }
{   Stores an ECA rule by compiling its attributes to an prolog     }
{   term (see  ECA*.pro for details)                                }
{*******************************************************************}

#MODE((store_ecarule(i)))


store_ecarule(what(_eca)) :-
	{* _ecaid wurde gerade erst getellt --> Uebersetzung anstossen *}
	name2idF2P(_eca,_ecaid),
	name2id(ECArule,_ECArule),
	retrieve_temp_ins(P(_,_ecaid,'*instanceof',_ECArule)), {* id_1403=ECArule *}
	!,
	compile_ecarule(_ecaid).



{* Die ECA Rule gab es bereits, es wurden jedoch neue Eigenschaften dazugetellt *}
{* ==> Fehler, da wir kein incrementelles Uebersetzen von ECA Rules implementiert haben. *}
{* Fuer active Attribut geht es doch!!! *}
store_ecarule(what(_eca)) :-
	name2idF2P(_eca,_ecaid),
	name2id(ECArule,_ECArule),
	retrieve_proposition(P(_,_ecaid,'*instanceof',_ECArule)),   {* id_1403=ECArule *}
	!,
	update_ecarule_ins(_ecaid).


store_ecarule(_).
	{* ECA rule ist bereits in der DB vorhanden und keine neuen Attribute *}


{***************************************}
{  Behandlung von DatalogRules          }
{***************************************}

IsDatalogRule(what(_r)):-
	name2idF2P(_r,_rid),
	name2id(DatalogRule,_DatalogRule),
	prove_edb_literal(In_e(_rid,_DatalogRule)).   {* id_91=DatalogRule *}


{*******************************************************************}
{                                                                   }
{ store_datalogrule(_rid)                                           }
{                                                                   }
{ Description of arguments:                                         }
{  _rid : what(ID of the datalog rule)                              }
{                                                                   }
{ Description of predicate:                                         }
{   Stores a datalog rule by compiling its attributes to a prolog   }
{   rule (see  QueryCompiler (compileDatalogRule) for details)      }
{*******************************************************************}

#MODE((store_datalogrule(i)))


store_datalogrule(what(_r)) :-
	{* rule wurde gerade erst getellt --> Uebersetzung anstossen *}
	name2idF2P(_r,_rid),
	retrieve_temp_ins(P(_rid,_rid,_,_rid)),
	!,
	compileDatalogRule(_rid).

{* Die DatalogRule gab es bereits, es wurden jedoch neue Eigenschaften dazugetellt *}
{* ==> Fehler, da wir kein incrementelles Uebersetzen von Datalog Rules implementiert haben. *}
store_datalogrule(what(_r)) :-
	name2idF2P(_r,_rid),
	retrieve_temp_ins(P(_,_rid,_,_)),
	!,report_error(QLERR9,FragmentToPropositions,[_r]),
	increment('error_number@F2P'),
	fail.


store_datalogrule(_).
	{* datalogrule ist bereits in der DB vorhanden und keine neuen Attribute *}

{ ********************** s t o r e _ w h a t *********************** }
{                                                                    }
{ store_what(_what)                                                  }
{   _what: ground,                                                   }
{                                                                    }
{ _what is expected to be a valid what component of a SML fragment.  }
{ If so, the specified object name _x is stored as an individual and }
{ the temporal relations in _timerellist for the time interval _t    }
{ are asserted.                                                      }
{ Otherwise, an error is reported and 'store_what' fails.            }
{                                                                    }
{ 27-Jul-1988/MJf: Up to now, store_what always generated an indivi- }
{ dual object _x. But now the extended syntax allows so-called       }
{ select-expressions. Therefore, arbitrary objects (e.g. attributes  }
{ can appear as _x. To handle them, I've introduced store_if_new     }
{ which first checks if _x is already existent (then nothing must be }
{ created). If not, it will be stored as an individual.              }
{ Examples:                                                          }
{                                                                    }
{     PROPOSITION John!name WITH                                     }
{        comment                                                     }
{           manfreds_view: "I like this little attribute of John"    }
{     END                                                            }
{                                                                    }
{     PROPOSITION John!name!manfred_view WITH                        }
{        comment                                                     }
{           wow: "I never could imagine things like this..."         }
{     END                                                            }
{                                                                    }
{ 14-Dec-1988/EK: To guarantee, that all '*instanceof' and '*isa'    }
{ relations have the right level, _level contains the level _what is }
{ instance of if it has already existed before. Otherwise _level     }
{ remains uninstantiated (also if it is an omega-class).             }
{                                                                    }
{ 13-Feb-1989/MJf: The level of _x is now stored in a Prolog fact    }
{ 'x@level' which is also used by the CompareInstLevel procedure.    }
{ This replaces the algorithms sketched in '14-Dec-1988/EK'!         }
{                                                                    }
{                                                   13-Feb-1989/MJf  }
{ ****************************************************************** }

store_what(what(_x)) :-
  store_if_new(_x),
  !.


{** 26-Apr-1991/MJf: x cannot be the OID of a derived proposition}

{* case 1: _xid was created as an attribute value before. Now we also *}
{* have to create it as an individual.                                *}
store_if_new(_xid) :-
	id2name(_xid,_x),
	check_implicit(_xid),
	create(P(_id,_id,_xid,_id)),           { TL/15.5.96, Id in der Label-Komponente }
{*        WriteUpdate(low,'+',P(_id,_id,_x,_id)),    *}
	pc_update('x@type'(id_7)),          {id7=Individual;  Objekte in die Datenbank uebernommen werden }
!.


{* case 2: _x existed already before. *}
store_if_new(_x) :-
  name2idF2P(_x,_xid),
 	 retrieve_proposition(P(_xid,_s,_l,_d)),          { _x  already exists }
 	 !,                                                 { ==> don't store it }
 	PropositionType(P(_xid,_s,_l,_d),_t),              { again but memorize its type. }
  	pc_update('x@type'(_t)),
  !.

{* case 3: _x did not exist before *}
store_if_new(_x) :-        		  	     { else: store it as an individual! }
  	STORE(P(_id,_id,_x,_id)),    { 25.07.1990 RG }
  	pc_update('x@type'(id_7)),    {* id_7=Individual *}
!.


{ **************** s t o r e _ i n _ o m e g a ********************* }
{                                                                    }
{ store_in_omega(_what,_in_omega)                                    }
{   _what: ground                                                    }
{   _in_omega: ground                                                }
{                                                                    }
{ The object specified by _what is told to be an instance of all the }
{ 'omega' classes specified in _in_omega.                            }
{ NOTE: We do not insist that _in_omega contains only 'omega'        }
{ classes. In fact we treat _classlist just as a list of classes of  }
{ of _x.                                                             }
{                                                                    }
{ ****************************************************************** }


store_in_omega(what(_x),in_omega(_classlist)) :-
  name2idF2P(_x,_xid),
  store_classlist(_xid,_classlist),
  !.




{ ********************** s t o r e _ i n *************************** }
{                                                                    }
{ store_in(_what,_in,_level)                                         }
{   _what: ground                                                    }
{   _in: ground                                                      }
{                                                                    }
{ Just the same as 'store_in_omega'. The only difference is the fact }
{ that the classes of _in come from a different location in the      }
{ SMLfragment.                                                       }
{                                                                    }
{ ****************************************************************** }


store_in(what(_x),in(_classlist)) :-
  name2idF2P(_x,_xid),
  store_classlist(_xid,_classlist),
  !.



{ *************** s t o r e _ c l a s s l i s t ******************** }
{                                                                    }
{ store_classlist(_x,_classlist)                                     }
{   _x: ground                                                       }
{   _classlist: list,ground                                          }
{                                                                    }
{ This procedure asserts the object named _x to be an instance of    }
{ classes specified in _classlist if the class has the right level.  }
{                                                                    }
{ ****************************************************************** }

store_classlist(_,[]) :- !.

store_classlist(_x,[class(_c)|_rest]) :-
  try_name2idF2P(_c,_cid),
  store_class(_x,class(_cid)),
  store_classlist(_x,_rest).


try_name2idF2P(_c,_cid) :-
  name2idF2P(_c,_cid),
  !.
try_name2idF2P(_c,_c).



{ ******************* s t o r e _ c l a s s ************************ }
{                                                                    }
{ store_class(_x,_class)                                             }
{   _x: ground                                                       }
{   _class: ground                                                   }
{                                                                    }
{ 'store_class' declares the object named _x to be an instance of    }
{ the class _c, specified in _class. Additionally, the necessary     }
{ assertions about the temporal relations of the time interval _t of }
{ this instantiation are made.                                       }
{ 14-Dec-88/EK: This all will be done only if _class has the right   }
{ level.                                                             }
{ 13-Feb-1989/MJf: Now using 'x@level' for the level checking.       }
{ 21-Jun-1989/MJf: Instantiation to one of the four classes Instance-}
{ Of,...,ATTRIBUTE is done automatically by the translator. If it    }
{ is part of the frame then store_class will filter such statements. }
{                                                   21-Jun-1989/MJf  }
{ ****************************************************************** }

store_class(_x, class(id_0)) :- !.   {* id_0=Proposition *}

store_class(_x, class(_sc1id)) :-
  'x@type'(_sc2id),      { instantiation to the system classes is derived }
  _sc1id == _sc2id,
  !.                  { and therefore doesn't need to be stored.      }

store_class(_x, class(_scid)) :-
   systemOmegaClass(_scid),
   'x@type'(_typeid),  {id of Individual, Attribute, InstanceOf, or IsA}
   _scid \== _typeid,
   !,
   report_error(WRONGSYSTEMCLASS,FragmentToPropositions,
                [objectName(_x),objectName(_scid),objectName(_typeid)]),
   fail.

store_class(_x, class(_qc)) :-
   is_id(_qc),
   name2idF2P(QueryClass,_QueryClass),
   prove_literal(In_e(_qc,_QueryClass)),  {* do not replace by constant id because CB_CreateSystem starts with empty DB *}
   !,
   report_error(NO_EDB_QC,FragmentToPropositions,
                [objectName(_x),objectName(_qc)]),
   fail.


store_class(_x,class(_c)) :-
  STORE(P(_a1,_x,'*instanceof',_c)),     { 25.07.1990 RG }
{
  name2idF2P(_c,_cid),
  id2name(_cid,_cname),
}
  hookQueryCall(_x,_c),   {* reified query calls require extra support *}
  !.


{* Derive expressions may be told explicitely as query calls. *}
{* Their instances are derived. Ticket 194.                   *}
hookQueryCall(_x,id_104) :-   {* id_104=QueryCall *}
  id2name(_x,_xname),
  isDeriveExpression(_xname,derive(_q,_slist)),  
  !,   {*  the subsequent check must succeed, otherwise, the whole TELL fails *}
  replace_derive_expression('_',derive(_q,_slist),_term),  {* check whether the expression is valid *}
  storeAsDeriveExpression(_x),
  STORE(P(_bx,_x,'*isa',_q)),
  !.
hookQueryCall(_x,_).





{ ********************* s t o r e _ i s a ************************** }
{                                                                    }
{ store_isa(_what,_isa)                                              }
{   _what: ground                                                    }
{   _isa: ground                                                     }
{                                                                    }
{ 'store_isa' declares the object specified in _what to be a specia- }
{ lization of all "classes" specified in _isa.                       }
{ 14-Dec-88/EK: If the levels of those classes are right.            }
{                                                                    }
{ ****************************************************************** }

store_isa(what(_x),isa(_classlist)) :-
  name2idF2P(_x,_xid),
  store_superclasslist(_xid,_classlist),
  !.



{ ********** s t o r e _  s u p e r c l a s s l i s t ************** }
{                                                                    }
{ store_superclasslist(_x,_classlist)                                }
{   _x: ground                                                       }
{   _classlist: list,ground                                          }
{                                                                    }
{ 'store_superclasslist' does the work for 'store_isa'.              }
{                                                                    }
{ ****************************************************************** }

store_superclasslist(_,[]) :- !.

store_superclasslist(_x,[_class|_rest]) :-
  store_superclass(_x,_class),
  !,
  store_superclasslist(_x,_rest).



{ ************** s t o r e _  s u p e r c l a s s ****************** }
{                                                                    }
{ store_superclass(_x,_class)                                        }
{   _x: ground                                                       }
{   _class: ground                                                   }
{                                                                    }
{ This procedure declares _x to be a subclass (i.e. specialization)  }
{ of the class specified in _class. The temporal information is      }
{ handled as is 'store_class'.                                       }
{                                                                    }
{ 20-Sep-1988/MJf: The specialization link is no longer declared as  }
{ instance of a level (Token, SimpleClass, ...).                     }
{                                                                    }
{ ****************************************************************** }

change_derive_list([],[]).
change_derive_list([substitute(_o,_l)|_rest],[substitute(_OID,_l)|_nrest]) :-
	(name2idF2P(_o,_OID) ; _o = _OID),
	change_derive_list(_rest,_nrest).

change_derive_list([specialize(_l,_o)|_rest],[specialize(_l,_OID)|_nrest]) :-
	name2idF2P(_o,_OID),
	change_derive_list(_rest,_nrest).

store_superclass(_x,class(_objname)) :- {13-Mar-90 MSt}
  isDeriveExpression(_objname,derive(_q,_slist)),
  pc_swriteQuotes(_at,derive(_q,_slist)),
  prove_edb_literal(In_e(_x,id_65)),     {* id_65=QueryClass *}
  prove_edb_literal(In_e(_q,id_72)),     {* id_72=QueryClass *}
  !,
  store_deriveexpression(_at,_x,'*isa',_q,_),
  !.

{ Wenn es sich um ein Objekt von GenericExternalQuery handelt, wird zuerst wie bei ExternalQuery die IsA Beziehung eingebaut.}
{ Dann werden die Attribute dieses Objekts erweirtert(wie bei ExternalQuery).    -- 04.99 Wang Hua}

store_superclass(_x,class(_objname)) :- {13-Mar-90 MSt}
  isDeriveExpression(_objname,derive(_q,_slist)),
  pc_swriteQuotes(_at,derive(_q,_slist)),
  name2id(GenericExternalQuery,_GeExQuClassId),
  prove_edb_literal(In_e(_x,id_65)),  {* id_65=QueryClass *}
  prove_edb_literal(In_e(_q,_GeExQuClassId)),
  !,
  store_deriveexpression(_at,_x,'*isa',_q,_),
  !,
  LoadExQStructure(derive(_q,_slist)).

store_superclass(_x,class(_c)) :-
  atom(_c),
  \+ pc_atomconcat('derive',_,_c),
  _c \= derive(_,_),
  STORE(P(_b1,_x,'*isa',_c)),                              { 25.07.1990 RG }
  !.

store_superclass(_x,class(_objname)) :-
  isDeriveExpression(_objname,derive(_q,_slist)),
{*  pc_atom_to_term(_de,derive(_q,_sIDlist)),  *}
  report_error(QLERR6, FragmentToPropositions,[objectName(derive(_q,_slist))]),
  increment('error_number@F2P'),
  !,
  fail.

store_superclass(_x,class(_c)) :-          {3-Aug-1988/MJf}
  report_error(FPNSC, FragmentToPropositions, [objectName(_x),objectName(_c)]),
  increment('error_number@F2P'),
  !,
  fail.


{* auxiliary procedure to store a derive expression _at mentioned as superclass or attribute *}
{* of the query _x. The parameter _qID identifies the generic query class used to form       *}
{* the derive expression. The parameter _l is either the attribute label or '*isa',          *}
{* depending on whether the derive expression is an attribute or a superclass of _x.         *}
{* The parameter _genlink returns the id of the attribute/isa link between _x and the derive *}
{* expression (object _b1).                                                                  *}
{* Ticket 194.                                                                               *}

store_deriveexpression(_at,_x,_l,_qID,_genlink) :-
  lookforDQ(_x,_l,P(_b1,_b1,_at,_b1) ),
  STORE(P(_b1,_b1,_at,_b1)),           { 25.07.1990 RG }
  STORE(P(_genlink,_x,_l,_b1)),
  STORE(P(_b3,_b1,'*isa',_qID)),
  storeAsDeriveExpression(_b1),
  !.

{*
store_deriveexpression(_at,_x,_l,_qID,_) :-
  write(store_deriveexpression(_at,_x,_l,_qID)),write(' failed'),nl,
  !,
  fail.
*}

storeAsDeriveExpression(_b1) :-
  name2id('DeriveExpression',_GO),   {* DeriveExpression is actually a subclass of GeneratedObject *}
  STORE(P(_bx,_b1,'*instanceof',_GO)),
  !.
storeAsDeriveExpression(_).  {* if this one fails, we would not mind so much *}



{* isDeriveExpr(_dexp,_dexp_ids) succeeds if _dexp is a derive expression. In case of success, *}
{* _dexp_ids contains the derive expression where object names are replaced by ids.            *}

isDeriveExpression(_dexp,derive(_q,_sl)) :-
  atom(_dexp),
  pc_atomconcat('derive(',_rest,_dexp),
  pc_atom_to_term(_dexp,derive(_q1,_sl1)),
  do_processIfDeriveExpr(derive(_q1,_sl1),derive(_q,_sl)),
  !.
isDeriveExpression(derive(_q1,_sl1),derive(_q,_sl)) :-
  do_processIfDeriveExpr(derive(_q1,_sl1),derive(_q,_sl)).
  



{ ******************** s t o r e _ w i t h ************************* }
{                                                                    }
{ store_with(_what,_with)                                            }
{   _what: ground                                                    }
{   _with: ground                                                    }
{                                                                    }
{ 'store_with' declares the attributes described in _what as         }
{ attributes of the object decribed by _what.                        }
{                                                                    }
{ ****************************************************************** }

store_with(what(_x),with(_attrdecllist)) :-
  name2idF2P(_x,_xid),
  store_implicit_vars(_attrdecllist),
  store_attrdecllist(_xid,_attrdecllist),
  !.


store_implicit_vars([]).

store_implicit_vars([attrdecl(_ac,_prop)|_t]) :-
	intersect(_ac,[parameter,computed_attribute],_list),
	_list \== [],
	store_implicit_vars2(_prop),
	store_implicit_vars(_t).

store_implicit_vars([attrdecl(_ac,_prop)|_t]) :-
	store_implicit_vars(_t).

store_implicit_vars2([]).
store_implicit_vars2([property(_label,_propval)|_r]) :-
	pc_atomconcat('~',_label,_at_label),
	((atom(_propval),_class=_propval);
	 (_propval = derive(_class,_))
	),
	saveVarTabInsert([_at_label],[_class]),
	store_implicit_vars2(_r).

{ ************ s t o r e _ a t t r d e c l l i s t ***************** }
{                                                                    }
{ store_attrdecllist(_x,_attrdecllist)                               }
{   _x: ground                                                       }
{   _attrdecllist: list,ground                                       }
{                                                                    }
{ All the "attribute declarations" in _attrdecllist are executed for }
{ the object named _x, i.e. the corresponding attribute links are    }
{ asserted in the knowledge base.                                    }
{                                                                    }
{ ****************************************************************** }


store_attrdecllist(_xid, []) :- !.

store_attrdecllist(_xid, [_attrdecl|_rest]) :-
  store_attrdecl(_xid,_attrdecl),
  store_attrdecllist(_xid,_rest).



{ **************** s t o r e _ a t t r d e c l ********************* }
{                                                                    }
{ store_attrdecl(_x,_attrdecl)                                       }
{   _x: ground                                                       }
{   _attrdecl: ground                                                }
{                                                                    }
{ _attrdecl is supposed to contain a _attrcategorylist and a         }
{ _propertylist. All the "properties" of _propertylist are asserted  }
{ as attributes of _x AND instances of the attribute classes         }
{ specified by _attrcategorylist.                                    }
{                                                                    }
{ ****************************************************************** }

store_attrdecl(_x,attrdecl(_attrcategorylist,_propertylist)) :-
  find_attributeclasses(_x,_attrcategorylist,_AClist),
  store_propertylist(_x,_AClist,_propertylist),
  !.


{ ************ s t o r e _ p r o p e r t y l i s t ***************** }
{                                                                    }
{ store_propertylist(_x,_AClist,_propertylist)                       }
{   _x: ground                                                       }
{   _AClist: ground,list                                             }
{   _propertylist: ground,list                                       }
{                                                                    }
{ _x is the name of an object, _AClist is a list of attribute        }
{ classes (see find_attributeclasses) and _propertylist is a list    }
{ list of "properties" (cf. SML fragments).                          }
{ 'store_propertylist' stores each element of _propertylist as an    }
{ attribute of _x and an instance of all attribute classes in        }
{ _AClist.                                                           }
{                                                                    }
{ ****************************************************************** }

store_propertylist(_x,_,[]) :- !.

{* 26-Nov-2003/M.Jeusfeld: Make sure that key terms of the Telos frame *}
{* and assertion syntax are not used as attribute labels. This would   *}
{* make formulas be translated wrongly.                                *}

store_propertylist(_x,_AClist,[property(_label,_)|_rest]) :-
  forbiddenLabel(_label),
  report_error(FPFBL, FragmentToPropositions, [objectName(_x),_label]),
  increment('error_number@F2P'),
  !,
  fail.

store_propertylist(_x,_AClist,[_property|_rest]) :-
  checkLabel(_property,_property1),
  store_property(_x,_AClist,_property1),
  store_propertylist(_x,_AClist,_rest).

forbiddenLabel('and').   {* list of forbidden attribute labels *}
forbiddenLabel('or').    {* we limit to reserved words of the  *}
forbiddenLabel('not').   {* assertion language. Words like "with" are checked by the Telos parser *}
forbiddenLabel('forall').
forbiddenLabel('exists').


{ ... replace empty label -- indicated by '?' -- with a new unique label }

checkLabel(property('?',_a),
           property(_l,_a)) :-
  newIdentifier(_newid),
  pc_atomconcat('l',_newid,_l),
  !.

checkLabel(_property,_property).







{ ****************** s t o r e _ p r o p e r t y ******************* }
{                                                                    }
{ store_property(_x,_AClist,_property)                               }
{   _x: ground                                                       }
{   _AClist: ground,list                                             }
{   _property: ground                                                }
{                                                                    }
{ 'store_property' does the work decribed in 'store_porpertylist'    }
{ for a single "property" (see syntax of SML fragments).             }
{ It performs the followings steps:                                  }
{   1. Store the temporal relations for the time interval _t of      }
{      _property                                                     }
{   2. Make an appropriate attribute for _x according to _property   }
{   3. Make the attribute link an instance of all attribute classes  }
{      in _AClist (for time interval _t)                             }
{                                                                    }
{ 20-Sep-1988/MJf: The attribute link is no longer declared as       }
{ instance of a level (Token, SimpleClass, ...).                     }
{                                                                    }
{ 06-Jan-1989/MJf: Adaption of FragmentToPropositions to the new     }
{ assertion model in ConceptBase. Assertions in the frame syntax are }
{ strings which are enclosed with '$'. It is wise not to use this    }
{ strings as the indentifier of the assertion like                   }
{    propval($forall ...$,$forall ...$,-,$forall ...$,t)             }
{ but to create a new identifier for it and to use the string as the }
{ label:                                                             }
{    propval(#123,#123,$forall ...$,#123,t).                         }
{ This helps for distinguishing different occurences of the same     }
{ assertion string. Therefore, properties of _x whose values (_a)    }
{ are assertion strings are treated in a special way: the assertion  }
{ _a is stored as an instance of its assertion class (given by the   }
{ attribute categories in _AClist). Additionally, it becomes an      }
{ instance of the omega class INDIVIDUAL (since _a should be a well- }
{ behaving object). Besides this, the translation of assertion pro-  }
{ perties is simmilar to ordinary properties.                        }
{                                                                    }
{ 13-Mar-1990/MSt: derive-expressions allowed as property values     }
{                                                                    }
{ ****************************************************************** }

store_property(_x,_AClist,property(_l,_a)) :-
  assertion_string(_a),
  store_assertionproperty(_x,_AClist,property(_l,_a)),
  !.

store_property(_x,_AClist,property(_l,_dexp)) :-
  isDeriveExpression(_dexp,derive(_q,_sl)),   {* could be encoded as atom or as term *}
  pc_swriteQuotes(_at,derive(_q,_sl)),
  prove_edb_literal(In_e(_x,id_65)),   {* id_65=QueryClass *}
  prove_edb_literal(In_e(_q,id_72)), {* id_72=GenericQueryClass *}
  store_deriveexpression(_at,_x,_l,_q,_linktoDexp),
  store_attributeclasses(_linktoDexp,_AClist),
  !.

{ Neue Faelle 1-3 fuer Select Expressions vom Typ B, SMLFragmente und Enumeration    20-02-95/CQ }
{ Fall 1: SelectExpressions }
store_property(_x,_AClist,property(_l,selectExpB(_left,_op,_right))) :-
	IsView(_x),
	!,
	store_selectExpB(_x,_AClist,property(_l,selectExpB(_left,_op,_right))).

{ Fall 2: SMLFragmente }
store_property(_x,_AClist,property(_l,[SMLfragment(what([]),in_omega([]),in([]),isa([_classlist]),with(_attrdecllist))])) :-
	IsView(_x),
	!,
	store_complexRef(_x,_AClist,property(_l,[SMLfragment(what([]),in_omega([]),in([]),isa([_classlist]),with(_attrdecllist))])).

{ Fall 3: Enumerations }
store_property(_x,_AClist,property(_l,enumeration(_list))) :-
	IsView(_x),
	!,
	store_enumeration(_x,_AClist,property(_l,enumeration(_list))).

{ Error }
store_property(_x,_AClist,property(_l,_v)) :-
	(_v = selectExpB(_,_,_);
	 _v = [SMLfragment(what([]),in_omega([]),in([]),isa([_classlist]),with(_attrdecllist))];
	 _v = enumeration(_)),
	not(IsView(_x)),
	(id2name(_x,_n); _n = _x),
	report_error(NOTVIEW,FragmentToPropositions,[_v,_l,_n]),
	!,
	fail.

store_property(_x,_AClist,property(_l,_y0)) :-
  delayedReplaceSelectExpression(_y0,_y),  {* ticket #350: some select expressions can be left over from ObjectTransformer *}
  \+(assertion_string(_y)),       { 14-Mar-89/MSt : prevents backtracking
                                     in case of failure during assertion
                                     translation }
  \+ isDeriveExpression(_y,_),
  create_if_builtin_object(_y),
  inst_to_string_if_string(_x,_l,_y,_AClist),
  STORE(P(_c1,_x,_l,_y)),
  store_attributeclasses(_c1,_AClist),
  store_implicit_superclasses(_c1,_x,_l),  {New! Obey to axiom A14 of O-Telos.}
  store_implicit_subclasses(_c1,_x,_l),  { 31-Jan-1996 LWEB }
!.


store_property(_x,_AClist,property(_l,derive(_q,_sl))) :-
  outIdentifier(derive(_q,_sl),_de),
{*  pc_atom_to_term(_de,derive(_q,_sl)), *}
  report_error(QLERR13, FragmentToPropositions,[_de]),
  increment('error_number@F2P'),
  !,
  fail.


store_assertionproperty(_x,_AClist,property(_l,_a)) :-
  lookforassertion(_x,_l,P(_assid,_assid,_a,_assid)),
  find_assertionclasses(_AClist,_assclasslist),
  STORE(P(_assid,_assid,_a,_assid)),                   { 25.07.1990 RG }
  store_assertionclasses(_assid,_assclasslist),     {CBNEWS[99]}
  STORE(P(_c1,_x,_l,_assid)),                          { 25.07.1990 RG }
  store_attributeclasses(_c1,_AClist),                      {3}
  !.


{ ********** s t o r e _ a t t r i b u t e c l a s s e s *********** }
{                                                                    }
{ store_attributeclasses(_attrid,_AClist)                            }
{   _attrid: ground                                                  }
{   _AClist: ground,list                                             }
{                                                                    }
{ 'store_attributeclasses' declares the attribute named _attrid to   }
{ be an instance of all attribute classes listed in _AClist.         }
{ Note that _AClist contains the ID's (names) of the attribute       }
{ classes.                                                           }
{ 21-Jun-1989/MJf: Instantiation to 'Attribute' is done solely by the}
{ system.                                                            }
{                                                  21-Jun-1989/MJf   }
{ ****************************************************************** }

store_attributeclasses(_,[]) :- !.

store_attributeclasses(_attrid,[id_6|_rest]) :-    {* id_6=Attribute *}
 store_attributeclasses(_attrid,_rest).

store_attributeclasses(_attrid,[_AC|_rest]) :-
  STORE(P(_d1,_attrid,'*instanceof',_AC)), { 25.07.1990 RG }
  store_attributeclasses(_attrid,_rest).




{ ********** s t o r e _ a s s e r t i o n c l a s s e s *********** }
{                                                     5-Jan-1989/MJf }
{ store_assertionclasses(_assid,_assclasslist)                       }
{   _assid: ground                                                   }
{   _assclasslist: ground,list                                       }
{                                                                    }
{ This procedure is similar to store_attributeclasses. The parameter }
{ _assid is the identifier of an assertion and _assclasslist is the  }
{ list of assertion classes for which _assid shall become an         }
{ instance of.                                                       }
{                                                                    }
{ ****************************************************************** }

store_assertionclasses(_,[]) :- !.

store_assertionclasses(_assid,[_ac|_rest]) :-
  STORE(P(_e1,_assid,'*instanceof',_ac)), { 25.07.1990 RG }
  store_assertionclasses(_assid,_rest).




{ *********** store_implicit_superclasses *************************** }
{                                                                     }
{ store_implicit_superclasses(_a1,_c,_l)                              }
{                                                                     }
{ The parameter _a1 is the Id of an attribute of _c with label _l.    }
{ Store_implicit_superclasses determines all superclasses of _c which }
{ have an attribute _a with the same label. The attribute _a1 is then }
{ declared as an attribute of each such _a.                           }
{ Background: axiom A14 of O-Telos. See also IsA_constraint_1 in      }
{ SMLaxioms.                                                          }
{                                                                     }
{ ******************************************************************* }

store_implicit_superclasses(_a1,_c,_l) :-
  findall(_a, ( isDirectSpecialization(_c,_d),
                retrieve_proposition(P(_a,_d,_l,_)),
                not(prove_edb_literal(Isa(_a1,_a)) )), _alist),
  store_isa_toAlist(_alist,_a1),
  !.

store_isa_toAlist([],_a1) :- !.
store_isa_toAlist([_a|_rest],_a1) :-
  STORE(P(_id,_a1,'*isa',_a)),
  store_isa_toAlist(_rest,_a1).




{ *********** store_implicit_subclasses *************************** }
{                                                                     }
{ store_implicit_subclasses(_a1,_c,_l)                              }
{                                                                     }
{ The parameter _a1 is the Id of an attribute of _c with label _l.    }
{ Store_implicit_subclasses determines all subclasses of _c which }
{ have an attribute _a with the same label. The attribute _a  is then }
{ declared as an attribute of each such _a1.                           }
{ Background: axiom A14 of O-Telos. See also IsA_constraint_1 in      }
{ SMLaxioms.                                                          }
{                                                                     }
{ ******************************************************************* }
{31-Jan-1996 LWEB }

store_implicit_subclasses(_a1,_c,_l) :-
  findall(_a, ( isDirectSpecialization(_d,_c),
                retrieve_proposition(P(_a,_d,_l,_)),
                not(prove_edb_literal(Isa(_a,_a1))) ), _alist),
  store_isa_toAlist_rev(_alist,_a1),
  !.

store_isa_toAlist_rev([],_) :- !.
store_isa_toAlist_rev([_a|_rest],_a1) :-
  STORE(P(_id,_a,'*isa',_a1)),
  store_isa_toAlist_rev(_rest,_a1).



isSpecialization(_c,_d) :-
  prove_upd_literal(Isa(_c,_d)).

{* treat ISA, specializes like isA 
* does not work yet; see DeepTelos and MLT-Telos, 2020-07-10 
* see issue #24
isSpecialization(_c,_d) :-
  getCC('Proposition','ISA',_ISA),  
  prove_upd_literal(Adot(_ISA,_c,_d)).

isSpecialization(_c,_d) :-
  getCC('TYPE',specializes,_ISA),  
  prove_upd_literal(Adot(_ISA,_c,_d)).
*}



isDirectSpecialization(_c,_d) :-
  prove_edb_literal(Isa(_c,_d)),
  _c \= _d.

{* 
* a correct implementation of  isDirectSpecialization needs to check that their is no middle class between _c and _d
isDirectSpecialization(_c,_d) :-
  getCC('Proposition','ISA',_ISA),   
  prove_upd_literal(Adot(_ISA,_c,_d)),
  _c \= _d.

isDirectSpecialization(_c,_d) :-
  getCC('TYPE',specializes,_ISA),  
  prove_upd_literal(Adot(_ISA,_c,_d)),
  _c \= _d.
*}






{ *********** f i n d _ a t t r i b u t e c l a s s e s ************ }
{                                                                    }
{ find_attributeclasses(_x,_attrcategorylist,_AClist)                }
{   _x: ground                                                       }
{   _attrcategorylist: ground,list                                   }
{   _AClist: any: list                                               }
{                                                                    }
{ _attrcategorylist is assumed to be a list of "labels" ,e.g.        }
{ 'singlevalued', which correspond to attribute classes, e.g.        }
{ sv=<CLASS,singlevalued,CLASS,Always>. 'find_attributeclasses' det- }
{ ermines those classes and collects their ID's in _AClist. Because  }
{ of the instatantiation constraints (see SMLaxioms), only attri-    }
{ butes of classes of _x (object to be stored) must be considered.   }
{ 7-Mar-2007: The _attrcategorylist can also contain terms like      }
{ id(_AC). This indicates that _AC is already the object identifier  }
{ of the attribute cxategory.                                        }
{                                                                    }
{ ****************************************************************** }

find_attributeclasses(_,[],[]) :- !.

find_attributeclasses(_x,[id(_AC)|_rest1],[_AC|_rest2]) :-
  !,
  find_attributeclasses(_x,_rest1,_rest2).


find_attributeclasses(_x,[_attrcategory|_rest1],[_AC|_rest2]) :-
  matchClass(_x,_c,_attrcategory),
  retrieve_proposition(P(_AC,_c,_attrcategory,_)),  {* the first solution is the right one thanks In_eh *}
  !,
  find_attributeclasses(_x,_rest1,_rest2).

find_attributeclasses(_x,[_e|_],_) :-
  report_error( FPACNF, FragmentToPropositions, [objectName(_x)
						,_e]),
  increment('error_number@F2P'),
  !,
  fail.


{* 12-Jan-2005/M. Jeusfeld: also find attribute classes which are defined *}
{* for deduced classes of _x. We need to exclude rule,constraint because  *}
{* otherwise, the system would try to compile a query class constraint    *}
{* also as an ordinary integrity constraint.                              *}
{* See also change to SAIOC1 in SMLaxioms.pro.                            *}
{* 13-Apr-2005/M.Jeusfeld: class _c must be ground when calling           *}
{* prove_literal(In(_x,_c)). Otherwise In(_x,_c) cannot be evaluated ...  *}

matchClass(_x,_c,_attrcategory) :-
   prove_edb_literal(In_eh(_x,_c)).   {* find the attribute category defined for the most specific class of _x *}

matchClass(_x,_c,_attrcategory) :-
  _attrcategory \== rule,
  _attrcategory \== constraint,
  checkIsDeducableByRule(In(_,_c)),  {* unify _c to a class whose instantiation is deducable *}
                                     {* by a rule (excludes query classes).                  *}
  prove_upd_literal(In(_x,_c)).      {* In(x,c) is evaluated with enabled cache, see ticket #126 *}






{ *********** f i n d _ a s s e r t i o n c l a s s e s ************ }
{                                                     5-Jan-1989/MJf }
{ find_assertionclasses(_AClist,_assclasslist)                       }
{   _AClist: list, ground                                            }
{   _assclasslist: any: list                                         }
{                                                                    }
{ The parameter _AClist is assumed to contain attributes id's which  }
{ have assertion classes as their value (=destination) component.    }
{ Find_assertionclasses just returns these assertion classes.        }
{                                                                    }
{ ****************************************************************** }


find_assertionclasses([],[]) :- !.

find_assertionclasses([_AC|_ACrest],[_asscl|_rest]) :-
  retrieve_proposition(P(_AC,_,_,_asscl)),
  name2id(Assertions,_AssId),
  prove_edb_literal(In_e(_asscl,_AssId)),
  !,
  find_assertionclasses(_ACrest,_rest).

find_assertionclasses([_|_ACrest],_rest) :-
  find_assertionclasses(_ACrest,_rest).




{ **************** l o o k f o r a s s e r t i o n ***************** }
{                                                     5-Jan-1988/MJf }
{ lookforassertion(_x,_l, _propdescr)                                }
{   _x: ground                                                       }
{   _l: ground                                                       }
{   _propdescr: partial                                              }
{                                                                    }
{ The parameter _x is an object identifier which has an assertion    }
{ given by the propval _propdescr as the value of its attribute _l.  }
{ Typically, the ID component of _propdescr is uninstantiated.       }
{ If there already exists such an assertion then _propdescr gets its }
{ ID _assid. Otherwise, a new ID is generated.                       }
{ The procedure helps for treating one speciality of assertions:     }
{ They can occur as an attribute value without having them declared  }
{ previously. Lookforassertion is also sensitive to the case where   }
{ the assertion already exists. In this case it may not be created a }
{ second time (compare also procedure STORE).                        }
{                                                    11-Jan-1989/MSt }
{                                                    19-Feb-1990/MSt }
{ ****************************************************************** }

lookforassertion(_x,_l, P(_assid,_assid,_a,_assid)) :-
  retrieve_proposition(P(_,_x,_l,_assid)),
  retrieve_proposition(P(_assid,_assid,_a,_assid)),
  !.

lookforassertion(_x,_l, _propdescr) :-
  !.



{ ******************** l o o k f o r D Q *************************** }
{                                                                    }
{ lookforDQ(_x,_l, _propdescr)                                       }
{   _x: ground                                                       }
{   _l: ground                                                       }
{   _propdescr: partial                                              }
{                                                                    }
{ same as lookforassertion/3 but for deriveExpressions instead of    }
{ assertions. If there exists already a link between _x and a derived}
{ query described by deriveExpression _l its identifier is put into  }
{ _propdescr.Otherwise a new id is generated.                        }
{                                                                    }
{ ****************************************************************** }


lookforDQ(_x,_l, P(_id,_id,_a,_id)) :-
  retrieve_proposition(P(_,_x,_l,_id)),
  retrieve_proposition(P(_id,_id,_a,_id)),
  !.

lookforDQ(_x,_l, _propdescr) :-
  !.





{ *************************** S T O R E **************************** }
{                                                                    }
{ STORE(_propdescr)                                                  }
{   _propdescr: partial: ground:                                     }
{                                                                    }
{ 'STORE' succeeds if either                                         }
{    1) there is already a proposition in the explicit KB    which   }
{       matches _propdescr or                                        }
{    2) _propdescr can be created as a new proposition in the        }
{       Rep_temp module.                                             }
{ Thus, 'STORE' avoids duplicate information in the KB.              }
{                                                                    }
{ Changed from the propval form to the proposition form.             }
{                                               25.07.1990 RG        }
{ Empty the query evaluation cache in Literals.pro whenever a real   }
{ STORE occurs. Will clear the cache on first call.  30-Aug-2002/MJf }
{                                                                    }
{ ****************************************************************** }


{* do not create an individual again if it was already told earlier *}
{* in the same transaction.                                         *}

STORE(P(_id,_id,_n,_id)) :-
  var(_id),
  atom(_n),
  retrieve_temp_ins(P(_id,_id,_n,_id)),   {* just told in current transaction *}
  !.

{* similar for instantiation links *}
STORE(P(_id1,_id,'*instanceof',_c)) :-
  var(_id1),
  is_id(_id),
  is_id(_c),
  retrieve_temp_ins(P(_id1,_id,'*instanceof',_c)),   {* just told in current transaction *}
  !.



STORE(P(_id,_s,_l,_d)) :-
  name2idF2P(_s,_sid),
  name2idF2P(_d,_did),
  retrieve_proposition(P(_id,_sid,_l,_did)),
  !.

STORE(P(_id,_s,_l,_d)) :-
	create(P(_id,_s,_l,_d)),
        check_insert_import_relationship(P(_id,_s,_l,_d)),  {* activate module imports asap *}
{*        WriteUpdate(veryhigh,'+',P(_id,_s,_l,_d)),  *}
        setCheckUpdateModeIfCacheKept,
        !.

{* 12-Oct-2006/M.Jeusfeld: We need to detect that the object base has been updated *}
{* while evaluating a query that creates temporary objects (e.g. results of arith- *}
{* metic expressions). If so and the cachemode=keep, some cached facts may contains*}
{* oid's of these temporary objects. The, we must make these objects persistent, so*}
{* set the CheckUpdateMode to YES, so that normal integrity checking for the update*}
{* is enabled. Part of the solution to ticket #123.                                *}
setCheckUpdateModeIfCacheKept :-
  getFlag(currentCacheMode,keep),
  setCheckUpdateMode(YES),
  !.
setCheckUpdateModeIfCacheKept.



{ ********* create_if_b u i l t i n _ o b j e c t ************}
{                                                             }
{                    create_if_builtin_object (_arg1)         }
{                                  _arg1 : ground             }
{       checks wether _arg1 is integer or real or string      }
{       and creates the implicit objects                      }
{                                                             }
{ *********************************************************** }

{* for tracing purposes only  
 create_if_builtin_object(_arg) :-
  write(create_if_builtin_object(_arg)),nl,fail.
*}

create_if_builtin_object(_arg) :-
   ground(_arg),
   pc_inttoatom(_,_arg), 
   !,
   STORE(P(_nid,_nid,_arg,_nid)),
   STORE(P(_id,_nid,'*instanceof',id_18)).   {* id_18=Integer *}

create_if_builtin_object(_argID) :-
   ground(_argID),
   id2name(_argID,_arg),
   pc_inttoatom(_,_arg), 
   !,
   STORE(P(_id,_argID,'*instanceof',id_18)).  {* id_18=Integer *}

create_if_builtin_object(_arg) :-
   ground(_arg),
   pc_floattoatom(_,_arg),
   !,
   STORE(P(_nid,_nid,_arg,_nid)),
   name2id(Real,_RealId),
   STORE(P(_id,_nid,'*instanceof',_RealId)).

create_if_builtin_object(_arg) :-
   quotedAtom(_arg),
   not(name2id(_arg,_x)), {Instanzenbeziehung zu String nicht eintragen, wenn es schon existiert}
   !,
   STORE(P(_nid,_nid,_arg,_nid)),
   name2id(String,_StrId),
   STORE(P(_id,_nid,'*instanceof',_StrId)).

create_if_builtin_object(_argID) :-
   ground(_argID),
   id2name(_argID,_arg),
   pc_floattoatom(_,_arg), 
   !,
   name2id(Real,_RealId),
   STORE(P(_id,_argID,'*instanceof',_RealId)).

create_if_builtin_object(_).



{* The 3-argument version of create_if_builtin_object 'knows'   *}
{* already the class into which _arg has to be classified into. *}
{* It is used mainly in SYSTEM.builtin and SYSTEM.SWI.builtin.  *}
{* 15-May-2006/M.Jeusfeld, 3rtd arg returns oid of the created  *}
{* or existing object.                                          *}

{* If _arg is already a known object, then we assume it is also *}
{* in the right builtin class.                                  *}
create_if_builtin_object(_arg,_class,_nid) :-
  atom(_class),
  name2id(_arg,_nid),
  !.

create_if_builtin_object(_arg,Real,_nid) :-
  STORE(P(_nid,_nid,_arg,_nid)),
  STORE(P(_id,_nid,'*instanceof',id_21)),  {* id_21=Real *}
  !.

create_if_builtin_object(_arg,Integer,_nid) :-
  STORE(P(_nid,_nid,_arg,_nid)),
  STORE(P(_id,_nid,'*instanceof',id_18)),  {* id_18=Integer *}
  !.

create_if_builtin_object(_arg,String,_nid) :-
  STORE(P(_nid,_nid,_arg,_nid)),
  STORE(P(_id,_nid,'*instanceof',id_24)),  {* id_24=String *}
  !.

create_if_builtin_object(_arg,TransactionTime,_nid) :-
  STORE(P(_nid,_nid,_arg,_nid)),
  name2id(TransactionTime,_TTId),
  STORE(P(_id,_nid,'*instanceof',_TTId)),
  !.

create_if_builtin_object(_arg,Label,_nid) :-
  STORE(P(_nid,_nid,_arg,_nid)),
  name2id(Label,_LabelId),
  STORE(P(_id,_nid,'*instanceof',_LabelId)),
  !.



{* try the best to create the builtin object *}
{* ticket #167: need to return the OID of the object since IPLUS and the like expect it *}
create_if_builtin_object(_arg,_,_nid) :-
  create_if_builtin_object(_arg),
  name2id(_arg,_nid).


{* 2-argument version used in SYSTEM.builtin etc.   *}
create_if_builtin_object(_arg,_class) :-
  create_if_builtin_object(_arg,_class,_).



create_as_individual(_arg,_nid) :-
  STORE(P(_nid,_nid,_arg,_nid)),
  STORE(P(_id,_nid,'*instanceof',id_7)),  {* id_7=Individual *}
  !.



{* inst_to_string_if_string(_x,_l,_y):
   Eine Instanzenbeziehung zu String wird doch eingetragen,
   wenn das Objekt zwar schon vorher existiert,
   aber aus der Attributdefinition hervorgeht, dass es ein
   String sein soll.
   Beispiel
   Class a with
	attribute
	 comment : String
   end

   "hallo.4711" in a
   end

   /* Hier ist "hallo.4711" nicht in String */

   "hallo.4711" with
	comment
		halloComment: "hallo.4711"
   end

   Jetzt muss "hallo.4711" in String eingetragen werden,
   obwohl es schon existiert

   2.1.96 RS *}

inst_to_string_if_string(_x,_l,_yId,_ACList) :-
   id2name(_yId,_y),
   quotedAtom(_y),
   name2id(String,_strId),
   retrieve_proposition(P(_,_yId,'*instanceof',_strId)),!.

inst_to_string_if_string(_x,_l,_y,_ACList) :-
   quotedAtom(_y),
   name2idF2P(_y,_yId),
   name2id(String,_strId),
   retrieve_proposition(P(_,_yId,'*instanceof',_strId)),!.

inst_to_string_if_string(_x,_l,_yId,_ACList) :-
   id2name(_yId,_y),
   quotedAtom(_y),
   getAttrTargetClass(_x,_l,_testId,_ACList),
   id2name(_testId,_s),_s == String,!,
   STORE(P(_id,_yId,'*instanceof',_testId)).

inst_to_string_if_string(_x,_l,_y,_ACList) :-
   quotedAtom(_y),
   getAttrTargetClass(_x,_l,_testId,_ACList),
   id2name(_testId,_s),_s == String,!,
   name2idF2P(_y,_yId),
   STORE(P(_id,_yId,'*instanceof',_testId)).


inst_to_string_if_string(_,_,_,_).



{************ s t o r e _ a s s e r t i o n *************************}
{*                                                                  *}
{* store_assertion(_AssIdList, _errno)                              *}
{* _AssIdList : ground : list of AssertionIds to be told            *}
{* _errno : partial : number of errors during AssertionCompilation  *}
{********************************************************************}

store_assertions([],0).

store_assertions(_Liste,_errno) :-

   _Liste = [ac(_AssID,_) | _],
   join(_AssID, _Liste, _purgedListe, _AssClassList),
   retrieve_proposition(P(_AssID,_AssID,_Asstext,_AssID)),
   !,
   compileOrIgnore(_AssID,_Asstext,_AssClassList,_errno1),
   store_assertions(_purgedListe,_errno2),
   _errno is _errno1 + _errno2.


{* 3-Jun-2004/M.Jeusfeld *}
{* if _Asstext is a formula, then we need to compile it *}
compileOrIgnore(_AssID,_Asstext,_AssClassList,_errno1) :-
  pc_atomconcat('$',_,_Asstext),   {* this is really a formula *}
  (
      (
         compileAssertion(_AssID,_Asstext,_AssClassList),
         _errno1 is 0
      );
      _errno1 is 1
   ),
  !.

{* otherwise: we do not compile it at all *}
compileOrIgnore(_AssID,_Asstext,_AssClassList,0).  {* this not a formula, e.g. a query class *}



{*************************** j o i n ********************************}
{*                                                                  *}
{* join(_AssID,_ac,_purgedlist,_AssClassList)                       *}
{*                                                                  *}
{* Seeks for an _AssId *X* all entries ac(*X*,*C*) and gathers all  *}
{* those *C*s in _AssClassList. The entry ac(*X*,*C*) is deleted    *}
{* from _AssClassList i.e. _purgedlist returns a list where the used*}
{* ac(.,.)'s are missing.                                           *}
{********************************************************************}

join(_,[],[],[]).

join(_AssID, [ac(_AssID,_AssClassNA) | _acrest],
      _purgedlist,[_AssClassNA|_AssClassList]) :-

   join(_AssID, _acrest, _purgedlist, _AssClassList).


join(_AssID, [_ac|_acrest], [_ac|_purgedlist], _AssClassList) :-

   join(_AssID, _acrest, _purgedlist, _AssClassList).


IsView(_x) :-
	name2idF2P(_x,_id),
	name2id(View,_viewid),
	prove_edb_literal(In_e(_id,_viewid)).

getAssertionClass(rule,MSFOLrule).
getAssertionClass(constraint,MSFOLconstraint).

generateMetaFormulaClassName(_class,_mClassName) :-
		pc_atomconcat('meta',_class,_mClassName).



{ name2id funktioniert nicht richtig bei der Retell Operation.  }
{ Wenn man was geuntellt hat, und dann gleichzeitig was tellt, }
{ holt name2id leider den alten geuntellten id, der eigentlich }
{ nicht mehr in OB existiert. Hier wird ein neue name2idF2P/2  }
{ eingebaut, das an einigen Stellen in diesem Modul            }
{ das alte name2id ersetzt.  }


name2idF2P(_id,_id) :-
	is_id(_id),
{*	id2name(_id,_), *}
	!.

name2idF2P(_id,_id) :-
	var(_id),
	!.

name2idF2P(_name,_id) :-
	atom(_name),
	retrieve_proposition(P(_id,_id,_name,_id)).


{******************** c o m p i l e H i n t *************************}
{*                                                                  *}
{* compileHint(_subst,_idattr,_rfID)                                *}
{*   _subst: a variable substitution of the form                    *}
{*           subst(_varlist,_conslist)                              *}
{*   _idattr: attribute by which the generated formula is defined   *}
{*   _rfID:  id of the original meta formula                        *}
{*                                                                  *}
{* compileHint is a attaching a so-called hint to a constraint      *}
{* generated from a meta level formula _rfID. If _rfId has a hint,  *}
{* then this hint will be subjected to variable substitition        *}
{* as specified by the _subst parameter. The _subst parameter       *}
{* will contain substitutions for the meta variables in formua      *}
{* _rfID. It is assumed that the hint to be substituted contains    *}
{* the occurrences of the meta-variables surrounded by curly braces *}
{* (ascii 123 and 125, resp.). This works much like substitution    *}
{* for answer formats.                                              *}
{* If a generated constraint is removed, then the generated hint    *}
{* will also be removed, see procedure untellHint in                *}
{* FragmentToHistoryPropositions.pro.                               *}
{* See also ticket #58 and ConceptBase user manual.                 *}
{*                                         5-Apr-2005/M.Jeusfeld    *}
{* **************************************************************** *}

compileHint(_subst,_idattr,_rfID) :-
  fetchHintPattern(_rfID,_hintpattern),
  produceCompiledHintText(_hintpattern,_subst,_hint),
  _hint \== _hintpattern,    {* would be useless to store a compiled hint that is identical to the pattern *}
                             {* since the pattern would be fetched in BDMEvaluation anyway                 *}
  do_store_Object(SMLfragment(what(_idattr),
                  in_omega([]),in([]),isa([]),
                  with([attrdecl([comment],[property(hint,_hint)])])),_errno),
  !.

compileHint(_subst,_idattr,_rfID).  {* never fail *}

{* try to find a hint pattern attached to the meta-level constraint _rfID *}
fetchHintPattern(_rfId,_hintpattern) :-
        prove_edb_literals([A_label(_attrid,comment,_hintid,hint),P(_attrid,_classid,_label,_rfId)]),
        prove_edb_literal(Label(_hintid,_hintpattern)),
        !.

{* execute the substitution on the hint pattern *}
produceCompiledHintText(_hintpattern,subst(_varlist,_constlist),_hint) :-
  name(_hintpattern,_patternstring),
  replaceSubstitutionsInHint(_patternstring,_varlist,_constlist,_hintstring),
  name(_hint,_hintstring),
  !.

produceCompiledHintText(_hintpattern,subst(_varlist,_constlist),_) :-
   WriteTrace('low',FragmentToPropositions,['Could not apply substitutions ',_constlist,
              '/',_varlist,' on hint pattern ',_hintpattern,
              '. Will use the formula text for explaining integrity violations in this case.']),
   !,
  fail.


replaceSubstitutionsInHint(_patternstring,_varlist,_constlist,_hintstring) :-
  replaceSubstitutionsInHint(_patternstring,[],_varlist,_constlist,_hintstring).
 

replaceSubstitutionsInHint([],_soFar,_vars,_consts,_soFar) :- !.

replaceSubstitutionsInHint([123|_rest],_soFar,_vars,_consts,_hintstring) :-
  !,
  getVarname(_rest,_varname,_rest1),
  findConst(_varname,_vars,_consts,_constname),
  name(_constname,_conststring),
  append(_soFar,_conststring,_soFar1),
  replaceSubstitutionsInHint(_rest1,_soFar1,_vars,_consts,_hintstring).

replaceSubstitutionsInHint([_char|_rest],_soFar,_vars,_consts,_hintstring) :-
  append(_soFar,[_char],_soFar1),
  replaceSubstitutionsInHint(_rest,_soFar1,_vars,_consts,_hintstring).


{* scan a variable name until the closing curly brace *}
getVarname(_input,_varname,_restinput) :-
  getVarname(_input,[],_varname,_restinput).

getVarname([125|_rest],_soFar,_varname,_rest) :-
  name(_varname,_soFar),
  !.

getVarname([_char|_rest],_soFar,_varname,_rest1) :-
  append(_soFar,[_char],_soFar1),
  getVarname(_rest,_soFar1,_varname,_rest1).

{* find the constant to be substituted for variable _v *}
findConst(_v,[_v|_],[_c|_],_cname) :- 
  is_id(_c),
  outObjectName(_c,_cname),
  !.

findConst(_v,[_v|_],[_c|_],_c) :-
  !.

findConst(_v,[_|_vars],[_|_consts],_c) :-
   findConst(_v,_vars,_consts,_c).


        
  





