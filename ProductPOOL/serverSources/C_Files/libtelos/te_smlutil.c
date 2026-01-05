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
/**********************************************
* File:        te_smlutil.c
* Version:     1.4
* Creation:    19.05.1993, C. Welter
* Last Change: 6/1/93 CW
* Release:
* Description:
***********************************************/


/* include section */
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "te_smlutil.h"


/***********************************************
*
*  private procedures and functions
*
***********************************************/

/* forward deklarartions */
char *BindingListToString();
char *ObjectIdToString();
void Destroy_ObjectId();
void Destroy_BindingList();
void Destroy_Restriction(Restriction *pRest);

/* generiert aus einer BindingList einen String
   der Form "substitute(a,b),substitute(x,y),..."  */

char *
BindingListToString(BindingList *blist)
{
  BindingList *lauf;
  char *s, *help, *b1, *b2;
  int l;

  s = strdup("");
  lauf = blist;
  while (lauf)
  {
    help = s;
    l = 0;
    b1 = NULL;
    b2 = NULL;
    if ((lauf->lab1) && (lauf->lab2))
    {
      b1 = ObjectIdToString(lauf->lab1);
      b2 = ObjectIdToString(lauf->lab2);
      s = (char *) malloc(20 + strlen(b1) + strlen(b2) + strlen(help));
      if (strcmp(lauf->op, "/") == 0)
      {
        sprintf(s, "%ssubstitute(%s,%s),", help, b1, b2);
      }
      else /* lauf->op == ":" */
      {
        sprintf(s, "%sspecialize(%s,%s),", help, b1, b2);
      }
    }

    lauf = lauf->next;
    if (!lauf)
    { l = strlen(s);
      if (l>0) s[l-1] = '\0';
    }

    if (help) free(help);
    if (b1)   free(b1);
    if (b2)   free(b2);
  }

  return(s);
}


/* generiert aus einer Baumstruktur fuer den oid
   einen Select-expression oder einfachen id  */
char *
ObjectIdToString(ObjectIdentifier *oid)
{
  char *s, *b, *help_left, *help_right;

  s = strdup("");
  if (oid)
  {
    if (oid->id)
    {
      if (oid->bind)
      {
        b = BindingListToString(oid->bind);
        s = (char *)malloc(20 + strlen(oid->id) + strlen(b));
        sprintf(s, "derive('%s',[%s])", oid->id, b);
      } else
      {
        s = (char *)malloc(4 + strlen(oid->id));
        sprintf(s, "'%s'", oid->id);
      }
    } else
    {
      help_left = strdup("");
      if (oid->obj_left) help_left=ObjectIdToString(oid->obj_left);
      help_right = strdup("");
      if (oid->obj_right) help_right=ObjectIdToString(oid->obj_right);
      s = (char *)malloc(20 + strlen(help_left) + strlen(oid->selector) + strlen(help_right));
      sprintf(s, "select(%s,'%s',%s)",
                  help_left, oid->selector, help_right);
      free(help_left);
      free(help_right);
    }
  }
  return(s);
}

/* generiert aus einer ClassList einen String
   der Form "class(...),class(...) ..."       */

char *
ClassListToString(te_ClassList *clist)
{
  te_ClassList *lauf;
  char *s, *help, *cl;
  int l;

  s = strdup("");
  lauf = clist;
  while (lauf)
  {
    help = s;
    l = 0;
    cl = NULL;
    if (lauf->Class)
    {
      cl = ObjectIdToString(lauf->Class);
      s = (char *) malloc(10 + strlen(cl) + strlen(help));
      sprintf(s, "%sclass(%s),", help, cl);
    }
    lauf = lauf->next;
    if (!lauf)
    { l = strlen(s);
      if (l>0) s[l-1] = '\0';
    }

    if (help) free(help);
    if (cl)   free(cl);
  }

  return(s);
}

/* generiert aus einer AttrClassList einen String
   der Form "...,..., ..."       */

char *
AClassListToString(AttrClassList *aclist)
{
  AttrClassList *lauf;
  char *s, *help;
  int l;

  s = strdup("");
  lauf = aclist;
  while (lauf)
  {
    help = s;
    l = 0;
    if (lauf->Class)
    {
      l=strlen(lauf->Class);
      s = (char *) malloc(6 + l + strlen(help));
      sprintf(s, "%s'%s',", help, lauf->Class);
    }
    lauf = lauf->next;
    if (!lauf)
    { l = strlen(s);
      if (l>0) s[l-1] = '\0';
    }

    if (help) free(help);
  }

  return(s);
}

/* generiert aus einer PropertyList einen String
   der Form "property(...,...),property(...,...),..." */

char *
PropListToString(PropertyList *plist)
{
  PropertyList *lauf;
  char *s, *help, *v;
  int l;

  s = strdup("");
  lauf = plist;
  while (lauf)
  {
    help = s;
    l = 0;
    v = NULL;
    if ((lauf->label)&&(lauf->value))
    {
      v = ObjectIdToString(lauf->value);
      l = strlen(lauf->label) + strlen(v);
      s = (char *) malloc(20 + l + strlen(help));
      sprintf(s, "%sproperty('%s',%s),", help, lauf->label, v);
    }
    lauf = lauf->next;
    if (!lauf)
    { l = strlen(s);
      if (l>0) s[l-1] = '\0';
    }

    if (help) free(help);
    if (v)    free(v);
  }

  return(s);
}

/* generiert aus einer AttDeclList einen String
   der Form "attrdecl([...],[...]),..."   */

char *
ADListToString(AttrDeclList *adlist)
{
  AttrDeclList *lauf;
  char *classList_String, *attrList_String;
  char *s, *help;
  int l;

  s = strdup("");
  lauf = adlist;
  while (lauf)
  {
    help = s;
    classList_String = AClassListToString(lauf->classList);
    attrList_String = PropListToString(lauf->attrList);

    if ((classList_String) && (attrList_String))
    {
      l = strlen(classList_String)+strlen(attrList_String);
      s = (char *) malloc(20 + l + strlen(help));
      sprintf(s, "%sattrdecl([%s],[%s]),", help,
                   classList_String, attrList_String);
      if (classList_String)
      { free(classList_String);
        classList_String = NULL;
      }
      if (attrList_String)
      { free(attrList_String);
        attrList_String = NULL;
      }
    }

    lauf = lauf->next;
    if (!lauf)
    { l = strlen(s);
      if (l>0) s[l-1] = '\0';
    }

    if (help) free(help);
  }
  return(s);
}

/* gibt den Speicherplatz eines Objektbaumes wieder frei */

void
Destroy_ObjectId(ObjectIdentifier *oid)
{
  if (oid->id)
  {
    free(oid->id);
    if (oid->bind) Destroy_BindingList(oid->bind);
  } else
  {
    if (oid->obj_left)  Destroy_ObjectId(oid->obj_left);
    if (oid->obj_right) Destroy_ObjectId(oid->obj_right);
    if (oid->selector) free(oid->selector);
  }
}

/* gibt den Speicherplatz einer ClassList wieder frei */

void
Destroy_BindingList(BindingList *blist)
{
  if(blist)
  {
    if (blist->lab1) Destroy_ObjectId(blist->lab1);
    if (blist->lab2) Destroy_ObjectId(blist->lab2);
    if (blist->op) free(blist->op);
    Destroy_BindingList(blist->next);
    free(blist);
  }
}

/* gibt den Speicherplatz einer ClassList wieder frei */

LIBTELOS_API void STDCALL Destroy_ClassList(te_ClassList *clist)
{
  if(clist)
  {
    if (clist->Class) Destroy_ObjectId(clist->Class);
    Destroy_ClassList(clist->next);
    free(clist);
  }
}

/* gibt den Speicherplatz einer AttrClassList wieder frei */

void
Destroy_AClassList(AttrClassList *aclist)
{
  if(aclist)
  {
    if (aclist->Class) free(aclist->Class);
    Destroy_AClassList(aclist->next);
    free(aclist);
  }
}

/* Speicherplatz eines Special Objects freigeben */
void Destroy_SpecObjId(SpecObjId *o)  {

	if (o)  {
		if (o->label)
			free (o->label);
		if (o->specobjright)
			Destroy_SpecObjId(o->specobjright);
		if (o->oid)
			Destroy_ObjectId(o->oid);
		free(o);
	}
}

/* Speicherplatz von einer SelectExpB freigeben */
void Destroy_SelectExpB(SelectExpB *pSelectExpB) {

    if (pSelectExpB) {
		if (pSelectExpB->objectleft)
	    	Destroy_SpecObjId(pSelectExpB->objectleft);
		if (pSelectExpB->restleft)
	    	Destroy_Restriction(pSelectExpB->restleft);
		if (pSelectExpB->labelleft)
			free(pSelectExpB->labelleft);
		if (pSelectExpB->selectExp)
			Destroy_SelectExpB(pSelectExpB->selectExp);
		if (pSelectExpB->labelright)
			free(pSelectExpB->labelright);
		if (pSelectExpB->restright)
			Destroy_Restriction(pSelectExpB->restright);
		free(pSelectExpB);
    }
}

void Destroy_Restriction(Restriction *pRest) {

    if (pRest) {
	if (pRest->label)
	    free(pRest->label);
	if (pRest->Class)
	    Destroy_ObjectId(pRest->Class);
	if (pRest->enumeration)
	    Destroy_ClassList(pRest->enumeration);
	if (pRest->selectExp)
	    Destroy_SelectExpB(pRest->selectExp);
	free(pRest);
    }
}

/* Speicherplatz von einem ObjectSet freigeben */
void Destroy_ObjectSet(ObjectSet* pOS) {

    if (pOS) {
	if (pOS->enumeration) Destroy_ClassList(pOS->enumeration);
	if (pOS->selectExp) Destroy_SelectExpB(pOS->selectExp);
	if (pOS->complexRef) DestroySMLfrag(pOS->complexRef);
	free(pOS);
    }
}

/* gibt den Speicherplatz einer PropertyList wieder frei */

void
Destroy_PropList(PropertyList *plist)
{
  if(plist)
  {
    if(plist->label) free(plist->label);
    if(plist->value) Destroy_ObjectId(plist->value);
    if(plist->objectSet) Destroy_ObjectSet(plist->objectSet);
    Destroy_PropList(plist->next);
    free(plist);
  }
}

/* gibt den Speicherplatz einer AttrDeclList wieder frei */

void
Destroy_ADList(AttrDeclList *adlist)
{
  if(adlist)
  {
    if(adlist->classList) Destroy_AClassList(adlist->classList);
    if(adlist->attrList) Destroy_PropList(adlist->attrList);
    Destroy_ADList(adlist->next);
    free(adlist);
  }
}

/***********************************************
*
*  public procedures and functions
*
***********************************************/

/***********************************************
* Gibt das Element der SMLfragmentList als SML-Fragment
* aus, auf dem der Cursor augenblicklich steht
***********************************************/
LIBTELOS_API char* STDCALL FragmentToString(te_SMLfragmentList *cursor)
{
  char *s;
  char *objectId, *inOmega_String, *in_String, *isa_String, *with_String;

  objectId       = ObjectIdToString(cursor->id);
  inOmega_String = ClassListToString(cursor->inOmega);
  in_String      = ClassListToString(cursor->in);
  isa_String     = ClassListToString(cursor->isa);
  with_String    = ADListToString(cursor->with);

  s = (char *) malloc(70+strlen(objectId)+strlen(inOmega_String)+strlen(in_String)+strlen(isa_String)+strlen(with_String));

  sprintf(s, "SMLfragment(what(%s),in_omega([%s]),in([%s]),isa([%s]),with([%s]))",
          objectId, inOmega_String, in_String, isa_String, with_String);

  free(objectId);
  free(inOmega_String);
  free(in_String);
  free(isa_String);
  free(with_String);

  return(s);
}

/***********************************************
* Freigabe des Speicherplatzes fuer eine SMLfragmentliste
***********************************************/
LIBTELOS_API void STDCALL DestroySMLfrag(te_SMLfragmentList *fragment)
{
  te_SMLfragmentList *lauf, *help;

  lauf = fragment;
  while (lauf)
  {
    if (lauf->id)      Destroy_ObjectId(lauf->id);
    if (lauf->inOmega) Destroy_ClassList(lauf->inOmega);
    if (lauf->in)      Destroy_ClassList(lauf->in);
    if (lauf->isa)     Destroy_ClassList(lauf->isa);
    if (lauf->with)    Destroy_ADList(lauf->with);

    help = lauf;
    lauf = lauf->next;
    free(help);
  }
}

