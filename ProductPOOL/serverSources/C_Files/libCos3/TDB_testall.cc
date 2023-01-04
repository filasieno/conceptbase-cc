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
Matthias Jarke, RWTH Aachen, Informatik 5, Ahornstr. 55, 52056 Aachen, Germany
Christoph Quix, RWTH Aachen, Informatik 5, Ahornstr. 55, 52056 Aachen, Germany


This license is a FreeBSD-style copyright license.
Legal home of the FreeBSD copyright license: http://www.freebsd.org/copyright/freebsd-license.html
*/
#include "TDB.h"

#ifdef ALGEBRA
#include "Algebra.h"
#include "AlgLiterals.h"


void TDB::alg_test(Relation &rel)
{
    if (3==4) rel=rel;
    TOID toid;
    SYMID symid;
    char s[50];
    
    Tupel t(2),tupel2(2);
    Tupel tupel4(4);    
    
        //  InI In_i;
//    ADOT Adot1,Adot2;
//    LABEL label;
//    P p;
    
    Relation rel1,rel2;
    
        //  In_i.Set(this,next_search_time,next_search_space,next_module);
//    Adot1.Set(this,next_search_time,next_search_space,next_module);
    
    name2toid("Class",toid);
    tupel2[1]=toid;
//    In_i.AddCalc(tupel2);
//    In_i.calc();
  
    strcpy(s,"Class!rule");
    select2toid(s,toid);
    tupel4[0]=toid;
    Symbols.get_symb("rule",symid);
    tupel4[2]=symid;
        //  Adot1.AddCalc(tupel4);
    
    JoinCondition jc1(1);
    jc1.add(0,1);
  
        //In_i.join(rel, Adot1, jc1);   
  
    strcpy(s,"Department!head");
    select2toid(s,toid);
    tupel4[0]=toid;
    Symbols.get_symb("head",symid);
    tupel4[2]=symid;
//    Adot2.AddCalc(tupel4);
 
  
 
 
    JoinCondition jc2(2);
    jc2.add(4,1);
    jc2.add(0,3);
}
#endif

/*
*void TDB::test_all()
*{
*    printf("testall aufgerufen...\n");
*    TIMEPOINT timepoint=next_search_time;
*    printf("Anzahl zu loeschender Eintraege: %ld\n",getEntryOlderthan(hist,timepoint));
*}
*/


void TDB::test_all()
{
    TOIDSETSTL space;
    TOID x;
    TOID y;
    SYMID ml,l;
    char Xstr[100],Ystr[100],MLstr[100],Lstr[100];
    while (3==3)
    {
        printf("bitte x, metalabel, label und y eingeben: ");
        scanf("%s%s%s%s",Xstr,MLstr,Lstr,Ystr);
        if (*Xstr=='e') return;
        
        int Pattern=0;
        printf("%d\n",Pattern);
        
        if (*Xstr=='_')  Pattern+=FREE_X;
        else
         {
             if (name2toid(Xstr,x)!=1) {printf("X unbekannt!\n");continue;}
         }
        printf("%d\n",Pattern);        
        if (*Ystr=='_')  Pattern+=FREE_Y;
        else
        {
            if (name2toid(Ystr,y)!=1) { printf("Y unbekannt!\n");continue;}
        }
        printf("%d\n",Pattern);
        if (*Lstr=='_')  Pattern+=FREE_CC;
        else
        {
            if (get_symb(Lstr,l)!=1) {printf("Label unbekannt!\n");continue;} 
        }
        printf("%d\n",Pattern);
        if (*MLstr=='_')  Pattern+=FREE_ML;
        else
        {
            if (get_symb(MLstr,ml)!=1) {printf("MetaLabel unbekannt!\n");continue;} 
        }
        printf("%d\n",Pattern);
        space.clear();
        
        char s[100];
        printf("AL(");
        if (Pattern & FREE_X) printf("_,"); else       {
            toid2name(x,s);
            printf("%s,",s);
        }
        
        if (Pattern & FREE_ML) printf("_,"); else
        {
            Symbols.get_name(ml,s);
            printf("%s,",s);
        }

        if (Pattern & FREE_CC) printf("_,"); else
        {
            Symbols.get_name(l,s);
            printf("%s,",s);
        }

        if (Pattern & FREE_Y) printf("_)\n"); else
        {
            toid2name(y,s);
            printf("%s)\n",s);
        }
        
       
        ALQUERY query;
        start_Literal4(query,x,ml,MLstr,l,Lstr,y,Pattern,ALabelLit);
        TOID toid;
        while (get_tuple(query,toid))
        {
            printf("(%ld",toid.GetId());
            toid2name(toid.Src().Src(),s);
            printf(",%s",s);
            printf(",%s",toid.Lab().get_name());
            printf(",%s",toid.Src().Lab().get_name());            
            toid2name(toid.Src().Dst(),s);
            printf(",%s)\n",s);
        }
        printf("Objects found: (AL) ");
        query.space.test();
        printf("\n");
 
    }

}


