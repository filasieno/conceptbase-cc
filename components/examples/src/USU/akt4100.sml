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

P_4110 in Action with
  processed_by
    who : A_Accounting
  follows_after
    pVon : P_3470
  takes
    take_1 : TF_ProjectBilling;
    take_2 : TF_MonthlyReport;
    take_3 : TF_MonthSupplement;
    take_4 : T_ExpenseReceipt
  gives
    give_1 : TF_ProjectBilling;
    give_2 : TF_MonthlyReport;
    give_3 : T_ExpenseReceipt
  input
    data_in_1 : D_ProjectBillingMaterialSig;
    data_in_2 : D_MonthIntMaterialSig;
    data_in_3 : D_MonthSuppMaterialSig;
    data_in_4 : D_ExpenseReceiptMaterialSig;
    data_in_5 : D_ProjectBillingMonth;
    data_in_6 : D_EmployeeName
  output
    data_out_1 : D_ProjectBillingInvoiceSig;
    data_out_2 : D_MonthIntInvoiceSig;
    data_out_3 : D_MonthSuppInvoiceSig;
    data_out_4 : D_ExpenseReceiptInvoiceSig
  input
    in_1 : TF_ProjectBilling!projectBillingMaterialSig;
    in_2 : TF_MonthlyReport!monthIntMaterialSig;
    in_3 : TF_MonthSupplement!monthSuppMaterialSig;
    in_4 : T_ExpenseReceipt!expenseReceiptMaterialSig;
    in_5 : TF_ProjectBilling!projectBillingMonth;
    in_6 : TF_ProjectBilling!maName;
    in_7 : TF_MonthSupplement!projectBillingMonth;
    in_8 : TF_MonthSupplement!maName;
    in_9 : TF_MonthlyReport!projectBillingMonth;
    in_10 : TF_MonthlyReport!maName
  output
    out_1 : TF_ProjectBilling!projectBillingInvoiceSig;
    out_2 : TF_MonthlyReport!monthIntInvoiceSig;
    out_3 : TF_MonthSupplement!monthSuppInvoiceSig;
    out_4 : T_ExpenseReceipt!expenseReceiptInvoiceSig
end P_4110

P_4120 in Action with
  processed_by
    who : A_Accounting
  follows_after
    pVon : P_4110
  takes
    take_1 : TF_ProjectBilling;
    take_2 : TF_MonthlyReport;
    take_3 : TF_MonthSupplement;
    take_4 : T_ExpenseReceipt
  gives
    give_1 : TX_Fibu
  input
    data_in_1 : D_ProjectBillingInvoiceSig;
    data_in_2 : D_MonthIntInvoiceSig;
    data_in_3 : D_ExpenseReceiptInvoiceSig;
    data_in_4 : D_MonthSuppInvoiceSig;
    data_in_5 : D_MonthSuppExpenses;
    data_in_6 : D_ProjectBillingMonth;
    data_in_7 : D_EmployeeName
  input
    in_1 : TF_ProjectBilling!projectBillingInvoiceSig;
    in_2 : TF_MonthlyReport!monthIntInvoiceSig;
    in_3 : T_ExpenseReceipt!expenseReceiptInvoiceSig;
    in_4 : TF_MonthSupplement!monthSuppInvoiceSig;
    in_5 : TF_MonthSupplement!monthSuppExpenses;
    in_6 : TF_MonthSupplement!projectBillingMonth;
    in_7 : TF_MonthSupplement!maName
  output
    out_1 : TX_Fibu!monthSuppExpenses;
    out_2 : TX_Fibu!projectBillingMonth;
    out_3 : TX_Fibu!maName
end P_4120

P_4130 in Action with
  processed_by
    who : A_Accounting
  follows_after
    pVon : P_4120
  takes
    take_1 : TX_Fibu
  input
    data_in_1 : D_MonthSuppExpenses;
    data_in_2 : D_ProjectBillingMonth;
    data_in_3 : D_EmployeeName
  input
    in_1 : TX_Fibu!monthSuppExpenses;
    in_2 : TX_Fibu!projectBillingMonth;
    in_3 : TX_Fibu!maName
end P_4130

P_END with
  follows_after
    pVon_4130 : P_4130
end P_END


