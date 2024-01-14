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
/*
 * This file defines a vector tree structure to access the
 * contents of Telos Frames. Use the functions vt_create(char*)
 * or vt_createByFragment(te_SMLfragmentList*) to create a vector
 * tree.
 */

#ifndef TE_ACCESS
#define TE_ACCESS

#include "telosdll.h"
#include "fragment.h"

/* ------------------------------------------------------------- */
/*                          STRUCTURES                           */
/* ------------------------------------------------------------- */

/** This structure represents an attribute declaration. An attribute declaration
 * is a list of attribute categories with a list of properties (label and values)
 * that belong to these attribute categories.
 */
struct te_AttrDecl {
  /** contains the list of category labels */
  char **aszCategory;
  /** contains the list of property labels corresponding to */
  char **aszLabel;
  /** the list of property values */
  char **aszValue;
};

/** The type for te_AttrDecl */
typedef struct te_AttrDecl TAttrDecl;

/** The pointer for TAttrDecl */
typedef TAttrDecl *PAttrDecl;

struct te_VectorizedTelosframe {
	/** determines the object identifier of the object */
  char *szId;
    /** determines the omega class */
  char **aszOmega;
  /** contains the classes of which this object is an instance */
  char **aszIn;
  /** a list of classes of which this object is a specialisation */
  char **aszIsA;
  /** a list of attribute declarations */
  PAttrDecl *listAttrDecl;
};

/** The type for te_VectorizedTelosframe */
typedef struct te_VectorizedTelosframe VTelos;

/** A pointer to VTelos */
typedef VTelos *PVTelos;

/** An array of VTelos pointers */
typedef PVTelos *AVTelos;

/** A te_TelosReport is a projection on certain attributes of a frame */
struct te_TelosReport {
	/** List of labels in the report */
  char **aszLabel;
	/** List of values in the report */
  char **aszValue;
};

/** The type for te_TelosReport */
typedef struct te_TelosReport TReport;

/** A pointer to TReport */
typedef TReport *PReport;


/* ------------------------------------------------------------- */
/*                          FUNCTIONS                            */
/* ------------------------------------------------------------- */

/**
 * Maps the given fragmentlist fl into a vector of frames.
 * @param fl contains the fragment list in the way produced by the parser
 * @return NULL if the argument is NULL too, else the pointer to the vector tree structure
 */
LIBTELOS_API AVTelos STDCALL vt_createByFragment(te_SMLfragmentList *fl);

/**
 * Maps the given Telos text szTelos into a vector of frames.
 * @param szTelos should be a string of correct Telos
 * @return NULL if the szTelos fails the parsing process else it contains the AVTelos with all its componends
 */
LIBTELOS_API AVTelos STDCALL vt_create(char *szTelos);

/**
 * Disposes the given vector tree.
 * @param avtFrames points to the vector tree structure
 */
LIBTELOS_API void STDCALL vt_destroy(AVTelos avtFrames);

/**
 * Filters all attributes to those properties which belong to all given categories at the same time.
 * Note: If there is a category wrong typed, it has the effect that result will always be an empty vector with NULL at index 0.
 * @param pvtFrame points to a single Frame, which must exists
 * @pararm aszCategories should be a NULL terminated vector of the categories to filter as a conjunction.
 * @return In each case a report will be created, even if the result is empty.
 */
LIBTELOS_API PReport STDCALL rep_create(PVTelos pvtFrame, char **aszCategories);

/**
 * Disposes the given report structure. Should be called to free the result of rep_create.
 * @param prepReport points to the report which should be disposed
*/
LIBTELOS_API void STDCALL rep_destroy(PReport prepReport);

/**
 * A simple service routine, which support the access on frames.
 * @param pvtFrame points to a single frame, which should be analyzed
 * @param szLabel contains the keyword, which should be searched in the labels
 * @return the string containing the value according to the given label
 *     or NULL if no appropriate value was found
 */
LIBTELOS_API char* STDCALL getValueOfLabel(PVTelos pvtFrame, char *szLabel);

/**
 * Lists the categories as flat list, each elemant appears only once.
 * The categories will be ordered by their appearance.
 * @param pvtFrame points to a single frame, which should be analyzed
 * @return array of strings with the categories
 */
LIBTELOS_API char** STDCALL getCategories(PVTelos pvtFrame);

/**
 * Disposes an asz (array of strings) structure.
 * @param asz the array of strings to be disposed
 */

LIBTELOS_API void STDCALL destroyASZ(char **asz);

#endif
