/*
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
*/
/* 
*
* File:         %M%
* Version:      %I%
* Creation:     ???
* Last Change   : %E%, Christoph Quix (RWTH)
*
* SCCS-Source-Pool : %P%
* Date retrieved : %D% (YY/MM/DD)
* -----------------------------------------------------
*/

#include <stdlib.h>
#include <stdio.h>
#include "TDB.h"
#include "AlgLiterals.h"

#define MAXIDLENGTH 15

/*
 *   Funktoren der bekannten Literale
 */
BP_Functor lit_in_i, lit_in_s, lit_in_o,lit_a,lit_aLabel,lit_true,lit_Adot_Label,lit_known,lit_in,lit_isa;
BP_Functor lit_p;
BP_Functor lit_adot;
BP_Functor lit_from, lit_to;
BP_Functor lit_ne, lit_lt, lit_le, lit_label, lit_identical, lit_gt, lit_ge, lit_eq;

void
TDB::AlgebraToProlog(AlgDescription *ad, BP_Term term)
{
}

void 
TDB::TupelCToProlog(Tupel &t, BP_Term term,int arity)
{
}

JoinCondition *
TDB::JoinConditionToAlg(BP_Term term, int mod)
{
    return NULL;
}

AttrList *
TDB::ArgListToAlg(BP_Term term)
{
    return NULL;
}


Relation *
TDB::LiteralToAlg(BP_Term term)
{
    return NULL;
}

            


            
Relation *
TDB::_PrologToAlg(BP_Term term)
{
    return NULL;
}


AlgDescription *
TDB::PrologToAlg(BP_Term term)
{
    return NULL;
}







