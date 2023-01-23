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
{
*     File : Employee_Queries.sml
*     last change : 17-Aug-93 Christoph Radig
}
{$set syntax=PlainToronto}

{ SI_Manager stands for "socially interested manager" }
QueryClass SI_Manager isA Manager,UnionMember with
	retrieved_attribute
		union : Union;
		salary : Integer 
end SI_Manager


QueryClass Well_off_SI_Manager isA Manager,UnionMember with
	retrieved_attribute
		union : Union;
		salary : HighSalary 
end Well_off_SI_Manager

QueryClass Well_off_SI_Manager2 isA Manager,UnionMember with
	retrieved_attribute
		union : Union
	constraint
		well_off_rule : $ exists s/HighSalary 
			          (this salary s) $
end Well_off_SI_Manager2

QueryClass Well_off_SI_Manager3 isA Manager,UnionMember with
	retrieved_attribute
		union : Union
	computed_attribute
		head_of : Department
	constraint
		well_off_head_of_rule : $ exists s/HighSalary
					(this salary s)
					and 
					(~head_of head this) $
end Well_off_SI_Manager3

QueryClass Well_off_Manager isA Manager with
	constraint
		well_off_rule : $ exists s/HighSalary
				(this salary s) $
end Well_off_Manager

QueryClass Well_off_SI_Manager4 isA SI_Manager,Well_off_Manager
with
	computed_attribute
		head_of : Department
	constraint
		head_of_rule : $ (~head_of head this) $ 
end Well_off_SI_Manager4


QueryClass SI_led_Department isA Department with
	retrieved_attribute
		head : SI_Manager
end SI_led_Department

QueryClass SI_led_Department2 isA Department with
	constraint
		SI_rule : $ exists m/SI_Manager 
				(this head m) $
end SI_led_Department2


QueryClass Used_SimpleClass isA SimpleClass with
	constraint
		used_r : $ exists Q/QueryClass
 			   (Q computed_attribute this) $
end Used_SimpleClass

QueryClass BillsMetaBoss { in Magic } isA Manager with
	constraint
		billsmetaboss_rule: $ (Bill boss this) 
					or
					exists m/Manager
					(m in BillsMetaBoss) and
					(m boss this) $
end BillsMetaBoss

QueryClass Emp_and_Dep with
	computed_attribute
		e : Employee;
		d : Department
	constraint
		ED_rule : $ (~e dept ~d) $
end Emp_and_Dep


QueryClass EmployeeSalaries isA Employee!salary
end EmployeeSalaries

GenericQueryClass Well_off_SI_Manager5 isA Manager,UnionMember
    with
	retrieved_attribute, parameter
		salary : HighSalary			
	computed_attribute, parameter
		head_of : Department
	parameter
	                u : Union
	constraint
		well_off_head_of_rule : $ (this union ~u)
					and 
					(~head_of head this) $
end Well_off_SI_Manager5

QueryClass Derived_1_FromWell_off_SI_Manager5 
	isA Well_off_SI_Manager5[salary:TopSalary]
end Derived_1_FromWell_off_SI_Manager5

QueryClass Derived_2_FromWell_off_SI_Manager5
	isA Well_off_SI_Manager5[Research/head_of]
end Derived_2_FromWell_off_SI_Manager5

QueryClass Derived_3_FromWell_off_SI_Manager5
	isA Well_off_SI_Manager5[100000/salary, head_of: ProductionDepartment]
end Derived_3_FromWell_off_SI_Manager5

QueryClass Derived_4_FromWell_off_SI_Manager5 
	isA Well_off_SI_Manager5[IGM/u]
end Derived_4_FromWell_off_SI_Manager5

QueryClass Well_off_SI_led_Department isA Department with
	retrieved_attribute
		head : Well_off_SI_Manager5[100000/salary]
end Well_off_SI_led_Department


GenericQueryClass MetabossQuery in SimpleClass {, Magic} isA Manager with
	parameter
		e:Employee
	constraint
		r: $(~e boss this) or
			exists m/Manager
			(m in MetabossQuery[~e/e]) 
			and      
			(m boss this) $
end MetabossQuery


QueryClass DerivedFromMetabossQuery1 {in Magic} isA MetabossQuery[Bill/e]
end DerivedFromMetabossQuery1

QueryClass DerivedFromMetabossQuery2 {in Magic} isA MetabossQuery[Rita/e]
end DerivedFromMetabossQuery2
