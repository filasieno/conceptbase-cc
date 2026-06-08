= Define Customized Error Messages For Integrity Constraints

Verified independently via:

```bash
nix build .#checks.x86_64-linux.define-customized-error-messages-for-integrity-constraints
```

== Input

=== `GeneratedHint.sml.txt`

```telos
{*
* File GeneratedHint.sml
* Author: Manfred Jeusfeld, jeusfeld@uvt.nl
* Date: 5-Apr-2005 (8-Apr-2005)
*----------------------------------------------------------------
*
* Meta-level constraints are a useful feature of ConceptBase.
* They can be augmented by so-called hints which are presented
* to the user in case of an integrity violation. Since the meta-level
* constraint is compiled to simple constraints, it is nice
* to present the hints in the context of the usage. For example, the
* marriedTo attribute is defined to be symmetric. When a violation occurs,
* the hint defined for the symmetric meta formula is specialized by the
* substitutions C=Person and M=marriedTo. 
*
* (c) 2005 by M. Jeusfeld. Do not use without proper reference
* to the author!
*
*}


{* Part 1: Definition of the generic concepts symmetric, irreflexive and single 
   These definitions are independent from the modeling domain and can be re-used
   whereever you want
*}

Proposition with
  attribute
    symmetric: Proposition;
    irreflexive: Proposition
    {* single:Proposition is already predefined in ConceptBase *}    
end

RelationSemantics in Class with
  constraint
    symm_IC: $ forall AC/Proposition!symmetric C/Proposition x,y/VAR M/VAR
                     P(AC,C,M,C) and (x in C) and (y in C) and
                     (x M y)  ==> (y M x) $;
    irrfl_IC: $ forall AC/Proposition!irreflexive C/Proposition x/VAR M/VAR
                     P(AC,C,M,C) and (x in C) ==>  not (x M x) $;
    singleConstraint :
        $ forall p/Proposition!single c,d/Proposition x,m/ VAR
             P(p,c,m,d) and In(x,c)  ==>
                forall y1,y2/VAR
                  In(y1,d) and In(y2,d) and A(x,m,y1) and A(x,m,y2) ==>
                 IDENTICAL(y1, y2) $
end

RelationSemantics!symm_IC with
 comment
   hint: "The relation {M} of {C} must be symmetric, i.e. (x {M} y) implies (y {M} x)."
end

RelationSemantics!irrfl_IC with
 comment
   hint: "No instance of {C} may stand in {M} relation to itself!"
end

RelationSemantics!singleConstraint with
 comment
   hint: "The attribute {m} of {c} is declared single-valued, i.e. any instance of {c} may stand in relation {m} to at most one instance of {d}."
end


{* Part 2: this example defines marriedTo to be symmetric, irreflexive and single-valued.
   It shows how simple models become when one can utilize the generic concepts:
   
Person with
  attribute,symmetric,irreflexive,single
   marriedTo: Person
end

*}




{* Part 3: some data to trigger constraint violation *}

{* this is a violator for symmetry:

adam in Person with
  marriedTo m1: eve
end

eve in Person end

*}

{* this is a violator for irreflexivity:

adonis in Person with
  marriedTo m1: adonis
end

*}


{* this is a violator for single-valuedness:

henry in Person with
  marriedTo
    m1: elizabeth;
    m2: anne;
    m3: mary
end

elizabeth in Person with
  marriedTo
    m1: henry
end

anne in Person with
  marriedTo
    m1: henry
end

mary in Person with
  marriedTo
    m1: henry
end
*}




```

=== `Max1Test.sml.txt`

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
* File Max1Test.sml
* Author: Manfred Jeusfeld
* Date: 15-Dec-2010 (3-Mar-2011)
*----------------------------------------------------------------
* Example of using generated hints for meta formulas.
*
*}



EntityType end

RelationshipType with
  attribute
    role: EntityType;
    max_1: EntityType   {* max_1 etc. are for indicating cardinality constraints *}
end

Class RelationshipType with
  constraint
    ic_max1: $ forall A/RelationshipType!max_1 R/RelationshipType M,E/VAR a1,a2,r/Proposition
                   P(A,R,M,E) and In(r,R) and
                   (a1 in A) and From(a1,r) and
                   (a2 in A) and From(a2,r)
                ==> (a1 == a2) $
end

RelationshipType!ic_max1 with
  comment
    hint: "The role link {M} of {R} has a maximum cardinality of 1, i.e. you may define at most one filler."
end


EntityType Staff end

EntityType University end

RelationshipType employs with
  role
    employee: Staff
  role, max_1
    employer: University
end

Staff willi end

University RWTH end
University HKUST end

employs emp1 with
  employee
    who: willi
  employer
    where: RWTH;
    also: HKUST
end




```

=== `SalaryBoundWithHint.sml.txt`

```telos
{*
* File SalaryBoundWithHint.sml
* Author: Manfred Jeusfeld, jeusfeld@uvt.nl
* Date: 3-Apr-2005 (8-Apr-2005)
*----------------------------------------------------------------
*
* This small example is excerpted from the ConceptBase user manual.
* It shows how to define readable 'hints' that are displayed to the user 
* when an integrity constraint is violated.
* Requires ConceptBase 6.2 (released after 4-Apr-2005).
*
*}

Individual Employee in Class with
   attribute
      name: String;
      salary: Integer;
      dept: Department;
      boss: Manager
end

Individual Manager in Class isA Employee end

Individual Department in Class with
   attribute
      head: Manager
end

Employee with
 rule
   BossRule : $ forall e/Employee m/Manager
                (exists d/Department
                (e dept d) and (d head m))
                ==> (e boss m) $
 constraint
   SalaryBound : $ forall e/Employee b/Manager x,y/Integer
                (e boss b) and (e salary x) and (b salary y)
                   ==> (x <= y) $
end

Employee!SalaryBound with
 comment
   hint: "An employee may not earn more than her/his manager!"
end


Individual mary in Manager with
  name
    hername: "mary Smith"
  salary
    earns: 15000
  dept
    advises:PR;
    currentdept:RD
end

Individual PR in Department end

Individual RD in Department end

{* Tell these two frames separately to trigger an integrity violation:

Individual bill in Manager with
  salary
   earns: 1000
end

Individual PR in Department with
  head PRhead: bill
end

*}


```

== Shell output

```text
=== HOW-TO: define-customized-error-messages-for-integrity-constraints ===

>>> Telling ./GeneratedHint.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>yes
[localhost:4001]>
>>> Telling ./Max1Test.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>no
[localhost:4001]>
>>> Telling ./SalaryBoundWithHint.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>yes
[localhost:4001]>
```

== Interpretation

The Nix check completes without CBShell or cbserver errors. Review `yes`/`no` responses in the log for tell outcomes.
