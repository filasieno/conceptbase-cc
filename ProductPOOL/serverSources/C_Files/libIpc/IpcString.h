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

#ifndef __IpcString_h
#define __IpcString_h

/* The functions in this module encode resp. decode an arbitrary C string for providing a start- and endmarker when transmitting it via a character stream. 
*/


#ifdef __cplusplus
  extern "C" {
#endif

char* encodeIpcString( const char* string );
/* encodes an arbitrary C string, so that it can be transmitted via ipc.
   IN: string: any
   RET: the string that results by enclosing the inputstring with doublequotes and escaping inner doublequotes and backslashes by a backslash.
      Bsp.: H"a\-gar becomes "H\"a\\-gar".
      The resulting string has to be freed by the caller.
*/

char* decodeIpcString( const char* ipcstring );
/* decodes a String that has been encoded with encodeIpcString()
   IN: ipcstring: string that matches the regular expression \"([^\\\"]|\\\\|\\\")*\"
   RET: string that results by deleting the inputstring's enclosing doublequotes and its escaping backslashes.
       Bsp.: "H\"a\\-gar" becomes H"a\-gar.
      The resulting string has to be freed by the caller.
*/

unsigned getLengthOfEncodedString( const char* string );
/* IN: string: any
   RET: length of the string that results by calling encodeIpcString() on string.
   constraint: strlen(RET) >= 2 && getLengthOfEncodedString(s) == strlen(encodeIpcString(s))
*/


#ifdef __cplusplus
  }
#endif

#endif
