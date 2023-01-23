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
{*
* File: iterations.sml
* Author: Manfred A. Jeusfeld, Tilburg University
* Date: 2-Aug-2001
* --------------------------------------------------------
* here: use of Foreach
*}


Class Person with 
  attribute
    parent: Person;
    age: Integer
end

{* a simple query class *}

QueryClass PersonWithParents3 isA Person with
  retrieved_attribute
     parent: Person;
     age: Integer
   constraint
     c1: $ exists a/Integer (~this age a) and (a > 10) $
end


{* answer format using Foreach *}

AnswerFormat PersonFormat3 with
   forQuery q: PersonWithParents3
   order o: ascending
   orderBy ob: "this"
   head h: 
"<html>These are the persons together with their parents:
<OL>
"
  pattern p:
"<LI> {this} is {this.age} years old {Foreach( ({this.parent},{this|parent}),(p,r), and {p} is {r} of {this})}.
"
  tail t: "</OL>"
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




  
