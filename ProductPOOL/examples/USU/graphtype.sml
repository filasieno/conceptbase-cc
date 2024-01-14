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
USU_Palette in GraphicalPalette with
contains 
	c1: TraegerGT;
	c2: AkteurGT;
	c3: AktionGT;
	c4: DatenGT;
        c5: metaTraegerGT;
        c6: metaAkteurGT;
        c7: metaAktionGT;
        c8: metaDatenGT;
	ac1 : TokenGtype;
 	ac2 : MetametaGtype;
 	ac3 : SimpleGtype;
 	ac4 : MetaGtype;
 	ac5 : ClassGtype;
 	ac6 : InGtype;
 	ac7 : IsAGtype;
 	ac8 : AGtype
end

Class TraegerGT in ATK_Iconnode with
rule
	gtrule : $ forall t/Traeger (t graphtype TraegerGT) $
WithShape
	shape : iconnode
PixmapFile
	file : "traeger.xpm"
end

Class metaTraegerGT in ATK_Iconnode with
WithShape
        shape : iconnode
PixmapFile
        file : "m_traeger.xpm"
end

Traeger with
  graphtype
     gt:  metaTraegerGT
end


Class AkteurGT in ATK_Iconnode with
rule
	gtrule : $ forall t/Akteur (t graphtype AkteurGT) $
WithShape
	shape : iconnode
PixmapFile
	file : "akteur.xpm"
end


Class metaAkteurGT in ATK_Iconnode with
WithShape
        shape : iconnode
PixmapFile
        file : "m_akteur.xpm"
end

Akteur with
  graphtype
     gt:  metaAkteurGT
end
 

Class AktionGT in ATK_Ovalnode with
rule
	gtrule : $ forall t/Aktion (t graphtype AktionGT) $
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
	font : andysans10f
BackgroundColor
	bgcolor : bisque
Fill
	fill : TRUE
end

Class metaAktionGT in ATK_Ovalnode with
WithShape
        shape : ovalnode
TextColor
        tcolor : black
TextAlign
        talign : Center
LineColor
        lcolor : bisque
LineWidth
        lwidth : 1
FontDesc
        font : andysans10f
BackgroundColor
        bgcolor : white
Fill
        fill : FALSE
end

Aktion with
  graphtype
     gt:  metaAktionGT
end
 



Class DatenGT in ATK_Rectnode with
rule
	gtrule : $ forall d/Daten (d graphtype DatenGT) $
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
BackgroundColor
	bgcolor : SkyBlue
Fill
	fill : TRUE
end

Class metaDatenGT in ATK_Rectnode with
WithShape
        shape : rectnode
TextColor
        tcolor : black
TextAlign
        talign : Center
LineColor
        lcolor : SkyBlue
LineWidth
        lwidth : 1
FontDesc
        font : andysans10f
BackgroundColor
        bgcolor : white
Fill
        fill : FALSE
end

Daten with
  graphtype
     gt:  metaDatenGT
end
 

 



bisque in X11_Color end
