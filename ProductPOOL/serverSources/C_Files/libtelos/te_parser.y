/*
The ConceptBase Copyright

Copyright 1988-2009 The ConceptBase Team. All rights reserved.

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

Matthias Jarke, RWTH Aachen, Informatik 5, Ahornstr. 55, 52056 Aachen, Germany
Manfred Jeusfeld, Tilburg University, Warandelaan 2, 5037 AB Tilburg, The Netherlands
Christoph Quix, RWTH Aachen, Informatik 5, Ahornstr. 55, 52056 Aachen, Germany


This license is a FreeBSD copyright license.
Legal home of the FreeBSD copyright license: http://www.freebsd.org/copyright/freebsd-license.html
*/
%{

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "fragment.h"
#include "te_smlutil.h"

/***********************************************************
 *
 *          DEKLARATIONS
 *
 **********************************************************/

/* extern deklarations */
#define yytext te_parser_text
#define YYERROR_VERBOSE 1
extern char yytext[];
extern int te_parser_lineno;
extern char* te_parser_errmsg;
extern int te_parse_mode;
extern int te_parser_lex();

/* global deklarations */

te_SMLfragmentList *te_sml;          /* globale Struktur, die 
			             SML-Fragmente enthaelt */
te_ClassList *te_classes;            /* globale Struktur, die eine
                                   ClassList enthaelt */
/* lokal deklarations */

te_SMLfragmentList *head, *tail;

char *te_tokenaftererror;   /* Inhalt des Tokens nach einem Fehler */
int te_errorline;           /* Zeilennummer der zuletzt geparsten 
                               Zeile */
int returnvalue;

/* forward deklarations */

int te_parser_wrap();
void te_parser_error(char* s);
void te_frame_ende();
void te_classlist_ende();
void te_reset();
void init_SMLfragmentlist();
void InsertTail();
ObjectIdentifier *new_Oid();
ObjectIdentifier *new_Select();
BindingList *new_bindList();
BindingList *concat_bindList();
BindingList *insert_bindList();
te_ClassList *new_Class();
te_ClassList *concat_Classlist();
AttrClassList *new_AttrClass();
AttrClassList *concat_AttrClasslist();
PropertyList *new_Property();
PropertyList *concat_PropList();
AttrDeclList *new_Decl();
AttrDeclList *concat_DeclList();
ObjectSet* new_objectSet();
SelectExpB* new_selectExpB(SpecObjId *oid,
			   Restriction *restleft,
			   char *labelleft,
			   char Operator,
			   SelectExpB *selectExp,
			   char *labelright,
			   Restriction *restright);
Restriction* new_restriction(char *label,
			     ObjectIdentifier *Class,
			     te_ClassList *enumeration,
			     SelectExpB *sb);
				 
SpecObjId *new_SpecObjId(char *label,
                           SpecObjId *right,
						   ObjectIdentifier *id);
						   
te_SMLfragmentList* new_smlFragmentList(ObjectIdentifier	*id,
		   te_ClassList		*inOmega,
		   te_ClassList		*in,
		   te_ClassList		*isa,
		   AttrDeclList		*with,
		   struct smlfragmentList	*next);

%}

/* Definition of yylval (synthesized attribute) */

%union { 
  char			    ch;
  char			    *s;
  struct objectIdentifier   *o;
  struct bindingList	    *b;
  struct classlist	    *c;
  struct attrdecllist	    *d;
  struct attrclasslist	    *a;
  struct propertylist	    *p;
  struct selectexpb	    *sexp;
  struct objectset	    *os;
  struct smlfragmentList    *sml;
  struct restriction	    *r;
  struct specObjId          *specoid;
}

/* Tokendeklaration */

%token <s> IN
%token <s> ISA
%token <s> WITH
%token <s> END
%token <s> ENDMIT
%left  <s> SELECTOR2   /* hiermit wird eine niedrigere 
                          Prioritaet von Selektor2 gegenueber
                          Selektor1 ausgedrueckt */
%left  <s> SELECTOR1
/* %token <s> ALPHANUM */
%token <s> LABEL
%token <s> NUMBER
%token <ch> SELECTORB
%token <s> ERROR
%token ENDOFINPUT

/* Typdeklaration for the nonterminals */

%type  <s> objectlist
%type  <s> object
%type  <s> choice
%type  <o> objectname
%type  <o> className
%type  <b> bindings
%type  <b> bindinglist
%type  <b> singlebinding
%type  <s> endspec
%type  <s> label
%type  <c> classlist
%type  <c> inspec
%type  <c> isaspec
%type  <d> withspec
%type  <d> decllist
%type  <d> declaration
%type  <a> attrcatlist
%type  <p> propertylist 
%type  <p> property 
%type  <os> setofobjects
%type  <c> enumeration
%type  <sexp> selectexpb
%type  <sexp> selectexpb2
%type  <sexp> selectexpb3
%type  <sml> complexref
%type  <r> restriction
%type  <specoid> specobjname
%type  <specoid> specobjname2

%start spec

%%
/***********************************************************
 *
 *         YACC-GRAMMAR
 *
 **********************************************************/
spec	       :		{ init_SMLfragmentlist();
                                  returnvalue=0; }
								  choice         { te_parser_wrap();
				  return(returnvalue);
						}
               ;
choice        : /*empty */  { returnvalue=0; }
              | objectlist ENDOFINPUT	{ 
				  if (te_parse_mode) { 
					  te_frame_ende();
					  returnvalue=0;
				  } 
				  else {
					  te_parser_error(NULL);
					  returnvalue=1;
				  }
			  }
              | classlist ENDOFINPUT {
				  if (!te_parse_mode) { 
					  te_classes = $1;
					  te_classlist_ende();
					  returnvalue=0;
				  } 
				  else { 
					  te_parser_error(NULL);
					  returnvalue=1;
 				  }
			  }
              | error { 
				  te_parser_error(NULL);
				  returnvalue=1;
			  }
              ; 
objectlist     : /*empty list */ 
               | object
               | objectlist
                 object
               ;
object	       : objectname
		 objectname		
		 inspec	    
                 isaspec
                 withspec
		 endspec	{InsertTail($2, new_Class($1), $3, $4, $5);}
               | objectname		
		 inspec	    
                 isaspec
                 withspec
		 endspec	{InsertTail($1, NULL, $2, $3, $4);}
               ;
classlist      : className	{$$ = new_Class($1);}
               | classlist
                 ','
		 className	{$$ = concat_Classlist($1, new_Class($3));}
              ;

className     :	objectname	{$$ = $1;}
              ;

objectname    : '('
                 objectname
		 ')'		{$$ = $2;}
	       | label 
		 bindings	{$$ = new_Oid($1, $2);}
	       | objectname
		 SELECTOR1	
		 label		{$$ = new_Select($1, $2, new_Oid($3, NULL));}   
               | objectname
                 SELECTOR2
                 objectname     {$$ = new_Select($1, $2, $3);}   
               ;
               
specobjname    : '(' specobjname ')'         { $$ = $2; }
               | label ':' ':' specobjname2  { $$ = new_SpecObjId($1,$4, 0); }
			   | objectname                  { $$ = new_SpecObjId( 0, 0,$1); }
               ;
specobjname2   : label ':' ':' specobjname2  { $$ = new_SpecObjId($1,$4, 0); }
               | label                       { $$ = new_SpecObjId($1, 0, 0); }
			   ;

bindings       : /* empty */	{$$ = NULL;}
               | '[' bindinglist ']'		{$$ = $2;}
               ;

bindinglist    : singlebinding	{$$ = $1;}
               | bindinglist  ',' singlebinding	{$$ = concat_bindList($1, $3);}
               ; 

singlebinding  : objectname '/' label  { $$ = new_bindList($1,"/",new_Oid($3,NULL)); }
               | label ':' objectname   { $$ = new_bindList(new_Oid($1,NULL),":",$3); }
               ;

inspec	       : /* empty */	{$$ = NULL;}
	       | IN classlist	{$$ = $2;}
               ;
isaspec	       : /* empty */	{$$ = NULL;}
	       | ISA classlist	{$$ = $2;}
               ;
withspec       : /* empty */	{$$ = NULL;}
	       | WITH decllist	{$$ = $2;}
               ;
decllist       : /* empty */    {$$ = NULL;}
	       | declaration	{$$ = $1;}
               | decllist
		 declaration	{$$ = concat_DeclList($1, $2);}
               ;
declaration    : attrcatlist 
                 propertylist   {$$ = new_Decl($1, $2);}
               ;
attrcatlist    : label		{$$ = new_AttrClass($1);}
               | attrcatlist
                 ','
		 label		{$$ = concat_AttrClasslist($1, new_AttrClass($3));}
               ;
propertylist   : property	{$$ = $1;}
               | propertylist
                 ';'
		 property	{$$ = concat_PropList($1, $3);}
               ;
property       : label ':' objectname	{$$ = new_Property($1, $3, 0);}  
               | label ':' setofobjects	{$$ = new_Property($1, 0, $3);}  
               ; 
setofobjects   : enumeration { $$=new_objectSet($1,0,0);}
	           | selectexpb  { $$=new_objectSet(0,$1,0);}
	           | complexref  { $$=new_objectSet(0,0,$1);}
	           ;
enumeration    : '[' classlist ']' { $$= $2;}  
               ;  
selectexpb     : specobjname SELECTORB label        { $$ = new_selectExpB($1, 0, 0,$2, 0,$3, 0);}
               | specobjname SELECTORB selectexpb2  { $$ = new_selectExpB($1, 0, 0,$2,$3, 0, 0);}
	           | specobjname SELECTORB restriction  { $$ = new_selectExpB($1, 0, 0,$2, 0, 0,$3);}
               ;
selectexpb2    : selectexpb3   { $$ = $1;}
               | restriction SELECTORB label       { $$ = new_selectExpB( 0,$1, 0,$2, 0,$3, 0);}
	           | restriction SELECTORB selectexpb2 { $$ = new_selectExpB( 0,$1, 0,$2,$3, 0, 0);}
	           | restriction SELECTORB restriction { $$ = new_selectExpB( 0,$1, 0,$2, 0, 0,$3);}
	           ;
selectexpb3    : label SELECTORB label        { $$ = new_selectExpB( 0, 0,$1,$2, 0,$3, 0);}
               | label SELECTORB selectexpb2  { $$ = new_selectExpB( 0, 0,$1,$2,$3, 0, 0);}
	           | label SELECTORB restriction  { $$ = new_selectExpB( 0, 0,$1,$2, 0, 0,$3);}
               ;
restriction    : '(' label ':' objectname  ')' { $$= new_restriction($2,$4,0,0); }
               | '(' label ':' enumeration ')' { $$= new_restriction($2,0,$4,0); }
               | '(' label ':' selectexpb  ')' { $$= new_restriction($2,0,0,$4); }
               ;
complexref     : classlist WITH decllist endspec { $$=new_smlFragmentList(NULL,NULL,NULL,$1,$3,NULL);}  
               ;  
endspec	       : END
               | ENDMIT 
                 objectname
	       ;
label	       : LABEL          {$$ = $1;}
			   | NUMBER    {$$ = $1;}
               ;
%%

/***********************************************************
 *
 *        ADDITIONAL C-FUNCTIONS
 *
 * *********************************************************/
/* Fehlerbehandlung, falls der Ausdruck nicht erfolgreich geparst wurde */

void te_parser_error(char *s)
{
  if (!s) {
      s="parse error";
  }
#ifdef DEBUG	
  printf("Parser ended with error at \"%s\" !\n", (char *)s);
#endif
  
  /* Setze das Errortoken nur einmal, es sei denn, es ist "parse error" */
  if ((!te_tokenaftererror) || (!strcmp(te_tokenaftererror,"parse error"))) {
      if(te_parser_errmsg) {
	  /* Lexical error reported by scanner */
	  te_tokenaftererror = (char*) strdup(te_parser_errmsg);
	  free(te_parser_errmsg);
      }
      else {
          te_tokenaftererror = (char *)strdup(s);
      }
      te_errorline = te_parser_lineno;
  }
  

  if(head)
  {
      /* Bislang aufgebaute Struktur zerstoeren, damit der
        Speicherplatz wieder freigegeben wird */
      DestroySMLfrag(head);
      head = NULL;
  }
  te_sml = NULL;
}

/*---------------------------------------------------------*/
/* Zuruecksetzen des Parsers auf den Anfangszustand */
void te_reset()
{
}
/*---------------------------------------------------------*/
/* erfolgreiches Beenden */

void te_frame_ende()
{
#ifdef DEBUG	
  printf("Parser ended correctly !\n");
#endif
	
  te_tokenaftererror = NULL;
  te_errorline = 0;
  te_sml = head;
  te_classes = NULL;
}

void te_classlist_ende()
{
#ifdef DEBUG
  printf("Parser ended correctly !\n");
#endif	
  te_tokenaftererror = NULL;
  te_errorline = 0;
  te_sml = NULL;
}

/*---------------------------------------------------------*/
/* Initialisierung */
void
init_SMLfragmentlist()
{
  te_sml = NULL;
  head = NULL;
  tail = NULL;
}
/*---------------------------------------------------------*/
/* Einfuegen eines Fragmentes am Ende der Liste */
void
InsertTail(ObjectIdentifier *objectid, te_ClassList *inOmega, te_ClassList * in, te_ClassList *isa, AttrDeclList *with)
{
  te_SMLfragmentList *fragment;

  fragment = (te_SMLfragmentList *)malloc(sizeof(te_SMLfragmentList));
  fragment->id = objectid;
  fragment->inOmega = inOmega;
  fragment->in = in;
  fragment->isa = isa;
  fragment->with = with;
  fragment->next = NULL;

  if(head)
  {
    tail->next=fragment;
    tail=fragment;
  }
  else
  {
     head=fragment;
     tail=fragment;
  }
}

/*---------------------------------------------------------*/
/* neue ObjectId */
ObjectIdentifier *
new_Oid(char *data, BindingList *bList)
{
  ObjectIdentifier *oid;
	
  oid = (ObjectIdentifier *)malloc(sizeof(ObjectIdentifier));
  oid->id = strdup(data);
  oid->bind = bList;
  oid->selector = NULL;
  oid->obj_left = NULL;
  oid->obj_right = NULL;

  return(oid);
} 

ObjectIdentifier *
new_Select(ObjectIdentifier *o1, char *sel, ObjectIdentifier *o2)
{
  ObjectIdentifier *oid;

  oid = (ObjectIdentifier *)malloc(sizeof(ObjectIdentifier));
  oid->id = NULL;
  oid->bind = NULL;
  oid->selector = strdup(sel);
  oid->obj_left = o1;
  oid->obj_right = o2;

  return(oid);
} 

/*---------------------------------------------------------*/
/* neue Bindinglist generieren */
BindingList *
new_bindList(ObjectIdentifier *id1, char *o, ObjectIdentifier *id2)
{
  BindingList *bList;

  bList = (BindingList *)malloc(sizeof(BindingList));
  bList->lab1 = id1;
  bList->op = strdup(o);
  bList->lab2 = id2;
  bList->next = NULL;

  return(bList);
}
/*---------------------------------------------------------*/
/* Zusammenfuegen zweier Bindinglisten */

BindingList *
concat_bindList(BindingList *bl1, BindingList *bl2)
{
  BindingList *lauf;

  lauf = bl1;
  while (lauf->next) lauf=lauf->next;
  lauf->next = bl2;

  return(bl1);
}
/*---------------------------------------------------------*/
/* Einfuegen des ersten labels in eine Bindinglist */
BindingList *
insert_bindList(BindingList *bl1, ObjectIdentifier *id)
{
  bl1->lab1 = id;

  return(bl1);
}

/*---------------------------------------------------------*/
/* neue Classlist generieren */

te_ClassList *
new_Class(ObjectIdentifier *data)
{
  te_ClassList *cl;

  cl = (te_ClassList *) malloc(sizeof(te_ClassList));
  cl->Class = data;
  cl->next = NULL;

  return(cl);
}
/*---------------------------------------------------------*/
/* Zusammenfuegen zweier Classlisten */

te_ClassList *
concat_Classlist(te_ClassList *cl1, te_ClassList *cl2)
{
  te_ClassList *lauf;

  lauf = cl1;
  while (lauf->next) lauf=lauf->next;
  lauf->next = cl2;
  
  return(cl1);
}
/*---------------------------------------------------------*/
/* neues AttrClasslist generieren */

AttrClassList *
new_AttrClass(char *data)
{
  AttrClassList *cl;

  cl = (AttrClassList *) malloc(sizeof(AttrClassList));
  cl->Class = strdup(data);
  cl->next = NULL;

  return(cl);
}
/*---------------------------------------------------------*/
/* Zusammenfuegen zweier Classlisten */

AttrClassList *
concat_AttrClasslist(AttrClassList *cl1, AttrClassList *cl2)
{
  AttrClassList *lauf;

  lauf = cl1;
  while (lauf->next) lauf=lauf->next;
  lauf->next = cl2;
  
  return(cl1);
}
/*---------------------------------------------------------*/
/* neue Propertylist generieren */

PropertyList *
new_Property(char *label, ObjectIdentifier *value, ObjectSet *objectSet)
{
  PropertyList *prop;

  prop = (PropertyList *) malloc(sizeof(PropertyList));
  prop->label = strdup(label);
  prop->value = value;
  prop->objectSet = objectSet;
  prop->next = NULL;

  return(prop);
}
/*---------------------------------------------------------*/
/* Zusammenfuegen zweier Propertylisten */

PropertyList *
concat_PropList(PropertyList *pl1, PropertyList *pl2)
{
  PropertyList *lauf;

  lauf = pl1;
  while (lauf->next) lauf=lauf->next;
  lauf->next = pl2;
  
  return(pl1);
}
/*---------------------------------------------------------*/
/* neue DeclarationList generieren */

AttrDeclList *
new_Decl(AttrClassList *classList, PropertyList *attrList)
{
  AttrDeclList *adecl;

  adecl = (AttrDeclList *) malloc(sizeof(AttrDeclList));
  adecl->classList = classList;
  adecl->attrList = attrList;
  adecl->next = NULL;
  
  return(adecl);
}
/*---------------------------------------------------------*/
/* Zusammenfuegen zweier Declarationlisten */

AttrDeclList *
concat_DeclList(AttrDeclList *ad1, AttrDeclList *ad2)
{
  AttrDeclList *lauf;

  lauf = ad1;
  while (lauf->next) lauf=lauf->next;
  lauf->next = ad2;
  
  return(ad1);
}
/*---------------------------------------------------------*/
/* neues ObjectSet generieren */

ObjectSet* new_objectSet(te_ClassList *enumeration,
			 SelectExpB *selectExp,
			 te_SMLfragmentList *complexRef) {

    ObjectSet *new_os;

    new_os = (ObjectSet *) malloc(sizeof(ObjectSet));

    new_os->enumeration	= enumeration;
    new_os->selectExp	= selectExp;
    new_os->complexRef	= complexRef;

    return (new_os);
}

/*---------------------------------------------------------*/
/*  Neue SelectExpB generieren */

SelectExpB* new_selectExpB(SpecObjId *oid,
			   Restriction *restleft,
			   char *labelleft,
			   char Operator,
			   SelectExpB *selectExp,
			   char *labelright,
			   Restriction *restright) {

    SelectExpB *new_sel;

    new_sel = (SelectExpB *) malloc(sizeof(SelectExpB));

    new_sel->objectleft=oid;
    new_sel->restleft=restleft;
	new_sel->labelleft=labelleft;
    new_sel->Operator=Operator;
    new_sel->selectExp=selectExp;
    new_sel->labelright=labelright;
    new_sel->restright=restright;

    return (new_sel);
}


/*---------------------------------------------------------*/
/*  Neue Restriction generieren */
Restriction* new_restriction(char *label,
			     ObjectIdentifier *Class,
			     te_ClassList *enumeration,
			     SelectExpB *sb) {

    Restriction *new_rest;

    new_rest=(Restriction *) malloc(sizeof(Restriction));

    new_rest->label=label;
    new_rest->Class=Class;
    new_rest->enumeration=enumeration;
    new_rest->selectExp=sb;

    return (new_rest);
}

/*---------------------------------------------------------*/
/*  Neues Special-Objekt generieren (wird fuer SelectExpressions benoetigt) */
SpecObjId *new_SpecObjId(char *label,
                         SpecObjId *specobjright,
						 ObjectIdentifier *oid) {

    SpecObjId *new_spec;
	
	new_spec = (SpecObjId *) malloc(sizeof(SpecObjId));
	
	new_spec->label=label;
	new_spec->specobjright=specobjright;
	new_spec->oid=oid;
	
	return (new_spec);	
}

/*---------------------------------------------------------*/
/*  Neue SMLFragmentList anlegen (fuer complexRef) */

te_SMLfragmentList*
new_smlFragmentList(ObjectIdentifier	*id,
		   te_ClassList		*inOmega,
		   te_ClassList		*in,
		   te_ClassList		*isa,
		   AttrDeclList		*with,
		   struct smlfragmentList	*next) {

    te_SMLfragmentList* fragment;

    fragment= (te_SMLfragmentList*) malloc(sizeof(te_SMLfragmentList));

    fragment->id=id;
    fragment->inOmega=inOmega;
    fragment->in=in;
    fragment->isa=isa;
    fragment->with=with;
    fragment->next=next;

    return (fragment);

}

