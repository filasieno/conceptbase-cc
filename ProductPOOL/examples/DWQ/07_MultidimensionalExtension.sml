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

Class Aggregation in ObjectType isA Concept with
attribute
	refines : Aggregation;
 	aggregatedBy : DimensionLevel;
	aggregatedAttributes: DerivedAttribute
attribute,single,necessary
	aggregates : Concept
constraint
  eitherOr:
    $ forall a/Aggregation d/DimensionLevel der/DerivedAttribute
      R1,R2/Relationship
      ((a aggregatedBy d) and (a aggregatedAttributes der) and
       (d accordingTo R1) and (der attributeName R2))
       ==> (not IDENTICAL(R1,R2)) $;
  atMostOnePerRelation:
    $ forall a/Aggregation d1,d2/DimensionLevel R1,R2/Relationship
      ((a aggregatedBy d1) and (a aggregatedBy d2) and
       (d1 accordingTo R1) and (d2 accordingTo R2) and
       (not IDENTICAL(d1,d2))) ==> not (IDENTICAL(R1,R2))$
end

Class DimensionLevel in ObjectType isA ConceptualObject with
attribute,single, necessary
	within : Level;
    accordingTo : DimensionAttribute
end

Class Level in ObjectType isA Concept end

Class DimensionAttribute in ObjectType isA Relationship end

Class DerivedAttribute in ObjectType isA ConceptualObject with
attribute,single, necessary
	attributeName : Relationship;
	aggFunction : AggregationFunction
end

Class AggregationFunction in ObjectType isA ConceptualObject with
attribute, single, necessary
	monotone : Boolean;
	additive : Boolean
end


Class ComplexAggregation in ObjectType isA Aggregation with
constraint
	aggregatedBy_is_necessary:
	$ forall c/ComplexAggregation (exists d/DimensionLevel
	(c aggregatedBy d)) $
end


