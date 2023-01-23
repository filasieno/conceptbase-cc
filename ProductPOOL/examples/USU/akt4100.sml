{*
The ConceptBase.cc Copyright

Copyright 1987-2023 The ConceptBase Team. All rights reserved.

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

P_4110 in Aktion with
  bearbeitet_von
    wer : A_Buchhalt
  folgt_auf
    pVon : P_3470
  nimmt
    nimm_1 : TF_ProjektAbrechnung;
    nimm_2 : TF_MonatsBericht;
    nimm_3 : TF_MonZus;
    nimm_4 : T_SpesenBeleg
  gibt
    gib_1 : TF_ProjektAbrechnung;
    gib_2 : TF_MonatsBericht;
    gib_3 : T_SpesenBeleg
  input
    in_1 : D_ProjAbrSachlUnt;
    in_2 : D_MonIntSachlUnt;
    in_3 : D_MonZusSachlUnt;
    in_4 : D_SpesBelSachlUnt;
    in_5 : D_ProjAbrMonat;
    in_6 : D_MaName
  output
    out_1 : D_ProjAbrRechnUnt;
    out_2 : D_MonIntRechnUnt;
    out_3 : D_MonZusRechnUnt;
    out_4 : D_SpesBelRechnUnt
  eingabe
    ein_1 : TF_ProjektAbrechnung!projAbrSachlUnt;
    ein_2 : TF_MonatsBericht!monIntSachlUnt;
    ein_3 : TF_MonZus!monZusSachlUnt;
    ein_4 : T_SpesenBeleg!spesBelSachlUnt;
    ein_5 : TF_ProjektAbrechnung!projAbrMonat;
    ein_6 : TF_ProjektAbrechnung!maName;
    ein_7 : TF_MonZus!projAbrMonat;
    ein_8 : TF_MonZus!maName;
    ein_9 : TF_MonatsBericht!projAbrMonat;
    ein_10 : TF_MonatsBericht!maName
  ausgabe
    aus_1 : TF_ProjektAbrechnung!projAbrRechnUnt;
    aus_2 : TF_MonatsBericht!monIntRechnUnt;
    aus_3 : TF_MonZus!monZusRechnUnt;
    aus_4 : T_SpesenBeleg!spesBelRechnUnt
end P_4110

P_4120 in Aktion with
  bearbeitet_von
    wer : A_Buchhalt
  folgt_auf
    pVon : P_4110
  nimmt
    nimm_1 : TF_ProjektAbrechnung;
    nimm_2 : TF_MonatsBericht;
    nimm_3 : TF_MonZus;
    nimm_4 : T_SpesenBeleg
  gibt
    gib_1 : TX_Fibu
  input
    in_1 : D_ProjAbrRechnUnt;
    in_2 : D_MonIntRechnUnt;
    in_3 : D_SpesBelRechnUnt;
    in_4 : D_MonZusRechnUnt;
    in_5 : D_MonZusSpesen;
    in_6 : D_ProjAbrMonat;
    in_7 : D_MaName
  eingabe
    ein_1 : TF_ProjektAbrechnung!projAbrRechnUnt;
    ein_2 : TF_MonatsBericht!monIntRechnUnt;
    ein_3 : T_SpesenBeleg!spesBelRechnUnt;
    ein_4 : TF_MonZus!monZusRechnUnt;
    ein_5 : TF_MonZus!monZusSpesen;
    ein_6 : TF_MonZus!projAbrMonat;
    ein_7 : TF_MonZus!maName
  ausgabe
    aus_1 : TX_Fibu!monZusSpesen;
    aus_2 : TX_Fibu!projAbrMonat;
    aus_3 : TX_Fibu!maName
end P_4120

P_4130 in Aktion with
  bearbeitet_von
    wer : A_Buchhalt
  folgt_auf
    pVon : P_4120
  nimmt
    nimm_1 : TX_Fibu
  input
    in_1 : D_MonZusSpesen;
    in_2 : D_ProjAbrMonat;
    in_3 : D_MaName
  eingabe
    ein_1 : TX_Fibu!monZusSpesen;
    ein_2 : TX_Fibu!projAbrMonat;
    ein_3 : TX_Fibu!maName
end P_4130

P_ENDE with
  folgt_auf
    pVon_4130 : P_4130
end P_ENDE


