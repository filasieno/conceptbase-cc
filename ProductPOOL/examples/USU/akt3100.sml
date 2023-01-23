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

P_3110 in Aktion with
  bearbeitet_von
    wer : A_ProjContrl
  folgt_auf
    pVon : P_3040
  nimmt
    nimm_1 : TF_StatusBericht;
    nimm_2 : TF_ProjektAbrechnung;
    nimm_3 : T_Abwesenheit;
    nimm_4 : T_SpesenBeleg
  input
    in_1 : D_ProjStatUnt;
    in_2 : D_ProjAbrUntMa;
    in_3 : D_ProjAbrUntPl;
    in_4 : D_ProjStatRechng;
    in_5 : D_ProjStatOperativ;
    in_6 : D_ProjAbrMonat;
    in_7 : D_ProjNummer;
    in_8 : D_MaName
  eingabe 
    ein_11 : TF_StatusBericht!projStatUnt;
    ein_12 : TF_StatusBericht!projStatRechng;
    ein_13 : TF_StatusBericht!projNummer;
    ein_14 : TF_StatusBericht!projAbrMonat;
    ein_15 : TF_StatusBericht!projStatOperativ;
    ein_21 : TF_ProjektAbrechnung!projAbrUntMa;
    ein_22 : TF_ProjektAbrechnung!projAbrUntPl;
    ein_23 : TF_ProjektAbrechnung!projAbrMonat;
    ein_24 : TF_ProjektAbrechnung!projNummer;
    ein_25 : TF_ProjektAbrechnung!maName
end P_3110

P_3120 in Aktion with
  bearbeitet_von
    wer : A_ProjContrl
  folgt_auf
    pVon : P_3110
  nimmt
    nimm_1 : TF_StatusBericht;
    nimm_2 : TF_ProjektAbrechnung
  gibt
    gib_1 : TF_StatusBericht
  input
    in_1 : D_ProjAbrMonat;
    in_2 : D_ProjNummer;
    in_3 : D_ProjAbrStundenSum;
    in_4 : D_ProjAbrGesStdSum
  output
    out_1 : D_ProjStatFertigSum
  eingabe
    ein_11 : TF_StatusBericht!projNummer;
    ein_12 : TF_StatusBericht!projStatRechng;
    ein_13 : TF_StatusBericht!projAbrMonat;   
    ein_21 : TF_ProjektAbrechnung!projNummer;
    ein_22 : TF_ProjektAbrechnung!projAbrStundenSum;
    ein_23 : TF_ProjektAbrechnung!projAbrMonat;
    ein_24 : TF_ProjektAbrechnung!projAbrGesStdSum
  ausgabe
    aus_1 : TF_StatusBericht!projStatFertigSum
end P_3120

P_3130 in Aktion with
  bearbeitet_von
    wer : A_Sekretariat
  folgt_auf
    pVon : P_START
  gibt
    gib_1 : T_SonstKosten
  output
    out_1 : D_SonstBetrag 
  ausgabe
    aus_1 : T_SonstKosten!sonstBetrag
end P_3130

P_3140 in Aktion with
  bearbeitet_von
    wer : A_ProjContrl
  folgt_auf
    pVon_3120 : P_3120;
    pVon_3130 : P_3130
  nimmt
    nimm_1 : TF_ProjektAbrechnung;
    nimm_2 : T_SpesenBeleg;
    nimm_3 : T_SonstKosten
  gibt
    gib_1 : TX_SpesenRechnung
  input
    in_1 : D_SpesenBetrag;
    in_2 : D_SonstBetrag;
    in_3 : D_MaName;
    in_4 : D_ProjAbrMonat;
    in_5 : D_ProjNummer
  output
    out_1 : D_SpesenBetragNetto
  eingabe
    ein_1 : TF_ProjektAbrechnung!projAbrMonat;
    ein_2 : TF_ProjektAbrechnung!maName;
    ein_3 : TF_ProjektAbrechnung!projNummer;
    ein_4 : T_SpesenBeleg!spesenBetrag;
    ein_5 : T_SonstKosten!sonstBetrag
  ausgabe
    aus_1 : TX_SpesenRechnung!spesenBetrag;
    aus_2 : TX_SpesenRechnung!spesenBetragNetto
end P_3140

P_3150 in Aktion with
  bearbeitet_von
    wer : A_ProjContrl
  folgt_auf
    pVon : P_3140
  nimmt
    nimm_1 : TF_ProjektAbrechnung
  gibt
    gib_1 : TF_ProjektAbrechnung
  input
    in_1 : D_ProjAbrMonat;
    in_2 : D_ProjAbrGesStdSum;
    in_3 : D_ProjAbrStundenSum;
    in_4 : D_MaName
  eingabe
    ein_1 : TF_ProjektAbrechnung!projAbrMonat;
    ein_2 : TF_ProjektAbrechnung!projAbrGesStdSum;
    ein_3 : TF_ProjektAbrechnung!projAbrStundenSum;
    ein_4 : TF_ProjektAbrechnung!maName
  output
    out_1 : D_ProjAbrBonusExtra
  ausgabe
    aus_1 : TF_ProjektAbrechnung!projAbrBonusExtra
end P_3150



