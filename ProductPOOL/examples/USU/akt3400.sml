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

P_3410 in Aktion with
  bearbeitet_von
    wer : A_Sekretariat
  folgt_auf
    pVon : P_3010
  nimmt
    nimm_1 : TF_MonatsBericht;
    nimm_2 : TF_MonZus;
    nimm_3 : T_Abwesenheit;
    nimm_4 : T_SpesenBeleg
  gibt
    gib_1 : TF_MonatsBericht;
    gib_2 : TF_MonZus;
    gib_3 : T_Abwesenheit;
    gib_4 : T_SpesenBeleg
end P_3410

P_3420 in Aktion with
  bearbeitet_von
    wer : A_PersVerantw
  folgt_auf
    pVon : P_3410
  nimmt
    nimm_1 : TF_MonatsBericht;
    nimm_2 : TF_MonZus;
    nimm_3 : T_Abwesenheit;
    nimm_4 : T_SpesenBeleg
  gibt
    gib_1 : TF_MonatsBericht;
    gib_2 : TF_MonZus;
    gib_3 : T_Abwesenheit;
    gib_4 : T_SpesenBeleg
  input
    in_1 : D_MonIntUntMa;
    in_2 : D_ProjAbrMonat;
    in_3 : D_MaName
  output
    out_1 : D_MonIntUntPv
  eingabe
    ein_1 : TF_MonatsBericht!monIntUntMa;
    ein_2 : TF_MonatsBericht!projAbrMonat;
    ein_3 : TF_MonatsBericht!maName
  ausgabe
    aus_1 : TF_MonatsBericht!monIntUntPv
end P_3420

P_3430 in Aktion with
  bearbeitet_von
    wer : A_Personal
  folgt_auf
    pVon_3140 : P_3140;
    pVon_3420 : P_3420
  nimmt
    nimm_1 : TF_MonatsBericht;
    nimm_2 : TF_ProjektAbrechnung;
    nimm_3 : TF_MonZus
  gibt
    gib_1 : T_SollProjektListe
  input
    in_1 : D_ProjNummer;
    in_2 : D_MaName;
    in_3 : D_ProjAbrMonat
  eingabe
    ein_11 : TF_MonatsBericht!maName;
    ein_12 : TF_MonatsBericht!projAbrMonat;
    ein_21 : TF_ProjektAbrechnung!maName;
    ein_22 : TF_ProjektAbrechnung!projNummer;
    ein_23 : TF_ProjektAbrechnung!projAbrMonat;
    ein_31 : TF_MonZus!maName;
    ein_32 : TF_MonZus!projAbrMonat
  ausgabe
    aus_1 : T_SollProjektListe!maName;
    aus_2 : T_SollProjektListe!projNummer
end P_3430

P_3440 in Aktion with
  bearbeitet_von
    wer : A_Personal
  folgt_auf
    pVon : P_3430
  nimmt
    nimm_1 : TF_MonatsBericht;
    nimm_2 : TF_ProjektAbrechnung;
    nimm_3 : T_SpesenBeleg
  gibt
    gib_1 : T_KorrekturGespraech
  input
    in_1 : D_ProjNummer;
    in_2 : D_MaName;
    in_3 : D_MonIntSpesen;
    in_4 : D_MonIntLeistung;
    in_5 : D_MonIntStundenSum;
    in_6 : D_ProjAbrSpesenSum;
    in_7 : D_ProjAbrLeistung;
    in_8 : D_SpesenBetrag;
    in_9 : D_ProjAbrMonat;
    in_10 : D_MonIntUntMa;
    in_11 : D_MonIntUntPv;
    in_12 : D_ProjAbrUntMa;
    in_13 : D_ProjAbrSpesVorOrt;
    in_14 : D_ProjAbrSpesen
  eingabe
    ein_1 : TF_MonatsBericht!maName;
    ein_2 : TF_MonatsBericht!projAbrMonat;
    ein_3 : TF_MonatsBericht!monIntSpesen;
    ein_4 : TF_MonatsBericht!monIntStundenSum;
    ein_5 : TF_MonatsBericht!monIntLeistung;
    ein_6 : TF_MonatsBericht!projAbrLeistung;
    ein_7 : TF_MonatsBericht!projAbrSpesenSum;
    ein_8 : TF_MonatsBericht!monIntUntMa;
    ein_9 : TF_MonatsBericht!monIntUntPv;
    ein_10 : TF_ProjektAbrechnung!maName;
    ein_11 : TF_ProjektAbrechnung!projAbrMonat;
    ein_12 : TF_ProjektAbrechnung!projAbrLeistung;
    ein_13 : TF_ProjektAbrechnung!projAbrStundenSum;
    ein_14 : TF_ProjektAbrechnung!projAbrUntMa;
    ein_15 : TF_ProjektAbrechnung!projNummer;
    ein_16 : TF_ProjektAbrechnung!projAbrSpesVorOrt;
    ein_17 : TF_ProjektAbrechnung!projAbrSpesen;
    ein_30 : T_SpesenBeleg!spesenBetrag
  output
    out_1 : D_KorrekturInfo
  ausgabe
    aus_1 : T_KorrekturGespraech!korrekturInfo
end P_3440

P_3450 in Aktion with
  bearbeitet_von
    wer : A_Personal
  folgt_auf
    pVon : P_3430
  nimmt
    nimm_1 : TF_MonZus;
    nimm_2 : T_Abwesenheit;
    nimm_3 : TX_Perbit
  gibt
    gib_1 : TX_Perbit
  input
    in_1 : D_MaName;
    in_2 : D_MaUrlaub;
    in_3 : D_ProjAbrMonat;
    in_4 : D_MonZusUrlaub
  output
    out_1 : D_PerbitUrlaub
  eingabe
    ein_11 : TF_MonZus!monZusUrlaub;
    ein_12 : TF_MonZus!maName;
    ein_13 : TF_MonZus!projAbrMonat;
    ein_21 : T_Abwesenheit!maName;
    ein_22 : T_Abwesenheit!maUrlaub;
    ein_31 : TX_Perbit!maName
  ausgabe
    aus_1 : TX_Perbit!perbitUrlaub
end P_3450

P_3460 in Aktion with
  bearbeitet_von
    wer : A_Personal
  folgt_auf
    pVon : P_3430
  nimmt
    nimm_1 : TF_MonZus;
    nimm_2 : TX_Perbit
  gibt
    gib_1 : TX_Perbit
  input
    in_1 : D_MonZusSchule;
    in_2 : D_MaName;
    in_3 : D_ProjAbrMonat
  eingabe
    ein_1 : TF_MonZus!monZusSchule;
    ein_2 : TF_MonZus!maName;
    ein_3 : TF_MonZus!projAbrMonat;
    ein_4 : TX_Perbit!maName
  output
    out_1 : D_PerbitSchulung
  ausgabe
    aus_1 : TX_Perbit!perbitSchulung
end P_3460

P_3470 in Aktion with
  bearbeitet_von
    wer : A_Personal
  folgt_auf
    pVon_1 : P_3440;
    pVon_2 : P_3450;
    pVon_3 : P_3460
  nimmt
    nimm_1 : TF_MonatsBericht;
    nimm_2 : TF_MonZus;
    nimm_3 : TF_ProjektAbrechnung;
    nimm_4 : T_SpesenBeleg
  gibt
    gib_1 : TF_MonatsBericht;
    gib_2 : TF_MonZus;
    gib_3 : TF_ProjektAbrechnung;
    gib_4 : T_SpesenBeleg
  input
    in_1 : D_SpesenBetrag;
    in_2 : D_ProjAbrSpesen;
    in_3 : D_ProjAbrSpesenSum;
    in_4 : D_MonIntSpesen;
    in_5 : D_MonIntSpesenSum;
    in_6 : D_ProjAbrMonat;
    in_7 : D_ProjNummer;
    in_8 : D_MaName;
    in_9 : D_ProjAbrSpesVorOrt
  eingabe
    ein_11 : TF_MonatsBericht!monIntSpesen;
    ein_12 : TF_MonatsBericht!monIntSpesenSum;
    ein_13 : TF_MonatsBericht!projAbrMonat;
    ein_14 : TF_MonatsBericht!maName;
    ein_21 : TF_ProjektAbrechnung!projNummer;
    ein_22 : TF_ProjektAbrechnung!projAbrSpesen;
    ein_23 : TF_ProjektAbrechnung!projAbrSpesenSum;
    ein_24 : TF_ProjektAbrechnung!projAbrMonat;
    ein_25 : TF_ProjektAbrechnung!maName;
    ein_26 : TF_ProjektAbrechnung!projAbrSpesVorOrt;
    ein_31 : TF_MonZus!projAbrMonat;
    ein_32 : TF_MonZus!maName;
    ein_33 : TF_MonZus!projAbrGesStdSum;
    ein_34 : TF_MonZus!projAbrSpesenSum;
    ein_4 : T_SpesenBeleg!spesenBetrag
  output
    out_1 : D_MonIntSachlUnt;
    out_2 : D_ProjAbrSachlUnt;
    out_3 : D_MonZusSachlUnt;
    out_4 : D_SpesBelSachlUnt
  ausgabe
    aus_1 : TF_MonatsBericht!monIntSachlUnt;
    aus_2 : TF_ProjektAbrechnung!projAbrSachlUnt;
    aus_3 : TF_MonZus!monZusSachlUnt;
    aus_4 : T_SpesenBeleg!spesBelSachlUnt
end P_3470

P_3480 in Aktion with
  bearbeitet_von
    wer : A_Personal
  folgt_auf
    pVon : P_3470
  nimmt
    nimm_1 : TF_MonZus
  gibt
    gib_1 : TX_LUG
  input
    in_1 : D_MaName;
    in_2 : D_MonIntStundenSum;
    in_3 : D_ProjAbrMonat
  eingabe
    ein_1 : TF_MonZus!projAbrMonat;
    ein_2 : TF_MonZus!maName;
    ein_3 : TF_MonZus!monIntStundenSum
  ausgabe
    aus_1 : TX_LUG!maName;
    aus_2 : TX_LUG!monIntStundenSum
end P_3480

P_3490 in Aktion with
  bearbeitet_von
    wer : A_Personal
  folgt_auf
    pVon : P_3480
end P_3490

P_3500 in Aktion with
  bearbeitet_von
    wer : A_Personal
  folgt_auf
    pVon : P_3490
  nimmt 
    nimm_1 : TX_LUG
  gibt
    gib_1 : T_VersNachweis
  input
    in_1 : D_MonIntStundenSum
  eingabe
    ein_1 : TX_LUG!monIntStundenSum
  ausgabe
    aus_1 : T_VersNachweis!monIntStundenSum
end P_3500

P_ENDE with
  folgt_auf
    pVon_3500 : P_3500
end P_ENDE

