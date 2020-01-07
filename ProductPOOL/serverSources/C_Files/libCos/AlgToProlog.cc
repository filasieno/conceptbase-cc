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
#include "Bim_functions.h"

#define MAXIDLENGTH 15
/*
 *   Funktoren der Algebra-Konstrukte
 */
static BP_Functor  proj, join, join_proj, uni, diff, exchange, equal_, lit, map, rule;

/*
 *   Funktoren der bekannten Literale
 */
BP_Functor lit_in_i, lit_in_s, lit_in_o, lit_isa,lit_a, lit_in, lit_not, lit_aLabel, lit_Adot_Label;
BP_Functor lit_p;
BP_Functor lit_adot;
BP_Functor lit_from, lit_to;
BP_Functor lit_ne, lit_lt, lit_le, lit_label, lit_identical, lit_gt, lit_ge, lit_eq, lit_true, lit_known;







static void
init_functor()
{
//  select    = GET_PRED( STR2ATOM(TRUE,"select"),2);
    proj      = GET_PRED( STR2ATOM(TRUE,"proj"),2);
    join      = GET_PRED( STR2ATOM(TRUE,"join"),3);
    join_proj = GET_PRED( STR2ATOM(TRUE,"join_proj"),4);
    uni       = GET_PRED( STR2ATOM(TRUE,"union"),2);
    diff      = GET_PRED( STR2ATOM(TRUE,"diff"),2);
    exchange  = GET_PRED( STR2ATOM(TRUE,"exchange"),3);
    equal_     = GET_PRED( STR2ATOM(TRUE,"equal"),2);
    map       = GET_PRED( STR2ATOM(TRUE,"map"),2);
    rule      = GET_PRED( STR2ATOM(TRUE,"rule"),3);
    lit       = GET_PRED( STR2ATOM(TRUE,"lit"),1);
    lit_in    = GET_PRED( STR2ATOM(TRUE,"In"),2);    
    lit_in_i  = GET_PRED( STR2ATOM(TRUE,"In_i"),2);
    lit_in_s  = GET_PRED( STR2ATOM(TRUE,"In_s"),2);
    lit_in_o  = GET_PRED( STR2ATOM(TRUE,"In_o"),2);
    lit_isa   = GET_PRED( STR2ATOM(TRUE,"Isa"),2);  
    lit_p     = GET_PRED( STR2ATOM(TRUE,"P"),4);
    lit_adot  = GET_PRED( STR2ATOM(TRUE,"Adot"),4);
    lit_a     = GET_PRED( STR2ATOM(TRUE,"A"),3);    
    lit_aLabel= GET_PRED( STR2ATOM(TRUE,"A_label"),4);    
    lit_Adot_Label= GET_PRED( STR2ATOM(TRUE,"Adot_label"),5);    
    lit_from  = GET_PRED( STR2ATOM(TRUE,"From"),2);
    lit_to    = GET_PRED( STR2ATOM(TRUE,"To"),2);
    lit_ne    = GET_PRED( STR2ATOM(TRUE,"NE"),2);
    lit_lt    = GET_PRED( STR2ATOM(TRUE,"LT"),2);
    lit_le    = GET_PRED( STR2ATOM(TRUE,"LE"),2);
    lit_label = GET_PRED( STR2ATOM(TRUE,"Label"),2);
    lit_identical = GET_PRED( STR2ATOM(TRUE,"IDENTICAL"),2);
    lit_gt    = GET_PRED( STR2ATOM(TRUE,"GT"),2);
    lit_ge    = GET_PRED( STR2ATOM(TRUE,"GE"),2);
    lit_eq    = GET_PRED( STR2ATOM(TRUE,"EQ"),2);
    lit_not   = GET_PRED( STR2ATOM(TRUE,"not"),1);
    lit_known   = GET_PRED( STR2ATOM(TRUE,"Known"),2);
     //  lit_true  = GET_PRED( STR2ATOM(TRUE,"TRUE"),0);
}

void
TDB::AlgebraToProlog(AlgDescription *ad, BP_Term term)
{
    BP_Term arg,arg2,arg3;
    BP_Functor functor;
    BP_Atom atom;
    int arity,i;
    TUPELSET solutions;
    Pix ind=ad->first();
    while (ind) {
        solutions.add((*ad)(ind));
        ad->next(ind);
    }
//    Relation &rel = *(ad->GetBody());
    if (!ad->length())
    {
        UNIFY( term, BP_T_ATOM, STR2ATOM(TRUE,"[]") );
        return;
    }
    
    GET_VALUE((BP_Term)ad->GetHead(), BP_T_STRUCTURE, &functor);
    GET_NAME_ARITY(functor,&atom,&arity);
    
    SPACE(solutions.length()*arity);

//    functor = GET_PRED( STR2ATOM(TRUE,"A"), rel.GetSize() );

//    for (ind=rel.first();ind;rel.next(ind))
//    {
//    	UNIFY( term, BP_T_LIST ); 
//        GET_ARG( term, 1, &arg );
//        UNIFY( arg, BP_T_STRUCTURE, functor );  
//        TupelCToProlog(rel(ind),arg);
//	GET_ARG( term, 2, &term );
//    }
//    UNIFY( term, BP_T_ATOM, STR2ATOM(TRUE,"[]") );
    
    for (ind=solutions.first();ind;solutions.next(ind))
    {    
    	UNIFY( term, BP_T_LIST ); 
        GET_ARG( term, 1, &arg );

        UNIFY(arg, BP_T_STRUCTURE, functor);
        
        for (i=1;i<=arity;i++)
        {
            GET_ARG(ad->GetHead(),i,&arg2);
            if (GET_TYPE( arg2) != BP_T_VARIABLE) 
            {
                if (GET_TYPE(arg2)==BP_T_ATOM)
                {
                    GET_VALUE(arg2,BP_T_ATOM,&atom);
                    if (ATOM2STR(atom)[0]=='_')
                    {
                            //Hack fuer Variablen die als Atom ankommen
                        break;
                    } else {
                        GET_ARG( arg,i,&arg3);
                        BIM_Prolog_unify_terms(arg2,arg3);
                    }
                } else printf("AlgToProlog: argument weder atom noch variable?!\n");
            }
        }
         //printf("(");
         //for (int a=0;a<(solutions)(ind).GetSize();a++)
         //{
         //   if ((solutions)(ind)[a].GetType()==2) 
         //       printf("%s ",((SYMID)((solutions)(ind)[a])).get_name());
         //   else printf("%s ",((TOID)((solutions)(ind)[a])).Lab().get_name());
         //}
         //printf(")\n");
  
        TupelCToProlog((solutions)(ind),arg,arity);
	GET_ARG( term, 2, &term );
    }
     //printf("%d Loesungen\n",solutions.length());
    UNIFY( term, BP_T_ATOM, STR2ATOM(TRUE,"[]") );
}

void 
TDB::TupelCToProlog(Tupel &t, BP_Term term,int arity)
{
    int i;
    BP_Term arg;
    static char id[MAXIDLENGTH];

        //Es existiert eine Ueberschneidung der Methoden length()
        //in JoinCondition und in AlgDescription
        //Weil AlgDescription nun Relations-Funktionalitaet erhalten
        //hat, liefert AlgDescription::length() die Anzahl der Lsg.
 /*   for (i=0;i<ad->JoinCondition::length();i++)
  *  {
  *      GET_ARG( term, ad->get(i,1)+1, &arg);
  *      switch (t[ad->get(i,0)].GetType()) {
  *      case TUPEL_OID:
  *          ((TOID) t[ad->get(i,0)]).GetOid(id);
  *          UNIFY( arg, BP_T_ATOM, STR2ATOM(FALSE,id) );
  *          break;
  *      case TUPEL_SYMID:
  *          UNIFY( arg, BP_T_ATOM, STR2ATOM(FALSE,((SYMID) t[ad->get(i,0)]).get_name()) );
  *          break;
  *      case TUPEL_FREE:
  *          break;
  *      default:
  *          break;
  *      }
  *  }
  */
    for (i=0;i<arity;i++)
    {
        GET_ARG(term,i+1,&arg);
        switch (t[i].GetType())
        {
        case TUPEL_OID:
            ((TOID) t[i]).GetOid(id);
            UNIFY( arg, BP_T_ATOM, STR2ATOM(FALSE,id) );
            break;
        case TUPEL_SYMID:
            UNIFY( arg, BP_T_ATOM, STR2ATOM(FALSE,(t[i].get_symid()).get_name()) );
            break;
        case TUPEL_FREE:
            break;
        default:
            break;            
        }
    }
}

JoinCondition *
TDB::JoinConditionToAlg(BP_Term term, int mod)
        /*
         *  mod == 0: Join-Bedigung (equal(...))
         *  mod != 0: Ergebnis-Mapping (map(...))
         *
         */
{
    BP_Term arg,arg2;
    BP_Atom atom;
    BP_Atom atom_nil = STR2ATOM(TRUE,"[]");
    BP_Functor functor;
    int anz=0;
    int type;
    JoinCondition *jc;
    int bedingung[2];
    int i;

    arg = term;

    while (GET_TYPE(arg) == BP_T_LIST)
    {
        anz++;
        GET_ARG(arg,2,&arg);
    }

    type = GET_TYPE(arg);
    if (type == BP_T_ATOM)
        GET_VALUE(arg,BP_T_ATOM,&atom);
    if (type != BP_T_ATOM || atom != atom_nil)
        printf("Ungewoehnliches Listenende - ignoriert\n");

    jc = (mod)? new AlgDescription(anz) : new JoinCondition(anz);
    
    while( GET_TYPE(term) == BP_T_LIST )
    {
        GET_ARG(term,1,&arg);
        if (GET_TYPE(arg) != BP_T_STRUCTURE)
        {
            printf("falscher Typ innherhalb einer Join-Bedingung.\n");
            continue;
        }
        GET_VALUE(arg, BP_T_STRUCTURE, &functor);

        if ((mod)?functor==map:functor == equal_)
        {
            for (i=0;i<2;i++)
            {
                GET_ARG(arg,i+1,&arg2);
                if (GET_TYPE(arg2) != BP_T_INTEGER)
                {
                    printf("falscher Typ innherhalb einer Join-Bedingung (equal-%d).\n",i+1);
                    bedingung[i]=0;
                }
                else
                    GET_VALUE(arg2,BP_T_INTEGER,bedingung+i);
            }
            jc->add(bedingung[0]-1,bedingung[1]-1);                         
        }
        else
        {
            printf("Falscher Funktor innerhalb einer Join-Bedingung\n");
        }
        
        GET_ARG(term,2,&arg);
        term=arg;
    }
    return jc;
}

AttrList *
TDB::ArgListToAlg(BP_Term term)
{
    BP_Term arg;
    BP_Atom atom;
    BP_Atom atom_nil = STR2ATOM(TRUE,"[]");
    int anz=0;
    int type;
    AttrList *al;
    int i,wert;

    arg = term;

    while (GET_TYPE(arg) == BP_T_LIST)
    {
        anz++;
        GET_ARG(arg,2,&arg);
    }

    type = GET_TYPE(arg);
    if (type == BP_T_ATOM)
        GET_VALUE(arg,BP_T_ATOM,&atom);
    if (type != BP_T_ATOM || atom != atom_nil)
        printf("Ungewoehnliches Listenende - ignoriert\n");

    al = new AttrList(anz);

    i=0;
    while( GET_TYPE(term) == BP_T_LIST )
    {
        GET_ARG(term,1,&arg);
        if (GET_TYPE(arg) != BP_T_INTEGER)
        {
            printf("falscher Typ innherhalb einer Attributliste.\n");
            continue;
        }
        GET_VALUE(arg, BP_T_INTEGER, &wert);

        (*al)[i++]=wert-1;
        
        GET_ARG(term,2,&arg);
        term=arg;
    }
    return al;
}

void
TDB::SetHead(Literal *rel, BP_Term h)
{
    BP_Atom atom;
    BP_Functor func;
    BP_Term arg;
    int arity=0;
    char **konstanten=NULL;
    if (GET_TYPE(h)==BP_T_STRUCTURE) 
    {
        GET_VALUE(h,BP_T_STRUCTURE,&func);
        GET_NAME_ARITY(func,&atom,&arity);
        char name[strlen((char *)ATOM2STR(atom))+1];
        strncpy(name,(char *)ATOM2STR(atom),strlen((char *)ATOM2STR(atom))+1);
         //printf("%s(%d)[",ATOM2STR(atom),arity);
        konstanten=new char*[arity];
    
        for (int i=0;i<arity;i++)
        {
            GET_ARG(h,i+1,&arg);
            int type=GET_TYPE(arg);
            if (type==BP_T_VARIABLE)
            {
                konstanten[i]=NULL;
                 //printf("NULL ");
                continue;
            }
            if (type==BP_T_ATOM)
            {
                GET_VALUE(arg,BP_T_ATOM,&atom);
                if (ATOM2STR(atom)[0]=='_')
                {
                     //Hack fuer Variablen die als Atoms ankommen...
                    konstanten[i]=NULL;
                     //printf("NULL ");
                    continue;
                }
                 //printf("%s ",(char*)ATOM2STR(atom));
                konstanten[i]=new char[strlen((char *)ATOM2STR(atom))+1];
                strncpy(konstanten[i],(char *)ATOM2STR(atom),strlen((char *)ATOM2STR(atom))+1);
            }        
        }
         //printf("]\n");
        rel->SetHead(name,arity,konstanten);
    } else {
        rel->SetHead("TRUE",0,konstanten);
    }
}

void
TDB::SetHead(AlgDescription* alg,BP_Term head)
{
    BP_Atom atom;
    BP_Functor func;
    BP_Term arg;
    int arity=0;
    char **konstanten=NULL;

    GET_VALUE(head,BP_T_STRUCTURE,&func);
    GET_NAME_ARITY(func,&atom,&arity);

    konstanten=new char*[arity];

     //printf("head=%s %d\n",ATOM2STR(atom),arity);
    char name[strlen((char *)ATOM2STR(atom))+1];
    strncpy(name,(char *)ATOM2STR(atom),strlen((char *)ATOM2STR(atom))+1);
     //printf("%s(%d)[",name,arity);
    
    for (int i=0;i<arity;i++)
    {
        GET_ARG(head,i+1,&arg);
        int type=GET_TYPE(arg);
         //printf("%d: type=%d : ",i+1,type);
        if (type==BP_T_VARIABLE)
        {
             //GET_VALUE(arg,type,&blub);
            konstanten[i]=NULL;
             //printf("NULL ");
        }
        if (type==BP_T_ATOM)
        {
            BP_Atom atom;
            GET_VALUE(arg,BP_T_ATOM,&atom);
            if (ATOM2STR(atom)[0]=='_')
            {
                    //Hack fuer Variablen die als Atoms ankommen...
                konstanten[i]=NULL;
                 //printf("NULL ");
                continue;
            }
            konstanten[i]=new char[strlen((char*)ATOM2STR(atom))+1];
            strncpy(konstanten[i],(char*)ATOM2STR(atom),strlen((char *)ATOM2STR(atom))+1);
             //konstanten[i]=(char*)ATOM2STR(atom);
             //printf("%s ",konstanten[i]);            
        }        
    }
     //printf("]\n");
    if (func==lit_Adot_Label) alg->isAdotLabel=1;
    else alg->isAdotLabel=0;
    alg->SetHead(name,arity,konstanten);
}



Relation *
TDB::LiteralToAlg(BP_Term term)
{
    int type;
    BP_Term arg;
    BP_Atom atom;
    BP_Functor functor;
    int i;
    int arity;
    Literal *rel;
    int negation=0;

    if (GET_TYPE(term) != BP_T_STRUCTURE)
    {
         //literal TRUE?
        if (GET_TYPE(term)!=BP_T_ATOM) return NULL;
        else 
        {
            GET_VALUE(term,BP_T_ATOM,&atom);
            if (!strncmp((char*)ATOM2STR(atom),"TRUE",4))
            {
                rel=new True;
                if (negation) rel->negation=1;
                rel->OwnSolutions=1;
                rel->not_calculated=1;
                SetHead(rel,term);
                rel->SetBelegung(24);
                rel->SetSize(-1);
                return rel;        
            }
        }
    }
    GET_VALUE(term, BP_T_STRUCTURE, &functor);
    GET_NAME_ARITY(functor,&atom,&arity);
     //printf("bearbeite %s\n",ATOM2STR(atom));
    if (!strncmp((char*)ATOM2STR(atom),"neg",3))
    {
        negation=1;
    }
    if (functor == lit_in_i ||
        functor == lit_in   ||
        functor == lit_in_s ||
        functor == lit_isa  ||
        functor == lit_from ||
        functor == lit_label ||
        functor == lit_to ||
        functor == lit_ge ||
        functor == lit_gt ||
        functor == lit_known ||
        functor == lit_identical)
    {
        
            /*
             *  In-i und In-s - Literal
             *
             *  From- und To-Literal
             */
        
        if (functor == lit_in_i)
            rel = new InI;
        else if (functor == lit_in)
            rel=new In;
        else if (functor == lit_in_s)
            rel = new InS;
        else if (functor == lit_isa)
            rel = new IsA;
        else if (functor == lit_from)
            rel = new FROM;
        else if (functor == lit_label)
            rel = new LABEL;        
        else if (functor == lit_ge)
            rel = new GE;
        else if (functor == lit_gt)
            rel = new GT;
        else if (functor == lit_known)
            rel = new Known;
        else if (functor == lit_identical)
            rel = new IDENTICAL;
        else rel = new TO;
        
        SetHead(rel,term);
        rel->OwnSolutions=1;
        
        Tupel tupel(2);
        TOID toid;
        
        for (i=0;i<2;i++)
        {
            GET_ARG(term, i+1, &arg);
            type = GET_TYPE(arg);
            switch (type)
            {
            case BP_T_ATOM:
                GET_VALUE(arg, type, &atom);
                    //Hack fuer Variablen die als Atoms ankommen...
                if (ATOM2STR(atom)[0]=='_') continue;
                if (!oid2toid((char *) ATOM2STR(atom),toid))  printf("_PrologToAlg->2stelliges Lit.: *** %s ist kein iod!\n",ATOM2STR(atom));
                tupel[i]=toid;
                break;
            case BP_T_VARIABLE:
                break;
            default:
                printf("Fehlerhafter Typ als Parameter fuer In_i/In_s\n");
            }
        }
       rel->AddCalc(tupel);
       if (negation) rel->negation=1;           
       return rel;
    }
    
    if (functor == lit_a)
    {
            /*
             *  A-Literal
             */
        
        if (functor==lit_a)
            rel = new ALIT;

        SetHead(rel,term);
        rel->OwnSolutions=1;
        
        Tupel tupel(3);
        TOID toid;
        SYMID symid;
        for (i=0;i<3;i++)
        {
            GET_ARG(term, i+1, &arg);
            type = GET_TYPE(arg);
            switch (type)
            {
            case BP_T_VARIABLE:
                break;
            case BP_T_ATOM:
                GET_VALUE(arg, type, &atom);
                 //Hack fuer Variablen die als Atoms ankommen...
                if (ATOM2STR(atom)[0]=='_') continue;
                if (i==1)
                {
                    get_symb( (char *) ATOM2STR(atom),symid);
                    tupel[i]=symid;
                }
                else
                {
                    if (!oid2toid( (char *) ATOM2STR(atom),toid)) printf("_PrologToAlg->A_Literal: *** %s ist kein iod!\n",ATOM2STR(atom));
                    tupel[i]=toid;
                }
                break;
            default:
                printf("Fehlerhafter Typ als Parameter %d fuer P oder Adot\n",i+1);
            }
        }
        
        rel->AddCalc(tupel);
       if (negation) rel->negation=1;            
        return rel;
    }

    if (functor == lit_p ||
        functor == lit_aLabel || 
        functor == lit_adot)
    {
            /*
             *  P-Literal
             *  Adot-Literal
             *  ALabel-Literal
             *
             *  (Adot und P sehen "gleich" aus (_id,_id,_label,_id))
             */
        
        if (functor==lit_p)
            rel = new P;
        else
            if (functor==lit_aLabel)
                rel = new ALLIT;        
            else
                rel = new ADOT;
        SetHead(rel,term);
        rel->OwnSolutions=1;

        Tupel tupel(4);
        TOID toid;
        SYMID symid;
        for (i=0;i<4;i++)
        {
            GET_ARG(term, i+1, &arg);
            type = GET_TYPE(arg);
            switch (type)
            {
            case BP_T_VARIABLE:
                break;
            case BP_T_ATOM:
                GET_VALUE(arg, type, &atom);
                 //Hack fuer Variablen die als Atoms ankommen...
                if (ATOM2STR(atom)[0]=='_') continue;
                if (((i==2) && !(functor==lit_aLabel)) ||
                    ((i==1) &&  (functor==lit_aLabel)) ||
                    ((i==3) &&  (functor==lit_aLabel)))
                {
                    get_symb( (char *) ATOM2STR(atom),symid);
                    tupel[i]=symid;
                }
                else
                {
                    if (!oid2toid( (char *) ATOM2STR(atom),toid)) printf("LiteralToAlg->P_Lit, Adot_Lit, ALabel_Lit *** %s ist kein oid!\n",ATOM2STR(atom));
                    tupel[i]=toid;
                }
                break;
            default:
                printf("Fehlerhafter Typ als Parameter %d fuer P oder Adot\n",i+1);
            }
        }
        rel->AddCalc(tupel);
        if (negation) rel->negation=1;
        return rel;
    }
    
 if (functor == lit_Adot_Label)
    {
            /*
             *  Adot_Label-Literal             
             */
        
        rel = new AdotLabelLIT;
        SetHead(rel,term);
        rel->OwnSolutions=1;
        
        rel->isAdotLabel=1;
        
        Tupel tupel(5);
        TOID toid;
        SYMID symid;
        for (i=0;i<5;i++)
        {
            GET_ARG(term, i+1, &arg);
            type = GET_TYPE(arg);
            switch (type)
            {
            case BP_T_VARIABLE:
                break;
            case BP_T_ATOM:
                GET_VALUE(arg, type, &atom);
                 //Hack fuer Variablen die als Atoms ankommen...
                if (ATOM2STR(atom)[0]=='_') continue;
                if ((i==2) || (i==4))
                {
                    get_symb( (char *) ATOM2STR(atom),symid);
                    tupel[i]=symid;
                }
                else
                {
                    if (!oid2toid( (char *) ATOM2STR(atom),toid)) printf("LiteralToAlg->Adot_Label *** %s (%d. arg) ist kein iod\n",ATOM2STR(atom),i);
                    tupel[i]=toid;
                }
                break;
            default:
                printf("Fehlerhafter Typ als Parameter %d fuer P oder Adot\n",i+1);
            }
        }
        rel->AddCalc(tupel);
        if (negation) rel->negation=1;            
        return rel;
    }

    if (functor==lit_not)
    {
        GET_ARG(term,1,&arg);
        if (GET_TYPE(arg)==BP_T_STRUCTURE)
        {
//            GET_VALUE(arg, BP_T_STRUCTURE, &functor);
//            GET_NAME_ARITY(functor,&atom,&arity);
            Relation* dummy=LiteralToAlg(arg);
            dummy->negation=1;
            return dummy;

        } else printf("Negiertes Literal konnte nicht aufgeloest werden!\n");
        return NULL;
    }

    rel = new Literal();
    if (negation) rel->negation=1;
    SetHead(rel,term);
    rel->OwnSolutions=0;
    return rel;
}

            
Relation *
TDB::_PrologToAlg(BP_Term term)
{ 
    int type;
    BP_Term arg;
    BP_Atom atom;
    BP_Atom atom_nil = STR2ATOM(TRUE,"[]");
    int i;
    
    type = GET_TYPE(term);
    switch ( type )
    {
    case BP_T_INTEGER:
        GET_VALUE(term, type, &i);
        printf("Integer: %d",i);
        return NULL;
        break;
    case BP_T_REAL:
        float f;
        GET_VALUE(term, type, &f);
        printf("Real: %f",f);
        return NULL;
        break;
    case BP_T_POINTER:
        void *p;
        GET_VALUE(term, type, &p);
        printf("Pointer");
        return NULL;
        break;
    case BP_T_ATOM:
        GET_VALUE(term, type, &atom);
        printf("Atom: %s",ATOM2STR(atom));
        return NULL;
        break;
    case BP_T_VARIABLE:
        printf("Variable");
        return NULL;
        break;
    case BP_T_STRUCTURE:
        BP_Functor functor;
        int arity;
        
        GET_VALUE(term, type, &functor);

         //printf("strukture\n");
        if ( functor == lit )
        {
            GET_ARG(term, 1, &arg);
            Relation *rel = LiteralToAlg(arg);
            rel->database=NULL;
            return rel;
        }
        
        if ( functor == join )
        {
            Relation *rel1,*rel2;
            GET_ARG(term, 1, &arg);
            JoinCondition *jc = JoinConditionToAlg(arg);
            GET_ARG(term, 2, &arg);
            rel1 = _PrologToAlg( arg );
            GET_ARG(term, 3, &arg);
            rel2 = _PrologToAlg( arg );
            Relation *rel = new JoinNode(rel1,rel2,jc);
            return rel;
        }

        if ( functor == proj )
        {
            Relation *rel1;
            GET_ARG(term, 1, &arg);
            AttrList *al = ArgListToAlg(arg);
            GET_ARG(term, 2, &arg);
            rel1 = _PrologToAlg( arg );
            Relation *rel = new ProjNode(rel1,al);
            return rel;
        }

        if ( functor == join_proj )
        {
             //printf("joinprpj\n");
            
            Relation *rel1,*rel2;
            GET_ARG(term, 1, &arg);
            JoinCondition *jc = JoinConditionToAlg(arg);
            GET_ARG(term, 2, &arg);
            AttrList *al = ArgListToAlg(arg);
            GET_ARG(term, 3, &arg);
            rel1 = _PrologToAlg( arg );
            GET_ARG(term, 4, &arg);
            rel2 = _PrologToAlg( arg );
            Relation *rel = new JoinProjNode(rel1,rel2,jc,al);
            rel->OwnSolutions=1;

            int bel=0,pot=1;
            for (int a=0;a<rel2->GetSize();a++) {bel+=pot;pot*=2;};
            if ((rel2->GetBelegung()==bel!=0) && (jc->length()==0)) 
            {
                printf("Ein ");
                rel2->StrukturTest();
                printf(" mit nur freien Variablen ist aufgetreten!\n");
                return NULL;
            }
            if ((!rel1) || (!rel2)) return NULL;
            return rel;
        }
            
        
        GET_NAME_ARITY(functor,&atom,&arity);

        if (functor == GET_PRED( STR2ATOM(TRUE,"simplecross"),arity))
        {
             //printf("simplecross\n");
            Relation *rel1=NULL;
            GET_ARG(term,1,&arg);
            rel1=_PrologToAlg(arg);
            SIMPLECROSS *rel=new SIMPLECROSS(rel1);
            TOID *toid;
            GET_ARG(term,2,&arg);
            if (GET_TYPE(arg)==BP_T_STRUCTURE)
            {
                GET_VALUE(arg,BP_T_STRUCTURE,&functor);
                GET_NAME_ARITY(functor,&atom,&arity);
                if (functor==GET_PRED( STR2ATOM(TRUE,"const"),arity))
                {
                    GET_NAME_ARITY(functor,&atom,&arity);
                    BP_Term arg2;
                    for (int a=1;a<=arity;a++)
                    {
                        GET_ARG(arg,a,&arg2);
                        if (GET_TYPE(arg2) != BP_T_ATOM)
                        {
                            printf("PrologToAlg->SIMPLECROSS: Argument %d in const-Structur ist kein Atom!\n",a);
                            continue;
                        }
                        TupelElement *tupelelement=new TupelElement();
                        GET_VALUE(arg2, BP_T_ATOM, &atom);
                        toid = new TOID();
                        if (!oid2toid( (char *) ATOM2STR(atom),*toid)) 
                        {
                            SYMID *symid=new SYMID();
                            get_symb( (char *) ATOM2STR(atom),*symid);
                            *tupelelement=*symid;
                            delete[] toid;
                        } else {
                            *tupelelement=*toid;
                        }
                             //printf("_PrologToAlg->SIMPLECROSS: *** %s ist kein iod!\n",ATOM2STR(atom));
                        rel->addKonst(tupelelement);
                    }
                } else printf("Prolog2Alg->SIMPLECROSS: 2.Argument keine const-Struktur! (%s\%d)\n",ATOM2STR(atom),arity);
            } else printf("PrologToAlg->SIMPLECROSS: 2.Argument keine BP_T_STRUCTURE!\n");
   
            return rel;
        }
        
         //printf("%s(",ATOM2STR(atom));
        GET_ARG( term, 1, &arg);
        _PrologToAlg( arg );
        for (i=2;i<=arity;i++)
        {
            printf(",");
            GET_ARG( term, i, &arg);
            _PrologToAlg( arg );
        }
        printf(")");
        break;
    case BP_T_LIST:
        printf("[");
        GET_ARG( term, 1, &arg );
        _PrologToAlg(arg);
        GET_ARG(term, 2, &arg);
        term = arg;
        while( GET_TYPE(term) == BP_T_LIST )
        {
            printf(",");
            GET_ARG(term,1,&arg);
            _PrologToAlg(arg);
            GET_ARG(term,2,&arg);
            term=arg;
        }
        if (GET_VALUE(term,BP_T_ATOM,&atom) && atom == atom_nil)
            printf(",[]");
        else
        {
            printf(" | ");
            _PrologToAlg(term);
        }
        printf("]");
        break;
    default:
        printf("unknown type");
    }
    return NULL;
}


AlgDescription *
TDB::PrologToAlg(BP_Term term)
{
    AlgDescription *alg_descr;
    BP_Functor functor;
    BP_Term algexp;
    BP_Term head;
    BP_Term map;
    int type;
    init_functor();
    
    type = GET_TYPE(term);
    if (type != BP_T_STRUCTURE)
        return NULL;
    
    GET_VALUE(term, type, &functor);

    if ( functor != rule )
        return NULL;

    GET_ARG(term, 1, &head);
    GET_ARG(term, 2, &algexp);
    GET_ARG(term, 3, &map);
    
/*    
 *   int arity;
 *   BP_Atom atom;
 *   BP_Functor func;
 *   BP_Term arg;
 *   type=GET_TYPE(head);
 *
 *   if (type==BP_T_STRUCTURE)
 *   {
 *       GET_VALUE(head,type,&func);
 *       GET_NAME_ARITY(func,&atom,&arity);
 *       printf("head=%s\n",ATOM2STR(atom));
 *       for (int i=0;i<arity;i++)
 *       {
 *           GET_ARG(head,i+1,&arg);
 *           type=GET_TYPE(arg);
 *           printf("%d: type=%d : ",i+1,type);
 *           if (type==BP_T_VARIABLE)
 *           {
 *               int blub;
 *               GET_VALUE(arg,type,&blub);
 *               printf("_%d\n",blub);
 *           }
 *       }
 *   }
 */
    alg_descr = (AlgDescription*) JoinConditionToAlg(map,1);
    alg_descr->SetBody(_PrologToAlg(algexp));
    SetHead(alg_descr,head);
     //dieser ausruf ist noetig, weil sonst die ergebnisse nicht verpackt werden koennen
    alg_descr->SetHead(head);

    if (alg_descr->ok) return alg_descr;
    else 
    {
        return NULL;
    }
    
}


void TDB::FaktenListe(BP_Term term, Fixpoint *fix)
{

    printf("FaktenListe...\n");

    BP_Term arg;
    BP_Functor functor,functorDiff;
    BP_Atom atom;
    int type,arity;
    AlgDescription *algdescr=NULL;
    Literal *rel=NULL;

    while (GET_TYPE(term) == BP_T_LIST)
    {
        GET_ARG(term,1,&arg);
        type=GET_TYPE(arg);
        if (type!=BP_T_STRUCTURE) printf("Fehlerhafte FaktenListe\n");
        GET_VALUE(arg,type,&functor);
        GET_NAME_ARITY(functor,&atom,&arity);
        printf("FaktenListe: %s\n",ATOM2STR(atom));
         //nur wenn der Functor sich geaendert hat, eine neue AlgDescr anlegen...
        if (!(functor==functorDiff)) 
        {
            algdescr=new AlgDescription(0);
            rel=new Literal(functor,arity,0);
            rel->OwnSolutions=1;
            rel->negation=0;
            rel->not_calculated=0;
            algdescr->SetBody(rel);
            fix->add(algdescr);
        }
         //vergleichsfunctor auf den gleichen wert wie der normale setzen
        GET_VALUE(arg,type,&functorDiff);
        BP_Term arg2;
        TOID toid;
        SYMID symid;
        Tupel tupel;
        for (int i=0;i<arity;i++)
        {
            GET_ARG(arg,i+1,&arg2);
            int type=GET_TYPE(arg2);
            if (type==BP_T_VARIABLE)
            {
                printf("freies Argument in FaktenListe gefunden??!!\n");
                continue;
            }
            if (type==BP_T_ATOM)
            {
                BP_Atom atom2;
                GET_VALUE(arg2,BP_T_ATOM,&atom2);
                if (ATOM2STR(atom2)[0]=='_')
                {
                     //Hack fuer Variablen die als Atoms ankommen...
                    printf("freies Argument in FaktenListe gefunden??!!\n");
                    continue;
                }
                if (!oid2toid( (char *) ATOM2STR(atom2),toid)) 
                {
                    if (get_symb((char*)ATOM2STR(atom2),symid)) tupel[i]=symid;
                    else printf("FaktenListe: konnte atom nicht als symid auslesen\n");
                } else {
                    tupel[i]=toid;
                }
            }
        }
        printf("addiere Faktenloesung: ");tupel.test();printf("\n");
        rel->add(tupel);
        GET_ARG(term,2,&term);
    }    
}


Fixpoint *
TDB::PrologToFixpoint(BP_Term term)
{
    BP_Term arg;
    BP_Atom atom;
    BP_Atom atom_nil = STR2ATOM(TRUE,"[]");
    Fixpoint *fixpoint = new Fixpoint;
    int type;
    int search_space;
    TOID module;
    
//    init_functor();

    arg = term;

    while( GET_TYPE(term) == BP_T_LIST )
    {
        GET_ARG(term,1,&arg);
        if (GET_TYPE(arg) != BP_T_STRUCTURE)
        {
            printf("PrologToFixpoint: falscher Typ innherhalb einer Algebraliste.\n");
            continue;
        }
        
        fixpoint->add(PrologToAlg(arg));
       
        GET_ARG(term,2,&arg);
        term=arg;
    }
    type = GET_TYPE(arg);
    if (type == BP_T_ATOM)
        GET_VALUE(arg,BP_T_ATOM,&atom);
    if (type != BP_T_ATOM || atom != atom_nil)
        printf("PrologToFixpoint: Ungewoehnliches Listenende - ignoriert\n");
    if (overrule_search_space) 
    {
        search_space = overrule_search_space;
        overrule_search_space = 0;
    } 

    else search_space = next_search_space;
    
    if (is_overrule_module)
    {
        module = overrule_module;
        is_overrule_module = 0;
    }
    else module = next_module;

    if (!fixpoint->ok)
    {
         //printf("Fixpoint canceled\n");
        return NULL;
    }
    fixpoint->Set(this,next_search_time,search_space,module);
    return fixpoint;
}


stratified_rules *
TDB::PrologToStratified_rules(BP_Term term)
{
    BP_Term arg;
    BP_Atom atom;
    BP_Atom atom_nil = STR2ATOM(TRUE,"[]");
    stratified_rules *stratified = new stratified_rules;
    int type;
    
    init_functor();

    arg = term;

     //int i=0;
    
    while( GET_TYPE(term) == BP_T_LIST )
    {
        GET_ARG(term,1,&arg);
        if (GET_TYPE(arg) != BP_T_LIST)
        {
            printf("PrologToStratified_rules: falscher Typ innherhalb einer Algebraliste.\n");
            continue;
        }

         //printf("erzeuge Fixpoint ...");
        stratified->add(PrologToFixpoint(arg));
         //printf("okay\n");
        
        GET_ARG(term,2,&arg);
        term=arg;
    }
    type = GET_TYPE(arg);
    if (type == BP_T_ATOM)
        GET_VALUE(arg,BP_T_ATOM,&atom);
    if (type != BP_T_ATOM || atom != atom_nil)
        printf("PrologToStratified_rules: Ungewoehnliches Listenende - ignoriert\n");
    if (stratified->ok) return stratified;
    else 
    {
         //printf("Stratified_rules canceled\n");
        return NULL;
    }
}

void
TDB::CalculateAlgebra(AlgDescription* ad)
{
    int search_space;
    TOID module;
    
    if (overrule_search_space) 
    {
        search_space = overrule_search_space;
        overrule_search_space = 0;
    } 
    else search_space = next_search_space;
    
    if (is_overrule_module)
    {
        module = overrule_module;
        is_overrule_module = 0;
    }
    else module = next_module;
    
    ad->GetBody()->Set(this,next_search_time,search_space,module);
    ad->GetBody()->calc();

    printf("Gesammtergebnis\n");
    
}





