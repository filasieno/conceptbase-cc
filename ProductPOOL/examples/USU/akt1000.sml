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

P_1010 in Aktion with
  bearbeitet_von
    wer : A_Personal
  folgt_auf
    pVon : P_START
  nimmt
    nimm_1 : TX_LUG;
    nimm_2 : TX_Perbit
  gibt
    gib_1 : T_Kostensaetze
  input
    in_1 : D_MaName
  eingabe
    ein_1 : TX_LUG!maName;
    ein_2 : TX_Perbit!maName
  output
    out_1 : D_KostenSatz;
    out_2 : D_MaName
  ausgabe 
    aus_1 : T_Kostensaetze!kostenSatz;
    aus_2 : T_Kostensaetze!maName
end P_1010

P_1020 in Aktion with
  bearbeitet_von
    wer : A_GL
  folgt_auf
    pVon : P_1010
  nimmt
    nimm_1 : T_Kostensaetze
  gibt
    gib_1 : T_Kostensaetze
  input
    in_1 : D_MaName;
    in_2 : D_KostenSatz
  eingabe
    ein_1 : T_Kostensaetze!maName;
    ein_2 : T_Kostensaetze!kostenSatz
  output
    out_1 : D_KostenSatz
  ausgabe 
    aus_1 : T_Kostensaetze!kostenSatz
end P_1020

P_1030 in Aktion with
  bearbeitet_von
    wer : A_Personal
  folgt_auf
    pVon : P_1020
  nimmt
    nimm_1 : T_Kostensaetze
  gibt
    gib_1 : T_Kostensaetze;
    gib_2 : TX_Perbit;
    gib_3 : T_SollProjektListe
  input
    in_1 : D_MaName;
    in_2 : D_KostenSatz
  eingabe
    ein_1 : T_Kostensaetze!maName;
    ein_2 : T_Kostensaetze!kostenSatz
  ausgabe
    aus_1 : TX_Perbit!maName;
    aus_2 : TX_Perbit!kostenSatz;
    aus_3 : T_SollProjektListe!maName;
    aus_4 : T_SollProjektListe!kostenSatz
end P_1030

