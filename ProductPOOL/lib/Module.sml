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
{*
*
* File:        Module.sml
* Version:     1.0
* Creation:    22-May-1996 Lutz Bauer, RWTH
* Last Change: 27-Jan-2014, Manfred Jeusfeld, Uni Skoevde
* Release:     
* -----------------------------------------------------------------------------
*
* This is the model for the Module Framework of ConceptBase
* It originates from the PhD thesis of Hans Nissen.
*
*
*}

Individual Module in Class with 
  attribute
     imports  :  Module;
     exports  :  Proposition;
     contains :  Proposition
end 


Individual System in Module 
end 

{* oHome is the default home module of client enrolling to ConceptBase *}
Individual oHome in Module 
end 



{* 1-Oct-2003/M.Jeusfeld: add user's and their so-called home modules *}
{* Home module of a user is the module that s/he will be assigned to  *}
{* when enrolling to the ConceptBase server. This makes management of *}
{* multiple concurrent users a lot easier.                            *}
{* This is much like a home directory.                                *}
{* 9-Feb-2004/M.Jeusfeld: profileTag is a facility to attach any      *}
{* number of user profile information tags to a CB_User. Rather than  *}
{* an extensive Telos model for user profiles, we pack everything into*}
{* this LDAP-like structure. Can be used by CBserver tp check any     *}
{* type of authorization of a ConceptBase user.                       *}

Individual CB_User with 
  attribute
    homeModule: Module;
    profileTag: String
end


{* Auto home module are such modules which force new users into automatically *}
{* created sub-modules of the auto home module.                               *}
{* This rule is overridden for the 'exception users'. These users are not     *}
{* forced downwards.                                                          *}
{* This is useful for letting a group of users work on the same CBserver on   *}
{* a given module without interference.                                       *}

AutoHomeModule isA Module with
  attribute
   exception: CB_User
end


{* 19-Feb-2004/M.Jeusfeld: rudimentary rights management model enforced at  *}
{* CBserverInterface.pro                                                    *}
{* Actual right rules are to be defined by users!                           *}

Resource with end   {* a resource is anything subject to access rights      *}
Module isA Resource end  {* modules are good examples of resources          *}

CB_Operation end    {* any operation (ipcmessage, query,...) we want to monitor   *}
CB_ReadOperation isA CB_Operation end  {* at least we distinguish read from write *}
CB_WriteOperation isA CB_Operation end

{* list of read/write operations of the CBserverInterface, as of 20-Feb-2004 *}
TELL in CB_WriteOperation end
TELL_MODEL in CB_WriteOperation end
UNTELL in CB_WriteOperation end
RETELL in CB_WriteOperation end
LPI_CALL in CB_WriteOperation end

ASK in CB_ReadOperation end  
HYPO_ASK in CB_ReadOperation end  


{* builtin module listing; M. Jeusfeld/26-Jan-2011 *}
listModule in BuiltinQueryClass with
  parameter
     module: Module
end

IsolatedValue in HiddenObject,GenericQueryClass isA Proposition with
  parameter
    type: BuiltinClass
  constraint
    isoC: $ 
              (:(~this in ~type): and
                      not (exists y/Proposition (~this attribute y)) and 
                      not (exists c/Proposition In_s(~this,c) and (c <> ~type) and
                                                (c <> Proposition) and (c <> Individual) ))
          $
end


{* used for listModule; see also ConfigurationUtilities.pro *}
DoNotSave_LM in QueryClass isA Proposition with
   constraint cnts: $ (~this in HiddenObject) or
                      ((~this in MSFOLassertion) and not (~this in QueryClass)) or
                      (~this in BDMRuleCheck) or
                      (~this in BDMConstraintCheck) or (~this in Proposition!deducedBy) or
                      (~this in Proposition!applyConstraintIfInsert) or (~this in Proposition!applyConstraintIfDelete) or
                      (~this in ECAassertion) or ( not (~this in Individual) and
                      (forall x/Proposition ((~this attribute x) ==> (x in DoNotSave_LM)) and not Isa_e(~this,x))) or
                      ( (~this in IsA) and exists a/Attribute From(~this,a) and 
                        ((a in QueryClass!retrieved_attribute) or (a in View!inherited_attribute))) or
                      (~this in IsolatedValue[String/type]) or
                      (~this in IsolatedValue[Integer/type]) or
                      (~this in IsolatedValue[Real/type]) or

                      :(~this in TransactionTime): and not (exists z/Proposition (~this attribute z))
                      $
end







{* for saving query answers in the file system *}
Module with 
  attribute
     saveView: QueryClass
end 

AnswerFormat with
  attribute
    fileType: String  {* preferred file type for saved query answers, e.g. "xml" *}
end





{* ===================================== *}
{* additional system objects follow here *}
{* without being necessarily related to  *}
{* 'Module'.                             *}
{* ===================================== *}

Function toLabel isA Individual with  
attribute,parameter
    s : String
attribute,comment
    c : "returns s as a label without quotes and special character and creates it as individual object"
end 


Function concat isA String with
parameter
	s1 : String;
	s2 : String
comment
	c : "Appends string s2 to the end of string s1; same as ConcatenateStrings"
end

DoNotSave_LM in HiddenObject end
rename in HiddenObject end
changeAttributeValue in HiddenObject end


{* immutable attributes are like ordinary attributes but they are supposed to be defined
   only once together with their source objects and then remain unchanged; 
*}
Proposition with
  attribute
    immutable: Proposition
end



{* give ISA links a white head, similar to UML specialization links; ticket #382*}
DefaultIsAGT with  
  property
    edgeheadcolor : "255,255,255"  
end 
ImplicitIsAGT with  
  property
    edgeheadcolor : "255,255,255"  
end 



{* any object can have its own graphical properties, augmenting the properties of its graphtype
   ticket #397; we allow the value to be any Proposition (strings, numbers, any object name)
   though graphtype properties are usually strings
*}
Proposition with
  attribute
    gproperty: Proposition
end



{* used for listModule; faster version that assumes that Integers or Reals cannot have attributes; ticket #417 *}

DoNotSave_1 in HiddenObject,QueryClass isA Proposition with  
  constraint
    cnts : $ (~this in HiddenObject) or
             ((~this in MSFOLassertion) and not (~this in QueryClass)) or
             (~this in BDMRuleCheck) or
             (~this in BDMConstraintCheck) or (~this in Proposition!deducedBy) or
             (~this in Proposition!applyConstraintIfInsert) or (~this in Proposition!applyConstraintIfDelete) or
             (~this in ECAassertion) or
             ( (~this in IsA) and exists a/Attribute From(~this,a) and 
             ((a in QueryClass!retrieved_attribute) or (a in View!inherited_attribute))) or
             (~this in IsolatedValue[String/type]) or
             (~this in IsolatedValue[Integer/type]) or
             (~this in IsolatedValue[Real/type]) or
             :(~this in TransactionTime): and not (exists z/Proposition (~this attribute z))
             $
end



{* builtin purgeModule; M. Jeusfeld/30-Oct-2018 *}
purgeModule in HiddenObject,BuiltinQueryClass with
  parameter
     module: Module
end


{* builtin reloadable module listing; M. Jeusfeld/2020-01-15 *}
listModuleReloadable in BuiltinQueryClass with
  parameter
     module: Module
end


{* define copyright and license of the System module *}

System in Module with
  comment
    author : "(C) 1987 ConceptBase Team, in particular Manfred Jeusfeld, Martin Staudt, Hans Nissen, Christoph Quix, Eva Krueger; all rights reserved.";
    license : "Use permitted under FreeBSD style license, see http://conceptbase.sourceforge.net/CB-FreeBSD-License.txt.";
    purpose: "The System module is the root module of ConceptBase. It contains the pre-defined objects and classes for ConceptBase."
end



{* new graphical palette TelosPalette; more modern look, can be specialized to define more easily new palettes *}
{* Manfred Jeusfeld, 2021-05-29 *}

XBridgePalette in Class,JavaGraphicalPalette with  
  contains,defaultIndividual
    xx1 : DefaultIndividualGT
  contains,defaultLink
    xx2 : DefaultLinkGT
  contains,implicitIsA
    xx3 : ImplicitIsAGT
  contains,implicitInstanceOf
    xx4 : ImplicitInstanceOfGT
  contains,implicitAttribute
    xx5 : ImplicitAttributeGT
  contains
    xx6 : DefaultIsAGT;
    xx7 : DefaultInstanceOfGT;
    xx8 : DefaultAttributeGT;
    xx9 : MetametaGT;
    xx10 : SimpleClassGT;
    xx11 : MetaClassGT;
    xx12 : ClassGT;
    xx13 : QueryClassGT
  rule
    inheritGTs: $ forall gt/JavaGraphicalType superpal,pal/JavaGraphicalPalette
                      (superpal isA XBridgePalette) and
                      (pal isA superpal) and (pal <> XBridgePalette) and
                      (superpal contains gt)
                  ==> (pal contains gt) $;
    inheritDef1: $ forall gt/JavaGraphicalType superpal,pal/JavaGraphicalPalette
                      (superpal isA XBridgePalette) and
                      (pal isA superpal) and (pal <> XBridgePalette) and
                      (superpal defaultIndividual gt)
                  ==> (pal defaultIndividual gt) $;
    inheritDef2: $ forall gt/JavaGraphicalType superpal,pal/JavaGraphicalPalette
                      (superpal isA XBridgePalette) and
                      (pal isA superpal) and (pal <> XBridgePalette) and
                      (superpal defaultLink gt)
                  ==> (pal defaultLink gt) $;
    inheritDef3: $ forall gt/JavaGraphicalType superpal,pal/JavaGraphicalPalette
                      (superpal isA XBridgePalette) and
                      (pal isA superpal) and (pal <> XBridgePalette) and
                      (superpal implicitIsA gt)
                  ==> (pal implicitIsA gt) $;
    inheritDef4: $ forall gt/JavaGraphicalType superpal,pal/JavaGraphicalPalette
                      (superpal isA XBridgePalette) and
                      (pal isA superpal) and (pal <> XBridgePalette) and
                      (superpal implicitInstanceOf gt)
                  ==> (pal implicitInstanceOf gt) $;
    inheritDef5: $ forall gt/JavaGraphicalType superpal,pal/JavaGraphicalPalette
                      (superpal isA XBridgePalette) and
                      (pal isA superpal) and (pal <> XBridgePalette) and
                      (superpal implicitAttribute gt)
                  ==> (pal implicitAttribute gt) $
end 



TelosPalette in Class,JavaGraphicalPalette isA XBridgePalette with  
  comment
    description: "This is the preferred default graphical palette for ConceptBase 8.2 (released 2021). The previous DefaultJavaPalette is still supported. TelosPalette is closer to the symbols used in UML class diagrams and has better support for long strings."
  contains,defaultIndividual
    tp1 : INDIVIDUAL_TP_GT
  contains,defaultLink
    tp2 : ATTR_TP_GT
  contains,implicitIsA
    tp3 : ISADEDUCED_TP_GT
  contains,implicitInstanceOf
    tp4 : INSTOFDEDUCED_TP_GT
  contains,implicitAttribute
    tp5 : ATTRDEDUCED_TP_GT
  contains
    tp6 : CLASS_TP_GT;
    tp7 : QUERYCLASS_TP_GT;
    tp8 : INSTOF_TP_GT;
    tp9: ISA_TP_GT;
    tp10: STRING_TP_GT;
    tp11: VALUE_TP_GT;
    tp12: ASSERTION_TP_GT
end 



INSTOF_TP_GT in JavaGraphicalType,Class with 
  attribute,property
    bgcolor : "0,180,0";
    textcolor : "0,0,0";
    edgecolor : "0,180,0";
    edgewidth : "2";
    edgeheadshape: "Caret";
    edgestyle : "ldashed";
    label : ""
  attribute,implementedBy
     implBy : "i5.cb.graph.cbeditor.CBLink"
  attribute,priority
     p : 6
  rule
     gtrule1: $ forall a/InstanceOf (a graphtype INSTOF_TP_GT) $
end 

INSTOFDEDUCED_TP_GT in JavaGraphicalType,Class with 
  attribute,property
    bgcolor : "0,180,0";
    textcolor : "0,0,0";
    edgecolor : "0,180,0";
    edgewidth : "1";
    edgeheadshape: "Caret";
    edgestyle : "dashed";
    label : ""
  attribute,implementedBy
     implBy : "i5.cb.graph.cbeditor.CBLink"
  attribute,priority
     p : 7
end  

ISA_TP_GT in JavaGraphicalType,Class with 
  attribute,property
    bgcolor : "0,150,255";
    textcolor : "0,0,0";
    edgecolor : "0,50,255";
    edgeheadcolor : "255,255,255";
    edgeheadshape : "Arrow";
    edgewidth : "2";
    label : ""
  attribute,implementedBy
     implBy : "i5.cb.graph.cbeditor.CBLink"
  attribute,priority
     p : 6
  rule
     gtrule1: $ forall a/IsA (a graphtype ISA_TP_GT) $
end 

ISADEDUCED_TP_GT in JavaGraphicalType,Class with 
  attribute,property
    bgcolor : "0,150,255";
    textcolor : "0,0,0";
    edgecolor : "0,50,255";
    edgewidth : "1";
    edgestyle : "dashed";
    label : "";
    edgeheadcolor : "255,255,255";
    edgeheadshape: "Arrow"
  attribute,implementedBy
     implBy : "i5.cb.graph.cbeditor.CBLink"
  attribute,priority
     p : 7
end  


ATTR_TP_GT in Class,JavaGraphicalType with  
  property
    textcolor : "0,0,0";
    edgecolor : "0,0,0";
    edgewidth : "2";
    fontsize: "10";
    bgcolor : "255,255,255,240"  {* white, slighlty transparent *}
  implementedBy
    implBy : "i5.cb.graph.cbeditor.CBLink"
  priority
    p : 5
  rule
     gtrule1: $ forall x/Proposition!attribute (x graphtype ATTR_TP_GT) $
end 

ATTRDEDUCED_TP_GT in JavaGraphicalType with  
  property
    textcolor : "0,0,0";
    edgecolor : "0,0,0";
    edgewidth : "2";
    edgestyle : "dashed";
    fontsize: "10";
    bgcolor : "255,255,255,240"  {* white, slighlty transparent *}
  implementedBy
    implBy : "i5.cb.graph.cbeditor.CBLink"
  priority
    p : 7
end 


INDIVIDUAL_TP_GT in Class,JavaGraphicalType with
property
	bgcolor : "255,255,255"; 
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "Rect";
        size: "resizable";
        linewidth : "1"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 5
rule
     gtrule1: $ forall x/Individual (x graphtype INDIVIDUAL_TP_GT) $
end


CLASS_TP_GT in Class,JavaGraphicalType with
property
	bgcolor : "250,250,250"; 
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "Rect";
        size: "resizable";
        linewidth : "1"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 6
rule
     gtrule1: $ forall x/Class (x graphtype CLASS_TP_GT) $
end

STRING_TP_GT in Class,JavaGraphicalType with
property
	bgcolor : "250,250,250"; 
	textcolor : "0,0,0";
	linecolor : "100,100,100";
	shape : "Rect";
        fontstyle: "italic";
        fontsize: "11";
        size: "wrap";
        labellength : "1000";
        linewidth : "0.3"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 7
rule
     gtrule1: $ forall x/String (x graphtype STRING_TP_GT) $
end

VALUE_TP_GT in Class,JavaGraphicalType with
property
	bgcolor : "250,250,250"; 
	textcolor : "0,0,0";
	linecolor : "100,100,100";
	shape : "Rect";
        fontstyle: "italic";
        fontsize: "11";
        linewidth : "0.3"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 7
rule
     gtrule1: $ forall x/Integer (x graphtype VALUE_TP_GT) $;
     gtrule2: $ forall x/Real (x graphtype VALUE_TP_GT) $
end

ASSERTION_TP_GT in Class,JavaGraphicalType with
property
	bgcolor : "250,250,250";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "Rect";
        size: "wrap";
        fontstyle: "italic";
        fontsize: "11";
        labellength : "1000";
        linewidth : "1"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 8
rule
     gtrule1: $ forall x/MSFOLassertion (x graphtype ASSERTION_TP_GT) $
end

QUERYCLASS_TP_GT in Class,JavaGraphicalType with
property
	bgcolor : "255,245,245"; 
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "Rect";
        size: "resizable";
        linewidth : "1";
        fontstyle: "italic"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 8
rule
     gtrule1: $ forall x/QueryClass (x graphtype QUERYCLASS_TP_GT) $
end


{* new function concatl, concatl4, concatl6 *}

Function concatl isA Label with
parameter
	s1 : Label;
	s2 : Label
comment
	c : "Appends the labels2 to the label s1; result is a Label, i.e. not necessarily an object name"
end

Function concatl4 isA Label with
parameter
	s1 : Label;
	s2 : Label;
	s3 : Label;
	s4 : Label
comment
	c : "Concats the labels s1,s2,s3,s4"
end

Function concatl6 isA Label with
parameter
	s1 : Label;
	s2 : Label;
	s3 : Label;
	s4 : Label;
	s5 : Label;
	s6 : Label
comment
	c : "Concats the labels s1,s2,s3,s4,s5,s6"
end


{* new function resultOf, which allows to derive labels that have been composed by calling a generic query class with a certain answer format *}

HiddenLabel isA HiddenObject,Label end 

resultOf in Function isA HiddenLabel with
  parameter
   a1: GenericQueryClass;
   a2: Proposition;
   a3: AnswerFormat
end

{* function signatures originally defined in strings.swi.lpi are now predefined in ConceptBase; issue #50 *}
toString in Function isA String with
   parameter obj: Proposition
   comment c: "convert the label of obj into a string with double quotes around it"
end

length in Function isA Integer with
  parameter obj: Proposition
  comment c: "compute the number of characters of the label of obj. The double quotes of strings are not counted."
end

isLike in Function isA Boolean with
  parameter
   label: Proposition;
   pattern: String
 comment c: "check wether the label (first parameter) is matching a pattern (2nd parameter); Use wildcard * in the pattern"
end

GlobalVariable end
currentPalette in GlobalVariable end

valueOf in Function isA Proposition with
  parameter
   variable: GlobalVariable 
end

{* new version to hide isolated instances of CB_User *}

IsolatedCB_User in HiddenObject,QueryClass isA CB_User with
  constraint
    isolated: $ not exists a/Attribute From(a,this) or To(a,this) $
end

DoNotSave_2 in HiddenObject,QueryClass isA Proposition with  
  constraint
    cnts : $ (~this in HiddenObject) or
             ((~this in MSFOLassertion) and not (~this in QueryClass)) or
             (~this in BDMRuleCheck) or
             (~this in BDMConstraintCheck) or (~this in Proposition!deducedBy) or
             (~this in Proposition!applyConstraintIfInsert) or (~this in Proposition!applyConstraintIfDelete) or
             (~this in ECAassertion) or
             ( (~this in IsA) and exists a/Attribute From(~this,a) and 
             ((a in QueryClass!retrieved_attribute) or (a in View!inherited_attribute))) or
             (~this in IsolatedValue[String/type]) or
             (~this in IsolatedValue[Integer/type]) or
             (~this in IsolatedValue[Real/type]) or
             (~this in IsolatedCB_User) or
             :(~this in TransactionTime): and not (exists z/Proposition (~this attribute z))
             $
end

