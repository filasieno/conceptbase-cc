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
Individual ResourceGT in JavaGraphicalType with
  attribute,property
     bgcolor : "153,204,255";
     textcolor : "0,0,0";
     linecolor : "0,0,0";
     shape : "i5.cb.graph.shapes.Rect"
  attribute,priority
     p : 31
  attribute,implementedBy
     implBy : "i5.cb.ontology.OntologyComponent"
end


Individual RDFS_Class_GT in JavaGraphicalType with
  attribute,property
     bgcolor : "51,102,255";
     textcolor : "0,0,0";
     linecolor : "0,0,0";
     shape : "i5.cb.graph.shapes.Ellipse"
  attribute,priority
     p : 32
  attribute,implementedBy
     implBy : "i5.cb.ontology.OntologyComponent"
end


Individual OWL_Class_GT in JavaGraphicalType with
  attribute,property
     bgcolor : "0,102,255";
     textcolor : "0,0,0";
     linecolor : "0,0,0";
     shape : "i5.cb.graph.shapes.Ellipse"
  attribute,priority
     p : 33
  attribute,implementedBy
     implBy : "i5.cb.ontology.OntologyComponent"
end

Individual LiteralDatatypeGT in JavaGraphicalType with
  attribute,property
     bgcolor : "204,204,204";
     textcolor : "0,0,0";
     linecolor : "0,0,0";
     shape : "i5.cb.graph.shapes.Rect"
  attribute,priority
     p : 34
  attribute,implementedBy
     implBy : "i5.cb.ontology.OntologyComponent"
end

Individual RDF_Property_GT in JavaGraphicalType with
  attribute,property
     textcolor : "0,0,0";
     edgecolor : "0,0,0";
     edgewidth : "2"
  attribute,implementedBy
     implBy : "i5.cb.graph.cbeditor.CBLink"
  attribute,priority
     p : 35
end

Individual RDFS_SubClass_GT in JavaGraphicalType with
  attribute,property
     bgcolor : "0,205,255";
     textcolor : "0,0,0";
     linecolor : "0,205,255";
     edgecolor : "0,205,255";
     edgewidth : "4";
     label : "subClassOf"
  attribute,implementedBy
     implBy : "i5.cb.graph.cbeditor.CBLink"
  attribute,priority
     p : 36
end


Individual RDFS_ContainerGT in JavaGraphicalType with
  attribute,property
     bgcolor : "204,204,204";
     textcolor : "0,0,0";
     linecolor : "0,0,0";
     shape : "i5.cb.graph.shapes.RoundRectangle"
  attribute,priority
     p : 37
  attribute,implementedBy
     implBy : "i5.cb.ontology.OntologyComponent"
end


Individual OWL_EquivalentClass_GT in JavaGraphicalType with
  attribute,property
     bgcolor : "0,155,255";
     textcolor : "0,0,0";
     linecolor : "0,155,255";
     edgecolor : "0,155,255";
     edgewidth : "4";
     label : "equivalentClass"
  attribute,implementedBy
     implBy : "i5.cb.graph.cbeditor.CBLink"
  attribute,priority
     p : 38
end

Individual OWL_ComplementOf_GT in JavaGraphicalType with
  attribute,property
     bgcolor : "255,15,15";
     textcolor : "0,0,0";
     linecolor : "255,15,15";
     edgecolor : "255,15,15";
     edgewidth : "3";
     label : "complementOf"
  attribute,implementedBy
     implBy : "i5.cb.graph.cbeditor.CBLink"
  attribute,priority
     p : 39
end

Individual OWL_DisjointWith_GT in JavaGraphicalType with
  attribute,property
     bgcolor : "255,0,155";
     textcolor : "0,0,0";
     linecolor : "255,0,155";
     edgecolor : "255,0,155";
     edgewidth : "3";
     label : "disjointWith"
  attribute,implementedBy
     implBy : "i5.cb.graph.cbeditor.CBLink"
  attribute,priority
     p : 40
end

Individual OntologyGT in JavaGraphicalType with
  attribute,property
     bgcolor : "255,255,255";
     textcolor : "0,0,0";
     linecolor : "0,0,0";
     shape : "i5.cb.graph.shapes.Ellipse"
  attribute,priority
     p : 41
  attribute,implementedBy
     implBy : "i5.cb.ontology.OntologyDialog"
end

Class OWL_GraphicalPalette in JavaGraphicalPalette with
 attribute,contains,defaultIndividual
     c1 : DefaultIndividualGT
  attribute,contains,defaultLink
     c2 : DefaultLinkGT
  attribute,contains,implicitIsA
     c3 : ImplicitIsAGT
  attribute,contains,implicitInstanceOf
     c4 : ImplicitInstanceOfGT
  attribute,contains,implicitAttribute
     c5 : ImplicitAttributeGT
  attribute,contains
     c6 : DefaultIsAGT;
     c7 : DefaultInstanceOfGT;
     c8 : DefaultAttributeGT;
     c9 : MetametaGT;
     c10 : SimpleClassGT;
     c11 : MetaClassGT;
     c12 : ClassGT;
     c13 : QueryClassGT;
     c31 : ResourceGT;
     c32 : RDFS_Class_GT;
     c33 : OWL_Class_GT;
     c34 : LiteralDatatypeGT;
     c35 : RDF_Property_GT;
     c36 : RDFS_SubClass_GT;
     c37 : RDFS_ContainerGT;
     c38 : OWL_EquivalentClass_GT;
     c39 : OWL_ComplementOf_GT;
     c40 : OWL_DisjointWith_GT;
     c41 : OntologyGT
rule
  r31 : $ forall r/RDFS_Resource (r graphtype ResourceGT) $;
  r32 : $ forall c/RDFS_Class (c graphtype RDFS_Class_GT) $;
  r33 : $ forall c/OWL_Class (c graphtype OWL_Class_GT) $;
  r34 : $ forall c/RDFS_Literal (c graphtype LiteralDatatypeGT) $;
  r34b : $ forall c/RDFS_Datatype (c graphtype LiteralDatatypeGT) $;
  r35 : $ forall c/RDFS_Resource!rdfProperty (c graphtype RDF_Property_GT) $;
  r36 : $ forall c/RDFS_Class!rdfsSubClassOf (c graphtype RDFS_SubClass_GT) $;
  r37 : $ forall c/RDFS_Container (c graphtype RDFS_ContainerGT) $;
  r37b : $ forall c/RDF_List (c graphtype RDFS_ContainerGT) $;
  r38 : $ forall l/OWL_Class!owlEquivalentClass (l graphtype OWL_EquivalentClass_GT) $;
  r39 : $ forall l/OWL_Class!owlComplementOf (l graphtype OWL_ComplementOf_GT) $;
  r40 : $ forall l/OWL_Class!owlDisjointWith (l graphtype OWL_DisjointWith_GT) $;
  r41 : $ forall o/Ontology (o graphtype OntologyGT) $
end

