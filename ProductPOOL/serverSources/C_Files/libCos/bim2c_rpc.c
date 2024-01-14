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
#include <rpc/rpc.h>
#include "BPextern.h"
#define OBJSTORE "OBJSTORE"

/*extern int *BIM_Prolog_get_repeat_units(int);*/

extern CLIENT *cl;

#include "rpc_idef.h"
#include "rpc_init.h"

/* char trans[1024]; */


void c_algebra_test( term1, term2 )
    BP_Term term1, term2;
{}

int c_init( in )
char *in;
{
   in_name2id toSV;
   int *fromSV;

   rpc_con_objsto();

#if DLEVEL >= 5
   printf("name2id.\n"); 
#endif

   toSV.name = in;

   fromSV = r_init_1( &toSV, cl );
   if( !fromSV ) {
      clnt_perror( cl, "c_init" );
      exit(2);
   }


   return( *fromSV );}

void c_test()
{
   r_test_1( 0, cl );
}

void c_done()
{
   r_done_1( 0, cl );
}


int c_find( i, tuple )
   int i;
   char ***tuple;
{
   in_find toSV;
   static out_find *fromSV;
   static char *trans[4];

#if DLEVEL >= 5
   printf("c_find\n"); 
#endif

   toSV.query = i;

   fromSV = r_find_1( &toSV, cl );
   if( !fromSV ) {
        clnt_perror( cl, "c_find" ); 
    exit(2);
   }


   trans[0] = fromSV->p4.id;
   trans[1] = fromSV->p4.src;
   trans[2] = fromSV->p4.lab;
   trans[3] = fromSV->p4.dst;
   *tuple=trans;
   return( fromSV->success );
}


int c_freequery( q )
   int q;
{
   int toSV;

#if DLEVEL >= 5
   printf("c_freequery.\n"); 
#endif

   toSV = *((int*) BIM_Prolog_get_repeat_units(q));
   
   r_freequery_1( &toSV, cl );

   return( 1 );
}

int c_getquery( tuple, address, dataadr )
   char *tuple[4];
   void **address, **dataadr;
{
   static in_getquery toSV;
   static out_getquery *fromSV;

#if DLEVEL >= 5
   printf("c_GetQuery.\n");
#endif

   toSV.p4.id=tuple[0];
   toSV.p4.src=tuple[1];
   toSV.p4.lab=tuple[2];
   toSV.p4.dst=tuple[3];

   fromSV = r_getquery_1( &toSV, cl );
   if( !fromSV ) {
      clnt_perror( cl, "c_getquery" );
      exit(2);
   }

   *address = &c_freequery;
   *dataadr = &(fromSV->nr);
 

   return( fromSV->nr );
}

int c_getid( s )
   char **s;
{
   static out_getid *fromSV;

#if DLEVEL >= 5
   printf("c_getid.\n"); 
#endif
   fromSV = r_getid_1( 0, cl );
   if( !fromSV ) {
      clnt_perror( cl, "c_getid" );
      exit(2);
   }


   *s = fromSV->id;

   return( 1 );
}


/*
*  The In_s Literal:
*/


int c_In_s_find( i, tuple )
   int i;
   char ***tuple;
{
   in_literal_find toSV;
   static out_literal_find *fromSV;
   static char *trans[2];

#if DLEVEL >= 5
   printf("c_In_s_find\n"); 
#endif

   toSV.query = i;
   toSV.WhatLit = 0;

   fromSV = r_literal_find_1( &toSV, cl );
   if( !fromSV ) {
        clnt_perror( cl, "c_In_s_find" ); 
    exit(2);
   }


   trans[0] = fromSV->o2.id1;
   trans[1] = fromSV->o2.id2;
   *tuple=trans;

   return( fromSV->success );
}


int c_In_s_freequery( q )
   int q;
{
   in_literal_freequery toSV;

#if DLEVEL >= 5
   printf("c_In_s_freequery.\n"); 
#endif

  
   toSV.query = *((int*) BIM_Prolog_get_repeat_units(q));
   toSV.WhatLit = 0;
   
   r_literal_freequery_1( &toSV, cl );

   return( 1 );
}

int c_In_s_getquery( tuple, address, dataadr )
   char *tuple[2];
   void **address, **dataadr;
{
   static in_literal_getquery toSV;
   static out_getquery *fromSV;

#if DLEVEL >= 5
   printf("c_In_s_GetQuery.\n");
#endif

   toSV.o2.id1=tuple[0];
   toSV.o2.id2=tuple[1];
   toSV.WhatLit = 0;

   fromSV = r_literal_getquery_1( &toSV, cl );
   if( !fromSV ) {
      clnt_perror( cl, "In_s_getquery" );
      exit(2);
   }

   *address = &c_In_s_freequery;
   *dataadr = &(fromSV->nr);
 

   return( fromSV->nr );
}

int c_In_s_getid( s )
   char **s;
{
   static out_getid *fromSV;
   int toSV;   

#if DLEVEL >= 5
   printf("c_In_s_getid.\n"); 
#endif

   toSV = 0;  /* Literalnummer */

   fromSV = r_literal_getid_1( toSV, cl );
   if( !fromSV ) {
      clnt_perror( cl, "c_In_s_getid" );
      exit(2);
   }


   *s = fromSV->id;

   return( 1 );
}

/*****************************************************************************/
/*
*  The In_i Literal:
*/


int c_In_i_find( i, tuple )
   int i;
   char ***tuple;
{
   in_literal_find toSV;
   static out_literal_find *fromSV;
   static char *trans[2];

#if DLEVEL >= 5
   printf("c_In_i_find\n"); 
#endif

   toSV.query = i;
   toSV.WhatLit = 1;

   fromSV = r_literal_find_1( &toSV, cl );
   if( !fromSV ) {
        clnt_perror( cl, "c_In_i_find" ); 
    exit(2);
   }


   trans[0] = fromSV->o2.id1;
   trans[1] = fromSV->o2.id2;
   *tuple=trans;

   return( fromSV->success );
}


int c_In_i_freequery( q )
   int q;
{
   in_literal_freequery toSV;

#if DLEVEL >= 5
   printf("c_In_i_freequery.\n"); 
#endif

  
   toSV.query = *((int*) BIM_Prolog_get_repeat_units(q));
   toSV.WhatLit = 1;
   
   r_literal_freequery_1( &toSV, cl );

   return( 1 );
}

int c_In_i_getquery( tuple, address, dataadr )
   char *tuple[2];
   void **address, **dataadr;
{
   static in_literal_getquery toSV;
   static out_getquery *fromSV;

#if DLEVEL >= 5
   printf("c_In_i_GetQuery.\n");
#endif

   toSV.o2.id1=tuple[0];
   toSV.o2.id2=tuple[1];
   toSV.WhatLit = 1;

   fromSV = r_literal_getquery_1( &toSV, cl );
   if( !fromSV ) {
      clnt_perror( cl, "c_In_i_getquery" );
      exit(2);
   }

   *address = &c_In_i_freequery;
   *dataadr = &(fromSV->nr);
 

   return( fromSV->nr );
}

int c_In_i_getid( s )
   char **s;
{
   static out_getid *fromSV;
   int toSV;   

#if DLEVEL >= 5
   printf("c_In_i_getid.\n"); 
#endif

   toSV = 1;  /* Literalnummer */

   fromSV = r_literal_getid_1( toSV, cl );
   if( !fromSV ) {
      clnt_perror( cl, "c_In_i_getid" );
      exit(2);
   }


   *s = fromSV->id;

   return( 1 );
}

/*****************************************************************************/
/*
*  system_class:
*/


int c_sys_class_find( i, tuple )
   int i;
   char ***tuple;
{
   in_literal_find toSV;
   static out_literal_find *fromSV;
   static char *trans[2];

#if DLEVEL >= 5
   printf("c_sys_class_find\n"); 
#endif

   toSV.query = i;
   toSV.WhatLit = 4;

   fromSV = r_literal_find_1( &toSV, cl );
   if( !fromSV ) {
        clnt_perror( cl, "c_sys_class_find" ); 
    exit(2);
   }


   trans[0] = fromSV->o2.id1;
   trans[1] = fromSV->o2.id2;
   *tuple=trans;

   return( fromSV->success );
}


/*****************************************************************************/
/*
*  The Isa Literal:
*/

int c_sys_class_freequery( q )
   int q;
{
   in_literal_freequery toSV;

#if DLEVEL >= 5
   printf("sys_class_freequery.\n"); 
#endif

  
   toSV.query = *((int*) BIM_Prolog_get_repeat_units(q));
   toSV.WhatLit = 4;
   
   r_literal_freequery_1( &toSV, cl );

   return( 1 );
}

int c_sys_class_getquery( tuple, address, dataadr )
   char *tuple[2];
   void **address, **dataadr;
{
   static in_literal_getquery toSV;
   static out_getquery *fromSV;

#if DLEVEL >= 5
   printf("sys_class_GetQuery.\n");
#endif

   toSV.o2.id1=tuple[0];
   toSV.o2.id2=tuple[1];
   toSV.WhatLit = 4;

   fromSV = r_literal_getquery_1( &toSV, cl );
   if( !fromSV ) {
      clnt_perror( cl, "sys_class_getquery" );
      exit(2);
   }

   *address = &c_sys_class_freequery;
   *dataadr = &(fromSV->nr);
 

   return( fromSV->nr );
}

int c_sys_class_getid( s )
   char **s;
{
   static out_getid *fromSV;
   int toSV;   

#if DLEVEL >= 5
   printf("sys_class_getid.\n"); 
#endif

   toSV = 4;  /* Literalnummer */

   fromSV = r_literal_getid_1( toSV, cl );
   if( !fromSV ) {
      clnt_perror( cl, "sys_class_getid" );
      exit(2);
   }


   *s = fromSV->id;

   return( 1 );
}




int c_Isa_find( i, tuple )
   int i;
   char ***tuple;
{     
   in_literal_find toSV;
   static out_literal_find *fromSV;
   static char *trans[2];
   
#if DLEVEL >= 5
   printf("Isa_find.\n"); 
#endif
   
   toSV.query = i;
   toSV.WhatLit = 6;

   fromSV = r_literal_find_1( &toSV, cl );
   if( !fromSV ) {
       clnt_perror( cl, "c_Isa_find" );
       exit(2);
   }
   trans[0] = fromSV->o2.id1;
   trans[1] = fromSV->o2.id2;
   *tuple=trans;

   return( fromSV->success );
}

int c_Isa_freequery( q )
   int q;
{
   in_literal_freequery toSV;

#if DLEVEL >= 5
   printf("Isa_freequery.\n"); 
#endif
  
   toSV.query = *((int*) BIM_Prolog_get_repeat_units(q));
   toSV.WhatLit = 6;
   
   r_literal_freequery_1( &toSV, cl );

   return( 1 );
}

int c_Isa_getquery( tuple, address, dataadr )
   char *tuple[2];
   void **address, **dataadr;
{
   static in_literal_getquery toSV;
   static out_getquery *fromSV;

#if DLEVEL >= 5
   printf("Isa GetQuery.\n");
#endif

   toSV.o2.id1=tuple[0];
   toSV.o2.id2=tuple[1];
   toSV.WhatLit = 6;

   fromSV = r_literal_getquery_1( &toSV, cl );
   if( !fromSV ) {
      clnt_perror( cl, "Isa_getquery" );
      exit(2);
   }

   *address = &c_Isa_freequery;
   *dataadr = &(fromSV->nr);
   
   return( fromSV->nr );
}


int c_Isa_getid( s )
   char **s;
{
   static out_getid *fromSV;
   int toSV;   

#if DLEVEL >= 5
   printf("Isa getid.\n"); 
#endif

   toSV = 6;  /* Literalnummer */
   fromSV = r_literal_getid_1( toSV, cl );
   if( !fromSV ) {
      clnt_perror( cl, "Isa_getid" );
      exit(2);
   }
   
   *s = fromSV->id;
   
   return( 1 );
}



/*****************************************************************************/
/*
*  The Adot Literal:
*/

int c_Adot_find( i, tuple )
   int i;
   char ***tuple;
{
   in_literal_find toSV;
   static out_find *fromSV;
   static char *trans[4];

#if DLEVEL >= 5
   printf("Adot_find\n"); 
#endif

   toSV.query = i;
   toSV.WhatLit = 2;

   fromSV = r_literal4_find_1( &toSV, cl );
   if( !fromSV ) {
        clnt_perror( cl, "c_Adot_find" ); 
    exit(2);
   }


   trans[0] = fromSV->p4.id;
   trans[1] = fromSV->p4.src;
   trans[2] = fromSV->p4.lab;
   trans[3] = fromSV->p4.dst;
   *tuple=trans;

   return( fromSV->success );
}


int c_Adot_freequery( q )
   int q;
{
   in_literal_freequery toSV;

#if DLEVEL >= 5
   printf("Adot_freequery.\n"); 
#endif

  
   toSV.query = *((int*) BIM_Prolog_get_repeat_units(q));
   toSV.WhatLit = 2;
   
   r_literal_freequery_1( &toSV, cl );

   return( 1 );
}

int c_Adot_getquery( tuple, address, dataadr )
   char *tuple[2];
   void **address, **dataadr;
{
   static in_literal4_getquery toSV;
   static out_getquery *fromSV;

#if DLEVEL >= 5
   printf("Adot GetQuery.\n");
#endif

   toSV.p4.id=tuple[0];
   toSV.p4.src=tuple[1];
   toSV.p4.lab=tuple[2];
   toSV.p4.dst=tuple[3];
   toSV.WhatLit = 2;

   fromSV = r_literal4_getquery_1( &toSV, cl );
   if( !fromSV ) {
      clnt_perror( cl, "Adot_getquery" );
      exit(2);
   }

   *address = &c_Adot_freequery;
   *dataadr = &(fromSV->nr);
 

   return( fromSV->nr );
}

int c_Adot_getid( s )
   char **s;
{
   static out_getid *fromSV;
   int toSV;   

#if DLEVEL >= 5
   printf("getid.\n"); 
#endif

   toSV = 2;  /* Literalnummer */

   fromSV = r_literal_getid_1( toSV, cl );
   if( !fromSV ) {
      clnt_perror( cl, "Adot_getid" );
      exit(2);
   }


   *s = fromSV->id;

   return( 1 );
}


/*****************************************************************************/
/*
*  The A Literal
*/

int c_A_find( i, tuple )
   int i;
   char ***tuple;
{
   in_literal_find toSV;
   static out_find3 *fromSV;
   static char *trans[3];

#if DLEVEL >= 5
   printf("A_find\n"); 
#endif

   toSV.query = i;
   toSV.WhatLit = 5;

   fromSV = r_literal3_find_1( &toSV, cl );
   if( !fromSV ) {
        clnt_perror( cl, "c_A_find" ); 
    exit(2);
   }
   
/*   trans[0] = fromSV->p4.id;*/
   trans[0] = fromSV->p3.src;
   trans[1] = fromSV->p3.lab;
   trans[2] = fromSV->p3.dst;
   *tuple=trans;

   return( fromSV->success );
}


int c_A_freequery( q )
   int q;
{
   in_literal_freequery toSV;

#if DLEVEL >= 5
   printf("A_freequery.\n"); 
#endif
  
   toSV.query = *((int*) BIM_Prolog_get_repeat_units(q));
   toSV.WhatLit = 5;
   
   r_literal_freequery_1( &toSV, cl );

   return( 1 );
}


int c_A_getquery( tuple, address, dataadr )
   char *tuple[3];
   void **address, **dataadr;
{

   static in_literal3_getquery toSV;
   static out_getquery *fromSV;

#if DLEVEL >= 5
   printf("A GetQuery.\n");
#endif

/*   toSV.p4.id=tuple[0];*/
   toSV.p3.src=tuple[0];
   toSV.p3.lab=tuple[1];
   toSV.p3.dst=tuple[2];
   toSV.WhatLit = 5;

   fromSV = r_literal3_getquery_1( &toSV, cl );
   if( !fromSV ) {
      clnt_perror( cl, "A_getquery" );
      exit(2);
   }

   *address = &c_A_freequery;
   *dataadr = &(fromSV->nr); 

   return( fromSV->nr );
}


int c_A_getid( s )
   char **s;
{
  static out_getid *fromSV;
   int toSV;   

#if DLEVEL >= 5
   printf("A getid.\n"); 
#endif

   toSV = 5;  /* Literalnummer */

   fromSV = r_literal_getid_1( toSV, cl );
   if( !fromSV ) {
      clnt_perror( cl, "A_getid" );
      exit(2);
   }
   
   *s = fromSV->id;
   
   return( 1 );
}



/*****************************************************************************/
/*
*  The star search:
*/

int c_star_find( i, id )
   int i;
   char **id;
{
   in_literal_find toSV;
   static out_literal_find *fromSV;
   static char *trans;

#if DLEVEL >= 5
   printf("star_find\n"); 
#endif

   toSV.query = i;
   toSV.WhatLit = 3;

   fromSV = r_literal_find_1( &toSV, cl );
   if( !fromSV ) {
        clnt_perror( cl, "c_star_find" ); 
    exit(2);
   }


   trans = fromSV->o2.id1;
   *id=trans;

   return( fromSV->success );
}


int c_star_freequery( q )
   int q;
{
   in_literal_freequery toSV;

#if DLEVEL >= 5
   printf("star_freequery.\n"); 
#endif

  
   toSV.query = *((int*) BIM_Prolog_get_repeat_units(q));
   toSV.WhatLit = 3;
   
   r_literal_freequery_1( &toSV, cl );

   return( 1 );
}

int c_star_getquery( label, address, dataadr )
   char *label;
   void **address, **dataadr;
{
   static in_literal_getquery toSV;
   static out_getquery *fromSV;

#if DLEVEL >= 5
   printf("star GetQuery.\n");
#endif

   toSV.o2.id1=label;
   toSV.o2.id2="empty";
   toSV.WhatLit = 3;

   fromSV = r_literal_getquery_1( &toSV, cl );
   if( !fromSV ) {
      clnt_perror( cl, "star_getquery" );
      exit(2);
   }

   *address = &c_star_freequery;
   *dataadr = &(fromSV->nr);
 

   return( fromSV->nr );
}

int c_star_getid( s )
   char **s;
{
   static out_getid *fromSV;
   int toSV;   

#if DLEVEL >= 5
   printf("star getid.\n"); 
#endif

   toSV = 3;  /* Literalnummer */

   fromSV = r_literal_getid_1( toSV, cl );
   if( !fromSV ) {
      clnt_perror( cl, "Adot_getid" );
      exit(2);
   }


   *s = fromSV->id;

   return( 1 );
}

/***************************************************************************/

int c_create_name2id( in, out )
   char *in;
   char **out;
{
   out_create_name2id *fromSV;
   in_create_name2id toSV;
#if DLEVEL >= 5
   printf("create_name2id.\n"); 
#endif

   toSV.name = in;

   fromSV = r_create_name2id_1( &toSV, cl );
   if( !fromSV ) {
      clnt_perror( cl, "c_create_name2id" );
      exit(2);
   }


   *out = fromSV->oid;

   return( fromSV->success );
}


int c_name2id( in, out )
   char *in;
   char **out;
{
   out_name2id *fromSV;
   in_name2id toSV;

#if DLEVEL >= 5
   printf("name2id.\n"); 
#endif

   toSV.name = in;

   fromSV = r_name2id_1( &toSV, cl );
   if( !fromSV ) {
      clnt_perror( cl, "c_name2id" );
      exit(2);
   }

   *out = fromSV->oid;

   return( fromSV->success );
}


int c_id2name( in, out )
   char *in;
   char **out;
{
   out_id2name *fromSV;
   in_id2name toSV;
#if DLEVEL >= 5
   printf("id2name.\n"); 
#endif

   toSV.oid = in;

   fromSV = r_id2name_1( &toSV, cl );
   if( !fromSV ) {
      clnt_perror( cl, "c_id2name" );
      exit(2);
   }

   *out = fromSV->name;

   return( fromSV->success );
}


int c_select2id( in, out )
   char *in;
   char **out;
{
   out_select2id *fromSV;
   in_select2id toSV;
#if DLEVEL >= 5
  printf("select2id.\n"); 
#endif


   toSV.name = in;

   fromSV = r_select2id_1( &toSV, cl );
   if( !fromSV ) {
      clnt_perror( cl, "c_select2id" );
      exit(2);
   }

   *out = fromSV->oid;

   return( fromSV->success );
}


int c_id2select( in, out )
   char *in;
   char **out;
{
   out_id2select *fromSV;
   in_id2select toSV;
#if DLEVEL >= 5
   printf("is2select.\n"); 
#endif

   toSV.oid = in;

   fromSV = r_id2select_1( &toSV, cl );
   if( !fromSV ) {
      clnt_perror( cl, "c_id2select" );
      exit(2);
   }


   *out = fromSV->name;

   return( fromSV->success );
}

int c_id2time( in, milsec, sec, min, hour, mday, mon, year )
   char *in;
   int *milsec, *sec, *min, *hour, *mday, *mon, *year;
{
   out_id2time *fromSV;
   in_id2time toSV;

#if DLEVEL >= 5
   printf("id2time.\n"); 
#endif

   toSV.oid = in;

   fromSV = r_id2time_1( &toSV, cl );
   if( !fromSV ) {
      clnt_perror( cl, "c_id2time" );
      exit(2);
   }

   *milsec = fromSV->milsec;
   *sec = fromSV->sec;
   *min = fromSV->min;
   *hour = fromSV->hour;
   *mday = fromSV->mday;
   *mon = fromSV->mon;
   *year = fromSV->year;

   return( fromSV->success );
}

int c_check_implicit( in )
   char *in;
{
    in_id2select toSV;
    int *fromSV;

    toSV.oid = in;

#if DLEVEL >= 5
    printf("check_implicit.\n");
#endif
   fromSV = r_check_implicit_1( &toSV, cl );
   if( !fromSV ) {
      clnt_perror( cl, "check_implicit" );
      exit(2);
   }

   return *fromSV;
}

int c_create_node( node )
   char **node;
{
   in_create_node  toSV;
   out_create_node *fromSV;

#if DLEVEL >= 5
   printf("create_node.\n"); 
#endif
   toSV.p4.id  = node[0];
   toSV.p4.src = node[1];
   toSV.p4.lab = node[2];
   toSV.p4.dst = node[3];

   fromSV = r_create_node_1( &toSV, cl );
   if( !fromSV ) {
      clnt_perror( cl, "c_create_node" );
      exit(2);
   }

   node[0] = fromSV->p4.id;
   node[1] = fromSV->p4.src;
  /* node[2] = fromSV->p4.lab; */
   node[3] = fromSV->p4.dst;

   return( fromSV->success );
}

int c_create_implicit_node( node )
   char **node;
{
   in_create_node  toSV;
   out_create_node *fromSV;

#if DLEVEL >= 5
   printf("create_impl_node.\n"); 
#endif
   toSV.p4.id  = node[0];
   toSV.p4.src = node[1];
   toSV.p4.lab = node[2];
   toSV.p4.dst = node[3];

   fromSV = r_create_implicit_node_1( &toSV, cl );
   if( !fromSV ) {
      clnt_perror( cl, "c_create_impl_node" );
      exit(2);
   }

   node[0] = fromSV->p4.id;
   node[1] = fromSV->p4.src;
   node[2] = fromSV->p4.lab;
   node[3] = fromSV->p4.dst;

   return( fromSV->success );
}

int c_create_link( node )
   char **node;
{
   in_create_link  toSV;
   out_create_link *fromSV;

#if DLEVEL >= 5
   printf("create_link.\n"); 
#endif
 toSV.p4.id  = node[0];
   toSV.p4.src = node[1];
   toSV.p4.lab = node[2];
   toSV.p4.dst = node[3];

   fromSV = r_create_link_1( &toSV, cl );
   if( !fromSV ) {
      clnt_perror( cl, "c_create_link" );
      exit(2);
   }

   node[0] = fromSV->p4.id;
   node[1] = fromSV->p4.src;
   node[2] = fromSV->p4.lab;
   node[3] = fromSV->p4.dst;

   return( fromSV->success );
}

void c_insert_commit()
{
#if DLEVEL >= 5
    printf("insert_commit.\n"); 
#endif
   r_insert_commit_1( 0, cl );
}

void c_insert_abort()
{
#if DLEVEL >= 5
    printf("insert_abort.\n"); 
#endif
  r_insert_abort_1( 0, cl );
}

int c_remove( in )
   char *in;
{
   int *fromSV;
   in_remove toSV;
#if DLEVEL >= 5
    printf("remove.\n"); 
#endif

   toSV.oid = in;

   fromSV = r_remove_1( &toSV, cl );
   if( !fromSV ) {
      clnt_perror( cl, "c_remove" );
      exit(2);
   }


   return( *fromSV );
}


void c_remove_abort()
{
#if DLEVEL >= 5
     printf("remove_abort.\n"); 
#endif
  r_remove_abort_1( 0, cl );
}

void c_remove_end()
{
#if DLEVEL >= 5
    printf("remove_end.\n"); 
#endif
   r_remove_end_1( 0, cl );
}




int c_rename(newname,oldname)
   char *newname,*oldname;
{
   int *fromSV;
   in_rename toSV;

   toSV.newname = newname;
   toSV.oldname = oldname;

   fromSV = r_rename_1( &toSV, cl );
   if( !fromSV ) {
      clnt_perror( cl, "c_rename" );
      exit(2);
   }

   return( *fromSV );
   
}




void c_set_act()
{
#if DLEVEL >= 5
     printf("set_act.\n"); 
#endif
 r_set_act_1( 0, cl );
}


void c_set_temp()
{
#if DLEVEL >= 5
    printf("set_temp.\n"); 
#endif
   r_set_temp_1( 0, cl );
}

void c_set_overrule_temp()
{
#if DLEVEL >= 5
    printf("set_overrule_temp.\n"); 
#endif
   r_set_overrule_temp_1( 0, cl );
}

void c_set_overrule_temp_tell()
{
#if DLEVEL >= 5
    printf("set_overrule_temp_tell.\n"); 
#endif
   r_set_overrule_temp_tell_1( 0, cl );
}

void c_set_overrule_temp_untell()
{
#if DLEVEL >= 5
    printf("set_overrule_temp_untell.\n"); 
#endif
   r_set_overrule_temp_untell_1( 0, cl );
}

void c_set_overrule_act()
{
#if DLEVEL >= 5
    printf("set_overrule_act.\n"); 
#endif
   r_set_overrule_act_1( 0, cl );
}

void c_set_hist()
{
#if DLEVEL >= 5
    printf("set_hist.\n"); 
#endif
  r_set_hist_1( 0, cl );
}

void c_set_act_temp()
{
#if DLEVEL >= 5
   printf("set_act_temp.\n"); 
#endif
  r_set_act_temp_1( 0, cl );
}

void c_set_act_hist()
{
#if DLEVEL >= 5
   printf("set_act_hist.\n"); 
#endif
  r_set_act_hist_1( 0, cl );
}

void c_set_new_DB()
{
#if DLEVEL >= 5
   printf("set_new_DB.\n"); 
#endif
  r_set_new_db_1( 0, cl );
}

void c_set_old_DB()
{
#if DLEVEL >= 5
   printf("set_old_DB.\n"); 
#endif
  r_set_old_db_1( 0, cl );
}

void c_set_current_DB()
{
#if DLEVEL >= 5
   printf("set_current_DB.\n"); 
#endif
  r_set_current_db_1( 0, cl );
}

int c_get_sys_class( in, out )
   char *in;
   char **out;
{
   out_get_sys_class *fromSV;
   in_get_sys_class toSV;

#if DLEVEL >= 5
    printf("get_sys_class.\n"); 
#endif
   toSV.name = in;

   fromSV = r_get_sys_class_1( &toSV, cl );
   if( !fromSV ) {
      clnt_perror( cl, "c_get_sys_class" );
      exit(2);
   }

   *out = fromSV->oid;

   return( fromSV->success );
}

int c_get_prop_id( out )
   char **out;
{
   out_get_prop_id *fromSV;

#if DLEVEL >= 5
    printf("get_prop_id.\n"); 
#endif
   fromSV = r_get_prop_id_1( 0, cl );
   if( !fromSV ) {
      clnt_perror( cl, "c_get_prop_id" );
      exit(2);
   }

   *out = fromSV->oid;

   return( fromSV->success );
}


void c_set_time_point( milsec, sec, min, hour, mday, mon, year  )
  int milsec, sec, min, hour, mday, mon, year;
{

  in_set_time_point toSV;
#if DLEVEL >= 5
    printf("set_time_point.\n"); 
#endif
    toSV.milsec = milsec;
    toSV.sec = sec;
    toSV.min = min;
    toSV.hour = hour; 
    toSV.mday = mday;
    toSV.mon = mon;
    toSV.year = year;

    r_set_time_point_1( &toSV, cl );
}

void c_set_search_point( milsec, sec, min, hour, mday, mon, year  )
  int milsec, sec, min, hour, mday, mon, year;
{

    in_set_time_point toSV;
#if DLEVEL >= 5
    printf("set_time_point.\n"); 
#endif
    toSV.milsec = milsec;
    toSV.sec = sec;
    toSV.min = min;
    toSV.hour = hour; 
    toSV.mday = mday;
    toSV.mon = mon;
    toSV.year = year;

    r_set_search_point_1( &toSV, cl );
}


void c_delete_history_db(ms, s, mi, h, d, m, y)
    int ms,s,mi,h,d,m,y;
{
    in_set_time_point toSV;
#if DLEVEL >= 5
    printf("delete_history_db.\n"); 
#endif
    toSV.milsec = ms;
    toSV.sec = s;
    toSV.min = mi;
    toSV.hour = h; 
    toSV.mday = d;
    toSV.mon = m;
    toSV.year = y;

    r_delete_history_db_1(&toSV, cl);
}



/*****************************************************************************/

int c_findM( i, tuple )
   int i;
   char ***tuple;
{
   in_find toSV;
   static out_findM *fromSV;
   static char *trans[5];

#if DLEVEL >= 5
   printf("c_findM\n"); 
#endif

   toSV.query = i;

   fromSV = r_findm_1( &toSV, cl );
   if( !fromSV ) {
        clnt_perror( cl, "c_findM" ); 
    exit(2);
   }

   trans[0] = fromSV->p5.id;
   trans[1] = fromSV->p5.src;
   trans[2] = fromSV->p5.lab;
   trans[3] = fromSV->p5.dst;
   trans[4] = fromSV->p5.mod;
   *tuple=trans;
   return( fromSV->success );
}


int c_getqueryM( tuple, address, dataadr )
   char *tuple[5];
   void **address, **dataadr;
{
   static in_getqueryM toSV;
   static out_getquery *fromSV;

#if DLEVEL >= 5
   printf("GetQueryM.\n");
#endif

   toSV.p5.id=tuple[0];
   toSV.p5.src=tuple[1];
   toSV.p5.lab=tuple[2];
   toSV.p5.dst=tuple[3];
   toSV.p5.mod=tuple[4];

   fromSV = r_getquerym_1( &toSV, cl );
   if( !fromSV ) {
      clnt_perror( cl, "c_getquery" );
      exit(2);
   }

   *address = &c_freequery;
   *dataadr = &(fromSV->nr);
 

   return( fromSV->nr );
}

int c_set_module( in )
char *in;
{
    in_module toSV;
    int *fromSV;

    toSV.oid = in;

    fromSV = r_set_module_1( &toSV, cl );
    if( !fromSV ) {
	clnt_perror( cl, "c_set_module" );
	exit(2);
    }
    
    return ( *fromSV );
}

int c_set_overrule_module( in )
char *in;
{
    in_module toSV;
    int *fromSV;

    toSV.oid = in;

    fromSV = r_set_overrule_module_1( &toSV, cl );
    if( !fromSV ) {
	clnt_perror( cl, "c_set_overrule_module" );
	exit(2);
    }
    
    return ( *fromSV );
}

int c_system_module( in )
char *in;
{
    in_module toSV;
    int *fromSV;

    toSV.oid = in;

    fromSV = r_system_module_1( &toSV, cl );
    if( !fromSV ) {
	clnt_perror( cl, "c_system_module" );
	exit(2);
    }
    
    return ( *fromSV );
}

int c_initialize_module( in )
char *in;
{
    in_module toSV;
    int *fromSV;

    toSV.oid = in;

    fromSV = r_initialize_module_1( &toSV, cl );
    if( !fromSV ) {
	clnt_perror( cl, "c_initialize_module" );
	exit(2);
    }
    
    return ( *fromSV );
}

int c_new_export( in )
char *in;
{
    in_module toSV;
    int *fromSV;

    toSV.oid = in;

    fromSV = r_new_export_1( &toSV, cl );
    if( !fromSV ) {
	clnt_perror( cl, "c_new_export" );
	exit(2);
    }
    
    return ( *fromSV );
}

int c_delete_export( in )
char *in;
{
    in_module toSV;
    int *fromSV;

    toSV.oid = in;

    fromSV = r_delete_export_1( &toSV, cl );
    if( !fromSV ) {
	clnt_perror( cl, "c_delete_export" );
	exit(2);
    }
    
    return ( *fromSV );
}

int c_new_import( in )
char *in;
{
    in_module toSV;
    int *fromSV;

    toSV.oid = in;

    fromSV = r_new_import_1( &toSV, cl );
    if( !fromSV ) {
	clnt_perror( cl, "c_new_import" );
	exit(2);
    }
    
    return ( *fromSV );
}

int c_delete_import( in )
char *in;
{
    in_module toSV;
    int *fromSV;

    toSV.oid = in;

    fromSV = r_delete_import_1( &toSV, cl );
    if( !fromSV ) {
	clnt_perror( cl, "c_delete_import" );
	exit(2);
    }
    
    return ( *fromSV );
}



/*****************************************************************************/

int c_update_zaehler( in, box, result )
char *in;
int  box;
long *result;
{
    in_zaehler toSV;
    out_zaehler *fromSV;

    toSV.oid = in;
    toSV.box = box;

    fromSV = r_update_zaehler_1( &toSV, cl );
    if( !fromSV ) {
	clnt_perror( cl, "c_update_zaehler" );
	exit(2);
    }
    
    *result = fromSV->count;
    return ( fromSV->success );
}

int c_update_zaehler_ohne_huelle( in, box, result )
char *in;
int  box;
long *result;
{
    in_zaehler toSV;
    out_zaehler *fromSV;

    toSV.oid = in;
    toSV.box = box;

    fromSV = r_update_zaehler_ohne_huelle_1( &toSV, cl );
    if( !fromSV ) {
	clnt_perror( cl, "c_update_zaehler_ohne_huelle" );
	exit(2);
    }
    
    *result = fromSV->count;
    return ( fromSV->success );
}

int c_get_zaehler( in, box, result )
char *in;
int  box;
long *result;
{
    in_zaehler toSV;
    out_zaehler *fromSV;

    toSV.oid = in;
    toSV.box = box;

    fromSV = r_get_zaehler_1( &toSV, cl );
    if( !fromSV ) {
	clnt_perror( cl, "c_get_zaehler" );
	exit(2);
    }
    
    *result = fromSV->count;
    return ( fromSV->success );
}

int c_start_get_histogramm( in, dir )
char *in;
int  dir;
{
    in_zaehler toSV;
    int *fromSV;

    toSV.oid = in;
    toSV.box = dir;

    fromSV = r_start_get_histogramm_1( &toSV, cl );
    if( !fromSV ) {
	clnt_perror( cl, "c_start_get_histogramm" );
	exit(2);
    }
    
    return ( *fromSV );
}

int c_get_histogramm( out, result )
char **out;
long *result;
{
    out_get_histogramm *fromSV;

    fromSV = r_get_histogramm_1( 0, cl );
    if( !fromSV ) {
	clnt_perror( cl, "c_get_histogramm" );
	exit(2);
    }
    
    *out = fromSV->oid;
    *result = fromSV->count;

    return ( fromSV->success );
}

int c_update_histogramm( in, dir )
char *in;
int  dir;
{
    in_zaehler toSV;
    int *fromSV;

    toSV.oid = in;
    toSV.box = dir;

    fromSV = r_update_histogramm_1( &toSV, cl );
    if( !fromSV ) {
	clnt_perror( cl, "c_update_histogramm" );
	exit(2);
    }
    
    return ( *fromSV );
}

int c_update_histogramm_with_restr( in, dir, src, dst )
char *in;
int  dir;
char *src;
char *dst;
{
    in_upd_restr_hist toSV;
    int *fromSV;

    toSV.oid = in;
    toSV.box = dir;
    toSV.src = src;
    toSV.dst = dst;

    fromSV = r_update_histogramm_with_restr_1( &toSV, cl );
    if( !fromSV ) {
	clnt_perror( cl, "c_update_histogramm" );
	exit(2);
    }
    
    return ( *fromSV );
}


