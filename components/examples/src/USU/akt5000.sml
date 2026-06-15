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

P_5020 in Aktion with
  bearbeitet_von
    wer : A_ProjContrl
  folgt_auf
    pVon : P_4120
  nimmt
    nimm_1 : T_SonstKosten;
    nimm_2 : TX_Probat
  gibt
    gib_1 : TX_Probat
  input
    in_1 : D_SonstBetrag;
    in_2 : D_ProjAbrMonat;
    in_3 : D_ProjNummer
  eingabe
    ein_11 : T_SonstKosten!sonstBetrag;
    ein_21 : TX_Probat!projAbrMonat;
    ein_22 : TX_Probat!projNummer
  ausgabe
    aus_1 : TX_Probat!sonstBetrag
end P_5020

P_5030 in Aktion with
  bearbeitet_von
    wer : A_ProjContrl
  folgt_auf
    pVon_1 : P_5020
  nimmt
    nimm_1 : TF_MonatsBericht;
    nimm_2 : TF_MonZus;
    nimm_3 : TF_ProjektAbrechnung;
    nimm_4 : T_SpesenBeleg;
    nimm_5 : TX_Probat
  gibt
    gib_1 : TX_Probat
  input
    in_1 : D_ProjAbrMonat;
    in_2 : D_MaName;
    in_3 : D_ProjNummer;
    in_4 : D_ProjAbrGesStdSum;
    in_5 : D_ProjAbrSpesenSum;
    in_6 : D_MonIntStundenSum;
    in_7 : D_MonIntSpesenSum;
    in_8 : D_MonIntRechnUnt;
    in_9 : D_ProjAbrRechnUnt;
    in_10 : D_MonZusRechnUnt
  eingabe
    ein_11 : TF_MonatsBericht!maName;
    ein_12 : TF_MonatsBericht!projAbrMonat;
    ein_13 : TF_MonatsBericht!monIntSpesenSum;
    ein_14 : TF_MonatsBericht!monIntStundenSum;
    ein_15 : TF_MonatsBericht!monIntRechnUnt;
    ein_21 : TF_MonZus!maName;
    ein_22 : TF_MonZus!projAbrMonat;
    ein_23 : TF_MonZus!monIntSpesenSum;
    ein_24 : TF_MonZus!monIntStundenSum;
    ein_25 : TF_MonZus!projAbrGesStdSum;
    ein_26 : TF_MonZus!projAbrSpesenSum;
    ein_27 : TF_MonZus!monZusRechnUnt;
    ein_31 : TF_ProjektAbrechnung!maName;
    ein_32 : TF_ProjektAbrechnung!projAbrMonat;
    ein_33 : TF_ProjektAbrechnung!projAbrGesStdSum;
    ein_34 : TF_ProjektAbrechnung!projAbrSpesenSum;
    ein_35 : TF_ProjektAbrechnung!projAbrRechnUnt;
    ein_41 : T_SpesenBeleg!spesenBetrag;
    ein_51 : TX_Probat!maName;
    ein_52 : TX_Probat!projAbrMonat;
    ein_53 : TX_Probat!projNummer
  ausgabe
    aus_1 : TX_Probat!maName;
    aus_2 : TX_Probat!projAbrGesStdSum;
    aus_3 : TX_Probat!projAbrSpesenSum;
    aus_4 : TX_Probat!monIntStundenSum;
    aus_5 : TX_Probat!monIntSpesenSum
end P_5030

P_5040 in Aktion with
  bearbeitet_von
    wer : A_ProjContrl
  folgt_auf
    pVon : P_5030
  nimmt
    nimm_1 : TX_Fibu;
    nimm_2 : TX_Probat
  gibt
    gib_1 : TX_Probat 
  input
    in_1 : D_MaName;
    in_2 : D_ProjAbrMonat;
    in_3 : D_MonZusSpesen;
    in_4 : D_ProjAbrSpesenSum;
    in_5 : D_MonIntSpesenSum
  eingabe
    ein_11 : TX_Fibu!projAbrMonat;
    ein_12 : TX_Fibu!maName;
    ein_13 : TX_Fibu!monZusSpesen; 
    ein_21 : TX_Probat!projAbrMonat;
    ein_22 : TX_Probat!maName;
    ein_23 : TX_Probat!projAbrSpesenSum;
    ein_24 : TX_Probat!monIntSpesenSum
  ausgabe
    aus_1 : TX_Probat!projAbrSpesenSum;
    aus_2 : TX_Probat!monIntSpesenSum
end P_5040

P_5050 in Aktion with
  bearbeitet_von
    wer : A_ProjContrl
  folgt_auf
    pVon : P_5040
  nimmt
    nimm_1 : TX_Probat
  gibt
    gib_1 : T_Auswertungen
  input
    in_1 : D_MaName;
    in_2 : D_ProjAbrMonat
  eingabe
    ein_21 : TX_Probat!projAbrMonat;
    ein_22 : TX_Probat!maName
end P_5050

P_ENDE with
  folgt_auf
    pVon_5050 : P_5050
end P_ENDE


