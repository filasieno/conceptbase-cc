/*
The ConceptBase.cc Copyright

Copyright 1987-2019 The ConceptBase Team. All rights reserved.

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
Matthias Jarke, RWTH Aachen, Informatik 5, Ahornstr. 55, 52056 Aachen, Germany
Christoph Quix, RWTH Aachen, Informatik 5, Ahornstr. 55, 52056 Aachen, Germany


This license is a FreeBSD-style copyright license.
Legal home of the FreeBSD copyright license: http://www.freebsd.org/copyright/freebsd-license.html
*/
 /******************************************************************
*
*      TIMELINE.h
*
*      Creation     : 10.12.92
*      Created By   : Marcel Rasche, Lutz Bauer, Thorben Woehler
*      Last Change  : 24.6.1993
*      Changed By   : Thomas List
*      Version      : 0.4
*
*******************************************************************/


#ifndef _TIMELINE
#define _TIMELINE 

#include "TIMEPOINT.h"

/** G\"ultigkeitsintervall.
  Die Klasse stellt den Abschnitt auf der Zeitlinie dar, in dem ein Telos-Objekt
  g\"ultig ist. Das Intervall ist links geschlossen und rechts offen. Hat das
  Intervall die Grenzen a < b, so ist das Objekt zum Zeitpunkt a g\"ultig, zum Zeitpunkt
  b jedoch nicht. Ist a==b, so ist das Objekt zu keinem Zeitpunkt g\"ultig.
  */
class TIMELINE { 
  private :
      /// Startzeitpunkt
   TIMEPOINT begin;
        /// Endzeitpunkt
   TIMEPOINT end;
  public:
        /// Konstruktor
   TIMELINE();
        /// Konstruktor: von a bis b
   TIMELINE( TIMEPOINT a, TIMEPOINT b );
        /// Setzt die Startzeit
   TIMELINE( const TIMELINE& tl );
   void Set_time_begin (TIMEPOINT a );
        /// Setzt die Endzeit
   void Set_time_end ( TIMEPOINT b );
        /// \"Uberpr\"uft, ob der gegebene Zeitpunkt innerhalb des Zeitintervalls liegt.
   int Is_In_Interval(TIMEPOINT c );
};

#endif

