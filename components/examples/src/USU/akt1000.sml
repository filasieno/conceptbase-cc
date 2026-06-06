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

P_1010 in Action with
  processed_by
    who : A_Personnel
  follows_after
    pVon : P_START
  takes
    take_1 : TX_LUG;
    take_2 : TX_Perbit
  gives
    give_1 : T_CostRates
  input
    data_in_1 : D_EmployeeName
  input
    in_1 : TX_LUG!maName;
    in_2 : TX_Perbit!maName
  output
    data_out_1 : D_CostRate;
    data_out_2 : D_EmployeeName
  output 
    out_1 : T_CostRates!costRate;
    out_2 : T_CostRates!maName
end P_1010

P_1020 in Action with
  processed_by
    who : A_Management
  follows_after
    pVon : P_1010
  takes
    take_1 : T_CostRates
  gives
    give_1 : T_CostRates
  input
    data_in_1 : D_EmployeeName;
    data_in_2 : D_CostRate
  input
    in_1 : T_CostRates!maName;
    in_2 : T_CostRates!costRate
  output
    data_out_1 : D_CostRate
  output 
    out_1 : T_CostRates!costRate
end P_1020

P_1030 in Action with
  processed_by
    who : A_Personnel
  follows_after
    pVon : P_1020
  takes
    take_1 : T_CostRates
  gives
    give_1 : T_CostRates;
    give_2 : TX_Perbit;
    give_3 : T_TargetProjectList
  input
    data_in_1 : D_EmployeeName;
    data_in_2 : D_CostRate
  input
    in_1 : T_CostRates!maName;
    in_2 : T_CostRates!costRate
  output
    out_1 : TX_Perbit!maName;
    out_2 : TX_Perbit!costRate;
    out_3 : T_TargetProjectList!maName;
    out_4 : T_TargetProjectList!costRate
end P_1030

