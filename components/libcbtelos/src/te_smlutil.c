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

/* forward declarations */
char *BindingListToString();
char *ObjectIdToString();
void Destroy_ObjectId();
void Destroy_BindingList();
void Destroy_Restriction(Restriction *pRest);

/* Generates a string from a BindingList
   of the form "substitute(a,b),substitute(x,y),..."  */

char *
BindingListToString(BindingList *blist)
{
  BindingList *current;
  char *s, *help, *b1, *b2;
  int l;

  s = strdup("");
  current = blist;
  while (current)
  {
    help = s;
    l = 0;
    b1 = NULL;
    b2 = NULL;
    if ((current->lab1) && (current->lab2))
    {
      b1 = ObjectIdToString(current->lab1);
      b2 = ObjectIdToString(current->lab2);
      s = (char *) malloc(20 + strlen(b1) + strlen(b2) + strlen(help));
      if (strcmp(current->op, "/") == 0)
      {
        sprintf(s, "%ssubstitute(%s,%s),", help, b1, b2);
      }
      else /* current->op == ":" */
      {
        sprintf(s, "%sspecialize(%s,%s),", help, b1, b2);
      }
    }

    current = current->next;
    if (!current)
    { l = strlen(s);
      if (l>0) s[l-1] = '\0';
    }

    if (help) free(help);
    if (b1)   free(b1);
    if (b2)   free(b2);
  }

  return(s);
}


/* Generates from a tree structure for the oid
   a select expression or simple id */
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

/* Generates a string from a ClassList
   of the form "class(...),class(...) ..."       */

char *
ClassListToString(te_ClassList *clist)
{
  te_ClassList *current;
  char *s, *help, *cl;
  int l;

  s = strdup("");
  current = clist;
  while (current)
  {
    help = s;
    l = 0;
    cl = NULL;
    if (current->Class)
    {
      cl = ObjectIdToString(current->Class);
      s = (char *) malloc(10 + strlen(cl) + strlen(help));
      sprintf(s, "%sclass(%s),", help, cl);
    }
    current = current->next;
    if (!current)
    { l = strlen(s);
      if (l>0) s[l-1] = '\0';
    }

    if (help) free(help);
    if (cl)   free(cl);
  }

  return(s);
}

/* Generates a string from an AttrClassList
   of the form "...,..., ..."       */

char *
AClassListToString(AttrClassList *aclist)
{
  AttrClassList *current;
  char *s, *help;
  int l;

  s = strdup("");
  current = aclist;
  while (current)
  {
    help = s;
    l = 0;
    if (current->Class)
    {
      l=strlen(current->Class);
      s = (char *) malloc(6 + l + strlen(help));
      sprintf(s, "%s'%s',", help, current->Class);
    }
    current = current->next;
    if (!current)
    { l = strlen(s);
      if (l>0) s[l-1] = '\0';
    }

    if (help) free(help);
  }

  return(s);
}

/* Generates a string from a PropertyList
   of the form "property(...,...),property(...,...),..." */

char *
PropListToString(PropertyList *plist)
{
  PropertyList *current;
  char *s, *help, *v;
  int l;

  s = strdup("");
  current = plist;
  while (current)
  {
    help = s;
    l = 0;
    v = NULL;
    if ((current->label)&&(current->value))
    {
      v = ObjectIdToString(current->value);
      l = strlen(current->label) + strlen(v);
      s = (char *) malloc(20 + l + strlen(help));
      sprintf(s, "%sproperty('%s',%s),", help, current->label, v);
    }
    current = current->next;
    if (!current)
    { l = strlen(s);
      if (l>0) s[l-1] = '\0';
    }

    if (help) free(help);
    if (v)    free(v);
  }

  return(s);
}

/* Generates a string from an AttDeclList
   of the form "attrdecl([...],[...]),..."   */

char *
ADListToString(AttrDeclList *adlist)
{
  AttrDeclList *current;
  char *classList_String, *attrList_String;
  char *s, *help;
  int l;

  s = strdup("");
  current = adlist;
  while (current)
  {
    help = s;
    classList_String = AClassListToString(current->classList);
    attrList_String = PropListToString(current->attrList);

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

    current = current->next;
    if (!current)
    { l = strlen(s);
      if (l>0) s[l-1] = '\0';
    }

    if (help) free(help);
  }
  return(s);
}

/* frees the memory of an object tree */

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

/* frees the memory of a ClassList */

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

/* frees the memory of a ClassList */

LIBTELOS_API void STDCALL Destroy_ClassList(te_ClassList *clist)
{
  if(clist)
  {
    if (clist->Class) Destroy_ObjectId(clist->Class);
    Destroy_ClassList(clist->next);
    free(clist);
  }
}

/* frees the memory of an AttrClassList */

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

/* Free memory of a Special Object */
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

/* Free memory of a SelectExpB */
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

/* Free memory space of an ObjectSet */
void Destroy_ObjectSet(ObjectSet* pOS) {

    if (pOS) {
	if (pOS->enumeration) Destroy_ClassList(pOS->enumeration);
	if (pOS->selectExp) Destroy_SelectExpB(pOS->selectExp);
	if (pOS->complexRef) DestroySMLfrag(pOS->complexRef);
	free(pOS);
    }
}

/* frees the memory of a PropertyList */

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

/* frees the memory of an AttrDeclList */

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
* Returns the SMLfragmentList element as an SML fragment
* on which the cursor is currently positioned
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
* Release the memory for an SML fragment list
***********************************************/
LIBTELOS_API void STDCALL DestroySMLfrag(te_SMLfragmentList *fragment)
{
  te_SMLfragmentList *current, *help;

  current = fragment;
  while (current)
  {
    if (current->id)      Destroy_ObjectId(current->id);
    if (current->inOmega) Destroy_ClassList(current->inOmega);
    if (current->in)      Destroy_ClassList(current->in);
    if (current->isa)     Destroy_ClassList(current->isa);
    if (current->with)    Destroy_ADList(current->with);

    help = current;
    current = current->next;
    free(help);
  }
}

