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

RDF_List with
attribute
  member : RDFS_Resource
end


Class RDFSConstraintsAndRules with
constraint
 isaLiteral :
    $ forall x/RDFS_Datatype (x isA RDFS_Literal) $;
 containerMembershipPropertyConstraint :
    $ forall x/RDFS_Resource!rdfsContainerMembershipProperty
      (x rdfsSubPropertyOf RDFS_Resource!rdfsMember) $
rule
 transitiveSubClassOf :
    $ forall x,y/RDFS_Class (x isA y) ==> (x rdfsSubClassOf y) $;
 transitiveSubPropertyOf :
    $ forall x,y/RDFS_Resource!rdfProperty (x isA y) ==> (x rdfsSubPropertyOf y) $;
 listFirstRule :
    $ forall r/RDFS_Resource l/RDF_List (l rdfFirst r) ==> (l member r) $;
 listRestRule :
    $ forall r/RDFS_Resource l/RDF_List (exists l2/RDF_List
       (l rdfRest l2) and (l2 member r)) ==> (l member r) $
end

{

ECArule TellSubClassOfAsIsA with
ecarule
  er : $ x,y/RDFS_Class
    ON Tell(A(x,rdfsSubClassOf,y))
    IF true
    DO Tell(Isa(x,y))
  $
end

ECArule UntellSubClassOfAsIsA with
ecarule
  er : $ x,y/RDFS_Class
    ON Untell(A(x,rdfsSubClassOf,y))
    IF Isa(x,y)
    DO Untell(Isa(x,y))
  $
end

ECArule TellSubPropertyOfAsIsA with
ecarule
  er : $ x,y/RDFS_Resource!rdfProperty
    ON Tell(A(x,rdfsSubPropertyOf,y))
    IF true
    DO Tell(Isa(x,y))
  $
end


ECArule UntellSubPropertyOfAsIsA with
ecarule
  er : $ x,y/RDFS_Resource!rdfProperty
    ON Untell(A(x,rdfsSubPropertyOf,y))
    IF Isa(x,y)
    DO Untell(Isa(x,y))
  $
end
}

