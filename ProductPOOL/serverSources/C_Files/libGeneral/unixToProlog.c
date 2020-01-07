/*
The ConceptBase.cc Copyright

Copyright 1987-2020 The ConceptBase Team. All rights reserved.

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
/*
*
* File:        unixToProlog.c
* Version:     2.18
* Creation:    Carlos Maltzahn (UPA)
* Last Change: 2/13/90 Rainer Gallersdoerfer (RG) (UPA)
* Release:     2
* -----------------------------------------------------------------------------
*
*  This module represents the unix side of the prolog interface to unix
*
*  Export
*	systemclock
*       dateOfLastFileChange
*       free_file_descriptors  (5-Dec-1988/MJf)
*       username (20-Sept-1989/MSt)
*       sleepsec (25-Sept-1989/MSt)
*       hostname (31-Oct-1989/MSt)
*	memfree (02-Jan-1990/MSt)
*	interval for msec: 0 to 999 (if < 0 then 0) (05-Feb-1990/CMa)
*
*/

#include "unixToProlog.h"

/*----------------------------------------------------------------------------*/

#ifndef _WIN32
void clockToTimeAndDate(time_t clock,long microsec,int* year,int* month,int* day,int* hour,
		          int* minute,int* second,long* usec)
{
	struct tm *t;

	t = gmtime(&clock);
	*year = t->tm_year + 1900;
	*month = t->tm_mon + 1;
	*day = t->tm_mday;
	*hour = t->tm_hour;
	*minute = t->tm_min;
	*second = t->tm_sec;

        *usec = microsec / 1000;
}
#endif

/*----------------------------------------------------------------------------*/

void systemclock(int*year,int* month,int* day,int* hour,int* minute,int* second,long* usec)
{

#ifdef _WIN32
    SYSTEMTIME sutime;
    GetSystemTime(&sutime);
    *year=sutime.wYear;
    *month=sutime.wMonth;
    *day=sutime.wDay;
    *hour=sutime.wHour;
    *minute=sutime.wMinute;
    *second=sutime.wSecond;
    *usec=sutime.wMilliseconds;
#else
	struct timeval sutime;

	gettimeofday(&sutime, NULL);
	clockToTimeAndDate(sutime.tv_sec, sutime.tv_usec, year, month, day, hour,
		                           minute, second, usec);
#endif
}



/*----------------------------------------------------------------------------*/


char buffer[200];

void username(name)
char **name;
{

#ifdef _WIN32
 DWORD size=200;
 memset(buffer,0x00,size);
 GetUserName(buffer,&size);
 *name=buffer;
/* *name=getenv("USERNAME");
 if(!*name)
    *name="unknown"; */
#else
#ifdef MACOS
 *name = getlogin();
#else
 memset(buffer,0x00,200);
 cuserid(buffer);
 *name = buffer;
#endif
#endif
}

/*----------------------------------------------------------------------------*/

void sleepsec(seconds)
unsigned seconds;
{
#ifdef _WIN32
 Sleep(seconds*1000);
#else
 sleep(seconds);
#endif

}

/*----------------------------------------------------------------------------*/

void hostname(host)
char **host;
{
  memset(buffer,0x00,200);
  gethostname(buffer,200);
  *host = buffer;
}

/*----------------------------------------------------------------------------*/

void memfree(ptr)
char *ptr;
{
 free(ptr);
}

/*---------------------------------------------------------------------------*/

/** This function is used to generate the session id of a CB server.
  * To compute this id, we take the current time (in milliseconds since 1970)
  * module 2^27 (as integers in Master (BIM) Prolog range from -2^28 to 2^28-1).
  * This should guarantee that the result is greater than zero. */
int sec_time()
{
       int res;
       time_t l;
       l = time(NULL);
       l = l/20;
       res=(int) (l % 134217728); /* 2^27*/
       if(res<0)
          res=res*(-1);
       return res;
}


