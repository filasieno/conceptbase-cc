= Define Basic Properties Of Relations

Verified independently via:

```bash
nix build .#checks.x86_64-linux.define-basic-properties-of-relations
```

== Input

=== `Contains.sml.txt`

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
* File Contains.sml.txt
* Author: Manfred Jeusfeld, jeusfeld@uvt.nl
* Date: 2021-07-31 (2021-07-31)
*----------------------------------------------------------------
* Show how to extend O-Telos by adding new relations and their semantics to Proposition
*
*}


Proposition with
  attribute
    contains: Proposition
end

{* in efficient solution with quadratic recursion in r1trans rule
ContainsSemantics in Class with 
  constraint
    c1asymm: $ forall x1,x2/Proposition (x1 contains x2) ==> not (x2 contains x1) $
  rule
    r1trans: $ forall x1,x2,x3/Proposition (x1 contains x2) and (x2 contains x3) ==> (x1 contains x3) $
end
*}

ContainsSemantics in Class with 
  constraint
    c1asymm: $ forall x1,x2/Proposition (x1 contains x2) ==> not (x2 contains x1) $
  rule
    r1trans: $ forall x1,x2,x3/Proposition :(x1 contains x2): and (x2 contains x3) ==> (x1 contains x3) $
end



car1 with
  contains
    p1: engine1;
    p2: frame1
end

engine1 with
  contains
    p1: engineblock1;
    p2: ecu1
end

frame1 end
engineblock1 end
ecu1 end


{* this definition will violate constraint c1asymm
engineblock1 with
  contains
    p1: engine1
end
*}




```

=== `Immutable.sml.txt`

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
* File: Immutable.sml
* Author: Manfred Jeusfeld
* Creation: 2012-06-29 (2017-02-10/MJf)
* ----------------------------------------------------------------------
*
* Giancarlo Guizzardi asked me at CAiSE-2012 whether ConceptBase can
* formalize immutability of associations such the partners in a
* marriage. If a marriage is created between two persons, then the associated persons
* of the marriage may not be removed or updated. One can only remove
* a marriage object as a whole.
* So here is a solution. We use an active rule to implement the desired
* semantics of immutability. One can also call this an example of a
* dynamic integrity constraint.
*
*}



{* Define the new attribute category 'immutable' in the most generic way *}
Proposition with  
  attribute
    immutable : Proposition
end 



{* This active rule does all the work                                    *}
{* Quoted predicates like `(x in c) are evaluated against the new        *}
{* database state.                                                       *}

IMMUTABLERULE in ECArule with  
  rejectMsg msg: "Immutable attributes may not be updated."
  mode m: Deferred
  ecarule
    er : $  iac/Proposition!immutable ia/attributee x/Proposition c/Class
        ON Untell (ia in iac)
        IF (iac in Proposition!immutable) and
            (ia in iac) and not `(ia in iac) and From(ia,x)  and From(iac,c) and `(x in c)
        DO reject
        $
end 




{* An example declaring spouses as immutable *}

Person in Class  
end 


Marriage in Class with  
  immutable,single
    spouse1 : Person;
    spouse2 : Person
end 



{* some data *}

bill in Person  
end 

mary in Person  
end 

john in Person  
end 

marriage1 in Marriage with  
  spouse1
    s1 : mary
  spouse2
    s2 : bill
end 


{* try to untell for example

marriage1 with  
  spouse1
    s1 : mary
end

*}



```

=== `InverseOf.sml.txt`

```telos
{*
* File InverseOf.sml
* Author: Manfred Jeusfeld, jeusfeld@uvt.nl
* Date: 9-Dec-2003 (6-Dec-2004)
*----------------------------------------------------------------
* This example shows how to declare an attribute to
* be inverse of some other attribute.
* For example, 'hasParticipant' is the inverse of
* the 'participates' attribute.
*
* Requires ConceptBase 6.2 released 5-Dec-2004 or later.
*
* (c) 2003-2004 by M. Jeusfeld. Do not use without proper reference
* to the author!
*
*}



{* The link ' isInverseOf' shall be used to   *}
{* declare some attribute B to be the inverse *}
{* of some other attribute A.                 *}

Proposition!attribute with
  attribute
    isInverseOf: Proposition!attribute
end


InverseSemantics in Class with
  rule
   invR1: $ forall x,y,MA,MB/VAR 
                   A,B/Proposition!attribute 
                   C,D/Proposition
                   (B isInverseOf A) and
                   P(A,C,MA,D) and P(B,D,MB,C) and 
                   (x in C) and (y in D) and 
                   (x MA y) ==> (y MB x) $
end


{* Example *}

{* first we declare two attributes *}

Person with
  attribute
    participates: Meeting
end

Meeting with
  attribute
    hasParticipant: Person
end

{* then we declare the hasParticipant (MB) to be the inverse
   of participant (MA) *}

Meeting!hasParticipant with
  isInverseOf
    origattribute: Person!participates
end

{* Note: 'hasParticipant' is the derived attribute *}



{* some example data to test whether everything went fine: *}

john in Person with
  participates m1: MeetingOnTaxes
end

bill in Person with 
  participates
    m1: MeetingOnMarketing;
    m2: MeetingOnTaxes
end

mary in Person with
  participates m1: MeetingOnTaxes
end

MeetingOnMarketing in Meeting end
MeetingOnTaxes in Meeting end


{* a query to test hasParticipant *}

MeetingWithParticipants in QueryClass isA Meeting with 
  computed_attribute
    pers: Person
  constraint
    c: $ (~this hasParticipant ~pers) $
end



```

=== `LinkSemantics2.sml.txt`

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
* File LinkSemantics2.sml
* Author: Manfred Jeusfeld, jeusfeld@uvt.nl
* Date: 28-Oct-2003 (1-Oct-2010)
*----------------------------------------------------------------
* Shows how to define abstract properties of relations
* like transitivity, symmetry etc.
* When possible, deductive rules are generated. Otherwise,
* integrity constraints are generated.
* The power of these definitions lies in the fact that
* they can be combined via multiple instantiation.
* 
* (c) 2003-2020 by M. Jeusfeld. 
*
* Requires ConceptBase 7.1.5 released December 2008 or later.
*
*}

{* relation type names *}

Proposition with
  attribute
    reflexive:  Proposition;      {* any object is related to itself       *}
    transitive: Proposition;      {* relation is closed under transitivity *}
    symmetric: Proposition;       {* if x rel y then also y rel x          *}
    antisymmetric: Proposition;   {* if x rel y and (y rel x) then x=y *}
    asymmetric: Proposition;      {* if x rel y then not y rel x     *}
    irreflexive: Proposition      {* no object is related to itself     *}
end


RelationSemantics in Class with
  constraint
   asym_IC: $ forall AC/Proposition!asymmetric C/Proposition x,y/VAR M/VAR
                     P(AC,C,M,C) and (x in C) and (y in C) and
                     (x M y)  ==> not (y M x) $;
   antis_IC: $ forall AC/Proposition!antisymmetric C/Proposition x,y/VAR M/VAR
                     P(AC,C,M,C) and (x in C) and (y in C) and
                     (x M y) and (y M x)  ==> (x = y) $;
   irref_IC: $ forall x,M/VAR 
                    AC/Proposition!irreflexive C/Proposition
                    P(AC,C,M,C) and (x in C)
                      ==> not (x M x) $
  rule
   trans_R: $ forall x,z,y,M/VAR 
                     AC/Proposition!transitive C/Proposition
                     P(AC,C,M,C) and (x in C) and (y in C) and (z in C) and
                     (x M y) and (y M z) ==> (x M z) $;
   refl_R: $ forall x,M/VAR 
                    AC/Proposition!reflexive C/Proposition
                    P(AC,C,M,C) and (x in C)
                      ==> (x M x) $;
   symm_R: $ forall x,y,M/VAR 
                    AC/Proposition!symmetric C/Proposition
                    P(AC,C,M,C) and (x in C) and (y in C) and
                    (x M y)  ==> (y M x) $
end


{* Define a hint for the asym_IC constraint. This will be used by ConceptBase       *}
{* to generate a customized error message in case of a violation of the constraint. *}
 
RelationSemantics!asym_IC with
  comment
    hint: "The {M} relation of {C} is declared asymmetric. Hence, if (x {M} y) holds, then (y {M} x) may not hold."
end

RelationSemantics!antis_IC with 
   comment
    hint : "The {M} relation of {C} is declared antisymmetric. Hence, (x {M} y) and (y M x) may only hold for x=y."
end 

RelationSemantics!irref_IC with 
   comment
    hint : "The {M} relation of {C} is declared irreflexive. Hence, if (x {M} x) may not hold."
end 


{* Example use of the relation properties as attribute categories 
   The subsequent definitions are in comments, hence they are
   not loaded into ConceptBase when you load this file
*}


{*
Person with
  attribute,symmetric,reflexive,transitive
    knows: Person
  attribute,asymmetric,transitive
    hasAncestor: Person
end


john in Person with
  knows p1: bill
  hasAncestor a1: mary
end

bill in Person with 
  knows p1: eve
end

eve in Person with
  hasAncestor p1: isabel
end

isabel in Person with
  knows p1: eve
  hasAncestor a1: carl
end

carl in Person end
mary in Person end


AncestorOf in GenericQueryClass isA Person with 
  parameter,computed_attribute
    pers: Person
  constraint
    c: $ (pers hasAncestor this) $
end

KnownPersonFor in GenericQueryClass isA Person with
  parameter,computed_attribute
    pers: Person
  constraint
    c: $ (pers knows this) $
end
*}


{* this would violate asymmetry of hasAncestor
carl in Person with
   hasAncestor a1: eve
end
*}











```

=== `LinkSemantics3.sml.txt`

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
* File LinkSemantics3.sml
* Author: Manfred Jeusfeld, jeusfeld@uvt.nl
* Date: 28-Oct-2003 (29-Sep-2010)
*----------------------------------------------------------------
*
* This is a version of LinkSemantics2.sml that uses the A_e predicate
* to create for efficient code for the rules for symmetric and transitive.
* The definition is however not 100% equivalent to LinkSemantics2.sml since
* it requires that the base solutions are explicit, not derived.
*
* Specifically, if one defines an explicit attribute a1 and then includes a "copy rule"
*     forall x,y/C (x a1 y) ==> (x a2 y)
* then declaring a2 to be symmetric and/or transitive would not work since there
* are no explicit attributes with category a2. Hence, LinkSemantics2 is preferred unless
* you experience performance problems. If you then can guarantee that there are no
* copy rules, then you may consider LinksSemantics3.
* 
* (c) 2003-2010 by M. Jeusfeld. 
*
* Requires ConceptBase 7.1.5 released December 2008 or later.
*
*}

{* relation type names *}

Proposition with
  attribute
    reflexive:  Proposition;      {* any object is related to itself       *}
    transitive: Proposition;      {* relation is closed under transitivity *}
    symmetric: Proposition;       {* if x rel y then also y rel x          *}
    antisymmetric: Proposition;   {* if x rel y and (y rel x) then x=y *}
    asymmetric: Proposition       {* if x rel y then not y rel x     *}
end



{* A_e(x,m,y) is like (x m y) except that it only considers explicit  *}
{* attributions between x,y. This yields much faster executable code. *}

RelationSemantics in Class with
  constraint
   asym_IC: $ forall AC/Proposition!asymmetric C/Proposition x,y/VAR M/VAR
                     P(AC,C,M,C) and (x in C) and (y in C) and
                     (x M y)  ==> not (y M x) $;
   antis_IC: $ forall AC/Proposition!antisymmetric C/Proposition x,y/VAR M/VAR
                     P(AC,C,M,C) and (x in C) and (y in C) and
                     (x M y) and (y M x)  ==> (x = y) $
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
 
RelationSemantics!asym_IC with
  comment
    hint: "The {M} relation of {C} is declared asymmetric. Hence, if (x {M} y) holds, then (y {M} x) may not hold."
end


{* Example use of the relation properties as attribute categories 
   The subsequent definitions are in comments, hence they are
   not loaded into ConceptBase when you load this file
*}


{*
Person with
  attribute,symmetric,reflexive,transitive
    knows: Person
  attribute,asymmetric,transitive
    hasAncestor: Person
end


john in Person with
  knows p1: bill
  hasAncestor a1: mary
end

bill in Person with 
  knows p1: eve
end

eve in Person with
  hasAncestor p1: isabel
end

isabel in Person with
  knows p1: eve
  hasAncestor a1: carl
end

carl in Person end
mary in Person end


AncestorOf in GenericQueryClass isA Person with 
  parameter,computed_attribute
    pers: Person
  constraint
    c: $ (pers hasAncestor this) $
end

KnownPersonFor in GenericQueryClass isA Person with
  parameter,computed_attribute
    pers: Person
  constraint
    c: $ (pers knows this) $
end
*}


{* this would violate asymmetry of hasAncestor
carl in Person with
   hasAncestor a1: eve
end
*}











```

=== `LinkSemantics.sml.txt`

```telos
{*
* File LinkSemantics.sml
* Author: Manfred Jeusfeld, jeusfeld@uvt.nl
* Date: 2-Oct-2002 (8-May-2008)
*----------------------------------------------------------------
* This Telos file shows that generic properties of mathematical
* relations (reflexive, transitive, ..) can easily be defined
* with ConceptBase and employed to make concept definitions
* more efficient.
* Note that the formulas are defined at the meta class level,
* i.e. independent from the application context.
* Some formulas like the ones for transitive and symmetric
* are also definable as deductive rules.
*
* The illustrating examples are set in comment. They are not
* loaded when you load this model into ConceptBase. 
*
* 6-Dec-2004: use relaxed format for deductive rules (requires
* ConceptBase 6.2)
* 3-Apr-2005: include user-defined hints for some meta-level constraints
*
* This model requires ConceptBase 7.1 released April 2008 or later.
*
* (c) 2003-2008 by M. Jeusfeld. Do not use without proper reference
* to the author!
*
*}

{* relation type names *}

Proposition with
  attribute
    injective: Proposition;   {* at most one filler for an attribute   *}
    surjective: Proposition;  {* all objects of the target class are also attribute values *}
    reflexive:  Proposition;  {* any object is related to itself       *}
    transitive: Proposition;  {* relation is closed under transitivity *}
    symmetric: Proposition;   {* if x rel y then also y rel x          *}
    antisymmetric: Proposition;     {* if x rel y and (y rel x) then x=y *}
    asymmetric: Proposition;        {* if x rel y then not (y rel x)     *}
    total: Proposition;             {* for all x,y: x rel y or y rel x   *}
    inv_injective: Proposition;     {* reverse relation is injective     *}
    makeTransitive: Proposition;    {* transitive by deduction           *}
    makeReflexive: Proposition;     {* reflexive by deduction            *}
    makeSymmetric: Proposition      {* symmetric by deduction            *}
end


RelationSemantics in Class with
  constraint
    inj_IC: $ forall AC/Proposition!injective a,b,x/Proposition
                 (a in AC) and (b in AC) and From(a,x) and From(b,x)  ==> (a = b) $;
    surj_IC: $ forall AC/Proposition!surjective C,D/Proposition M/VAR y/Proposition
                  P(AC,C,M,D) and (y in D) ==> exists a/Proposition (a in AC) and To(a,y) $;
    refl_IC: $ forall AC/Proposition!reflexive C,D/Proposition x,M/VAR
                        P(AC,C,M,D) and (x in C) ==> (x M x) $;
    trans_IC: $ forall AC/Proposition!transitive C/Proposition x,y,z/VAR M/VAR
                     P(AC,C,M,C) and (x in C) and (y in C) and (z in C) and
                     (x M y) and (y M z) ==> (x M z) $;
    symm_IC: $ forall AC/Proposition!symmetric C/Proposition x,y/VAR M/VAR
                     P(AC,C,M,C) and (x in C) and (y in C) and
                     (x M y)  ==> (y M x) $;
    asym_IC: $ forall AC/Proposition!asymmetric C/Proposition x,y/VAR M/VAR
                     P(AC,C,M,C) and (x in C) and (y in C) and
                     (x M y)  ==> not (y M x) $;
    antis_IC: $ forall AC/Proposition!antisymmetric C/Proposition x,y/VAR M/VAR
                     P(AC,C,M,C) and (x in C) and (y in C) and
                     (x M y) and (y M x)  ==> (x = y) $;
    total_IC: $ forall AC/Proposition!total C/Proposition x,y/VAR M/VAR
                     P(AC,C,M,C) and (x in C) and (y in C) ==>
                     ((x M y) or (y M x)) $;
    invinj_IC: $ forall AC/Proposition!inv_injective a,b,x/Proposition
                 (a in AC) and (b in AC) and To(a,x) and To(b,x)  ==> (a = b) $
end


{* some so-called hints for constraints. They are to be returned to the user when *}
{* an integrity violation occurs.                                                 *}

RelationSemantics!surj_IC with
 comment
   hint: "The relation {M} of {C} is surjective. Each instance of {D} must be the target of at least one attribute {M}."
end

RelationSemantics!refl_IC with
 comment
   hint: "The relation {M} of {C} is reflexive. Any object of class {C} must be linked to itself via the {M} relation."
end

RelationSemantics!trans_IC with
 comment
   hint: "The relation {M} of {C} is transitive. The facts (x {M} y) and (y {M} z) must imply that (x {M} z) holds."
end


RelationSemantics!symm_IC with
 comment
   hint: "The relation {M} of {C} must be symmetric, i.e. (x {M} y) implies (y {M} x)."
end



RelationSemantics in Class with
  rule
   trans_R: $ forall x,y,z,M/VAR 
                     AC/Proposition!makeTransitive C/Proposition
                     P(AC,C,M,C) and (x in C) and (y in C) and (z in C) and
                     (x M y) and (y M z) ==> (x M z) $;
   refl_R: $ forall x,M/VAR 
                    AC/Proposition!makeReflexive C/Proposition
                    P(AC,C,M,C) and (x in C)
                    ==> (x M x) $;
   symm_R: $ forall x,y,M/VAR 
                    AC/Proposition!makeSymmetric C/Proposition
                     P(AC,C,M,C) and (x in C) and (y in C) and
                     (x M y)  ==> (y M x) $
end


{* Test injective 

Person with
  attribute,injective
    name: String
end


bill in Person with
  name n1: "William";
       n2: "The Conqueror"  
end

--> this is a violator

john in Person with
  name n1: "John Smith"
end

--> this is OK

*}

{* Test surjective:

Person with
  attribute,surjective
    worksOn: Project
end

Project end

bill in Person with
  worksOn
    p1: Proj1
end

Proj1 in Project end
Proj2 in Project end

--> Proj2 is not hit by the worksOn relation

*}



{* Test reflexive:

Person in Class with
  attribute,reflexive
    knows: Person
end

bill in Person end

john in Person with
  knows p1: john
end

*}

{* Test transitive

Person with
  attribute,transitive
     knows: Person
end

bill in Person with
  knows p1: john
end

john in Person with
  knows p1: mary
end

mary in Person end

--> bill should also know mary!

*}

{* Test symmetric

Person with
  attribute,symmetric
   marriedTo: Person
end

mary in Person with
  marriedTo m1: john
end

john in Person with
  marriedTo m1: mary
end

bill in Person with
  marriedTo m1: eve
end

eve in Person end

*}

{* Test asymmetric:

Person with
  attribute,asymmetric
   hasChild: Person
end

adam in Person with
  hasChild
    c1: kain
end

kain in Person with
  hasChild
    c1: adam
end

*}

{* Test inv_injective:


Person with
  attribute,inv_injective
   holds: Account
end

Account end

A12345 in Account end

bill in Person with
  holds a1: A12345
end

mary in Person with
  holds a1: A12345
end

*}


{* This example shows the use of the deductive flavors of the relational properties


Person with
  attribute,makeSymmetric,makeReflexive,makeTransitive
    knows: Person
  attribute,asymmetric,makeTransitive
    hasAncestor: Person
end


john in Person with
  knows p1: bill
  hasAncestor a1: mary
end

bill in Person with 
  knows p1: eve
end

eve in Person with
  hasAncestor p1: isabel
end

isabel in Person with
  knows p1: eve
  hasAncestor a1: carl
end

carl in Person end
mary in Person end

AncestorOf in GenericQueryClass isA Person with 
  parameter,computed_attribute
    pers: Person
  constraint
    c: $ (pers hasAncestor this) $
end

*}











```

=== `SingleNecessary.sml.txt`

```telos
{*
* File: SingleNecessary.sml
* Author: Manfred Jeusfeld, jeusfeld@uvt.nl
* Date: 21-Sep-2005 (22-May-2020)
*----------------------------------------------------------------
* These are the classical definitions [1] for the attribute categories
* single (at most 1 filler for an attribute) and necessary (at least
* one filler for an attribute. The two attribute categories single and
* neccessary are already in pre-defined in ConceptBase. We nevertheless
* declare them here.
* Use the formulas below to enrich the capabilities of your ConceptBase
* application!
* [1] The definitions date back to the time when Telos was defined, i.e.
* around 1987. Versions of the definitions can be found also in the master
* thesis of Manolis Koubarakis. ConceptBase was to our knowledge the first
* implementation of Telos that can efficiently compile the constraints
* associated to single/necessary.
* revsingle: This is the reverse constraint of the single constraint.
* revnecessary: This is the reverse constraint of the necessary constraint.
*
* attributes/relation (x m y) is
*     single --> m is right-unique --> partial function
*     revsingle --> m is right-unique 
*     necessary --> m is left-total
*     revnecessary --> m is right-total 
* 
*  injective: single+revsingle
*  surjective: single+revnecessary
*  total function: single+necessary
*  bijective: single+necessary+revnecessary
*
*}


Proposition with
  attribute
    single: Proposition;
    necessary: Proposition;
    revsingle: Proposition;
    revnecessary: Proposition
end

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
             exists y/VAR (y in d) and (x m y) $;
      revsingleConstraint :
          $ forall c,d/Proposition p/Proposition!revsingle y,m/VAR
              P(p,c,m,d) and (y in d) ==>
                (
                  forall x1,x2/VAR
                    (x1 in c) and (x2 in c) and (x1 m y) and (x2 m y) ==>
                   (x1=x2)
                ) $;
      revnecConstraint:
          $ forall c,d/Proposition p/Proposition!necessary y,m/VAR
            P(p,c,m,d) and (y in d) ==>
             exists x/VAR (x in c) and (x m y) $
end


AdditionalConstraints!singleConstraint with
 comment
   hint:
"The attribute/relation {m} of {c} is single-valued (right-unique). Any instance of {c} may have at most one attribute of category {m}!"
end


AdditionalConstraints!necConstraint with
 comment
   hint:
"The attribute/relation {m} of {c} is defined necessary (left-total). Any instance of {c} must have at least one instance of {d} for the attribute {m}!"
end

AdditionalConstraints!revsingleConstraint with
 comment
   hint:
"The attribute/relation {m} of {c} is reverse single-valued (left-unique). Any instance of {d} may have at most one instance of {c} connected to it via an attribute of category {m}!"
end

AdditionalConstraints!revnecConstraint with
 comment
   hint:
"The attribute/relation {m} of {c} is defined reverse necessary (right-total). Any instance of {d} must have at least one instance of {c} for the attribute {m}!"
end



{* example on the use of single/necessary

Employee in Class with
  single
    salary: Integer
  single,necessary
    name: String
  necessary
    worksOn: Project
end

Project end

*}


{* these instances do not violate the constraints:

bill in Employee with
  salary s: 1000
  name n: "William"
  worksOn p1: Proj1; p2: Proj2
end

Proj1 in Project end
Proj2 in Project end

*}

{* these instances violate the constraints

jim in Employee with
  salary s1: 1000; s2: 2000
end

greta in Employee with
   salary s1: 1000
   name n1: "Gretchen"
end

*}


{* these instances violate revsingle
C with
  revsingle
    attr: D
end

D end

Y in D end

X1 in C with
  attr a1: Y
end


X2 in C with
  attr a1: Y
end
*}



```

=== `TransitiveClosureOf.sml.txt`

```telos
{*
* File: TransitiveClosureOf.sml
* Author: Manfred Jeusfeld, jeusfeld@uvt.nl
* Date: 10-Nov-2003 (8-May-2008)
*----------------------------------------------------------------
* This example shows how to declare an attribute to
* be the transitive clusure of some other attribute.
* For example, ancestor is the transitive closure of
* the 'parent' attribute.
*
* You can include the two first frames into your
* ConceptBase database. Then you can use the new
* feature 'isTransitiveClosureOf' whereever you
* need the transitive closure of an attribute.
*
* The difference to LinkSemantics2.sml is that there we
* define an attribute to be transitively closed. That
* makes it difficult to distinguish derived relations
* from the original relation.
*
* (c) 2003-2008 by M. Jeusfeld. 
* This model file is licensed under the CC-GNU GPL 
* http://creativecommons.org/licenses/GPL/2.0/
*
* Requires ConceptBase 7.1 released April 2008 or later.
* 
*
*}



{* The link ' isTransitiveClosureOf' shall be used to    *}
{* declare some attribute B to be the transitive closure *}
{* of some attribute A.                                  *}

Proposition!attribute with
  attribute
    isTransitiveClosureOf: Proposition!attribute
end


MakeTransitiveSemantics1 in Class with
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


{* Example *}

{* first we declare two attributes of the same class and declare
   the 2nd to the the transitive closure of the first *}

{*
Person with
  attribute
    hasParent: Person;
    hasAncestor: Person
end

Person!hasAncestor with
  isTransitiveClosureOf
    baseattribute: Person!hasParent
end
*}


{* this will generate the necessary rules from the above meta formulas *}
{* relax and enjoy the flawless execution                              *}



{* some example data to test whether everything went fine:
john in Person with
  hasParent a1: mary
end

bill in Person with 
end

mary in Person with
  hasParent p1: isabel
end

isabel in Person with
  hasParent a1: carl
end

carl in Person end
mary in Person end
*}


{* a query to test whether hasAncestor is indeed computed correctly *}
{* you can ask this without providing a parameter                   *}

{*
AncestorOf in GenericQueryClass isA Person with 
  parameter,computed_attribute
    pers: Person
  constraint
    c: $ (pers hasAncestor this) $
end
*}




```

== Graph files

- `hasancestor.gel`
- `knows.gel`

== Shell output

```text
=== HOW-TO: define-basic-properties-of-relations ===

>>> Telling ./Contains.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>yes
[localhost:4001]>
>>> Telling ./Immutable.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>no
[localhost:4001]>
>>> Telling ./InverseOf.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>yes
[localhost:4001]>
>>> Telling ./LinkSemantics.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>yes
[localhost:4001]>
>>> Telling ./LinkSemantics2.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>no
[localhost:4001]>
>>> Telling ./LinkSemantics3.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>no
[localhost:4001]>
>>> Telling ./SingleNecessary.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>yes
[localhost:4001]>
>>> Telling ./TransitiveClosureOf.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>yes
[localhost:4001]>
```

== Interpretation

The Nix check completes without CBShell or cbserver errors. Review `yes`/`no` responses in the log for tell outcomes.
