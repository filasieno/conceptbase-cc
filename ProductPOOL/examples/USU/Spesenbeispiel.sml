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

Class Daten with
  attribute
    aggregiertVon: Daten;
    transAggregiertVon: Daten
  rule 
    transRule: $ forall d1,d2/Daten
                   ( (d1 aggregiertVon d2) or
                   (exists z/Daten 
                     (d1 aggregiertVon z) and (z transAggregiertVon d2)))
                  ==> (d1 transAggregiertVon d2) $
end

Class Entity with
  attribute
     abgebildetAus: Daten
end




Daten D_Spesenauszahlung with
  aggregiertVon
    teil_1: D_Spesensaetze
end

Daten D_Spesensaetze 
end

Daten D_Mitarbeiter with
  attribute
    istInProjekt: D_Projekt;
    istProjektLeiter: D_Projekt;
    erhaelt: D_Spesenauszahlung
end

Daten D_Projekt with
  attribute
    abgerechnetWann: D_ProjAbrMonat
end

Daten D_Spesenauszahlung with
  attribute
    abgerechnetWann: D_ProjAbrMonat
end

  

T_SpesenZahlung in Traeger with
  enthaelt
    spesenauszahlung: D_Spesenauszahlung
end


Aktion aendereSpesensaetze with
   bearbeitet_von
     akteur: A_Buchhalt
   output
     output_1: D_Spesensaetze
end

QueryClass QuerZugegriffen isA Daten with
  computed_attribute
     hauptDatum: Daten;
     querProzess: Aktion
  constraint
     c1: $ (~hauptDatum transAggregiertVon ~this) and
           (~querProzess output ~this) and
           not (~querProzess output ~hauptDatum) $
  comment
     kommentar1: "Es wird von einer Aktion auf ein Datum this
      zugegriffen, aber nicht auf das uebergeordnete hauptDatum,
      welches this mittelbar oder unmittelbar als Teil
      aggregiert"
end
  

Attribute A_Personal!pe_teilt_mit with
  comment
    kommentar1: "Mitteilung der Kostensaetze aus der Personalabteilung"
end

Daten D_ProjAbrGB with
  comment
    kommentar1: "Geschaeftsbereich, auf dem die Kosten und Umsaetze gebucht werden"
end


