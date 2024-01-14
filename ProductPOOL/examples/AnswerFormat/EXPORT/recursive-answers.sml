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

{*
* File: recursive-answers.sml
* Author: Manfred Jeusfeld, jeusfeld@kub.nl
* Date: 2-Aug-2001
* Purpose: Shows how to have answers that contain recursively composed objects
*}


Class Person with
  attribute
    hasChild: Person
end



Person Adam with
  hasChild
    c1: Kain;
    c2: Abel;
    c3: Seth
end


Person Abel with
  hasChild
    c1: Abraham;
    c2: Lea
end

Person Abraham with
  hasChild
    c1: Isaak;
    c2: Ismael
end

Person Seth with
  hasChild
    c1: Lot
end

Person Kain with
end

Person Lea with
end

Person Isaak with
end

Person Ismael with
end

Person Lot with
end



View PersonQ isA Person with
  parameter
    p: Person
  inherited_attribute
    hasChild: Person
  constraint
    c: $ UNIFIES(~p,~this) $
end


AnswerFormat PersonLayout with
  forQuery fq: PersonQ
  order o: ascending
  orderBy ob: "this"
  head h : "<family>"
  pattern pt:
    "
    <person>{this}
      <children>
      {Foreach(({this.hasChild}),(s),{ASKquery(PersonQ[{s}/p],PersonLayout)})}
      </children>
    </person>
     "
  tail t: "</family>"
end



