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

P_2010 in Action with
  processed_by
    who : A_Customer
  follows_after
    pVon : P_1030
  gives
    give_1 : T_Inquiry
  output
    data_out_1 : D_CustomerName
  output 
    out_1 : T_Inquiry!customerName
end P_2010

P_2020 in Action with
  processed_by
    who : A_CustomerRepresentative
  follows_after
    pVon : P_2010
  takes
    take_1 : T_Inquiry
  gives
    give_1 : T_Offer;
    give_2 : TF_CalculationSheet
  input
    data_in_1 : D_CustomerName
  output
    data_out_1 : D_OfferService;
    data_out_2 : D_OfferNumber;
    data_out_3 : D_CalcHours
  input
    in_1 : T_Inquiry!customerName
  output
    out_1 : T_Offer!offerService;
    out_2 : T_Offer!offerNumber;
    out_0 : T_Offer!customerName;
    out_4 : TF_CalculationSheet!offerService;
    out_5 : TF_CalculationSheet!offerNumber;
    out_6 : TF_CalculationSheet!customerName;
    out_7 : TF_CalculationSheet!calcHours
end P_2020

P_2030 in Action with
  processed_by
    who : A_Management
  follows_after
    pVon : P_2020
  takes
    take_1 : T_Inquiry;
    take_2 : T_Offer;
    take_3 : TF_CalculationSheet
  gives
    give_1 : T_Offer;
    give_2 : TF_CalculationSheet
  input
    data_in_1 : D_CustomerName;
    data_in_2 : D_OfferNumber;
    data_in_3 : D_OfferService;
    data_in_4 : D_CalcHours
  output
    data_out_1 : D_OfferOk
  input 
    in_11 : T_Inquiry!customerName;
    in_21 : T_Offer!customerName;
    in_22 : T_Offer!offerNumber;
    in_23 : T_Offer!offerService;
    in_31 : TF_CalculationSheet!customerName;
    in_32 : TF_CalculationSheet!offerNumber;
    in_33 : TF_CalculationSheet!offerService;
    in_34 : TF_CalculationSheet!calcHours
  output
    out_1 : TF_CalculationSheet!offerOk
end P_2030

P_2035 in Action with
  processed_by
    who : A_CustomerRepresentative
  follows_after
    pVon : P_2030
  takes
    take_1 : T_Inquiry;
    take_2 : T_Offer;
    take_3 : TF_CalculationSheet
  gives
    give_1 : T_Offer
  input
    data_in_1 : D_CustomerName;
    data_in_2 : D_OfferNumber;
    data_in_3 : D_OfferService;
    data_in_4 : D_OfferOk
  output
    data_out_1 : D_OfferSigManagement
  input 
    in_11 : T_Inquiry!customerName;
    in_21 : T_Offer!customerName;
    in_22 : T_Offer!offerNumber;
    in_23 : T_Offer!offerService;
    in_31 : TF_CalculationSheet!customerName;
    in_32 : TF_CalculationSheet!offerNumber;
    in_33 : TF_CalculationSheet!offerOk
  output
    out_1 : T_Offer!offerSigManagement
end P_2035

P_2040 in Action with
  processed_by
    who : A_Customer
  follows_after
    pVon : P_2030
  takes
    take_1 : T_Offer
  gives
    give_1 : T_Order
  input
    data_in_1 : D_CustomerName;
    data_in_2 : D_OfferSigManagement;
    data_in_3 : D_OfferNumber
  output
    data_out_1 : D_OrderSignature
  input
    in_1 : T_Offer!customerName;
    in_2 : T_Offer!offerSigManagement;
    in_3 : T_Offer!offerNumber;
    in_4 : T_Offer!offerService
  output
    out_1 : T_Order!offerNumber;
    out_2 : T_Order!orderSignature;
    out_3 : T_Order!customerName
end P_2040

P_2050 in Action with
  processed_by
    who : A_CustomerRepresentative
  follows_after
    pVon : P_2040
  takes
    take_1 : T_Order
  gives
    give_1 : TF_ProjectOrder
  input
    data_in_1 : D_OfferNumber;
    data_in_2 : D_OrderSignature;
    data_in_3 : D_CustomerName
  output
    data_out_1 : D_PLName
  input
    in_1 : T_Order!offerNumber;
    in_2 : T_Order!orderSignature;
    in_3 : T_Order!customerName
  output
    out_1 : TF_ProjectOrder!customerName;
    out_2 : TF_ProjectOrder!plName
end P_2050

P_2060 in Action with
  processed_by
    who : A_ProjectLeader
  follows_after
    pVon : P_2050
  takes
    take_1 : TF_ProjectOrder;
    take_2 : TF_CalculationSheet
  gives
    give_1 : TF_ProjectCreation;
    give_2 : TF_ProjectOrder;
    give_3 : TF_ProjectOrderEmployee;
    give_4 : TF_CalculationSheet
  input
    data_in_1 : D_CustomerName;
    data_in_2 : D_OfferService;
    data_in_3 : D_CalcHours;
    data_in_4 : D_PLName
  output
    data_out_1 : D_ProjectTargetHours
  input
    in_1 : TF_ProjectOrder!customerName; 
    in_2 : TF_CalculationSheet!offerService;
    in_3 : TF_CalculationSheet!calcHours;
    in_4 : TF_ProjectOrder!plName
  output
    out_1 : TF_ProjectOrderEmployee!customerName;
    out_2 : TF_ProjectOrderEmployee!maName;
    out_3 : TF_ProjectOrderEmployee!plName;
    out_4 : TF_ProjectOrderEmployee!projectTargetHours;
    out_5 : TF_ProjectOrder!projectTargetHours;
    out_6 : TF_ProjectCreation!customerName; 
    out_7 : TF_ProjectCreation!offerService;
    out_8 : TF_ProjectCreation!projectTargetHours
end P_2060

P_2070 in Action with
  processed_by
    who : A_ProjectControl
  follows_after
    pVon : P_2060
  takes
    take_1 : TF_ProjectCreation;
    take_2 : TF_ProjectOrder;
    take_3 : TF_ProjectOrderEmployee;
    take_4 : TF_CalculationSheet
  gives
    give_1 : TF_ProjectCreation;
    give_2 : TF_ProjectOrder;
    give_3 : TF_ProjectOrderEmployee;
    give_4 : TF_CalculationSheet
  input
    data_in_1 : D_EmployeeName;
    data_in_2 : D_CustomerName;
    data_in_3 : D_PLName;
    data_in_4 : D_CalcHours;
    data_in_5 : D_ProjectTargetHours
  output
    data_out_1 : D_ProjectNumber
  input
    in_1 : TF_ProjectCreation!customerName;
    in_2 : TF_ProjectCreation!projectTargetHours;
    in_3 : TF_ProjectOrder!plName;
    in_4 : TF_ProjectOrderEmployee!maName;
    in_5 : TF_CalculationSheet!calcHours;
    in_6 : TF_CalculationSheet!customerName
  output
    out_1 : TX_Probat!customerName;
    out_2 : TX_Probat!projectNumber;
    out_3 : TX_Probat!plName;
    out_4 : TX_Probat!maName;
    out_5 : TX_Probat!projectTargetHours;
    out_11 : TF_ProjectCreation!projectNumber;
    out_21 : TF_ProjectOrder!projectNumber;
    out_31 : TF_ProjectOrderEmployee!projectNumber
end P_2070

P_2080 in Action with
  processed_by
    who : A_ProjectLeader
  follows_after
    pVon : P_2070
  takes
    take_1 : TF_ProjectOrder;
    take_2 : TF_ProjectOrderEmployee
  gives
    give_1 : TF_ProjectOrderEmployee
  input
    data_in_1 : D_EmployeeName;
    data_in_2 : D_ProjectNumber
  output
    data_out_1 : D_ProjectOrderPLSig
  input
    in_1 : TF_ProjectOrderEmployee!maName;
    in_2 : TF_ProjectOrder!projectNumber
  output 
    aus : TF_ProjectOrderEmployee!projectOrderPLSig
end P_2080


