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
*     File : Employee_Instances.sml
*     created : 9/18/89 SE
*     last change : 07-Jul-93 Christoph Radig
}
{$set syntax=PlainToronto}


Individual DAG in Union
end DAG

Individual HBV in Union
end HBV

Individual IGM in WorkerUnion
end IGM

Individual Production in ProductionDepartment with
  head
    Boss_of_Production : Lloyd
end Production

Individual Marketing in Department with
  head
    Boss_of_Marketing : Phil
end Marketing

Individual Administration in Department with
  head
    Boss_of_Administration : Eleonore
end Administration

Individual Research in Department with
  head
    Boss_of_Research : Angus
end Research

Individual John in Manager
end John

Individual Oscar in Manager with
  boss
    OscarsBoss : John
end Oscar

Individual Lloyd in Manager,UnionMember with
  dept
    LloydsDepartment : Production
  salary
    LloydsSalary : 100000
  union
    LloydsUnion : IGM
end Lloyd

Individual Phil in Manager with
  dept
    PhilsDepartment : Marketing
  salary
    PhilsSalary : 120000
end Phil

Individual Eleonore in Manager,UnionMember with
  dept
    EleonoresDepartment : Administration
  salary
    EleonoresSalary : 20000
  boss
    EleonoresBoss : Oscar	
  union
    EleonoresUnion : HBV
end Eleonore

Individual Angus in Manager,UnionMember with
  dept
    AngusDepartment : Research
  salary
    AngusSalary : 110000
  boss
    AngusBoss : Oscar
  union
    AngusUnion : DAG
end Angus

Individual Michael in Employee with
  dept
    MichaelsDepartment : Production
  salary 
    MichaelsSalary : 30000
end Michael

Individual Jack in Employee with
  dept
    JacksDepartment : Production
  salary 
    JacksSalary : 30500
end Jack

Individual Joe in Employee with
  dept
    JoesDepartment : Production
  salary 
    JoesSalary : 35000
end Joe

Individual Max in Employee with
  dept
    MaxDepartment : Production
  salary 
    MaxSalary : 40000
end Max

Individual Rita in Employee with
  dept
    RitasDepartment : Production
  salary 
    RitasSalary : 50000
end Rita

Individual Herbert in Employee with
  dept
    HerbertsDepartment : Marketing
  salary 
    HerbertsSalary : 60000
end Herbert

Individual Susan in Employee with
  dept
    SusansDepartment : Marketing
  salary 
    SusansSalary : 65000
end Susan

Individual Thomas in Employee with
  dept
    ThomasDepartment : Marketing
  salary 
    ThomasSalary : 70000
end Thomas

Individual Christopher in Employee with
  dept
    ChristophersDepartment : Marketing
  salary 
    ChristophersSalary : 90000
end Christopher

Individual Mary in Employee with
  dept
    MarysDepartment : Administration
  salary 
    MarysSalary : 10000
end Mary

Individual Felix in Employee with
  dept
    FelixsDepartment : Administration
  salary 
    FelixsSalary : 12000
end Felix

Individual Robert in Employee with
  dept
    RobertsDepartment : Research
  salary 
    RobertsSalary : 70000
end Robert

Individual Edward in Employee with
  dept
    EdwarsDepartment : Research
  salary 
    EdwardsSalary : 50000
end Edward

Individual Bill in Employee with
  dept
    BillsDepartment : Research
  salary
    BillsSalary : 55000
end Bill
