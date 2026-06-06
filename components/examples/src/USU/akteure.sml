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

A_CustomerRepresentative in Actor with
  creates 
    vb_creates_1 : T_Offer;
    vb_creates_2 : TF_ProjectOrder;
    vb_creates_3 : TF_CalculationSheet
  needs
    vb_needs_1 : T_Inquiry;
    vb_needs_2 : T_Order
  supplies
    vb_offers : A_Customer;
    vb_commissions : A_ProjectLeader;
    vb_verifies : A_Management
end A_CustomerRepresentative

A_CustomerRepresentative!vb_offers with
  via
    vb_offers : T_Offer
end A_CustomerRepresentative!vb_offers

A_CustomerRepresentative!vb_commissions with
  via
    vb_commissions : TF_ProjectOrder;
    vb_calculates : TF_CalculationSheet
end A_CustomerRepresentative!vb_commissions

A_CustomerRepresentative!vb_verifies with
  via
    vb_verifies_1 : T_Offer;
    vb_verifies_2 : TF_CalculationSheet
end A_CustomerRepresentative!vb_verifies

A_Customer in Actor with
  creates 
    kd_creates_1 : T_Inquiry;
    kd_creates_2 : T_Order;
    kd_creates_3 : T_Payment
  needs
    kd_needs_1 : T_Offer;
    kd_needs_2 : T_Invoice;
    kd_needs_3 : T_ExpenseReceipt;
    kd_needs_4 : T_MiscCosts;
    kd_needs_5 : TF_ProjectBilling;
    kd_needs_6 : T_Reminder
  supplies
    kd_inquires : A_CustomerRepresentative;
    kd_commissions : A_CustomerRepresentative;
    kd_pays : A_Accounting
end A_Customer

A_Customer!kd_inquires with
  via
    kd_asks : T_Inquiry
end A_Customer!kd_inquires
    
A_Customer!kd_commissions with
  via
    kd_commissions : T_Order
end A_Customer!kd_commissions
 
A_Customer!kd_pays with
  via
    kd_pays : T_Payment
end A_Customer!kd_pays

A_CustomerPL in Actor with
  creates 
    kd_creates_1 : TF_ProjectBilling
  needs
    kd_needs_1 : TF_ProjectBilling
  supplies
    kd_confirms : A_ProjectLeader
end A_CustomerPL

A_CustomerPL!kd_confirms with
  via
    kd_confirms : TF_ProjectBilling
end A_CustomerPL!kd_confirms
 
A_ProjectControl in Actor with
  creates 
    pc_creates_1 : T_Invoice;
    pc_creates_2 : T_Evaluations;
    pc_creates_3 : T_Reminder;
    pc_creates_4 : TF_MonthlyReport;
    pc_creates_5 : T_ExpenseReceipt;
    pc_creates_6 : T_MiscCosts;
    pc_creates_7 : TF_MonthSupplement;
    pc_creates_8 : T_Absence;
    pc_creates_9 : T_BookingList;
    pc_creates_10 : TF_ProjectBilling;
    pc_creates_11 : TF_ProjectOrder;
    pc_creates_12 : TF_ProjectOrderEmployee;
    pc_creates_13 : TF_ProjectCreation
  needs
    pc_needs_1 : TF_StatusReport;
    pc_needs_2 : TF_ProjectBilling;
    pc_needs_3 : TF_MonthlyReport;
    pc_needs_4 : T_ExpenseReceipt;
    pc_needs_5 : T_CostRates;
    pc_needs_6 : T_MiscCosts;
    pc_needs_7 : TF_ProjectCreation;
    pc_needs_8 : T_Absence;
    pc_needs_9 : TF_MonthSupplement;
    pc_needs_10 : TF_CalculationSheet;
    pc_needs_11 : T_OpenItemsList;
    pc_needs_12 : TF_ProjectOrder;
    pc_needs_13 : TF_ProjectOrderEmployee
  supplies
    pc_invoices : A_Customer;
    pc_copies_invoice : A_Accounting;
    pc_informs : A_Management;
    pc_reminds : A_Customer;
    pc_forwards : A_Personnel;
    pc_project_start : A_ProjectLeader;
    pc_archives : A_Accounting
end A_ProjectControl

A_ProjectControl!pc_invoices with
  via
    pc_invoice_1 : T_Invoice;
    pc_invoice_2 : TF_ProjectBilling;
    pc_invoice_3 : T_ExpenseReceipt
end A_ProjectControl!pc_invoices
 
A_ProjectControl!pc_copies_invoice with
  via
    pc_copied : T_BookingList
end A_ProjectControl!pc_copies_invoice
 
A_ProjectControl!pc_informs with
  via
    pc_informs : T_Evaluations
end A_ProjectControl!pc_informs
 
A_ProjectControl!pc_reminds with
  via
    pc_reminds : T_Reminder
end A_ProjectControl!pc_reminds

A_ProjectControl!pc_project_start with
  via
    pc_project_start_1 : TF_ProjectCreation;
    pc_project_start_2 : TF_ProjectOrder;
    pc_project_start_3 : TF_ProjectOrderEmployee
end A_ProjectControl!pc_project_start
  
A_ProjectControl!pc_forwards with
  via
    pc_gives_1 : TF_ProjectBilling;
    pc_gives_2 : T_ExpenseReceipt;
    pc_gives_3 : T_MiscCosts;
    pc_gives_4 : T_Absence
end A_ProjectControl!pc_forwards
 
A_ProjectControl!pc_archives with
  via
    pc_archives_1 : TF_MonthlyReport;
    pc_archives_2 : T_ExpenseReceipt;
    pc_archives_3 : TF_MonthSupplement;
    pc_archives_4 : T_MiscCosts;
    pc_archives_5 : TF_ProjectBilling
end A_ProjectControl!pc_archives
 
A_Personnel in Actor with
  creates 
    pe_creates_1 : TF_ProjectBilling;
    pe_creates_2 : TF_MonthlyReport;
    pe_creates_3 : TF_MonthSupplement;
    pe_creates_4 : T_ExpenseReceipt;
    pe_creates_5 : T_CorrectionMeeting;
    pe_creates_6 : T_CostRates;
    pe_creates_7 : T_MiscCosts
  needs
    pe_needs_2 : T_ExpenseReceipt;
    pe_needs_3 : T_MiscCosts;
    pe_needs_4 : TF_MonthlyReport;
    pe_needs_5 : TF_MonthSupplement;
    pe_needs_6 : TF_ProjectBilling;
    pe_needs_7 : T_Absence;
    pe_needs_8 : T_CostRates
  supplies
    pe_forwards : A_Accounting;
    pe_corrects : A_ProjectControl;
    pe_distributes : A_ProjectControl;
    pe_shares_with : A_Accounting;
    pe_notifies : A_Employee
end A_Personnel

A_Personnel!pe_forwards with
  via
    pe_fwd_1 : TF_ProjectBilling;
    pe_fwd_2 : TF_MonthlyReport;
    pe_fwd_3 : TF_MonthSupplement;
    pe_fwd_4 : T_ExpenseReceipt;
    pe_fwd_5 : T_MiscCosts
end A_Personnel!pe_forwards
  
A_Personnel!pe_corrects with
  via
    pe_corrects : T_ExpenseReceipt
end A_Personnel!pe_corrects
 
A_Personnel!pe_distributes with
  via
    pe_distributes : T_CostRates
end A_Personnel!pe_distributes
 
A_Personnel!pe_notifies with
  via
    pe_notifies : T_CorrectionMeeting
end A_Personnel!pe_notifies

A_Accounting in Actor with
  creates 
    bu_creates_2 : T_ExpensePayment;
    bu_creates_3 : T_OpenItemsList;
    bu_creates_4 : T_MiscCosts;
    bu_creates_5 : T_ExpenseReceipt;
    bu_creates_6 : TF_ProjectBilling;
    bu_creates_7 : TF_MonthlyReport;
    bu_creates_8 : TF_MonthSupplement
  needs
    bu_needs_1 : T_ExpenseReceipt;
    bu_needs_2 : T_BookingList;
    bu_needs_3 : T_MiscCosts;
    bu_needs_4 : T_Payment;
    bu_needs_5 : TF_ProjectBilling;
    bu_needs_6 : TF_MonthlyReport;
    bu_needs_7 : TF_MonthSupplement
  supplies
    bu_settlement : A_ProjectControl;
    bu_open_items : A_ProjectControl;
    bu_pays_expenses : A_Employee    
end A_Accounting

A_Accounting!bu_settlement with
  via
    bu_settlement_1 : TF_ProjectBilling;
    bu_settlement_2 : TF_MonthlyReport;
    bu_settlement_3 : TF_MonthSupplement;
    bu_settlement_4 : T_ExpenseReceipt;
    bu_settlement_5 : T_MiscCosts
end A_Accounting!bu_settlement
 
A_Accounting!bu_pays_expenses with
  via
    bu_pays_expenses : T_ExpensePayment
end A_Accounting!bu_pays_expenses
 
A_Accounting!bu_open_items with
  via
    bu_open_items : T_OpenItemsList
end A_Accounting!bu_open_items
 
A_ProjectLeader in Actor with
  creates 
    pl_creates_1 : TF_MonthlyReport;
    pl_creates_2 : TF_MonthSupplement;
    pl_creates_3 : TF_ProjectBilling;
    pl_creates_4 : T_Absence;
    pl_creates_5 : T_ExpenseReceipt;
    pl_creates_6 : TF_ProjectOrder;
    pl_creates_7 : TF_ProjectOrderEmployee;
    pl_creates_8 : TF_ProjectCreation;
    pl_creates_9 : TF_StatusReport;
    pl_creates_10 : TF_CalculationSheet
  needs
    pl_needs_1 : TF_ProjectOrder;
    pl_needs_2 : TF_ProjectOrderEmployee;
    pl_needs_3 : TF_ProjectBilling;
    pl_needs_4 : T_Absence;
    pl_needs_5 : T_ExpenseReceipt;
    pl_needs_6 : TF_ProjectCreation;
    pl_needs_7 : TF_CalculationSheet
  supplies
    pl_project_setup : A_ProjectControl;
    pl_commissions : A_Employee;
    pl_monthly_report : A_Secretariat;
    pl_project_billing : A_ProjectControl;
    pl_proof : A_CustomerPL
end A_ProjectLeader

A_ProjectLeader!pl_project_setup with
  via
    pl_project_setup_1 : TF_ProjectCreation;
    pl_project_setup_2 : TF_CalculationSheet;
    pl_project_setup_3 : TF_ProjectOrder;
    pl_project_setup_4 : TF_ProjectOrderEmployee
end A_ProjectLeader!pl_project_setup
 
A_ProjectLeader!pl_commissions with
  via
    pl_commissions : TF_ProjectOrderEmployee
end A_ProjectLeader!pl_commissions
 
A_ProjectLeader!pl_monthly_report with
  via
    pl_monthly_report_1 : TF_MonthlyReport;
    pl_monthly_report_2 : TF_MonthSupplement;
    pl_monthly_report_3 : T_ExpenseReceipt;
    pl_monthly_report_4 : T_Absence
end A_ProjectLeader!pl_monthly_report
 
A_ProjectLeader!pl_project_billing with
  via
    pl_project_billing_1 : TF_StatusReport;
    pl_project_billing_2 : TF_ProjectBilling;
    pl_project_billing_3 : T_ExpenseReceipt;
    pl_project_billing_4 : T_Absence
end A_ProjectLeader!pl_monthly_report
 
A_ProjectLeader!pl_proof with
  via
    pl_proof : TF_ProjectBilling
end A_ProjectLeader!pl_proof
 
A_PersonnelManager in Actor with
  creates 
    pv_creates_1 : TF_MonthlyReport;
    pv_creates_2 : T_Absence;
    pv_creates_3 : T_ExpenseReceipt;
    pv_creates_4 : TF_MonthSupplement
  needs
    pv_needs_1 : TF_MonthlyReport;
    pv_needs_2 : T_Absence;
    pv_needs_3 : T_ExpenseReceipt;
    pv_needs_4 : TF_MonthSupplement
  supplies
    pv_monthly_report : A_Personnel
end A_PersonnelManager

A_PersonnelManager!pv_monthly_report with
  via
    pv_monthly_report_1 : TF_MonthlyReport;
    pv_monthly_report_2 : T_ExpenseReceipt;
    pv_monthly_report_3 : T_Absence;
    pv_monthly_report_4 : TF_MonthSupplement     
end A_PersonnelManager!pv_monthly_report

A_Secretariat in Actor with
  needs
    se_needs_1 : TF_MonthlyReport;
    se_needs_2 : TF_MonthSupplement;
    se_needs_3 : T_Absence;
    se_needs_4 : T_ExpenseReceipt
  creates
    se_creates_1 : TF_MonthlyReport;
    se_creates_2 : TF_MonthSupplement;
    se_creates_3 : T_Absence;
    se_creates_4 : T_ExpenseReceipt;
    se_creates_5 : T_MiscCosts
  supplies 
    se_forwards : A_PersonnelManager;
    se_forwards_invoice : A_Accounting;
    se_forwards_misc : A_ProjectControl
end A_Secretariat
 
A_Secretariat!se_forwards with
  via
    se_monthly_report_1 : TF_MonthlyReport;
    se_monthly_report_2 : T_ExpenseReceipt;
    se_monthly_report_3 : T_Absence;
    se_monthly_report_4 : TF_MonthSupplement
end A_Secretariat!se_forwards

A_Secretariat!se_forwards_invoice with
  via
    se_forwards_invoice_1 : T_MiscCosts
end A_Secretariat!se_forwards_invoice

A_Secretariat!se_forwards_misc with
  via
    se_forwards_misc_1 : T_MiscCosts
end A_Secretariat!se_forwards_misc

A_Employee in Actor with
  creates 
    ma_creates_1 : TF_MonthlyReport;
    ma_creates_2 : TF_MonthSupplement;
    ma_creates_3 : TF_ProjectBilling;
    ma_creates_4 : T_Absence;
    ma_creates_5 : T_ExpenseReceipt
  needs
    ma_needs_1 : TF_ProjectOrderEmployee;
    ma_needs_2 : T_ExpensePayment;
    ma_needs_3 : T_CorrectionMeeting
  supplies
    ma_monthly_report : A_Secretariat;
    ma_project_billing : A_ProjectLeader
end A_Employee

A_Employee!ma_monthly_report with
  via
    ma_monthly_report_1 : TF_MonthlyReport;
    ma_monthly_report_2 : T_ExpenseReceipt;
    ma_monthly_report_3 : T_Absence;
    ma_monthly_report_4 : TF_MonthSupplement
end A_Employee!ma_monthly_report
 
A_Employee!ma_project_billing with
  via
    ma_project_billing_1 : TF_ProjectBilling;
    ma_project_billing_2 : T_ExpenseReceipt;
    ma_project_billing_3 : T_Absence
end A_Employee!ma_monthly_report
 
A_Management in Actor with
  needs
    gl_needs : T_Evaluations
  creates
    gl_creates : T_CostRates
  supplies
    gl_determines : A_Personnel;
    gl_confirms : A_CustomerRepresentative
end A_Management

A_Management!gl_determines with
  via
    gl_determines : T_CostRates
end A_Management!gl_determines

A_Management!gl_confirms with
  via
    gl_confirms_1 : T_Offer;
    gl_confirms_2 : TF_CalculationSheet
end A_Management!gl_confirms


