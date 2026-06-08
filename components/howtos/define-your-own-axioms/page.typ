= Define Your Own Axioms

Verified independently via:

```bash
nix build .#checks.x86_64-linux.define-your-own-axioms
```

== Input

=== `AutoType.sml.txt`

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
* File: AutoType.sml
* Author: Manfred Jeusfeld
* Creation: 2011-09-05 (2011-09-08)
* ----------------------------------------------------------------------
* Automatically classify attribute values in the right target class.
* Requires ConceptBase 7.3.18 released 2011-09-08
*
}




Proposition with
  attribute
    autotype: Proposition
end
AutoTypeClass in Class with
  rule
    autotype: $ forall a,x,y/VAR C,D/Proposition A/Proposition!autotype
                    (x in C) and From(a,x) and To(a,y) and (a in A) and From(A,C) and To(A,D) ==> (y in D) $
end

Department end

{* the attribute department is 'autotyped', i.e. any attribute value will be automatically *}
{* instantiated to Department                                                              *} 
Employee in Class with
  autotype
    department: Department
end



{* This example shows the effect; note that we still need to declare Marketing as individual object 

bill in Employee with
  department
    d1: Marketing
end

Marketing end

*}



```

=== `SelfDefinedAxiom14.sml.txt`

```telos
{*
* File SelfDefinedAxiom14.sml
* Author: Manfred Jeusfeld, jeusfeld@uvt.nl
* Date: 14-Apr-2005 (14-Apr-2005)
*----------------------------------------------------------------
*
* O-Telos axiom 14 (also known as InstanceOf constraint 1) is only
* partially defined in ConceptBase by some hard-coded check routines.
* One can however define the axiom as a meta formula and that leads to
* good results (not speaking of efficiency here!)
*
* Requires ConceptBase 6.2.
*
* (c) 2005 by M. Jeusfeld. Do not use without proper reference
* to the author!
*
*}

{* attributes classes are those for which we want our self-defined axiom           *}
{* be checked. Without this range, the system would also try to generate checks   *}
{* for attributes that are never instantiated, e.g. attributes whose values       *}
{* are formulas. In that case, the generated formulas would even be               *}
{* syntactically wrong.                                                           *}

{* Step 1: tell the axiom: *}

Proposition with
  attribute
    attributeclass: Proposition
end

MyAxioms in Class with
  constraint
     ax14new: $ forall p/Proposition!attributeclass o,c,m,d/VAR (o in p) and P(p,c,m,d)
                   ==> exists x,y/VAR From(o,x) and To(o,y) and (x in c) and (y in d) $
end

MyAxioms!ax14new with
 comment
   hint: "The typing axiom a14new at MyAxioms is violated for the attribute {m} of {c}. If you use the {m} attribute for an object x, then x must be instance of {c} and the {m} value of x must be instance of {d}."
end


{* Note: The original axiom A14 reads different:

    forall o,x,l,y,p P(o,x,l,y) and In(o, p) ==>
      exists c,m,d P(p,c,m,d) and In(x,c) and In(y,d)

  1) The predicate P(p,c,m,d) moved to the conclusion: This is no logical difference
  given the fact that any filler for p uniquely determines c,m,d since p is the
  object identifier of that fact. Hence, it is implied by (o in p) which forces a
  substitution for p.

  2) The predicate P(o,x,l,y) in the original axiom is replaced by From(o,x) and To(o,y)
  which is equivalent because the argument l is not used. Additionaly, the predicate
  has moved from condition to conclusion of the implication. This is also equivalent
  since o uniquely determines x and y.

  3) In ax14new, the variable p is bound to Proposition!attributeclass (equivalent to
  (p in Proposition!attributeclass)). This range-restriction is not present for the 
  original axiom. One could use attributee as a range for p or even Proposition 
  (as implied in the original axiom) but then there would be two problems:
    a) The formula can't be compiled because some fillers for p would gave fillers for 
    c,m,d that would render a syntactically wrong formula (see above). This is due to
    some implementation detail of ConceptBase, not due to a logical inconsistency.
    b) Even if problem a) would be solved, the axiom would be extremely inefficient because
    virtually any attribute (or proposition) would match P(p,c,m,d).
   Using attributeclass for attribute definitions at the class level is not
   a real problem for the user.

  4) The predicates (o in p), (x in c) and (y in d) do not have the same extension as
  the predicates In(o,p), In(c,x) and In(y,d) in the orginal constraint. In the latter,
  the In predicates contains only those solutions that are derivable by the O-Telos
  axioms, i.e. explicit and inherited instances (= via subclasses) of a class. 
  The new form however fully takes into account any user-defined deductive rule that
  derives instantiation to a class. Hence ax14new is a real extension of the old axiom
  to cover also user-defined rules!

*}


{* The subsequent definitions are in comments. Tell/untell them to *}
{* check the behavior.                                             *}


{* Step 2: some example using attribute classes : 

Employee in Class with
  attributeclass
    salary: Integer
end

Manager in Class with
  attributeclass
    country: String
  rule
    r1: $ forall m/Manager (m country "Ubuntu") ==> (m in Employee) $
end

*}

{* Step 3: tell this to instantiate salary 

bill in Manager with
  country c: "Ubuntu"
  salary s: 1000
end

*}

{* Step 4: then untell this to check the axiom. It will indirectly untell the
   instantiation of bill to Emp[loyee, thus rendering the salary attribute of 
   bill inconsistent. 

bill with 
  attribute,country
     c : "Ubuntu"
end 

*}

```

== Shell output

```text
=== HOW-TO: define-your-own-axioms ===

>>> Telling ./AutoType.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>yes
[localhost:4001]>
>>> Telling ./SelfDefinedAxiom14.sml.txt
This is CBShell, the command line interface to ConceptBase.cc
[offline]>Successfully connected to server
[localhost:4001]>yes
[localhost:4001]>
```

== Interpretation

The Nix check completes without CBShell or cbserver errors. Review `yes`/`no` responses in the log for tell outcomes.
