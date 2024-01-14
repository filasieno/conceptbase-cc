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
/*********************************************************************
*
*   Literals.h
*
*   Creation:      15.11.1994
*   Created by:    Thomas List
*   last Change:   15.11.1994
*   Changed by:    Thomas List
*   Version 2.1a
*
*   Literal (enum) Typ!
*
*
**********************************************************************/

#ifndef _Literals
#define _Literals

#include "TOIDSETSTL.h"


#define LITANZ 10
#define FREE_ID_1 1
#define FREE_ID_2 2

#define FREE_CC 1
#define FREE_X 2
#define FREE_ML 4
#define FREE_Y 8

#define ADOT_METHOD_CC 1
#define ADOT_METHOD_X_Y 2
#define ADOT_METHOD_X 3
#define ADOT_METHOD_Y 4


enum Literals {In_s,In_i,Adot,star,system_class,ALit,Isa,Attr_s,Aidot,ALabelLit,Adot_LabelLIT};

void P_Literal(TOID,TOID,SYMID,TOID,int,TOIDSETSTL&,class TDB*, TIMEPOINT,int,TOID);
void P_Literal_wo_timecheck(TOID,TOID,SYMID,TOID,int,TOIDSETSTL&,class TDB*, TIMEPOINT,int);

void In_i_Literal( TOID, TOID, int, TOIDSETSTL&, TIMEPOINT, int, TOID );
void In_s_Literal( TOID, TOID, int, TOIDSETSTL&, TIMEPOINT, int, TOID );
void In_o_Literal( TOID, TOID, int, TOIDSETSTL&, class TDB*, TIMEPOINT, int, TOID);
void In_o_Literal_wo_timecheck( TOID, TOID, int, TOIDSETSTL&, class TDB*, int);
void Attr_s_Literal( TOID, TOID, int, TOIDSETSTL&, TIMEPOINT, int, TOID );

void Adot_Literal( TOID, TOID, SYMID, TOID, int, TOIDSETSTL&, TIMEPOINT, int, TOID );
void Aidot_Literal( TOID, TOID, SYMID, TOID, int, TOIDSETSTL&, TIMEPOINT, int, TOID );

void apply_source( TOIDSETSTL&, TOIDSETSTL&, TIMEPOINT, int, TOID, int ) ;
void apply_desti( TOIDSETSTL&, TOIDSETSTL&, TIMEPOINT, int, TOID, int ) ;
void apply_self( TOIDSETSTL&, TOIDSETSTL&, TIMEPOINT, int, TOID, int ) ;

void closure( TOIDSETSTL&, TOIDSETSTL&, void (*accfun)(TOIDSETSTL&, TOIDSETSTL& , TIMEPOINT, int, TOID, int), 
		 TIMEPOINT, int, TOID, int);
void generalization( TOIDSETSTL&, TOIDSETSTL &, TIMEPOINT, int, TOID, int );
void specialization( TOIDSETSTL&, TOIDSETSTL &, TIMEPOINT, int, TOID, int );

void A_Literal( TOID, SYMID, TOID,int, TOIDSETSTL&, TIMEPOINT, int, TOID );
void A_Label_Literal( TOID, SYMID, SYMID, TOID,int, TOIDSETSTL&, TIMEPOINT, int, TOID );

void Adot_Label_Literal( TOID, TOID, SYMID, TOID, SYMID,int, TOIDSETSTL&, TIMEPOINT, int, TOID );

void getSuperObjects( TOID, TOIDSETSTL&, TIMEPOINT,int, TOID, int);
void getInstances( TOID, TOIDSETSTL&, TIMEPOINT,int, TOID, int);
void addSolution(TOIDSETSTL&, TOID&, TOID&);
void addSolutionALabel(TOIDSETSTL &solution,TOID &lab,TOID &scrdst);


void Isa_Literal(TOID c1,TOID c2,int pattern, TOIDSETSTL &solution,
                 TIMEPOINT timepoint, int searchspace, TOID module);
void From(TOID,TOID,int, TOIDSETSTL&,
          TIMEPOINT, int, TOID);
void To(TOID,TOID,int, TOIDSETSTL&,
        TIMEPOINT, int, TOID);
void Label(TOID,TOID,int, TOIDSETSTL&,
           TIMEPOINT, int, TOID);

#endif







