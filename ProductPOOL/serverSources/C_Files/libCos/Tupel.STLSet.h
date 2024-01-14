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
#include <set>
#include "Pix.h"
#include "Tupel.h"
#include "Tupel.Set.h"
#include <vector>
//#include <assert>

template<class T>
class slist
{
public:
    slist():Anfang(0),Anzahl(0){};
    
    void push_front(const T& Dat)
    {
        Listenelement *temp=new Listenelement(Dat,Anfang);
        Anfang=temp;
        Anzahl++;
    };
    
private:
    struct Listenelement
    {
        T Daten;
        Listenelement *Naechstes;
        Listenelement(const T& Dat, Listenelement* p):Daten(Dat),Naechstes(p){}
    };
    Listenelement *Anfang;
    int Anzahl;

public:
    class iterator
    {
    public:
        iterator(Listenelement *Init = 0)
                :aktuell(Init)
        {}

        T& operator*() const
        {
            return aktuell->Daten;
        }
        
        iterator& operator++() 
        {
            if (aktuell) aktuell=aktuell->Naechstes;
            return *this;
        }
/*
        iterator& operator++(int)
        {
            iterator temp=*this;
            ++*this;
            return temp;
        }
*/        
        bool operator!=(const iterator& x) const
        {
            return aktuell != x.aktuell;
        }

        bool operator==(const iterator& x) const
        {
            return aktuell==x.aktuell;
        }

        Listenelement* aktuell;
    };
    
    iterator begin() const {return iterator(Anfang);}
    iterator end() const {return iterator();}

    void erase(iterator &iter)
    {
        Listenelement* zeiger=Anfang;
        Listenelement* vorher=NULL;
        while (zeiger!=iter.aktuell)
        {
            vorher=zeiger;
            if (zeiger->Naechstes==NULL) return;
            zeiger=zeiger->Naechstes;
        }
        if (vorher) vorher->Naechstes=zeiger->Naechstes;
        else Anfang=zeiger->Naechstes;
        delete zeiger;
    }
};

//template<class T>
#define hash_size 1009;
class hashFkt
{
public:
    hashFkt(){};
    
    int operator()(Tupel p) const
    {
        int a=0;
        for (int b=0;b<p.GetSize();b++) 
        {
            if (p[b].GetType()!=TUPEL_FREE)
            {
                if (p[b].GetType()==TUPEL_SYMID) a+=(p[b].get_symid()).getid();
                else a+=((TOID)p[b]).GetId();
            }
        }
        return a%hash_size;
    }
    int tableSize() const
    {
        return hash_size;
    }
};



template<class T,class hashFun>
class HSet
{
public:
    typedef slist<T> Liste;
    typedef vector<Liste*> Vektor;
    
    class iterator;
    typedef iterator const_iterator;
    friend class iterator;
    
    class iterator : public forward_iterator<T,int >
    {
        
        friend class HSet<T,hashFun >;
    private:
        Liste::iterator aktuell;
        unsigned int Adresse;
        const Vektor *pVek;
        
    public:
        iterator()
                :aktuell(Liste::iterator()),pVek(0)
        {}
        iterator(Liste::iterator LI,int A,const Vektor *C)
                :aktuell(LI),Adresse(A),pVek(C)
        {}

        
        operator const void* () const
        {
            return pVek;
        }

        bool operator!() const
        {
            return pVek==0;
        }
        const T& operator*() const
        {
//            assert(pVek);
            return *aktuell;
        }

        T& operator*() 
        {
             //asser(pVek);
            return *aktuell;
        }
        
        iterator& operator++()
        {
            ++aktuell;
            if (aktuell==(*pVek)[Adresse]->end())
            {
                while (++Adresse<pVek->size())
                    if ((*pVek)[Adresse])
                    {
                        aktuell=(*pVek)[Adresse]->begin();
                        break;
                    }
                if (Adresse==pVek->size())
                    pVek=0;
            }
            return *this;
        }
/*
        iterator& operator++(int)
        {
            iterator temp=*this;
            operator++();
            return temp;
        }        
*/        
        bool operator==(const iterator& x) const
        {
            return (aktuell==x.aktuell) || (!pVek && !x.pVek);
        }

        bool operator!=(const iterator& x) const
        {
            return !operator==(x);
        }
    };
    
private:
    Vektor v;
    hashFun hf;
    int Anzahl;
    
    void construct(const HSet& S)
    {
        hf=S.hf;
        v=Vektor(S.v.size(),(Liste*)NULL);
        Anzahl=0;
        iterator t=S.begin();
        while (t !=S.end())
        {
            insert(*t);
            ++t;
        }
    }
    
public:
    iterator begin() const
    {
        unsigned int adr=0;
        while (adr<v.size())
        {
            if (!v[adr]) adr++;
            else return iterator(v[adr]->begin(),adr,&v);
        }
        return iterator();
    }
       iterator end() const
    {
        return iterator();
    }
    
    HSet(hashFun f)
            :v(f.tableSize(),(Liste*)NULL),hf(f),Anzahl(0)
    {}
    
    HSet(const HSet& S)
    {
        construct(S);
    }
    
    ~HSet()
        {
            clear();
        }
    
    HSet& operator=(const HSet& S)
    {
        if (this !=&S)
        {
            clear();
            construct(S);
        }
        return *this;
    }
    
    void clear()
    {
        for (unsigned int i=0;i<v.size();i++)
            if (v[i])
            {
                delete v[i];
                v[i]=0;
            }
        Anzahl=0;
    }

    void erase(iterator iter)
    {
        v[iter.Adresse]->erase(iter.aktuell);
        if (v[iter.Adresse]->begin()==v[iter.Adresse]->end())
        {
            delete v[iter.Adresse];
            v[iter.Adresse]=NULL;
        }
        Anzahl--;
    }
    
    
    iterator find(const T& k) const
    {
        int adresse=hf(k);
        if (!v[adresse]) return iterator();
        Liste::iterator temp=v[adresse]->begin();
        while (temp!=v[adresse]->end())
        {
            if ((*temp)==k) return iterator(temp,adresse,&v);
            else ++temp;
        }
        return iterator();
    }
    
    pair<iterator,bool > insert(const T& P)
    {
        iterator temp=find(P);
        bool eingefuegt=false;
        if (!temp)
        {
            int adresse=hf(P);
            if (!v[adresse]) v[adresse]=new Liste;
            v[adresse]->push_front(P);
            temp=find(P);
            eingefuegt=true;
            Anzahl++;
        }
        return make_pair(temp,eingefuegt);
    }

    int size() const {return Anzahl;}
    int empty() const {return Anzahl==0;}    

     //diese beiden Fkten sind nicht sinnvoll 
     //der compiler hat gemeckert, als sie fehlten...
    bool operator==(HSet<T,hashFun > m)
    {
        printf("Hset==Hset aufgerufen!!!!!+++++++++++++++++++++++++++\n");
        if (m.size()) return 1; else return 0;
    }

    bool operator<=(HSet<T,hashFun > m)
    {
        printf("Hset<Hset aufgerufen!!!!!+++++++++++++++++++++++++++\n");
        if (m.size()) return 1; else return 0;
    }
                   
};

//keine sinnvolle Implementierung. braucht aber auch nur der compiler...
inline bool operator<(HSet<Tupel,hashFkt > m,HSet<Tupel,hashFkt > n)
{
    printf("Hset<Hset aufgerufen!!!!!+++++++++++++++++++++++++++\n");
    return (m.size()<n.size());
}

class TupelSTLSet : public TupelSet
{
    typedef HSet<Tupel, hashFkt > Menge;
    typedef Menge::iterator iterator_;


protected:
    Menge p; 
    iterator_ iter;
    iterator_ iter_dummy;
    hashFkt HashFunktion;
    
public:
    TupelSTLSet()
            :p(HashFunktion)
    {
    }
    virtual ~TupelSTLSet(){};

    TupelSTLSet(const TupelSTLSet&);
    
    virtual Pix           add(Tupel  item);
    virtual void          del(Tupel  item);
    virtual int           contains(Tupel  item);
    int           length();
    int           empty();
    
    virtual void          clear();
    
    virtual Pix           first();
    virtual void          next(Pix& i);
    virtual Tupel&        operator () (Pix i);
    virtual int           owns(Pix i);
    virtual Pix           seek(Tupel  item);
    
    void          operator |= (TupelSTLSet& b);
    void          operator -= (TupelSTLSet& b);
    void          operator &= (TupelSTLSet& b){if (b==b) b=b;};
    
    inline int           operator == (TupelSTLSet& b);
    inline int           operator != (TupelSTLSet& b);
    inline int           operator <= (TupelSTLSet& b); 
    
    virtual int           OK(){return 1;};
    void          test();
};

inline TupelSTLSet::TupelSTLSet(const TupelSTLSet& s) : p(s.p) {}


//die folgenden operatoren sind nicht sinnvoll implementiert!!!
inline int TupelSTLSet::operator != (TupelSTLSet& b)
{
  return !(p == b.p);
}

inline int TupelSTLSet::operator == (TupelSTLSet& b)
{
  return (p == b.p);
}

inline int TupelSTLSet::operator <= (TupelSTLSet& b)
{
  return (p <= b.p);
}


