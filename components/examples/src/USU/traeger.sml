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


TF_StatusBericht in Traeger with
  enthaelt
    projNummer : D_ProjNummer;
    projAbrMonat : D_ProjAbrMonat;
    projStatOperativ : D_ProjStatOperativ;
    projStatFestpreis : D_ProjStatFestpreis;
    projStatRechng : D_ProjStatRechng;
    projStatFertig : D_ProjStatFertig;
    projStatFertigSum : D_ProjStatFertigSum;
    projStatUnt : D_ProjStatUnt
end TF_StatusBericht

TF_ProjektAbrechnung in Traeger with
  enthaelt
    projNummer: D_ProjNummer;
    projAbrMonat : D_ProjAbrMonat;
    maName : D_MaName;
    kundenName : D_KundenName;
    projAbrGB : D_ProjAbrGB;
    projAbrUntMa : D_ProjAbrUntMa;
    projAbrUntPl : D_ProjAbrUntPl;
    projAbrSpesenSum : D_ProjAbrSpesenSum;
    projAbrSpesen : D_ProjAbrSpesen;
    projAbrGesStdSum : D_ProjAbrGesStdSum;
    projAbrSpesVorOrt : D_ProjAbrSpesVorOrt;
    projAbrStundenSum : D_ProjAbrStundenSum;
    projAbrLeistung : D_ProjAbrLeistung;
    projAbrBonusExtra : D_ProjAbrBonusExtra;
    projAbrUntKd : D_ProjAbrUntKd;
    projAbrSachlUnt : D_ProjAbrSachlUnt;
    projAbrRechnUnt : D_ProjAbrRechnUnt
end TF_ProjektAbrechnung

TF_MonatsBericht in Traeger with
  enthaelt
    maName : D_MaName;
    projAbrMonat : D_ProjAbrMonat;
    monIntSpesen : D_MonIntSpesen;
    monIntSpesenSum : D_MonIntSpesenSum;
    monIntStundenSum : D_MonIntStundenSum;
    monIntLeistung : D_MonIntLeistung;
    projAbrLeistung : D_ProjAbrLeistung;
    projAbrSpesenSum : D_ProjAbrSpesenSum;
    monIntUntMa : D_MonIntUntMa;
    monIntUntPv : D_MonIntUntPv;
    monIntSachlUnt : D_MonIntSachlUnt;
    monIntRechnUnt : D_MonIntRechnUnt
end TF_MonatsBericht

TF_MonZus in Traeger with
  enthaelt
    maName : D_MaName;
    projAbrMonat : D_ProjAbrMonat;
    monIntSpesenSum : D_MonIntSpesenSum;
    monIntStundenSum : D_MonIntStundenSum;
    monIntLeistung : D_MonIntLeistung;
    monZusUrlaub : D_MonZusUrlaub;
    monZusSchule : D_MonZusSchule;
    projAbrGesStdSum : D_ProjAbrGesStdSum;
    projAbrSpesenSum : D_ProjAbrSpesenSum;
    monZusSpesen : D_MonZusSpesen;
    monZusSachlUnt : D_MonZusSachlUnt;
    monZusRechnUnt : D_MonZusRechnUnt
end TF_MonZus

T_SpesenBeleg in Traeger with
  enthaelt
    spesenBetrag : D_SpesenBetrag;
    spesBelSachlUnt : D_SpesBelSachlUnt;
    spesBelRechnUnt : D_SpesBelRechnUnt
end T_SpesenBeleg

T_Rechnung in Traeger with
  enthaelt
    rechngNummer : D_RechngNummer;
    projNummer : D_ProjNummer;
    projAbrMonat : D_ProjAbrMonat;
    kundenName : D_KundenName;
    projAbrStundenSum : D_ProjAbrStundenSum;
    projAbrSumme : D_ProjAbrSumme;
    spesenBetragSum : D_SpesenBetragSum;
    rechngUnt : D_RechngUnt
end T_Rechnung

TW_Rechnung in Traeger with
  enthaelt
    rechngNummer : D_RechngNummer;
    projNummer : D_ProjNummer;
    projAbrMonat : D_ProjAbrMonat;
    kundenName : D_KundenName;
    projAbrStundenSum : D_ProjAbrStundenSum;
    projAbrSumme : D_ProjAbrSumme;
    spesenBetragSum : D_SpesenBetragSum
end TW_Rechnung

T_Auswertungen in Traeger with
end T_Auswertungen

T_UmsatzListe in Traeger with
  enthaelt
    projAbrMonat : D_ProjAbrMonat;
    projNummer : D_ProjNummer;
    projAbrStundenSum : D_ProjAbrStundenSum;
    projAbrSumme : D_ProjAbrSumme;
    spesenBetragSum : D_SpesenBetragSum;
    kundenName : D_KundenName;
    projAbrGB : D_ProjAbrGB
end T_UmsatzListe

T_Kostensaetze in Traeger with
  enthaelt
    maName : D_MaName;
    kostenSatz : D_KostenSatz
end T_Kostensaetze

T_SonstKosten in Traeger with
  enthaelt
    sonstBetrag : D_SonstBetrag
end T_SonstKosten

T_Abwesenheit in Traeger with
  enthaelt
    maName : D_MaName;
    maUrlaub : D_MaUrlaub
end T_Abwesenheit

T_BuchungsListe in Traeger with
  enthaelt
    rechngNummer : D_RechngNummer;
    projNummer : D_ProjNummer;
    projAbrMonat : D_ProjAbrMonat
end T_BuchungsListe

T_Mahnung in Traeger with
  enthaelt
    rechngNummer : D_RechngNummer
end T_Mahnung

T_Auftrag in Traeger with
  enthaelt
    kundenName : D_KundenName;
    angebotsNummer : D_AngebotsNummer;
    auftragUnt : D_AuftragUnt
end T_Auftrag

T_Anfrage in Traeger with
  enthaelt
    kundenName : D_KundenName
end T_Anfrage

T_Angebot in Traeger with
  enthaelt
    kundenName : D_KundenName;
    angebotsNummer : D_AngebotsNummer;
    angebotsLeistung : D_AngebotsLeistung;
    angebotUntGL : D_AngebotUntGL
end T_Angebot

TF_Kalkulationsblatt in Traeger with
  enthaelt
    kundenName: D_KundenName;
    angebotsNummer : D_AngebotsNummer;
    angebotsLeistung : D_AngebotsLeistung;
    kalkStunden : D_KalkStunden;
    angebotsOk : D_AngebotsOk
end TF_Kalkulationsblatt

TF_ProjektAuftrag in Traeger with
  enthaelt
    projNummer : D_ProjNummer;
    kundenName : D_KundenName;
    plName : D_PlName;
    projSollStunden : D_ProjSollStunden
end TF_ProjektAuftrag

TF_ProjektAuftragMa in Traeger with
  enthaelt
    projNummer : D_ProjNummer;
    kundenName : D_KundenName;
    plName : D_PlName;
    maName : D_MaName;
    projSollStunden : D_ProjSollStunden;
    projAuftPlUnt : D_ProjAuftPlUnt
end TF_ProjektAuftragMa

TF_ProjektAnlage in Traeger with
  enthaelt
    projNummer : D_ProjNummer;
    kundenName : D_KundenName;
    angebotsLeistung : D_AngebotsLeistung;
    projSollStunden : D_ProjSollStunden
end TF_ProjektAnlage

TF_ProjektAbschluss in Traeger
end TF_ProjektAbschluss

T_ProjektOrdner in Traeger
end T_ProjektOrdner

T_SollProjektListe in Traeger with
  enthaelt
    projNummer : D_ProjNummer;
    projAbrMonat : D_ProjAbrMonat;
    maName : D_MaName;
    kostenSatz : D_KostenSatz
end T_SollProjektListe

TX_Halbfertige in Traeger with
  enthaelt
    projNummer : D_ProjNummer;
    projAbrMonat : D_ProjAbrMonat;
    halbFertigSumme : D_HalbFertigSumme;
    halbFertigRestaufwand : D_HalbFertigRestaufwand
end T_Halbfertige

TX_SpesenRechnung in Traeger with
  enthaelt
    spesenBetrag : D_SpesenBetrag;
    spesenBetragNetto : D_SpesenBetragNetto
end TX_SpesenRechnung

TX_Probat in Traeger with
  enthaelt
    projNummer : D_ProjNummer;
    plName : D_PlName;
    projSollStunden : D_ProjSollStunden;
    projAbrLeistung : D_ProjAbrLeistung;
    projAbrStundenSum : D_ProjAbrStundenSum;
    projAbrSpesVorOrt : D_ProjAbrSpesVorOrt;
    projAbrMonat : D_ProjAbrMonat;
    spesenBetragNetto : D_SpesenBetragNetto;
    sonstBetrag : D_SonstBetrag;
    maName : D_MaName;
    kundenName: D_KundenName;
    projAbrGesStdSum : D_ProjAbrGesStdSum;
    projAbrSpesenSum : D_ProjAbrSpesenSum;
    monIntStundenSum : D_MonIntStundenSum;
    monIntSpesenSum : D_MonIntSpesenSum
end TX_Probat

TX_Fibu in Traeger with
  enthaelt
    rechngNummer : D_RechngNummer;
    bezahlt : D_Bezahlt;
    monZusSpesen : D_MonZusSpesen;
    projAbrMonat : D_ProjAbrMonat;
    maName : D_MaName
end TX_Fibu

T_SpesenZahlung in Traeger with
  enthaelt
    projAbrMonat : D_ProjAbrMonat;
    maName : D_MaName;
    monZusSpesen : D_MonZusSpesen
end TX_SpesenZahlung

T_OpListe in Traeger with
  enthaelt
    rechngNummer : D_RechngNummer
end T_OpListe

TX_Perbit in Traeger with
  enthaelt
    maName : D_MaName;
    kostenSatz : D_KostenSatz;
    perbitUrlaub : D_PerbitUrlaub;
    perbitSchulung : D_PerbitSchulung
end TX_Perbit

T_Zahlung in Traeger with
  enthaelt
    rechngNummer : D_RechngNummer
end T_Zahlung

T_KorrekturGespraech in Traeger with
  enthaelt
    korrekturInfo : D_KorrekturInfo
end T_KorrekturGespraech

TX_LUG in Traeger with
  enthaelt
    maName : D_MaName;
    perbitUrlaub : D_PerbitUrlaub;
    monIntStundenSum : D_MonIntStundenSum
end TX_LUG

T_VersNachweis in Traeger with
  enthaelt
    monIntStundenSum : D_MonIntStundenSum 
end T_VersNachweis

