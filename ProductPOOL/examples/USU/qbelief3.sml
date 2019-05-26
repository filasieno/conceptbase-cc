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
GenericQueryClass AkteurBelieferung isA Akteur with
  computed_attribute
    bekommt : Traeger
  constraint
     c1 : $
  exists a/Akteur!beliefert To(a, this)
  and (a mit ~bekommt)
  $
end

GenericQueryClass BeliefernEinanderMit isA Akteur with
  computed_attribute
    wer : Akteur;
    was : Traeger
  constraint
     c1 : $
      not (~wer == this)
  and exists q1,q2/Akteur!beliefert
          To(q1, this) and From(q1, ~wer)
      and To(q2, ~wer) and From(q2, this)
      and exists t1,t2/Akteur!beliefert!mit
              From(t1, q1) and To(t1, ~was)
          and From(t2, q2) and To(t2, ~was)
  $
end

GenericQueryClass BeliefertMitNichts
isA Akteur!beliefert with
  constraint
    c1 : $
  not exists t/Traeger (this mit t)
  $
end

GenericQueryClass UngelieferteTraeger isA Traeger with
  constraint
    c1 : $
  not exists x/Akteur!beliefert (x mit this)
  $
end

