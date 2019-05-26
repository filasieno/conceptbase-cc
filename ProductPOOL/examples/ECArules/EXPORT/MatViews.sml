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

{ Materialization of Views with ECArules }
{ See User Manual for details }




Class Employee with 
attribute
	salary : Integer
end

View EmployeeWithHighSalary isA Employee with
constraint
	c : $ exists i/Integer (this salary i) and (i > 100000) $
end

Class EmployeeWithHighSalary_Materialized 
end


{* 2011-10-27/MJf: updated to new ECArule syntax *}
ECArule EmployeeWithHighSalary_Materialized_Ins with
ecarule
	er : $ x/Employee
	ON Tell (x in Employee)
	IF `(x in EmployeeWithHighSalary)
	DO Tell (x in EmployeeWithHighSalary_Materialized) $
end

ECArule EmployeeWithHighSalary_Materialized_Del with
ecarule
	er : $ x/Employee
	ON Untell (x in Employee)
	IF (x in EmployeeWithHighSalary)
	DO Untell (x in EmployeeWithHighSalary_Materialized) $
end

ECArule EmployeeWithHighSalary_Materialized_Ins_salary with
ecarule
	er : $ x/Employee y/Integer
	ON Tell (x salary y)
	IF `(x in EmployeeWithHighSalary)
	DO Tell (x in EmployeeWithHighSalary_Materialized) $
end

ECArule EmployeeWithHighSalary_Materialized_Del_salary with
ecarule
	er : $ x/Employee y/Integer
	ON Untell (x salary y)
	IF (x in EmployeeWithHighSalary)
	DO Untell (x in EmployeeWithHighSalary_Materialized) $
end

{* check with data like:
mary in Employee with  
  salary msal : 150000
end 
*}
