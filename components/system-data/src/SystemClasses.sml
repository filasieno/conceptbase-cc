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
{Versionsmanagement }
Class Version end

T_0 in Version end

{ Transaktionszeit }
Class TransactionTime end

{ Label }
Class Label end


{ Boolean }
Class Boolean
end

FALSE in Boolean
end

TRUE in Boolean
end


{ View Maintenance }

Class ViewMaintenanceStrategy end
Class BottomUpVM isA ViewMaintenanceStrategy end
Class TopDownVM isA ViewMaintenanceStrategy end
Class NaiveVM isA ViewMaintenanceStrategy end

{ For Cardinality Constraints }
Proposition with
attribute
	cardinality : Proposition
end

Proposition!cardinality with
attribute
	min : Integer;
	max : Integer
end


{AnswerFormat}


Order in Class end

ascending in Order end

descending in Order end

Individual AnswerFormat in Class with
  attribute
     forQuery : QueryClass;
     order : Order;
     orderBy : String;
     head : String;
     tail : String;
     pattern : String;
     split : Boolean
end



Function COUNT isA Integer with
parameter
	class : Proposition
comment
	c: "counts the instances of class"
end

Function COUNT_Attribute isA Integer with
parameter
	objname : Proposition;
	attrcat : Proposition
comment
	c: "counts the attributes in category <attrcat> of object <objname>"
end

Function SUM isA Real with
parameter
	class : Proposition
comment
	c: "computes the sum of the instances of class (must be reals or integers)"
end

Function AVG isA Real with
parameter
	class : Proposition
comment
	c: "computes the average of the instances of class (must be reals or integers)"
end

Function MAX isA Real with
parameter
	class : Proposition
comment
	c: "gives the maximum of the instances of class (must be reals or integers)"
end

Function MIN isA Real with
parameter
	class : Proposition
comment
	c: "gives the minimum of the instances of class (must be reals or integers)"
end


Function SUM_Attribute isA Real with
parameter
	objname : Proposition;
	attrcat : Proposition
comment
	c: "computes the sum of the attributes in category <attrcat> of object <objname> (must be reals or integers)"
end

Function AVG_Attribute isA Real with
parameter
	objname : Proposition;
	attrcat : Proposition
comment
	c: "computes the average of the attributes in category <attrcat> of object <objname> (must be reals or integers)"
end

Function MAX_Attribute isA Real with
parameter
	objname : Proposition;
	attrcat : Proposition
comment
	c: "gives the maximum of the attributes in category <attrcat> of object <objname> (must be reals or integers)"
end

Function MIN_Attribute isA Real with
parameter
	objname : Proposition;
	attrcat : Proposition
comment
	c: "gives the minimum of the attributes in category <attrcat> of object <objname> (must be reals or integers)"
end

Function PLUS isA Real with
parameter
	r1 : Real;
	r2 : Real
comment
	c : "computes r1 + r2"
end

Function IPLUS isA Integer with
parameter
        i1 : Integer;
        i2 : Integer
comment
        c : "computes i1 + i2"
end


Function MINUS isA Real with
parameter
	r1 : Real;
	r2 : Real
comment
	c : "computes r1 - r2"
end

Function IMINUS isA Integer with
parameter
        i1 : Integer;
        i2 : Integer
comment
        c : "computes i1 - i2"
end


Function MULT isA Real with
parameter
	r1 : Real;
	r2 : Real
comment
	c : "computes r1 * r2"
end

Function IMULT isA Integer with
parameter
        i1 : Integer;
        i2 : Integer
comment
        c : "computes i1 * i2"
end


Function DIV isA Real with
parameter
	r1 : Real;
	r2 : Real
comment
	c : "computes r1 / r2"
end

Function IDIV isA Integer with
parameter
        i1 : Integer;
        i2 : Integer
comment
        c : "computes truncate(i1/i2)"
end


Function ConcatenateStrings isA String with
parameter
	s1 : String;
	s2 : String
comment
	c : "Appends string s2 to the end of string s1"
end


Function ConcatenateStrings3 isA String with
  attribute,parameter
     s1 : String;
     s2 : String;
     s3 : String
comment
  c : "Append strings s1 + s2 + s3"
end

Function ConcatenateStrings4 isA String with
  attribute,parameter
     s1 : String;
     s2 : String;
     s3 : String;
     s4 : String
comment
  c : "Append strings s1 + s2 + s3 + s4"
end


Function StringToLabel isA Label with  
attribute,parameter
    s : String
attribute,comment
    c : "returns s as a label (without quotes)"
end 

