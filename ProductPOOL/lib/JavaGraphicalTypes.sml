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
Class JavaGraphicalType isA GraphicalType with
attribute
    implementedBy : String;
    property : String;
    priority : Integer
rule
    rPriority : $ forall jgt/JavaGraphicalType (not (exists i/Integer A_e(jgt,priority,i))) ==> A(jgt,priority,0) $
end


Class JavaGraphicalPalette isA GraphicalPalette with
attribute
    defaultIndividual : JavaGraphicalType;
    defaultLink : JavaGraphicalType;
    implicitIsA : JavaGraphicalType;
    implicitInstanceOf : JavaGraphicalType;
    implicitAttribute : JavaGraphicalType;
    palproperty: String  {* for properties of the palette itself such as background color *}
end


{ ********************************************
 DTD for the CBGraphEditorResult:
  <!ELEMENT result (object*)>
  <!ELEMENT object (name,graptype?,edges?)>
			// "main" objects (i.e. direct childs of result) have always edges
  <!ELEMENT name (#PCDATA)>
  <!ELEMENT graphtype (#PCDATA)>
  <!ELEMENT edges (object*)>      
        // objects within edges have no edges
}

Individual CBGraphEditorResult in AnswerFormat with 
  comment c: "This answer format has four parameters: 'obj' is the object
   which is related to the result objects, 'cat' is the category of the link
   between 'obj' and 'this', 'pal' is the graphical palette, and 'objtype'
   specifies whether 'obj' should be considered as source (src) or destination (dst)
   in the set of edges to be included in answer."
  attribute,head
     hd : "<result>"
  attribute,tail
     tl : "</result>"
  attribute,pattern
     p : "
{buildCBEditorResult({this},{obj},{cat},{pal},{objtype})}
"
end 

Individual CBGraphEditorResultWithoutEdges in AnswerFormat with 
  comment c: "This answer format is like CBGraphEditorResult but it
   will not output any edges. Therefore, it has only the parameter
   'pal' to indicate the graphical palette."
  attribute,head
     hd : "<result>"
  attribute,tail
     tl : "</result>"
  attribute,pattern
     p : "
{buildCBEditorResultWithoutEdges({this},{pal})}
"
end 



{** The following queries and answer formats will return all
  graphical types and related information of a JavaGraphicalPalette
  in one XML document. Use GetJavaGraphicalPalette[DefaultJavaPalette/pal] 
  to get the XML document 
  
  DTD of the document:
  <!ELEMENT palette (contains,defaultIndividual,defaultLink,implicitIsA,implicitInstanceOf,implicitAttribute,palproperty*) >
  <!ELEMENT contains (graphtype*)>
  <!ELEMENT graphtype (name,property*,implementedBy)>
  <!ELEMENT property (name,value)>
  <!ELEMENT palproperty (name,value)>
  <!ELEMENT defaultIndividual (#PCDATA)>
  <!ELEMENT defaultLink (#PCDATA)>
  <!ELEMENT implicitIsA (#PCDATA)>
  <!ELEMENT implicitInstanceOf (#PCDATA)>
  <!ELEMENT implicitAttribute (#PCDATA)>
  <!ELEMENT name (#PCDATA)>
  <!ELEMENT label (#PCDATA)>
  <!ELEMENT implementedBy (#PCDATA)>

  **}
  
View GetJavaGraphicalPalette in HiddenObject isA JavaGraphicalPalette with
  parameter
     pal : JavaGraphicalPalette
  inherited_attribute
     defaultIndividual : JavaGraphicalType;
     defaultLink : JavaGraphicalType;
     implicitIsA : JavaGraphicalType;
     implicitInstanceOf : JavaGraphicalType;
     implicitAttribute : JavaGraphicalType;
     contains : JavaGraphicalType;
     palproperty : String
  constraint
     c : $ UNIFIES(this,~pal) $
end

AnswerFormat XML_JavaGraphicalPalette with
  forQuery
     fq : GetJavaGraphicalPalette
  head
     h : "<palette>"
  tail
     t : "</palette>"
  pattern
     p : "
<contains>
{Foreach(({this.contains}),(gt),
{ASKquery(GetJavaGraphicalType[{gt}/gt],XML_JavaGraphicalType)})}
</contains>
  <defaultIndividual>{this.defaultIndividual}</defaultIndividual>
  <defaultLink>{this.defaultLink}</defaultLink>
  <implicitIsA>{this.implicitIsA}</implicitIsA>
  <implicitInstanceOf>{this.implicitInstanceOf}</implicitInstanceOf>
  <implicitAttribute>{this.implicitAttribute}</implicitAttribute>
{Foreach(({this.palproperty},{this|palproperty}),(v,l),
  <palproperty>
    <name>{l}</name>
    <value>{v}</value>
  </palproperty>)}
"
end

View GetJavaGraphicalType in HiddenObject isA JavaGraphicalType with
  parameter
     gt : JavaGraphicalType
  inherited_attribute
     property : String;
     implementedBy : String
  constraint
     c : $ UNIFIES(~gt,this)  $
end

AnswerFormat XML_JavaGraphicalType with
  forQuery
     fq : GetJavaGraphicalType
  head
     h : "<graphtype>"
  tail
     t : "</graphtype>"
  pattern
     p : "
  <name>{this}</name>{Foreach(({this.property},{this|property}),(v,l),
  <property>
    <name>{l}</name>
    <value>{v}</value>
  </property>)}
  <implementedBy>{this.implementedBy}</implementedBy>
"
end
