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

P_3210 in Aktion with
  bearbeitet_von
    wer : A_ProjContrl
  folgt_auf
    pVon : P_3150
  nimmt
    nimm_1 : TF_StatusBericht; 
    nimm_2 : TF_ProjektAbrechnung
  gibt
    gib_1 : TX_Halbfertige
  input
    in_1 : D_ProjAbrMonat;
    in_2 : D_ProjNummer;
    in_4 : D_ProjStatFertigSum
  eingabe
    ein_1 : TF_ProjektAbrechnung!projAbrStundenSum;
    ein_2 : TF_ProjektAbrechnung!projNummer;
    ein_3 : TF_ProjektAbrechnung!projAbrMonat;
    ein_4 : TF_StatusBericht!projStatFertigSum;
    ein_5 : TF_StatusBericht!projAbrMonat
  output
    out_1 : D_HalbFertigSumme;
    out_2 : D_HalbFertigRestaufwand
  ausgabe
   aus_1 : TX_Halbfertige!projNummer;
   aus_2 : TX_Halbfertige!projAbrMonat;
   aus_3 : TX_Halbfertige!halbFertigSumme;
   aus_4 : TX_Halbfertige!halbFertigRestaufwand
end P_3210

P_3220 in Aktion with
  bearbeitet_von
    wer : A_ProjContrl
  folgt_auf
    pVon : P_3210
  nimmt
    nimm_1 : TF_ProjektAbrechnung;
    nimm_2 : TX_SpesenRechnung;
    nimm_3 : T_Kostensaetze;
    nimm_4 : TX_Probat
  gibt
    gib_1 : TX_Probat
  input
    in_1 : D_ProjNummer;
    in_2 : D_ProjAbrLeistung;
    in_3 : D_ProjAbrStundenSum;
    in_5 : D_ProjAbrSpesVorOrt;
    in_6 : D_ProjAbrMonat;
    in_7 : D_SpesenBetragNetto;
    in_8 : D_KostenSatz;
    in_9 : D_MaName
  eingabe
    ein_11 : TF_ProjektAbrechnung!projNummer;
    ein_12 : TF_ProjektAbrechnung!projAbrLeistung;
    ein_13 : TF_ProjektAbrechnung!projAbrMonat;
    ein_14 : TF_ProjektAbrechnung!projAbrSpesVorOrt;
    ein_15 : TF_ProjektAbrechnung!projAbrStundenSum;
    ein_21 : TX_SpesenRechnung!spesenBetragNetto;
    ein_31 : T_Kostensaetze!kostenSatz;
    ein_32 : T_Kostensaetze!maName;
    ein_41 : TX_Probat!projAbrMonat;
    ein_42 : TX_Probat!projNummer;
    ein_44 : TX_Probat!maName
  ausgabe
    aus_1 : TX_Probat!projAbrMonat;
    aus_2 : TX_Probat!projAbrLeistung;
    aus_3 : TX_Probat!projAbrStundenSum;
    aus_4 : TX_Probat!projAbrSpesVorOrt;
    aus_5 : TX_Probat!spesenBetragNetto    
end P_3220

P_3230 in Aktion with
  bearbeitet_von
    wer : A_ProjContrl
  folgt_auf
    pVon : P_3220
  nimmt
    nimm_1 : TX_Probat
  gibt
    gib_1 : TW_Rechnung
  input
    in_1 : D_ProjNummer;
    in_2 : D_ProjAbrMonat;
    in_3 : D_ProjAbrLeistung;
    in_4 : D_SpesenBetragNetto
  output
    out_1 : D_RechngNummer;
    out_2 : D_SpesenBetragSum
  eingabe
    ein_1 : TX_Probat!projNummer;
    ein_2 : TX_Probat!projAbrMonat;
    ein_3 : TX_Probat!projAbrStundenSum;
    ein_4 : TX_Probat!spesenBetragNetto
  ausgabe
    aus_1 : TW_Rechnung!rechngNummer;
    aus_2 : TW_Rechnung!projNummer;
    aus_3 : TW_Rechnung!projAbrMonat;
    aus_4 : TW_Rechnung!projAbrStundenSum;
    aus_5 : TW_Rechnung!spesenBetragSum
end P_3230

P_3240 in Aktion with
  bearbeitet_von
    wer : A_ProjContrl
  folgt_auf
    pVon : P_3230
  nimmt
    nimm_1 : TF_ProjektAbrechnung;
    nimm_2 : TW_Rechnung
  input
    in_1 : D_KundenName;
    in_2 : D_ProjNummer;
    in_3 : D_ProjAbrMonat
  eingabe
    ein_1 : TW_Rechnung!projNummer;
    ein_2 : TW_Rechnung!projAbrMonat;
    ein_3 : TF_ProjektAbrechnung!kundenName;
    ein_4 : TF_ProjektAbrechnung!projNummer
  ausgabe
    aus_1 : TW_Rechnung!kundenName
end P_3240

P_3250 in Aktion with
  bearbeitet_von
    wer : A_ProjContrl
  folgt_auf
    pVon : P_3240
  nimmt
    nimm_1 : TW_Rechnung
  gibt
    gib_1 : T_BuchungsListe
  input
    in_1 : D_RechngNummer
  eingabe
    ein_1 : TW_Rechnung!rechngNummer
  ausgabe
    pAus_1 : T_BuchungsListe!rechngNummer
end P_3250

P_3260 in Aktion with
  bearbeitet_von
    wer : A_ProjContrl
  folgt_auf
    pVon : P_3240
  nimmt
    nimm_1 : TX_Probat
  gibt
    gib_1 : T_UmsatzListe
  input
    in_1 : D_ProjAbrMonat;
    in_2 : D_ProjNummer;
    in_3 : D_ProjAbrStundenSum;
    in_4 : D_KundenName
  eingabe
    ein_1 : TX_Probat!projAbrMonat;
    ein_2 : TX_Probat!projNummer;
    ein_3 : TX_Probat!projAbrStundenSum;
    ein_4 : TX_Probat!kundenName
  ausgabe
    aus_1 : T_UmsatzListe!projAbrMonat;  
    aus_2 : T_UmsatzListe!projNummer;
    aus_3 : T_UmsatzListe!projAbrStundenSum;
    aus_4 : T_UmsatzListe!kundenName
end P_3260

P_ENDE with 
  folgt_auf 
    pVon_3260 : P_3260
end P_ENDE

P_3270 in Aktion with
  bearbeitet_von
    wer : A_ProjContrl
  folgt_auf
    pVon : P_3240
  nimmt
    nimm_1 : TW_Rechnung
  gibt
    gib_1 : T_Rechnung
  input
    in_1 : D_RechngNummer;
    in_2 : D_ProjNummer;
    in_3 : D_ProjAbrMonat;
    in_4 : D_ProjAbrStundenSum;
    in_5 : D_SpesenBetragSum;
    in_6 : D_KundenName
  eingabe
    ein_1 : TW_Rechnung!rechngNummer;
    ein_2 : TW_Rechnung!projNummer;
    ein_3 : TW_Rechnung!projAbrMonat;
    ein_4 : TW_Rechnung!projAbrStundenSum;
    ein_5 : TW_Rechnung!spesenBetragSum;
    ein_6 : TW_Rechnung!kundenName
  ausgabe
    aus_1 : T_Rechnung!rechngNummer;
    aus_2 : T_Rechnung!projNummer;
    aus_3 : T_Rechnung!projAbrMonat;
    aus_4 : T_Rechnung!projAbrStundenSum;
    aus_5 : T_Rechnung!spesenBetragSum;
    aus_6 : T_Rechnung!kundenName
end P_3270

P_3280 in Aktion with
  bearbeitet_von
    wer : A_ProjContrl
  folgt_auf
    pVon : P_3270
  nimmt
    nimm_1 : T_Rechnung;
    nimm_2 : T_SpesenBeleg;
    nimm_3 : T_SonstKosten;
    nimm_4 : TF_ProjektAbrechnung
  gibt
    gib_1 : T_Rechnung;
    gib_2 : T_SpesenBeleg;
    gib_3 : T_SonstKosten;
    gib_4 : TF_ProjektAbrechnung
  input
    in_1 : D_RechngNummer
  eingabe
    ein_1 : T_Rechnung!rechngNummer 
  output
    out_1 : D_RechngUnt
  ausgabe
    aus_1 : T_Rechnung!rechngUnt
end P_3280


