/*
The ConceptBase.cc Copyright

Copyright 1987-2020 The ConceptBase Team. All rights reserved.

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


int init(char*);
int done();
void test();
#ifdef BPextern_h
void algebra_test(BP_Term,BP_Term);
#endif
int find(int,char**);
int getquery(char**);
int getid(char**); 
int freequery(int);
int Literal_find(int,char**,int);
int Literal_getquery(char**,int);
int Literal_getid(char**,int);
int Literal_freequery(int,int);

int Literal4_find(int,char**,int);
int Literal4_getquery(char**,int);

int Literal3_find(int,char**,int);
int Literal3_getquery(char**,int);

int star_find(int,char**);
int star_getquery(char*);

int create_node(char**);
int create_implicit_node(char**);
int create_link(char**);
void insert_commit();
void insert_abort();
int name2id(char*,char**);
int create_name2id(char*,char**);
int id2name(char*,char**);
int select2id(char*, char**);
int id2select(char*, char**);
int id2time(char*,int*,int*,int*,int*,int*,int*,int*); 
int check_implicit(char*);
int remove_(char*);
void remove_end();
void remove_abort();
int rename_object(char*,char*);
void set_act();
void set_temp();
void set_overrule_temp();
void set_overrule_temp_tell();
void set_overrule_temp_untell();
void set_overrule_act();
void set_hist();
void set_act_temp();
void set_act_hist();
void set_new_db();
void set_old_db();
void set_current_db();
int get_sys_class(char*, char**);
int get_prop_id(char**);
void set_time_point( int, int, int, int, int, int, int);
void set_search_point( int, int, int, int, int, int, int);
int update_zaehler(char*,int,long*);
int update_zaehler_ohne_huelle(char*,int,long*);
int get_zaehler(char*,int,long*);
int update_histogramm(char*,int);
int update_histogramm_with_restr(char*,int,char*,char*);
int start_get_histogramm(char*,int);
int get_histogramm(char**,long*);
int findM(int,char**);
int getqueryM(char**);
int set_module(char*);
int set_overrule_module(char*);
int system_module(char*);
int initialize_module(char*);
int new_export(char*);
int delete_export(char*);
int new_import(char*);
int delete_import(char*);
void delete_history_db(int, int, int, int, int, int, int);
