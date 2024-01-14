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
* File InverseOf.sml
* Author: Manfred Jeusfeld, jeusfeld@uvt.nl
* Date: 9-Dec-2003 (6-Dec-2004)
*----------------------------------------------------------------
* This example shows how to declare an attribute to
* be inverse of some other attribute.
* For example, 'hasParticipant' is the inverse of
* the 'participates' attribute.
*
* Requires ConceptBase 6.2 released 5-Dec-2004 or later.
*
* (c) 2003-2004 by M. Jeusfeld. Do not use without proper reference
* to the author!
*
*}



{* The link ' isInverseOf' shall be used to   *}
{* declare some attribute B to be the inverse *}
{* of some other attribute A.                 *}

Proposition!attribute with
  attribute
    isInverseOf: Proposition!attribute
end


InverseSemantics in Class with
  rule
   invR1: $ forall x,y,MA,MB/VAR 
                   A,B/Proposition!attribute 
                   C,D/Proposition
                   (B isInverseOf A) and
                   P(A,C,MA,D) and P(B,D,MB,C) and 
                   (x in C) and (y in D) and 
                   (x MA y) ==> (y MB x) $
end


{* Example *}

{* first we declare two attributes *}

Person with
  attribute
    participates: Meeting
end

Meeting with
  attribute
    hasParticipant: Person
end

{* then we declare the hasParticipant (MB) to be the inverse
   of participant (MA) *}

Meeting!hasParticipant with
  isInverseOf
    origattribute: Person!participates
end

{* Note: 'hasParticipant' is the derived attribute *}



{* some example data to test whether everything went fine: *}

john in Person with
  participates m1: MeetingOnTaxes
end

bill in Person with 
  participates
    m1: MeetingOnMarketing;
    m2: MeetingOnTaxes
end

mary in Person with
  participates m1: MeetingOnTaxes
end

MeetingOnMarketing in Meeting end
MeetingOnTaxes in Meeting end


{* a query to test hasParticipant *}

MeetingWithParticipants in QueryClass isA Meeting with 
  computed_attribute
    pers: Person
  constraint
    c: $ (~this hasParticipant ~pers) $
end


