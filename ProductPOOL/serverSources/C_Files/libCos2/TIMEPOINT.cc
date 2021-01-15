/*
The ConceptBase.cc Copyright

Copyright 1987-2021 The ConceptBase Team. All rights reserved.

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
 /***********************************************************************
*
*      TIMEPOINT.cc
*
*      Creation     : 08.12.92
*      Created By   : Marcel Rasche, Lutz Bauer, Thorben Woehler
*      Last Change  : 30.6.1993
*      Changed By   : Thomas List
*      Version      : 0.5
*
************************************************************************/


#include "TIMEPOINT.h"
#include <time.h>


TIMEPOINT::TIMEPOINT() {
  clock = 0;
  usec=0;
}	
 
TIMEPOINT::TIMEPOINT( long c, short u ) {
  clock=c;
  usec = u;
}

TIMEPOINT::TIMEPOINT( const TIMEPOINT &c )
{
    clock = c.clock;
    usec = c.usec;
}

void TIMEPOINT::SetTime( long c, short u ) {
  clock = c ;
  usec = u;
}

void TIMEPOINT::SetTime(TIMEPOINT c)
{
    clock = c.clock;
    usec = c.usec;
}

void TIMEPOINT::SetTime( int milsec, int sec, int min, int hour, int mday, int mon, int year ) {
/*
*  convert a timepoint given by year, month, .. ,sec to the type t_time
*  with the lib-function t_time (t_time is long, hopefully)
*/
  struct tm tm_time;
  tm_time.tm_sec = sec;
  tm_time.tm_min = min;
  tm_time.tm_hour = hour;
  tm_time.tm_mday = mday;
  tm_time.tm_mon = mon-1;            // see library-description
  tm_time.tm_year = year-1900;
  tm_time.tm_isdst=0;
  clock = mktime(&tm_time);
  usec = milsec % 1000;
}


long TIMEPOINT::GetTime() {
  return clock;
}

short TIMEPOINT::GetUsec()
{
    return usec;
}

void TIMEPOINT::GetTime(int &milsec, int &sec, int &min, int &hour, int &mday, int &mon, int &year)
{
    tzset();
    struct tm *tm_time;
    tm_time = gmtime ( &clock);
    sec = tm_time->tm_sec;
    min = tm_time->tm_min;
    hour = tm_time->tm_hour;
    mday = tm_time->tm_mday;
    mon = tm_time->tm_mon+1;
    year = tm_time->tm_year + 1900;
    milsec = usec;
}


int TIMEPOINT::operator == (TIMEPOINT c ) {
  return (clock == c.clock) && (usec == c.usec);
}
 
int TIMEPOINT::operator < (TIMEPOINT c ) {
  if ((clock < 0) && (c.clock >= 0)) return 1;
/* the negative values indicate the infinit-timepoint! */
  if (clock == c.clock)
      return usec < c.usec;
  return  clock < c.clock;
}

int TIMEPOINT::operator > (TIMEPOINT c ) {
  if (c.clock < 0) return 0;
  if (clock < 0) return 1;
/* the negative values indicate the infinit-timepoint! */
  if (clock == c.clock)
      return usec > c.usec;
  return  clock > c.clock;
}

