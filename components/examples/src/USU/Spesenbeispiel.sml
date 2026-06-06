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

Class Data with
  attribute
    aggregatedVon: Data;
    transAggregatedFrom: Data
  rule 
    transRule: $ forall d1,d2/Data
                   ( (d1 aggregatedVon d2) or
                   (exists z/Data 
                     (d1 aggregatedVon z) and (z transAggregatedFrom d2)))
                  ==> (d1 transAggregatedFrom d2) $
end

Class Entity with
  attribute
     abgebildetAus: Data
end




Data D_ExpensePayout with
  aggregatedVon
    teil_1: D_ExpenseRates
end

Data D_ExpenseRates 
end

Data D_Employee with
  attribute
    isInProject: D_Project;
    isProjectLeader: D_Project;
    erhaelt: D_ExpensePayout
end

Data D_Project with
  attribute
    billedWhen: D_ProjectBillingMonth
end

Data D_ExpensePayout with
  attribute
    billedWhen: D_ProjectBillingMonth
end

  

T_ExpensePayment in Carrier with
  contains
    expensePayout: D_ExpensePayout
end


Action changeExpenseRates with
   processed_by
     actor: A_Accounting
   output
     output_1: D_ExpenseRates
end

QueryClass QuerZugegriffen isA Data with
  computed_attribute
     mainData: Data;
     querProzess: Action
  constraint
     c1: $ (~mainData transAggregatedFrom ~this) and
           (~querProzess data_output ~this) and
           not (~querProzess data_output ~mainData) $
  comment
     kommentar1: "An action accesses this data item
      but not the parent mainData,
      which aggregates this directly or indirectly as a part"
end
  

Attribute A_Personnel!pe_shares_with with
  comment
    kommentar1: "Notification of cost rates from the HR department"
end

Data D_ProjectBillingBusinessArea with
  comment
    kommentar1: "Business area on which costs and revenue are booked"
end


