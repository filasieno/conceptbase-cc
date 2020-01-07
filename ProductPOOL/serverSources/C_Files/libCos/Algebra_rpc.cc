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
#include "Algebra.h"


TupelElement::TupelElement()
{
}

TupelElement::TupelElement(const TOID &toid)
{
}


TupelElement::TupelElement(int i)
{
}

TupelElement::~TupelElement()
{
}

void TupelElement::create_toid() 
{
}

void TupelElement::create_symid()
{
}


void
TupelElement::test() const
{
}

TupelElement& TupelElement::operator=(const SYMID& symid)
{
    return *(new TupelElement);
}

TupelElement& TupelElement::operator=(const TOID& toid) 
{
    return *(new TupelElement);
}

TupelElement& TupelElement::operator=(const int& i)
{
    return *(new TupelElement);    
}

    

TupelElement& TupelElement::operator=(const TupelElement &tel) 
{
    return *(new TupelElement);    
}

int TupelElement::operator==(const TupelElement &tel) const
{
    return 0;    
}

int TupelElement::operator<=(const TupelElement &tel) const
{
    return 0;    
}

int TupelElement::match(const TupelElement &tel) const
{
    return 0;    
}

Tupel::Tupel()
{
}


Tupel::Tupel(char n)
{
}



Tupel::Tupel(const Tupel &t)
{
}

Tupel::Tupel(const TupelElement& el1,
             const TupelElement& el2,
             const TupelElement& el3)
{
}

    
    

Tupel::~Tupel()
{
}


void
Tupel::test() const
{
}


TupelElement& Tupel::operator[](int i)
{
    return *(new TupelElement);    
}

TupelElement Tupel::operator[](int i) const
{
    return *(new TupelElement);    
}

Tupel& Tupel::operator=(const Tupel &t)
{
    return *(new Tupel);    
}

int
Tupel::operator==(const Tupel &t) const
{
    return 0;    
}

int
Tupel::operator<=(const Tupel &t) const
{
    return 0;    
}

int Tupel::match(const Tupel &t) const
{
    return 0;    
}

Tupel Tupel::proj(const AttrList& al)
{
    return *(new Tupel);    
}


int JoinCondition::add(int a, int b)
{
    return 0;    
}

int JoinCondition::get(int cn, int pos)
{
    return 0;    
}

int JoinCondition::result_length(int l1=0,int l2=0)
{
    return 0;    
}

int JoinCondition::result_contains(int f2)
{
    return 0;    
}

int JoinProjNode::contains(Tupel  item)
{
    return 0;
}

void JoinProjNode::clear()
{}

Pix JoinProjNode::first()
{
    return NULL;
}

void JoinProjNode::next(Pix& i)
{}

Pix JoinProjNode::firstGetAll()
{
    return NULL;
}

void JoinProjNode::nextGetAll(Pix&)
{}

Tupel& JoinProjNode::operator () (Pix i)
{
    Tupel t;
    return t;
}

void JoinProjNode::operator |=(TUPELSET& y)
{}

int JoinProjNode::owns(Pix i)
{
    return 0;
}


int JoinProjNode::length()
{
    return 0;
}

void JoinProjNode::GetDelta(TUPELSET& d)
{}

void JoinProjNode::GetDelta(TUPELBAG& d)
{}
      
void JoinProjNode::RestoreDelta()
{}

void JoinProjNode::RemoveDelta()
{}


void 
DataCollector::saveData(void*** where,void *what)
{}

int 
DataCollector::HasGotLinks() 
{}

void* 
DataCollector::getNrOf(void ***whatever,int nr)
{}

void
DataCollector::print(int pos)
{}




void JoinProjNode::CollectData(DataCollector* jdc) 
{}

class TDB *Relation::database=NULL;
TIMEPOINT Relation::timepoint;
int Relation::searchspace=0;
TOID Relation::module;

Relation::Relation(char new_size,char new_key, char t1,char t2,char t3,char t4,
                   char t5,char t6,char t7,char t8,char t9,char t10)
        :TUPELSET(), tupel_size(new_size),
         key(new_key), Belegung(0), not_calculated(0)
{
};

void Relation::RestoreDelta()
{}

void Relation::RemoveDelta()
{}

void Relation::Set(TDB *db,TIMEPOINT tp,int sp, TOID mod)
{
}

int Relation::AddCalc(Tupel tupel)
{
    return 0;    
}

int Relation::GetSize()
{
    return 0;
}

Pix Relation::first()
{
    return NULL;
}

int Relation::length()
{
    return 0;
}


void Relation::GetDelta(TUPELSET& d)
{}

void Relation::GetDelta(TUPELBAG& d)
{}

void Relation::next(Pix& i)
{}

Pix Relation::firstGetAll()
{
    return NULL;
}

void Relation::nextGetAll(Pix& i)
{}

Tupel& Relation::operator ()(Pix   idx)
{
    return *(new Tupel);
}

void Relation::operator |= (TUPELSET& y)
{}

void Relation::clear()
{}

int Relation::contains (Tupel  item)
{
    return 0;
}

int Relation::owns (Pix   idx)
{
    return 0;
}

    
Pix Relation::add(Tupel item)
{
    return NULL;    
}

void Relation::test()
{
}

void Relation::StrukturTest()
{
}

int Relation::select(class Relation &ergebnis, const Condition &cond)
{
    return 0;    
}

int Relation::proj(class Relation &ergebnis, const AttrList &attrlist)
{
    return 0;    
}

int Relation::unite(class Relation &relation2)
{
    return 0;    
}

int Relation::diff(class Relation &relation2,int mode)
{
    return 0;    
}

int Relation::calc(Tupel&,TUPELBAG&,int)
{
    return 0;
}

int Relation::calc()
{
    return 0;    
}

int Relation::join(class Relation &ergebnis, class Relation &relation2,
                   class JoinCondition &jc)
{
    return 0;    
}

void Relation::deltaclear()
{}

void Literal::CheckForRule( class Fixpoint *fixpoint)
{
}

void Literal::CollectData(DataCollector *jdc)
{}


void Literal::test()
{}

void Literal::StrukturTest()
{}


/*
void Literal::SetHead(BP_Term h)
{}
*/
Pix Literal::add(Tupel item)
{}

Pix Literal::firstGetAll()
{
    return NULL;
}

Tupel& Literal::operator ()(Pix)
{
    return *(new Tupel);
}

void Literal::RestoreDelta()
{}

void Literal::RemoveDelta()
{}


void Literal::nextGetAll(Pix& i)
{}

void Literal::GetDelta(TUPELSET& d)
{}

void Literal::GetDelta(TUPELBAG& d)
{}

Pix BuiltinLiteral::add(Tupel item)
{}

Pix BuiltinLiteral::firstGetAll()
{
    return NULL;
}

void BuiltinLiteral::nextGetAll(Pix& i)
{}


AttrList::AttrList(int ns) 
            : size(ns)
{
}

int JoinNode::calc()
{
    return 0;    
}

void JoinNode::CheckForRule(class Fixpoint *fixpoint)
{}

void JoinNode::test()
{
}

int ProjNode::calc()
{
    return 0;    
}

void ProjNode::CheckForRule(class Fixpoint *fixpoint)
{}

void ProjNode::test()
{
}

Pix JoinProjNode::add(Tupel item)
{
    return NULL;
}

int JoinProjNode::calc()
{
    return 0;    
}

void JoinProjNode::CheckForRule(class Fixpoint *fixpoint)
{}

void JoinProjNode::test()
{
}

void JoinProjNode::StrukturTest()
{
}

int JoinProjNode::TakeTokenFrom(Relation* relation)
{
    return 0;
}

SIMPLECROSS::SIMPLECROSS(Relation*)
{
}

void SIMPLECROSS::CheckForRule(class Fixpoint *fixpoint)
{}

void SIMPLECROSS::test()
{
}

void SIMPLECROSS::StrukturTest()
{
}

int SIMPLECROSS::calc() 
{
    return 1;
}

void SIMPLECROSS::RestoreDelta()
{}

void SIMPLECROSS::RemoveDelta()
{}

void SIMPLECROSS::GetDelta(TUPELSET& d)
{}

void SIMPLECROSS::GetDelta(TUPELBAG& d)
{}

void SIMPLECROSS::CollectData(DataCollector *jdc)
{}

/*
void AlgDescription::SetHead(BP_Term h)
{
}


BP_Term AlgDescription::GetHead()
{
    return NULL;    
}
*/

void AlgDescription::SetBody(Relation *b)
{
}

int AlgDescription::match(int arity2, char** konstanten2)
{
    return 0;    
}

Pix AlgDescription::first()
{
    return NULL;    
}

void AlgDescription::next(Pix  & idx)
{
}

Tupel& AlgDescription::operator ()(Pix   idx)
{
    return *(new Tupel);    
}


void AlgDescription::operator |= (TUPELSET& y)
{
}    


void AlgDescription::clear()
{
}

int AlgDescription::contains (Tupel  item)
{
    return 0;    
}

int AlgDescription::owns (Pix   idx)
{
    return 0;    
}

Relation *AlgDescription::GetBody()
{
    return NULL;    
}

/*
C_Functor AlgDescription::Functor()
{
    return NULL;    
}
*/

int AlgDescription::start_join_proj()
{}

int AlgDescription::join_proj(Relation &ergebnis,Tupel MainTupel,DataCollector *jdc,int pos)
{}

/*
C_Functor FixpointNode::GetFunctor()
{
    return new C_Functor();    
}
*/

Relation *FixpointNode::GetBody()
{
    return NULL;    
}

void FixpointNode::CheckForRule(class Fixpoint *fixpoint)
{
    GetBody()->CheckForRule(fixpoint);
}


void
Fixpoint::add(AlgDescription *ad)
{
}

/*Relation
Fixpoint::GetRelation(BP_Functor functor)
{
}
*/

int Relation::Anfrage(Tupel t, TupelSTLBag &bag)
{
    return 0;
};

C_Functor::C_Functor()
{};

C_Functor::~C_Functor()
{};
