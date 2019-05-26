/*
The ConceptBase.cc Copyright

Copyright 1987-2019 The ConceptBase Team. All rights reserved.

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
//==========================================================================
//
// = LIBRARY
//     xi/telos
//
// = FILENAME
//     $RCSfile: te_access.c,v $
//
// = NAME
//     te_cursor - A C API to access parsed telos frames.
//
// = REVISION
//     $Revision: 14.18 $
//     $Date: 2019/01/09 10:24:20 $
//     $Author: jeusfeld $
//     $Locker:  $
//
// = AUTHOR(S)
//     Michael Gebhardt
//
// = COPYRIGHT
//     Copyright 1995 Lehrstuhl Informatik V - RWTH Aachen
//
// =========================================================================
*/

#include "te_access.h"
#include "te_callparser.h" /* used for vt_createByFragment */
#include "te_smlutil.h"    /* used for vt_createByFragment */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#ifndef MACOS
#include <malloc.h>
#endif

/* readRecId
 * return a duplicate or a new composed string of the <oid>
 */
char *readRecId(ObjectIdentifier *oid) {
  char *left, *right, *ret;

  if (oid) {
    if (oid->id) {
      return strdup( oid->id );
    } else {
      left = readRecId( oid->obj_left );
      right = readRecId( oid->obj_right );
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

/* te_createClassList
 * ------------------------------------------------------------------------
 * Maps the given classlist <cl> into a vector of strings.
 */
char **te_createClassList(te_ClassList *cl) {
  char **ret = NULL;
  te_ClassList *tmpCl = cl;
  int i = 0;

  i = 0;
  for (tmpCl = cl; tmpCl != NULL; tmpCl = tmpCl->next ) i++;
  ret =(char **) malloc( (i+1) * sizeof(char *) );
  i = 0;
  for (tmpCl = cl; tmpCl != NULL; tmpCl = tmpCl->next ) {
    ret[i++] = readRecId( tmpCl->Class );
  };
  ret[i] = NULL;
  return ret;
}

/* te_createAttrDecl
 * ------------------------------------------------------------------------
 * Maps the given node of the attribute declaration <adl>
 *  into a structor of three vector of strings.
 * ( aszCategory, aszLabel, aszValue )
 * Note: That these new structur does not match direct the Telos structur,
 *       but it is much easier to use labels and values as two separated
 *       correlated vectors of a basic type,
 *       instead of a construction like vector of pairs of label and value.
 */
PAttrDecl te_createAttrDecl(AttrDeclList *adl) {
  PAttrDecl ret = (PAttrDecl) malloc( sizeof(TAttrDecl) );
  AttrClassList *aclTmp;
  PropertyList *plTmp;
  int i = 0;

  /* create the ClassList: */
  i = 0;
  for (aclTmp = adl->classList; aclTmp != NULL; aclTmp = aclTmp->next ) i++;
  ret->aszCategory = (char **) malloc( (i+1)*sizeof(char *) );
  i = 0;
  for (aclTmp = adl->classList; aclTmp != NULL; aclTmp = aclTmp->next ) {
    ret->aszCategory[i] = (aclTmp->Class) ? strdup(aclTmp->Class) : NULL;
    i++;
  };
  ret->aszCategory[i] = NULL;

  /* count the properties in <i>: */
  i = 0;
  for (plTmp = adl->attrList; plTmp != NULL; plTmp = plTmp->next ) i++;
  /* allocate the arrays for label and value: */
  ret->aszLabel = (char **) malloc( (i+1)*sizeof(char *) );
  ret->aszValue = (char **) malloc( (i+1)*sizeof(char *) );
  i = 0;
  /* initialize the arrays of label and value: */
  for (plTmp = adl->attrList; plTmp != NULL; plTmp = plTmp->next ) {
    ret->aszLabel[i] = (plTmp->label) ? strdup(plTmp->label) : NULL;
    ret->aszValue[i++] = readRecId( plTmp->value );
  }
  ret->aszLabel[i] = ret->aszValue[i] = NULL;
  /* return the pointer on the structure of aszCategory, aszLabel and aszValue: */
  return ret;
}

PVTelos te_createFrame(te_SMLfragmentList *fl) {
  PVTelos ret;
  AttrDeclList *alTmp = fl->with;
  int i;

  ret = (PVTelos) malloc( sizeof( VTelos ) );
  ret->szId = readRecId(fl->id);
  ret->aszOmega = te_createClassList( fl->inOmega );
  ret->aszIn = te_createClassList( fl->in );
  ret->aszIsA = te_createClassList( fl->isa );
  i =  0;
  for ( alTmp = fl->with; alTmp != NULL; alTmp = alTmp->next ) i++;
  ret->listAttrDecl = (PAttrDecl *) malloc( (i+1)*sizeof( PAttrDecl ) );
  i = 0;
  for ( alTmp = fl->with; alTmp != NULL; alTmp = alTmp->next ) {
    ret->listAttrDecl[i++] = te_createAttrDecl( alTmp );
  };
  ret->listAttrDecl[i] = NULL;

  return ret;
}


/**************************************************************************
 * vt_createByFragment:
 * ------------------------------------------------------------------------
 * <fl>: contains the fragment list in the way produced by the parser
 * RETURN: NULL if the argument is NULL too
 *         else the pointer to the vector tree structure
 * SUBJECT: Maps the given fragmentlist <fl> into a vector of frames.
 **************************************************************************/
LIBTELOS_API AVTelos STDCALL vt_createByFragment(te_SMLfragmentList *fl) {
  AVTelos ret = NULL;
  te_SMLfragmentList *tmpFl = NULL;
  int i = 0;

  if (fl) {
    tmpFl = fl;
    for (i = 0; tmpFl != NULL; tmpFl = tmpFl->next ) i++;
    ret = (AVTelos) malloc( (i+1) * sizeof(PVTelos) );

    i = 0;
    tmpFl = fl;
    for (i = 0; tmpFl != NULL; tmpFl = tmpFl->next ) {
      ret[i] = te_createFrame( tmpFl );
      i++;
    };
    ret[i] = NULL;
  }
  return ret;
}

/**************************************************************************
 * vt_create:
 * ------------------------------------------------------------------------
 * <szTelos>: should be a string of correct Telos
 * RETURN: NULL if the szTelos fails the parsing process
 *         else it contains the AVTelos with all its componends
 * SUBJECT: Maps the given Telos text <szTelos> into a vector of frames.
 **************************************************************************/
LIBTELOS_API AVTelos STDCALL vt_create(char *szTelos) {
  /* scan the Telos frames of the string: */
  FrameParseOutput* fpo=te_frame_parser( szTelos );
  te_SMLfragmentList *fl=fpo->smlfrag;
/* create a VectorTree structure: */
  AVTelos ret = vt_createByFragment( fl );

  DestroySMLfrag( fl );
  return ret;
}

/* destroyASZ: disposes the <asz> structure
 */
LIBTELOS_API void STDCALL destroyASZ(char **asz) {
  int i;

  for ( i = 0; asz[i] != NULL; i++) free( asz[i] );
  free( asz );
}

/* te_destroyFrame: disposes a single Frame
 * USED: by the function vt_destroy to dispose all frames
 */
void te_destroyFrame(PVTelos pvtFrame) {
  int i;

  free( pvtFrame->szId );
  destroyASZ( pvtFrame->aszOmega );
  destroyASZ( pvtFrame->aszIn );
  destroyASZ( pvtFrame->aszIsA );
  for ( i = 0; pvtFrame->listAttrDecl[i]; i++) {
    destroyASZ( pvtFrame->listAttrDecl[i]->aszCategory );
    destroyASZ( pvtFrame->listAttrDecl[i]->aszLabel );
    destroyASZ( pvtFrame->listAttrDecl[i]->aszValue );
    free( pvtFrame->listAttrDecl[i] );
  };
  free( pvtFrame );
}

/**************************************************************************
 * vt_destroy:
 * ------------------------------------------------------------------------
 * <avtFrames>: points to the vector tree structure
 * RETURN: none
 * SUBJECT: disposes the given vector tree
 **************************************************************************/
LIBTELOS_API void STDCALL vt_destroy(AVTelos avtFrames) {
  int i;

  if (avtFrames) {
    for ( i = 0; avtFrames[i] != NULL; i++) te_destroyFrame(avtFrames[i]);
    free(avtFrames);
  }
}

/* isSubASZ:
 * Input: aszSub    will be checked as subset
 *        aszSuper  will be tested as superset
 * Output: 1 iff (aszSub < aszSuper) else 0
 * Subject: Tests if for each string in aszSub exists an equivalent string
 *          in aszSuper.
 *          If you understant the string as elements and arguments as sets
 *          on these elements then this function describes a normal subset
 *          relation.
 */
int isSubASZ(char **aszSub, char **aszSuper) {
  int found = 1; /* default is true, because for the first loop */
  int iCurSub, iCurSuper;   /* indices */

  if (aszSub) {
    for (iCurSub = 0; (aszSub[iCurSub] != NULL) && (found); iCurSub++) {
      found = 0; /* must be found for every el. of aszSub ! */
      if (aszSuper) {
	for (iCurSuper = 0; (aszSuper[iCurSuper] != NULL) && (!found); iCurSuper++) {
	  found = (strcmp(aszSub[iCurSub],aszSuper[iCurSuper]) == 0);
	}
      }
    } /* found iff for each el. of aszSub exists an el. of aszSuper: */
  }
  return (found);
}

/**************************************************************************
 * rep_create:
 * ------------------------------------------------------------------------
 * <pvtFrame>: points to a single Frame, which must exists
 * <aszCategories>: should be a NULL terminated vector of the
 *                  categories to filter as a conjunction.
 * RETURN: In each case a report will be created, even  the result is empty
 * SUBJECT: Filters all attributes to those properties,
 *          which belongs to all given categories at the same time
 * NOTE: If there is a category wrong typed, it has the effect
 *       that result will always be an empty vector with NULL at index 0
 **************************************************************************/
LIBTELOS_API PReport STDCALL rep_create(PVTelos pvtFrame, char **aszCategories) {
  int iCountProp = 0, iProp, iAttr;
  PAttrDecl padCur;
  PReport ret = (PReport) malloc( sizeof(TReport) );

  /* count the properties that will be filtered: */
  for (iAttr = 0; pvtFrame->listAttrDecl[iAttr]; iAttr++) {
    padCur = pvtFrame->listAttrDecl[iAttr];
    if (isSubASZ( aszCategories, padCur->aszCategory )) {
      for (iProp = 0; padCur->aszLabel[iProp] != NULL; iProp++) iCountProp++;
    }
  }
  /* allocate the space for the array of labels and values: */
  ret->aszLabel = (char **) malloc( (iCountProp+1)*sizeof(char *) );
  ret->aszValue = (char **) malloc( (iCountProp+1)*sizeof(char *) );
  /* copy the filtered labels and values: */
  iCountProp = 0;
  for (iAttr = 0; pvtFrame->listAttrDecl[iAttr]; iAttr++) {
    padCur = pvtFrame->listAttrDecl[iAttr];
    if (isSubASZ( aszCategories, padCur->aszCategory )) {
      for (iProp = 0; padCur->aszLabel[iProp] != NULL; iProp++) {
	ret->aszLabel[iCountProp] = strdup(padCur->aszLabel[iProp]);
	ret->aszValue[iCountProp] = strdup(padCur->aszValue[iProp]);
	iCountProp++;
      }
    }
  }
  ret->aszLabel[iCountProp] = ret->aszValue[iCountProp] = NULL;
  return (ret);
}

/**************************************************************************
 * rep_destroy:
 * ------------------------------------------------------------------------
 * <prepReport>: points to the report which should be disposed
 * RETURN: None
 * SUBJECT: Disposes the given report structure
 * NOTE: Should be called to free the result of rep_create
 **************************************************************************/
LIBTELOS_API void STDCALL rep_destroy(PReport prepReport) {
  if (prepReport) {
    destroyASZ( prepReport->aszLabel );
    destroyASZ( prepReport->aszValue );
    free( prepReport );
  };
}

/**************************************************************************
 * getValueOfLabel:
 * ------------------------------------------------------------------------
 * <pvtFrame>: points to a single frame, which should be analyzed
 * <szLabel>: contains the keyword, which should be searched in the labels
 * RETURN: the string containing the value according to the given label
 *         or NULL if no appropriate value was found
 * SUBJECT: A simple service routine, which support the access on frames
 * NOTE: These routine can serve as a simple example how to use the
 *       vector tree structure
 **************************************************************************/
LIBTELOS_API char* STDCALL getValueOfLabel(PVTelos pvtFrame, char *szLabel) {
  char *ret = NULL;
  int i, j;

  /* check the arguments: */
  if ((pvtFrame != NULL) && (szLabel != NULL)) {
    /* for all attribut deklaration parts: */
    for ( i = 0; (pvtFrame->listAttrDecl[i] != NULL) && (ret == NULL); i++) {
      /* a simple help variable, which is usefull for the most cases: */
      PAttrDecl pad = pvtFrame->listAttrDecl[i];

      /* for all labels of the declaration part: */
      for ( j = 0; (pad->aszLabel[j] != NULL) && (ret == NULL); j++) {
	if (strcmp( szLabel, pad->aszLabel[j] ) == 0) {
	  ret = pad->aszValue[j];
	  /* if the label was equal, the according value should be returned !*/
	}
      }
    }
  }
  return ret;
}

/**************************************************************************
 * getCategories:
 * ------------------------------------------------------------------------
 * <pvtFrame>: points to a single frame, which should be analyzed
 * RETURN: ASZ with the categories
 * SUBJECT: Lists the categories as flat list,
 *          each elemant appears only one time
 * NOTE: In these implementation the result has no special order,
 *       It is in this case the order of first appearence,
 *       but in future is could be sorted.
 **************************************************************************/
LIBTELOS_API char** STDCALL getCategories(PVTelos pvtFrame) {
  char **aszRes = NULL, **aszTemp, **aszWork;
  int i, j, iCount = 0, iResCount = 0;

  /* check the arguments: */
  if (pvtFrame != NULL) {
    /* count the categories to get the maximal size: */
    /* for all attribut deklaration parts: */
    for ( i = 0; (pvtFrame->listAttrDecl[i] != NULL); i++) {
      /* a simple help variable, which is usefull for the most cases: */
      PAttrDecl pad = pvtFrame->listAttrDecl[i];
      /* for all categories of the declaration part: */
      for ( j = 0; (pad->aszCategory[j] != NULL); j++) iCount++;
    }
    aszTemp =(char **) malloc( (iCount+1) * sizeof(char *) );

    /* copy the new categories: */
    aszTemp[0] = NULL;
    /* for all attribut deklaration parts: */
    for ( i = 0; (pvtFrame->listAttrDecl[i] != NULL); i++) {
      /* a simple help variable, which is usefull for the most cases: */
      PAttrDecl pad = pvtFrame->listAttrDecl[i];
      /* for all labels of the declaration part: */
      for ( j = 0; (pad->aszCategory[j] != NULL); j++) {
	/* search the current category in the current result: */
	aszWork = aszTemp;
	while ( (*aszWork != NULL)
		&& (strcmp( pad->aszCategory[j], *aszWork) != 0) ) aszWork++;
	/* if it is new the append it to the result list: */
	if (*aszWork == NULL) {
	  aszWork[0] = strdup( pad->aszCategory[j] );
	  ++aszWork;
	  aszWork[0] = NULL;
	  iResCount++;
	}
      }
    }

    /* reduce the result vector: */
    aszRes =(char **) malloc( (iResCount+1) * sizeof(char *) );
    for ( i = 0; i < iResCount+1; i++ ) aszRes[i] = aszTemp[i];
    free( aszTemp );
  }
  return aszRes;
}
