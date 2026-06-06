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
#include "algebra.h"
#include "string.h"
#include "TDB.h"

//#define TRACE Lloyd
#define MaxLsg 5

TupelElement::TupelElement()
{
    element.toid=NULL;
    element.symid=NULL;
    type=0;
}

TupelElement::TupelElement(const TOID &toid)
{
    create_toid();
    *element.toid=toid;
}


TupelElement::TupelElement(int i)
{
    switch (type=i)
     {
     case TUPEL_FREE:
         element.toid=NULL;
         element.symid=NULL;
         break;
     case TUPEL_OID:
         create_toid();
         break;
     case TUPEL_SYMID:
         create_symid();
         break;
     default:
         ;
     }    
}

TupelElement::~TupelElement()
{
    switch (type)
    {
    case TUPEL_FREE:
        break;
    case TUPEL_OID:
        delete element.toid;
        break;
    case TUPEL_SYMID:
        delete element.symid;
        break;
    default:
        ;
    }
}

void TupelElement::create_toid() 
{
    if (!type) {
        type = TUPEL_OID;
        element.toid = new TOID;
    }
}

void
TupelElement::create_symid()
{
    if (!type) {
        type = TUPEL_SYMID;
        element.symid = new SYMID;
    }
}


void
TupelElement::test() const
{
    switch (type)
    {
    case TUPEL_FREE:
        printf("_");
        break;
    case TUPEL_OID:
        printf("id_%ld",element.toid->GetId());
        break;
    case TUPEL_SYMID:
        printf("%s",element.symid->get_name());
        break;
    default:;
    }
}

TupelElement& TupelElement::operator=(const SYMID& symid)
{
/*
 *  SYMID assignment
 */
    if (!type)
        create_symid();

    if (type == TUPEL_SYMID)
        *element.symid = symid;
    return *this;
}

TupelElement& TupelElement::operator=(const TOID& toid) 
{
/*
 *  TOID assignment
 */
    if (!type)
        create_toid();
    if (type == TUPEL_OID)
        *element.toid = toid;
    return *this;
}

TupelElement& TupelElement::operator=(const int& i)
{
    if (i != TUPEL_FREE)
        return *this;
    switch (type) {
    case TUPEL_FREE:
        break;
    case TUPEL_OID:
        delete element.toid;
        break;
    case TUPEL_SYMID:
        delete element.symid;
        break;
    default:
        ;
    }
    type = i;
    return *this;
}

    

TupelElement& TupelElement::operator=(const TupelElement &tel) 
{

    
    if (tel.type == TUPEL_FREE)
    {
        switch (type) {
        case TUPEL_FREE:
            break;
        case TUPEL_OID:
            delete element.toid;
            break;
        case TUPEL_SYMID:
            delete element.symid;
            break;
        default:
            ;
        }
        type = TUPEL_FREE;
        return *this;
    }

    if ((!type || type == TUPEL_OID) && tel.type == TUPEL_OID)
    {
        if (!type)
            create_toid();
        *element.toid = (TOID) tel;
        return *this;
    }

    if ((!type || type == TUPEL_SYMID) && tel.type == TUPEL_SYMID)
    {
        if (!type)
            create_symid();
        *element.symid = tel.get_symid();
        return *this;
    }
    return *this;
}

int TupelElement::operator==(const TupelElement &tel) const
{
    if (type != tel.type)
        return 0;
    switch (type)
    {
    case TUPEL_FREE:
        return 1;
    case TUPEL_OID:
        return *element.toid == (TOID) tel;
    case TUPEL_SYMID:
       return *element.symid == tel.get_symid();
    }
    return 0;
}

int TupelElement::operator<=(const TupelElement &tel) const
{
    if (type != tel.type)
        return 0;
    switch (type)
    {
    case TUPEL_FREE:
        return 1;
    case TUPEL_OID:
        return *element.toid <= (TOID) tel;
    case TUPEL_SYMID:
        return *element.symid <= tel.get_symid();
    }
    return 0;
}

int TupelElement::match(const TupelElement &tel) const
{
    if (tel.type == TUPEL_FREE)
        return 1;
    return (*this) == tel;
}

Tupel::Tupel()
{
    size = sort_by = 0;
    tupel=NULL;
}


Tupel::Tupel(const char n)
{
    size = n;
    sort_by = 0;
    tupel = new TupelElement[size];    
}



Tupel::Tupel(const Tupel &t)
{
    int i;
    
    size=t.size;
    sort_by=t.sort_by;
    
    tupel = new TupelElement[size];
    
    
    for (i=0;i<size;i++)
    {
        tupel[i]=t.tupel[i]; 
    }
    
}

Tupel::Tupel(const TupelElement& el1,
             const TupelElement& el2,
             const TupelElement& el3)
{
    size=3;
    if (el1.GetType()==TUPEL_UNDEF)
        size=0;
    else if (el2.GetType()==TUPEL_UNDEF)
        size=1;
    else if (el3.GetType()==TUPEL_UNDEF)
        size=2;
    tupel = new TupelElement[size];

    if (el1.GetType()!=TUPEL_UNDEF)
        tupel[0]=el1;
    if (el2.GetType()!=TUPEL_UNDEF)
        tupel[0]=el2;
    if (el3.GetType()!=TUPEL_UNDEF)
        tupel[0]=el3;
}

    
    

Tupel::~Tupel()
{
    delete[] tupel;
}


void
Tupel::test() const
{
    int i;
    printf("(");
    for (i=0;i<size-1;i++)
    {    
        tupel[i].test();
        printf(",");
    }
    tupel[size-1].test();
    printf(")");
}


TupelElement& Tupel::operator[](int i)
{
    return tupel[i];
}

TupelElement Tupel::operator[](int i) const
{
    return tupel[i];
}

Tupel& Tupel::operator=(const Tupel &t)
{
    
    
    
    if (!size)
    {
        size = t.size;
        sort_by = t.sort_by;
        tupel = new TupelElement[size];
    }
    else
        if (t.size > size)
            return *this;

    for (int i=0;i<t.size;i++)
    {
        tupel[i] = t.tupel[i];
    }
    
    return *this;    
}

int
Tupel::operator==(const Tupel &t) const
{
    if (size != t.size)
        return 0;
    for (int i=0;i<size;i++)
        if (!(tupel[i] == t.tupel[i]))
            return 0;
    return 1;
}

int
Tupel::operator<=(const Tupel &t) const
{
    
    int i,j;
    if (size != t.size)
        return 0;
    for (i=0,j=sort_by;i < size;i++,j = (j+1) % size)
    {
        if (!(tupel[j] <= t.tupel[j]))
            return 0;
        if (!(tupel[j] == t.tupel[j]))
            return 1;
    }
    return 1;
}

int Tupel::match(const Tupel &t) const
{
    if (size != t.size)
        return 0;
    for (int i=0;i<size;i++)
        if (!(tupel[i].match(t.tupel[i])))
            return 0;
    return 1;
}

Tupel Tupel::proj(const AttrList& al)
{
    int als,i;
    Tupel t(als=al.length());
    for (i=0;i<als;i++)
    {
        t[i]=(*this)[al(i)];
    }
    return t;
}

int Tupel::contains(const TupelElement *te)
{
    for (int a=0;a<size;a++)
    {
        if (tupel[a].GetType() == te->GetType())
        {
            switch (tupel[a].GetType())
            {
            case TUPEL_FREE:
                if (te->GetType()==TUPEL_FREE) return 1; 
            case TUPEL_OID:
                if (tupel[a]==*te) return 1;
            case TUPEL_SYMID:
                if (tupel[a]==*te) return 1;
            }
        }
    }
    return 0;
}


int JoinCondition::add(int a, int b)
{
    conditions[anz*2]=a;
    conditions[anz*2+1]=b;
    anz++;
    return 1;
}

int JoinCondition::get(int cn, int pos)
{
    return conditions[cn*2+pos];
}

int JoinCondition::result_length(int l1=0,int l2=0)
{
    int result,i,j;
    result=l1+l2;
    for (i=0;i<l2;i++)
        for (j=0;j<anz;j++)
            if (conditions[2*j+1]==i)
            {
                result--;
                break;
            }
    return result;
}

int JoinCondition::result_contains(int f2)
        /*
         * returns if attribute f2 of the second relation
         * is contained in the resulting relation
         *
         *
         * Example: (a,b,c) joins (d,b)
         *
         * f2=d => 1
         * fs=b => 0
         *
         */
{
    int i;
    for (i=0;i<anz;i++)
        if (conditions[2*i+1]==f2)
            return 0;
    return 1;
}


void
DataCollector::saveData(void*** where,void *what)
{
    if (!what) return;
    int zaehler=0;
    void **Neu;
    if (*where)
    {
         //anzahl der vorhanden daten zaehlen
        for (zaehler=0;(*where)[zaehler]!=NULL;zaehler++) 
        {
            if (where==Literals())
            {
                 //if ein literal eingefuegt are should, that es so already gives, is link auf das alte gesetzt
                if ((*(Literal*)((*where)[zaehler])).Functor()==(*(Literal*)what).Functor())
                {
                    what=(Literal*)((*where)[zaehler]);
                }
            }
        }
         //Neu ist eins larger...
        Neu=new void*[zaehler+2];
         //alten daten uebertragen
        for (int a=0;a<zaehler;a++) Neu[a]=(*where)[a];
         //neues datum setzen
        Neu[zaehler]=what;
         //ende signalisieren
        Neu[zaehler+1]=NULL;
    } else {
        Neu=new void*[2];
        Neu[0]=what;
        Neu[1]=NULL;
    }
    delete[] *where;
    *where=Neu;
}




int 
DataCollector::HasGotLinks() 
{
    if (LINKs) return 1; else return 0;
}

int 
DataCollector::HasGotSimpleCross() 
{
    if (SCs) return 1; else return 0;
}


void* 
DataCollector::getNrOf(void ***whatever,int nr)
{
    return (*whatever)[nr];
}

void
DataCollector::print(int pos)
{
    printf("DataCollector: \n");
    int a=0;
    if (LITs==NULL) return;

    for (a=0;((a<pos) && (LITs[a]));a++);
    
    if ((!pos) && (!LINKs)) printf("no Links!\n");
    while (LITs[a]!=NULL)
    {
        printf("%d: ",a+1);
        LITs[a]->structureTest();printf("(%p) ",LITs[a]);
        if (LINKs)
        {
            if (LINKs[a]!=NULL) printf(" link set");
        }
        if (ALs && JCs && ALs[a] && JCs[a])
        {
            printf(" AL(");
            int anz = ALs[a]->length();
            int i;
            for (i=0;i<anz;i++)
                printf(" %d",(*ALs[a])[i]);
            printf(") ");
            printf(" JC(");
            anz=JCs[a]->length();
            for (i=0;i<anz;i++)
                printf(" %d=%d",JCs[a]->get(i,0),JCs[a]->get(i,1));
            printf(")");
        }
        printf("\n");
        a++;
    }
}

ProgressView::ProgressView(int i,int a)
{
    max=i;
    zaehler=0;
    if (max>=a) divisor=a;
    else divisor=max;
    draw();
}

ProgressView::~ProgressView()
{
    printf("\r                                                          \r");
}


void ProgressView::step(int anz)
{
    zaehler+=anz;
    draw();
}

void ProgressView::draw()
{
    for (int a=0;a<divisor;a++)
    {
        if (a<int(zaehler/(max/divisor))) printf("#"); else printf("=");
    }
    if (max>0) 
    {
        printf("(%d/%d)",zaehler,max);
        printf("\r");
        fflush(stdout);
    }
}


       
class TDB *Relation::database=NULL;
TIMEPOINT Relation::timepoint;
int Relation::searchspace=0;
TOID Relation::module;
int Relation::zumuelln=0;
#ifdef CB_TRACE
 Relation::zumuelln=1;
#endif



Relation::Relation(char new_size,char new_key, char t1,char t2,char t3,char t4,
                   char t5,char t6,char t7,char t8,char t9,char t10)
        :TUPELSET(), tupel_size(new_size), key(new_key)
{
    types = new char[new_size];
    
    if (tupel_size >= 1)
        types[0]=t1;
    if (tupel_size >= 2)
        types[1]=t2;
    if (tupel_size >= 3)
        types[2]=t3;
    if (tupel_size >= 4)
        types[3]=t4;
    if (tupel_size >= 5)
        types[4]=t5;
    if (tupel_size >= 6)
        types[5]=t6;
    if (tupel_size >= 7)
        types[6]=t7;
    if (tupel_size >= 8)
        types[7]=t8;
    if (tupel_size >= 9)
        types[8]=t9;
    if (tupel_size >= 10)
        types[9]=t10;
    if (tupel_size >= 11)
    {
        int i;
        for (i=10;i<tupel_size;i++)
            types[i]=TUPEL_FREE;
    }
    OwnSolutions=1;
    solutions=NULL;
    not_calculated=1;
    Belegung=0;
    link=NULL;
    Token=NULL;
    negation=0;
    isAdotLabel=0;
};

void Relation::Set(TDB *db,TIMEPOINT tp,int sp, TOID mod)
{
    database=db;
    timepoint = tp;
    searchspace = sp;
    module = mod;
}

//first can actually durch firstGetAll ersetzt are, only funktioniert then
//the |=operator not more
Pix Relation::first()
{
    lokal=1;
    if ((!OwnSolutions) && (!link))
    {
        printf("relation::first(%p): Weder OwnSolutions still link gesetzt!\n",this);
        return NULL;
    }
    if (OwnSolutions) return TUPELSET::first();
    else return link->first();
}

//wie first, only are bei bedarf also die gelinkten lsg mitgeliefert
Pix Relation::firstGetAll()
{
    if ((!OwnSolutions) && (!link))
    {
        printf("relation::first(%p): Weder OwnSolutions still link gesetzt!\n",this);
        return NULL;
    }
    lokal=1;
    if (OwnSolutions)
    {
        Pix dummy=TUPELSET::first();
        if ((dummy) || (!link)) return dummy;
        else
        {
            lokal=0;
            link->SetPattern(0,NULL);
            return link->first();
        }
    }
    else {
        link->SetPattern(0,NULL);
        return link->first();
    }
}

void Relation::next(Pix  & idx)
{
    if ((!OwnSolutions) && (!link)) printf("relation::next(%p): Weder OwnSolutions still link gesetzt!\n",this);
    if (OwnSolutions)  TUPELSET::next(idx);
    else link->next(idx);
}

//wie next, aber if die last lokale lsg geliefert wurde, are die gelinkten lsg returngeliefert
void Relation::nextGetAll(Pix  & idx)
{
    if ((!OwnSolutions) && (!link)) 
    {
        printf("relation::next(%p): Weder OwnSolutions still link gesetzt!\n",this);
        idx=NULL;
        return;
    }
    if ((OwnSolutions) && (lokal)) TUPELSET::next(idx);
    else {
        link->SetPattern(0,NULL);
        link->next(idx);
    }
    if ((!idx) && (link) && (lokal) && (OwnSolutions))
    {
        lokal=0;
        link->SetPattern(0,NULL);
        idx=link->first();
    }
}

//returns on demand(lokal==false) also lsg from link return
Tupel& Relation::operator ()(Pix   idx)
{   
    if ((!OwnSolutions) && (!link)) printf("relation::operator()(%p): Weder OwnSolutions still link gesetzt!\n",this);    
    if ((OwnSolutions) && (lokal)) return TUPELSET::operator()(idx);
    else return (*link)(idx);
};


void Relation::operator |= (TUPELSET& y)
{
    *(TUPELSET*)(this)|=y;
}


void Relation::clear()
{
//  count = 0;
  TUPELSET::clear();
}

int Relation::contains (Tupel  item)
{
    if ((!OwnSolutions) && (!link)) printf("relation::contains: Weder OwnSolutions still link gesetzt!\n");        
    if (OwnSolutions) return TUPELSET::contains(item)!=0;
    else return link->contains(item)!=0;
}

int Relation::owns (Pix   idx)
{
    if ((!OwnSolutions) && (!link)) printf("relation::owns: Weder OwnSolutions still link gesetzt!\n");    
    if (OwnSolutions) return TUPELSET::owns(idx);
    else return link->owns(idx);
}

int Relation::AddCalc(Tupel tupel)
{
    if (!OwnSolutions) printf("relation::AddCalc: AddCalc aufgerufen auf eine relations without eigene Lsg.!\n");
    int pot,i;
    int bel;
    if (GetSize() != tupel.GetSize())
        {
            printf("AddCalc verweigert because of falscher Tupelsize!\n");
            tupel.test();printf(" Size is %d, Size should %d\n",tupel.GetSize(),GetSize());
            return 0;
        }
    
    bel=0;
    for (pot=1,i=0;i<GetSize();i++,pot*=2)
    {
        if (tupel[i].GetType() == TUPEL_FREE)
        {
            bel += pot;
        }
    }
        //here is not relation::length uses. because da die links mit beruecksichtigt are
    if (!TUPELSET::length())
        Belegung=bel;
    else
        if (Belegung != bel)
        {
            printf("AddCalc verweigert because of falscher Belegung!\n");
            return 0;
        }
    tupel.SetKey(key);
        //es is not relation::add uses. because
        //dort lsg nach solution geschrieben are
        //Berechnungen are aber always only lokal ausgefuehrt
  
    if (!contains(tupel)) delta.add(tupel);
    TUPELSET::add(tupel);
    
    not_calculated=1;
    return 1;
}

int Relation::GetSize()
{
     //database ist set if the fixpoint built wurde. Erst then ist eine Ueberpruefung of link and OwnSolution sinnvoll
    if (!database) return tupel_size;
    if ((!OwnSolutions) && (!link)) 
    {
        printf("relation::GetSize(): Eine relation without eigene and without gelinkte Lsg. ist aufgetreten!(");
        structureTest();
        printf(")\n");
        return 0;
    }
    if (OwnSolutions) return tupel_size;
    if (link==NULL) return tupel_size;
    else if (tupel_size>0) return tupel_size;
         else return link->GetBody()->GetSize();    
}

int Relation::length()
{
    if ((!OwnSolutions) && (!link)) 
    {
        printf("relation::length(): Eine relation without eigene and without gelinkte Lsg. ist aufgetreten!\n");
        return 0;
    }
    if ((OwnSolutions) && (!link)) return TUPELSET::length();
    if ((!OwnSolutions) && (link)) return link->length();
    return TUPELSET::length()+link->length();
}

    
int Relation::NewSolutions()
{
    if ((!OwnSolutions) && (!link)) printf("relation::NewSolutions: Eine relation without eigene and without gelinkte Lsg. ist aufgetreten!\n");
    if ((!link) || (OwnSolutions))
    {
        if (!IsCalculated()) return 0;
        if (!delta.length())
            return 0;
        return delta.length();
    };
    if ((link) && (OwnSolutions)) return link->NewSolutions()+delta.length();
    return link->NewSolutions();
}

//schreibt die lsg, if possible, nach solutions    
Pix Relation::add(Tupel item)
{
    if (!OwnSolutions) printf("relation::add: Es wurde versucht Lsg. hinzuzufuegen, without OwnSolutions set zu haben!\n");
    item.SetKey(key);
    if (!solutions)
    {
        if ((!contains(item)) && ((!link) || (!link->contains(item))))  delta.add(item);
        return TUPELSET::add(item);
    }
    return solutions->add(item);
}

void Relation::test() {
    if (link)
    
        printf("Umgelenkt on %p  \n",link);
    printf("calculated   : ");if (not_calculated) printf("NEIN\n"); else printf("JA\n");
    printf("tupel_size   : %d",GetSize());printf("\n");
    printf("Belegung     : %d\n",Belegung);
    printf("solutions    : ");if (solutions) printf("after %p\n",solutions); else printf("selbst\n");
    printf("OwnSolutions : ");if (OwnSolutions) printf("JA\n"); else printf("NEIN\n");
    printf("negated      : ");if (negation) printf("JA\n"); else printf("NEIN\n");
    Pix i = firstGetAll();
    int zaehler=0;
    printf("[");
    while (i) {
        if (!lokal) printf("[00;00;34m|"); else printf("[00;00;30m");
        (*this)(i).test();
        nextGetAll(i);
        zaehler++;
        if (zaehler>MaxLsg) 
        {
            printf("...(%d lsg)",length());
            i=NULL;
        }
    }
    printf("[00;00;30m");
    printf("]; \n");
}

void Relation::structureTest()
{
}

int Relation::select(class Relation &ergebnis, const Condition &cond)
{
    
    for (Pix ind=first();ind;next(ind))
    {
        if ((*this)(ind).match(cond))
            ergebnis.add((*this)(ind));
    }
    return 1;
}

int Relation::proj(class Relation &ergebnis, const AttrList &attrlist)
{
    ergebnis.tupel_size = attrlist.length();
    for (Pix ind=first();ind;next(ind))
    {
        ergebnis.add((*this)(ind).proj(attrlist));
    }
    return 1;
    
}

int Relation::unite(class Relation &relation2)
{
    int i;
    if (GetSize() != relation2.GetSize())
        return 0;
    for (i=0;i<GetSize();i++)
        if (types[i] != relation2.types[i])
            return 0;
    *this |= relation2;
    return 1;
}

int Relation::diff(class Relation &relation2,int mode)
{
    if (4==3) mode=0;
    if (GetSize() != relation2.GetSize())
        return 0;
    *this -= relation2;
    return 1;
}

int Relation::calc()
{
//    printf("***************relation::calc() aufgerufen!!!!***************\n");
    deltaclear();
    return 1;
}

//this Berechnung ist in the literals effektiver programmiert
//here ist only eine Ausweichvariante, if die obige implementation
//(virtual) not existiert
int Relation::calc(Tupel& tupel,TUPELBAG& ergebnis,int bel)
{
     //printf("relation::calc(tuple...) : ");
     //tupel.test();
    TUPELSET dummy;
    bel=GetBelegung();
    dummy|=(*this);
    clear();
    AddCalc(tupel);
    calc();
     //printf(" liefere: ");
    for (Pix ind=first();ind;next(ind)) 
    { 
        ergebnis.add((*this)(ind));
         // (*this)(ind).test();
    }
    clear();
    (*this)|=dummy; 
    not_calculated=1;
    SetBelegung(bel);
     //printf("\n");
    return 1;
}


int Relation::join(class Relation &ergebnis, class Relation &relation2,
                   class JoinCondition &jc)
{
     //only um "unused parameter"-Warning zu umgehen
    if (4==5)
    {
        ergebnis.test();
        relation2.test();
        jc.add(1,1);
    }
    return 1;
}

int Relation::query(Tupel tupel,TUPELBAG &ergebnis)
{
     //printf("relation::query gestellt! ");
     //tupel.test();printf("\n");
    if (!IsCalculated())
    {
         //printf("query: not calculated\n");
        if (negation) 
        {
           
            if (link)
            {
                Pix ind=firstGetAll();
                while (lokal) nextGetAll(ind);
                while (ind) 
                {
                    if ((*this)(ind).match(tupel)) 
                    {
                         //tupel ist im gelinken stored --> no lsg
                        return 1;
                    } 
                    nextGetAll(ind);
                }
            }

            if (tupel_size!=tupel.GetSize()) return 0;
            
             //das ist die eigene Berechnungsvorschrift
            Tupel t2=(*this)(first());
            if (t2.GetSize()!=tupel.GetSize()) return 0;
            
            int bel=0,pot=1;
            for (int a=0;a<tupel.GetSize();a++)
            {
                 //if das tuple element frei is...
                if (tupel[a].GetType()==0)
                {
                     //das des Orginaltupels einsetzen
                    tupel[a]=t2[a];
                    if (tupel[a].GetType()==0) bel+=pot;
                } else {
                     //if die tupel not zusammenpassen...
                    if (t2[a].GetType()!=0)
                        if (!(tupel[a]==t2[a])) 
                        {
                            ergebnis.add(tupel);
                            return 1;
                        }
                }
                pot*=2;
            }

             //alle elemente in tupel muessen belegt sein!
             //int bel=1;
             //for (int a=1;a<tupel.GetSize();a++) bel*=2;
            if (!calc(tupel,ergebnis,0)) return 0;
            not_calculated=1;
            if (!ergebnis.length()) 
            {
                 //printf("add: ");
                 //tupel.test();
                 //printf("\n");
                ergebnis.add(tupel); 
            } else {
                 //printf("ignoriere: ");
                 //tupel.test();
                 //printf("\n");
                ergebnis.clear();
            }
            return 1;
        }
        
        if (!length()) return 0;

         //if gelinkte Lsg vorhanden, only this liefern
        if (link) {
            if (!Token)
            {
                 //das ist die Berechnungsvorschrift!
                Pix ind=firstGetAll();
                 //das ist die first gelinkte Lsg!
                while ((lokal) && (ind)) nextGetAll(ind);
                while (ind) 
                {
                     //printf("teste ");
                     //(*this)(ind).test();
                    if ((*this)(ind).match(tupel)) 
                    {
                         //printf(" passt ");
                        ergebnis.add((*this)(ind));
                    }
                     //printf("\n");
                    nextGetAll(ind);
                }
            } else {
                TUPELSET *globDelta=link->globDelta;
                if (!globDelta) return 1;
                 //link->globDelta->test();
                
                Pix ind=globDelta->first();
                 //printf("[");
                while (ind)
                {
                     //(*globDelta)(ind).test();
                     //printf(" ");
                    if ((*globDelta)(ind).match(tupel)) 
                    {
                        ergebnis.add((*globDelta)(ind));
                         //tupel.test();
                         //printf(" matcht\n");
                    }
                    globDelta->next(ind);
                }
                 //printf("](%d eintraege)",globDelta->length());
            }
        }

         //das ist die eigene Berechnungsvorschrift
        Tupel t2=(*this)(first());
         //printf("berechnungvorschrift is ");t2.test();printf("\n");
        if (t2.GetSize()!=tupel.GetSize()) return 0;

        int bel=0,pot=1;
        for (int a=0;a<tupel.GetSize();a++)
        {
             //if das tuple element frei is...
            if (tupel[a].GetType()==0)
            {
                 //das des Orginaltupels einsetzen
                tupel[a]=t2[a];
                if (tupel[a].GetType()==0) bel+=pot;
            } else {
                 //if die tupel not zusammenpassen...
                if (t2[a].GetType()!=0)
                    if (!(tupel[a]==t2[a])) return ergebnis.length();
            }
            pot*=2;
        }
        
        if (!calc(tupel,ergebnis,bel)) return 0;
         //printf("generierte vorschrift ");tupel.test();printf("\n");
//        clear();
         //berechnung ausfuehren
//        AddCalc(tupel);
//        calc();        
         //alten zustand again herstellen
         //not_calculated=1;
//        for (Pix ind=first();ind;next(ind)) ergebnis.add((*this)(ind));
//        clear();
//        TUPELSET::add(t2);
    } else {
         //printf("berechnet\n");

        if (GetSize()!=tupel.GetSize()) return 0;

        if (negation)
        {
             //printf("relation::query gestellt! ");
             //tupel.test();printf("  ");
             //printf("negated!\n");
            if (!length()) return 0;
            TupelElement *frei=new TupelElement();
            if (tupel.contains(frei))
            {
                for (Pix ind=firstGetAll();ind;nextGetAll(ind))
                {
                    if ((*this)(ind).match(tupel)) 
                    {
                         //printf(" abgelehnt\n");
                        return 1;
                    }
                }
            } else if (contains(tupel)) {delete frei;return 1;} 
            delete frei;
             //printf(" angenommen\n");
            ergebnis.add(tupel);
        } else {
            if (!length()) return 0;
            if (!Token) 
            {
                for (Pix ind=firstGetAll();ind;nextGetAll(ind))
                {
                    if ((*this)(ind).match(tupel)) 
                    {
                         //printf("untersuche: ");
                         //(*this)(ind).test();
                        ergebnis.add((*this)(ind));
                         //printf(" ja\n");
                    }
                }
            } else {
                TUPELSET dummy;
                GetDelta(dummy);
                for (Pix ind=dummy.first();ind;dummy.next(ind))
                {
                    if (dummy(ind).match(tupel)) 
                    {
                         //printf("untersuche: ");
                         //(*this)(ind).test();
                        ergebnis.add(dummy(ind));
                         //printf(" ja\n");
                    }
                }
            }
        }
    }
     /*
      *printf("liefere ergebnis: [");
      *for (Pix ind=ergebnis.first();ind;ergebnis.next(ind)) 
      *{
      * ergebnis(ind).test();
      * printf(",");
      *}
      *printf("]\n");
      *return ergebnis.length();
      */
}


int Relation::join_proj2(class JoinProjNode &ergebnis, class Relation &relation2,
                         class JoinCondition &jc, AttrList &al)
{
     //printf("join_proj2\n");
     //ergebnis.structureTest();
     //printf("\n");
    if (relation2.IsCalculated()) 
    {
         //printf("JoinProj %dx%d\n",length(),relation2.length()); 
    } else {
         //printf("JoinProj %dx???\n",length());
    }
    int zaehler=0;

    if (length()*relation2.length()>42) ergebnis.AufBagUmschalten();
    if ((relation2.IsCalculated() && length()*relation2.length()>5000) || 
        (length()>1000) || 
        (relation2.IsCalculated() && relation2.length()>1000))
    {
         //zaehler=1;
    }
    if (!jc.length()) 
    {
         //printf("Keine JoinConditions angegeben! Ich kuerze das Verfahren ab...\n");
        if (relation2.calc()) 
        {
             //printf("relation 2 wurde berechnet.\n");
        } else {
             //printf("Relation2 konnte not berechnet are. Normales Verfahren eingeleitet.\n");
        }
         //printf("Kreuzprodukt %dx%d\n",length(),relation2.length());
    } else 
        if (relation2.IsCalculated()) 
        {
             //printf("JoinProj %dx%d\n",length(),relation2.length()); 
        } else {
             //printf("JoinProj %dx???\n",length());
        }
    
    Pix ind,ind2;
    int i,j,zwischen_ts;
    
     //variablen for die between.- and endergebnise dimensionieren
    Tupel tupel(zwischen_ts = jc.result_length(GetSize(),relation2.GetSize()));

     //ergebnis.clear();
    
    ergebnis.tupel_size = al.length();    
    
    int feld2_anz;
    int feld2[zwischen_ts];

    for (i=j=0;i<relation2.GetSize();i++)
    {
        if (jc.result_contains(i))
        {
            feld2[j++]=i;
        }
    }
    feld2_anz = j;
    Tupel t2(relation2.GetSize()),t;
    
     //if (token) printf("Relation1 hat token\n");
     //if (relation2.token) printf("Relation2 hat token\n");
    

    TUPELBAG tmp;
    Tupel dummy(relation2.GetSize());
    int a=0,b=0,c=length()/10;

#ifdef TRACE    
    TOID toid;
    char *sC6=new char[50];
    strcpy(sC6,"Lloyd");
    if ((TDB*)database->name2toid(sC6,toid)) 
    {
    }else printf("konnte %s not finden\n",sC6);
    TupelElement *C6=new TupelElement();
    *C6=toid;
    
    printf("Tracing after %s (id_%ld)\n",sC6,((TOID)*C6).GetId());
#endif
    for (ind=firstGetAll();ind;nextGetAll(ind))
    {
        if (zaehler) 
        {
            a++;
            if (c==a) {b++;a=0;printf("%d Prozent (%d loesungen)\n",b*10,ergebnis.length());}
        }
        t=(*this)(ind);
        tupel=t;

         //elemente of t2 auf Frei setzen
        t2=dummy;
        for (i=0;i<jc.length();i++)
        {        
            t2[jc.get(i,1)]=t[jc.get(i,0)];
        }
         //printf("(%d) stelle anfrage: ",a++);
         //t2.test();
         //printf(" (bis now %ld lsg) ",ergebnis.length());
        if (jc.length()) 
        {
            relation2.query(t2,tmp);
             //printf(" %d ergebnisse\n",tmp.length());
            for (ind2=tmp.first();ind2;tmp.next(ind2))
            {
                for (i=0;i<feld2_anz;i++)
                    tupel[GetSize()+i]=tmp(ind2)[feld2[i]];
                ergebnis.add(tupel.proj(al));
#ifdef TRACE
                if (tupel.proj(al).contains(C6)) 
                {
                    printf("%s in Lsg (",sC6);
                    tupel.proj(al).test();
                    printf(" mit query ");
                    t2.test();
                    printf(")\n");
                }
#endif
            }
            tmp.clear();
        } else {
             //printf(" %d ergebnisse\n",relation2.length());
            for (ind2=relation2.first();ind2;relation2.next(ind2))
            {
                for (i=0;i<feld2_anz;i++)
                    tupel[GetSize()+i]=relation2(ind2)[feld2[i]];
                ergebnis.add(tupel.proj(al));
#ifdef TRACE
                if (tupel.proj(al).contains(C6)) 
                {
                    printf("%s in Lsg (",sC6);
                    tupel.proj(al).test();
                    printf(" mit query ");
                    t2.test();
                    printf(")\n");
                }
#endif
            }
        }
    }
     //  printf("join_proj2: liefere: ");
     //for (ind2=ergebnis.first();ind2;ergebnis.next(ind2))
     //{
     //   ergebnis(ind2).test();
     //   printf(" ");
     // }
     //printf("\n");
    return 1;
}




void Relation::deltaclear()
{
    delta.clear();
}

//gives gelinkte and/or eigene Deltas return
void Relation::GetDelta(TUPELSET& Tupelset)
{
    Tupelset|=delta;
    if (link) 
    {
         //if !solution, then ist man not oberste rel, also also no mapping
        if (!solutions) link->GetDelta(Tupelset);
        else {
            TUPELSET dummy;
            link->GetDelta(dummy);
            Pix ind=dummy.first();
            while (ind) {
                Tupelset.add(solutions->map(dummy(ind)));
                dummy.next(ind);
            }
        }
    }
}

//gives gelinkte and/or eigene Deltas return, aber in a TUPELBAG
void Relation::GetDelta(TUPELBAG& Tupelbag)
{
    Pix i;
    i=delta.first();
    while (i) { Tupelbag.add(delta(i));delta.next(i);}
    if (link) 
    {
         //if !solution, then ist man not oberste rel, also also no mapping
        if (!solutions) 
        {
            link->GetDelta(Tupelbag);
        } else {
            TUPELBAG dummy;
            link->GetDelta(dummy);
            Pix ind=dummy.first();
            while (ind) {
                Tupelbag.add(solutions->map(dummy(ind)));
                dummy.next(ind);
            }
        }
    }
}

void Relation::RestoreDelta()
{   
    if (link && !LinkZeigtAufEigenenFixpoint)
    {
         //structureTest();
         //printf(" :Restauriere link-delta!\n");
        *(link->globDelta)|=*(link->GetBody());
    }
}

void Relation::RemoveDelta()
{
    if (link && !LinkZeigtAufEigenenFixpoint)
    {
         //structureTest();
         //printf(" :Loesche link-delta!\n");
        link->globDelta->clear();
    }
}

void Literal::CheckForRule( class Fixpoint *fixpoint)
{ 
     //printf("literal\n");
     //structureTest();
     //BP_Functor lit_adot       = GET_PRED( STR2ATOM(TRUE,"Adot"),4);

    C_Functor lit_adot("Adot",4);
   
     AdotLink=NULL;

     if (isAdotLabel) AdotLink=fixpoint->GetAlgDescr(lit_adot);
     if (AdotLink && fixpoint->ContainsAlgDescr(AdotLink)) AdotLinkZeigtAufEigenenFixpoint=1;
     else AdotLinkZeigtAufEigenenFixpoint=0;
     set_link(fixpoint->GetAlgDescr(Functor()));
     if (link && fixpoint->ContainsAlgDescr(link)) LinkZeigtAufEigenenFixpoint=1;
     else LinkZeigtAufEigenenFixpoint=0;
      //printf("literal ende\n");
}


void Literal::test()
{
     //BP_Atom atom;
//    int arity;
     //GET_NAME_ARITY(functor,&atom,&arity);
    printf("[00;00;34m");
//    printf("literal: %s [",ATOM2STR(atom));

    
    printf("literal:");structureTest();
     

    printf("] (%p)\n",this);
    if (AdotLink) printf("Adot gelinkt an Position %p\n",AdotLink);
    printf("[00;00;30m");
    Relation::test();
     /*
       TUPELSET dummy;
       GetDelta(dummy);
       Pix i = dummy.first();
       printf("delta: [");
       int zaehler=0;
       while (i) 
       {
       (dummy)(i).test();
       dummy.next(i);
       zaehler++;
       if (zaehler>MaxLsg)
       {
       printf("...(%d lsg)",delta.length());
       i=NULL;
       }
       }
       printf("]\n");
     */
    if (link) if (!LinkZeigtAufEigenenFixpoint) printf("link zeigt not auf own fixpoint!\n");
    if (AdotLink) if (!AdotLinkZeigtAufEigenenFixpoint) printf("AdotLink zeigt not auf own fixpoint!\n");
}

void Literal::structureTest()
{
//    BP_Atom atom;
//    int arity;
//    GET_NAME_ARITY(functor,&atom,&arity);
    printf("[00;00;34m");
    if (negation) printf("neg(");
//    printf("%s[",ATOM2STR(atom));
    printf("%s[",Functor().name());

    if (Functor().konst()) {
        for (int a=0;a<Functor().len();a++)
        {
            if (Functor()[a]!=NULL) printf("%s",Functor()[a]); else printf("_");
            if (a<Functor().len()-1) printf(",");
        }
    }

    printf("]");
    if (negation) printf(")");
    printf("[00;00;30m");
}


void Literal::AdotAusnahmeBehandeln()
{
    TUPELBAG deltabag;
    AdotLink->SetPattern(Functor().len()-1,Functor().konst());
    AdotLink->GetDelta(deltabag);
     //   printf("%d new lsg im bag\n",deltabag.length());
    for (Pix i=deltabag.first();i;deltabag.next(i))
    {
        Tupel tupel(5);
        tupel=deltabag(i);
        int MLlen=strlen(((deltabag(i))[2].get_symid()).get_name());
//        char dummy[15+MLlen]="COMPUTED_";
        char dummy[15+MLlen];
        strcpy(dummy,"COMPUTED_");
        strcat(dummy,((deltabag(i))[2].get_symid()).get_name());
        strcat(dummy,"_");
        char dummy2[5];
        ((TOID)(deltabag(i))[3]).GetOid(dummy2);
        strcat(dummy,dummy2);
//        delete[] dummy2;
        tupel[4]=*(new SYMID(dummy));
         //printf("add tupel ");
        add(tupel);
         //tupel.test();
         //printf("\n");
    }
}


Pix Literal::firstGetAll()
{
    
     //printf("literal::firstgetall()\n");
    
    if ((!OwnSolutions) && (!link))
    {
        printf("literal::first(%p): Weder OwnSolutions still link gesetzt!\n",this);
        return NULL;
    }
    lokal=1;
    if (OwnSolutions)
    {
         //if this ein AdotLabel mit a link zu of a Adot-Rule ist
         //are alle Lsg in die eigene relation kopiert.
         //not schnell, kommt aber also not oft vor.
        if ((AdotLink) && (AdotLink->NewSolutions())) AdotAusnahmeBehandeln();
            
        Pix dummy=TUPELSET::first();
        if ((dummy) || (!link)) return dummy;
        else
        {   
            lokal=0;
            link->SetPattern(Functor().len(),Functor().konst());
            Pix i=link->first();
            while ((i) && (!(link->match(Functor(),(*link)(i))))) link->next(i);
            return i;
        }
    } else {
        link->SetPattern(Functor().len(),Functor().konst());
        Pix i=link->first();
        while ((i) && (!(link->match(Functor(),(*link)(i))))) link->next(i);
        return i;
    }
}

void Literal::nextGetAll(Pix  & idx)
{
     //printf("literal::nextgetall()\n");
     //if ((!OwnSolutions) && (!link)) printf("relation::next(%p): Weder OwnSolutions still link gesetzt!\n",this);
    if ((OwnSolutions) && (lokal)) TUPELSET::next(idx);
    else {
        link->SetPattern(Functor().len(),Functor().konst());
        link->next(idx);
        while ((idx) && (!(link->match(Functor(),(*link)(idx))))) link->next(idx);
    }
    if ((!idx) && (link) && (lokal) && (OwnSolutions))
    {
        lokal=0;
        link->SetPattern(Functor().len(),Functor().konst());
        idx=link->first();
        while ((idx) && (!(link->match(Functor(),(*link)(idx))))) link->next(idx);
    }
     //printf("literal::nextgetall() ende\n");
}


void Literal::RestoreDelta()
{
    if (link && !LinkZeigtAufEigenenFixpoint)
    {
         //structureTest();
         //printf(" :Restauriere link-delta!\n");
        *(link->globDelta)|=*(link->GetBody());
    }
    if (AdotLink && !AdotLinkZeigtAufEigenenFixpoint)
    {
         //structureTest();
         //printf(" :Restauriere AdotLink-delta!\n");
        *(AdotLink->globDelta)|=*(AdotLink->GetBody());
    }
}

void Literal::RemoveDelta()
{
    if (link && !LinkZeigtAufEigenenFixpoint)
    {
         //structureTest();
         // printf(" :Loesche link-delta!\n");
        link->globDelta->clear();
    }
    if (AdotLink && !AdotLinkZeigtAufEigenenFixpoint)
    {
         //structureTest();
         //printf(" :Loesche AdotLink-delta!\n");
        AdotLink->globDelta->clear();
    }
}

Pix Literal::add(Tupel item)
{
    if (!OwnSolutions) printf("literal::add: Es wurde versucht Lsg. hinzuzufuegen, without OwnSolutions set zu haben!\n");
    item.SetKey(key);
    if (!solutions)
    {
        if (!contains(item)) delta.add(item);
        return TUPELSET::add(item);
    }
//    return solutions->add_mapping(item);    
    return solutions->add(item);    
}

//returns on demand(lokal==false) also lsg from link return
Tupel& Literal::operator ()(Pix   idx)
{   
    if ((!OwnSolutions) && (!link)) printf("relation::operator()(%p): Weder OwnSolutions still link gesetzt!\n",this);    
    if ((OwnSolutions) && (lokal)) return TUPELSET::operator()(idx);
    else return (*link)(idx);
};

void Literal::SetHead(char *name,int anz,char **konst)
{
    Functor().set(name,anz,konst);
    SetSize(anz);
//    konstanten=konst;
}

/*
void Literal::SetHeadBP_Term h)
{
    BP_Atom atom;
    BP_Functor func;
    BP_Term arg;
    int arity;
    if (GET_TYPE(h)==BP_T_STRUCTURE) 
    {
        GET_VALUE(h,BP_T_STRUCTURE,&func);
        GET_NAME_ARITY(func,&atom,&arity);
        functor.set((char*)ATOM2STRING(atom),arity);
        konstanten=new char*[arity];
    
        for (int i=0;i<arity;i++)
        {
            GET_ARG(h,i+1,&arg);
            int type=GET_TYPE(arg);
            if (type==BP_T_VARIABLE)
            {
                konstanten[i]=NULL;
            }
            if (type==BP_T_ATOM)
            {
                BP_Atom atom;
                GET_VALUE(arg,BP_T_ATOM,&atom);
                if (ATOM2STR(atom)[0]=='_')
                {
                     //Hack for variables die als atoms arrive...
                    konstanten[i]=NULL;
                    continue;
                }
                konstanten[i]=new char[strlen((char*)ATOM2STR(atom))];
                konstanten[i]=(char*)ATOM2STR(atom);
            }        
        }
    } else {
        functor=GET_PRED(STR2ATOM(TRUE,"TRUE"),0);
    }    
}
*/

void Literal::GetDelta(TUPELBAG& Tupelbag)
{
    if (link) link->SetPattern(Functor().len(),Functor().konst());
    Relation::GetDelta(Tupelbag);
}

void Literal::GetDelta(TUPELSET& Tupelset)
{
    if (link) link->SetPattern(Functor().len(),Functor().konst());
    Relation::GetDelta(Tupelset);
}

void Literal::CollectData(DataCollector* jdc) 
{
    jdc->saveData(jdc->Literals(),this);
    jdc->saveData(jdc->Links(),link);
}

Pix BuiltinLiteral::add(Tupel item)
{   
    if (!OwnSolutions) printf("BuiltinLiteral::add: Es wurde versucht Lsg. hinzuzufuegen, without OwnSolutions set zu haben!\n");
    item.SetKey(key);
    if (!solutions)
    {
        if (!contains(item)) delta.add(item);
        return TUPELSET::add(item);
    }
    return solutions->add(item);    
}

void BuiltinLiteral::nextGetAll(Pix  & idx)
{
    Literal::nextGetAll(idx);
}

Pix BuiltinLiteral::firstGetAll()
{
    return Literal::firstGetAll();
}


AttrList::AttrList(int ns) 
            : size(ns)
{
    int i;
    attr=new int[size];
    for (i=0;i<size;i++)
        attr[i]=-1;
}

int JoinNode::calc()
{
    deltaclear();
    if (rel1->calc()) {
        if (rel1->NewSolutions()) rel2->not_calculated=1;        
        if (rel1->join(*this,*rel2,*jc)) {
            not_calculated=0;
            return 1;
        }
        return 0;
    }
    return 0;    
}

void JoinNode::CheckForRule( class Fixpoint *fixpoint )
{
    rel1->CheckForRule(fixpoint);
    rel2->CheckForRule(fixpoint);
}


void JoinNode::test()
{
    if (not_calculated)
    {
        int i,anz;
        printf("JoinNode: \n");
        printf(" JoinCondition:\n");
        printf("  number: %d\n",anz=jc->length());
        for (i=0;i<anz;i++)
            printf("  condition %d: %d==%d\n",i+1,jc->get(i,0),jc->get(i,1));
        printf(" relation 1:\n");
        rel1->test();
        printf(" relation 2:\n");
        rel2->test();
        printf("JoinNode - Ende\n");
    }
    else
    {
        Relation::test();
        rel1->test();
        rel2->test();
    }
}

int ProjNode::calc()
{
    deltaclear();
    rel->calc();
    rel->proj(*this,*al);
    not_calculated=0;
    return 1;
}

void ProjNode::CheckForRule( class Fixpoint *fixpoint )
{
    rel->CheckForRule(fixpoint);
}

void ProjNode::test()
{
    if (not_calculated)
    {
        int i,anz;
        printf("projection: \n");
        printf(" AttrList:\n");
        anz = al->length();
        for (i=0;i<anz;i++)
            printf(" %d",(*al)[i]);
        printf("\n");
        printf("solutions=%p\n",solutions);
        printf(" relation:\n");
        rel->test();
        printf("projection - Ende\n");
    }
    else
    {
        Relation::test();
        rel->test();
    }
}

//siehe also relation::TakeTokenFrom in algebra.h
int JoinProjNode::TakeTokenFrom(Relation* relation)
{
        //token erstmal (because man ist ja ein JoinProjNode) uebernehmen
    Token=relation->Token;
        //if rel2-link set is, koennte da ein delta sein (bei builtins ist das delta nonsensical)
        //if link==NULL kriegt sie also keinen token, because ja no deltas...
    if ((rel2->link) && (rel2->LinkZeigtAufEigenenFixpoint))
    {
            //token der 2.Ralation geben
        rel2->Token=Token;
            //eigenen loeschen
        Token=NULL;
    } else {
            //token der 1. relation geben (das ist wahrscheinlich again ein JoinProjNode)
        if (!rel1->TakeTokenFrom(this))
        {
                //if sie den token not will(because sie only eine relation and no JoinNode is, then ende
            Token=NULL;
            return 0;
        } 
    }
        //token der gebenden relation loeschen (here there is mal kurzzeitig 2 tokens, abba das macht nix)
    relation->Token=NULL;
    return 1;
}

/* Tokens:
 * Bei of a Kette of relations in a join is ein token of der ersten
 * bis zur letzten relation durchgegeben (bei jedem calc eins weiter)
 * es are also mehrere calc-durchlaeufe gemacht
 * relations mit token beruecksichtgen only ihre Deltas, die anderen alle lsg
 * if the token bis hinten gekommen is, is die Berechnungsschleife of
 * der letzten relation gestoppt, indem der ersten weiter=0 set is */
int JoinProjNode::calc()
{
     //printf("JoinprojNode:calc()\n");
    
    deltaclear();
        //if erfuellt, then ist this der first JoinProjNode der Kette
        //er hat den token without Ueberpruefung bekommen and must das nachholen
    if (RepeatCalc)
            //if the token not weitergegeben are konnte, then ist no
            //gelinkte relation in der Kette and es is only einrn Durchlauf geben
        if (!TakeTokenFrom(this)) RepeatCalc=0;
    do
    {
         //  if (RepeatCalc) printf("JoinProjNode::calc\n");
         //only der oberste JoinProjNode wiederholt die Berechnung
         //RepeatCalc ist standartmaessig=true
         //jeder JoinProjNode setzt das repeatCalc des naechsten auf false
         //so only for the first in the chain RepeatCalc==true
        rel1->RepeatCalc=0;
        if (rel1->calc()) {
            if (rel1->NewSolutions() && (rel2->link)) rel2->not_calculated=1;
            if ((rel2->negation) && (!rel2->calc()))
            {
                 //negationen muessen zum zeitpunkt des joins ausrechenbar sein, or
                 //already ausgerechnet sein!
                 //printf("JoinProjNode::calc(): Negation in rel2 konnte not ausgerechnet are!!\n");
            }
             //    printf("token %d\n",token);
             //printf("rel1-token %d\n",rel1->token);
             //printf("rel2-token %d\n",rel2->token);
            
             //printf("joine: ");
             //rel1->structureTest();
             //printf(" with ");
             //rel2->structureTest();
             //printf("\n");
            
             //Pix i = rel1->firstGetAll();
             //printf("[");
             //while (i) {
             //   (*rel1)(i).test();
             //   rel1->nextGetAll(i);
             //}
             //printf("]; \n");
            
             //i = rel2->firstGetAll();
             //printf("[");
             //while (i) {
             //   (*rel2)(i).test();
             //   rel2->nextGetAll(i);
             //}
             //printf("]; \n");
            
            if (bag) deltaclear();
            if (rel1->join_proj2(*this,*rel2,*jc,*al))
            {
                not_calculated=0;
                 //war rel1 das ende der kette and besitzt den token (-->gelinkt)?
                if (rel1->Token)
                {
                     //berechnung beenden
                    rel1->Token->RepeatCalc=0;
                    rel1->Token=NULL;
                }
                 //if rel2 den token gerade hatte and rel1 ihn not will (-->not gelinkt)...
                if ((rel2->Token) && (!rel1->TakeTokenFrom(rel2)))
                {
                     //Berechnung beenden
                     //token zeigt auf die first relation
                    rel2->Token->RepeatCalc=0;
                    rel2->Token=NULL;
                }
            }
        }
         //  }
    } while (RepeatCalc);
     //printf("result des joins: %d\n",length());
    
//     Pix i = firstGetAll();
//     printf("[");
//     while (i) {
//        (*this)(i).test();
//        nextGetAll(i);
//     }
//     printf("]; \n");
    return 1;
}

void JoinProjNode::CheckForRule( class Fixpoint *fixpoint )
{
    rel1->CheckForRule( fixpoint );
    rel2->CheckForRule( fixpoint );
        //must standartmaessig 1 sein, siehe JoinProjNode::Calc
    RepeatCalc=1;
    bag=NULL;
}

void JoinProjNode::test()
{
    printf("[00;00;35m");
    if (not_calculated) 
    {
        int i,anz;
        printf("join-projection: (%p)\n",this);
        printf("[00;00;30m");        
        printf("tupel_size=%d\n",GetSize());
        printf(" AttrList:\n");
        anz = al->length();
        for (i=0;i<anz;i++)
            printf(" %d",(*al)[i]);
        printf("\n");
        printf(" JoinCondition:\n");
        printf("  number: %d\n",anz=jc->length());
        for (i=0;i<anz;i++)
            printf("  condition %d: %d==%d\n",i+1,jc->get(i,0),jc->get(i,1));
        printf("RepeatCalc=%d\n",RepeatCalc);
        printf(" relation 1 (%p):\n",rel1);
        printf("-----------------\n");
        rel1->test();
        printf(" relation 2 (%p):\n",rel2);
        printf("-----------------\n");
        rel2->test();
        printf("JoinNode - Ende\n");
    }
    else
    {
        printf("JoinProjNodetest: \n");
        printf(" AttrList:\n");
        int i,anz;
        anz = al->length();
        for (i=0;i<anz;i++)
            printf(" %d",(*al)[i]);
        printf("\n");
        printf(" JoinCondition:\n");
        printf("  number: %d\n",anz=jc->length());
        for (i=0;i<anz;i++)
            printf("  condition %d: %d==%d\n",i+1,jc->get(i,0),jc->get(i,1));
        printf("[00;00;30m");        
        Relation::test();
        TUPELSET dummy;
        GetDelta(dummy);
        Pix ind = dummy.first();
        printf("delta: [");
        int zaehler=0;
        while (ind) {
            (dummy)(ind).test();
            dummy.next(ind);
            zaehler++;
            if (zaehler>MaxLsg) 
            {
                printf("...(%d lsg)",delta.length());
                ind=NULL;
            }
        }
        printf("]\n");
        printf(" relation 1 (%p):\n",rel1);
        rel1->test();
        printf(" relation 2 (%p):\n",rel2);        
        rel2->test();
        printf("\n.");
    }
}

void JoinProjNode::structureTest()
{
    printf("[00;00;33m");
    printf("JoinProj(");
    printf("[00;00;30m");
    rel1->structureTest();
    printf("[00;00;33m");
    printf(",");
    printf("[00;00;30m");
    rel2->structureTest();
    printf("[00;00;33m");
    printf(")");
    printf("[00;00;30m");
}

Pix JoinProjNode::add(Tupel item)
{
    if (bag!=NULL) 
    {
        return bag->add(item);
    } else return Relation::add(item);
}


void JoinProjNode::RestoreDelta()
{    
    rel1->RestoreDelta();
    rel2->RestoreDelta();
}

void JoinProjNode::RemoveDelta()
{
    rel1->RemoveDelta();
    rel2->RemoveDelta();
}

void JoinProjNode::AufBagUmschalten()
{
    if ((bag==NULL) && (!RepeatCalc) && (!link) && (!solutions)) 
    {
         //structureTest();
         //printf(" --- Switching to bag!!!!\n");
        TUPELBAG *dummy=new TUPELBAG;
        if (length()) 
        {
             //printf("transfering current data into bag...");
            Pix i=first();
            while (i) { dummy->add((*this)(i));next(i);}
             //printf("done\n");
        }
        bag=dummy;
    }
}



int JoinProjNode::contains(Tupel  item)
{
    if (bag!=NULL) {
        return bag->contains(item);
    }
    return Relation::contains(item);
}

void JoinProjNode::clear()
{
    if (bag!=NULL) bag->clear();
    else Relation::clear();
}

Pix JoinProjNode::first()
{
    if (bag!=NULL) return bag->first();
    else return Relation::first();
}

void JoinProjNode::next(Pix& i)
{
    if (bag!=NULL) bag->next(i);
    else Relation::next(i);
}

Pix JoinProjNode::firstGetAll()
{
    if (bag!=NULL) 
    {
        return bag->first();
    }
    else return Relation::firstGetAll();
}

void JoinProjNode::nextGetAll(Pix& i)
{
    if (bag!=NULL) bag->next(i);
    else Relation::nextGetAll(i);
}

Tupel& JoinProjNode::operator () (Pix i)
{
    if (bag!=NULL) return (*bag)(i);
    else return ((Relation)(*this))(i);
}

void JoinProjNode::operator |=(TUPELSET& y)
{
    if (bag!=NULL) 
    {
        Pix ind=y.first();
        while (ind) 
        {
            bag->add(y(ind));
            y.next(ind);
        }
    } else *(TUPELSET*)(this)|=y;
}


int JoinProjNode::owns(Pix i)
{
    if (bag!=NULL) return bag->owns(i);
    else return Relation::owns(i);
}


int JoinProjNode::length()
{
    if (bag!=NULL) return bag->length();
    else return Relation::length();
}

void JoinProjNode::GetDelta(TUPELSET& d)
{
    if (bag!=NULL) 
    {
        Pix i=bag->first();
        while (i)
        {
            d.add((*bag)(i));
            bag->next(i);
        }
    } else Relation::GetDelta(d);
}

void JoinProjNode::GetDelta(TUPELBAG& d)
{
    if (bag!=NULL) 
    {
        Pix i=bag->first();
        while (i)
        {
            d.add((*bag)(i));
            bag->next(i);
        }
    } else Relation::GetDelta(d);
}

void JoinProjNode::CollectData(DataCollector* jdc) 
{
    rel1->CollectData(jdc);
    rel2->CollectData(jdc);
    jdc->saveData(jdc->JoinConditions(),jc);
    jdc->saveData(jdc->AttrLists(),al);
}

SIMPLECROSS::SIMPLECROSS(Relation *rela)
{
    laenge=0;
    rel=rela;
    konstanten=NULL;
    OwnSolutions=1;
    solutions=NULL;
    not_calculated=1;
    link=NULL;
    Token=NULL;
    negation=0;
//    SetSize(laen+rel->GetSize());
     // funzt not bei joinprojnodes...
     //   SetSize(rel->GetSize());
     //printf("simplecross creates\n");
}

void SIMPLECROSS::test()
{
    printf("SIMPLECROSS: \n");
    Relation::test();
    TUPELSET dummy;
    GetDelta(dummy);
    Pix i = dummy.first();
    printf("delta: [");
    int zaehler=0;
    while (i) {
        (dummy)(i).test();
        dummy.next(i);
        zaehler++;
        if (zaehler>MaxLsg) 
        {
            printf("...(%d lsg)",delta.length());
            i=NULL;
        }
    }
    printf("]\n");
    printf("relation: \n");
    rel->test();
    printf("Konstanten: \n");
    if (konstanten) {
        for (int a=0;a<laenge;a++)
        {
            if (konstanten[a]) 
                if (konstanten[a]->GetType()==TUPEL_OID) printf("  %d: id_%ld\n",a,((TOID)*konstanten[a]).GetId());
                else printf("  %d: %s\n",a,(*konstanten[a]).get_symid().get_name());
            else printf("  %d: constant not lesbar!\n",a);
        }
    } else printf("  no Konstanten\n");
}

void SIMPLECROSS::structureTest()
{
     //   printf("SimpleCross(");
    printf("[00;00;30m");
    rel->structureTest();
     //printf(")");
}


void SIMPLECROSS::GetDelta(TUPELSET &d)
{
    d|=delta;
}


void SIMPLECROSS::GetDelta(TUPELBAG &d)
{
    for (Pix i=delta.first();i;delta.next(i))
    {
        d.add(delta(i));
    }
}

int SIMPLECROSS::calc() 
{
     //printf("Simplecross calc\n");   
    rel->Token=(JoinProjNode*)rel;
    rel->RepeatCalc=1;
    if ((!rel->calc()) && (rel->OwnSolutions)) return 0;
    SetSize(rel->GetSize()+laenge);
    Tupel *tupel=new Tupel(GetSize());
     //rechnen mit GetDelta() 
    TUPELBAG bag;
    rel->GetDelta(bag);
    deltaclear();
    if (!rel->negation) 
    {    
        for (Pix i=bag.first();i;bag.next(i))
        {
            *tupel=(bag)(i);
             //printf("SIMPLECROSS:: schreibe delta: ");
            for (int a=0;a<laenge;a++)
                (*tupel)[a+rel->GetSize()]=*konstanten[a];
             //tupel->test();
             //printf("\n");
            add(*tupel);
        }
    } else {
        for (int a=0;a<laenge;a++)
            (*tupel)[a+rel->GetSize()]=*konstanten[a];
        add(*tupel);
    }
    not_calculated=0;
     //printf("ende\n");
    
    return 1;
}

int SIMPLECROSS::calc(Relation &rel)
{
    SetSize(rel.GetSize()+laenge);
    Tupel *tupel=new Tupel(GetSize());
     //rechnen mit GetDelta() 
    TUPELBAG bag;
    for (Pix ind=rel.first();ind;rel.next(ind))
    {
        bag.add(rel(ind));
    }
    rel.clear();
    if (!rel.negation) 
    {    
        for (Pix i=bag.first();i;bag.next(i))
        {
            *tupel=(bag)(i);
             //printf("SIMPLECROSS:: schreibe delta: ");
            for (int a=0;a<laenge;a++)
                (*tupel)[a+rel.GetSize()]=*konstanten[a];
             //tupel->test();
             //printf("\n");
            rel.add(*tupel);
        }
    } else {
        for (int a=0;a<laenge;a++)
            (*tupel)[a+rel.GetSize()]=*konstanten[a];
        rel.add(*tupel);
    }
    not_calculated=0;
     //printf("ende\n");
    
    return 1;
}


void SIMPLECROSS::addKonst(TupelElement *konst)
{
    laenge++;
     //printf("SIMPLECROSS::add : ");
     //if (konst->GetType()==TUPEL_OID) printf("id_%ld (%d)\n",((TOID)*konst).GetId(),laenge);
     //else printf("%s (%d)\n",((SYMID)*konst).get_name(),laenge);
    if (konstanten)
    {
        TupelElement **dummy;
        dummy=new TupelElement*[laenge];
        for (int a=1;a<laenge;a++) dummy[a]=konstanten[a-1];
        delete konstanten;
        konstanten=dummy;
    } else konstanten=new TupelElement*[laenge];        
    konstanten[0]=konst;
    SetSize(GetSize()+1);
}

void SIMPLECROSS::RestoreDelta()
{
    rel->RestoreDelta();
}

void SIMPLECROSS::RemoveDelta()
{ 
   rel->RemoveDelta();
}

void SIMPLECROSS::CheckForRule( class Fixpoint *fixpoint )
{
     //printf("SIMPLECROSS::CheckForRule\n");
    rel->CheckForRule( fixpoint );
}

void SIMPLECROSS::CollectData(DataCollector *jdc)
{
    jdc->saveData(jdc->SimpleCross(),this);
    rel->CollectData(jdc);
}

void AlgDescription::SetHead(char *name,int anz,char **konst)
{
    functor.set(name,anz,konst);
//    konstanten=konst;
}

void AlgDescription::SetHead(long unsigned int h)
{
    head=h;
}


long unsigned int AlgDescription::GetHead()
{
    return head;
}

void AlgDescription::SetBody(Relation *b)
{
    if (b==NULL) 
    {
        ok=0;
         //printf("AlgDescription canceled\n");
        return;
    } else ok=1;
    body = b;
    body->solutions=this;
    link=NULL;
    solutions=NULL;
    globDelta=NULL;
    KeineLsg=0;
    PatternArity=0;
    PatternKonstanten=NULL;
}

Relation *AlgDescription::GetBody()
{
    return body;
}

C_Functor& AlgDescription::Functor()
{
    return functor;
}


//BP_Functor AlgDescription::Functor()
//{
//    BP_Functor functor;
//    GET_VALUE(head, BP_T_STRUCTURE, &functor);
//    return functor;
//}


Tupel AlgDescription::map(Tupel tupel)
{
    Tupel TupelNeu(JoinCondition::length());
    for (int a=0;a<JoinCondition::length();a++)
    {
        TupelNeu[get(a,1)]=tupel[get(a,0)];
    }
    return TupelNeu;
}

Tupel& AlgDescription::map2(Tupel tupel)
{
//    tuple tupelNeu(JoinCondition::length());
    Tupel* tupelNeu=new Tupel(JoinCondition::length());
    for (int a=0;a<JoinCondition::length();a++)
    {
        (*tupelNeu)[get(a,1)]=tupel[get(a,0)];
    }
    return (*tupelNeu);

}

/*
Tupel AlgDescription::mapNegativ(Tupel tupel)
{
    printf("mappe: ");tupel.test();
    Tupel tupelNeu(tupel.GetSize()-JoinCondition::length());
    int b=1;
    int InJC;
    for (int a=0;a<tupel.GetSize();a++)
    {
        InJC=0;
        for (int jc=0;jc<JoinCondition::length();jc++)
            if (a==get(jc,0)) InJC=1;
        if (!InJC)
        {
            tupelNeu[b]=tupel[a];
            b++;
        }   
    }
    printf(" to ");
    tupelNeu.test();
    printf("\n");
    return tupelNeu;
}
*/

//dieses Map is not more uses.
//stattdessen are die einzelnen tuple mit map
//beim algdescription::add gemappt
//Grund: die entscheidung ob mapping or not wurde
//durch die solutions-zeiger erschwert
/*
void AlgDescription::Map()
{
    if (solutions==NULL) return;
    if (solutions!=this)
    {
        deltaclear();
        return;
    }
    Relation *relation=GetBody();
    if (relation->link) {printf("mapping refused\n");return;}
    printf("start mapping\n");
    Relation tmp(relation->GetSize(),relation->key);
    TUPELSET tmpdelta;
    tmp |= *relation;
    relation->clear();
    relation->SetSize(JoinCondition::length());
    Tupel tupel(JoinCondition::length());
    for (Pix i=tmp.first();i;tmp.next(i))
    {
        if (relation->delta.contains(tmp(i)))
        {
            for (int a=0;a<JoinCondition::length();a++)
            {
                tupel[get(a,1)]=tmp(i)[get(a,0)];
            }
            if (!relation->contains(tupel))
            {
                relation->TUPELSET::add(tupel);
                tmpdelta.add(tmp(i));
            }
        } else relation->TUPELSET::add(tmp(i));
    }
    tmp.clear();
    relation->delta.clear();
    relation->delta|=tmpdelta;
    tmpdelta.clear();
}
*/

void AlgDescription::CheckForRule(Fixpoint *fixpoint)
{
     //printf("AlgDescription::CheckForRule (%s)\n",GetHeadline());
    
     //here are die AlgDescriptions mit gleichem head
     //zu a Kreis verbunden (durch link)
     //dabei are die konstanten not beachtet
    AlgDescription *next;
        //fragt den fixpoint nach rules mit gleichem functor
        //der sucht zuerst in the anderem fixpoints, if da
        //no are, then im eigenen
        //if it gar no gives, kommt here ein zeiger auf sich selbst
        //return
    if (!link) {
         //einen Functor without konstanten erzeugen, because die not mit checks are sollen
        C_Functor func(Functor().name(),Functor().len());
        next=fixpoint->GetAlgDescrReverse(func);
         //if ((next!=this) && (next) && (next->link)) printf("algdescr %s(%p): fuege mich between %s(%p) and %s(%p) ein\n",GetHeadline(),this,next->GetHeadline(),next,next->link->GetHeadline(),next->link);
         //if ((next!=this) && (!next->link) && next) printf("algdescr %s(%p): fuege mich hinter %s(%p) ein\n",GetHeadline(),this,next->GetHeadline(),next);    
        if (!next->link) link=next; else link=next->link;
        next->link=this;
    }
    
        //then can the body seine links setzen
    GetBody()->CheckForRule(fixpoint);
    if (!GetBody()->OwnSolutions) KeineLsg=1;
    jdc=new DataCollector();
    GetBody()->CollectData(jdc);
     //jdc->print(0);
}

char *AlgDescription::GetHeadline()
{
//    BP_Atom atom;
//    GET_NAME_ARITY(Functor(),&atom,&arity);
    char *dummy=new char[100];
    dummy[0]='\0';
    strcpy(dummy,Functor().name());
    dummy[strlen(dummy)+1]='\0';
    dummy[strlen(dummy)]='[';
    for (int a=0;a<Functor().len();a++)
    {
        if (Functor()[a]!=NULL) strcat(dummy,Functor()[a]); 
        else strcat(dummy,"VAR");
        dummy[strlen(dummy)+1]='\0';
        dummy[strlen(dummy)]=',';
    }
    dummy[strlen(dummy)-1]=']';
    return dummy;
}


void AlgDescription::test()
{
//    BP_Atom atom;
//    GET_NAME_ARITY(Functor(),&atom,&arity);
    printf("[00;00;31m*******************************************************\n");
    Functor().test();
    printf("Rule: %s",GetHeadline());
    printf("] (%p)\n",this);
    jdc->test();
    printf("[00;00;30m");
    printf(" Mapping:\n");
    int anz;
    printf("  number: %d\n",anz=JoinCondition::length());
    for (int a=0;a<anz;a++)
        printf("  condition %d: %d==%d\n",a+1,get(a,0),get(a,1));
    if (link) printf("Umgelenkt (on %p) !\n",link);
    printf("solutions=%p\n",solutions);
    if (KeineLsg) printf("Keine eigenen solutions : JA\n");
    GetBody()->test();
    printf("Rule-Data: [");    
    Pix i;
    int zaehler=0;
    for (i=first();i;next(i))
    {
        printf("(%p)",alg);
        (*this)(i).test();
        zaehler++;
        if (zaehler>MaxLsg) 
        {
            printf("...(%d lsg)",length());
            break;
        }
    }
    printf("]; \n");

    if (!globDelta) {printf("globDelta=NULL\n");return;}
    
    printf("globDelta: [");
    for (i=globDelta->first();i;globDelta->next(i))
    {
        (*globDelta)(i).test();
        zaehler++;
        if (zaehler>MaxLsg) 
        {
            printf("...(%d lsg)",globDelta->length());
            break;
        }
    }
    printf("]; \n");
}

void AlgDescription::structureTest()
{
//    BP_Atom atom;
//    GET_NAME_ARITY(Functor(),&atom,&arity);
    printf("[00;00;30m");
    printf("%s[",Functor().name());
    if (Functor().konst())
        for (int a=0;a<Functor().len();a++)
        {
            if (Functor()[a]!=NULL) printf("%s",Functor()[a]); else printf("_");
            if (a<Functor().len()-1) printf(",");
        }
    printf("] :- ");
    GetBody()->structureTest();
    printf("[00;00;30m");
    printf("\n");
    
}

int AlgDescription::GetSize()
{
    if (solutions) return solutions->GetBody()->GetSize();
    else return GetBody()->GetSize();
}

//this function stands in Konflikt mit Condition::length()
//Vorsicht beim Umgang so that!
//returns anzahl der lsg in a rule return
int AlgDescription::length()
{
    AlgDescription *next=link;
    int laenge=0;
    if (IsCalculated()) laenge=GetBody()->length();
    while (next!=this)
    {
        if (next->IsCalculated()) laenge+=next->GetBody()->length();
        next=next->link;
    }
    return laenge;
}

    
int AlgDescription::NewSolutions()
{
    if (!globDelta) return 0;
    return globDelta->length();
}

//here is eine lsg stored
//ausserdem are solutions and globdelta unter den AlgDescriptions
//"abgesprochen"
Pix AlgDescription::add(Tupel tupel)
{
    if (!solutions)
    {
         //solutiuon ist am Anfang NULL (SetHead())
         //here is es auf this gesetzt, so that speichern alle rulen ihre solutions
         //in the eigenen Bodies. Nur das global delta (globDelta) is set under allen
         //gelinkten rulen abgesprochen. Es bekommt the rule, die zuerst solutions.
         //solutions existiert only, so that the possibility besteht, that the rulen
         //ihr solutions vielleicht einmal zusammen abspeichert. Das w\"urde the 
         //auslesen beschleunigen, wirft aber Problem beim delta auf.
        AlgDescription *dummy=alg;
        Pix i=first();
        if (i)
        {
            solutions=this;
            globDelta=alg->globDelta;
            if (!globDelta) { alg->globDelta=new TUPELSET;globDelta=alg->globDelta;}
        }
        else
        {
            globDelta=new TUPELSET;
            solutions=this;
        }
        alg=dummy;
    }
  
    Tupel TupelNeu=map(tupel);
    
    if (!GetBody()->contains(TupelNeu)) GetBody()->delta.add(TupelNeu);
    solutions->GetBody()->TUPELSET::add(TupelNeu);
    solutions->GetBody()->OwnSolutions=1;
}

/*
Pix AlgDescription::add_mapping(Tupel tupel)
{
    map(tupel);
    return add(tupel);
}
*/

void AlgDescription::deltaclear()
{
//    if (solutions) solutions->GetBody()->delta.clear(); else GetBody()->delta.clear();
    GetBody()->delta.clear();
}


//returns true, if these AlgDescription loesungen haben koennte, die also
//zu of a AlgDescription mit arity2 and konstanten2 passen
//zusaetzlich are still die namen der konstanten checks
int AlgDescription::match(int arity2, char** konstanten2)
{
    if ((arity2==0) || (konstanten2==NULL)) return 1;
    if (Functor().len()!=arity2) return 0;    
    for (int a=0;a<Functor().len();a++)
    {
        if ((Functor()[a]!=NULL) && (konstanten2[a]!=NULL) && (strcmp(Functor()[a],konstanten2[a]))) return 0;
    }
    return 1;
}

//checks, ob das tupel (als lsg this algdescr) zu den werten arity2 and
//konstanten2 of a literales passt, that auf this algdescr gelinkt ist
int AlgDescription::match(int arity2,char **konstanten2, Tupel &tupel)
{
     /* printf("vergleiche: ");
        printf("[");
        if (konstanten2) 
        { 
           for (int a=0;a<arity2;a++)
           {
           if (konstanten2[a]!=NULL) printf("%s ",konstanten2[a]); else printf("VAR ");
           }
        }
        printf("] with ");
        tupel.test();
        printf("\n");
     */
    if ((arity2==0) || (konstanten2==NULL)) return 1;
    if (tupel.GetSize()!=arity2) return 0;    
    for (int a=0;a<arity2;a++)
    {
        if (konstanten2[a]!=NULL)
        {   
            if (tupel[a].GetType()==TUPEL_OID) 
            {
                char *s=new char[9];
                ((TOID)tupel[a]).GetOid(s);
                if (strcmp(s,konstanten2[a])) { delete s;return 0;}
                delete s;
            } else {
                if (strcmp((tupel[a].get_symid()).get_name(),konstanten2[a])) return 0;
            }
        }
    }
    return 1;
}


//checks, ob Func zu tupel passt.
//if Func an of a stelle, die not frei is, eine andere konstante
//eingetragen hat als tupel, then passt es not
int AlgDescription::match(C_Functor &Func, Tupel &tupel)
{
    if ((Func.len()==0) || (Func.konst()==NULL)) return 1;
    if (tupel.GetSize()!=Func.len()) return 0;
    for (int a=0;a<Func.len();a++)
    {
        
        if (Func[a]!=NULL)
        {  
            if (tupel[a].GetType()==TUPEL_OID) 
            {
                if (Func.oid()[a]!=-1) 
                {
                    if (Func.oid()[a]!=((TOID)(tupel[a])).GetId()) 
                    {
                        return 0; 
                    } 
                     //an this stelle sollte ein oid-eintrag uses are, 
                     //der not vorhanden ist!
                } else printf("*******C_Functor::operator== ups************\n");
            } else {
                if (Func.oid()[a]!=-1)
                    if ((tupel[a].get_symid()).get_sum()!=Func.oid()[a])
                    {
                        return 0;
                    }
                if (strcmp((tupel[a].get_symid()).get_name(),Func[a]))
                {
                    return 0;
                }
            }
        }
    }
    return 1;
}

//lohnt sich eine erneute Berechnung?
int AlgDescription::LohntBerechnung()
{
     //if still nie berechnet ---> ja
    if (!GetBody()->IsCalculated()) return 1;

     //if already mal berechnet and no links ---> nein
    if (!jdc->HasGotLinks()) return 0;    

     //otherwise links ueberpruefen...
    AlgDescription *dummy;
    int a=0;
    do
    {
        dummy=(AlgDescription*)jdc->getNrOf(jdc->Links(),a);
        a++;
         //if aer der links new Lsg hat ---> ja
        if ((dummy) && (dummy->NewSolutions())) 
        {
            return 1;
        }
        
    } while (dummy);    
     //otherwise ---> nein
    return 0;
}


int AlgDescription::calc()
{
//    printf("berechne: %s\n",GetHeadline());

    TUPELSET dummy;
     //das alte delta sichern (siehe unten)
    dummy|=GetBody()->delta;
     //den token der ersten relation geben
    GetBody()->Token=(JoinProjNode*)GetBody();
     //ist wahrscheinlich already eins, abba sicher ist sicher
    GetBody()->RepeatCalc=1;
    int i=1;
     //this variante ignoriert die struktur and rechnet alles partially from
    if (LohntBerechnung()) i=start_join_proj();
     //if partially fehl schlaegt, mal normal versuchen
    if (i==0) i=GetBody()->calc(); 
     //so that das kopieren der daten angestossen is
    if (GetBody()->isAdotLabel) ((Literal*)GetBody())->AdotAusnahmeBehandeln();
     //if still no globales delta abgemacht wurde...
    if (!globDelta) globDelta=new TUPELSET;
     //new Lsg dazu
    GetBody()->GetDelta(*globDelta);
     //also die gelinkten deltas ins delta
    GetBody()->GetDelta(GetBody()->delta);
        //die alten (from der letzten berechnung this relation) raus
    (*globDelta)-=dummy;
     
    return i;
}

int AlgDescription::start_join_proj()
{
     //printf("start_join_proj\n");

     //only if ae 2. relation da is 
    if (jdc->getNrOf(jdc->Literals(),1)) 
    {
         //first relation auslesen
        Relation *rel=(Relation*)(jdc->getNrOf(jdc->Literals(),0));
        Relation *dummy;
        SIMPLECROSS *sc=NULL;
         //if ein simplecross vorhanden is...
        if (jdc->HasGotSimpleCross()) sc=(SIMPLECROSS*)(jdc->getNrOf(jdc->SimpleCross(),0));
         //first relation complete ausrechnen
        rel->calc();
         //printf("calc: %d ergebnisse\n",rel->length());
        int a=0;
        int berechnet=0;
        Relation ergebnis;
        TUPELBAG bag;

         //if first relation gelinkt is...
        if ((rel->link) && (rel->LinkZeigtAufEigenenFixpoint))
        {
            berechnet=1;
            TUPELBAG bag;
             //einmal mit deltas ausrechnen (geht still weiter!)
            rel->GetDelta(bag);            
            ProgressView pv(bag.length(),40);
            for (Pix ind=bag.first();ind;bag.next(ind))
            {        
                join_proj(ergebnis,(bag)(ind),jdc,1);
                pv.step(1);
            }   
            a=1;
        }
         //alle lsg of rel 1 in ein bag schreiben
        for (Pix ind=rel->firstGetAll();ind;rel->nextGetAll(ind))
        {
            bag.add((*rel)(ind));
        }
         //for jede andere (also ausser der ersten) relation eine schleife
        while (jdc->getNrOf(jdc->Literals(),a))
        {
            dummy=(Relation*)(jdc->getNrOf(jdc->Literals(),a));
             //only if sich eine berechnung mit deltas lohnt...
            if ((dummy->link) && (dummy->LinkZeigtAufEigenenFixpoint))
            {
                berechnet=1;
                dummy->Token=(JoinProjNode*)GetBody();
                ProgressView pv(rel->length(),40);
                for (Pix ind=bag.first();ind;bag.next(ind))
                {        
                    join_proj(ergebnis,bag(ind),jdc,1);
                    pv.step(1);
                }
                dummy->Token=NULL;
            }
            a++;
        }
         //if bisher nix berechnet wurde, 
         //einmal komplett (not mit deltas!) ausrechnen
        if (!berechnet)
        {
            ProgressView pv(rel->length(),40);
            for (Pix ind=bag.first();ind;bag.next(ind))
            {
                join_proj(ergebnis,bag(ind),jdc,1);
                pv.step(1);
            }
        }
        
         //printf("start_join_proj: %d ergebnisse \n",ergebnis.length());
        
        GetBody()->not_calculated=0;
         //schnell still konstanten einfuegen
        if (sc) sc->calc(ergebnis);
         //solutions in ergebnisrelation schreiben
        for (Pix ind2=ergebnis.first();ind2;ergebnis.next(ind2))
        {
            add(ergebnis(ind2));
        }
         //printf("alterset:\n");
         //alterset.test();
         //printf(" (now %d lsg)\n",GetBody()->length());
    } else {
         //if only eine relation da war, nix tun
        return 0;
    }
    return 1;
}


int AlgDescription::join_proj(Relation &ergebnis,Tupel MainTupel,DataCollector *jdc,int pos)
{
     //printf("join_proj\n");
    Pix ind2;
    int i,j,zwischen_ts;
     //join-daten auslesen
    JoinCondition *jc=(JoinCondition*)(jdc->getNrOf(jdc->JoinConditions(),pos-1));
    BuiltinLiteral *set2=(BuiltinLiteral*)(jdc->getNrOf(jdc->Literals(),pos));
    AttrList *al=(AttrList*)(jdc->getNrOf(jdc->AttrLists(),pos-1));

     //es is MainTupel mit set2 joined
     //dabei is bedingung jc beachtet and abschliessend auf al projeziert

    int MainSize=MainTupel.GetSize(),set2Size=set2->GetSize();

     //printf("joine: %d %d",MainTupel.GetSize(),set2->GetSize());
     //MainTupel.test();
      //printf(" with ");
     //set2->structureTest();
     //printf("\n");    
    
    int LetzterInKette=1;
    if (jdc->getNrOf(jdc->Literals(),pos+1)) LetzterInKette=0;
     //if (LetzterInKette) printf("(Letzter in Kette) ");
    
     //variablen for die between.- and endergebnise dimensionieren
    Tupel tupel(zwischen_ts = jc->result_length(MainSize,set2Size));
    ergebnis.SetSize(al->length());
  
    
    int feld2_anz;
    int feld2[zwischen_ts];

    for (i=j=0;i<set2Size;i++)
    {
        if (jc->result_contains(i))
        {
            feld2[j++]=i;
        }
    }
    feld2_anz = j;
    Tupel t2(set2Size),t;
    TUPELBAG tmp;
    Tupel dummy(set2Size);

    tupel=MainTupel;
     //Elemente of t2 auf Frei setzen
    t2=dummy;
    for (i=0;i<jc->length();i++)
    {        
        t2[jc->get(i,1)]=MainTupel[jc->get(i,0)];
    }
     //set2->structureTest();
     //printf("(%d) : ",set2->length());
    set2->query(t2,tmp);


     //if (LetzterInKette) printf(" %d lsg stored\n",tmp.length());
     //set2->test();
    
     //printf("\n");
     //ProgressView pv(tmp.length(),20);
     //printf("%d ergebnisse| ",tmp.length());
     //printf("liefere: [");
     //for (ind2=tmp.first();ind2;tmp.next(ind2))
     //{
     //    tmp(ind2).test();
     //printf(" ");
     //}
     //printf("]\n");
    for (ind2=tmp.first();ind2;tmp.next(ind2))
    {
        for (i=0;i<feld2_anz;i++)
            tupel[MainSize+i]=tmp(ind2)[feld2[i]];

        if (LetzterInKette) 
        {
             //printf("SPEICHERE: ");
             //tupel.proj(*al).test();
             //printf("\n");
            ergebnis.add(tupel.proj(*al));
        } else {
             //pv.step(1);
             //printf("bearbeite: ");
             //tupel.proj(*al).test();
             //printf(" ---> ");
            join_proj(ergebnis,tupel.proj(*al),jdc,pos+1);
        }
    }
     //printf("join ende\n");
    
    return 1;
} 

//setzt das tuple-Muster, that zu of a Lsg passen must, die returned is
void AlgDescription::SetPattern(int arity2, char** konstanten2)
{
    PatternArity=arity2;
    PatternKonstanten=konstanten2;
}


//findet die first zu den eigenen daten (konstanten, arity) matching algdescription
Pix AlgDescription::first()
{
     //printf("algDescription::first()\n");
    
    alg=this;
    Pix start=GetBody()->firstGetAll();
    if (!((start) && (IsCalculated()))) { alg=alg->link;start=NULL;} else return start;
        //solange no AlgDescription gefunden wurde, dessen relation:
        //  Werte besitzt (start)
        //  berechnet is (IsCalculated())
        //  zum Pattern passt (mit SetPattern gesetzt)
        //  and gleich this is (only einmal im Kreis, then Abbruch)
    while (!((start=alg->GetBody()->firstGetAll()) &&
             (alg->IsCalculated())
             && (alg->match(PatternArity,PatternKonstanten))
             )
           && (alg!=this)) 
    { 
        alg=alg->link;
//        printf("teste alg %p (next=%p)\n",alg,alg->link);
    }
    if (alg==this) start=NULL;
    return start;
}

//returns the naechsten wert and springt also zur naechsten alsdescription, if noetig
void AlgDescription::next(Pix  & idx)
{
    alg->GetBody()->nextGetAll(idx);
    if (!idx)
    {
        Pix start=NULL;
        alg=alg->link;
        while (!((start=alg->GetBody()->firstGetAll()) &&
                 (alg->IsCalculated()) 
                 && (alg->match(PatternArity,PatternKonstanten))
                 )
               && (alg!=this)) alg=alg->link;
        if (alg==this) start=NULL;
        idx=start;
    }   
}

Tupel& AlgDescription::operator ()(Pix   idx)
{
     //dieses mapping ist for lsg, die gelinkt in die oberste rel of a
     //algdescr kamen and somit still not passend for die algdescr gemappt wurden
    if ((alg->KeineLsg) || (!(alg->GetBody()->SolutionsLocal())))
    {
         //printf("AlgDescr: mappe ");
         //(*(alg->GetBody()))(idx).test();
         //printf(" to ");
         //alg->map((*(alg->GetBody()))(idx)).test();
         //printf("\n");
        return alg->map2((*(alg->GetBody()))(idx));
    }
    return (*(alg->GetBody()))(idx);
}


void AlgDescription::operator |= (TUPELSET& y)
{
    (*GetBody())|=y;
}    


void AlgDescription::clear()
{
    GetBody()->clear();
}

int AlgDescription::contains (Tupel  item)
{
    
    return GetBody()->TUPELSET::contains(item)!=0;
}

int AlgDescription::owns (Pix   idx)
{
    return GetBody()->owns(idx);
}

//uebertragt alle matchingn delta-tuple nach d
void AlgDescription::GetDelta(TUPELSET& d)
{
    alg=this;
    do
    {
        if (alg->globDelta)
            for (Pix i=alg->globDelta->first();i;alg->globDelta->next(i))
            {
                if (match(PatternArity,PatternKonstanten,(*alg->globDelta)(i)))
                {
                    d.add((*alg->globDelta)(i));
                }
            }
        if (alg->link) alg=alg->link;
        if ((!link) && (alg!=this)) printf("AlgDescription: link-Kette not geschlossen!\n");
    } while (alg!=this);
}

//uebertragt alle matchingn delta-tuple nach d
void AlgDescription::GetDelta(TUPELBAG& d)
{
    alg=this;
    do
    {
        if (alg->globDelta)
            for (Pix i=alg->globDelta->first();i;alg->globDelta->next(i))
            {
                if (match(PatternArity,PatternKonstanten,(*alg->globDelta)(i)))
                    d.add((*alg->globDelta)(i));
            }
        if (alg->link) alg=alg->link;
        if ((!link) && (alg!=this)) printf("AlgDescription: link-Kette not geschlossen!\n");
    } while (alg!=this);
}

C_Functor FixpointNode::GetFunctor()
{
    return ad->Functor();
}

Relation *FixpointNode::GetBody()
{
    return ad->GetBody();
}
 
void FixpointNode::CheckForRule(class Fixpoint *fixpoint)
{
    ad->CheckForRule(fixpoint);
}

void
Fixpoint::add(AlgDescription *ad)
{
    if (ad==NULL) 
    {
        ok=0;
         //printf("fixpoint:add ungueltige AlgDescription...\n");
        return;
    } 
    
    if (fpn)
        fpn = fpn->Next() = new FixpointNode(ad,fpn->Next());
    else
    {
        start = fpn = new FixpointNode(ad,NULL);
        fpn->Next() = fpn;
    }
}

AlgDescription
*fixpoint::GetAlgDescr(C_Functor &functor)
{
    AlgDescription *dummy=GetAlgDescr_WO_advancedCheck(functor);
    if (dummy) return dummy;
    return stratified->GetAlgDescr(functor,this);
}

AlgDescription
*fixpoint::GetAlgDescrReverse(C_Functor &functor)
{
    AlgDescription *dummy=stratified->GetAlgDescr(functor,this);
    if (dummy) return dummy;
    return GetAlgDescr_WO_advancedCheck(functor);
}

AlgDescription
*fixpoint::GetAlgDescr_WO_advancedCheck(C_Functor &functor)
{
//    printf("GetAlgDescr_WO_advancedCheck: \n");
//    printf("frage after %s in fixpoint %d\n",functor.name,this);
    FixpointNode *fpn;
    fpn = start;
    do
    {
        if (functor == fpn->GetFunctor())
        {
//            printf("gefunden\n");
            return fpn->GetAlgDescr();
        }
         //}
        fpn = fpn->Next();
    }
    while (fpn != start);
//    printf("nix gefunden\n");
    return NULL;
}

void
Fixpoint::RestoreDeltas()
{
    FixpointNode *fpn;
    fpn = start;
    do
    {
        fpn->GetAlgDescr()->GetBody()->RestoreDelta();
        fpn = fpn->Next();
    }
    while (fpn != start);
}

void
Fixpoint::RemoveDeltas()
{
    FixpointNode *fpn;
    fpn = start;
    do
    {
        fpn->GetAlgDescr()->GetBody()->RemoveDelta();
        fpn = fpn->Next();
    }
    while (fpn != start);
}

void
Fixpoint::CheckRules(stratified_rules *strati)
{
    stratified=strati;
    FixpointNode *fpn;
    fpn = start;
    do
    {
        fpn->CheckForRule(this);
        fpn = fpn->Next();
    }
    while (fpn != start);
}

void
Fixpoint::CheckRules()
{
    FixpointNode *fpn;
    fpn = start;
    do
    {
        fpn->CheckForRule(this);
        fpn = fpn->Next();
    }
    while (fpn != start);
}

int Fixpoint::ContainsAlgDescr(AlgDescription* alg)
{
    FixpointNode *fpn;
    fpn = start;
    do
    {
        if (fpn->GetAlgDescr()==alg) return 1;
        fpn = fpn->Next();
    }
    while (fpn != start);
    return 0;
}


void
Fixpoint::test()
{
    int i;
    FixpointNode *fpn;
    fpn = start;
    i = 0;
    do
    {
        printf("[03;00;33m");
        printf("rule %d:\n",++i);
        printf("FixpointNode: %s/%d.(%p)\n",fpn->GetFunctor().name(),fpn->GetFunctor().len(),fpn);
        printf("[00;00;30m");
        fpn->GetAlgDescr()->test();
        fpn = fpn->Next();
    }
    while (fpn != start);
}

void
Fixpoint::structureTest()
{
    int i;
    FixpointNode *fpn;
    fpn = start;
    i = 0;
    do
    {
        fpn->GetAlgDescr()->structureTest();
        fpn = fpn->Next();
    }
    while (fpn != start);
}

void
Fixpoint::calc()
{
    int i=0,Abbruch=0,Remove=1;
    FixpointNode *fpn=start;
    FixpointNode *lastWithSolutions=NULL;
    while (!Abbruch)    
    {
        if (fpn==start) i=0;
         //printf("************************************************************************************\n");    
         //printf("rule ");fpn->GetAlgDescr()->structureTest();printf("\n");
         //fpn->GetAlgDescr()->test();
        fpn->GetAlgDescr()->calc();
         //fpn->GetAlgDescr()->test();
         //printf("%d new solutions (of %d)\n",fpn->GetAlgDescr()->NewSolutions(),fpn->GetAlgDescr()->length());
        
         /*
           printf("delta: [");    
           Pix i;
           TUPELBAG bag;
           fpn->GetAlgDescr()->GetBody()->GetDelta(bag);
           for (i=bag.first();i;bag.next(i))
           {
           bag(i).test();
           }
           printf("]; \n");
         */

        if (fpn->GetAlgDescr()->NewSolutions()) lastWithSolutions=fpn;
        else if (fpn==lastWithSolutions) Abbruch=1;
         //fpn->GetAlgDescr()->test();
        if (lastWithSolutions==NULL) lastWithSolutions=start;
        fpn=fpn->Next();    
        if ((fpn==start) && (Remove)) 
        {
            fpn->GetAlgDescr()->GetBody()->RemoveDelta();
            Remove=0;
        }
    }
    return;
    
    fpn=NULL;
    printf("**************************************\n");    
    while (fpn!=start)
    {
        if (fpn==NULL) fpn=start;
        printf("**************************************\n");
        fpn->GetAlgDescr()->test();
        fpn=fpn->Next();
    }
}

void
Fixpoint::Set(class TDB* db,TIMEPOINT point,int set,TOID module)
{
        //die variablen db, point, set and module sind in relation als static declariert,
        //deshalb reicht es here from, set only for die first rule auszufuehren
    if (start)
        start->GetBody()->Set(db,point,set,module);
}



void
stratified_rules::add(Fixpoint *fix)
{
    if (fix==NULL)
    {
        ok=0;
        return;
    }
    if (fp)
    {
         //  fix->Next()=fp->Next();
         //  fp = fp->Next() = fix;
        fix->Next()=start;
        start=fix;
        fp->Next()=fix;
    }

    else
    {
        start = fp = fix;
        fp->Next() = fp;
    }
}

void
stratified_rules::test()
{
    int i;
    fp = start;
    i = 0;
    do
    {
        printf("[00;00;34m");
        printf("\n########################################################\n");
        printf("fixpoint %d:\n",++i);
        printf("[00;00;30m");
        fp->test();
        fp = fp->Next();
    }
    while (fp != start);    
}

void
stratified_rules::structureTest()
{   
    int i;
    fp = start;
    i = 0;
    do
    {
        printf("[00;00;34m");
//        printf("\n########################################################\n");
        printf("fixpoint %d:\n",++i);
        printf("[00;00;30m");
        fp->structureTest();
        fp = fp->Next();
    }
    while (fp != start);    
}


void
stratified_rules::calc()
{
    int i;
    fp = start;
    i = 0;
    do
    {
         //  printf("stratified_rules: calculiere fixpoint %d:\n",++i);
        fp->RestoreDeltas();
        fp->calc();
        fp = fp->Next();
    }
    while (fp != start);
     //test();
}


void
stratified_rules::CheckRules()
{
    fp = start;
    do
    {
        fp->CheckRules(this);
        fp = fp->Next();
    }
    while (fp != start);    
}

AlgDescription
*stratified_rules::GetAlgDescr(C_Functor &functor,fixpoint *fixpoint)
{
//    printf("stratified_rules:\n");
    Fixpoint *fix;
    fix = start;
    AlgDescription *dummy;
    do
    {
            //den aufrufenden fixpoint rauslassen, because otherwise dreht man sich im kreis
//        printf("stratified_rules:teste fixpoint %d\n",fp);
        if (fix!=fixpoint) {
            dummy=fix->GetAlgDescr_WO_advancedCheck(functor);
            if (dummy)
            {
//                printf("stratified_rules:gefunden\n");
                return dummy;
            }
            
        }
        fix = fix->Next();
    }
    while (fix != start);
//    printf("stratified_rules:nix gefunden\n");
    
    return NULL;
}

AlgDescription
*stratified_rules::GetMainRule()
{
    fp = start;
    while (fp->Next()!=start) 
    {
        fp = fp->Next();
    }
    FixpointNode *fpn=fp->Start();
    while (fpn->Next()!=fp->Start())
    {
        fpn=fpn->Next();
    }
    return fpn->GetAlgDescr();
}
