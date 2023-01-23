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
{**************************}
{*                        *}
{ File: ERSingNec         *}
{*                        *}
{**************************}

{* necessary constraint (metaformula) *}
Class with constraint
    necConstraint:
    $ forall c,d/Proposition p/Proposition!necessary x,m/VAR
            P(p,c,m,d) and (x in c) ==>
             exists y/VAR (y in d) and (x m y) $
end




{* every Entity has a key *}
Class EntityType with
  necessary
     keyeAttr : Domain
end


{* single constraint (metaformula) *}
Class with constraint
    singleConstraint :
    $ forall c,d/Proposition p/Proposition!single x,m/VAR
              P(p,c,m,d) and (x in c) ==>
                (
                  forall a1,a2/VAR
                    (a1 in p) and (a2 in p) and Ai(x,m,a1) and Ai(x,m,a2) ==>
                   (a1=a2)
                ) $
end

{* every Entity key is monovalued ( = necessary and single)*}
Class EntityType with rule
     keys_are_necessary:
        $forall a/EntityType!keyeAttr In(a,Proposition!necessary)$;
     keys_are_single:
        $forall a/EntityType!keyeAttr In(a,Proposition!single)$
end


