{*
The ConceptBase.cc Copyright

Copyright 1987-2023 The ConceptBase Team. All rights reserved.

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
* File LinkSemantics2.sml
* Author: Manfred Jeusfeld, jeusfeld@uvt.nl
* Date: 28-Oct-2003 (6-Dec-2004)
*----------------------------------------------------------------
* Shows how to define abstract properties of relations
* like transitivity, symmetry etc.
* When possible, deductive rules are generated. Otherwise,
* integrity constraints are generated.
* The power of these definitions lies in the fact that
* they can be combined via multiple instantiation.
*
* Requires ConceptBase 6.2 released 5-Dec-2004 or later.
*
* (c) 2003 by M. Jeusfeld. Do not use without proper reference
* to the author!
*
*}

{* Relation type names *}

Proposition with
  attribute
    reflexive:  Proposition;  {* any object is related to itself       *}
    transitive: Proposition;  {* relation is closed under transitivity *}
    symmetric: Proposition;   {* if x rel y then also y rel x          *}
    asymmetric: Proposition   {* if x rel y then not y rel x     *}
end


RelationSemantics in Class with
  constraint
   asym_IC: $ forall AC/Proposition!asymmetric C/Proposition x,y/VAR M/VAR
                     P(AC,C,M,C) and (x in C) and (y in C) and
                     (x M y)  ==> not (y M x) $
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


{* Example use of the relation properties as attribute categories *}

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

{* this would violate asymmetry of hasAncestor
carl in Person with
   hasAncestor a1: eve
end
*}
  

AncestorOf in GenericQueryClass isA Person with 
  parameter,computed_attribute
    pers: Person
  constraint
    c: $ (~pers hasAncestor ~this) $
end

KnownPersonFor in GenericQueryClass isA Person with
  parameter,computed_attribute
    pers: Person
  constraint
    c: $ (~pers knows ~this) $
end











