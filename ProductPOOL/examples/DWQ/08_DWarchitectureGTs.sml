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
{ The GraphicalPalette for the DWQ model }

Class DWQ_Palette in JavaGraphicalPalette with
contains,defaultIndividual
	c1 : DefaultIndividualGT
contains,defaultLink
	c2 : DefaultLinkGT
implicitIsA, contains
    c3 : ImplicitIsAGT
implicitInstanceOf, contains
    c4 : ImplicitInstanceOfGT
implicitAttribute, contains
    c5 : ImplicitAttributeGT
contains
    c6 : DefaultIsAGT;
    c7 : DefaultInstanceOfGT;
    c8 : DefaultAttributeGT;
    c9 : MetametaGT;
    c10 : SimpleClassGT;
    c11 : MetaClassGT;
    c12 : ClassGT;
    c13 : QueryClassGT;

	c15 : DW_ComponentGT;
	c16 : ProgramGT;
	c17 : DataStoreGT;
	c18 : SchemaGT;
	c19 : TypeGT;
	c20 : InstDW_ComponentGT;
	c21 : InstProgramGT;
	c22 : InstDataStoreGT;
	c23 : InstSchemaGT;
	c24 : InstTypeGT;
	c25 : InstComputerGT;
	c30 : DeliversToGT;
	c31 : ModelGT;
	c32 : ConceptGT;
	c33 : ConceptualGT;
	c34 : RelationshipGT
end


{ GraphicalType for an attribute link. }
DeliversToGT in JavaGraphicalType with
property
	bgcolor : "20,20,210";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.Diamond"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBLink"
priority
    pr : 21
end


{ Graphical type for the DW_Component object. }
DW_ComponentGT in JavaGraphicalType with
property
	bgcolor : "0,0,255";
	textcolor : "0,0,0";
	linecolor : "0,0,255";
	shape : "i5.cb.graph.shapes.Rect"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 22
end


{ Graphical type for the instances of DW_Component. }
InstDW_ComponentGT in JavaGraphicalType with
property
	bgcolor : "0,0,255";
	textcolor : "0,0,0";
	linecolor : "0,155,255";
	shape : "i5.cb.graph.shapes.Rect"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 23
end

{ Explicit and implicit definition of graphtype attribute }
DW_Component with
graphtype
	gt : DW_ComponentGT
rule
	dwrule : $ (this graphtype InstDW_ComponentGT) $
rule
	delrule : $ forall l/DW_Component!deliversTo (l graphtype DeliversToGT) $
end

{ Graphical type for Program object. }
ProgramGT in JavaGraphicalType with
property
	bgcolor : "0,200,0";
	textcolor : "0,0,0";
	linecolor : "0,0,255";
	shape : "i5.cb.graph.shapes.Ellipse"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 24
end


{ Graphical type for instances of the Program object. }
InstProgramGT in JavaGraphicalType with
property
	bgcolor : "0,200,0";
	textcolor : "0,0,0";
	linecolor : "0,0,255";
	shape : "i5.cb.graph.shapes.Ellipse"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 24
end


{ Explicit and implicit definition of graphtype attribute }
Program with
graphtype
	gt2 : InstProgramGT
rule
	progrule : $ (this graphtype InstProgramGT) $
rule
	isarule : $ forall c/Class Isa(c,Program) ==> (c graphtype ProgramGT) $
end

{ Graphical type for DataStore object. }
DataStoreGT in JavaGraphicalType with
property
	bgcolor : "200,200,200";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.Rect"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 25
end

{ Grapical type for instances of DataStore. This is a pixmap. }
InstDataStoreGT in JavaGraphicalType with
property
	textcolor : "0,0,0";
	linecolor : "0,0,0";
    image : "http://www-i5.informatik.rwth-aachen.de/~quix/cb/pics/datastore.jpg"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 26
end

{ Explicit and implicit definition of graphtype attribute }
DataStore with
graphtype
	gt2 : InstDataStoreGT
rule
	dsrule : $ (this graphtype InstDataStoreGT) $
rule
	isarule : $ forall c/Class Isa(c,DataStore) ==> (c graphtype InstDataStoreGT) $
end



{ Graphical type for Schema }
SchemaGT in JavaGraphicalType with
property
    bgcolor : "222,222,222";
	textcolor : "0,0,255";
	linecolor : "0,0,255";
	shape : "i5.cb.graph.shapes.Rect";
	fontstyle : "italic"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 27
end

{ Graphical type for instances of  Schema }
InstSchemaGT in JavaGraphicalType with
property
    bgcolor : "222,222,222";
	textcolor : "0,0,255";
	linecolor : "0,0,255";
	shape : "i5.cb.graph.shapes.Rect"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 28
end


{ Explicit and implicit definition of graphtype attribute }
Schema with
graphtype
	gt2 : SchemaGT
rule
	schemarule : $ (this graphtype InstSchemaGT) $
end


{ Graphical type for Type }
TypeGT in JavaGraphicalType with
property
    bgcolor : "255,255,255";
	textcolor : "0,0,255";
	linecolor : "0,0,255";
	shape : "i5.cb.graph.shapes.Rect";
	fontstyle : "italic,bold"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 29
end



{ Graphical type for instances of Type }
InstTypeGT in JavaGraphicalType with
property
    bgcolor : "255,255,255";
	textcolor : "0,0,255";
	linecolor : "0,0,255";
	shape : "i5.cb.graph.shapes.Rect"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 30
end


{ Explicit and implicit definition of graphtype attribute }
Type with
graphtype
	gt2 : TypeGT
rule
	typerule : $ (this graphtype InstTypeGT) $
end


{ Graphical type for instances of Computer. }
InstComputerGT in JavaGraphicalType with
property
	textcolor : "0,0,0";
	linecolor : "0,0,0";
    image : "http://www-i5.informatik.rwth-aachen.de/~quix/cb/pics/server.jpg"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 31
end

Computer with
rule
	comprule : $ (this graphtype InstComputerGT) $
end




ModelGT in JavaGraphicalType with
property
    bgcolor : "255,255,255";
	textcolor : "0,255,255";
	linecolor : "0,255,255";
	shape : "i5.cb.graph.shapes.Rect";
	fontstyle : "italic,bold"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 32
end


ConceptGT in JavaGraphicalType with
property
    bgcolor : "255,255,255";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.Rect";
	fontstyle : "italic"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 33
end

ConceptualGT in JavaGraphicalType with
property
    bgcolor : "255,255,255";
	textcolor : "0,0,0";
	linecolor : "255,0,0";
	shape : "i5.cb.graph.shapes.Rect";
	fontstyle : "italic,bold"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 25 { lower than ConceptGT }
end

Class RelationshipGT in JavaGraphicalType with
property
    bgcolor : "255,255,255";
	textcolor : "0,0,0";
	linecolor : "0,0,0";
	shape : "i5.cb.graph.shapes.Diamond";
	fontstyle : "italic"
implementedBy
	implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority
    pr : 35
end


ConceptualObject with
rule
	gtrule1 : $ forall x/Proposition (x isA ConceptualObject) ==> (x graphtype ConceptualGT) $;
	gtrule2 : $ (this graphtype ConceptualGT) $
end

Model with
rule
	gtrule3: $ (this graphtype ModelGT) $
end

Concept with
rule
	gtrule4 : $ (this graphtype ConceptGT) $
end

Relationship with
rule
	gtrule5 : $  (this graphtype RelationshipGT) $
end

