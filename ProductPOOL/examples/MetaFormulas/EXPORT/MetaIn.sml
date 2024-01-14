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
{
*
* File: Meta-In.sml
* Author: Manfred Jeusfeld
* Creation: 2-Nov-2001 (14-Apr-2004)
* ----------------------------------------------------------------------
*
* This Telos model shows that we can define 'meta formulas' that actually define
* what a metaclass is: a class whose instances have themselves instances.
*
}


{* first: define an attribute category to relate token objects to their metaclasses *}

Token with
  attribute
     inMeta: MetaClass   {* shall mimic the (x [in] mc) predicate *}
end


{* The rule that derives the solutions for the new 'inMeta' construct *}
{* This rule is a meta formula: both (x in sc) and (sc in mc) are     *}
{* meta predicates since their second argument is a variable.         *}
{* Note that we utilize the builtin classes MetaClass, SimpleClass,   *}
{* and Token.                                                         *}
{* Otherwise, the meta formula compiler of ConceptBase would not have *}
{* specific ranges for the partial evaluation of (sc in mc) and       *}
{* (x in sc).                                                         *}


Class MetaClass with
  rule
    rim1: $ forall x/Token mc/MetaClass (exists sc/SimpleClass (x in sc) and (sc in mc))
              ==> (x inMeta mc) $
end


{* ********************************** *}
{* Application of the [in] predicate: *}
{* ********************************** *}

{* meta classes (notation level) }

EntityType in MetaClass with
  attribute
    ent_attr: Domain
end

Domain in MetaClass end


{* simple classes (model level) *}

Integer in SimpleClass,Domain end

Person in SimpleClass,EntityType with
  ent_attr
    salary: Integer
end

{* tokens (data level) *}

10000 in Token,Integer end
15000 in Token,Integer end
20000 in Token,Integer end

mary in Token,Person with
  salary s: 20000
end

bill in Token,Person with
  salary s: 15000
end

anne in Token,Person with
  salary s: 10000
end



{* a query that shows that our solution works *}

GenericQueryClass ShowMetaClasses isA MetaClass with
  parameter,computed_attribute
    obj: Token
  constraint
    c1: $ (~obj inMeta ~this) $
end
