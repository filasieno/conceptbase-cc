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
{*******************************************}
{*                                         *}
{* File: ERModelGTs                        *}
{* Definition of the graphical palette for *}
{* ER-Diagrams for use on color displays   *}
{*                                         *}
{*******************************************}

{* graphical type for inconsistent roles *}
Class InconsistentGtype in JavaGraphicalType with 
  attribute,property
     textcolor : "0,0,0";
     edgecolor : "255,0,0";
     edgewidth : "2"
implementedBy
     implBy : "i5.cb.graph.cbeditor.CBLink"
priority
     p : 14
end
 

{* graphical type for entities *}
Class EntityTypeGtype in JavaGraphicalType with 
property
     bgcolor : "10,0,250";
     textcolor : "0,0,0";
     linecolor : "0,55,144";
     shape : "i5.cb.graph.shapes.Rect"
implementedBy
     implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority 
    p : 12
end 
 
{* graphical type for relationships *}
Class RelationshipGtype in JavaGraphicalType with 
property
     bgcolor : "255,0,0";
     textcolor : "0,0,0";
     linecolor : "0,0,255";
     shape : "i5.cb.graph.shapes.Diamond"
implementedBy
     implBy : "i5.cb.graph.cbeditor.CBIndividual"
priority 
    p : 13
end 

 
{* graphical palette *}
Class ER_GraphBrowserPalette in JavaGraphicalPalette with 
  contains,defaultIndividual
     c1 : DefaultIndividualGT
  contains,defaultLink
     c2 : DefaultLinkGT
  contains,implicitIsA
     c3 : ImplicitIsAGT
  contains,implicitInstanceOf
     c4 : ImplicitInstanceOfGT
  contains,implicitAttribute
     c5 : ImplicitAttributeGT
  contains
     c6 : DefaultIsAGT;
     c7 : DefaultInstanceOfGT;
     c8 : DefaultAttributeGT;
     c14 : EntityTypeGtype;
     c15 : RelationshipGtype;
     c16 : InconsistentGtype
end 
 

EntityType with rule
    EntityGTRule:
        $ forall e/EntityType  A(e,graphtype,EntityTypeGtype)$ ;
    EntityGTMetaRule:
        $ forall x/VAR (exists e/EntityType In(x,e)) ==> 
          A(x,graphtype,EntityTypeGtype)$
end 
 
 
RelationshipType with rule
     RelationshipGTRule:
         $ forall r/RelationshipType A(r,graphtype,RelationshipGtype)$ ;
     RelationshipGTMetaRule:
         $ forall x/VAR (exists r/RelationshipType In(x,r))  ==> 
           A(x,graphtype,RelationshipGtype) $
end 
