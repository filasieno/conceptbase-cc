= Use Graphical Types

Verified independently via:

```bash
nix build .#checks.x86_64-linux.use-graphical-types
```

== Input

=== `Dark Telos Palette/DarkTelosPalette.sml.txt`

```telos
{*
This file is governed by the Creative Commons license
   attributeion-NonCommercial 4.0 Unported
   http://creativecommons.org/licenses/by-nc/4.0/
   http://creativecommons.org/licenses/by-nc/4.0/legalcode

Extended licenses, in particular commercial licenses, can be obtained from the
author of the source code.
Any re-distribution as source code must acknowledge the original author of this file.
*}


{*
* File: DarkTelosPalette.sml.txt
* Author: Manfred Jeusfeld
* Created: 2024-10-01
* -------------------------------------------------------
* This is the dark variant of TelosPalette. Can be used in conjunction to the dark mode of CBGraph and CBIva.
* Should work even with older versions of ConceptBase from 2020 onwards. Recommended is ConceptBase 8.5
* or later.
*
*}

DarkTelosPalette in Class,JavaGraphicalPalette isA XBridgePalette with  
  comment
    description: "This is the dark variant of TelosPalette. Can be used in conjunction to the dark mode of CBGraph and CBIva"
  contains,defaultIndividual
    tp1 : INDIVIDUAL_TP_DARK_GT
  contains,defaultLink
    tp2 : ATTR_TP_DARK_GT
  contains,implicitIsA
    tp3 : ISADEDUCED_TP_DARK_GT
  contains,implicitInstanceOf
    tp4 : INSTOFDEDUCED_TP_DARK_GT
  contains,implicitattributee
    tp5 : ATTRDEDUCED_TP_DARK_GT
  contains
    tp6 : CLASS_TP_DARK_GT;
    tp7 : QUERYCLASS_TP_DARK_GT;
    tp8 : INSTOF_TP_DARK_GT;
    tp9: ISA_TP_DARK_GT;
    tp10: STRING_TP_DARK_GT;
    tp11: VALUE_TP_DARK_GT;
    tp12: ASSERTION_TP_DARK_GT
  palproperty
    bgcolor: "50,50,50"
end 



INSTOF_TP_DARK_GT in JavaGraphicalType,Class with 
  attribute,property
    bgcolor : "0,200,0";
    textcolor : "230,230,230";
    edgecolor : "0,200,0";
    edgewidth : "2";
    edgeheadshape: "Caret";
    edgestyle : "ldashed";
    label : ""
  attribute,implementedBy
     implBy : "i5.cb.graph.cbeditor.CBLink"
  attribute,priority
     p : 6
  rule
     gtrule1: $ forall a/InstanceOf (a graphtype INSTOF_TP_DARK_GT) $
end 

INSTOFDEDUCED_TP_DARK_GT in JavaGraphicalType,Class with 
  attribute,property
    bgcolor : "0,200,0";
    textcolor : "230,230,230";
    edgecolor : "0,200,0";
    edgewidth : "1";
    edgeheadshape: "Caret";
    edgestyle : "dashed";
    label : ""
  attribute,implementedBy
     implBy : "i5.cb.graph.cbeditor.CBLink"
  attribute,priority
     p : 7
end  

ISA_TP_DARK_GT in JavaGraphicalType,Class with 
  attribute,property
    bgcolor : "0,150,255";
    textcolor : "230,230,230";
    edgecolor : "0,150,255";
    edgeheadcolor : "50,50,50";
    edgeheadshape : "Arrow";
    edgewidth : "2";
    label : ""
  attribute,implementedBy
     implBy : "i5.cb.graph.cbeditor.CBLink"
  attribute,priority
     p : 6
  rule
     gtrule1: $ forall a/IsA (a graphtype ISA_TP_DARK_GT) $
end 

ISADEDUCED_TP_DARK_GT in JavaGraphicalType,Class with 
  attribute,property
    bgcolor : "0,150,255";
    textcolor : "230,230,230";
    edgecolor : "0,150,255";
    edgeheadcolor : "50,50,50";
    edgewidth : "1";
    edgestyle : "dashed";
    label : "";
    edgeheadshape: "Arrow"
  attribute,implementedBy
     implBy : "i5.cb.graph.cbeditor.CBLink"
  attribute,priority
     p : 7
end  


ATTR_TP_DARK_GT in Class,JavaGraphicalType with  
  property
    textcolor : "230,230,230";
    edgecolor : "230,230,230";
    edgewidth : "2";
    fontsize: "10";
    bgcolor : "50,50,50,240"  {* white, slighlty transparent *}
  implementedBy
    implBy : "i5.cb.graph.cbeditor.CBLink"
  priority
    p : 5
  rule
     gtrule1: $ forall x/Proposition!attribute (x graphtype ATTR_TP_DARK_GT) $
end 

ATTRDEDUCED_TP_DARK_GT in JavaGraphicalType with  
  property
    textcolor : "230,230,230";
    edgecolor : "230,230,230";
    edgewidth : "2";
    edgestyle : "dashed";
    fontsize: "10";
    bgcolor : "50,50,50,240"  {* white, slighlty transparent *}
  implementedBy
    implBy : "i5.cb.graph.cbeditor.CBLink"
  priority
    p : 7
end 


INDIVIDUAL_TP_DARK_GT in Class,JavaGraphicalType with
property
	bgcolor : "50,50,40"; 
	textcolor : "230,230,230";
	linecolor : "230,230,230";
	shape : "Rect";
        size: "resizable";
        linewidth : "1"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 5
rule
     gtrule1: $ forall x/Individual (x graphtype INDIVIDUAL_TP_DARK_GT) $
end


CLASS_TP_DARK_GT in Class,JavaGraphicalType with
property
	bgcolor : "100,100,100"; 
	textcolor : "230,230,230";
	linecolor : "230,230,230";
	shape : "Rect";
        size: "resizable";
        linewidth : "1"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 6
rule
     gtrule1: $ forall x/Class (x graphtype CLASS_TP_DARK_GT) $
end

STRING_TP_DARK_GT in Class,JavaGraphicalType with
property
	bgcolor : "110,110,110"; 
	textcolor : "230,230,230";
	linecolor : "200,200,200";
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
     gtrule1: $ forall x/String (x graphtype STRING_TP_DARK_GT) $
end

VALUE_TP_DARK_GT in Class,JavaGraphicalType with
property
	bgcolor : "50,50,50"; 
	textcolor : "230,230,230";
	linecolor : "190,190,190";
	shape : "Rect";
        fontstyle: "italic";
        fontsize: "11";
        linewidth : "0.3"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 7
rule
     gtrule1: $ forall x/Integer (x graphtype VALUE_TP_DARK_GT) $;
     gtrule2: $ forall x/Real (x graphtype VALUE_TP_DARK_GT) $
end

ASSERTION_TP_DARK_GT in Class,JavaGraphicalType with
property
	bgcolor : "50,50,50";
	textcolor : "230,230,230";
	linecolor : "230,230,230";
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
     gtrule1: $ forall x/MSFOLassertion (x graphtype ASSERTION_TP_DARK_GT) $
end

QUERYCLASS_TP_DARK_GT in Class,JavaGraphicalType with
property
	bgcolor : "50,80,50"; 
	textcolor : "230,230,230";
	linecolor : "230,230,230";
	shape : "Rect";
        size: "resizable";
        linewidth : "1";
        fontstyle: "italic"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 8
rule
     gtrule1: $ forall x/QueryClass (x graphtype QUERYCLASS_TP_DARK_GT) $
end





```

=== `Example 1_ ERD/00-XPalette.sml.txt`

```telos
{
*
* File: 00-XPalette.sml
* Author: Manfred Jeusfeld
* Creation: 3-May-2013
* ----------------------------------------------------------------------
* 
* Extensible graphical Palette; makes life easier in dealing with ConceptBase
* graphical types
* Define additional graphical types by definining a subclass of XPalette and
* then add the new graphical types. XPalette will then make sure that 
* required builtin graphical types are automatically added.
}



XPalette in Class,JavaGraphicalPalette with  
  contains,defaultIndividual
    xx1 : DefaultIndividualGT
  contains,defaultLink
    xx2 : DefaultLinkGT
  contains,implicitIsA
    xx3 : ImplicitIsAGT
  contains,implicitInstanceOf
    xx4 : ImplicitInstanceOfGT
  contains,implicitattributee
    xx5 : ImplicitattributeeGT
  contains
    xx6 : DefaultIsAGT;
    xx7 : DefaultInstanceOfGT;
    xx8 : DefaultattributeeGT;
    xx9 : MetametaGT;
    xx10 : SimpleClassGT;
    xx11 : MetaClassGT;
    xx12 : ClassGT;
    xx13 : QueryClassGT
  rule
    inheritGTs: $ forall gt/JavaGraphicalType pal/JavaGraphicalPalette
                      (pal isA XPalette) and
                      (DefaultJavaPalette contains gt)
                  ==> (pal contains gt) $;
    inheritDef1: $ forall gt/JavaGraphicalType pal/JavaGraphicalPalette
                      (pal isA XPalette) and
                      (DefaultJavaPalette defaultIndividual gt)
                  ==> (pal defaultIndividual gt) $;
    inheritDef2: $ forall gt/JavaGraphicalType pal/JavaGraphicalPalette
                      (pal isA XPalette) and
                      (DefaultJavaPalette defaultLink gt)
                  ==> (pal defaultLink gt) $;
    inheritDef3: $ forall gt/JavaGraphicalType pal/JavaGraphicalPalette
                      (pal isA XPalette) and
                      (DefaultJavaPalette implicitIsA gt)
                  ==> (pal implicitIsA gt) $;
    inheritDef4: $ forall gt/JavaGraphicalType pal/JavaGraphicalPalette
                      (pal isA XPalette) and
                      (DefaultJavaPalette implicitInstanceOf gt)
                  ==> (pal implicitInstanceOf gt) $;
    inheritDef5: $ forall gt/JavaGraphicalType pal/JavaGraphicalPalette
                      (pal isA XPalette) and
                      (DefaultJavaPalette implicitattributee gt)
                  ==> (pal implicitattributee gt) $
end 



```

=== `Example 1_ ERD/01-ERD.sml.txt`

```telos
{
*
* File: 01-ERD.sml
* Author: Manfred Jeusfeld
* Creation: 3-May-2013
* ----------------------------------------------------------------------
* 
* ERD Model with graphical types
* load 00-XPalette.sml in advance
}


{* super-simple meta classes for ERDs *}


EntityType in Class with
  attribute
    attr: Domain
end

RelationshipType in Class with
  attribute
    role: EntityType
end

Domain end

Integer in Domain end
String in Domain end



{* a simple example ERD model *}


Course in EntityType
end 


Student in EntityType with
  attr
    name: String;
    studid: Integer
end

enrolls in RelationshipType with
  role
     course: Course;
     student: Student
end




{* a new palette with additional graphical types; rest is inherited from XPalette *}

ERD_Palette in JavaGraphicalPalette isA XPalette with
  contains
    gt1: EntityTypeGT;
    gt2: RelationshipTypeGT;
    gt3: DomainGT;
    gt4: RoleLinkGT;
    gt5: AttrLinkGT
end



{* graphical type for entity types; the properties define the graphical style for
   entity types; the implementedBy tag specifies that it will be regarded as a 'node';
   the priority is used in case that an object has several graphical types, the one with the
   highest priority wins;
   the rule assigns the graphical type to all instances of EntityType
*}

EntityTypeGT in Class,JavaGraphicalType with
  property
	bgcolor : "255,255,155";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.Rect";
	fontstyle : "italic"
  implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 20
  rule
     gtrule: $ forall E/EntityType (E graphtype EntityTypeGT) $

end


Class RelationshipTypeGT in JavaGraphicalType with
  property
      bgcolor : "255,255,155";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.Diamond";
	fontstyle : "italic"
  implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 20
  rule
   gtrule: $ forall R/RelationshipType (R graphtype RelationshipTypeGT) $
end

DomainGT in Class,JavaGraphicalType with
  property
	bgcolor : "200,200,200";
	textcolor : "0,0,0";
        fontsize: "9";  
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.Ellipse"
  implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
  priority
    pr : 20
  rule
     gtrule: $ forall D/Domain (D graphtype DomainGT) $

end

RoleLinkGT in JavaGraphicalType,Class with 
  attribute,property
     textcolor : "0,0,0";
     edgecolor : "120,120,120";
     edgewidth : "2";
     label : "";           {* force empty label for role links *}
     bgcolor : "255,150,150"
  attribute,implementedBy
     implBy : "i5.cb.graph.cbeditor.CBLink"
  attribute,priority
     p : 8
  rule
     gtrule1: $ forall r/RelationshipType!role (r graphtype RoleLinkGT) $
end 

AttrLinkGT in JavaGraphicalType,Class with 
  attribute,property
     textcolor : "0,0,0";
     edgecolor : "120,120,120";
     fontsize: "8";  
     edgewidth : "1";
     bgcolor : "200,200,200"
  attribute,implementedBy
     implBy : "i5.cb.graph.cbeditor.CBLink"
  attribute,priority
     p : 8
  rule
     gtrule1: $ forall a/EntityType!attr (a graphtype AttrLinkGT) $
end 






```

=== `Example 2_ Petri nets/01-PetriNetSimu.sml.txt`

```telos
{
* File: 01-PetriNetSimu.sml
* Author: Manfred Jeusfeld
* Created: 26-Oct-2005/M.Jeusfeld (29-Nov-2012/M.Jeusfeld)
* ------------------------------------------------------
* Executable variant for petri nets. Allows to fire specified
* transactions. An example on how to fire a transition is at the end of this
* file. You can inspect the current state of the petri net by the query
* ReportState.
* 
* This requires ConceptBase 7.4 released after July 2012!
}

{*
This file is governed by the Creative Commons license
   attributeion-NonCommercial 3.0 Unported
   http://creativecommons.org/licenses/by-nc/3.0/
   http://creativecommons.org/licenses/by-nc/3.0/legalcode

Extended licenses, in particular commercial licenses, can be obtained from the
author of the source code.
Any re-distribution as source code must acknowledge the original author of this file.
*}


Place with
  attribute
   sendsToken: Transition;
   marks: Integer {* defines markings *}
end

Transition with
  attribute
    producesToken : Place
end

M in Function isA Integer with
  parameter p: Place
  constraint c1: $ (p marks this) $
end

Input in GenericQueryClass isA Place with
  parameter t: Transition
  constraint ci: $ (this sendsToken t) $
end


{* A transition is enabled if the number of Tokens *}
{* at all its input places is greater than zero.   *}

Enabled in QueryClass isA Transition with
  constraint c: $ forall p/Input[this] (M(p) > 0) $
end


{* A connected place is a place that is linked to a given transition *}
{* either by sending a token to it or receiving a token from it.     *}
{* A connected place is affected by firing a transition.             *}

ConnectedPlace in GenericQueryClass isA Place with
  parameter trans: Transition
  constraint c: $ (this sendsToken trans) or (trans producesToken this) $
end

inFlow in GenericQueryClass isA Transition!producesToken with
  parameter place: Place; trans: Transition
  constraint c1: $ From(this,trans) and To(this,place) $
end

outFlow in GenericQueryClass isA Place!sendsToken with
  parameter place: Place; trans: Transition
  constraint c1: $ From(this,place) and To(this,trans) $
end

{* Net effect of a transition t on a place p = incidence matrix.   *}
{* = number of links from t to p minus number of links from p to t *}
IM in Function isA Integer with
  parameter p: Place; t: Transition
  constraint c1: $ (this = #inFlow[p,t] - #outFlow[p,t]) $
end


{* Artificial class to store firings of transitions. Needed to simulate *}
{* the execution of a petri net.                                        *}

FireTransition with
  attribute transition: Transition
end

{* This active rules encodes the semantics of firing a transition. *}
{* When firing a transition tr, the IF part of the ECArule         *}
{* determines for any connected place pl the new token fill.       *}
{* The DO part will then update the token fill of the place pl     *}
{* accordingly. The IF part will be evaluated for all connected    *}
{* places.                                                         *}
{* Note that the net effect can be negative or zero or positive.   *}
{* The IFNEW clause indicates that the condition is                *}
{* evaluated against the newest database state, in contrast to     *}
{* being evaluated against the database state immediately before   *}
{* the current transaction. This allow to model multiple           *}
{* of UpdateConnectedPlaces in the same TELL transaction.          *}

ECArule UpdateConnectedPlaces with
  mode m: Deferred
  ecarule
    er : $ fire/FireTransition t/Transition p/Place m/Integer
           ON Tell (fire transition t)
           IFNEW (t in Enabled) and (p in ConnectedPlace[t]) and
           (m = M(p)+IM(p,t))
           DO Retell (p marks m) $
end




{* This query reports the current state of a petri net. *}

ReportState in QueryClass isA Place with
  retrieved_attribute
    marks: Integer
end

AnswerFormat StateFormat with
   forQuery q: ReportState
   order o: ascending
   orderBy ob: "this"
   head h: 
"Place   #Tokens
-----------------
"
  pattern p:
"{this}   {this.marks}
"
  tail t:
"-----------------
"
end






```

=== `Example 2_ Petri nets/02-PN-GTs.sml.txt`

```telos
{
* File: 02-PN-GTs.sml
* Author: Manfred Jeusfeld
* Created: 26-Oct-2005/M.Jeusfeld (28-Oct-2014/M.Jeusfeld)
* ------------------------------------------------------
* Graphical types for displaying petri nets
* 
* This requires ConceptBase 7.7 released after October 2014!
}

{*
This file is governed by the Creative Commons license
   attributeion-NonCommercial 3.0 Unported
   http://creativecommons.org/licenses/by-nc/3.0/
   http://creativecommons.org/licenses/by-nc/3.0/legalcode

Extended licenses, in particular commercial licenses, can be obtained from the
author of the source code.
Any re-distribution as source code must acknowledge the original author of this file.
*}



{* graphical types that take care that the petri net is displayed *}
{* in the usual notation in the graph editor of ConceptBase.      *}


Class Petrinet_Palette in JavaGraphicalPalette with
contains,defaultIndividual
	c1 : DefaultIndividualGT
contains,defaultLink
	c2 : DefaultLinkGT
implicitIsA, contains
    c3 : ImplicitIsAGT
implicitInstanceOf, contains
    c4 : ImplicitInstanceOfGT
implicitattributee, contains
    c5 : ImplicitattributeeGT
contains
    c7: Transition_GT;
    c8: Enabled_GT;
    c10: Place0_GT;
    c11: Place1_GT;
    c12: Place2_GT;
    c13: Place3_GT;
    c14: PlaceN_GT;
    c19: DefaultattributeeGT;
    c20: DefaultIsAGT;
    c21: DefaultInstanceOfGT;
    c22: QueryClassGT;
    c23: TokenPassageGT;
    c24: marksGT;
    c25: flowToEnabledGT;
    c26: triggerFromEnabledGT
end




Transition_GT in Class,JavaGraphicalType with
property
	textcolor : "0,0,0";
        linecolor : "0,0,0";
        linewidth: "2";
        bgcolor : "255,255,255";
	shape : "i5.cb.graph.shapes.Rect";
        size: "resizable";
        align : "center";
        image: "http://conceptbase.sourceforge.net/CBICONS/white70x20.png";
        textposition: "center"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 22
rule
     gtrule: $ forall x/Transition (x graphtype Transition_GT) $
end

Enabled_GT in Class,JavaGraphicalType with
property
	textcolor : "0,0,0";
        linecolor : "0,0,0";
        linewidth: "2";
        bgcolor : "255,255,255";
	shape : "i5.cb.graph.shapes.Rect";
        size: "resizable";
        align : "center";
        image: "http://conceptbase.sourceforge.net/CBICONS/greengrad70x20.png";
        textposition: "center"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 23
rule
     gtrule: $ forall x/Enabled (x graphtype Enabled_GT) $
end         

               
Place0_GT in Class,JavaGraphicalType with
property
	textcolor : "0,0,0";
        linecolor : "0,0,0";
        linewidth: "2";
	shape : "i5.cb.graph.shapes.Circle";
        fontsize: "9";
        size: "40x40";
        bgcolor : "255,255,255";
        align : "center";
        image: "http://conceptbase.sourceforge.net/CBICONS/tokens0.png";
        textposition: "bottom"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 27
rule
     gtrule: $ forall x/Place (x graphtype Place0_GT) $
end



Place1_GT in Class,JavaGraphicalType with
property
	textcolor : "0,0,0";
        linecolor : "0,0,0";
        linewidth: "2";
	shape : "i5.cb.graph.shapes.Circle";
        fontsize: "9";
        size: "40x40";
        bgcolor : "255,255,255";
        align : "bottom";
        image: "http://conceptbase.sourceforge.net/CBICONS/tokens1.png";
        textposition: "bottom"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 28
rule
     gtrule: $ forall x/Place n/Integer (x marks n) and (n = 1) ==>
               (x graphtype Place1_GT) $
end


Place2_GT in Class,JavaGraphicalType with
property
	textcolor : "0,0,0";
        linecolor : "0,0,0";
        linewidth: "2";
	shape : "i5.cb.graph.shapes.Circle";
        fontsize: "9";
        size: "40x40";
        bgcolor : "255,255,255";
        align : "center";
        image: "http://conceptbase.sourceforge.net/CBICONS/tokens2.png";
        textposition: "bottom"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 28
rule
     gtrule: $ forall x/Place n/Integer (x marks n) and (n = 2) ==>
               (x graphtype Place2_GT) $
end


Place3_GT in Class,JavaGraphicalType with
property
	textcolor : "0,0,0";
        linecolor : "0,0,0";
        linewidth: "2";
	shape : "i5.cb.graph.shapes.Circle";
        fontsize: "9";
        size: "40x40";
        bgcolor : "255,255,255";
        align : "center";
        image: "http://conceptbase.sourceforge.net/CBICONS/tokens3.png";
        textposition: "bottom"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 28
rule
     gtrule: $ forall x/Place n/Integer (x marks n) and (n = 3) ==>
               (x graphtype Place3_GT) $
end


PlaceN_GT in Class,JavaGraphicalType with
property
	textcolor : "0,0,0";
        linecolor : "0,0,0";
        linewidth: "2";
	shape : "i5.cb.graph.shapes.Circle";
        fontsize: "9";
        size: "40x40";
        bgcolor : "255,255,255";
        align : "center";
        image: "http://conceptbase.sourceforge.net/CBICONS/tokensN.png";
        textposition: "bottom"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 28
rule
     gtrule: $ forall x/Place n/Integer (x marks n) and (n > 3) ==>
               (x graphtype PlaceN_GT) $
end


TokenPassageGT in JavaGraphicalType,Class with 
  attribute,property
     textcolor : "0,0,0";
     edgecolor : "120,120,120";
     edgewidth : "1";
     label : "";
     bgcolor : "220,120,120" 
  attribute,implementedBy
     implBy : "i5.cb.graph.cbeditor.CBLink"
  attribute,priority
     p : 3
  rule
     gtrule1: $ forall a/Place!sendsToken (a graphtype TokenPassageGT) $;
     gtrule2: $ forall a/Transition!producesToken (a graphtype TokenPassageGT) $
end   

flowToEnabledGT in JavaGraphicalType,Class with 
  attribute,property
     textcolor : "0,0,0";
     edgecolor : "120,190,120";
     edgewidth : "2";
     label : "";
     bgcolor : "220,120,120" 
  attribute,implementedBy
     implBy : "i5.cb.graph.cbeditor.CBLink"
  attribute,priority
     p : 10
  rule
     gtrule1: $ forall a/Place!sendsToken t/Enabled To(a,t)  ==> (a graphtype flowToEnabledGT) $
end  

triggerFromEnabledGT in JavaGraphicalType,Class with 
  attribute,property
     textcolor : "0,0,0";
     edgecolor : "190,120,120";
     edgewidth : "2";
     label : "";
     bgcolor : "220,120,120" 
  attribute,implementedBy
     implBy : "i5.cb.graph.cbeditor.CBLink"
  attribute,priority
     p : 10
  rule
     gtrule1: $ forall a/Transition!producesToken t/Enabled From(a,t)  ==> (a graphtype triggerFromEnabledGT) $
end 

marksGT in JavaGraphicalType,Class with 
  attribute,property
     textcolor : "0,0,0";
     linecolor : "210,210,210";
     edgecolor : "210,210,210";
     edgewidth : "3";
     label : "";
     bgcolor : "255,150,150"
  attribute,implementedBy
     implBy : "i5.cb.graph.cbeditor.CBLink"
  attribute,priority
     p : 3
  rule
     gtrule1: $ forall a/Place!marks (a graphtype marksGT) $
end                       


```

=== `Example 2_ Petri nets/03-trafficlights.sml.txt`

```telos
{* -------------------------------------------------- *}

{* Petri net for traffic lights. Taken from slides of *}
{* Wil van der Aalst.                                 *}

red1 in Place with
  sendsToken
    t1: rg1
  marks
    tf: 1
end

yellow1 in Place with
  sendsToken
    t1: yr1
  marks
    tf: 0
end

green1 in Place with
  sendsToken
    t1: gy1
  marks
    tf: 0
end

safe1 in Place with
  sendsToken
    t1: rg1
  marks
    tf: 1
end

yr1 in Transition with
  producesToken
    p1: red1;
    p2: safe2
end

rg1 in Transition with
  producesToken
    p1: green1
end

gy1 in Transition with
  producesToken
    p1: yellow1
end



red2 in Place with
  sendsToken
    t1: rg2
  marks
    tf: 1
end

yellow2 in Place with
  sendsToken
    t1: yr2
  marks
    tf: 0
end

green2 in Place with
  sendsToken
    t1: gy2
  marks
    tf: 0
end

safe2 in Place with
  sendsToken
    t1: rg2
  marks
    tf: 0
end

yr2 in Transition with
  producesToken
    p1: red2;
    p2: safe1
end

rg2 in Transition with
  producesToken
    p1: green2
end

gy2 in Transition with
  producesToken
    p1: yellow2
end




{* -------------------------------------------------------- *}

{* You can fire a specified transition by telling instances of
   FireTransition. You can either tell the individual firings
   one by one or several consecutive firings in the same 
   TELL transaction. You can even tell all of them in a single
   TELL transaction.

fire1 in FireTransition with
  transition t1: rg1
end

fire2 in FireTransition with
  transition t1: gy1
end

fire3 in FireTransition with
  transition t1: yr1
end

fire4 in FireTransition with
  transition t1: rg2
end


*}


```

=== `Example 3_ Click actions/01-PetriNetSimu-Ask.sml.txt`

```telos
{
* File: PetriNetSimu-Ask.sml
* Author: Manfred Jeusfeld
* Created: 18-May-2006/M.Jeusfeld (6-Nov-2014/M.Jeusfeld)
* ------------------------------------------------------
* 
* This variant allows to trigger enabled transitions by just calling
* the query FireTransition.
* 
* This requires ConceptBase 7.7 released Nov 2014 or later!
}


{*
This file is governed by the Creative Commons license
   attributeion-NonCommercial 3.0 Unported
   http://creativecommons.org/licenses/by-nc/3.0/
   http://creativecommons.org/licenses/by-nc/3.0/legalcode

Extended licenses, in particular commercial licenses, can be obtained from the
author of the source code.
Any re-distribution as source code must acknowledge the original author of this file.
*}


Place with
  attribute
   sendsToken: Transition;
   marks: Integer {* defines markings *}
end

Transition with
  attribute
    producesToken : Place
end

M in Function isA Integer with
  parameter p: Place
  constraint c1: $ (p marks this) $
end

Input in GenericQueryClass isA Place with
  parameter t: Transition
  constraint ci: $ (this sendsToken t) $
end


{* A transition is enabled if the number of Tokens *}
{* at all its input places is greater than zero.   *}

Enabled in QueryClass isA Transition with
  constraint c: $ forall p/Input[this] (M(p) > 0) $
end


{* A connected place is a place that is linked to a given transition *}
{* either by sending a token to it or receiving a token from it.     *}
{* A connected place is affected by firing a transition.             *}

ConnectedPlace in GenericQueryClass isA Place with
  parameter trans: Transition
  constraint c: $ (this sendsToken trans) or (trans producesToken this) $
end

inFlow in GenericQueryClass isA Transition!producesToken with
  parameter place: Place; trans: Transition
  constraint c1: $ From(this,trans) and To(this,place) $
end

outFlow in GenericQueryClass isA Place!sendsToken with
  parameter place: Place; trans: Transition
  constraint c1: $ From(this,place) and To(this,trans) $
end

{* Net effect of a transition t on a place p = incidence matrix.   *}
{* = number of links from t to p minus number of links from p to t *}
IM in Function isA Integer with
  parameter p: Place; t: Transition
  constraint c1: $ (this = #inFlow[p,t] - #outFlow[p,t]) $
end


fireTransition in GenericQueryClass isA YesClass with
 parameter
    transition: Enabled
 constraint
    c1: $ (this=yes) $
end

{* This active rules encodes the semantics of firing a transition. *}
{* When firing a transition tr, the IF part of the ECArule         *}
{* determines for any connected place pl the new token fill.       *}
{* The DO part will then update the token fill of the place pl     *}
{* accordingly. The IF part will be evaluated for all connected    *}
{* places.                                                         *}
{* Note that the net effect can be negative or zero or positive.   *}
{* The IFNEW clause indicates that the condition is                *}
{* evaluated against the newest database state, in contrast to     *}
{* being evaluated against the database state immediately before   *}
{* the current transaction. This allow to model multiple           *}
{* of UpdateConnectedPlaces in the same TELL transaction.          *}

ECArule UpdateConnectedPlaces with
  mode m: Deferred
  ecarule
    er : $ t/Transition p/Place m/Integer
           ON Ask fireTransition[t]
           IFNEW (t in Enabled) and (p in ConnectedPlace[t]) and
           (m = M(p)+IM(p,t))
           DO Retell (p marks m) $
end



{* this fires all enabled transitions, one after the other; some can become non-enabled *}
{* by a preceding firing;                                                               *}
ECArule fire in QueryClass isA YesClass with
  mode m: Deferred
  ecarule
    er : $ t/Transition p/Place m/Integer
           ON Ask fire
           IFNEW (t in Enabled) 
           DO Raise fireTransition[t]  $
end



{* This query reports the current state of a petri net. *}

ReportState in QueryClass isA Place with
  retrieved_attribute
    marks: Integer
end

AnswerFormat StateFormat with
   forQuery q: ReportState
   order o: ascending
   orderBy ob: "this"
   head h: 
"Place   #Tokens
-----------------
"
  pattern p:
"{this}   {this.marks}
"
  tail t:
"-----------------
"
end






```

=== `Example 3_ Click actions/02-PN-GTs-Simpler.sml.txt`

```telos
{
* File: 02-PN-GTs-Simpler.sml
* Author: Manfred Jeusfeld
* Created: 2017-06-20/M.Jeusfeld (2017-06-20/M.Jeusfeld)
* ------------------------------------------------------
* Graphical types for displaying petri nets
* Like 02-PN-GTs.sml but simpler using gproperty
* 
* This requires ConceptBase 8.0 released after June 20, 2017!
* DOES NOT YET UPDATE after clicking an enabled transition
}

{*
This file is governed by the Creative Commons license
   attributeion-NonCommercial 3.0 Unported
   http://creativecommons.org/licenses/by-nc/3.0/
   http://creativecommons.org/licenses/by-nc/3.0/legalcode

Extended licenses, in particular commercial licenses, can be obtained from the
author of the source code.
Any re-distribution as source code must acknowledge the original author of this file.
*}

{* XPalette embeds user defined palettes into the deault palette *}
XPalette in Class,JavaGraphicalPalette with  
  contains,defaultIndividual
    xx1 : DefaultIndividualGT
  contains,defaultLink
    xx2 : DefaultLinkGT
  contains,implicitIsA
    xx3 : ImplicitIsAGT
  contains,implicitInstanceOf
    xx4 : ImplicitInstanceOfGT
  contains,implicitattributee
    xx5 : ImplicitattributeeGT
  contains
    xx6 : DefaultIsAGT;
    xx7 : DefaultInstanceOfGT;
    xx8 : DefaultattributeeGT;
    xx9 : MetametaGT;
    xx10 : SimpleClassGT;
    xx11 : MetaClassGT;
    xx12 : ClassGT;
    xx13 : QueryClassGT
  rule
    inheritGTs: $ forall gt/JavaGraphicalType pal/JavaGraphicalPalette
                      (pal isA XPalette) and
                      (DefaultJavaPalette contains gt)
                  ==> (pal contains gt) $;
    inheritDef1: $ forall gt/JavaGraphicalType pal/JavaGraphicalPalette
                      (pal isA XPalette) and
                      (DefaultJavaPalette defaultIndividual gt)
                  ==> (pal defaultIndividual gt) $;
    inheritDef2: $ forall gt/JavaGraphicalType pal/JavaGraphicalPalette
                      (pal isA XPalette) and
                      (DefaultJavaPalette defaultLink gt)
                  ==> (pal defaultLink gt) $;
    inheritDef3: $ forall gt/JavaGraphicalType pal/JavaGraphicalPalette
                      (pal isA XPalette) and
                      (DefaultJavaPalette implicitIsA gt)
                  ==> (pal implicitIsA gt) $;
    inheritDef4: $ forall gt/JavaGraphicalType pal/JavaGraphicalPalette
                      (pal isA XPalette) and
                      (DefaultJavaPalette implicitInstanceOf gt)
                  ==> (pal implicitInstanceOf gt) $;
    inheritDef5: $ forall gt/JavaGraphicalType pal/JavaGraphicalPalette
                      (pal isA XPalette) and
                      (DefaultJavaPalette implicitattributee gt)
                  ==> (pal implicitattributee gt) $
end 


{* graphical types that take care that the petri net is displayed *}
{* in the usual notation in the graph editor of ConceptBase.      *}


SimplePetrinetPalette in Class,JavaGraphicalPalette isA XPalette with
contains
    pn1: Transition_GT;
    pn2: Enabled_GT;
    pn3: Place_GT;
    pn4: TokenPassageGT
rule
    rlabel1: $ forall p/Place (p marks 0) ==> (p gproperty/label " ") $;
    rlabel2: $ forall p/Place n/Integer (p marks n) and (n > 0) ==> (p gproperty/label n) $
end


Transition_GT in Class,JavaGraphicalType with
property
	textcolor : "0,0,0";
        linecolor : "0,0,0";
        linewidth: "1";
        bgcolor : "240,240,240";
	fontstyle : "italic";
        shape : "Rect"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 22
rule
     gtrule: $ forall x/Transition (x graphtype Transition_GT) $
end

Enabled_GT in Class,JavaGraphicalType with
property
        clickaction: "fireTransition";
	textcolor : "0,0,0";
        linecolor : "0,0,0";
        linewidth: "1";
        bgcolor : "140,255,140";  {* green *}
	fontstyle : "italic";
        shape : "Rect"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 23
rule
     gtrule: $ forall x/Enabled (x graphtype Enabled_GT) $
end         
                  
Place_GT in Class,JavaGraphicalType with
property
	textcolor : "0,0,0";
	linecolor : "0,0,0";
        linewidth: "1";
        bgcolor : "240,240,240";
	fontstyle : "italic";
        shape : "Circle";
        size: "18x18";
        label: " "
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 27
rule
     gtrule: $ forall x/Place (x graphtype Place_GT) $
end



TokenPassageGT in JavaGraphicalType,Class with 
  property
     textcolor : "0,0,0";
     edgecolor : "120,120,120";
     edgewidth : "1";
     label : "";
     bgcolor : "220,120,120" 
  implementedBy
     implBy : "i5.cb.graph.cbeditor.CBLink"
  priority
     p : 3
  rule
     gtrule1: $ forall a/Place!sendsToken (a graphtype TokenPassageGT) $;
     gtrule2: $ forall a/Transition!producesToken (a graphtype TokenPassageGT) $
end   


                    


```

== Graph files

- `knows-dark.gel`
- `double-trafficlights-adv.gel`
- `double-trafficlights.gel`
- `trafficlights_ADVANCED.gel`
- `trafficlights_ALT3.gel`
- `trafficlights_COLORS2.gel`
- `clicktoplay-petrinet-clean.gel`
- `clicktoplay-petrinet.gel`
- `clicktoplay-petrinet-neighbor.gel`
- `clicktoplay-swepn.gel`
- `clicktoplay-swepn-neighbors.gel`
- `clicktoplay-swe-trafficlights-fire.gel`
- `clicktoplay-swe-trafficlights.gel`
- `clicktoplay-trafficlights-fire.gel`
- `clicktoplay-trafficlights.gel`
- `organigraph-highlight.gel`
- `USU_outcat.gel`
- `anna.gel`
- `htmllabels.gel`
- `htmllabels-table.gel`

== Shell output

```text
=== HOW-TO: use-graphical-types ===

>>> Running ./HTML code as node label/02- UML class diagram style using answer formats/htmllabels.cbs.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>This is CBShell, the command line interface to ConceptBase.cc
[offline]>[offline]>[offline]>Successfully connected to server
Successfully connected to server
[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>yes
[localhost:4001]>yes
[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>
>>> cbgraph smoke: ./Dark Telos Palette/knows-dark.gel
>>> cbgraph smoke: ./Dark Telos Palette/knows-dark.gel
/nix/store/ppzp1jz4q8wn8hc1535y6c4v0vfwxmy4-stdenv-linux/setup: line 1947: xvfb-run: command not found
cbgraph smoke skipped (asset validation only)
cbgraph smoke skipped (asset validation only)
```

== Interpretation

The Nix check completes without CBShell or cbserver errors. Review `yes`/`no` responses in the log for tell outcomes.
