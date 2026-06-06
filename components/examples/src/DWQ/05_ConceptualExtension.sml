{*
The ConceptBase.cc Copyright

Copyright 1987-2024 The ConceptBase Team. All rights reserved.

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
Class AtomicConceptRelationship in ObjectType
  isA ConceptRelationship with
attribute
    attrib : Attrib_name
constraint
  exists_destination:
    $ forall c/AtomicConceptRelationship at/Attrib_name (c attrib at)
       ==> (exists ca/AtomicConceptRelationship!attrib Ai(c,attrib,ca)
       and To(ca,at) ) $;
  unionConceptRelationship :
    $ forall c/ConceptRelationship
      (c in AtomicConcept) or (c in ComplexConcept) or
      (c in AtomicRelationship) or (c in ComplexRelationship) $
end

Class Attrib_name in ObjectType isA ConceptualObject with
attribute, single, necessary
    refersTo: Model
end

AtomicConceptRelationship!attrib in Class with
  attribute,necessary,single
     destination : ConceptDomain;
     functional : Boolean;
     mandatory : Boolean
end

Class ComplexConceptRelationship in ObjectType
  isA ConceptRelationship with
attribute,single,necessary
    definition : String
attribute
    containsSyntactically : ConceptualObject
constraint
  atomicContainmentConstraint :
    $ forall c/ComplexConceptRelationship d/ConceptualObject
    (c containsSyntactically d) ==> ((d in AtomicConceptRelationship)
     or (d in AtomicDomain) or (d in Attrib_name)) $;
  sameModelConstraint :
    $ forall c1/ComplexConceptRelationship c2/AtomicConceptRelationship
      m/Model ((c1 refersTo m) and (c1 containsSyntactically c2))
      ==> (c2 refersTo m) $
end

Class AtomicConcept in ObjectType isA Concept,AtomicConceptRelationship
end

Class ComplexConcept in ObjectType
  isA Concept,ComplexConceptRelationship
end

Class AtomicRelationship in ObjectType
  isA Relationship,AtomicConceptRelationship
end

Class ComplexRelationship in ObjectType
  isA Relationship,ComplexConceptRelationship with
end

Class AtomicDomain in ObjectType isA Domain with
constraint
  xorDomain :
    $ forall ad/AtomicDomain  not (ad in ComplexDomain) $;
  unionDomain :
    $ forall d/Domain (d in AtomicDomain) or (d in ComplexDomain) $
end

Class ComplexDomain in ObjectType isA Domain with
attribute,single,necessary
    domainDefinition : String
attribute
    containsSyntactically : AtomicDomain
end

Class Assertion in ObjectType isA ConceptualObject with
attribute,single,necessary
    equivalence: Boolean
constraint
  unionAssertion :
    $ forall a/Assertion
      (a in DomainAssertion) or (a in ModelAssertion) $;
  conceptComponentAssertion :
    $ forall a/ModelAssertion l,r/Relationship i/Integer
      (exists lc,rc/Relationship!component cdl,cdr/ConceptDomain
      ( (a left l) and (a right r) and From(lc, l) and To(lc, cdl)
       and From(rc, r) and To(rc, cdr) and (lc position i) and
      (rc position i) and (cdl in Concept) ==> (cdr in Concept) ) ) $;
  domainComponentAssertion :
    $ forall a/ModelAssertion l,r/Relationship i/Integer
      (exists lc,rc/Relationship!component cdl,cdr/ConceptDomain
      ((a left l) and (a right r) and From(lc, l) and
      To(lc, cdl) and From(rc, r) and To(rc, cdr) and (lc position i)
      and (rc position i) and (cdl in Domain) ==> (cdr in Domain))) $
end

Class DomainAssertion in ObjectType isA Assertion with
attribute,single,necessary
    left : Domain;
    right : Domain
end

Class ModelAssertion in ObjectType isA Assertion with
attribute,single,necessary
    left : ConceptRelationship;
    right : ConceptRelationship
constraint
  conceptAssertion:
    $ forall a/ModelAssertion l,r/ConceptRelationship (a left l) and
      (a right r) and (l in Concept) ==> (r in Concept) $;
  relationshipAssertion:
    $ forall a/ModelAssertion l,r/ConceptRelationship (a left l) and
      (a right r) and (l in Relationship)==>(r in Relationship) $;
  relationshipArityAssertion:
    $ forall a/ModelAssertion l,r/Relationship (exists i/Integer
      ((a left l) and (a right r) and (l arity i) ==> (r arity i))) $;
  unionModelAssertion:
    $ forall a/ModelAssertion
      (a in InterModelAssertion) or (a in IntraModelAssertion) $
end

Class IntraModelAssertion in ObjectType isA ModelAssertion with
constraint
  intraModel:
    $ forall a/IntraModelAssertion l,r/ConceptRelationship m/Model
     (a left l) and (a right r) and (l refersTo m) ==> (r refersTo m) $
end

Class InterModelAssertion in ObjectType isA ModelAssertion with
attribute,single,necessary
    intensional: Boolean
constraint
  interModel:
   $ forall a/InterModelAssertion l,r/ConceptRelationship m1,m2/Model
   (a left l) and (a right r) and (l refersTo m1) and (r refersTo m2)
     ==> not (m1 == m2) $
end

