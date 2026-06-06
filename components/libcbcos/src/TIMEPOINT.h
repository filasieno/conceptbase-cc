/*
The ConceptBase.cc Copyright

Copyright 1987-2026 The ConceptBase Team. All rights reserved.

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
*/
/***********************************************************************
*
*      TIMEPOINT.h
*
*      Creation     : 08.12.92
*      Created By   : Marcel Rasche, Lutz Bauer, Thorben Woehler
*      Last Change  : 1.7.1993
*      Changed By   : Thomas List
*      Version      : 04
*
************************************************************************/

#ifndef _TIMEPOINT
 #define _TIMEPOINT
 #define INFINITY -1
 #define TEMP_INFINITY -2


/** Time point.
  A time point consists of two components: a long value that resolves to seconds
  and a short value that represents the milliseconds.
  */
class TIMEPOINT {	
private:
        /// time from years down to seconds
    long clock;
        /// milliseconds
    short usec;
public:
        /// constructor (time point 0)
    TIMEPOINT ();
        /// constructor with a given time
    TIMEPOINT( long c, short u );
        /// constructor with a given time
    TIMEPOINT( const TIMEPOINT &c );    
        /// sets the time
    void SetTime( long c, short u );
        /// sets the time
    void SetTime( int milsec, int sec, int min, int hour, int mday, int mon, int year );
        /// sets the time
    void SetTime( TIMEPOINT c );
        /// returns the time up to seconds
    long GetTime();
        /// returns the milliseconds
    short GetUsec();
        /// returns the time
    void GetTime(int &milsec, int &sec, int &min, int &hour, int &mday, int &mon, int &year);

        /// Operator ==
    int operator == ( TIMEPOINT c);
        /// Operator <
    int operator < ( TIMEPOINT c);
        /// Operator >
    int operator > ( TIMEPOINT c);

};

#endif


