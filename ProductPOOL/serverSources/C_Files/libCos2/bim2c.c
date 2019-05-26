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
#include "BPextern.h"
#include "trans_c.h"

/* extern int *BIM_Prolog_get_repeat_units(int); */


char trans[1024];

int c_init( in )
char *in;
{
  return init( in );
}

void c_test()
{
  test();
}

void c_algebra_test( BP_Term term1, BP_Term term2 )
{
//    algebra_test(term1,term2);
}

void c_done() 
{
   done();
}




int c_find( int i, char ***tuple )
{
   int res;
   static char *output[4];

#if DLEVEL >= 5
    printf("find.\n"); 
#endif

   res = find( i, output );
   *tuple = output;

   return( res );
}

int c_findM( int i,char ***tuple )
{
   int res;
   static char *output[5];

#if DLEVEL >= 5
    printf("find.\n"); 
#endif

   res = findM( i, output );
   *tuple = output;
   return( res );
}


int c_freequery(int q )
{
   int toSV;

#if DLEVEL >= 5
   printf("freequery.\n"); 
#endif

   toSV = *((int*) BIM_Prolog_get_repeat_units(q));

   freequery( toSV );

   return( 1 );
}

int c_getquery(char * tuple[4],void ** address,void ** dataadr )
{

  static int nr;

#if DLEVEL >= 5
   printf("GetQuery.\n");
#endif

   nr = getquery( tuple );
 
   *address = &c_freequery;
   *dataadr = &nr;

   return nr;
}

int c_getqueryM(char * tuple[5],void ** address,void ** dataadr) 
{

  static int nr;

#if DLEVEL >= 5
   printf("GetQueryM.\n");
#endif

   nr = getqueryM( tuple );
 
   *address = &c_freequery;
   *dataadr = &nr;

   return nr;
}


int c_getid(char ** s )
{
  
#if DLEVEL >= 5
   printf("getid.\n"); 
#endif

   getid( s );

   return( 1 );
}


/*
*  The In_s Literal:
*/


int c_In_s_find(int i,char *** tuple )
{
   int res;
   static char *output[2];

#if DLEVEL >= 5
   printf("c_In_s_find\n"); 
#endif

   res = Literal_find(i,output, 0);

   *tuple=output;

   return( res );
}


int c_In_s_freequery(int q )
{
   int toSV;

#if DLEVEL >= 5
   printf("In_s_freequery.\n"); 
#endif

  
   toSV = *((int*) BIM_Prolog_get_repeat_units(q));
   
   Literal_freequery( toSV, 0 );

   return( 1 );
}

int c_In_s_getquery(char * tuple[2],void **address, void **dataadr )
{

  static int nr;
#if DLEVEL >= 5
   printf("In_s_GetQuery.\n");
#endif

   nr = Literal_getquery( tuple, 0 );

   *address = &c_In_s_freequery;
   *dataadr = &nr;
 

   return( nr );
}

int c_In_s_getid(char **s )
{

#if DLEVEL >= 5
   printf("getid.\n"); 
#endif

   Literal_getid( s, 0 );

   return( 1 );
}

/*****************************************************************************/

int c_In_i_find(int i,char ***tuple )
{
   int res;
   static char *output[2];

#if DLEVEL >= 5
   printf("c_In_i_find\n"); 
#endif

   res = Literal_find(i,output, 1 );

   *tuple=output;

   return( res );
}

int c_In_i_freequery(int q )
{
   int toSV;

#if DLEVEL >= 5
   printf("In_i_freequery.\n"); 
#endif

  
   toSV = *((int*) BIM_Prolog_get_repeat_units(q));
   
   Literal_freequery( toSV, 1 );

   return( 1 );
}

int c_In_i_getquery( char *tuple[2],void **address, void **dataadr )
{

  static int nr;
#if DLEVEL >= 5
   printf("In_i_GetQuery.\n");
#endif

   nr = Literal_getquery( tuple, 1 );

   *address = &c_In_i_freequery;
   *dataadr = &nr;
 

   return( nr );
}


int c_In_i_getid(char ** s )
{

#if DLEVEL >= 5
   printf("getid.\n"); 
#endif

   Literal_getid( s, 1 );

   return( 1 );
}


/*****************************************************************************/

int c_Isa_find(int i,char ***tuple )
{
   int res;
   static char *output[2];

#if DLEVEL >= 5
   printf("c_Isa_find\n"); 
#endif

   res = Literal_find(i,output, 6 );

   *tuple=output;

   return( res );
}

int c_Isa_freequery(int q )
{
   int toSV;

#if DLEVEL >= 5
   printf("Isa_freequery.\n"); 
#endif

  
   toSV = *((int*) BIM_Prolog_get_repeat_units(q));
   
   Literal_freequery( toSV, 6 );

   return( 1 );
}

int c_Isa_getquery(char * tuple[2],void ** address,void ** dataadr )
{

  static int nr;
#if DLEVEL >= 5
   printf("Isa_GetQuery.\n");
#endif

   nr = Literal_getquery( tuple, 6 );

   *address = &c_Isa_freequery;
   *dataadr = &nr;
 

   return( nr );
}


int c_Isa_getid( char **s )
{

#if DLEVEL >= 5
   printf("getid.\n"); 
#endif

   Literal_getid( s, 6 );

   return( 1 );
}


/*****************************************************************************/

int c_sys_class_find(int i, char ***tuple )
{
   int res;
   static char *output[2];

#if DLEVEL >= 5
   printf("c_sys_class_find\n"); 
#endif

   res = Literal_find(i,output, 4 );

   *tuple=output;

   return( res );
}

int c_sys_class_freequery(int q )
{
   int toSV;

#if DLEVEL >= 5
   printf("c_sys_class_freequery.\n"); 
#endif

  
   toSV = *((int*) BIM_Prolog_get_repeat_units(q));
   
   Literal_freequery( toSV, 4 );

   return( 1 );
}

int c_sys_class_getquery(char * tuple[2],void **address, void **dataadr )
{

  static int nr;
#if DLEVEL >= 5
   printf("c_sys_class_GetQuery.\n");
#endif

   nr = Literal_getquery( tuple, 4 );

   *address = &c_sys_class_freequery;
   *dataadr = &nr;
 

   return( nr );
}


int c_sys_class_getid(  char **s )
{

#if DLEVEL >= 5
   printf("c_sys_class_getid.\n"); 
#endif

   Literal_getid( s, 4 );

   return( 1 );
}
/*****************************************************************************/
/*
*  The Adot Literal:
*/

int c_Adot_find(int i, char ***tuple )
{
   int res;
   static char *trans[4];

#if DLEVEL >= 5
   printf("Adot_find\n"); 
#endif

   res = Literal4_find(i,trans,2);

   *tuple=trans;

   return( res );
}


int c_Adot_freequery(int q )
{
   int toSV;

#if DLEVEL >= 5
   printf("Adot_freequery.\n"); 
#endif

  
   toSV = *((int*) BIM_Prolog_get_repeat_units(q));
   
   Literal_freequery( toSV, 2 );

   return( 1 );
}

int c_Adot_getquery( char *tuple[4], void **address, void **dataadr )
{
   static int nr;

#if DLEVEL >= 5
   printf("Adot GetQuery.\n");
#endif

   nr = Literal4_getquery( tuple, 2 );

   *address = &c_Adot_freequery;
   *dataadr = &nr;
 

   return( nr );
}


int c_Adot_getid( char **s )
{

#if DLEVEL >= 5
   printf("getid.\n"); 
#endif

   Literal_getid( s,2);
   return( 1 );
}

/*****************************************************************************/
/*
*  The A Literal
*/

int c_A_find(int i, char ***tuple )
{
   int res;
   static char *trans[3];

#if DLEVEL >= 5
   printf("Adot_find\n"); 
#endif

   res = Literal3_find(i,trans,5);

   *tuple=trans;

   return( res );
}


int c_A_freequery(int q )
{
   int toSV;

#if DLEVEL >= 5
   printf("Adot_freequery.\n"); 
#endif

  
   toSV = *((int*) BIM_Prolog_get_repeat_units(q));
   
   Literal_freequery( toSV, 5 );

   return( 1 );
}

int c_A_getquery( char *tuple[3], void **address, void **dataadr )
{
   static int nr;

#if DLEVEL >= 5
   printf("Adot GetQuery.\n");
#endif

   nr = Literal3_getquery( tuple, 5 );

   *address = &c_A_freequery;
   *dataadr = &nr;
 

   return( nr );
}


int c_A_getid( char **s )
{

#if DLEVEL >= 5
   printf("getid.\n"); 
#endif

   Literal_getid( s,5);
   return( 1 );
}

/*****************************************************************************/
/*
*  The star search:
*/

int c_star_find(int i, char **id )
{
   int res;
   static char *output[1];

#if DLEVEL >= 5
   printf("star_find\n"); 
#endif


   res = star_find(i, output);

   *id=output[0];

   return( res );
}

int c_star_freequery(int q )
{
   int toSV;

#if DLEVEL >= 5
   printf("star_freequery.\n"); 
#endif

  
   toSV = *((int*) BIM_Prolog_get_repeat_units(q));
   
   Literal_freequery( toSV, 3 );

   return( 1 );
}

int c_star_getquery( char *label, void **address, void **dataadr )
{

  static int nr;
#if DLEVEL >= 5
   printf("star_GetQuery.\n");
#endif

   nr = star_getquery( label );

   *address = &c_star_freequery;
   *dataadr = &nr;
 
   return( nr );
}

int c_star_getid(  char **s )
{

#if DLEVEL >= 5
   printf("star_getid.\n"); 
#endif

   Literal_getid( s, 3 );

   return( 1 );
}


/***************************************************************************/


int c_create_name2id( char *in, char **out )
{
   int res;

#if DLEVEL >= 5
   printf("create_name2id.\n"); 
#endif


   res = create_name2id( in, out );
 

   return( res );
}


int c_name2id( char *in, char **out )
{
   int res;

#if DLEVEL >= 5
   printf("name2id.\n"); 
#endif


   res = name2id( in, out );


   return( res );
}


int c_id2name( char *in, char **out )
{
   int res;
#if DLEVEL >= 5
   printf("id2name.\n"); 
#endif


   res = id2name( in, out );

   return( res );
}


int c_select2id( char *in, char **out )
{
  int res;

#if DLEVEL >= 5
  printf("select2id.\n"); 
#endif


   res = select2id( in, out );


   return( res );
 }


int c_id2select( char *in, char **out )
{
   int res;
#if DLEVEL >= 5
   printf("is2select.\n"); 
#endif

   res = id2select( in, out );

   return( res );
}

int c_id2time( char *in, int *milsec, int *sec, int *min, int *hour, int *mday, int *mon, int *year )
{
    int res;
    res = id2time( in, milsec, sec, min, hour, mday, mon, year );
    return ( res );
}



int c_check_implicit( char *in )
{
    
    int res;
#if DLEVEL >= 5
    printf("check_implicit.\n");
#endif
   res = check_implicit  ( in );

   return( res );
}


int c_create_node(  char **node )
{
   int res;
#if DLEVEL >= 5
   printf("create_node.\n"); 
#endif

   res = create_node( node );

   return( res );
}

int c_create_implicit_node( char **node )
{
   int res;

#if DLEVEL >= 5
   printf("create_impl_node.\n"); 
#endif

   res = create_implicit_node( node );

   return( res );
}

int c_create_link( char **node )
{
   int res;

#if DLEVEL >= 5
   printf("create_link.\n"); 
#endif

   res = create_link( node );

   return( res );
}


void c_insert_commit()
{
#if DLEVEL >= 5
    printf("insert_commit.\n"); 
#endif
   insert_commit( );
}

void c_insert_abort()
{
#if DLEVEL >= 5
    printf("insert_abort.\n"); 
#endif
  insert_abort();
}

int c_remove( char *in )
{
  int res;
#if DLEVEL >= 5
    printf("remove.\n"); 
#endif

   res = remove_( in );
   return( res );
}


void c_remove_abort()
{
#if DLEVEL >= 5
     printf("remove_abort.\n"); 
#endif
  remove_abort();
}

void c_remove_end()
{
#if DLEVEL >= 5
    printf("remove_end.\n"); 
#endif
   remove_end();
}


int c_rename(char *newname,char *oldname)
{
   return rename_object( newname, oldname );
}



void c_set_act()
{
#if DLEVEL >= 5
     printf("set_act.\n"); 
#endif
 set_act();
}


void c_set_temp()
{
#if DLEVEL >= 5
    printf("set_temp.\n"); 
#endif
   set_temp();
}

void c_set_overrule_temp()
{
#if DLEVEL >= 5
    printf("set_overrule_temp.\n"); 
#endif
   set_overrule_temp();
}

void c_set_overrule_temp_tell()
{
#if DLEVEL >= 5
    printf("set_overrule_temp_tell.\n"); 
#endif
   set_overrule_temp_tell();
}

void c_set_overrule_temp_untell()
{
#if DLEVEL >= 5
    printf("set_overrule_temp_untell.\n"); 
#endif
   set_overrule_temp_untell();
}

void c_set_overrule_act()
{
#if DLEVEL >= 5
    printf("set_overrule_act.\n"); 
#endif
   set_overrule_act();
}


void c_set_hist()
{
#if DLEVEL >= 5
    printf("set_hist.\n"); 
#endif
  set_hist();
}

void c_set_act_temp()
{
#if DLEVEL >= 5
   printf("set_act_temp.\n"); 
#endif
  set_act_temp();
}

void c_set_act_hist()
{
#if DLEVEL >= 5
   printf("set_act_hist.\n"); 
#endif
  set_act_hist();
}

void c_set_old_DB()
{
#if DLEVEL >= 5
   printf("set_old_DB.\n"); 
#endif
  set_old_db();
}

void c_set_new_DB()
{
#if DLEVEL >= 5
   printf("set_new_DB.\n"); 
#endif
  set_new_db();
}

void c_set_current_DB()
{
#if DLEVEL >= 5
   printf("set_current_DB.\n"); 
#endif
  set_current_db();
}


int c_get_sys_class( char *in, char **out )
{
   int res;

#if DLEVEL >= 5
    printf("get_sys_class.\n"); 
#endif

   res = get_sys_class( in, out );


   return( res );
}

int c_get_prop_id( char **out )
{
   int res;
#if DLEVEL >= 5
    printf("get_prop_id.\n"); 
#endif
   res = get_prop_id( out );

   return( res );
}


void c_set_time_point(int milsec,int sec,int min,int hour,int mday,int mon,int year  )
{

#if DLEVEL >= 5
    printf("set_time_point.\n"); 
#endif

   set_time_point( milsec, sec, min, hour, mday, mon, year );
}

void c_set_search_point(int milsec,int sec,int min,int hour,int mday,int mon,int year  )
{

#if DLEVEL >= 5
    printf("set_search_point.\n"); 
#endif
   set_search_point( milsec, sec, min, hour, mday, mon, year );
}


void c_delete_history_db(int ms,int s,int mi,int h,int d,int m,int y)
{
    delete_history_db(ms, s, mi, h, d, m, y);
}

    
/***************************************************************************/

/*
 * und noch fuer die Module:
 */

int c_set_module( char *in )
{
   int res;

#if DLEVEL >= 5
    printf("set_module.\n"); 
#endif

   res = set_module( in );

   return( res );
}

int c_set_overrule_module( char *in )
{
   int res;

#if DLEVEL >= 5
    printf("set_overrule_module.\n"); 
#endif

   res = set_overrule_module( in );

   return( res );
}

int c_system_module( char *in )
{
   int res;

#if DLEVEL >= 5
    printf("system_module.\n"); 
#endif

   res = system_module( in );

   return( res );
}

int c_initialize_module( char *in )
{
   int res;

#if DLEVEL >= 5
    printf("initialize_module.\n"); 
#endif

   res = initialize_module( in );

   return( res );
}

int c_new_export( char *in )
{
   int res;

#if DLEVEL >= 5
    printf("new export.\n"); 
#endif

   res = new_export( in );

   return( res );
}

int c_delete_export( char *in )
{
   int res;

#if DLEVEL >= 5
    printf("delete export.\n"); 
#endif

   res = delete_export( in );

   return( res );
}

int c_new_import( char *in )
{
   int res;

#if DLEVEL >= 5
    printf("new import.\n"); 
#endif

   res = new_import( in );

   return( res );
}

int c_delete_import( char *in )
{
   int res;

#if DLEVEL >= 5
    printf("delete import.\n"); 
#endif

   res = delete_import( in );

   return( res );
}


/***************************************************************************/


int c_update_zaehler( char *in, int box, long *result )
{
    int res;
    res = update_zaehler( in, box, result );
    return ( res );
}

int c_update_zaehler_ohne_huelle( char *in, int box, long *result )
{
    int res;
    res = update_zaehler_ohne_huelle( in, box, result );
    return ( res );
}

int c_get_zaehler( char *in, int box, long *result  )
{
    int res;
    res = get_zaehler( in, box, result );
    return ( res );
}

int c_start_get_histogramm( char *in, int dir )
{
    int res;
    res = start_get_histogramm( in, dir );
    return ( res );
}

int c_get_histogramm( char **out, long *result )
{
    int res;
    res = get_histogramm( out, result );
    return ( res );
}

int c_update_histogramm( char *in,int dir )
{
    int res;
    res = update_histogramm( in, dir );
    return ( res );
}

int c_update_histogramm_with_restr( char *in, int dir, char *src, char *dst )
{
    int res;
    res = update_histogramm_with_restr( in, dir, src, dst );
    return ( res );
}

