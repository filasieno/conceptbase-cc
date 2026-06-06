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

P_5020 in Action with
  processed_by
    who : A_ProjectControl
  follows_after
    pVon : P_4120
  takes
    take_1 : T_MiscCosts;
    take_2 : TX_Probat
  gives
    give_1 : TX_Probat
  input
    data_in_1 : D_MiscAmount;
    data_in_2 : D_ProjectBillingMonth;
    data_in_3 : D_ProjectNumber
  input
    in_11 : T_MiscCosts!miscAmount;
    in_21 : TX_Probat!projectBillingMonth;
    in_22 : TX_Probat!projectNumber
  output
    out_1 : TX_Probat!miscAmount
end P_5020

P_5030 in Action with
  processed_by
    who : A_ProjectControl
  follows_after
    pVon_1 : P_5020
  takes
    take_1 : TF_MonthlyReport;
    take_2 : TF_MonthSupplement;
    take_3 : TF_ProjectBilling;
    take_4 : T_ExpenseReceipt;
    take_5 : TX_Probat
  gives
    give_1 : TX_Probat
  input
    data_in_1 : D_ProjectBillingMonth;
    data_in_2 : D_EmployeeName;
    data_in_3 : D_ProjectNumber;
    data_in_4 : D_ProjectBillingTotalHoursSum;
    data_in_5 : D_ProjectBillingExpensesSum;
    data_in_6 : D_MonthIntHoursSum;
    data_in_7 : D_MonthIntExpensesSum;
    data_in_8 : D_MonthIntInvoiceSig;
    data_in_9 : D_ProjectBillingInvoiceSig;
    data_in_10 : D_MonthSuppInvoiceSig
  input
    in_11 : TF_MonthlyReport!maName;
    in_12 : TF_MonthlyReport!projectBillingMonth;
    in_13 : TF_MonthlyReport!monthIntExpensesSum;
    in_14 : TF_MonthlyReport!monthIntHoursSum;
    in_15 : TF_MonthlyReport!monthIntInvoiceSig;
    in_21 : TF_MonthSupplement!maName;
    in_22 : TF_MonthSupplement!projectBillingMonth;
    in_23 : TF_MonthSupplement!monthIntExpensesSum;
    in_24 : TF_MonthSupplement!monthIntHoursSum;
    in_25 : TF_MonthSupplement!projectBillingTotalHoursSum;
    in_26 : TF_MonthSupplement!projectBillingExpensesSum;
    in_27 : TF_MonthSupplement!monthSuppInvoiceSig;
    in_31 : TF_ProjectBilling!maName;
    in_32 : TF_ProjectBilling!projectBillingMonth;
    in_33 : TF_ProjectBilling!projectBillingTotalHoursSum;
    in_34 : TF_ProjectBilling!projectBillingExpensesSum;
    in_35 : TF_ProjectBilling!projectBillingInvoiceSig;
    in_41 : T_ExpenseReceipt!expenseAmount;
    in_51 : TX_Probat!maName;
    in_52 : TX_Probat!projectBillingMonth;
    in_53 : TX_Probat!projectNumber
  output
    out_1 : TX_Probat!maName;
    out_2 : TX_Probat!projectBillingTotalHoursSum;
    out_3 : TX_Probat!projectBillingExpensesSum;
    out_4 : TX_Probat!monthIntHoursSum;
    out_5 : TX_Probat!monthIntExpensesSum
end P_5030

P_5040 in Action with
  processed_by
    who : A_ProjectControl
  follows_after
    pVon : P_5030
  takes
    take_1 : TX_Fibu;
    take_2 : TX_Probat
  gives
    give_1 : TX_Probat 
  input
    data_in_1 : D_EmployeeName;
    data_in_2 : D_ProjectBillingMonth;
    data_in_3 : D_MonthSuppExpenses;
    data_in_4 : D_ProjectBillingExpensesSum;
    data_in_5 : D_MonthIntExpensesSum
  input
    in_11 : TX_Fibu!projectBillingMonth;
    in_12 : TX_Fibu!maName;
    in_13 : TX_Fibu!monthSuppExpenses; 
    in_21 : TX_Probat!projectBillingMonth;
    in_22 : TX_Probat!maName;
    in_23 : TX_Probat!projectBillingExpensesSum;
    in_24 : TX_Probat!monthIntExpensesSum
  output
    out_1 : TX_Probat!projectBillingExpensesSum;
    out_2 : TX_Probat!monthIntExpensesSum
end P_5040

P_5050 in Action with
  processed_by
    who : A_ProjectControl
  follows_after
    pVon : P_5040
  takes
    take_1 : TX_Probat
  gives
    give_1 : T_Evaluations
  input
    data_in_1 : D_EmployeeName;
    data_in_2 : D_ProjectBillingMonth
  input
    in_21 : TX_Probat!projectBillingMonth;
    in_22 : TX_Probat!maName
end P_5050

P_END with
  follows_after
    pVon_5050 : P_5050
end P_END


