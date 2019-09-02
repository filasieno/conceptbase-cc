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
{*
* File: simple_answerformats2.sml
* Author: Manfred A. Jeusfeld, Tilburg University
* Date: 1-Aug-2001
* --------------------------------------------------------
* shows how simple answer formats can be constructed.
* here: use of this|attribute_cat
*}


Class Person with
  attribute
    parent: Person;
    age: Integer
end

{* a simple query class *}

QueryClass PersonWithParents2 isA Person with
  retrieved_attribute
     parent: Person;
     age: Integer
   constraint
     c1: $ exists a/Integer (~this age a) and (a > 10) $
end


{* a simple ASCII-based answer format *}
AnswerFormat PersonFormat2 with
   forQuery q: PersonWithParents2
   order o: ascending
   orderBy ob: "this"
   head h:
"<html>These are the persons together with their parents:
<OL>
"
  pattern p:
"<LI> {this} is {this.age} years old. Parents of {this} are {this.parent} by using labels {this|parent}.
"
  tail t:
"</OL> That's the whole story about persons and parents!"
end




{* a database for the example *}

Person Mary with
  age a: 14
  parent mother: Charlotte;
         father: Frederic
end

Person Charlotte with
  age a: 34
  parent father: Albert
end

Person Frederic end

Person Albert end

Person Bill with
  age a: 16
  parent mother: Charlotte;
         stepfather: John;
         father: Albert
end

Person John with
 age a: 43
end





