/*
The ConceptBase.cc Copyright

Copyright 1987-2025 The ConceptBase Team. All rights reserved.

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

int c_init( char* in );
void c_test();
void c_done();

int c_find( int i, char ***tuple );
int c_findM( int i,char ***tuple );
int c_getquery(char * tuple[4]);
int c_getqueryM(char * tuple[5]);
int c_getid(char ** s );
int c_Attr_s_find(int i,char *** tuple );
int c_Attr_s_getquery(char * tuple[2] );
int c_Attr_s_getid(char **s );
int c_In_s_find(int i,char *** tuple );
int c_In_s_getquery(char * tuple[2] );
int c_In_s_getid(char **s );
int c_In_i_find(int i,char ***tuple );
int c_In_i_getquery( char *tuple[2] );
int c_In_i_getid(char ** s );
int c_Isa_find(int i,char ***tuple );
int c_Isa_getquery(char * tuple[2]);
int c_Isa_getid( char **s );
int c_sys_class_find(int i, char ***tuple );
int c_sys_class_getquery(char * tuple[2]);
int c_sys_class_getid(  char **s );
int c_Adot_find(int i, char ***tuple );
int c_Adot_getquery( char *tuple[4]);
int c_Adot_getid( char **s );
int c_Aidot_find(int i, char ***tuple );
int c_Aidot_getquery( char *tuple[4]);
int c_Aidot_getid( char **s );
int c_A_find(int i, char ***tuple );
int c_A_getquery( char *tuple[3] );
int c_A_getid( char **s );
int c_star_find(int i, char **id );
int c_star_getquery( char *label );
int c_star_getid(  char **s );
int c_create_name2id( char *in, char **out );
int c_name2id( char *in, char **out );
int c_id2name( char *in, char **out );
int c_select2id( char *in, char **out );
int c_id2select( char *in, char **out );
int c_id2starttime( char *in, int *milsec, int *sec, int *min, int *hour, int *mday, int *mon, int *year );
int c_id2endtime( char *in, int *milsec, int *sec, int *min, int *hour, int *mday, int *mon, int *year );
int c_check_implicit( char *in );
int c_create_node(  char *name, char **id );
int c_create_implicit_node( char* name, char **id);
int c_create_link( char** id, char* src, char* lab, char* dst );
void c_insert_commit();
void c_insert_abort();
int c_remove( char *in );
int c_removetmp( char *in );
void c_remove_abort();
void c_remove_end();
int c_rename(char *newname,char *oldname);
int c_changeAttrValue(char *attrname,char * newdest);
void c_set_act();
void c_set_persistency_level(int newlevel);
void c_set_temp();
void c_set_overrule_temp();
void c_set_overrule_temp_tell();
void c_set_overrule_temp_untell();
void c_set_overrule_act();
void c_set_hist();
void c_set_act_temp();
void c_set_act_hist();
void c_set_old_DB();
void c_set_new_DB();
void c_set_current_DB();
int c_get_sys_class( char *in, char **out );
int c_get_prop_id( char **out );
void c_set_time_point(int milsec,int sec,int min,int hour,int mday,int mon,int year  );
void c_set_search_point(int milsec,int sec,int min,int hour,int mday,int mon,int year  );
void c_delete_history_db(int ms,int s,int mi,int h,int d,int m,int y);
int c_set_module( char *in );
int c_set_overrule_module( char *in );
int c_system_module( char *in );
int c_initialize_module( char *in );
int c_new_export( char *in );
int c_delete_export( char *in );
int c_new_import( char *in );
int c_delete_import( char *in );
int c_update_zaehler( char *in, int box, long *result );
int c_update_zaehler_ohne_huelle( char *in, int box, long *result );
int c_get_zaehler( char *in, int box, long *result  );
int c_start_get_histogramm( char *in, int dir );
int c_get_histogramm( char **out, long *result );
int c_update_histogramm( char *in,int dir );
int c_update_histogramm_with_restr( char *in, int dir, char *src, char *dst );
