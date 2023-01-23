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
* File:        QueryModel.sml
* Version:     2.6
* Creation:    2-Dec-1988, Manfred Jeusfeld (UPA)
* Last Change: 9-Oct-2008, Manfred Jeusfeld (UvT)
* Release:     2
* -----------------------------------------------------------------------------
*
* This is the model for queries in CML. See also
* AssertionModel.sml.
*
*}


Class MSFOLquery in Assertions isA MSFOLconstraint with end


Class QueryClass isA Class with
  attribute
     retrieved_attribute : Proposition;
     computed_attribute : Proposition;
     constraint : MSFOLquery
end

Class GenericQueryClass isA QueryClass with
   attribute
      parameter : Proposition;
      required : Proposition   {* to mark certain parameters as required *}
end

Class BuiltinQueryClass isA GenericQueryClass with
end

{ Views }
Class View isA GenericQueryClass with
attribute
        partof : Proposition;
		inherited_attribute : Proposition
end

SubView isA View
end

{ Datalog Queries }
Class DatalogQueryClass isA GenericQueryClass with
attribute
   code : String
end

Class DatalogRule with
attribute
  concernedClass : Proposition;
  code : String
end

Class DatalogInRule isA DatalogRule
end

Class DatalogAttrRule isA DatalogRule
end


{ Class for generated objects }
{ 9-Oct-2008 for ticket 194   }
GeneratedObject end
DeriveExpression isA GeneratedObject end
QueryCall end  {* for query calls that are to be reified *}


{ For qualifying query classes (and other concepts) that should be hidden from certain displays }
{ For example, some builtin query classes should not be listed in the Display Queries dialog.   }

HiddenObject end

{ Functions }
Class Function isA GenericQueryClass end

vQueryClass in QueryClass,HiddenObject isA QueryClass with   {* "visible" query classes *}
  constraint
     visiblecon: $ not (this in HiddenObject) and not (this in Function) $
end


