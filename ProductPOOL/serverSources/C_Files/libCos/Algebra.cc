/*
The ConceptBase.cc Copyright

Copyright 1987-2023 The ConceptBase Team. All rights reserved.

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
#include "Algebra.h"
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
                 //falls ein Literal eingefuegt werden soll, dass es so schon gibt, wird Link auf das alte gesetzt
                if ((*(Literal*)((*where)[zaehler])).Functor()==(*(Literal*)what).Functor())
                {
                    what=(Literal*)((*where)[zaehler]);
                }
            }
        }
         //Neu ist eins groesser...
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
    
    if ((!pos) && (!LINKs)) printf("keine Links!\n");
    while (LITs[a]!=NULL)
    {
        printf("%d: ",a+1);
        LITs[a]->StrukturTest();printf("(%p) ",LITs[a]);
        if (LINKs)
        {
            if (LINKs[a]!=NULL) printf(" Link set");
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

//first kann eigentlich durch firstGetAll ersetzt werden, nur funktioniert dann
//der |=operator nicht mehr
Pix Relation::first()
{
    lokal=1;
    if ((!OwnSolutions) && (!link))
    {
        printf("Relation::first(%p): Weder OwnSolutions noch link gesetzt!\n",this);
        return NULL;
    }
    if (OwnSolutions) return TUPELSET::first();
    else return link->first();
}

//wie first, nur werden bei bedarf auch die gelinkten lsg mitgeliefert
Pix Relation::firstGetAll()
{
    if ((!OwnSolutions) && (!link))
    {
        printf("Relation::first(%p): Weder OwnSolutions noch link gesetzt!\n",this);
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
    if ((!OwnSolutions) && (!link)) printf("Relation::next(%p): Weder OwnSolutions noch link gesetzt!\n",this);
    if (OwnSolutions)  TUPELSET::next(idx);
    else link->next(idx);
}

//wie next, aber falls die letzte lokale lsg geliefert wurde, werden die gelinkten lsg zurueckgeliefert
void Relation::nextGetAll(Pix  & idx)
{
    if ((!OwnSolutions) && (!link)) 
    {
        printf("Relation::next(%p): Weder OwnSolutions noch link gesetzt!\n",this);
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

//liefert bei bedarf(lokal==false) auch lsg aus link zurueck
Tupel& Relation::operator ()(Pix   idx)
{   
    if ((!OwnSolutions) && (!link)) printf("Relation::operator()(%p): Weder OwnSolutions noch link gesetzt!\n",this);    
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
    if ((!OwnSolutions) && (!link)) printf("Relation::contains: Weder OwnSolutions noch link gesetzt!\n");        
    if (OwnSolutions) return TUPELSET::contains(item)!=0;
    else return link->contains(item)!=0;
}

int Relation::owns (Pix   idx)
{
    if ((!OwnSolutions) && (!link)) printf("Relation::owns: Weder OwnSolutions noch link gesetzt!\n");    
    if (OwnSolutions) return TUPELSET::owns(idx);
    else return link->owns(idx);
}

int Relation::AddCalc(Tupel tupel)
{
    if (!OwnSolutions) printf("Relation::AddCalc: AddCalc aufgerufen auf eine Relations ohne eigene Lsg.!\n");
    int pot,i;
    int bel;
    if (GetSize() != tupel.GetSize())
        {
            printf("AddCalc verweigert wegen falscher Tupelsize!\n");
            tupel.test();printf(" Size ist %d, Size soll %d\n",tupel.GetSize(),GetSize());
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
        //hier wird nicht relation::length benutzt, weil da die links mit beruecksichtigt werden
    if (!TUPELSET::length())
        Belegung=bel;
    else
        if (Belegung != bel)
        {
            printf("AddCalc verweigert wegen falscher Belegung!\n");
            return 0;
        }
    tupel.SetKey(key);
        //es wird nicht Relation::add benutzt, weil
        //dort lsg nach solution geschrieben werden
        //Berechnungen werden aber immer nur lokal ausgefuehrt
  
    if (!contains(tupel)) delta.add(tupel);
    TUPELSET::add(tupel);
    
    not_calculated=1;
    return 1;
}

int Relation::GetSize()
{
     //database ist gesetzt wenn der Fixpoint aufgebaut wurde. Erst dann ist eine Ueberpruefung von Link und OwnSolution sinnvoll
    if (!database) return tupel_size;
    if ((!OwnSolutions) && (!link)) 
    {
        printf("Relation::GetSize(): Eine Relation ohne eigene und ohne gelinkte Lsg. ist aufgetreten!(");
        StrukturTest();
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
        printf("Relation::length(): Eine Relation ohne eigene und ohne gelinkte Lsg. ist aufgetreten!\n");
        return 0;
    }
    if ((OwnSolutions) && (!link)) return TUPELSET::length();
    if ((!OwnSolutions) && (link)) return link->length();
    return TUPELSET::length()+link->length();
}

    
int Relation::NewSolutions()
{
    if ((!OwnSolutions) && (!link)) printf("Relation::NewSolutions: Eine Relation ohne eigene und ohne gelinkte Lsg. ist aufgetreten!\n");
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

//schreibt die lsg, wenn moeglich, nach solutions    
Pix Relation::add(Tupel item)
{
    if (!OwnSolutions) printf("Relation::add: Es wurde versucht Lsg. hinzuzufuegen, ohne OwnSolutions gesetzt zu haben!\n");
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
    
        printf("Umgelenkt auf %p  \n",link);
    printf("calculated   : ");if (not_calculated) printf("NEIN\n"); else printf("JA\n");
    printf("tupel_size   : %d",GetSize());printf("\n");
    printf("Belegung     : %d\n",Belegung);
    printf("solutions    : ");if (solutions) printf("nach %p\n",solutions); else printf("selbst\n");
    printf("OwnSolutions : ");if (OwnSolutions) printf("JA\n"); else printf("NEIN\n");
    printf("negiert      : ");if (negation) printf("JA\n"); else printf("NEIN\n");
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

void Relation::StrukturTest()
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
//    printf("***************Relation::calc() aufgerufen!!!!***************\n");
    deltaclear();
    return 1;
}

//diese Berechnung ist in den Literals effektiver programmiert
//hier ist nur eine Ausweichvariante, falls die obige Implementierung
//(virtual) nicht existiert
int Relation::calc(Tupel& tupel,TUPELBAG& ergebnis,int bel)
{
     //printf("Relation::calc(Tupel...) : ");
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
     //nur um "unused Parameter"-Warning zu umgehen
    if (4==5)
    {
        ergebnis.test();
        relation2.test();
        jc.add(1,1);
    }
    return 1;
}

int Relation::Anfrage(Tupel tupel,TUPELBAG &ergebnis)
{
     //printf("Relation::Anfrage gestellt! ");
     //tupel.test();printf("\n");
    if (!IsCalculated())
    {
         //printf("Anfrage: not calculated\n");
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
                         //tupel ist im gelinken gespeichert --> keine lsg
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
                 //wenn das TupelElement frei ist...
                if (tupel[a].GetType()==0)
                {
                     //das des Orginaltupels einsetzen
                    tupel[a]=t2[a];
                    if (tupel[a].GetType()==0) bel+=pot;
                } else {
                     //falls die tupel nicht zusammenpassen...
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

         //wenn gelinkte Lsg vorhanden, nur diese liefern
        if (link) {
            if (!Token)
            {
                 //das ist die Berechnungsvorschrift!
                Pix ind=firstGetAll();
                 //das ist die erste gelinkte Lsg!
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
         //printf("berechnungvorschrift ist ");t2.test();printf("\n");
        if (t2.GetSize()!=tupel.GetSize()) return 0;

        int bel=0,pot=1;
        for (int a=0;a<tupel.GetSize();a++)
        {
             //wenn das TupelElement frei ist...
            if (tupel[a].GetType()==0)
            {
                 //das des Orginaltupels einsetzen
                tupel[a]=t2[a];
                if (tupel[a].GetType()==0) bel+=pot;
            } else {
                 //falls die tupel nicht zusammenpassen...
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
         //alten zustand wieder herstellen
         //not_calculated=1;
//        for (Pix ind=first();ind;next(ind)) ergebnis.add((*this)(ind));
//        clear();
//        TUPELSET::add(t2);
    } else {
         //printf("berechnet\n");

        if (GetSize()!=tupel.GetSize()) return 0;

        if (negation)
        {
             //printf("Relation::Anfrage gestellt! ");
             //tupel.test();printf("  ");
             //printf("negiert!\n");
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
     //ergebnis.StrukturTest();
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
             //printf("Relation 2 wurde berechnet.\n");
        } else {
             //printf("Relation2 konnte nicht berechnet werden. Normales Verfahren eingeleitet.\n");
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
    
     //variablen fuer die zwischen.- und endergebnise dimensionieren
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
    
     //if (Token) printf("Relation1 hat Token\n");
     //if (relation2.Token) printf("Relation2 hat Token\n");
    

    TUPELBAG tmp;
    Tupel dummy(relation2.GetSize());
    int a=0,b=0,c=length()/10;

#ifdef TRACE    
    TOID toid;
    char *sC6=new char[50];
    strcpy(sC6,"Lloyd");
    if ((TDB*)database->name2toid(sC6,toid)) 
    {
    }else printf("konnte %s nicht finden\n",sC6);
    TupelElement *C6=new TupelElement();
    *C6=toid;
    
    printf("Tracing nach %s (id_%ld)\n",sC6,((TOID)*C6).GetId());
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

         //elemente von t2 auf Frei setzen
        t2=dummy;
        for (i=0;i<jc.length();i++)
        {        
            t2[jc.get(i,1)]=t[jc.get(i,0)];
        }
         //printf("(%d) stelle anfrage: ",a++);
         //t2.test();
         //printf(" (bis jetzt %ld lsg) ",ergebnis.length());
        if (jc.length()) 
        {
            relation2.Anfrage(t2,tmp);
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
                    printf(" mit Anfrage ");
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
                    printf(" mit Anfrage ");
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

//gibt gelinkte und/oder eigene Deltas zurueck
void Relation::GetDelta(TUPELSET& Tupelset)
{
    Tupelset|=delta;
    if (link) 
    {
         //wenn !solution, dann ist man nicht oberste rel, also auch kein mapping
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

//gibt gelinkte und/oder eigene Deltas zurueck, aber in einem TUPELBAG
void Relation::GetDelta(TUPELBAG& Tupelbag)
{
    Pix i;
    i=delta.first();
    while (i) { Tupelbag.add(delta(i));delta.next(i);}
    if (link) 
    {
         //wenn !solution, dann ist man nicht oberste rel, also auch kein mapping
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
         //StrukturTest();
         //printf(" :Restauriere link-Delta!\n");
        *(link->globDelta)|=*(link->GetBody());
    }
}

void Relation::RemoveDelta()
{
    if (link && !LinkZeigtAufEigenenFixpoint)
    {
         //StrukturTest();
         //printf(" :Loesche link-Delta!\n");
        link->globDelta->clear();
    }
}

void Literal::CheckForRule( class Fixpoint *fixpoint)
{ 
     //printf("literal\n");
     //StrukturTest();
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
//    printf("Literal: %s [",ATOM2STR(atom));

    
    printf("Literal:");StrukturTest();
     

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
    if (link) if (!LinkZeigtAufEigenenFixpoint) printf("Link zeigt nicht auf eigenen Fixpoint!\n");
    if (AdotLink) if (!AdotLinkZeigtAufEigenenFixpoint) printf("AdotLink zeigt nicht auf eigenen Fixpoint!\n");
}

void Literal::StrukturTest()
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
     //   printf("%d neue lsg im bag\n",deltabag.length());
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
        printf("Literal::first(%p): Weder OwnSolutions noch link gesetzt!\n",this);
        return NULL;
    }
    lokal=1;
    if (OwnSolutions)
    {
         //falls dies ein AdotLabel mit einem Link zu einer Adot-Rule ist
         //werden alle Lsg in die eigene Relation kopiert.
         //nicht schnell, kommt aber auch nicht oft vor.
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
     //if ((!OwnSolutions) && (!link)) printf("Relation::next(%p): Weder OwnSolutions noch link gesetzt!\n",this);
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
         //StrukturTest();
         //printf(" :Restauriere link-Delta!\n");
        *(link->globDelta)|=*(link->GetBody());
    }
    if (AdotLink && !AdotLinkZeigtAufEigenenFixpoint)
    {
         //StrukturTest();
         //printf(" :Restauriere AdotLink-Delta!\n");
        *(AdotLink->globDelta)|=*(AdotLink->GetBody());
    }
}

void Literal::RemoveDelta()
{
    if (link && !LinkZeigtAufEigenenFixpoint)
    {
         //StrukturTest();
         // printf(" :Loesche link-Delta!\n");
        link->globDelta->clear();
    }
    if (AdotLink && !AdotLinkZeigtAufEigenenFixpoint)
    {
         //StrukturTest();
         //printf(" :Loesche AdotLink-Delta!\n");
        AdotLink->globDelta->clear();
    }
}

Pix Literal::add(Tupel item)
{
    if (!OwnSolutions) printf("Literal::add: Es wurde versucht Lsg. hinzuzufuegen, ohne OwnSolutions gesetzt zu haben!\n");
    item.SetKey(key);
    if (!solutions)
    {
        if (!contains(item)) delta.add(item);
        return TUPELSET::add(item);
    }
//    return solutions->add_mapping(item);    
    return solutions->add(item);    
}

//liefert bei bedarf(lokal==false) auch lsg aus link zurueck
Tupel& Literal::operator ()(Pix   idx)
{   
    if ((!OwnSolutions) && (!link)) printf("Relation::operator()(%p): Weder OwnSolutions noch link gesetzt!\n",this);    
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
                     //Hack fuer Variablen die als Atoms ankommen...
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
    if (!OwnSolutions) printf("BuiltinLiteral::add: Es wurde versucht Lsg. hinzuzufuegen, ohne OwnSolutions gesetzt zu haben!\n");
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
        printf("  Anzahl: %d\n",anz=jc->length());
        for (i=0;i<anz;i++)
            printf("  Bedingung %d: %d==%d\n",i+1,jc->get(i,0),jc->get(i,1));
        printf(" Relation 1:\n");
        rel1->test();
        printf(" Relation 2:\n");
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
        printf("Projektion: \n");
        printf(" AttrList:\n");
        anz = al->length();
        for (i=0;i<anz;i++)
            printf(" %d",(*al)[i]);
        printf("\n");
        printf("solutions=%p\n",solutions);
        printf(" Relation:\n");
        rel->test();
        printf("Projektion - Ende\n");
    }
    else
    {
        Relation::test();
        rel->test();
    }
}

//siehe auch Relation::TakeTokenFrom in Algebra.h
int JoinProjNode::TakeTokenFrom(Relation* relation)
{
        //Token erstmal (weil man ist ja ein JoinProjNode) uebernehmen
    Token=relation->Token;
        //falls rel2-link gesetzt ist, koennte da ein delta sein (bei builtins ist das delta unsinnig)
        //wenn link==NULL kriegt sie auch keinen Token, weil ja keine deltas...
    if ((rel2->link) && (rel2->LinkZeigtAufEigenenFixpoint))
    {
            //Token der 2.Ralation geben
        rel2->Token=Token;
            //eigenen loeschen
        Token=NULL;
    } else {
            //Token der 1. Relation geben (das ist wahrscheinlich wieder ein JoinProjNode)
        if (!rel1->TakeTokenFrom(this))
        {
                //wenn sie den Token nicht will(weil sie nur eine Relation und kein JoinNode ist, dann ende
            Token=NULL;
            return 0;
        } 
    }
        //token der gebenden relation loeschen (hier gibt es mal kurzzeitig 2 tokens, abba das macht nix)
    relation->Token=NULL;
    return 1;
}

/* Tokens:
 * Bei einer Kette von Relationen in einem Join wird ein Token von der ersten
 * bis zur letzten relation durchgegeben (bei jedem calc eins weiter)
 * es werden also mehrere calc-durchlaeufe gemacht
 * Relationen mit Token beruecksichtgen nur ihre Deltas, die anderen alle lsg
 * wenn der Token bis hinten gekommen ist, wird die Berechnungsschleife von
 * der letzten relation gestoppt, indem der ersten weiter=0 gesetzt wird */
int JoinProjNode::calc()
{
     //printf("JoinprojNode:calc()\n");
    
    deltaclear();
        //wenn erfuellt, dann ist dies der erste JoinProjNode der Kette
        //er hat den Token ohne Ueberpruefung bekommen und muss das nachholen
    if (RepeatCalc)
            //wenn der Token nicht weitergegeben werden konnte, dann ist keine
            //gelinkte Relation in der Kette und es wird nur einrn Durchlauf geben
        if (!TakeTokenFrom(this)) RepeatCalc=0;
    do
    {
         //  if (RepeatCalc) printf("JoinProjNode::calc\n");
         //nur der oberste JoinProjNode wiederholt die Berechnung
         //RepeatCalc ist standartmaessig=true
         //jeder JoinProjNode setzt das repeatCalc des naechsten auf false
         //damit ist nur bei dem ersten der Kette RepeatCalc==true
        rel1->RepeatCalc=0;
        if (rel1->calc()) {
            if (rel1->NewSolutions() && (rel2->link)) rel2->not_calculated=1;
            if ((rel2->negation) && (!rel2->calc()))
            {
                 //negationen muessen zum zeitpunkt des joins ausrechenbar sein, oder
                 //schon ausgerechnet sein!
                 //printf("JoinProjNode::calc(): Negation in rel2 konnte nicht ausgerechnet werden!!\n");
            }
             //    printf("Token %d\n",Token);
             //printf("rel1-Token %d\n",rel1->Token);
             //printf("rel2-Token %d\n",rel2->Token);
            
             //printf("joine: ");
             //rel1->StrukturTest();
             //printf(" mit ");
             //rel2->StrukturTest();
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
                 //war rel1 das ende der kette und besitzt den Token (-->gelinkt)?
                if (rel1->Token)
                {
                     //berechnung beenden
                    rel1->Token->RepeatCalc=0;
                    rel1->Token=NULL;
                }
                 //falls rel2 den Token gerade hatte und rel1 ihn nicht will (-->nicht gelinkt)...
                if ((rel2->Token) && (!rel1->TakeTokenFrom(rel2)))
                {
                     //Berechnung beenden
                     //Token zeigt auf die erste Relation
                    rel2->Token->RepeatCalc=0;
                    rel2->Token=NULL;
                }
            }
        }
         //  }
    } while (RepeatCalc);
     //printf("Ergebnis des Joins: %d\n",length());
    
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
        //muss standartmaessig 1 sein, siehe JoinProjNode::Calc
    RepeatCalc=1;
    bag=NULL;
}

void JoinProjNode::test()
{
    printf("[00;00;35m");
    if (not_calculated) 
    {
        int i,anz;
        printf("Join-Projektion: (%p)\n",this);
        printf("[00;00;30m");        
        printf("tupel_size=%d\n",GetSize());
        printf(" AttrList:\n");
        anz = al->length();
        for (i=0;i<anz;i++)
            printf(" %d",(*al)[i]);
        printf("\n");
        printf(" JoinCondition:\n");
        printf("  Anzahl: %d\n",anz=jc->length());
        for (i=0;i<anz;i++)
            printf("  Bedingung %d: %d==%d\n",i+1,jc->get(i,0),jc->get(i,1));
        printf("RepeatCalc=%d\n",RepeatCalc);
        printf(" Relation 1 (%p):\n",rel1);
        printf("-----------------\n");
        rel1->test();
        printf(" Relation 2 (%p):\n",rel2);
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
        printf("  Anzahl: %d\n",anz=jc->length());
        for (i=0;i<anz;i++)
            printf("  Bedingung %d: %d==%d\n",i+1,jc->get(i,0),jc->get(i,1));
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
        printf(" Relation 1 (%p):\n",rel1);
        rel1->test();
        printf(" Relation 2 (%p):\n",rel2);        
        rel2->test();
        printf("\n.");
    }
}

void JoinProjNode::StrukturTest()
{
    printf("[00;00;33m");
    printf("JoinProj(");
    printf("[00;00;30m");
    rel1->StrukturTest();
    printf("[00;00;33m");
    printf(",");
    printf("[00;00;30m");
    rel2->StrukturTest();
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
         //StrukturTest();
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
     // funzt nicht bei joinprojnodes...
     //   SetSize(rel->GetSize());
     //printf("simplecross erzeugt\n");
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
    printf("Relation: \n");
    rel->test();
    printf("Konstanten: \n");
    if (konstanten) {
        for (int a=0;a<laenge;a++)
        {
            if (konstanten[a]) 
                if (konstanten[a]->GetType()==TUPEL_OID) printf("  %d: id_%ld\n",a,((TOID)*konstanten[a]).GetId());
                else printf("  %d: %s\n",a,(*konstanten[a]).get_symid().get_name());
            else printf("  %d: Konstante nicht lesbar!\n",a);
        }
    } else printf("  keine Konstanten\n");
}

void SIMPLECROSS::StrukturTest()
{
     //   printf("SimpleCross(");
    printf("[00;00;30m");
    rel->StrukturTest();
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
//    Tupel tupelNeu(JoinCondition::length());
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
    printf(" zu ");
    tupelNeu.test();
    printf("\n");
    return tupelNeu;
}
*/

//dieses Map wird nicht mehr benutzt.
//stattdessen werden die einzelnen Tupel mit map
//beim algdescription::add gemappt
//Grund: die entscheidung ob mapping oder nicht wurde
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
    
     //hier werden die AlgDescriptions mit gleichem Kopf
     //zu einem Kreis verbunden (durch link)
     //dabei werden die konstanten nicht beachtet
    AlgDescription *next;
        //fragt den fixpoint nach rules mit gleichem functor
        //der sucht zuerst in den anderem fixpoints, falls da
        //keine sind, dann im eigenen
        //wenn es gar keine gibt, kommt hier ein zeiger auf sich selbst
        //zurueck
    if (!link) {
         //einen Functor ohne konstanten erzeugen, weil die nicht mit ueberprueft werden sollen
        C_Functor func(Functor().name(),Functor().len());
        next=fixpoint->GetAlgDescrReverse(func);
         //if ((next!=this) && (next) && (next->link)) printf("algdescr %s(%p): fuege mich zwischen %s(%p) und %s(%p) ein\n",GetHeadline(),this,next->GetHeadline(),next,next->link->GetHeadline(),next->link);
         //if ((next!=this) && (!next->link) && next) printf("algdescr %s(%p): fuege mich hinter %s(%p) ein\n",GetHeadline(),this,next->GetHeadline(),next);    
        if (!next->link) link=next; else link=next->link;
        next->link=this;
    }
    
        //dann kann der Body seine links setzen
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
    printf("  Anzahl: %d\n",anz=JoinCondition::length());
    for (int a=0;a<anz;a++)
        printf("  Bedingung %d: %d==%d\n",a+1,get(a,0),get(a,1));
    if (link) printf("Umgelenkt (auf %p) !\n",link);
    printf("solutions=%p\n",solutions);
    if (KeineLsg) printf("Keine eigenen Loesungen : JA\n");
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

void AlgDescription::StrukturTest()
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
    GetBody()->StrukturTest();
    printf("[00;00;30m");
    printf("\n");
    
}

int AlgDescription::GetSize()
{
    if (solutions) return solutions->GetBody()->GetSize();
    else return GetBody()->GetSize();
}

//diese Funktion steht in Konflikt mit Condition::length()
//Vorsicht beim Umgang damit!
//liefert anzahl der lsg in einer rule zurueck
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

//hier wird eine lsg gespeichert
//ausserdem werden solutions und globdelta unter den AlgDescriptions
//"abgesprochen"
Pix AlgDescription::add(Tupel tupel)
{
    if (!solutions)
    {
         //solutiuon ist am Anfang NULL (SetHead())
         //hier wird es auf this gesetzt, damit speichern alle Regeln ihre L\"osungen
         //in den eigenen Bodies. Nur das globale Delta (globDelta) wird unter allen
         //gelinkten Regeln abgesprochen. Es bekommt die Regel, die zuerst L\"osungen.
         //solutions existiert nur, damit die M\"oglichkeit besteht, dass die Regeln
         //ihr L\"osungen vielleicht einmal zusammen abspeichert. Das w\"urde das 
         //auslesen beschleunigen, wirft aber Problem beim Delta auf.
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


//liefert true, wenn diese AlgDescription loesungen haben koennte, die auch
//zu einer AlgDescription mit arity2 und konstanten2 passen
//zusaetzlich werden noch die namen der konstanten ueberprueft
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

//ueberprueft, ob das tupel (als lsg dieser algdescr) zu den werten arity2 und
//konstanten2 eines literales passt, dass auf diese algdescr gelinkt ist
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
        printf("] mit ");
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


//ueberprueft, ob Func zu tupel passt.
//falls Func an einer stelle, die nicht frei ist, eine andere konstante
//eingetragen hat als tupel, dann passt es nicht
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
                     //an dieser stelle sollte ein oid-eintrag benutzt werden, 
                     //der nicht vorhanden ist!
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
     //wenn noch nie berechnet ---> ja
    if (!GetBody()->IsCalculated()) return 1;

     //wenn schon mal berechnet und keine links ---> nein
    if (!jdc->HasGotLinks()) return 0;    

     //sonst links ueberpruefen...
    AlgDescription *dummy;
    int a=0;
    do
    {
        dummy=(AlgDescription*)jdc->getNrOf(jdc->Links(),a);
        a++;
         //wenn einer der links neue Lsg hat ---> ja
        if ((dummy) && (dummy->NewSolutions())) 
        {
            return 1;
        }
        
    } while (dummy);    
     //sonst ---> nein
    return 0;
}


int AlgDescription::calc()
{
//    printf("berechne: %s\n",GetHeadline());

    TUPELSET dummy;
     //das alte delta sichern (siehe unten)
    dummy|=GetBody()->delta;
     //den Token der ersten relation geben
    GetBody()->Token=(JoinProjNode*)GetBody();
     //ist wahrscheinlich schon eins, abba sicher ist sicher
    GetBody()->RepeatCalc=1;
    int i=1;
     //diese variante ignoriert die struktur und rechnet alles partiell aus
    if (LohntBerechnung()) i=start_join_proj();
     //falls partiell fehl schlaegt, mal normal versuchen
    if (i==0) i=GetBody()->calc(); 
     //damit das kopieren der daten angestossen wird
    if (GetBody()->isAdotLabel) ((Literal*)GetBody())->AdotAusnahmeBehandeln();
     //falls noch kein globales delta abgemacht wurde...
    if (!globDelta) globDelta=new TUPELSET;
     //neue Lsg dazu
    GetBody()->GetDelta(*globDelta);
     //auch die gelinkten deltas ins delta
    GetBody()->GetDelta(GetBody()->delta);
        //die alten (aus der letzten berechnung dieser relation) raus
    (*globDelta)-=dummy;
     
    return i;
}

int AlgDescription::start_join_proj()
{
     //printf("start_join_proj\n");

     //nur wenn eine 2. relation da ist 
    if (jdc->getNrOf(jdc->Literals(),1)) 
    {
         //erste relation auslesen
        Relation *rel=(Relation*)(jdc->getNrOf(jdc->Literals(),0));
        Relation *dummy;
        SIMPLECROSS *sc=NULL;
         //falls ein simplecross vorhanden ist...
        if (jdc->HasGotSimpleCross()) sc=(SIMPLECROSS*)(jdc->getNrOf(jdc->SimpleCross(),0));
         //erste relation vollstaendig ausrechnen
        rel->calc();
         //printf("calc: %d ergebnisse\n",rel->length());
        int a=0;
        int berechnet=0;
        Relation ergebnis;
        TUPELBAG bag;

         //falls erste relation gelinkt ist...
        if ((rel->link) && (rel->LinkZeigtAufEigenenFixpoint))
        {
            berechnet=1;
            TUPELBAG bag;
             //einmal mit deltas ausrechnen (geht noch weiter!)
            rel->GetDelta(bag);            
            ProgressView pv(bag.length(),40);
            for (Pix ind=bag.first();ind;bag.next(ind))
            {        
                join_proj(ergebnis,(bag)(ind),jdc,1);
                pv.step(1);
            }   
            a=1;
        }
         //alle lsg von rel 1 in ein bag schreiben
        for (Pix ind=rel->firstGetAll();ind;rel->nextGetAll(ind))
        {
            bag.add((*rel)(ind));
        }
         //fuer jede andere (also ausser der ersten) relation eine schleife
        while (jdc->getNrOf(jdc->Literals(),a))
        {
            dummy=(Relation*)(jdc->getNrOf(jdc->Literals(),a));
             //nur wenn sich eine berechnung mit deltas lohnt...
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
         //falls bisher nix berechnet wurde, 
         //einmal komplett (nicht mit deltas!) ausrechnen
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
         //schnell noch konstanten einfuegen
        if (sc) sc->calc(ergebnis);
         //Loesungen in ergebnisrelation schreiben
        for (Pix ind2=ergebnis.first();ind2;ergebnis.next(ind2))
        {
            add(ergebnis(ind2));
        }
         //printf("alterset:\n");
         //alterset.test();
         //printf(" (jetzt %d lsg)\n",GetBody()->length());
    } else {
         //falls nur eine relation da war, nix tun
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

     //es wird MainTupel mit set2 gejoint
     //dabei wird bedingung jc beachtet und abschliessend auf al projeziert

    int MainSize=MainTupel.GetSize(),set2Size=set2->GetSize();

     //printf("joine: %d %d",MainTupel.GetSize(),set2->GetSize());
     //MainTupel.test();
      //printf(" mit ");
     //set2->StrukturTest();
     //printf("\n");    
    
    int LetzterInKette=1;
    if (jdc->getNrOf(jdc->Literals(),pos+1)) LetzterInKette=0;
     //if (LetzterInKette) printf("(Letzter in Kette) ");
    
     //variablen fuer die zwischen.- und endergebnise dimensionieren
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
     //Elemente von t2 auf Frei setzen
    t2=dummy;
    for (i=0;i<jc->length();i++)
    {        
        t2[jc->get(i,1)]=MainTupel[jc->get(i,0)];
    }
     //set2->StrukturTest();
     //printf("(%d) : ",set2->length());
    set2->Anfrage(t2,tmp);


     //if (LetzterInKette) printf(" %d lsg gespeichert\n",tmp.length());
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

//setzt das Tupel-Muster, dass zu einer Lsg passen muss, die zurueckgegeben wird
void AlgDescription::SetPattern(int arity2, char** konstanten2)
{
    PatternArity=arity2;
    PatternKonstanten=konstanten2;
}


//findet die erste zu den eigenen daten (konstanten, arity) passende algdescription
Pix AlgDescription::first()
{
     //printf("algDescription::first()\n");
    
    alg=this;
    Pix start=GetBody()->firstGetAll();
    if (!((start) && (IsCalculated()))) { alg=alg->link;start=NULL;} else return start;
        //solange keine AlgDescription gefunden wurde, dessen Relation:
        //  Werte besitzt (start)
        //  berechnet ist (IsCalculated())
        //  zum Pattern passt (mit SetPattern gesetzt)
        //  und gleich this ist (nur einmal im Kreis, dann Abbruch)
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

//liefert den naechsten wert und springt auch zur naechsten alsdescription, wenn noetig
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
     //dieses mapping ist fuer lsg, die gelinkt in die oberste rel einer
     //algdescr kamen und somit noch nicht passend fuer die algdescr gemappt wurden
    if ((alg->KeineLsg) || (!(alg->GetBody()->SolutionsLocal())))
    {
         //printf("AlgDescr: mappe ");
         //(*(alg->GetBody()))(idx).test();
         //printf(" zu ");
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

//uebertragt alle passenden delta-Tupel nach d
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
        if ((!link) && (alg!=this)) printf("AlgDescription: Link-Kette nicht geschlossen!\n");
    } while (alg!=this);
}

//uebertragt alle passenden delta-Tupel nach d
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
        if ((!link) && (alg!=this)) printf("AlgDescription: Link-Kette nicht geschlossen!\n");
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
         //printf("Fixpoint:add ungueltige AlgDescription...\n");
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
*Fixpoint::GetAlgDescr(C_Functor &functor)
{
    AlgDescription *dummy=GetAlgDescr_WO_advancedCheck(functor);
    if (dummy) return dummy;
    return stratified->GetAlgDescr(functor,this);
}

AlgDescription
*Fixpoint::GetAlgDescrReverse(C_Functor &functor)
{
    AlgDescription *dummy=stratified->GetAlgDescr(functor,this);
    if (dummy) return dummy;
    return GetAlgDescr_WO_advancedCheck(functor);
}

AlgDescription
*Fixpoint::GetAlgDescr_WO_advancedCheck(C_Functor &functor)
{
//    printf("GetAlgDescr_WO_advancedCheck: \n");
//    printf("frage nach %s in fixpoint %d\n",functor.name,this);
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
        printf("Regel %d:\n",++i);
        printf("FixpointNode: %s/%d.(%p)\n",fpn->GetFunctor().name(),fpn->GetFunctor().len(),fpn);
        printf("[00;00;30m");
        fpn->GetAlgDescr()->test();
        fpn = fpn->Next();
    }
    while (fpn != start);
}

void
Fixpoint::StrukturTest()
{
    int i;
    FixpointNode *fpn;
    fpn = start;
    i = 0;
    do
    {
        fpn->GetAlgDescr()->StrukturTest();
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
         //printf("Regel ");fpn->GetAlgDescr()->StrukturTest();printf("\n");
         //fpn->GetAlgDescr()->test();
        fpn->GetAlgDescr()->calc();
         //fpn->GetAlgDescr()->test();
         //printf("%d neue Loesungen (von %d)\n",fpn->GetAlgDescr()->NewSolutions(),fpn->GetAlgDescr()->length());
        
         /*
           printf("Delta: [");    
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
        //die variablen db, point, set und module sind in relation als static declariert,
        //deshalb reicht es hier aus, set nur fuer die erste Regel auszufuehren
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
        printf("Fixpoint %d:\n",++i);
        printf("[00;00;30m");
        fp->test();
        fp = fp->Next();
    }
    while (fp != start);    
}

void
stratified_rules::StrukturTest()
{   
    int i;
    fp = start;
    i = 0;
    do
    {
        printf("[00;00;34m");
//        printf("\n########################################################\n");
        printf("Fixpoint %d:\n",++i);
        printf("[00;00;30m");
        fp->StrukturTest();
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
         //  printf("stratified_rules: calculiere Fixpoint %d:\n",++i);
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
*stratified_rules::GetAlgDescr(C_Functor &functor,Fixpoint *fixpoint)
{
//    printf("stratified_rules:\n");
    Fixpoint *fix;
    fix = start;
    AlgDescription *dummy;
    do
    {
            //den aufrufenden Fixpoint rauslassen, weil sonst dreht man sich im kreis
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
