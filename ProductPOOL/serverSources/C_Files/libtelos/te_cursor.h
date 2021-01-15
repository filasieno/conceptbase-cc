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
/*
 * Structures and methods which define a cursor structure for
 * Telos Frames.
 */

#include "telosdll.h"
#include "fragment.h"


/* ------------------------------------------------------------- */
/*                          STRUCTURES                           */
/* ------------------------------------------------------------- */

/**
 * A cursor for a Telos frame
 */
struct te_framecursor {

  /** Parsed telos frames in a fragment list */
  te_SMLfragmentList *flAll;


  /* Cursors */
  /** fragment list cursor */
  te_SMLfragmentList *flCur;

  /** cursor for inOmega */
  te_ClassList *clCurOmega;

  /** cursor for in */
  te_ClassList *clCurIn;

  /** cursor for isA */
  te_ClassList *clCurIsA;

  /** cursor for attribute declarations  */
  AttrDeclList *alCur;

  /** cursor for attribute categories (within one attribute declaration) */
  AttrClassList *clCurCategory;

  /** cursor for property list (within one attribute declaration) */
  PropertyList *plCur;

  /** internal filter: tests if alCur was checked */
  AttrDeclList *alChecked;

};

/** Type for te_framecursor */
typedef struct te_framecursor TFrameCursor;

/** Type for a pointer to TFrameCursor */
typedef TFrameCursor *PFrameCursor;


/* ------------------------------------------------------------- */
/*                          FUNCTIONS                            */
/* ------------------------------------------------------------- */

/**
 * Creates and initializes a cursor structure for the given smlfragmentlist.
 * and returns a pointer to it.
 */
LIBTELOS_API PFrameCursor STDCALL te_createCursor( te_SMLfragmentList *fl);

/**
 * Deallocates a cursor structure.
 */
LIBTELOS_API void  STDCALL te_destroyCursor(PFrameCursor pfc);

/**
 * Sets the frame cursor to the first frame and resets all sub cursors.
 */
LIBTELOS_API void  STDCALL te_resetFrame(PFrameCursor pfc);

/**
 * Sets the frame cursor to the next frame in the list and resets the
 * Omega, IsA, In, AttrDecl, Category and Property cursors.
 * @return true (non-zero) if there is a next element
 */
LIBTELOS_API int  STDCALL te_nextFrame(PFrameCursor pfc);

/**
 * Returns the OID of a frame as plain string, even if it is
 * a select expression. Memory for this string has to be deallocated
 * by the caller.
 */
LIBTELOS_API char* STDCALL te_retOID(PFrameCursor pfc);

/**
 * Resets the Omega cursor.
 */
LIBTELOS_API void  STDCALL te_resetOmega(PFrameCursor pfc);

/**
 * Sets the omega cursor to the next element.
 * @return true (non-zero) if there is a next element
 */
LIBTELOS_API int  STDCALL te_nextOmega(PFrameCursor pfc);

/**
 * Returns the omega object as string
 * @see te_retOID
 */
LIBTELOS_API char* STDCALL te_retOmega(PFrameCursor pfc);

/**
 * Resets the Isa cursor.
 */
LIBTELOS_API void  STDCALL te_resetIsA(PFrameCursor pfc);

/**
 * Sets the IsA cursor to the next element.
 * @return true (non-zero) if there is a next element
 */
LIBTELOS_API int  STDCALL te_nextIsA(PFrameCursor pfc);

/**
 * Returns the IsA object as string
 * @see te_retOID
 */
LIBTELOS_API char* STDCALL te_retIsA(PFrameCursor pfc);

/**
 * Resets the In cursor.
 */
LIBTELOS_API void  STDCALL te_resetIn(PFrameCursor pfc);

/**
 * Sets the In cursor to the next element.
 * @return true (non-zero) if there is a next element
 */
LIBTELOS_API int  STDCALL te_nextIn(PFrameCursor pfc);

/**
 * Returns the In object as string
 * @see te_retOID
 */
LIBTELOS_API char* STDCALL te_retIn(PFrameCursor pfc);

/**
 * Sets the attr decl block cursor to the first attr decl block  in the
 * current frame and resets the sub-cursors Category and Property.
 */
LIBTELOS_API void  STDCALL te_resetAttrDecl(PFrameCursor pfc);

/**
 * Sets the Property cursor to the next Property class in the attr decl
 * block frame and resets the Category and Property cursors.
 * @return true (non-zero) if there is a next element
 */
LIBTELOS_API int  STDCALL te_nextAttrDecl(PFrameCursor pfc);

/**
 * Resets the category cursor.
 */
LIBTELOS_API void  STDCALL te_resetCategory(PFrameCursor pfc);

/**
 * Sets the category cursor to the next element.
 * @return true (non-zero) if there is a next element
 */
LIBTELOS_API int  STDCALL te_nextCategory(PFrameCursor pfc);

/**
 * Returns the category as string
 * @see te_retOID
 */
LIBTELOS_API char* STDCALL te_retCategory(PFrameCursor pfc);

/**
 * Resets the property cursor.
 */
LIBTELOS_API void  STDCALL te_resetProperty(PFrameCursor pfc);

/**
 * Sets the category cursor to the next element.
 * @return true (non-zero) if there is a next element
 */
LIBTELOS_API int  STDCALL te_nextProperty(PFrameCursor pfc);

/**
 * Lists all properties that are of the type "category".
 * The usage of this function is similar to the function
 *  te_filterPropertyByCategories. The only diffrence is the simplicity of
 *  the second parameter for the case that you only need to filter with
 *  one category.
 */
LIBTELOS_API int  STDCALL te_filterPropertyByCategory(PFrameCursor pfc, char* category);

/**
 * Lists all properties that matches all types of categories
 * If the categories are empty then any category matches.
 * In difference to the nextXXX functions, these function should be
 * called before the first access via te_retLabel or te_retValue,
 * because it must search the first valid AttrDecl.
 * This means at the beginning you should call:
 *       "te_resetAttrDecl( ... );"          AND
 *       "te_filterPropertyByCategories( ... );"
 */
LIBTELOS_API int  STDCALL te_filterPropertyByCategories(PFrameCursor pfc, char* categories[]);

/**
 * Lists the value of the property with label of the current frame.
 * This results only one value which is a new created string.
 * Note that the caller has to dispose the return value !
 */
LIBTELOS_API char* STDCALL te_filterPropertyByLabel(PFrameCursor pfc, char* );

/**
 * Returns the current label of the current property in the current
 * decl block or NULL.
 */
LIBTELOS_API char* STDCALL te_retLabel(PFrameCursor pfc);

/**
 * Returns the current value of the current property in the current
 *  decl block or NULL.
 */
LIBTELOS_API char* STDCALL te_retValue(PFrameCursor pfc);

