= Define Formulas At The Meta Class Level

Verified independently via:

```bash
nix build .#checks.x86_64-linux.define-formulas-at-the-meta-class-level
```

== Input

=== `AbstractClass.sml.txt`

```telos
{*
This file is governed by the Creative Commons license
   attributeion-NonCommercial 3.0 Unported
   http://creativecommons.org/licenses/by-nc/3.0/
   http://creativecommons.org/licenses/by-nc/3.0/legalcode

Extended licenses, in particular commercial licenses, can be obtained from the
author of the source code.
Any re-distribution as source code must acknowledge the original author of this file.
*}


{
*
* File: AbstractClass.sml
* Author: Manfred Jeusfeld
* Creation: 2012-12-13 (2013-01-16/MJf)
* ----------------------------------------------------------------------
*
* Abstract classes have no explicit instances. 

*
*}


{* An abstract class is simply a class whose instances are not explicit instances.  *}
{* In particular, subclasses can have explicit instances that are then also derived *}
{* instances of the abstract class.                                                 *}
{* The predicate In_s(x,c) returns explicit instances of c, i.e. neither derived    *}
{* inherited via a subclass.                                                        *}

AbstractClass in Class with  
   constraint
     no_explicit_instance : $ forall c/AbstractClass x/Proposition 
             (x in c) ==> not In_s(x,c) $
end









{* Positive example:
   GeometricObject has no explicit instances but all instances may have an area
   The query SmallGeometricObject uses the area attribute to returns all
   geometric objects whose area is smaller than 1.0

GeometricObject in AbstractClass with
  attribute
    area: Real
end

SmallGeometricObject in QueryClass isA GeometricObject with  
  constraint
    isSmall : $ exists a/Real (this area a) and (a < 1.0) $
end 


Rectangle in Class isA GeometricObject with
  attribute
     width: Real;
     height: Real
  rule
     onArea: $ forall r/Rectangle w,h,a/Real
                 (r width w) and (r height h) and (a = w*h) ==> (r area a) $
end


Ellipse in Class isA GeometricObject with
  attribute
     majoraxis: Real;
     minoraxis: Real
  rule
     onArea: $ forall e/Ellipse a,b,ar/Real
                 (e majoraxis a) and (e minoraxis b) and (ar = 3.141592654*a*b) ==> (e area ar) $
end


Circle in Class isA Ellipse with
  attribute
     radius: Real
  rule
     mapMajor: $ forall c/Circle r/Real (c radius r) ==> (c majoraxis r) $;
     mapMinor: $ forall c/Circle r/Real (c radius r) ==> (c minoraxis r) $
end


R1 in Rectangle with
  width w: 10.5
  height h: 20.0
end

C1 in Circle with
  radius r: 5.0
end

C2 in Circle with  
  radius
    r : 0.5
end 

E1 in Ellipse with
  majoraxis a: 2.5
  minoraxis b: 1.2
end



*}

{* Negative Example:

LivingBeing in AbstractClass end

billy in LivingBeing end

*}




```

=== `EmptyNonEmpty.sml.txt`

```telos
{
*
* File: EmptyNonEmpty.sml
* Author: Manfred Jeusfeld
* Creation: 2-May-2005 (2-May-2005)
* ----------------------------------------------------------------------
* 
* Proposal to define 'empty class' and 'non empty class' either
* via a constraint of a regular class or as a query class.
* The query classes are returning those classes which are currently
* empty (non-empty). The constraints of the regular classes will
* ensure emptieness (non-emptieness).
*
}

EmptyClass in Class with 
  constraint
    classIsEmpty: $ forall c/EmptyClass not (exists x/VAR (x in c)) $
end

NonEmptyClass in Class with 
  constraint
    classIsNonEmpty: $ forall c/NonEmptyClass exists x/VAR (x in c) $
end

{* a violator of EmptyClass

Marxist in EmptyClass end

karl_marx in Marxist end

*}

{* a violator of NonEmptyClass

Philosopher in NonEmptyClass end

socrates in Philosopher end

--> untell socrates to see the effect

*}

MyClass end 
{* Essential as a range for the subsequent queries.
   If you would use Class as a range, then the computation would
   be extremely time-consuming since any query class is also
   an instance of class
*}

EmptyClassQ in QueryClass isA MyClass with
  constraint
    c1: $ not exists x/Proposition (x in ~this) $
end

NonEmptyClassQ in QueryClass isA MyClass with
  constraint
    c1: $ exists x/Proposition (x in ~this) $
end


{* some data to check the queries

Marxist in MyClass end

Philosopher in MyClass end

socrates in Philosopher end


*}




```

=== `exists-metaformula.sml.txt`

```telos
{*
This file is governed by the Creative Commons license
   attributeion-NonCommercial 3.0 Unported
   http://creativecommons.org/licenses/by-nc/3.0/
   http://creativecommons.org/licenses/by-nc/3.0/legalcode

Extended licenses, in particular commercial licenses, can be obtained from the
author of the source code.
Any re-distribution as source code must acknowledge the original author of this file.
*}



{*
* File exists-metaformula.sml
* Author: Manfred Jeusfeld
* Date: 17-Dec-2010 (17-Dec-2010)
*----------------------------------------------------------------
* Another example on how to use an intermediary deductive rule
* to allow the partial evaluation of a metaformula with metavariables
* under existential quantification.
* Here, METACLASS is a very special metaclass: It requires that it has at
* least one instance (like MyClass) that itself has an instance (like foo).
* This has hardly a real application. It just shows that metaformulas can
* also handle these tricky existential cases via an intermediary deductive
* rule.
*
*}


Proposition with
  attribute
    inViaMC: METACLASS
end

METACLASS in Class with
  constraint
    {* intended formulation 
    exists_in_in: $ exists x/Proposition C/METACLASS (x in C) $ *}
    {* working formulation *}
    exists_in_in: $ exists x/Proposition C/METACLASS (x inViaMC C) $
  rule
    intermediary_rule: $ forall x/Proposition C/METACLASS (x in C) ==> (x inViaMC C) $
end



{* the required instances: *}

MyClass in METACLASS end

foo in MyClass end

{* UNTELL foo in MyClass to see the constraint working *}


```

=== `MacroFormulas.sml.txt`

```telos
{*
This file is governed by the Creative Commons license
   attributeion-NonCommercial 3.0 Unported
   http://creativecommons.org/licenses/by-nc/3.0/
   http://creativecommons.org/licenses/by-nc/3.0/legalcode

Extended licenses, in particular commercial licenses, can be obtained from the
author of the source code.
Any re-distribution as source code must acknowledge the original author of this file.
*}

{
*
* File: MacroFormulas.sml
* Author: Manfred Jeusfeld
* Creation: 21-Jun-2007 (15-Feb-2016/MJf)
* ----------------------------------------------------------------------
*
* Situation: You have defined a modeling language by means of some meta classes.
* You would like to capture the semantics of the constructs like the
* key property of attributes of entity types. Or you would like to
* quuery the database by means of the meta classes, e.g. to find out
* which entities are sharing the same value as an attribute.
*
* This example shows how to use the predicates (x [in] mc), (x m/n y) and
* (x [m] y) as special meta formulas. Essentially, (x [in] mc) and 
* (x [m] y) are abbreviations of logical sub-formulas:
*
*   (x [in] mc) <==> exists c/VAR (x in c) and (x in mc)
*   (x [m] y) <==> exists c,d,n/VAR (x in c) and (y in d) and (c m/n d) and (x n y)
*
* These sub-formulas are indeed meta formulas in the sense of the ConceptBase User
* Manual (section The Predicative Sublanguage CBL). 
*
* This example requires ConceptBase 7.01 released after 22-Jun-2007.
}


AdditionalConstraints in Class with
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





{* ================================================================================= *}

{* Example 1: Define the extension of a concept Entity: shall have all instances of
   instances of EntityType as instances.  Analogously, define Value as the class
   of all values. Essentially, we define here the difference between entities (objects)
   and values!                            
*}

Domain in Class end
Entity in Class with
  attribute
    value: Value;
    identifier: Value
end

Value in Class end
Domain in Class with
  rule
    r1: $ forall v/VAR (v [in] Domain) ==> (v in Value) $
end


EntityType in Class with
  attribute
    field: Domain
  single
    key: Domain
  rule
    r1: $ forall e/VAR (e [in] EntityType) ==> (e in Entity) $;
    r2: $ forall va/VAR (va [in] EntityType!field) ==> (va in Entity!value) $;
    r3: $ forall kv/VAR (kv [in] EntityType!key) ==> (kv in Entity!identifier) $
end
EntityType!key isA EntityType!field end   {* key fields are also fields *}
EntityType!key isA Proposition!single end   {* key fields are always single fields here *}




Relationship in Class with
  attribute
     rolelink: Entity
end
RelationshipType in Class with
  attribute
     role: EntityType
  rule
    r1: $ forall r/VAR (r [in] RelationshipType) ==> (r in Relationship) $;
    r2: $ forall rl/VAR (rl [in] RelationshipType!role) ==> (rl in Relationship!rolelink) $
end




Employee in EntityType end
Course in EntityType with
  field
    participants: Integer
end

Project in EntityType end


bill in Employee end
MetaModeling in Course with
  participants p: 1234
end


Integer in Domain end
VARCHAR in Domain end
"ABC123" in VARCHAR end

WorksFor in RelationshipType with
  role
    toEmp: Employee;
    toProj: Project
end

proj34 in Project end

wf123 in WorksFor with
  toEmp emp: bill
  toProj proj: proj34
end




{* Ask ConceptBase to display the instances of Entity to see the effect *}
{* ConceptBase will optimize the generated code by partually evaluating *}
{* it.                                                                  *}
{* Similarily, you can ask for the instances of Value.                  *}
{* find_instances[Value/class]                                          *}
{* find_instances[Entity/class]                                         *}

{* You might also want to express a constraint that the sets of values  *}
{* and entities are disjoint. The constraint below is sufficient to do  *}
{* so. It is equivalent to the logical formula                          *}
{*    forall e not (e in Entity) or not (e in Value)                    *}
{* which is equivalent to                                               *}
{*    forall e (e in Entity) and (e in Value) ==> FALSE  (1)            *}
{* which is equivalent to                                               *}
{*    forall e/Value not (e in Entity)                                  *}
{* Since all variables need a class range in ConceptBase, we have to    *}
{* pick either Entity or Value as the class range of e though           *}
{* ConceptBase internally compiles to the format (1).                   *}
{* Consequently, the formula below is indeed symmetric for Entity vs.   *}
{* Value as class range.                                                *}

Entity in Class with 
  constraint
    disjoint: $ forall e/Entity not (e in Value) $
end


{* The following frame would lead to a violation. Note that 1234 was made 
   an instance of Integer when telling the frame 'MetaModeling' above. This
   is done atomatically by ConceptBase.
1234 in Employee end
*}

{* The following frame also leads to a violation. It's just the other way round.
bill in Value end
*}



{* ================================================================================= *}


{* Example 2: Define the key property for EntityType. We assume here that a key consists
   of exactly one attribute. Otherwise, the formulas would just be to expensive to compile
   into efficient code. But feel free to generalize the constraint to multi-attribute keys.
   Note that the macro literal (x [m] y) is not usable here since we want to use the same
   variable E,D,n in this case. For technical reasons, the literal (x [m] y) is only
   supported in query classes, i.e. not for integrity constraints and not for deductive
   rules.
*}


{* disabled because EntityWithSharedKey is more elegant 
EntityType in Class with
   constraint
    c1: $ forall e1,e2,v,n/VAR E/EntityType D/Domain
            (e1 in E) and (e2 in E) and (v in D) and (E key/n D) and (e1 n v) and (e2 n v) ==> (e1=e2) $
end
*}



Manager in EntityType with
  key
    mno: Integer
end

mary in Manager with
  mno m: 1234
end




{* While (x [m] y) is cannot be used in decuctive rules and integrity constraints due *}
{* to its too complex definition, you can well use in in query classes. For example,  *}
{* you can find out which entity is identified by which value --- independently from  *}
{* the schema definitions!                                                            *}

IdentifiedBy in GenericQueryClass isA Entity with
  parameter,computed_attribute
    value: Value
  constraint
    c: $ (~this [key] ~value) $
end


{* Ask for example IdentifiedBy[1234/value]. It should return mary. *}
{* If you ask IdentifiedBy without providing a parameter, then      *}
{* it will list all pairs of entities and their key.                *}




{* ================================================================================= *}

{* Example 3: Explore which values are shared by at least two entities, regardless of the
   entity class. Note that the entities and values are from the database level (actual
   data) whereas the query refers only to the generic concepts of Entity, Value and 
   the 'field' construct of EntityType. Hence, we can really query the database level
   from the meta class level.
*}

SharedValue in GenericQueryClass isA Value with
  parameter
    entity: Entity
  computed_attribute
    sharingEntity: Entity
  constraint
    cshare: $ (~entity [field] ~this) and (~sharingEntity [field] ~this) and not (~entity = ~sharingEntity) $
end

{* Ask SharedValue[mary/entity] or simply SharedValue to analyze the database *}
{* on shared values of entities. In our example, the value 1234 is shared     *}
{* between mary and MetaModeling                                              *}




{* Example 4: Retrieve entities that violate the key property. Note that we
   assume that an entity type has at most one key attribute here. The multi-attribute
   case is more complex.
*}

EntityWithSharedKey in QueryClass isA Entity with
  computed_attribute
    entity2: Entity;
    keyvalue: Value
  constraint
    cshare: $  (~this [key] ~keyvalue) and (~entity2 [key] ~keyvalue) and (~entity2 \= ~this) $
end

{* tell this frame to see that EntityWithSharedKey detects the clone *}
maryclone in Manager with
  mno m: 1234
end


{* Ask EntityWithSharedKey to retrieve all entities that share the key with another entity  *}


{* Alternative formulation that returns the keys that are shared by entities *}
SharedKey in QueryClass isA Value with  
  computed_attribute
    entity : Entity
  constraint
    cshare : $  exists entity2/Entity (~entity [key] ~this) 
                      and (entity2 [key] ~this) and (~entity \= entity2) $
end 


{* Example 5: Querying via Entity, Relationship and Value. These example use the
   there classes and their attributes as a schema for query the M0 level.
*}


EntityRelatedTo in GenericQueryClass isA Entity with
  computed_attribute
    entity : Entity
  constraint
    relto : $  exists r/Relationship lab1,lab2/Label (r rolelink/lab1 ~this) and 
                      (r rolelink/lab2 ~entity) and
                      (lab1 \= lab2) $
end 

BinaryRelationship in QueryClass isA Relationship with
  constraint
    binrel : $  exists e1,e2/Entity lab1,lab2/Label (~this rolelink/lab1 e1) and
                   (~this rolelink/lab2 e2) and (lab1 \= lab2) $
end 








```

=== `Meta-In2.sml.txt`

```telos
{
*
* File: Meta-In2.sml
* Author: Manfred Jeusfeld
* Creation: 16-Oct-2007 (6-Nov-2008)
* ----------------------------------------------------------------------
* 
* This small model shows the use of the macro literal (x [in] c)
* in combination with a constraint.
*
}

NodeOrLink end
EntityType in NodeOrLink end
Employee in EntityType end


{* ModelElement subsumes all instances of instances of NodeOrLink *}
ModelElement in Class with
 rule 
    rme: $ forall x/VAR (x [in] NodeOrLink) ==> (x in ModelElement) $
end

{* the following constraint is artificial and only used to show
   that the rule rme works together with a constraint
*}

MyConstraints in Class with
  constraint
    c1: $ forall e/ModelElement (e=Employee) $
end

{* tell this object to trigger a constraint violation

Project in EntityType end

}





```

=== `Meta-In.sml.txt`

```telos
{
*
* File: Meta-In.sml
* Author: Manfred Jeusfeld
* Creation: 2-Nov-2001 (27-Jun-2007)
* ----------------------------------------------------------------------
* 
* This Telos model shows that we can define 'meta formulas' that actually define
* what a metaclass is: a class whose instances have themselves instances
*
* This example is included for historical reasons. The macro literals
* (x [in] mc) and (x [m] y) provided by ConceptBase 7.01 are more
* convenient to express meta class semantics.
*
}


{* first: define an attribute category to relate token objects to their metaclasses *}

Token with
  attribute
     inMeta: MetaClass   {* shall mimic the (x [in] mc) predicate *}
end


{* The rule that derives the solutions for the new 'inMeta' construct *}
{* This rule is a meta formula: both (x in sc) and (sc in mc) are     *}
{* meta predicates since their second argument is a variable.         *}
{* Note that we utilize the builtin classes MetaClass, SimpleClass,   *}
{* and token.                                                         *}
{* Otherwise, the meta formula compiler of ConceptBase would not have *}
{* specific ranges for the partial evaluation of (sc in mc) and       *}
{* (x in sc).                                                         *}


Class MetaClass with
  rule
    rim1: $ forall x/Token mc/MetaClass (exists sc/SimpleClass (x in sc) and (sc in mc))
              ==> (x inMeta mc) $
end


{* ********************************** *}
{* Application of the [in] predicate: *}
{* ********************************** *}

{* meta classes (notation level) }

EntityType in MetaClass isA SimpleClass with
  attribute
    ent_attr: Domain
end

Domain in MetaClass isA SimpleClass end


{* simple classes (model level) *}

Integer in Domain isA Token end
String in Domain isA Token end

Person in EntityType with
  ent_attr
    salary: Integer;
    name: String
end

{* tokens (data level) *}

10000 in Integer end
15000 in Integer end
20000 in Integer end
"Maria Theresia" in String end
"William Alexander" in String end
"Anne Arbor" in String end


mary in Token,Person with
  salary s: 20000
  name n: "Maria Theresia"
end

bill in Token,Person with
  salary s: 15000
  name n: "William Alexander"
end

anne in Token,Person with
  salary s: 10000
  name n: "Anne Arbor"
end





{* a query that shows that our solution works *}

GenericQueryClass ShowMetaClasses isA MetaClass with
  parameter,computed_attribute
    obj: Token
  constraint
    c1: $ (~obj inMeta ~this) $
end

{* This query defines what an entity actually is ... *}

Entity in QueryClass isA Token with
  constraint
     c1: $ (~this inMeta EntityType) $
end

{* This query dfines what a value actually is ... *}

Value in QueryClass isA Token with
  constraint
     c1: $ (~this inMeta Domain) $
end
```

=== `ModElem.sml.txt`

```telos
{*
This file is governed by the Creative Commons license
   attributeion-NonCommercial 3.0 Unported
   http://creativecommons.org/licenses/by-nc/3.0/
   http://creativecommons.org/licenses/by-nc/3.0/legalcode

Extended licenses, in particular commercial licenses, can be obtained from the
author of the source code.
Any re-distribution as source code must acknowledge the original author of this file.
*}

{ 
*
* File: ModElem.sml
* Author: Manfred Jeusfeld
* Creation: 13-Nov-2008 (22-Dec-2010/MJf)
* ----------------------------------------------------------------------
* This file allows to perfrom connectivity analysis for models at the M1 level
* (according to the OMG MOF levels). It is important not to define the attribute linkto as
* both symmetric and transitive. Instead, we only make linkto symmetric and then define
* linkto_trans as the transitive closure of linkto. Doing this in one step would
* be formally correct but creates very inefficient code.
* Background: http://merkur.informatik.rwth-aachen.de/pub/bscw.cgi/d2616333/lect10.pdf
}


{* Very simple M3 level *}
NodeOrLink with
  attribute
    connectedTo: NodeOrLink
end 
Node isA NodeOrLink end
NodeOrLink!connectedTo isA NodeOrLink end



{* It should be noted that we do not refer to any M2 concepts explicitely. *}
{* Instead we quantify over it via the predicates (x [in] NodeOrLink) and  *}
{* (link [in] NodeOrLink!connectedTo).                                     *}
{* The predicate (x [in] mc)  can also be written as In2(x,mc) and is      *}
{* equivalent to "exists c/VAR (x in c) and (c in mc)"                     *}

ModelElement in Class with
  attribute
    linkto: ModelElement;
    linkto_trans: ModelElement
  rule
    me1: $ forall x/VAR (x [in] NodeOrLink)  ==> (x in ModelElement) $;
    me2: $ forall link/VAR (link [in] NodeOrLink!connectedTo) ==> (link in ModelElement!linkto) $;
    me3: $ forall x/ModelElement link/ModelElement (link in ModelElement!linkto) and From(link,x) ==> (x linkto link) $;
    symm: $ forall x,y/ModelElement (x linkto y) ==> (y linkto x)  $;
    copy: $ forall x,y/ModelElement (x linkto y) ==> (x linkto_trans y) $;
    trans: $ forall x,y,z/ModelElement (x linkto z) and (z linkto_trans y) ==> (x linkto_trans y) $
end


UnconnectedModelElement in GenericQueryClass isA ModelElement with  
  required,parameter
    start : ModelElement
  constraint
    uc : $ not (start linkto_trans this) $
end 

ConnectedModelElement in GenericQueryClass isA ModelElement with
  required,parameter
    start : ModelElement
  constraint
    uc : $ (start linkto_trans this) $
end 


{* example M2 level (just included to illustrate the functioning of ModelElement *}


{*
Individual ObjectType in Node isA DataType
end

Individual DataType in Node
end


EntityType in Node isA ObjectType with
connectedTo,necessary
    ent_attr : Domain
connectedTo,single
    key : Domain
end

Domain in Node
end

Integer in Domain end

EntityType!key isA EntityType!ent_attr
end

RelationshipType in Node isA ObjectType with
attribute,connectedTo,necessary
    role : EntityType
end

RelationshipType!role in NodeOrLink!connectedTo,Necessary with
attribute,connectedTo,single
    cardinality : CardinalityTag
end

CardinalityTag in Node
end
*}


{* example M1 level (just included to illustrate the functioning of ModelElement *}

{*
Course in EntityType with
  key
   coursenr: Integer
end

Student in EntityType  with
  key
   anr: Integer
end

enrollment in RelationshipType with
role
    toStud : Student;
    toCourse : Course
end

Project in EntityType end
*}

{* test the function by query calls like    *}
{*   UnconnectedModelElement[Student/start] *}
{* The answer should be: Project.           *}






```

=== `mp-ISA-complete.sml.txt`

```telos
{*
This file is governed by the Creative Commons license
   attributeion-NonCommercial 3.0 Unported
   http://creativecommons.org/licenses/by-nc/3.0/
   http://creativecommons.org/licenses/by-nc/3.0/legalcode

Extended licenses, in particular commercial licenses, can be obtained from the
author of the source code.
Any re-distribution as source code must acknowledge the original author of this file.
*}



{*
* File mp-ISA-complete.sml
* Author: Manfred Jeusfeld
* Date: 15-Dec-2010 (22-Dec-2010)
*----------------------------------------------------------------
* A solution to a meta formula probleme formulated by Michael Petit
* "Specify that in complete ISA hierarchies all instances of the
*  superclass must also be instance of at least one subclass."
*
*}


CLASS in Class end   {* for the classes of interest *}

Proposition with
   attribute
     inSubRel: CLASS
end

{* a generic ISA construct without constraints on the instances *}

ISA in Class with
  single,necessary
     super: CLASS
  necessary
     sub: CLASS
  {* intermediary rule to handle the existential quantification of the meta variable SUBC *}
  {* in constraint complete_decomposition                                                 *}
  rule
      derive_inSubRel: $ forall x/Proposition spec/ISA SUBC/CLASS
                          (spec sub SUBC) and (x in SUBC) ==> (x inSubRel SUBC) $
end



{* this one provides the completeness constraint *}
ISA_complete in Class isA ISA with
  constraint
     {* original version 
     complete_decomposition: $ forall x/VAR SC/CLASS spec/ISA_complete 
                                    (spec super SC) and (x in SC) ==>
                                exists SUBC/CLASS (spec sub SUBC) and (x in SUBC) $
     *}

     {* working version *}
     complete_decomposition: $ forall x/VAR SC/CLASS spec/ISA_complete 
                                    (spec super SC) and (x in SC) ==>
                                exists SUBC/CLASS (spec sub SUBC) and (x inSubRel SUBC) $
end



{* we also provide ISA_disjoint; it has no exists-quantification *}
ISA_disjoint in Class isA ISA with
  constraint
     disjoint_decomposition: $ forall spec/ISA_disjoint SUBC1,SUBC2/CLASS x/VAR
                                    (spec sub SUBC1) and (spec sub SUBC2) and (SUBC1 <> SUBC2) and
                                    (x in SUBC1) ==> not (x in SUBC2) $
end


{* then, ISA_disjoint_complete is just both *}

ISA_disjoint_complete in Class isA ISA_disjoint,ISA_complete end


{* Example for ISA_complete *}

Person in CLASS end

Male in CLASS end

Female in CLASS end

ISA1 in ISA_complete with
  super super1: Person
  sub sub1: Female; sub2: Male
end

{* this causes a violation
mary in Person end
*}


{* Example for ISA_disjoint *}

SubatomicParticle in CLASS end

ElementaryParticle in CLASS end

ComposedParticle in CLASS end

ISA2 in ISA_disjoint with
  super super1: SubatomicParticle
  sub sub1: ElementaryParticle;
      sub2: ComposedParticle
end

Electron in ElementaryParticle end

{* this causes a violation
Electron in ComposedParticle end
*}


{* Example for ISA_disjoint_complete *}

Employee in CLASS end

MonthlyPaidEmployee in CLASS end

HourlyPaidEmployee in CLASS end

ISA3 in ISA_disjoint_complete with
  super super1: Employee
  sub sub1: MonthlyPaidEmployee; sub2: HourlyPaidEmployee
end

{* this causes a violation of disjointness
bill in MonthlyPaidEmployee, HourlyPaidEmployee end
*}

{* this causes a violation ofc ompleteness
jane in Employee end
*}



```

== Graph files

- `erdmm.gel`
- `SharedKeyDemo.gel`

== Shell output

```text
=== HOW-TO: define-formulas-at-the-meta-class-level ===

>>> Telling ./AbstractClass.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>yes
[localhost:4001]>
>>> Telling ./EmptyNonEmpty.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4002]>yes
[localhost:4002]>
>>> Telling ./MacroFormulas.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4003]>yes
[localhost:4003]>
>>> cbgraph smoke: ./SharedKeyDemo.gel
>>> cbgraph smoke: ./SharedKeyDemo.gel
/nix/store/ppzp1jz4q8wn8hc1535y6c4v0vfwxmy4-stdenv-linux/setup: line 1947: xvfb-run: command not found
cbgraph smoke skipped (asset validation only)
cbgraph smoke skipped (asset validation only)
```

== Interpretation

The Nix check completes without CBShell or cbserver errors. Review `yes`/`no` responses in the log for tell outcomes.
