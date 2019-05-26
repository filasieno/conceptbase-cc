{*
The ConceptBase.cc Copyright

Copyright 1987-2014 The ConceptBase Team. All rights reserved.

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

Matthias Jarke, RWTH Aachen, Informatik 5, Ahornstr. 55, 52056 Aachen, Germany
Manfred Jeusfeld, Tilburg University, Warandelaan 2, 5037 AB Tilburg, The Netherlands
Christoph Quix, RWTH Aachen, Informatik 5, Ahornstr. 55, 52056 Aachen, Germany


This license is a FreeBSD-style copyright license.
Legal home of the FreeBSD copyright license: http://www.freebsd.org/copyright/freebsd-license.html
*}
{$set syntax=PlainToronto}

P_2010 in Aktion with
  bearbeitet_von
    wer : A_Kunde
  folgt_auf
    pVon : P_1030
  gibt
    gib_1 : T_Anfrage
  output
    out_1 : D_KundenName
  ausgabe 
    aus_1 : T_Anfrage!kundenName
end P_2010

P_2020 in Aktion with
  bearbeitet_von
    wer : A_Kundenverantwortlicher
  folgt_auf
    pVon : P_2010
  nimmt
    nimm_1 : T_Anfrage
  gibt
    gib_1 : T_Angebot;
    gib_2 : TF_Kalkulationsblatt
  input
    in_1 : D_KundenName
  output
    out_1 : D_AngebotsLeistung;
    out_2 : D_AngebotsNummer;
    out_3 : D_KalkStunden
  eingabe
    ein_1 : T_Anfrage!kundenName
  ausgabe
    aus_1 : T_Angebot!angebotsLeistung;
    aus_2 : T_Angebot!angebotsNummer;
    aus_0 : T_Angebot!kundenName;
    aus_4 : TF_Kalkulationsblatt!angebotsLeistung;
    aus_5 : TF_Kalkulationsblatt!angebotsNummer;
    aus_6 : TF_Kalkulationsblatt!kundenName;
    aus_7 : TF_Kalkulationsblatt!kalkStunden
end P_2020

P_2030 in Aktion with
  bearbeitet_von
    wer : A_GL
  folgt_auf
    pVon : P_2020
  nimmt
    nimm_1 : T_Anfrage;
    nimm_2 : T_Angebot;
    nimm_3 : TF_Kalkulationsblatt
  gibt
    gib_1 : T_Angebot;
    gib_2 : TF_Kalkulationsblatt
  input
    in_1 : D_KundenName;
    in_2 : D_AngebotsNummer;
    in_3 : D_AngebotsLeistung;
    in_4 : D_KalkStunden
  output
    out_1 : D_AngebotsOk
  eingabe 
    ein_11 : T_Anfrage!kundenName;
    ein_21 : T_Angebot!kundenName;
    ein_22 : T_Angebot!angebotsNummer;
    ein_23 : T_Angebot!angebotsLeistung;
    ein_31 : TF_Kalkulationsblatt!kundenName;
    ein_32 : TF_Kalkulationsblatt!angebotsNummer;
    ein_33 : TF_Kalkulationsblatt!angebotsLeistung;
    ein_34 : TF_Kalkulationsblatt!kalkStunden
  ausgabe
    aus_1 : TF_Kalkulationsblatt!angebotsOk
end P_2030

P_2035 in Aktion with
  bearbeitet_von
    wer : A_Kundenverantwortlicher
  folgt_auf
    pVon : P_2030
  nimmt
    nimm_1 : T_Anfrage;
    nimm_2 : T_Angebot;
    nimm_3 : TF_Kalkulationsblatt
  gibt
    gib_1 : T_Angebot
  input
    in_1 : D_KundenName;
    in_2 : D_AngebotsNummer;
    in_3 : D_AngebotsLeistung;
    in_4 : D_AngebotsOk
  output
    out_1 : D_AngebotUntGL
  eingabe 
    ein_11 : T_Anfrage!kundenName;
    ein_21 : T_Angebot!kundenName;
    ein_22 : T_Angebot!angebotsNummer;
    ein_23 : T_Angebot!angebotsLeistung;
    ein_31 : TF_Kalkulationsblatt!kundenName;
    ein_32 : TF_Kalkulationsblatt!angebotsNummer;
    ein_33 : TF_Kalkulationsblatt!angebotsOk
  ausgabe
    aus_1 : T_Angebot!angebotUntGL
end P_2035

P_2040 in Aktion with
  bearbeitet_von
    wer : A_Kunde
  folgt_auf
    pVon : P_2030
  nimmt
    nimm_1 : T_Angebot
  gibt
    gib_1 : T_Auftrag
  input
    in_1 : D_KundenName;
    in_2 : D_AngebotUntGL;
    in_3 : D_AngebotsNummer
  output
    out_1 : D_AuftragUnt
  eingabe
    ein_1 : T_Angebot!kundenName;
    ein_2 : T_Angebot!angebotUntGL;
    ein_3 : T_Angebot!angebotsNummer;
    ein_4 : T_Angebot!angebotsLeistung
  ausgabe
    aus_1 : T_Auftrag!angebotsNummer;
    aus_2 : T_Auftrag!auftragUnt;
    aus_3 : T_Auftrag!kundenName
end P_2040

P_2050 in Aktion with
  bearbeitet_von
    wer : A_Kundenverantwortlicher
  folgt_auf
    pVon : P_2040
  nimmt
    nimm_1 : T_Auftrag
  gibt
    gib_1 : TF_ProjektAuftrag
  input
    in_1 : D_AngebotsNummer;
    in_2 : D_AuftragUnt;
    in_3 : D_KundenName
  output
    out_1 : D_PlName
  eingabe
    ein_1 : T_Auftrag!angebotsNummer;
    ein_2 : T_Auftrag!auftragUnt;
    ein_3 : T_Auftrag!kundenName
  ausgabe
    aus_1 : TF_ProjektAuftrag!kundenName;
    aus_2 : TF_ProjektAuftrag!plName
end P_2050

P_2060 in Aktion with
  bearbeitet_von
    wer : A_Projektleiter
  folgt_auf
    pVon : P_2050
  nimmt
    nimm_1 : TF_ProjektAuftrag;
    nimm_2 : TF_Kalkulationsblatt
  gibt
    gib_1 : TF_ProjektAnlage;
    gib_2 : TF_ProjektAuftrag;
    gib_3 : TF_ProjektAuftragMa;
    gib_4 : TF_Kalkulationsblatt
  input
    in_1 : D_KundenName;
    in_2 : D_AngebotsLeistung;
    in_3 : D_KalkStunden;
    in_4 : D_PlName
  output
    out_1 : D_ProjSollStunden
  eingabe
    ein_1 : TF_ProjektAuftrag!kundenName; 
    ein_2 : TF_Kalkulationsblatt!angebotsLeistung;
    ein_3 : TF_Kalkulationsblatt!kalkStunden;
    ein_4 : TF_ProjektAuftrag!plName
  ausgabe
    aus_1 : TF_ProjektAuftragMa!kundenName;
    aus_2 : TF_ProjektAuftragMa!maName;
    aus_3 : TF_ProjektAuftragMa!plName;
    aus_4 : TF_ProjektAuftragMa!projSollStunden;
    aus_5 : TF_ProjektAuftrag!projSollStunden;
    aus_6 : TF_ProjektAnlage!kundenName; 
    aus_7 : TF_ProjektAnlage!angebotsLeistung;
    aus_8 : TF_ProjektAnlage!projSollStunden
end P_2060

P_2070 in Aktion with
  bearbeitet_von
    wer : A_ProjContrl
  folgt_auf
    pVon : P_2060
  nimmt
    nimm_1 : TF_ProjektAnlage;
    nimm_2 : TF_ProjektAuftrag;
    nimm_3 : TF_ProjektAuftragMa;
    nimm_4 : TF_Kalkulationsblatt
  gibt
    gib_1 : TF_ProjektAnlage;
    gib_2 : TF_ProjektAuftrag;
    gib_3 : TF_ProjektAuftragMa;
    gib_4 : TF_Kalkulationsblatt
  input
    in_1 : D_MaName;
    in_2 : D_KundenName;
    in_3 : D_PlName;
    in_4 : D_KalkStunden;
    in_5 : D_ProjSollStunden
  output
    out_1 : D_ProjNummer
  eingabe
    ein_1 : TF_ProjektAnlage!kundenName;
    ein_2 : TF_ProjektAnlage!projSollStunden;
    ein_3 : TF_ProjektAuftrag!plName;
    ein_4 : TF_ProjektAuftragMa!maName;
    ein_5 : TF_Kalkulationsblatt!kalkStunden;
    ein_6 : TF_Kalkulationsblatt!kundenName
  ausgabe
    aus_1 : TX_Probat!kundenName;
    aus_2 : TX_Probat!projNummer;
    aus_3 : TX_Probat!plName;
    aus_4 : TX_Probat!maName;
    aus_5 : TX_Probat!projSollStunden;
    aus_11 : TF_ProjektAnlage!projNummer;
    aus_21 : TF_ProjektAuftrag!projNummer;
    aus_31 : TF_ProjektAuftragMa!projNummer
end P_2070

P_2080 in Aktion with
  bearbeitet_von
    wer : A_Projektleiter
  folgt_auf
    pVon : P_2070
  nimmt
    nimm_1 : TF_ProjektAuftrag;
    nimm_2 : TF_ProjektAuftragMa
  gibt
    gib_1 : TF_ProjektAuftragMa
  input
    in_1 : D_MaName;
    in_2 : D_ProjNummer
  output
    out_1 : D_ProjAuftPlUnt
  eingabe
    ein_1 : TF_ProjektAuftragMa!maName;
    ein_2 : TF_ProjektAuftrag!projNummer
  ausgabe 
    aus : TF_ProjektAuftragMa!projAuftPlUnt
end P_2080


