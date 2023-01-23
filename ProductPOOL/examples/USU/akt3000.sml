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

P_3010 in Aktion with
  bearbeitet_von
    wer : A_Mitarbeiter
  folgt_auf
    pVon : P_2080
  nimmt
    nimm_1 : TF_ProjektAuftragMa
  gibt 
    gib_1 : TF_ProjektAbrechnung;
    gib_2 : TF_MonatsBericht;
    gib_3 : TF_MonZus;
    gib_4 : T_Abwesenheit;
    gib_5 : T_SpesenBeleg
  input
    in_1 : D_ProjNummer;
    in_2 : D_KundenName;
    in_3 : D_MaName
  output
    out_1 : D_ProjAbrSpesVorOrt;
    out_2 : D_ProjAbrStundenSum;
    out_3 : D_ProjAbrGesStdSum;
    out_4 : D_ProjAbrLeistung;
    out_5 : D_ProjAbrSpesenSum;
    out_6 : D_ProjAbrSpesen;
    out_7 : D_ProjAbrUntMa;
    out_8 : D_MonIntStundenSum;
    out_9 : D_MonIntLeistung;
    out_9a : D_MonIntSpesen;
    out_10 : D_MonIntSpesenSum;
    out_11 : D_MonIntUntMa;
    out_12 : D_MonZusUrlaub;
    out_13 : D_MonZusSchule;
    out_14 : D_MonZusSpesen;
    out_15 : D_SpesenBetrag;
    out_16 : D_MaUrlaub
  eingabe
    ein_1 : TF_ProjektAuftragMa!projNummer;
    ein_2 : TF_ProjektAuftragMa!kundenName;
    ein_3 : TF_ProjektAuftragMa!maName
  ausgabe
    aus_1 : TF_ProjektAbrechnung!projNummer;
    aus_2 : TF_ProjektAbrechnung!kundenName;
    aus_3 : TF_ProjektAbrechnung!projAbrMonat;
    aus_4 : TF_ProjektAbrechnung!maName;
    aus_5 : TF_ProjektAbrechnung!projAbrSpesVorOrt;
    aus_6 : TF_ProjektAbrechnung!projAbrStundenSum;
    aus_7 : TF_ProjektAbrechnung!projAbrSpesenSum;
    aus_8 : TF_ProjektAbrechnung!projAbrSpesen;
    aus_9 : TF_ProjektAbrechnung!projAbrGesStdSum;
    aus_9a : TF_ProjektAbrechnung!projAbrLeistung;
    aus_9b : TF_ProjektAbrechnung!projAbrUntMa;
    aus_10 : TF_MonatsBericht!projAbrMonat;
    aus_11 : TF_MonatsBericht!maName;
    aus_12 : TF_MonatsBericht!monIntStundenSum;
    aus_13 : TF_MonatsBericht!monIntLeistung;
    aus_14 : TF_MonatsBericht!monIntSpesenSum;
    aus_15 : TF_MonatsBericht!monIntSpesen;
    aus_16 : TF_MonatsBericht!monIntUntMa;
    aus_17 : TF_MonatsBericht!projAbrSpesenSum;
    aus_18 : TF_MonatsBericht!projAbrLeistung;
    aus_20 : TF_MonZus!projAbrMonat;
    aus_21 : TF_MonZus!maName;
    aus_22 : TF_MonZus!monZusUrlaub;
    aus_23 : TF_MonZus!monIntStundenSum;
    aus_24 : TF_MonZus!projAbrGesStdSum;
    aus_25 : TF_MonZus!monIntLeistung;
    aus_26 : TF_MonZus!projAbrSpesenSum;
    aus_27 : TF_MonZus!monIntSpesenSum;
    aus_28 : TF_MonZus!monZusSpesen;
    aus_29 : TF_MonZus!monZusSchule;
    aus_30 : T_SpesenBeleg!spesenBetrag;
    aus_40 : T_Abwesenheit!maName;
    aus_41 : T_Abwesenheit!maUrlaub
end P_3010 

P_3020 in Aktion with
  bearbeitet_von
    wer : A_Projektleiter
  folgt_auf
    pVon : P_3010
  nimmt 
    nimm_1 : TF_ProjektAbrechnung;
    nimm_2 : T_Abwesenheit;
    nimm_3 : T_SpesenBeleg;
    nimm_4 : TF_ProjektAuftrag
  gibt
    gib_1 : TF_ProjektAbrechnung;
    gib_2 : T_Abwesenheit;
    gib_3 : T_SpesenBeleg
  input
    in_1 : D_ProjAbrMonat;
    in_2 : D_ProjNummer;
    in_3 : D_MaName;
    in_4 : D_ProjAbrUntMa;
    in_5 : D_ProjAbrLeistung
  output
    out_1 : D_ProjAbrUntPl
  eingabe
    ein_1 : TF_ProjektAuftrag!projNummer;
    ein_2 : TF_ProjektAbrechnung!maName;
    ein_3 : TF_ProjektAbrechnung!projAbrUntMa;
    ein_4 : TF_ProjektAbrechnung!projAbrLeistung;
    ein_5 : TF_ProjektAbrechnung!projAbrMonat;
    ein_6 : T_SpesenBeleg!spesenBetrag
  ausgabe 
    aus_1 : TF_ProjektAbrechnung!projAbrUntPl
end P_3020

P_3030 in Aktion with
  bearbeitet_von
    wer : A_KundenPl
  folgt_auf
    pVon : P_3020
  nimmt 
    nimm_1 : TF_ProjektAbrechnung
  gibt
    gib_1 : TF_ProjektAbrechnung
  input
    in_1 : D_ProjAbrMonat;
    in_2 : D_ProjNummer;
    in_3 : D_MaName;
    in_4 : D_ProjAbrUntMa;
    in_5 : D_ProjAbrLeistung;
    in_6 : D_ProjAbrSpesVorOrt
  output
    out_1 : D_ProjAbrUntKd
  eingabe
    ein_1 : TF_ProjektAbrechnung!projAbrMonat;
    ein_2 : TF_ProjektAbrechnung!projNummer;
    ein_3 : TF_ProjektAbrechnung!maName;
    ein_4 : TF_ProjektAbrechnung!projAbrUntMa;
    ein_5 : TF_ProjektAbrechnung!projAbrLeistung;
    ein_6 : TF_ProjektAbrechnung!projAbrSpesVorOrt
  ausgabe 
    aus_1 : TF_ProjektAbrechnung!projAbrUntKd
end P_3030

P_3040 in Aktion with
  bearbeitet_von
    wer : A_Projektleiter
  folgt_auf
    pVon_3020 : P_3020;
    pVon_3030 : P_3030
  nimmt
    nimm_1 : TF_ProjektAuftrag;
    nimm_2 : TF_ProjektAbrechnung
  gibt
    gib_1 : TF_ProjektAbrechnung;
    gib_2 : TF_StatusBericht
  input
    in_1 : D_ProjAbrMonat;
    in_2 : D_ProjNummer;
    in_3 : D_ProjAbrLeistung
  output
    out_1 : D_ProjStatOperativ;
    out_2 : D_ProjStatFestpreis;
    out_3 : D_ProjStatRechng;
    out_4 : D_ProjStatFertig;
    out_5 : D_ProjStatUnt
  eingabe
    ein_1 : TF_ProjektAuftrag!projNummer;
    ein_2 : TF_ProjektAbrechnung!projAbrMonat;
    ein_3 : TF_ProjektAbrechnung!projNummer;
    ein_4 : TF_ProjektAbrechnung!projAbrLeistung
  ausgabe
    aus_1 : TF_StatusBericht!projNummer;
    aus_2 : TF_StatusBericht!projAbrMonat;
    aus_3 : TF_StatusBericht!projStatOperativ;
    aus_4 : TF_StatusBericht!projStatFestpreis;
    aus_5 : TF_StatusBericht!projStatRechng;
    aus_6 : TF_StatusBericht!projStatFertig;
    aus_7 : TF_StatusBericht!projStatUnt
end P_3040


