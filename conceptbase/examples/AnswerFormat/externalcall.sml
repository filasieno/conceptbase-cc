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
{*
* File: externalcall.sml
* Author: Manfred Jeusfeld, Tilburg University
* Date: 7-Aug-2001
*}

Class Employee with
  attribute
    name: String;
    dept: Department;
    salary: Integer
end

Class Manager isA Employee end

Class Department with
  attribute
     head: Manager;
     name: String;
     budget: Integer
end


View EmpDept isA Employee with
  inherited_attribute
     salary: Integer
  retrieved_attribute,partof
     dept: Department with
              retrieved_attribute
                  head: Manager;
                  name: String
           end
  constraint
     ce: $ exists s/Integer (~this salary s) and (s < 10000) $
end

AnswerFormat EmpDeptFormatWithExternalCall with
   forQuery q: EmpDept
   head h: "The predicate call returns {anExternalPredicate(a,b)}.
This is a list of employees who earn very little.

employee  |  dept      | head of dept
"
   pattern p:
"{this} | {STRINGDECODING({this.dept.name})} | {this.dept.head}
"
end

Employee E1 with
  name n: "Willi S"
  dept d: D1
  salary s: 5000
end

Employee E2 with
  name n: "Peter S"
  dept d: D1
  salary s: 35000
end

Employee E3 with
  name n: "Carl S"
  dept d: D2
  salary s: 8000
end

Manager M1 end
Manager M2 end

Department D1 with
  head h: M1
  name n: "Sales and Service"
  budget bg: 560
end

Department D2 with
  head h1: M1; h2: M2
  name n: "Production"
  budget bg: 560
end





