= Model The Entity Relationship Model

Verified independently via:

```bash
nix build .#checks.x86_64-linux.model-the-entity-relationship-model
```

== Input

=== `01-ERD-Language.sml.txt`

```telos
{*
* File 01-ERD-Language.sml
* Author: Manfred Jeusfeld, jeusfeld@uvt.nl
* Date: 7-Dec-2012 (7-Dec-2012)
*----------------------------------------------------------------
* This model file specifies the ERD notation, actually as complete as possible with
* ConceptBase
*
* (c) 2008 by M. Jeusfeld. 
* This model file is licensed under the terms of attributeion-Non-Commercial 2.0 Germany 
*   http://creativecommons.org/licenses/by-nc/2.0/de/legalcode  (German)
*   http://creativecommons.org/licenses/by-nc/2.0/legalcode     (generic)
* A summary of your rights and obligations concerning this work is available from
*   http://creativecommons.org/licenses/by-nc/2.0/de/deed.en_GB
* Extended rights can be obtained via the author.
*
* Requires ConceptBase 7.4 or later.
*
*}


{* some useful additions to system classes *}

QueryClass isA MSFOLrule end  {* for close integration with IC test *}

Class Concept with
   attribute
     singleDef: Concept;
     necessaryDef: Concept
  constraint
     single_IC: $ forall AC/Concept!singleDef a,b,c/Proposition
                 (a in AC) and (b in AC) and From(a,c) and From(b,c)  ==> (a == b) $;
     necessary_IC: $ forall AC/Concept!necessaryDef C,D/Concept M/VAR c/Proposition
                  P(AC,C,M,D) and (c in C) ==> exists a/Proposition (a in AC) and From(a,c) $;
     notUserDefined_IC: $ forall ac/Proposition!deducedOnly not exists a/attributee (a in ac) $;
     disjoint_IC: $ forall pair/Proposition!disjointTo x,f,t/Proposition From(pair,f) and To(pair,t)
                    and (x in f) ==> not (x in t) $
end

Individual Proposition with
  attribute
    deducedOnly: Proposition;  {* used to make sure that some attributes are only derived *}
    disjointTo: Proposition    {* expresses that some classes (or attribute categories) do not share any instance *}
end

Proposition with
  attribute
    cardinalityTag: Proposition
end






{* -------------------------------------------------------------------------- *}
{* Define the ERD notation:                                                   *}
{*  entity types, relationship types, IsA types, cardinality tags, attributes *}
{* -------------------------------------------------------------------------- *}

Concept EntityType with
  attribute
    attr: Domain;
    key: Domain;   {* some attributes are key attributes *}
    superType: EntityType  {* only used for defining the semaantics of the IsaType *}
end


Concept RelationshipType with
  attribute
    role: EntityType;
    "1..n": EntityType;
    "2..n": EntityType;
    "1..1": EntityType;
    "0..1": EntityType;
    "0..2": EntityType;
    "0..n": EntityType;
    "n..m": EntityType
end



RelationshipType!"1..n" in Proposition!cardinalityTag end
RelationshipType!"2..n" in Proposition!cardinalityTag end
RelationshipType!"1..1" in Proposition!cardinalityTag end
RelationshipType!"0..1" in Proposition!cardinalityTag end
RelationshipType!"0..2" in Proposition!cardinalityTag end
RelationshipType!"0..n" in Proposition!cardinalityTag end
RelationshipType!"n..m" in Proposition!cardinalityTag end

{* This one is what Yourdan calls an associative object type *}
Concept EntityRelationshipType in Class isA EntityType,RelationshipType
end

Concept IsaType in Class with
  attribute 
    sub: EntityType;
    super: EntityType
end


Concept Domain with
end


Domain Date
end

Domain String
end

Domain Integer
end

Domain Real
end




{* the 'superType' attribute of EntityType is not used by the modeler. It's just derived *}
{* by a rule to help define the semantics of the IsaType concept.                        *}
EntityType with
  deducedOnly
    superType: EntityType
end


{* A specialization has exactly one super entity type and at least one sub entity type *}
IsaType with
  necessaryDef 
    sub: EntityType
  singleDef,necessaryDef 
    super: EntityType
end





{* define ERDModel as container of ERD elements *}

ERDElement end
EntityType isA ERDElement end
RelationshipType isA ERDElement end
RelationshipType!role isA ERDElement end
IsaType isA ERDElement end
IsaType!sub isA ERDElement end
IsaType!super isA ERDElement end
Domain isA ERDElement end
EntityType!attr isA ERDElement end

ERDModel in Class with
  attribute
    contains: ERDElement
  rule
    r1: $ forall e/EntityType m/ERDModel a/EntityType!attr
             (m contains e) and Ai(e,attr,a) ==> (m contains a) $;
    r2: $ forall e/IsaType m/ERDModel a/IsaType!sub
             (m contains e) and Ai(e,sub,a) ==> (m contains a) $;
    r3: $ forall e/IsaType m/ERDModel a/IsaType!super
             (m contains e) and Ai(e,super,a) ==> (m contains a) $;
    r4: $ forall e/RelationshipType m/ERDModel a/RelationshipType!role
             (m contains e) and Ai(e,role,a) ==> (m contains a) $
end







```

=== `02-ERD-Syntax.sml.txt`

```telos

{
*
* File: 2_ERD_Syntax.sml
* Author: Manfred Jeusfeld
* Creation: 6-Dec-1996 (13-Mar-2002)
* ----------------------------------------------------------------------
* 
}

Individual Proposition with
  attribute
    deducedOnly: Proposition;  {* used to make sure that some attributes are only derived *}
    disjointTo: Proposition    {* expresses that some classes (or attribute categories) do not share any instance *}
end


{* We define at meta meta class level some language constructs to express constraints at *}
{* the model level. That means: we constrain the set of allowed ER diagrams (=syntax     *}
{* constraints). All formulas are meta-level formulas.                                   *}


Concept with
   attribute
     singleDef: Concept;
     necessaryDef: Concept
  constraint
     single_IC: $ forall AC/Concept!singleDef a,b,c/Proposition
                 (a in AC) and (b in AC) and From(a,c) and From(b,c)  ==> (a == b) $;
     necessary_IC: $ forall AC/Concept!necessaryDef C,D/Concept M/VAR c/Proposition
                  P(AC,C,M,D) and (c in C) ==> exists a/Proposition (a in AC) and From(a,c) $;
     notUserDefined_IC: $ forall ac/Proposition!deducedOnly not exists a/attributee (a in ac) $;
     disjoint_IC: $ forall pair/Proposition!disjointTo x,f,t/Proposition From(pair,f) and To(pair,t)
                    and (x in f) ==> not (x in t) $
end

{* "2..n" cardinality is mutually exclusive to "0..1" and "1..n" *}
RelationshipType!"2..n" with
  disjointTo
    o1: RelationshipType!"0..1";
    o2: RelationshipType!"1..n"
end

{* "0..2" is mutually exclusive to "0..1" *}
RelationshipType!"0..2" with
  disjointTo
    o1: RelationshipType!"0..1"
end

{* the 'superType' attribute of EntityType is not used by the modeler. It's just derived *}
{* by a rule to help define the semantics of the IsaType concept.                        *}
EntityType with
  deducedOnly
    superType: EntityType
end


{* A specialization has exactly one super entity type and at least one sub entity type *}
IsaType with
  necessaryDef 
    sub: EntityType
  singleDef,necessaryDef 
    super: EntityType
end



```

=== `03-ERD-GTs.sml.txt`

```telos

{
*
* File: 3_ERD_GTs.sml
* Author: Manfred Jeusfeld
* Creation: 15-Jun-2004 (21-Mar-2014/M. Jeusfeld)
* ----------------------------------------------------------------------
* 
* graphical types for the ERD Model; designed for Java-based Graph Editor of ConceptBase 7.6
}


Class ERD_Palette in JavaGraphicalPalette with
palproperty
	{* indicates 4 abstraction levels *}
	bgimage: "http://conceptbase.sourceforge.net/CBICONS/bgimages/levels4.png"; 
	longtitle: "ERD Model"
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
    c8: MetaDomain_GT;
    c9: EntityType_GT;
    c10: RelationshipType_GT;
    c11: Domain_GT;
    c12: Entity_GT;
    c13: Relationship_GT;
    c14: Domainvalue_GT;
    c15: MetaIsaType_GT;
    c16: IsaType_GT;
    c17: Isa_GT;
    c18: MetaAttr_GT;
    c19: DefaultattributeeGT;
    c20: DefaultIsAGT;
    c21: DefaultInstanceOfGT;
    c22: QueryClassGT;
    c23: MetaEntityRelationshipType_GT;
    c24: EntityRelationshipType_GT;
    c25: EntityRelationship_GT;
    c26: LabelledLink_GT
rule
    rIsaGT : $ forall p/IsA (p graphtype DefaultIsAGT) $;
    rInstGT : $ forall p/InstanceOf (p graphtype DefaultInstanceOfGT) $;
    rAttrGT : $ forall p/attributee (p graphtype LabelledLink_GT) $;
    rIndGT : $ forall p/Individual (p graphtype DefaultIndividualGT) $;
    rQueryClass : $ forall c/QueryClass (c graphtype QueryClassGT) $
end



EntityType with
  graphtype
    gte: MetaEntityType_GT
end


RelationshipType with
  graphtype
    gtr: MetaRelationshipType_GT
end

IsaType with
  graphtype
    gt: MetaIsaType_GT
end

EntityRelationshipType with
  graphtype
    gter: MetaEntityRelationshipType_GT
end


Domain with
  graphtype
    gt: MetaDomain_GT
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



Class MetaIsaType_GT in JavaGraphicalType with
property
      bgcolor : "255,255,255";
	textcolor : "0,0,0";
	linecolor : "200,200,0";
      linewidth: "3";
	shape : "i5.cb.graph.shapes.Diamond";
	fontstyle : "italic"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 36
end



MetaDomain_GT  in JavaGraphicalType with
property
	bgcolor : "255,255,255";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.Ellipse"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 24
end


MetaAttr_GT  in JavaGraphicalType with 
  attribute,property
     textcolor : "0,0,0";
     edgecolor : "200,0,200";
     edgewidth : "2"
  attribute,implementedBy
     implBy : "i5.cb.graph.cbeditor.CBLink"
end 



EntityType_GT in Class,JavaGraphicalType with
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
     gtrule: $ forall E/EntityType (E graphtype EntityType_GT) $

end


Class RelationshipType_GT in JavaGraphicalType with
property
      bgcolor : "255,255,155";
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
      bgcolor : "255,255,155";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.Octagon";
	fontstyle : "italic"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 40
rule
   gtrule: $ forall R/EntityRelationshipType (R graphtype EntityRelationshipType_GT) $
end


 
Class IsaType_GT in JavaGraphicalType with
property
      bgcolor : "255,255,155";
	textcolor : "0,0,0";
	linecolor : "200,200,0";
      linewidth: "3";
	shape : "i5.cb.graph.shapes.Diamond";
	fontstyle : "italic"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 30
rule
    gtrule: $ forall R/IsaType (R graphtype IsaType_GT) $
end

 

Class Domain_GT  in JavaGraphicalType with
property
	bgcolor : "230,230,230";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.Ellipse"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 22
rule
   gtrule: $ forall D/Domain (D graphtype Domain_GT) $
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
    trule: $ forall r/VAR (exists R/EntityRelationshipType (r in R)) ==> (r graphtype EntityRelationship_GT) $
end



Class Isa_GT in JavaGraphicalType with
property
      bgcolor : "50,50,50";
	textcolor : "230,230,100";
	linecolor : "200,200,0";
      linewidth: "3";
	shape : "i5.cb.graph.shapes.Diamond";
	fontstyle : "italic"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 25
rule
     gtrule: $ forall r/VAR (exists R/IsaType (r in R)) ==> (r graphtype Isa_GT) $
end




Class Domainvalue_GT in JavaGraphicalType with
property
	bgcolor : "100,100,100";
	textcolor : "255,250,250";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.Ellipse"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 14
rule
   gtrule: $ forall d/VAR (exists D/Domain (d in D)) ==> (d graphtype Domainvalue_GT) $
end


{* all attributes get this graphical type *}
{* the filler for bgcolor makes sure that attribute labels are painted with bgcolor as background *}
LabelledLink_GT in JavaGraphicalType,Class with 
  attribute,property
     textcolor : "0,0,0";
     edgecolor : "50,50,50";
     edgewidth : "2";
     bgcolor : "255,255,237"  {* this is also the bgcolor of the bgimage of this palette *}
  attribute,implementedBy
     implBy : "i5.cb.graph.cbeditor.CBLink"
  attribute,priority
     p : 21
end 





```

=== `03-ERD-GTs-UML.sml.txt`

```telos

{
*
* File: 3_ERD_GTs.sml
* Author: Manfred Jeusfeld
* Creation: 15-Jun-2004 (21-Mar-2014/M. Jeusfeld)
* ----------------------------------------------------------------------
* 
* graphical types for the ERD Model; designed for Java-based Graph Editor of ConceptBase 7.6
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




Class ERD_Palette in JavaGraphicalPalette isA XPalette with
palproperty
	{* indicates 4 abstraction levels *}
	bgimage: "http://conceptbase.sourceforge.net/CBICONS/bgimages/levels4.png"; 
	longtitle: "ERD Model"
contains
    c6: MetaEntityType_GT;
    c7: MetaRelationshipType_GT;
    c8: MetaDomain_GT;
    c9: EntityType_GT;
    c10: RelationshipType_GT;
    c11: Domain_GT;
    c12: Entity_GT;
    c13: Relationship_GT;
    c14: Domainvalue_GT;
    c15: MetaIsaType_GT;
    c16: IsaType_GT;
    c17: Isa_GT;
    c18: MetaAttr_GT;
    c23: MetaEntityRelationshipType_GT;
    c24: EntityRelationshipType_GT;
    c25: EntityRelationship_GT;
    c26: LabelledLink_GT
end

Class UML_Palette in JavaGraphicalPalette isA XPalette with
palproperty
    {* indicates 4 abstraction levels *}
    bgimage: "http://conceptbase.sourceforge.net/CBICONS/bgimages/levels4.png"; 
    longtitle: "ERD/UML Model"
contains
    c1: WhiteRect_GT;
    c26: LabelledLink_GT
end




EntityType with
  graphtype
    gte: MetaEntityType_GT
end


RelationshipType with
  graphtype
    gtr: MetaRelationshipType_GT
end

IsaType with
  graphtype
    gt: MetaIsaType_GT
end

EntityRelationshipType with
  graphtype
    gter: MetaEntityRelationshipType_GT
end


Domain with
  graphtype
    gt: MetaDomain_GT
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



Class MetaIsaType_GT in JavaGraphicalType with
property
      bgcolor : "255,255,255";
	textcolor : "0,0,0";
	linecolor : "200,200,0";
      linewidth: "3";
	shape : "i5.cb.graph.shapes.Diamond";
	fontstyle : "italic"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 36
end



MetaDomain_GT  in JavaGraphicalType with
property
	bgcolor : "255,255,255";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.Ellipse"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 24
end


MetaAttr_GT  in JavaGraphicalType with 
  attribute,property
     textcolor : "0,0,0";
     edgecolor : "200,0,200";
     edgewidth : "2"
  attribute,implementedBy
     implBy : "i5.cb.graph.cbeditor.CBLink"
end 



EntityType_GT in Class,JavaGraphicalType with
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
     gtrule: $ forall E/EntityType (E graphtype EntityType_GT) $

end


Class RelationshipType_GT in JavaGraphicalType with
property
      bgcolor : "255,255,155";
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
      bgcolor : "255,255,155";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.Octagon";
	fontstyle : "italic"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 40
rule
   gtrule: $ forall R/EntityRelationshipType (R graphtype EntityRelationshipType_GT) $
end


 
Class IsaType_GT in JavaGraphicalType with
property
      bgcolor : "255,255,155";
	textcolor : "0,0,0";
	linecolor : "200,200,0";
      linewidth: "3";
	shape : "i5.cb.graph.shapes.Diamond";
	fontstyle : "italic"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 30
rule
    gtrule: $ forall R/IsaType (R graphtype IsaType_GT) $
end

 

Class Domain_GT  in JavaGraphicalType with
property
	bgcolor : "230,230,230";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.Ellipse"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 22
rule
   gtrule: $ forall D/Domain (D graphtype Domain_GT) $
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
    trule: $ forall r/VAR (exists R/EntityRelationshipType (r in R)) ==> (r graphtype EntityRelationship_GT) $
end



Class Isa_GT in JavaGraphicalType with
property
      bgcolor : "50,50,50";
	textcolor : "230,230,100";
	linecolor : "200,200,0";
      linewidth: "3";
	shape : "i5.cb.graph.shapes.Diamond";
	fontstyle : "italic"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 25
rule
     gtrule: $ forall r/VAR (exists R/IsaType (r in R)) ==> (r graphtype Isa_GT) $
end




Class Domainvalue_GT in JavaGraphicalType with
property
	bgcolor : "100,100,100";
	textcolor : "255,250,250";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.Ellipse"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 14
rule
   gtrule: $ forall d/VAR (exists D/Domain (d in D)) ==> (d graphtype Domainvalue_GT) $
end


{* all attributes get this graphical type *}
{* the filler for bgcolor makes sure that attribute labels are painted with bgcolor as background *}
LabelledLink_GT in JavaGraphicalType,Class with 
  attribute,property
     textcolor : "0,0,0";
     edgecolor : "50,50,50";
     edgewidth : "2";
     bgcolor : "255,255,237"  {* this is also the bgcolor of the bgimage of this palette *}
  attribute,implementedBy
     implBy : "i5.cb.graph.cbeditor.CBLink"
  attribute,priority
     p : 21
end 



DefaultattributeeGT with
  property
     bgcolor : "255,255,237"  {* this is also the bgcolor of the bgimage of this palette *}
end

{* for UMLish representation *}
WhiteRect_GT in Class,JavaGraphicalType with
property
    bgcolor : "255,255,255";
    textcolor : "0,0,0";
    linecolor : "0,0,0";
    shape : "i5.cb.graph.shapes.Rect";
    size : "resizable";
    align: "top"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 30
rule
   gtrule1: $ forall d/VAR (exists D/Domain (d in D)) ==> (d graphtype WhiteRect_GT) $;
   gtrule2: $ forall r/VAR (exists R/EntityRelationshipType (r in R)) ==> (r graphtype WhiteRect_GT) $;
   gtrule3: $ forall r/VAR (exists R/RelationshipType (r in R)) ==> (r graphtype WhiteRect_GT) $;
   gtrule4: $ forall D/Domain (D graphtype WhiteRect_GT) $;
   gtrule5: $ forall D/EntityType (D graphtype WhiteRect_GT) $;
   gtrule6: $ forall D/RelationshipType (D graphtype WhiteRect_GT) $;
   gtrule7: $ (EntityType graphtype WhiteRect_GT) $;
   gtrule8: $ (RelationshipType graphtype WhiteRect_GT) $;
   gtrule9: $ (Domain graphtype WhiteRect_GT) $;
   gtrule10: $ (EntityRelationshipType graphtype WhiteRect_GT) $;
   gtrule11: $ forall e/VAR (exists E/EntityType (e in E)) ==> (e graphtype WhiteRect_GT) $;
   gtrule12: $ (Concept graphtype WhiteRect_GT) $
end







```

=== `04-ERD-Semantics.sml.txt`

```telos

{
*
* File: 04-ERD-Semantics.sml
* Author: Manfred Jeusfeld
* Creation: 6-Dec-1996 (7-Dec-2012)
* ----------------------------------------------------------------------
* 
* (c) 2012 by M. Jeusfeld. 
* This model file is licensed under the terms of attributeion-Non-Commercial 2.0 Germany 
*   http://creativecommons.org/licenses/by-nc/2.0/de/legalcode  (German)
*   http://creativecommons.org/licenses/by-nc/2.0/legalcode     (generic)
* A summary of your rights and obligations concerning this work is available from
*   http://creativecommons.org/licenses/by-nc/2.0/de/deed.en_GB
* Extended rights can be obtained via the author.
}


{
* The following four constraints define the semantics of the
* cardinality categories '"0..1"' (at most 1 filler), '"0..2"' (at most
* 2 fillers), '"1..n"' (at least 1 filler) and '"2..n"' (at least two
* fillers). Note that all constraints range over object attributes a1,a2 etc.
* at the data level.
}

Class RelationshipType with
  constraint
    ic_max1: $ forall A/RelationshipType!"0..1" a1,a2,r/Proposition
                   (a1 in A) and From(a1,r) and
                   (a2 in A) and From(a2,r)
                ==> (a1 == a2) $;
    ic_max2: $ forall A/RelationshipType!"0..2" a1,a2,a3,r/Proposition
                   (a1 in A) and From(a1,r) and
                   (a2 in A) and From(a2,r) and
                   (a3 in A) and From(a3,r)
                ==> (a1 == a2) or (a1 == a3) or (a2 == a3) $;
    ic_min1: $ forall A/RelationshipType!"1..n" R/RelationshipType r/Proposition
                From(A,R) and (r in R) 
               ==> exists a1/Proposition (a1 in A) and From(a1,r) $;
    ic_min2: $ forall A/RelationshipType!"2..n" R/RelationshipType r/Proposition
                From(A,R) and (r in R) 
               ==> (exists a1,a2/Proposition (a1 in A) and From(a1,r) and
                                             (a2 in A) and From(a2,r) and
                                             not (a1 == a2) ) $
end


{
* The semantics of the 'Isa' relationship type is declared as 
* inheritance of entity type membership. The first rule derives a
* predicate (E1 superType E2), the second uses this predicate to 
* derive membership to the super entity type.
* Again note that the variable 'e' stands for an instance of
* some entity type like 'Employee'. Thus, these two user-defined
* rules actually define the semantics of 'Isa'!
}

IsaType with
  rule
    makeBinaryRel: $ forall I/IsaType E1,E2/EntityType
                        (I sub E1) and (I super E2)  ==> (E1 superType E2) $;
    membershipRule: $ forall e/VAR E,D/EntityType
                       (e in D) and (D superType E) ==> (e in E) $
end



```

=== `05-ERD-graphviz2.sml.txt`

```telos
{*
* File ERD-graphviz2.sml
* Author: Manfred Jeusfeld, jeusfeld@uvt.nl
* Date: 5-Jun-2008 (9-Jul-2008)
*----------------------------------------------------------------
* This model file specifies the ERD notation and provides and
* export filter for graphviz.
* Steps:
*  1- Load this model into ConceptBase
*  2- Load the example model UniversityModel.sml into ConceptBase
*  3- Ask the query ShowERD[UniversityModel/erd]
*  4- Copy/paste the answer to a file graphviz-input.dot
*  5- Call Graphviz, e.g. by
*       neato -Tpng graphviz-input.dot > graphviz-output.png
* Use the manual pages of dot or neato to learn more about options of Graphviz.
* Graphviz is available from http://graphviz.org/
*
* (c) 2008 by M. Jeusfeld. 
* This model file is licensed under the terms of attributeion-Non-Commercial 2.0 Germany 
*   http://creativecommons.org/licenses/by-nc/2.0/de/legalcode  (German)
*   http://creativecommons.org/licenses/by-nc/2.0/legalcode     (generic)
* A summary of your rights and obligations concerning this work is available from
*   http://creativecommons.org/licenses/by-nc/2.0/de/deed.en_GB
* Extended rights can be obtained via the author.
*
* Requires ConceptBase 7.1.2 released 9-Jul-2008 or later.
*
*}


{* -------------------------------------------------------------------------- *}
{* Define the ERD notation:                                                   *}
{*  entity types, relationship types, IsA types, cardinality tags, attributes *}
{* -------------------------------------------------------------------------- *}

EntityType with
  attribute
    attr: Domain;
    key: Domain;   {* some attributes are key attributes *}
    superType: EntityType  {* only used for defining the semaantics of the IsaType *}
end


RelationshipType with
  attribute
    role: EntityType;
    "1..n": EntityType;
    "1..1": EntityType;
    "0..1": EntityType;
    "0..n": EntityType;
    "n..m": EntityType
end


Proposition with
  attribute
    cardinalityTag: Proposition
end


RelationshipType!"1..n" in Proposition!cardinalityTag end
RelationshipType!"1..1" in Proposition!cardinalityTag end
RelationshipType!"0..1" in Proposition!cardinalityTag end
RelationshipType!"0..n" in Proposition!cardinalityTag end
RelationshipType!"n..m" in Proposition!cardinalityTag end

{* This one is what Yourdan calls an associative object type *}
EntityRelationshipType in Class isA EntityType,RelationshipType
end

IsaType in Class with
  attribute 
    sub: EntityType;
    super: EntityType
end


Domain with
end

{* -------------------------------------------------------------------------- *}
{* ERD elements are just all elements that can occur in an ER diagram         *}
{* -------------------------------------------------------------------------- *}

ERDElement end
EntityType isA ERDElement end
RelationshipType isA ERDElement end
RelationshipType!role isA ERDElement end
IsaType isA ERDElement end
IsaType!sub isA ERDElement end
IsaType!super isA ERDElement end
Domain isA ERDElement end
EntityType!attr isA ERDElement end

ERDModel in Class with
  attribute
    contains: ERDElement
  rule
    r1: $ forall e/EntityType m/ERDModel a/EntityType!attr
             (m contains e) and Ai(e,attr,a) ==> (m contains a) $;
    r2: $ forall e/IsaType m/ERDModel a/IsaType!sub
             (m contains e) and Ai(e,sub,a) ==> (m contains a) $;
    r3: $ forall e/IsaType m/ERDModel a/IsaType!super
             (m contains e) and Ai(e,super,a) ==> (m contains a) $;
    r4: $ forall e/RelationshipType m/ERDModel a/RelationshipType!role
             (m contains e) and Ai(e,role,a) ==> (m contains a) $
end




{* -------------------------------------------------------------------------- *}
{* We  support the following graphical notation for ERDs:                     *}
{* Entity types                 --> boxes                                     *}
{* Relationship types           --> diamonds                                  *}
{* Entityrelationship types     --> squared diamonds                          *}
{* IsA types                    --> diamonds with grey color                  *}
{* entity attributes            --> ellipses                                  *}
{* key attributes               --> ellipses with double lines                *}
{* roles links                  --> undirected links                          *}
{* links to subtypes            --> undirected links                          *}
{* links to supertypes          --> undirected links with a bar               *}
{* attribute links              --> undirected links                          *}
{* -------------------------------------------------------------------------- *}

GraphVizType end

Boxnode in GraphVizType,Class with
  rule
    r1: $ forall n/EntityType not (n in EntityRelationshipType) ==> (n in Boxnode) $
end
Diamondnode in GraphVizType,Class with
  rule
    r1: $ forall n/RelationshipType not (n in EntityType) ==> (n in Diamondnode) $
end
Mdiamondnode in GraphVizType,Class with
  rule
    r1: $ forall n/EntityRelationshipType (n in Mdiamondnode) $
end
Filleddiamondnode in GraphVizType,Class with
  rule
    r1: $ forall n/IsaType (n in Filleddiamondnode) $
end
Ellipsenode in GraphVizType,Class with
  rule
    r1: $ forall n/EntityType!attr not (n in EntityType!key) ==> (n in Ellipsenode) $
end
Dellipsenode in GraphVizType,Class with
  rule
    r1: $ forall n/EntityType!key (n in Dellipsenode) $
end
Link in GraphVizType,Class with
  rule
    r1: $ forall l/RelationshipType!role (l in Link) $;
    r2: $ forall l/IsaType!sub (l in Link) $
end
LinkTee in GraphVizType,Class with
  rule
    r1: $ forall l/IsaType!super (l in LinkTee) $
end
LinkAttr in GraphVizType,Class with
  rule
    r1: $ forall l/EntityType!attr (l in LinkAttr) $
end


{* -------------------------------------------------------------------------- *}
{* LinkLabel returns the cardinality tag of a role link; if the tag is        *}
{* undefined then the empty string is returned.                               *}
{* -------------------------------------------------------------------------- *}

Function LinkLabel isA Label with
  parameter
     li: Link
  constraint
     cfn: $ (exists tag1/Proposition!cardinalityTag (li in RelationshipType!role) and (li in tag1) and Label(tag1,this))
            or (not exists tag2/Proposition!cardinalityTag (li in RelationshipType!role) and (li in tag2)) and (this ="")
          $
end


{* -------------------------------------------------------------------------- *}
{* ShowERD returns the parameter erd as result. This is apparently not very   *}
{* meaningful but is triggers the evaluation of the answer format script      *}
{* GraphVizErd, which coordinates the production of the answer.               *}
{* -------------------------------------------------------------------------- *}

GenericQueryClass ShowERD isA ERDModel with
  required,parameter
     erd: ERDModel
  constraint
     c1: $ (erd = this) $
end


{* -------------------------------------------------------------------------- *}
{* ShowElement(erd,type) computes those elements that are contained in a      *}
{* given ERD diagram erd and that have the given type (e.g. Boxnode).         *}
{* It is used to format all elements of an ERD to their Graphviz              *}
{* representation.                                                            *}
{* -------------------------------------------------------------------------- *}

GenericQueryClass ShowElement isA ERDModel with
  required,parameter
     erd: ERDModel;
     type: GraphVizType
  computed_attribute
     elem: ERDElement
 constraint
     c1: $ (erd = this) and
           (this contains elem) and
           (elem in type) $
end


{* -------------------------------------------------------------------------- *}
{* GraphVizErd coordinates the production of all Graphviz code for an ER      *}
{* diagram. It does so by calling ShowElement for all supported types.        *}
{* -------------------------------------------------------------------------- *}

GraphVizErd in AnswerFormat with
  forQuery q: ShowERD
  head h: 
"# Generated by ConceptBase {cb_version} at {transactiontime}
# Process this file by Graphviz, e.g. 
#    neato -Tpng thisfile.txt > thisfile.png

"
  pattern p:
"graph {this} \{
{ASKquery(ShowElement[{this}/erd,Boxnode/type],BOXNODE_FORMAT)}
{ASKquery(ShowElement[{this}/erd,Diamondnode/type],DIAMONDNODE_FORMAT)}
{ASKquery(ShowElement[{this}/erd,Mdiamondnode/type],MDIAMONDNODE_FORMAT)}
{ASKquery(ShowElement[{this}/erd,Dellipsenode/type],DELLIPSENODE_FORMAT)}
{ASKquery(ShowElement[{this}/erd,Ellipsenode/type],ELLIPSENODE_FORMAT)}
{ASKquery(ShowElement[{this}/erd,Filleddiamondnode/type],FILLEDDIAMONDNODE_FORMAT)}
{ASKquery(ShowElement[{this}/erd,link/type],LINK_FORMAT)}
{ASKquery(ShowElement[{this}/erd,LinkTee/type],LINKTEE_FORMAT)}
{ASKquery(ShowElement[{this}/erd,LinkAttr/type],LINKATTR_FORMAT)}
overlap=false
label=\"ERD Model {this}\\\nExtracted from ConceptBase and layed out by Graphviz (neato) \"
fontsize=12;
\}
"
end


{* -------------------------------------------------------------------------- *}
{* The following answer formats are linked one-to-one to the supported        *}
{* Graphviz types (Boxnode,...).                                              *}
{* Note that a given ERD referenced by 'this' usually has many elements of    *}
{* a given type. They are scanned by the Foreach-construct.                   *}
{* -------------------------------------------------------------------------- *}

BOXNODE_FORMAT in AnswerFormat with
pattern p: "node [shape=box]; {Foreach( ({this.elem}), (n), {n};)}"
end

DIAMONDNODE_FORMAT in AnswerFormat with
pattern p: "node [shape=diamond]; {Foreach( ({this.elem}), (d), {d};)}"
end

FILLEDDIAMONDNODE_FORMAT in AnswerFormat with
pattern p: "node [shape=diamond,style=filled,peripheries=1,color=lightgrey,label=\"isa\"]; {Foreach( ({this.elem}), (f), {f};)}"
end

ELLIPSENODE_FORMAT in AnswerFormat with
pattern p: "{Foreach( ({this.elem}), (e),node [shape=ellipse,peripheries=1,label=\"{Label({e})}\"]; {Oid({e})};\\n)}"
end

DELLIPSENODE_FORMAT in AnswerFormat with
pattern p: "{Foreach( ({this.elem}), (e),node [shape=ellipse,peripheries=2,label=\"{Label({e})}\"]; {Oid({e})};\\n)}"
end


MDIAMONDNODE_FORMAT in AnswerFormat with
pattern p: "node [shape=Mdiamond]; {Foreach( ({this.elem}), (m), {m};)}"
end

LINK_FORMAT in AnswerFormat with
pattern p: "{Foreach( ({this.elem}),(l),{From({l})}--{To({l})} [len=1.20,label={ASKquery(LinkLabel[{l}/li],LABEL)}];\\n)}"
end

LINKTEE_FORMAT in AnswerFormat with
pattern p: "{Foreach( ({this.elem}),(l),{From({l})}--{To({l})} [len=1.10,dir=forward,arrowhead=tee];\\n)}"
end

LINKATTR_FORMAT in AnswerFormat with
pattern p: "{Foreach( ({this.elem}),(l),{From({l})}--{Oid({l})} [len=1.00];\\n)}"
end




```

=== `06-UniversityModel.sml.txt`

```telos


{*** UniversityModel.sml *}
{*** this defines an example ER diagram using the ER notation *}
{*** of ERD-graphviz2.sml                                     *}


EntityType Staff with
  attr
    name: String;
    hired: Date;
    salary: Integer
  attr,key
   staffno: Integer
end

EntityType Faculty with
  attr
    since: Date;
    post: String
end

EntityType Technician with
  attr
    since: Date;
    post: String
end



EntityType Student with
  attr
    since: Date
  attr,key
    studentid: Integer
end


EntityType University with
  attr, key
   name: String;
   location: String
end

EntityType Course with
  attr,key
    courseno: Integer;
    semester: String
  attr
    title: String
end

RelationshipType employs with
  role,"0..n"
    employee: Staff
  role,"1..1"
    employer: University
end

IsaType ISA_1 with 
  sub
    sub1: Faculty;
    sub2: Technician
  super
     super1: Staff
end


RelationshipType teaches with
  role,"1..1"
    teacher: Faculty
  role
    subject: Course
end


EntityRelationshipType attends with
  role
    stud: Student;
    course: Course
  attr
    quota: Integer
end




UniversityModel in ERDModel with
  contains
    e1: Staff;
    e2: Faculty;
    e3: Technician;
    e4: Student;
    e5: University;
    e6: Course;
    e7: employs;
    e8: teaches;
    e9: attends;
    e10: ISA_1
end

```

=== `07-UniversityData.sml.txt`

```telos


{*** UniversityData.sml *}
{*** instantiates UniversityModel.sml; to be used with ERD-key.sml *}


Faculty willi with
  staffno sn: 1234
  salary s: 1000
end

Faculty mary with
  staffno sn: 2345
  salary s: 1500
end

Faculty kurt 
end

Faculty charles 
end

Faculty petra 
end

Technician harry
end

University RWTH
end

University HKUST
end

Student carla with
  studentid anr: 1234
end

employs emp1 with
  employee
    who: willi
  employer
    where: RWTH
end


employs emp2 with
  employee
    who: mary
  employer
    where: RWTH
end

employs emp3 with
  employee
    who: kurt
  employer
    where: RWTH
end

employs emp4 with
  employee
    who: charles
  employer
    where: RWTH
end

employs emp5 with
  employee
    who: petra
  employer
    where: HKUST
end



```

== Graph files

- `acrosslevels.gel`
- `acrosslevels-proposition.gel`
- `erdcomplete.gel`

== Shell output

```text
=== HOW-TO: model-the-entity-relationship-model ===

>>> Running ./createdb.cbs.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>This is CBShell, the command line interface to ConceptBase.cc
[offline]>[offline]>[offline]>[offline]>[offline]>Successfully connected to server
Successfully connected to server
[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>yes
[localhost:4001]>yes
[localhost:4001]>ERnotation
[localhost:4001]>ERnotation
[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>no
no
[localhost:4001]>[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>yes
[localhost:4001]>yes
[localhost:4001]>[localhost:4001]>[localhost:4001]>yes
[localhost:4001]>yes
[localhost:4001]>yes
[localhost:4001]>yes
[localhost:4001]>ERnotation/UModel
[localhost:4001]>ERnotation/UModel
[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>[localhost:4001]>[localhost:4001]>yes
yes
[localhost:4001]>[localhost:4001]>ERnotation/UModel/UData
[localhost:4001]>ERnotation/UModel/UData
[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>[localhost:4001]>[localhost:4001]>ERnotation/AcrossLevels
[localhost:4001]>ERnotation/AcrossLevels
[localhost:4001]>no
[localhost:4001]>no
[localhost:4001]>[localhost:4001]>[localhost:4001]>
>>> Running ./extractGV.cbs.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>This is CBShell, the command line interface to ConceptBase.cc
[offline]>[offline]>[offline]>[offline]>[offline]>Successfully connected to server
Successfully connected to server
[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>UModel
[localhost:4001]>UModel
[localhost:4001]>nil
[localhost:4001]>nil
[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>[localhost:4001]>
>>> Telling ./01-ERD-Language.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>no
[localhost:4001]>
>>> Telling ./02-ERD-Syntax.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>no
[localhost:4001]>
>>> Telling ./03-ERD-GTs-UML.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>no
[localhost:4001]>
>>> Telling ./03-ERD-GTs.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>no
[localhost:4001]>
>>> Telling ./04-ERD-Semantics.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>no
[localhost:4001]>
>>> Telling ./05-ERD-graphviz2.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>no
[localhost:4001]>
>>> Telling ./06-UniversityModel.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>no
[localhost:4001]>
>>> Telling ./07-UniversityData.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>no
[localhost:4001]>
>>> Telling ./08-AcrossLevels.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>no
[localhost:4001]>
>>> Telling ./Older variant for Model the ER Model/1_ERD_Structure.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>yes
[localhost:4001]>
>>> Telling ./Older variant for Model the ER Model/2_ERD_Syntax.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>no
[localhost:4001]>
>>> Telling ./Older variant for Model the ER Model/3_ERD_GTs.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>no
[localhost:4001]>
>>> Telling ./Older variant for Model the ER Model/4_ERD_Semantics.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>yes
[localhost:4001]>
>>> Telling ./Older variant for Model the ER Model/5_ERD_Model.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>yes
[localhost:4001]>
>>> Telling ./Older variant for Model the ER Model/6_ERD_Data.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>yes
[localhost:4001]>
```

== Interpretation

The Nix check completes without CBShell or cbserver errors. Review `yes`/`no` responses in the log for tell outcomes.
