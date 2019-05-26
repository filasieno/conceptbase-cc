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

P_4010 in Aktion with
  bearbeitet_von
    wer : A_Buchhalt
  folgt_auf
    pVon : P_3250
  nimmt
    nimm_1 : T_BuchungsListe
  gibt
    gib_1 : TX_Fibu
  input
    in_1 : D_RechngNummer
  eingabe 
    ein_1 : T_BuchungsListe!rechngNummer
  ausgabe
    aus_1 : TX_Fibu!rechngNummer
end P_4010

P_4020 in Aktion with
  bearbeitet_von
    wer : A_Buchhalt
  folgt_auf
    pVon : P_4010
  nimmt
    nimm_1 : TX_Fibu
  gibt
    gib_1 : T_OpListe
  input
    in_1 : D_RechngNummer
  eingabe
    ein_1 : TX_Fibu!rechngNummer
  ausgabe
    aus_1 : T_OpListe!rechngNummer
end P_4020

P_4030 in Aktion with
  bearbeitet_von
    wer : A_ProjContrl
  folgt_auf
    pVon : P_4020
  nimmt
    nimm_1 : T_OpListe
  gibt
    gib_1 : T_Mahnung
  input
    in_1 : D_RechngNummer
  eingabe
    ein_1 : T_OpListe!rechngNummer
  ausgabe 
    aus_1 : T_Mahnung!rechngNummer
end P_4030

P_4040 in Aktion with
  bearbeitet_von
    wer : A_Kunde
  folgt_auf
    pVon_1 : P_4030;
    pVon_2 : P_3280
  nimmt
    nimm_1 : T_Rechnung;
    nimm_2 : T_Mahnung
  gibt
    gib_1 : T_Zahlung
  input
    in_1 : D_RechngNummer;
    in_2 : D_RechngUnt
  eingabe
    ein_1 : T_Rechnung!rechngNummer;
    ein_2 : T_Rechnung!rechngUnt
  ausgabe
    aus_1 : T_Zahlung!rechngNummer
end P_4040

P_4050 in Aktion with
  bearbeitet_von
    wer : A_Buchhalt
  folgt_auf
    pVon : P_4040
  nimmt
    nimm_1 : T_Zahlung
  gibt
    gib_1 : TX_Fibu
  input
    in_1 : D_RechngNummer
  output
    out : D_Bezahlt
  eingabe
    ein_1 : T_Zahlung!rechngNummer
  ausgabe
    aus_1 : TX_Fibu!bezahlt
end P_4050

P_ENDE with
  folgt_auf
    pVon_4050 : P_4050
end P_ENDE

