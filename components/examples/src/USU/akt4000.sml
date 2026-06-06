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

P_4010 in Action with
  processed_by
    who : A_Accounting
  follows_after
    pVon : P_3250
  takes
    take_1 : T_BookingList
  gives
    give_1 : TX_Fibu
  input
    data_in_1 : D_InvoiceNumber
  input 
    in_1 : T_BookingList!invoiceNumber
  output
    out_1 : TX_Fibu!invoiceNumber
end P_4010

P_4020 in Action with
  processed_by
    who : A_Accounting
  follows_after
    pVon : P_4010
  takes
    take_1 : TX_Fibu
  gives
    give_1 : T_OpenItemsList
  input
    data_in_1 : D_InvoiceNumber
  input
    in_1 : TX_Fibu!invoiceNumber
  output
    out_1 : T_OpenItemsList!invoiceNumber
end P_4020

P_4030 in Action with
  processed_by
    who : A_ProjectControl
  follows_after
    pVon : P_4020
  takes
    take_1 : T_OpenItemsList
  gives
    give_1 : T_Reminder
  input
    data_in_1 : D_InvoiceNumber
  input
    in_1 : T_OpenItemsList!invoiceNumber
  output 
    out_1 : T_Reminder!invoiceNumber
end P_4030

P_4040 in Action with
  processed_by
    who : A_Customer
  follows_after
    pVon_1 : P_4030;
    pVon_2 : P_3280
  takes
    take_1 : T_Invoice;
    take_2 : T_Reminder
  gives
    give_1 : T_Payment
  input
    data_in_1 : D_InvoiceNumber;
    data_in_2 : D_InvoiceSignature
  input
    in_1 : T_Invoice!invoiceNumber;
    in_2 : T_Invoice!invoiceSignature
  output
    out_1 : T_Payment!invoiceNumber
end P_4040

P_4050 in Action with
  processed_by
    who : A_Accounting
  follows_after
    pVon : P_4040
  takes
    take_1 : T_Payment
  gives
    give_1 : TX_Fibu
  input
    data_in_1 : D_InvoiceNumber
  output
    out : D_Paid
  input
    in_1 : T_Payment!invoiceNumber
  output
    out_1 : TX_Fibu!paid
end P_4050

P_END with
  follows_after
    pVon_4050 : P_4050
end P_END

