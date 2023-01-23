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
GenericQueryClass NieBeliefert isA Akteur with
  constraint
     c1 : $
  not exists a/Akteur (a beliefert this)
  $
end

GenericQueryClass BeliefertKeinen isA Akteur with
  constraint
     c1 : $
  not exists a/Akteur (this beliefert a)
  $
end

GenericQueryClass BeliefertSich isA Akteur with
  computed_attribute
    sich : Akteur!beliefert
  constraint
     c1 : $
  To(~sich, this) and From(~sich, this)
  $
end


{* schlechter *}
GenericQueryClass BeliefernEinander isA Akteur with
  computed_attribute
    sich1 : Akteur!beliefert;
    sich2 : Akteur!beliefert
  constraint
     c1 : $
       exists a/Akteur not (a == this)
   and To(~sich1, this) and From(~sich1, a)
   and To(~sich2, a) and From(~sich2, this)
  $
end

GenericQueryClass BeliefertOneWay isA Akteur with
  computed_attribute
    von : Akteur!beliefert
  constraint
     c1 : $
       exists a/Akteur not (a == this)
   and To(~von, this) and From(~von, a)
   and not (this beliefert a)
  $
end

GenericQueryClass WirdMehrfachBeliefert isA Akteur with
  computed_attribute
    sich1 : Akteur!beliefert
  constraint
     c1 : $
       exists a/Akteur sich2/Akteur!beliefert
       not (~sich1 == sich2)
   and To(~sich1, this) and To(sich2, this)
   and From(~sich1, a) and From(sich2, a)
  $
end

