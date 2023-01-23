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
Class Model in ObjectType isA ConceptualObject
end

Class EnterpriseModel in ObjectType isA Model
end

Class SourceModel in ObjectType isA Model with
attribute,single,necessary
    isModelOf : Source
end

Class ClientModel in ObjectType isA Model with
attribute,single,necessary
    isModelOf : Client
end

Class ConceptRelationship in ObjectType isA ConceptualObject with
attribute,single,necessary
    refersTo : Model
attribute
    isSubsumedBy : ConceptRelationship;
    isNotSubsumedBy  : ConceptRelationship
constraint
  xorConceptRelationship :
    $ forall c/ConceptRelationship
      (c in Concept) ==> not (c in Relationship) $
end

Class Concept in ObjectType isA ConceptRelationship,ConceptDomain with
constraint
  subsumeConcept :
     $ forall c1/Concept c2/ConceptRelationship
       ((c1 isSubsumedBy c2) or (c1 isNotSubsumedBy c2)) ==>
       (c2 in Concept) $
end

Class ConceptDomain in ObjectType isA ConceptualObject with
constraint
  xorDomainConceptRelationship :
    $ forall c/ConceptRelationship not (c in Domain) $;
  unionDomainConceptRelationship :
    $ forall cd/ConceptDomain (cd in ConceptRelationship) or
      (cd in Domain) $
end

Class Relationship in ObjectType isA ConceptRelationship with
attribute,single,necessary
    arity : Integer
attribute
    component : ConceptDomain
constraint
  arity_constraint :
    $ forall r/Relationship i/Integer (r arity i) ==> (i >= 2 ) $;
  position_constraint :
    $ forall r/Relationship a/Integer p1,p2/Integer
     (exists c1,c2/Relationship!component
      Ai(r,component,c1) and Ai(r,component,c2) and
      (c1 position p1) and (c2 position p2) and not(c1 == c2) and
      A(r,arity,a)) ==> (not (p1 == p2) and (p1 <= a) and (p2 <= a)) $;
  all_positions_constraint :
    $ forall r/Relationship i/Integer a/Integer
      A(r,arity,a) and (i<= a) and (i>0) ==> (exists c/Relationship!component
      Ai(r,component,c) and (c position i)) $;
  subsumeRelationship :
    $ forall r1/Relationship r2/ConceptRelationship
      ((r1 isSubsumedBy r2) or (r1 isNotSubsumedBy r2)) ==>
      (r2 in Relationship) $;
  subsumeArityRelationship :
    $ forall r1,r2/Relationship (exists i/Integer
      ( ((r1 isSubsumedBy r2) or (r1 isNotSubsumedBy r2)) and
      (r1 arity i) ==> (r2 arity i) ) ) $
end

Relationship!component in Class with
attribute,single,necessary
	position : Integer
end

Class Domain in ObjectType isA ConceptDomain with
attribute
	isSubsumedBy : Domain;
	isNotSubsumedBy : Domain
end
