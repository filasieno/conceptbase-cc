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


TF_StatusReport in Carrier with
  contains
    projectNumber : D_ProjectNumber;
    projectBillingMonth : D_ProjectBillingMonth;
    projectStatusOperative : D_ProjectStatusOperative;
    projectStatusFixedPrice : D_ProjectStatusFixedPrice;
    projectStatusInvoice : D_ProjectStatusInvoice;
    projectStatusComplete : D_ProjectStatusComplete;
    projectStatusCompleteSum : D_ProjectStatusCompleteSum;
    projectStatusSignature : D_ProjectStatusSignature
end TF_StatusReport

TF_ProjectBilling in Carrier with
  contains
    projectNumber: D_ProjectNumber;
    projectBillingMonth : D_ProjectBillingMonth;
    maName : D_EmployeeName;
    customerName : D_CustomerName;
    projectBillingBusinessArea : D_ProjectBillingBusinessArea;
    projectBillingSigEmployee : D_ProjectBillingSigEmployee;
    projectBillingSigPL : D_ProjectBillingSigPL;
    projectBillingExpensesSum : D_ProjectBillingExpensesSum;
    projectBillingExpenses : D_ProjectBillingExpenses;
    projectBillingTotalHoursSum : D_ProjectBillingTotalHoursSum;
    projectBillingOnSiteExpenses : D_ProjectBillingOnSiteExpenses;
    projectBillingHoursSum : D_ProjectBillingHoursSum;
    projectBillingService : D_ProjectBillingService;
    projectBillingBonusExtra : D_ProjectBillingBonusExtra;
    projectBillingSigCustomer : D_ProjectBillingSigCustomer;
    projectBillingMaterialSig : D_ProjectBillingMaterialSig;
    projectBillingInvoiceSig : D_ProjectBillingInvoiceSig
end TF_ProjectBilling

TF_MonthlyReport in Carrier with
  contains
    maName : D_EmployeeName;
    projectBillingMonth : D_ProjectBillingMonth;
    monthIntExpenses : D_MonthIntExpenses;
    monthIntExpensesSum : D_MonthIntExpensesSum;
    monthIntHoursSum : D_MonthIntHoursSum;
    monthIntService : D_MonthIntService;
    projectBillingService : D_ProjectBillingService;
    projectBillingExpensesSum : D_ProjectBillingExpensesSum;
    monthIntSigEmployee : D_MonthIntSigEmployee;
    monthIntSigPersonnelMgr : D_MonthIntSigPersonnelMgr;
    monthIntMaterialSig : D_MonthIntMaterialSig;
    monthIntInvoiceSig : D_MonthIntInvoiceSig
end TF_MonthlyReport

TF_MonthSupplement in Carrier with
  contains
    maName : D_EmployeeName;
    projectBillingMonth : D_ProjectBillingMonth;
    monthIntExpensesSum : D_MonthIntExpensesSum;
    monthIntHoursSum : D_MonthIntHoursSum;
    monthIntService : D_MonthIntService;
    monthSuppVacation : D_MonthSuppVacation;
    monthSuppSchool : D_MonthSuppSchool;
    projectBillingTotalHoursSum : D_ProjectBillingTotalHoursSum;
    projectBillingExpensesSum : D_ProjectBillingExpensesSum;
    monthSuppExpenses : D_MonthSuppExpenses;
    monthSuppMaterialSig : D_MonthSuppMaterialSig;
    monthSuppInvoiceSig : D_MonthSuppInvoiceSig
end TF_MonthSupplement

T_ExpenseReceipt in Carrier with
  contains
    expenseAmount : D_ExpenseAmount;
    expenseReceiptMaterialSig : D_ExpenseReceiptMaterialSig;
    expenseReceiptInvoiceSig : D_ExpenseReceiptInvoiceSig
end T_ExpenseReceipt

T_Invoice in Carrier with
  contains
    invoiceNumber : D_InvoiceNumber;
    projectNumber : D_ProjectNumber;
    projectBillingMonth : D_ProjectBillingMonth;
    customerName : D_CustomerName;
    projectBillingHoursSum : D_ProjectBillingHoursSum;
    projectBillingSum : D_ProjectBillingSum;
    expenseAmountSum : D_ExpenseAmountSum;
    invoiceSignature : D_InvoiceSignature
end T_Invoice

TW_Invoice in Carrier with
  contains
    invoiceNumber : D_InvoiceNumber;
    projectNumber : D_ProjectNumber;
    projectBillingMonth : D_ProjectBillingMonth;
    customerName : D_CustomerName;
    projectBillingHoursSum : D_ProjectBillingHoursSum;
    projectBillingSum : D_ProjectBillingSum;
    expenseAmountSum : D_ExpenseAmountSum
end TW_Invoice

T_Evaluations in Carrier with
end T_Evaluations

T_RevenueList in Carrier with
  contains
    projectBillingMonth : D_ProjectBillingMonth;
    projectNumber : D_ProjectNumber;
    projectBillingHoursSum : D_ProjectBillingHoursSum;
    projectBillingSum : D_ProjectBillingSum;
    expenseAmountSum : D_ExpenseAmountSum;
    customerName : D_CustomerName;
    projectBillingBusinessArea : D_ProjectBillingBusinessArea
end T_RevenueList

T_CostRates in Carrier with
  contains
    maName : D_EmployeeName;
    costRate : D_CostRate
end T_CostRates

T_MiscCosts in Carrier with
  contains
    miscAmount : D_MiscAmount
end T_MiscCosts

T_Absence in Carrier with
  contains
    maName : D_EmployeeName;
    employeeVacation : D_EmployeeVacation
end T_Absence

T_BookingList in Carrier with
  contains
    invoiceNumber : D_InvoiceNumber;
    projectNumber : D_ProjectNumber;
    projectBillingMonth : D_ProjectBillingMonth
end T_BookingList

T_Reminder in Carrier with
  contains
    invoiceNumber : D_InvoiceNumber
end T_Reminder

T_Order in Carrier with
  contains
    customerName : D_CustomerName;
    offerNumber : D_OfferNumber;
    orderSignature : D_OrderSignature
end T_Order

T_Inquiry in Carrier with
  contains
    customerName : D_CustomerName
end T_Inquiry

T_Offer in Carrier with
  contains
    customerName : D_CustomerName;
    offerNumber : D_OfferNumber;
    offerService : D_OfferService;
    offerSigManagement : D_OfferSigManagement
end T_Offer

TF_CalculationSheet in Carrier with
  contains
    customerName: D_CustomerName;
    offerNumber : D_OfferNumber;
    offerService : D_OfferService;
    calcHours : D_CalcHours;
    offerOk : D_OfferOk
end TF_CalculationSheet

TF_ProjectOrder in Carrier with
  contains
    projectNumber : D_ProjectNumber;
    customerName : D_CustomerName;
    plName : D_PLName;
    projectTargetHours : D_ProjectTargetHours
end TF_ProjectOrder

TF_ProjectOrderEmployee in Carrier with
  contains
    projectNumber : D_ProjectNumber;
    customerName : D_CustomerName;
    plName : D_PLName;
    maName : D_EmployeeName;
    projectTargetHours : D_ProjectTargetHours;
    projectOrderPLSig : D_ProjectOrderPLSig
end TF_ProjectOrderEmployee

TF_ProjectCreation in Carrier with
  contains
    projectNumber : D_ProjectNumber;
    customerName : D_CustomerName;
    offerService : D_OfferService;
    projectTargetHours : D_ProjectTargetHours
end TF_ProjectCreation

TF_ProjectClosure in Carrier
end TF_ProjectClosure

T_ProjectFolder in Carrier
end T_ProjectFolder

T_TargetProjectList in Carrier with
  contains
    projectNumber : D_ProjectNumber;
    projectBillingMonth : D_ProjectBillingMonth;
    maName : D_EmployeeName;
    costRate : D_CostRate
end T_TargetProjectList

TX_SemiFinished in Carrier with
  contains
    projectNumber : D_ProjectNumber;
    projectBillingMonth : D_ProjectBillingMonth;
    semiFinishedSum : D_SemiFinishedSum;
    semiFinishedRemainingEffort : D_SemiFinishedRemainingEffort
end T_SemiFinished

TX_ExpenseInvoice in Carrier with
  contains
    expenseAmount : D_ExpenseAmount;
    expenseAmountNet : D_ExpenseAmountNet
end TX_ExpenseInvoice

TX_Probat in Carrier with
  contains
    projectNumber : D_ProjectNumber;
    plName : D_PLName;
    projectTargetHours : D_ProjectTargetHours;
    projectBillingService : D_ProjectBillingService;
    projectBillingHoursSum : D_ProjectBillingHoursSum;
    projectBillingOnSiteExpenses : D_ProjectBillingOnSiteExpenses;
    projectBillingMonth : D_ProjectBillingMonth;
    expenseAmountNet : D_ExpenseAmountNet;
    miscAmount : D_MiscAmount;
    maName : D_EmployeeName;
    customerName: D_CustomerName;
    projectBillingTotalHoursSum : D_ProjectBillingTotalHoursSum;
    projectBillingExpensesSum : D_ProjectBillingExpensesSum;
    monthIntHoursSum : D_MonthIntHoursSum;
    monthIntExpensesSum : D_MonthIntExpensesSum
end TX_Probat

TX_Fibu in Carrier with
  contains
    invoiceNumber : D_InvoiceNumber;
    paid : D_Paid;
    monthSuppExpenses : D_MonthSuppExpenses;
    projectBillingMonth : D_ProjectBillingMonth;
    maName : D_EmployeeName
end TX_Fibu

T_ExpensePayment in Carrier with
  contains
    projectBillingMonth : D_ProjectBillingMonth;
    maName : D_EmployeeName;
    monthSuppExpenses : D_MonthSuppExpenses
end TX_ExpensePayment

T_OpenItemsList in Carrier with
  contains
    invoiceNumber : D_InvoiceNumber
end T_OpenItemsList

TX_Perbit in Carrier with
  contains
    maName : D_EmployeeName;
    costRate : D_CostRate;
    perbitVacation : D_PerbitVacation;
    perbitTraining : D_PerbitTraining
end TX_Perbit

T_Payment in Carrier with
  contains
    invoiceNumber : D_InvoiceNumber
end T_Payment

T_CorrectionMeeting in Carrier with
  contains
    correctionInfo : D_CorrectionInfo
end T_CorrectionMeeting

TX_LUG in Carrier with
  contains
    maName : D_EmployeeName;
    perbitVacation : D_PerbitVacation;
    monthIntHoursSum : D_MonthIntHoursSum
end TX_LUG

T_InsuranceProof in Carrier with
  contains
    monthIntHoursSum : D_MonthIntHoursSum 
end T_InsuranceProof

