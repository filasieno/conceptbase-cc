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

P_3110 in Action with
  processed_by
    who : A_ProjectControl
  follows_after
    pVon : P_3040
  takes
    take_1 : TF_StatusReport;
    take_2 : TF_ProjectBilling;
    take_3 : T_Absence;
    take_4 : T_ExpenseReceipt
  input
    data_in_1 : D_ProjectStatusSignature;
    data_in_2 : D_ProjectBillingSigEmployee;
    data_in_3 : D_ProjectBillingSigPL;
    data_in_4 : D_ProjectStatusInvoice;
    data_in_5 : D_ProjectStatusOperative;
    data_in_6 : D_ProjectBillingMonth;
    data_in_7 : D_ProjectNumber;
    data_in_8 : D_EmployeeName
  input 
    in_11 : TF_StatusReport!projectStatusSignature;
    in_12 : TF_StatusReport!projectStatusInvoice;
    in_13 : TF_StatusReport!projectNumber;
    in_14 : TF_StatusReport!projectBillingMonth;
    in_15 : TF_StatusReport!projectStatusOperative;
    in_21 : TF_ProjectBilling!projectBillingSigEmployee;
    in_22 : TF_ProjectBilling!projectBillingSigPL;
    in_23 : TF_ProjectBilling!projectBillingMonth;
    in_24 : TF_ProjectBilling!projectNumber;
    in_25 : TF_ProjectBilling!maName
end P_3110

P_3120 in Action with
  processed_by
    who : A_ProjectControl
  follows_after
    pVon : P_3110
  takes
    take_1 : TF_StatusReport;
    take_2 : TF_ProjectBilling
  gives
    give_1 : TF_StatusReport
  input
    data_in_1 : D_ProjectBillingMonth;
    data_in_2 : D_ProjectNumber;
    data_in_3 : D_ProjectBillingHoursSum;
    data_in_4 : D_ProjectBillingTotalHoursSum
  output
    data_out_1 : D_ProjectStatusCompleteSum
  input
    in_11 : TF_StatusReport!projectNumber;
    in_12 : TF_StatusReport!projectStatusInvoice;
    in_13 : TF_StatusReport!projectBillingMonth;   
    in_21 : TF_ProjectBilling!projectNumber;
    in_22 : TF_ProjectBilling!projectBillingHoursSum;
    in_23 : TF_ProjectBilling!projectBillingMonth;
    in_24 : TF_ProjectBilling!projectBillingTotalHoursSum
  output
    out_1 : TF_StatusReport!projectStatusCompleteSum
end P_3120

P_3130 in Action with
  processed_by
    who : A_Secretariat
  follows_after
    pVon : P_START
  gives
    give_1 : T_MiscCosts
  output
    data_out_1 : D_MiscAmount 
  output
    out_1 : T_MiscCosts!miscAmount
end P_3130

P_3140 in Action with
  processed_by
    who : A_ProjectControl
  follows_after
    pVon_3120 : P_3120;
    pVon_3130 : P_3130
  takes
    take_1 : TF_ProjectBilling;
    take_2 : T_ExpenseReceipt;
    take_3 : T_MiscCosts
  gives
    give_1 : TX_ExpenseInvoice
  input
    data_in_1 : D_ExpenseAmount;
    data_in_2 : D_MiscAmount;
    data_in_3 : D_EmployeeName;
    data_in_4 : D_ProjectBillingMonth;
    data_in_5 : D_ProjectNumber
  output
    data_out_1 : D_ExpenseAmountNet
  input
    in_1 : TF_ProjectBilling!projectBillingMonth;
    in_2 : TF_ProjectBilling!maName;
    in_3 : TF_ProjectBilling!projectNumber;
    in_4 : T_ExpenseReceipt!expenseAmount;
    in_5 : T_MiscCosts!miscAmount
  output
    out_1 : TX_ExpenseInvoice!expenseAmount;
    out_2 : TX_ExpenseInvoice!expenseAmountNet
end P_3140

P_3150 in Action with
  processed_by
    who : A_ProjectControl
  follows_after
    pVon : P_3140
  takes
    take_1 : TF_ProjectBilling
  gives
    give_1 : TF_ProjectBilling
  input
    data_in_1 : D_ProjectBillingMonth;
    data_in_2 : D_ProjectBillingTotalHoursSum;
    data_in_3 : D_ProjectBillingHoursSum;
    data_in_4 : D_EmployeeName
  input
    in_1 : TF_ProjectBilling!projectBillingMonth;
    in_2 : TF_ProjectBilling!projectBillingTotalHoursSum;
    in_3 : TF_ProjectBilling!projectBillingHoursSum;
    in_4 : TF_ProjectBilling!maName
  output
    data_out_1 : D_ProjectBillingBonusExtra
  output
    out_1 : TF_ProjectBilling!projectBillingBonusExtra
end P_3150



