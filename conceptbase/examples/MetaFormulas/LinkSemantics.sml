{*
The ConceptBase.cc Copyright

Copyright 1987-2014 The ConceptBase Team. All rights reserved.

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

Matthias Jarke, RWTH Aachen, Informatik 5, Ahornstr. 55, 52056 Aachen, Germany
Manfred Jeusfeld, Tilburg University, Warandelaan 2, 5037 AB Tilburg, The Netherlands
Christoph Quix, RWTH Aachen, Informatik 5, Ahornstr. 55, 52056 Aachen, Germany


This license is a FreeBSD-style copyright license.
Legal home of the FreeBSD copyright license: http://www.freebsd.org/copyright/freebsd-license.html
*}
{*
* File LinkSemantics.sml
* Author: Manfred Jeusfeld, jeusfeld@uvt.nl
* Date: 2-Oct-2002 (6-Dec-2004)
*----------------------------------------------------------------
* This Telos file shows that generic properties of mathematical
* relations (reflexive, transitive, ..) can easily be defined
* with ConceptBase and employed to make concept definitions
* more efficient.
* Note that the formulas are defined at the meta class level,
* i.e. independent from the application context.
* Some formulas like the ones for transitive and symmetric
* are also definable as deductive rules.
* 6-Dec-2004: use relaxed format for deductive rules (requires
* ConceptBase 6.2)
*
* (c) 2003-2004 by M. Jeusfeld. Do not use without proper reference
* to the author!
*
*}

{* Relation type names *}

Proposition with
  attribute
    injective: Proposition;   {* at most one filler for an attribute   *}
    surjective: Proposition;  {* at least  one filler for an attribute *}
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
                 (a in AC) and (b in AC) and From(a,x) and From(b,x)  ==> (a == b) $;
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
                     (x M y) and (y M x)  ==> (x == y) $;
    total_IC: $ forall AC/Proposition!total C/Proposition x,y/VAR M/VAR
                     P(AC,C,M,C) and (x in C) and (y in C) ==>
                     ((x M y) or (y M x)) $;
    invinj_IC: $ forall AC/Proposition!inv_injective a,b,x/Proposition
                 (a in AC) and (b in AC) and To(a,x) and To(b,x)  ==> (a == b) $
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
    c: $ (~pers hasAncestor ~this) $
end

*}










