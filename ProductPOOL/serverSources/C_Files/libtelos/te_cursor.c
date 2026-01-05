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

#include "te_cursor.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#ifndef MACOS
#include <malloc.h>
#endif

/* createCursor
 * ----------------------------------------------------------------------
 * Creates and initializes a cursor structure for the given smlfragmentlist.
 * and returns a pointer to it.
 */
LIBTELOS_API PFrameCursor STDCALL te_createCursor(te_SMLfragmentList *fl)
{
  PFrameCursor pfc = malloc(sizeof(TFrameCursor));
  pfc->flAll = fl;

  te_resetFrame(pfc);

  return pfc;
}

/* destroyCursor
 * ----------------------------------------------------------------------
 * Deallocates a cursor structure.
 */
LIBTELOS_API void STDCALL te_destroyCursor(PFrameCursor pfc)
{
  free(pfc);
}


/* ------------------------------------------------------------------------
 *  reset functions
 * ------------------------------------------------------------------------
 */


/* resetFrame
 * ------------------------------------------------------------------------
 * Sets the frame cursor to the first frame and resets all sub cursors.
 */

LIBTELOS_API void STDCALL te_resetFrame(PFrameCursor pfc)
{
  pfc->flCur = pfc->flAll;

  te_resetOmega(pfc);
  te_resetIsA(pfc);
  te_resetIn(pfc);
  te_resetAttrDecl(pfc);
}

/* resetOmega
 * ------------------------------------------------------------------------
 * Sets the omega cursor to the first omega class in the current frame.
 */

LIBTELOS_API void STDCALL te_resetOmega(PFrameCursor pfc)
{
  pfc->clCurOmega = (pfc->flCur) ? pfc->flCur->inOmega : NULL;
}

/* resetIsA
 * ------------------------------------------------------------------------
 * Sets the IsA cursor to the first IsA class  in the current frame.
 */

LIBTELOS_API void STDCALL te_resetIsA(PFrameCursor pfc)
{
  pfc->clCurIsA = (pfc->flCur) ? pfc->flCur->isa : NULL;
}

/* resetIn
 * ------------------------------------------------------------------------
 * Sets the omega cursor to the first omega class  in the current frame.
 */

LIBTELOS_API void STDCALL te_resetIn(PFrameCursor pfc)
{
  pfc->clCurIn = (pfc->flCur) ? pfc->flCur->in : NULL;
}

/* resetAttrDecl
 * ------------------------------------------------------------------------
 * Sets the attr decl block cursor to the first attr decl block  in the
 * current frame.
 */

LIBTELOS_API void STDCALL te_resetAttrDecl(PFrameCursor pfc)
{
  pfc->alCur = (pfc->flCur) ? pfc->flCur->with : NULL;
  pfc->alChecked = NULL;

  te_resetCategory(pfc);
  te_resetProperty(pfc);
}

/* resetCategory
 * ------------------------------------------------------------------------
 * Sets the category cursor to the first category in the current attr decl
 * block.
 */

LIBTELOS_API void STDCALL te_resetCategory(PFrameCursor pfc)
{
  pfc->clCurCategory = (pfc->alCur) ? pfc->alCur->classList : NULL;
}

/* resetProperty
 * ------------------------------------------------------------------------
 * Sets the property cursor to the first property in the current attr decl
 * block.
 */

LIBTELOS_API void STDCALL te_resetProperty(PFrameCursor pfc)
{
  pfc->plCur = (pfc->alCur) ? pfc->alCur->attrList : NULL;
}

/* ------------------------------------------------------------------------
 *  ret functions
 * ------------------------------------------------------------------------
 */

/* readRecOid
 * return a duplicate or a new composed string of the <oid>
 */
char *readRecOid(ObjectIdentifier *oid) {
  char *left, *right, *ret;

  if (oid) {
    if (oid->id) {
      return strdup( oid->id );
    } else {
      left = readRecOid( oid->obj_left );
      right = readRecOid( oid->obj_right );
      ret =(char*) malloc( strlen( left ) + strlen( oid->selector ) + strlen( right ) );
      sprintf( ret, "%s%s%s", left, oid->selector, right );
      free( left );
      free( right );
      return ( ret );
    }
  } else {
    return NULL;
  }
}

/* retOID
 * ------------------------------------------------------------------------
 * Returns a duplicate or a new composed OID
 * Subject: In the most cases the OID is of a simple type
 *          and there is no need to control dynamic variables.
 *          But sometimes the OID is composed like "blub"+"!"+"blabla"
 * Note: The caller is responsible to free the new created string !
 */
LIBTELOS_API char* STDCALL te_retOID(PFrameCursor pfc) {
  return (pfc->flCur) ? readRecOid( pfc->flCur->id ) : NULL;
}

/* retOmega
 * ------------------------------------------------------------------------
 * Returns the current Omega class of the current frame or NULL.
 */

LIBTELOS_API char* STDCALL te_retOmega(PFrameCursor pfc) {
  return (pfc->clCurOmega) ? readRecOid( pfc->clCurOmega->Class ) : NULL;
}


/* retIn
 * ------------------------------------------------------------------------
 * Returns the current In class of the current frame or NULL.
 */

LIBTELOS_API char* STDCALL te_retIn(PFrameCursor pfc) {
  return (pfc->clCurIn) ? readRecOid( pfc->clCurIn->Class ) : NULL;
}


/* retIsA
 * ------------------------------------------------------------------------
 * Returns the current IsA class of the current frame or NULL.
 */

LIBTELOS_API char* STDCALL te_retIsA(PFrameCursor pfc) {
  return (pfc->clCurIsA) ? readRecOid( pfc->clCurIsA->Class ) : NULL;
}

/* retCategory
 * ------------------------------------------------------------------------
 * Returns the current category class of the current attr decl block
 * or NULL.
 */

LIBTELOS_API char* STDCALL te_retCategory(PFrameCursor pfc) {
  return (pfc->clCurCategory) ?  strdup(pfc->clCurCategory->Class) : NULL;
}

/* retLabel
 * ------------------------------------------------------------------------
 * Returns the current label of the current property in the current
 *  decl block or NULL.
 */

LIBTELOS_API char* STDCALL te_retLabel(PFrameCursor pfc) {
  return (pfc->plCur) ?  strdup( pfc->plCur->label ) : NULL;
}

/* retValue
 * ------------------------------------------------------------------------
 * Returns the current value of the current property in the current
 *  decl block or NULL.
 */

LIBTELOS_API char* STDCALL te_retValue(PFrameCursor pfc) {
  return (pfc->plCur) ?  readRecOid( pfc->plCur->value ) : NULL;
}

/* ------------------------------------------------------------------------
 *  next functions
 * ------------------------------------------------------------------------
 */

/* nextOmega
 * ------------------------------------------------------------------------
 * Sets the omega cursor to the next omega class in the current frame.
 */

LIBTELOS_API int STDCALL te_nextOmega(PFrameCursor pfc) {
  if (pfc->clCurOmega) {
    pfc->clCurOmega = pfc->clCurOmega->next;
  }
  return (pfc->clCurOmega != NULL);
}

/* nextIsA
 * ------------------------------------------------------------------------
 * Sets the IsA cursor to the next IsA class in the current frame.
 */

LIBTELOS_API int STDCALL te_nextIsA(PFrameCursor pfc) {
  if (pfc->clCurIsA) {
    pfc->clCurIsA = pfc->clCurIsA->next;
  }
  return (pfc->clCurIsA != NULL);
}

/* nextIn
 * ------------------------------------------------------------------------
 * Sets the In cursor to the next In class in the current frame.
 */

LIBTELOS_API int STDCALL te_nextIn(PFrameCursor pfc) {
  if (pfc->clCurIn) {
    pfc->clCurIn = pfc->clCurIn->next;
  }
  return (pfc->clCurIn != NULL);
}

/* nextCategory
 * ------------------------------------------------------------------------
 * Sets the Category cursor to the next Category class in the current attr
 * decl block frame.
 */

LIBTELOS_API int STDCALL te_nextCategory(PFrameCursor pfc) {
  if (pfc->clCurCategory) {
    pfc->clCurCategory = pfc->clCurCategory->next;
  }
  return (pfc->clCurCategory != NULL);
}

/* nextProperty
 * ------------------------------------------------------------------------
 * Sets the Property cursor to the next Property class in the current
 * attr decl block frame.
 */

LIBTELOS_API int STDCALL te_nextProperty(PFrameCursor pfc) {
  if (pfc->plCur) {
    pfc->plCur = pfc->plCur->next;
  }
  return (pfc->plCur != NULL);
}

/* nextAttrDecl
 * ------------------------------------------------------------------------
 * Sets the Property cursor to the next Property class in the attr decl
 * block frame and resets the Category and Property cursors.
 */

LIBTELOS_API int STDCALL te_nextAttrDecl(PFrameCursor pfc) {
  if (pfc->alCur) {
    pfc->alCur = pfc->alCur->next;
    te_resetCategory(pfc);
    te_resetProperty(pfc);
  }
  pfc->alChecked = NULL; /* a new AttrDecl is not checked ! */
  return (pfc->alCur != NULL);
}

/* nextFrame
 * ------------------------------------------------------------------------
 * Sets the frame cursor to the next frame in the list and resets the
 * Omega, IsA, In, AttrDecl, Category and Property cursors
 */

LIBTELOS_API int STDCALL te_nextFrame(PFrameCursor pfc) {
  if (pfc->flCur) {
    pfc->flCur = pfc->flCur->next;
    te_resetOmega(pfc);
    te_resetIsA(pfc);
    te_resetIn(pfc);
    te_resetAttrDecl(pfc);
  }
  return (pfc->flCur != NULL);
}

/* filterPropertyByCategory
 * ------------------------------------------------------------------------
 * Lists all properties that are of the type <category>
 * The usage of this function is similar to the following function
 *  te_filterPropertyByCategory. The only diffrence is the simplicity of
 *  the second parameter for the case that you only need to filter with
 *  one category.
 */
LIBTELOS_API int STDCALL te_filterPropertyByCategory(PFrameCursor pfc, char *category) {
  char *filter[] = { category, NULL };

  return (te_filterPropertyByCategories( pfc, (category) ? filter : NULL ));
}

/* filterPropertyByCategories
 * ------------------------------------------------------------------------
 * Lists all properties that matches all types of <categories>
 * If the <categories> are empty then any category matches
 * NOTE: Diffrent to the nextXXX functions these function should be
 *       called before the first access via te_retLabel or te_retValue,
 *       because it must search the first valid AttrDecl.
 *       This means at the beginning you should call:
 *       "te_resetAttrDecl( ... );"          AND
 *       "te_filterPropertyByCategories( ... );"
 */
LIBTELOS_API int STDCALL te_filterPropertyByCategories(PFrameCursor pfc, char *categories[]) {
  int tofind = 0;
  /* if AttrDecl is checked then next Property else search a new AttrDecl: */
  if ( pfc->alChecked == pfc->alCur) {
    if (!te_nextProperty( pfc )) te_nextAttrDecl( pfc );
  } /* Note: nextAttrDecl will uncheck the <alChecked> */
  /* if thetest if cat ok: */
  if ( pfc->alChecked != pfc->alCur) {
    do { /* try to find in the ClassList all searched ones: */
      te_resetCategory( pfc ); /* reset for search */
      te_resetProperty( pfc ); /* set ahead for later access */
      /* count the categories to be searched: */
      if (categories) {
	for (tofind = 0; categories[tofind] != NULL; tofind++);
	do { /* if the Category is a searched one then decrement the <tofind>: */
	  char *tmp = te_retCategory( pfc );
	  int i = 0;

	  for (i = 0; categories[i] != NULL; i++) {
	    if (strcmp( categories[i], tmp ) == 0) tofind--;
	  };
	  if (tmp) free(tmp);
	} while ((tofind > 0) && (te_nextCategory( pfc )));
      }
      /* mark the checked category if successful and non empty: */
      if ((tofind == 0) && (pfc->plCur)) pfc->alChecked = pfc->alCur;
      /* if not found and no more AttrDecl to search then the search fails: */
      if ((tofind > 0) && !(te_nextAttrDecl( pfc ))) tofind = -1;
    } while (tofind > 0);
  } /* => end of the frame or (non empty) checked category */
  /* if a next or a first Prop of a new AttrDecl was found then it should be checked: */
  return ((pfc->alChecked == pfc->alCur) && (pfc->alChecked != NULL));
}

/* filterPropertyByLabel
 * ------------------------------------------------------------------------
 * Lists the value of the property with <label> of the current frame
 * This results only one Value which is a new created stringg
 * Note the caller has to dispose the return value !
 */
LIBTELOS_API char* STDCALL te_filterPropertyByLabel(PFrameCursor pfc, char *label) {
  AttrDeclList *attDecList = (pfc->flCur)? pfc->flCur->with : NULL; /* local alCur */

  while ( attDecList ) { /* forall attribute: */
    PropertyList *propList = attDecList->attrList; /* local plCur */
    while ( propList ) { /* forall properties: */
      if (strcmp(propList->label,label) == 0) {
	return readRecOid( propList->value );
      }
      propList = propList->next;
    }
    attDecList = attDecList->next;
  }
  return NULL;
}
