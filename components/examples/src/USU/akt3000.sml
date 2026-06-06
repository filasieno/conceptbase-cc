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
{$set syntax=PlainToronto}

P_3010 in Action with
  processed_by
    who : A_Employee
  follows_after
    pVon : P_2080
  takes
    take_1 : TF_ProjectOrderEmployee
  gives 
    give_1 : TF_ProjectBilling;
    give_2 : TF_MonthlyReport;
    give_3 : TF_MonthSupplement;
    give_4 : T_Absence;
    give_5 : T_ExpenseReceipt
  input
    data_in_1 : D_ProjectNumber;
    data_in_2 : D_CustomerName;
    data_in_3 : D_EmployeeName
  output
    data_out_1 : D_ProjectBillingOnSiteExpenses;
    data_out_2 : D_ProjectBillingHoursSum;
    data_out_3 : D_ProjectBillingTotalHoursSum;
    data_out_4 : D_ProjectBillingService;
    data_out_5 : D_ProjectBillingExpensesSum;
    data_out_6 : D_ProjectBillingExpenses;
    data_out_7 : D_ProjectBillingSigEmployee;
    data_out_8 : D_MonthIntHoursSum;
    data_out_9 : D_MonthIntService;
    data_out_9a : D_MonthIntExpenses;
    data_out_10 : D_MonthIntExpensesSum;
    data_out_11 : D_MonthIntSigEmployee;
    data_out_12 : D_MonthSuppVacation;
    data_out_13 : D_MonthSuppSchool;
    data_out_14 : D_MonthSuppExpenses;
    data_out_15 : D_ExpenseAmount;
    data_out_16 : D_EmployeeVacation
  input
    in_1 : TF_ProjectOrderEmployee!projectNumber;
    in_2 : TF_ProjectOrderEmployee!customerName;
    in_3 : TF_ProjectOrderEmployee!maName
  output
    out_1 : TF_ProjectBilling!projectNumber;
    out_2 : TF_ProjectBilling!customerName;
    out_3 : TF_ProjectBilling!projectBillingMonth;
    out_4 : TF_ProjectBilling!maName;
    out_5 : TF_ProjectBilling!projectBillingOnSiteExpenses;
    out_6 : TF_ProjectBilling!projectBillingHoursSum;
    out_7 : TF_ProjectBilling!projectBillingExpensesSum;
    out_8 : TF_ProjectBilling!projectBillingExpenses;
    out_9 : TF_ProjectBilling!projectBillingTotalHoursSum;
    out_9a : TF_ProjectBilling!projectBillingService;
    out_9b : TF_ProjectBilling!projectBillingSigEmployee;
    out_10 : TF_MonthlyReport!projectBillingMonth;
    out_11 : TF_MonthlyReport!maName;
    out_12 : TF_MonthlyReport!monthIntHoursSum;
    out_13 : TF_MonthlyReport!monthIntService;
    out_14 : TF_MonthlyReport!monthIntExpensesSum;
    out_15 : TF_MonthlyReport!monthIntExpenses;
    out_16 : TF_MonthlyReport!monthIntSigEmployee;
    out_17 : TF_MonthlyReport!projectBillingExpensesSum;
    out_18 : TF_MonthlyReport!projectBillingService;
    out_20 : TF_MonthSupplement!projectBillingMonth;
    out_21 : TF_MonthSupplement!maName;
    out_22 : TF_MonthSupplement!monthSuppVacation;
    out_23 : TF_MonthSupplement!monthIntHoursSum;
    out_24 : TF_MonthSupplement!projectBillingTotalHoursSum;
    out_25 : TF_MonthSupplement!monthIntService;
    out_26 : TF_MonthSupplement!projectBillingExpensesSum;
    out_27 : TF_MonthSupplement!monthIntExpensesSum;
    out_28 : TF_MonthSupplement!monthSuppExpenses;
    out_29 : TF_MonthSupplement!monthSuppSchool;
    out_30 : T_ExpenseReceipt!expenseAmount;
    out_40 : T_Absence!maName;
    out_41 : T_Absence!employeeVacation
end P_3010 

P_3020 in Action with
  processed_by
    who : A_ProjectLeader
  follows_after
    pVon : P_3010
  takes 
    take_1 : TF_ProjectBilling;
    take_2 : T_Absence;
    take_3 : T_ExpenseReceipt;
    take_4 : TF_ProjectOrder
  gives
    give_1 : TF_ProjectBilling;
    give_2 : T_Absence;
    give_3 : T_ExpenseReceipt
  input
    data_in_1 : D_ProjectBillingMonth;
    data_in_2 : D_ProjectNumber;
    data_in_3 : D_EmployeeName;
    data_in_4 : D_ProjectBillingSigEmployee;
    data_in_5 : D_ProjectBillingService
  output
    data_out_1 : D_ProjectBillingSigPL
  input
    in_1 : TF_ProjectOrder!projectNumber;
    in_2 : TF_ProjectBilling!maName;
    in_3 : TF_ProjectBilling!projectBillingSigEmployee;
    in_4 : TF_ProjectBilling!projectBillingService;
    in_5 : TF_ProjectBilling!projectBillingMonth;
    in_6 : T_ExpenseReceipt!expenseAmount
  output 
    out_1 : TF_ProjectBilling!projectBillingSigPL
end P_3020

P_3030 in Action with
  processed_by
    who : A_CustomerPL
  follows_after
    pVon : P_3020
  takes 
    take_1 : TF_ProjectBilling
  gives
    give_1 : TF_ProjectBilling
  input
    data_in_1 : D_ProjectBillingMonth;
    data_in_2 : D_ProjectNumber;
    data_in_3 : D_EmployeeName;
    data_in_4 : D_ProjectBillingSigEmployee;
    data_in_5 : D_ProjectBillingService;
    data_in_6 : D_ProjectBillingOnSiteExpenses
  output
    data_out_1 : D_ProjectBillingSigCustomer
  input
    in_1 : TF_ProjectBilling!projectBillingMonth;
    in_2 : TF_ProjectBilling!projectNumber;
    in_3 : TF_ProjectBilling!maName;
    in_4 : TF_ProjectBilling!projectBillingSigEmployee;
    in_5 : TF_ProjectBilling!projectBillingService;
    in_6 : TF_ProjectBilling!projectBillingOnSiteExpenses
  output 
    out_1 : TF_ProjectBilling!projectBillingSigCustomer
end P_3030

P_3040 in Action with
  processed_by
    who : A_ProjectLeader
  follows_after
    pVon_3020 : P_3020;
    pVon_3030 : P_3030
  takes
    take_1 : TF_ProjectOrder;
    take_2 : TF_ProjectBilling
  gives
    give_1 : TF_ProjectBilling;
    give_2 : TF_StatusReport
  input
    data_in_1 : D_ProjectBillingMonth;
    data_in_2 : D_ProjectNumber;
    data_in_3 : D_ProjectBillingService
  output
    data_out_1 : D_ProjectStatusOperative;
    data_out_2 : D_ProjectStatusFixedPrice;
    data_out_3 : D_ProjectStatusInvoice;
    data_out_4 : D_ProjectStatusComplete;
    data_out_5 : D_ProjectStatusSignature
  input
    in_1 : TF_ProjectOrder!projectNumber;
    in_2 : TF_ProjectBilling!projectBillingMonth;
    in_3 : TF_ProjectBilling!projectNumber;
    in_4 : TF_ProjectBilling!projectBillingService
  output
    out_1 : TF_StatusReport!projectNumber;
    out_2 : TF_StatusReport!projectBillingMonth;
    out_3 : TF_StatusReport!projectStatusOperative;
    out_4 : TF_StatusReport!projectStatusFixedPrice;
    out_5 : TF_StatusReport!projectStatusInvoice;
    out_6 : TF_StatusReport!projectStatusComplete;
    out_7 : TF_StatusReport!projectStatusSignature
end P_3040


