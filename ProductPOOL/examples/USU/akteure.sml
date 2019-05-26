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

A_Kundenverantwortlicher in Akteur with
  erzeugt 
    vb_erzeugt_1 : T_Angebot;
    vb_erzeugt_2 : TF_ProjektAuftrag;
    vb_erzeugt_3 : TF_Kalkulationsblatt
  braucht
    vb_braucht_1 : T_Anfrage;
    vb_braucht_2 : T_Auftrag
  beliefert
    vb_bietet_an : A_Kunde;
    vb_beauftragt : A_Projektleiter;
    vb_verifiziert : A_GL
end A_Kundenverantwortlicher

A_Kundenverantwortlicher!vb_bietet_an with
  mit
    vb_bietet_an : T_Angebot
end A_Kundenverantwortlicher!vb_bietet_an

A_Kundenverantwortlicher!vb_beauftragt with
  mit
    vb_beauftragt : TF_ProjektAuftrag;
    vb_kalkuliert : TF_Kalkulationsblatt
end A_Kundenverantwortlicher!vb_beauftragt

A_Kundenverantwortlicher!vb_verifiziert with
  mit
    vb_verifiziert_1 : T_Angebot;
    vb_verifiziert_2 : TF_Kalkulationsblatt
end A_Kundenverantwortlicher!vb_verifiziert

A_Kunde in Akteur with
  erzeugt 
    kd_erzeugt_1 : T_Anfrage;
    kd_erzeugt_2 : T_Auftrag;
    kd_erzeugt_3 : T_Zahlung
  braucht
    kd_braucht_1 : T_Angebot;
    kd_braucht_2 : T_Rechnung;
    kd_braucht_3 : T_SpesenBeleg;
    kd_braucht_4 : T_SonstKosten;
    kd_braucht_5 : TF_ProjektAbrechnung;
    kd_braucht_6 : T_Mahnung
  beliefert
    kd_anfragt : A_Kundenverantwortlicher;
    kd_beauftragt : A_Kundenverantwortlicher;
    kd_bezahlt : A_Buchhalt
end A_Kunde

A_Kunde!kd_anfragt with
  mit
    kd_fragt_an : T_Anfrage
end A_Kunde!kd_anfragt
    
A_Kunde!kd_beauftragt with
  mit
    kd_beauftragt : T_Auftrag
end A_Kunde!kd_beauftragt
 
A_Kunde!kd_bezahlt with
  mit
    kd_bezahlt : T_Zahlung
end A_Kunde!kd_bezahlt

A_KundenPl in Akteur with
  erzeugt 
    kd_erzeugt_1 : TF_ProjektAbrechnung
  braucht
    kd_braucht_1 : TF_ProjektAbrechnung
  beliefert
    kd_bestaetigt : A_Projektleiter
end A_KundenPl

A_KundenPl!kd_bestaetigt with
  mit
    kd_bestaetigt : TF_ProjektAbrechnung
end A_KundenPl!kd_bestaetigt
 
A_ProjContrl in Akteur with
  erzeugt 
    pc_erzeugt_1 : T_Rechnung;
    pc_erzeugt_2 : T_Auswertungen;
    pc_erzeugt_3 : T_Mahnung;
    pc_erzeugt_4 : TF_MonatsBericht;
    pc_erzeugt_5 : T_SpesenBeleg;
    pc_erzeugt_6 : T_SonstKosten;
    pc_erzeugt_7 : TF_MonZus;
    pc_erzeugt_8 : T_Abwesenheit;
    pc_erzeugt_9 : T_BuchungsListe;
    pc_erzeugt_10 : TF_ProjektAbrechnung;
    pc_erzeugt_11 : TF_ProjektAuftrag;
    pc_erzeugt_12 : TF_ProjektAuftragMa;
    pc_erzeugt_13 : TF_ProjektAnlage
  braucht
    pc_braucht_1 : TF_StatusBericht;
    pc_braucht_2 : TF_ProjektAbrechnung;
    pc_braucht_3 : TF_MonatsBericht;
    pc_braucht_4 : T_SpesenBeleg;
    pc_braucht_5 : T_Kostensaetze;
    pc_braucht_6 : T_SonstKosten;
    pc_braucht_7 : TF_ProjektAnlage;
    pc_braucht_8 : T_Abwesenheit;
    pc_braucht_9 : TF_MonZus;
    pc_braucht_10 : TF_Kalkulationsblatt;
    pc_braucht_11 : T_OpListe;
    pc_braucht_12 : TF_ProjektAuftrag;
    pc_braucht_13 : TF_ProjektAuftragMa
  beliefert
    pc_stellt_rechnung : A_Kunde;
    pc_kopiert_rechnung : A_Buchhalt;
    pc_informiert : A_GL;
    pc_mahnt : A_Kunde;
    pc_gibt_weiter : A_Personal;
    pc_projektstart : A_Projektleiter;
    pc_ablage : A_Buchhalt
end A_ProjContrl

A_ProjContrl!pc_stellt_rechnung with
  mit
    pc_stellt_1 : T_Rechnung;
    pc_stellt_2 : TF_ProjektAbrechnung;
    pc_stellt_3 : T_SpesenBeleg
end A_ProjContrl!pc_stellt_rechnung
 
A_ProjContrl!pc_kopiert_rechnung with
  mit
    pc_kopiert : T_BuchungsListe
end A_ProjContrl!pc_kopiert_rechnung
 
A_ProjContrl!pc_informiert with
  mit
    pc_informiert : T_Auswertungen
end A_ProjContrl!pc_informiert
 
A_ProjContrl!pc_mahnt with
  mit
    pc_mahnt : T_Mahnung
end A_ProjContrl!pc_mahnt

A_ProjContrl!pc_projektstart with
  mit
    pc_projektstart_1 : TF_ProjektAnlage;
    pc_projektstart_2 : TF_ProjektAuftrag;
    pc_projektstart_3 : TF_ProjektAuftragMa
end A_ProjContrl!pc_projektstart
  
A_ProjContrl!pc_gibt_weiter with
  mit
    pc_gibt_1 : TF_ProjektAbrechnung;
    pc_gibt_2 : T_SpesenBeleg;
    pc_gibt_3 : T_SonstKosten;
    pc_gibt_4 : T_Abwesenheit
end A_ProjContrl!pc_gibt_weiter
 
A_ProjContrl!pc_ablage with
  mit
    pc_ablage_1 : TF_MonatsBericht;
    pc_ablage_2 : T_SpesenBeleg;
    pc_ablage_3 : TF_MonZus;
    pc_ablage_4 : T_SonstKosten;
    pc_ablage_5 : TF_ProjektAbrechnung
end A_ProjContrl!pc_ablage
 
A_Personal in Akteur with
  erzeugt 
    pe_erzeugt_1 : TF_ProjektAbrechnung;
    pe_erzeugt_2 : TF_MonatsBericht;
    pe_erzeugt_3 : TF_MonZus;
    pe_erzeugt_4 : T_SpesenBeleg;
    pe_erzeugt_5 : T_KorrekturGespraech;
    pe_erzeugt_6 : T_Kostensaetze;
    pe_erzeugt_7 : T_SonstKosten
  braucht
    pe_braucht_2 : T_SpesenBeleg;
    pe_braucht_3 : T_SonstKosten;
    pe_braucht_4 : TF_MonatsBericht;
    pe_braucht_5 : TF_MonZus;
    pe_braucht_6 : TF_ProjektAbrechnung;
    pe_braucht_7 : T_Abwesenheit;
    pe_braucht_8 : T_Kostensaetze
  beliefert
    pe_gibt_weiter : A_Buchhalt;
    pe_korrigiert : A_ProjContrl;
    pe_verteilt : A_ProjContrl;
    pe_teilt_mit : A_Buchhalt;
    pe_sagt_bescheid : A_Mitarbeiter
end A_Personal

A_Personal!pe_gibt_weiter with
  mit
    pe_anbh_1 : TF_ProjektAbrechnung;
    pe_anbh_2 : TF_MonatsBericht;
    pe_anbh_3 : TF_MonZus;
    pe_anbh_4 : T_SpesenBeleg;
    pe_anbh_5 : T_SonstKosten
end A_Personal!pe_gibt_weiter
  
A_Personal!pe_korrigiert with
  mit
    pe_korrigiert : T_SpesenBeleg
end A_Personal!pe_korrigiert
 
A_Personal!pe_verteilt with
  mit
    pe_verteilt : T_Kostensaetze
end A_Personal!pe_verteilt
 
A_Personal!pe_sagt_bescheid with
  mit
    pe_sagt_bescheid : T_KorrekturGespraech
end A_Personal!pe_sagt_bescheid

A_Buchhalt in Akteur with
  erzeugt 
    bu_erzeugt_2 : T_SpesenZahlung;
    bu_erzeugt_3 : T_OpListe;
    bu_erzeugt_4 : T_SonstKosten;
    bu_erzeugt_5 : T_SpesenBeleg;
    bu_erzeugt_6 : TF_ProjektAbrechnung;
    bu_erzeugt_7 : TF_MonatsBericht;
    bu_erzeugt_8 : TF_MonZus
  braucht
    bu_braucht_1 : T_SpesenBeleg;
    bu_braucht_2 : T_BuchungsListe;
    bu_braucht_3 : T_SonstKosten;
    bu_braucht_4 : T_Zahlung;
    bu_braucht_5 : TF_ProjektAbrechnung;
    bu_braucht_6 : TF_MonatsBericht;
    bu_braucht_7 : TF_MonZus
  beliefert
    bu_abrechnung : A_ProjContrl;
    bu_offene_posten : A_ProjContrl;
    bu_zahlt_spesen : A_Mitarbeiter    
end A_Buchhalt

A_Buchhalt!bu_abrechnung with
  mit
    bu_abrechnung_1 : TF_ProjektAbrechnung;
    bu_abrechnung_2 : TF_MonatsBericht;
    bu_abrechnung_3 : TF_MonZus;
    bu_abrechnung_4 : T_SpesenBeleg;
    bu_abrechnung_5 : T_SonstKosten
end A_Buchhalt!bu_abrechnung
 
A_Buchhalt!bu_zahlt_spesen with
  mit
    bu_zahlt_spesen : T_SpesenZahlung
end A_Buchhalt!bu_zahlt_spesen
 
A_Buchhalt!bu_offene_posten with
  mit
    bu_offene_posten : T_OpListe
end A_Buchhalt!bu_offene_posten
 
A_Projektleiter in Akteur with
  erzeugt 
    pl_erzeugt_1 : TF_MonatsBericht;
    pl_erzeugt_2 : TF_MonZus;
    pl_erzeugt_3 : TF_ProjektAbrechnung;
    pl_erzeugt_4 : T_Abwesenheit;
    pl_erzeugt_5 : T_SpesenBeleg;
    pl_erzeugt_6 : TF_ProjektAuftrag;
    pl_erzeugt_7 : TF_ProjektAuftragMa;
    pl_erzeugt_8 : TF_ProjektAnlage;
    pl_erzeugt_9 : TF_StatusBericht;
    pl_erzeugt_10 : TF_Kalkulationsblatt
  braucht
    pl_braucht_1 : TF_ProjektAuftrag;
    pl_braucht_2 : TF_ProjektAuftragMa;
    pl_braucht_3 : TF_ProjektAbrechnung;
    pl_braucht_4 : T_Abwesenheit;
    pl_braucht_5 : T_SpesenBeleg;
    pl_braucht_6 : TF_ProjektAnlage;
    pl_braucht_7 : TF_Kalkulationsblatt
  beliefert
    pl_projektanlage : A_ProjContrl;
    pl_beauftragt : A_Mitarbeiter;
    pl_monatsbericht : A_Sekretariat;
    pl_projektabrechnung : A_ProjContrl;
    pl_nachweis : A_KundenPl
end A_Projektleiter

A_Projektleiter!pl_projektanlage with
  mit
    pl_projektanlage_1 : TF_ProjektAnlage;
    pl_projektanlage_2 : TF_Kalkulationsblatt;
    pl_projektanlage_3 : TF_ProjektAuftrag;
    pl_projektanlage_4 : TF_ProjektAuftragMa
end A_Projektleiter!pl_projektanlage
 
A_Projektleiter!pl_beauftragt with
  mit
    pl_beauftragt : TF_ProjektAuftragMa
end A_Projektleiter!pl_beauftragt
 
A_Projektleiter!pl_monatsbericht with
  mit
    pl_monatsbericht_1 : TF_MonatsBericht;
    pl_monatsbericht_2 : TF_MonZus;
    pl_monatsbericht_3 : T_SpesenBeleg;
    pl_monatsbericht_4 : T_Abwesenheit
end A_Projektleiter!pl_monatsbericht
 
A_Projektleiter!pl_projektabrechnung with
  mit
    pl_projabr_1 : TF_StatusBericht;
    pl_projabr_2 : TF_ProjektAbrechnung;
    pl_projabr_3 : T_SpesenBeleg;
    pl_projabr_4 : T_Abwesenheit
end A_Projektleiter!pl_monatsbericht
 
A_Projektleiter!pl_nachweis with
  mit
    pl_nachweis : TF_ProjektAbrechnung
end A_Projektleiter!pl_nachweis
 
A_PersVerantw in Akteur with
  erzeugt 
    pv_erzeugt_1 : TF_MonatsBericht;
    pv_erzeugt_2 : T_Abwesenheit;
    pv_erzeugt_3 : T_SpesenBeleg;
    pv_erzeugt_4 : TF_MonZus
  braucht
    pv_braucht_1 : TF_MonatsBericht;
    pv_braucht_2 : T_Abwesenheit;
    pv_braucht_3 : T_SpesenBeleg;
    pv_braucht_4 : TF_MonZus
  beliefert
    pv_monatsbericht : A_Personal
end A_PersVerantw

A_PersVerantw!pv_monatsbericht with
  mit
    pv_monatsbericht_1 : TF_MonatsBericht;
    pv_monatsbericht_2 : T_SpesenBeleg;
    pv_monatsbericht_3 : T_Abwesenheit;
    pv_monatsbericht_4 : TF_MonZus     
end A_PersVerantw!pv_monatsbericht

A_Sekretariat in Akteur with
  braucht
    se_braucht_1 : TF_MonatsBericht;
    se_braucht_2 : TF_MonZus;
    se_braucht_3 : T_Abwesenheit;
    se_braucht_4 : T_SpesenBeleg
  erzeugt
    se_erzeugt_1 : TF_MonatsBericht;
    se_erzeugt_2 : TF_MonZus;
    se_erzeugt_3 : T_Abwesenheit;
    se_erzeugt_4 : T_SpesenBeleg;
    se_erzeugt_5 : T_SonstKosten
  beliefert 
    se_gibt_weiter : A_PersVerantw;
    se_gibt_rechng : A_Buchhalt;
    se_gibt_sonst : A_ProjContrl
end A_Sekretariat
 
A_Sekretariat!se_gibt_weiter with
  mit
    se_monatsbericht_1 : TF_MonatsBericht;
    se_monatsbericht_2 : T_SpesenBeleg;
    se_monatsbericht_3 : T_Abwesenheit;
    se_monatsbericht_4 : TF_MonZus
end A_Sekretariat!se_gibt_weiter

A_Sekretariat!se_gibt_rechng with
  mit
    se_gibtrechng_1 : T_SonstKosten
end A_Sekretariat!se_gibt_rechng

A_Sekretariat!se_gibt_sonst with
  mit
    se_gibtsonst_1 : T_SonstKosten
end A_Sekretariat!se_gibt_sonst

A_Mitarbeiter in Akteur with
  erzeugt 
    ma_erzeugt_1 : TF_MonatsBericht;
    ma_erzeugt_2 : TF_MonZus;
    ma_erzeugt_3 : TF_ProjektAbrechnung;
    ma_erzeugt_4 : T_Abwesenheit;
    ma_erzeugt_5 : T_SpesenBeleg
  braucht
    ma_braucht_1 : TF_ProjektAuftragMa;
    ma_braucht_2 : T_SpesenZahlung;
    ma_braucht_3 : T_KorrekturGespraech
  beliefert
    ma_monatsbericht : A_Sekretariat;
    ma_projektabrechnung : A_Projektleiter
end A_Mitarbeiter

A_Mitarbeiter!ma_monatsbericht with
  mit
    ma_monatsbericht_1 : TF_MonatsBericht;
    ma_monatsbericht_2 : T_SpesenBeleg;
    ma_monatsbericht_3 : T_Abwesenheit;
    ma_monatsbericht_4 : TF_MonZus
end A_Mitarbeiter!ma_monatsbericht
 
A_Mitarbeiter!ma_projektabrechnung with
  mit
    ma_projektabr_1 : TF_ProjektAbrechnung;
    ma_projektabr_2 : T_SpesenBeleg;
    ma_projektabr_3 : T_Abwesenheit
end A_Mitarbeiter!ma_monatsbericht
 
A_GL in Akteur with
  braucht
    gl_braucht : T_Auswertungen
  erzeugt
    gl_erzeugt : T_Kostensaetze
  beliefert
    gl_bestimmt : A_Personal;
    gl_bestaetigt : A_Kundenverantwortlicher
end A_GL

A_GL!gl_bestimmt with
  mit
    gl_bestimmt : T_Kostensaetze
end A_GL!gl_bestimmt

A_GL!gl_bestaetigt with
  mit
    gl_bestaetigt_1 : T_Angebot;
    gl_bestaetigt_2 : TF_Kalkulationsblatt
end A_GL!gl_bestaetigt


