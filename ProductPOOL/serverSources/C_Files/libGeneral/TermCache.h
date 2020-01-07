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

#include "prolog.h"

#define FAIL 0
#define SUCCEED 1

#ifdef __cplusplus
extern "C" {
#endif

/**
 * Stores a copy of the PROLOG_TERM 'record' associated to 
 * double key (key1, key2). Fails with an error if there 
 * is already a value associated to the double key.
 */
int pc_record(char* key1, char* key2, record_t record);

/**
 * Stores a copy of the PROLOG_TERM 'record' associated to 
 * double key (key1, key2). Any value that was associated
 * to the double key, is erased.
 */
int pc_rerecord(char* key1, char* key2, record_t record);

/**
 * Unifies the PROLOG_TERM 'record' with the record associated 
 * to the double key (key1, key2). Fails if there is nothing
 * associated to the double key.
 */
int pc_recorded(char* key1, char* key2, record_t* record);

/*
 * Succeeds if there is an association to double key (key1, key2).
 */
int pc_is_a_key(char* key1, char* key2);

/**
 * Any record associated to the double key (key1, key2) is 
 * erased. Succeeds always.
 */
int pc_erase(char* key1, char* key2);

/**
 * All associations to double keys with second key (key2) are 
 * erased.
 */
int pc_erase_all(char* key2);

/**
 * Succeeds for all double keys (key1, key2) that have an 
 * associated value. If one or both of the arguments are free, all
 * matching solutions are returned by backtracking. The order is
 * undefined.
 */ 
int pc_current_key(char* key1, char* key2, PROLOG_TERM resultList);

#ifdef __cplusplus
}
#endif
