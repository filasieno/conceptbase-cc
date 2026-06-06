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

P_3210 in Action with
  processed_by
    who : A_ProjectControl
  follows_after
    pVon : P_3150
  takes
    take_1 : TF_StatusReport; 
    take_2 : TF_ProjectBilling
  gives
    give_1 : TX_SemiFinished
  input
    data_in_1 : D_ProjectBillingMonth;
    data_in_2 : D_ProjectNumber;
    data_in_4 : D_ProjectStatusCompleteSum
  input
    in_1 : TF_ProjectBilling!projectBillingHoursSum;
    in_2 : TF_ProjectBilling!projectNumber;
    in_3 : TF_ProjectBilling!projectBillingMonth;
    in_4 : TF_StatusReport!projectStatusCompleteSum;
    in_5 : TF_StatusReport!projectBillingMonth
  output
    data_out_1 : D_SemiFinishedSum;
    data_out_2 : D_SemiFinishedRemainingEffort
  output
   out_1 : TX_SemiFinished!projectNumber;
   out_2 : TX_SemiFinished!projectBillingMonth;
   out_3 : TX_SemiFinished!semiFinishedSum;
   out_4 : TX_SemiFinished!semiFinishedRemainingEffort
end P_3210

P_3220 in Action with
  processed_by
    who : A_ProjectControl
  follows_after
    pVon : P_3210
  takes
    take_1 : TF_ProjectBilling;
    take_2 : TX_ExpenseInvoice;
    take_3 : T_CostRates;
    take_4 : TX_Probat
  gives
    give_1 : TX_Probat
  input
    data_in_1 : D_ProjectNumber;
    data_in_2 : D_ProjectBillingService;
    data_in_3 : D_ProjectBillingHoursSum;
    data_in_5 : D_ProjectBillingOnSiteExpenses;
    data_in_6 : D_ProjectBillingMonth;
    data_in_7 : D_ExpenseAmountNet;
    data_in_8 : D_CostRate;
    data_in_9 : D_EmployeeName
  input
    in_11 : TF_ProjectBilling!projectNumber;
    in_12 : TF_ProjectBilling!projectBillingService;
    in_13 : TF_ProjectBilling!projectBillingMonth;
    in_14 : TF_ProjectBilling!projectBillingOnSiteExpenses;
    in_15 : TF_ProjectBilling!projectBillingHoursSum;
    in_21 : TX_ExpenseInvoice!expenseAmountNet;
    in_31 : T_CostRates!costRate;
    in_32 : T_CostRates!maName;
    in_41 : TX_Probat!projectBillingMonth;
    in_42 : TX_Probat!projectNumber;
    in_44 : TX_Probat!maName
  output
    out_1 : TX_Probat!projectBillingMonth;
    out_2 : TX_Probat!projectBillingService;
    out_3 : TX_Probat!projectBillingHoursSum;
    out_4 : TX_Probat!projectBillingOnSiteExpenses;
    out_5 : TX_Probat!expenseAmountNet    
end P_3220

P_3230 in Action with
  processed_by
    who : A_ProjectControl
  follows_after
    pVon : P_3220
  takes
    take_1 : TX_Probat
  gives
    give_1 : TW_Invoice
  input
    data_in_1 : D_ProjectNumber;
    data_in_2 : D_ProjectBillingMonth;
    data_in_3 : D_ProjectBillingService;
    data_in_4 : D_ExpenseAmountNet
  output
    data_out_1 : D_InvoiceNumber;
    data_out_2 : D_ExpenseAmountSum
  input
    in_1 : TX_Probat!projectNumber;
    in_2 : TX_Probat!projectBillingMonth;
    in_3 : TX_Probat!projectBillingHoursSum;
    in_4 : TX_Probat!expenseAmountNet
  output
    out_1 : TW_Invoice!invoiceNumber;
    out_2 : TW_Invoice!projectNumber;
    out_3 : TW_Invoice!projectBillingMonth;
    out_4 : TW_Invoice!projectBillingHoursSum;
    out_5 : TW_Invoice!expenseAmountSum
end P_3230

P_3240 in Action with
  processed_by
    who : A_ProjectControl
  follows_after
    pVon : P_3230
  takes
    take_1 : TF_ProjectBilling;
    take_2 : TW_Invoice
  input
    data_in_1 : D_CustomerName;
    data_in_2 : D_ProjectNumber;
    data_in_3 : D_ProjectBillingMonth
  input
    in_1 : TW_Invoice!projectNumber;
    in_2 : TW_Invoice!projectBillingMonth;
    in_3 : TF_ProjectBilling!customerName;
    in_4 : TF_ProjectBilling!projectNumber
  output
    out_1 : TW_Invoice!customerName
end P_3240

P_3250 in Action with
  processed_by
    who : A_ProjectControl
  follows_after
    pVon : P_3240
  takes
    take_1 : TW_Invoice
  gives
    give_1 : T_BookingList
  input
    data_in_1 : D_InvoiceNumber
  input
    in_1 : TW_Invoice!invoiceNumber
  output
    pAus_1 : T_BookingList!invoiceNumber
end P_3250

P_3260 in Action with
  processed_by
    who : A_ProjectControl
  follows_after
    pVon : P_3240
  takes
    take_1 : TX_Probat
  gives
    give_1 : T_RevenueList
  input
    data_in_1 : D_ProjectBillingMonth;
    data_in_2 : D_ProjectNumber;
    data_in_3 : D_ProjectBillingHoursSum;
    data_in_4 : D_CustomerName
  input
    in_1 : TX_Probat!projectBillingMonth;
    in_2 : TX_Probat!projectNumber;
    in_3 : TX_Probat!projectBillingHoursSum;
    in_4 : TX_Probat!customerName
  output
    out_1 : T_RevenueList!projectBillingMonth;  
    out_2 : T_RevenueList!projectNumber;
    out_3 : T_RevenueList!projectBillingHoursSum;
    out_4 : T_RevenueList!customerName
end P_3260

P_END with 
  follows_after 
    pVon_3260 : P_3260
end P_END

P_3270 in Action with
  processed_by
    who : A_ProjectControl
  follows_after
    pVon : P_3240
  takes
    take_1 : TW_Invoice
  gives
    give_1 : T_Invoice
  input
    data_in_1 : D_InvoiceNumber;
    data_in_2 : D_ProjectNumber;
    data_in_3 : D_ProjectBillingMonth;
    data_in_4 : D_ProjectBillingHoursSum;
    data_in_5 : D_ExpenseAmountSum;
    data_in_6 : D_CustomerName
  input
    in_1 : TW_Invoice!invoiceNumber;
    in_2 : TW_Invoice!projectNumber;
    in_3 : TW_Invoice!projectBillingMonth;
    in_4 : TW_Invoice!projectBillingHoursSum;
    in_5 : TW_Invoice!expenseAmountSum;
    in_6 : TW_Invoice!customerName
  output
    out_1 : T_Invoice!invoiceNumber;
    out_2 : T_Invoice!projectNumber;
    out_3 : T_Invoice!projectBillingMonth;
    out_4 : T_Invoice!projectBillingHoursSum;
    out_5 : T_Invoice!expenseAmountSum;
    out_6 : T_Invoice!customerName
end P_3270

P_3280 in Action with
  processed_by
    who : A_ProjectControl
  follows_after
    pVon : P_3270
  takes
    take_1 : T_Invoice;
    take_2 : T_ExpenseReceipt;
    take_3 : T_MiscCosts;
    take_4 : TF_ProjectBilling
  gives
    give_1 : T_Invoice;
    give_2 : T_ExpenseReceipt;
    give_3 : T_MiscCosts;
    give_4 : TF_ProjectBilling
  input
    data_in_1 : D_InvoiceNumber
  input
    in_1 : T_Invoice!invoiceNumber 
  output
    data_out_1 : D_InvoiceSignature
  output
    out_1 : T_Invoice!invoiceSignature
end P_3280


