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
OWL_Class in RDFS_Class isA RDFS_Resource,RDFS_Class
end

OWL_AnonymousClass in RDFS_Class isA OWL_Class
end

OWL_Class with
rdfProperty
  owlUnionOf : RDF_List;
  owlIntersectionOf : RDF_List;
  owlComplementOf : OWL_Class;
  owlOneOf : RDF_List
end

Thing in OWL_Class isA RDFS_Resource with
owlUnionOf
   union : ThingList
end

"http://www.daml.org/2001/03/daml+oil#Thing" in OWL_Class isA RDFS_Resource with
owlUnionOf
   union : ThingList
end

"http://www.daml.org/2001/03/daml+oil#Class" in OWL_Class isA RDFS_Resource with
owlUnionOf
   union : ThingList
end

ThingList in RDF_List with
member
  first : Nothing;
  second : OWL_AnonymousComplementOfNothing
end

OWL_AnonymousComplementOfNothing in OWL_AnonymousClass with
owlComplementOf
   complement : Nothing
end

Nothing in OWL_Class with
owlComplementOf
  complement : Thing
end

OWL_Class with
rdfProperty
  owlEquivalentClass : OWL_Class
end

OWL_Class!owlEquivalentClass isA RDFS_Class!rdfsSubClassOf
end

OWL_Class with
rdfProperty
  owlDisjointWith : OWL_Class
end

RDFS_Resource!rdfProperty with
rdfProperty
  owlEquivalentProperty : RDFS_Resource!rdfProperty
end

RDFS_Resource!rdfProperty!owlEquivalentProperty isA RDFS_Resource!rdfProperty!rdfsSubPropertyOf
end

Thing with
rdfProperty
  sameAs : Thing;
  differentFrom : Thing
end

OWL_AllDifferent in RDFS_Class isA RDFS_Resource with
rdfProperty
  owlDistinctMember : RDF_List
end

OWL_Restriction in RDFS_Class isA OWL_Class with
rdfProperty
  owlOnProperty : RDFS_Resource!rdfProperty;
  owlAllValuesFrom : RDFS_Class;
  owlHasValue : RDFS_Resource;   { TODO: range not defined, may be also data value }
  owlSomeValuesFrom : RDFS_Class;
  owlMinCardinality : Integer;
  owlMaxCardinality : Integer;
  owlCardinality : Integer
end

Integer in RDFS_Resource
end

Real in RDFS_Resource
end

RDFS_Class with
attribute
   owlObjectProperty : RDFS_Class;
   owlDatatypeProperty : RDFS_Resource
end

RDFS_Class!owlObjectProperty in RDFS_Class isA RDFS_Resource!rdfProperty
end

RDFS_Class!owlDatatypeProperty in RDFS_Class isA RDFS_Resource!rdfProperty
end

RDFS_Class!owlObjectProperty with
rdfProperty
   owlInverseOf : RDFS_Class!owlObjectProperty
end


RDFS_Class with
attribute
   owlTransitiveProperty : RDFS_Class;
   owlSymmetricProperty : RDFS_Class;
   owlFunctionalProperty : RDFS_Class;
   owlInverseFunctionalProperty : RDFS_Class;
   owlAnnotationProperty : RDFS_Class
end

RDFS_Class!owlTransitiveProperty in RDFS_Class isA RDFS_Class!owlObjectProperty
end

RDFS_Class!owlSymmetricProperty in RDFS_Class isA RDFS_Class!owlObjectProperty
end

RDFS_Class!owlFunctionalProperty in RDFS_Class isA RDFS_Resource!rdfProperty
end

RDFS_Class!owlInverseFunctionalProperty in RDFS_Class isA RDFS_Class!owlObjectProperty
end

RDFS_Class!owlAnnotationProperty in RDFS_Class isA RDFS_Resource!rdfProperty
end


RDFS_Resource!rdfsLabel in RDFS_Class!owlAnnotationProperty with
rdfType
   type : RDFS_Class!owlAnnotationProperty
end


RDFS_Resource!rdfsComment in RDFS_Class!owlAnnotationProperty with
rdfType
   type : RDFS_Class!owlAnnotationProperty
end


RDFS_Resource!rdfSeeAlso in RDFS_Class!owlAnnotationProperty with
rdfType
   type : RDFS_Class!owlAnnotationProperty
end


RDFS_Resource!rdfIsDefinedBy in RDFS_Class!owlAnnotationProperty with
rdfType
   type : RDFS_Class!owlAnnotationProperty
end

RDFS_Class with
attribute
   owlOntologyProperty : RDFS_Resource
end

RDFS_Class!owlOntologyProperty in RDFS_Class isA RDFS_Resource!rdfProperty
end

OWL_Ontology in RDFS_Class with
rdfProperty,owlOntologyProperty
   owlImports : OWL_Ontology;
   owlPriorVersion : OWL_Ontology;
   owlBackwardCompatibleWith : OWL_Ontology;
   owlIncompatibleWith : OWL_Ontology
end


RDFS_Resource with
rdfProperty,owlAnnotationProperty
   owlVersionInfo : RDFS_Resource
end

RDFS_Resource!owlVersionInfo with
rdfType
   type : RDFS_Class!owlAnnotationProperty
end

OWL_DeprecatedClass in RDFS_Class isA RDFS_Class
end

RDFS_Resource with
attribute
   owlDeprecatedProperty : RDFS_Resource
end

RDFS_Resource!owlDeprecatedProperty isA RDFS_Resource!rdfProperty
end

OWL_DataRange isA RDFS_Class
end

Undefined in OWL_Class isA RDFS_Resource
end
