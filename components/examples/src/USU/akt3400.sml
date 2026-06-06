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

P_3410 in Action with
  processed_by
    who : A_Secretariat
  follows_after
    pVon : P_3010
  takes
    take_1 : TF_MonthlyReport;
    take_2 : TF_MonthSupplement;
    take_3 : T_Absence;
    take_4 : T_ExpenseReceipt
  gives
    give_1 : TF_MonthlyReport;
    give_2 : TF_MonthSupplement;
    give_3 : T_Absence;
    give_4 : T_ExpenseReceipt
end P_3410

P_3420 in Action with
  processed_by
    who : A_PersonnelManager
  follows_after
    pVon : P_3410
  takes
    take_1 : TF_MonthlyReport;
    take_2 : TF_MonthSupplement;
    take_3 : T_Absence;
    take_4 : T_ExpenseReceipt
  gives
    give_1 : TF_MonthlyReport;
    give_2 : TF_MonthSupplement;
    give_3 : T_Absence;
    give_4 : T_ExpenseReceipt
  input
    data_in_1 : D_MonthIntSigEmployee;
    data_in_2 : D_ProjectBillingMonth;
    data_in_3 : D_EmployeeName
  output
    data_out_1 : D_MonthIntSigPersonnelMgr
  input
    in_1 : TF_MonthlyReport!monthIntSigEmployee;
    in_2 : TF_MonthlyReport!projectBillingMonth;
    in_3 : TF_MonthlyReport!maName
  output
    out_1 : TF_MonthlyReport!monthIntSigPersonnelMgr
end P_3420

P_3430 in Action with
  processed_by
    who : A_Personnel
  follows_after
    pVon_3140 : P_3140;
    pVon_3420 : P_3420
  takes
    take_1 : TF_MonthlyReport;
    take_2 : TF_ProjectBilling;
    take_3 : TF_MonthSupplement
  gives
    give_1 : T_TargetProjectList
  input
    data_in_1 : D_ProjectNumber;
    data_in_2 : D_EmployeeName;
    data_in_3 : D_ProjectBillingMonth
  input
    in_11 : TF_MonthlyReport!maName;
    in_12 : TF_MonthlyReport!projectBillingMonth;
    in_21 : TF_ProjectBilling!maName;
    in_22 : TF_ProjectBilling!projectNumber;
    in_23 : TF_ProjectBilling!projectBillingMonth;
    in_31 : TF_MonthSupplement!maName;
    in_32 : TF_MonthSupplement!projectBillingMonth
  output
    out_1 : T_TargetProjectList!maName;
    out_2 : T_TargetProjectList!projectNumber
end P_3430

P_3440 in Action with
  processed_by
    who : A_Personnel
  follows_after
    pVon : P_3430
  takes
    take_1 : TF_MonthlyReport;
    take_2 : TF_ProjectBilling;
    take_3 : T_ExpenseReceipt
  gives
    give_1 : T_CorrectionMeeting
  input
    data_in_1 : D_ProjectNumber;
    data_in_2 : D_EmployeeName;
    data_in_3 : D_MonthIntExpenses;
    data_in_4 : D_MonthIntService;
    data_in_5 : D_MonthIntHoursSum;
    data_in_6 : D_ProjectBillingExpensesSum;
    data_in_7 : D_ProjectBillingService;
    data_in_8 : D_ExpenseAmount;
    data_in_9 : D_ProjectBillingMonth;
    data_in_10 : D_MonthIntSigEmployee;
    data_in_11 : D_MonthIntSigPersonnelMgr;
    data_in_12 : D_ProjectBillingSigEmployee;
    data_in_13 : D_ProjectBillingOnSiteExpenses;
    data_in_14 : D_ProjectBillingExpenses
  input
    in_1 : TF_MonthlyReport!maName;
    in_2 : TF_MonthlyReport!projectBillingMonth;
    in_3 : TF_MonthlyReport!monthIntExpenses;
    in_4 : TF_MonthlyReport!monthIntHoursSum;
    in_5 : TF_MonthlyReport!monthIntService;
    in_6 : TF_MonthlyReport!projectBillingService;
    in_7 : TF_MonthlyReport!projectBillingExpensesSum;
    in_8 : TF_MonthlyReport!monthIntSigEmployee;
    in_9 : TF_MonthlyReport!monthIntSigPersonnelMgr;
    in_10 : TF_ProjectBilling!maName;
    in_11 : TF_ProjectBilling!projectBillingMonth;
    in_12 : TF_ProjectBilling!projectBillingService;
    in_13 : TF_ProjectBilling!projectBillingHoursSum;
    in_14 : TF_ProjectBilling!projectBillingSigEmployee;
    in_15 : TF_ProjectBilling!projectNumber;
    in_16 : TF_ProjectBilling!projectBillingOnSiteExpenses;
    in_17 : TF_ProjectBilling!projectBillingExpenses;
    in_30 : T_ExpenseReceipt!expenseAmount
  output
    data_out_1 : D_CorrectionInfo
  output
    out_1 : T_CorrectionMeeting!correctionInfo
end P_3440

P_3450 in Action with
  processed_by
    who : A_Personnel
  follows_after
    pVon : P_3430
  takes
    take_1 : TF_MonthSupplement;
    take_2 : T_Absence;
    take_3 : TX_Perbit
  gives
    give_1 : TX_Perbit
  input
    data_in_1 : D_EmployeeName;
    data_in_2 : D_EmployeeVacation;
    data_in_3 : D_ProjectBillingMonth;
    data_in_4 : D_MonthSuppVacation
  output
    data_out_1 : D_PerbitVacation
  input
    in_11 : TF_MonthSupplement!monthSuppVacation;
    in_12 : TF_MonthSupplement!maName;
    in_13 : TF_MonthSupplement!projectBillingMonth;
    in_21 : T_Absence!maName;
    in_22 : T_Absence!employeeVacation;
    in_31 : TX_Perbit!maName
  output
    out_1 : TX_Perbit!perbitVacation
end P_3450

P_3460 in Action with
  processed_by
    who : A_Personnel
  follows_after
    pVon : P_3430
  takes
    take_1 : TF_MonthSupplement;
    take_2 : TX_Perbit
  gives
    give_1 : TX_Perbit
  input
    data_in_1 : D_MonthSuppSchool;
    data_in_2 : D_EmployeeName;
    data_in_3 : D_ProjectBillingMonth
  input
    in_1 : TF_MonthSupplement!monthSuppSchool;
    in_2 : TF_MonthSupplement!maName;
    in_3 : TF_MonthSupplement!projectBillingMonth;
    in_4 : TX_Perbit!maName
  output
    data_out_1 : D_PerbitTraining
  output
    out_1 : TX_Perbit!perbitTraining
end P_3460

P_3470 in Action with
  processed_by
    who : A_Personnel
  follows_after
    pVon_1 : P_3440;
    pVon_2 : P_3450;
    pVon_3 : P_3460
  takes
    take_1 : TF_MonthlyReport;
    take_2 : TF_MonthSupplement;
    take_3 : TF_ProjectBilling;
    take_4 : T_ExpenseReceipt
  gives
    give_1 : TF_MonthlyReport;
    give_2 : TF_MonthSupplement;
    give_3 : TF_ProjectBilling;
    give_4 : T_ExpenseReceipt
  input
    data_in_1 : D_ExpenseAmount;
    data_in_2 : D_ProjectBillingExpenses;
    data_in_3 : D_ProjectBillingExpensesSum;
    data_in_4 : D_MonthIntExpenses;
    data_in_5 : D_MonthIntExpensesSum;
    data_in_6 : D_ProjectBillingMonth;
    data_in_7 : D_ProjectNumber;
    data_in_8 : D_EmployeeName;
    data_in_9 : D_ProjectBillingOnSiteExpenses
  input
    in_11 : TF_MonthlyReport!monthIntExpenses;
    in_12 : TF_MonthlyReport!monthIntExpensesSum;
    in_13 : TF_MonthlyReport!projectBillingMonth;
    in_14 : TF_MonthlyReport!maName;
    in_21 : TF_ProjectBilling!projectNumber;
    in_22 : TF_ProjectBilling!projectBillingExpenses;
    in_23 : TF_ProjectBilling!projectBillingExpensesSum;
    in_24 : TF_ProjectBilling!projectBillingMonth;
    in_25 : TF_ProjectBilling!maName;
    in_26 : TF_ProjectBilling!projectBillingOnSiteExpenses;
    in_31 : TF_MonthSupplement!projectBillingMonth;
    in_32 : TF_MonthSupplement!maName;
    in_33 : TF_MonthSupplement!projectBillingTotalHoursSum;
    in_34 : TF_MonthSupplement!projectBillingExpensesSum;
    in_4 : T_ExpenseReceipt!expenseAmount
  output
    data_out_1 : D_MonthIntMaterialSig;
    data_out_2 : D_ProjectBillingMaterialSig;
    data_out_3 : D_MonthSuppMaterialSig;
    data_out_4 : D_ExpenseReceiptMaterialSig
  output
    out_1 : TF_MonthlyReport!monthIntMaterialSig;
    out_2 : TF_ProjectBilling!projectBillingMaterialSig;
    out_3 : TF_MonthSupplement!monthSuppMaterialSig;
    out_4 : T_ExpenseReceipt!expenseReceiptMaterialSig
end P_3470

P_3480 in Action with
  processed_by
    who : A_Personnel
  follows_after
    pVon : P_3470
  takes
    take_1 : TF_MonthSupplement
  gives
    give_1 : TX_LUG
  input
    data_in_1 : D_EmployeeName;
    data_in_2 : D_MonthIntHoursSum;
    data_in_3 : D_ProjectBillingMonth
  input
    in_1 : TF_MonthSupplement!projectBillingMonth;
    in_2 : TF_MonthSupplement!maName;
    in_3 : TF_MonthSupplement!monthIntHoursSum
  output
    out_1 : TX_LUG!maName;
    out_2 : TX_LUG!monthIntHoursSum
end P_3480

P_3490 in Action with
  processed_by
    who : A_Personnel
  follows_after
    pVon : P_3480
end P_3490

P_3500 in Action with
  processed_by
    who : A_Personnel
  follows_after
    pVon : P_3490
  takes 
    take_1 : TX_LUG
  gives
    give_1 : T_InsuranceProof
  input
    data_in_1 : D_MonthIntHoursSum
  input
    in_1 : TX_LUG!monthIntHoursSum
  output
    out_1 : T_InsuranceProof!monthIntHoursSum
end P_3500

P_END with
  follows_after
    pVon_3500 : P_3500
end P_END

