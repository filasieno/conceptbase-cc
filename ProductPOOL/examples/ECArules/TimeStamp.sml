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

{ Example on using Timestamps with ECArules }
{ See User Manual for details. }

{ The createdOn attribute contains the time when the }
{ employee was inserted in the object base. }
{ The lastModified attribute contains the time, }
{ when the salary was changed. }

Class Employee with
attribute
	salary : Integer;
	createdOn : TransactionTime;
	lastModified : String
rule
	createdOnRule : $ forall t/TransactionTime
	     Known(this,t) ==> (this createdOn t) $
end



{ ECArule for updating the last modified attribute }
ECArule LastModified_Employee_salary with
ecarule
        er : $ t1,t2/TransactionTime y/Employee i/Integer es/Employee!salary lab/Proposition
        ON Tell(A(y,salary,i))
        IF A(y,lastModified,t1)
        DO Untell(A(y,lastModified,t1)),
           Ask(new(In(es,Employee!salary))),
           Ask(new(P(es,y,lab,i))),
           Ask(new(Known(es,t2))),
           Tell(A(y,lastModified,t2))
        ELSE
           Ask(new(In(es,Employee!salary))),
           Ask(new(P(es,y,lab,i))),
		   Ask(new(Known(es,t2))),
           Tell(A(y,lastModified,t2))
        $
end
