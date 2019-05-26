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
* File: TransitiveClosureOf.sml
* Author: Manfred Jeusfeld, jeusfeld@uvt.nl
* Date: 10-Nov-2003 (6-Dec-2004)
*----------------------------------------------------------------
* This example shows how to declare an attribute to
* be the transitive clusure of some other attribute.
* For example, ancestor is the transitive closure of
* the 'parent' attribute.
*
* You can include the two first frames into your
* ConceptBase database. Then you can use the new
* feature 'isTransitiveClosureOf' whereever you
* need the transitive closure of an attribute.
*
* The difference to LinkSemantics2.sml is that there we
* define an attribute to be transitively closed. That
* makes it difficult to distinguish derived relations
* from the original relation.
*
* Requires ConceptBase 6.2 released 5-Dec-2004 or later.
*
* (c) 2003-2004 by M. Jeusfeld. Do not use without proper reference
* to the author!
*
*}



{* The link ' isTransitiveClosureOf' shall be used to    *}
{* declare some attribute B to be the transitive closure *}
{* of some attribute A.                                  *}

Proposition!attribute with
  attribute
    isTransitiveClosureOf: Proposition!attribute
end


MakeTransitiveSemantics1 in Class with
  rule
   transR1: $ forall x,y,MA,MB/VAR 
                     A,B/Proposition!attribute C/Proposition

                     (B isTransitiveClosureOf A) and
                     P(A,C,MA,C) and P(B,C,MB,C) and 
                     (x in C) and (y in C) and 
                     (x MA y) ==> (x MB y) $;

   transR2: $ forall x,y,z,MA,MB/VAR
                     A,B/Proposition!attribute C/Proposition

                     (B isTransitiveClosureOf A) and
                     P(A,C,MA,C) and P(B,C,MB,C) and
                     (x in C) and (y in C)  and (z in C) and 
                     (x MA z) and (z MB y) ==> (x MB y) $
end


{* Example *}

{* first we declare two attributes of the same class *}

Person with
  attribute
    hasParent: Person;
    hasAncestor: Person
end

{* then we declare the hasAncestor (MB) to be the transitive
   closure of hasParent (MA) *}

Person!hasAncestor with
  isTransitiveClosureOf
    baseattribute: Person!hasParent
end


{* this will generate the necessary rules from the above meta formulas *}
{* relax and enjoy the flawless execution                              *}



{* some example data to test whether everything went fine: *}

john in Person with
  hasParent a1: mary
end

bill in Person with 
end

mary in Person with
  hasParent p1: isabel
end

isabel in Person with
  hasParent a1: carl
end

carl in Person end
mary in Person end


{* a query to test whether hasAncestor is indeed computed correctly *}
{* you can ask this without providing a parameter                   *}

AncestorOf in GenericQueryClass isA Person with 
  parameter,computed_attribute
    pers: Person
  constraint
    c: $ (~pers hasAncestor ~this) $
end



