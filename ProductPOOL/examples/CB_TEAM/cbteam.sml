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
{ ---- Example for graphical types ---- }

X11GraphBrowserPalette with
  contains
    c9  : HansGT;
    c10 : MartinGT;
    c11 : ReneGT;
    c12 : ClaudiaGT;
    c13 : ManfredGT;
    c14 : RainerGT;
    c15 : StefanGT;
    c16 : ChristophQGT;
    c17 : ChristophRGT;
    c18 : ThomasGT;
    c19 : MarkusGT;
    c20 : CBGT
end

HansGT in ATK_Iconnode with
  WithShape
    shape : iconnode
  PixmapFile
    file  : "hans.xpm"
end 

MartinGT in ATK_Iconnode with
  WithShape
    shape : iconnode
  PixmapFile
    file  : "martin.xpm"
end 

ReneGT in ATK_Iconnode with
  WithShape
    shape : iconnode
  PixmapFile
    file  : "rene.xpm"
end 

ClaudiaGT in ATK_Iconnode with
  WithShape
    shape : iconnode
  PixmapFile
    file  : "claudia.xpm"
end 

ManfredGT in ATK_Iconnode with
  WithShape
    shape : iconnode
  PixmapFile
    file  : "manfred.xpm"
end 

RainerGT in ATK_Iconnode with
  WithShape
    shape : iconnode
  PixmapFile
    file  : "rainer.xpm"
end 

StefanGT in ATK_Iconnode with
  WithShape
    shape : iconnode
  PixmapFile
    file  : "stefan.xpm"
end 


ChristophQGT in ATK_Iconnode with
  WithShape
    shape : iconnode
  PixmapFile
    file  : "christophQ.xpm"
end 

ChristophRGT in ATK_Iconnode with
  WithShape
    shape : iconnode
  PixmapFile
    file  : "christophR.xpm"
end 

ThomasGT in ATK_Iconnode with
  WithShape
    shape : iconnode
  PixmapFile
    file  : "thomas.xpm"
end 

MarkusGT in ATK_Iconnode with
  WithShape
    shape : iconnode
  PixmapFile
    file  : "markus.xpm"
end 

CBGT in ATK_Iconnode with
  WithShape
    shape : iconnode
  PixmapFile
    file  : "cb.xpm"
end 


{ ---- Objekte, denen ein grafischer Typ zugeordnet ist ---- }

CB_Team in Class with
  graphtype
    t : CBGT
end

Hans in CB_Team with
  graphtype
    t : HansGT
end

Martin in CB_Team with
  graphtype
    t : MartinGT
end

Rene in CB_Team with
  graphtype
    t : ReneGT
end

Claudia in CB_Team with
  graphtype
    t : ClaudiaGT
end

Manfred in CB_Team with
  graphtype
    t : ManfredGT
end

ChristophQ in CB_Team with
  graphtype
    t : ChristophQGT
end

ChristophR in CB_Team with
  graphtype
    t : ChristophRGT
end

Rainer in CB_Team with
  graphtype
    t : RainerGT
end

Stefan in CB_Team with
  graphtype
    t : StefanGT
end

Markus in CB_Team with
  graphtype
    t : MarkusGT
end

Thomas in CB_Team with
  graphtype
    t : ThomasGT
end

