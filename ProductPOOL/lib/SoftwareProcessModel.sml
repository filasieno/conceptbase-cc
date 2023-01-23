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
{*
*
* File:        SoftwareProcessModel.sml
* Version:     2.3
* Creation:    04-May-1987, Matthias Jarke,Thomas Rose (UPA)
* Last change: 24 Jul 1990, Manfred Jeusfeld (UPA)
* Release:     2
* ----------------------------------------------------------
*
* The process model defines design objects, design
* decisions and design tools. The notion of dependencies between
* attributes allows a detailed description of a design decision.
*
* Classes may specify a trigger which is activated when inserting a
* new instance.
*
* 30-Jan-1989/MJf: Version 2.0
*}


Individual Proposition with
  attribute
     dependson: Proposition
end



Class DesignObject in MetametaClass isA MetaClass with
  attribute
       justification: DesignDecision;
       objectsemantic: Class;
       objectsource: ExternalReference;
       part: DesignObject
end



Class DesignDecision in MetametaClass isA DesignObject with
   attribute
        from: DesignObject;
	to: DesignObject;
	decisionsemantic: DecisionDescription;
	part: DesignDecision;
        by: DesignTool
end


Class DesignTool in MetametaClass isA DesignDecision with
   attribute
	from: DesignDecision;
	to: BehaviorObject
end



Class ExternalReference in MetaClass isA SimpleClass with end


Class BehaviorObject in MetametaClass isA DesignObject with end


Class DecisionDescription in MetametaClass isA MetaClass with
   attribute
	dependencies: Proposition!dependson
end



