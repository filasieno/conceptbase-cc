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
#include "AlgLiterals.h"
#include "TDB.h"

//int P::calc(Tupel &tupel, TupelXPBag &ergebnis,int bel)
//{}


int P::calc()
{
     // printf("P::calc()\n");
    if (IsCalculated()) {
        deltaclear();
        return 1;
    }
    Tupel tupel;
    TOID id,src,dst;
    SYMID label;
    int Pattern;
    TOIDSET result;
    Relation tmp;
    Pix ind1;

    tmp |= *this;
    clear();
    deltaclear();
    
    for (ind1=tmp.first();ind1;tmp.next(ind1))
    {
        tupel = tmp(ind1);
        Pattern=0;
        
        if (!(GetBelegung() & 1))
            id = (TOID) tupel[0];
        else
            Pattern |= FREE_ID;
        
        if (!(GetBelegung() & 2))
            src = (TOID) tupel[1];
        else
            Pattern |= FREE_SRC;

        if (!(GetBelegung() & 4)){
            label = tupel[2].get_symid();
	}
        else
            Pattern |= FREE_LAB;

        if (!(GetBelegung() & 8))
            dst = (TOID) tupel[3];
        else
            Pattern |= FREE_DST;
        
        P_Literal(id,src,label,dst,Pattern,result,database,timepoint,searchspace,module);
        
        for (Pix ind2 = result.first();ind2;result.next(ind2))
        {
            if (GetBelegung() & 1)
            {
                tupel[0]=result(ind2);
            }
            if (GetBelegung() & 2)
            {
                tupel[1] = result(ind2).Src();
            }
            if (GetBelegung() & 4)
            {
                tupel[2] = result(ind2).Lab();
            }
            if (GetBelegung() & 8)
            {
                tupel[3] = result(ind2).Dst();
            }
            add(tupel);
        }
    }
    not_calculated=0;
    return 1;
}

int In::calc(Tupel &tupel, TUPELBAG &ergebnis,int bel)
{
    int Pattern;
    TOID c,x;
    TOIDSET result;
    
    switch (bel)
    {
    case 0:
        c = (TOID) tupel[1];
        x = (TOID) tupel[0];
        Pattern=0;
        break;
    case 1:
        c = (TOID) tupel[1];
        Pattern = FREE_ID_1;
        break;
    case 2:
        x = (TOID) tupel[0];
        Pattern = FREE_ID_2;
        break;
    default:
        printf("**********falsche belegung!*********\n");
        return 0;
    }
    In_o_Literal(x,c,Pattern,result,database,timepoint,searchspace,module);
    In_i_Literal(x,c,Pattern,result,timepoint,searchspace,module);
    for (Pix ind2 = result.first();ind2;result.next(ind2))
    {
        switch (bel)
        {
        case 0:
            break;
        case 1:
            tupel[0]=result(ind2);
            break;
        case 2:
            tupel[1]=result(ind2);
            break;
        }
        ergebnis.add(tupel);
    }
    return 1;
}


//das In-Literal wird als ein In_i ausgerechnet...
int In::calc()
{
     //printf("In:calc...");
    if (IsCalculated()) {
        deltaclear();
        return 1;
    }
    Tupel tupel;
    TOID x,c;
    int Pattern;
    TOIDSET result;
    Relation tmp;
    Pix ind1;
    
    tmp |= (*this); 
    clear();
    deltaclear();
    
    for (ind1=tmp.first();ind1;tmp.next(ind1))
    {
        tupel = tmp(ind1);
        switch (GetBelegung())
        {
        case 0:
            c = (TOID) tupel[1];
            x = (TOID) tupel[0];
            Pattern=0;
            break;
        case 1:
            c = (TOID) tupel[1];
            Pattern = FREE_ID_1;
            break;
        case 2:
            x = (TOID) tupel[0];
            Pattern = FREE_ID_2;
            break;
        default:
            continue;
        }
//        printf("berechne In_o...\n");
        In_o_Literal(x,c,Pattern,result,database,timepoint,searchspace,module);
//        printf("berechne In_i...\n");
        In_i_Literal(x,c,Pattern,result,timepoint,searchspace,module);
//        printf("liefere %d lsg\n",result.length());
        for (Pix ind2 = result.first();ind2;result.next(ind2))
        {
            switch (GetBelegung())
            {
            case 0:
                add(tupel);
                break;
            case 1:
                tupel[0]=result(ind2);
                break;
            case 2:
                tupel[1]=result(ind2);
                break;
            }
            add(tupel);
        }
    }
    not_calculated=0;
//    printf("done\n");    
    return 1;
}


int InI::calc()
{
    printf("In_i::calc\n");
    if (IsCalculated()) {
        deltaclear();
        return 1;
    }
    Tupel tupel;
    TOID x,c;
    int Pattern;
    TOIDSET result;
    Relation tmp;
    Pix ind1;
    
    tmp |= (*this); 
    clear();
    deltaclear();

    int UnCompleted=0;
    
    for (ind1=tmp.first();ind1;tmp.next(ind1))
    {
        tupel = tmp(ind1);
        switch (GetBelegung())
        {
        case 0:
            c = (TOID) tupel[1];
            x = (TOID) tupel[0];
            Pattern=0;
            break;
        case 1:
            c = (TOID) tupel[1];
            Pattern = FREE_ID_1;
            break;
        case 2:
            x = (TOID) tupel[0];
            Pattern = FREE_ID_2;
            break;
        default:
            add(tupel);
            UnCompleted=1;
            continue;
        }
        printf("suche nach ");
        tmp(ind1).test();
        In_i_Literal(x,c,Pattern,result,timepoint,searchspace,module);
        printf("%d gefunden\n",result.length());
        
        for (Pix ind2 = result.first();ind2;result.next(ind2))
        {
            switch (GetBelegung())
            {
            case 0:
                add(tupel);
                break;
            case 1:
                tupel[0]=result(ind2);
                break;
            case 2:
                tupel[1]=result(ind2);
                break;
            }
            add(tupel);
        }
    }
    if (!UnCompleted) not_calculated=0;
    return 1;
}


int InS::calc()
{
     // printf("InS::calc()\n");
    if (IsCalculated()) {
        deltaclear();
        return 1;
    }
    Tupel tupel;
    TOID x,c;
    int Pattern;
    TOIDSET result;
    Relation tmp;
    Pix ind1;

    tmp |= *this;
    clear();
    deltaclear();
    
    for (ind1=tmp.first();ind1;tmp.next(ind1))
    {
        tupel = tmp(ind1);
        switch (GetBelegung())
        {
        case 0:
            c = (TOID) tupel[1];
            x = (TOID) tupel[0];
            Pattern=0;
            break;
        case 1:
            c = (TOID) tupel[1];
            Pattern = FREE_ID_1;
            break;
        case 2:
            x = (TOID) tupel[0];
            Pattern = FREE_ID_2;
            break;
        default:
            add(tupel);
            continue;
        }
        In_s_Literal(x,c,Pattern,result,timepoint,searchspace,module);
        
        for (Pix ind2 = result.first();ind2;result.next(ind2))
        {
            switch (GetBelegung())
            {
            case 0:
                add(tupel);
                break;
            case 1:
                tupel[0]=result(ind2);
                break;
            case 2:
                tupel[1]=result(ind2);
                break;
            }
            add(tupel);
        }
    }
    not_calculated=0;
    return 1;
}

int InO::calc()
{
     //  printf("InO::calc()\n");
    if (IsCalculated()) {
        deltaclear();
        return 1;
    }
    Tupel tupel;
    TOID x,c;
    int Pattern;
    TOIDSET result;
    Relation tmp;
    Pix ind1;

    tmp |= *this;
    clear();
    deltaclear();
    
    for (ind1=tmp.first();ind1;tmp.next(ind1))
    {
        tupel = tmp(ind1);
        switch (GetBelegung())
        {
        case 0:
            c = (TOID) tupel[1];
            x = (TOID) tupel[0];
            Pattern=0;
            break;
        case 1:
            c = (TOID) tupel[1];
            Pattern = FREE_ID_1;
            break;
        case 2:
            x = (TOID) tupel[0];
            Pattern = FREE_ID_2;
            break;
        default:
            add(tupel);
            continue;
        }
        In_o_Literal(x,c,Pattern,result,database,timepoint,searchspace,module);
        
        for (Pix ind2 = result.first();ind2;result.next(ind2))
        {
            switch (GetBelegung())
            {
            case 0:
                add(tupel);
                break;
            case 1:
                tupel[0]=result(ind2);
                break;
            case 2:
                tupel[1]=result(ind2);
                break;
            }
            add(tupel);
        }
    }
    not_calculated=0;
    return 1;
}

int ADOT::calc(Tupel &tupel, TUPELBAG &ergebnis,int bel)
{
    TOID cc,x,y;
    SYMID ml;
    
    int Pattern=0;
    TOIDSET result;
    
    if (!(bel & 1))
        cc = (TOID) tupel[0];
    else
            Pattern |= FREE_CC;
    
    if (!(bel & 2))
        x = (TOID) tupel[1];
    else
        Pattern |= FREE_X;
    
    if (!(bel & 4))
        ml = tupel[2].get_symid();
    else
        Pattern |= FREE_ML;
    
    if (!(bel & 8))
        y = (TOID) tupel[3];
    else
        Pattern |= FREE_Y;
        
    Adot_Literal(cc,x,ml,y,Pattern,result,timepoint,searchspace,module);
    
        
    for (Pix ind2 = result.first();ind2;result.next(ind2))
    {
        if (bel & 1)
        {
             /*
              *  FREE_CC geht nicht
              */
        }
        if (bel & 2)
        {
            tupel[1] = result(ind2).Src();
        }
        if (bel & 4)
        {
            tupel[2] = cc.Lab();
        }
        if (bel & 8)
        {
            tupel[3] = result(ind2).Dst();
        }
        ergebnis.add(tupel);
    }
    return 1;
}

int ADOT::calc()
{
    if (IsCalculated()) {
        deltaclear();
        return 1;
    }

    Tupel tupel;
    TOID cc,x,y;
    SYMID ml;
    
    int Pattern;
    TOIDSET result;
    Relation tmp;
    Pix ind1;

    tmp |= *this;
    clear();
    deltaclear();
    
    for (ind1=tmp.first();ind1;tmp.next(ind1))
    {
        tupel = tmp(ind1);
        Pattern=0;
        
        if (!(GetBelegung() & 1))
            cc = (TOID) tupel[0];
        else
            Pattern |= FREE_CC;
        
        if (!(GetBelegung() & 2))
            x = (TOID) tupel[1];
        else
            Pattern |= FREE_X;

        if (!(GetBelegung() & 4))
            ml = tupel[2].get_symid();
        else
            Pattern |= FREE_ML;

        if (!(GetBelegung() & 8))
            y = (TOID) tupel[3];
        else
            Pattern |= FREE_Y;
        
        Adot_Literal(cc,x,ml,y,Pattern,result,timepoint,searchspace,module);
        for (Pix ind2 = result.first();ind2;result.next(ind2))
        {
            if (GetBelegung() & 1)
            {
                    /*
                     *  FREE_CC geht nicht
                     */
            }
            if (GetBelegung() & 2)
            {
                tupel[1] = result(ind2).Src();
            }
            if (GetBelegung() & 4)
            {
                tupel[2] = cc.Lab();
            }
            if (GetBelegung() & 8)
            {
                tupel[3] = result(ind2).Dst();
            }
            add(tupel);
        }
    }
    not_calculated=0;
//    printf("done\n");
    return 1;
}

//ALIT

//int ALIT::calc(Tupel &tupel, TUPELBAG &ergebnis,int bel)
//{}

int ALIT::calc()
{
    printf("A::calc()\n");
    if (IsCalculated()) {
        deltaclear();
        return 1;
    }
    Tupel tupel;
    TOID x,y;
    SYMID ml;
    
    int Pattern;
    TOIDSET result;
    Relation tmp;
    Pix ind1;

    tmp |= *this;
    clear();
    deltaclear();
    
    for (ind1=tmp.first();ind1;tmp.next(ind1))
    {
        tupel = tmp(ind1);
        Pattern=0;
        printf("berechne: ");
        tupel.test();
        printf("\n");
        
        if (!(GetBelegung() & 1))
            x = (TOID) tupel[0];
        else
            Pattern |= FREE_X;

        if (!(GetBelegung() & 2))
            ml = tupel[1].get_symid();
        else
            Pattern |= FREE_ML;

        if (!(GetBelegung() & 4))
            y = (TOID) tupel[2];
        else
            Pattern |= FREE_Y;
        
        A_Literal(x,ml,y,Pattern,result,timepoint,searchspace,module);
        
        printf("A_Literal liefert %d loesungen!\n",result.length());
        for (Pix ind2 = result.first();ind2;result.next(ind2))
        {
            if (GetBelegung() & 1)
            {
                tupel[0] = result(ind2).Src();
            }
            if (GetBelegung() & 2)
            {
                tupel[1] = result(ind2).Lab();
            }
            if (GetBelegung() & 4)
            {
                tupel[2] = result(ind2).Dst();
            }
            printf("addiere lsg: ");
            tupel.test();
            printf("\n");
            add(tupel);
        }
        result.destruct();
    }
    not_calculated=0;
    return 1;
}

//ALabelLIT

int ALLIT::calc()
{
//    printf("AL::calc()\n");
    if (IsCalculated()) {
        deltaclear();
        return 1;
    }
    Tupel tupel;
    TOID x,y;
    SYMID ml,l;
    
    int Pattern;
    TOIDSET result;
    Relation tmp;
    Pix ind1;

    tmp |= *this;
    clear();
    deltaclear();
    
    for (ind1=tmp.first();ind1;tmp.next(ind1))
    {
        tupel = tmp(ind1);
        Pattern=0;
     
         //      printf("bearbeite: ");
         // tupel.test();printf("\n");
        
        if (!(GetBelegung() & 1))
            x = (TOID) tupel[0];
        else
            Pattern |= FREE_X;

        if (!(GetBelegung() & 2))
            ml = tupel[1].get_symid();
        else
            Pattern |= FREE_ML;

        if (!(GetBelegung() & 4))
            y = (TOID) tupel[3];
        else
            Pattern |= FREE_Y;
            
        if (!(GetBelegung() & 8))
            l = tupel[2].get_symid();
        else
            Pattern |= FREE_CC;

        
        A_Label_Literal(x,ml,l,y,Pattern,result,timepoint,searchspace,module);
        
        for (Pix ind2 = result.first();ind2;result.next(ind2))
        {
            if (GetBelegung() & 1)
            {
                tupel[0] = result(ind2).Src().Src();
            }
            if (GetBelegung() & 2)
            {
                tupel[1] = result(ind2).Lab();
            }
            if (GetBelegung() & 4)
            {
                tupel[2] = result(ind2).Src().Lab();
            }
            
            if (GetBelegung() & 8)
            {
                tupel[3] = result(ind2).Src().Dst();
            }
            add(tupel);
            printf("liefere: ");
            tupel.test();
            printf("\n");
        }
        result.destruct();
    }
    not_calculated=0;
    return 1;
}

//AdotLabelLIT

//int AdotLabelLIT::calc(Tupel &tupel, TUPELBAG &ergebnis,int bel)
//{}


int AdotLabelLIT::calc()
{
     //  printf("Adot_label::calc()\n");
    if (IsCalculated()) {
        deltaclear();
        return 1;
    }
    Tupel tupel;
    TOID x,y,cc;
    SYMID ml,l;
    
    int Pattern;
    TOIDSET result;
    Relation tmp;
    Pix ind1;

    tmp |= *this;
    clear();
    deltaclear();
    
    for (ind1=tmp.first();ind1;tmp.next(ind1))
    {
        tupel = tmp(ind1);

        Pattern=0;        
        if (!(GetBelegung() & 1))
        {
            cc = (TOID) tupel[0];
        }
        else
            Pattern+=1;

        if (!(GetBelegung() & 2)) 
        {
            x = (TOID) tupel[1];
        }
        else
            Pattern+=2;

        if (!(GetBelegung() & 4))
            ml = tupel[2].get_symid();
        else
            Pattern+=4;
        if (!(GetBelegung() & 8))
        {
            y = (TOID) tupel[3];
        }
        else
            Pattern+=8;
        if (!(GetBelegung() & 16))
            l = tupel[4].get_symid();
        else
            Pattern+=16;
        
        Adot_Label_Literal(cc,x,ml,y,l,Pattern,result,timepoint,searchspace,module);
        
        for (Pix ind2 = result.first();ind2;result.next(ind2))
        {
            if (GetBelegung() & 1)
            {
                tupel[0] = cc;
            }
            if (GetBelegung() & 2)
            {
                tupel[1] = result(ind2).Src();
            }
            if (GetBelegung() & 4)
            {
                tupel[2] = cc.Lab();
            }
            if (GetBelegung() & 8)
            {
                tupel[3] = result(ind2).Dst();
            }
            if (GetBelegung() & 16)
            {
                tupel[4] = result(ind2).Lab();
            }
            add(tupel);
        }
    }
    not_calculated=0;
    return 1;
}

//int IsA::calc(Tupel &tupel, TUPELBAG &ergebnis,int bel)
//{}


int IsA::calc()
{
     // printf("Isa::calc()\n");
    if (IsCalculated()) {
        deltaclear();
        return 1;
    }
    Tupel tupel;
    TOID x,c;
    int Pattern;
    TOIDSET result;
    Relation tmp;
    Pix ind1;
    tmp |= *this;
    deltaclear();
    clear();   
    for (ind1=tmp.first();ind1;tmp.next(ind1))
    {
         //printf("berechne: ");
        tupel = tmp(ind1);
         //tupel.test();
         //printf("\n");
      
        switch (GetBelegung())
        {
        case 0:
            c = (TOID) tupel[1];
            x = (TOID) tupel[0];
            Pattern=0;
            break;
        case 1:
            c = (TOID) tupel[1];
            Pattern = FREE_ID_1;
            break;
        case 2:
            x = (TOID) tupel[0];
            Pattern = FREE_ID_2;
            break;
        default:
            add(tupel);
            continue;
        }
        Isa_Literal(x,c,Pattern,result,timepoint,searchspace,module);
        
        for (Pix ind2 = result.first();ind2;result.next(ind2))
        {
            switch (GetBelegung())
            {
            case 0:
                add(tupel);
                break;
            case 1:
                tupel[0]=result(ind2);
                break;
            case 2:
                tupel[1]=result(ind2);
                break;
            }
             // printf("ergebnis: ");
             //tupel.test();
             //printf("\n");
            add(tupel);
        }
    }
    not_calculated=0;
    return 1;
}

//int FROM::calc(Tupel &tupel, TUPELBAG &ergebnis,int bel)
//{}


int FROM::calc()
{
    if (IsCalculated()) {
        deltaclear();
        return 1;
    }
    Tupel tupel;
    FROM tmp;
    Pix ind1;


    tmp |= *this;
    clear();
    deltaclear();
    
    for (ind1=tmp.first();ind1;tmp.next(ind1))
    {
        tupel = tmp(ind1);
        switch (GetBelegung())
        {
        case 0:
                /* beide belegt */
            if ( ((TOID) tupel[0]).is_valid(timepoint,searchspace,module) &&
                 ((TOID) tupel[1]).is_valid(timepoint,searchspace,module) &&
                 ((TOID) tupel[0]).Src() == (TOID) tupel[1] )
                add(tupel);
            break;
        case 1:
                /* 1. Komponente nicht belegt */
            if ( ((TOID) tupel[1]).is_valid(timepoint,searchspace,module) )
            {
                Pix ind;
                TOIDSET toidset;
                toidset|=((TOID) tupel[1]).AtrO();
                for (ind=toidset.first();ind;toidset.next(ind))
                {
                    tupel[0] = toidset(ind);
                    add(tupel);
                }
                toidset.clear();
                toidset|=((TOID) tupel[1]).IsaO();
                for (ind=toidset.first();ind;toidset.next(ind))
                {
                    tupel[0] = toidset(ind);
                    add(tupel);
                }
                toidset.clear();
                toidset|=((TOID) tupel[1]).IofO();
                for (ind=toidset.first();ind;toidset.next(ind))
                {
                    tupel[0] = toidset(ind);
                    add(tupel);
                }
                tupel[0]=tupel[1];
                add(tupel);
            }
            break;
        case 2:
                /* 2. Komponente nicht belegt */
            if ( ((TOID) tupel[0]).is_valid(timepoint,searchspace,module) )
            {
                tupel[1] = ((TOID) tupel[0]).Src();
                add(tupel);
            }
            break;
        default:
            continue;
        }
    }
    not_calculated=0;
    return 1;
}

int TO::calc(Tupel &tupel, TUPELBAG &ergebnis,int bel)
{
    switch (bel)
    {
    case 0:
         /* beide belegt */
        if ( ((TOID) tupel[0]).is_valid(timepoint,searchspace,module) &&
             ((TOID) tupel[1]).is_valid(timepoint,searchspace,module) &&
             ((TOID) tupel[0]).Dst() == (TOID) tupel[1] )
            ergebnis.add(tupel);
        break;
    case 1:
         /* 1. Komponente nicht belegt */
        if ( ((TOID) tupel[1]).is_valid(timepoint,searchspace,module) )
        {   
            Pix ind;
            TOIDSET toidset;
            toidset|=((TOID) tupel[1]).AtrI();
            if (toidset.length())
                for (ind=toidset.first();ind;toidset.next(ind))
                {
                    tupel[0] = toidset(ind);
                    ergebnis.add(tupel);
                }
            toidset.clear();
            toidset|=((TOID) tupel[1]).IsaI();
            if (toidset.length())
            {
                for (ind=toidset.first();ind;toidset.next(ind))
                {
                    tupel[0] = toidset(ind);
                    ergebnis.add(tupel);
                }
            }
            toidset.clear();     
            toidset|=((TOID) tupel[1]).IofI();
            if (toidset.length())                
                for (ind=toidset.first();ind;toidset.next(ind))
                {
                    tupel[0] = toidset(ind);
                    ergebnis.add(tupel);
                }
            tupel[0]=tupel[1];
            ergebnis.add(tupel);
        }
        break;
    case 2:
         /* 2. Komponente nicht belegt */
        if ( ((TOID) tupel[0]).is_valid(timepoint,searchspace,module) )
        {
            tupel[1] = ((TOID) tupel[0]).Dst();
            ergebnis.add(tupel);
        }
        break;
    }
    return 1;
}


int TO::calc()
{
    if (IsCalculated()) {
        deltaclear();
        return 1;
    }
    Tupel tupel;
    FROM tmp;
    Pix ind1;

    tmp |= *this;
    clear();
    deltaclear();
    
    for (ind1=tmp.first();ind1;tmp.next(ind1))
    {
        tupel = tmp(ind1);
        switch (GetBelegung())
        {
        case 0:
                /* beide belegt */
            if ( ((TOID) tupel[0]).is_valid(timepoint,searchspace,module) &&
                 ((TOID) tupel[1]).is_valid(timepoint,searchspace,module) &&
                 ((TOID) tupel[0]).Dst() == (TOID) tupel[1] )
                add(tupel);
            break;
        case 1:
                /* 1. Komponente nicht belegt */
            if ( ((TOID) tupel[1]).is_valid(timepoint,searchspace,module) )
            {   
                Pix ind;
                TOIDSET toidset;
                toidset|=((TOID) tupel[1]).AtrI();
                if (toidset.length())
                    for (ind=toidset.first();ind;toidset.next(ind))
                    {
                        tupel[0] = toidset(ind);
                        add(tupel);
                    }
                toidset.clear();
                toidset|=((TOID) tupel[1]).IsaI();
                if (toidset.length())
                {
                    for (ind=toidset.first();ind;toidset.next(ind))
                    {
                        tupel[0] = toidset(ind);
                        add(tupel);
                    }
                }
                toidset.clear();     
                toidset|=((TOID) tupel[1]).IofI();
                if (toidset.length())                
                    for (ind=toidset.first();ind;toidset.next(ind))
                    {
                        tupel[0] = toidset(ind);
                        add(tupel);
                    }
                tupel[0]=tupel[1];
                add(tupel);
            }
            break;
        case 2:
                /* 2. Komponente nicht belegt */
            if ( ((TOID) tupel[0]).is_valid(timepoint,searchspace,module) )
            {
                tupel[1] = ((TOID) tupel[0]).Dst();
                add(tupel);
            }
            break;
        default:
            continue;
        }
    }
    not_calculated=0;
    return 1;
}

//int LABEL::calc(Tupel &tupel, TUPELBAG &ergebnis,int bel)
//{}


int LABEL::calc()
{
    if (IsCalculated()) {
        deltaclear();
        return 1;
    }
    Tupel tupel;
    
    FROM tmp;
    Pix ind1;


    tmp |= *this;
    clear();
    deltaclear();
    
    for (ind1=tmp.first();ind1;tmp.next(ind1))
    {
        tupel = tmp(ind1);
        switch (GetBelegung())
        {
        case 0:
                /* beide belegt */
            if ( ((TOID) tupel[0]).is_valid(timepoint,searchspace,module) &&
                 ((TOID) tupel[0]).Lab() == tupel[1].get_symid() )
                add(tupel);
            break;
        case 1:
            {
                    /* 1. Komponente nicht belegt */
                TOIDSET &toidset = *(tupel[1].get_symid()).get_uses();
                Pix ind;
                for (ind=toidset.first();ind;toidset.next(ind))
                {
                    if (toidset(ind).is_valid(timepoint,searchspace,module))
                    {
                        tupel[0]=toidset(ind);
                        add(tupel);
                    }
                }
                break;
            }
        case 2:
                /* 2. Komponente nicht belegt */
            if ( ((TOID) tupel[0]).is_valid(timepoint,searchspace,module) )
            {
                tupel[1] = ((TOID) tupel[0]).Lab();
                add(tupel);
            }
            break;
        default:
            continue;
        }
    }
    not_calculated=0;
    return 1;
}

//int IDENTICAL::calc(Tupel &tupel, TUPELBAG &ergebnis,int bel)
//{}


int IDENTICAL::calc()
{
     //printf("IDENTICAL berechnen...\n");
    if (IsCalculated()) {
        deltaclear();
         //printf("schon berechnet\n");
        return 1;
    }
    Tupel tupel;
    
    FROM tmp;
    Pix ind1;


    tmp |= *this;
    clear();
    deltaclear();
    
    for (ind1=tmp.first();ind1;tmp.next(ind1))
    {
        tupel = tmp(ind1);
        switch (GetBelegung())
        {
        case 0:
                /* beide belegt */
            if ( tupel[0] == tupel[1] )
            {
                add(tupel);
            }
            break;
        default:
             //printf("IDENTICAL konnte nicht ausgerechnet werden!\n");
            (*this)|=tmp;
            return 0;
        }
    }
    not_calculated=0;
    return 1;
}

//int LT::calc(Tupel &tupel, TUPELBAG &ergebnis,int bel)
//{}


int LT::calc()
{
    if (IsCalculated()) {
        deltaclear();
        return 1;
    }
    Tupel tupel;
    
    FROM tmp;
    Pix ind1;
    float f1,f2;


    tmp |= *this;
    clear();
    deltaclear();
    
    for (ind1=tmp.first();ind1;tmp.next(ind1))
    {
        tupel = tmp(ind1);
        switch (GetBelegung())
        {
        case 0:
                /* beide belegt */
            if (sscanf( ((TOID) tupel[0]).Lab().get_name(),"%f",&f1) == 1 &&
                sscanf( ((TOID) tupel[1]).Lab().get_name(),"%f",&f2) == 1 &&
                f1 < f2)
                add(tupel);
            break;
        default:
            continue;
        }
    }
    not_calculated=0;
    return 1;
}

//int GT::calc(Tupel &tupel, TUPELBAG &ergebnis,int bel)
//{}


int GT::calc()
{
    if (IsCalculated()) {
        deltaclear();
        return 1;
    }
    Tupel tupel;
    
    FROM tmp;
    Pix ind1;
    float f1,f2;


    tmp |= *this;
    clear();
    deltaclear();
    
    for (ind1=tmp.first();ind1;tmp.next(ind1))
    {
        tupel = tmp(ind1);
        switch (GetBelegung())
        {
        case 0:
                /* beide belegt */
            if (sscanf( ((TOID) tupel[0]).Lab().get_name(),"%f",&f1) == 1 &&
                sscanf( ((TOID) tupel[1]).Lab().get_name(),"%f",&f2) == 1 &&
                f1 > f2)
                add(tupel);
            break;
        default:
            continue;
        }
    }
    not_calculated=0;
    return 1;
}

//int LE::calc(Tupel &tupel, TUPELBAG &ergebnis,int bel)
//{}


int LE::calc()
{
    if (IsCalculated()) {
        deltaclear();
        return 1;
    }
    Tupel tupel;
    
    FROM tmp;
    Pix ind1;
    float f1,f2;


    tmp |= *this;
    clear();
    deltaclear();
    
    for (ind1=tmp.first();ind1;tmp.next(ind1))
    {
        tupel = tmp(ind1);
        switch (GetBelegung())
        {
        case 0:
                /* beide belegt */
            if (sscanf( ((TOID) tupel[0]).Lab().get_name(),"%f",&f1) == 1 &&
                sscanf( ((TOID) tupel[1]).Lab().get_name(),"%f",&f2) == 1 &&
                f1 <= f2)
                add(tupel);
            break;
        default:
            continue;
        }
    }
    not_calculated=0;
    return 1;
}
    
//int GE::calc(Tupel &tupel, TUPELBAG &ergebnis,int bel)
//{}

int GE::calc()
{
    if (IsCalculated()) {
        deltaclear();
        return 1;
    }
    Tupel tupel;
    
    FROM tmp;
    Pix ind1;
    float f1,f2;


    tmp |= *this;
    clear();
    deltaclear();
    
    for (ind1=tmp.first();ind1;tmp.next(ind1))
    {
        tupel = tmp(ind1);
        switch (GetBelegung())
        {
        case 0:
                /* beide belegt */
            if (sscanf( ((TOID) tupel[0]).Lab().get_name(),"%f",&f1) == 1 &&
                sscanf( ((TOID) tupel[1]).Lab().get_name(),"%f",&f2) == 1 &&
                f1 >= f2)
                add(tupel);
            break;
        default:
            continue;
        }
    }
    not_calculated=0;
    return 1;
}

//int EQ::calc(Tupel &tupel, TUPELBAG &ergebnis,int bel)
//{}


int EQ::calc()
{
    if (IsCalculated()) {
        deltaclear();
        return 1;
    }
    Tupel tupel;
    
    FROM tmp;
    Pix ind1;
    float f1,f2;


    tmp |= *this;
    clear();
    deltaclear();
    
    for (ind1=tmp.first();ind1;tmp.next(ind1))
    {
        tupel = tmp(ind1);
        switch (GetBelegung())
        {
        case 0:
                /* beide belegt */
            if (sscanf( ((TOID) tupel[0]).Lab().get_name(),"%f",&f1) == 1 &&
                sscanf( ((TOID) tupel[1]).Lab().get_name(),"%f",&f2) == 1 &&
                f1 == f2)
                add(tupel);
            break;
        default:
            continue;
        }
    }
    not_calculated=0;
    return 1;
}

int NE::calc()
{
    if (IsCalculated()) {
        deltaclear();
        return 1;
    }
    Tupel tupel;
    
    FROM tmp;
    Pix ind1;
    float f1,f2;


    tmp |= *this;
    clear();
    deltaclear();
    
    for (ind1=tmp.first();ind1;tmp.next(ind1))
    {
        tupel = tmp(ind1);
        switch (GetBelegung())
        {
        case 0:
                /* beide belegt */
            if (sscanf( ((TOID) tupel[0]).Lab().get_name(),"%f",&f1) == 1 &&
                sscanf( ((TOID) tupel[1]).Lab().get_name(),"%f",&f2) == 1 &&
                f1 != f2)
                add(tupel);
            break;
        default:
            continue;
        }
    }
    not_calculated=0;
    return 1;
}

int True::calc()
{
    not_calculated=0;
    deltaclear();
    Relation tmp;
    tmp|=*this;
    clear();
     // printf("TRUE::calc: ");
    for (Pix ind1=tmp.first();ind1;tmp.next(ind1)) 
    {
         // tmp(ind1).test();printf(" ");
        add(tmp(ind1));
    }
     //printf("\n");
    return 1;
}


int Known::calc()
{
    not_calculated=0;
    deltaclear();
    Relation tmp;
    tmp|=*this;
    clear();
    Tupel tupel(2);
    printf("Known::calc: ");
    for (Pix ind1=tmp.first();ind1;tmp.next(ind1)) 
    {
        tmp(ind1).test();printf(" ");
         //wenn Endzeit unendlich ist...
        if (((TOID)(tmp(ind1)[0])).ETime().GetTime()==INFINITY)
        {
            if (tmp(ind1)[1]==TUPEL_FREE) 
            {
                 //erzeuge eine Instanz von String mit der Startzeit des TOIDs
                char s[100];
                int ms,sec,min,h,d,mon,y;
                ((TOID)(tmp(ind1)[0])).STime().GetTime(ms,sec,min,h,d,mon,y);
                sprintf(s,"\"tt(millisecond(%d,%d,%d,%d,%d,%d,%d))\"",y,mon,d,h,min,sec,ms);
                printf("liefere %s\n",s);
                TOID toid,zeiger,strings;
                 //falls kein solcher String existiert oder diese nicht gueltig ist...
                if (!database->name2toid(s,toid,module) || (!toid.is_valid(timepoint,searchspace,module)))
                {
                     //erzeuge einen neuen
                    toid=(database->Create_node(s));
                    database->insert(toid);
                     //er soll instanz von string sein
                    strcpy(s,"*instanceof");
                    zeiger=database->Create_link(s,toid,toid);
                    strcpy(s,"String");
                    if (!database->name2toid(s,strings)) 
                    {
                        printf("Konnte Objekt String nicht finden!\n");
                        return 0;
                    }
                    zeiger.Update(toid,strings);
                    database->insert(zeiger);
                    tupel[1]=toid;
                    tupel[0]=(TOID)(tmp(ind1)[0]);
                }
                tupel[1]=toid;
                tupel[0]=(TOID)(tmp(ind1)[0]);
                printf("add ");tupel.test();printf("\n");
                add(tupel);
            } else {
                 //gibts wohl nicht...
                printf("Known:calc() eine zeit uebergeben... :-\\n");
            }
        }
    }
    printf("\n");
    return 1;
}


