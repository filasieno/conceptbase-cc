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
{ ---- Klasse X11_Color und die Instanzen; sind natuerlich noch nicht vollstaendig ---- }

Class X11_Color
end

black            in X11_Color end
white            in X11_Color end
red              in X11_Color end
blue             in X11_Color end
sienna           in X11_Color end
firebrick        in X11_Color end
brown            in X11_Color end
naroon           in X11_Color end
magenta          in X11_Color end
purple           in X11_Color end
green            in X11_Color end
pink             in X11_Color end

LightSeaGreen    in X11_Color end
aquamarine       in X11_Color end
RoyalBlue        in X11_Color end
SkyBlue          in X11_Color end
DarkTurquoise    in X11_Color end
SlateGrey        in X11_Color end
DodgerBlue       in X11_Color end
LightGray        in X11_Color end
MediumSeaGreen   in X11_Color end

{ ---- Klasse ATK_Fonts ---- }

Class ATK_Fonts 
end

andy8   in ATK_Fonts end
andy8b  in ATK_Fonts end
andy8bi in ATK_Fonts end
andy8i  in ATK_Fonts end

andy10   in ATK_Fonts end
andy10b  in ATK_Fonts end
andy10bi in ATK_Fonts end
andy10i  in ATK_Fonts end

andy12   in ATK_Fonts end
andy12b  in ATK_Fonts end
andy12bi in ATK_Fonts end
andy12i  in ATK_Fonts end

andy16   in ATK_Fonts end
andy16b  in ATK_Fonts end
andy16bi in ATK_Fonts end
andy16i  in ATK_Fonts end

andy22   in ATK_Fonts end
andy22b  in ATK_Fonts end
andy22bi in ATK_Fonts end
andy22i  in ATK_Fonts end

andysans8   in ATK_Fonts end
andysans8b  in ATK_Fonts end
andysans8bi in ATK_Fonts end
andysans8i  in ATK_Fonts end

andysans10   in ATK_Fonts end
andysans10b  in ATK_Fonts end
andysans10bi in ATK_Fonts end
andysans10i  in ATK_Fonts end
andysans10f  in ATK_Fonts end

andysans12   in ATK_Fonts end
andysans12b  in ATK_Fonts end
andysans12bi in ATK_Fonts end
andysans12i  in ATK_Fonts end

andysans16   in ATK_Fonts end
andysans16b  in ATK_Fonts end
andysans16bi in ATK_Fonts end
andysans16i  in ATK_Fonts end

andysans22   in ATK_Fonts end
andysans22b  in ATK_Fonts end
andysans22bi in ATK_Fonts end
andysans22i  in ATK_Fonts end

{ ---- Klasse ATK_TextAlign ---- }

Class ATK_TextAlign
end

Center in ATK_TextAlign end
Left   in ATK_TextAlign end
Right  in ATK_TextAlign end

{ ---- Klasse ATK_LineCap ---- }

Class ATK_LineCap
end

0 in ATK_LineCap end
1 in ATK_LineCap end
2 in ATK_LineCap end
3 in ATK_LineCap end
4 in ATK_LineCap end

{ ---- Die verschiedenen Shapes ---- }

Class ATK_ShapeStyle
end

Class rectnode     in ATK_ShapeStyle end
Class ovalnode     in ATK_ShapeStyle end
Class diamondnode  in ATK_ShapeStyle end
Class bubblenode   in ATK_ShapeStyle end
Class pixmapnode   in ATK_ShapeStyle end
Class iconnode     in ATK_ShapeStyle end
Class trianglenode in ATK_ShapeStyle end
Class lineedge     in ATK_ShapeStyle end
Class erlineedge   in ATK_ShapeStyle end

{ ---- Klassen fuer die verschiedenen Shapes ---- }

Class ATK_Shape isA GraphicalType with
  attribute
    TextColor       : X11_Color;
    TextAlign       : ATK_TextAlign;
    LineColor       : X11_Color;
    LineWidth       : Integer;
    FontDesc        : ATK_Fonts
end

Class ATK_Node isA ATK_Shape with
  attribute
    BackgroundColor : X11_Color;
    Fill            : Boolean
end

Class ATK_Edge isA ATK_Shape with
  attribute 
    LineCap1        : ATK_LineCap; {Art des Kantenanfangs}
    LineCap2        : ATK_LineCap  {Art des Kantenendes}
end

{------------------ N O D E S -------------------}

Class ATK_Rectnode isA ATK_Node with
  attribute
    WithShape : ATK_ShapeStyle
end

Class ATK_Ovalnode isA ATK_Node with
  attribute
    WithShape : ATK_ShapeStyle
end

Class ATK_Diamondnode isA ATK_Node with
  attribute
    WithShape : ATK_ShapeStyle
end

Class ATK_Bubblenode isA ATK_Node with
  attribute
    WithShape : ATK_ShapeStyle
end

Class ATK_Pixmapnode isA ATK_Node with
  attribute
    WithShape  : ATK_ShapeStyle;
    PixmapFile : String
end

Class ATK_Iconnode isA ATK_Node with
  attribute
    WithShape  : ATK_ShapeStyle;
    PixmapFile : String
end

Class ATK_Trianglenode isA ATK_Node with
  attribute
    WithShape : ATK_ShapeStyle
end

{------------------ E D G E S -------------------}

Class ATK_Lineedge isA ATK_Edge with
  attribute
    WithShape : ATK_ShapeStyle
end

Class ATK_ERLineedge isA ATK_Edge with
  attribute
    WithShape : ATK_ShapeStyle
end

