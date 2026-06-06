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


GenericQueryClass P_CarrierOutput isA Action with
  parameter
    t1 : Carrier
  computed_attribute
    writtenData : Data
  constraint
     c1 : $
      exists t/Carrier!contains (this output t) 
  and From(t,~t1) 
  and To(t,~writtenData)
  $
end 

GenericQueryClass P_CarrierInput isA Action with
  parameter
    t1 : Carrier
  computed_attribute
    readData : Data
  constraint
     c1 : $
      exists t/Carrier!contains (this input t) 
  and From(t,~t1) 
  and To(t,~readData)
  $
end

GenericQueryClass P_CarrierFilledIn isA Data with
  parameter
     t1 : Carrier;
     a1 : Action
  constraint
     c1 : $
  (~t1 contains this)
  and exists t/Carrier!contains From(t,~t1) and To(t,this)
  and exists a/Action ((~a1 transFollowsAfter a) or (a == ~a1)) 
  and (a output t) 
  $
end 
 
GenericQueryClass P_CarrierNotFilledIn isA Data with
  parameter
     t1 : Carrier;
     a1 : Action
  constraint
     c1 : $
  (~t1 contains this)
  and not exists t/Carrier!contains From(t,~t1) and To(t,this)
  and exists a/Action ((~a1 transFollowsAfter a) or (a == ~a1)) 
  and (a output t) 
  $
end

GenericQueryClass P_AllCarriersFilledIn isA Carrier with
  parameter
     a1 : Action
  computed_attribute
     registered : Data
  constraint
     c1 : $
    ((~a1 gives this) or (~a1 takes this) or 
     (exists q/Carrier!contains From(q,this) and ((~a1 output q)
        or (~a1 input q)))) and
    (this contains ~registered)
  and exists t/Carrier!contains From(t,this) and To(t,~registered)
  and exists a/Action ((~a1 transFollowsAfter a) or (a == ~a1)) 
  and (a output t)
  $
end 
 
GenericQueryClass P_AllCarriersNotFilledIn isA Carrier with
  parameter
     a1 : Action
  computed_attribute
     registered : Data
  constraint
     c1 : $
    ((~a1 gives this) or (~a1 takes this) or 
     (exists q/Carrier!contains From(q,this) and ((~a1 output q)
        or (~a1 input q)))) and
    (this contains ~registered)
  and not exists t/Carrier!contains From(t,this) and To(t,~registered)
  and exists a/Action ((~a1 transFollowsAfter a) or (a == ~a1)) 
  and (a output t)
  $
end 


