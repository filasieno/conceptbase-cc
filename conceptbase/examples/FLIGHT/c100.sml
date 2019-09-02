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
{$set syntax=PlainToronto}
Individual frankfurt in city  with
 con_to
       F1 : muenchen;
       F2 : hamburg;
       F3 : muenchen;
       F4 : muenchen;
       F5 : muenchen;
       F6 : muenchen;
       F7 : muenchen;
       F16 : paris;
       F17 : london;
       F19 : bayreuth;
       F37 : glasgow;
       F38 : saarbruecken;
       F39 : nice;
       F48 : zagreb;
       F58 : berlin;
       F61 : moskva;
       F76 : goeteborg;
       F90 : muenchen;
       F91 : saarbruecken;
       F94 : muenchen;
       F99 : madrid
end frankfurt
Individual muenchen in city  with
 con_to
       F8 : frankfurt;
       F9 : duesseldorf;
       F15 : bremen;
       F29 : duesseldorf;
       F34 : duesseldorf;
       F43 : frankfurt;
       F46 : frankfurt;
       F66 : berlin;
       F80 : frankfurt
end muenchen
Individual hamburg in city  with
 con_to
       F71 : duesseldorf;
       F77 : duesseldorf;
       F84 : helsinki
end hamburg
Individual duesseldorf in city  with
 con_to
       F87 : frankfurt;
       F100 : hamburg
end duesseldorf
Individual bremen in city  with
 con_to
       F10 : wangerooge;
       F13 : muenchen;
       F14 : frankfurt;
       F24 : london;
       F88 : berlin
end bremen
Individual wangerooge in city  with
 con_to
       F11 : bremen
end wangerooge
Individual juist in city  with
 con_to
       F12 : bremen
end juist
Individual paris in city  with
 con_to
       F64 : frankfurt;
       F97 : bremen
end paris
Individual london in city  with
 con_to
       F25 : bremen
end london
Individual hof in city  with
 con_to
       F18 : bayreuth;
       F98 : frankfurt
end hof
Individual bayreuth in city  with
 con_to
       F20 : hof;
       F21 : frankfurt
end bayreuth
Individual kobenhavn in city  with
 con_to
       F22 : hamburg;
       F36 : hamburg;
       F73 : duesseldorf
end kobenhavn
Individual stuttgart in city  with
 con_to
       F23 : bremen;
       F32 : duesseldorf
end stuttgart
Individual hannover in city  with
 con_to
       F26 : frankfurt;
       F27 : berlin;
       F28 : nuernberg;
       F49 : frankfurt;
       F52 : frankfurt;
       F59 : muenchen
end hannover
Individual berlin in city  with
 con_to
       F41 : koeln_bonn;
       F50 : saarbruecken;
       F57 : frankfurt;
       F67 : duesseldorf;
       F68 : muenster;
       F69 : muenster;
       F79 : duesseldorf;
       F96 : frankfurt
end berlin
Individual nuernberg in city  with
 con_to
       F33 : london;
       F85 : frankfurt;
       F86 : duesseldorf
end nuernberg
Individual sofia in city  with
 con_to
       F30 : frankfurt
end sofia
Individual helsinki in city  with
 con_to
       F31 : hamburg;
       F56 : hannover
end helsinki
Individual roma in city  with
 con_to
       F35 : muenchen;
       F72 : duesseldorf
end roma
Individual glasgow in city 
end glasgow
Individual saarbruecken in city  with
 con_to
       F93 : frankfurt
end saarbruecken
Individual nice in city  with
 con_to
       F62 : muenchen;
       F63 : muenchen
end nice
Individual milano in city  with
 con_to
       F40 : frankfurt;
       F42 : frankfurt;
       F54 : koeln_bonn
end milano
Individual koeln_bonn in city  with
 con_to
       F55 : berlin
end koeln_bonn
Individual oslo in city  with
 con_to
       F44 : duesseldorf
end oslo
Individual bucuresti in city  with
 con_to
       F45 : muenchen
end bucuresti
Individual dublin in city  with
 con_to
       F47 : frankfurt
end dublin
Individual zagreb in city 
end zagreb
Individual manchester in city  with
 con_to
       F51 : duesseldorf
end manchester
Individual amsterdam in city  with
 con_to
       F53 : frankfurt;
       F70 : frankfurt
end amsterdam
Individual barcelona in city  with
 con_to
       F60 : frankfurt
end barcelona
Individual moskva in city 
end moskva
Individual wien in city  with
 con_to
       F65 : nuernberg;
       F74 : frankfurt
end wien
Individual muenster in city 
end muenster
Individual tunis in city  with
 con_to
       F75 : duesseldorf
end tunis
Individual goeteborg in city 
end goeteborg
Individual chicago in city  with
 con_to
       F78 : frankfurt
end chicago
Individual bruxelles in city  with
 con_to
       F81 : stuttgart
end bruxelles
Individual casablanca in city  with
 con_to
       F82 : frankfurt;
       F83 : frankfurt
end casablanca
Individual dallas in city  with
 con_to
       F89 : frankfurt
end dallas
Individual helgoland in city  with
 con_to
       F92 : hamburg
end helgoland
Individual madrid in city  with
 con_to
       F95 : frankfurt
end madrid
