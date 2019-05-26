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
{ ---- Klasse X11GraphBrowserPalette mit ihren Inhalten ---- }

Class X11GraphBrowserPalette in GraphicalPalette with
  contains
    c1 : TokenGtype;
    c2 : MetametaGtype;
    c3 : SimpleGtype;
    c4 : MetaGtype;
    c5 : ClassGtype;
    c6 : InGtype;
    c7 : IsAGtype;
    c8 : AGtype
  default
    d  : PropositionGtype
end


{ ---- Die Standard grafischen Typen des Graphbrowsers ---- }

Class PropositionGtype in ATK_Rectnode with
  WithShape
    shape   : rectnode
  TextColor 
    tcolor  : black
  TextAlign 
    talign  : Center
  LineColor 
    lcolor  : black
  LineWidth 
    lwidth  : 1
  FontDesc 
    font    : andysans10
  BackgroundColor 
    bgcolor : LightGray
  Fill    
    fill    : TRUE
end

Class TokenGtype in ATK_Rectnode with
  rule
    gtrule  : $forall t/Token  (t graphtype TokenGtype)$
  WithShape
    shape   : rectnode
  TextColor 
    tcolor  : black
  TextAlign 
    talign  : Center
  LineColor 
    lcolor  : DarkTurquoise
  LineWidth 
    lwidth  : 1
  FontDesc 
    font    : andysans10f
  BackgroundColor 
    bgcolor : LightSeaGreen
  Fill    
    fill    : TRUE
end

Class MetametaGtype in ATK_Ovalnode with
  rule
    gtrule  : $forall t/MetametaClass  (t graphtype MetametaGtype)$
  WithShape
    shape   : ovalnode
  TextColor 
    tcolor  : black
  TextAlign 
    talign  : Center
  LineColor 
    lcolor  : LightSeaGreen
  LineWidth 
    lwidth  : 1
  FontDesc 
    font    : andysans10b
  BackgroundColor 
    bgcolor : aquamarine
  Fill    
    fill    : TRUE
end

Class SimpleGtype in ATK_Ovalnode with
  rule

    gtrule  : $forall t/SimpleClass  (t graphtype SimpleGtype)$
  WithShape
    shape   : ovalnode
  TextColor 
    tcolor  : black
  TextAlign 
    talign  : Center
  LineColor 
    lcolor  : red
  LineWidth 
    lwidth  : 1
  FontDesc 
    font    : andysans10b
  BackgroundColor 
    bgcolor : pink
  Fill    
    fill    : TRUE
end

Class MetaGtype in ATK_Ovalnode with
  rule
    gtrule  : $forall t/MetaClass  (t graphtype MetaGtype)$
  WithShape
    shape   : ovalnode
  TextColor 
    tcolor  : black
  TextAlign 
    talign  : Center
  LineColor 
    lcolor  : RoyalBlue
  LineWidth 
    lwidth  : 1
  FontDesc 
    font    : andysans10b
  BackgroundColor 
    bgcolor : SkyBlue
  Fill    
    fill    : TRUE
end

Class ClassGtype in ATK_Rectnode with
  rule
    gtrule  : $forall c/Class ( not (c in Token) and not (c in SimpleClass) and 
not (c in MetaClass) and not (c in MetametaClass)  ) ==> (c graphtype ClassGtype)$
  WithShape
    shape   : rectnode
  TextColor 
    tcolor  : black
  TextAlign 
    talign  : Center
  LineColor 
    lcolor  : black
  LineWidth 
    lwidth  : 1
  FontDesc 
    font    : andysans10
  BackgroundColor 
    bgcolor : DarkTurquoise
  Fill    
    fill    : TRUE
end

Class InGtype in ATK_Lineedge with
  rule
    gtrule  : $forall e/InstanceOf  (e graphtype InGtype)$
  WithShape
    shape   : lineedge
  TextColor
    tcolor  : black
  LineColor 
    lcolor  : SlateGrey
  LineWidth 
    lwidth  : 1
  FontDesc 
    font    : andysans8
  LineCap1
    lcap1   : 2
  LineCap2
    lcap2   : 4
end
  
Class IsAGtype in ATK_Lineedge with
  rule
    gtrule  : $forall e/IsA  (e graphtype IsAGtype)$
  WithShape
    shape   : lineedge
  TextColor
    tcolor  : black
  LineColor 
    lcolor  : DodgerBlue
  LineWidth 
    lwidth  : 3
  FontDesc 
    font    : andysans8
  LineCap1
    lcap1   : 2
  LineCap2
    lcap2   : 4
end
  
Class AGtype in ATK_Lineedge with
  rule
   gtrule   : $forall e/Attribute  (e graphtype AGtype)$
  WithShape
    shape   : lineedge
  TextColor
    tcolor  : black
  LineColor 
    lcolor  : MediumSeaGreen
  LineWidth 
    lwidth  : 1
  FontDesc 
    font    : andysans8
  LineCap1
    lcap1   : 2
  LineCap2
    lcap2   : 4
end
  


