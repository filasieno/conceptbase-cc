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
Ontology with
attribute
  contains : RDFS_Resource;
  url : String;
  comment : String;
  backwardCompatibleWith : String;
  imports : String;
  incompatibleWith : String;
  priorVersion : String
end

RDFS_Resource in RDFS_Class
end

RDFS_Class in RDFS_Class isA RDFS_Resource
end

RDFS_Literal in RDFS_Class isA RDFS_Resource
end

RDFS_Datatype in RDFS_Class isA RDFS_Class
end

RDF_XMLLiteral in RDFS_Datatype  isA RDFS_Literal
end

RDFS_Resource with
attribute
  rdfProperty : RDFS_Resource;
  localName : String
end

RDFS_Class with
rdfProperty
  rdfsSubClassOf : RDFS_Class
end

RDFS_Resource!rdfProperty in RDFS_Class isA RDFS_Resource with
rdfProperty
  rdfsSubPropertyOf : RDFS_Resource!rdfProperty
end

RDFS_Resource with
rdfProperty
  rdfsDomain : RDFS_Resource;
  rdfsRange : RDFS_Resource;
  rdfType : RDFS_Resource;  { originally RDFS_Class }
  rdfsLabel : RDFS_Literal;
  rdfsComment : RDFS_Resource
end



RDFS_Container isA RDFS_Resource
end


RDF_Bag isA RDFS_Container end
RDF_Seq isA RDFS_Container end
RDF_Alt isA RDFS_Container end


RDFS_Resource with
attribute
   rdfsContainerMembershipProperty : RDFS_Resource
end

RDFS_Resource!rdfsContainerMembershipProperty isA RDFS_Resource!rdfProperty
end

RDFS_Resource with
rdfProperty
   rdfsMember : RDFS_Resource
end


RDF_List in RDFS_Class isA RDFS_Resource with
rdfProperty
   rdfFirst : RDFS_Resource;
   rdfRest : RDF_List
end

RDF_nil in RDF_List
end


RDFS_Statement in RDFS_Class isA RDFS_Resource with
rdfProperty
   rdfSubject : RDFS_Resource;
   rdfPredicate : RDFS_Resource!rdfProperty;
   rdfObject : RDFS_Resource
end

RDFS_Resource with
rdfProperty
   rdfSeeAlso : RDFS_Resource;
   rdfIsDefinedBy : RDFS_Resource;
   rdfValue : RDFS_Resource
end

GenericQueryClass GetContainedElements isA RDFS_Resource with
parameter
   ontology : Ontology;
   type : RDFS_Resource
constraint
   c : $ (~ontology contains this) and (this in ~type) $
end
