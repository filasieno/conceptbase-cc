{*
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
*}
{ Definition of some global predicates }

#IF(SWI)
#MODULE(GlobalPredicates)
#EXPORT(LTevalRule/2)
#EXPORT(LTevalQuery/2)
#EXPORT(stratificationErrorFound/0)
#EXPORT(System/1)
#EXPORT(Module/1)
#EXPORT(M_SearchSpace/1)
#EXPORT(QueryArgExp/2)
#EXPORT(ViewArgExp/3)
#EXPORT(QCjoincond/3)
#EXPORT(vmrule/2)
#EXPORT('error_number@F2P'/1)
#EXPORT(tmpRuleInfo/10)
#EXPORT(ruleInfo/10)
#EXPORT(RuleTTime/2)
{#EXPORT(ExamIcLiterals/6)
#EXPORT(ExamCondLitsForRuleOrIc/10) }
#EXPORT('e@ECAevent'/4)
#EXPORT('e@ECATEMP'/4)
#EXPORT('nest@ECAruleManager'/3 )
#EXPORT('priority@ECAruleManager'/3 )
#EXPORT('eca@ECAruleManager'/12 )
#EXPORT('r@ECAruleManager'/7 )
#EXPORT('nest@ECATEMP'/3 )
#EXPORT('priority@ECATEMP'/3 )
#EXPORT('eca@ECATEMP'/12 )
#EXPORT('r@ECATEMP'/7 )
#EXPORT('error_number@SI'/1)
#EXPORT('error_number@UI'/1)
#EXPORT('error_number@F2HP'/1)
#EXPORT('error_number@ECA'/1)
#EXPORT('var@counter'/1)
#EXPORT(buildCBEditorResult/6)             {* from SYSTEM*.builtin; ticket #256 *}
#EXPORT(buildCBEditorResultWithoutEdges/3) {*    "   *}
#EXPORT(currentUser/1)                     {*    "   *}
#ENDMODDECL()

#ENDIF(SWI)
#IMPORT(pc_atomconcat/2,PrologCompatibility)
#IMPORT(pc_atomconcat/3,PrologCompatibility)
#IMPORT(appendBuffer/3,ExternalCodeLoader)
#IMPORT(save_setof/3,GeneralUtilities)
#IMPORT(ObjNameStringToList/3,TellAndAsk)
#IMPORT(EliminateClassInList/2,TellAndAsk)
#IMPORT(replace/4,GeneralUtilities)
#IMPORT(outObjectName/2,ScanFormatUtilities)
#IMPORT(active_user/1,CBserverInterface)
#IMPORT(pc_stringtoatom/2,PrologCompatibility)
#IMPORT(getGraphType/3,GeneralUtilities)
#IMPORT(appendGproperties/2,GeneralUtilities)
#IMPORT(evalClassList/3,SelectExpressions)
#IMPORT(prove_literal/1,Literals)
#IMPORT(is_allIds/1,GeneralUtilities)
#IMPORT(WriteTrace/3,GeneralUtilities)
#IMPORT(report_error/3,ErrorMessages)


#IF(SWI)
:- style_check(-singleton).
#ENDIF(SWI)

{ from Literals.pro }

#DYNAMIC(LTevalRule/2)
#DYNAMIC(LTevalQuery/2)
#DYNAMIC(stratificationErrorFound/0)
  {* to report violations of stratification *}


{ from ConfigurationUtilities.pro }

#DYNAMIC(System/1)
	{ LWEB 	f. Optimierung: Praedikat enthaelt ID des System Objekts}
#DYNAMIC(Module/1)
	{ LWEB 	f. Optimierung: Praedikat enthaelt ID des Module Objekts}



{ from PropositionProcessor.pro }

#DYNAMIC(M_SearchSpace/1)

{ default Module SearchSpace }
M_SearchSpace( System ).

{ from Query/ViewCompiler }
#DYNAMIC(QueryArgExp/2)
#DYNAMIC(ViewArgExp/3)


{ for QueryCompilerUtilities.pro }

#DYNAMIC(QCjoincond/3)


{ for VMruleGenerator.pro }

#DYNAMIC(vmrule/2).


{ from FragmentToPropositions.pro }

#DYNAMIC('error_number@F2P'/1)

{ from ECAactionManager.pro }

#DYNAMIC('error_number@ECA'/1)




{ from RuleBase.pro }

#DYNAMIC(tmpRuleInfo/10)
#DYNAMIC(ruleInfo/10)

#IF(BIM)
:- tmpRuleInfo/10 index (1,5).
:- ruleInfo/10 index (1,5).
#ELSE(BIM)
{* :- index(tmpRuleInfo(1,0,0,0,1,0,0,0,0,0)).
:- index(ruleInfo(1,0,0,0,1,0,0,0,0,0)). *}
#ENDIF(BIM)


{ from LTstubs and related modules }
#DYNAMIC(RuleTTime/2).


{ from BDMcompile.pro }
{ TODO: eigentlich nicht dynamic, sondern statisch in BDMcompile definiert }
{ geht so nicht, statische und dynamische Definition gleichzeitig geht nicht in SWI
#DYNAMIC(ExamIcLiterals/6 )
#DYNAMIC(ExamCondLitsForRuleOrIc/10 )
}





{ from ECAeventManager }
#DYNAMIC('e@ECAevent'/4)
#DYNAMIC('e@ECATEMP'/4)

{ from ECAruleProcessor }
#DYNAMIC('nest@ECAruleManager'/3 )
#DYNAMIC('priority@ECAruleManager'/3 )
#DYNAMIC('eca@ECAruleManager'/12 )
#DYNAMIC('r@ECAruleManager'/7 )
#DYNAMIC('nest@ECATEMP'/3 )
#DYNAMIC('priority@ECATEMP'/3 )
#DYNAMIC('eca@ECATEMP'/12 )
#DYNAMIC('r@ECATEMP'/7 )

{ from SemanticIntegrity }
#DYNAMIC('error_number@SI'/1)
#DYNAMIC('error_number@UI'/1)

{ from FragmentToHistoryPropositions }
#DYNAMIC('error_number@F2HP'/1)

{ from MetaLiterals }
#DYNAMIC('var@counter'/1)





{* These predicates were aoriginally in SYSTEM*.builtin and thus globally visible *}
{* We supply them now via GlobalPredicates. Ticket #256.                          *}

{* ********************************************************************** *}
{* Predicates for Java CBEditor, used by AnswerFormat CBGraphEditorResult *}
{* ********************************************************************** *}
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
    report_error(MISSOBJ4,GlobalPredicates,[_object,_dst,_cat,_pal]).



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
    report_error(MISSOBJ2,GlobalPredicates,[_object,_pal]).








parseObjectNames(_atomlist,_idlist) :-
    atomconcatWithCommata(_atomlist,_bigatom),
    pc_stringtoatom(_Objstring,_bigatom),
    ObjNameStringToList(_Objstring,_sml_objnamelist),
    evalClassList(_sml_objnamelist,replaceSelectExpression,_idlist1),
    EliminateClassInList(_idlist1,_idlist),
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


{* ********************************************************************** *}
{* Extensions for ECA rule (predicates to be invoked in DO part)          *}
{* ********************************************************************** *}

{* ticket 151: auxiliary predicate required to protect access to ConceptBase 
   modules
*}
currentUser(_u) :-
   active_user(_uname),
   name2id(_uname,_u),
   !.






