{*
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


This license is a FreeBSD-style copyright license.
Legal home of the FreeBSD copyright license: http://www.freebsd.org/copyright/freebsd-license.html
*}

{************************************************************************
*
* File:         AssertionCompiler.pro
* Version:      2.2
*
*
* Date released : 96/01/10  (YY/MM/DD)
*
* SCCS-Source-Pool : /home/CBase/CB_NewStruct/ProductPOOL/serverSources/Prolog_Files/SCCS/s.AssertionCompiler.pro
* Date retrieved : 96/01/17 (YY/MM/DD)
**************************************************************************
*----------------------------------------------------------------------------
*
* Exported predicates:
*---------------------
*
*   + compileAssertion/3
*
*	25-Jul-90 MSt: assertions which are instances of MSFOLquery are
*			no longer compiled
*
*
* Nomenklatur
IDS : Struktur der Form (_rID,_nID) : _rID ist die ID des Objekts, das den Text
der Regel enthaelt, _nID ist eine neue ID (wer den Verwendungszweck kennt, bitte hier eintragen)
ID : eine OID
DL : DATALOG-neg
PL : PROLOG-Code
*
*
*
* Metaformel-Aenderungen (10.1.96):
* neues Praedikat
* handleRangeform/4, dass die Code-Erzeugung fuer die in generate-Rangeform
* erzeugten Formeln zusammenfasst.
* Fuer rule,constraint bleibt in handleRangeform
* alles beim alten.
* Ist die Formel eine Metaformel, so wird fuer sie selbst hier kein Code
* erzeugt, sondern fuer ihre Instantiierungen. Dies geschieht im
* Modul AssertionTransformer.
*
* Apr-98/Wang handleCode,generateMRules, generatePROLOGCode werden hier Komplekt weggenommen.
* Die Bearbeitung der Prolog-Code-Erzeugung wird in RuleBase erst nach der Optimierung gemacht.
* stattdessen wird hier nach Datalog-Code-Erzeugung initDatalogRulesInfo gemacht.
}

#MODULE(AssertionCompiler)
#EXPORT(compileAssertion/3)
#EXPORT(currentCompiledRule/1)
#ENDMODDECL()

#IMPORT(generateRangeform/5,AssertionTransformer)
#IMPORT(setQueryFlag/1,AssertionTransformer)
#IMPORT(tell_BDMIntegrityConstraint/3,BDMIntegrityChecker)
#IMPORT(tell_BDMRule/3,BDMIntegrityChecker)
#IMPORT(generateDatalog/5,LTcompiler)
#IMPORT(retrieve_proposition/1,PropositionProcessor)
#IMPORT(set_KBsearchSpace/2,SearchSpace)
#IMPORT(get_KBsearchSpace/2,SearchSpace)
#IMPORT(assign_ID/1,validProposition)
#IMPORT(WriteTrace/3,GeneralUtilities)
#IMPORT(name2id/2,GeneralUtilities)
#IMPORT(initDatalogRulesInfo/5,RuleBase)
#IMPORT(pc_update/1,PrologCompatibility)

#LOCAL(existing_relation/2)
#LOCAL(newOID/1)
#LOCAL(currentCompiledRule/1)

#DYNAMIC(currentCompiledRule/1)

#IF(SWI)
:- style_check(-singleton).
#ENDIF(SWI)


{***********************************************************}
{* compileAssertion ( _assID , _text , _superclasslist )   *}
{*                                                         *}
{* _assID : ground : propId                                *}
{* _text : ground : atom surrounded by $                   *}
{* _superclasslist : ground : list                         *}
{*                                                         *}
{* compileAssertion compiles assertion _id with            *}
{* textrepresentation _text. _superclasslist contains      *}
{* assertionclasses e.g. MSFOLquery or MSFOLrule to which  *}
{* assertion _id belongs.                                  *}
{***********************************************************}
#MODE(compileAssertion(i,i,i))

compileAssertion( _, _, []) :-  !.

{* Assertion has been already told
*}
compileAssertion(_id,_text,[_fc|_rc]) :-
	    existing_relation(_id,_fc),
            !,
            compileAssertion(_id,_text,_rc).

{* new Rule: to be compiled to PROLOG-Code
*}


compileAssertion(_ruleID,_text,[MSFOLrule| _more]) :-

	{* generate optimized datastructure
	*}
	setQueryFlag(RC),
	pc_update(currentCompiledRule(_ruleID)),
	generateRangeform(rule,_ruleID, _text, _rangerule, _vartab),
	!,
	handleRangeform(rule, _rangerule,_vartab,_ruleID),
	{* check Integrity and generate triggers for integrity-checking
	*}
	compileAssertion(_ruleID,_text, _more).


compileAssertion(_queryID,_text,[MSFOLquery| _more]).


{9-Mar-1993/MJf: MSFOLconstraint anstatt BDMConstraint }
compileAssertion( _constrID, _text, [MSFOLconstraint | _more]) :-

	{* generate optimized datastructure
	*}
	setQueryFlag(RC),
	pc_update(currentCompiledRule(_constrID)),
	generateRangeform(constraint, _constrID,_text, _rangeform, _vartab),
	handleRangeform(constraint, _rangeform,_vartab,_constrID),
	{* check Integrity and generate triggers for integrity-checking
	*}
	compileAssertion(_constrID,_text, _more).


compileAssertion(_,_,_) :-
	WriteTrace(low,AssertionCompiler,'Assertion was not compiled'),
	!,
	fail.

{===========================================================}
{=                LOCAL PREDICATES DEFINITION              =}
{===========================================================}

{***********************************************************}
{* existing_relation ( _id , _assclass )                   *}
{*                                                         *}
{* _id       : ground                                      *}
{* _assclass : ground                                      *}
{*                                                         *}
{* checks wether the instantiation link between assertion  *}
{* _id and its assertion class _assclass exists with a not *}
{*  finished transaction time. This means that such a link *}
{* is already believed and a compilation again is not      *}
{* necessary.                                              *}
{***********************************************************}


existing_relation(_assid,_assclass) :-

	get_KBsearchSpace(_kb,_rbt),
	set_KBsearchSpace(currentOB,Now),    { see also CBNEWS[126]/MJf }
	((
	    {* either there is a relation ...
	    *}
	    name2id(_assclass,_assclassID),
	    retrieve_proposition( P( _id, _assid, '*instanceof', _assclassID))
	);(
	    {* ... or NOT: reinstall old settings of KBsearchSpace
	    *}
	    set_KBsearchSpace(_kb,_rbt),
	    !
	    ,fail
	)),
	{* ... reinstall in case of success, too
	*}
	set_KBsearchSpace(_kb,_rbt),
	!.

{* Aufbau der IDS (ID-struct)
*}
create_IDS(_rID,id(_rID,_nID)) :-
	newOID(_nID).

{***********************************************************}
{* newOID(_nID)                                            *}
{*                                                         *}
{* _nID : (output) : OID                                   *}
{*                                                         *}
{* self-explaining, isn't it ?                             *}
{* waere nicht schlecht, wenn es das auch als Test gaebe ??*}
{***********************************************************}

#MODE(newOID(o))
newOID(_nID) :-
	assign_ID(P(_nID,_,_,_)).

{***********************************************************}
{* handleRangeform(_mode,_rangeformula,_vartab,_ID         *}
{*                                                         *}
{* _mode: rule oder constraint                             *}
{* _rangeformula: Formel, die behandelt werden soll im     *}
{*                im rangeform - format                    *}
{*                oder das atom 'metaFormula' falls die    *}
{*                Formel eine Metaformel ist               *}
{* _varTab:       Variablentabelle                         *}
{* _ID:  oid des Formeltexts                               *}
{*                                                         *}
{* handleRangeform stoesst die Codeerzeugung fuer einfache *}
{* Formeln an. Ist die Formel eine Metaformel, so wird fuer*}
{* fuer die Formel selbst hier kein Code erzeugt, sondern  *}
{* fuer die partiell ausgewerteten Formeln, die Instanzen  *}
{* dieser Formel sind.                                     *}
{***********************************************************}

#MODE(handleRangeform(i,i,i,i))

{* Metaformel-Anpassung:
   Ist die Formel eine Metaformel, so wird
   fuer sie selber kein Code erzeugt, sondern
   fuer ihre Instanzen.
   siehe AssertionTransformer, Praedikat tellGenFormulas
   ansonsten wie vorher
   R.S. 9.1. 1996
*}

handleRangeform(_,'metaFormula',_,_) :- !.


{* Redundante Formeln:
   Formeln die Aussagen ueber Instanzen von Objekten beinhalten, welche
   keine Instanzen haben koennen, werden ignoriert.
   Beispiel
	exists y/Proposition In(y,4) .....

   kann durch TRUE ersetzt werden, weil das Objekt 4 keine Instanzen haben kann.
   Ob ein solcher Fall vorliegt, wird in RangeformSimplifier entschieden.
*}

handleRangeform(_,'redundant',_,_) :- !.

handleRangeform(rule,_rangerule,_vartab,_ruleID) :-
	{* check Integrity and generate triggers for integrity-checking
	*}
	tell_BDMRule(_rangerule,_vartab,_ruleID),
	!,
	create_IDS(_ruleID,_rIDS),
	{*compile to Datalog
	*}
	generateDatalog(_ruleID,_rIDS,_rangerule,_vartab,_ruleDLs),
	!,
	{* Generate Rule Infos Sep-97/RS,CQ *}
	initDatalogRulesInfo(_ruleDLs,rule,_ruleID,_rIDS,_vartab).




handleRangeform(constraint,_rangeform,_vartab,_constrID) :-
	{* check Integrity and generate triggers for integrity-checking
	*}
	tell_BDMIntegrityConstraint( _rangeform,_vartab,_constrID),
	!.





