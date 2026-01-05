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
#include "te_access.h"
#include "te_callparser.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <malloc.h>

/* Demo 2 *************************************************************************/
void printHeader1(PFrameCursor pfc) {
  char *tmp = NULL;

  te_resetOmega( pfc );
  printf(" Omega:");
  do {
    tmp = te_retOmega( pfc );
    if (tmp) {
      printf( " %s", tmp );
    }
  } while ( te_nextOmega( pfc ) );
  printf(".\n");

  te_resetIsA( pfc );
  printf(" IsA:");
  do {
    tmp = te_retIsA( pfc );
    if (tmp) {
      printf( " %s", tmp );
    }
  } while ( te_nextIsA( pfc ) );
  printf(".\n");

  te_resetIn( pfc );
  printf(" In:");
  do {
    tmp = te_retIn( pfc );
    if (tmp) {
      printf( " %s", tmp );
    }
  } while ( te_nextIn( pfc ) );
  printf(".\n");

}

void printCats1(PFrameCursor pfc) {
  char *tmp = NULL;

  te_resetAttrDecl( pfc );
  do {
    int ok = 1;

    te_resetCategory( pfc );
    printf("{");
    while (ok) {
      tmp = te_retCategory( pfc );
      if (tmp) {
	printf("%s",tmp);
	free( tmp );

      }
      ok = te_nextCategory( pfc );
      if (ok) printf(", ");
    };
    printf("}:");

    te_resetProperty( pfc );
    do {
      char *lab = te_retLabel( pfc );
      char *val = te_retValue( pfc );
      if ((lab) && (val)) {
	printf( "[%s: %s]", lab, val);
      }
      if (lab) free(lab);
      if (val) free(val);
    } while (te_nextProperty( pfc ));
    printf("\n");

  } while (te_nextAttrDecl( pfc ));
}

/* call Demo 2 **************************/
void printOIDs1(PFrameCursor pfc) {
  char *tmp = NULL;

  do {
    tmp = te_retOID( pfc );
    printf("frame: %s\n", tmp );
    free( tmp );
    printHeader1( pfc );
    printCats1( pfc );
    printf("\n");

  } while (te_nextFrame( pfc ));

  tmp = te_retOID( pfc );
  if (tmp) {
    printf("frame: %s\n", tmp );
    free( tmp );
  } else printf("nil\n");

  printf("end\n");
}

/* Demo 3 *****************************************************************************/
void printCurProp1(PFrameCursor pfc) {
    char *lab = te_retLabel( pfc );
    char *val = te_retValue( pfc );

    if ((lab) && (val)) printf( "[%s: %s] ", lab, val );
    if (lab) free( lab );
    if (val) free( val );
}

void testFilter1(PFrameCursor pfc, char *filter, char *remark ) {

  te_resetFrame( pfc );
  printf( "Filter:%s (%s)\n  { ", filter ? filter : "", remark );
  while (te_filterPropertyByCategory( pfc, filter )) printCurProp1( pfc );
  printf("}.\n");
}

void testFilters1(PFrameCursor pfc, char *filters[], char *remark ) {
  int i = 0;

  te_resetFrame( pfc );
  printf( "Filters:" );
  if (filters) {
    for (i = 0;filters[i] != NULL; i++) printf(" %s",filters[i]);
  }
  printf(" (%s):\n   { ", remark );
  while (te_filterPropertyByCategories( pfc, filters )) printCurProp1( pfc );
  printf("}.\n");
}

/* call Demo 3 ****************************/
void printFilter1(PFrameCursor pfc) {
  char *filters4[] = { "attr2", "attr3", NULL };
  char *filters5[] = { "attr1", "attr2", "attr3", NULL };

  printf("Demonstrate some filter:\n");
  testFilter1( pfc, "attr1", "tests a single attribute" );
  testFilter1( pfc, "attr2", "tests a single attribute, wich is in many declarations" );
  testFilter1( pfc, "none", "tests a not existing" );
  testFilter1( pfc, NULL, "tests without attribute" );
  testFilters1( pfc, filters4, "tests many attributes" );
  testFilters1( pfc, filters5, "tests too many attributes" );
  testFilters1( pfc, NULL, "tests without attributes" );
  printf("on the first frame with data:");
  printCats1( pfc );
}

/* Demo concept vector tree ************************************************************/

void printASZ(char **asz) {
  char **tmp = asz;
  int i = 0;

  for (i = 0; tmp[i]; i++) {
    printf("%s ", tmp[i]);
  };
}

/* Demo 4 ****************************************************************************/
void printLabeledASZ(char *label, char **asz) {
  printf( "%s{", label );
  printASZ( asz );
  printf( "}\n" );
}

/* call Demo 4 *************************/
void printFRAME2(PVTelos aFrame) {
  int i;

  printf("Frame: %s.\n", aFrame->szId);
  printLabeledASZ(" Omega: ", aFrame->aszOmega);
  printLabeledASZ(" In: ", aFrame->aszIn);
  printLabeledASZ(" IsA: ", aFrame->aszIsA);
  for (i = 0; aFrame->listAttrDecl[i]; i++) {
    printLabeledASZ("  Categories: ", aFrame->listAttrDecl[i]->aszCategory );
    printLabeledASZ("   Labels: ", aFrame->listAttrDecl[i]->aszLabel);
    printLabeledASZ("   Values: ", aFrame->listAttrDecl[i]->aszValue);
  }
  printf("\n");
}

/* Demo 5 *************************************************************************/
void printDoubleASZ( char **aszLab, char **aszVal ) {
  int i;

  if ((aszLab) && (aszVal)) {
    for (i = 0; (aszLab[i]) && (aszVal[i]); i++) {
      printf(" [%s: %s]", aszLab[i], aszVal[i] );
    }
  }
}

/* call Demo 5 *************************************************************/
void testReport2(PVTelos aFrame, char *filters[], char *remark ) {
  PReport pRep;

  printf( "Filter:");
  if (filters) printASZ( filters );
  printf(" (%s)\n  { ", remark );
  pRep = rep_create( aFrame, filters );
  printDoubleASZ( pRep->aszLabel, pRep->aszValue );
  printf("}.\n");
  rep_destroy( pRep );
}

/* call Demo 5 **********************/
void printFilter2(PVTelos pfc) {
  char *filters1[] = { "attr1", NULL };
  char *filters2[] = { "attr2", NULL };
  char *filters3[] = { "none", NULL };
  char *filters4[] = { "attr2", "attr3", NULL };
  char *filters5[] = { "attr1", "attr2", "attr3", NULL };

  printf("Demonstrate some filter:\n");
  testReport2( pfc, filters1, "tests a single attribute" );
  testReport2( pfc, filters2, "tests a single attribute, wich is in many declarations" );
  testReport2( pfc, filters3, "tests a not existing" );
  testReport2( pfc, filters4, "tests many attributes" );
  testReport2( pfc, filters5, "tests too many attributes" );
  testReport2( pfc, NULL, "tests without attribute" );
}

/* Demo 6 ****************************************************************************/
void testGetValueOfLabeL(PVTelos aFrame) {

  printf("Of first frame get the value of the label:\n");
  printf("Label:%s, value:%s.\n", "lab1", getValueOfLabel( aFrame, "lab1" ) );
}

void testGetCategories(PVTelos aFrame) {
  char **aszTemp = NULL;

  printf("Of first frame get the categories: {");
  aszTemp = getCategories( aFrame );
  printASZ( aszTemp );
  destroyASZ( aszTemp );
  printf("}\n");
}

int main(int argc, char** argv) {
  char *telos = " \n\
 Individual Administration in Department with \n\
   head \n\
     head_of_Administration : Eleonore \n\
   attr1, attr2 \n\
     lab1 : val1; \n\
     lab2 : val2 \n\
   attr2, attr3 \n\
     labA : valA; \n\
     labB : valB \n\
 end \n\
 \n\
Individual QueryClass in Class isA Class with \n\
  attribute \n\
     retrieved_attribute : Proposition; \n\
     computed_attribute : Proposition; \n\
     constraint : MSFOLquery \n\
end \n\
 \n\
Individual Research in Department with \n\
  head \n\
    head_of_Research : Albert \n\
end \n\
\n\
Individual George in Employee with \n\
        name \n\
                GeorgesName: Smith\n\
        salary\n\
                GeogesBaseSalary : 30000; \n\
                GeorgesBonusSalary : 3000 \n\
end \n\
\n\
Individual GetClassDemo in Employee,Manager isA A,B,C with \n\
        name \n\
                ClassDemo: Test \n\
end \n\
";
  FrameParseOutput* fpo;
  te_SMLfragmentList *flXmpl; /* struct-tree filled by the parser */
  PFrameCursor pfcXmpl;
  AVTelos avtXmpl;
  int key;
  int i;

  /* scan the Telos frames of the string: */
  fpo = te_frame_parser(telos);
  flXmpl=fpo->smlfrag;
  /* create a FrameCursor structure: */
  pfcXmpl = te_createCursor(flXmpl);
  /* create a VectorTree structure: */
  avtXmpl = vt_create( telos );
  /* Menu: */

  if(argc==1) { /* Interactive mode */
	  do {
	    printf("***********************************************************\n");
	    printf("0: exit\n");
	    printf("1: lists the Telos source.\n");
	    printf("2: lists the frames with the cursor concept\n");
	    printf("3: filters the first frame with the cursor concept\n");
	    printf("4: lists the frames with the vector tree concept\n");
	    printf("5: filters the first frame with the vector tree concept\n");
	    printf("6: test additional funtions of vector tree concept\n" );
	    printf("enter a digit and press return\n");
	    scanf("%1d",&key);
	    printf("choice:%d",key);
	    printf("***********************************************************\n");
	    if (key == 1) printf( "Telos source:\n%s\n", telos );
	    if (key == 2) printOIDs1( pfcXmpl );
	    if (key == 3) printFilter1( pfcXmpl );
	    if (key == 4) for (i = 0; avtXmpl[i] != NULL; i++) printFRAME2(avtXmpl[i]);
	    if (key == 5) printFilter2( avtXmpl[0] );
	    if (key == 6) {
	      testGetValueOfLabeL( avtXmpl[0] );
	      testGetCategories( avtXmpl[0] );
	    }
	  } while (key != 0);
	}
	else { /* Non-Interactive mode */
		printf( "Telos source:\n%s\n", telos );
	 	printOIDs1( pfcXmpl );
	 	printFilter1( pfcXmpl );
	 	for (i = 0; avtXmpl[i] != NULL; i++) printFRAME2(avtXmpl[i]);
	 	printFilter2( avtXmpl[0] );
	 	testGetValueOfLabeL( avtXmpl[0] );
	 	testGetCategories( avtXmpl[0] );
	}
  /* destroy the VectorTree: */
  vt_destroy( avtXmpl );

  return 0;
}
