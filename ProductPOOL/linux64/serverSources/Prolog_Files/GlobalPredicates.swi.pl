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
/* Definition of some global predicates */


:- module('GlobalPredicates',[
'LTevalRule'/2
,'LTevalQuery'/2
,'stratificationErrorFound'/0
,'System'/1
,'Module'/1
,'M_SearchSpace'/1
,'QueryArgExp'/2
,'ViewArgExp'/3
,'QCjoincond'/3
,'vmrule'/2
,'error_number@F2P'/1
,'tmpRuleInfo'/10
,'ruleInfo'/10
,'RuleTTime'/2
/*#EXPORT(ExamIcLiterals/6)
#EXPORT(ExamCondLitsForRuleOrIc/10) */
,'e@ECAevent'/4
,'e@ECATEMP'/4
,'nest@ECAruleManager'/3
,'priority@ECAruleManager'/3
,'eca@ECAruleManager'/12
,'r@ECAruleManager'/7
,'nest@ECATEMP'/3
,'priority@ECATEMP'/3
,'eca@ECATEMP'/12
,'r@ECATEMP'/7
,'error_number@SI'/1
,'error_number@UI'/1
,'error_number@F2HP'/1
,'error_number@ECA'/1
,'ruleTriggerCalls'/1
,'constraintTriggerCalls'/1
,'var@counter'/1
,'buildCBEditorResult'/6
,'buildCBEditorResultWithoutEdges'/3
,'currentUser'/1
]).
:- use_module('GlobalPredicates.swi.pl').
:- use_module('debug.swi.pl').


:- use_module('PrologCompatibility.swi.pl').

:- use_module('ExternalCodeLoader.swi.pl').
:- use_module('GeneralUtilities.swi.pl').
:- use_module('TellAndAsk.swi.pl').


:- use_module('ScanFormatUtilities.swi.pl').
:- use_module('CBserverInterface.swi.pl').



:- use_module('SelectExpressions.swi.pl').
:- use_module('Literals.swi.pl').


:- use_module('ErrorMessages.swi.pl').



:- style_check(-singleton).


/* from Literals.pro */

:- dynamic 'LTevalRule'/2 .
:- dynamic 'LTevalQuery'/2 .
:- dynamic 'stratificationErrorFound'/0 .
  /** to report violations of stratification **/


/* from ConfigurationUtilities.pro */

:- dynamic 'System'/1 .
	/* LWEB 	f. Optimierung: Praedikat enthaelt ID des System Objekts*/
:- dynamic 'Module'/1 .
	/* LWEB 	f. Optimierung: Praedikat enthaelt ID des Module Objekts*/



/* from PropositionProcessor.pro */

:- dynamic 'M_SearchSpace'/1 .

/* default Module SearchSpace */
'M_SearchSpace'( 'System' ).

/* from Query/ViewCompiler */
:- dynamic 'QueryArgExp'/2 .
:- dynamic 'ViewArgExp'/3 .


/* for QueryCompilerUtilities.pro */

:- dynamic 'QCjoincond'/3 .


/* for VMruleGenerator.pro */

:- dynamic 'vmrule'/2 .


/* from FragmentToPropositions.pro */

:- dynamic 'error_number@F2P'/1 .

/* from ECAactionManager.pro */

:- dynamic 'error_number@ECA'/1 .

:- dynamic 'ruleTriggerCalls'/1 .
:- dynamic 'constraintTriggerCalls'/1 .


/* from RuleBase.pro */

:- dynamic 'tmpRuleInfo'/10 .
:- dynamic 'ruleInfo'/10 .


/** :- index(tmpRuleInfo(1,0,0,0,1,0,0,0,0,0)).
:- index(ruleInfo(1,0,0,0,1,0,0,0,0,0)). **/



/* from LTstubs and related modules */
:- dynamic 'RuleTTime'/2 .


/* from BDMcompile.pro */
/* TODO: eigentlich nicht dynamic, sondern statisch in BDMcompile definiert */
/* geht so nicht, statische und dynamische Definition gleichzeitig geht nicht in SWI
#DYNAMIC(ExamIcLiterals/6 )
#DYNAMIC(ExamCondLitsForRuleOrIc/10 )
*/





/* from ECAeventManager */
:- dynamic 'e@ECAevent'/4 .
:- dynamic 'e@ECATEMP'/4 .

/* from ECAruleProcessor */
:- dynamic 'nest@ECAruleManager'/3 .
:- dynamic 'priority@ECAruleManager'/3 .
:- dynamic 'eca@ECAruleManager'/12 .
:- dynamic 'r@ECAruleManager'/7 .
:- dynamic 'nest@ECATEMP'/3 .
:- dynamic 'priority@ECATEMP'/3 .
:- dynamic 'eca@ECATEMP'/12 .
:- dynamic 'r@ECATEMP'/7 .

/* from SemanticIntegrity */
:- dynamic 'error_number@SI'/1 .
:- dynamic 'error_number@UI'/1 .

/* from FragmentToHistoryPropositions */
:- dynamic 'error_number@F2HP'/1 .

/* from MetaLiterals */
:- dynamic 'var@counter'/1 .





/** These predicates were aoriginally in SYSTEM*.builtin and thus globally visible **/
/** We supply them now via GlobalPredicates. Ticket #256.                          **/

/** ********************************************************************** **/
/** Predicates for Java CBEditor, used by AnswerFormat CBGraphEditorResult **/
/** ********************************************************************** **/
buildCBEditorResult(_result,_object,_dst,_cat,_pal,_dir) :-
    parseObjectNames([_object,_dst,_cat,_pal],[_oid,_dstid,_catid,_palid]),
    is_allIds([_oid,_dstid,_catid,_palid]),
    !,
    replaceSpecialCharacter(_object,_object2),
    !,
    appendBuffer(_result,'  <object>\n    <name>'),
    appendBuffer(_result,_object2),
    appendBuffer(_result,'</name>\n'),
    getGraphType([_result],_oid,_palid),
    !,
    getEdges(_oid,_dstid,_catid,_dir,_edgeIds),
    !,
    appendBuffer(_result,'    <edges>\n'),
    makeEdgesElement(_edgeIds,_palid,_result),
    !,
    appendBuffer(_result,'    </edges>\n'),

    appendGproperties(_result,_oid),
    appendBuffer(_result,'  </object>\n').

buildCBEditorResult(_result,_object,_dst,_cat,_pal,_dir) :-
    appendBuffer(_result,' <object>buildCBEditorResult:ERROR</object>'),
    report_error('MISSOBJ4','GlobalPredicates',[_object,_dst,_cat,_pal]).



buildCBEditorResultWithoutEdges(_result,_object,_pal) :-
    parseObjectNames([_object,_pal],[_oid,_palid]),
    is_allIds([_oid,_palid]),
    !,
    replaceSpecialCharacter(_object,_object2),
    !,
    appendBuffer(_result,'  <object>\n    <name>'),
    appendBuffer(_result,_object2),
    appendBuffer(_result,'</name>\n'),
    getGraphType([_result],_oid,_palid),
    appendGproperties(_result,_oid),
    !,
    appendBuffer(_result,'  </object>\n').

buildCBEditorResultWithoutEdges(_result,_object,_pal) :-
    appendBuffer(_result,' <object>buildCBEditorResultWithoutEdges:ERROR</object>'),
    report_error('MISSOBJ2','GlobalPredicates',[_object,_pal]).








parseObjectNames(_atomlist,_idlist) :-
    atomconcatWithCommata(_atomlist,_bigatom),
    pc_stringtoatom(_Objstring,_bigatom),
    'ObjNameStringToList'(_Objstring,_sml_objnamelist),
    evalClassList(_sml_objnamelist,replaceSelectExpression,_idlist1),
    'EliminateClassInList'(_idlist1,_idlist),
    !.


atomconcatWithCommata([],'') :- !.
atomconcatWithCommata([_a],_a) :- !.
atomconcatWithCommata([_a|_r],_res) :-
    atomconcatWithCommata(_r,_ar),
    !,
    pc_atomconcat([_a,',',_ar],_res).

replaceSpecialCharacter(_object,_object) :-
    sub_atom(_object,_,_,_,'<').

replaceSpecialCharacter(_object,_newobject) :-
    atom_chars(_object,_list),
    replace('<',_list,'&lt;',_newlist),
    pc_atomconcat(_newlist,_newobject),
    !.


getEdges(_oid,_dstid,_catid,dst,_edges) :-
    save_setof(_e,
        (_l)^(prove_literal('P'(_e,_oid,_l,_dstid)),
         prove_literal('In'(_e,_catid))),
        _edges).

getEdges(_oid,_srcid,_catid,src,_edges) :-
    save_setof(_e,
        (_l)^(prove_literal('P'(_e,_srcid,_l,_oid)),
         prove_literal('In'(_e,_catid))),
        _edges).

makeEdgesElement([],_,'') :- !.

makeEdgesElement([],_,_elem) :- !.

makeEdgesElement([_id|_r],_palid,_elem) :-
    outObjectName(_id,_object),
    replaceSpecialCharacter(_object,_object2),
    appendBuffer(_elem,'      <object>\n        <name>'),
    appendBuffer(_elem,_object2),
    appendBuffer(_elem,'</name>\n'),
    getGraphType([_elem],_id,_palid),
    appendGproperties(_elem,_id),
    appendBuffer(_elem,'      </object>\n'),
    makeEdgesElement(_r,_palid,_elem).


/** ********************************************************************** **/
/** Extensions for ECA rule (predicates to be invoked in DO part)          **/
/** ********************************************************************** **/

/** ticket 151: auxiliary predicate required to protect access to ConceptBase 
   modules
**/
currentUser(_u) :-
   active_user(_uname),
   name2id(_uname,_u),
   !.






