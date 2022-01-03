/*
The ConceptBase.cc Copyright

Copyright 1987-2022 The ConceptBase Team. All rights reserved.

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
/**********************************************************************
*
*   TDB.h: 
*
*   Creation:      10.2.1995
*   Created by:    Thomas List
*   last Change:   10.2.1995
*   Changed by:    Thomas List
*   Version 2.1a
*
*   some global definitions
*
**********************************************************************/

#ifndef _TDB_defs
#define _TDB_defs

#define ACTUAL_DB 1
/* #define TEMP_DB 2 */
#define HISTORY_DB 4
#define TEMP_DB_TELL 8
#define TEMP_DB_UNTELL 16

#define SEEK_END 2
#define UNUSED -1
#define FREE_ID 1
#define FREE_SRC 2
#define FREE_LAB 4
#define FREE_DST 8
#define FREE_MODULE 16

#define SYSTEM_CLASS_PROPOSITION 1
#define SYSTEM_CLASS_INDIVIDUAL 2
#define SYSTEM_CLASS_ATTRIBUTE 3
#define SYSTEM_CLASS_INSTANCEOF 4
#define SYSTEM_CLASS_ISA 5

#endif
