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
*
* File:        Module.sml
* Version:     1.0
* Creation:    22-May-1996 Lutz Bauer, RWTH
* Last Change: 27-Jan-2014, Manfred Jeusfeld, Uni Skoevde
* Release:     
* -----------------------------------------------------------------------------
*
* This is the model for the Module Framework of ConceptBase
* It originates from the PhD thesis of Hans Nissen.
*
*
*}

Individual Module in Class with 
  attribute
     imports  :  Module;
     exports  :  Proposition;
     contains :  Proposition
end 


Individual System in Module 
end 

{* oHome is the default home module of client enrolling to ConceptBase *}
Individual oHome in Module 
end 



{* 1-Oct-2003/M.Jeusfeld: add user's and their so-called home modules *}
{* Home module of a user is the module that s/he will be assigned to  *}
{* when enrolling to the ConceptBase server. This makes management of *}
{* multiple concurrent users a lot easier.                            *}
{* This is much like a home directory.                                *}
{* 9-Feb-2004/M.Jeusfeld: profileTag is a facility to attach any      *}
{* number of user profile information tags to a CB_User. Rather than  *}
{* an extensive Telos model for user profiles, we pack everything into*}
{* this LDAP-like structure. Can be used by CBserver tp check any     *}
{* type of authorization of a ConceptBase user.                       *}

Individual CB_User with 
  attribute
    homeModule: Module;
    profileTag: String
end


{* Auto home module are such modules which force new users into automatically *}
{* created sub-modules of the auto home module.                               *}
{* This rule is overridden for the 'exception users'. These users are not     *}
{* forced downwards.                                                          *}
{* This is useful for letting a group of users work on the same CBserver on   *}
{* a given module without interference.                                       *}

AutoHomeModule isA Module with
  attribute
   exception: CB_User
end


{* 19-Feb-2004/M.Jeusfeld: rudimentary rights management model enforced at  *}
{* CBserverInterface.pro                                                    *}
{* Actual right rules are to be defined by users!                           *}

Resource with end   {* a resource is anything subject to access rights      *}
Module isA Resource end  {* modules are good examples of resources          *}

CB_Operation end    {* any operation (ipcmessage, query,...) we want to monitor   *}
CB_ReadOperation isA CB_Operation end  {* at least we distinguish read from write *}
CB_WriteOperation isA CB_Operation end

{* list of read/write operations of the CBserverInterface, as of 20-Feb-2004 *}
TELL in CB_WriteOperation end
TELL_MODEL in CB_WriteOperation end
UNTELL in CB_WriteOperation end
RETELL in CB_WriteOperation end
LPI_CALL in CB_WriteOperation end

ASK in CB_ReadOperation end  
HYPO_ASK in CB_ReadOperation end  


{* builtin module listing; M. Jeusfeld/26-Jan-2011 *}
listModule in BuiltinQueryClass with
  parameter
     module: Module
end

IsolatedValue in HiddenObject,GenericQueryClass isA Proposition with
  parameter
    type: BuiltinClass
  constraint
    isoC: $ 
              (:(~this in ~type): and
                      not (exists y/Proposition (~this attribute y)) and 
                      not (exists c/Proposition In_s(~this,c) and (c <> ~type) and
                                                (c <> Proposition) and (c <> Individual) ))
          $
end


{* used for listModule; see also ConfigurationUtilities.pro *}
DoNotSave_LM in QueryClass isA Proposition with
   constraint cnts: $ (~this in HiddenObject) or
                      ((~this in MSFOLassertion) and not (~this in QueryClass)) or
                      (~this in BDMRuleCheck) or
                      (~this in BDMConstraintCheck) or (~this in Proposition!deducedBy) or
                      (~this in Proposition!applyConstraintIfInsert) or (~this in Proposition!applyConstraintIfDelete) or
                      (~this in ECAassertion) or ( not (~this in Individual) and
                      (forall x/Proposition ((~this attribute x) ==> (x in DoNotSave_LM)) and not Isa_e(~this,x))) or
                      ( (~this in IsA) and exists a/Attribute From(~this,a) and 
                        ((a in QueryClass!retrieved_attribute) or (a in View!inherited_attribute))) or
                      (~this in IsolatedValue[String/type]) or
                      (~this in IsolatedValue[Integer/type]) or
                      (~this in IsolatedValue[Real/type]) or

                      :(~this in TransactionTime): and not (exists z/Proposition (~this attribute z))
                      $
end







{* for saving query answers in the file system *}
Module with 
  attribute
     saveView: QueryClass
end 

AnswerFormat with
  attribute
    fileType: String  {* preferred file type for saved query answers, e.g. "xml" *}
end





{* ===================================== *}
{* additional system objects follow here *}
{* without being necessarily related to  *}
{* 'Module'.                             *}
{* ===================================== *}

Function toLabel isA Individual with  
attribute,parameter
    s : String
attribute,comment
    c : "returns s as a label without quotes and special character and creates it as individual object"
end 


Function concat isA String with
parameter
	s1 : String;
	s2 : String
comment
	c : "Appends string s2 to the end of string s1; same as ConcatenateStrings"
end

DoNotSave_LM in HiddenObject end
rename in HiddenObject end
changeAttributeValue in HiddenObject end


{* immutable attributes are like ordinary attributes but they are supposed to be defined
   only once together with their source objects and then remain unchanged; 
*}
Proposition with
  attribute
    immutable: Proposition
end



{* give ISA links a white head, similar to UML specialization links; ticket #382*}
DefaultIsAGT with  
  property
    edgeheadcolor : "255,255,255"  
end 
ImplicitIsAGT with  
  property
    edgeheadcolor : "255,255,255"  
end 



{* any object can have its own graphical properties, augmenting the properties of its graphtype
   ticket #397; we allow the value to be any Proposition (strings, numbers, any object name)
   though graphtype properties are usually strings
*}
Proposition with
  attribute
    gproperty: Proposition
end



{* used for listModule; faster version that assumes that Integers or Reals cannot have attributes; ticket #417 *}

DoNotSave_1 in HiddenObject,QueryClass isA Proposition with  
  constraint
    cnts : $ (~this in HiddenObject) or
             ((~this in MSFOLassertion) and not (~this in QueryClass)) or
             (~this in BDMRuleCheck) or
             (~this in BDMConstraintCheck) or (~this in Proposition!deducedBy) or
             (~this in Proposition!applyConstraintIfInsert) or (~this in Proposition!applyConstraintIfDelete) or
             (~this in ECAassertion) or
             ( (~this in IsA) and exists a/Attribute From(~this,a) and 
             ((a in QueryClass!retrieved_attribute) or (a in View!inherited_attribute))) or
             (~this in IsolatedValue[String/type]) or
             (~this in IsolatedValue[Integer/type]) or
             (~this in IsolatedValue[Real/type]) or
             :(~this in TransactionTime): and not (exists z/Proposition (~this attribute z))
             $
end



{* builtin purgeModule; M. Jeusfeld/30-Oct-2018 *}
purgeModule in HiddenObject,BuiltinQueryClass with
  parameter
     module: Module
end




