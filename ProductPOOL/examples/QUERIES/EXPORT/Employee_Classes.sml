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
{
*     File : Employee_Classes.sml
*     created : 9/18/89 SE
*     last change : 06-Jul-93 Christoph Radig
}
{$set syntax=PlainToronto}

Class HighSalary in SimpleClass isA Integer with
   rule
     highsalaryrule: $forall m/Integer
				 (m >= 60000) 
				 ==> (m in HighSalary)
				$ 
end HighSalary

Class TopSalary in SimpleClass isA HighSalary with
   rule
     topsalaryrule: $forall m/Integer
				 (m >= 100000) 
				 ==> (m in TopSalary)
				$ 
end TopSalary


Class Employee in SimpleClass with
   attribute
      name : String;
      salary : Integer;
      dept : Department;
      boss : Manager
end Employee

Class Manager in SimpleClass isA Employee
end Manager

Class Department in SimpleClass with
   attribute
      head : Manager
end Department

Class ProductionDepartment isA Department
end ProductionDepartment

Class Union in SimpleClass
end Union

Class WorkerUnion isA Union
end WorkerUnion

Class UnionMember in SimpleClass with
	attribute
		union:Union
end UnionMember
      
Class Employee with
   rule
      bossrule : $ forall e/Employee  m/Manager
		(exists d/Department  (e dept d) and (d head m) )
		==> (e boss m)  $
   constraint
      SalaryBound : $ forall e/Employee b/Manager  x/Integer y/Integer
		(e boss b) and  (e salary x) and (b salary y)
		==> (y >= x) $
end Employee
