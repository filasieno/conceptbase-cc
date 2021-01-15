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
#ifndef ALGLITERALS_H
#define ALGLITERALS_H

#include "Algebra.h"
//#include "BPextern.h"
//#include "Functors.h"

/*
 *  Das P-Literal
 *  =============
 *
 *  P : retrieve_proposition
 *
 */


/**P(id,x,l,y). Das Grundliteral.*/
class P : public BuiltinLiteral
{
public:
    P() : BuiltinLiteral(4,0,TUPEL_OID,TUPEL_OID,TUPEL_SYMID,TUPEL_OID) {};
    int calc();
};



/*
 *  In Literale
 *  ===========
 *
 *  In_i : In mit IsA-H\"ulle
 *  In_s : In ohne IsA-H\"ulle
 *  In_o : In_Beziehungen zu System-Omega Klassen
 *  Isa  : Isa was sonst...
 *
 */
/**In(x,c). x ist Instanz von c*/
class In : public BuiltinLiteral
{
public:
    In() : BuiltinLiteral(2,1,TUPEL_OID,TUPEL_OID) {}
    int calc();
    int calc(Tupel&,TUPELBAG&,int);
};

/**In\_i(x,c). Extensionale Instanzenbeziehungen mit Ber\"ucksichtigung der Isa-H\"ulle ( mit System-Klassen). */
class InI : public BuiltinLiteral
{
public:
    InI() : BuiltinLiteral(2,1,TUPEL_OID,TUPEL_OID) {}
    int calc();
};

/**In\_s(x,c). Extensionale Instanzenbeziehungen ohne Ber\"ucksichtigung der Isa-Hülle (also nur direkte Instanzen, keine System-Klassen). */
class InS : public BuiltinLiteral
{
public:
    InS() : BuiltinLiteral(2,1,TUPEL_OID,TUPEL_OID) {}
    int calc();
};

/**In\_o(x,c). Instanzenbeziehungen zu Systemklassen (sys\_In) */
class InO : public BuiltinLiteral
{
public:
    InO() 
            : BuiltinLiteral(2,1,TUPEL_OID,TUPEL_OID) {}
    int calc();
};

/**Isa(c1,c2). c1 ist Spezialisierung von c2 (mit transitiver H\"ulle) */
class IsA : public BuiltinLiteral
{
public:
    IsA() : BuiltinLiteral(2,1,TUPEL_OID,TUPEL_OID) {}
    int calc();
};

    
/*
 *  A Literale
 *  ==========
 *
 *  Adot : das Adot aus Literals.pro
 *  ALIT : das A-Literal
 *
 */

/**Adot(cc,x,ml,y). Wie A, zusaetzlich mit ConcernedClass cc für schnellere Auswertung. */
class ADOT : public BuiltinLiteral
{
public:
    ADOT() : BuiltinLiteral(4,2,TUPEL_OID,TUPEL_OID,TUPEL_SYMID,TUPEL_OID) {}
    int calc();
    int calc(Tupel&,TUPELBAG&,int);
};

/**A(x,ml,y). x hat ein Attribut zu y mit dem Meta-Label ml. */
class ALIT : public BuiltinLiteral
{
public:
    ALIT() : BuiltinLiteral(3,2,TUPEL_OID,TUPEL_SYMID,TUPEL_OID) {}
    int calc();
};

/**A\_label(x,ml,y,l). Wie A, jedoch gibt l den zugehörigen Label auf Instanzenebene an */
class ALLIT : public BuiltinLiteral
{
public:
    ALLIT() : BuiltinLiteral(4,2,TUPEL_OID,TUPEL_SYMID,TUPEL_OID,TUPEL_SYMID) {}
    int calc();
};

/**Adot\_label(cc,x,ml,y,l). wie A\_label */
class AdotLabelLIT : public BuiltinLiteral
{
public:
    AdotLabelLIT() : BuiltinLiteral(5,2,TUPEL_OID,TUPEL_OID,TUPEL_SYMID,TUPEL_OID,TUPEL_SYMID) {}
    int calc();
};


/* 
 *  From, To und Label
 *  ==================
 *
 *  vgl. From, To und Label in Literals.pro
 *
 */

/**From(id,x). Von x geht ein Link id aus */
class FROM : public BuiltinLiteral
{
public:
    FROM() : BuiltinLiteral(2,1,TUPEL_OID,TUPEL_OID) {}
    int calc();
};

/**To(id,x). In x geht ein Link id hinein */
class TO : public BuiltinLiteral
{
public:
    TO()   : BuiltinLiteral(2,1,TUPEL_OID,TUPEL_OID) {}
    int calc();
    int calc(Tupel&,TUPELBAG&,int);
};

/**Label(id,l). id hat den Label l*/
class LABEL : public BuiltinLiteral
{
public:
    LABEL() : BuiltinLiteral(2,1,TUPEL_OID,TUPEL_SYMID) {}
    int calc();
};

/*
 *  Vergleichs-Literale
 *  ===================
 *
 *  Identical: gleich-Operator
 *
 *  LT: numerisches kleiner 
 *  GT: numerisches gr\"osser gleich
 *  LE: numerisches kleiner gleich
 *  GE: numerisches gr\"osser gleich
 *  EQ: numerisches gleich
 *  NE: numerisches ungleich
 *
 */

/// IDENTICAL - gleich-Operator
class IDENTICAL : public BuiltinLiteral
{
public:
    IDENTICAL() : BuiltinLiteral(2,0,TUPEL_OID,TUPEL_OID) {}
    int calc();
};

/// kleiner-Operator
class LT : public BuiltinLiteral
{
public:
    LT() : BuiltinLiteral(2,0,TUPEL_OID,TUPEL_OID) {}
    int calc();
};

/// gr\"osser-Operator
class GT : public BuiltinLiteral
{
public:
    GT() : BuiltinLiteral(2,0,TUPEL_OID,TUPEL_OID) {}
    int calc();
};

/// kleiner-gleich
class LE : public BuiltinLiteral
{
public:
    LE() : BuiltinLiteral(2,0,TUPEL_OID,TUPEL_OID) {}
    int calc();
};

/// gr\"osser-gleich
class GE : public BuiltinLiteral
{
public:
    GE() : BuiltinLiteral(2,0,TUPEL_OID,TUPEL_OID) {}
    int calc();
};

/// numerisches gleich
class EQ : public BuiltinLiteral
{
public:
    EQ() : BuiltinLiteral(2,0,TUPEL_OID,TUPEL_OID) {}
    int calc();
};


/// numerisches ungleich
class NE : public BuiltinLiteral
{
public:
    NE() : BuiltinLiteral(2,0,TUPEL_OID,TUPEL_OID) {}
    int calc();
};

//Literal TRUE
class True : public BuiltinLiteral
{
public:
    True(): BuiltinLiteral(0,0) {}
    int calc();
};

//Literal Known
class Known : public BuiltinLiteral
{
public:
    Known():BuiltinLiteral(2,0) {}
    int calc();
};


#endif

