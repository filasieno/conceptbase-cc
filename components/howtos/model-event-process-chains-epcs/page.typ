= Model Event Process Chains Epcs

Verified independently via:

```bash
nix build .#checks.x86_64-linux.model-event-process-chains-epcs
```

== Input

=== `01-EPC.sml.txt`

```telos
{
* File: EPC.sml
* Author: Manfred Jeusfeld
* Created: 12-Oct-2004/M.Jeusfeld (20-Oct-2004/M.Jeusfeld)
* ------------------------------------------------------
* Notation for event process chains
* 12-Oct-2004: basic definitions
* 15-Oct-2004: added defs for single/necessary
*
}

{* NDL *}

Node with
  attribute   
    connectedTo: Node
end

Model isA Node with
   attribute
      contains: Node
end

{* Define single/necessary (adapted from ConceptBase user manual) *}

Class with constraint, attribute
  necConstraint:
    $ forall p/Proposition!necessary c,d/Proposition x,m/VAR 
      P(p,c,m,d) and In(x,c) ==> 
         exists y/VAR  In(y,d) and A(x,m,y) $;
  singleConstraint : 
   $ forall p/Proposition!single c,d/Proposition x,m/ VAR 
     In(p,Proposition!single) and P(p,c,m,d) and In(x,c)  ==> 
        forall y1,y2/VAR 
        In(y1,d) and In(y2,d) and A(x,m,y1) and A(x,m,y2) ==>  
                 IDENTICAL(y1, y2) $
end 



{* NL *}

{* EPC = Event-Process-Chain *}
EPC in Model with
  contains
    containsBPelement: BusinessProcessElement
end

BusinessProcessElement in Node end


Event in Node isA BusinessProcessElement with
  connectedTo
     triggers: BusinessFunction;
     partOf: CompositeEvent
end


CompositeEvent in Node isA Event with
   connectedTo,single,necessary
      operator: LogicalOperator
end

ElementaryEvent in Node isA Event end

LogicalOperator in Node isA BusinessProcessElement end

BusinessFunction in Node isA BusinessProcessElement with
  connectedTo
     resultEvent: Event;
     responsibleUnit: OrganizationalUnit;
     flowsOut: BusinessProduct;
     producesInformation: InformationObject
end


StartEvent in QueryClass isA Event with
  constraint
    c1: $ exists epc/EPC (epc containsBPelement ~this) and
           not (
                exists bf/BusinessFunction 
                  (epc containsBPelement bf) and
                  (bf resultEvent ~this)
                ) $
end



InformationObject in Node isA BusinessProcessElement with
   connectedTo
     feedsInformation: BusinessFunction
end

BusinessProduct in Node with
   connectedTo
     flowsIn: BusinessFunction
end

OrganizationalUnit in Node isA BusinessProcessElement end

AND_OP in LogicalOperator end

OR_OP in LogicalOperator end

XOR_OP in LogicalOperator end



{* ML *}

MyEpc19oct2004 in EPC with
  containsBPelement
    e1: MailOrderArrived;
    e2: PhoneOrderArrived;
    e3: OrderArrivedEvent;
    e4: CheckOrder;
    e5: OrderValid;
    e6: OrdersDB;
    e7: SalesDept
end

MailOrderArrived in ElementaryEvent with
 partOf
    ev: OrderArrivedEvent
end 

PhoneOrderArrived in ElementaryEvent with
 partOf
    ev: OrderArrivedEvent
end 

OrderArrivedEvent in CompositeEvent with 
  operator
     op1 : XOR_OP
  triggers
     tr1 : CheckOrder
end 

CheckOrder in BusinessFunction with 
  resultEvent
     re1 : OrderValid
  producesInformation
     pi1 : OrdersDB
  responsibleUnit
     ru1 : SalesDept
end 


SalesDept in OrganizationalUnit end

OrderValid in ElementaryEvent end

OrdersDB in InformationObject end 

      
```

=== `02-EPC-GTs.sml.txt`

```telos
{
*
* File: EPC-GTs.sml
* Author: Manfred Jeusfeld
* Creation: 19-Oct-2004
* ----------------------------------------------------------------------
* Graphical types for event-process chains (adopted from Aris style)
*
}



Class EPC_Palette in JavaGraphicalPalette with
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
    c6: BusinessFunction_GT;
    c7: InformationObject_GT;
    c9: ElementaryEvent_GT;
    c10: OrgUnit_GT;
    c11: StartElementaryEvent_GT;
    c12: CompositeANDEvent_GT;
    c13: CompositeOREvent_GT;
    c14: CompositeXOREvent_GT;
    c19: DefaultattributeeGT;
    c20: DefaultIsAGT;
    c21: DefaultInstanceOfGT;
    c22: QueryClassGT
rule
    rIsaGT : $ forall p/IsA (p graphtype DefaultIsAGT) $;
    rInstGT : $ forall p/InstanceOf (p graphtype DefaultInstanceOfGT) $;
    rAttrGT : $ forall p/attributee (p graphtype DefaultattributeeGT) $;
    rIndGT : $ forall p/Individual (p graphtype DefaultIndividualGT) $;
    rQueryClass : $ forall c/QueryClass (c graphtype QueryClassGT) $
end


BusinessFunction_GT in Class,JavaGraphicalType with
property
	bgcolor : "150,150,255";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.RoundRectangle";
	fontstyle : "italic"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 20
rule
     gtrule: $ forall x/BusinessFunction (x graphtype BusinessFunction_GT) $

end


InformationObject_GT in Class,JavaGraphicalType with
property
	bgcolor : "200,200,255";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.Rect";
	fontstyle : "bold,italic";
      edgewidth : "3"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 22
rule
     gtrule: $ forall x/InformationObject (x graphtype InformationObject_GT) $
end

                  
ElementaryEvent_GT in Class,JavaGraphicalType with
property
	bgcolor : "150,150,255";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.Hexagon";
	fontstyle : "italic"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 24
rule
     gtrule: $ forall x/ElementaryEvent (x graphtype ElementaryEvent_GT) $

end

{* Start events get a lighter blue color *}
StartElementaryEvent_GT in Class,JavaGraphicalType with
property
	bgcolor : "220,220,255";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.Hexagon";
	fontstyle : "italic"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 25
rule
     gtrule: $ forall x/ElementaryEvent (x in StartEvent) ==> 
                 (x graphtype StartElementaryEvent_GT) $

end


                  
OrgUnit_GT in Class,JavaGraphicalType with
property
	bgcolor : "150,150,255";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.Ellipse";
	fontstyle : "italic";
      linewidth : "3"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 26
rule
     gtrule: $ forall x/OrganizationalUnit (x graphtype OrgUnit_GT) $

end

                        
CompositeANDEvent_GT in Class,JavaGraphicalType with
property
	bgcolor : "150,150,255";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.Ellipse";
      label: "AND"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 30
rule
     gtrule: $ forall x/CompositeEvent 
                 (x operator AND_OP) ==> (x graphtype CompositeANDEvent_GT) $

end


CompositeOREvent_GT in Class,JavaGraphicalType with
property
	bgcolor : "150,150,255";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.Ellipse";
      label: "OR"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 30
rule
     gtrule: $ forall x/CompositeEvent 
                 (x operator OR_OP) ==> (x graphtype CompositeOREvent_GT) $

end

CompositeXOREvent_GT in Class,JavaGraphicalType with
property
	bgcolor : "150,150,255";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.Ellipse";
      label: "XOR"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 30
rule
     gtrule: $ forall x/CompositeEvent 
                 (x operator XOR_OP) ==> (x graphtype CompositeXOREvent_GT) $

end






```

=== `03-ERD-advanced.sml.txt`

```telos
{*
* File ERD-advanced.sml
* Author: Manfred Jeusfeld, jeusfeld@uvt.nl
* Date: 26-Oct-1999 (19-Oct-2004)
*----------------------------------------------------------------
* This file specifies a version of the ERD notation
* that includes the so-called EntRelType
* 19-Oct-2004: adpated for linking to EPC.sml
*}


{*** the simple notation definition level of *}

Node with
  attribute
    connectedTo: Node
end


{*** this defines a simple version of the ER notation *}

EntityType in Node with 
  connectedTo
    ent_attr: Domain    {* we now define entity attributes as a property of the ER notation *}
end

RelationshipType in Node with
  connectedTo
     role: EntityType
end

EntRelType in Node isA EntityType,RelationshipType with
end

{* Of course, 'Domain' must be defined: *}

Domain in Node with
end




{*** this defines an example ER diagram using the above ER notation *}


Customer in EntityType 
end 

Item in EntityType 
end 

Order in EntRelType with 
  attribute,role
     r1 : Item;
     r2 : Customer
end


{* following the definition of known domains for entity attributes: *}

Integer in Domain with
end

String in Domain with
end

Date in Domain with 
end

String isA Date with 
end  {* this is a trick to accept any string as date *}




```

=== `05-ERD-advanced-GTs.sml.txt`

```telos
{
*
* File: ERD-advanced-GTs.sml
* Author: Manfred Jeusfeld
* Creation: 3-Sep-2004
* ----------------------------------------------------------------------
* 
* graphical types for the ERD-advanced model
}


Class ERD_Advanced_Palette in JavaGraphicalPalette with
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
    c6: MetaEntityType_GT;
    c7: MetaRelationshipType_GT;
    c9: EntityType_GT;
    c10: RelationshipType_GT;
    c12: Entity_GT;
    c13: Relationship_GT;
    c19: DefaultattributeeGT;
    c20: DefaultIsAGT;
    c21: DefaultInstanceOfGT;
    c22: QueryClassGT;
    c23: MetaEntityRelationshipType_GT;
    c24: EntityRelationshipType_GT;
    c25: EntityRelationship_GT
rule
    rIsaGT : $ forall p/IsA (p graphtype DefaultIsAGT) $;
    rInstGT : $ forall p/InstanceOf (p graphtype DefaultInstanceOfGT) $;
    rAttrGT : $ forall p/attributee (p graphtype DefaultattributeeGT) $;
    rIndGT : $ forall p/Individual (p graphtype DefaultIndividualGT) $;
    rQueryClass : $ forall c/QueryClass (c graphtype QueryClassGT) $
end





EntityType with
  graphtype
    gt: MetaEntityType_GT
end


RelationshipType with
  graphtype
    gt: MetaRelationshipType_GT
end

EntRelType with
  graphtype
    gt2: MetaEntityRelationshipType_GT 
end



MetaEntityType_GT in JavaGraphicalType with
property
	bgcolor : "255,255,255";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.Rect"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 22
end


Class MetaRelationshipType_GT in JavaGraphicalType with
property
      bgcolor : "255,255,255";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.Diamond";
	fontstyle : "italic"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 35
end

Class MetaEntityRelationshipType_GT in JavaGraphicalType with
property
      bgcolor : "255,255,255";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.Octagon";
	fontstyle : "italic"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 38
end


EntityType_GT in Class,JavaGraphicalType with
property
	bgcolor : "255,100,255";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.Rect";
	fontstyle : "italic"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 20
rule
     gtrule: $ forall E/EntityType (E graphtype EntityType_GT) $

end



Class RelationshipType_GT in JavaGraphicalType with
property
      bgcolor : "255,100,255";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.Diamond";
	fontstyle : "italic"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 34
rule
   gtrule: $ forall R/RelationshipType (R graphtype RelationshipType_GT) $
end

Class EntityRelationshipType_GT in JavaGraphicalType with
property
      bgcolor : "255,100,255";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.Octagon";
	fontstyle : "italic"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 40
rule
   gtrule: $ forall R/EntRelType (R graphtype EntityRelationshipType_GT) $
end


Entity_GT in Class,JavaGraphicalType with
property
	bgcolor : "50,50,50";
	textcolor : "230,230,230";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.Rect";
	fontstyle : "italic"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 18
rule
   gtrule: $ forall e/VAR (exists E/EntityType (e in E)) ==> (e graphtype Entity_GT) $
end


Class Relationship_GT in JavaGraphicalType with
property
      bgcolor : "50,50,50";
	textcolor : "230,230,230";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.Diamond";
	fontstyle : "italic"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 28
rule
    trule: $ forall r/VAR (exists R/RelationshipType (r in R)) ==> (r graphtype Relationship_GT) $
end

Class EntityRelationship_GT in JavaGraphicalType with
property
      bgcolor : "50,50,50";
	textcolor : "230,230,230";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.Octagon";
	fontstyle : "italic"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 41
rule
    trule: $ forall r/VAR (exists R/EntRelType (r in R)) ==> (r graphtype EntityRelationship_GT) $
end



```

=== `05-LinkEPC-ERD.sml.txt`

```telos
{
* File: LinkEPC-ERD.sml
* Author: Manfred Jeusfeld
* Created: 19-Oct-2004/M.Jeusfeld (19-Oct-2004/M.Jeusfeld)
* ------------------------------------------------------
* Linkage between EPC and ERD-advanced
* load as last file
*
}



{* NL *}


{* link information object to entity relationship diagrams *}

ObjectType in Node end

EntityType isA ObjectType end
RelationshipType isA ObjectType end

ERD in Model with
  contains
    containsObjectType: ObjectType
end

InformationObject in Model isA ERD end


{* ML *}

OrdersDB with 
  containsObjectType
     ob1 : Order;
     ob2 : Customer;
     ob3 : Item
end 


```

== Graph files

- `epc-erd-layout.gel`

== Shell output

```text
=== HOW-TO: model-event-process-chains-epcs ===

>>> Telling ./01-EPC.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>yes
[localhost:4001]>
>>> Telling ./02-EPC-GTs.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>no
[localhost:4001]>
>>> Telling ./03-ERD-advanced.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>yes
[localhost:4001]>
>>> Telling ./05-ERD-advanced-GTs.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>no
[localhost:4001]>
>>> Telling ./05-LinkEPC-ERD.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>yes
[localhost:4001]>
```

== Interpretation

The Nix check completes without CBShell or cbserver errors. Review `yes`/`no` responses in the log for tell outcomes.
