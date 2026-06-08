= Formalize Process Data Diagrams

Verified independently via:

```bash
nix build .#checks.x86_64-linux.formalize-process-data-diagrams
```

== Input

=== `00-M3.sml.txt`

```telos
{ 
*
* File: M3.sml
* Author: Manfred Jeusfeld
* Creation: 08-Feb-2010 (16-Mar-2010/M.Jeusfeld)
* ----------------------------------------------------------------------
* A standard M3 level for meta-modeling
*
* Copyright (C) 2010 by Manfred Jeusfeld
* This model file is licensed under the terms of
*   attributeion-NonCommercial 3.0 (Germany)
*   http://creativecommons.org/licenses/by-nc/3.0/de/legalcode
*   http://creativecommons.org/licenses/by-nc/3.0/legalcode
* Extended licenses can be obtained from the author.
*
}

Proposition with
  attribute
    disjointTo: Proposition;   {* expresses that some classes (or attribute categories) do not share any instance *}
    reflexive:  Proposition;  {* any object is related to itself       *}
    transitive: Proposition;  {* relation is closed under transitivity *}
    symmetric: Proposition;   {* if x rel y then also y rel x          *}
    asymmetric: Proposition   {* if x rel y then not y rel x     *}
end


{* A_e(x,m,y) is like (x m y) except that it only considers explicit  *}
{* attributions between x,y. This yields much faster executable code. *}

MetaConstraints in Class with
  constraint

   disjoint_IC: $ forall pair/Proposition!disjointTo x,f,t/Proposition From(pair,f) and To(pair,t)
                    and (x in f) ==> not (x in t) $;

   asym_IC: $ forall AC/Proposition!asymmetric C/Proposition x,y/VAR M/VAR
                     P(AC,C,M,C) and (x in C) and (y in C) and
                     (x M y)  ==> not (y M x) $
  rule
   trans_R: $ forall x,z,y,M/VAR 
                     AC/Proposition!transitive C/Proposition
                     P(AC,C,M,C) and (x in C) and (y in C) and (z in C) and
                     A_e(x,M,y) and (y M z) ==> (x M z) $;
   refl_R: $ forall x,M/VAR 
                    AC/Proposition!reflexive C/Proposition
                    P(AC,C,M,C) and (x in C)
                      ==> (x M x) $;
   symm_R: $ forall x,y,M/VAR 
                    AC/Proposition!symmetric C/Proposition
                    P(AC,C,M,C) and (x in C) and (y in C) and
                    A_e(x,M,y)  ==> (y M x) $
end


{* Define a hint for the asym_IC constraint. This will be used by ConceptBase       *}
{* to generate a customized error message in case of a violation of the constraint. *}
 
MetaConstraints!asym_IC with
  comment
    hint: "The {M} relation of {C} is declared asymmetric. Hence, if (x {M} y) holds, then (y {M} x) may not hold."
end



MetaConstraints in Class with
   constraint
      singleConstraint :
          $ forall c,d/Proposition p/Proposition!single x,m/VAR
              P(p,c,m,d) and (x in c) ==>
                (
                  forall a1,a2/VAR
                    (a1 in p) and (a2 in p) and Ai(x,m,a1) and Ai(x,m,a2) ==>
                   (a1=a2)
                ) $;
      necConstraint:
          $ forall c,d/Proposition p/Proposition!necessary x,m/VAR
            P(p,c,m,d) and (x in c) ==>
             exists y/VAR (y in d) and (x m y) $
end


MetaConstraints!singleConstraint with
 comment
   hint:
"The attribute {m} of {c} is single-valued. Any instance of {c} may have at most one attribute of category {m}!"
end


MetaConstraints!necConstraint with
 comment
   hint:
"The attribute {m} of {c} is defined necessary. Any instance of {c} must have at least one instance of {d} for the attribute {m}!"
end


Proposition!attribute with
  attribute
    isTransitiveClosureOf: Proposition!attribute
end

MetaConstraints in Class with
  rule
   transR1: $ forall x,y,MA,MB/VAR 
                     A,B/Proposition!attribute C/Proposition

                     (B isTransitiveClosureOf A) and
                     P(A,C,MA,C) and P(B,C,MB,C) and 
                     (x in C) and (y in C) and 
                     (x MA y) ==> (x MB y) $;

   transR2: $ forall x,y,z,MA,MB/VAR
                     A,B/Proposition!attribute C/Proposition

                     (B isTransitiveClosureOf A) and
                     P(A,C,MA,C) and P(B,C,MB,C) and
                     (x in C) and (y in C)  and (z in C) and 
                     (x MA z) and (z MB y) ==> (x MB y) $
end



{* ** M3 ** *}

{* M3: our standard M3 constructs *}
NodeOrLink with
  attribute
    connectedTo: NodeOrLink
end 
Node isA NodeOrLink end
NodeOrLink!connectedTo isA NodeOrLink end


Model isA Node with
   attribute
      contains: NodeOrLink
end



```

=== `01-PDD.sml.txt`

```telos
{ 
*
* File: PDD.sml
* Author: Manfred Jeusfeld
* Creation: 08-Feb-2010 (17-Feb-2011/M.Jeusfeld)
* ----------------------------------------------------------------------
* A simple representation of Process-Deliverable-Diagrams (PDD)
* as used by Inge van de Weerd.
*
* Copyright (C) 2010 by Manfred Jeusfeld
* This model file is licensed under the terms of
*   attributeion-NonCommercial 3.0 (Germany)
*   http://creativecommons.org/licenses/by-nc/3.0/de/legalcode
*   http://creativecommons.org/licenses/by-nc/3.0/legalcode
* Extended licenses can be obtained from the author.
*
}



{* M3: Deliverable diagrams; this is M3 level since instances are at M2 level *}


{* By making Deliverable both a subclass and instance of ProductElem *}
{* we can use Deliverable on the one hand as M3 level construct for  *}
{* the product side, and at the same time we can connected to it     *}
{* via the usual connectedTo link from Activity (M2 level of         *}
{* production side. Technically, we do not need to do so. We can     *}
{* just use 'attribute' instead of connectedTo when linking          *}
{* Activity to Deliverable. It is just a bit nicer and we can use    *}
{* existing machinery for NodeOrLink (like the ModElem stuff) to     *}
{* analyze PDDs as models.                                           *}

ProcessElem isA NodeOrLink end
ProductElem isA NodeOrLink end

Deliverable in ProductElem isA ProductElem end   {* that for anything an activity can require as input *}

Concept isA Deliverable end

StandardConcept isA Concept end

OpenConcept isA Concept,Model with
  attribute
     contains: Deliverable    {* so this a a special kind of a model *}
end

ClosedConcept isA Concept,Model end  {* actually we should demand that is has no model elements *}

DocumentDeliverable isA OpenConcept end
ModelDeliverable isA OpenConcept end




{* == M2 == *}


{* M2 (Production side): Activity diagrams much like in UML *}

{*
* This is for the production side; we call this M2 level but it is referring to 
* Deliverable, which is a M3 construct; see slides of lect09 at
*        http://merkur.informatik.rwth-aachen.de/pub/bscw.cgi/d2616329/
* for a discussion of this phenomenon. 
*
*}

ActivityNode in Node,ProcessElem with
  connectedTo
     next: ActivityNode
end

ActivityDiagram in Model,ProcessElem,Class isA Activity with   {* synonym for ComplexActivity *}
  contains
     activity: ActivityNode;
     control: ActivityNode!next
  reflexive,attribute
     subactivity: ActivityNode
  rule
     addcontrol: $ forall a/ActivityNode ad/ActivityDiagram link/ActivityNode!next
                        (ad activity a) and From(link,a) ==> (ad control link) $;
     t1: $ forall ad/ActivityDiagram a/ActivityNode (ad activity a) ==> (ad subactivity a) $;
     t2: $ forall ad1,ad2/ActivityDiagram a/ActivityNode (ad1 activity ad2) and (ad2 subactivity a) ==> (ad1 subactivity a) $
end



Phase in Model isA ActivityDiagram with  {* this is a useful construct for distinguishing phases of a method *}
  connectedTo
     preferredDeliverable: Deliverable    {* for specifying the deliverable part linked to a phase in a PDD *}
end

PDD in Model isA Phase end               {* this is for a full PDD=method *}
PDDLibrary in Model isA PDD end          {* this is for fragment libraries *}

Agent in ProcessElem end

Activity in ProcessElem isA ActivityNode with
  connectedTo
     produces: Deliverable;
     performer: Agent
end

StartPoint in ProcessElem isA ActivityNode end
EndPoint in ProcessElem isA ActivityNode end

ParallelBranch in ProcessElem isA Activity with
  connectedTo
     branch: ActivityNode
end

ParallelBranch!branch isA ActivityNode!next end

ParallelJoin in ProcessElem isA Activity with
end

DecisionPoint in ProcessElem isA Activity with
  connectedTo
    choice: ActivityNode
end

DecisionPoint!choice isA ActivityNode!next end

DecisionJoin in ProcessElem isA Activity with
end


{* some derived constructs *}

ClosedActivityDiagram in QueryClass isA ActivityDiagram with
  constraint
    isClosed: $ not exists a/ActivityNode (this activity a) $
end

ClosedActivity in QueryClass isA ActivityNode with
  constraint
    isClosed: $ (this in ActivityDiagram) ==> (this in ClosedActivityDiagram) $
end

ComplexActivity in QueryClass isA ActivityDiagram with
  constraint
    isClosed: $ exists a/ActivityNode (this activity a) $
end


{* StartNode returns the first activity node of an activity diagram *}

StartNode in GenericQueryClass isA ActivityNode with
   parameter,computed_attribute
      diagram: ActivityNode
   constraint
      isStart: $ ((diagram in ActivityDiagram) and Adot(ActivityDiagram!activity,diagram,this) and not exists a/ActivityNode Adot(ActivityDiagram!activity,diagram,a) and (a \= this) and :(a next this):) or
                 (not (diagram in ComplexActivity)) and (this=diagram) $
end


{* EndNode returns the last activity node of an activity diagram *}

EndNode in GenericQueryClass isA ActivityNode with
   parameter,computed_attribute
      diagram: ActivityNode
   constraint
      isEnd: $ ((diagram in ActivityDiagram) and Adot(ActivityDiagram!activity,diagram,this) and not exists a/ActivityNode Adot(ActivityDiagram!activity,diagram,a) and (a \= this) and :(this next a):) or 
               (not (diagram in ComplexActivity)) and (this=diagram) $
end







```

=== `02-PDD-Rule.sml.txt`

```telos
{ 
*
* File: PDD-Rule.sml
* Author: Manfred Jeusfeld
* Creation: 11-Feb-2010 (04-Mar-2010/M.Jeusfeld)
* ----------------------------------------------------------------------
* Deductive rules for synchronizing the control structure between levels
*
* Copyright (C) 2010 by Manfred Jeusfeld
* This model file is licensed under the terms of
*   attributeion-NonCommercial 3.0 (Germany)
*   http://creativecommons.org/licenses/by-nc/3.0/de/legalcode
*   http://creativecommons.org/licenses/by-nc/3.0/legalcode
* Extended licenses can be obtained from the author.
*
}




Activity in Class with
  rule
     d1: $ forall a1/ClosedActivity a2/ComplexActivity s/ActivityNode
              (a1 next a2) and (s in StartNode[a2]) 
           ==> (a1 next s)
          $;
     d2: $ forall a1/ComplexActivity a2/ClosedActivity e/ActivityNode
              (a1 next a2) and (e in EndNode[a1])
           ==> (e next a2)
         $;
     d3: $ forall a1,a2/ComplexActivity e,s/ActivityNode
              (a1 next a2) and (e in EndNode[a1]) and (s in StartNode[a2]) 
           ==> (e next s)
         $
{ disable the upward rule for performance reasons
     u1: $ forall e,s/ActivityNode a1,a2/ComplexActivity
              (e next s) and (a1 activity e) and (a2 activity s) and (a1 \= a2) and
              (e in EndNode[a1]) and (s in StartNode[a2])
           ==> (a1 next a2)
         $
}
end




```

=== `03-PDD-GTs.sml.txt`

```telos
{
*
* File: PDD-GTs.sml
* Author: Manfred Jeusfeld
* Creation: 09-Feb-2010 (04-Mar-2010/M.Jeusfeld)
* ----------------------------------------------------------------------
* Graphical types for PDDs
*
* Copyright (C) 2010 by Manfred Jeusfeld
* This model file is licensed under the terms of
*   attributeion-NonCommercial 3.0 (Germany)
*   http://creativecommons.org/licenses/by-nc/3.0/de/legalcode
*   http://creativecommons.org/licenses/by-nc/3.0/legalcode
* Extended licenses can be obtained from the author.
*
}



Class PDD_Palette in JavaGraphicalPalette with
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
    c7: SimpleActivity_GT;
    c8: ActivityDiagram_GT;
    c10: ParSplit_GT;
    c11: ParJoin_GT;
    c23: NextLink_GT;
    c24: ChoiceLink_GT;
    c25: Choice_GT;
    c26: Start_GT;
    c27: End_GT;
    c28: StandardC_GT;
    c29: OpenC_GT;
    c30: ClosedC_GT;
    c31: ProducesLink_GT;
    c32: PartOfLink_GT;
    d1: DefaultattributeeGT;
    d2: DefaultIsAGT;
    d3: DefaultInstanceOfGT;
    d4: QueryClassGT
rule
    rIsaGT : $ forall p/IsA (p graphtype DefaultIsAGT) $;
    rInstGT : $ forall p/InstanceOf (p graphtype DefaultInstanceOfGT) $;
    rAttrGT : $ forall p/attributee (p graphtype DefaultattributeeGT) $;
    rIndGT : $ forall p/Individual (p graphtype DefaultIndividualGT) $;
    rQueryClass : $ forall c/QueryClass (c graphtype QueryClassGT) $
end




SimpleActivity_GT in Class,JavaGraphicalType with
property
	bgcolor : "230,230,120";   {*  *}
	textcolor : "0,0,0";
      linecolor : "100,100,100";
	shape : "i5.cb.graph.shapes.RoundRectangle";
	fontstyle : "italic";
      linewidth : "1"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 22
rule
     gtrule: $ forall x/Activity In_e(x,Activity) ==> (x graphtype SimpleActivity_GT) $
end

Activity with
  graphtype
     thisgt1: SimpleActivity_GT
end

ActivityDiagram_GT in Class,JavaGraphicalType with
property
	bgcolor : "200,200,100";   {* green = enabled *}
	textcolor : "0,0,0";
      linecolor : "100,100,100";
	shape : "i5.cb.graph.shapes.RoundRectangle";
	fontstyle : "bold,italic";
      linewidth : "2"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 23
rule
     gtrule: $ forall x/ActivityDiagram (x graphtype ActivityDiagram_GT) $
end    

ActivityDiagram with
  graphtype
     thisgt2: ActivityDiagram_GT
end     
                  
ParSplit_GT in Class,JavaGraphicalType with
property
	bgcolor : "0,0,0";  {* light grey for places without tokens *}
	textcolor : "0,0,0";
	linecolor : "0,0,0";
        label : "     ";
	shape : "i5.cb.graph.shapes.Rect";
        linewidth : "1"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 27
rule
     gtrule: $ forall x/ParallelBranch (x graphtype ParSplit_GT) $
end

ParJoin_GT in Class,JavaGraphicalType with
property
	bgcolor : "0,0,0";  {* light grey for places without tokens *}
	textcolor : "0,0,0";
	linecolor : "0,0,0";
        label : "      ";
	shape : "i5.cb.graph.shapes.Rect";
        linewidth : "1"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 28
rule
     gtrule: $ forall x/ParallelJoin (x graphtype ParJoin_GT) $
end


Choice_GT in Class,JavaGraphicalType with
property
	bgcolor : "255,255,255"; 
	textcolor : "0,0,0";
	linecolor : "0,0,0";
        label : "   ";
	shape : "i5.cb.graph.shapes.Diamond";
        linewidth : "2"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 29
rule
     gtrule: $ forall x/DecisionPoint (x graphtype Choice_GT) $
end

Start_GT in Class,JavaGraphicalType with
property
	bgcolor : "50,50,50"; 
	textcolor : "150,150,150";
	linecolor : "0,0,0";
        label : " o ";
	shape : "i5.cb.graph.shapes.Ellipse";
        linewidth : "2"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 29
rule
     gtrule: $ forall x/StartPoint (x graphtype Start_GT) $
end


End_GT in Class,JavaGraphicalType with
property
	bgcolor : "50,50,50"; 
	textcolor : "150,150,150";
	linecolor : "0,0,0";
        label : " x ";
	shape : "i5.cb.graph.shapes.Ellipse";
        linewidth : "2"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 29
rule
     gtrule: $ forall x/EndPoint (x graphtype End_GT) $
end


StandardC_GT in Class,JavaGraphicalType with
property
	bgcolor : "255,255,255"; 
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.Rect";
        linewidth : "1"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 20
rule
     gtrule: $ forall x/Concept (x graphtype StandardC_GT) $
end

Concept with
  graphtype
     thisgt1: StandardC_GT
end


OpenC_GT in Class,JavaGraphicalType with
property
	bgcolor : "255,255,255"; 
	textcolor : "0,0,0";
	linecolor : "150,150,150";
	shape : "i5.cb.graph.shapes.Rect";
        linewidth : "3"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 22
rule
     gtrule: $ forall x/OpenConcept (x graphtype OpenC_GT) $
end

OpenConcept with
  graphtype
     thisgt2: OpenC_GT
end


ClosedC_GT in Class,JavaGraphicalType with
property
	bgcolor : "255,255,255"; 
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.Rect";
        linewidth : "3"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 24
rule
     gtrule: $ forall x/ClosedConcept (x graphtype ClosedC_GT) $
end

ClosedConcept with
  graphtype
     thisgt3: ClosedC_GT
end



NextLink_GT in JavaGraphicalType,Class with 
  attribute,property
     textcolor : "0,0,0";
     edgecolor : "100,100,100";
     edgewidth : "2";
     label : ""
  attribute,implementedBy
     implBy : "i5.cb.graph.cbeditor.CBLink"
  attribute,priority
     p : 20
  rule
     gtrule: $ forall a/ActivityNode!next (a graphtype NextLink_GT) $
end   

ChoiceLink_GT in JavaGraphicalType,Class with 
  attribute,property
     textcolor : "0,0,0";
     edgecolor : "100,100,100";
     edgewidth : "2";
     bgcolor : "255,150,150"
  attribute,implementedBy
     implBy : "i5.cb.graph.cbeditor.CBLink"
  attribute,priority
     p : 21
  rule
     gtrule: $ forall a/DecisionPoint!choice (a graphtype ChoiceLink_GT) $
end  

ProducesLink_GT in JavaGraphicalType,Class with 
  attribute,property
     textcolor : "0,0,0";
     edgecolor : "50,50,180";
     edgewidth : "2";
     edgestyle : "dashdotted";
     label : ""
  attribute,implementedBy
     implBy : "i5.cb.graph.cbeditor.CBLink"
  attribute,priority
     p : 22
  rule
     gtrule: $ forall a/Activity!produces (a graphtype ProducesLink_GT) $
end  

PartOfLink_GT in JavaGraphicalType,Class with 
  attribute,property
     textcolor : "0,0,0";
     edgecolor : "40,180,40";
     edgewidth : "2";
     edgestyle : "dotted";
     label : ""
  attribute,implementedBy
     implBy : "i5.cb.graph.cbeditor.CBLink"
  attribute,priority
     p : 23
  rule
     gtrule1: $ forall a/ActivityDiagram!activity (a graphtype PartOfLink_GT) $;
     gtrule2: $ forall a/OpenConcept!contains (a graphtype PartOfLink_GT) $
end  


```

=== `040-PDD-WEM-Lib.sml.txt`

```telos
{ 
*
* File: PDD-WEM-Lib.sml
* Author: Manfred Jeusfeld
* Creation: 01-Feb-2010 (17-Feb-2011/M.Jeusfeld)
* ----------------------------------------------------------------------
* Applying the PDD constructs to define a part of the Web Engineering Method (WEM).
* Excerpted from slides of Inge van de Weerd
*
* Copyright (C) 2010 by Manfred Jeusfeld
* This model file is licensed under the terms of
*   attributeion-NonCommercial 3.0 (Germany)
*   http://creativecommons.org/licenses/by-nc/3.0/de/legalcode
*   http://creativecommons.org/licenses/by-nc/3.0/legalcode
* Extended licenses can be obtained from the author.
*
}



{* M1 (Production side): *}

{*
* These are actual examples of method fragments for some method. We use the GX Web Manager case study here;
  We only model the "Complex Definition Phase" here.
*}





DescribeBackground in Activity with
  next
    step3: ListFeatures
  produces
    product1: BACKGROUND
end

ListFeatures in Activity with
  next
    step4: ListAssumptions
  produces
    product1: FEATURELIST
end

ListAssumptions in Activity with
  next
    step5: DescribeGoals
  produces
    product1: ASSUMPTION
end

DescribeGoals in Activity with
  next
    step6: DescribeScope
  produces
    product1: GOAL
end

DescribeScope in Activity with
  produces
    product1: SCOPE
end


GoalSetting in Phase with
  activity
    a1: DescribeBackground;
    a2: ListFeatures;
    a3: ListAssumptions;
    a4: DescribeGoals;
    a5: DescribeScope
  preferredDeliverable
    del: GOALSETTING
end


DefineImportantTerms in Activity with
  next
    step7: IdentifyRelations
  produces
    product1: TERM
end

IdentifyRelations in Activity with
  next
    step8: DrawClassDiagram
  produces
    product1: RELATION
end

DrawClassDiagram in Activity with
  produces
    product1: CLASSDIAGRAM
end

DomainModeling in Phase with
  activity
    a1: DefineImportantTerms;
    a2: IdentifyRelations;
    a3: DrawClassDiagram
  preferredDeliverable
    del: DOMAINMODEL
end



ParBranch1 in ParallelBranch with
  branch
    step11: DescribeActors;
    step12: ExtractUseCases
end

DescribeActors in Activity with
  next
    step13: ParJoin1
  produces
    product1: ACTOR
end

ExtractUseCases in Activity with
  next
    step14: ParJoin1
  produces
    product1: USECASE
end

ParJoin1 in ParallelJoin with
  next
    step15: DrawUseCaseModel
end

DrawUseCaseModel in Activity with
  next
    step16: DescribeStandardUseCases
  produces
    product1: USECASEMODEL
end

DescribeStandardUseCases in Activity with
  next
    step17: DescribeCustomUseCases
  produces
    product1: DESCRIPTION
end


DescribeCustomUseCases in Activity with
  produces
    product1: USECASEDESCRIPTION
end



UseCaseModeling in Phase with
  activity
    a2: ParBranch1;
    a3: DescribeActors;
    a4: ExtractUseCases;
    a5: ParJoin1;
    a6: DrawUseCaseModel;
    a7: DescribeStandardUseCases;
    a8: DescribeCustomUseCases
  preferredDeliverable
    del: USECASEMODEL
end


DescribeNavigation in Activity with
  next
    step18: DescribeUserInterface
  produces
    product1: NAVIGATION
end

DescribeUserInterface in Activity with
  next
    step19: DescribeApplicationImplicationsUseCases
  produces
    product1: USERINTERFACE
end

DescribeApplicationImplicationsUseCases in Activity with
  next
    step20: DescribeInterfacesOtherSystems
  produces
    product1: APPLICATIONIMPLICATIONS
end

DescribeInterfacesOtherSystems in Activity with
  next
    step21: DescribeMigrationIssues
  produces
    product1: INTERFACE
end

DescribeMigrationIssues in Activity with
  produces
    product1: MIGRATIONISSUE
end


ApplicationModeling in Phase with
  activity
    a1: DescribeNavigation;
    a2: DescribeUserInterface;
    a3: DescribeApplicationImplicationsUseCases;
    a4: DescribeInterfacesOtherSystems;
    a5: DescribeMigrationIssues
  preferredDeliverable
    del: APPLICATIONMODEL
end


AdditionalRequirementsDescription in Activity with
  produces
    product1: ADDITIONALREQUIREMENT
end


RequirementsValidation in Activity with
  produces
    product1: REQUIREMENTSREVIEWREPORT
end

ExtensiveRequirementsElicitation in Phase with
end


UML_WEB_ENGINEERING in PDDLibrary with
  activity
    a1: ExtensiveRequirementsElicitation;
    a2: ApplicationModeling;
    a3: AdditionalRequirementsDescription
end

GX_METHOD in PDDLibrary with
   activity
     a1: GoalSetting;
     a2: DomainModeling;
     a3: RequirementsValidation
end

UNIFIED_PROCESS in PDDLibrary with
   activity
     a1: UseCaseModeling
end



{* M2: Deliverable types *}



RequirementsDocument in DocumentDeliverable with
  contains,single
    part1: GOALSETTING;
    part2: DOMAINMODEL;
    part3: USECASEMODEL;
    part4: APPLICATIONMODEL;
    part5: ADDITIONALREQUIREMENT
end


GOALSETTING  in ModelDeliverable with
  contains,single
    part1: BACKGROUND;
    part2: FEATURELIST
  contains
    part3: ASSUMPTION;
    part4: GOAL
  contains,single
    part5: SCOPE
end
    
BACKGROUND in StandardConcept end
FEATURELIST in StandardConcept end
ASSUMPTION in StandardConcept end
GOAL in StandardConcept end
SCOPE in StandardConcept end


DOMAINMODEL in ModelDeliverable with
  contains
    part1: TERM
  contains,single
    part2: CLASSDIAGRAM
end

TERM in StandardConcept with
  connectedTo
    hasRelation: RELATION
end

RELATION in StandardConcept end


CLASSDIAGRAM in ModelDeliverable with
{*
  contains
   classes: UmlClass;
   associations: Association;
   specialization: UmlIsA 
*}
end


UmlClass in StandardConcept with
  connectedTo
    statevariable: UmlDomain;
    operation: UmlOperation
end

UmlDomain in StandardConcept end

{* some predefined names *}
UmlString in UmlDomain end
UmlInteger in UmlDomain end
UmlReal in UmlDomain end


UmlOperation in StandardConcept end

Association in StandardConcept with
  connectedTo
     assocLink: UmlClass
end


Association!assocLink with
  attribute
     card: Cardinality
end


Cardinality in Node end

{* we support here just three cardinalities *}
"1..1" in Cardinality end
"0..1" in Cardinality end
"1..*" in Cardinality end

AssociationClass in StandardConcept isA Association,UmlClass end  {* much like EntRelType ! *}

PartOfAssoc in StandardConcept isA Association with
  connectedTo,single,necessary   {* this forces PartOfAssoc to be a binary link type *}
    superOrdinate: UmlClass;
    subOrdinate: UmlClass
end

PartOfAssoc!superOrdinate isA Association!assocLink end
PartOfAssoc!subOrdinate isA Association!assocLink end

UmlIsA in StandardConcept with
  connectedTo,single,necessary    {* exactly one supertype *}
    supertype: UmlClass
  connectedTo,necessary           {* at least one subtype *}
    subtype: UmlClass
end


UmlIsA_complete in StandardConcept isA UmlIsA end   {* just a variant of UmlIsA *}


USECASEMODEL in ModelDeliverable with
  contains
     actor: ACTOR;
     useCase: USECASE
end

ACTOR in StandardConcept end

USECASE in StandardConcept with
  connectedTo
    shortdescr: DESCRIPTION;
    longdescr: USECASEDESCRIPTION
end

DESCRIPTION in StandardConcept end

USECASEDESCRIPTION in OpenConcept end

APPLICATIONMODEL in ModelDeliverable with
  contains,single
    navigation: NAVIGATION;
    userInterface: USERINTERFACE
  contains
    applicationImplications: APPLICATIONIMPLICATIONS;
    interface: INTERFACE;
    migrationIssue: MIGRATIONISSUE 
end

NAVIGATION in ClosedConcept end
USERINTERFACE in ClosedConcept end
APPLICATIONIMPLICATIONS in ClosedConcept end
INTERFACE in ClosedConcept end
MIGRATIONISSUE in ClosedConcept end


ADDITIONALREQUIREMENT in ClosedConcept with
end


REQUIREMENTSREVIEWREPORT in ClosedConcept with
end




```

=== `041-WEM-Combine.sml.txt`

```telos
{ 
*
* File: PDD-WEM-Combine.sml
* Author: Manfred Jeusfeld
* Creation: 01-Feb-2010 (04-Apr-2011/M.Jeusfeld)
* ----------------------------------------------------------------------
* Applying the PDD constructs to define a part of the Web Engineering Method (WEM).
* Excerpted from slides of Inge van de Weerd
*
* Copyright (C) 2011 by Manfred Jeusfeld
* This model file is licensed under the terms of
*   attributeion-NonCommercial 3.0 (Germany)
*   http://creativecommons.org/licenses/by-nc/3.0/de/legalcode
*   http://creativecommons.org/licenses/by-nc/3.0/legalcode
* Extended licenses can be obtained from the author.
*
}





ExtensiveRequirementsElicitation in Phase with
  next
    nextphase: GoalSetting
end

GoalSetting in Phase with
  next
    nextphase: DomainModeling
end

DomainModeling in Phase with
  next
    nextphase: UseCaseModeling
end

UseCaseModeling in Phase with
  next
    nextphase: ApplicationModeling
end

ApplicationModeling in Phase with
  next
    nextphase: AdditionalRequirementsDescription
end

AdditionalRequirementsDescription in Activity with
  next
    step23: RequirementsValidation
  produces
    product1: ADDITIONALREQUIREMENT
end


ComplexDefinitionPhase in PDD with
  activity
    a1: ExtensiveRequirementsElicitation;
    a2: GoalSetting;
    a3: DomainModeling;
    a4: UseCaseModeling;
    a5: ApplicationModeling;
    a6: AdditionalRequirementsDescription;
    a7: RequirementsValidation
  preferredDeliverable
    del: RequirementsDocument
end





```

=== `05-PDD-simple-example.sml.txt`

```telos
{ 
*
* File: PDD-simple-example.sml
* Author: Manfred Jeusfeld
* Creation: 08-Feb-2010 (04-Mar-2010/M.Jeusfeld)
* ----------------------------------------------------------------------
* A simple representation of Process-Deliverable-Diagrams (PDD)
* as used by Inge van de Weerd. Used to highlight some of
* the analysis rules
*
* Copyright (C) 2010 by Manfred Jeusfeld
* This model file is licensed under the terms of
*   attributeion-NonCommercial 3.0 (Germany)
*   http://creativecommons.org/licenses/by-nc/3.0/de/legalcode
*   http://creativecommons.org/licenses/by-nc/3.0/legalcode
* Extended licenses can be obtained from the author.
*
}


AD1 in Phase with
  activity
    a1: A11;
    a2: A12;
    a3: A13;
    a4: A14
end

AD2 in Phase with
  activity
    a1: A21;
    a2: A22
end

BIG in PDD with
  activity
    a1: AD1;
    a2: AD2
end

A11 in Activity with
  next n: A12
end

A12 in Activity with
  next n1: A13; n2: A14
end

A13 in Activity end
A14 in Activity end



A21 in Activity with
  next n: A22
end

A22 in Activity end


{* the above diagram has two flaws:

   (1) AD1 and AD2 are not linked to each other, ie.
   the activity diagram BIG has no unique start and end.
   Repair this as follows:

AD1 with
  next
   n1: AD2
end

   (2) AD1 has two end activities A13 and A14
    You can repait it for example by

A13 with
  next n: A14
end


*}




{* Test data for CrossWrittenDeliverable  *}
{* M1 is "cross-written since AD1 and AD2 are not yet in a sequence *}

A12 in Activity with
  produces
     del: D1
end

A21 in Activity with
  produces
     del: D2
end


M1 in ModelDeliverable with
  contains
     p1: D1;
     p2: D2
end

D1 in Deliverable end
D2 in Deliverable end




{* This is an example for the GoToActivity *}

MyPdd1 in PDD with
  activity
    a1: P1;
    a2: P2
end


P1 in Phase with
  activity
    a: A1
  next
    ph: P2
end

P2 in Phase with
   activity
     a1: A2_start;
     a2: A2
end

A1 in Activity with
  next
     n: A2
end

A2_start in Activity with
  next
    n: A2
end

A2 in Activity with
end











```

=== `06-PDD-Analysis.sml.txt`

```telos
{ 
*
* File: PDD-Analysis.sml
* Author: Manfred Jeusfeld
* Creation: 12-Feb-2010 (04-Apr-2011/M.Jeusfeld)
* ----------------------------------------------------------------------
* Some functionality to analyze PDDs:
*
*   - Cross-writing of deliverables
*   - Unstructured GoTos
*   - duplicate start/end nodes of activity diagrams
*
* Copyright (C) 2010 by Manfred Jeusfeld
* This model file is licensed under the terms of
*   attributeion-NonCommercial 3.0 (Germany)
*   http://creativecommons.org/licenses/by-nc/3.0/de/legalcode
*   http://creativecommons.org/licenses/by-nc/3.0/legalcode
* Extended licenses can be obtained from the author.
*
}





{* Cross-writing of deliverables

   There is a Deliberable that is written into by activities
   that belong to different phases

*}


CrossWrittenDeliverable in QueryClass isA ModelDeliverable with
    computed_attribute
       crosswriter: Activity
    constraint
      crossCond: $ exists phase1,phase2/Phase d1,d2/Deliverable writer/Activity
                      (phase1 \= phase2) and
                      (phase1 activity writer) and (phase2 activity crosswriter) and
                      (writer produces d1) and (crosswriter produces d2) and
                      (this contains d1) and (this contains d2) $
end


{* Testdata

P1 in Phase with
  activity
    a: A1
end

P2 in Phase with
   activity
     a: A2
end

A1 in Activity with
  produces
     del: D1
end

A2 in Activity with
  produces
     del: D2
end


M1 in ModelDeliverable with
  contains
     p1: D1;
     p2: D2
end

D1 in Deliverable end
D2 in Deliverable end

*}




{* extend graphical palette to display cross-written deliverables in redish *}
Class PDD_Palette in JavaGraphicalPalette with
contains
   cwd1: CrossDeliverable
end



CrossDeliverable in Class,JavaGraphicalType with
property
	bgcolor : "255,200,200"; 
	textcolor : "0,0,0";
	linecolor : "150,150,150";
	shape : "i5.cb.graph.shapes.Rect";
        linewidth : "3"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 32
rule
     gtrule: $ forall x/CrossWrittenDeliverable (x graphtype CrossDeliverable) $
graphtype
     thisgt: CrossDeliverable
end







{* GoToActivity

   An activity A1 belongs to a phase P1 and jumps to an activity A2 that belongs to another
   phase P2 , but A2 is not the StartNode of P2.

*}


GoToActivity in QueryClass isA Activity with
    computed_attribute
       target: Activity
    constraint
      gotoCond: $ exists pdd/PDD phase1,phase2/Phase 
                      (pdd activity phase1 ) and (pdd activity phase2) and
                      (phase1 \= phase2) and (phase1 activity this) and
                      :(this next target): and (phase2 activity target) and
                      not (target in StartNode[phase2]) $
end





{* DuplicateStartNode/DuplicateEndNode

   An activity diagram must have a unique start and a unique end node

*}

DuplicateStartNode in QueryClass isA ActivityNode with
   computed_attribute
      diag: ActivityDiagram;
      duplicate: ActivityNode
   constraint
      isDup: $ (duplicate in StartNode[diag]) and (this in StartNode[diag]) and 
               (duplicate \= this) and not (diag in PDDLibrary) $
end

DuplicateEndNode in QueryClass isA ActivityNode with
   computed_attribute
      diag: ActivityDiagram;
      duplicate: ActivityNode
   constraint
      isDup: $ (duplicate in EndNode[diag]) and (this in EndNode[diag]) and
               (duplicate \= this) and not (diag in PDDLibrary)$
end




{* sample data

P1 in Phase with
  activity
    a: A1
end

P2 in Phase with
   activity
     a1: A2_start;
     a2: A2
end

A1 in Activity with
  next
     n: A2
end

A2_start in Activity with
  next
    n: A2
end

A2 in Activity with
end

*}


Class PDD_Palette in JavaGraphicalPalette with
contains
   gta1: ProblemActivity
end



ProblemActivity in Class,JavaGraphicalType with
property
	bgcolor : "255,150,80";   {* more redish *}
	textcolor : "0,0,0";
        linecolor : "100,100,100";
	shape : "i5.cb.graph.shapes.RoundRectangle";
	fontstyle : "italic";
        linewidth : "1"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 32
rule
     gtrule1: $ forall x/GoToActivity (x graphtype ProblemActivity) $; 
     gtrule2: $ forall x/DuplicateStartNode (x graphtype ProblemActivity) $;
     gtrule3: $ forall x/DuplicateEndNode (x graphtype ProblemActivity) $
graphtype
     thisgt: ProblemActivity
end


```

== Graph files

- `PDD-overview00-src.gel`

== Shell output

```text
=== HOW-TO: formalize-process-data-diagrams ===

>>> Running ./createDatabase.cbs.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>This is CBShell, the command line interface to ConceptBase.cc
[offline]>[offline]>[offline]>[offline]>[offline]>Successfully connected to server
Successfully connected to server
[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>yes
[localhost:4001]>yes
[localhost:4001]>PDD
[localhost:4001]>PDD
[localhost:4001]>[localhost:4001]>[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>no
no
[localhost:4001]>[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>no
no
[localhost:4001]>[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>[localhost:4001]>[localhost:4001]>yes
[localhost:4001]>yes
[localhost:4001]>WEM
[localhost:4001]>WEM
[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>no
no
[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>yes
[localhost:4001]>yes
[localhost:4001]>WEMGV
[localhost:4001]>WEMGV
[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>[localhost:4001]>[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>[localhost:4001]>[localhost:4001]>PDD
[localhost:4001]>PDD
[localhost:4001]>yes
[localhost:4001]>yes
[localhost:4001]>WEM2
[localhost:4001]>WEM2
[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>PDD
[localhost:4001]>PDD
[localhost:4001]>yes
[localhost:4001]>yes
[localhost:4001]>SimpleExample
[localhost:4001]>SimpleExample
[localhost:4001]>[localhost:4001]>[localhost:4001]>no
no
[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>
>>> Running ./startstop.cbs.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>This is CBShell, the command line interface to ConceptBase.cc
[offline]>[offline]>[offline]>Successfully connected to server
Successfully connected to server
[localhost:4001]>[localhost:4001]>
>>> Telling ./00-M3.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>yes
[localhost:4001]>
>>> Telling ./01-PDD.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>yes
[localhost:4001]>
>>> Telling ./02-PDD-Rule.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>yes
[localhost:4001]>
>>> Telling ./03-PDD-GTs.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>no
[localhost:4001]>
>>> Telling ./040-PDD-WEM-Lib.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>yes
[localhost:4001]>
>>> Telling ./041-WEM-Combine.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>yes
[localhost:4001]>
>>> Telling ./05-PDD-simple-example.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>yes
[localhost:4001]>
>>> Telling ./06-PDD-Analysis.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>yes
[localhost:4001]>
>>> Telling ./07-PDD-graphviz.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>yes
[localhost:4001]>
>>> Telling ./08-Trace.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>yes
[localhost:4001]>
```

== Interpretation

The Nix check completes without CBShell or cbserver errors. Review `yes`/`no` responses in the log for tell outcomes.
