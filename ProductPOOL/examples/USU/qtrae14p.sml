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


GenericQueryClass P_TraegerAusgabe isA Aktion with
  parameter
    t1 : Traeger
  computed_attribute
    geschrieben : Daten
  constraint
     c1 : $
      exists t/Traeger!enthaelt (this ausgabe t) 
  and From(t,~t1) 
  and To(t,~geschrieben)
  $
end 

GenericQueryClass P_TraegerEingabe isA Aktion with
  parameter
    t1 : Traeger
  computed_attribute
    gelesen : Daten
  constraint
     c1 : $
      exists t/Traeger!enthaelt (this eingabe t) 
  and From(t,~t1) 
  and To(t,~gelesen)
  $
end

GenericQueryClass P_TraegerGefuelltIn isA Daten with
  parameter
     t1 : Traeger;
     a1 : Aktion
  constraint
     c1 : $
  (~t1 enthaelt this)
  and exists t/Traeger!enthaelt From(t,~t1) and To(t,this)
  and exists a/Aktion ((~a1 transFolgtAuf a) or (a == ~a1)) 
  and (a ausgabe t) 
  $
end 
 
GenericQueryClass P_TraegerNichtGefuelltIn isA Daten with
  parameter
     t1 : Traeger;
     a1 : Aktion
  constraint
     c1 : $
  (~t1 enthaelt this)
  and not exists t/Traeger!enthaelt From(t,~t1) and To(t,this)
  and exists a/Aktion ((~a1 transFolgtAuf a) or (a == ~a1)) 
  and (a ausgabe t) 
  $
end

GenericQueryClass P_AlleTraegerGefuelltIn isA Traeger with
  parameter
     a1 : Aktion
  computed_attribute
     eingetragen : Daten
  constraint
     c1 : $
    ((~a1 gibt this) or (~a1 nimmt this) or 
     (exists q/Traeger!enthaelt From(q,this) and ((~a1 ausgabe q)
        or (~a1 eingabe q)))) and
    (this enthaelt ~eingetragen)
  and exists t/Traeger!enthaelt From(t,this) and To(t,~eingetragen)
  and exists a/Aktion ((~a1 transFolgtAuf a) or (a == ~a1)) 
  and (a ausgabe t)
  $
end 
 
GenericQueryClass P_AlleTraegerNichtGefuelltIn isA Traeger with
  parameter
     a1 : Aktion
  computed_attribute
     eingetragen : Daten
  constraint
     c1 : $
    ((~a1 gibt this) or (~a1 nimmt this) or 
     (exists q/Traeger!enthaelt From(q,this) and ((~a1 ausgabe q)
        or (~a1 eingabe q)))) and
    (this enthaelt ~eingetragen)
  and not exists t/Traeger!enthaelt From(t,this) and To(t,~eingetragen)
  and exists a/Aktion ((~a1 transFolgtAuf a) or (a == ~a1)) 
  and (a ausgabe t)
  $
end 


