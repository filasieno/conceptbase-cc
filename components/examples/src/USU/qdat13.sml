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


GenericQueryClass ActionsWithoutInput isA Action with
  constraint
     c1 : $
  not exists t/Carrier!contains (this input t)
  $
end

GenericQueryClass ActionsWithoutOutput isA Action with
  constraint
     c1 : $
  not exists t/Carrier!contains (this output t)
  $
end

GenericQueryClass DataInputWithoutInput isA Action with
  computed_attribute
    inData : Data
  constraint
    c1 : $
    (not exists t/Carrier!contains
        (this input t) and To(t, ~inData))
    and  (this data_input ~inData)
  $
end

GenericQueryClass InputWithoutDataInput isA Action with
  computed_attribute
    inData : Data
  constraint
    c1 : $
   (exists t/Carrier!contains
       (this input t) and To(t, ~inData) )
   and not (this data_input ~inData)
  $
end

GenericQueryClass DataOutputWithoutOutput isA Action with
  computed_attribute
    outData : Data
  constraint
    c1 : $
    (not exists t/Carrier!contains
        (this output t) and To(t, ~outData))
    and (this data_output ~outData)
  $
end

GenericQueryClass OutputWithoutDataOutput isA Action with
  computed_attribute
    outData : Data
  constraint
    c1 : $
   (exists t/Carrier!contains
       (this output t) and To(t, ~outData) )
   and not (this data_output ~outData)
   and not (this data_input ~outData)
  $
end

GenericQueryClass OutputWithoutInput isA Action with
  computed_attribute
    outData : Data
  constraint
    c1 : $
   (exists t/Carrier!contains
       (this output t) and To(t, ~outData) )
   and not (this data_output ~outData)
   and not (this data_input ~outData)
   and not exists t2/Carrier!contains
       (this input t2) and To(t2, ~outData)
  $
end

GenericQueryClass CarrierExcess isA Action with
  computed_attribute
	takesCarrier : Carrier
  constraint
     c1 : $
          (this takes ~takesCarrier)
  and not exists d/Data (~takesCarrier contains d)
  and (this data_input d)
  and not exists t/Carrier (this takes t)
  and (not (~takesCarrier == t))
  and (t contains d)
  $
end

