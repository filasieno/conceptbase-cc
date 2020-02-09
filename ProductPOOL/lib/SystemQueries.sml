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
GenericQueryClass find_instances in HiddenObject isA Proposition with
  required,parameter
     class : Proposition
  constraint,attribute
     r : $ (this in ~class) $
end


GenericQueryClass find_storeframes_instances in HiddenObject isA Proposition with
  required,parameter
     class : Proposition
  constraint,attribute
     r : $ (this in ~class) and (not
(this in MSFOLassertion)) and
(not (this in BDMConstraintCheck)) and
(not (this in BDMRuleCheck))$
end

GenericQueryClass ISINSTANCE in HiddenObject isA Boolean with
  required,parameter
     obj : Proposition;
     class : Proposition
  constraint,attribute
     c : $ ((~obj in ~class)==>(this == TRUE))and
    (not (~obj in ~class)==>(this == FALSE)) $
end

GenericQueryClass ISSUBCLASS  in HiddenObject isA Boolean with
  required,parameter
     sub : Proposition;
     super : Proposition
  constraint,attribute
     c : $ ((~sub isA ~super)==>(this == TRUE))and
    (not (~sub isA ~super)==>(this == FALSE)) $
end

GenericQueryClass find_iattributes in HiddenObject isA Attribute with
   required,parameter
     class : Proposition
   constraint
     r : $ To(this,~class) $
end

GenericQueryClass find_specializations in HiddenObject isA Proposition with
  required,parameter
     class : Proposition;
     ded : Boolean
  constraint
     r : $    (~ded == TRUE) and (this isA ~class)
           or (~ded == FALSE) and Isa_e(this,~class) $
end

{ Version management }
QueryClass AvailableVersions in HiddenObject isA Version with
computed_attribute
	time : TransactionTime
constraint
	c: $ exists x/Proposition P(x,~this,'*instanceof',Version) and Known(x,~time) $
end




{ Some queries for the Java-ObjectBase Interface }

GenericQueryClass find_incoming_links in HiddenObject isA Proposition with
   required,parameter
	objname : Proposition;
	category : Proposition
constraint
	c: $ To(this,~objname) and In(this,~category) $
end



GenericQueryClass find_incoming_links_simple in HiddenObject isA Proposition with
   required,parameter
	objname : Proposition
constraint
	c: $ To(this,~objname) $
end

GenericQueryClass find_outgoing_links in HiddenObject isA Proposition with
   required,parameter
	objname : Proposition;
	category : Proposition
constraint
	c: $ From(this,~objname) and In(this,~category) $
end



GenericQueryClass find_outgoing_links_simple in HiddenObject isA Proposition with
  required,parameter
	objname : Proposition
constraint
	c: $ From(this,~objname) $
end



{* 11-Oct-2004/M.Jeusfeld: extend find_classes to solve ticket #34; *}
{* find also query classes as classes of objname; we exclude        *}
{* generic query classes and builtin query classes since they       *}
{* would require too much computation time; this extension allows   *}
{* the 'instance of' menu of the graph editor to display also       *}
{* query classes under the sub-menu 'all'                           *}
{* 14-Oct-2008/M.Jeusfeld: also support the retrieval of query      *}
{* calls (ticket 194).                                              *}

GenericQueryClass find_classes in HiddenObject isA Proposition with
  required,parameter
	objname : Proposition
  constraint
    c : $ In(~objname,this) or
              (In_s(~this,QueryClass) and In(~objname,~this)) or
              (In_s(~this,QueryCall) and In(~objname,~this))$
end


GenericQueryClass find_explicit_classes in HiddenObject isA Proposition with
   required,parameter
	objname : Proposition
constraint
	c: $ In_s(~objname,this) $
end



GenericQueryClass find_explicit_instances in HiddenObject isA Proposition with
   required,parameter
	class : Proposition
constraint
	c: $ In_s(this,~class) $
end


GenericQueryClass find_generalizations in HiddenObject isA Proposition with
  required,parameter
     class : Proposition;
     ded : Boolean
  constraint
     r : $    (~ded == TRUE) and (~class isA this)
           or (~ded == FALSE) and Isa_e(~class,this) $
end

GenericQueryClass IS_EXPLICIT_INSTANCE in HiddenObject isA Boolean with
  required,parameter
     obj : Proposition;
     class : Proposition
  constraint,attribute
     c : $ (In_s(~obj,~class)==>(this == TRUE)) and
    (not In_s(~obj,~class)==>(this == FALSE)) $
end

GenericQueryClass IS_EXPLICIT_SUBCLASS  in HiddenObject isA Boolean with
  required,parameter
     sub : Proposition;
     super : Proposition
  constraint,attribute
     c : $ (Isa_e(~sub,~super)==>(this == TRUE)) and
    (not Isa_e(~sub,~super)==>(this == FALSE)) $
end





{ Special query and answer format to find the incoming attributes of an object.}
{ We need the full object here, so that the OBI can correctly create the attribute objects.}

GenericQueryClass find_referring_objects in HiddenObject isA Proposition with
  required,parameter
     class : Proposition
  attribute,constraint
     r : $ exists a/Attribute l/Label P(a,this,l,~class) $
end

AnswerFormat AF_find_referring_objects_obi  with
forQuery
        fq : find_referring_objects
head hd :""
pattern  p  : "{ASKquery(get_object[{this}/objname],FRAME)}"
tail tl : ""
end



GenericQueryClass IS_ATTRIBUTE_OF in HiddenObject isA Proposition with
   required,parameter
	src : Proposition;
	attrCat : Proposition;
	dst : Proposition
constraint
	c: $ exists l/Label Label(~attrCat,l) and A(~src,l,~dst) and UNIFIES(this,TRUE) $
end



GenericQueryClass IS_EXPLICIT_ATTRIBUTE_OF in HiddenObject isA Proposition with
   required,parameter
	src : Proposition;
	attrCat : Proposition;
	dst : Proposition
constraint
	c: $ exists l/Label Label(~attrCat,l) and A_e(~src,l,~dst) and UNIFIES(this,TRUE) $
end



{ Queries to get the links between two objects }
GenericQueryClass get_links2 in HiddenObject isA Proposition with
   required,parameter
    src : Proposition;
    dst : Proposition
constraint
    c : $ exists l/Label P(this,~src,l,~dst) $
end


GenericQueryClass get_links3 in HiddenObject isA Proposition with
   required,parameter
    src : Proposition;
    dst : Proposition;
    cat : Proposition
constraint
    c : $ exists l/Label P(this,~src,l,~dst) and (this in ~cat) $
end



GenericQueryClass find_all_explicit_attribute_values in HiddenObject isA Proposition with
  required,parameter
     objname : Proposition
  constraint
     r : $ exists x/Attribute l/Label P(x,~objname,l,this) $
end

GenericQueryClass find_referring_objects2 in HiddenObject isA Proposition with
  required,parameter
     objname : Proposition;
     cat : Attribute
  constraint
{*     r : $ exists a/Attribute l/Label P(a,this,l,~objname) and In(a,~cat) $ *}
     r : $ AeD(~cat,this,~objname) $
end

GenericQueryClass find_all_referring_objects2 in HiddenObject isA Proposition with
  required,parameter
     objname : Proposition;
     cat : Attribute
  attribute,constraint
{*     r : $ exists l/Label Label(~cat,l) and A(this,l,~objname) $ *}
     r : $ AD(~cat,this,~objname) $
end

{* 27-Aug-2007: M.Jeusfeld; attributes that have formulas as values can never be *}
{* attribute categories; follow-up of change [7808] and ticket #145              *}

GenericQueryClass find_attribute_categories in HiddenObject isA Attribute with
  required,parameter
     objname : Proposition
  attribute,constraint
     r : $ (exists c,d/Proposition l/Label In(~objname,c) and P(this,c,l,d) and not(UNIFIES(c,Proposition)) and
 not (In(d,MSFOLassertion) or In(d,BDMRuleCheck) or In(d,BDMConstraintCheck))) or UNIFIES(this,Attribute) $
end

{* AD is an internal predicate not documented to normal CB users; It works like Adot(cc,x,y) *}
{* but does not require that cc is bound.                                                    *}
GenericQueryClass find_used_attribute_categories in HiddenObject isA Attribute with
  required,parameter
    objname : Proposition
attribute,constraint
    r : $  exists x/Proposition AD(this,~objname,x) and 
                (this <> Class!rule) and (this <> Class!constraint) and 
                (this <> Proposition!applyConstraintIfInsert) and (this <> Proposition!applyConstraintIfDelete) and 
                (this <> Proposition!applyRuleIfInsert) and (this <> Proposition!applyRuleIfDelete) and 
                (this <> Proposition!deducedBy) $
end

GenericQueryClass find_attribute_values in HiddenObject isA Proposition with
  required,parameter
     objname : Proposition;
     cat : Attribute
  attribute,constraint
{*     r : $ exists l/Label Label(~cat,l) and A(~objname,l,this) $ *}
     r : $ AD(~cat,~objname,this) $
end

GenericQueryClass find_explicit_attribute_values in HiddenObject isA Proposition with
  required,parameter
     objname : Proposition;
     cat : Attribute
  attribute,constraint
{*      r : $ exists x/Attribute l/Label P(x,~objname,l,this) and In(x,~cat) $ *}
     r : $ AeD(~cat,~objname,this) $
end

GenericQueryClass find_incoming_attribute_categories in HiddenObject isA Attribute with
  required,parameter
     objname : Proposition
  attribute,constraint
     r : $ (exists c,d/Proposition l/Label In(~objname,c) and P(this,d,l,c) and not(UNIFIES(c,Proposition))) or UNIFIES(this,Attribute) $
end

{* see also find_used_attribute_categories *}
GenericQueryClass find_used_incoming_attribute_categories in HiddenObject isA Attribute with
   required,parameter
    objname : Proposition
attribute,constraint
    r : $  exists x/Proposition AD(this,x,~objname)  $
end


GenericQueryClass find_object in HiddenObject isA Proposition with
  required,parameter
     objname : Proposition
  attribute,constraint
     r : $ UNIFIES(this,~objname) $
   comment
     c: "Similar to get_object, but just returns the object (used by JavaGraphBrowser)"
end

