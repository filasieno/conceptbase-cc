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

Relation with
attribute
  hasAdornedQuery : AdornedQuery
constraint
  all_value_Adornment_constraint :
    $ forall r/Relation aq/AdornedQuery i,a/Integer (r arity a) and
     (r hasAdornedQuery aq) and (i <= a) ==> (exists vc/ValueConstraint
     (aq hasAdornment vc) and (vc variable i)) $;
  onlyConceptRelationship&Attrib_name :
    $ forall r/Relation a/AdornedQuery dq/DisjunctiveQuery
      cq/ConjunctiveQuery c/Conjunct (r hasAdornedQuery a) and
      (((a hasBody dq) and (dq disjunct cq)) or (a hasBody cq))
      and (cq containsSyntactically c) ==> (c in ConceptRelationship)
      or (c in Attrib_name) $
end

Class DWRelation in ObjectType isA Relation with
attribute
    hasMediator : Mediator
end

Class AdornedQuery in ObjectType isA LogicalObject with
attribute, necessary,single
    hasBody : Query
attribute,necessary
    hasAdornment : Adornment
end


Class Adornment in ObjectType isA LogicalObject with
constraint
  unionAdornment:
    $ forall a/Adornment (a in ValueConstraint) or (a in Identify) $;
  xorAdornment:
    $ forall v/ValueConstraint not (v in Identify) $
end

Class ValueConstraint in ObjectType isA Adornment with
attribute,single,necessary
    variable : Integer;
    value   : Domain
end

Class Identify in ObjectType isA Adornment with
attribute, necessary
    ident : Integer
attribute,single,necessary
    object : Integer
end

Class Query in ObjectType with
constraint
  unionQuery :
    $ forall q/Query
      (q in ConjunctiveQuery) or (q in DisjunctiveQuery) $;
  xorQuery :
    $ forall q/ConjunctiveQuery not (q in DisjunctiveQuery) $
end

Class ConjunctiveQuery in ObjectType isA Query with
attribute,single,necessary
    body : String
attribute
    containsSyntactically : Conjunct
end

Class DisjunctiveQuery in ObjectType isA Query with
attribute,necessary
    disjunct : ConjunctiveQuery
end

Class RewrittenQuery in ObjectType isA Query with
constraint
  unionRewrittenQuery :
    $ forall q/RewrittenQuery (q in RewrittenConjunctiveQuery) or
      (q in RewrittenDisjunctiveQuery) $;
  xorRewrittenQuery :
    $ forall q/RewrittenConjunctiveQuery
       not (q in RewrittenDisjunctiveQuery) $
end

Class RewrittenConjunctiveQuery in ObjectType
  isA ConjunctiveQuery,RewrittenQuery with
constraint
  onlyRelation&Correspondence :
    $ forall r/RewrittenConjunctiveQuery c/Conjunct
     (r containsSyntactically c) ==>
     (c in Relation) or (c in Correspondence) $
end

Class RewrittenDisjunctiveQuery in ObjectType
  isA DisjunctiveQuery,RewrittenQuery with
constraint
  onlyRewrittenConjunctiveQuery:
    $ forall r/RewrittenDisjunctiveQuery c/ConjunctiveQuery
      (r disjunct c) ==> (c in RewrittenConjunctiveQuery) $
end

Class Conjunct in ObjectType  isA LogicalObject with
constraint
  unionConjunct :
    $ forall c/Conjunct (c in Relation) or (c in ConceptRelationship)
    or (c in Attrib_name) or (c in Correspondence) or (c in Domain) $;
  xorConjunct1 :
    $ forall c/Relation not (c in ConceptRelationship) and
       not (c in Attrib_name) and not (c in Correspondence)
       and not (c in Domain) $;
  xorConjunct2 :
    $ forall c/ConceptRelationship not(c in Attrib_name) and
    not (c in Correspondence) and not (c in Domain) $;
  xorConjunct3 :
    $ forall c/Attrib_name not
      (c in Correspondence) and not (c in Domain) $;
  xorConjunct4 :
    $ forall c/Domain not (c in Correspondence) $
end

Relation isA Conjunct end

ConceptRelationship isA Conjunct end

Domain isA Conjunct end

Attrib_name isA Conjunct end

Class Correspondence in ObjectType isA Conjunct with
attribute,single,necessary
  condition : ConjunctiveQuery;
  arity     : Integer
attribute,necessary
  argumentDimension : Integer
attribute,single
  program : String
constraint
  notRelation :
    $ forall cr/Correspondence dq/DisjunctiveQuery cq/ConjunctiveQuery
      c/Conjunct (((cr condition cq) or ((cr condition dq) and
      (dq disjunct cq))) and (cq containsSyntactically c)) ==>
      not (c in Relation) $;
  position_constraint :
    $ forall c/Correspondence a1,a2/Correspondence!argumentDimension
      i,p1,p2/Integer (Ai(c,argumentDimension,a1) and
      Ai(c,argumentDimension,a2) and (a1 position p1) and
      (a2 position p2) and not (a1 == a2) and A(c,arity,i)) ==>
      (not (p1 ==p2) and (p1 <= i) and (p2 <= i)) $;
  all_positions_constraint :
    $ forall c/Correspondence i,a/Integer A(c,arity,a) and (i <= a) ==>
      (exists arg/Correspondence!argumentDimension
       Ai(c,argumentDimension,arg) and (arg position i)) $
end

Correspondence!argumentDimension in Class with
attribute,single,necessary
    position : Integer
end

Class Convert in ObjectType isA Correspondence with
constraint
    c : $ forall c/Convert i/Integer (c arity i) ==> (i=2) $
end

Class Reconcile in ObjectType isA Correspondence
end

Class Match in ObjectType isA Correspondence
end

Class Mediator in ObjectType isA LogicalObject with
attribute,single,necessary
    hasBody : RewrittenQuery
attribute
    hasMergingClause : MergingClause
end

Class MergingClause in ObjectType isA LogicalObject with
attribute, necessary
    mergingPart : RewrittenConjunctiveQuery
attribute, single
    suchThatPart : RewrittenConjunctiveQuery
attribute,single, necessary
    intoPart : RewrittenConjunctiveQuery
constraint
  onlyCorrespondence_for_suchThatPart :
    $ forall m/MergingClause r/RewrittenConjunctiveQuery c/Conjunct
      (m suchThatPart r) and (r containsSyntactically c) ==>
      (c in Correspondence) $;
  onlyRelation_for_intoPart :
    $ forall m/MergingClause r/RewrittenConjunctiveQuery c/Conjunct
     (m intoPart r) and (r containsSyntactically c)==>(c in Relation)$
end
