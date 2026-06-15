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


GenericQueryClass AktionenOhneEingabe isA Aktion with
  constraint
     c1 : $
  not exists t/Traeger!enthaelt (this eingabe t)
  $
end

GenericQueryClass AktionenOhneAusgabe isA Aktion with
  constraint
     c1 : $
  not exists t/Traeger!enthaelt (this ausgabe t)
  $
end

GenericQueryClass InputOhneEingabe isA Aktion with
  computed_attribute
    inDaten : Daten
  constraint
    c1 : $
    (not exists t/Traeger!enthaelt
        (this eingabe t) and To(t, ~inDaten))
    and  (this input ~inDaten)
  $
end

GenericQueryClass EingabeOhneInput isA Aktion with
  computed_attribute
    inDaten : Daten
  constraint
    c1 : $
   (exists t/Traeger!enthaelt
       (this eingabe t) and To(t, ~inDaten) )
   and not (this input ~inDaten)
  $
end

GenericQueryClass OutputOhneAusgabe isA Aktion with
  computed_attribute
    ausDaten : Daten
  constraint
    c1 : $
    (not exists t/Traeger!enthaelt
        (this ausgabe t) and To(t, ~ausDaten))
    and (this output ~ausDaten)
  $
end

GenericQueryClass AusgabeOhneOutput isA Aktion with
  computed_attribute
    ausDaten : Daten
  constraint
    c1 : $
   (exists t/Traeger!enthaelt
       (this ausgabe t) and To(t, ~ausDaten) )
   and not (this output ~ausDaten)
   and not (this input ~ausDaten)
  $
end

GenericQueryClass AusgabeOhneEingabe isA Aktion with
  computed_attribute
    ausDaten : Daten
  constraint
    c1 : $
   (exists t/Traeger!enthaelt
       (this ausgabe t) and To(t, ~ausDaten) )
   and not (this output ~ausDaten)
   and not (this input ~ausDaten)
   and not exists t2/Traeger!enthaelt
       (this eingabe t2) and To(t2, ~ausDaten)
  $
end

GenericQueryClass TraegerZuviel isA Aktion with
  computed_attribute
	nimmtTraeger : Traeger
  constraint
     c1 : $
          (this nimmt ~nimmtTraeger)
  and not exists d/Daten (~nimmtTraeger enthaelt d)
  and (this input d)
  and not exists t/Traeger (this nimmt t)
  and (not (~nimmtTraeger == t))
  and (t enthaelt d)
  $
end

