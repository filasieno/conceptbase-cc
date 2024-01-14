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
*------------------------------
* Mono-GB Palette  
*
* LB Thu Dec 21 15:05:34 MET 1995
*------------------------------
} TokenGtype_mono in Class,ATK_Rectnode with 
  rule
     gtrule : $forall t/Token  (t graphtype TokenGtype_mono)$
  WithShape
     shape : rectnode
  TextColor
     tcolor : black
  TextAlign
     talign : Center
  LineColor
     lcolor : black
  LineWidth
     lwidth : 1
  FontDesc
     font : andysans10f
  Fill
     fill : FALSE
  BackgroundColor
     bgcolor : white
end 

 MetametaGtype_mono in Class,ATK_Ovalnode with 
  rule
     gtrule : $forall t/MetametaClass  (t graphtype MetametaGtype_mono)$
  WithShape
     shape : ovalnode
  TextColor
     tcolor : black
  TextAlign
     talign : Center
  LineColor
     lcolor : black
  LineWidth
     lwidth : 1
  FontDesc
     font : andysans10b
  BackgroundColor
     bgcolor : white
  Fill
     fill : FALSE
end 

 SimpleGtype_mono in Class,ATK_Ovalnode with 
  rule
     gtrule : $forall t/SimpleClass  (t graphtype SimpleGtype_mono)$
  WithShape
     shape : ovalnode
  TextColor
     tcolor : black
  TextAlign
     talign : Center
  LineColor
     lcolor : black
  LineWidth
     lwidth : 1
  FontDesc
     font : andysans10b
  BackgroundColor
     bgcolor : white
  Fill
     fill : FALSE
end 

 MetaGtype_mono in Class,ATK_Ovalnode with 
  rule
     gtrule : $forall t/MetaClass (t graphtype MetaGtype_mono)$
  WithShape
     shape : ovalnode
  TextColor
     tcolor : black
  TextAlign
     talign : Center
  LineColor
     lcolor : black
  LineWidth
     lwidth : 1
  FontDesc
     font : andysans10b
  BackgroundColor
     bgcolor : white
  Fill
     fill : FALSE
end 

 ClassGtype_mono in Class,ATK_Rectnode with 
  rule
     gtrule : $forall c/Class ( not (c in Token) and not (c in SimpleClass) and 
not (c in MetaClass) and not (c in MetametaClass)  ) ==> (c graphtype ClassGtype_mono)$
  WithShape
     shape : rectnode
  TextColor
     tcolor : black
  TextAlign
     talign : Center
  LineColor
     lcolor : black
  LineWidth
     lwidth : 1
  FontDesc
     font : andysans10
  BackgroundColor
     bgcolor : white
  Fill
     fill : FALSE
end 

 InGtype_mono in Class,ATK_Lineedge with 
  rule
     gtrule : $forall e/InstanceOf  (e graphtype InGtype_mono)$
  WithShape
     shape : lineedge
  TextColor
     tcolor : black
  LineColor
     lcolor : black
  LineWidth
     lwidth : 1
  FontDesc
     font : andysans8
  LineCap1
     lcap1 : 2
  LineCap2
     lcap2 : 4
end 

 IsAGtype_mono in Class,ATK_Lineedge with 
  rule
     gtrule : $forall e/IsA  (e graphtype IsAGtype_mono)$
  WithShape
     shape : lineedge
  TextColor
     tcolor : black
  LineColor
     lcolor : black
  LineWidth
     lwidth : 3
  FontDesc
     font : andysans8
  LineCap1
     lcap1 : 2
  LineCap2
     lcap2 : 4
end 

AGtype_mono in Class,ATK_Lineedge with 
  rule
     gtrule : $forall e/Attribute  (e graphtype AGtype_mono)$
  WithShape
     shape : lineedge
  TextColor
     tcolor : black
  LineColor
     lcolor : black
  LineWidth
     lwidth : 1
  FontDesc
     font : andysans8
  LineCap1
     lcap1 : 2
  LineCap2
     lcap2 : 4
end 

PropositionGtype_mono in Class,ATK_Rectnode with 
  WithShape
     shape : rectnode
  TextColor
     tcolor : black
  TextAlign
     talign : Center
  LineColor
     lcolor : black
  LineWidth
     lwidth : 1
  FontDesc
     font : andysans10
  BackgroundColor
     bgcolor : white
  Fill
     fill : FALSE
end 


X11GraphBrowserPalette_mono in Class,GraphicalPalette with 
  contains
     cm1 : TokenGtype_mono;
     cm2 : MetametaGtype_mono;
     cm3 : SimpleGtype_mono;
     cm4 : MetaGtype_mono;
     cm5 : ClassGtype_mono;
     cm6 : InGtype_mono;
     cm7 : IsAGtype_mono;
     cm8 : AGtype_mono
 default
     dm1 : PropositionGtype_mono
end 

